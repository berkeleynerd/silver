# Retained Why3 splitting and response cardinality

2026-10-18, Linux x86_64, research for
[#119](https://github.com/berkeleynerd/silver/issues/119). This component supplies
the final splitting transfer needed by the [response record](retained-producer-tail.md).
It does **not** yet bound the complete source-to-Why3 VC transformation. The
capacity rule remains unfinished; no production configuration or admission rule
changes here.

The [offline evidence](../evidence/retained-producer-splitting-20261018/identity.json)
retains complete files at Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`, the
same inspected revision as the response record. Its
[checker](../evidence/retained-producer-splitting-20261018/check.py) checks their
identities and arithmetic examples without executing Why3 or a prover. The
installed-tool relevant-behavior premise remains separate.

## The selected transformation has four parts

The selected GNATprove Per_Check strategy contains one transformation name,
`split_goal_wp_conj` (`gnat_checks.ml:285–291`). This name denotes a composition,
registered at the end of `gnat_split_conj.ml`:

1. `Split_goal.split_goal_right` performs the ordinary right-side proof split,
   including its `stop_split`, `case_split`, asymmetric and by/so handling.
2. `unfold_trans` extracts eligible marked definitions/axioms from the task and
   calls `unfold_right 1` on the goal.
3. `Gnat_rewrite.elim_to_of_array` rewrites selected array/integer conversions.
4. `split_conj` runs the separate GNAT conjunction splitter.

The second and third parts are singleton transformations. They may change a
goal's size and structure, but do not themselves multiply the number of tasks.
The first and fourth parts can multiply tasks. Thus neither the number of
registered checks nor the strategy list's length bounds terminal goals by
itself. Under the controlled Per_Check session premise in the response record,
these final goals are terminal transformation children. Registration associates
each interesting goal with the single check returned by `search_labels`
(`gnat_main.ml:47–74`); dropping uninteresting goals can only lower their total.

## The local 20 guard is not a total result bound

`gnat_split_conj.ml:24` returns `f :: acc` when `List.length acc > 20`.
It does not stop already-entered recursive calls. In particular, for the
right-associated conjunction

```text
a1 /\ (a2 /\ (... /\ a100))
```

each recursive right-child call starts with the same empty accumulator. On
unwinding, each left atom contributes one result even after the accumulator
passes 20. The final result has 100 leaves. Implication, let, universal
quantifier and case branches also recurse with fresh empty accumulators.
Consequently 20, 21 or 22 is not a sound global split multiplier. These are
symbolic traversal examples, not claims that this exact goal occurs in Silver.

## A structural bound for the final splitter

For a well-formed proposition `f` entering the fourth part, define `L(f)` by
the following table. Count occurrences, including repeated uses of a shared
node; a count of distinct term identities is insufficient.

| Formula shape | `L(f)` |
| --- | --- |
| True, False, negation, existential, disjunction or ordinary predicate application | `1` |
| Conjunction or equivalence with children `a,b` | `L(a)+L(b)` |
| Implication with consequent `b` | `L(b)` |
| Conditional with then/else propositions `a,b` | `L(a)+L(b)` |
| Let or universal quantifier with body `b` | `L(b)` |
| Case with proposition branches `b_i` | `sum_i L(b_i)` |
| Equality `(if c then True else False) = True`, matching the exact Boolean-symbol test | `L(c)` |

The equality row takes precedence over the ordinary-application row. Why3's
typed `t_case` rejects an empty branch list (`term.ml:939–951`), so `L(f)>=1`.
Term-valued variables/constants/epsilon cannot occur as bare well-typed
propositions in the splitter; its explicit error branches remain errors.

For every accumulator of length `k`,

```text
length(split acc f) <= k + L(f).
```

This follows by structural induction on the actual splitter (`gnat_split_conj.ml:23–89`):

- The early guard appends one, bounded by `L(f)>=1`. Atomic cases do the same.
- Conjunction runs the two children consecutively against the accumulator;
  the two inductive increments add.
- Implication, let and universal quantifier map over `split [] body`, then
  append those results. Opening/closing binders and copying attributes do not
  change the number of list elements.
- Equivalence and conditional construct two implications. Each implication
  preserves only its consequent's split count. Applying the accumulator guard
  to either generated implication can reduce its contribution to one.
- `split_case` maps existing branch lists without multiplying them, then
  appends one new branch list for each result of `split [] branch`. Its total
  is the sum of branch counts, not their product.
- The special Boolean equality creates a dummy let around `c`, then splits
  that let. It retains the bound `L(c)`; the dummy binder does not add a goal.

All constructors in these branches are the non-simplifying typed term
constructors; binding opens rename bound variables and preserve formula shape.
No claim that arbitrary rewriting preserves `L` is needed. The input here is
**after** the marked-definition unfolding and conversion rewriting.

Let `h_1,...,h_q` be the goals at that boundary. Then the whole Per_Check
transformation's terminal goal count satisfies

```text
G <= sum(j=1..q, L(h_j)) <= sum(j=1..q, term_occurrences(h_j)).
```

This is an exact interface to the response byte/container bounds. It requires
a source-derived upper bound on the right-hand side; it does not permit
compiling a program and counting its emitted goals to decide membership.

## Earlier transformations still need their source join

`unfold_right 1` does not mean one expansion in the whole formula. It traverses
ordinary children, including the arguments of eligible applications, at the
current depth, then substitutes a marked definition and recurses on that
replacement at depth zero. Nested applications in the original arguments may
therefore each expand. Definition substitution can repeat an argument. Only
definitions carrying `GP_Inline` and the required `GP_Pretty_Ada` labels enter
the map; arbitrary library definitions do not automatically expand.

Likewise `elim_to_of_array` is not a general occurrence-size-decreasing pass.
It records rewritten let definitions in an environment, then can replace an
application on a variable by a child of that variable's stored definition
(`gnat_rewrite.ml:18–36,43–63,119–124`). The original let remains. Repeated
uses may therefore repeat a stored subtree in the occurrence count even if no
new subtree identity is allocated. These replacements need a binding-aware
occurrence transfer before using the formula above.

The inspected SP/WP code supplies useful structural facts, but they do not
finish that transfer:

- `vc_sp` selects compact SP through `vc_fun`/`vc_kode` and `reflow`.
  `sp_expr` visits each sequence child once and joins its safety formulas as
  `wp1 /\ forall(..., sp0 -> wp2)` (`vc.ml:1428–1500`). A branch's continuation
  is not copied merely because its two source arms exist.
- `reflow` marks whether an outcome has one or multiple exit points, pushes a
  continuation at a single exit, and removes unreachable continuations
  (`vc.ml:1073–1173`). The classical `wp_expr` has different duplication
  behavior and remains reachable through internal WP/axiom paths.
- VC declaration construction subsequently calls `Typeinv.inject`,
  `Eval_match.eval_match`, and `simp_cast_projections`
  (`vc.ml:1675–1689`). Counting only the formula before those passes is not
  the required input to `split_goal_right`.
- Right splitting has its own case compilation and flag-controlled
  cross-products (`split_goal.ml:176–438`). Its name is not a proof that
  every relevant cardinality is linear in registered checks.

The outstanding join is from the existing source-derived producer occurrence
and label counts through Why3 typing/VC generation, these preprocessing passes,
the first split, marked unfolding and binding-aware conversion rewriting, to
`sum L(h_j)`. This component closes the final list-count transfer only. It
neither bounds Why3's own complete allocations/identifier domains nor supplies
the missing source-derived `G` by assuming it equals the registration count.
