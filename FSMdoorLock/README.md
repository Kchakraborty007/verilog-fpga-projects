# FSM Digital Door Lock

A password door lock built as a finite state machine in Verilog. Four push buttons enter a 4-press code; the design shows `UNLOCK` for the right code and `ERROR` for a wrong one. Written in Vivado 2020.1 for the ZedBoard (Zynq-7020).

## The password

The code is four presses: **PB1, PB0, PB0, PB2**. On the ZedBoard that is Right, Up, Up, Down.

If any press is wrong, the lock keeps counting presses and shows `ERROR` after exactly four presses in total. It never reveals which digit was wrong.

## Block diagram

```text
 PB0 ─▶ debouncer ─┐
 PB1 ─▶ debouncer ─┤   press = any button
 PB2 ─▶ debouncer ─┼─▶ priority ─▶ Bout[1:0] ─▶ dlock FSM ─▶ UNLOCK
 PB3 ─▶ debouncer ─┘   encoder      + EN                     └─▶ ERROR
            ▲
            │ SLCLOCK (≈190 Hz)
      clockdivider ◀── CLK (100 MHz)
```

| Module | File | What it does |
|--------|------|--------------|
| `clockdivider` | `rtl/clockdivider.v` | 19-bit counter; its top bit is `SLCLOCK`, about 190.7 Hz (100 MHz / 2¹⁹, period ≈ 5.2 ms). |
| `debouncer` | `rtl/debouncer.v` | 3-stage shift register on `SLCLOCK`. Output is high when the button was seen high on two samples in a row after being low. |
| `dlock` | `rtl/dlock.v` | The password FSM (below). |
| `mainblock` | `rtl/mainblock.v` | Top level. Four debouncers, a priority encoder (PB0=`00`, PB1=`01`, PB2=`10`, PB3=`11`), and the FSM. |

## The FSM

```text
 S1 ─01─▶ S2 ─00─▶ S3 ─00─▶ S4 ─10─▶ S5   (UNLOCK = 1, stays here until reset)
  │        │        │        │
 wrong    wrong    wrong    wrong
  ▼        ▼        ▼        ▼
 E1 ─any─▶ E2 ─any─▶ E3 ─any─▶ E4   (ERROR = 1) ─any─▶ S1
```

- `EN` (a button was pressed) gates every step. With `EN = 0` the state does not change.
- The press after `E4` returns the FSM to `S1` and is not counted as the first digit of a new attempt.
- `RST` (active high) returns the FSM to `S1`.

## Board pins (`constraints/dlstream.xdc`)

| Signal | Pin | ZedBoard |
|--------|-----|----------|
| `CLK` | Y9 | 100 MHz clock |
| `RST` | P16 | BTNC |
| `PB0` | T18 | BTNU |
| `PB1` | R18 | BTNR |
| `PB2` | R16 | BTND |
| `PB3` | N15 | BTNL |
| `UNLOCK` | T22 | LD0 |
| `ERROR` | T21 | LD1 |

## Repository layout

```text
FSMdoorLock/
├── rtl/
│   ├── clockdivider.v
│   ├── debouncer.v
│   ├── dlock.v
│   └── mainblock.v
├── tb/
│   ├── tb_dlock_check.v      self-checking testbench for dlock (PASS / FAIL)
│   └── test_door.v           original Vivado waveform testbench
├── constraints/
│   └── dlstream.xdc
├── build.tcl                 recreates the Vivado project
└── README.md
```

## Run it

**Simulation, Icarus Verilog** (from this folder):

```bash
iverilog -o sim rtl/dlock.v tb/tb_dlock_check.v
vvp sim
```

**Vivado:** `vivado -source build.tcl` creates the project in `build/`. Use *Run Simulation → Run Behavioral Simulation* (top: `tb_dlock_check`). For the board, run Synthesis, Implementation and Generate Bitstream (top: `mainblock`), then program the ZedBoard.

## Verification

`tb/tb_dlock_check.v` drives `dlock` with one enable cycle per press and checks 22 conditions:

- reset state is locked with no error
- the correct code unlocks, and the lock stays unlocked on further presses
- a wrong digit at each of the four positions gives `ERROR` after exactly four presses, never earlier, and one more press clears it
- the correct code works again after an error
- `EN = 0` holds the state
- reset clears `UNLOCK` and `ERROR`

Result: `PASS: all checks passed` with both Icarus Verilog 12 and the Vivado 2020.1 simulator (XSim). The testbench was also tried against four deliberately broken copies of `dlock` (wrong digit, `ERROR` one state early, unlock not held, `EN` ignored); each one reports `FAIL`.

The original `tb/test_door.v` runs a wrong code (`01, 00, 10, 00`) and then the correct code (`01, 00, 00, 10`) and is meant to be read as a waveform.

## Implementation results

From the Vivado 2020.1 implementation run (`xc7z020clg484-1`):

| Resource | Used | Available |
|----------|------|-----------|
| Slice LUTs | 10 | 53,200 |
| Slice registers | 41 | 106,400 |
| Bonded IOB | 8 | 200 |
| BUFG | 1 | 32 |

A bitstream was generated. Timing was not analysed: the XDC has no `create_clock` for `CLK`, so Vivado reports no timing results.

## Known limitation

`dlock` runs on the 100 MHz clock, but its enable `press` comes from the slow-clock debouncers and stays high for one full slow-clock period (2¹⁹ = 524,288 fast cycles, about 5.2 ms). While `EN` is high, the FSM takes a step on every fast-clock edge, so one physical press can move it many steps instead of one. A full-system simulation of `mainblock` with 20 ms button presses showed 524,288 state changes per press.

The testbenches in this folder drive `dlock` with a one-cycle enable (one step per press), which is the behaviour the FSM is designed for. Turning `press` into a single-cycle pulse in the 100 MHz domain (for example with an edge detector) would give one step per press.

## Tools

Vivado 2020.1 · target `xc7z020clg484-1` (ZedBoard, board part `em.avnet.com:zed:part0:1.4`)
