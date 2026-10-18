# Joining match preprocessing to marked unfolding

2026-10-18, research for [#119](https://github.com/berkeleynerd/silver/issues/119).
This lifts the [matcher envelope](retained-producer-matchsize.md) to the
[`E1` envelope](retained-producer-postsplit.md) used by the two subsequent
splitters. It closes that mathematical transfer **given** the incoming formula,
the concrete type frontier, the exact marked-definition map and the finite
unary-alias map. Deriving those inputs from source remains required. No native
tool was executed; the pinned source and arithmetic fixtures are checked
[here](../evidence/retained-producer-match-unfold-20261018/check.py).

## Marked application costs are maxima of affine forms

Let `D` be the actual map constructed by `unfold_trans`, including the
Boolean-axiom wrappers it creates. For each symbol, define

```text
A_D(f, w_1,...,w_k) = max(1+sum w_i, E0(D[f].body,formal_i:=w_i))
```

when `f` is in `D`; otherwise use `1+sum w_i`. Use the actual ordered formal
bindings if a list repeats a variable. All other free variables keep their
lexical weights. Alpha-fresh formula binders do not capture definition-map
variables. These are exactly the application cases of E1, not a recursive
unfolding of the body.

`E0` is affine in free-variable weights. In its let case, the body's coefficient
of the bound variable multiplies the affine definition cost; that coefficient
depends on syntax, not on the external weights. Thus each fixed definition
body can be summarized by its constant and formal-use coefficients. Preserve
any other free-variable coefficients as well. This permits exact evaluation
of `A_D` without constructing its substituted body. Its constructor arm is
essential when an actual pass skips the application.

For example, `D[f](x)=x /\ x` gives `A_D(f,w)=1+2*w`; two original nested
applications cost seven at unit input weight. Only the original application
nesting composes those multipliers. Calls introduced solely inside one
unfolded body are still evaluated with E0.

## Unary aliases must carry their target's marked cost

The reviewed `find_inlineable` frontier contains only identity, constant and
unary-application bodies; its case-shaped alternative is excluded for ordinary
Main. Named projections are handled before this alias branch. Let `I` be the
actual finite, acyclic alias graph for the reached symbol/type instances.
For a unary nonprojection symbol define

```text
H(f,w) = max(A_D(f,w), w)                 if I[f] is its formal variable
H(f,w) = max(A_D(f,w), 1)                 if I[f] is a constant
H(f,w) = max(A_D(f,w), H(g,w))            if I[f] is g(formal)
H(f,w) = A_D(f,w)                        otherwise.
```

At a named projection stop this recursion and use `A_D(f,w)`; a successful
projection selects a charged part of its argument, bounded by `w`, and
`A_D(f,w)>=1+w`. Types and selected projection identities must remain in the
alias input. The later [constructor-invariant argument](retained-producer-formula-refinements.md#unary-alias-chains-cannot-cycle-in-a-constructed-context)
establishes acyclicity for the reached case-free alias graph of a constructed
Why3 context. This follows from declaration ordering and logic-definition
termination checks, not merely from Silver's lack of source subprograms.

Keeping both arms matters in both directions. An unmarked alias can lead to
a marked target whose replacement is large. Conversely, the matcher does not
recursively evaluate every trigger term, so an original marked alias may stay
in the formula even if its normalized target would be small. The original
`A_D` arm covers such skipped contexts. For a chain, H is the maximum of the
original application costs along the chain and its final identity/constant
cost. There is no product merely for passing through an alias chain.

## Equality and quantifier clauses

Let `eq` denote builtin equality. Put

```text
K = max(3, A_D(eq,1,1)).
```

For positive `x,y`, the affine property gives `A_D(eq,x,y)<=K*x*y`.
Any nonformal free-variable weights in D are held fixed for this inequality.
For ordinary builtin equality with no marked entry, K is exactly three.
Allowing the general coefficient avoids inferring absence from Dlogic alone:
the map can also be populated by marked axioms (`gnat_split_conj.ml:240–303`).

The constructor-equality argument from the matcher record now gives

```text
E1(cs_equ(a,b),rho,D) <= K*E1(a,rho,D)*E1(b,rho,D).
```

Conditionals distribute the counterpart; lets carry saved-definition weights;
paired constructor fields contribute a sum of pairwise products; fallback
equality is bounded by the displayed affine inequality. All marked application
costs dominate their ordinary constructor/child costs, so extra marked costs
on an input constructor can only enlarge the right-hand side. New output
connectives are the same ordinary Boolean constructors already charged.
Partial failed traversal output is discarded and is not part of this result.

For a destructed bound variable, charge the actual constructor introduced by
`add_quant`. If its unit constructor is `c`, use weight `A_D(c)` and overhead
`1+A_D(c)`. If its flat reference constructor is `c`, use weight `A_D(c,1)`
and overhead `1+A_D(c,1)`. The overhead is the retained let plus its definition.
Fresh reference contents have pure nondestructible types. For every other
concrete type use weight one and overhead zero. With unmarked constructors,
these are exactly the earlier `(weight,overhead)` pairs `(1,2)` and `(2,3)`.
This formulation also covers a constructor with a marked axiom entry rather
than silently assuming such an entry impossible.

## The joined envelope

Define `M1(t,rho,D,I)` recursively:

- Variables use their positive lexical weights.
- A let costs `1+M1(def)+M1(body,rho[v:=M1(def)])`.
- Equality costs `K*M1(left)*M1(right)`.
- An ordinary application uses `A_D` on its children's M1 costs, or H for
  a unary alias/projection in the reached frontier.
- A quantifier costs one, its destruction overheads, and M1 of its body and
  trigger terms under the corresponding substituted weights. Charging matcher
  evaluation in a skipped trigger is safe because each M1 clause also bounds
  the unchanged E1 shape.
- All other ordinary nodes cost one plus their children's M1 costs. Other
  binders reset their fresh variables to one. There are no case nodes under
  the ordinary Main frontier.

Structural induction preserves the saved-definition weight invariant. The
alias clause handles newly exposed target symbols, the equality lemma handles
distribution, and the quantifier clause charges its explicit substitutions.
Projection selection is nonincreasing in the weighted argument. Consequently

```text
E1(eval_match(f),empty,D) <= M1(f,empty,D,I).
```

The subsequent constant range-projection pass only replaces a projection of a
constant by a constant. Its E1 cost cannot increase because every application
cost includes its original constructor/child arm. The all-solid type-invariant
pass has already preserved ordinary Main formula structure. Let M0 be the
previous raw matcher envelope. Combining these results with the first split
and final GNAT split gives the concrete structural transfer

```text
G(f) <= 6 * M0(f)^2 * M1(f,D,I)
G(total) <= sum_initial_VCs 6 * M0(f)^2 * M1(f,D_f,I_f).
```

Use actual per-VC inputs; summing all imported context formulas into each goal
would lose the useful domain. Exact split structure can sharpen the quadratic
factor. No blanket exponential in total formula size is introduced by this
composition. Real repeated formal uses, equality products and lexical
definition reuse remain charged.

This resolves the earlier open matcher/E1 **composition**, not the source
derivation of f, D or I, the finiteness/coverage of the alias instances, all
identifier/hash-cons increments, fixed library-body processes, or essential
solver representations. Counters must be evaluated with checked/saturating
arithmetic in an eventual admission implementation. This research changes no
admission rule.

The later [formula refinements](retained-producer-formula-refinements.md)
close the case-free alias-cycle premise and give additive retained-equality
costs for scalar/opaque operands, plus a first-split factor based on the
logical skeleton. Source-to-formula composition and construction-time
identifier counters remain required.

## Source-dependent Main entries have fixed range bodies

The complete retained SPARK `src/` tree contains 279 Ada source files and
only three emitters of `GP_Inline_Marker`:

| Emitter | Condition / generated family |
| --- | --- |
| `gnat2why-subprograms.adb:3352–3358` | Nonrecursive Ada expression function without post/contract cases |
| `gnat2why-types.adb:571–614` | Explicit type-invariant predicate |
| `why-gen-scalars.adb:542–751` | Scalar range/dynamic-property predicate |

The symbol constant itself is defined in `vc_kinds.ads`; no other literal
`GP_Inline` emitter is present in that source tree. The checker inventories
these sites in the retained archive. Main has neither Ada expression-function
declarations nor explicit type invariants. Its internal WhyML Abstract_expr
functions are created later by the converter and do not call these Ada
emitters. The selected public API operations are not expression functions,
as established by the existing fixed marking frontier. Existing imported
entries and clones remain a separately paid fixed map; this inventory does
not declare that map empty.

Consequently the new source-dependent Main entries are scalar range predicates.
For ordinary Integer/Character integral representations,
`Generate_Range_Predicate` starts at true and constructs

```text
first <= x /\ x <= last.
```

`New_And_Expr` removes the initial true (`why-gen-expr.adb:3485–3504`), and
`New_Range_Expr` adds the two pretty-labelled comparisons (`:4883–4926`).
Pretty labels add no term nodes. Static bounds are nullary named constants;
dynamic bounds are explicit formal parameters. Their original source
expressions are not inserted into this definition body. The logical
predicate's affine costs are therefore

```text
static:  5 + 2*w_x
dynamic: 3 + w_first + w_last + 2*w_x.
```

If an actual map entry came from the Boolean-axiom extraction path instead
of the logical predicate definition, charge its additional three-node
`if ... then True else False` wrapper. The original-application arm of A_D
remains required. The Image adapter's copied Integer range template is a
fixed instance of this family, not a source-sized expression-function body.

This closes the size and formal-use profile of **new Main range entries**;
their number is bounded by the already charged scalar-type declarations.
It does not yet classify every reachable fixed imported D entry or prove an
aggregate bound on marked-call nesting in the initial formula. Those fixed
inputs and the source-to-formula transfer remain necessary for the complete
producer predicate.

Independent source review on 2026-10-18 found no material issue in the affine
application envelope, alias maxima, equality inequality, quantifier weights or
the two new range profiles. It checked the retained matcher/quantifier and
marked-definition extraction paths, including the skipped-trigger case. It
did not independently rederive the supplied Main type/alias frontier and
performed no native or Lean execution.
