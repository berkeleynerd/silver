# Fixed-size Integer arrays

Status: authorized design and implementation; not supported yet.

The [2026-10-27 owner instruction](session-memory.md#2026-10-27--fixed-size-integer-arrays-authorized)
selects one bounded array increment under
[milestone 10](https://github.com/berkeleynerd/silver/milestone/10) and
[#260](https://github.com/berkeleynerd/silver/issues/260), linked to the broader
[arrays stage #12](https://github.com/berkeleynerd/silver/issues/12).
Baseline: `7acddbcc0f4e7e1aec567f496539f956864ed294` (PR #259).

## Selected first fragment

The driver is Rosetta's **Shift list elements to left by 3**, whose required
result is a rotation: `[1,2,3,4,5,6,7,8,9]` becomes
`[4,5,6,7,8,9,1,2,3]`. A constant source array and mutable result array, two
copying loops and output loops exercise initialization, indexing and writes.
Clearing the last three entries would not implement this task. The existing
Loops/Foreach assessment is not the driver: the task asks for the language's
foreach construct when available, and Ada has a distinct `for E of A` form.

The implementation scope is:

- Anonymous, one-dimensional objects:
  `A : [constant] array (L .. U) of Integer := (E1, E2, ...);`.
  Bounds are nonempty Ada-static Integer expressions. Every component is
  explicit and the count must equal `U-L+1`. A singleton uses `(L => E)`, with
  the static choice equal to its sole index; `(E)` alone is a scalar expression.
- Indexed reads `A(index_expression)` in the ordinary scalar expression
  positions, including later initializers, Image, comparisons and loop bounds.
  The subscript uses the pre-array scalar grammar: no array read inside a
  subscript. Every inferred index interval must be nonempty and contained in
  the declared bounds, including dead arms and empty loops.
- Indexed assignment to mutable arrays, with a checked Integer RHS. It reads
  the incoming state, changes one component and preserves scalar-flow and
  String/input facts. Loop bounds capture their values before iteration;
  subsequent array writes do not change that sequence.
- Declaration elaboration retains exact initialized components, so later
  declarations capture the correct snapshot. Every indexed read is nonstatic,
  even from a constant array. Body reads use the full Integer interval for
  both constant and mutable arrays. Guards do not refine individual elements.
- Existing name hiding and cross-type uniqueness include arrays. A loop index
  can hide an array, and its own name is unavailable in both loop bounds.
  Each array-read atom charges one operand plus all subscript operands against
  the existing 64-leaf limit; arithmetic retains the shared 63-operator budget.

Named array types, component range constraints, `others`, general named choices,
null arrays, array attributes, slices, whole-array operations and foreach loops
are excluded from this first fragment. These are scope choices, not Ada rules.
The broad Rosetta `arrays` identifier remains unsupported.

Explicit initialization bounds the native value table by the existing source
budget: each component needs at least one expression byte and a separate comma
or closing delimiter, so all initialized components together fit within
`floor(source_length/2) <= 2048` slots. Compute index cardinality in wide
arithmetic before comparing it with the parsed count. The immutable table stays
outside recursive body-flow storage; the body needs only array metadata.
Report storage requires the separate feature-local source/producer accounting;
the inherited report bound is not assumed to cover additional checks.

## Assurance design

The Lean model represents array components in disjoint segments of the existing
Integer store, with an explicit projection to indexed array values. Descriptor
bounds and addresses, ordered initialization, read/update behavior, other-cell
preservation and separation from scalar/loop identities are proof obligations.
An indexed scalar expression checks its subscript and reads the selected cell;
inference joins the addressed range entries. Elaboration supplies singleton
cell ranges and the body supplies full Integer ranges.

Source readiness must derive the native scalar/index bound before using it for
address separation. Generic abstract loop constructors accept arbitrary `Nat`
identities, so their soundness arguments cannot silently assume that bound.
Initializer snapshot folding must retain and discharge the original index and
arithmetic checks. Native/model equations and reviewed source shapes must cover
the actual declarations, helpers and calls; matching token pins alone is not
correspondence.

The first managed producer probe, `20261027T073406-f0f1fb5fa601`, passed for
anonymous constant/mutable arrays, positional and singleton initialization,
snapshots, rotation loops and Image/output. Its fixed index checks were
eliminated. A second guarded-index probe retained proved `VC_INDEX_CHECK`
records. These establish the observed producer routes, not universal assurance.
The Main policy extension retains proved/info, provenance, coverage, entity,
location and no-suppression requirements. It admits no `VC_RAISE`. Python policy run `20261027T074145-cbfc2a518c40` passed
all 60 existing tests, including the extended index-check mutation matrix.

The rotation's first end-to-end attempt proved all 71 checks but failed the
application audit on two exact `array-initialization` advisories. The
[producer/capacity record](fixed-integer-arrays-report-capacity.md) corrects the
initial no-new-diagnostic assumption: this note withholds an initialization fact,
and nested loops may repeat it. Commit `4d4919efa2` extends the existing exact
classifier to Main, preserving every required check, and raises retained Main
report storage to 32 MiB against the 25,084,928-byte source/producer envelope.
The shared platform reader supports that storage; runtime/null policies retain
262,144 bytes and the language source budget remains 4,096 bytes. Focused runs
`20261027T080446-52b19ad70a27` (60 Python evidence tests),
`20261027T080646-873f52b08046` (11 Python/native Image and array advisory tests),
`20261027T080721-f9182bff71ec` (36 native report-policy tests) and
`20261027T080751-d735c37e325e` (retained-record/envelope guard) passed.
The [independent classifier review](reviews/review-fixed-arrays-main-advisory-4d4919efa2.md)
found no blocking issue. Complete native proof and source assurance remain pending.
The [capacity integration review](reviews/review-fixed-arrays-capacity-8c95af6742.md)
also confirmed the conservative envelope against the pinned producer routes.

## Delivery obligations

Completion requires agreement among the native compiler, specification and
catalogue; universal composition, automatic-discharge and exact-source arguments;
complete native and Lean/source/module/axiom assurance; regression/sample
validation; and independent review. Update the Rosetta mapping for precisely
the delivered fragment. Broader arrays remain unsupported where their forms
exceed it. Ordinary cached iteration and the existing stable-checkpoint workflow
apply; a focused pass is not the final delivery checkpoint.

General array expansion, other #11 constructs, capacity/assurance modes and
further #246 optimization work are outside this increment. The Oracle and
trusted toolchain remain unchanged. Avoid new infrastructure unless the selected
capability requires it.

| Round | Selected model/effort | Intended result | Result and available measurements |
| --- | --- | --- | --- |
| Initial design | GPT-6 Astra / Extra High for assurance; GPT-6.1 Sol / Extra High for driver/native design | Select a faithful driver and a compositional fragment | Rotation selected; explicit initialization, non-nested subscripts and uniform full-range body reads bound the fragment. Lead runtime setting and token/cost measurements are unavailable. |
| Authorization review | GPT-6.1 Sol / High | Check the three planning files against the owner instruction and current sequence | No blocking finding; one wording clarification applied. Relative links and whitespace checked. Runtime settings and elapsed/token/cost measurements are unavailable. |
| Core implementation | GPT-6.1 Sol / Extra High native; GPT-6 Astra / Extra High core and composition | Implement indexed storage and preserve existing compositions | Core array projection/expression/assignment/obligation modules passed focused Lean checks; native admission and exact initializer-hull probes passed. A real producer warning corrected the initial capacity conclusion; full integration remains pending. Elapsed/token/cost measurements unavailable. |
| Aggregate-loop diagnostic review | GPT-6 Astra / Extra High | Identify the remaining recursive-model proof obstacle before another native retry | Read-only review of `20261027T091926-c04248446233` found distinct internal array-update maps despite identical bounded element equations. The recursive unfolding was already present. The repair shares one pure `Put_Array_Value` expression between the model and runtime; its focused native check passed in `20261027T092828-bc511f2ddc79`, followed by the exact loop refinement in `20261027T092945-c19ef466ed7d` (359 checks). No extra equality lemma was needed. About seven minutes for the review; runtime model settings and token/cost measurements unavailable. |
| Array source and language integration | GPT-6 Astra / Extra High for core and composition subthreads | Connect indexed reads, declaration snapshots and nested control flow to current assurance | Exact scalar-expression source bridge passed (`20261027T101109-bca7c1bbb6c8`, 50.106 s build, 6.575 s audit); mathematical `Current` and selector endpoints passed (`20261027T101357-1cc770acdc6a`, 34.517 s build, 6.380 s audit). The Compose declaration model also passed a focused check after its raw helper equations were derived. Native declaration refinement and the remaining source/caller integration are pending; these are not a complete checkpoint. Runtime settings and token/cost measurements unavailable. |

The diagnostic review used the retained source with SHA-256
`d4222ef6c64f0becbcd59bd725c0dda1156450c1a08acf451e83eca6675409da`
and six saved SMT obligations under the native worktree's
`.silver/linux-x86_64/array-step-review-091926/` (inventory `inputs.json`).
The successful scalar-unit check in `20261027T092253-06c49ba4b19a` has 190 proof
and 38 flow records, all info. Its overall managed run remains failed because
the shared exploratory directory retained three unresolved output-profile
obligations; it is not a complete native checkpoint.

The later native declaration diagnostic isolated two identical string literals
represented as distinct solver maps. Reusing `Spelling (Integer_Name)` proved
the wrapper but failed native compilation, so that experiment remains
superseded. A shared static `Integer_Type_Word` constant preserves the exact
string and both routines' contracts. The final constant version built in
`20261027T103130-6338213d6531` (9.794 s), proved all 419 targeted declaration
checks in `20261027T103206-4b9cae036d88` (226.526 s), and passed all 12 array
tests in `20261027T103611-8a2488674e75` (20.312 s test phase). The mixed report
policy congruence separately passed all 384 checks in
`20261027T101514-03e5a36178d6` (623.115 s). These remain focused results.

The [Compose domain and snapshot review](reviews/review-fixed-arrays-compose-domains-f2b5791d5a.md)
found one source-correspondence gap, tracked in
[#262](https://github.com/berkeleynerd/silver/issues/262): raw aggregate helpers
must retain the caller's native scalar-state conditions. The domain repair and
its array declaration/caller equations have compiled in focused checks. A
follow-up independent review found no remaining caller-domain defect; the
concrete model has passed its focused check, while complete source validation
is pending. The separate mathematical
snapshot/composition review found no missing link. Generic, array and remaining
declaration equations now live in separate modules so repairing the array proof
retains the already checked helper proofs; public imports preserve their names.

The [native/specification review](reviews/review-fixed-arrays-native-726465447c.md)
found no mismatch in static bounds, aggregate shape, snapshots, body intervals,
subscripts, hiding, operand limits or existing guard/loop/input compositions.
It reused the matching 12-test checkpoint; it does not replace the pending
complete native and source assurance or the final integrated feature review.

A fresh [semantic integration review](reviews/review-fixed-arrays-integration-726465447c.md)
found no new consequential gap in storage separation, raw initializer obligations,
snapshot preservation, captured loop bounds or native/source wiring. It reviewed
`726465447c` before the outstanding validation finished; later proof-script
repairs and final evidence still require their closing review.

Focused integration run `20261027T121859-1ce124c7ffc1` passed the Compose model
equations and legality, predicate native/flow-reader and Basic libraries, indexed
body source bridge, and scalar/array source candidate. Build time was 366.777 s,
followed by a fresh 22.700 s audit of 34,373 declarations using only `propext`,
`Classical.choice` and `Quot.sound`. Earlier completed modules were retained,
including the 642 s scalar/array source candidate. The recurring legality-proof
timeout came from lazy equation-lemma generation for the large expression
evaluator; direct `dsimp` unfolding resolved it without changing statements or
increasing limits. This focused result does not replace the complete checkpoint.

## Regression checkpoint

The [independent closing review](reviews/review-fixed-arrays-closing-899a15a5a0.md)
accounts for every one of the 530 tests at `899a15a5a0`: 73 successful focused
results and 457 retained successful results. The
[retained evidence](evidence/fixed-integer-arrays/delivery-20261027/README.md)
keeps the original full run `20261027T113223-c732210ca335` labelled failed
(three failures and two errors; 6,818.245 s test time).

The three failures came from omitted array bindings in the test fixture lists;
the corrected source/evidence modules passed all 12 and 49 tests. The division
and maximum-expression errors were compilation deadlines in the test harness,
not failed proof obligations. Their unchanged tests passed in runs
`20261027T132720-978e7f5308f1` (11 tests, 82.317 s) and
`20261027T132919-e15867ceed8c` (one test, 138.741 s), with more CPU availability
and existing warm caches. Deadlines and production prover settings were
unchanged. The full run also passed all 49 manifest samples, including the
rotation, and all 12 array regressions.

This closes regression coverage for the reviewed implementation. Final Rosetta
metadata needs its applicable renderer tests. Complete native and Lean/source
assurance and their closing evidence review remain pending; arrays are not yet
supported.

## Source-check memory repair

Composition source run `20261027T113255-5e15169d81f4` failed at its 24 GiB
kernel-memory threshold: the `expression_at` prototype check and two array-helper
header checks could not finish. Its failed build and diagnostics are retained;
no fresh axiom audit ran. The output-certificate worker was suspended while the
composition check occupied memory, then resumed on the same inputs and process.
Its 4,375.007-second suspension is part of the recorded wall time.

The [reviewed repair](reviews/review-fixed-arrays-header-literals-5dd2c43b58.md)
at `24452b335a` replaces four uses of long expected-header strings with literal
token lists: `expression_at` in its predicate and proof, and the
`array_values_model` / `array_values_at` prototypes. Independent comparison
preserves all 214, 231 and 265 tokens, including every contract and aspect.
The source lexer, extractors, generator, reviewed pin, Ada and authoritative
source transport are unchanged.

Isolated run `20261027T142844-8cb1d281bb38` proved the three header equalities
at a 4 GiB limit (51.071 s build, 10.752 s fresh audit, 519 declarations with
only the approved foundations). Its temporary probe is retained as evidence
and excluded from the delivered proof tree. This result supports the local
repair; it does not establish the complete candidate's memory peak or replace
the pending complete source/module/axiom checkpoint.
