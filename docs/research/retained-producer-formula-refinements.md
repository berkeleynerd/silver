# Formula-sensitive producer bounds

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119) research.
These source deductions sharpen the [matcher/unfolding
join](retained-producer-match-unfold.md) without executing Why3. They concern
retained formulas and task counts. They do not close source-to-typed-body
composition, construction-time counters, or the fixed library proof processes.
The [offline checker](../evidence/retained-producer-formula-refinements-20261018/check.py)
checks the retained source identities and arithmetic fixtures.

## Unary alias chains cannot cycle in a constructed context

The case-free `find_inlineable` frontier consists of a sole formal variable,
a constant, or `g(formal)` (`eval_match.ml:62–82`). Only the last shape adds
an edge to the alias graph. Its argument is unchanged; the target has the
same instantiated argument type. Type instantiation does not change the
target symbol identity or that syntactic fact.

Why3's `create_logic_decl` calls `check_termination` before constructing its
`Dlogic` node (`decl.ml:526–535`). For `f(x)=g(x)`, the call graph records
`Equal 0`, not `Less 0` (`:119–131,179–198`). Composing a cycle of these
edges still yields `Equal 0`; `find_variant` rejects a returning call vector
with no `Less` position (`:200–271`). Declarations can otherwise refer only
to already known symbols, so a cycle cannot straddle separate ordered
declarations. Variable/constant leaves and the named-projection fast path
terminate a chain.

Consequently the eligible case-free unary alias graph of every **constructed**
context is acyclic. A chain has no more edges than the number of logical
symbols in that context. The existing weighted maximum-along-chain recurrence
is therefore finite; it needs the actual definitions for its costs, but no
independent acyclicity premise. One-step polymorphic instantiation cannot
evade the symbol-cycle argument.

This is a constructor invariant, not a membership test based on a successful
Why3 execution. The separate source-correspondence/typechecking argument must
still establish that every admitted source produces valid declarations.
Nor does rejection erase earlier identifier/hash-cons increments: temporary
objects created while attempting a declaration remain part of the lifetime
counter account.

## Scalar and opaque equality has an additive retained cost

`cs_equ` distributes equality only after `dive_to_constructor` reaches a
constructor (`eval_match.ml:142–168`). For builtin integers, numeric ranges,
opaque Character/maps/images/private snapshots and function types, there is
no constructor of the operand type in the concrete Main frontier. Following
a saved variable definition, let or conditional preserves that type. The
attempt must therefore fail before a constructor callback can succeed, and
the retained result is ordinary equality of its two already evaluated
operands. Identical operands can instead simplify to True.

For these types the raw matcher clause can be sharpened from `3*x*y` to
`1+x+y`. For the weighted matcher clause, use `A_D(eq,x,y)` rather than
`K*x*y`. The general version keeps any possible marked equality entry;
with the actual unmarked builtin equality it is again `1+x+y`. No change
is made to Boolean, unit, reference, bounds-record or String-record equality,
where the constructor path can be reached.

This bounds the **retained result**. An unsuccessful descent can traverse
conditional branches and create discarded let/conditional reconstructions.
Those attempts still need accounting wherever they increment finite counters.

## First splitting counts a formula skeleton

Define `s(f)` on a case-free proposition by:

```text
s(predicate application) = s(True) = s(False) = 1
s(not a) = 1+s(a)
s(a connective b) = 1+s(a)+s(b)
s(if c then a else b) = 1+s(c)+s(a)+s(b)
s(let x=t in b) = 1+s(b)
s(quantifier variables, triggers, b) = 1+s(b).
```

In particular, an application's term arguments, a let's definition and
quantifier trigger terms do not enter `s`. The ordinary right splitter does
not recurse into those positions (`split_goal.ml:217,333–338,417–431`).
Stop handling can only suppress recursion. Its by/so special forms recurse
into subformulas already counted by the displayed connective clauses.

The four-mode induction in the [first-split
record](retained-producer-firstsplit.md#conditional-first-split-transfer)
therefore works unchanged with `s` in place of the whole occurrence count:

```text
q(f) <= 2*s(f)^2.
G(f) <= 6*s(f)^2*E1(f,D).
```

The per-output `3*E1` bound continues to count all term arguments, definitions
and triggers. They are excluded only from the **task multiplicity** factor,
not from retained term size or any actual representation domain. The input
`f` here is after matcher preprocessing; no claim that `s` is preserved by
that preprocessing is made. Its source-sensitive derivation must carry the
weighted matcher structure or bound the resulting skeleton separately.

For example, `forall x. P(large_term(x))` has `s=2` regardless of that term's
size. A conjunction of `k` relational atoms has `s=2*k-1`, independent of the
size of their arithmetic arguments. This is why a full JSON occurrence bound
should not be substituted blindly into the first-split task factor.

## A sharp task interface for straight conjunctions of checks

A useful narrower formula family is formed from check atoms by conjunction,
let, universal quantification, and implications `A -> F`. Its assumptions A
contain no `case_split` attribute or enabled by/so form. A check atom is either
an ordinary atomic relation left atomic by the final splitter, or an integral
range predicate with the already derived two-comparison definition. The
Boolean-equality wrapper around exactly that range predicate is also allowed.
This family does not include arbitrary Boolean-equality wrappers which can
expose a larger formula in the final splitter.

Check atoms and the connecting formula also have no `case_split` attribute
or enabled by/so form. For `k` check-atom occurrences, the whole selected transformation produces at
most `2*k` terminal goals. In the first splitter, the assumptions' returned
case flags remain false and their side lists remain empty, so they supply
singleton guards. Conjunction concatenates positive outputs; let/universal
wrappers map over them. A stop marker can retain a group of check atoms as
one output. The groups still contain each original positive check atom once.
Unfolding an integral range exposes two comparisons and introduces no other
marked call in its body. The conversion rewrite cannot introduce a new
formula into a scalar relational atom. The final splitter preserves guards
and splits each resulting conjunction group additively. Thus ordinary atoms
cost one leaf and range atoms at most two.

The fixture is intentionally at this **formula interface**, not a claim that
an arbitrary sequence of source assignments has already been shown to produce
it. With 64 range checks and 64 ordinary checks, `G<=192`. If the separate
label/registration argument gives `R<=128` and there are no warnings, the
proposed response projection bound is 977,300 bytes. Arithmetic term size
does not affect that task count. The offline fixture records this calculation
and contrasts it with an occurrence-only upper bound.

The unresolved numerical input is now precise: source-derived typed bodies
and instantiated contracts must determine the generated formula structure,
its logical skeleton, and each atom's marked-definition profile. The existing
source fixtures are not yet certified through this entire join. This record
does not claim that a complete new capacity predicate admits those fixtures.

An independent source review found no material issue in the additive retained
equality bound, formula-skeleton induction or restricted `2*k` interface.
It also checked the stated declaration-termination invariant for aliases.
The review corrected the splitter line anchors above; it ran no Why3 process.
