# Fixed library sources: first two terminal-task bounds

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This joins two of the five fixed library backend inputs selected by
[literal output](retained-producer-zero-check-sources.md#literal-output-source)
to terminal-task bounds. The other three inputs remain open. No compiler,
Why3, solver or Lean execution was made; this is a source derivation checked
against complete previously retained producer inputs.

Under the existing
[fixed-library source reduction](retained-producer-fixed.md#separate-fixed-library-processes)
and pinned source behavior, the bounds are:

| Fixed library entity | New native check IDs in this entity | Terminal backend tasks `G` | Response records `R` |
| --- | ---: | ---: | ---: |
| `Silver_Arguments.Input_Is_Valid` | 1 | at most 1 | at most 1 |
| `Silver_Arguments.Is_Message` | 1 | at most 3 | at most 1 |

The third Is_Message allowance deliberately retains a potentially surviving
**True helper postcondition**. Counting only its native registered check would
miss that piece of Why3 construction. Task counts are not obtained from the
check-ID counts or from successful solver results.

The [offline evidence](../evidence/retained-producer-fixed-check-spines-20261018/README.md)
pins the inspected Why3 sources, current library sources and exact retained
JSON inputs. The source argument below supplies the transformations; the
checker reconciles their native shapes and does not execute those transforms.
This result bounds emitted tasks, not their full formulas, context size,
lifetime allocations, raw response strings or solver representations.

## Fixed-source input boundary

The selected current
[Silver_Arguments body](../../src/silver_arguments.adb) and
[specification](../../src/silver_arguments.ads), together with
[Silver_Runtime](../../src/silver_runtime.ads), are fixed independently of Main.
The native producer evidence retains their complete source/ALI inputs and
separate library invocations. Disabling only the backend command did not change
native translation; see that evidence's explicit phase/source premises. This
is the previously established fixed-case reduction, not a maximum over sampled
Main programs. Future library or relevant option changes invalidate this case.

The required invariance is the backend input's semantic tree and selected
contracts, modulo fresh identifier/check-ID renaming and bounded location/name
metadata. This does not claim byte-identical JSON after moving the workspace.
The two source units and their transitive imports contain no reference to Main;
their own bodies, explicit contracts and formal types determine these checks.
Each producer analyzes only its requested library unit and obtains proof globals
for that unit's own callees. Main callers introduce no higher-order
specialization or parameter-dependent library body on these APIs. The existing
fixed-source reduction supplies this independence under the recorded options.
The retained files are therefore concrete representatives of these fixed tree
shapes; their actual hashes remain evidence identities. Symbol/name/location
bytes and the per-process native counters remain paid by their separate bounds.

The two emitted entity theories contain only the following program shapes:

- Input_Is_Valid: two nested conditionals, five assignments (three returned
  Boolean values and two branch-observation assignments), the structural
  return exception/handler, and two empty-contract Abstract_expr wrappers.
  The only check-marked call is Argument(1).
- Is_Message: one result assignment; the Length range-check call; the
  short-circuit right operand's arbitrary index, guarded membership-check
  helper and arbitrary Boolean result with a quantified postcondition; two
  empty-contract Abstract_expr wrappers. Its only `W_ASSERT` is Assume for
  the input String's dynamic property. There are three Abstract_expr nodes
  altogether, all with True postconditions.

The source explains these shapes. Input_Is_Valid calls Argument_Count without
a precondition; only the `Argument (1)` call requires
`Number <= Argument_Count`. The literal 1 is a valid Positive. Is_Message
converts `Item'Length` to Integer for its comparison with 4096, so a range check
is needed for an arbitrary unconstrained String. Its Character membership
test uses only the mathematical character representation and integer
comparisons; the generated quantified-index guard makes the element access
safe without a separate labeled runtime check. No source type invariant,
ownership operation, loop variant, dispatch or exceptional-call contract
introduces another check.

Neither function has an explicit postcondition. The outer producer wrapper is
the previously inspected subprogram wrapper; functions additionally store and
read their result. Their Boolean result and the reachable String/Character/
Integer types fall inside the solid, flat-reference
[type frontier](retained-producer-main-types.md). Thus Why3's `Typeinv.inspect`
and injection add no obligations here. The imported context declarations are
logical definitions, axioms and abstract callable declarations, rather than
extra executable bodies whose contracts are verified with these entities.

## Why3's safety formula has a single checked path

These bounds use the actual SP/WP constructors in `src/mlw/vc.ml`, not merely
the logical equivalence of a desired formula. Abbreviate wrappers consisting
of lets, universal quantifiers and implications by `C[-]`. On the paths below
their antecedents have no `case_split` or enabled by/so form, and their positive
hole occurs once. Variable-for-variable renamings preserve that occurrence.

Relevant constructor behavior is:

1. `k_fun` ends an ordinary function at `Kstop` of its postcondition. An empty
   postcondition list gives unannotated True (`:373–377,1023–1052`). The
   converter sets `vc:divergent` on each emitted program function body, so
   missing-divergence checks are absent
   (`plugins/gnat_json/gnat_ast_to_ptree.ml:1116–1123`).
2. Calls to abstract declarations have no separately checked body. Their
   postconditions are `Klet`/`Kval` assumptions; a nonempty precondition adds
   a `Kstop p` branch or a `Kcut p` before the call
   (`vc.ml:661–748`). `Any_expr` likewise becomes an abstract any value with
   its specified pre/postcondition (`gnat_ast_to_ptree.ml:731–756`). The two
   Is_Message Any_expr nodes have no precondition. Their postconditions cannot
   create a feasibility assertion on this path.
3. Under an unannotated True continuation, unlabelled assignments, assumptions,
   pure calls, returned values and structural return/handler nodes contribute
   True safety. The `Klet`/`Kval`/`Kcont` rules and `sp_implies` simplify that
   continuation; an unused result does not make its computed Boolean formula
   into a checked postcondition (`vc.ml:223–285,1564–1581,1600–1646`).
4. For safety, a conditional calls `wp_if`, not `sp_if`. With True safety on
   one side, `wp_if` makes an implication for the other side. It does not add
   `case_split` (`:258–269,1495–1509`). The separate strongest-postcondition
   maps may contain `case_split` on merged outgoing values. Here there is no
   later checked continuation to consume that merge: both functions have no
   postcondition, and each of the checked sites described next is reached
   before any merge of its enclosing alternatives.
5. `reflow` moves continuations only to unique eligible exits and never copies
   them; the [retained-code derivation](retained-producer-kode.md#reflow-preserves-attached-terms-without-copying-code)
   applies. Keeping counterexample trace bindings can retain lets and value
   equalities, but creates no new checked positive leaf.

For **Input_Is_Valid**, the sole precondition is reached only when the first
test `Argument_Count = 0` is false and the next test
`Argument_Count = 1` is true. The three source returns have True checked
continuations. The two empty-contract Abstract_expr wrappers are removed by
the converter because their expressions contain only literal/binding/unit
nodes (`gnat_ast_to_ptree.ml:271–322,889–903`). Consequently its safety formula
has the structural shape

```text
C[ 1 <= Argument_Count ].
```

The notation suppresses fresh logical names, traces and type-preserving
conversions; it does not claim identical pretty-printed syntax. The consequent
is one ordinary scalar comparison. All result-value branches are either
discarded under True safety or remain in assumptions, not a second positive
checked occurrence. No branch join precedes this unique check route.

For **Is_Message**, the Integer range check happens before the comparison and
short-circuit branch. Its check leaf is `Integer.in_range (length Item)`.
The RHS quantified-expression RTE check is different from the two empty
contracts: its comparisons are applications, so the converter's conservative
`no_vcs_no_side_effects` predicate can keep its Abstract_expr even though none
has a precondition. The helper's explicit True postcondition is annotated by
`wp_of_post`; this allowance keeps it as one positive True leaf instead of
assuming it disappears. The two empty contracts still elide.

The quantified result's Any_expr postcondition is only assumed after the RTE
helper. The function result has no checked postcondition, so that quantified
Boolean relation cannot become a further safety goal. The safety formula is
therefore within the two-leaf shape

```text
C1[ Integer.in_range (length Item) ]
  and
C2[ True_with_helper_annotation ].
```

`C2` includes the short-circuit guard and the single arbitrary index's bounds.
There is one route to this helper; `C1` is evaluated before that branch. The
conditions affect formula size, but do not duplicate either checked leaf.

## Matcher and splitting on these two formulas

All consequent numeric comparisons are scalar/opaque-operand atoms, so the
[matcher refinement](retained-producer-formula-refinements.md#scalar-and-opaque-equality-has-an-additive-retained-cost)
keeps them atomic. Contextual Boolean equalities used for tests may simplify
or introduce Boolean conditions inside antecedents, but do not turn them into
positive checked leaves or add `case_split` attributes. These two paths have
no case-match term or user algebraic equality requiring pattern expansion.

The first right splitter maps a let or universal wrapper over its results and
wraps implication conclusions with their premises. With no case-split/by-so
antecedent, each of the displayed positive leaves contributes at most one
first-split result. An annotated leaf is stopped as a whole; a retained True
helper can count as one rather than zero
(`src/transform/split_goal.ml:209–217,263–280,333–338,417–431`).

Marked right unfolding does not visit implication antecedents or let
definitions (`src/transform/gnat_split_conj.ml:166–210`). The ordinary
`1 <= Argument_Count` consequent does not unfold into a connective.
The only relevant marked definition in the Is_Message consequent is the
integral `in_range` predicate: `first <= x and x <= last`. Its possible
Boolean extraction wrapper has the specially handled `if p then True else
False = True` shape. The existing
[range-leaf refinement](retained-producer-formula-refinements.md#a-sharp-task-interface-for-straight-conjunctions-of-checks)
therefore contributes at most two final tasks. The True helper contributes
at most one. Conversion rewriting changes terms but does not duplicate these
positive positions. Thus the displayed bounds follow:

```text
G_Input_Is_Valid <= 1
G_Is_Message <= 2 + 1 = 3.
```

Each native input has one distinct check label and no loop-invariant label.
The [label correspondence](retained-producer-response.md#registered-ids-bound-result-records-without-a-kind-domain-product)
therefore gives `R <= 1` per response, even if the one range-check record
contains two terminal goals. The extra True helper does not create a native
check ID. All raw-response/counter/string/solver domains remain separate.

These are two concrete fixed-source task joins. They do not bound
First_Or_Default, Put or Put_Line: their checked postconditions and loop
invariants make branch/outcome joins relevant, so this single-path argument
cannot simply be reused for them.

An independent focused source review found no material issue in these two
bounds. It checked the Eexec/Cany postcondition-to-assumption translation, the
empty-precondition and Cfun distinction, the Any_expr converter, `wp_if`
safety and right-splitter handling of unmarked antecedents. It agreed that the
annotated True helper must remain charged and that the fixed-input argument
is scoped to semantic shape modulo fresh metadata. It did not rerun the
checker or transforms, or independently rederive the full type frontier.
