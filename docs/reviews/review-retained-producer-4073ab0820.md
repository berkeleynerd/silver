# Review: retained producer String and wrapper components

2026-10-17, Linux x86_64. Focused independent review for
[#119](https://github.com/berkeleynerd/silver/issues/119), frozen producer
`4073ab0820`, covering additions after the earlier reviewed `fcfdc7b103`.

**No material finding within these components' stated domains.** The String
read/conversion/concat/comparison/Image, assignment and initializer-core costs
include the inspected eager allocations and repeated serialized references.
The corrected literal fixed costs and import/file aggregation also hold under
their explicit premises. This does not complete the whole producer bound.

## Scope and reproduced evidence

The target is [retained-producer-capacity.md](../research/retained-producer-capacity.md)
and its evidence at the frozen commit. The review covers the later ordinary
Integer declaration/assignment and Boolean/warning wrappers as well. Earlier
normalized scalar/entity results were reused from the
[prior review](review-retained-entity-producer-e00109d8a8.md), and the Main String
type premise from the [component review](review-retained-capacity-components-63b0c9671f.md).
No later String-invariant, Length/control, source-closure or native-expansion
change is included.

The pinned producer source is SPARK
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. Its relationship to the installed
GNATprove package remains the target's explicit source/tool premise. I reran
`capture.py` in separate scratch with the retained source tree, source archive,
original JSON and original Ada input. All seven generated evidence files matched
byte for byte, including complete hashes of thirty source files, the excerpts,
three extracted literal modules and their input record.

The [review checker and result](../evidence/review-retained-producer-4073ab0820/results.json)
independently reconstruct the fixed literal theory/use and length-equality
shapes from the AST schema. It counts empty builder lists and repeated
references, and checks the reviewed composite-row arithmetic. These are source
and retained-artifact checks; no compiler, GNATprove, Lean, full suite, clean
build, macOS or CI run occurred. No new program directories were generated.

## Source conclusions

| Component | Source-backed assessment |
| --- | --- |
| String reads and primitive conversions | `why-gen-arrays.adb:311–448` reconstructs an unconstrained split array from one content read and two bounds, converting each bound once. `why-inter.adb:1158–1224,1547–1632` distinguishes the two-node abstract type from the three-node map type/direct-module construction. The `6/3/5/48` read allowance and conversion primitives preserve that distinction; binder/symbol setup remains separate. |
| Full array conversion | The `From_Split` and `To_Split` constants allocate before the same-type return (`why-gen-expr.adb:1136–1158`). The reviewed Main shape excludes initialization wrappers, component conversions, predicates, qualification and fixed-lower-bound work. `Needs_Slide` excludes unconstrained targets without fixed lower bounds (`:3219–3277`), so the complex nonstatic sliding branch is absent. Both temporary/binding stages and all remaining map/accessor/check alternatives are included in `47/22/31/459`. |
| Repeated length bounds | `New_Length_Equality` references its left bounds twice and right bounds three times (`why-gen-arrays.adb:3396–3599`). Four accessor allocations therefore do not mean four emitted accessor occurrences. Independent schema reconstruction confirms the conservative `12/12/16/232` length-equality envelope and reference multiplicities `2,2,3,3`; assertion and sequence raise it to `16/13/18/238`. |
| String concatenation | `gnat2why-expr.adb:21976–22351` eagerly constructs the Character type even with two String operands and the unused `One_Term` in `Build_Last_No_Slide`. Both are charged. The static-empty and dynamic-empty-left alternatives, the two packed arrays, range/reconstruction path and both operand bindings fit `60/32/49/484`. The excluded constrained-ancestor branch follows the Main result-type premise. |
| String comparison | Initialization checking creates a temporary before returning the original ordinary operand (`why-gen-init.adb:502–554`); comparison then requests its own useful temporary. The four discarded identifier/name nodes are included. `gnat2why-expr.adb:18547–18735` packs each array once and uses the six-argument comparison/equality call. The common `25/8/14/147` wrapper covers ordering and optional inequality negation. Predicate-domain pretty labels are expressly separate. |
| Integer Image | `gnat2why-expr.adb:20256–20300` supplies the scalar once to the existing image function and then calls `to_string` with a new maximum-image constant. The fresh abstract String type is two nodes; both calls and the constant supply the other three. Existing image symbols (`why-atree-modules.adb:870–893,3962–3975`) support the `5/2/3/18` allowance. Symbol initialization and the later adapter are separate. |
| String initialization core | The UCArray branch constructs one initializer temporary, one content assignment, two bound assumptions and one three-statement sequence (`gnat2why-expr.adb:1621–1686`; `why-gen-progs.adb:38–58,329–364`). The caller-created expected type and discarded move temporary are included; regular immutable/mutable branches are smaller. `21/8/12/116` prices this core, with initializer coefficient one. The subsequent object read/dynamic invariant remains deliberately unpriced in this frozen component. |
| String assignment | `gnat2why-expr.adb:19042–19146,19238–19345,29520–29561` charges the discarded target-name temporary, target reconstruction, length assertion and bindings. `New_Assignment` performs the second conversion before selecting regular or UCArray assignment (`:12286–12440`). The report includes both conversion bodies in `148/61/86/1247`; it does not assume `Actual_Subtype` equality to avoid them. |
| Scalar and Boolean wrappers | The discarded move and target temporaries are present even without moves or source `@` syntax (`gnat2why-expr.adb:11961–12034,29520–29561`). The ordinary scalar invariant uses the named predicate with four existing Boolean flags and no dynamic variables (`:2329–2360,6730–6824,22591–22638`). The declaration and assignment allowances include these paths. Dead-branch warning construction is restricted to program domain (`:24630–24712`); thus its 27-occurrence allowance combines with a one-occurrence connective, while term-domain Boolean calls do not also receive that warning. |
| Child multiplicity | `New_Temp_For_Expr` and `Binding_For_Temp` (`why-gen-expr.adb:311–352,4962–5010`) preserve a complex supplied expression once in the binding definition. Cheap names/dereferences may occur repeatedly, but their complete reference costs are included in accessor/packing allowances. This supports the additive child coefficients for these wrappers; it does not establish their number of invocations. |

Producer paths in this table are relative to `src/why/` unless another prefix
is shown. Source-level control flow, not the numerical reproducer alone,
justifies the listed exclusions.

## Literal fixed cost and aggregation

The fixed literal cost correction is necessary and present: `Unit_Param` creates
a fresh identifier/name, and the default `New_Effects` in `New_Function_Decl`
creates three empty lists (`why-gen-binders.adb:1222–1307,1626–1640`). The
unreferenced low temporary also remains in allocation counts. The independently
reconstructed source/schema shapes give:

| Literal component | Nodes | Lists | Elements | Emitted occurrences |
| --- | ---: | ---: | ---: | ---: |
| Per invocation, including eager static program check | 9 | 2 | 3 | 14 for the returned use |
| Fixed theory on a cache miss, excluding character predicate/imports | 22 | 12 | 10 | 74 |

The function declaration has 19 occurrences, the definition axiom has 30 besides
its character predicate, the well-formed axiom has 24, and the theory header
adds one. This derives the 74 from the source, independently corroborated by
the retained modules. Shared unit/type/function nodes recur in serialization;
their allocation sharing does not reduce this count. The separate String-valued
temporary-name call also advances its counter without creating an identifier
node, as the target now records.

The final import allowance is sound given complete `B`, `M`, `C` and `F` bounds.
`Add_With_Clause` creates one include node and appends one element to the
existing includes list (`why-inter.adb:361–382`); it does not create another
list. The two set traversals in `Close_Theory` plus two standard imports give
at most `C(2+2M)` nodes/elements and `C(4+4M)` occurrences. The printing plan's
per-invocation `Seen` set emits each theory symbol at most once per file
(`gnat2why-util.adb:503–540`), so `F` times the sum of all created theory
skeletons is conservative. No reset of the process-global occurrence counter
is assumed. Counts for unselected/discarded theories can only overcount output.

## Recommendation and limits

Integrate these local results and continue the remaining helper and invocation
closure. Preserve the distinction between lifetime allocations, repeated
serialization and auxiliary representations. In particular, symbol/module
setup, conversion invocation counts, generated declarations, complete String
invariants, fixed library bodies/call sites, loop framing and source-derived
`M/C/F` bounds remain required; their named `K_h` terms are not established
numeric allowances. The exact source/tool identity premise also remains.

The reviewer added only this report and its evidence in an isolated worktree.
There were no production, issue/board, GitHub or goal changes. No admission cap
is selected and #119 remains unfinished.
