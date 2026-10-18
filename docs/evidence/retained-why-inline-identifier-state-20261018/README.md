# Retained private identifier counter

Research #119, 2026-10-18, Linux x86_64. The
[source argument](../../research/retained-why-inline-identifier-state.md) binds
`Ident.id_register`'s private starting ref **60,496** to a same-run input graph
and complete Hsdecl projection. The accepted **1,145 accounted source
registrations** fit through **61,641**. Complete continuing runtime callback
closure remains open; complete transform/pipeline claims stay false.

```sh
python3 -B docs/evidence/retained-why-inline-identifier-state-20261018/check.py
```

This check is offline and starts no native target, debugger, compiler or solver.

- `capture.tar.gz` retains the successful core/auxiliary capture, preparation
  scripts, exact input/configuration, raw memory-read log, guards, static
  disassembly and managed evidence. Raw read bytes are losslessly compressed.
- `failed-attempts.tar.gz` preserves both failed decoders, target outputs,
  plans and managed records. Their failures and repairs are explicit.
- `runtime-sources.tar.gz` retains seven selected OCaml source files at the
  existing pin, their retrieval identities, installed destructor disassembly
  and a limited direct finalizer-registration reference scan.
- `callback-inventory.json` records complete Why3 textual-scan inputs and
  matches plus selected installed finalization symbols/operation records.
  Negative text/direct-reference results do not establish all indirect callback
  reachability or linked initialization behavior.
- `counter.py` checks natural preincrement arithmetic; `compose.py` replays
  the private-ref bytes, unchanged prior guards, full graph/table validation,
  exact input sharing isomorphism and representative selection before joining
  the accepted local source bound. Auxiliary counters are observations only.
- `inputs.json` pins every archive/member and reused packet. `result.json`
  freezes the callable result. `check.py` tests arithmetic boundaries and the
  robust raw-memory fixtures; `round.json` records real settings/times and
  requested independent-review scope.

The initial snapshot does not prove earlier nonoverflow, noncollision, family
invariance, future-call bounds or absence of reentrant identifier-producing
OCaml/library callbacks. No inlining, printing or solver submission was
executed in the three read-only target observations.
