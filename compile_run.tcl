vlib work
vcom -work work vhdl/Rolling_max/rolling_max_types.vhdl 
vcom -work work vhdl/Rolling_max/rolling_max_window.vhdl 
vcom -work work vhdl/Rolling_max/rolling_max_localmax.vhdl
vcom -work work vhdl/Rolling_max/rolling_max_maxroll_specf.vhdl
vcom -work work vhdl/Rolling_max/rolling_max_maxroll.vhdl
vcom -work work vhdl/Rolling_max/rolling_max_topentity_0.vhdl
vcom -work work vhdl/Rolling_max/rolling_max_topentity.vhdl
vcom -work work signal_testbench.vhd

vsim work.signal_testbench
add wave sample_ctr
add wave -height 70 -analog -max 700 -min "-1400" -radix decimal filter_input
add wave -height 70 -color white -analog -max 700 -min "-1400" -radix decimal filter_output
add wave filter_clk
add wave filter_reset

run -all
wave zoom full
