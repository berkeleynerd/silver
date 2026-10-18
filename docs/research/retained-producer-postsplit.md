# Marked unfolding and conversion-rewrite occurrence transfer

2026-10-18, research for
[#119](https://github.com/berkeleynerd/silver/issues/119). This closes the two
singleton transformations between the first right split and the final
[GNAT conjunction split](retained-producer-splitting.md), at the level of term
occurrences. It does not close the source-to-VC or first-split join, nor count
all temporary allocations, type substitutions, identifiers or attributes.
The [retained sources](../evidence/retained-producer-postsplit-20261018/identity.json)
are Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`; no tool is executed here.

## A lexical occurrence envelope

Count every occurrence of a term node, including terms in quantifier triggers,
and repeated occurrences of shared nodes. Patterns, type nodes, variable
declarations and attributes have separate representation budgets. Use
alpha-fresh binder identities, as the capture-avoiding Why3 term operations do.

For an environment `rho` assigning positive integer weights to free variable
identities, define `E0(t,rho)` structurally:

```text
E0(variable v,rho) = rho(v), defaulting to 1
E0(let v = a in b,rho)
  = 1 + E0(a,rho) + E0(b,rho[v := E0(a,rho)])
E0(other node with term children c_i,rho)
  = 1 + sum_i E0(c_i,rho).
```

For other binders, process their term children with each newly bound variable
weighted 1. Preserve outer weights. This counts a let definition at its own
position and allows its full weight again at each use. It does not erase the
let or claim that the actual transformation substitutes every variable.
Environments are lexical and nonrecursive: a let's definition is evaluated
before its variable enters the environment. Thus `E0` is a finite computable
function of a finite term tree. `occurrences(t) <= E0(t,empty)` follows directly.

## Conversion rewriting does not increase this envelope

`gnat_rewrite.ml:18–124` has four relevant behaviors:

1. Ordinary nodes recurse on their children without introducing extra term
   constructors. Binder opening/closing changes variable identities, not the
   occurrence structure.
2. A let recursively rewrites its definition, stores that definition under
   its fresh variable, rewrites the body, and retains the let.
3. A successful `to_array/first/last(of_array ...)` or integer conversion
   rewrite returns an existing child of its direct argument or a stored let
   definition. Attribute copying does not add term occurrences.
4. The inverse array rewrite can additionally look up a variable occurring
   as that child. Its replacement is still a term already charged to a
   lexical variable's weight.

Maintain the invariant that each stored rewritten definition has `E0` weight
at most the weight assigned to its variable. Every candidate returned by a
successful rewrite is a subtree of a charged argument/definition, or a
variable's charged definition, so its weighted cost is at most the input
application's cost. Failure to match merely takes the structural-recursion
case. Positivity makes all sums and environment substitutions monotone. The
let case extends the invariant with the just-checked definition. Induction
therefore gives:

```text
E0(rewrite_term(t),empty) <= E0(t,empty).
```

This is stronger than a raw occurrence comparison and does not assert that
the raw tree shrinks. For example, storing a large `of_array` term in a let
and applying `to_array` to that variable twice repeats its stored child twice
while retaining the original definition. `E0` charges those uses in advance.
The predicate tests and type-equality guards can prevent a rewrite and cannot
increase this upper bound.

## One-level marked unfolding

Let `D` be exactly the definition map built by `unfold_trans`: eligible logical
definitions and extracted axioms with `GP_Inline` and `GP_Pretty_Ada` labels.
Each entry contains formal variables `v_i` and a body `b`. The Boolean-axiom
case's generated `if b then True else False` is part of that body and must be
counted (`gnat_split_conj.ml:135–303`). Do not use an unwrapped axiom RHS for
that entry. All entries are fixed before unfolding the goal.

Define `E1(t,rho,D)` by the same structural/let clauses as `E0`, recursively
using `E1`. At an eligible application `f(a_1,...,a_k)`, first compute
`w_i = E1(a_i,rho,D)` and use

```text
E1(f(a_1,...,a_k),rho,D)
  = max(1 + sum_i w_i,
        E0(D[f].body, rho[D[f].formal_i := w_i])).
```

Formal bindings use the same ordered updates as the actual substitution map.
The body is evaluated with `E0`, so it cannot recursively inline another
definition. The first arm preserves an upper bound when the actual traversal
does not enter this expression. In particular, merely using a shrinking
definition's cost would fail for an application inside a skipped negation.

The actual `unfold_right 1` first unfolds eligible applications in original
actual arguments, substitutes those arguments into the selected definition,
then visits the replacement at depth zero (`:166–210`). Substitution is
capture-avoiding. `E0`'s weighted variables and retained let definitions charge
every substituted occurrence, including repeated actuals. Original nested
applications each get their own `E1` case; calls appearing solely inside a
replacement body do not. Contexts skipped by the actual traversal are bounded
by the original-constructor arms. Hence:

```text
E0(unfold_right(1,D,t),empty) <= E1(t,empty,D).
```

The bound remains sensitive to formal-use multiplicity and lexical sharing.
It is not a constant multiplier per goal. For `f(x) = x /\ x`, the original
`f(f(a))` has three term occurrences, and one-level marked unfolding produces
seven: both original calls expand once. `E1` gives seven for this example.

## Joined terminal-goal bound and remaining source dependency

Let `g_i` be the goals emitted by the first `split_goal_right`, and let `D_i`
be each task's exact eligible definition map. Combine the two inequalities
with the final splitter's `L` bound:

```text
G <= sum_i L(rewrite(unfold(g_i)))
  <= sum_i occurrences(rewrite(unfold(g_i)))
  <= sum_i E1(g_i,empty,D_i).
```

This supplies the backend structural input needed by the
[response-schema formula](retained-producer-response.md). The next missing
join is a source-derived account of `g_i` and `D_i` through JSON translation,
typing, SP/WP generation, type-invariant/match preprocessing and the first
right split. Running the compiler and measuring these objects cannot decide
membership. A future source counter must soundly bound or reconstruct their
shapes before admission. This component proves neither that join nor whole
Why3 process capacity.

The [offline arithmetic fixtures](../evidence/retained-producer-postsplit-20261018/check.py)
check the retained identities and the two illustrative occurrence calculations;
they are not a formal verification of Why3 or an execution of its transforms.
