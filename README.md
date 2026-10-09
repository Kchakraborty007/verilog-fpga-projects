# Verilog / FPGA Projects

Small digital-design projects written in Verilog and built with Vivado 2020.1 for the ZedBoard (Zynq-7020, `xc7z020clg484-1`).

## Projects

| Project | What it is | Status |
|---------|------------|--------|
| [FSMdoorLock](FSMdoorLock/) | Password door lock as a finite state machine: four buttons, debouncers, clock divider. Code is PB1, PB0, PB0, PB2. | FSM verified in simulation with a self-checking testbench. Implemented for the ZedBoard (bitstream generated). See the README for a known limitation. |
| [FSMcounter](FSMcounter/) | 4-state up/down counter driven by a 1 Hz clock divider (counts 0, 2, 4, 6). | Verified in simulation with a self-checking testbench. |
| [Adder8bitVIO](Adder8bitVIO/) | 8-bit ripple-carry adder built from full adders. Inputs are set live from Vivado Hardware Manager through a VIO debug core; the sum shows on the LEDs. | Exhaustive testbench (all 131,072 input combinations) passes. Implemented for the ZedBoard (bitstream generated). |
| [ParkingLot](ParkingLot/) | Parking-lot car counter: two gate sensors, an FSM that tells entry from exit, a 25-car limit, a FULL output and a blinking ERROR output. Car count is read through a VIO core. | FSM and full chain verified in simulation; synthesizes cleanly. No pin constraints yet, not run on a board. |

## How each project is laid out

```text
<project>/
├── rtl/            Verilog design files
├── tb/             testbenches (the *_check.v ones print PASS / FAIL)
├── constraints/    pin assignments (.xdc), where the project has them
├── ip/             Xilinx IP sources (.xci), where the project uses any
├── build.tcl       recreates the Vivado project
└── README.md
```

Only source files are stored here. Vivado's generated output is git-ignored, and `build.tcl` rebuilds the project from the sources.

## Run a project

**Vivado 2020.1:** `vivado -source <project>/build.tcl` creates the project in `<project>/build/`.

**Icarus Verilog** (free), from inside a project folder:

```bash
# FSMdoorLock
iverilog -o sim rtl/dlock.v tb/tb_dlock_check.v && vvp sim

# FSMcounter
iverilog -o sim rtl/FSMcounter.v tb/tb_fsmcounter_check.v && vvp sim

# Adder8bitVIO (the adder itself; the top level needs the Xilinx VIO core)
iverilog -o sim rtl/full_adder.v rtl/adder_8.v tb/tb_adder_check.v && vvp sim

# ParkingLot (state machine)
iverilog -o sim rtl/parklot.v tb/tb_parklot_check.v && vvp sim
```
