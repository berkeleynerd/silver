# Explicit body condition initializer argument

Managed focused run `20261031T053848-2f8f986ab6e3` passed
`Silver.PredicateEquations` and a fresh audit of 309 imported modules / 91,711
declarations, using only the three approved Lean foundations. It used one
worker, one thread and an 8 GiB process threshold. Build time was 12.881 s,
audit 11.249 s, and managed time 33.356 s.

All 687 captured source and two tool hashes matched at terminal. The compressed
original events, log and evidence retain exact inputs and results; `retained.json`
records their uncompressed hashes. The
[independent review](../../../../reviews/review-boolean-body-condition-wiring-20261031.md)
explains the actual Ada default and preservation of the generalized reader's
full domain. Four unused simplification arguments were also removed from the
separate source candidate; that expensive candidate is deliberately deferred
to the complete checkpoint on the final native-validated source.

The old complete run remains failed. This focused result does not establish
complete source correspondence, whole-project module/axiom coverage or feature
support. No native code, runtime behavior or proof policy changed in this repair.
