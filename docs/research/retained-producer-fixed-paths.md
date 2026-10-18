# Fixed library task bounds with return and loop outcomes

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119) research.
The complete retained native inputs and pinned converter/SP/WP/splitter source
give these conservative bounds:

| Fixed entity | Terminal Why3 tasks `G` | Response records `R` |
| --- | ---: | ---: |
| First_Or_Default | 1,203 | 9 |
| Put | 629 | 18 |
| Put_Line | 1,145 | 22 |

These are source-derived upper bounds, not observed solver goal counts. Every
evaluated call is charged two tasks, even when it has no precondition; this
intentional overcount avoids needing a tight count for each unchecked call.
The [offline evidence](../evidence/retained-producer-fixed-paths-20261018/README.md)
reconciles the calculation with complete native inputs and source identities.
No compiler, Why3, solver or Lean process ran for this work.

The [fixed-input independence argument](retained-producer-fixed-check-spines.md)
applies: fixed library bodies and their contracts do not depend on Main.
Their retained semantic tree is invariant under the recorded configuration,
modulo fresh names/check IDs and bounded source-location metadata. The exact
retained file hashes identify the concrete representatives; they are not a
claim that moving the installation preserves those bytes. Library or relevant
configuration changes invalidate these fixed cases.

## The path account

For a verification-code fragment use a finite map `p[i]` of path multiplicities
for each exported outcome, and a weighted check count `Q`. Normal completion
has its own key; every named exception/return has a distinct key. These count
paths in finite verification code, not runtime paths through all loop iterations.
Predicates attached to checks supply their positive-leaf weights below.

For fragments `A=(p,Q)` and `B=(r,S)`, composition that handles outcome `i` is

```text
Q(A ;i B) = Q + p[i]*S
p(A ;i B)[j] = (if j=i then 0 else p[j]) + p[i]*r[j].
```

Missing map entries are zero. Other outcomes of A bypass B. Parallel/check
branches and conditional alternatives add their maps and check counts. A
conditional evaluates its condition before those alternatives. `Kstop f`
has no exported outcome and costs the leaf weight of `f`; `Kcut f` also checks
`f` but preserves one normal route. Assignments, havoc, lets and assumptions
without a checked predicate export one route. A raise exports only its named
outcome. Catching one named outcome does not also catch a fresh raise of the
same name from that handler; the checker keeps this lexical scope distinction.

The native statement sequences and bindings become sequencing. `And_then`
and `Or_else` are conservatively a right-operand route plus a skipped route
after their left operand. Each evaluated call first evaluates its arguments,
then supplies one normal route and at most two check leaves. The complete
inputs confirm every call argument itself has exactly one normal route and
no escaping outcome, so the argument evaluation order does not affect this
sum. The call's assumed result postcondition adds no checked continuation.

Every `Abstract_expr` here has an explicit True postcondition and no escaping
exception. The converter either removes it or creates an abstract Cfun block
(`gnat_ast_to_ptree.ml:889–903`). Charge the child body's checks and one True
postcondition per child normal route, then export exactly one normal route
for the abstract block. This includes empty helpers even when removed.
`Any_expr` is an abstract callable, with its precondition checked and its
postcondition assumed. None has exceptional effects in these inputs.
There are no additional program-function bodies in the imported native context.

### Why the SP case splits fit this account

This uses the actual constructors in `src/mlw/vc.ml`, not just a logically
equivalent full-path formula. SP sequence constructs

```text
wp_A and forall fresh. (sp_A[i] -> wp_B)
```

and combines each B outcome with `sp_A[i]` by conjunction
(`:1421–1494`). Thus A's checks occur once; B's checks can acquire only the
selected-outcome path multiplier. Alternative outcome maps combine by
`sp_or`; `Kif` creates one `sp_if` per outcome after completing write maps,
not one conditional per written variable (`:1495–1512`). Hence alternatives
add and sequencing multiplies the selected path counts. Variables renamed
for writes, quantifiers and lets do not add alternative paths.

All native check and assumption formulas here lack `case_split` and enabled
by/so metadata. Generated path merges are the source of antecedent case splits.
The right splitter can expose at most the alternatives represented by this
full-path account; its suppression of case splits when they would duplicate
nontrivial positive lists only decreases that allowance
(`split_goal.ml:175–217,263–280`). Unmarked assumptions do not independently
multiply the count. The classical WP branches satisfy the same recurrence by
substituting the continuation at each matching exit (`vc.ml:1600–1646`).
Switching between WP and SP therefore does not require an additional factor.
The [reflow argument](retained-producer-kode.md#reflow-preserves-attached-terms-without-copying-code)
ensures continuation placement adds no code-copy multiplier.

This argument requires the concrete predicate frontier below. It is not a
claim that an arbitrary Boolean formula stored in an assumption can be treated
as one path, nor that arbitrary Boolean-valued terms preserve these leaf costs.

## Loops terminate their normal verification route

Put and Put_Line each contain one native Loop with two invariants and no
variant. Let `A` be its `code_before`, `D` its `code_after`, and `I` the sum of
all invariant leaf weights. The converter produces

```text
A;
while True invariant inv do D; A done.
```

The true-guard/empty-variant Ewhile branch lowers this to

```text
A; parallel(stop I,
            havoc; assume inv; D; A; stop I).
```

See `gnat_ast_to_ptree.ml:789–877` and `vc.ml:930–963`. The two invariant
checks are initialization and preservation. The normal route through the
body ends at preservation; it does not fall through the loop. Only named
return/loop-exit routes escape this verification fragment, and their enclosing
handlers process them normally. Both copies of `code_before` are charged.
No numeric trip-count factor is introduced.

The existing solid scalar/String/flat-reference
[type frontier](retained-producer-main-types.md) supplies no injected Why3
type invariants here. Native implicit frame facts remain explicit assumptions
in `code_after`; the checker counts every actual entry of the invariant list,
not only entries carrying native check IDs. The outer function body has
`vc:divergent`, inherited by its generated helpers, so there is no additional
missing-divergence obligation.

For each of these two loops the conservative calculation is:

| Component | Exported route multiplicities | Weighted checks |
| --- | --- | ---: |
| A | normal: 1 | 43 |
| D | normal: 1, Return: 1, loop-exit: 1 | 38 |
| Invariant list | no route when checked by stop | 2 |
| Complete Loop | Return: 1, loop-exit: 1 | 128 |

Indeed `43 + 2 + 38 + 43 + 2 = 128`. The surrounding nonempty-range test,
loop-exit handler, failure returns and post-loop calls are outside this row
and are included in the complete calculation.

## Concrete predicate and call frontier

The checker walks every evaluated expression in the pinned native body,
including expressions nested in call arguments. The reached calls are:

- scalar arithmetic/comparison and Boolean operations;
- scalar representation and integral range-check operations;
- String bounds, length, record conversion and array map get/set/slide/slice/
  equality operations;
- the fixed input queries, Argument, output primitives and generated literal/
  aggregate constructors.

The fixed native callable declarations have empty/True preconditions except
Argument's single scalar comparison. The imported integral `range_check_`
template requires `in_range`; the exact cloned definitions are two scalar
comparisons. Array map operations and representation/conversion helpers have
no additional precondition. These are the concrete templates in the retained
`ada__model.mlw` and `_gnatprove_standard.mlw`, plus the native declarations,
not a general statement about every callable with the same basename. Their
effects have no exceptional posts. Thus charging **two positive leaves per
evaluated call** covers even the integral range check after marked unfolding.
Explicit native assertions and Any_expr preconditions are charged separately.

All positive native predicates reached by these checks consist of scalar or
opaque-Boolean atoms, conjunctions, implications, equivalences, conditionals,
lets and universal quantifiers. The positive scalar comparisons remain atomic
through matcher preprocessing. The only direct positive Boolean-state atoms
in Put/Put_Line's contract refer to Succeeded and Flushed, whose assignments
are Boolean constants; matching them adds no concealed formula expansion.
Branch-observation variables occur in guards, not these checked postconditions.
The input-query result is an opaque application. Character comparisons use
the scalar representation. No String-record equality is expanded in a positive
checked position.

In particular the emitted `Array__Int__Standard__character.bool_eq`
declaration has **no GP_Inline attribute** in all three inputs. Its equality
to True remains an atom for marked unfolding, despite the function's semantic
definition describing array equality. The marked Is_Message definition is
used in assumptions, not a positive checked position in these three entities.
The only relevant marked positive applications are the two-comparison integral
range predicates already paid by the per-call allowance. Right unfolding
does not visit antecedents or let definitions
(`gnat_split_conj.ml:166–210`).

After this refinement, the native predicate leaf account is additive for
conjunction, equivalence and the two branches of a conditional; implication
charges only its conclusion, and let/forall only their body. An atom, retained
True, negation or disjunction costs one. The exact forms here contain no
by/so or case-match term. These rules dominate both right split stages on this
frontier (`split_goal.ml:209–338,417–431`; `gnat_split_conj.ml:21–76`). Final
conversion rewriting changes array terms without duplicating positive leaves.

The complete arithmetic is:

| Entity | Body normal routes | Body check budget | Outer postcondition leaf budget | Total |
| --- | ---: | ---: | ---: | ---: |
| First_Or_Default | 6 | 1,173 | 5 | `1173 + 6*5 = 1203` |
| Put | 6 | 593 | 6 | `593 + 6*6 = 629` |
| Put_Line | 8 | 1,089 | 7 | `1089 + 8*7 = 1145` |

No exceptional outcome escapes a complete body. The outer function's explicit
postcondition is charged on every normal route. An observed successful proof
or a count of native check IDs is not used to establish these task bounds.

## Response composition and remaining domains

First_Or_Default has nine native check IDs and no loop-invariant ID. Put has
14 IDs, including two loop-invariant IDs; Put_Line has 18, also including two.
The [registered-label result](retained-producer-response.md#registered-ids-bound-result-records-without-a-kind-domain-product)
gives `R <= V + 2*V_loop`, hence 9, 18 and 22. Combining the previously
established Input_Is_Valid/Is_Message bounds gives, over the five fixed files,

```text
sum G <= 2981
sum R <= 51.
```

The [response transfer](retained-producer-response.md) then supplies the
following aggregate byte accounting over five independently constructed files:

```text
sum raw bytes       <= 6,660,802 + 3*sum W + 6*sum(L_A + L_W)
sum projected bytes <= 7,944,973 + 3*sum W + 6*sum L_W.
```

Warnings, warning-string bytes and argument-string bytes remain explicit terms;
these expressions do not assume they vanish. The source-to-task join closes
one missing component for the [literal-output path](retained-producer-zero-check-sources.md).
It does not bound the entire Why3 lifetime identifier/hash-cons allocation,
each solver's internal representation, native/frontend/flow/final report
objects, or the time and memory needed to discharge the tasks. It supplies no
aggregate-RAM admission gate. Production admission remains unchanged and #119
remains unfinished.

An independent source review supported the outcome-aware recurrence and loop
lowering under the stated predicate-shape premises. It checked SP sequence,
Kif/Kpar, stops/cuts, abstract Cfun continuation and true-guard Ewhile against
the pinned source, and found no material issue when reviewing this complete
record and its stated frontier. It did not independently recompute the three
totals, audit every predicate expansion or run any transformation. The offline checker
checks pinned identities and arithmetic; it is not a mechanized proof of the
SP/WP/splitter argument.
