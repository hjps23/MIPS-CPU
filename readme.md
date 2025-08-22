### 环境部署

软件编译使用 vivado 2022.1

开发板采用  Xilinx Artix-7 系列 XC7A35T-1CSG324C FPGA

### 原理简介

本项目在24条指令的基础上加入了（multu/mult/divu/mflo/mfhi/lh/sltiu/sllv/bgtz) 9条指令，涵盖大部分处理逻辑。

基于气泡流水线实现的重定向逻辑：[BubleDel.v](https://github.com/hjps23/MIPS-CPU/blob/ps/JMP_Predict_CPU.srcs/sources_1/new/BubleDel.v)

基于重定向实现的动态分支预测逻辑：[BPB.v](https://github.com/hjps23/MIPS-CPU/blob/ps/JMP_Predict_CPU.srcs/sources_1/new/BPB.v)

动态分支预测逻辑采用双位预测状态机和全相联并发查找机制以及LRU置换算法实现。

### 运行示例

1.若软件编译采用 vivado 2022.1版本，拉取项目后，直接双击项目文件 [JMP_Predict_CPU.xpr](https://github.com/hjps23/MIPS-CPU/blob/ps/JMP_Predict_CPU.xpr) 即可运行，若是其他版本需考虑兼容问题，可以访问[source/new](https://github.com/hjps23/MIPS-CPU/tree/ps/JMP_Predict_CPU.srcs/sources_1/new)中的源码来进行编译。

2.由于存储器采用IP核，运行时需配置具体的IP核文件，将文件[benchmark_8_test.coe](https://github.com/hjps23/MIPS-CPU/blob/ps/ins/benchmark_8_test.coe)（此文件包含benchmark和9条指令的测试）载入CS_DRAM模块中即可，DS_DRAM模块也为IP核但无需初始化。

3.注意：CPU在测试完benchmark后会暂停，需要按下go按钮后继续执行后续指令测试，具体逻辑参考[CPU.v](https://github.com/hjps23/MIPS-CPU/blob/ps/JMP_Predict_CPU.srcs/sources_1/new/CPU.v)文件。



