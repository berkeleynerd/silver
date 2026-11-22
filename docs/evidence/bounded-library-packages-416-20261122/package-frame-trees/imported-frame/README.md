# Complete imported-frame interpretation

Focused Linux run `20261122T182343-3e11889fd158` passed the complete
`Silver.ApplicationPackageImportedFrame` target and fresh axiom audit of
21,659 declarations, using only `propext`, `Classical.choice`, and `Quot.sound`.
The incremental build took 3.296 seconds and the audit 2.970 seconds. Two workers
and two threads per process shared the host's eight-CPU allocation. The
12,000 MiB per-process threshold was a precaution for this previously expanding
proof, not an observed peak or a repository-wide default.

The whole typed body now equals the executable imported-frame equation for
arbitrary calls and locals. Each qualification loop, field reset, and final
validity guard is composed through separate checked equations. This preserves
the original theorem domain while avoiding expansion of all nested parser-state
records. The earlier interrupted attempt remains failed in the managed ledger.

This is focused development evidence. Hide_Outer, state-effect interpretation,
authoritative source binding and the complete application endpoint remain
separate work; no complete feature assurance is claimed here.
