# Conditional save/exit and first-fold reporting charge

Research #119, Linux x86_64, 2026-10-19. Read the
[source argument](../../research/retained-why-save-exit-charge.md).

Conditional OCaml components: zero direct save/exit non-binder charge, zero
returning first-fold excess, and whole-interval reporting **D = 25,920**.
The interface is **89,493 + N_native**. Native effects/preservation remain
OPEN; neither complete R nor an unconditional endpoint is established.
The ordinary ending save and later scheduler invocations are excluded.

- `inputs.json` pins inherited artifacts and the authored argument/checker.
- `source-excerpts.json` binds 62 ranges to exact members of the already
  retained Why3 and OCaml archives; `source-excerpts.txt` contains literal
  linefeeds and the complete selected ranges.
- `effect-ledger.json` records 16 specialized effect/catch families, including
  the nonzero `Pretty -> is_ts_tuple -> ts_tuple` allocation path.
- `report-sites.json` records the forward-only six-site reporting envelope,
  signal interruptions and the excluded scheduler/ending continuations.
- `check.py` verifies identities, source correspondence and finite arithmetic.
  It does not prove source semantics, execute old checkers or replay captures.
- `result.json` preserves the conditional/native-open and interval boundaries.
- `round.json` records selected settings, elapsed time and draft rework.

```sh
python3 -B docs/evidence/retained-why-save-exit-charge-20261019/check.py
```

No target, build, solver, debugger, disassembler or new native inventory was run.
The initial 60,496 counter, 1,145 fold charge, 966 binders per save and two-serial-
attempt protocol are imported unchanged. The reporting allowance includes
failure even with zero signal saves and charges every possible tuple-cache miss.
