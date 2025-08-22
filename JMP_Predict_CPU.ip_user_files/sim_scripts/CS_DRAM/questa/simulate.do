onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib CS_DRAM_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {CS_DRAM.udo}

run -all

quit -force
