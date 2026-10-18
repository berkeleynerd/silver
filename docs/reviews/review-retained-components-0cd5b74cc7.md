# Independent review of retained capacity components

2026-10-18, Linux x86_64. Frozen integration target:
`0cd5b74cc77326df06284d57066dd16db145f43b`.
Refs [#119](https://github.com/berkeleynerd/silver/issues/119).

**Verdict: no material findings within the component domains reviewed.** The
new rows preserve the distinction between fresh allocations, discarded work,
and repeated serialization. Their conditional source/helper and name transfers
do not claim a complete admission predicate. This review makes no whole-predicate
verdict and does not justify lifting an existing language limit.

## Scope

The independent lane owns this report and its new evidence only. It reviewed:

- [Fixed support](../research/retained-fixed-support.md) and the associated
  [source closure](../research/retained-source-closure.md): grammar/helper
  selection through `5fa01bdda1`, native/producer virtual-source exclusions,
  selected support closure and binder source arithmetic.
- [Producer capacity](../research/retained-producer-capacity.md): ordinary
  rank-one Character representation-cache miss bodies and ordinary type
  translation/completion, including `eb2572f6e6`, `438f40cac1` and copied-name
  correction `caa37f44af`.
- The new [Length/control](../research/retained-producer-control.md),
  [object/theory](../research/retained-producer-objects.md) and
  [selected-call](../research/retained-producer-calls.md) components.
- [Name and qualification transfers](../research/retained-table-capacity.md#names-and-serial-number-components).

Earlier expression costs were used as reviewed interfaces, with focused checks
where the new callers differ. Their complete derivation was not repeated; see
the [earlier component review](review-retained-capacity-components-63b0c9671f.md)
and [later producer review](review-retained-producer-4073ab0820.md). Latest native
expansion work was excluded except for helper-selection paths relevant to the
fixed source seeds. Source-to-helper visit counts, executable loop framing,
fixed-library translation, backend/linker capacity and installed binary/source
correspondence were not completed by this review.

## Source checks and conclusions

**Support selection and binder.** The strict `-gnato` setting and target backend
overflow flag exclude the frontend bignum/arithmetic-runtime routes for the
stated Integer family. Error-check construction does not imply a local-raise
helper: its debug/restriction guard is absent under the selected invocation.
The source distinguishes generated String access types from author-declared
access types. Storage-pool, collection, task-master and controlled-initialization
guards were checked with that distinction intact. Ordinary Integer Image uses
the scalar image route; generated default Put_Image support remains in the
selected seeds. Light expansion does not take the native concat/helper bodies.

The virtual-range argument keeps generic-body demand separate from inline
annotations and charges the possible Image generic body once. Its body/spec
guards, generated-helper inlining exclusions and text-buffer inherited-contract
conditions support the stated conditional contributions. This is helper-family
and source-range coverage, not zero allocation in those paths.

Binder writer sites were checked against their enclosing loops and selected
subroutine calls, including the at-most-once finalize header. Direct `WBI`
operands, separate path comments, the linker-comment prefix, empty policy
strings and generated-source naming are accounted for. The independently
recalculated raw bound is **4,270,635 bytes**; with the two alignment allowances,
whole-runtime physical overapproximation and binder virtual contribution, the
source charge is **24,779,307**. The result remains conditional on the explicit
invocation/search controls, fixed dependency closure and source/tool premises.

**Array cache and types.** Every array-cache attempt retains its seventeen-node
charge, even on a hit. The miss row counts both Integer-prefix modules, the
comparison module, local-name copies, effect-list defaults and declaration-list
entries. The equality definition is serialized in both its function and reverse
axiom. An independent reconstruction from the AST schema and selected constructors
reproduces **219** occurrences in that shared definition, **273** in the function
and **315** in the reverse axiom, totaling **588**. The complete miss allowance
remains `148/44/76/711`, separate from attempts and close-time imports.

Static nonempty scalar types, dynamic/empty scalar itypes, static String types
and non-itype completions select different guards. In particular, dynamic
itypes still pay eager known-bound literals when applicable, while their omitted
completion bodies do not translate dynamic bound expressions. The reference
record's field type and havoc parameter occur repeatedly in serialization and
are charged accordingly. Static String attributes use the name-copying
`New_Identifier` overload: the corrected **37-node itype** and **112-node
non-itype** totals retain both copies. Raw declaration builders are smaller than
the uniform function allowance; their omitted effects/pre/post fields are not
mistaken for actual raw-builder allocations.

**Length and control.** Length's eager object read, implicit expected type,
same-type conversion and optional temporary are counted before its binder-specific
accessor is selected. The program binding can retain the read while the term
path discards it. Branch observation has no counterexample-option guard; its
independent serialization reconstruction gives **23** occurrences beyond the
condition. The if row translates each child once, keeps elsif actions separate,
and allows the empty conditional list. Statement-list initialization precedes
the empty-input return. The simple list transfer is correctly restricted to
positive-location entries whose wrapper prevents sequence flattening.

**Objects and calls.** `Mk_Item_Of_Entity` constructs Ada binder records rather
than Why binder nodes, but its type/name constructors still allocate. Object
registration and `Translate_Variable` are separate setup visits. Constant-value
axioms translate the initializer before possibly discarding it; their empty-binder
quantifier discards already allocated triggers. Loop entities create both exit
and continue exception declarations regardless of source jumps.

The call guards agree with the selected Silver specifications: ordinary immutable
String formals, no selected precondition/exceptional/exit contract, static
termination conditions and no relaxed-init output globals. Both eager Void
sequences and the program-domain Effects allocation are charged. `File_System`
is also an input and does not take the output-only havoc route. Guarded logic
function calls are included, with argument translation once and additional
cheap-reference occurrences when no temporary is created. Expected-type/result
conversions, fixed registered symbols and library theories remain explicit
separate costs.

**Names.** The scanner contribution covers ASCII source words only. Name
initialization, the NUL character, Short length conversion, table reserves and
downstream 4096-byte decoding temporary are distinct constraints. Internal/external
name suffix transfers match their overloads. Full qualification includes generated
scope names for types/subprograms; ordinary-object scope exclusions cannot be
applied to them. Homonym digits occupy the 256-byte temporary even when the final
all-one suffix is omitted. Already-qualified prefixes and recovered suffix groups
are included once. The one-`Name_Enter` statement excludes debug-renaming paths,
and the additional scalar encoding bound applies only to its stated Integer-bound
domain. No whole-grammar generated-name bound is inferred from these transfers.

## Evidence and limits

[The review checker](../evidence/review-retained-components-0cd5b74cc7/check.py)
and [results](../evidence/review-retained-components-0cd5b74cc7/results.json)
record eight byte-identical regenerated outputs. They verify 37 complete SPARK
source files against the retained source archive and 38 complete GCC Ada files
against the retained full-source manifest. Identity verification is broader than
the directly inspected code paths; these counts do not claim a complete source
audit. The independent checks reconstruct array-equality and branch-observation
serialization, recalculate binder/support arithmetic, and exercise 781 finite
homonym-length combinations.

Reproduce from the review checkout:

```sh
python3 docs/evidence/review-retained-components-0cd5b74cc7/check.py \
  --spark /tmp/silver-frontend-representation-20261017/availability/spark-source \
  --gcc /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --gpr /tmp/silver-retained-gpr-source-20261017/gprbuild-bdfb879cf03643ec8e48a09ce07b08c4a6ff0263 \
  --installation /home/canto/src/github.com/berkeleynerd/silver
```

SPARK source revision remains `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`;
GCC source remains `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The records correctly
retain the unresolved source-to-installed-tool qualifications. No compiler,
GNATprove, Lean, full suite, clean build, kernel replay or giant probe ran. No
production/research record, issue, board entry, harness goal or GitHub state was
changed by this lane. Local report links and authored whitespace were checked.

Recommendation: retain these scoped components for #119 integration, preserving
their invocation counts, expected-type construction, cache/import and fixed-library
terms. Do not substitute their successful local checks for the remaining
whole-process capacity and correspondence obligations.
