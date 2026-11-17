# Named scalar arguments

## Authorization and scope — 2026-11-17

The owner selected named scalar arguments for the existing functions and
procedures after reporting the Worca #377/#378 work unavailable. The
[dated instruction](session-memory.md#2026-11-17--named-scalar-arguments-selected-while-worca-recovery-awaits)
selects [#392](https://github.com/berkeleynerd/silver/issues/392), in
[milestone 25](https://github.com/berkeleynerd/silver/milestone/25), as the next
language capability. [Stage #393](https://github.com/berkeleynerd/silver/issues/393)
tracks its precise Rosetta construct; broad #11 remains separate. The
bounded capability is supported; the [delivery record](#delivery-assurance-and-validation)
retains complete Linux native/Lean assurance, the passed whole suite and closing
independent review. [#373](https://github.com/berkeleynerd/silver/issues/373)
remains open pending recovery; its implementations and the hold on draft PR #385
are preserved.

Add ordinary Ada named associations to calls of existing Integer/Boolean scalar
functions and procedures. Retain fully positional calls; admit fully named
calls in arbitrary order and a positional prefix followed by a named suffix.
Every formal must be supplied exactly once. Selector matching follows Ada's
case-insensitive identifier rules and uses the called subprogram's formal
namespace. Unknown, duplicate or missing selectors and positional actuals after
a named association are rejected.

Defaults, omitted actuals, overloads, new parameter/result types, new effects,
captured outer values and nested calls in actual expressions remain outside
this increment. Existing call placement, earlier-only ordering, full-domain body
checking, result ranges, explicit modes, source-written output initialization,
incoming-state evaluation and conservative alias/copy-back rules remain intact.
The complete-source and expression budgets are unchanged.

## Faithful driver and alternatives

[Named parameters](../rosetta/n/named-parameters/task.wiki) requires a function
whose actuals can be visibly bound to formal names independently of their order.
Defaults and omission are optional. Its old stored approach uses an output
procedure and a default; neither is necessary to meet the primary task.

Use a noncommutative function such as `Subtract (Left : in Small; Right : in
Small) return Difference`, with `Small` equal to `-100 .. 100` and `Difference`
equal to `-200 .. 200`. The body returns `Left - Right` over the entire declared
domain. Positional `Subtract (5, 3)`, reordered `Subtract (Right => 3, Left =>
5)` and mixed `Subtract (5, Right => 3)` each return `2`; swapping the values
returns `-2`. Print the results in Main and derive exact Image formatting
independently. Procedure regressions separately exercise output and `in out`
binding, including caller names that coincide with selectors.

Read-only fixed-array function parameters are a useful later candidate, with
[Dot product](../rosetta/d/dot-product/task.wiki) as a faithful callable driver.
They additionally need named constrained array types and aggregate call frames.
[String append](../rosetta/s/string-append/task.wiki) requires variable-length
storage or an appropriate verified library abstraction. Named scalar arguments
reuse the delivered value and call semantics without those new representations.
No timing or memory improvement is inferred from this comparison.

## Implementation and assurance obligations

The current call scanners in `src/silver_output_profile.adb` visit formals in
declaration order. Existing function/procedure metadata already retains formal
name spans. Establish a checked association-to-formal mapping and prove unique,
complete matching before relying on the existing typed-actual rules. Choose its
native representation and Lean interpretation together; a matching source hash
or a correct abstract permutation alone does not establish correspondence.

All input actuals are checked against the same incoming state. A Boolean actual
cannot refine another actual, and output updates cannot affect later input
checking. Procedure writable targets remain pairwise distinct and cannot occur
in another actual's read expression. Named selectors are labels, not reads:
alias analysis must inspect actual payloads without treating selectors as caller
variables. Prove the connection between written argument order, formal order and
copy-back rather than assuming an evaluation order Ada does not promise.

The existing source-derived formal pool (`Max_Source_Length / 7`) is not an
authorization for an additional fixed association-count limit. Derive bounds for
any new mapping/visited storage and account for native stack effects. Check
producer diagnostics and the report-capacity account; do not widen accepted
messages without observed pinned-producer evidence and corresponding policy
tests. Preserve exact admitted source bytes through proof and compilation.

Implement this as one coherent capability with focused native and Lean helper
checks followed by one shared complete checkpoint. Functions and procedures
share the association rule, while procedures additionally require payload-aware
alias and copy-back correspondence. Keep their native implementation, semantic
readings and handwritten source proofs synchronized.

## Validation and delivery

Before complete checkpoints, prove each new/changed helper's full contract and
affected caller obligations, and check the corresponding focused Lean targets.
Include malformed/empty states permitted by helper preconditions. Positive
fixtures must compile and check output through the full route; admission-only
success cannot establish this feature's behavior.

Discriminating controls cover positional compatibility, arbitrary named order,
mixed calls, case folding, Integer/Boolean signatures, all procedure modes,
wrong types/ranges, unknown/duplicate/missing selectors, positional-after-named
syntax, comments/whitespace, selector/value-name collisions, writable aliases,
same-incoming-state evaluation, calls in earlier subprogram bodies, branches,
loops and unreachable paths. Test capacity endpoints and names that shadow
other declarations. Preserve existing source-policy mutation controls.

Update language, catalogue, function/procedure capability records, assurance and
trusted-boundary descriptions together. Add a precise named-scalar-arguments
Rosetta construct and the faithful sample after validation; broad #11 remains
open. Keep original assessment provenance and attribute the new task review.

On stable final inputs, complete native proof/audit, compiler build, Lean/source/
module/axiom assurance and the regression/sample suite, followed by independent
review. Record actual Linux host, requested/granted resources, fresh/cached scope
and failed attempts. Reuse applicable artifacts under the existing invalidation
rules; changing parser source still requires actual-source certificates. No CI,
mandatory kernel replay or global proof-budget increase is selected.

## Work record

The implementation uses the existing source-derived 585-slot formal pool and
retains formal-order call semantics. Native code scans written associations,
checks distinct complete coverage and applies procedure updates in written order;
the semantic proof reorders the paired formals/payloads without changing source.
There is no additional author-visible association-count limit.

Focused evidence on Linux aarch64 `silver-m4pro` (12 CPUs, about 16 GiB RAM,
no swap):

- The [semantic model packet](evidence/named-scalar-arguments-392-20261117/model/progress.md)
  records a final focused audit of 314 modules and 26,420 declarations. The
  [independent critical review](reviews/review-named-scalar-semantics-20261117.md)
  found no defect in its 19-module slice and independently verified all 1,119
  captured input hashes.
- The [source helper/library packet](evidence/named-scalar-arguments-392-20261117/source/README.md)
  records full-domain helper interpretations and a fresh marker-helper audit
  of 49,919 declarations. The
  [independent source review](reviews/review-named-scalar-source-20261117.md)
  found no static correspondence or domain defect in the frozen candidate slice
  and checked its complete 76,980-token pin against native source. The final
  three-candidate union passed with a fresh audit of 243 modules and 20,793
  declarations. Two stale proof scripts required a bounded repair; their failed
  run and the independently reviewed successful checks are retained. The
  later [complete checkpoint](#delivery-assurance-and-validation)
  separately establishes integrated actual-source assurance.
- The [behavior packet](evidence/named-scalar-arguments-392-20261117/behavior/README.md)
  records all 16 final named methods passing in 35.218 seconds, including full-route
  positives, source-size endpoints and discriminating rejection controls. The
  Named parameters sample compiled with unchanged source and produced its four
  independently derived output lines. Its five-unit report audit counted 20
  flow checks, 51 proof checks and the required function termination witness;
  existing advisories suffice. This is focused behavior evidence, not the final
  repository suite.
- The [producer inspection](evidence/named-scalar-arguments-392-20261117/producer/README.md)
  and [capacity extension](scalar-procedures-report-capacity.md#named-scalar-associations--392)
  derive an unchanged 49,279,744-byte retained-report envelope in 64 MiB. Selectors
  add source bytes while preserving each actual's delimiter/payload reservation.

The native recurrence proof initially encountered separately translated array
updates with finite element equations, obstructing recursive-function map
congruence. A bounded `Hide_Info` experiment did not resolve that issue; its
annotations and source-policy allowance were withdrawn, with failed attempts
and passing experimental-policy controls retained as history. The completed
repair uses one shared executable mark operation with a complete pointwise
contract, checked before the tail recurrence and its loop caller. All 26 planned
whole-subprogram scopes passed, covering 506 checks; the
[native coverage ledger](evidence/named-scalar-arguments-392-20261117/native/coverage.md)
records exact captured inputs and applicability. The
[independent native review](reviews/review-named-scalar-native-20261117.md)
verified complete scope, unchanged dependency closures and final-source applicability.
The catalogue exporter and its
caller also passed their complete selected scopes. No unproved lemma is consumed
and no domain, obligation or proof budget is weakened.

The [compiled storage inspection](evidence/named-scalar-arguments-392-20261117/stack/README.md)
accounts for the 585-slot visited set and transient by-value mark operation.
It reports local frame sizes, not a universal stack bound or a memory improvement.
Final behavior and catalogue parity checks passed after rebuilding both changed
Ada units.

## Delivery assurance and validation

The [setup record](evidence/named-scalar-arguments-392-20261117/setup/README.md)
records the native-filesystem Lean overlays and unchanged donor caches. Native
behavior runs used a 16 MiB process stack. Native proofs used four workers to
share the host with Lean. During the complete checkpoint, the original Lean
process group was temporarily stopped to avoid overlapping dense memory peaks,
then resumed unchanged after native proof/build completed. The post-audit build
reconsidered resources and used automatic allocation. Exact run records distinguish rebuilt
units, retained dependencies and fresh declaration audits. The
[complete native packet](evidence/named-scalar-arguments-392-20261117/complete-native/README.md)
records successful run `20261117T034048-8c22c1e6a33d`: 78 units, 1,252 entities,
1,751 flow checks and 17,975 proof checks, with complete coverage and provenance
accepted. It generated fresh reports and sessions with a seeded solver-cache
overlay; actual cache hits are unobserved. The post-audit build
`20261117T055412-08a00820e2ef` passed with both binaries up to date and an automatic
11-worker reservation. Its 147 tracked native inputs match the combined source
snapshot.

The [complete Lean packet](evidence/named-scalar-arguments-392-20261117/complete-lean/README.md)
retains the original run `20261117T040626-c2b89a81f8a6`, which passed the
source-candidate chains but failed in `ComposeModelHelperEquations` at the
8,192 MiB kernel memory threshold, without completing the audit. It used one
Lake worker and the default 12 process threads. Its same process resumed at
`2026-11-17T05:55:26.052388Z` after a 3,776.511-second internal resource-scheduling
pause. That pause belongs only to this failed run.

The unchanged complete-module serial gate `20261117T064503-a6b27d1c4b6a`
then passed, covering 142 modules and 15,893 declarations, with 96.563 seconds
of build time and a 2.068-second audit. No source, theorem statement, domain or
proof budget changed for the memory repair.

Final complete run `20261117T064945-d458c99ae977` passed the actual-source and
whole-project module/axiom audit, freshly auditing 1,035 modules and 166,332 declarations with only
`propext`, `Classical.choice` and `Quot.sound`. It used one Lake worker, one
process thread and the unchanged 8,192 MiB internal per-process memory setting,
with the same external 10 GiB process-tree RSS and 1.5 GiB host-available-memory
guards. Its wrapper elapsed time was 25.027 seconds; recorded peak process and
process-tree RSS were 2,628,960 KiB and 3,722,736 KiB. This successful run was not
paused. Inputs were unchanged; matching objects were retained while outstanding consumers
rebuilt. The packet records exact
provenance and fresh/cached applicability; this is not a clean rebuild or
independent kernel-replay claim.

The first complete suite ran all 715 methods but exposed two failing source-policy
methods (three failure records): the nine tracked output-body certificate copies
had not been synchronized with the freshly generated, successfully audited
workspace. The [synchronization record](evidence/named-scalar-arguments-392-20261117/certificate-sync/README.md)
retains that failed run and the independently verified nine-file repair at
`20e055be873f04a05d520b4e50f0e066515b7d4f`. Every replacement exactly matches the
successful complete proof's generated inputs; effective native and Lean inputs
are unchanged. All 17 source-policy methods then passed, including the native
certificate probe. The fresh complete suite then passed on that repaired frozen head.

The [final complete suite](evidence/named-scalar-arguments-392-20261117/complete-suite/README.md),
run `20261117T072619-37479dd61ba9`, passed **715 tests in 1,160.908 seconds:
713 passes and two expected Linux x86-64-only skips**. All eight native Lean
probes executed. The exact inventory includes all 16 named-scalar methods and
86 manifest samples / 149 execution cases. This was fresh test execution using
retained validated compiler/tool binaries, with automatic 12-worker allocation
and the observed 16 MiB process stack. Every captured input, native manifest and
binary matched after the run; no results from the failed suite substitute for
this complete success.

The [closing independent review](reviews/review-named-scalar-delivery-20261117.md)
records exact targets, evidence applicability and the disposition of the
certificate synchronization finding. The stable tested implementation is
`20e055be873f04a05d520b4e50f0e066515b7d4f`; subsequent closeout changes contain
documentation/evidence only. The precise Rosetta mapping adds Named parameters,
raising supported task mappings from 84 to 85; broad functions, procedures and
array stages remain separate. Issue-open-to-final-validation elapsed time was
5 hours 50 minutes 16 seconds, including overlapping work, failed attempts and
the recorded scheduling pause. It is not CPU time or model cost. The checkpoint
used one complete native attempt, two complete Lean attempts (failed then cached
success), and two complete suites (failed then fresh success), plus the recorded
focused checks. Local Linux validation is complete; CI and independent kernel
replay were not run. Publication is authorized; merge is not.

Selected source/native/semantic design settings are Astra Max; the bounded
scope comparison used Astra Extra High. Lead runtime identity and whole-team
cost are not independently exposed. CLI memory was not updated.
