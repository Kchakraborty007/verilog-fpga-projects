# FSM-Based Digital Door Lock

A digital door-lock controller implemented in Verilog and deployed on an FPGA using Xilinx Vivado.

## Overview

This project implements a password-based digital door lock using a Finite State Machine (FSM).

The design accepts button inputs corresponding to the password sequence and transitions through different states depending on the user's input. A debounce circuit is used to prevent mechanical switch bouncing from being interpreted as multiple button presses.

## Architecture

The design consists of:

- **Door Lock FSM (`dlock.v`)** — Implements the password/state transition logic.
- **Debouncer (`debouncer.v`)** — Filters mechanical button bounce.
- **Clock Divider (`clockdivider.v`)** — Generates a slower clock suitable for button handling and control logic.
- **Top-Level Module (`mainblock.v`)** — Integrates the individual modules.
- **Testbench (`test_door.v`)** — Used to simulate and verify the door-lock behavior.
- **XDC Constraints (`dlstream.xdc`)** — Defines FPGA pin and timing constraints.

## Project Structure

```text
01_FSM_Doorlock/
│
├── constraints/
│   └── dlstream.xdc
│
├── rtl/
│   ├── clockdivider.v
│   ├── debouncer.v
│   ├── dlock.v
│   └── mainblock.v
│
└── tb/
    └── test_door.v