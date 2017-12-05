vcom -work work-modelsim signal_testbench.vhd

vsim work.signal_testbench
add wave sample_ctr
add wave -height 150 -analog -max 700 -min "-1400" -radix decimal filter_input
add wave -height 150 -color white -analog -max 240 -min 180 -radix decimal filter_output
add wave filter_clk
add wave filter_reset

run -all
wave zoom full
