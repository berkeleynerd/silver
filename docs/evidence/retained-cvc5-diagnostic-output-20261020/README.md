# CVC5 diagnostic recurrence and payload evidence

This offline packet supports
[the focused research note](../../research/retained-cvc5-diagnostic-output.md).
The source is the complete archive already retained in
`../retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz` at upstream revision
`86cecd83b685f59e884094693b9a4c5c90a62e03`. No source fetch or solver execution
is part of the packet.

Run the focused check from the repository root:

```sh
python3 docs/evidence/retained-cvc5-diagnostic-output-20261020/check.py
```

`inputs.json` pins the reused archive, governing component notes/review and all
inspected source files. `witnesses.json` retains exact source ranges for the
arithmetic cache producer, returning search path, stream routing, rational
printer and API exception producer. `result.json` records local arithmetic and
leaves all missing task-derived bounds and complete q/O null. `round.json`
records scope, settings, elapsed time and author rework.

The checker validates byte identities, retained excerpts, option defaults,
specific source anchors and arithmetic. It is not a C++ call-graph proof,
runtime experiment, native/source correspondence proof, semantic-acceptance
theorem, or a complete diagnostic-site inventory. The accepted wrapper bounds
are imported without repeating their old validation. This lane identified an
exact unresolved producer rather than claiming an exhaustive output bound.
