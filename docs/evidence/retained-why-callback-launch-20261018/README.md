# Retained Why signal multiplicity and launch rule

Research #119, Linux x86_64, 2026-10-18. The
[source argument](../../research/retained-why-callback-launch.md) derives a
conditional bound of **two SIGINT save-entering callbacks** from the selected
native signal protocol. It permits arbitrary external SIGINT events and accounts
for one stale runtime pending bit. It does not claim an observed two-callback
execution, one-shotness, a complete handler charge or full capacity.

```sh
python3 -B docs/evidence/retained-why-callback-launch-20261018/check.py
```

The check reads retained archives and the pinned installed ELF as data, checks
selected source/native witnesses and identities, and exhausts the 29-state
abstraction. It runs no target, debugger, objdump, compiler or solver.

- `sources.tar.gz` contains additional exact OCaml/Why3 source and official
  POSIX documentation with retrieval/member identities. Existing sources are
  reused from the corrected callback packet.
- `native-witnesses.json` retains seven named bodies extracted from the existing
  disassembly; 1,520 instruction bytes are checked against the installed ELF.
- `invocation.json` binds the retained external-server argv/plan. It contains
  no new signal-mask observation or controller/session graph.
- `fixed-session-seed.json` identifies the equal fixed JSON and historical
  session XML; neither is silently treated as the current raw-task forest.
- `multiplicity.py` checks the finite-state abstraction, not native refinement.
- `result.json` freezes scoped results, premises and missing charge/join inputs.
- `inputs.json` pins archives, reused evidence and local files.
- `round.json` records selected settings, actual timing and the review handoff.

The accounted endpoint remains **61,641**. An explicit conditional charging
schema identifies explanation and shape binder work, the missing session graph,
and uncharged remaining helper/exit work. A Why-only POSIX spawn mask is described
with cancellation and solver-child effects; it has not been implemented or
validated, and the earlier counter observation is not attached to that future
configuration.
