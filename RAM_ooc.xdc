################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name RED_clk -period 10 [get_ports RED_clk]
create_clock -name GREEN_clk -period 10 [get_ports GREEN_clk]
create_clock -name BLUE_clk -period 10 [get_ports BLUE_clk]

################################################################################