# Parallel residual-key symbol exclusion

2026-10-20 UTC, Round 54, #119 / #153.

For the five fixed raw domains and selected Z3 metadata attached in
[R53](retained-why-parallel-residual-transfer.md), every one of R52's thirteen
residual CE formulas contains a physical logic symbol that Z3's first
`inline_trivial` stage removes. The remaining selected stages cannot put that
symbol back into an axiom under the residual physical prsymbol. Thus no Z3
insertion under those keys can be strict-equal to the CE candidate, including
insertions made by a preparation that later fails.

This is a source argument with checked finite input witnesses, not a mechanically
checked universal theorem. It closes the residual producer obligation under the
inherited fixed-raw-input, driver ownership, valid-cache, fresh-identifier and
initial-state premises. It does not attach every mutable native table to every
J>1 launch. R53's five captured J12 registration domains are the concrete input
attachment; the older Input table projection was taken after its first CE call.
The [packet](../evidence/retained-why-parallel-symbol-exclusion-20261020/README.md)
pins those distinctions and all reused bytes. No new target or solver ran.

## Actual metadata and selected branches

`derive-metadata.py` applies `Driver.update_task` to the captured metadata:
`drv_thuse` is empty; driver entries follow the captured Mid order, matching
Use/Clone histories follow HStdecl's Patricia order, and each driver's metadata
set follows Theory.Stdecl's AVL order. Use retains the metadata arguments.
Clone applies `Theory.clone_meta`: local MAts/MAls/MApr arguments require their
actual symbol-map entry; missing entries drop that meta. MAty recursively maps
children, gives `sm_ts` priority over `sm_ty`, instantiates a type replacement,
and expands aliases through `Ty.ty_app`. Exclusive metas replace their old
set. Task metadata addition does not synthesize logical declarations or check
metadata arguments against `task_known`.

The result retains every successful argument list and every dropped clone,
with physical pointers joined to R51 by R53's bijections. All raw tasks within
each process have exactly the same captured meta/clone histories. Actual
`inline:no` counts are Put_Line 19, Put 19, First 17, Is_Message 14, and Input 15.
No updated domain has `introduced_prsymbol` metadata.

Three domains' only potentially polymorphic raw signatures are `infix ->`,
`infix @`, equality, and `ite`; all four are actually ignored by the selected
metadata. Put and Put_Line also contain `well_founded` and `acc`. The complete
raw term-use census gives their only incoming declarations: the `acc` inductive
declaration, the `well_founded` definition, and four axioms `ult_wf`, `ugt_wf`,
`slt_wf`, `sgt_wf`. All four axioms are actual `remove_prop` members and disappear
in `eliminate_builtin`. Neither remaining symbol is in `remove_unused:keep`.
They are not either initial builtin seed (equality and int).

Inlining cannot introduce an incoming use from outside this closed dependency
component: an unfolded definition can only propagate the uses already in that
definition. After the four axioms disappear, `remove_unused` has no seed into
the component. Its deferred dependency closure is keyed by defined identifiers;
internal references cannot seed themselves. The Dind clause is not visited as
a separate Dprop, and no proposition can refer to its prsymbol in a term.
Both polymorphic signatures are therefore removed. The certificates identify
the Dind head and clause prsymbol explicitly, rather than treating every Dind
as internal by its declaration kind.

R51 already established that every raw proposition, including delayed saved
values and quantified variable types, has no free type variables. Inlining's
well-typed instantiation preserves this; builtin elimination and unused removal
do not introduce new type variables or signatures. For an ignored symbol that
survives removal, its single-symbol ignore meta survives too
(`remove_unused.ml:145–174`). Consequently `detect_polymorphism` inserts the
zero-argument `encoding:monomorphic_only` meta in all five domains. The later
stages retain that meta. The selected algebraic branch is `compile_match` then
`eliminate_projections_sums`; `discriminate_if_poly` and `encoding_smt_if_poly`
are identities. This is an actual membership/removal derivation, not an assumed
monomorphic setting.

## Thirteen physical witnesses

| Residual family | Physical keys | Distinguishing symbol retained by CE | Actual inlining decision |
| --- | ---: | --- | --- |
| `concat_singleton_left_def` | 5 | Its `index_I1_one` | Singleton definition has constant body 1. |
| `bool_eq_rev` | 5 | Its integer `infix >` | Singleton body is `infix <(y,x)` with distinct variables. |
| `argument_count__post_axiom` | 2 | Its result `dynamic_invariant` | Prior `dynamic_property` unfolding leaves `in_range(result)`. |
| `argument__post_axiom` | 1 | Its result `dynamic_invariant` | The same checked dependency form leaves `in_range(result)`. |

Each certificate records the old and new physical marker pointers, the actual
residual prsymbol, definition and declaration order, attributes, and the exact
body decision. Each CE candidate has one visible occurrence of its marker.
The two `dynamic_invariant` symbols in First's argument axiom are distinguished
by physical identity; the result invariant is eligible, while the other
invariant's conjunction body is not. Names label the witnesses; names do not
perform the old/new symbol join.

Every selected marker is outside actual `inline:no`, has neither constructor
nor projection status, and is defined by a preceding singleton Dlogic in every
raw task. Its body and every demanded dependency are nonrecursive and lack
`inline:trivial`. The argument witnesses' `in_range` body has a conjunction at
its root: the nonsimplifying inlining mapper preserves that constructor, so
that definition is not placed in the environment. `dynamic_property`, and then
the selected `dynamic_invariant`, have an application with a distinct variable
argument and are placed in the environment. The checked demand interpreter
records the intervening `first`/`last` decisions as well.

`Inlining.fold` maps a Dprop completely before calling its declaration
constructor. An exception during the map produces no candidate for that Dprop;
any subsequent same-key insertion uses the mapped marker-free formula. A
marker definition itself can be hashconsed while its Dlogic is being mapped,
but its declaration kind/key is not a residual Paxiom key, and the definition
is then omitted from the output task. Since declarations cannot refer forward
to the singleton marker, earlier retained task formulas cannot contain it.
Later inlining environment bodies and formulas have already had it unfolded.
The declaration hashcons may return an older representative at every step;
strict equality preserves the visible-symbol fact used here. The eligibility
argument does not infer attributes of a saved replacement from strict equality:
all retained raw and source-derived CE stored term, symbol and variable closures lack
`inline:trivial`, and none of the selected producers attaches that attribute.
Inlining only tests its interned attribute. Other selected attribute operations
copy input attributes, add `introduced`/model attributes, or remove split markers.
Thus an old-return delayed substitution cannot supply a hidden force-inline
attribute that turns the stable conjunction dependency into an eligible body.

## Equality, delayed maps and later stages

Define a visible symbol occurrence using Term's comparison frames: descend
through a saved value only when a variable selects it, after checking whether
that variable is bound; then use the remaining outer frames. Traverse ordinary
children, binder bodies and triggers. This is the same substitution direction
as `Term.descend` and `t_compare` (`term.ml:262–402`). A strict-equal pair has the
same application symbols in this view: Tapp compares the physical lsymbol,
constructor alternatives differ, and binder frames preserve alpha positions.
A physical term shortcut is taken only with both frame lists empty.

This deliberately does not assert that strict equality bounds hidden storage.
A returned representative may contain unused saved-map entries, even entries
whose values mention a marker. Those entries do not make it strict-equal to a
CE formula with a *visible* marker when its candidate has none. Opening a binder
first overrides its bound-variable entries with fresh variables; substitution
restricts new entries to the binding's free variables and composes existing
saved values (`term.ml:739–858`). A dead entry cannot become an application
merely through opening, closing, capture-avoiding substitution, or an unchanged
closing callback. Fresh-variable and valid-binding premises are the inherited
source/runtime premises, not inferred from a count of saved entries.

The ordered producer transfer is:

| Stage | Existing residual key and possible reinsertion |
| --- | --- |
| 1. `inline_trivial` | Removes the certified marker before the same-prsymbol Paxiom constructor. Older returned declarations preserve visible absence. |
| 2. `eliminate_builtin` | Drops a tagged axiom or retains its existing object. Its other constructors make Dparam/Dlogic/Ddata, not an axiom under a residual head. |
| 3. `remove_unused` | Retains selected tdecls; it never reconstructs a removed definition from metadata. In particular `>` remains in actual `syntax_logic` and `remove_unused:keep` metadata, but those memberships do not put its applications back. |
| 4. `detect_polymorphism` | Retains logical declarations and adds the derived mono meta. |
| 5. `eliminate_inductive` | Retains Dprop objects. Any clause axiom reuses its Dind clause head, disjoint from all residual heads; inversion heads are fresh. The only raw Dind here is removed with `acc` in the Put domains. |
| 6. `eliminate_algebraic_if_poly` | The actual mono branch compiles input cases and rewrites projections. `Pattern.compile_bare` uses input patterns/terms and fresh variables; it does not fetch an arbitrary library symbol. Projection rewriting replaces only projection symbols with fresh symbols. All markers have constructor/projection fields zero. |
| 7. `eliminate_literal` | Existing-key formulas use input terms, constant replacement and fresh literal symbols. Actual range/float metadata contains no marker. Environment lookups request integer/real `<=` and real unary `-`, distinct from every marker. Those helpers and projection/is-finite calls occur in freshly headed literal/type axioms; lookup is not silently assumed absent. |
| 8. `eliminate_gnatprove_guard_epsilon` | Witnesses and properties come from the input formula; conjunction/implication wrapping adds no lsymbol. Its unconditional let reopening/reclosing preserves visible absence, even if the stored representation changes. |
| 9. `eliminate_epsilon` | Reuses input subterms or creates fresh closure/lift symbols, plus the fixed equality, boolean and function-application primitives. Canonicalization caches return their previously fresh closure symbols, not a marker. Generated axioms have fresh prsymbols; existing residual heads retain absence. |
| 10. `introduce_premises` | Retains context. Generated premise heads and its separate name/content hashcons are excluded from residual heads by the attribute argument below. Goal heads remain distinct physical Pgoal keys. |
| 11. `simplify_formula` | Its propositional/quantifier/let simplifiers select or substitute input subterms and fixed Boolean/equality primitives. They can perform CE's pruning and if-true rewrites, but cannot restore the missing physical marker. |
| 12. `discriminate_if_poly` | Identity under the retained derived mono meta. |
| 13. `encoding_smt_if_poly` | Identity under that same meta. No unselected encoding subpass is treated as executed. |

The separate Introduction table is essential. Actual updated metadata has no
`introduced_prsymbol`, and none of stages 1–9 creates it. Hence each newly
constructed premise uses `pr_of_premise`, whose identifier attributes are
`{introduced}`. Residual heads instead have either empty attributes (concat)
or `{useraxiom}`. Main Decl.Hsdecl requires the same physical head. Introduction's
separate Hsdecl additionally compares name, attributes, location and strict
formula; it therefore cannot return a residual head for the generated premise.
A Wdecl queue is keyed by the returned declaration object; a queued alternative
was entered from that same equality class. The attribute distinction thus also
excludes residual heads from a queue result. This argument does not require a
capture of that separate table and does not assume its return is fresh.

## Failed calls, epsilon and the resulting family

The argument applies at every constructor invocation in every finite preparation
prefix, before later validation, task insertion, printing, or another stage can
fail. Successful insertion followed by failure remains an insertion satisfying
the marker invariant. A later valid transform-cache hit returns an earlier
result already covered by that induction. Weak hashcons hits can return older
stored representations; absence survives each such return by strict equality.
Metadata-only driver updates preserve existing logical declarations. Earlier
library/transform lookup and fresh-head producers remain under R51/R52's stated
initial-state and symbol-origin premises; this packet does not replace them
with an unsupported claim that all lookup effects are empty.

The argument axiom's CE candidate retains an epsilon. Stages 1–7 are already
excluded by its removed result invariant, before either epsilon pass runs.
The guard pass substitutes its input witness and properties without adding the
marker; the general epsilon pass has the same exclusion and subsequently removes
epsilon. Consequently the proof does not use final epsilon absence to dismiss
an earlier insertion. It also does not assume the guard pass leaves lets or
hidden maps unchanged.

Before the first successful CE seed for a residual key, partial CVC5/Alt-Ergo
computations still have only the deterministic raw-key CE producer described
in R51/R52; their downstream transforms cannot precede that key's completed
CE prefix. Z3 adds no compatible representative. The raw residual representative
is incompatible. Input's retained post-CE table already includes its known CE
representatives; they are accounted as CE-produced objects, not mislabeled as
registration state. Thus every compatible residual representative comes from
the checked CE stored family, even if an earlier failed call supplied it:
concat 78 stored terms / 2 bindings / 6 saved entries; bool-reverse 52 / 2 / 0;
argument-count 16 / 2 / 0; argument-post 35 / 3 / 0. R52's 662 protected keys and
these thirteen residual keys cover the 675 fixed context axiom keys under the
inherited premises.

The process-wide allowance remains two save callbacks, three saves and e ≤ 2.
No stage receives a new allowance. Arithmetic or arbitrary-parallel state
attachment is not asserted merely because this producer-family obligation is
closed. Selected author model/effort: GPT-6 Astra / Extra High; runtime model
confirmation and token/cost telemetry were unavailable.
