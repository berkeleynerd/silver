# Installed producer fixed-phase evidence

Native Linux x86_64, 2026-10-18, #119. Supports the
[fixed-phase record](../../research/retained-producer-fixed.md).

The retained probe runs the installed `gnat2why` under an isolated GDB 17.1
installation in `/tmp`, reads its memory at three phase boundaries, and quits
before table release. No inferior function is called by the reader. A separate
breakpoint stops before backend invocation, and `/usr/bin/false` is configured
as a second backend safeguard. No solver ran.

`invocation.json` and `options.json` retain the reconstructed invocation and
its differences from the earlier production invocation. `main.adb` is the
unchanged null sample. The `phase1` files and `main.ali` retain its isolated
global-generation prerequisite. Paths identify the installation actually used;
they are not portable installation instructions. `result.json` records actual
producer/debugger hashes, command, elapsed time and counters. `probe.log` is
the raw successful log. `graphs.tar.gz` retains every node's child fields and
every list's members at all three stops, together with the DWARF layout read
from that installed executable.

`raw_snapshot_v2.py` uses symbol addresses and DWARF field offsets rather than
evaluating dynamic Ada objects. Node IDs start at zero; list IDs start at
2^30. The empty list vector's Last_Index is 2^30-1. Optional lists are ordinary
allocated empty lists; optional node zero serializes null. The reader checks
pointer presence, ID ranges, linked-list lengths/backlinks and graph cycles.
`nodes` excludes the one allocated node-zero sentinel, which remains present
in the graph and vector; `lists` is a count, not Last_Index. The expanded-root
metric counts shared nodes each time a parent refers to them. It is not a
measurement of the serializer or of all temporary containers.

Run the offline reconciliation from any directory:

```sh
python3 docs/evidence/retained-producer-fixed-20261018/check.py
```

This rechecks retained graph arithmetic and bundle hashes without invoking GDB,
the compiler or a prover. `source-manifest.json` names the candidate source
used for the conditional monotonicity and phase-independence arguments. Its
historical relationship to the installed producer remains unestablished.
The existing source archive retains those bytes.

Successful managed runs: `20261018T010148-5b413e8494d4` (global generation),
`20261018T010952-3e272e7b560c` (snapshots). Earlier diagnostic attempts remain
in the shared managed ledger and `/tmp/silver-producer-counter-plan-20261018/`
under `attempt1` through `attempt6`: missing ALI, unsupported dynamic Ada
location evaluation, then the incorrect initial list-index interpretation.
Those failed attempts supply no successful counters. They did not run solvers.
