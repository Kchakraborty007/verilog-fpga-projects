# Recreates the Vivado project from the sources in this folder.
#
# Usage (run from anywhere; paths are resolved relative to this script):
#   vivado -mode batch -source build.tcl      ;# create project, then exit
#   vivado -source build.tcl                  ;# create project and stay in the GUI
#
# Then open build/Adder8bitVIO.xpr.
# Developed with Vivado 2020.1. Target: xc7z020clg484-1 (ZedBoard / Zynq-7020).

set proj_name Adder8bitVIO
set script_dir [file dirname [file normalize [info script]]]

create_project $proj_name $script_dir/build -part xc7z020clg484-1 -force
catch { set_property board_part em.avnet.com:zed:part0:1.4 [current_project] }

add_files                    [glob $script_dir/rtl/*.v]
add_files -fileset sim_1     [glob $script_dir/tb/*.v]
add_files -fileset constrs_1 [glob $script_dir/constraints/*.xdc]

# VIO debug core (Xilinx IP). import_ip copies it into build/, so the files
# Vivado generates for it never touch the sources in this folder.
import_ip $script_dir/ip/vio_0/vio_0.xci
generate_target all [get_ips vio_0]

set_property top main_adderVIO   [current_fileset]
set_property top tb_adder_check  [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Project created in $script_dir/build"
