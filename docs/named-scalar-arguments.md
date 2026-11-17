# Named scalar arguments

## Authorization and scope — 2026-11-17

The owner selected named scalar arguments for the existing functions and
procedures after reporting the Worca #377/#378 work unavailable. The
[dated instruction](session-memory.md#2026-11-17--named-scalar-arguments-selected-while-worca-recovery-awaits)
selects [#392](https://github.com/berkeleynerd/silver/issues/392), in
[milestone 25](https://github.com/berkeleynerd/silver/milestone/25), as the next
language capability. This record specifies authorized work, not delivered
support. [#373](https://github.com/berkeleynerd/silver/issues/373) remains open
pending recovery; its implementations and the hold on draft PR #385 are preserved.

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
  records full-domain helper interpretations and a fresh audit of 49,840
  declarations. Final native-source candidate binding remains pending.
- The [behavior packet](evidence/named-scalar-arguments-392-20261117/behavior/README.md)
  records all 15 named methods passing in 32.099 seconds, including full-route
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

The remaining native recurrence proof encountered separately translated array
updates with finite element equations, obstructing recursive-function map
congruence. A bounded `Hide_Info` experiment did not resolve that issue; its
annotations and source-policy allowance were withdrawn, with failed attempts
and passing experimental-policy controls retained as history. The independently
reviewed next repair uses one shared executable mark operation with a complete
pointwise contract, checked before the tail recurrence and its loop caller.
No unproved lemma is consumed and no domain, obligation or proof budget is weakened.

The [setup record](evidence/named-scalar-arguments-392-20261117/setup/README.md)
records the native-filesystem Lean overlays and unchanged donor caches. Native
behavior runs used a 16 MiB process stack. Native workers were reduced to four
only while concurrent focused Lean checks used the remaining allocation; exclusive
checks return to automatic allocation. Exact run records distinguish rebuilt
units, retained dependencies and fresh declaration audits. Complete native,
actual-source, whole-suite and final-review checkpoints remain pending.

Selected source/native/semantic design settings are Astra Max; the bounded
scope comparison used Astra Extra High. Lead runtime identity and whole-team
cost are not independently exposed. CLI memory was not updated.
