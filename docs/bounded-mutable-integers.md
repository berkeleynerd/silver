# Bounded mutable integers

**Complete on Linux x86_64, 2026-10-17.**
The owner authorized implementation through delivery after completion of
[scope work #67](https://github.com/berkeleynerd/silver/issues/67).
[Session memory](session-memory.md#2026-10-17--bounded-mutable-integers-implementation-authorized)
records authorization for [milestone 4](https://github.com/berkeleynerd/silver/milestone/4)
packages #68–#70, under the narrow [stage #11](https://github.com/berkeleynerd/silver/issues/11)
increment below. The [delivery evidence](evidence/bounded-mutable-integers/delivery-validation.json)
records the completed assurance, validation and review, with actual input identities.
The completed For loops and integers harness goal remains complete.

The selected capability lets a program retain and update an Integer result
inside a statically declared range. It builds on the existing Integer
expressions, finite loops, String composition and standard Integer Image.
[language.md](../language.md) continues to describe current support; the
[Oracle](../oracle.md) and [development workflow](../development.md) govern
this extension.

## Motivating program

[Find square difference](../rosetta/f/find-square-difference/silver.md) needs
one mutable result, an object-local range constraint and the existing loop,
arithmetic, condition and Image forms:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Answer : Integer range 0 .. 1000 := 0;
begin
   for N in 1 .. 1000 loop
      if Answer = 0 and then
        ((N * N) - ((N - 1) * (N - 1))) > 1000
      then
         Answer := N;
      end if;
   end loop;
   Silver_IO.Put_Line (Integer'Image (Answer));
end Main;
```

The output is ` 501` followed by LF, preserving Ada's leading space.
The square difference is `2*N - 1`; the first satisfying index is 501.
All arithmetic fits Integer using the loop-index interval alone, and every
assignment lies in `0 .. 1000`. The comparison with Answer selects the first
result; it supplies no range fact needed for safety. The native compile/execution probe produced the expected bytes,
` 501` followed by LF. The checked-in [sample](../samples/find_square_difference.adb) uses this
source. That observed result remains distinct from universal/source assurance.

## Selected admission rules

The ordered declaration region admits the following object declarations,
with scalar assignment wherever an ordinary assignment is allowed:

```text
integer_declaration ::= name ":" [ "constant" ] "Integer"
                        [ "range" static_scalar_expression ".."
                          static_scalar_expression ]
                        ":=" scalar_expression ";"
integer_assignment  ::= mutable_integer_name ":=" scalar_expression ";"
```

An object-local range constraint creates no new named type or subtype. A plain
Integer object has the pinned range -2147483648 through 2147483647. Explicit
endpoints must be in that range and ordered `L <= U`. A null range contains no
value for the required initializer. One initialized name per declaration,
existing expression grouping and literal spelling, and the common String/scalar
namespace remain in force.

Static range expressions use the existing scalar operators and literals plus
earlier Ada-static Integer constants. Staticness is recursive: the constant's
subtype and initializer must be static under
[Ada RM 4.9](../references/ada/2022/RM-4-9.html). Merely knowing a value during
admission does not make its source expression static. Mutable names, loop
indexes and constants initialized from mutable objects cannot supply a static
range endpoint. All intermediate operations in a bound expression must satisfy
the existing Integer safety rules.

Declarations still precede all executable statements. Every scalar initializer
reads only earlier initialized scalars, with no numeric external input or
intervening assignment. Admission can therefore calculate its exact initial
value in declaration order. It must establish that value lies in the declared
range. Record separately:

- the exact initial value, used for subsequent declaration snapshots;
- the object's immutable or mutable status and declared range;
- whether a constant is Ada-static and may appear in a later range bound.

For example, after `A : Integer range 0 .. 99 := 7`, a later
`K : constant Integer := A` captures 7, while a later
`S : String := Integer'Image (A)` captures the two bytes ` 7`. Writes to A
change neither K nor S. K is immutable but its initializer is not Ada-static,
so it cannot define a static range bound. The implementation retains separate
metadata for exact values, staticness, declared ranges and mutability.

At every executable-body read, a mutable scalar contributes its **entire
declared range**. Immutable scalar snapshots retain their exact values;
loop indexes retain their checked iteration intervals. An assignment is admitted
only when every intermediate RHS operation fits Integer and the complete RHS
interval is included in the target's declared range. Evaluate the RHS using
the pre-assignment store, then update exactly the target. Self-reading assignments
are allowed when that same rule succeeds. Constants and loop indexes cannot be
assignment targets, and String/scalar assignments remain type-distinct.

Assignments and scalar comparisons do not narrow mutable ranges. In particular,
`X : Integer range 0 .. 9 := 0` does not permit `X := (X + 1)`, even after a
reset or under `X < 9`: its body interval is `[0,9]`, giving `[1,10]` for the RHS.
Conversely, `X := (9 - X)` fits `[0,9]` and needs no information from an earlier
iteration. These are explicit limits of this first admission analysis; Ada
permits more programs. General accumulation needs a separately justified
value-flow or guard-refinement rule.

Even in an empty loop, target type/mutability, visibility and static expression
legality must be checked. Index-dependent empty intervals retain the existing
vacuous safety treatment; they do not admit assignment to an immutable index
or a hidden outer object.

Existing visibility rules extend across mutable objects and constants. Names
must be distinct in the outer declaration region, and forward/self-initializer
references are excluded. The Integer type mark must remain visible, including
inside its own object declaration. Loop indexes may hide mutable objects but
remain immutable themselves. Qualified library operations remain available
when an object hides an unqualified operation.

## Composition requirements

Both output-capable shells admit these declarations after their existing
prefix; the argument shell still starts with its sole immutable argument
binding. Scalar values may appear in all existing scalar-expression positions:
initializers, range bounds subject to staticness, comparisons, loop bounds and
Integer Image. Scalar assignments compose with String assignments, all choices,
nested forward/reverse loops, null, Put, Put_Line and returning Reject.

Execution must carry the scalar store through statement sequences, branch
selection and every loop iteration. Each initialized mutable object stays in
its declared range. Branch joins and loop back edges need no stronger scalar
facts. Existing input validity/length facts and sticky rejection/output behavior
retain their meaning; a scalar assignment cannot create input facts or erase
an earlier failure.

Evaluate both loop bounds once in the entry scalar store. Later writes to an
object mentioned in a bound do not alter that iteration sequence. A nested loop
evaluates its own bounds when it is entered. Empty loops preserve both stores;
nonempty loops preserve writes to outer mutable objects. Restore only the
index's lexical scope on exit. Do not restore the entire scalar store and lose
body assignments. The current empty/definite/uncertain treatment of String/input
facts still applies, with scalar range preservation proved alongside it.

String initialization retains its existing exact-length requirement. Exact
declaration snapshots support Image initializers without making a String's
fixed bounds depend on later scalar writes. In the executable body, Image
length is derived afresh from the current expression's abstract interval, using
the existing decimal length rule. For a mutable object that interval is its
declared range. A range `10 .. 99` always yields length 3; `0 .. 1000` yields
lengths 2 through 5. The former can support a matching fixed-length String
assignment; the latter cannot assign its Image to a fixed-length target merely
because the most recent scalar assignment selected one length.

The existing capacity, input-validity and exact assignment-length rules apply
in every String-expression position, including Image in comparisons and
concatenations. Repeated Image calls observe the actual value at each call;
captured String values remain snapshots. No fact about equality to an earlier
Image may be reused as a fact about the mutable scalar after a write.
Facts already derived about immutable input length or fixed String lengths
remain valid. This distinction needs no general dependency graph when body
analysis always uses the declared scalar ranges.

## Assurance boundaries

The implementation connects the following boundaries. The evidence below
distinguishes focused development checks from the complete delivery checkpoint:

| Boundary | Implementation and required guarantee |
| --- | --- |
| [Scalar expression environment](../src/silver_scalar_expressions.ads) and [native output profile](../src/silver_output_profile.adb) | Distinguish exact declaration values, Ada-staticness, mutability and declared ranges; recognize constrained objects and typed scalar assignments; establish native contracts and body-state rules. |
| [Integer declarations](../proof/Silver/IntegerDeclarations.lean), [composition declarations](../proof/Silver/ComposeScalarDeclarations.lean) and [frozen semantics](../proof/Silver/ComposeFrozenSemantics.lean) | Specify initialization, snapshots, range inclusion, mutability and name resolution; prove the declaration-to-body abstraction preserves concrete values. Replace the all-static premise with an elaboration-store relation. Preserve stable scalar identities when separating static constants from mutable or nonstatic bindings. |
| [Predicate execution](../proof/Silver/PredicateExecution.lean) and its checking/composition modules | Return and thread mutable scalar state through checked and ordinary execution; prove assignment safety, range preservation, finite-loop composition and agreement. The evaluator now carries the mutable scalar store through each checked composition. |
| Native equations, source certificates and whole-source bridges | Match every changed SPARK body to its semantic equations, extend declaration/statement decoding and correspondence, and review regenerated pins with those changes. |
| [Image producer and consumer boundary](trusted-boundary.md#image-proof-adapter-boundary) | Re-establish applicability for mutable reads, declaration snapshots and constrained objects; verify the unchanged Image meaning, selected schemas and size-12 Main translation, or repair the owned connection if required. |
| [Report capacity](report-capacity.md#for-loops-and-integers-extension) and report policy | Derive all new declaration/assignment/range-check and advisory charges from source/producer routes; cover every selected report and required obligation. The [mutable producer review](bounded-mutable-report-capacity.md) derives the combined envelope from the pinned routes, including scalar declarations, constraints, assignments and Image translation. |

The model must establish automatic-discharge schemas as well as safety and
execution meaning. Native application evidence must use the actual submitted
Ada source with the pinned proof configuration and no loop unrolling. Existing
[tool-contract premises](trusted-boundary.md) remain explicit; neither the
scope argument nor passing samples proves solver completeness for the extension.

Retain the 4096-byte source/value bounds, 64 leaves per expression and repaired
shared 63-operator budget. Arithmetic in range constraints also spends that
budget. Recheck source-derived binding and statement bounds. The earlier
15,028,224-byte derivation covered constant-only declarations. The new combined
envelope is **15,292,416 bytes**, leaving **1,484,800 bytes** in the existing
16 MiB allocation. It charges shorter mutable declarations, assignment-root
range checks, constraints, flow advisories and Image translation. The
[producer review](bounded-mutable-report-capacity.md) supplies the derivation;
the dense specimen corroborates it without replacing the universal bound.

## Validation coverage

The focused native work addresses the technical questions recorded during
scoping. The integrated checkpoint below covers the final combined inputs:

1. Confirm declaration snapshots and staticness through the selected frontend:
   a mutable initializer, a constant copying it, a captured String Image, and
   a later scalar write. Check static-bound acceptance/rejection separately.
2. Inspect genuine reports and generated Image models for the driver and a
   small combined interaction case: constrained assignment, branch, nested
   loop, a bound object written inside its loop, and output after the loop.
   Confirm both execution and applicable producer schemas.
3. Exercise constant-width versus varying-width Image assignment and rejection
   of overflowing/out-of-range scalar assignments, including endpoint values
   and guarded cases that the non-refining analysis deliberately excludes.
4. Review the producer's extra checks/advisories and source-derived envelope,
   then use a dense legal specimen to corroborate it. Map any new diagnostic
   to its exact semantic rule rather than broadening accepted warnings.

Use the managed [proof-iteration workflow](proof-iteration.md). Share applicable
evidence between native and assurance packages. Start with the smallest probe
that resolves a stated uncertainty; preserve its actual inputs and report before
changing them. A recurring failure needs a diagnostic checkpoint and new
hypothesis. Do not repeat an unchanged successful broad audit for bookkeeping.
Complete native and Lean validation belongs at the integrated implementation
checkpoint, with focused checks during development and independent review
proportionate to the changed boundaries.

No Oracle amendment was needed. Declaration/body separation, producer
applicability and the extended report envelope are part of this implementation
and assurance, with complete validation required before support.

## Work packages and completion

| Order | Package | Completion criterion |
| --- | --- | --- |
| 1 | [#67 Scope and automatic-proof design](https://github.com/berkeleynerd/silver/issues/67) | Record the driver, exact proposed rules, composition, exclusions, assurance boundaries, evidence plan and ordered issues; review and publish the scope. Completed through PR #72. |
| 2 | [#68 Native admission and regressions](https://github.com/berkeleynerd/silver/issues/68) | Resolve focused frontend/producer questions, implement verified SPARK declaration and assignment rules, preserve existing behavior, and retain boundary/composition regressions and genuine reports. |
| 3 | [#69 Universal and actual-source assurance](https://github.com/berkeleynerd/silver/issues/69) | Establish mutable-store semantics, range preservation, complete safety/discharge composition, actual-source correspondence, Image applicability and the extended report envelope; validate every affected endpoint. Coordinate with #68. |
| 4 | [#70 Validation, review and delivery](https://github.com/berkeleynerd/silver/issues/70) | Complete stable Linux validation and independent review of the integrated inputs, resolve findings, and synchronize language, catalogue, samples, capability, roadmap and Rosetta records before claiming support. |

All four packages are complete. PR #73 recorded the authorization for #68–#70
through implementation, assurance and delivery. The board and issue handoffs
track publication and closure. Native macOS validation remains independent and
nonblocking; hosted CI remains disabled.

## Exclusions and stage mapping

Named subtype/type declarations and explicit conversions remain in #11: this
increment uses object-local constraints of the existing Integer type. Dynamic
range constraints require a separate elaboration/bound-lifetime argument.
Scalar guard refinement and stronger loop-carried value analysis need additional
proof rules. Division, other scalar types/images, additional loop forms,
procedures and arrays remain outside this capability. Existing exclusions on
uninitialized objects, multiple declared names and inner declaration regions
continue to apply.

The Rosetta update introduces the narrow `bounded-mutable-integers` identifier
and maps Find square difference to the existing-language stage (position 15;
35 tasks in that stage). It leaves broad `integers`, `ranged-subtypes`,
`for-loops` and `scalar-image` unsupported. Stage #11 remains open with ten
tasks requiring its remaining forms; procedures and arrays retain their later
positions. Existing-language Rosetta sample work on #9 remains separate. The
[assessment review](../rosetta/bounded-mutable-integers-delivery-review.md)
records the exact mapping and preserved exclusions.

## Implementation and focused evidence — 2026-10-17

The implementation branch is `feat/bounded-mutable-integers`. The native
recognizer changes began in `d3a4885ed6` (native lane `264c7edbd0`); the later
cursor-contract clarification is `537c1a245d` (native lane `04240f5df6`).
The selected grammar and semantics are unchanged by that clarification.
Language, catalogue, native export, sample and Rosetta changes are committed.
The native implementation inputs are `d83927cef3`; `fc983799c3` adds its final
independent source review. Later `54551e49f9` completes the selector proof and
`bbd5989b2b` refreshes generated snapshots; the latter is the complete delivered
input tree. This section records focused development evidence. The integrated
checkpoint below identifies final results and review targets separately.

The semantics separates exact declaration elaboration from body ranges in
`IntegerMutable` and `ScalarExpressionConstants`. `Assignment.check_sound`
proves evaluation safety and preservation of the scalar range invariant.
`Predicate.Execution` carries both stores through statements and iterations;
`restoreIndex` restores only the loop index. At the program endpoint,
`Program.scalar_execution_invariant` preserves every declared scalar range,
`Program.execution_sound` proves checked/ordinary execution agreement, and
`Program.all_obligations_discharge` covers declaration, initializer and body
schemas. `Sequence.scalar_tokens_objects` connects parsed declarations to
ordered object elaboration. `Predicate.form_reading_valid` connects that trace
to the widened body context and checked program. These are machine-checked model
and frontend results; exact native helper/source correspondence is a separate
required connection completed by the reviewed helper and source-check changes
recorded below.

Retained native admission probes cover staticness, snapshots, range containment,
empty-loop legality, Image width, guard non-refinement and name visibility.
Run `20261017T005405-55885e79d1d5` passed seven admission methods. Run
`20261017T005429-cfeb5626a484` compiled and executed the snapshot/Image and
loop-bound cases, producing ` 7 7 8 99\n` and ` 501\n 3 1 7\n`.
Those runs used the native worktree and its actual inputs, before the cursor
clarification; focused rechecks and integrated validation are recorded separately.

The frontend integration at `1421a903e5` passed a fresh audit of 15,425
declarations; adapter/loop exact rendering at `c5d31fd5c9` passed a fresh audit of
14,473 declarations. Both audits permit only `propext`, `Classical.choice` and
`Quot.sound`. No clean build or independent kernel replay is claimed.
The initial native exploratory run `20261017T005642-23ef5fcd65f0` left the
`Scalar_Constraint_At` cursor postcondition unresolved. After naming the delimiter
cursor and explicitly checking it, targeted run `20261017T011710-7a2283e0c59a`
proved that routine's 341 checks. The earlier failed record remains retained;
a targeted success is not a replacement for the required complete audited run.

## Integrated validation and review

The final validation checkpoint is complete. The
[machine-readable record](evidence/bounded-mutable-integers/delivery-validation.json)
binds the actual native, Lean and test inputs to `bbd5989b2b`, distinguishing
its generated snapshots from authoritative proof inputs and retaining failures.

The initial complete Lean run `20261017T021003-1cc505ed3a9d` exposed missing scalar-assignment
alternatives in `PredicateSelectors`: the semantic flag function and the
source-lowering flag proof had not yet covered the new constructor. The repair
is committed as `54551e49f9` (repair lane `768ce4d4ed`) and independently
reviewed in `41d4bb07da` (review lane `cf15eb1bd4`). It adds the assignment flag
and its lowering proof without changing native behavior or range semantics.
The initial complete run retains its completed objects; it is not successful
assurance evidence. Focused run `20261017T024103-91cbfeaba0b4` passed a fresh
audit of 13,689 declarations. Resumed complete run
`20261017T024125-7b26370b62f2` passed all 466 modules and freshly audited
89,339 declarations, using only `propext`, `Classical.choice` and `Quot.sound`.
Its authoritative input digest is
`951c3440ec24e971e40719035a07d1e920ac56bbc83b4c28c6cccc4c20c3990f`.
The final cached run took 22.355 seconds, reusing the initial run's completed
source checks; that initial build took 1,838.329 seconds and failed on the
selector omission. These are separate costs and outcomes.

The [independent review](reviews/review-bounded-mutable-integers.md) found two low
consistency defects, both repaired in `b0f0af3522`: [#74](https://github.com/berkeleynerd/silver/issues/74)
adds the constrained-constant catalogue token skeleton, and
[#75](https://github.com/berkeleynerd/silver/issues/75) selects the assignment
report policy for Integer samples. The exact native catalogue export passed
run `20261017T013750-268a83390c8e`, following native build
`20261017T013651-ba9e762f6662`. Review found no runtime or universal-model defect;
its final source-linkage and aggregate-repair review is complete through
`d83927cef3`, followed by the selector review at `768ce4d4ed`. The final
validation above closes the delivery boundary without repeating the review.

The new scalar source requirements first exposed an extractor mismatch:
`Scalar_Target` returns qualified `Scalar_Expressions.Binding_Count`, whereas
the draft used the unqualified-return extractor. `700b39de58` uses the existing
qualified extractor and isolates all six exact helper requirements in a focused
candidate module. Run `20261017T013421-bcdee034fa2a` passed a fresh audit of
16,217 declarations. The original failure
`20261017T012407-d8d8f5eb7ca7` remains retained; this was a source-check wiring
repair, with no native behavior change.

The final declaration/model equations, legality and ranges passed together in
helper run `20261017T013548-b72a0d98f428`, with a fresh audit of 14,219
declarations. Factored typed denotations are proved by definitional equality,
then refined through their checked callees. Earlier reduction/normalization
failures and their diagnostic checkpoints remain in the shared ledger.

Native audit `20261017T012753-5b63a9622610` and output-certificate run
`20261017T012356-389ba9e98469` were interrupted during the native-agent handoff.
Neither is successful validation evidence. The parent resumed the same frozen
inputs in the original native worktree, preserving completed artifacts and solver
cache, as runs `20261017T013355-d1fad227ef71` and
`20261017T013354-6ff99f1ce6c4`. The output certificate passed a fresh audit of
14,427 declarations. The later catalogue and aggregate repairs require an
updated native manifest; the interrupted/resumed native snapshot must not be
described as hash-identical to the final delivery.

The resumed native audit proved all 15,153 checks but correctly failed its
strict report audit on the new `Body_Environment` loop's `array-initialization`
warning. Commit `d83927cef3` replaces that statement loop with an iterated array
aggregate, preserving the same Count/full-array mapping contract. Focused native
run `20261017T015422-fbfab8ecf794` proved all three mapping checks without the
warning; build `20261017T015610-9b49f21729ff` passed. The source pin and exact
expression check were updated together, and independent review accepted the
repair. No diagnostic policy was weakened. Final native run
`20261017T020716-cfa3562b8261` passed the complete strict audit: 75 units,
1,000 entities, 1,295 flow checks and 13,854 proof checks (15,149 combined).
Its actual native inputs match the implementation; the original lane HEAD
alone does not reproduce the two synchronized files. The updated scalar-body
source certificate is included in the final complete Lean run.

The final helper linkage is `bab3c7e9f8` (semantic lane `c0811ae49b`), audited
in run `20261017T014736-724f22a1471e` over 25,539 declarations. The complete
predicate source candidate passed run `20261017T014352-b453a8e86413` over
21,198 declarations. The full test suite began on the committed implementation
inputs at `d83927cef3`, in the root checkout, as run
`20261017T015701-ad774ab8b5aa`. Later review/documentation commits do not alter
those captured inputs. That suite exposed five stale checked-in generated
certificate snapshots: output profile specification/body, scalar expression
specification/body and scalar literal body. The managed Lean runner excludes
these generated snapshots from authoritative input hashes and regenerates its
actual candidates from the native sources. The prepared snapshot repair is
byte-identical to those generated validation candidates. The suite finished
469 tests in 1,685.096 seconds with exactly those five subcase failures in one
method. After its input lease ended, `bbd5989b2b` refreshed the five snapshots.
Run `20261017T022620-08e72ef5c544` then passed all ten affected
`CompilerSourcePolicyTests` in 2.528 seconds, including exact regeneration and
source/module policies for the selector repair. All 22 manifest samples passed
in the original suite. Its failure and this focused repair are separate evidence;
no second full-suite execution is claimed.

Cache reuse is recorded rather than inferred from worktree HEADs. The root
retains its existing Lake cache and these narrowly checked transfers:

- `tmp/mutable-scalar-certificate-transfer.json`: 51 source/artifact files for
  three certificates. The later aggregate repair invalidates the transferred
  scalar-expression body certificate, which the final runner rebuilt successfully.
- `tmp/mutable-compose-artifact-transfer.json`: 204 files from twelve matching
  module families. Six families were rejected because the root's declaration
  trace proofs changed their dependency closure; no rejected objects were copied.
- `tmp/mutable-semantics-artifact-transfer.json`: 324 files across 151 matching
  modules, after a fresh audit of the integrated trace/helper equations. Its
  earlier ModelLegal transfer is retained in that lane's
  `tmp/compose-model-legal-import.json`.

All copies preserve mandatory object/trace/setup siblings, use separate files
and verify source/tool/closure identities. The complete cached Lean build and fresh whole-project audit ran in
`tmp/bounded-mutable-integers-semantics`, with all 581 authoritative inputs
hash-equal to `bbd5989b2b`. The full suite used the root checkout at
`d83927cef3`; its proof tree differs from the delivery in exactly the selector
and five generated snapshots, covered by the focused source-policy recheck
and final complete Lean audit. The validation lane retained its earlier cache,
imported the checked predicate-candidate closure from root and the completed
output-body certificate from the native lane. The delivery evidence records
that entire transfer chain, source/native/tool checks and actual artifact
identities. Copied caches did not substitute for the fresh complete audit.

After validation, the checked artifacts were copied back into the idle root
proof workspace for continued cached development.
`tmp/final-lean-cache-promotion.json` records the complete audited source/tool
identity, 466 module families, physical copies and backups of replaced root
artifacts. No proof was rerun for this cache handoff.

No clean build, independent kernel replay, native macOS rerun or hosted CI is
claimed. CLI memory was unavailable and was not updated. The original harness
goal remains complete; this milestone was authorized separately.

## Original scoping validation — 2026-10-17

The completed scoping checkpoint was based on read-only review of the current specification,
implementation and assurance boundaries at `a6cc65112b`, with focused semantic
and assurance reviews. No compiler, prover or application execution is claimed
for the proposed source. The scoping change affects documentation and planning
only; final link, whitespace and tracking checks are recorded in its handoff.
