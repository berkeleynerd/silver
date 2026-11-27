# Complete shadow-frame imported meaning — 2026-11-27

Focused run `20261127T125516-4da224194373` passed `Silver.ApplicationPackageHideImports` and
`Silver.FunctionDeclarationNative`, with a fresh audit of 44,395 declarations.
Only `propext`, `Classical.choice` and `Quot.sound` remain as foundations.
Linux x86-64, Lean 4.34.1, two managed workers/two threads per process, shared
host allocation of eight CPUs. Timings and actual inputs are retained here.

The complete Hide_Outer tree now evaluates concrete lexical/package-name calls,
its native Outer_Declaration expression, the existing Hide_Name field trees and
the executable Valid_State aggregate. Its three compaction passes are connected
to the model over every native entry domain: valid source, checked frame,
native metadata representation bounds and the validated incoming name. Name
spans for all examined rows follow from Valid_State; there is no assumption
about inactive storage, prior parser reachability, a completed helper result or
an admitted program's safety. Package metadata need not be valid merely to
classify an outer declaration.

The focus also found and repaired an inherited scalar-binding constructor in
FunctionDeclarationNative: the two qualification fields introduced by packages
must receive the original zero defaults for local bindings. No Ada source or
admission rule changes in this proof repair. Later proof failures were an
opaque name-spelling wrapper, record-layout notation and a function equality
under Option.elim. Their failed outcomes remain in the managed ledger; the
successful theorem preserves every declared argument domain.

The check is incremental, using ordinary Lake dependency checks and the cache
seed disclosed in `../support-domain-closure/`. It is not kernel replay or
complete language validation. The full certified-profile aggregate, remaining
reader composition, native checkpoint, regressions and independent review remain
required. Selected proof-role setting: Astra Max; runtime settings are not
independently exposed.
