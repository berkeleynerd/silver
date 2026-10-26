# Interval-checked Integer division

## Authorization and delivery scope

The [2026-10-25 owner instruction](session-memory.md#2026-10-25--merge-228-and-implement-interval-checked-integer-division)
authorizes [#229](https://github.com/berkeleynerd/silver/issues/229) through
complete implementation, assurance, validation, review and pull-request delivery.
The implementation and coordinated language/catalogue/sample changes are
delivered through [PR #236](https://github.com/berkeleynerd/silver/pull/236),
with the Linux validation checkpoint below. The current
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
source-correspondence validation has passed on the repaired inputs. Earlier
focused evidence is distinguished from the complete checkpoint below.
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
rejected before empty propagation. The [empty-loop native probes](integer-division-report-capacity.md#native-corroboration-and-scope-choices)
report “division check proved” under `VC_RAISE`, with dead-code diagnostics,
rather than `VC_DIVISION_CHECK`: the frontend rewrites static division by zero
to an unreachable raise. The zero-before-empty rejection is required by the
current Main report policy, which excludes `VC_RAISE`. Static invalid subtrees
and empty assignment RHSs remain excluded. Minimum/-1 is accepted for `mod`/`rem`
and rejected for quotient overflow.

The [arithmetic core review](reviews/review-integer-division-core-16d0f0cfaa.md)
found no issue at `16d0f0cfaa`, covering native code, arithmetic models, reports,
capacity and all seven sample sources. The core's focused Lean check and fresh
axiom audit passed; the complete source-bridge validation and review are recorded
separately below. The new obligation class was observed in managed
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
All seven passed the manifest-driven admission, proof, build and exact-output
checks in the complete suite below. The independently reviewed source/manifest
behavior and native execution are separate evidence.

## Integrated delivery checkpoint

Implementation/source integration: `14b9302a97` (arithmetic/native core
`16d0f0cfaa`, merged planning base `ca4242ff5a`), with the proof-script-only
repair `92a3791e22` described below. The [source-bridge integration review](reviews/review-integer-division-integration-14b9302a97.md)
reports no findings for that exact target. The bounded
[repair review](reviews/review-integer-division-repairs-559ef643e3.md) reports no
findings for the proof repairs through `559ef643e3`. The final implementation
target is `b7dfcbcdb0`, which also refreshes three checked-in generated
certificates; the machine-readable [validation index](evidence/integer-division/validation.json)
compares retained run inputs with that commit. Linux
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
and cache remain retained. The rebuilt repaired source passed the new complete
native audit: all 15,224 checks and the coverage/provenance audit succeeded.
Final Lean input correspondence is retained for all
582 captured source inputs before the validation workspace was reused for the
separate guard increment.

The complete suite ran **485 tests**. All sample and execution checks passed;
its only failures were three subcases of the checked-in certificate parity test.
The full run remains recorded as failed. Commit `b7dfcbcdb0` refreshes
`OutputBodyCertificate`, `ScalarExpressionBodyCertificate` and
`ScalarsSpecCertificate` from the unchanged authoritative sources and generator.
The affected test then passed in managed run `20261026T032402-770b4c60bac2`
(4.216 seconds). An intervening whole-file run used the old certificates and
reported the same failures; it supplies no repaired-success claim.

The complete Lean runner generates these candidates in its isolated workspace
and excludes checked-in candidates from its captured source inputs. All **582**
captured inputs remain byte-identical to the final implementation, including the
actual source, generator, handwritten proofs and tooling. Refreshing the checked-in
copies therefore does not invalidate that successful audit. The native proof/build
inputs likewise remain unchanged. The division full suite remains failed; the
focused rerun establishes repaired certificate parity, but it did not rerun every
test that reads the refreshed certificates. The later
[scalar-guard checkpoint](scalar-guard-refinement.md#delivery-assurance-and-validation),
including full run `20261026T110119-3b18a2302af0` and its independently reviewed
focused auditor repair, supplies complete regression coverage for the current
implementation under the [reviewed reuse policy](../development.md#proof-loop-and-validation).
No successful whole-suite rerun is claimed for the historical division target.

| Required evidence | Result |
| --- | --- |
| Native compiler/runtime build | `20261026T002846-e157157cf62b` succeeded; commands, logs and final input comparison are retained in the validation index. |
| Full native proof and evidence audit | `20261026T002857-50fd2281b177` passed all **15,224 checks** and complete coverage/provenance auditing: 75 units, 1,007 entities, 1,303 flow checks and 13,921 proof checks; 5,801.392 seconds with four workers. The audit line, time and retained provenance are indexed. |
| Complete Lean/source and axiom audit | `20261026T005331-e0e3d7a0bf00` passed: **467 modules, 90,288 declarations**, only `propext`, `Classical.choice` and `Quot.sound`. All 582 captured inputs match the final implementation. Cached build 39.714 seconds; fresh audit 8.867 seconds; four workers and two threads per process. No independent kernel replay is claimed. |
| Regression and sample checkpoint | Full run `20261026T020550-192982f3d06e`: 485 tests, the three parity subcase failures above, all **47 manifest samples / 103 execution cases** passed. Repair run `20261026T032402-770b4c60bac2` passed the complete certificate parity method. Symlinked-TMPDIR tests passed. Commands, original outcomes, logs and input comparisons are retained. |
| Independent review | The linked arithmetic/core, source integration and proof repair reviews report no findings in their exact scopes. The [final documentation/evidence review](reviews/review-integer-division-delivery-384cb43a24.md) reports no correctness, source-correspondence or evidence findings at `384cb43a24`; its table-formatting suggestion is fixed. |
| Rosetta reconciliation and render | The [assessment record](../rosetta/assessment-division-20261025.md#delivery-mapping) records the narrow supported identifier, seven concrete approaches and complete render. #11 remains stage 2; arrays #12 remains stage 3. |
| Delivery | PR #236 carries the completing commit for #229–#233. The next authorized increment is scalar guard refinement #234, under the existing continuation. |

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
| Source integration and validation | Live lead model/effort not independently exposed; source reviewer selected GPT-6 Astra, Extra High | Bridge integration and proof repairs passed complete native and Lean audits. Independent source integration review reports no findings; exact final documentation/evidence review is separate. | Integration review interval 22:45:59–22:49:01 UTC (3m 2s); retain managed run measurements with final evidence. Whole-team tokens/cost unavailable. |
| Delivery documentation and Rosetta mapping | Lead-selected GPT-6.1 Sol, High; runtime setting not independently exposed | Align semantic/discharge and boundary claims, map seven reviewed approaches to narrow support and render current metadata. Validation records preserve failed parity and its focused successful repair, with unchanged-input reuse. | Whole-round elapsed, tokens and cost unavailable. |
| Certificate parity repair | Lead setting not independently exposed; evidence-export thread selected GPT-6 Astra, Extra High | Refreshed three stale checked-in candidates; full-suite sample checks passed and the repaired parity test passed. Native and complete Lean inputs unchanged. | Full suite 4,361.623 seconds; repaired parity 4.216 seconds; whole-team tokens/cost unavailable. |
| Final delivery-record review | Selected GPT-6 Astra, Extra High; runtime setting not independently exposed | Independently checked retained artifacts, run outcomes and final input correspondence; no correctness or evidence findings. Repaired the suggested table formatting. | 03:30:51–03:37:12 UTC (6m 21s); tokens/cost unavailable. |

The owner's [continuation](session-memory.md#2026-10-25--continue-non-deferred-roadmap-delivery)
selects scalar guard refinement #234 after division, with its scope/design,
native, assurance and delivery packages #237–#240. Deferred #119 and related
findings/paused packets, #88–#94, PR #121 and PR #147 remain outside this work.
A completed intermediate PR is not a stop condition. This thread did not create
a harness goal or change the paused capacity harness. CLI memory was not
updated by this documentation thread.
