# Match preprocessing: a lexical size transfer for ordinary Main

2026-10-18, research for [#119](https://github.com/berkeleynerd/silver/issues/119).
Given the [concrete Main type/definition frontier](retained-producer-main-types.md),
this record bounds the retained term occurrences after
`Eval_match.eval_match`. It does not count all allocation attempts, prove a
bound on the preceding SP/WP formula, or finish the marked-definition `E1`
join. The source files and their identities are retained by the Main type
record. No native tool is run.

The [offline fixtures](../evidence/retained-producer-matchsize-20261018/check.py)
recheck that source archive and the small occurrence example below. They do
not execute or formally verify the matcher.

## Constructor equality requires a product

The matcher evaluates the two sides of equality and calls `cs_equ`
(`eval_match.ml:154–163,175–178`). It can follow both sides through their
conditionals, distributing the comparison. For example, abstractly writing
`Box` for a one-field constructor,

```text
(if p then Box(x) else Box(y)) = (if q then Box(z) else Box(w))
```

can produce four scalar equalities, under the two conditions. With each atom
one node, the input has 13 term occurrences and the fully distributed shape
has 18. More branches produce a product. These are arithmetic shapes, not
claims of a newly executed probe or a source-language constructor.

Let `C(t,rho)` be the lexical `E0` envelope from the
[post-split record](retained-producer-postsplit.md), with saved definitions
charged at each variable occurrence. A definition in the matcher's environment
must have envelope at most its variable's positive weight. For the concrete
case-free frontier, constructor equality satisfies

```text
C(cs_equ(a,b),rho) <= 3*C(a,rho)*C(b,rho).
```

The argument follows the actual traversal:

- The fallback equality has cost `1+x+y <= 3*x*y` for positive `x,y`.
  Equal terms or different constructor identities return a constant.
- A conditional on either side distributes the other comparison into its
  two arms. The condition is retained once at that level; its cost fits
  the corresponding factor's original conditional cost.
- A let retains its definition and recurses with that definition entered
  in the environment. Its definition cost and binder fit the same factor;
  lexical charging accounts for each later use or substitution.
- Matching constructors compare paired fields and conjoin those formulas.
  The sum of paired products, plus conjunction constructors, fits the
  product of the two original constructor costs. A constructor with no
  fields returns true. Following a saved variable uses its charged cost.
- If a traversal raises `Exit`, the enclosing comparison falls back to its
  original equality. Partial expressions constructed before that failure
  are **not** retained in the result; their allocation is a separate budget.

For named-field projection, a successful `dive_to_constructor` keeps only
the selected constructor field, plus the conditionals/lets it crossed. This
is nonincreasing in `C` of its argument. If any required traversal fails,
the original projection application is retained. It is incorrect to count
successful projection traversal as adding a fresh projection at every
conditional leaf: the callback actually selects an existing field.

## The computable envelope

Define `M(t,rho)` recursively. Free variable weights default to one. New
binder identities are fresh, and all weights are positive integers.

```text
M(variable v,rho) = rho(v)
M(let v=a in b,rho)
  = 1 + M(a,rho) + M(b,rho[v := M(a,rho)])
M(equality(a,b),rho) = 3*M(a,rho)*M(b,rho)
M(other ordinary term node with children c_i,rho)
  = 1 + sum_i M(c_i,rho).
```

Use the equality clause for the builtin equality predicate, including
Boolean-valued equality. An enclosing negation adds its ordinary one node;
the matcher's negated-equality shortcut cannot increase this bound. Other
binders reset their newly bound variables to one unless the quantifier rule
below applies. Include term children in triggers. No case node occurs under
the closed Main frontier.

For a quantifier, use the following finite destruction profile for each
bound variable:

| Original type | Weight substituted for original variable | Extra retained let cost |
| --- | ---: | ---: |
| Unit | `1` | `2` |
| Flat one-field reference | `2` | `3` |
| Other concrete Main type | `1` | `0` |

Unit is replaced by its nullary constructor. A reference is replaced by
its constructor applied to one fresh variable of its pure content type;
that type is nondestructible in this frontier. The additional cost counts
the let binder and the constructor term. Define the quantifier cost as
one, plus the sum of these extra costs, plus `M` of its body and trigger
terms under the substituted weights. This safely allows destruction even
when the actual `stop`/annotation guard disables it. If the guard disables
destruction, the unchanged bound-variable weights and absence of extra
lets are smaller.

`add_quant` performs exactly this constructor/let substitution and updates
the triggers (`:87–130`). It does not introduce an arbitrary tuple of all
quantified variables. Opening multiple binders creates fresh variables;
the introduced reference contents are pure and do not recursively destruct
into another reference. The two-field String and bounds records are not
destructible. Unused lets/quantifiers can be removed by simplification.

The relevant `find_inlineable` definitions have bodies that are a variable,
constant or one unary application on their formal variable. Their possible
one-branch case body is excluded by the concrete definition frontier.
Inlining those aliases does not increase this raw lexical envelope. Chains
of such aliases require their own traversal/allocation account, but each
retained replacement has the same one-application shape or a smaller one.
Named reference-wrapper targets are the named-field projections already
handled above. No equality application has this unary shape.

Apply structural induction, maintaining the saved-definition weight invariant,
and the constructor-equality product lemma. The result is

```text
E0(eval_match(f),empty) <= M(f,empty).
```

This is a size envelope for the existing deterministic pass. Its arithmetic
uses unbounded mathematical integers, with saturating/checked evaluation
required in a future membership implementation; an overflowed counter must
never wrap into acceptance.

## What this joins, and what is still needed

For ordinary Main, the preceding all-solid type-invariant pass rebuilds the
same structure without its projection-distribution or pin-expansion paths.
The following constant range-projection simplifier only contracts terms.
Thus `M` supplies a sufficient upper bound on the `n` entering the first
right split, **provided the incoming SP/WP formula is itself accounted for
from source**. Its products are sensitive to the actual equality/conditional
structure; there is no additional arbitrary source cap.

This does not automatically bound `E1` of the post-matcher formula. That
envelope depends on the exact marked-definition map and formal-use counts,
including definitions inside the formula after alias/projection rewriting.
An indiscriminate bound exponential in the whole formula size would lose
the useful admission region. The remaining join must carry that map and
its reachable call shapes through the source-derived SP/WP and matcher
account. The retained tree envelope also does not bound temporary discarded
branches, identifier/type allocations, context declarations, the four fixed
library-body processes or complete solver representations.
