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
