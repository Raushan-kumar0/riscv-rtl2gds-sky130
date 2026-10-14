# constraints.sdc - the timing rules the layout tools must meet.
# An SDC file answers three questions: how fast is the clock, how much of each
# cycle does the outside world use up, and what do the pins connect to?

# 1. The clock: one clock on port 'clk'. Its period (ns) comes from CLOCK_PERIOD in config.json.
create_clock [get_ports clk] -name clk -period $::env(CLOCK_PERIOD)

# Real clocks jitter and arrive with skew; reserve a safety margin for that.
set_clock_uncertainty 0.25 [get_clocks clk]
set_clock_transition  0.15 [get_clocks clk]

# 2. I/O budget: assume the memories outside the core use 20% of each cycle
#    on the way in and 20% on the way out. The core gets the rest.
set io_delay [expr {$::env(CLOCK_PERIOD) * 0.2}]
set clk_port   [get_ports clk]
set clk_index  [lsearch [all_inputs] $clk_port]
set data_inputs [lreplace [all_inputs] $clk_index $clk_index]
set_input_delay  $io_delay -clock [get_clocks clk] $data_inputs
set_output_delay $io_delay -clock [get_clocks clk] [all_outputs]

# 3. What the pins connect to: inputs are driven by a small inverter,
#    outputs drive about 33 fF (0.033 pF) of load.
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin Y $data_inputs
set_load 0.033 [all_outputs]

# Keep any one gate from driving too many others (long, slow nets).
set_max_fanout 10 [current_design]
