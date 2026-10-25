# Interval-checked Integer division

## Authorization and delivery scope

The [2026-10-25 owner instruction](session-memory.md#2026-10-25--merge-228-and-implement-interval-checked-integer-division)
authorizes [#229](https://github.com/berkeleynerd/silver/issues/229) through
complete implementation, assurance, validation, review and pull-request delivery.
This is an in-progress capability; current language.md remains authoritative
until the complete checkpoint passes.

Admit fully grouped binary `/`, `mod` and `rem` wherever today's scalar
expressions are admitted: declaration initializers and static range endpoints,
loop bounds, predicates, scalar assignment and Integer Image. Preserve exact
initialization snapshots, staticness, body reads using mutable objects' declared
ranges, empty-loop/static-legality rules, existing String/argument compositions
and same-source proof/build. All three new operators share the current
63-operator budget and the complete source remains at most 4,096 bytes.

The first design package specifies sound transfer rules: nonzero divisor
intervals, Ada truncation toward zero for division, dividend-sign remainder and
divisor-sign modulus. Exact singleton operands retain exact values. General
`mod`/`rem` intervals require sound sign/magnitude bounds, not evaluation of only
the interval corners. Define the minimum-Integer/divisor-minus-one policy and
empty operands explicitly, and distinguish any conservative Silver restriction
from inherited Ada behavior. No guard narrowing is selected.

Josephus is the driver: a loop divisor in `2 .. 41` and a result object in
`0 .. 40` exercise nonstatic modulo and range-preserving loop-carried updates.
The research's six other approaches are candidates to check concretely, not
promised supported samples. Full-range Integer sequence stays outside this work.

## Work packages and completion

1. [#230](https://github.com/berkeleynerd/silver/issues/230): exact rules, boundary
   semantics, driver and focused pinned-tool obligation/discharge experiment.
   Derive the feature-local report-envelope extension from actual producer routes.
2. [#231](https://github.com/berkeleynerd/silver/issues/231): verified SPARK helpers,
   recognition, operator accounting, complete report policies and meaningful
   boundary/composition regressions.
3. [#232](https://github.com/berkeleynerd/silver/issues/232): universal membership,
   execution/safety and automatic discharge, with actual-source correspondence
   and semantic review of source-shape changes. Accepting a report class alone
   does not discharge the corresponding obligations.
4. [#233](https://github.com/berkeleynerd/silver/issues/233): stable full native
   proof/audit and build, full regression/sample suite, complete cached Lean/source
   and axiom audit, independent review and exact evidence. Update specification,
   catalogue, supported samples, Rosetta mapping and capability records together.

Preserve unrelated scratch and native caches; one lead coordinates all proof
workspace writes. Reuse successful evidence only while all its relevant inputs
and assumptions remain applicable. Compiler/runtime implementation stays SPARK.
No Oracle, tool-pin, source-bound, operator-budget, capacity-mode, `abs`, power,
conversion, wider type, scalar refinement or array change is selected. Deferred
#119 work and paused packets remain untouched.

## Evidence and rounds

Design and implementation evidence will be linked here as each obligation closes.
No admission, proof or execution result is claimed by this authorization record.
The initial planning thread selects GPT-6.1 Sol High; native and Lean design
threads select GPT-6 Astra Extra High. Runtime settings and lead setting are not
independently exposed. No token/cost measurement is available. The lead handles
integration and is the sole proof-workspace runner.
