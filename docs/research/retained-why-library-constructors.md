# Constructor charges inside selected library lookup

2026-10-23 UTC, #119 / #153. **Complete author lookup vector; independent
source review pending.** The earlier Hsdecl/zero-Task checkpoint is retained
below, and the resumed source argument supplies Ident, Hsty and Hstdecl.
The vector is conditional on a prefix before the first combined owner-guard
violation. The lead must close that condition by joining every residual;
this packet does not claim whole-process headroom.

The [packet](../evidence/retained-why-library-constructors-20261023/README.md)
starts at integration `0e17e4a874`. It owns no production or accepted-packet
files. Source revision is `9390baf120ef260547dfa14f08e11c890b203d9c`, under the
existing source/native/runtime relation. Only post-registration selected
`int.Int`/`real.Real` lookup is counted. Initial loading remains absorbed by
the [six-owner state attachment](retained-why-shared-demand.md); Input retains
the PID97103 upper envelope, with no subtraction of an unknown CE delta.

## Actual writer and caller map

| Owner | Writer and selected callers | What is not a request |
| --- | --- | --- |
| Ident | `id_register`; Ty/Term symbol constructors, program-variable/routine constructors, binder openings, parser declarations, clone substitutions, tuple memo bodies | `id_fresh`, `id_clone` and copied `preid` values alone do not register an identifier |
| Decl.Hsdecl | `Decl.mk_decl` selects hashcons or unique; Typing's provisional/final pure declarations, Pdecl's type/let products, `Pmodule.clone_decl`, `Theory.tuple_theory` through `create_data_decl` | A Theory path publication, a term visit or a type validator is not another declaration construction |
| Ty.Hsty | raw `ty_var`/`ty_app`; `ty_inst`, `ty_of_ity`, `clone_ty`, inferred application result types, `t_ty_subst`, `create_meta` conversion, explicit/implicit tuples | Successful `ty_match`, ordinary explicit-type term reconstruction, type folds and binder renaming reuse/scan types |
| Theory.Hstdecl | `mk_tdecl`; `add_decl`, `create_use`, `create_meta`, `add_clone_unsafe` | Namespace merging and closing a theory are not tdecl constructors |
| Task.Hstask | None on this selected lookup route | `Pmodule`/`Theory` do not invoke Task insertion |
| Task.Stdecl.Hcpt | None on this selected lookup route | `Theory.Stdecl` is a different persistent set; it is not Task's Hcpt history |

Hashcons allocates a tag candidate before `Weak.merge`, increments only when
the candidate is returned, and uses `unique` without a merge for Pgoal. Thus
candidate allocation, merge request and increment remain distinct. Our upper
request and increment bounds may coincide without asserting that every request
misses. Type matching's failure handler constructs `ty_inst` for its diagnostic
(`ty.ml:252–254`); its normal-path scan classification does not exclude that
failure-prefix writer. Public alias `ty_app` also expands its alias body.

The exact lookup boundary is the incremental WhyML parser and ordinary
`Pmodule.clone_export'`, not the namespace walker `Theory.clone_theory` or the
interface-copy route. The accepted four-file/no-interface origin argument is
retained, including allowed foreign `restore_its`, `restore_rs`, and
`restore_pv` body hits. No blanket source-local body assumption is added here.

For the zero Task components, `Typing.add_decl` computes `vc` from an empty
library path (`typing.ml:1675–1677`); the selected paths are nonempty. Pure
typing uses `vc:false` at1234. Ordinary cloning's additions likewise use
`vc:false` (`pmodule.ml:739–833,1365–1485`). `add_pdecl` only invokes `Vc.vc`
when that flag is true (547–553). Fixed builtin modules were constructed
before the cut; lazy tuple-module construction uses only Pmodule/Theory
operations (481–486). The selected no-refinement/no-witness premise excludes
other VC-producing cases. No Task operation is reachable along these paths.
Callbacks are separately owned and are not charged as parser work.

## A finite magnitude bound for the tuple domain

The publication result already establishes
`K = |R0 union A0 union [0,38678]| <= 2I+38679`, using the attached initial
registration count I. It bounds the number of keys, not their magnitudes.
Here a stronger magnitude consequence follows from the same constructor
premises:

1. `create_tysymbol` rejects duplicate type variables in `ts_args`
   (`ty.ml:183–185`). Every initial type variable required an identifier
   registration, so every initial list length in A0 is at most I.
2. A positive initial registry value n was installed by `ts_tuple n` only
   after its loop created n fresh type variables (`ty.ml:280–285`). Those
   registrations precede installation, hence n<=I. A negative initial n is
   retained as an allowed key, but its loop executes zero times and its
   argument list is empty; no absolute-value assumption is needed.
3. The accepted lexical/clone/arity-domain closure introduces only lengths
   at most38678 or copies existing arities. Therefore `max(0,n)<=A`, where
   `A=max(I,38678)`, for every selected tuple key.

The initial no-wrap/count attachment, not a raw counter residue, supplies I.
This argument does not require a tuple-registry capture or a maximum inferred
foreign formula size. The loop index n for positive tuple construction is
therefore below max_int in all five processes.

## Completed Hsdecl constructor component

Use the accepted four-file DAG and its expanded source-slot recurrence L.
For one direct root, `S_int=147480`, `S_real=807447`, and the swallowed
Uclone/Umeta slot bounds are `Q_int=866`, `Q_real=4698`. These are frozen source
results, not observations of one parser run.

The original four-per-source-slot argument also bounds prospective Hsdecl
constructor entries before Theory insertion. The additional correspondence
needed here is explicit:

- Typing's pure logic and inductive paths construct provisional parameter
  declarations and at most one final parameter/definition/inductive product
  per lexical head (`typing.ml:1495–1557`). Proposition conversion's extra
  lemma routine has `RKnone` and contributes no pure head (1566–1580).
- Selected type declarations use the abstract or explicit-variant paths of
  `Pdecl.create_type_decl`; the temporary sorting declaration has an empty
  pure list, and the variant is constructed once when mounted
  (`pdecl.ml:379–386,462–506`). Range, float, record/invariant/witness and
  interface generators remain excluded by the accepted source inventory.
- `create_let_decl` constructs at most the prospective parameter/definition
  products and one axiom per lexical postcondition. The attempted logical
  definition and its `NoTerminationProof` parameter/axiom fallback are
  charged even if the failed attempt reached a candidate. Three constructor
  entries per routine head plus one per contract slot fit the four-slot
  allowance (`pdecl.ml:531–638`). No effect-repair iteration calls this
  declaration producer until the routine result is selected.
- `clone_decl` maps/skips those head lists. Program/type cloning returns the
  same bounded outer routine, post and type-declaration shapes; it does not
  splice a restored routine's definition into the outer syntax. This is the
  accepted origin/shape result, even where bodies and signatures are foreign.

Each selected Hsdecl constructor entry is therefore assigned to one of these
prospective slots, whether it returns, is subsequently discarded, or fails
before publication. Partial prefixes cannot exceed the full prospective
charge. Along the acyclic clone recurrence this gives `D_root<=4*S_root`.
This is a new source argument about candidates; **W is never substituted for
the constructor count**.

Each `tuple_theory` body constructs exactly one Ddata candidate. Let E be
`3*N+e` for the actual registered-root count N and the one process-wide e<=2.
The accepted two-publication-memo argument bounds entries to each of
`tuple_theory` and `tuple_module` by

```
J = 2*E*(K+Q_real+1) + 128*K + e*(K+1).
D_lookup <= 2*E*4*S_real + J.
```

The128 term covers all resize assignments of those two memos once for the
whole process; the signal term also occurs once. Neither is multiplied by
the save count. The `+1` covers an escaping incomplete body or insertion.
An ordinary swallowed failure consumes one of the accepted Q slots. Lower
tuple memos cannot bypass `tuple_theory` to create a Ddata, so their separate
loss issue does not invalidate this Hsdecl bound.

Both total possible increments and hashcons requests are bounded by D_lookup.
Unique requests are separately bounded by `2*E*4*S_real`; tuple Ddata is not
unique. The hashcons and unique upper bounds are alternatives per constructor,
not additive inputs to the increment bound. Goal clone specifications really
occur in these files, so a zero-unique claim would be wrong.

| Process | E | A | Complete lookup Hsdecl increments/requests upper |
| --- | ---: | ---: | ---: |
| Put_Line | 155 | 136844 | 1140132452 |
| Put | 128 | 121505 | 936760628 |
| First_Or_Default | 68 | 77806 | 491571640 |
| Is_Message | 8 | 59035 | 74637148 |
| Input_Is_Valid | 5 | 60496 | 54698812 |

Each initial Hsdecl counter plus this demand fits the retained signed OCaml
integer. This closes that counter component, not whole backing or process
capacity. Large mathematical request totals are not treated as native
counters or aggregate RAM gates.

## Direct publication-body charges

The two publication bodies themselves contribute at most `2J` Ident
registrations, `J*(A+1)` Hsty requests and `2J` Hstdecl requests. Children
such as `fs_tuple` are separate. The completed every-call child charge below
covers all five lower integer memos without assuming their entries survive.
The former `complete_lookup` arithmetic join remains available for checking
this decomposition; `lookup_vector(case,e)` now supplies the full author
vector directly.

## Prefix restriction for restore-cache hits

The following new lemma is conditional on a prefix ending before the first
Ident counter wrap. It is **not** an unconditional replacement for the earlier
origin theorem, which deliberately permits tag aliases. The initial count
attachment proves the starting point; the remaining constructor bounds must
eventually discharge the post-cut prefix condition by a first-violation argument.

The three private cache writers store these associations:

| Table | Relationship when data is present |
| --- | --- |
| `Ity.ts_to_its` | key ts; value its with `its.its_ts == ts` (`ity.ml:543–561`) |
| `Expr.ls_to_rs` | key ls; value rs with `rs.rs_logic = RLls ls` (`expr.ml:46–58`) |
| `Ity.vs_to_pv` | key vs; value pv with `pv.pv_vs == vs` (`ity.ml:751–757`) |

Before wrap, the selected symbol constructors register a distinct identifier
for each new ts/ls/vs. Their tag-keyed equality therefore identifies the same
physical key symbol. Copying a preid does not copy its registered identifier.
The source/native immutable-value relation is essential here; this does not
cover forged records or arbitrary clients that bypass those constructors.

The associations survive interrupted ephemeron mutations. `add` constructs
the key/data container privately before publishing its bucket (retained
`ephemeron.ml:214–219`). `replace` first finds a matched key (315–334), then
`K1.set_key_data` clears data, writes the key and writes the new data (546–549).
Every interrupted intermediate state either still has a matched old pair,
has no data, or has the new matched pair. The native field operations retain
their existing runtime semantics. Resize copies the whole container pointer
(195–211); dropping or duplicating a bucket does not fabricate a pair.
Weak clearing can turn a hit into a miss but cannot change its present value
into another symbol's payload. A nonreturning traversal supplies no hit.

`its`, `ity`, `region`, `pv`, `rs`, and `cty` are immutable OCaml records
(`ity.ml:19–66,1293–1303`, `expr.ml:19–30`). In particular `its_mutable` is a
Boolean describing a WhyML type, not an OCaml mutable field. Their nested
lists/maps and logical term/type payloads have the existing immutable ownership
premise. Selected pending callbacks save/exit/yield under the accepted client
closure; they do not invoke these private setters or mutate payload records.
Save binder openings construct logical vsymbols, not program restoration
entries. Unrelated cache clearing/loss therefore needs no record repair theorem.

The frozen563-source-member reference census also checks a relevant remaining
case: `rs_of_ls` is private, and its only calls are fixed bool adapters,
the fixed function-application adapter, and `rs_tuple`. The other `mk_rs RLls`
paths construct their own fresh lsymbol in `create_rsymbol`, projection or
constructor creation. No selected caller can attach an arbitrary contract to
an existing library lsymbol. A tuple adapter can be recreated for the same
symbol; its contract is the signature-derived `rs_of_ls` construction, not
an arbitrary previous body. The census is evidence for reviewing this source
case, not an automatic whole-program reachability proof.

Consequently a successful restore hit in such a prefix is either the source
routine/type/variable associated with the queried symbol, or one of those
specific adapters. Named namespace/module provenance and clone ancestry can
now constrain its body. A failure still follows its real source continuation;
the lemma does not assume cache hits always succeed or persist.

To close the eventual no-wrap theorem, use the earliest violating operation
of the combined owner/caller guards. All earlier prefixes satisfy association
and the resulting source-shape bounds; their charged operations bound the
candidate violating increment. If the attached initial counter plus **all**
applicable stage/callback/lookup charges is below the native limit, that first
violation is impossible. One may not assume the final no-wrap result merely
to discard foreign bodies and then omit an owner that could wrap earlier.
The resumed bounds below supply the formerly missing lookup demands. The
contradiction still belongs to the lead's combined all-residual composition;
a lookup-only margin cannot discharge it.

## Historical pause checkpoint

The owner requested a pause on2026-10-23 at the next convenient checkpoint.
The [durable handoff](../evidence/retained-why-library-constructors-20261023/checkpoint.json)
records the exact completed subparts and remaining work. Latest validation:
74 focused source/census/arithmetic checks passed in2.197588s on Linux x86_64,
and `git diff --check` passed. No native execution, capture, predecessor replay,
production/planning changes or publication occurred. Selected model/effort was
GPT-6 Astra/Extra High; runtime confirmation and token/cost measurements are
unavailable. Elapsed time to the pause observation was1955 seconds.

At that pause the type/contract measures and full vector were unresolved.
The owner's subsequent “Please continue” authorized the resumed work below.
The old pause figures are historical; current results are in the packet.

## Resumed fixed-family shape closure

All statements in this section apply to the association prefix above, with
ordinary immutable values, the accepted four-file origin and no interface
route. They are source arguments, not properties inferred from a successful
parse or from a native counter. The frozen `family-shapes.json` records all
499 direct declaration/marker spans after removing WhyML comments. Its
scanner implements the special `(*)` rule **inside** comments as well as
outside (`lexer.mll:108–111`, `lexlib.mll:82–96`). It splits only the retained
family's outer declaration positions; the two nested match ends in IntInf
remain inside their enclosing declaration. Alphanumeric runs are counted
once and other nonspace characters separately. These units overcount the
selected lexer's compound punctuation, quoted type variables and literals.
The largest declaration has128 units, and the largest clone ancestry has
10 module nodes. These lexical facts do not automatically establish the
semantic bounds that follow.

The source-case restrictions are particularly useful here:

* All user-defined type heads are nullary. The only concrete datatype is
  `Finite int | Infinite`. There are no aliases, records, mutable fields,
  regions, exception declarations/contracts, old-state terms, loops,
  polymorphic recursion or mutually recursive groups. All recursive program
  definitions have a lexical variant. The sole nested recursive definition
  is `HOInduction.f` inside a nonrecursive lemma; a recursive body does not
  contain another recursive group.
* Explicit program formals number at most8. A lexical scope, including its
  surrounding program formals, a result binder and nested formula binders,
  needs at most16 variables. The polymorphic family is SumParam (`'a`,
  `'b`), Iter (`'a`) and the fixed equality/function/WF/tuple adapters.
  Source substitutions for abstract cloned types are nullary types.
  Each program use of a routine supplies its complete actual argument list.
  Higher-order variable application is an application of the fixed function
  adapter; it does not inline a routine body. The logical higher-order use
  of `ltof` introduces only its two-argument mapping wrapper.
* The recursive groups are singletons. There are no or-patterns. The only
  program matches are IntInf's two nested one-column matches and its
  two-column pair match, using the two fixed constructors. The pattern
  compiler has at most two columns of datatype case distinctions, hence
  at most four leaves; allowing64 intermediate pattern states covers its
  wild, constructor and continuation cases (`pattern.ml:16–170`).
* No explicit `let` or `val` declaration belongs to any transitively cloned
  target. This does **not** make `clone_cty` unreachable: Typing creates a
  `Cany` lemma wrapper for each eligible proposition (`1567–1580`). These
  generated wrappers are cloned. A `Uuse` retains its module value rather
  than cloning that module's program bodies (`pmodule.ml:1590–1634`). Thus
  clone traversal never clones a selected recursive program body. The
  selected `clone_cty` branch maps generated `Cany` signatures/contracts;
  its region/write/exception paths are empty.

Type shapes are closed under these cases. Nullary heads and type variables
have mass1; function/tuple constructors have mass `1+sum(child masses)`.
Source argument/result types have mass at most5; a curried signature with
at most8 such arguments has mass at most49. A subapplication selects a
subtype. Type-variable instantiation in SumParam and Iter preserves their
shown source type variables; the function adapter selects source argument
and result types. Nullary clone substitutions do not duplicate a child type.
Allow64 for every ordinary stored logical/program type, including generated
mapping signatures. A failed logical `ty_match` can materialize its partial
substitution for an error; without assuming success, replacing each of at
most64 occurrences by a type of mass64 gives4096 for that diagnostic type.
It is not exported as a successful source type. Ity matching failure itself
is not an additional logical-type traversal.

The ordinary tuple-key set is `{0,2}`. Unit, the Lex pair, IntInf's pair match
and length tests of the function/tuple heads produce those keys; other heads
are nullary. `cty_from_formula` has no multiple existential result on this
family (Div2's single existential becomes the single result directly).
`vl_of_mask`'s exception cases are absent. A present tuple-registry entry
still belongs to the symbol that installed it: before Ident wrap its key
identifies that physical symbol, and strong-table resize moves whole
key/value nodes. An integer memo hit likewise returns its own integer key's
body. Loss can cause another construction, a mismatch or an escaping
failure; it cannot turn a selected pair into an arbitrary initial arity.
The earlier larger A/K bounds remain valid and are retained as padding for
publication-body accounting.

Use the following stored measure: count every term and pattern occurrence,
each binder/formal slot (including unused ones), each `bv_vars` key, each
`bv_subst` key and every occurrence in its saved value. Count free-variable
prepasses as additional visits, rather than treating the Wty memo as their
owner. Types are measured separately by unfolded occurrence count.

For original callable `rs_cty` payloads,1024 slots bound the complete
pre/post/variant term skeleton. Each selected syntax unit creates at most
four term/pattern/binder slots in these annotations; the128-unit declaration
bound leaves512 slots. Generated result/signature posts, a DECR application
and the two-argument logical mapping wrapper fit the remaining512. There is
no copied callee specification in a routine's own lexical annotation list.
`create_rsymbol` adds a signature-derived post, and `rec_fixp` rebuilds from
the unchanged `Cfun` annotation lists before adding one DECR precondition.
An instantiated call's `cty_apply` result is attached to that expression; it
is never written back into the callee's `rs_cty` (`expr.ml:1230–1249`). This
separates source callable contracts from larger expression payloads.

A generated `Cany` wrapper starts from a pure formula of at most512 skeleton
slots. `cty_from_formula` opens its outer forall prefix, then substitutes
its program parameters. At most16 saved keys and16 current free keys per
binder suffice; saved values here are variables. Thus
`512*(1+16+2*16) < 32768` bounds its complete stored contract. `clone_cty`
renames arguments and maps terms (`pmodule.ml:902–956`). `t_gen_map` maps
existing saved keys/values and patterns without adding a binder or a saved
key (`term.ml:1085–1173`). Therefore clone ancestry does not exponentiate
this measure. The same argument covers failed prefixes of those maps.

A direct program `cty_apply` traverses the **original** callable payload,
not a previously instantiated call. Its substitutions contain at most16
variable keys, with variable values. Including `bv_vars`, saved keys and
saved values gives the conservative65536 stored slots for its result.
`cty_apply`'s free-variable prepass, type substitutions, copied formals and
oldies must all be charged even when the call later fails. Here oldies are
empty, but their absence follows from the source rather than the cache.

Program declaration conversion needs a different measure from a stored-term
remap. Its nonunit callee posts are signature apps or the fixed short
equality/division/min/max contracts; their first post has at most32 skeleton
slots. Pure conversion therefore has at most4096 opened skeleton slots per
declaration. `t_let_close_simp` substitutes a non-small expression only at
one logical occurrence (`term.ml:1688–1714`); a small term is just a variable
or constant. The safe opening fold used by logical call-graph construction
opens a binder before visiting its body (`term.ml:1284–1294`), rather than
visiting every obsolete saved-map entry. This justifies its opening charge
without assuming that the complete stored term has the same size.

No general complete-stored-size bound for a program declaration diagnostic
operand is exported here. Such a bound is not substituted for a missing
constructor demand: the selected Cfun declarations are not cloned or sent
through a type-remapping backedge, `cty_apply` consumes original callable
contracts, and the later `pd_syms` scan is bounded by distinct identifier
origins below. The separate callback analysis determines whether any general
diagnostic pretty-printer is reached. The exported shape interface supplies
only the type/contract bounds established above, with its exact scopes.

## Ordinary constructor budget

Let S be the accepted expanded source-byte sum for one root. Charge each
lexical application/operator or binder occurrence to its nonempty source
position; generated signature/DECR/result nodes are charged to their owning
declaration. The clone recurrence already repeats that declaration's B(m)
charge for each actual clone visit. The following allowances are per
expanded source byte, **not per distinct term or successful declaration**.

Recursive effect repair needs a finite pass argument. On this pure family
all region/write/reset/taint/exception sets stay empty and `eff_oneway` stays
Total. External reads range over at most16 fixed source variables; spoils
range over at most two source type variables. Read/spoil union can only add
one of these, and ghost/mask can each change once. Formal removal uses the
same formal symbols at every pass. No new external read variable is created
by routine renaming. Thus at most20 strict changes precede stability.
Including initial expression construction, the first recursive replacement,
the final declaration conversion and the two-candidate initial overload
probe fits32 constructor-bearing passes per lexical application site.
The singleton/non-nested-group restrictions prevent multiplication of these
passes. Resolved `Capp` replay calls its selected routine directly; it does
not repeat overload selection (`expr.ml:1193–1309`).

The repeated notation probes do matter: the import merge retains at most
one routine per first-argument type (`pmodule.ml:98–116`). The overloaded
names in this family are the int/real scalar arithmetic/comparison names;
source-local replacement of the same type removes its predecessor. Hence
there are at most two candidates at a selected notation site. Generated
lemma names and polymorphic higher-order routines do not form these
notations. Failed probes are included in the32 allowance.

| Category | Ident and Hsty upper, each per S byte | Source transfer |
| --- | ---: | --- |
| Actual `cty_apply` entries, including overload failures and effect repair | `32 * 2^18 = 2^23` | At most1024 original stored slots,64 type occurrences per slot, plus the separate free-variable pass, up to16 type-error operands of4096, and copied argument/result types. Their sum is below `2^18`; Ident's binder/key copies are smaller. |
| Other term/contract maps and logical-definition validation | `2^20` | At most256 stored slots per lexical origin in the cloned pure/Cany family;16 mapping/opening/validation visits, two type callbacks per slot and64 type nodes give `2^19`, leaving the other half for declaration wrappers. Clone ancestry is already represented by S. |
| Direct typing, type reification, symbol/metadata creation and failed type operands | `2^18` |16 local construction/reification passes,64 type/signature slots and64 unfolded type nodes give `2^16`; four alternatives cover preliminary/final heads and failure operands. Matching/folding alone adds no writer. |
| Pattern conversion/exhaustiveness and logical call-graph construction | `2^18` | The64-state selected pattern envelope and64-node type envelope fit inside the allowance, including fresh variables. Logical call-graph construction opens each stored binder once; subsequent call-vector closure operates on arrays and existing identifiers and has no six-owner constructor. |
| Ordinary calls to lower tuple constructors, every call treated as a miss | `2^20` | At most `2^16` tuple-entry/type-mask tests per source byte, each with at most16 direct/transitive Ident or Hsty writes for n=0 or2. Type remapping itself does not call a tuple test. The tuple tests are from syntax, masks/result conversion and fixed type adapters, including abandoned prefixes. |

The sum is `10.5 * 2^20 < 2^24`. Export `2^24*S` for each of Ident and Hsty.
The identical upper values do not assert identical behavior. This accounts
for the type writes in `cty_apply`, generated-Cany `clone_cty`, `clone_ty`,
`ty_of_ity`, `create_cty`, logical term instantiation, provisional typing,
pattern checks and tuple children. Ity's different weak tags are not
mislabelled as Ty.Hsty writes. General program declaration term conversion
has no Cfun clone/type-remap backedge; its openings and direct reifications
are covered by the listed categories, without treating a printed/opened skeleton as a complete saved-map traversal.

For Hstdecl, there are at most four prospective declaration products per
source slot. Each product's `pd_syms` contains identifiers from its source
and generated binders/signatures. Renamings across the at most32 local
passes, at most128 lexical origins and at most16 binder/signature additions
provide fewer than `2^16` such identifiers; using `2^18` per product is
conservative. Each triggering identifier can call `use_export` once in
`add_use`, and `Theory.use_export` may request a Use even when a module was
already used. Charge these **requests**, not successful new modules.
The resulting `4*2^18*S` allowance, plus direct decl wrappers, source
uses/clones/metas and the three initial module uses, is below `2^21*S`.
Generated `pd_meta` entries go directly to Theory and are also charged.
No caching assumption removes a repeated `create_use` here.

These phase bounds are the main independent source-review obligation. The
focused checker verifies their frozen inputs and arithmetic, not an OCaml
control-flow theorem. A source reviewer must challenge the family exclusions,
shape preservation and pass allocations together; a checked multiplication
alone is not their justification.

## Five lower memos: charge every call

No lower-memo successful-persistence theorem is needed. A call may execute
its body on **every** entry. Interrupted resize, ordinary constructor failure,
no-data restore hits and lost insertions therefore receive their full body
charge without any new event budget. The following counts include actual
`id_register`/Hsty sites and exclude children listed in the third column.

| Lower body | Direct Ident / Hsty | Lower children |
| --- | --- | --- |
| `ts_tuple n` | `A+1 / 0` | none |
| `fs_tuple n` | `1 / (A+1)` | one `ts_tuple` |
| `its_tuple n` | `A / A` | initial `ts_tuple`, and `its_of_ts`'s `is_ts_tuple` call to `ts_tuple` |
| `rs_tuple n` | `(A+1) / (2A+1)` | one `its_tuple` and one `fs_tuple` |
| `pd_tuple n` | `0 / 0` | one `its_tuple`, one `rs_tuple`, and a publication `tuple_theory` call |

The `rs_of_ls` argument variables contribute A registrations/type requests;
`make_post` contributes one result variable, and `create_cty.check_post`
converts the A-child result type. `mk_rs` reuses the lsymbol's name.
`mk_itd`/`Pdecl.mk_decl` perform no direct six-owner write. Treating every
child call as a miss gives `(3A+2,A)` for an its body including children and
`(5A+5,4A+2)` for an rs body including children. A pd body has lower children
`(8A+7,5A+2)`; its tuple-theory callback is counted in J, not duplicated here.

A publication tuple-theory body has lower children `(2A+3,A+1)`.
A publication tuple-module body enters `pd_tuple` at most once; its final
`tuple_theory` call is already in J. Thus all lower children of the two
publication bodies contribute at most

```
Ident_lower_publication <= J * (10A+10)
Hsty_lower_publication  <= J * (6A+3).
```

This is a call-tree count, including every failed prefix. The initial/memo
state is irrelevant to its safety. Ordinary direct lower calls are included
in the `2^20*S` phase above using their actual selected arities0/2. The five
memos therefore receive no borrowed128 resize allowance, no fresh e, and no
per-key success shortcut. Publication J itself retains its accepted separate
128 allowance and the same process-global e.

## Full lookup vector and integration interface

For each process let `X=2*E*S_real`, `D=8*E*S_real+J`, and retain the earlier
`E=3N+e`, `A=max(I,38678)` and J. The complete author vector is

```
Ident            increments = 2^24*X + (10A+12)*J; requests = 0
Decl.Hsdecl      increments = D;                  requests <= D
Ty.Hsty          increments = 2^24*X + (7A+4)*J;  requests <= same
Theory.Hstdecl   increments = 2^21*X + 2J;         requests <= same
Task.Hstask      increments = requests = 0
Task.Stdecl.Hcpt increments = requests = 0.
```

Unique Hsdecl requests retain their separate `8*E*S_real` upper. They are
not added to D; setting the hashcons request upper to D is conservative.
`compose.lookup_vector(case,e)` exports this six-owner vector for the R60
shared-demand API. It is already weighted for the whole suffix and is joined
**once** as `lookup_library_constructors`. No root/save multiplier is applied
by the caller. The separate `shape_interface` supplies the type and stored
payload bounds for later work; no diagnostic-printing vector is claimed here.

The earliest-violation reasoning is now applicable to the complete lookup
component: before the first combined violation all preceding source objects
satisfy the association/shape lemmas, and the prospective offending operation
is included in the bound. The lead still needs the actual printer and other
callback residuals, the combined native backing transfers, and independent
acceptance of this source argument before concluding that no such violation
can occur. Mathematical work totals and type/contract shape bounds are not
asserted to be native counters, allocation requests or a RAM gate.

## Author freeze record

Selected model/effort: GPT-6 Astra/Extra High; runtime settings and token/cost
measurements are unavailable. The measured resumed tail interval was1593s
(15:04:34–15:31:07 UTC); earlier resumed work was not clocked, so this is not
a whole-round or whole-team elapsed-time claim. The final focused run passed
128 checks in2.489039s on Linux x86_64, with `git diff --check` passing. It
ran no target, native capture, proof suite or predecessor checker. The full
vector is an author result awaiting independent semantic review; the exact
commit and review disposition are the lead's integration record.
