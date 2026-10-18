# First right-split bound and the type-invariant frontier

2026-10-18, research for
[#119](https://github.com/berkeleynerd/silver/issues/119). For a case-free input
formula, the retained Why3 first right split emits at most `2*n^2` formulas,
each with lexical marked-unfolding envelope at most three times the input's.
Together with the [post-split transfer](retained-producer-postsplit.md), this
gives a conditional terminal-goal bound. This record does not assert that every
Silver-generated VC satisfies the case-free premise or supply the missing
source-to-VC size bound. It changes no production rule or tool configuration.

The [retained source identities](../evidence/retained-producer-firstsplit-20261018/identity.json)
pin Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`. The accompanying checker
checks source hashes and induction arithmetic; no compiler, Why3, solver or
Lean process is executed. Installed-tool relevant behavior remains a separate
accepted premise.

## Conditional first-split transfer

Let `f` be a well-typed proposition containing no `Tcase`, including in terms,
let definitions and quantifier triggers. Let `n >= 1` count every term-node
occurrence, including repeated occurrences of shared nodes and trigger terms.
Patterns, type nodes, variable declarations and attributes have separate costs.
The condition can be weakened to exclude only cases visited by the splitter,
but the stronger condition is easier to carry through VC generation.

The selected transformation calls `Split_goal.split_goal_right`, which uses
`right_proof`: `right_only`, `byso_split`, `side_split`, `stop_split`, both case
flags and `asym_split` are true; `intro_mode` is false and `comp_match` contains
the task's known map (`split_goal.ml:455–486,559–562`). With no `Tcase`, the
known-map pattern compilation branch is unreachable.

For a recursive result write `P`, `N` and `S` for the lengths of `to_list` of
`pos`, `neg` and `side`; put `Q=P+N+S`. Distinguish the two *configuration*
flags from the returned `cpos`/`cneg` flags. Induct simultaneously over all
four configurations:

| Configuration `(cpos_split,cneg_split)` | Bounds |
| --- | --- |
| `(false,false)` | `Q <= 2*n` |
| `(true,false)` | `P <= 2*n`; `N+S <= n^2` |
| `(false,true)` | `N <= 2*n`; `P+S <= n^2` |
| `(true,true)` | `Q <= 2*n^2` |

A disabled configuration flag implies its returned flag is false. The
`case_split` attribute can set a returned flag only to the corresponding
configuration flag (`:441–443`). Stop handling returns one positive and one
negative element and no side conditions. Resetting a result whose side is
`Zero` only removes positive/negative elements (`:444–447`).

### Why cross products stay bounded

The monoid laws give three direct cardinality facts (`:38–112`):

1. `Unit` has length zero, `Zero` length one, and a base length one.
2. Addition has length at most the sum. The maps used here do not increase
   length.
3. Bimapping has length at most the product of its argument lengths. Its
   zero cases return at most one base/zero for each paired element.

`degree <= 1` implies length at most one. With `right_only=true`, a `pcase`
or `ncase` uses the child's decomposition only if its returned flag is true
and the *sum* of all guard degrees is at most one; otherwise it supplies one
whole `bwd`/`fwd` formula (`:176–193`). Thus a guarded cross product with a
counterpart of length `x` is bounded by `max(x, child_count)`, with zero
handled by the monoid law. It is safely bounded by `x+child_count` when a
sum is more convenient. This is the relevant mechanism; merely knowing the
transformation's name is insufficient.

The two-stage products in ordinary conjunction and disjunction obey the same
bound. In conjunction, the left `ncase` is guarded by the actual right
`nf2`, so choosing both decompositions requires `length(nf2)<=1`. In
disjunction, the guard is the right `sf2.pos`; if its length is at most one,
the separately selected right `pf2` also has length at most one. Otherwise
the left selection is a singleton. In either case the product is at most
`max(1, forced_left_count, forced_right_count)`.

### Induction by source branch

For binary children let their occurrence counts be `n1,n2 >= 1` and put
`n=1+n1+n2`. Additional source wrappers in by/so forms only increase `n`.

- **Both flags disabled.** Every `pcase`/`ncase` supplies a singleton.
  Ordinary conjunction/disjunction cost at most `Q1+Q2+1`, implication at
  most `Q1+Q2`, and equivalence at most `Q1+Q2+2`. A conditional costs at
  most the sum of its three child `Q`s. A `so` form costs at most
  `Q1+Q2+1`; a `by` form at most `Q1+Q2`. These all fit `2*n`.
- **Only the negative flag enabled.** Conjunction retains that mode in
  both children. Its negative count is at most
  `max(1,N1,N2) <= 2*max(n1,n2)`. The positive/side count is at most
  `(P1+S1)+(P2+S2)+2*N1`: asymmetric closure can add the forced left
  count to each of `pos2` and `side2`, at most once each. Hence it is at
  most `n1^2+n2^2+4*n1 <= n^2`. Disjunction and implication clear the
  remaining case flag in their children, so the linear disabled-mode
  bounds suffice. Negation exchanges positive/negative modes.
- **Only the positive flag enabled.** Disjunction retains this mode;
  implication sends its left child to negative-only and its right child
  to positive-only. Their forced positive count is at most
  `2*max(n1,n2)`. Their negative/side count is at most the children's
  unforced/side counts plus twice the left forced count, again bounded
  by `n1^2+n2^2+4*n1 <= n^2`. Conjunction clears the remaining flag in
  its children. Negation uses the preceding case.
- **Both flags enabled.** Conjunction, disjunction and implication send
  their children to the preceding one-flag modes. Their total is at most
  `n1^2+n2^2+4*n1+2*max(n1,n2) <= 2*n^2`.
- **Equivalence, conditional and enabled by/so.** These explicitly clear
  both flags in all their recursively split children. The disabled-mode
  total bound therefore applies irrespective of the caller's mode.
  For their size `n>=2`, `2*n<=n^2` also supplies either one-flag bound.
  Disabled by/so handling simply recurses into the selected subformula.
- **Negation, let and quantifiers.** Negation exchanges positive/negative
  counts and flags. A retained let maps a wrapper over each result without
  multiplying counts. A universal quantifier keeps positive/side counts
  and replaces the negative count by one; an existential does the dual.
  Adding one fits the extra binder node's linear/quadratic allowance.
  Definition/trigger terms only enlarge the available occurrence budget.
- **Atoms and constants.** A predicate application contributes `P=N=1`;
  true and false contribute total one. Their term arguments need not be
  recursively split. The ill-typed bare-term error branches cannot occur.

For the main one-flag inequality, setting `a=n1-1`, `b=n2-1` gives the
nonnegative polynomial identity

```text
(1+n1+n2)^2 - (n1^2+n2^2+4*n1) = 2*a*b + 4*b + 3.
```

Replacing `max(n1,n2)` by `n1+n2` in the both-flags bound gives difference
`a^2+b^2+4*a*b+4*a+8*b+8` against `2*n^2`. These identities, together
with the unary and disabled-mode inequalities, are checked offline. They
check the arithmetic used by the source induction, not its correspondence.

Finally `split_proof` returns `to_list(pos ++ side)`, whose length is at
most `P+S<=Q`. The actual first-split output count therefore satisfies

```text
q <= 2*n^2.
```

The later [formula-sensitive refinement](retained-producer-formula-refinements.md#first-splitting-counts-a-formula-skeleton)
sharpens this to `q<=2*s(f)^2`, where `s` excludes application arguments,
let definitions and quantifier triggers. Those positions remain counted in
the term-size envelope below.

## Cost of an individual output

For the same case-free input and any positive lexical weight environment,
every returned `bwd`/`fwd` has `E1` at most the input's `E1`, and every
positive, negative or side formula has `E1` at most three times the input's.
Here `E1` and the eligible marked-definition map `D` are exactly those in
the [post-split record](retained-producer-postsplit.md).

This follows by simultaneous structural induction on `split_core`:

- Whole-formula fallbacks use the `bwd`/`fwd` bound. Logical wrappers
  combine at most one fragment from each relevant child in each individual
  output. Cross products multiply *how many* outputs exist; they do not
  concatenate every selected output into one formula.
- The largest connective replacement for one original connective is the
  negative equivalence branch `not a /\ not b`, with three constructors.
  Conditional closures use a condition once, optionally under negation,
  and one branch fragment. By/so fallbacks drop existing source wrappers.
- Predicate applications and their arguments are unchanged. Thus the
  definition-sensitive `max` clause of `E1` needs no monotonicity claim
  about arbitrary formula rewriting or newly introduced applications.
- Let definitions are unchanged; apply the body induction with the same
  lexical weight for the let variable. Quantifier triggers are unchanged
  and bound variables receive the same fresh weights as in the input.
  Binder opening changes identities, not occurrence structure.

Consequently each first-split result `g_i` satisfies
`E1(g_i,empty,D) <= 3*E1(f,empty,D)`. The splitter changes only the goal
declaration; `Trans.goal_l` reuses the same previous task for each replacement
(`trans.ml:208–213`), so its context and eligible definition map are unchanged.
The later singleton transformations and final conjunction split give

```text
G(f) <= sum_i E1(g_i,empty,D)
     <= 6*n^2*E1(f,empty,D).

G(total) <= sum_over_initial_VCs f (6*n_f^2*E1(f,empty,D_f)).
```

This is a deliberately sufficient transfer, not an exact estimator. A
source admission account may keep the stronger structure-sensitive sum
when available. Neither formula permits generating the VC with GNATprove
and using the observed successful size to decide language membership.

## Type invariants: a sufficient case-preservation condition

`Typeinv.its_solid` means **all** of the following (`typeinv.ml:25–29`):
the symbol is not fragile, all type-argument flags are frozen, and all
region flags are frozen. Merely observing `td_inv=[]` does not establish
this property. A generic tuple or record may be nonsolid without having
an invariant.

A weaker sufficient condition for not introducing retained `Tcase` terms
is a finite ranked certificate on every instantiated type reached by
`add_gl_cap` or `add_var`:

1. A type variable or a solid symbol is a terminal case.
2. Otherwise the symbol is not fragile. Every instantiated field of a
   nonfree record, or constructor argument of a free type, has a strictly
   smaller certified rank.

Induct on this certificate. All recursive children yield capability `V`;
`mkC` and `mkR` collapse collections of `V` to `V`. Neither helper enters
the fragile-record branch, so it creates no pin (`:119–164,313–355`).
Consequently `inspect` has no pin to commit and emits no `ls_valid`
formula (`:166–304`). In `inject`, variables and their bound replacements
have capability `V`; ordinary constructors collapse to `V`, joins preserve
`V`, and equality produces no extra commitment formulas. The branches
creating a new case from a nontrivial capability are unreachable. Existing
cases may be traversed, but case-free input stays case-free.

This weaker condition does **not** establish a nonincreasing occurrence
count. A trusted projection of a nonsolid type can be pushed through an
`if` or let and repeated in its branches. `add_gl_cap` can also construct
temporary field-extraction cases while recursively finding that every
capability is `V`. Those temporary objects need a separate allocation
account even though none reaches the VC. Under the stronger all-solid
condition, the trusted projection/constructor branches are disabled,
`add_gl_cap`/`add_var` terminate immediately, and this particular projection
distribution is absent.

## Generated syntax narrows, but does not finish, the frontier

The retained plugin supplies concrete exclusions:

- Every generated `Type_decl` has no invariant and no witness
  (`gnat_ast_to_ptree.ml:1175–1206`). Such a declaration generates no
  independent type-invariant VC (`vc.ml:1775–1783`). Imported declarations
  still require their own account.
- The plugin's only match constructor is a try block with **no ordinary
  match branches**, and each exception handler has at most one variable
  pattern (`:119–124,930–940`). `vc.ml:857–905` goes directly to the body
  for an empty ordinary branch list; tuple-destructuring `Kcase` is used
  for exception payloads only when there are multiple bound variables.
- Generated tuple expressions/types in this converter are unit tuples.
  Builtin tuple declarations have constructor fields without named
  projections (`pdecl.ml:683–686`), so it would be unsound to assume that
  every possible tuple has the complete-record projection fast path.
- Loop variants are explicitly lowered into old/new values and assertion
  comparisons; the generated `while` receives an empty variant list
  (`gnat_ast_to_ptree.ml:808–875`). This excludes the algebraic-decrease
  path for those loops; it does not classify imported function bodies.

The remaining joins are precise:

| Producer boundary | Remaining source-derived obligation |
| --- | --- |
| Generated and imported type instances | Establish the ranked no-pin condition above, or account for general invariant injection. No-invariant syntax alone is insufficient. |
| Write-effect havoc | Show each affected type takes the directly written/nonfree or complete-record-projection branch, or account for the fallback cases at `vc.ml:1289–1306`. |
| Match evaluation | Close the eligible logical-definition bodies used by `find_inlineable`, including its one-branch projection-case form; account for quantifier destruction, constructor equality and lexical substitution in size bounds (`eval_match.ml:62–82,87–130,154–211`). |
| VC generation | Bound the generated/typed expressions, SP/WP formulas and all preprocessing sizes before the first split. The absence of source `case` statements does not supply these bounds. |
| Full process capacity | Count temporary objects, identifiers, types, attributes, patterns, lists and declaration/context storage in their actual representation domains, alongside the terminal-goal/response bounds. |

In particular, match evaluation can inline a retained logical definition
whose body is a one-branch case even when the incoming formula has no
case. A sufficient no-case frontier can exclude that eligible body shape,
or prove its elimination for each allowed argument shape; this record
does neither globally. The conditional transfer closes the splitter's
arithmetic interface without concealing this source dependency.

The subsequent [ordinary Main type record](retained-producer-main-types.md)
specializes this frontier to its actual scalar/String/reference shapes and
named-field wrappers. It closes case creation for that family; incoming size
bounds and the separate fixed library-body processes remain outstanding.
