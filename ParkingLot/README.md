# Parking Lot Car Counter

A car counter for a parking lot with one gate, written in Verilog. Two sensors sit at the gate. The order in which they trigger tells the design whether a car is **entering** or **leaving**, and it keeps a running count of the cars inside (up to 25). The count can be watched live in Vivado's Hardware Manager through a **VIO** debug core. A `FULL` output goes high at 25 cars, and an `ERROR` output blinks when something impossible happens (for example, a car leaving an empty lot).

Written in Vivado 2020.1. The project targets `xc7z020clg484-1` (the Zynq-7020 on the ZedBoard).

## How it works

Think of the gate as a short corridor with two doors, one on the outside and one on the inside:

```text
   OUTSIDE  [ pout ]──────[ pin ]  INSIDE
```

- A car driving **in** passes `pout` first, then `pin`.
- A car driving **out** passes `pin` first, then `pout`.

The design just watches the order. The two sensors come in as push-button inputs (`POUT_BT`, `PIN_BT`), so a button press stands in for a car passing a sensor.

```text
 PoutB ─▶ debouncer ─┐                       ┌─▶ carcount[4:0] ─▶ vio_0 (read in Hardware Manager)
                     ├─▶ parklot FSM ────────┼─▶ Full
 PinB  ─▶ debouncer ─┘        ▲              └─▶ Error (blinking)
                              │
 CLK ─▶ clockdivider ─────────┘   (slow clock, about 190.7 Hz)
```

| Module | File | What it does |
|--------|------|--------------|
| `clockdivider` | `rtl/clockdivider.v` | 19-bit counter; its top bit is the slow clock `SLCLOCK` = 100 MHz / 2^19 ≈ 190.7 Hz (period ≈ 5.24 ms). |
| `debouncer` | `rtl/debouncer.v` | Three flip-flops in a row. Output is `A & B & ~C`, which is a **one-clock pulse** once the button has been high for two samples in a row. A single press gives exactly one pulse, and very short glitches are ignored. |
| `parklot` | `rtl/parklot.v` | The state machine and the counter (below). |
| `main` | `rtl/main.v` | Connects the divider, two debouncers and `parklot`. |
| `mian_parkinglot` | `rtl/mian_parkinglot.v` | Top level. Adds the VIO core that shows the car count. The module name is spelled `mian_parkinglot`, as in the source. |
| `vio_0` | `ip/vio_0/vio_0.xci` | Xilinx VIO core, one 5-bit input probe (`probe_in0` = car count), no output probes. Clocked by `CLK_F`. |

The debouncers and the state machine run on the slow clock, so a button press must be held for about 10 ms (two slow-clock samples) to count.

### The state machine (`parklot`)

Six states. It sits in `idle` until a sensor fires:

| From | Input | Goes to | Meaning |
|------|-------|---------|---------|
| `idle` | `pout` only | `wait_pin` | Car reached the outside sensor, waiting for the inside one |
| `idle` | `pin` only | `wait_pout` | Car reached the inside sensor, waiting for the outside one |
| `idle` | both at once | `invalid` | Not a real car movement |
| `wait_pin` | `pin` | `entry` | Outside then inside: a car came in |
| `wait_pout` | `pout` | `exit` | Inside then outside: a car left |
| `entry`, `exit`, `invalid` | (any) | `idle` | One clock, then back to idle |

What happens in the one-clock states:

| State | If allowed | If not allowed |
|-------|-----------|----------------|
| `entry` | `CarCount + 1`, clear the error flag (when `CarCount < 25`) | Lot already has 25 cars: count unchanged, **set the error flag** |
| `exit` | `CarCount - 1`, clear the error flag (when `CarCount > 0`) | Lot is empty: count unchanged, **set the error flag** |
| `invalid` | n/a | Set the error flag |

Outputs:

- `CarCount[4:0]`: number of cars, 0 to 25.
- `FULL`: high when `CarCount == 25`.
- `ERROR`: `error_flag & blink_cnt[5]`. The flag stays set until the next valid entry or exit (or a reset). While it is set, `ERROR` toggles with a 64-slow-clock period, about **3 Hz**, so an LED on it blinks.
- `RST` (active high, asynchronous) clears the state, the count, the error flag and the clock divider.

### Ports of the top level

| Port | Dir | Width | Description |
|------|-----|-------|-------------|
| `CLK_F` | in | 1 | 100 MHz clock |
| `RST_F` | in | 1 | Reset, active high |
| `POUT_BT` | in | 1 | Outside sensor (push button) |
| `PIN_BT` | in | 1 | Inside sensor (push button) |
| `FULL_F` | out | 1 | High when the lot is full |
| `ERROR_F` | out | 1 | Blinks on an error |

The car count is not a port: it goes only to the VIO core, so you read it in Hardware Manager.

## Repository layout

```text
ParkingLot/
├── rtl/
│   ├── clockdivider.v
│   ├── debouncer.v
│   ├── parklot.v
│   ├── main.v
│   └── mian_parkinglot.v       top level
├── ip/
│   └── vio_0/vio_0.xci         VIO core (source of the IP; Vivado regenerates the rest)
├── tb/
│   ├── tb_parklot_check.v      self-checking testbench for the state machine
│   └── tb_main_check.v         self-checking system test with real-length button presses
├── build.tcl                   recreates the Vivado project
└── README.md
```

## Run the simulation

**Icarus Verilog** (from this folder):

```bash
# state machine, runs in well under a second
iverilog -o sim rtl/parklot.v tb/tb_parklot_check.v
vvp sim

# whole chain with 20 ms button presses, takes about 10 seconds
iverilog -o sim_sys rtl/clockdivider.v rtl/debouncer.v rtl/parklot.v rtl/main.v tb/tb_main_check.v
vvp sim_sys
```

**Vivado:** run `vivado -source build.tcl`. This creates the project in `build/`, including the VIO core. The default simulation top is `tb_parklot_check`. To run the other one, set `tb_main_check` as the simulation top.

## Verification

**`tb/tb_parklot_check.v`** drives the sensors directly, one clock per event, and checks `CarCount`, `FULL` and `ERROR`:

- reset values
- cars entering and leaving
- a car leaving an empty lot (count stays 0, `ERROR` blinks, next good entry clears it)
- one sensor firing alone (nothing changes until the second sensor fires)
- both sensors at the same time (`ERROR` blinks)
- filling the lot to exactly 25 (`FULL` goes high, no error)
- a 26th car (count stays 25, `ERROR` blinks) and a car leaving to clear it
- reset clears both the count and the error

**`tb/tb_main_check.v`** goes through the clock divider and debouncers with 20 ms button presses: two cars in, one out, count checked after each, and `Error` / `Full` must stay low. About 0.24 s of board time is simulated.

Result: both print `PASS: all checks passed` with Icarus Verilog 12 and with the Vivado 2020.1 simulator (XSim, project created by `build.tcl`).

`tb_parklot_check` was also run against four deliberately broken copies of `parklot` (count goes up by 2, limit set to 26, wrong state after `wait_pin`, `invalid` not setting the error flag). Each one reports `FAIL`.

## Synthesis

Vivado 2020.1 synthesis finishes with 0 errors and 0 critical warnings. Resources used by the design itself (the VIO core is a separate IP, so it is not in these numbers):

| Resource | Used | Available |
|----------|------|-----------|
| Slice LUTs | 18 | 53,200 |
| Slice registers | 40 | 106,400 |
| Bonded IOB | 6 | 200 |
| BUFG | 1 | 32 |

Vivado prints one warning (`Synth 8-4446`) at the VIO instance. This VIO only reads a signal, so it has no outputs to connect.

## Status and limitations

- Verified in simulation and synthesis. **Pin constraints (`.xdc`) are not included, and the design has not been implemented or run on a board.** `build.tcl` picks up any `.xdc` placed in a `constraints/` folder.
- After the first sensor fires, the state machine waits for the second one with no time limit. A car that triggers the outside sensor and backs out leaves it armed until the next `pin` event.
- The state machine runs on a clock divided down in logic. A common alternative is to run everything on `CLK` and use a slow enable pulse.

## Tools

Vivado 2020.1 · target `xc7z020clg484-1` (ZedBoard, board part `em.avnet.com:zed:part0:1.4`)
