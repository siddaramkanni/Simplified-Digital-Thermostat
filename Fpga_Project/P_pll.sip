set_global_assignment -entity "P_pll" -library "lib_P_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "P_pll" -library "lib_P_pll" -name IP_TOOL_VERSION "16.0"
set_global_assignment -entity "P_pll" -library "lib_P_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_P_pll" -name SPD_FILE [file join $::quartus(sip_path) "P_pll.spd"]

set_global_assignment -library "lib_P_pll" -name MISC_FILE [file join $::quartus(sip_path) "P_pll_sim/P_pll.vho"]
