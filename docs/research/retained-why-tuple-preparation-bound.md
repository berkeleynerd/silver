# Retained tuple preparation bound

2026-10-20, Round 35; bounded owner-authorized #155 within #153/#119. The
[packet](../evidence/retained-why-tuple-preparation-bound-20261020/README.md)
establishes a useful **actual direct algebraic tuple callback bound** under
the selected source/native, immutable-value, runtime and continuation premises
of the [writer episode result](retained-why-path-writer-capacity.md). It replaces
the representation-only task ceiling for this charge. It does not supply the
separate library publication charge, actual total `W`, or complete capacity.

Let `H` be the set of physical type symbols occurring as **Ddata heads** in all
initially retained `Hsdecl` representatives in one stopped process. Then every
selected algebraic fold has at most `|H|` direct tuple callbacks, including
failed prefixes and continuations with numeric-tag aliases and memo hits.
This counts all data heads conservatively; it does not classify tuple symbols
by their spelling or assume the initial tuple registry is complete.

| Process | PID | Raw-context data heads | Initial global data heads / `T_prepared` | Episodes `E` | Direct tuple publications ≤ `3 E T_prepared` |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 17310 | 21 | 63 | 194 | 36,666 |
| Put | 17514 | 21 | 63 | 161 | 30,429 |
| First_Or_Default | 17631 | 18 | 61 | 98 | 17,934 |
| Is_Message | 17704 | 15 | 58 | 11 | 1,914 |
| Input_Is_Valid | 17869 | 16 | 59 | 5 | 885 |

The sum **87,828** is bookkeeping across five separate processes. Each row's
bound applies to every goal/driver pair allowed by the retained schedule, in
any allowed order, rather than only the observed first cvc5 task. Input_Is_Valid
starts inside its first preparation episode; its `E=5` conservatively includes
that entire episode. The raw-context column is diagnostic and is not substituted
for the larger initial representative family.

## Exact initial family and driver update

The focused checker reads each fresh capture's `hsdecl-table.json`, enumerates
every allocated bucket/key slot, verifies its retained distinct-root list
against the representative graph, and inspects every declaration node. It
records each data declaration's physical type-head pointer, identifier pointer,
numeric tag, diagnostic name and physical `ts_args` list length. There are
6,917/6,917/6,763/6,672/6,704 initial distinct declaration representatives,
with 63/63/61/58/59 data heads. Every observed data type arity is in `{0,1,2,3,4}`.
Each initial raw task chain's data declaration is separately joined by pointer
to that same process's global representative graph and raw session blocks.
The captured raw chains include unregistered/uninteresting tasks as well as
selected leaves; no equality with the scheduler goal count is assumed.

Selected capture-member bytes/hashes match the retained capture manifest;
process/session-block identities also match the accepted fresh status packet.
The episode values are read-checked against Round 34's
`under_named_existing_premises` result, with matching case and PID. This is a
new focused projection of retained observations. It does not replay the prior
collector or claim a new native capture or binary/source attestation.

The initial universe also bounds **initially returnable cache results**, not
only the visible raw contexts. `decl` is private (`decl.mli:105`); every Ddata
constructor ends in `mk_decl`, which calls `Hsdecl.hashcons`. Only goal
propositions use `Hsdecl.unique` (`decl.ml:411–419,462–508`). A data declaration
reachable from a returnable cached task/declaration result remains live. Under
the retained OCaml weak-table semantics its hashcons entry is therefore among
the enumerated live entries. An expired weak entry cannot later supply that
cached value. This is a source/runtime liveness argument; the packet does not
pretend to have directly captured every private transform cache.

There are **no driver-forced theory exports** in this task family. The new
lexer-based scan checks all 14 exact resolved driver/import files against their
retained hashes and finds zero uncommented `use` tokens. In
`Driver.load_driver`, only the `Ruse` local-rule arm changes `th_uc`; the other
arms return the same object. `thuse` starts empty and receives an entry only
when that object changes (`driver.ml:153,173–249`). Thus `drv_thuse` is empty for
all three actual selected drivers. `Driver.update_task` can add/clone metas and
reattach the goal, but its `Task.use_export` arm cannot run
(`driver.ml:330–367`). An update-task memo result remains a result of one of
these same data-preserving closures, even if numeric driver/task keys alias.

## Data-head preservation through the selected producers

The invariant is **set containment of physical Ddata heads in `H`**, not
per-input declaration-count monotonicity. A memoized result for another task
may contain data heads absent from the current raw input. Using the initial
global family allows this without assuming injective numeric tags or cache
misses. `Decl.decl_map` and `decl_map_fold` return Ddata unchanged
(`decl.ml:621–671`); formula expansion cannot create data heads through these
helpers.

| Producer in the resolved chains | Ddata effect |
| --- | --- |
| `counterexamples_dependent_intros` | The actual no-counterexample branch uses `remove_unused_from_context`; its Ddata arm returns `[d]`. The alternate dequantification branch also only introduces parameters/propositions and retains data declarations (`prepare_for_counterexmp.ml:15–31`, `introduction.ml:338–363,513–524`). |
| `monomorphise_goal` | Replaces only the goal and adds `Dtype` declarations for fresh type constants. It introduces no Ddata (`libencoding.ml:263–276`). |
| `inline_trivial` | Maps formulas, optionally removes a Dlogic definition, and inserts other declarations once. Ddata passes through `decl_map` unchanged (`inlining.ml:57–86`). |
| `eliminate_builtin` | Filters a Ddata group's existing `(ts, constructors)` pairs; returns no group or one group with the retained original type heads (`eliminate_definition.ml:27–39`). |
| `remove_unused` | Keeps or drops each existing Ddata declaration (`remove_unused.ml:143–173`). |
| `detect_polymorphism` | Inspects declarations and appends metas; no data-head creation (`detect_polymorphism.ml`). |
| Conditional definition/recursion elimination; inductive elimination | Rewrite Dlogic/Dind into parameters/propositions; all Ddata arms retain the input declaration (`eliminate_definition.ml:121–203`, `eliminate_inductive.ml:49–57`). |
| Guard epsilon; epsilon; literal; formula simplification | Term/declaration maps, parameters, propositions, Dtype replacements and metas only. Ddata is unchanged. Literal initialization reads `int.Int` and `real.Real` and extracts symbols; it does not import their declarations into a Task (`eliminate_gnatprove_guard_epsilon.ml:110–119`, `eliminate_epsilon.ml:205–220`, `eliminate_literal.ml:92–223`, `simplify_formula.ml:15–40`). |
| `eliminate_projections_sums` | Constructs one Ddata group with the original `ts` for each pair; may remove projections and add Dlogic declarations (`eliminate_algebraic.ml:599–642`). |
| `discriminate_if_poly` and its helpers | `compile_match` is a declaration term map. Goal monomorphisation adds Dtype only. Selection adds metas; moving types to the front rearranges existing tdecls; `translate` returns `[d]` for Ddata (`eliminate_algebraic.ml:67`, `discriminate.ml:211–214,410–478`). Formula/logic instantiation can multiply other declarations, but cannot multiply the head family. |

The cvc5 algebraic fold follows its first 13 transforms, including projection
elimination and discrimination. The z3 fold follows only inline, builtin,
unused removal, polymorphism detection and inductive elimination. The altergo
fold follows counterexample introductions, goal monomorphisation, inline,
builtin, unused removal, recursion, inductive and epsilon elimination. The
exact dispatch is retained by identity in the packet. Both alternatives of
`eliminate_algebraic_if_poly` are included: the polymorphic arm uses the fold;
the monomorphic arm uses only compile-match/projection elimination and has
zero direct tuple callbacks (`eliminate_algebraic.ml:666–671`). No conclusion
depends on a cached polymorphism decision being correct for the current task.

For closure across later episodes, the post-fold producers also preserve this
family. Algebraic elimination partitions the original data pairs and keeps
`dl_concr` with their original heads; generated projections are logic symbols
(`eliminate_algebraic.ml:433–467`). Its deferred tuple reconstruction inserts
the original `d`, then adds a `Use` tdecl, **without `Task.use_export`**
(`eliminate_algebraic.ml:479–487`). Literal/premise/split/simplification helpers
have the effects above. Encoding's type-selection/field-type helpers add metas;
twin/guards/tags and monomorphisation retain Ddata and add only other declaration
kinds (`encoding.ml`, `encoding_twin.ml:100`, `encoding_guards.ml:123`,
`encoding_tags.ml:123`, `libencoding.ml:190`). Formula-bound type instances and
foreign cached terms are not sources of new Ddata heads.

The alternate registered `guards_full`/`tags_full` flag implementations also
retain Ddata (`encoding_guards_full.ml:273`, `encoding_tags_full.ml:66`).
`guards_full` has a static task initializer exporting `builtin_theory`
(`encoding_guards_full.ml:280–285`); this is constructed before the cut and
belongs to the initial live family. The registered encoding choices are
`twin` and `guards`, `tags`, `guards_full`, `tags_full`, with selection adding
metas only (`encoding_select.ml`). `encoding_sort` is a separately named
transformation, absent from the selected driver lists and these flag tables.
It can create new data heads, so it is not included in the preservation
claim; its source is retained only for the separate arity cross-check below.

Later library reparses may add new global Hsdecl representatives. They do not
enlarge this Task-producing invariant: the literal environment constructor
extracts library symbols only; the fixed driver update has no export; and the
selected task producers above never convert those symbols into Ddata heads.
Their private memo tables contain either initially returnable values or values
produced by these same closures. The selected fixed-session/dispatch premise
excludes an unrelated concurrent transformation producer; this is the same
single-process continuation scope as Round 34, not a universal claim about
arbitrary Why3 clients or plugin registrations.

In particular, **library parsing itself cannot populate these task-transform
caches**. This is not inferred merely from the literal caller extracting
symbols. In `Typing.add_decl`, program VC generation is enabled only when
`muc.muc_theory.uc_path = []` (`typing.ml:1675–1678`); the fixed library reads
and their named imports use the nonempty paths `int`, `real`, `algebra` and
`relations`. Dlet/Drec/Dexn therefore pass `vc:false` to `add_pdecl`
(`typing.ml:1701–1712`). Pure logical declarations and lemma wrapper declarations
also use `vc:false` (`typing.ml:1234,1567–1572`); ordinary module clone insertion
does likewise (`pmodule.ml:756,781,820,833,1355,1376,1466,1481`).

There is an explicit exception to check: `add_types` calls `add_pdecl ~vc:true`
(`typing.ml:1471`). The focused four-file lexical check uses the retained,
hash-matched comment/string spans and establishes zero `invariant` or `by`
keywords outside those spans. These type declarations have no invariant or
witness. The constructors retain precisely their supplied invariant/witness
fields, or set `[]`/`None` for aliases/variants/ranges/floats
(`pdecl.ml:28–42,75–143`, `typing.ml:1417–1420`). Hence `Vc.vc`'s PDtype branch
returns the empty list via its `None, []` case, without forcing its lazy
environment, building VCs, or calling any inference/simplification callback
(`vc.ml:1741–1783`). Builtin module and implicit tuple construction use the
separate raw module/theory constructors already covered by the library-origin
account; they do not dispatch Task transformations. Thus the actual parser
branches manipulate terms, program declarations and theories, but never feed
newly parsed Ddata into the shared driver `Trans.store`/`fold`/`compile_match`
result producers. This covers failures and foreign body-cache references as
well: those can change body terms or raise, but cannot change the library
module's nonempty path or supply lexical type-invariant/witness clauses.

## Memo representatives, duplication and the fold charge

There are three separate obligations.

1. **Hashcons representatives preserve heads.** `Hsdecl.equal` requires the
   same constructor and physically equal introduced type heads for each Ddata
   pair (`decl.ml:340–370`; `Ty.ts_equal` is physical equality at `ty.ml:75`).
   A hash collision or numeric tag wrap cannot return a data declaration with
   a different head. `Hstdecl` compares Decl contents physically (and uses
   physical theory-name identifiers for Use/Clone); `Task.Hstask` compares
   tdecls and predecessors. A successful task
   insertion is before a goal, so its nonempty predecessor has the physical
   equality case of `task_hd_equal` (`task.ml:76–107,140–164`). Thus hashconsing
   preserves the constructed physical chain and its known-map invariant.
2. **Memo results preserve the global family.** Task/decl memo keys may alias.
   `Trans.store`, `store_decl`, `fold` and combinators can return or resume from
   a result produced earlier by that same closure. Their result producers are
   closed by the preceding section. A `fold` hit can mix an earlier output
   prefix with a current input suffix; this invalidates a naive per-input
   count argument, but both parts still have their heads in `H`. Failure may
   leave completed cache entries; those entries satisfy the same invariant.
3. **A task chain cannot repeat one data head.** `create_data_decl` inserts
   every type identifier into `d_news`, rejecting a collision within the
   group (`decl.ml:440,499–508`). `known_add_decl` unions those identifiers with
   the predecessor's known map. An existing key raises `KnownIdent` for the
   same declaration or `RedeclaredIdent` otherwise; `Task.new_decl` suppresses
   the former and propagates the latter (`decl.ml:697–707`, `task.ml:148–155`).
   Numeric aliases cause suppression/failure, not two inserted copies. The
   known map never forgets a successfully inserted identifier in that chain.
   Sharing a node between tasks does not repeat it within one immutable,
   acyclic `task_prev` chain. Rebuilding/reordering/combining output prefixes
   goes through the same insertion check.

Consequently a prepared input chain has at most `|H|` Ddata occurrences: assign
each nonempty Ddata group any one of its heads; the assigned heads are distinct
between occurrences. This handles groups becoming singleton after builtin
filtering. It does not require singleton tuple declarations to remain singleton
through every predecessor.

`Trans.fold` accumulates a suffix by following `task_prev` once until `None` or
a memo hit, then calls its function once per accumulated node
(`trans.ml:75–100`). A hit does not replay callbacks in the cached prefix.
Thus even a partially completed fold invokes the tuple wrapper at most `|H|`
times on matching singleton Ddata nodes. The second `let comp` is nonrecursive:
its internal calls name the previous Task-only `comp`, so deferred tuple-map
reconstruction does not recursively invoke the tuple-writing case
(`eliminate_algebraic.ml:470–496`). Each direct callback calls `tuple_theory`
once; each actual constructor callback publishes at most three paths, as proved
in Round 34. The already established episode bound covers restarted folds.

## Arity side result and limits

`is_ts_tuple ts` compares physical `ts` with `ts_tuple(List.length ts.ts_args)`.
It can seed the tuple registry even for a non-tuple type; the check is not a
pure registry read. The direct Ddata tests therefore have arities only in
`{0,1,2,3,4}`. The wrapper's singleton `Use` test has the same bound: its initial
theory-contained Ddata declarations are initially live hashcons representatives,
and the only new selected `Use` producer above uses `tuple_theory` at one of
these existing arities. This side result bounds registry additions by **these
algebraic tests**, not every possible `ts_tuple` call in later library parsing.

The packet does not infer the full initial `ts_tuple_ids` or integer-key tuple
memo domain from these declarations. A memoized tuple type could exist without
a Ddata declaration. Nor does physical `is_ts_tuple` imply that the different
`is_ts_tuple_id` lookup used by library `Pmodule.add_use` is alias-free. That
implicit library route and its tuple-module construction remain in `C_lib`.

A separate whole-driver type-creation census supports the library lane's
arity argument: all explicit fresh type-symbol constructors in the retained
selected transformation bodies use an empty `ts_args` list. They are
`Introduction`'s goal type constants (`introduction.ml:251`),
`Libencoding.ts_of_tv` (`libencoding.ml:265`) and `Encoding_sort`'s fresh sorts
(`encoding_sort.ml:42`, separately inspected but not selected); static
`Libencoding` symbols `uni` and `ty` and `tags_full`'s `uni` and `deco` also use
`[]` (`libencoding.ml:30,39`, `encoding_tags_full.ml:89,92`). There is no `ts_args` record update in these
bodies. Their term/type substitution helpers build types from existing type
symbols, rather than creating type symbols with a new arity. The only tuple
type constructor route in these selected transform bodies is the algebraic
test/constructor route just bounded. Thus preparation contributes arity zero
and those existing algebraic arities; this does not close later parser origins
or the missing initial registry by itself.

The revised writer interface is therefore

`W <= E * (3 * T_prepared + 2 * C_lib)`

with the five `T_prepared` values above. The direct term is now useful; `C_lib`
and actual `W` remain null in this packet. Writer/table/save/whole-pipeline
capacity flags remain false. No Oracle, admission, installed tool, source pin,
production implementation or prior packet was changed.
