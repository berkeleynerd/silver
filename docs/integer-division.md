# Interval-checked Integer division

## Authorization and delivery scope

The [2026-10-25 owner instruction](session-memory.md#2026-10-25--merge-228-and-implement-interval-checked-integer-division)
authorizes [#229](https://github.com/berkeleynerd/silver/issues/229) through
complete implementation, assurance, validation, review and pull-request delivery.
The implementation and coordinated language/catalogue/sample changes are in
review; the complete delivery checkpoint below is pending. The current
[language specification](../language.md) states the selected rules.

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

The [producer/report review](integer-division-report-capacity.md) records the
feature-local envelope and native discovery. Implementation and source-bridge
integration are at `14b9302a97`; complete
source-correspondence validation remains in progress. Earlier focused evidence
is distinguished from the complete checkpoint below.
The initial planning thread selects GPT-6.1 Sol High; native and Lean design
threads select GPT-6 Astra Extra High. Runtime settings and lead setting are not
independently exposed. No token/cost measurement is available. The lead handles
integration and is the sole proof-workspace runner.

## Selected rules and design result

The native rule and checked mathematical model use `/` with truncation toward
zero, divisor-sign `mod` and dividend-sign `rem`. Quotient uses the hull of four
endpoint quotients; modulo uses exact singleton evaluation or divisor-sign
bounds; remainder uses exact singletons or the divisor-magnitude bound clipped
by dividend magnitude/sign. The [language section](../language.md#integer-objects-expressions-and-comparisons)
states the complete transfer rules. Every nonempty zero-containing divisor is
rejected before empty propagation. The successful empty-loop native probes show
that this uniform profile restriction is conservative; it is not inherited from
Ada or required by a demonstrated frontend failure. Static invalid subtrees and
empty assignment RHSs remain excluded. Minimum/-1 is accepted for `mod`/`rem`
and rejected for quotient overflow.

The [arithmetic core review](reviews/review-integer-division-core-16d0f0cfaa.md)
found no issue at `16d0f0cfaa`, covering native code, arithmetic models, reports,
capacity and all seven sample sources. The core's focused Lean check and fresh
axiom audit passed; complete source-bridge validation and review remain separate
outstanding obligations. The new obligation class was observed in managed
native discovery before acceptance was extended. No authored program receives
hidden contracts or an annotated replacement.

The Rosetta [reconciliation](../rosetta/assessment-division-20261025.md) corrects
five dependency assessments and reserves `interval-integer-division` for this
narrow capability. The existing `integer-division` identifier also covers `abs`
and other broader assessed approaches and will remain unsupported. Seven
concrete reviewed sample approaches now map to the narrow identifier in
the prepared delivery metadata; broad uses are not migrated mechanically.

Seven implemented regressions exercise the selected fragment: Josephus (the fixed
41-prisoner, step-3 incident, zero-based survivor 30), first-n cubes (0 through
49), odd three-digit squares, the fourteen department triples, largest proper
divisors for 1 through 100, an 8-by-8 text mosaic and the task's fixed simultaneous
equations. Josephus is explicitly an incident demonstration, not an arbitrary
positive-n,k API. Expected output was derived independently from list elimination,
direct sums/searches/divisor enumeration or the requested alternating grid.
All seven await the complete sample checkpoint before supported delivery.
The independently reviewed source/manifest behavior is distinct from successful
execution of every case.

## Integrated delivery checkpoint

Implementation/source integration: `14b9302a97` (arithmetic/native core
`16d0f0cfaa`, merged planning base `ca4242ff5a`), with the proof-script-only
repair `92a3791e22` described below. The [source-bridge integration review](reviews/review-integer-division-integration-14b9302a97.md)
reports no findings for that exact target. The bounded
[repair review](reviews/review-integer-division-repairs-559ef643e3.md) reports no
findings for the proof repairs through `559ef643e3`. Full validation must identify the
actual final source inputs before closing #232/#233/#229. Linux
is the selected native platform; no new macOS or hosted-CI evidence is claimed.
The lead coordinates the managed workspaces and native worker allocations.

The first complete Lean build reached the expanded scalar source checks and
could not synthesize a decision procedure for their combined expression/header
conjunctions. Commit `92a3791e22` splits those conjunctions into individual
kernel-checked obligations, preserving every statement and the existing proof
limits. The completed repaired run retained the independent certificates and
passed the complete source and fresh axiom audit. The original failure remains
recorded separately from that successful checkpoint.

The same native checkpoint subsequently reported a 30-second timeout in
`Silver_Library_Reports.Map_OK`'s loop-invariant preservation. Repair `1d9bc08382`
names the recursive suffix as a ghost summary and explicitly establishes its
one-step equation and the existing `Advance_Map` policy equivalence. It preserves
the executable policy, original invariant/postcondition and proof settings.
Focused managed run `20261026T002009-46b35fbc8582` proved all 39 `Map_OK` checks,
including both new assertions and the invariant, in isolated scratch output using
the unchanged proof regime. An earlier selector pointed at a blank line and
generated no checks; that failed invocation is retained separately. The original
complete run finished with that single failed obligation. Its successful work
and cache remain retained. The rebuilt repaired source now has a new complete
native audit in progress. Final Lean input correspondence is retained for all
582 captured source inputs before the validation workspace was reused for the
separate guard increment.

| Required evidence | Current result and exact remaining field |
| --- | --- |
| Native compiler/runtime build | Repaired-input run `20261026T002846-e157157cf62b` succeeded. Pending retained command/log link and exact input correspondence to final implementation. |
| Full native proof and evidence audit | Repaired-input run `20261026T002857-50fd2281b177` is active after the focused repair passed. Successful complete coverage/provenance audit and retained evidence links remain pending. Original run `20261025T221851-c7c38b2dd915` failed only the recorded invariant. |
| Complete Lean/source and axiom audit | Repaired complete run `20261026T005331-e0e3d7a0bf00` passed: 467 modules and 90,288 declarations, with only `propext`, `Classical.choice` and `Quot.sound`. All 582 captured source inputs matched `dfdd0269ae` and the live validation worktree before reuse. Cached build: 39.714 seconds; fresh audit: 8.867 seconds; four workers, two threads per process. Portable evidence export remains pending the native/full-suite checkpoint. |
| Full regression and sample checkpoint | Pending run identity, result, actual tests/samples/execution-case totals, exact stdout/stderr/status comparisons and retained log/input identities. Seven new sample sources and expected outputs are implemented; success is not inferred from their existence. |
| Independent review | [Arithmetic/native core review](reviews/review-integer-division-core-16d0f0cfaa.md) reports no findings for its exact target. [Source-bridge integration review](reviews/review-integer-division-integration-14b9302a97.md) reports no findings at `14b9302a97`. Final documentation/evidence review is outside those implementation-review scopes and remains pending. |
| Rosetta reconciliation and render | Narrow identifier and seven concrete approaches prepared; full render and documentation consistency result recorded in the [assessment record](../rosetta/assessment-division-20261025.md#delivery-mapping). Pending lead's stage/board update and successful delivery checkpoint. |
| Delivery and closure | Pending final evidence record, reviewed delivery commit/PR, issue/board disposition and dated session-memory update. No completing commit or closure is claimed here. |

The [assurance chain](assurance.md#interval-checked-integer-division) links
`VC_DIVISION_CHECK` to nonzero-divisor semantics, explicit per-node mathematical
discharge, safe execution, native source equations and the inherited producer
premises. The [feature-local envelope](integer-division-report-capacity.md)
adds at most 63 records of 2,048 bytes: 15,421,440 retained bytes, below the
unchanged 16,777,216-byte domain. These source-reviewed bounds and complete
obligation discharge remain required; storage or report acceptance alone is
insufficient. No broader capacity, solver-completeness or binary-attestation
claim follows.

| Round/work | Selected or actual settings | Intended result and achieved state | Time/token/cost evidence |
| --- | --- | --- | --- |
| Native and arithmetic design/core review | Selected GPT-6 Astra, Extra High; runtime setting not independently exposed | Operator-specific transfer rules, nonzero checks, seven source approaches and envelope reviewed; no findings in the linked core scope. Complete bridge validation remains separate. | Review completion 22:22:59 UTC; whole-round elapsed, tokens and cost unavailable. |
| Source integration and validation | Live lead model/effort not independently exposed; source reviewer selected GPT-6 Astra, Extra High | Bridge integration at `14b9302a97`; complete native and Lean runs pending above. Independent source integration review reports no findings; final documentation/evidence review remains pending. | Integration review interval 22:45:59–22:49:01 UTC (3m 2s); retain managed run measurements with final evidence. Whole-team tokens/cost unavailable. |
| Delivery documentation and Rosetta mapping | Lead-selected GPT-6.1 Sol, High; runtime setting not independently exposed | Align semantic/discharge and boundary claims, map seven reviewed approaches to narrow support and render current metadata. Final validation fields remain explicitly pending. | Whole-round elapsed, tokens and cost unavailable. |

The owner's [continuation](session-memory.md#2026-10-25--continue-non-deferred-roadmap-delivery)
selects scalar guard refinement #234 after division, with its scope/design,
native, assurance and delivery packages #237–#240. Deferred #119 and related
findings/paused packets, #88–#94, PR #121 and PR #147 remain outside this work.
A completed intermediate PR is not a stop condition. This thread did not create
a harness goal or change the paused capacity harness. CLI memory was not
updated by this documentation thread.
