# 8-bit Adder with VIO

An 8-bit ripple-carry adder built from eight 1-bit full adders. Instead of wiring up switches, the inputs are set live from Vivado's Hardware Manager through a **VIO** (Virtual Input/Output) debug core, and the result is read back in the same window and shown on the board's LEDs. Written in Vivado 2020.1 for the ZedBoard (Zynq-7020).

## How it works

```text
                       ┌──────────── main_adderVIO ─────────────┐
 Hardware Manager      │                                        │
 (over JTAG)  ──A[7:0]─┼─▶┌─────────┐                           │
              ──B[7:0]─┼─▶│ adder_8 │──Sum[7:0]─┬─▶ LD7…LD0     │
              ──Cin────┼─▶│         │──Cout─────┤               │
                       │  └─────────┘           │               │
              ◀────────┼───────── vio_0 ◀───────┘               │
              Sum, Cout│    (reads Sum and Cout back)           │
                       └────────────────────────────────────────┘
```

| Module | File | What it does |
|--------|------|--------------|
| `full_adder` | `rtl/full_adder.v` | `SUM = A ^ B ^ CIN`, `COUT` = majority of the three inputs. |
| `adder_8` | `rtl/adder_8.v` | Eight full adders in a chain. The carry out of each bit feeds the next bit ("ripples" from bit 0 to bit 7). |
| `main_adderVIO` | `rtl/main_adderVIO.v` | Top level. Connects `adder_8` to the VIO core and drives `Sum` onto the LEDs. |
| `vio_0` | `ip/vio_0/vio_0.xci` | Xilinx VIO core (v3.0), clocked by the 100 MHz board clock. |

**VIO probes** (from the IP configuration):

| Probe | Width | Direction | Signal |
|-------|-------|-----------|--------|
| `probe_out0` | 8 | you set it | `A` |
| `probe_out1` | 8 | you set it | `B` |
| `probe_out2` | 1 | you set it | `Cin` |
| `probe_in0` | 8 | you read it | `Sum` |
| `probe_in1` | 1 | you read it | `Cout` |

All output probes start at 0.

## Board pins (`constraints/addervio.xdc`)

| Signal | Pin | ZedBoard |
|--------|-----|----------|
| `CLK` | Y9 | 100 MHz clock |
| `Sum1[0]` … `Sum1[7]` | T22, T21, U22, U21, V22, W22, U19, U14 | LD0 … LD7 |

The LEDs show `Sum` only. The carry-out is visible in the VIO window.

## Repository layout

```text
Adder8bitVIO/
├── rtl/
│   ├── full_adder.v
│   ├── adder_8.v
│   └── main_adderVIO.v
├── ip/
│   └── vio_0/vio_0.xci         VIO core (source of the IP; Vivado regenerates the rest)
├── tb/
│   ├── tb_adder_check.v        exhaustive self-checking testbench (PASS / FAIL)
│   └── test_adder_8.v          original Vivado testbench (150 + 110)
├── constraints/
│   └── addervio.xdc
├── build.tcl                   recreates the Vivado project
└── README.md
```

## Run it

**Simulation, Icarus Verilog** (from this folder). This covers the adder itself; the top level needs the Xilinx VIO IP, which only Vivado can simulate.

```bash
iverilog -o sim rtl/full_adder.v rtl/adder_8.v tb/tb_adder_check.v
vvp sim
```

**Vivado:** `vivado -source build.tcl` creates the project in `build/` (including the VIO core). Use *Run Simulation → Run Behavioral Simulation* (top: `tb_adder_check`).

**On the board:**
1. Run Synthesis, Implementation and Generate Bitstream (top: `main_adderVIO`).
2. Open Hardware Manager, connect to the ZedBoard, and program the bitstream.
3. The VIO dashboard shows the probes above. Set `A`, `B` and `Cin`, and watch `Sum` and `Cout` update, along with the LEDs.

## Verification

`tb/tb_adder_check.v` is exhaustive: it tries every combination of `A` (256) × `B` (256) × `Cin` (2), which is **131,072** cases, and checks `{Cout, Sum} == A + B + Cin` for each.

Result: `PASS: all checks passed` with Icarus Verilog 12 and the Vivado 2020.1 simulator (XSim, project created by `build.tcl`). The testbench was also tried against three deliberately broken copies of the adder (a dropped carry term, a carry wired from the wrong stage, a disconnected carry-out); each one reports `FAIL`.

The original `tb/test_adder_8.v` runs the single case 150 + 110 and is meant to be read as a waveform.

## Implementation results

From the Vivado 2020.1 implementation run (`xc7z020clg484-1`):

| Resource | Used | Available |
|----------|------|-----------|
| Slice LUTs | 605 | 53,200 |
| Slice registers | 1,069 | 106,400 |
| Bonded IOB | 9 | 200 |
| BUFG | 2 | 32 |

Almost all of this is the VIO core and the JTAG debug hub, not the adder. A bitstream was generated.

Timing: only the debug hub's JTAG clock (30 MHz) is constrained, and it meets timing (worst slack 27.3 ns). The XDC has no `create_clock` for the 100 MHz `CLK`, so Vivado does not time the design's own clock paths.

## Tools

Vivado 2020.1 · target `xc7z020clg484-1` (ZedBoard, board part `em.avnet.com:zed:part0:1.4`)
