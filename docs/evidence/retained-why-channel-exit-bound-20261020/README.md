# Selected channel and exit attachment

See the [research note](../../research/retained-why-channel-exit-bound.md).
`inputs.json` pins the reused initial bounds, interrupted episode/control,
configuration and source evidence. `source-witnesses.json` contains exact
archive excerpts. `native-bodies.json` is a subset of retained disassembly;
`native-data.json` binds the installed uncaught-handler closure. The executable
and disassembly identities are in `native-witnesses.json`. `result.json`
contains five conditional bounds and explicit incomplete-scope flags.

```sh
python3 docs/evidence/retained-why-channel-exit-bound-20261020/check.py
```

This reads retained source and executable bytes only. No target, capture,
disassembler, source fetch, solver/proof, suite or predecessor checker is run.
Source control/callback selection and lifetime reasoning require review; the
check is not a machine proof. Driver/save ownership avoids recharging save
constructor wrappers. The rejected e+2 hypothesis and actual Sys_blocked_io
countertrace are retained in the note. Six roots do not prove successful flush,
finite external-service retries, complete error/exit capacity or physical RAM.

The author freeze check passed five cases, 36 excerpts and 41 native bodies /
17,704 instruction bytes in 0.686634249 seconds. Earlier preparation diagnostics
corrected a curried-closure pointer interpretation and a multiline-versus-line
instruction byte counter before this success; no native run or successful
checker replay was involved. A subsequent evidence-only addition retains startup option c at lines100–130,
bringing the final source excerpt count to37; the reviewer checks that final
input set. Independent review belongs to Round 37.
Refs #119, #153.
