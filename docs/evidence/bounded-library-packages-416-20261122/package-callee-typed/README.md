# Complete typed package callee — 2026-11-22

Focused Linux run `20261122T181643-35a68d109771` passed
`Silver.ApplicationPackageCalleeNative` with a fresh axiom audit of 20,025
declarations, two workers and two threads per Lean process within the shared
eight-CPU allocation. Build took 5.885 seconds and audit 3.836 seconds.

The complete typed body includes declarations, every rejection branch, lookup
and return, and quantifies over all initial locals and imported calls. The
uninitialized scalar Callee slot is arbitrary; it is assigned before reading.
Structural spelling and scope checks passed. This is typed-tree denotation,
not yet authoritative-source equality or imported primitive closure.

The initial attempt `20261122T181201-2902af9c3217` exhausted the simplifier
reduction budget. Directed finite-tree reduction exposed a branch-association
equality and a stale helper identifier in `20261122T181544-5a7501bff0d0`.
Splitting the actual Pure flag resolved it without source/domain changes.
The diagnostic is retained in the managed task ledger.

Proof role selected GPT-6 Astra Max. This continuation has no independently
confirmed live model/effort or token/cost measurement; native and Lean tool
times are not whole-team cost.
