# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7vx485tffg1157-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/ma/Documents/GitHub/Round5_VHDL/Xilinx/Round5_VHDL/Round5_VHDL.cache/wt [current_project]
set_property parent.project_path C:/Users/ma/Documents/GitHub/Round5_VHDL/Xilinx/Round5_VHDL/Round5_VHDL.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property ip_output_repo c:/Users/ma/Documents/GitHub/Round5_VHDL/Xilinx/Round5_VHDL/Round5_VHDL.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/ma/Documents/GitHub/Round5_VHDL/Round5_constants.vhd
  C:/Users/ma/Documents/GitHub/Round5_VHDL/Lift_Poly.vhd
  C:/Users/ma/Documents/GitHub/Round5_VHDL/Mul_Poly.vhd
  C:/Users/ma/Documents/GitHub/Round5_VHDL/Mul_Poly_NTRU.vhd
  C:/Users/ma/Documents/GitHub/Round5_VHDL/Mul_Poly_NTRU_tri_unit.vhd
  C:/Users/ma/Documents/GitHub/Round5_VHDL/Unlift_Poly.vhd
  C:/Users/ma/Documents/GitHub/Round5_VHDL/add_sub_poly.vhd
  C:/Users/ma/Documents/GitHub/Round5_VHDL/add_sub_unit.vhd
  C:/Users/ma/Documents/GitHub/Round5_VHDL/round_element_ex.vhd
  C:/Users/ma/Documents/GitHub/Round5_VHDL/Round5_enc_arith.vhd
}
read_vhdl -vhdl2008 -library xil_defaultlib C:/Users/ma/Documents/GitHub/Round5_VHDL/round_poly_ex.vhd
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top Round5_enc_arith -part xc7vx485tffg1157-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef Round5_enc_arith.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file Round5_enc_arith_utilization_synth.rpt -pb Round5_enc_arith_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
