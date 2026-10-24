# Clone-caller review — bounded attachment accepted

Author freeze `b5cfa9c1a501eefdd5db89670ca60ccbc399e036` is **accepted for the
stated ordinary-Main/fixed-origin clone-map attachment and direct caller
recurrence**. No material author finding remains. This does not complete
native allocation demand, source-to-VC stored construction, kode/SPWP, #202
or #119. The earlier bridge/repair `3f4f6143c206518bf257d3d9b63cee2a08d14bcd`
and review `536c35cd2c36ac43dee39e1d6d8a8321d60fc070` remain unchanged.

The new reviewed inputs are the appended continuation in
[retained-main-construction-demand.md](../research/retained-main-construction-demand.md)
and its `clone-callers/` packet. The [receipt](../evidence/review-main-clone-callers-20261024/receipt.json)
and [audit result](../evidence/review-main-clone-callers-20261024/audit-result.json)
bind the exact ten author files, providers and source archives.

## Actual origin and state boundary

The accepted import graph plus the inspected scalar/array emitter branches
supply 64 fixed origins and five additional ordinary-Main origins, 69 total.
The six Main choices include the already-fixed Dynamic_Discrete. Rank-one
array and ordinary integral representation premises are retained; arbitrary
WhyML modules are not covered. The array-copy path is a use/alias, and
`Include_Decl` translates even `Clone_default` includes to use declarations.
Genuine clone declarations use the separate converter branch. The accepted
Image templates add no program-module clone origin.

The independent inventory agrees on all 352 retained modules, 97 dependency
nodes, 26 nullary lexical-let candidates, four corpus program globals and
three `val eq` refinements. Each candidate has its own `in` before another
binding/declaration; the retained snippets are logical lets except for the
local allocation in `SetImp.singleton`. Plain nullary program globals occur
only in standard Main (`__HEAP`, `no__return`, attribute-bearing
`spark__branch`) and Random63 (`s`). Neither module is an origin, Random63 is
outside the dependency closure, and standard Main's state names occur only
at their declarations. Other file-backed dependency modules do not refer to
them. Uses retain references rather than copying their variable declarations
into `cl.pv_table`.

One dependency node is not a file-backed corpus module:
`why3.WellFounded.WellFounded`. The reviewer explicitly inspected
`pmodule.ml:385–473`: this builtin imports the stateless primitive modules and
adds closed accessibility/well-foundedness declarations with
`create_pure_decl`. Its binders are closed by `t_forall_close` and
`make_ls_defn`. It supplies no foreign program variable. The review evidence
records this extra source span rather than silently ignoring an unknown node.

The absence of state names alone would not exclude generated state. The
source gates make that conclusion adequate here:

- The generated Main module is never a clone original. Converter
  `Clone_declaration` emits only type/function/predicate substitutions and
  proposition policy. `Typing.type_inst` puts CSfsym/CSpsym substitutions in
  `mi_ls`; `mi_pv` and `mi_rs` require CSvsym. A logical-symbol replacement
  changes an application symbol without inlining a target program body or
  importing its reads.
- Fixed originals use the WhyML parser. Its if-rules build Eif, typing builds
  DEif, and `Expr.e_if` combines exactly the three children/effects. These
  paths do not synthesize `spark__branch`. Proxy, result, pattern and oldie
  variables have the lexical source constructors covered below.
- All retained module headers lack an interface, and the accepted generated
  Modules entries carry `None`. The inspected `open_module`/`close_module`
  gates therefore exclude `mod_impl_register` and its implementation-copy
  clone traversal. This is an invocation/configuration-bound claim.
- The origins contain no program recursion, loops, handlers, explicit type
  invariants or `by` witnesses. The parser's optional witness and typing's
  `Option.map` construction preserve `None`; ordinary invariant/witness
  cloning therefore adds no omitted root family here. Generated callable
  lemmas use closed input formulas and fresh formals, producing LDsym records.

These facts exclude the relevant foreign program-variable input to this
clone frontier without asserting that ordinary Main itself has no state.

## Whole inherited and lexical map history

`cl_init` starts with `empty_clones`; it validates instantiations but does
not seed `pv_table` from replacements. The declaration-boundary induction is
valid for the classified origins. Top-level parameterized declarations are
LDsym; nullary RKfunc/RKpred declarations get their native Cfun wrappers;
top-level RKlocal is rejected; plain nullary LDvar and program LDrec are
absent. Their representatives are RLnone/RLls/RLlemma, so `sm_save_rs` leaves
`sm_pv` unchanged. The ordinary PDlet write-back consequently retains an
empty `pv_table`. The three fixed routine refinements use `cl_save_rs`, which
also does not populate that table. Uses, metadata and pure/type declarations
do not supply a hidden write-back path. Earlier clone output preserves these
properties, including its generated pure refinement VCs.

Inside each declaration, the inspected native constructors establish the
strong premise required by the repaired generic mapper:

- `clone_cty` freshly clones each formal before preconditions and each oldie
  before normal/exceptional posts. Result variables are epsilon-bound.
- A Cfun body receives the exact cloned formals and oldies via
  `sm_save_args`/`sm_save_olds`. Local LDvar initialization uses the old scope,
  then installs its newly registered symbol for the subsequent body. Persistent
  branch/local maps do not escape back to the top-level map.
- A local RKlocal representative gets a fresh RLpv. Program patterns allocate
  distinct variables with a per-pattern name table, reuse the same variable
  across Por alternatives and reject incompatible duplicates. The native
  exception/index extension rows also preserve scope and freshness, although
  those program forms are absent in the inventoried origins.
- `find_old` creates at most one oldie per current pvsymbol in each fresh
  label table. Reversing that relation in `sm_save_olds` is injective because
  the current-variable map is injective. `clone_cty` adds all newly allocated
  oldies to reads before `create_cty` intersects the oldie map, retaining
  body-only oldies. Applied Capp contracts are reconstructed through `c_app`;
  they are not confused with these original Cfun/Cany maps.

The original module is constructed before its clone starts. Every new map
target therefore postdates all identities in its stored graph, including
keys, patterns, triggers and dead saved images, under the transported Ident
no-wrap premise. This establishes the repaired bridge's stronger disjointness
condition, not merely injection. Type compatibility follows the matching
symbol/type substitutions in `clone_ty` and `clone_ity`: type projection
forgets region metadata, the formal-instantiation cases correspond, and
`ty_table` replacements are restricted to pure symbols. Region cloning uses
the matching symbol and argument projection; aliases retain that projection.
`create_pvsymbol` consequently gives each fresh target the required term type.

Correct source caches and the accepted saved-support invariant connect lexical
coverage to every saved image. This is a source/history argument under those
existing premises, not a claim that the finite `History` fixture manufactures
valid arbitrary native inputs. The original #211 capture example cannot enter
through the derived fresh map history. Pure `clone_fmla` entries use empty
maps on closed declaration axioms: `make_ls_defn`, `create_ind_decl` and
`create_prop_decl` check that closure in the retained source.

## Direct counts and the remaining construction boundary

The direct count table agrees with `clone_expr`, `clone_cexp`,
`clone_let_defn`, `clone_decl`, `clone_pdecl` and the ordered unit traversal.
Cfun/Cany map every pre/post/xpost root once; only Cfun traverses a body.
Capp makes its direct `c_app`. Assertions and pure expressions contribute
one root each. Dlogic and Dind include formulas constructed solely for a
substitution comparison. Dprop respects its skip guard. Routine refinement
includes both `clone_cty` and the direct `c_app` before its separate VC work.
Uses and Uclone metadata do not replay the referenced module's declarations.
Failed comparisons retain the work already performed and stop a finite prefix.

The recurrence uses the actual transformed records at each clone boundary.
It does not reuse a numerical weight from an unchanged ancestor: substitution
can remove definitions or change propositions, and refinement can produce new
records. The accepted #185 declaration fold supplies the typed records,
contract lists, scopes and guard decisions needed for these direct counts.
Its opened-term representation suffices for root/list multiplicity; it does
not supply saved-map native allocation history or eliminate that separate
obligation. Thus the continuation is not circularly assuming the complete
storage-demand result it still leaves open.

The author's 27 term roots / three contracts / three direct applications are
explicitly a diagram. The reviewed result is a finite source/configuration
recurrence, not a measured or fixed whole-Main total. Internal term/type/effect
builders, map backing requests, namespace operations and kode/SPWP remain to
be priced. Apply the accepted mapper separately to each actual stored root;
this review does not turn direct entry counts into a complete native byte bound.

## Independent evidence and review record

The [new audit](../evidence/review-main-clone-callers-20261024/audit.py) passed
**2,035 assertions** in **1.345268225 seconds** on Linux. It independently
scans the retained source corpus, reuses only the accepted import graph as
data, and checks ten exact author files, nine providers, three archives,
36 complete source files, 50 spans and 112 anchors. Thirty constructed lexical
histories exercise 300 root premises at the accepted bridge, including saved
images, fresh formal/oldie/local/pattern/routine targets, persistence and
oldie reversal. Focused caller diagrams check comparison/refinement demand
and changed records at the next clone boundary. Unknown caller kinds fail.
The author inputs remained unchanged. No author/predecessor checker was
imported or replayed; accepted bridge code was reused as a provider.

One audit program was developed in three attempts. The first stopped because
the reviewer extractor expected WellFounded to be a corpus module. The second
mistook WhyML's `(*)` multiplication operator for a comment opener. Source
inspection resolved both: explicit builtin classification, and the lexical
special case in `lexer.mll:108–111`. The third attempt was the sole successful
run. These were reviewer tooling repairs, not author defects; their tool wall
times were 0.309310613, 0.611124280 and 1.333076961 seconds respectively.
Finite inventories and diagrams support the reviewed source induction; they
are not machine-checked universal proofs or native execution measurements.

Selected reviewer model/effort: **GPT-6 Astra / Extra High**. Runtime
confirmation, token counts and cost were unavailable. The recorded interval
was 05:09:39–05:18:11 UTC on 2026-10-24, **512 seconds**, covering setup,
source inspection and audit development; it excludes later report/commit
work and is not whole-team time. The live harness goal read returned null.

No native compiler/prover build, tool/pin change, Oracle/admission change,
production #88–#94 work or #206 configuration adoption occurred. The one global
`e <= 2`, two save-entering callbacks and three saves remain unchanged.
No GitHub, goal or CLI-memory write was made. Parent handles integration,
publication and issue/session bookkeeping. The review adds only this report
and its evidence directory.

| Round | Selected setting | Intended result | Achieved result / rework | Available evidence |
| --- | --- | --- | --- | --- |
| Clone-caller continuation | GPT-6 Astra / Extra High; runtime unconfirmed | Challenge actual inherited-map safety and direct source caller recurrence | Bounded attachment accepted; two reviewer audit-tooling corrections, no author repair | 512 s recorded interval; one successful 2,035-assertion audit in 1.345268225 s; tokens/cost unavailable |
