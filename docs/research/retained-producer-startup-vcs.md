# Six fixed library-startup formulas

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The [configured import closure](retained-producer-import-context.md) reaches
two set-type witness checks, one character-type existence check and three
program-value equality refinements. Their retained formula and intermediate
code shapes have the following bounds. No compiler, Why3, solver or Lean ran.
The [offline evidence](../evidence/retained-producer-startup-vcs-20261018/README.md)
reuses the complete, pinned sources already archived for the import, type,
typing and first-split analyses.

| Construction | Copies | Pre-reflow kode nodes | Attached term occurrences | Final lexical formula envelope |
| --- | ---: | ---: | ---: | ---: |
| `SetAppInt.Iter.t`, `SetAppString.Iter.t` witness | 2 | 25 each | 42 each | 41 each |
| Set `eq` value refinement | 3 | 7 each | 17 each | 27 each |
| `string.Char.char` existence | 1 | 0 | 5 | 5 |
| Sum per backend process | 6 | 71 | 140 | 168 |

Here an attached-term occurrence includes each Klet definition and predicate,
each Kval/Kcut/Kstop predicate, and the character formula outside kode.
The final measure is the lexical `E0` envelope used in the
[SP/WP analysis](retained-producer-spwp.md): definitions are charged at their
own position and again at every use. Thus the final numbers also bound ordinary
tree occurrences. They are sufficient bounds, not measured exact output sizes.
Trivial checks may be omitted by `add_vc_decl`; all six constructions are charged.
These are imported context formulas, not extra registered `GP_Check` leaves.

## Concrete typed shapes

`Typing.type_wit` changes each record witness into the ordered field tuple
(`typing.ml:1260–1323`). Both witnesses contain exactly two calls to
`SetApp.empty ()`. They do not construct an `Iter.t` value. Each unit argument
and each call result has at most one proxy let; the tuple has a two-variable
constructor contract (`dexpr.ml:1405–1450`, `expr.ml:902–951`,
`ity.ml:1491–1501`). Optional ghost wrappers add no kode.

Write `p` for `to_fset`, `card` for `Fset.cardinal`, and `empty` for the
logical empty set. The applied empty-call postcondition is

```text
P(v) = (p(v) = empty) /\ (card(p(v)) = 0),        E0(P) = 10.
Q(a,b) = Fset.subset(p(b), p(a)),                E0(Q) = 5.
```

Contract application replaces formal variables by variables, preserving
these shapes. `term_of_post` cannot extract a direct result equality from
`p(v) = empty`, so this call takes Kval. It can add one trace Klet.
The tuple call extracts its three-node constructor term and has no trace
branch because it is a fully applied constructor of the nonsolid tuple type.
The unit constructor likewise has no trace branch (`vc.ml:676–718`).

`Vc.vc` makes a tuple pattern, an assertion of Q and a final unit expression
(`vc.ml:1740–1784`). Each complete witness therefore has this upper skeleton:

```text
empty-call = seq(unit-let, seq(val P, trace-let))             # 5 kode nodes
witness    = seq(empty-call, seq(empty-call, tuple-let))     # 13
assertion  = seq(seq(cut Q, val True), unit-let)              # 5
match      = seq(witness, SP(case tuple [assertion]))         # 21
function   = seq(val True, seq(match, stop True))             # 25
```

The three cloned values have the same source and target contract:
`result <-> x = y`. The targets are `int.Int.(=)` and
`string.OCaml.(=)`; both source parameter types are replaced by the target's
ordinary scalar/opaque type (`set.mlw:607,663,781`, `int.mlw:16`,
`string.mlw:487–488`). `clone_pdecl` constructs a single call and one Cfun
with that postcondition (`pmodule.ml:1382–1455`). Its Klet definition is
`if x = y then True else False`, of cost six, its residual predicate is True,
and its checked post has cost seven. Allowing the trace gives seven kode nodes.

The remaining formula is simply `exists contents:string. length(contents)=1`,
of cost five. It does not quantify a `char` value.

## No recursive invariant or effect expansion

The set snapshots in the witness are private, nullary records. Their symbols
are nonfragile with empty argument/region flag lists, hence solid
(`ity.ml:690–735`, `typeinv.ml:23–26`). Integer, string, Boolean and unit
are solid builtins. A pair of set snapshots is not a solid *symbol*, but its
two component caps are V, so `mkC` returns V. This distinction avoids assuming
that all tuple instantiations satisfy the symbol-level solid test.

Consequently inspection emits no invariant commitments, injection creates
no pins or temporary invariant fields, and no Iter.t invariant is recursively
injected. There are no writes, oldies, variants, recursive calls or exceptions
in these six constructions. Their exception-counter increments and
type-invariant pin-counter increments are both zero. Reflow adds no terms;
the general bound gives at most 223 retained kode nodes across the five
kode-producing checks after reflow.

Before logical alpha-renaming by formula operations, VCgen directly creates
at most seven program variables per witness (two pattern fields, the assertion
dummy, the function result, the tuple scrutinee proxy and two call traces),
and two per refinement (result and trace): twenty total. The four proxies
already present in each typed witness and the two cloned refinement arguments
are earlier typing work. Logical variable clones made while opening binders
are **not** included in twenty.

## Why the final envelopes are small

For a witness, the empty precondition, unit-result operations and empty
function postcondition simplify away. The SP switch encloses a single tuple
branch with one cut; it adds no alternative path or duplicated continuation.
A conservative remaining shape is two nested `forall v. P(v) -> ...`
wrappers, two retained trace lets, and the tuple case on Q. Charge the tuple
definition once more even when the one-use substitution keeps an unused trace
binding. The cost is

```text
2*(1 + 1 + 10) + 2*(1 + 1) + (1 + 3) + (1 + 3 + 5) = 41.
```

For a refinement, keep the result let of cost-six Boolean definition, the
trace let that reads it, and the seven-node postcondition. Substituting its
weight six at both result uses gives 26; the argument quantifier adds one.
The character existence formula stays at five. These envelopes also allow
the branches that omit trace bindings or simplify true formulas earlier.

Type-invariant injection only rebuilds these shapes. Match evaluation cannot
increase the envelopes here: the sole tuple case has one irrefutable branch;
its two field substitutions are already paid by lexical charging. Set
projections have private nondestructible inputs, and cardinal/length have
opaque inputs, so their definitions are not inlined. Equality operands are
scalar/opaque, except for the Boolean conditional whose branches are the two
nullary Boolean constructors. Comparing that conditional with True contracts
its cost. There are no quantified tuple/reference values to destruct and no
range-constant projection to expand (`eval_match.ml:48–211`).

## Boundary still open

This closes the six checks' retained kode/formula shape, directly created
VCgen program variables and two specific counter families. It does **not**
turn retained nodes into lifetime allocation counts. Typing and cloning the
whole fixed context also constructs declarations, callable lemmas, contracts,
types and namespaces; opening and simplifying these small formulas still
creates temporary logical identifiers and attribute records. Hash-cons table
misses and weak-cache recomputation need their own event account. Those costs,
the source-dependent Main construction, solver domains and final reports
remain part of #119. No aggregate RAM admission limit is introduced.
