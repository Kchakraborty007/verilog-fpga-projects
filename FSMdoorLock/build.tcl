# Recreates the Vivado project from the sources in this folder.
#
# Usage (run from anywhere; paths are resolved relative to this script):
#   vivado -mode batch -source build.tcl      ;# create project, then exit
#   vivado -source build.tcl                  ;# create project and stay in the GUI
#
# Then open build/FSMdoorLock.xpr.
# Developed with Vivado 2020.1. Target: xc7z020clg484-1 (ZedBoard / Zynq-7020).

set proj_name FSMdoorLock
set script_dir [file dirname [file normalize [info script]]]

create_project $proj_name $script_dir/build -part xc7z020clg484-1 -force
catch { set_property board_part em.avnet.com:zed:part0:1.4 [current_project] }

add_files          [glob $script_dir/rtl/*.v]
add_files -fileset sim_1    [glob $script_dir/tb/*.v]
add_files -fileset constrs_1 [glob $script_dir/constraints/*.xdc]

set_property top mainblock        [current_fileset]
set_property top tb_dlock_check   [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Project created in $script_dir/build"
