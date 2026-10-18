# Selected Why3 preparation: conditional inlining transfer

2026-10-18, Linux x86_64, bounded research for
[#119](https://github.com/berkeleynerd/silver/issues/119), based on
`ee3ea76e280735657404d82a96273d1dd998b7c1`.

The next closed interface is the **`inline_trivial` term kernel**, with
source-derived bounds on its output occurrence size, recursive callback
entries and fresh variable identifiers. Its declaration fold also cannot
increase task-chain length and makes at most one real declaration-tag
increment per mapped logical/proposition declaration. These are conditional
transfers, **not instantiated capacity bounds for the five fixed inputs**.
The missing input is the fully opened term dimension at each driver's
inlining entry, after the preparation stages listed below. The retained
registration counts do not supply it.

The [callable packet](../evidence/retained-why-preparation-bound-20261018/README.md)
pins fourteen complete files from Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`. Every file also joins the accepted
complete-prefix archive. The already downloaded complete archive was checked
against its accepted SHA-256; no source fetch or target execution was needed.
The existing relevant-source/runtime premise is unchanged. The arithmetic
checker does not prove OCaml source semantics or establish historical
binary/source identity.

## The exact selected sequence and entry interface

The accepted [driver envelope](retained-producer-driver-envelope.md) supplies
153 registered tasks, 459 task/driver pairs and 6,120 **outer directives**.
There is one `inline_trivial` directive in each of the three lists, hence at
most 459 entries to that directive over five separate processes. The lists,
in driver import order, are:

| Driver | Ordered transformations |
| --- | --- |
| cvc5 | `counterexamples_dependent_intros`, `inline_trivial`, `eliminate_builtin`, `remove_unused`, `detect_polymorphism`, `eliminate_definition_conditionally`, `eliminate_inductive`, `eliminate_gnatprove_guard_epsilon`, `eliminate_epsilon`, `eliminate_literal`, `simplify_formula`, `eliminate_projections_sums`, `discriminate_if_poly`, `eliminate_algebraic_if_poly`, `encoding_smt_if_poly` |
| z3 | `inline_trivial`, `eliminate_builtin`, `remove_unused`, `detect_polymorphism`, `eliminate_inductive`, `eliminate_algebraic_if_poly`, `eliminate_literal`, `eliminate_gnatprove_guard_epsilon`, `eliminate_epsilon`, `introduce_premises`, `simplify_formula`, `discriminate_if_poly`, `encoding_smt_if_poly` |
| altergo | `counterexamples_dependent_intros`, `monomorphise_goal`, `inline_trivial`, `eliminate_builtin`, `remove_unused`, `eliminate_recursion`, `eliminate_inductive`, `eliminate_epsilon`, `eliminate_algebraic`, `eliminate_literal`, `split_premise_right`, `simplify_formula` |

`Driver.prepare_task` first calls `update_task`, then folds this list
(`driver.ml:330–393`). `update_task` can export requested theories and clone
metas; `Task.use_export` recursively flattens theory declarations, and
`Theory.clone_meta` can instantiate meta-argument types
(`task.ml:183–196`, `theory.ml:999–1016`). Consequently the original task's
context length is not automatically the entry length for inlining.

For counterexamples off, `counterexamples_dependent_intros` selects
`Introduction.remove_unused_from_context`, not dequantification
(`prepare_for_counterexmp.ml:15–31`). The actual entry interfaces are thus:

- z3: output of `update_task`;
- cvc5: output of `update_task` followed by unused-CE removal;
- altergo: that same prefix followed by `monomorphise_goal`.

The [initial-split packet](retained-producer-fixed-tail.md) stops before any
of these stages. Its task-chain lengths, allocation budget and semantic-count
maximum remain valid for its own endpoint. The earlier
[formula skeleton](retained-producer-formula-refinements.md) and
[fixed-check spines](retained-producer-fixed-check-spines.md) bound splitting
multiplicity; they deliberately omit term arguments and triggers from that
factor. Neither those results nor the finite directive lists instantiate
the dimensions below.

## What the kernel actually does

`inlining.ml:36–40` defines `t_replace_all env t` by first applying itself to
the children through `Term.t_map`, then, only at an application, calling
`t_unfold` on the already transformed arguments. If the symbol is absent
from `env`, it rebuilds the application. On a hit it relocates the saved
definition body and applies type/term substitution (`:22–31`). **The returned
replacement is not recursively fed back to `t_replace_all`.** Thus recursion
follows the opened input tree, not an unbounded rewrite-until-stable loop.

`Trans.fold` visits task nodes in declaration order (`trans.ml:76–101`).
`Inlining.fold` transforms a declaration using the preceding environment;
only afterwards may it add a singleton, nonrecursive, permitted definition
to the environment (`inlining.ml:57–84`). All roots of a mutual declaration
see the same preceding environment. Stored bodies have therefore already
undergone that preceding environment's inlining. The kernel bound does not
need to assume that a replacement has no applications.

The actual `notdef` accepts variables, constants, Boolean constants and
certain applications, and an `inline:trivial` attribute overrides the shape
test (`:119–145`). Closed arguments may be arbitrarily large within their
separate input domain. Neither the name “trivial” nor absence of recursive
definitions justifies a constant expansion factor.

## Measures and a finite size recurrence

Use a well-formed immutable Why3 term, with valid binding/substitution
metadata, interpreted with its delayed substitutions fully materialized and
binders freshly opened. Count occurrences, including trigger terms and each
repeated use of a shared subtree; do not count only physical DAG vertices.
Alpha-renaming does not change these dimensions:

```text
n(t) = term-node occurrences
b(t) = bound-variable slots (each quantifier list, let/epsilon binder,
       and each branch pattern's distinct pat_vars)
p(t) = pattern-node occurrences
m(t) = n(t) + b(t) + p(t)
a(t) = application-node occurrences.
```

Types, names, attribute sets, lazy free-variable counts and hidden
substitution storage are outside `m`. A finite acyclic constructor graph
with well-formed substitution links has a finite opened tree, although its
size may be much larger than the stored graph. Providing a bound on that
tree is an explicit precondition of this transfer.

For every possible environment-hit body `e`, supply upper bounds `N`, `B`,
`M`, `F` on respectively `n(e)`, `b(e)`, `m(e)` and its distinct free term
variables; `M >= 1`. These are separate coordinate bounds, so their maxima
need not be attained by the same body. An empty environment is distinguished
by `N=0` and causes no hits. Let `H=a(t)` for a nonempty environment and zero
otherwise; this conservatively counts every input application as a hit.

Substituting argument trees of masses `u_i` into a body of mass `v` gives
mass at most `v * max(1, max_i u_i)`: each formal-variable occurrence is
replaced once, and all remaining nodes/binder slots/pattern nodes retain
their weight. Type instantiation and relocation preserve this type-erased
shape. A structural induction on the opened input tree therefore gives

```text
m(t_replace_all env t) <= m(t) * M^H.
```

At an environment-hit application charge one factor `M`; at a non-hit or
other node add the children's sizes and the node's own weight. Since
`M >= 1`, the product charged across all child applications dominates each
child's product. This explains the exponent; it is not an empirical or
arbitrary transform multiplier. Empty quantifier elimination can only reduce
the result. The same argument bounds semantic intermediate terms by this
output majorant or the corresponding input/body majorant; it does not bound
their hidden stored representations.

`inline_context(batches)` composes that recurrence in task order. Each batch
contains bounds for the input roots mapped by `Decl.decl_map`. For `Dlogic`
these are opened definition bodies and formal arities; for `Dind` and `Dprop`
they are clause/proposition formulas. After a singleton logic batch it
conservatively admits that body to the bounding environment even if the real
eligibility predicate rejects it. Its next environment bounds can use the
body mass for `N`/`M`, mass minus one for `B`, and the smaller of arity and
mass for `F`. Adding extra candidates weakens a bound without excluding an
actual inlining path. No definition becomes available within its own batch.

For a logic definition of arity `k`, its stored axiom has at most
`body_mass + 2 + 2*k + (1 if k>0 else 0)` mass. `make_ls_defn` constructs a
head application, equality/iff, `k` head variable occurrences, `k` binder
slots and, if needed, one universal quantifier (`decl.ml:41–58`). This is
separate from the environment's opened body mass.
This uses the ordinary constructor invariant for `ls_defn`, not an arbitrary
externally fabricated tuple.

## Recursive entries and meaningful fresh identifiers

For one kernel call, the following natural-number upper bounds hold:

| Reached operation | Bound |
| --- | ---: |
| Recursive `t_replace_all` entries | `n(t)` |
| `t_unfold` entries, hits and misses | `a(t)` |
| Recursive `relocate` entries | `H*N` |
| Term entries in the hit body's `t_gen_map` during type substitution | `H*N` |
| Recursive `t_subst_unsafe` entries in the **final substitution after type mapping** | `H*N` |
| Fresh variable identifiers registered inside the kernel | `b(t) + H*(2*B + F)` |

The fresh-identifier charge has three specific origins:

1. `t_map` opens input binders, charging `b(t)` registrations. Opening a let,
   epsilon, quantifier or pattern creates one variable per corresponding
   bound slot (`term.ml:799–831,1247–1277`). Its substitutions introduce no
   other fresh variables (`:739–778`).
2. Every hit's `relocate` recursively opens the saved body, charging at most
   `B` registrations. The initial `t_attr_set` creates a new record at every
   recursive call (`inlining.ml:22–23`, `term.ml:646`). Consequently the
   physical-equality fast paths in `t_map` cannot retain an old binder after
   visiting that binder's children: it closes the processed children with
   empty `bv_subst` (`term.ml:785–795,1247–1277`). The relocated body is fully
   opened/reclosed, with no delayed substitution maps. Its node and binder
   counts are bounded by `N` and `B`.
3. `t_subst_types` first considers each free variable, then maps the body.
   `gen_fresh_vsymbol` creates a fresh symbol only if its type changes.
   There are at most `F` free-variable keys and `B` bound slots. The
   `gen_bnd_rename` loop over delayed-substitution keys is empty here because
   relocation has reclosed every binder (`term.ml:1083–1173`). This charges
   another `B+F` identifiers. Type matching/instantiation constructs no new
   named type symbols (`ty.ml:126–143,234–254`).

`create_vsymbol` performs one `Ident.id_register`; `id_clone` alone creates
only a pre-identifier (`term.ml:36–39`, `ident.ml:187–213`). Hence the last
row counts meaningful identifier-counter increments, not just retained
variables. The final `t_subst_unsafe` creates no identifiers and never
recursively traverses the replacement at a variable leaf. Starting from the
reclosed body, it can visit at most `N` term nodes: at a binder it updates
the initially empty substitution map and stops descending that binder.

This last bound is specifically for the final substitution in `t_ty_subst`.
It **does not cover all recursive substitution work during binder opening**.
An original binding can contain saved substitution values; opening it can
visit those representations even when their contents disappear from the
eventual opened tree. The opened-tree dimensions alone are not a bound on
all such hidden work or its semantic occurrence-count additions/products.
The theorem keeps that obligation explicit instead of reusing the earlier
maximum count 47 outside its captured interval.

## Declaration and cache event bounds, without backing closure

For an input chain of `D` task nodes, `Trans.fold` rewinds each uncached node
once. It performs at most `D` callback entries, `D` cache lookups and `D`
cache sets in that fold instance (`trans.ml:76–101`). A cached prefix stores
the result of the same immutable input prefix; assuming the existing
noncolliding tag invariant, using it skips work. The no-cache calculation
therefore bounds one entry independently of collection/hit choices. Across
calls, add these event bounds; do not substitute a distinct-key count.

`Inlining.fold` adds either zero or one task declaration per input task node.
`Task.add_tdecl` does not recursively export a `Use`, unlike `use_export`.
Thus the output chain length is at most `D`. Each mapped `Dlogic`, `Dind` or
`Dprop` calls its declaration constructor once; the remaining declaration
kinds are reused (`decl.ml:621–634`). Those constructors reach `mk_decl` at
most once (`:526–535,569–606`), so real **`Decl.Hsdecl`** increments are at
most the number of these mapped declarations, including discarded results.
This counter's `tag` stores the value in `d_tag`; it is not the irrelevant
private counter addressed by the
[introduction result](retained-why-introduction-counter.md).

These are counter **increments**, not a complete no-wrap claim. On the
retained 64-bit OCaml runtime, a sufficient eventual join is the initial
nonnegative counter plus all subsequent increments at most `2^62-1`, with
every other caller included. The kernel's variable-ID charge and this
declaration-tag charge supply only their respective summands.

The bound does not include all identifier creation outside the term kernel.
`open_ls_defn`, logic termination checking and inductive validation also open
binders (`decl.ml:60–74,177–198,273–281,569–592`). Their allocations, semantic
counts and source work remain required, even when a declaration is later
inlined away. Task/theory/type hashcons increments also remain separate.

`Weakhtbl.Make` implements its caches with `Ephemeron.K1.Make`
(`weakhtbl.ml:65–75`). Set-entry counts alone do not bound backing arrays,
collision-chain work, weak-key clearing/reinsertion, growth arithmetic or
the other `Trans.bind`/meta caches. No initial capacity such as 63 is used
as a maximum, and no no-collection theorem is extended past registration.

## Exact remaining input and completion boundary

To instantiate this transfer, a next composition must supply, for each fixed
registered task and driver, the post-prefix chain and its ordered root
dimensions `(n,b,p,a)` plus logic arities. The derivation must cover the
actual `update_task` theory/meta additions, cvc5/altergo's unused-CE removal
and altergo's monomorphisation. It must also bound stored substitution
representations/types and the non-kernel declaration validators, then join
all meaningful counters and cache backing across the process lifetime.

These inputs are not present in the accepted registration snapshot. A
fresh capture would have to target this specific post-prefix interface and
its hidden representations, account for every candidate pair and its shared
lifetime, and retain source correspondence. Stopping at the first selected
pair, or remeasuring initial registration, would not supply that join. No
such capture was performed here.

The callable returns the conditional transfer and synthetic fixtures with
`fixed_input_prepared_dimensions_instantiated=false`. It leaves complete
preparation, printer, shared-lifetime and whole-pipeline capacity false.
No admission/configuration/tool change or aggregate physical-memory gate is
introduced. The scoped result is ready for parent review; the next technical
dependency is the post-prefix input derivation above, not a new inventory of
every later transform.

Selected worker model/effort: GPT-6 Astra, Extra High. Runtime confirmation
and token/cost measurements are unavailable. The packet's round record
reports measured elapsed time and offline checks; no native build, prover,
proof, audit, full suite, GitHub write or CLI memory update occurred.
