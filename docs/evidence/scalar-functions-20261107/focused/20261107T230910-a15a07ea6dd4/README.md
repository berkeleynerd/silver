# Frozen integration check — failed outcome retained

Managed Linux run `20261107T230910-a15a07ea6dd4` checked `SequenceModel` and
`PredicateEquations` on the source/proof/script inputs of `eb72b5217e`, with
10 Lake workers and 22 threads per Lean process. It finished with failure at
2026-11-08 02:15:03 UTC after 11,151.970 seconds. The retained log's phase start
matches its managed event record; `index.json` identifies the compressed copies
by their uncompressed hashes.

The two required target failures are `PredicateOuterEquations` and
`ComposeBooleanDeclarationDomain`: the former omits the native function-assignment
flag, and the latter has stale context constructors and conjunction projections.
The run performed no successful fresh axiom audit and has no completed-success
manifest. The failed outcome is not replaced by its successful module objects.

SequenceModel, all eight output-source chunks, OutputBodyCertificate,
OutputSourceBridge and the downstream Compose/named/argument/lexical source
dependencies compiled. The output certificate alone took 6,094 seconds as
reported by Lake. These objects remain cached for the corrected run; no clean
rebuild or independent replay is claimed.

After preserving this result and releasing its workspace lease, the coordinator
applied the independently reviewed outer evaluator/render/candidate repair and
Boolean context-adapter repair. The separately reviewed report warning cleanup
was integrated from native commit `560144172c` as `cd705e9bba`; it leaves the
output-profile bytes unchanged. See the
[bounded review](../../../../reviews/review-scalar-functions-delivery-20261108.md).
The next focused check includes the named `scan_step` source extraction, and
complete native, Lean/source and regression validation remain required.
