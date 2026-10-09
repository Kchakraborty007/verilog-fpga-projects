# CLAUDE.md

Notes for Claude when working in this repo. Read this first in a fresh session.

## What this repo is

Koustav's GitHub portfolio of Vivado/Verilog projects (ECE graduate, embedded/VLSI focus). It is shown to recruiters during placements, so it has to look clean and professional and every claim has to be true. Vivado 2020.1, ZedBoard (`xc7z020clg484-1`).

The source projects live on the user's PC in a connected folder called `MYProjects`. This repo holds only the relevant files from them.

## Standing rules from the user

1. **Never modify the user's RTL, constraints or IP.** The code is professor-verified and the user is happy with it. Only add new files: testbenches, `build.tcl`, README. If the design has a bug, document it in that project's README. Do not fix it. (Example: the door lock's `mainblock` bug.)
2. **README claims must be verified.** Numbers come from real tool runs or real Vivado reports. If something was not done (no pin constraints, never run on a board), say so plainly.
3. **Source files only.** Vivado output stays out (`.gitignore` blocks it). `build.tcl` recreates the project.
4. Push straight to `main`. One commit per project, plus one commit for the root index README. Run `git pull --ff-only` first.
5. Commit author is the user. Reuse what earlier commits used (`git log -1 --format='%an <%ae>'`, set via `GIT_AUTHOR_*` / `GIT_COMMITTER_*`). End commit messages with the attribution trailers the session provides.
6. Before committing, scan for personal paths and emails: `grep -rniE --exclude=CLAUDE.md "koust|C:[/\\]|Users[/\\]|@gmail|bits_academics" .`. It should find nothing (the exclude is only because this file quotes the pattern).
7. The user likes inline answers (no artifacts), direct communication, and short summaries at the end.

## Where things stand (2026-10-10)

| Folder | What | State |
|--------|------|-------|
| `FSMcounter/` | 4-state up/down counter, 1 Hz divider | Simulation-verified. No XDC. |
| `FSMdoorLock/` | Password door lock, 4 buttons, debouncers | Simulation-verified, implemented. Known top-level bug documented in its README (left unfixed on purpose). |
| `Adder8bitVIO/` | 8-bit ripple adder, VIO | Exhaustive TB (131,072 cases) passes in Icarus and XSim, synth clean, bitstream exists. |
| `ParkingLot/` | Sensor-based car counter (max 25), VIO | TBs pass in Icarus and XSim, synth clean. **No XDC, never run on a board.** |

The user deleted `FSMdoorLock` from GitHub once and had it re-added with the same RTL, so don't be surprised by that history.

Left out on purpose:
- `RC_midsem _question_2025` in `MYProjects`: looks like exam material. Ask the user before touching it.
- `Main_AdderVIO.v` in the adder's `sim_1` folder: an older copy with a different module name, not in the design.
- Stray `vio_1` / `vio_2` folders in the adder: not part of the project.

Small things to know:
- ParkingLot's top module is spelled `mian_parkinglot` in the source. Kept as is.
- ParkingLot's state machine waits for the second sensor with no timeout. Documented in its README.
- Possible next step: a pin-constraint file for ParkingLot, if the user gives the button/LED mapping.

## Folder layout of every project

```text
<project>/
├── rtl/            user's Verilog, copied unchanged
├── tb/             original testbench(es) + my self-checking *_check.v (prints PASS / FAIL)
├── constraints/    user's .xdc (only if the project has one)
├── ip/<name>/      the .xci only (the IP source), if the project uses Xilinx IP
├── build.tcl       recreates the Vivado project
└── README.md
```

Templates to copy from: `FSMdoorLock/` (plain project with XDC) and `Adder8bitVIO/` (project with a VIO core: `import_ip` + `generate_target`). `ParkingLot/build.tcl` shows the version that works without an XDC.

## Recipe for adding a project

1. **Pick the files** from the Vivado project folder: `<proj>.srcs/sources_1/new/*.v` (rtl), `constrs_1/new/*.xdc`, `sim_1/new/*.v` (original testbenches), `sources_1/ip/<ip>/<ip>.xci`. Skip `.runs`, `.cache`, `.sim`, `.hw`, `.ip_user_files`, generated IP outputs, and duplicate or unused files.
2. **Copy unchanged** and compare SHA-256 against the originals.
3. **Write a self-checking testbench** (prints `PASS: all checks passed` or `FAIL`, then `$finish`). Prove it works by running it against deliberately broken copies of the design; each one must FAIL. If the real timing is too slow to simulate (1 Hz dividers), poke the counter near its terminal value after `@(posedge CLK); #1` in the testbench. Never edit the RTL.
4. **Write `build.tcl`** from a template above, then test it in real Vivado.
5. **Write the README** in the same shape as the existing ones: what it is, how it works, ports/pins, layout, how to run, verification, results, status and limitations, tools.
6. **Verify**:
   - Icarus Verilog (`apt-get update && apt-get install -y iverilog` if missing).
   - Vivado 2020.1 on the user's PC: `K:\Vivado\2020.1\bin\vivado.bat -mode batch -source test.tcl -nojournal -nolog`, where `test.tcl` does `source build.tcl`, `launch_simulation`, `run all`, `close_sim`, `launch_runs synth_1`, `wait_on_run synth_1`, then `exit`. Work in a temp folder on the PC and delete it afterwards. Each run takes about 2 minutes. IP runs (like `vio_0`) are launched automatically by `synth_1`.
7. **Update the root README** project table (and its Icarus commands), leak scan, commit, push.
8. **Verify from a fresh clone**: file list, hashes against the originals, and re-run the testbenches.

## Tool gotchas

- The PowerShell tool refuses `Set-Content`. Write files with `Add-LinesToFile path -Content $var1`; use `Out-File` to save command output.
- Long Vivado calls return "still running". Use `wait_for_completion`.
- Small new files are moved to the PC by piping `tar czf - ... | base64 -w0` into a `var1` and decoding there.
- `gh` has no valid token. Use the `add_repo` tool with `access: "push"`, then clone from GitHub.
- Recursive `device_list_dir` on a Vivado folder is huge. Save the output and parse it.
- `expect` is a SystemVerilog keyword; don't use it as a task name in testbenches.
- XSim prints a "no timescale" warning for `parklot.v`. It is harmless.
