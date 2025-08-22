`timescale 1ns / 1ps
module BPB(
    input wire clk,   
    input wire rst,   
    
    // ========== 预测接口 (在指令取指阶段IF使用) ==========
    input wire [31:0] pc_if,           // 当前取指阶段的程序计数器值
    output wire prediction,            // 预测结果：1预测分支发生，0预测不发生
    output wire [31:0] target_addr,    // 预测的分支目标地址
    
    // ========== 更新接口 (在指令译码阶段ID使用) ==========
    input wire update_en,              // 更新使能信号，表示需要更新预测器
    input wire [31:0] pc_ex,           // 译码阶段的PC值（分支指令地址）
    input wire actual_taken,           // 实际的分支结果（来自执行阶段）
    input wire [31:0] actual_target    // 实际的分支目标地址
);
    wire prediction_valid;              // 预测是否有效：1表示有有效预测
    // ========== 参数定义 ==========
    parameter ENTRIES = 16;            // BPB中条目（表项）的数量
    parameter TAG_WIDTH = 20;          // 地址标签的位宽（用于比较PC的高位）
    parameter LRU_BITS = 4;            // LRU计数器的位宽（用于替换算法）

    // ========== 状态机状态定义（两位饱和计数器） ==========
    // 用于记录和预测分支行为
    localparam STRONGLY_NOT_TAKEN = 2'b00; // 强烈不跳转
    localparam WEAKLY_NOT_TAKEN   = 2'b01; // 弱不跳转
    localparam WEAKLY_TAKEN       = 2'b10; // 弱跳转
    localparam STRONGLY_TAKEN     = 2'b11;  // 强烈跳转
    
    // ========== BPB表条目寄存器数组 ==========
    // 这些数组共同组成了BPB表，每个条目包含多个字段
    reg valid [0:ENTRIES-1];           // 有效位：1表示该条目有效
    reg [TAG_WIDTH-1:0] tag [0:ENTRIES-1]; // 地址标签（存储PC的高位）
    reg [1:0] state [0:ENTRIES-1];     // 双位预测器状态（使用上面定义的4种状态）
    reg [31:0] target [0:ENTRIES-1];   // 预测的目标地址
    reg [LRU_BITS-1:0] lru_count [0:ENTRIES-1]; // LRU计数器（用于实现最近最少使用替换算法）

    // ========== 内部临时信号声明 ==========
    wire [ENTRIES-1:0] tag_match;      // 每个位表示对应条目是否标签匹配
    wire hit;                          // 是否有条目匹配（即预测命中）
    integer i;                         
    
    // 用于LRU替换算法的临时信号
    reg [LRU_BITS-1:0] min_lru;        // 当前最小的LRU值
    reg [ENTRIES-1:0] min_lru_mask;    // 独热码，指示哪些条目具有最小的LRU值

    // ========== 标签比较逻辑 ==========
    generate
        for (genvar j = 0; j < ENTRIES; j = j + 1) begin : tag_comparison
            assign tag_match[j] = valid[j] && (tag[j] == pc_if[TAG_WIDTH-1:0]);
        end
    endgenerate

    // ========== 简化命中判断 ==========
    assign hit = |tag_match;
    assign prediction_valid = hit;

    // ========== 预测结果和目标地址选择逻辑 ==========
    reg pred_result;        // 内部寄存器，存储预测结果（是否跳转）
    reg [31:0] pred_target; // 内部寄存器，存储预测的目标地址
    
    always @(*) begin // 组合逻辑
        pred_result = 0;   // 默认预测不跳转
        pred_target = 0;   // 默认目标地址为0
        
        for (i = 0; i < ENTRIES; i = i + 1) begin
            if (tag_match[i]) begin
                pred_result = (state[i] >= WEAKLY_TAKEN) ? 1'b1 : 1'b0;
                pred_target = target[i];
                $display("[BPB] 预测命中: PC=%h, 条目索引=%d, 预测结果=%b, 目标地址=%h", 
                         pc_if, i, pred_result, pred_target);
            end
        end
        
        if (hit) begin
            $display("[BPB] 预测阶段: PC=%h, 命中=%b, 预测跳转=%b, 目标地址=%h", 
                     pc_if, hit, pred_result, pred_target);
        end else if (|pc_if) begin // 仅当pc_if非零时显示
            $display("[BPB] 预测阶段: PC=%h, 未命中BPB", pc_if);
        end
     end
    
    // 将内部寄存器的值输出到模块端口
    assign prediction = pred_result;
    assign target_addr = pred_target;

    // ========== LRU替换算法：查找最小LRU值的条目 ==========
    always @(*) begin
        min_lru = {LRU_BITS{1'b1}}; // 初始化为最大值（所有位为1）
        min_lru_mask = 0;           // 初始化为全0
        
        // 遍历所有条目，寻找最小的LRU值
        for (i = 0; i < ENTRIES; i = i + 1) begin
            if (lru_count[i] < min_lru) begin
                // 发现更小的LRU值，更新min_lru，并重置mask
                min_lru = lru_count[i];
                min_lru_mask = (1 << i); // 将对应位置1，其他为0
            end else if (lru_count[i] == min_lru) begin
                // 发现相同的LRU值，在mask中添加该条目
                min_lru_mask[i] = 1'b1;
            end
        end
    end
    
    // ========== 辅助函数：在具有最小LRU的条目中选择一个进行替换 ==========
    function integer find_replacement_entry;
        input [ENTRIES-1:0] lru_mask; // 输入参数：指示哪些条目具有最小LRU值
        integer k;
        reg found; 
        begin
            find_replacement_entry = 0; // 默认返回0号条目
            found = 0; // 初始化标志位
            
            // 遍历寻找第一个具有最小LRU的条目
            for (k = 0; k < ENTRIES; k = k + 1) begin
                if (!found && lru_mask[k]) begin
                    find_replacement_entry = k;
                    found = 1; // 设置标志位
                end
            end
            $display("[BPB] LRU替换算法: 选择索引%d进行替换", find_replacement_entry);
        end
    endfunction

    // ========== BPB表更新逻辑（在时钟上升沿或复位时触发） ==========
    integer found_index;   // 临时变量，记录找到的条目索引
    integer replace_index; // 临时变量，记录要替换的条目索引
    reg found_flag;        // 标志位
    reg [1:0] old_state;   // 用于记录更新前的状态
    
    initial begin
        // 初始化所有条目
        for (i = 0; i < ENTRIES; i = i + 1) begin
            valid[i] <= 1'b0;                  // 有效位置0
            tag[i] <= 0;                       // 标签清零
            state[i] <= WEAKLY_NOT_TAKEN;      // 状态初始化为弱不跳转
            target[i] <= 0;                    // 目标地址清零
            lru_count[i] <= i[LRU_BITS-1:0];   // LRU计数器初始化为不同的值（0,1,2,...）
        end
        $display("[BPB] BPB模块初始化完成，条目数=%d", ENTRIES);
     end
     
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 复位操作：初始化所有条目
            for (i = 0; i < ENTRIES; i = i + 1) begin
                valid[i] <= 1'b0;                  // 有效位置0
                tag[i] <= 0;                       // 标签清零
                state[i] <= WEAKLY_NOT_TAKEN;      // 状态初始化为弱不跳转
                target[i] <= 0;                    // 目标地址清零
                lru_count[i] <= i[LRU_BITS-1:0];   // LRU计数器初始化为不同的值（0,1,2,...）
            end
            $display("[BPB] 系统复位: BPB所有条目已初始化");
        end else if (update_en) begin // 更新使能有效，需要更新BPB
            $display("[BPB] 更新请求: PC=%h, 实际跳转=%b, 实际目标地址=%h", 
                     pc_ex, actual_taken, actual_target);
                     
            // 第一步：查找BPB中是否已有当前分支指令的条目
            found_index = -1; // 初始化为-1表示未找到
            found_flag = 0;   // 重置标志位
            for (i = 0; i < ENTRIES && !found_flag; i = i + 1) begin
                if (valid[i] && (tag[i] == pc_ex[TAG_WIDTH-1:0])) begin
                    found_index = i; // 记录找到的条目索引
                    found_flag = 1;  // 设置标志位
                    $display("[BPB] 找到现有条目: 索引=%d", i);
                end
            end
            
            // 第二步：根据是否找到条目进行更新或创建
            if (found_index != -1) begin
                // 情况1：找到现有条目，更新状态机和目标地址
                old_state = state[found_index]; // 记录旧状态
                
                // 根据当前状态和实际结果更新双位预测器状态
                case (state[found_index])
                    STRONGLY_NOT_TAKEN: 
                        // 当前强不跳转：实际跳转则变为弱不跳转，实际不跳转保持强不跳转
                        state[found_index] <= actual_taken ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
                    WEAKLY_NOT_TAKEN: 
                        // 当前弱不跳转：实际跳转变为弱跳转，实际不跳转变为强不跳转
                        state[found_index] <= actual_taken ? WEAKLY_TAKEN : STRONGLY_NOT_TAKEN;
                    WEAKLY_TAKEN: 
                        // 当前弱跳转：实际跳转变为强跳转，实际不跳转变为弱不跳转
                        state[found_index] <= actual_taken ? STRONGLY_TAKEN : WEAKLY_NOT_TAKEN;
                    STRONGLY_TAKEN: 
                        // 当前强跳转：实际跳转保持强跳转，实际不跳转变为弱跳转
                        state[found_index] <= actual_taken ? STRONGLY_TAKEN : WEAKLY_TAKEN;
                endcase
                
                // 更新目标地址（即使地址可能不变）
                target[found_index] <= actual_target;
                
                // 更新LRU计数器：将当前使用的条目计数器设为最大值
                lru_count[found_index] <= {LRU_BITS{1'b1}};
                
                // 减少其他所有条目的LRU值（模拟时间流逝）
                for (i = 0; i < ENTRIES; i = i + 1) begin
                    if (i != found_index && lru_count[i] > 0) begin
                        lru_count[i] <= lru_count[i] - 1;
                    end
                end
                
                $display("[BPB] 更新现有条目: 索引=%d, 旧状态=%b, 新状态=%b, 目标地址=%h", 
                         found_index, old_state, state[found_index], actual_target);
                
            end else if (actual_taken) begin
                // 情况2：未找到条目且实际发生了分支，需要创建新条目
                $display("[BPB] 未找到匹配条目，需要创建新条目");
                
                // 使用LRU算法选择要替换的条目
                replace_index = find_replacement_entry(min_lru_mask);
                
                // 创建新条目
                valid[replace_index] <= 1'b1; // 设置有效位
                tag[replace_index] <= pc_ex[TAG_WIDTH-1:0]; // 存储标签
                // 根据实际结果初始化状态：实际跳转则初始化为弱跳转，否则弱不跳转
                state[replace_index] <= actual_taken ? WEAKLY_TAKEN : WEAKLY_NOT_TAKEN;
                target[replace_index] <= actual_target; // 存储目标地址
                lru_count[replace_index] <= {LRU_BITS{1'b1}}; // 设置LRU为最大值
                
                // 减少其他所有条目的LRU值
                for (i = 0; i < ENTRIES; i = i + 1) begin
                    if (i != replace_index && lru_count[i] > 0) begin
                        lru_count[i] <= lru_count[i] - 1;
                    end
                end
                
                $display("[BPB] 创建新条目: 索引=%d, 标签=%h, 状态=%b, 目标地址=%h", 
                         replace_index, pc_ex[TAG_WIDTH-1:0], 
                         (actual_taken ? WEAKLY_TAKEN : WEAKLY_NOT_TAKEN), 
                         actual_target);
            end else begin
                $display("[BPB] 未找到匹配条目且分支未发生，无需更新");
            end
            // 注意：如果未找到条目且实际没有发生分支，则不创建新条目
        end
    end

endmodule