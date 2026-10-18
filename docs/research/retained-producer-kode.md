# Typed expression to retained intermediate code

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119) research.
This record joins typed WhyML expressions to the
[SP/WP transfer](retained-producer-spwp.md). It also establishes that `reflow`
does not introduce an exponential code-copy multiplier. The source is
`vc.ml` in the [retained Main-type archive](../evidence/retained-producer-main-types-20261018/identity.json).
No compiler, solver or Lean execution is involved. The offline source identity
and arithmetic checks are retained [here](../evidence/retained-producer-kode-20261018/check.py).

The input remains **typed** expressions, with instantiated contracts and
effects. The source-to-Ptree/typing transfer must still produce these inputs;
this is not a claim that that earlier join is finished.

## Reflow preserves attached terms without copying code

Count retained `kode` constructor occurrences as a tree, including occurrences
inside `Kaxiom`, and call the input count `B`. Let `S` count `Kseq` nodes and
`T` count WP/SP tag nodes. Count attached term occurrences separately, so a
`Klet`'s definition and predicate are both charged. `vc.ml:1065–1173` gives

```text
B_reflow <= B + 2*S + T + 2 <= 3*B + 2.
```

The final two nodes allow the initial SP wrapper and its Out marker. With
classical WP initially selected, these two nodes are unnecessary. `reflow`
creates no program variable, term, contract or outcome label. In particular,
the multiset of attached terms in its result is a submultiset of the input
multiset. Source identifiers already present in attributes remain metadata.

The reason continuations are not copied is the exact meaning of `mark`'s
outcome map. A true entry identifies one syntactic exit at which code may be
pushed. A false entry identifies multiple exits or an explicit VC-generation
barrier. Disjoint branch maps are joined; a repeated key becomes false.
Sequence removes its handled key before joining the continuation's exits.
Dead continuations are removed. A `Kaxiom` has one external normal exit;
its internal code is marked separately. A WP/SP switch marks every exported
outcome false and `push` clears its incoming continuation map at that barrier.

Thus a continuation placed in `push`'s map can reach at most one eligible
insertion site in the code receiving it. At an ordinary sequence, its handled
key is removed when visiting the left child. At branches, the singleton-exit
invariant prevents the same pending continuation from being inserted in two
children. Processing the continuation itself first does not change that
invariant: its eventual exits are exactly the exits already propagated by
`mark`. `Kaxiom` bodies likewise receive an empty incoming map. The assertion
is about **retained occurrences**, not the number of intermediate map lookups
or traversals.

For the node count, `mark` adds at most one Push tag per sequence and one Out
tag per WP/SP switch. `push` removes each Push tag and its enclosing sequence.
It adds at most one sequence at the unique insertion site. An open exceptional
continuation can additionally require the outer `Kseq(...,i,Kcont 0)` pair.
Even charging all those additions without credit for removed `Kcont` nodes
gives at most one net extra node per marked Push sequence. Together with
`mark` this gives the displayed `2*S` allowance. Off/Out/WP/SP nodes are only
retained, removed or traversed; they introduce no further pair of children.

## A local counter for typed expressions

Use the [ordinary Main type frontier](retained-producer-main-types.md): all
types are solid, fields of mutable references have pure snapshot types,
generated loop tests are True, and native WhyML variant lists are empty.
Main's `vc:divergent` sets `env.divergent=true`; nested generated functions
inherit that environment. Thus type-invariant wrappers and the missing-diverges
check add no code in the reached fragment. This does not erase source-emitted
loop assertions, contracts or internal function bodies.

Let `B(e)` bound the kode generated for typed expression `e`, before `reflow`.
Every row below excludes the optional final WP/SP tag on that expression;
add one when either attribute is present (`:1017–1021`). Child `B` values
already include their own tags. A variable operand handled directly by
`var_or_proxy` needs no child code; charging its `B=1` is a harmless overcount.
Keep exact nonnegative counts:

- `h`: exceptional-post/handler entries actually handled by the local branch;
- `o`: old-value bindings in the local contract;
- `v`: one if the local effect requires a havoc wrapper, otherwise zero;
- `p`: one if the precondition list is nonempty, otherwise zero;
- `F(c,e)`: the `k_fun` bound for the particular internal function below.

| Typed form / reached path | Sufficient retained kode count |
| --- | --- |
| `Evar`, `Econst`, `Epure` | `1` |
| `Eassign` | `3` |
| `Elet(LDvar(_,e0),e1)` | `1+B(e0)+B(e1)` |
| `Eif(e0,e1,e2)` | `5+B(e0)+B(e1)+B(e2)` |
| `Eraise(_,e0)` | `2+B(e0)` |
| Assert or Check | `3` |
| Assume | `1` |
| `Eabsurd` | `1` |
| `Eghost e0`, `Eexn(_,e0)` | `B(e0)` |
| `Ewhile(True,invariants,[],body)` | `6+2*v+B(body)` |
| Try/match with no ordinary branches, at most one carried variable per handler | `B(scrutinee)+sum B(handler)+h` |
| The same with one ordinary variable/wildcard branch | `B(scrutinee)+B(branch)+sum B(handler)+h+1` |
| Ordinary `Eexec` other than Cfun | `3+6*h+2*o+2*v+2*p` |
| Ordinary `Eexec(Cfun body,cty)` | `3+6*h+2*o+2*v+2*p+1+F(cty,body)` |
| White-box zero-argument Cfun execution | `B(body)+2+4*h+2*o+2*p` |

The three-node allowance per ordinary postcondition includes an optional trace
binding. Every exceptional alternative adds that allowance plus Kpar, Kseq and
Kcont. `k_havoc` and each `bind_oldies` entry add two nodes. A nonempty execution
precondition adds Kseq/Kcut or Kpar/Kstop. These are exactly the branches at
`:623–748`, including Cfun's separately checked body; no user-subprogram
exclusion is applied to this internal machinery.

The if bound covers `term_of_kode`'s successful pure-Boolean shortcut: its
retained child code is no larger than the original child code, while Kseq,
Ktag, Kif and Klet add four nodes. A nonvariable condition adds one sequence
and its own code. Term extraction can enlarge the **attached term**, handled
separately below; it must not be inferred from this node bound alone.

For a single nonrecursive `Elet(LDsym(s,c),e1)` (`:776–834`), a safe local
bound is

```text
B(e1) + a*(5+2*o+2*v) + 2*r
      + f*(1+2*v+F(c.cty,c.body)),
```

where `a=1` conservatively allows a nontrivial generated axiom, `r=1` when
the symbol has an RLpv logical variable, and `f=1` when its body is Cfun.
The axiom count is its outer Kseq/Kaxiom, inner Kseq/Kval/Kstop, old bindings
and optional havoc. An RLnone symbol requires no axiom. A simplified true
axiom can be dropped. Recursive LDrec blocks need a separate row; none is
introduced by the reviewed converter's zero-argument Abstract_expr/Any_expr
paths. Imported callable declarations still have their separate context cost.

For `k_fun` (`:1023–1052`), let `h` be its locally completed exceptional
postconditions, `o` the total cardinality of its two old-value maps, and
`t` the possible outer WP/SP attribute. Then

```text
F(cty,body) <= B(body)+4+2*h+2*o+t.
```

Normal and exceptional checks each add Kseq/Kstop. The precondition always
adds Kseq/Kval, even for an empty list. No body is inlined at every call:
each generated Cfun body is visited at its own reached `k_fun` occurrence,
while a call uses its instantiated contract. Nested generated bodies must
nevertheless remain in the source-derived input tree.

The same traversal bounds the fresh program-variable keys needed by SP/WP.
Start with all program variables in the typed expressions/contracts, then add
one for every reached nonvariable `var_or_proxy` operand; one result for each
normal/exceptional `k_fun` postcondition; one optional trace result per
normal/exceptional Eexec postcondition; one result per white-box lost exception;
and one unit placeholder per argument-free handler. Local RLlemma processing
adds one result, and an RLpv Cfun can add one in `cty_enrich_post`. These are
the reached `create_pvsymbol` families in `vc.ml:51–93,395–423,598–1052`.
Variant oldification and recursive-call old-value renewal add no variables
when variant lists and the recursive-function map are empty. Existing contract
oldies remain included in the initial set. Logical variable clones in SP/WP
are a different identifier count and do not enlarge these program-variable keys.

The fresh outcome counter increments once per try handler, white-box lost
exception and completed `k_fun` exceptional postcondition. It does not count
every path through the code. Sum these occurrences over the actual traversal
to bound its increments; include the initial counter value at the process
boundary rather than assuming every nested function starts at zero.

## Attached terms and the next join

An occurrence counter must carry the actual attached terms and not replace
them by `B`. The needed transfers are explicit:

- `wp_of_pre`, `sp_of_pre`, `wp_of_post`, `sp_of_post` and invariant helpers
  conjoin their input lists. Opening a regular postcondition replaces its
  result variable by another variable. Explanation/trace attributes add no
  term nodes. For a list with costs `c_i`, `1+sum(c_i+1)` bounds the result,
  including an empty list. Exact conjunction counts are preferable.
- For an Eexec contract, `term_of_post` may separate a definition from the
  conjunctive postcondition. The complete input postcondition and the selected
  result definition must be charged at their respective Klet positions.
  Establishing a sharp bound for that extraction from source remains part
  of the typed-contract transfer.
- An RLpv Cfun's `cty_enrich_post` can use `term_of_expr` or `post_of_expr`
  on its body and append the result to its contract (`:395–423`). Its input
  contract alone therefore does not bound the resulting axiom. Carry that
  generated term through the same expression/lexical-definition transfer;
  this additional formula path remains an explicit earlier-join obligation.
- `term_of_kode` walks a linear stack and unwinds its saved definitions into
  both the resulting value and, if needed, its predicate (`:511–547`). Apply
  the lexical `Let(a,b)` bound from the SP/WP record once per such saved
  definition and **separately for those two outputs**. A declaration without
  a definition can be passed only when its variable is unused. A failed
  extraction retains the original conditional code; partial work concerns
  finite creation counters, not a second retained formula.
- A loop emits initialization, assumed-preservation and checked-preservation
  copies of its invariant list. With no native variants, the annotated true
  decrease formula can still add a true node and conjunction to the checked
  list; allow two nodes instead of silently discarding it.
- Predicate-valued `Epure` converts to `if predicate then True else False`,
  adding at most three term nodes. Other Epure values are passed through.

The resulting structured kode and attached terms can feed the SP/WP recurrence,
then the matcher and first-split transfers. `reflow` adds no extra term factor.
To complete the source join, the GNAT JSON conversion and typing passes must
account for the typed occurrences, contract instantiations, result/proxy/old
variables and outcome keys used above. The converter specifically duplicates
`code_before` in a Loop, evaluates each variant expression twice, and creates
a zero-argument function for Abstract_expr (`gnat_ast_to_ptree.ml:786–905`).
Those are concrete source-shape obligations; a universal claim of one
converted occurrence per JSON occurrence would be false.

There is no requirement to turn the sum of independent linked allocations
into an aggregate RAM admission bound. Remaining representation joins concern
actual object lengths, collection indexes/cardinalities, and finite counters
such as identifier/hash-cons creation counters. Temporary discarded branches
matter when they increment such a counter. Physical availability remains the
separate environmental premise. The marked-definition E1 composition, fixed
library processes and essential solver representations remain open.
