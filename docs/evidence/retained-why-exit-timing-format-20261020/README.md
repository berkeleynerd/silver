# Retained Debug Stats timing format extension

This packet extends the frozen private formatter environment to the exact static
`<stats>@[%s: %f, %d@]@.` template, under its existing source/native and scalar/libc
premises. The [research note](../../research/retained-why-exit-timing-format.md)
states the argument and boundaries.

- `extension-spec.json` gives the permitted Float_f/empty-box delta and node census.
- `source-witnesses.json` retains exact source excerpts from existing archives.
- `native-bodies.json`, `native-frames.json` and `native-control.json` retain the
  checked installed bodies, own stack bounds, dispatch tables and runtime DAG.
- `retained-environment.json` records five manifest-bound `LC_ALL=C` observations.
- `result.json` exports conditional 317-byte float output, requested allocation
  subtotals, zero F stack delta, and the separate 512-byte C wrapper shell in R.
- `inputs.json` binds all read inputs, including this packet's checker.
- `round.json` records selected settings, scope, elapsed time and checks.

Run `python3 docs/evidence/retained-why-exit-timing-format-20261020/check.py`
from the repository. It reads the already retained `/tmp` disassembly and the
installed executable; their exact identities are checked. It never executes
gnatwhy3, runs a disassembler, replays a predecessor checker, captures a process
or invokes a solver. It writes only this packet's generated JSON files.

The output bound requires normal numeric services and preserved effective C
locale. The packet supplies no global formatter-state or callback theorem,
timing-update count, whole-save/exit capacity or physical-sufficiency claim.
