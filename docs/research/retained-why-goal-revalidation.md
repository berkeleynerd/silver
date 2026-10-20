# Fixed raw-goal revalidation charge

2026-10-20 UTC, Linux x86_64, Round 50; #119 / #153.
`Driver.update_task`'s final goal reattachment registers at most **236 / 190 /
181 / 28 / 15 identifiers per selected raw-goal call**, respectively for
Put_Line / Put / First_Or_Default / Is_Message / Input_Is_Valid. These are
concrete bounds from the retained logical graphs. They cover the validator's
direct calls, including an abandoned prefix, without assigning zero cost to
binder opening. Together with the accepted zero direct metadata charge, they
supply update's direct Ident summand. Pending callbacks remain separately
charged. With the accepted Round 34 interrupted-episode theorem, the summed
charge is **50,785**, or **50,770 after the five current cuts**, under its
named premises. Full preparation/counter capacity remains unfinished.

The [packet](../evidence/retained-why-goal-revalidation-20261020/README.md)
performs a new goal-only structural calculation from the five current raw
capture graphs. It cross-checks the counts against saved earlier binder
certificates using the accepted old/new correspondence, without rerunning an
observer, binder/alpha interpreter or predecessor checker. The relevant source
is Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`; the existing source/native
and faithful-runtime relation remains explicit. The checker verifies finite
data and arithmetic, not the OCaml source theorem below.

## Exact domain and concrete values

The source route and zero-metadata result are the accepted Round 49
[task-acceptance interface](retained-cvc5-task-acceptance.md), author commit
`5cbf04b56480a830e336c58908352dcc7f741732`. The selected drivers request no
theories through `drv_thuse`. Their update loops insert metadata and register
no identifiers. The registered Per_Check goals remain the initial split leaves;
preparation receives the preserved raw session task, never another driver's
prepared temporary result. The accepted
[dispatch envelope](retained-producer-driver-envelope.md) includes losing
attempts and distinguishes raw split tasks from registered goals.

The five current captures are PIDs 17310 / 17514 / 17631 / 17704 / 17869. The
first four stop before scheduling; Input_Is_Valid stops at its first CVC5
`inline_trivial` entry. Every raw-task head is checked to contain a `Dprop
(Pgoal,_,formula)`. The forest contains one unsplit root in addition to each
case's raw split leaves. A root is not a selected solver input on this route.

| Case | All raw task values | Split leaves | Maximum over all goals | Maximum over selected-leaf superset M | Sum over selected-leaf superset S |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 65 | 64 | 595 | 236 | 8,353 |
| Put | 54 | 53 | 509 | 190 | 6,127 |
| First_Or_Default | 33 | 32 | 374 | 181 | 1,968 |
| Is_Message | 4 | 3 | 52 | 28 | 32 |
| Input_Is_Valid | 5 | 4 | 45 | 15 | 15 |

For the first four rows, the selected-leaf superset is **all split leaves**;
no equality between interesting/registered goals and all leaves is assumed.
Input_Is_Valid uses the separately accepted registration classification: only
goal 3 is selected. Its four leaves have charges 0 / 7 / 15 / 16, and its root
has charge 45. Thus the raw-leaf maximum 16 is deliberately distinct from its
selected maximum 15. Keeping all task values instead gives the conservative
per-call maxima 595 / 509 / 374 / 52 / 45 when no leaf selection is available.

Each row's finite calculation checks constructor fields, acyclic term/list/map
traversals, occurrence multiplicity, trigger lists and binder slots. It finds
no `Tcase` in any raw goal closure. All delayed-substitution images reachable
from those binders are `Tvar`; their distinct counts are 387 / 310 / 44 / 0 / 4.
This is checked in the raw graph, including the substitution-value edges, not
inferred from printed goal text. It agrees with the broader accepted
[administrative-map analysis](retained-why-save-stack-composition.md#the-binder-input-that-makes-a-finite-useful-bound-possible).

The new goal counts equal the saved `opened_binder_occurrences` for every
corresponding goal. The graph attachment uses the already accepted
[fresh-state correspondence](retained-why-save-state-join.md): earlier PIDs
3085 / 3323 / 3470 / 3568 / 97103 have a checked logical pointer bijection to
these current captures. This work reads the current blocks directly; it does
not transplant an old auxiliary state or presume identical addresses.
The command-only [quiet-prefix transfer](retained-quiet-prefix-transfer.md)
preserves this named logical projection under its own controlled paired
invocation relation. It does not make every future invocation have this graph.

## Why revalidation opens each binder once

At `driver.ml:360–368`, `update_task` binds the incoming raw goal separately
from its preceding task. `Trans.store` operates on that preceding task; the
function then calls `add_tdecl task goal` with the **original goal declaration**.
`Task.add_tdecl` dispatches that `Decl d` to `new_decl`, which calls
`Decl.known_add_decl` before `mk_task` (`task.ml:145–151,174–177`).

The first known-map check can raise `KnownIdent`, `RedeclaredIdent` or
`UnknownIdent`. None registers identifiers. `get_used_syms_decl` selects
`syms_prop_decl`/`syms_term`, using `t_gen_fold`, whose symbol/binding traversal
does not open binders (`decl.ml:440–446,605–618,697–709`;
`term.ml:1177–1198`). `check_positivity` and `check_foundness` act only on
`Ddata`, so do nothing for this `Dprop` (`decl.ml:780–789,810–835`). The sole
remaining registration-producing direct helper is `check_match`.

For `Dprop`, `decl_fold` invokes its callback exactly once on the formula
(`decl.ml:635–649`). `check_match` recursively calls `t_fold` (`:743–752`):

- A `Tlet` opens its one binder, then visits its bound expression and opened
  body once each. An epsilon opens one binder and visits its body once.
- A `Tquant` opens every variable in its binder list, then visits the body and
  every term of every trigger, retaining repeated occurrences.
- Application, conditional, binary and negation nodes traverse their ordinary
  children. Variables, constants and Boolean constants have no children or
  registration of their own.

`t_open_bound` uses one `vs_rename`; `t_open_quant` uses one per list entry.
Each calls `fresh_vsymbol -> create_vsymbol -> Ident.id_register` exactly once
(`term.ml:36–39,799–831,1284–1294`; `ident.ml:187–213`). `id_clone` by itself
does not register. Case branches would be opened once by `check_match` before
being opened again by `t_fold`; `Pattern.check_compile` can also create fresh
constructor-argument variables (`pattern.ml:115–155`). The checked absence of
`Tcase`, preserved under opening below, excludes **both** sources of extra
registrations; the argument is not a generic bound for arbitrary case terms.

## Delayed substitutions and representative choices

The substitution helpers themselves perform zero registrations.
`t_subst_unsafe`/`bv_subst_unsafe` copy/rebuild terms and maps; they do not call
`fresh_vsymbol`, a binder opener, or a named-symbol constructor
(`term.ml:739–778`). The reconstructed term constructors and `t_attr_copy`
also register nothing (`:628–658`). Hidden substitution/map traversal may cost
time, storage and numerical occurrence arithmetic, but it is not an extra
Ident call. Those other capacities remain separate obligations.

Here the stronger variable-image fact makes a simple structural induction
possible. Opening introduces only fresh-variable `Tvar` images. Substituting
into a saved `Tvar` returns a variable image or the original variable;
`t_attr_copy` keeps its constructor. Nonvariable constructors retain their
constructor and child-list shape. Existing binder lists are not expanded.
Deferred-map composition therefore preserves the variable-only image
invariant. No substituted image introduces a case or binder, and no bound
expression is substituted for a let variable by **this traversal**: it is
alpha-opening, not let elimination.

Define `b(f)` by adding one for each let/epsilon occurrence, the binder-list
length for each quantifier occurrence, and the children's masses; include
quantifier triggers. Shared children contribute on every incoming occurrence.
Then, for this case-free variable-image class,

```text
direct Ident registrations in one completed check_match goal walk = b(f).
direct Ident registrations in any abandoned prefix of that walk <= b(f).
```

An earlier known-map rejection can reduce the complete reattachment charge
to zero, so `b(f)` is an upper bound for the whole reattachment operation.
The checker computes this recurrence directly on the stored goal DAG, because
variable-only opening preserves that shape. Memoizing the mathematical
subproblem does not deduplicate its contributions when a child is repeated.

The charge does not require a correct task-cache hit. A prefix cache can return
another prefix or a known-map lookup can reject the original goal; neither
changes the `d` passed to `check_match`. `mk_task` and its representative lookup
occur only after validation. Terms created by this opening use direct `mk_term`
records; they have no term-hashcons representative lookup. Thus an unrelated
prepared formula cannot become the validator's input through these caches.
This is a property of this caller, not a general memo-key soundness theorem.

Nor must this counting lemma presume future identifier freshness: if variable
map keys alias, an image is still a variable, and a merged map cannot add
binders or a new registration-producing callback. Freshness remains necessary
for semantic correspondence; the count is usable in the first-overflow
argument that establishes it. Immutable raw task ownership and ordinary
typed/runtime behavior are still required. Application callbacks dispatched
while this operation is suspended have their own global charge, rather than
being silently assigned zero or counted as this direct walk.

## Composition interface and limits

For any continuation with `E_p` direct update entries on the selected raw leaves
of process p, including repeats and abandoned calls, this result supplies
`R_goal,p <= E_p * M_p`. More precisely, with entry multiplicity `e_g` for each
leaf, use `R_goal,p <= sum_g e_g*b(goal_g)`. No bound on `E_p` is newly assumed.
If only all-domain task membership is supplied, use the larger all-goal maximum
from the table. The recorded per-goal constructor inventories and charges allow
a later caller proof to use the sharper weighted sum.

The accepted Round 34
[interrupted-episode theorem](retained-why-path-writer-capacity.md#actual-cut-and-repeated-pair-charge)
supplies more than the ordinary nonrepeating envelope. Under its named source,
fresh-phase/configuration/serial-ownership, metadata-key/counter/result,
global signal-escape and valid immutable-task premises, first pair episodes
inject into the three selected prover keys times registered goals; repeated
pair episodes inject into consumed signal-save escapes. There is **one global
`e <= 2` allowance per process**, not a new allowance per goal or transform.
This proves `E <= 3*G + e`, including failed prefixes, nonreturning services
and Input_Is_Valid's active first episode. It does not bound arbitrary prior
scheduler history or continuations that lack the named premises.

Each episode invokes `prepare_task` at most once and `update_task` at most
once before its transformation list. The original raw goal remains the update
input even when a prefix cache selects another prefix. Pending callbacks do
not create another preparation owner under the inherited ownership relation.
Weight the first pair injection by each leaf's `b(f)`, and each repeated
episode by the selected maximum `M`. Then the direct reattachment charge is

```text
R_goal,p <= 3*S_p + e_p*M_p <= 3*S_p + 2*M_p.
```

This composition uses the stronger Round 34 premises. The local shape-counting
lemma above remains separately usable without future Ident freshness. In
particular, the composition does not itself discharge Round 34's metadata
table/counter preservation premise. The checker pins and reads the accepted
Round 34 note and result, checking the actual PIDs, selected goal upper bounds,
active episode counts and conditional dispatch bounds before composing.

| Case | Episodes at most | First-pair allowance 3*S | Full episode charge 3*S+2*M | Charge after current cut |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 194 | 25,059 | 25,531 | 25,531 |
| Put | 161 | 18,381 | 18,761 | 18,761 |
| First_Or_Default | 98 | 5,904 | 6,266 | 6,266 |
| Is_Message | 11 | 96 | 152 | 152 |
| Input_Is_Valid | 5 | 45 | 75 | 60 |
| Sum over five separate processes | 469 | **49,485** | **50,785** | **50,770** |

Input_Is_Valid's first CVC5 update has already returned at its inline cut.
Round 34 includes that active episode in its first-pair allowance, so the
post-cut calculation removes that completed call's allowance of 15. This does
not assert that the initial counter includes exactly 15 registrations; it
excludes a call that cannot run again in that episode. Both remaining ordinary
pairs and up to two repeated pairs remain charged. Without repeats, the normal
post-cut total would be 49,470. The sums concern five separate processes, not
one shared counter. No save/report callback registration is absorbed by this
direct summand; the global two save-entering callbacks/three-save allowance is
unchanged and is not renewed per call.

For a process initial count I, complete no-wrap still requires
`I + R_goal + R_other <= 2^62-1`, with every other direct and continuing callback
registration in `R_other`. This packet supplies the goal-validation summand;
it does not set that other summand to zero. It also does not transfer raw-goal
dimensions through CE-off context removal, monomorphisation, later inlining
or declaration revalidation elsewhere. Those transformations can change term
shape and need their own actual input and source bounds. Full task/caller,
solver-output, save/report and whole #119 capacity remain open. Oracle, tools,
pins and admission are unchanged; production #88–#94 remains unstarted.
