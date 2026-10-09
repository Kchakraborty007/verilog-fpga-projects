# FSM Up/Down Counter

A 4-state finite-state-machine counter in Verilog. It counts up or down once per second, driven from the 100 MHz board clock through a built-in clock divider. Written in Vivado 2020.1 for the ZedBoard (Zynq-7020).

## How it works

The design has two parts inside one module (`rtl/FSMcounter.v`):

**1. Clock divider (100 MHz → 1 Hz).**
A 27-bit counter counts 0 → 49,999,999 on every `CLK` edge. That is 50 million cycles, or 0.5 s at 100 MHz. At the end of each count `slow_clock` flips, so it has a 1-second period (1 Hz).

**2. State machine (Moore).**
Four states in a ring. On every rising edge of `slow_clock` the FSM moves one step:

| `CountUP` | Direction |
|-----------|-----------|
| 1 | S0 → S1 → S2 → S3 → S0 → … |
| 0 | S0 → S3 → S2 → S1 → S0 → … |

The output depends only on the current state:

| State | `CountValue[3:0]` | Decimal |
|-------|-------------------|---------|
| S0 | `0000` | 0 |
| S1 | `0010` | 2 |
| S2 | `0100` | 4 |
| S3 | `0110` | 6 |

`RST` (active high) returns the FSM to S0 and clears the divider.

## Interface

| Port | Dir | Width | Description |
|------|-----|-------|-------------|
| `CLK` | in | 1 | 100 MHz board clock |
| `RST` | in | 1 | Reset, active high |
| `CountUP` | in | 1 | 1 = count up, 0 = count down |
| `CountValue` | out | 4 | Current count (0, 2, 4 or 6) |

## Repository layout

```text
FSMcounter/
├── rtl/
│   └── FSMcounter.v              design
├── tb/
│   ├── tb_fsmcounter_check.v     self-checking testbench (prints PASS / FAIL)
│   └── test_fsmcounter.v         original Vivado waveform testbench
├── build.tcl                     recreates the Vivado project
└── README.md
```

## Run the simulation

**Icarus Verilog** (from this folder):

```bash
iverilog -o sim rtl/FSMcounter.v tb/tb_fsmcounter_check.v
vvp sim
```

**Vivado:** run `vivado -source build.tcl`, then *Run Simulation → Run Behavioral Simulation*. The simulation top is `tb_fsmcounter_check`.

## Verification

`tb/tb_fsmcounter_check.v` checks:

- the value after reset (`0000`)
- five steps counting up, including the wrap from 6 back to 0
- four steps counting down, including the wrap from 0 to 6
- a reset in the middle of a count

Because the real divider takes a full second per step, the testbench loads the divider counter close to its terminal count before each step. The RTL is not modified for this.

Result: `PASS: all checks passed` with both Icarus Verilog 12 and the Vivado 2020.1 simulator (XSim, project created by `build.tcl`). The testbench was also tried against two deliberately broken copies of the design (wrong output code, wrong count direction); it reports `FAIL` for both.

The original `tb/test_fsmcounter.v` only simulates about 2 µs, so the divider never ticks and it shows only the reset state. It is kept as a waveform starting point.

## Status and next steps

- Verified in simulation. Pin constraints (`.xdc`) are not included in this folder yet.
- The FSM is clocked by a divided clock generated in logic. A common alternative is to keep one clock for everything and use a 1 Hz enable pulse instead.
- The divider limit (49,999,999) could be made a parameter so the design is easy to simulate without fast-forwarding.

## Tools

Vivado 2020.1 · target `xc7z020clg484-1` (ZedBoard, board part `em.avnet.com:zed:part0:1.4`)
