# Conditional operational demand of the retained inlining invocation

2026-10-18, Linux x86_64, research for
[#119](https://github.com/berkeleynerd/silver/issues/119). This packet supplies
**conditional candidate arithmetic and pure shared-state transfers**. It does
**not** establish the local structural/registration transfer for the native
invocation: the envelope and semantic correspondence of old declarations
returned by `Decl.Hsdecl` are missing. The default result leaves
`actual_representative_envelope` null and
`local_structural_and_registration_transfer_established` false.

This corrects the overclaim in `b68756eea4`, identified by the
[independent review](https://github.com/berkeleynerd/silver/blob/78db8ca58e6fe68d28cf5f350d859d03e8f1796b/docs/reviews/review-why-inline-operations-b68756eea4.md)
and [#133](https://github.com/berkeleynerd/silver/issues/133). The earlier
1,145-identifier, 36-key and 21,483-stored-occurrence numbers survive as
**conditional arithmetic**, not established ceilings for the actual transform.
The accepted [semantic refinement](retained-why-inline-refinement.md) remains
an input model; attaching its alternatives to execution after representative
selection also requires the correspondence premise described below.

The scope is the one retained first Input_Is_Valid/cvc5 `inline_trivial` entry.
The [offline packet](../evidence/retained-why-inline-operations-20261018/README.md)
reuses the successful capture and predecessor evidence without another native
run. It pins complete relevant Why3 sources at
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml sources at
`8eb41f72ded84df884c3671734c947f612091f84`. Relevant-source/runtime,
well-formedness and noncolliding-identifier premises remain applicable. The
source argument is inspected, not machine-checked OCaml semantics. Physical
resources remain external assumptions; no aggregate RAM gate is introduced.

## Why the shared table supplies a downstream representation input

`decl_map` reconstructs logic/proposition declarations; `mk_decl` hashconses
all except goals (`decl.ml:350–419,526–535,621–634`). Declaration equality uses
`t_equal_strict`, which follows delayed frames reached from variable leaves
and ignores unused saved-map keys (`term.ml:266–281,325–379`). Strict hashing
uses the same frame interpretation (`:441–510`). `Hashcons.Make.hashcons`
returns `WH.merge`'s result (`hashcons.ml:41–45`); a successful weak-table
comparison returns the old live object (`weak.ml:272–311`).

That old declaration enters used-symbol collection, definition opening,
eligibility/environment storage and possibly `Task.add_decl`
(`inlining.ml:64–80`). `known_add_decl` then traverses it again, including
stored substitution values and match-check opening
(`decl.ml:518–524,699–709,741–748,780–826`; `task.ml:145–165`). A bound on the
new candidate's saved maps therefore does not bound these downstream maps.
Accounting only for collision comparison cost misses this use of the old object.

The regression specializes `bv_subst_unsafe` (`term.ml:764–778`) to variable
renamings of `forall z. P(x0)`, with `z` distinct from every `xi`. Repeated
`xi -> x(i+1)` substitutions give, after `n` steps:

```text
bv_vars  = { xn : 1 }
bv_subst = { x0 -> xn, ..., x(n-1) -> xn }
raw body = P(x0)
```

Each value is a leaf. Closing `xn` as an outer formal gives the same opened
alpha form and strict hash/equality as a clean representation, with the same
symbols, types, empty attributes and locations. The Python specialization
selects that old representation on the matching key. Opening its outer formal
renames the `n` saved values and adds one more key; a downstream stored-value
fold visits all `n+1` entries. Checks at `n=37` and `n=128` exceed the former
36-key ceiling. This is a source-valid parametric witness and a focused model
regression, **not a native observation of this process's table**. It does not
by itself refute the 1,145 identifier arithmetic.

There is a separate eligibility attachment obligation. Strict comparison and
hashing process the raw node's attributes before `descend`; they do not recheck
a substituted node's root attributes at that point. Opening uses `t_attr_copy`,
which unions attributes (`term.ml:646–662,739–778`), and `notdef` observes
`inline:trivial` (`inlining.ml:119–145`). This packet does not prove that strict
equality alone preserves the actual opened eligibility decision. The required
contract explicitly includes opened attributes and forbids extra eligible
bodies. The 1,145/669 exports are conditional on that contract too.

## Captured facts and the missing representative contract

The inventory covers captured roots only. There are 512 task nodes and 244
logical declarations: 17 type, 16 data, 68 parameter, 81 singleton logic and
62 propositions. The accepted model has 143 mapped roots, summed term count
1,613, body-bound slots 168, patterns 12 and applications 594. Logic bodies
contribute 418 terms and four body-bound slots; formals total 123. Its maximum
reconstructed formula mass is 99. Optional hit/miss choices cover unknown
metadata exclusions; no missing Meta payload is inferred to be empty.

The captured graph has 157 binding records and eight saved entries: six leaf
values and two six-node binder-free values. All are unary in free occurrences;
nonunit keys occur in none of the saved values' free sets. Captured patterns
are nullary constructors with empty variable sets. The 16 ground Ddata
declarations have acyclic constructor-type dependencies. Types have at most
three occurrences, signatures at most two type variables and applications at
most seven arguments. The attribute universe has 80 entries; the known-map
identifier union has 277. All 45 model-eligible bodies are binder-free and
pattern-free, their hit formal coefficients are at most one, and possible
environment constants use builtin unbounded `int`.

`inventory.py` checks these restricted captured facts. It does not check a
projection of the shared declaration table. `representatives.py` exports the
missing contract, with exact scope, source references and numeric fields:

| Hypothesis | Required coverage |
| --- | --- |
| `E`, seed saved entries per formula | Sum of saved-map entries in every selectable old declaration formula before downstream opening, including unused entries and repeated stored edges |
| `V`, delayed-value nodes | Every such seed saved value's stored term occurrences |
| `T`, type occurrences | Every stored type, symbol signature, variable type and map-key type |
| `A`, attribute-universe entries | Union across captured and selectable terms, symbols, variables and saved-map keys |

The numeric fields are insufficient without these source-checkable invariants:

1. Cover **every** old live declaration any `Hsdecl` merge can return, including
   previously inserted local candidates. Join a complete initial projection
   or source/process invariant to each merge/return site; prove closure under
   local insertions and weak clearing, with no concurrent foreign insertions.
   Include unused values, keys, types and attributes. A sample is insufficient.
2. Require finite, acyclic, well-formed stored graphs and caches, correct
   `bv_vars`, and fresh identities distinct from all projected identifiers.
   Every seed saved value is binder-free/pattern-free with at most one free
   occurrence. Across maps that can compose, no key with a non-leaf value is
   free in any seed value. Subsequent map additions are fresh renamings;
   independent validators restart from the immutable declaration.
3. After **actual opening and attribute copying**, selected bodies/formulas
   correspond modulo fresh alpha names to the accepted alternatives at the
   corresponding declaration index, preserving types, constants, triggers,
   patterns, multiplicities and eligibility-relevant attributes. Additional
   guard exclusions may be optional misses; no extra eligible body or hit may
   enter the 45-body/85-hit model. Eligible bodies retain the binder-free,
   pattern-free and coefficient-at-most-one restrictions.
4. Include all stored symbols and signatures, even in unused values and key
   types, in the captured validated universe. Introduce no hidden self-reference,
   alias expansion, recursive data dependency or extra signature variable.
   Retain normalized types, arity at most seven, at most two signature type
   variables, and the constant-constructor restriction. Types and the attribute
   union obey `T,A`; no new named symbols/attributes arise.
5. Retain declaration kind/index/symbol, singleton nonrecursive logic shape,
   formal arities, `d_news` and valid cached fields. Per-declaration opened
   root/body/trigger/binder/pattern coordinates remain within the model's
   corresponding alternatives. All patterns remain nullary with no variables.
   Reused data/type/parameter declarations retain the captured dependency graph.

These are obligations to establish from representations and source behavior,
not caller truth flags. `compose(envelope_hypothesis=...)` accepts only the four
natural-number hypotheses. It propagates them into **conditional** arithmetic
but never populates `actual_representative_envelope`, coverage evidence or an
established flag. The no-argument case uses `(8,6,3,80)` only as an illustrative
hypothesis copied from captured facts. It is not evidence that any old-table
projection satisfies those values. Establishing the actual contract remains
work under #119; repairing the scope/interface resolves the #133 overclaim.

## Conditional propagation through openings and validators

All numerical ceilings in this section require the full preceding contract.
Set `E*=max(8,E)`, `V*=max(6,V)`, `T*=max(3,T)` and `A*=max(80,A)` to include
the captured inputs. The immutable mapped declaration can contain either the
new candidate or an imported old seed. The mapper and an independent validator
supply at most two renaming ancestries. With the accepted independent maxima
`P=8+6=14` for body-bound slots plus formals:

```text
saved-map keys             K <= E* + 2*P
opening-map keys               <= K + P
saved-value nodes          V <= V*
stored formula occurrences R <= 99*(1 + K*V*)
```

The disjointness/unary condition means saved-value composition only renames
its one possible free leaf. Fresh identifiers cannot collide with seed keys.
`t_subst_unsafe` stops at raw binder bodies but recursively visits old saved
values; `t_replace_all` does not rewrite hidden saved values. Changed binders
close with empty maps; unchanged binders retain their records. Hit-body type
and final substitution passes are binder-free. The raw skeleton cannot exceed
the fully opened count because variable replacement is nonempty and binder-free.
At most 99 binding records, each charged `K` values of `V*` nodes, give `R`.

The original mapper, logic termination and task match checking account for
recursive opening. Six outer-formal sites per logic declaration and twelve
extra branch openings give:

```text
opening-substitution starts <= 2*1613 + 418 + 6*81 + 12 = 4,142
recursive substitution entries / binder updates <= 4,142*R
stored validator entries <= (3*81 + 143)*R
```

The default **hypothesis** yields `K=36`, opening-map size 50 and `R=21,483`,
then 88,982,586 hidden substitution entries and 8,292,438 stored validator
entries. Free-variable scan arithmetic is
`4142*R*99*V* + (1613+81+143+81*7)*R + 156`, yielding 52,907,301,372 under
that hypothesis. Semantic occurrence counters and positive intermediate
sum/products are at most 99 under the unary condition
(`term.ml:599–622,759–773`). These are event-count arithmetic, not measurements,
allocation bytes or expected running costs.

Six outer-formal opening sites are `decl_map/open_ls_defn_cb`, termination,
the inlining used-symbol guard, eligibility/environment opening, task
used-symbol checking, and `decl_fold` for match checking. Counting all six
is conservative even where branches exclude one another. The conditional
registration increment is `235 + 6*123 + 4 + 168 = 1,145`. `id_clone` creates
a pre-identifier; `create_vsymbol` performs registration. Nullary patterns
avoid pattern compiler variable creation (`pattern.ml:141–161`).

Reused declarations still undergo task validation. There are at most 16 data
revalidations, zero Ddata constructors, 16 positivity argument checks, 22
`ts_extract_pos` calls, 38 foundedness type entries and 22 constructor entries.
Nonrecursive singleton termination creates at most 162 empty `Hid.create 5`
tables, without descent-vector arrays or recursive call-list closure. These
facts use the declaration/hidden-symbol contract, not just equal opened mass.

Hit type instantiation visits at most `(156+67)*T*` recursive type entries and
`Ty.Hsty` requests, including free-variable type work outside the memo. At the
default hypothesis this is 669. Intermediate type size is at most `(T*)²`;
source instantiation substitutes each type-variable leaf once. The exported
type folds and matching arithmetic use that enlarged type bound. Attribute
set size uses `A*`; stored map-height-plus-two includes `K`, 99, 277, 268 and
`A*`. A larger hypothesis thus enlarges dependent operations rather than
leaving the original hidden-work ceilings unchanged.

## Requests that survive selection, and pure backing transfers

The captured spine fixes at most one declaration reconstruction per mapped
root, one theory request per logical declaration, and one task request per
spine node. These **request counts** survive representation selection and
early failure, assuming valid shared tables and no foreign concurrent
insertions; they do not bound callback work or initial counter values:

| Shared group | Selection-independent request bound |
| --- | ---: |
| `Decl.Hsdecl` | 143 |
| `Theory.Hstdecl` | 244 |
| `Task.Hstask` | 512 |
| `Task.Stdecl` Hcpt | 17,152 |

The Hcpt allowance is `64*(192+42+34)`, at most 64 Patricia nodes per history
insertion for 63-bit keys (`hcpt.ml:132–158,176–275`). This route is `add_tdecl`,
not recursive `use_export`. The captured `d_news` and topology give at most
277 known keys, 192 metadata keys, 76 clone keys and 268 history-set keys;
representative-dependent shape and map work remain in conditional arithmetic.
`Ident`'s 1,145 and `Ty.Hsty`'s 669 are deliberately absent from the independent
request group because their semantic/eligibility attachment is unresolved.

The goal-specific wrappers bypass the enclosing store caches. The fresh
`Wtask.create 63` cache has at most 512 lookups and 511 sets; the fresh
`Wtds.create 17` metadata cache has one lookup/set. Their backing transfers
are instantiated independently of term representatives. The hit `Wty` caches
(at most 85 instances, 156 total lookups/sets and five per instance under the
model) remain conditional on the representative contract.

`ephemeron_transfer(L,S,E)` retains dead entries in its input stored size.
For `N=S+E`, every array has length at most `max(L,4*N)`: resize cleans first
and grows only if retained size is at least half the old array length. The
callable also exports twice that bound for resize/threshold arithmetic and
old-plus-new arrays (`ephemeron.ml:141–211`). Fresh initial arrays round to 64
for the fold and 32 for metadata/type memos. The fold-array bound is 2,044;
metadata arrays stay at most 32. Arbitrary weak clearing is allowed.

`weak_transfer(L,B,S,E)` counts all initial allocated slots, including cleared
slots. Set `N=S+E`. The inherited table may resize once because of historical
oversized buckets. A rehashed fresh table has at most `N` oversized buckets,
so a resize trigger implies old outer length below `2*N`. Thus:

```text
outer array <= max(L, floor(3*L/2)+3, 3*N+3)
each bucket <= max(B, floor(3*N/2)+3)
```

The callable retains pre-saturation multiplication, shrinking, rover/oversize
and equality-callback count bounds (`weak.ml:123–140,185–285`). Its representation
conditions must be checked against actual integer/array/ephemeron capacities;
`min` or saturation after an overflowing multiplication is insufficient.
`counter_transfer(initial,increments)` requires its natural-number final value
to fit `2^62-1`. Hash mixing and Patricia bit operations keep their source-defined
modular meaning. These three pure callables neither infer an initial state nor
satisfy the missing representative contract.

## Remaining work and verification

The local call graph has been inventoried through task validation. Its
representation-dependent operational transfer is **not established**. Remaining
inputs include the selectable-old-representative contract; unsuccessful old
collision-comparand frame/attribute costs; shared counters/backing and other
process-lifetime callers; runtime allocation/collector composition; other
entry projections, later transformations, printers, serialization and the
remaining assurance-essential consumer capacities. Neither #119 nor any
complete transformation, process or whole-pipeline capacity predicate is closed.

The focused offline check replays the frozen conditional output/inventory,
models returned-old selection at 37 and 128 saved keys, propagates enlarged
numeric hypotheses, rejects Boolean/extra-field coverage substitutes, and
asserts missing actual coverage keeps the established flags false. It retains
the captured malformed-delayed-value rejection, counter boundary tests,
inherited weak backing and small ephemeron clearing enumeration. It verifies
source/capture identities and reuses the successful predecessor suite. No
native capture, compiler, prover, debugger, server, solver, build or proof run
was started. No Oracle, tool pin, production source or configuration changed.

`round.json` is the historical original round and contains its now-superseded
claim. `round-repair.json` records the corrective round, review finding and
actual measured checks. Selected worker: GPT-6 Astra / Extra High, assigned by
the parent; runtime confirmation and token/cost data are unavailable. The
parent owns independent repair review, integration, publication, issues and
memory. Scope correction does not supply the actual initial-state projection.
