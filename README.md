# Verilog / FPGA Projects

Small digital-design projects written in Verilog and built with Vivado 2020.1 for the ZedBoard (Zynq-7020, `xc7z020clg484-1`).

## Projects

| Project | What it is | Status |
|---------|------------|--------|
| [FSMdoorLock](FSMdoorLock/) | Password door lock as a finite state machine: four buttons, debouncers, clock divider. Code is PB1, PB0, PB0, PB2. | FSM verified in simulation with a self-checking testbench. Implemented for the ZedBoard (bitstream generated). See the README for a known limitation. |
| [FSMcounter](FSMcounter/) | 4-state up/down counter driven by a 1 Hz clock divider (counts 0, 2, 4, 6). | Verified in simulation with a self-checking testbench. |

## How each project is laid out

```text
<project>/
├── rtl/            Verilog design files
├── tb/             testbenches (the *_check.v ones print PASS / FAIL)
├── constraints/    pin assignments (.xdc), where the project has them
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
```
