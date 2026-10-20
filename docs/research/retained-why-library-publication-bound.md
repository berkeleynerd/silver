# Publications in one retained library read

2026-10-20 UTC, Round 35, Refs #119, #153, #155. This bounded subthread
counts `Theory.id_to_path` publications during one direct `int.Int` or
`real.Real` library read in the selected interrupted preparation. It includes
nested reads, cache misses, reparses, clones, temporary typing environments,
implicit tuple modules and abandoned prefixes. It does not change the Oracle,
production sources, proof pins or the admitted language.

The source transfer gives a per-root base charge and a separate global
cache-loss allowance:

```
C_base <= 3,404,503 + 8*I
K <= 2*I + 38,679
W <= E*(3*T_prepared + 2*C_base) + 4*128*K + 4*e*(K+1),  e <= 2.
```

where **I must bound the number of completed identifier registrations before
the retained cut**, including any initialization that can supply cached body
objects. The initial-registration attachment is being developed by the lead;
this note does not infer that attachment merely from a captured counter. The
formula is useful at the retained counter scale, but its numerical
instantiation remains conditional until that separate attachment is accepted.
`C_base` is deliberately not called a standalone `C_lib`: interrupted or
successful resizing can discard cache bindings, and the last two terms charge
all such replay globally across the suffix. The lead composes this interface
with the accepted episode and prepared-tuple bounds.

The [packet](../evidence/retained-why-library-publication-bound-20261020/)
contains a focused source/arithmetic checker. Its lexical projections are
inputs to the semantic argument below, not a semantic parser proof.

## Fixed scope and publication routes

The accepted [library-origin transfer](retained-why-path-library-origins.md)
fixes four installed files, 38,678 bytes, 69 plain module heads, 102
use/clone declarations, an acyclic dependency graph, and preceding same-file
definitions. There are no nested modules or module interfaces, explicit
scopes, record witnesses/invariants, mutable/private type declarations, or
val/exception clone substitutions. The only concrete data type is
`int.IntInf.t = Finite int | Infinite`; other explicit type heads are abstract.
The only external builtin target is `why3.WellFounded.WellFounded`.

This is the incremental WhyML route: `Lexer.read_channel` selects
`Parser.Incremental.mlw_file`; its grammar invokes each module/declaration
action once. `Typing.add_decl` at 1960 invokes the core dispatcher at 1675,
and the no-interface close at 1900 closes exactly one module. Its parser
exception handler discards the current file and rethrows; it does not resume
typing a failed declaration. `Typing.add_decl` at 1234 wraps a pure declaration in
`Pmodule.add_pdecl`; `Pmodule.add_pdecl_raw` folds `Theory.add_decl` over
`pd_pure`. Each actual head visited by `Theory.add_decl` is charged, including
a repeated identifier and a write later abandoned. Counting distinct names
would be insufficient. `use_export` publishes no new Theory paths.

`Pmodule.clone_export'` walks the source module's expanded units, clones
`Udecl`, uses stored module values for `Uuse`, and records `Uclone` through
`Theory.add_clone_internal` / `add_clone_unsafe`. It does not call the
namespace-walking `Theory.clone_theory` route. Accordingly the separate
namespace-walker contribution **N is zero here**. Clone-created declaration
heads remain charged below. The selected files have no interface that could
activate `mod_impl`/`unit_impl` copying.

Foreign `restore_rs`, `restore_its` and `restore_pv` body hits remain allowed.
They can expose foreign types and contracts to symbol scans. This proof does
not assume that every used symbol appears in the four-file source census.

## File reads and expanded source slots

For each module m, B(m) is its byte span from the beginning of its module-head
line to the next module-head line or EOF. Comments, strings and whitespace are
retained as spare capacity. A module inventory field named `bytes` measures
the name, **not this span**; the checker calculates spans from actual source
bytes. Their sum is 38,163 bytes; the omitted file preambles declare no heads.

Let clone(m) be the multiset of its lexical clone targets. Define

```
L(m) = B(m) + sum(L(t) for t in clone(m)).
```

Uses add no cloned heads. Both exported and nonexported clones contribute;
their namespace wrappers do not duplicate their contained unit list. The
accepted DAG makes this recurrence finite. Cached modules, if selected, have
the same bounded provenance; a failed prior parse cannot store an arbitrary
module under one of these string-selected names.

For each complete file parse, the sum of L(m) is:

| File | Modules | Expanded byte slots |
| --- | ---: | ---: |
| relations | 22 | 9,466 |
| algebra | 13 | 22,178 |
| int | 20 | 27,396 |
| real | 14 | 19,471 |

An external textual `find_module` action performs at most one complete-file
parse attempt. `Env.read_library` checks its cache once, invokes the uncached
reader once on failure, then checks once again; it has no retry loop. File
format registration stores the parser's result and does not run the parser
again. An exception truncates that attempt. A later textual action can miss
again, including after a caught signal-origin `Not_found`, so no successful
cache entry is assumed persistent for this count. Cloning stored `Uuse` and
`Uclone` values performs no source read. A failed same-file lookup falls back
to a fixed `why3.<module-name>` builtin lookup, not a reparse of the same file;
none of the module names in this family denotes `Tuple<n>`.

Ignoring all cache hits yields the whole-file recurrence

```
P_relations = 1
P_algebra   = 1 + 2*P_relations                         = 3
P_int       = 1 + 2*P_algebra + 4*P_relations            = 11
P_real      = 1 + P_algebra + P_relations + 5*P_int      = 60.
```

| Direct root | real parses | int parses | algebra parses | relations parses | Expanded byte slots | Ordinary closes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| int.Int | 0 | 1 | 2 | 8 | 147,480 | 222 |
| real.Real | 1 | 5 | 11 | 43 | 807,447 | 1,203 |

The ordinary closes include every prospective module in every parse, even
when a prefix fails before reaching them. Static builtin modules were already
constructed before the cut. Their uses add no new ordinary closes.

## From source slots to actual declaration-head visits

For the admitted fixed declaration forms, **4*B(m)** bounds the direct head
visits during typing, and bounds the head visits when those retained direct
units are cloned. This is a capacity argument about lexical binder and
contract slots, not a claim that an arbitrary AST has at most B nodes.

* Pure logic symbols receive a preliminary parameter head in the temporary
  typing environment and at most one final parameter/definition head
  (`Typing.add_logics`). Inductive predicates likewise receive one preliminary
  head and one final predicate head, plus one head per lexical clause binder
  (`add_inductives`). Discarding the temporary environment does not undo its
  publications.
* Each selected type head is abstract or belongs to the one explicit variant;
  every selected explicit type-declaration group is a singleton.
  `create_type_decl` publishes the type and its lexical constructor/projection
  occurrences. There is no selected range/float, record-injectivity,
  invariant or witness generator. Clone type traversal is restricted to the
  original declaration's `def` map and returns a filtered list indexed by
  the original `tdl`. Substitution validation can inspect a foreign target,
  but the substituted entry is omitted rather than importing the foreign
  target's declarations. Other entries copy their head/list shapes.
* A pure proposition publishes its lexical head. Its generated lemma
  function uses `create_val` with default `RKnone`, producing no additional
  pure head. A selected top-level program routine is an explicit lambda,
  recursive lambda, or `any` declaration; the sole `val constant pi` is the
  corresponding zero-argument wrapper. The exported computation's post list
  is its lexical contract list, rather than a foreign callee's post list.
  `create_let_decl` contributes at most a parameter/definition pair plus one
  axiom per postcondition; the `NoTerminationProof` fallback is precisely a
  parameter/axiom pair per original logic head. Allocating up to four slots
  per routine binder and contract occurrence covers these alternatives.
* `clone_cty` maps post lists; `clone_cexp` preserves a `Cfun`/`Cany` wrapper,
  and recursive cloning maps its routine list. Effects may be repaired to a
  fixed point, but these repairs do not call a Theory publication routine or
  add items to the outer post list. `PDpure` cloning maps the original head
  lists or skips substituted heads. It does not expand a foreign declaration
  list. Nonempty library paths disable ordinary program VCs. The selected
  family has neither type invariants/witnesses nor program refinements, so
  the other relevant VC-producing branches contribute no heads.

The binder/clause/contract tokens just described occupy distinct nonempty
source-byte positions. Charging four to each and then allowing every byte
as a possible position gives the stated bound, with spare capacity. Compound
datatype projection occurrences are charged by source occurrence, not unique
name. The accepted family contains no unlisted declaration form requiring a
different generator. Nested expression-local functions do not become extra
outer `pd_pure` heads.

Induction along the clone DAG therefore gives `H(m) <= 4*L(m)`, including
cloned generated heads and failures partway through a list. Combining the
file recurrence and ordinary closes gives

```
non_tuple(int)  <= 4*147480 + 222  =   590142
non_tuple(real) <= 4*807447 + 1203 = 3,230,991.
```

## Implicit tuple domain

`Pmodule.add_use` can scan arbitrarily large foreign contracts. Its tuple
branch uses `Ty.is_ts_tuple_id` and the integer returned by the initial or
later tuple registry. Rather than bound the symbol scan's size, use the
integer-keyed strong `Hint.memo` tables for `tuple_module` and `tuple_theory`.

Let R0 be the set of integer values in the initial `ts_tuple_ids` registry,
and A0 the set of `List.length ts.ts_args` values for **all** initial type
symbols, including symbols reachable only through permitted foreign caches.
Let L be every integer from 0 through 38,678. Once an initial registration
bound I is attached, `|R0| <= I` and `|A0| <= I`, hence

```
K = |R0 union A0 union L| <= 2*I + 38679.
```

This deliberately double-counts overlapping values. It does not need a
maximum initial arity, a complete tuple-registry root capture, or foreign
formula-size bounds. Initial negative registry values, if any, are included
in R0. Every later list-length-derived value is nonnegative.

The domain is closed under the selected continuation:

1. Parser tuple syntax uses lengths of lexical type/term/pattern/expression
   lists. `create_val` calls `cty_from_formula` only on the newly typed lexical
   proposition. Its consecutive existential result binders are lexical
   binders; symbol lookup does not inline a foreign formula body there.
   Its fresh variable substitution preserves the binder-list shape. The
   selected family has no witness; even a witness-list length would be
   lexical. These lengths belong to L.
2. `Dexpr.try_cexp` builds the actual `vl` one element per lexical application
   argument. Unapplied foreign parameters remain a separate argument list.
   `Expr.c_app` enters `cty_tuple vl` only when that separate list is empty.
   Cloning and recursive substitution map the existing `Capp` actual list
   without changing its length. `e_match` maps existing branch variable
   lists. `Dexpr.vl_of_mask` can build a tuple from a foreign result type's
   application arguments; a well-formed application's argument-list length
   is its type-symbol arity, already in A0 or the later closed domain.
3. Every `is_ts_tuple ts` test can seed `ts_tuple(length ts_args)` even when
   ts is not a tuple. This includes type/mask checks and diagnostic printers;
   those calls are not silently excluded. A newly declared type takes its
   explicit lexical parameter list; clone type creation copies `ts_args`.
   Existing foreign type symbols retain their arity. The synthetic frozen
   type in notation matching is nullary. A newly made tuple type carries
   its requested arity, already in this domain (or fails before returning).
4. The sibling prepared-Ddata/arity transfer covers the selected preparation
   transformations: fresh non-tuple type constructors are nullary; the only
   later tuple constructor route is the algebraic test on retained Ddata
   arities 0 through 4. Type substitution/hashcons uses existing heads;
   `Ty.Hsty.equal` compares heads and child types physically, so identifier
   tag aliasing does not manufacture a new type-application length. All of
   these values are already in L or the initial domain.
5. No selected source module or dependency names a dynamically chosen
   `why3.Tuple<n>` file. Implicit module lookup takes its integer from the
   registry; declaration cloning does not introduce a new source read.

The fourth item uses the [prepared-tuple arity corollary](retained-why-tuple-preparation-bound.md),
author freeze `f29fe06a2228e9fe518c2b1f85e979f86e34bb90`. Its initial-Ddata/Use
closure bounds algebraic arities by 0 through 4; its selected fresh
non-tuple constructors use `[]`. Final independent acceptance is tracked by
the lead. This packet does not replay that predecessor checker or claim a new
native projection.

## Completed and abandoned tuple constructions

A direct `Theory.tuple_theory n` miss has at most three publications: its
type head, constructor head and close. An implicit
`Pmodule.tuple_module n` miss can have **four**, because it also closes its
initial temporary Theory before replacing `mod_theory` with the tuple theory.
Moreover `pd_tuple n` already calls `tuple_theory n` before that temporary
close. Strong memoization prevents a second ordinary completed tuple-theory
construction for the same integer. The tuple module's `add_pdecl_no_logic`
writes only Pmodule's different path table.

Between cache-loss events, all ordinary completed module/theory constructions
for K keys cost at most 4K. Exactly two private memo tables control these
publication callbacks: `Theory.tuple_theory` and `Pmodule.tuple_module`.
`pd_tuple`, `ts_tuple`, `fs_tuple`, `its_tuple` and `rs_tuple` have their own
memos, but they cannot bypass these two publication memos. Neither publication
memo uses identifier tags as its key, and neither has a selected remove,
clear, reset or replacement operation. A failed body can leave a publication
prefix without caching its result. Such a failure either escapes this direct
read or is swallowed by a `clone_export'` Uclone/Umeta `Not_found` handler.
Charge each swallowed handler occurrence one incomplete construction, at
cost at most four; no assumption about a foreign contract's symbol count is
needed. Once a tuple constructor raises, that `Sid.fold` stops at that element.
The constructor body does not call `add_use` recursively.

For a module m let `q(m)` count its lexical clone markers plus a conservative
raw-line count of meta heads. The raw count intentionally includes three
comment-contained meta lines. Define

```
Q(m) = q(m) + sum(Q(t) for t in clone(m)).
```

Generated `pd_meta` entries are folded directly into Theory metadata, not
added as new `Umeta` units. With no record generator or interface-copy route,
the only `Uclone`/`Umeta` catch slots are bounded by this recurrence. The
per-file Q sums are int 108, real 55, algebra 115 and relations 66. The
whole-file recurrence gives 866 slots for int and 4,698 for real. This also
charges direct markers whose own creation is outside a catching clone walk.

Other caught lookup failures do not enclose a tuple-publication callback.
Typing failures are wrapped/rethrown, not resumed at the next declaration.
Builtin reader `Not_found` handling cannot surround a new tuple module here,
because the fixed builtin target and same-file fallbacks have no tuple name.
The selected source guards and wrappers therefore provide no additional
ordinary swallowed callback slots. A final escaping incomplete construction
costs at most four. This includes a failed memo insertion after the callback
already published its result. Ordinary allocation, stack or array failures
are not `Not_found` and escape these local handlers. The source integer hash
is identity and equality is integer equality (`Wstdlib.Int`); neither raises
ordinary `Not_found`. `Hashtbl.add`/`resize` likewise has no such branch.

Crucially, strong memoization does **not** make an interrupted resize
transactional. The retained OCaml `Hashtbl.resize` assigns `h.data <- ndata`
before rehashing. In-place interrupted rehash can also leave shared or
extraneous bucket links. This note makes no claim that a subsequent
successful rebuild preserves those old malformed chains. Instead charge
**every subsequent resize assignment as loss of every memo key**, whether
the resize succeeds or fails.

There are at most 64 such assignments per publication memo, hence at most
128 globally. Each private table is created once, with a positive power-of-two
array length. The sole later `h.data` assignment first computes twice the
old length and successfully allocates that length. A negative or oversized
allocation cannot publish a smaller array; it raises before assignment.
On the retained 63-bit OCaml integer ABI a strictly doubling positive array
length permits fewer than 64 such assignments. Interruptions do not decrement
the published length. The budget is global, not per root or episode.

Between these assignments, `add` prepends a distinct fresh bucket cell at the
exact integer-key index, and `find` is read-only. Old malformed tails can make
a traversal fail to return, but do not remove a subsequently cached head.
All mutations of old `next` links occur inside the charged resize interval.
The interval has no tuple-publication reentrancy: the hash/equality operations
are plain integer operations, no table callback calls the memo body, and the
accepted [library-origin pending-callback closure](retained-why-path-library-origins.md)
excludes reentrant parsing/preparation or another Theory writer. Selected
pending callbacks save/exit or yield. A nonreturning resize produces no
further publications. This argument requires no recovery theorem for a
corrupted table and no bound on the number of old bucket-cell visits.

Charge four publications per possible key for each of the 128 assignments,
even though one assignment changes only one table. Separately the accepted
global escaping signal-exception budget e <= 2 can force a spurious miss or
an interrupted callback/insertion prefix. Reserve `4*e*(K+1)` globally for
those events as well, deliberately also allowing whole-key replay. Nonsignal
memo failures either abort the root or consume an already counted clone
handler slot; they do not create an uncharged resumed epoch. No component of
this argument resets e or the resize budget at a root, callback or save.

The base charges are therefore

```
C_base,int  <= 590142  + 4*(2*I + 38679 + 866  + 1)
            = 748326  + 8*I
C_base,real <= 3230991 + 4*(2*I + 38679 + 4698 + 1)
            = 3404503 + 8*I.
global cache/signal replay <= 4*128*K + 4*e*(K+1).
```

Use the real base bound for either literal root, then add the global replay
allowance once to the whole-suffix writer count. This is an actual publication
accounting interface; treating C_base alone as C_lib would omit a required
term. The parent numerical composition must retain all terms displayed at the
start of this note.
The additional temporary tuple-module close corrects the composition of the
earlier writer equation: it is either a separately charged close or part of
this four-publication implicit construction; it is never lost in a `3*T`
charge intended only for direct tuple-theory callbacks.

## Verification and round record

Selected model/effort: GPT-6 Astra / Extra High; runtime setting unconfirmed.
First observed Round 35 work time: 2026-10-20 12:38:08 UTC. Source freeze
prepared after the independent resize challenge described below. The bounded author
used the inherited accepted origin/writer inputs, source archives and inventory
without native execution, new capture, disassembly, fetch, expensive proof
validation, predecessor-checker replay or GitHub writes. No token/cost
measurement is available. The checker verifies 69 module rows, 72 source
slices from 15 source members, the finite
read/clone arithmetic and exact source-slice correspondence. It does not
automatically prove the semantic transfer or the lead's initial-state lemma.

The independent reviewer identified that the first draft's per-signal
four-publication padding failed to cover cache loss during resize. The repair
charges every resize globally, retaining the original four-per-source-slot
allowance and avoiding a recovery assumption about malformed bucket chains.

The principal review obligations are the four-per-source-slot head transfer,
the closed arity domain under foreign body hits, the complete swallowed-failure
accounting and the separate registration-count attachment. Until those are
integrated and independently accepted, this packet alone does not mark #119,
#153 or #155 complete or turn the parent writer's actual W from null to a
proved number.
