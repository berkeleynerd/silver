# Fixed initial split and registration evidence

2026-10-18, Linux x86_64, research for #119. See the
[source argument and scope correction](../../research/retained-producer-fixed-tail.md).

From the repository root, replay offline:

```sh
python3 docs/evidence/retained-producer-fixed-tail-20261018/check.py
```

The checker requires no installed tool, debugger, solver, network or original
scratch directory. It validates archive/member identities, replays the accepted
Per_Check prefix checker, joins source/input/driver identities, checks the
protected snapshots and guards, recomputes every semantic-count operation, and
checks the one-input registration classification against the retained values.
`result.json` records recomputed bounds, exact ordered driver directives and
classifications. The source reachability partition, register/layout meanings
and first-event transfer are inspected arguments, not machine-checked proofs.

Files:

- `observations.tar.gz`: unmodified completed five-case capture, plans,
  read-only runner/probe, driver overlay/resolution, instructions, arithmetic
  operands, process/open/mapping observations and managed records.
- `registration.tar.gz`: separate completed Input_Is_Valid classification
  capture, full labels/selected predicates/IDs and endpoint set membership;
  all original no-scheduling guards remain enabled.
- `sources.tar.gz`: 25 complete Why3 files joined to the accepted prefix source
  archive, plus server teardown/logging source. No source-shape pin is changed.
- `identity.json`: packet dependencies and archive/member identities.
- `check.py`, `result.json`: offline replay and its exact current result.
- `round.json`: selected settings, authorization, completed work and timing.

The five-case run `20261018T182701-4554d278376e` used one managed worker and
completed in 83.367528516 seconds. The debugger processes took 81.250524901
seconds in total. No guard fired and no prover was scheduled. The one-input
diagnostic `20261018T183727-b79953f86b46` used one worker and completed in
6.796294796 seconds (debugger 4.741128133 seconds), resolving raw four versus
reported one without repeating the other successful inputs.

Both stop at entry to `camlGnat_checks__iter_2373`, before its body. Each real
idle server exits 1 naturally after the debugger kills its stopped client;
that teardown is expected from the retained server source and is not called
exit-zero server success. Server allocation/capacity is a separate open join.

`W=128,847,761`, `B=131,043,754`, semantic operations 514,906, maximum result 47.
These establish the conditional initial-split/registration segment with its
source/runtime premises. Driver transformations, backend task printing,
solvers/results and final serialization are open. Raw split tasks are not
substituted for response G; the exact Input_Is_Valid classification preserves
the existing reported-G bound and response constants. Frozen historical
wording is explicitly corrected in the new report without repinning its
successful evidence.

During offline packaging, the first driver-directive extraction rejected
the syntax operator `(*)` as an unterminated comment. The extractor was
corrected to follow Driver_lexer.token's explicit operator case. This was an
offline checker error; neither native capture was repeated. Initial archive
packaging also requested a nonexistent `run.json` for the second managed run;
the actual `events.jsonl` and `native.log` are retained instead.
