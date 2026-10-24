# Main stored construction: type instantiation and caller obligations

This #202 / #119 unit proves a stored-term invariant needed to connect native
contract instantiation to the accepted
[case-free substitution kernel](retained-main-why-storage.md). It gives the
generic mapper's stored-node, type-callback and freshening recurrences and
attaches them to `Ity.cty_apply` stage 4. It identifies `Pmodule.clone_term`'s
native dispatch, but that caller's preservation result remains conditional on
the map coverage and capture premises below. **It does not
close source-to-initial-VC storage demand.** The source-dependent typing,
clone, kode, extraction, reflow and SP/WP caller construction still has the
obligations listed below. In particular, no arbitrary typed-term fixture or
caller-demand certificate becomes a Main admission input here.

The [packet](../evidence/retained-main-construction-demand-20261024/README.md)
uses only retained sources at Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`; its manifest identifies complete
files and exact relevant spans. It reuses the accepted kernel implementation
without replaying its checker. Native execution, captures and compiler/prover
runs are all zero. These are mathematical constructions and source arguments,
not measured dynamic allocation counts. The #211 repair corrects the original
freeze's insufficient generic/clone premise; it is not a native Why3 change.

## Saved-image support, including capture

For a stored binder write `V = bv_vars` and `H = bv_subst`. In addition to the
accepted well-typed, finite, cache-correct graph premises, retain:

```text
V[v] > 0 for every stored cache entry v;
FV(image) ⊆ dom(V) for every image in H;
the same properties recursively hold inside body, triggers and every image.
```

`FV` is the native cached free-variable operation, counting saved-image
semantics in the surrounding scope. This invariant includes dead saved keys;
it does not remove their images. It is stronger than merely checking an
opened formula's variable set or its term-node count. An arbitrary fixture
with a hidden free variable in an old image need not satisfy it.

Here is the constructor/substitution proof. New closing operations use
`bnd_new` with **empty H** (`term.ml:785–795`); removing bound variables from
the new positive cache cannot invalidate an image property because there are
no saved images in that new frame. Existing inner frames retain their own
invariant. The `t_vars` rows add positive occurrence counts and never insert
zero coefficients.

For a substitution M on an existing frame, let `R = M restricted to dom(V)`.
If R is empty the native frame is returned. Otherwise `bv_subst_unsafe`
constructs

```text
V' = (V without dom(R)) + Σ[v in dom(R)] V[v] * vars(R[v])
H' = map (subst R) H  left-biased-union  R.
```

This is the actual old-image rewriting order, including left-biased union;
it is not an eager replacement of the whole stored binder. By the ordinary
substitution support induction,

```text
FV(subst R image)
  ⊆ (FV(image) without dom(R))
      ∪ ⋃[v in FV(image) ∩ dom(R)] FV(R[v]).
```

The first set is in `dom(V')` by the incoming invariant. Each variable in the
second set has a positive contribution because `V[v] > 0`. Every new image
R[v] has the same positive contribution. Left-biased union retains one of
these already-valid alternatives. Positive additions and products preserve
positivity. Mutual induction on the finite stored graph establishes the
recursive clause for image/body subcalls. Native arithmetic must still pass
the accepted kernel's occurrence guards; this is an unbounded-integer proof,
not permission for a wrapping coefficient.

The proof does **not** assume that `dom(V)` is disjoint from the frame's bound
variable identities. For example, substituting `x ↦ v` into
`forall v. R(x,v)` can store an image mentioning the same identity v as the
binder. That occurrence is free in the image: interpreting an image drops
its owning binder frame. Fresh opening and generic mapping must preserve
that distinction. The packet checks precisely this example, including type
instantiation; its two occurrences remain free and bound respectively.

This establishes the invariant from source-built ordinary closing and the
accepted substitution/opening operations. It does not assert that every
unexamined typing helper has already been attached to those constructors.

## The actual generic mapper

`t_subst_types` first obtains `t_vars t`, then `gen_mapV` creates a new
variable only when `ty_inst mapT` changes that variable's type. Next
`t_gen_map` traverses the stored graph. Only afterwards does
`fold2_inter` attach supplied term images to the newly typed variables;
`t_ty_subst` finally runs the accepted term substitution
(`term.ml:1163–1173`). A simultaneous type-and-term substitution is therefore
not one leaf substitution on an opened formula.

The critical `gen_bnd_rename` row (`:1103–1111`) is:

1. Rename each key of V through the **incoming** variable map h, retaining
   its occurrence coefficient.
2. Fold **all** entries `(key,image)` of H. Type-rename each saved key,
   extending a running map nh, and map its image through `fnE`.
3. `fnE` was closed over the original h at `:1114`. It does not use the
   progressively extended nh. Return nh and the newly constructed V/H.
4. Rename the frame's bound variables after the saved-key fold. Use this
   resulting map for body/triggers. A let's defining value still uses h.

### Coverage and capture compatibility — correction for #211

Type compatibility and injection alone do **not** make this a
capture-avoiding transformation. On `forall v:int. R(x,v)`, take the injective
outer map `{x -> v}` and identity type/symbol maps. The native mapper retains
the unchanged bound v and produces `forall v. R(v,v)`, while its mapped cache
still contains `v:1`. Saved support can hold even when this cache is wrong.
The independent review exposed this counterexample in original author freeze
`5d9ed9375c4db7fd92b8c7317402754c8fede354`. The earlier unconditional
capture-avoidance statement and clone attachment under mere injection/type
compatibility were incorrect and are superseded here.

Use the following **sufficient root premise**. Let `Ids(t)` include every
variable identity in the input stored graph: free and bound variables,
pattern variables, cached and saved keys, bodies, triggers and all saved
images. For the initial map h require:

```text
FV(t) ⊆ dom(h);
h is injective;
h(v) = v or h(v) ∉ Ids(t), for each entry v in h.
```

Also retain correct positive caches, saved support, type/symbol-compatible
callbacks, and a transported unwrapped Ident history covering every input and
map symbol. All newly created symbols must be fresh relative to those inputs
and each other. The disjointness condition is deliberately stronger than
necessary; a map failing it is outside this bounded preservation theorem,
not necessarily an invalid native call. In particular, an arbitrary inherited
clone map is not assumed to satisfy it. The proof wrapper checks support,
coverage, injection and disjointness without invoking the type callback; this
check is mathematical input validation, not native construction demand.

Here is how the premise propagates. At a binder, h covers V. Correctness of
the input cache implies that every variable in its raw body/triggers is
accounted for by V, that frame's bound variables or its saved keys: an
unbound/unsubstituted occurrence would otherwise contribute positively to V.
Saved support puts every image's free variables in V. Thus mapping each image
with the original h is covered; extending h with every saved key and then
every bound variable covers the body/triggers. The same argument applies to
case patterns and their branch bodies.

Extensions use either the variable's unchanged old identity or a new globally
fresh symbol. A nonidentity image of a different incoming variable cannot
collide with an unchanged binder/saved key because that key is in `Ids(t)`;
it cannot collide with a newly freshened symbol because the owner history
covers the incoming range. Distinct freshenings cannot collide. When the same
old identity has both an outer free role and a local bound/saved-key role,
mapping an image still uses the original outer h, while the body uses the
local extension. Hence intentional shadowing follows the native frame
semantics without capturing a *different* free variable. Induction over the
stored graph preserves this separation, type compatibility, positive/correct
caches and saved support. In particular, the mapped image's support lies in
the renamed V and different cached free keys cannot collapse.

`t_subst_types` **constructs** the sufficient premise: `gen_mapV` covers every
root free variable, keeps the original symbol when its type is unchanged,
and otherwise allocates a globally fresh symbol. It is injective and all
nonidentity targets are outside `Ids(t)`. No external capture-freedom
certificate is needed for this entry. The later term substitution remains
the accepted capture-avoiding kernel operation. The packet preserves the raw
native counterexample as a negative regression and rejects it at the proof
wrapper; it does not change native behavior by freshening unchanged binders.

All stored term occurrences are visited once, including triggers and every
saved image. The generic mapper preserves term constructors and binder-map
cardinalities; it does not open and flatten the binder. Its output denotes
the ordinary capture-avoiding type/symbol transformation of its input.
Term attribute copying is retained. Physical record reuse is not assumed.
The denotation and cache-correctness claims in this paragraph require the
coverage/capture premise just proved; constructor-shape preservation alone
does not imply them.

The same mapper has explicit `Tcase` and all five native pattern rows
(`Pwild`, `Pvar`, `Papp`, `Por`, `Pas`). Each case branch applies the same
V/H rule, separately type-renames its pattern-variable set, maps the pattern,
and maps its body using the extended map (`:1130–1136`). The packet implements
this generic context row and checks its shape. **It does not extend the
accepted substitution or candidate gate to cases.** Its composed
`ty_subst` interface rejects a case anywhere in its stored input. Generic
mapping preserves case-freedom when it is present and preserves existing
cases when it is absent; mapping is no proof that an entire imported context
was case-free.

## Demand recurrences and owner transport

Count occurrences over the actual stored input, recursively including all
saved images. Let N be term occurrences; K saved entries; B bound-variable
slots (including distinct pattern variables per case branch); P pattern
occurrences; F the root's cached free-variable cardinality. Let A be typed
application occurrences, X variable-term occurrences and C constant-term
occurrences. For one `t_subst_types` call:

```text
generic term visits = N;
generic pattern visits = P;
gen_fresh_vsymbol attempts = F + K + B;
Ident increments = number of those attempts whose type changes;
outer type-callback requests = F + K + B + P + X + C + A.
```

Repeated variable/type occurrences count repeatedly. F callbacks occur in
`gen_mapV` **before** the public generic mapper creates its
`Wty.memoize 17` wrapper. The remaining callbacks share that one local
ephemeron table. The wrapper's lookup count is `K+B+P+X+C+A`; its successful
set count is at most that number, without a no-GC premise. Each independent
root gets a new table. There is no once-per-module or once-per-type credit.

For `ty_inst` on a resolved canonical type, count all callbacks as misses for
the purpose of bounding its work. Each callback visits the old type's syntax;
each old `Tyapp` occurrence requests `Ty.Hsty.hashcons`, including nullary
and unchanged applications (`ty.ml:126–128,234–236`). A `Tyvar` lookup returns
its image without recursively substituting inside that image. Consequently
the sum of old `Tyapp` occurrences over those callbacks bounds Hsty requests
and hence new tags. This bound does not claim that every lookup misses or
change the native canonical-type equality used by the freshening test. The
still-live input type remains available for canonical equality when the
result is unchanged. Cloning's different type callback needs its own bound;
the generic mapper only supplies its callback multiplicity.

Feed the same Ident history through free-variable freshening, saved-key and
bound-variable freshening, the accepted term substitution, and later opening
or gate operations. Similarly add every Hsty request to the existing Hsty
history. The [cut-C provider](retained-main-entry-capacity.md) supplies
populated upper histories, not empty tables or a renewed counter. For its
current accepted R56/R78 maximum, Ident enters at most 27,104,344 and Hsty
at most `floor(135521724/3)`; intervening construction must be included before
using a later endpoint. The exact-role/configuration relation remains
required. Proposed #206 timing configuration is not included.

The packet's map/local-byte fields are only the reused kernel charges and
the explicitly recorded map operations. **They are not a complete native
byte bound for this new mapper.** Generic constructors' type checks, pattern
set construction, callback frames, Hsty and ephemeron backing requests still
need their source/native request consumers. The request recurrences above
make those consumers concrete; an arbitrary 4,096-byte charge on every new
function would not establish them.

## Source callers attached by this unit

For a nontrivial `cty_apply`, stage 4 maps every precondition, every
epsilon-closed postcondition and every exceptional postcondition list
(`ity.ml:1480–1489`). Put
`r = |pre| + |post| + sum_x |xpost[x]|`.

- If the source-computed final `same` test holds, there are r ordinary
  `t_subst` calls and no generic-map tables. The test includes identity
  type-variable substitutions even when an earlier Ity comparison differed.
- Otherwise there are r `t_ty_subst` calls and r local generic-map tables,
  with the recurrences above evaluated separately on each stored contract.
- The earlier `same && vl=[]` return (`:1473`) bypasses stage 4 entirely;
  stage-1/2 work already executed is not refunded.
- Saturation and empty oldies remove the remaining-formal and oldie
  freshening loops, as established in the accepted Main typing frontier.
  The actual map is still constructed from program pvsymbols and then
  mapped to fresh `t_var` records at `:1471`; its images are leaves.
  Type matching, result/effect instantiation, freeze operations and their
  temporary maps are separate stage-1/2/3 demands.

These rules attach a **call's contract transformation**, not the number of
native calls issued by a source application. For example, overload resolution
may attempt several `Expr.c_app` candidates and catch failures before selecting
one; a count of resolved typed calls does not count those failed prefixes.

For context cloning, `clone_term` calls the generic mapper with `clone_ty`,
`cl_find_ls` and the supplied variable map (`pmodule.ml:672–678`).
`clone_cty` maps preconditions using `sm_args`, normal and exceptional
postconditions using `sm_olds`, after cloning actual formal and old variables
(`:893–915`). These are source dispatch facts, not yet a complete preservation
attachment for clone callers.

In particular, `sm_of_cl` obtains its initial `sm_vs` by mapping
`cl.pv_table` (`pmodule.ml:851–862`). `sm_save_vs`, `sm_save_pv` and the RLpv
row of `sm_save_rs` extend existing maps (`:864–883`); `clone_cty` retains this
inherited map when adding fresh formals/oldies. Earlier declaration cloning
also writes `sm.sm_pv` back to `cl.pv_table` (`:1465`). Fresh formals and oldies
therefore do **not** establish a property of every inherited range entry.
The negative test explicitly retains the capturing `{x -> v}` inherited
entry while adding a fresh formal: the full map remains incompatible.

The exact remaining clone obligation is to establish, at every reached
`clone_term cl sm.sm_vs t`, type compatibility, coverage of the cached
supports reached by `gen_bnd_rename` (the sufficient root condition above
implies it), and capture compatibility of the **whole** inherited-and-extended
map relative to t's stored bodies, patterns, keys and images. This requires an
induction over initialization, prior declaration/lexical `sm_save_*` updates,
unchanged foreign variables and the current formal/oldie additions. That
induction is **not discharged in this unit**. The mapper's conditional
preservation theorem and successful-call request recurrences are available
once that obligation is proved; no claim that the actual clone maps satisfy
it is made here. `clone_ty` demand, routine/type construction and the whole
clone/declaration traversal also remain open as before.

## Remaining source-to-candidate joins

The [#185 construction](retained-main-vc-composition.md) deliberately denotes
opened typed terms and explicitly excludes native fixed-parser/typing
temporary allocations. Its termination argument and the cut-C carrier are
not substitutes for the missing stored construction. These are the concrete
remaining rows within the assigned boundary:

| Row | Required construction demand and domain attachment |
| --- | --- |
| Source/parser/type/declaration fold | Construct actual stored initial contracts through native closing, type inference, proxies, overload attempts and failures; account for types, symbols, attributes and strings. Separate fixed/imported case-bearing context from every contract actually passed into Main's VC construction. The invariant above supplies the saved-image part of the induction. |
| Native clone fold | Prove cached-support coverage and capture compatibility for the whole inherited `sm.sm_vs` history, then apply the conditional `clone_term` rule. Count all reached ordered units and instantiated type/symbol/cty builders, including case-bearing context records, callback type demand and old-return representative histories. |
| Candidate enumeration | Keep Main and each generated nullary Pterm/undefined-Pred `LDsym Cfun` candidate. Internal ignored Cfun checks are Par children, not extra candidates. Count construction before the gate even when a candidate is discarded. |
| k_expr / k_fun | Include pre/post opening, result/proxy allocation, implicit unit enrichment, invariant inspection, assignment maps, location/trace attributes and associated strings at their actual native sites. Accepted program-key U/H measures are not creation counts. |
| term_of_kode | Retain both unwind outputs: value first, then the closedness test and possible predicate unwind. A later `Exit` keeps all earlier work. Returning the original kode on failure does not erase those requests. |
| Reflow | Count construction before dead-continuation deletion and every mark/push temporary, map and continuation wrapper. The retained `3B+2` node bound alone does not count those requests. |
| SP/WP | Derive calls from actual outcome/read/write maps, distinguishing the special Let sequence and general sequence. Include adjustment/advancement substitutions, written-name freshening, quantifier/let simplifiers, attribute relocation, havoc and all temporary formulas. `Vc.ht_written = Hvs.create 17` is shared state (`vc.ml:1334`), not a new table per expression. |
| Selection | After those constructions, invoke the accepted `add_vc_decl` gate on the actual stored candidate with the transported owner state. Stop at entry to `mk_vc_decl`; its outer quantification, injection, matching and declaration creation remain beyond this unit's boundary. |

The next source proof must discharge these rows, rather than defining an
uninterpreted operator that says to count every helper. Successful source
closure requires both actual stored values and caller multiplicities; samples,
opened semantic sizes and source-constructed key unions are insufficient.

The single process-wide `e <= 2`, two save-entering callbacks and three saves
are unchanged. Physical resource premises, current language admission, Oracle
and source/tool pins are unchanged. This bounded result does not complete
#202 or #119, adopt #206 or start production #88–#94.

## Source-attached clone frontier — continuation after the accepted bridge

This continuation discharges the inherited-map coverage/capture obligation
above for the **current ordinary-Main clone origins and the retained fixed
import clone origins**. It does not establish that property for arbitrary
WhyML modules. The bridge and #211 repair remain unchanged; the new
[clone-caller packet](../evidence/retained-main-construction-demand-20261024/clone-callers/README.md)
adds source attachment and direct caller recurrences. Complete native bytes,
other typing work and kode/SP/WP demand remain open.

### Which original declarations can be cloned

Reuse the accepted 21-file import graph, not a new source/version search.
Its 205 explicit clone declarations name 64 distinct original modules. The
ordinary Integer/Boolean/Character/String frontier additionally permits
`ada__model.Static_Discrete`, `Dynamic_Discrete`, `Rep_Proj_Int`,
`Constr_Array`, `Unconstr_Array` and `_gnatprove_standard.Array__1`.
Dynamic_Discrete is already in the fixed set, giving 69 distinct origins.
These choices follow the accepted Main type construction together with
`why-gen-scalars.adb:757–824,1291–1338` and
`why-gen-arrays.adb:1055–1059,2538–2539,2666–2667`. Rank is one and the other
numeric representation alternatives are outside that Main frontier. Scalar
and array helper modules emit references and symbol substitutions; they do
not make an arbitrary Main program module a clone origin.

In particular, `Array_Type_Is_Clone` exports an existing type module and may
add an alias (`why-gen-arrays.adb:1534–1567`). This is a **use**, not another
clone execution. `Include_Decl.mk_include_variant` maps even an include tagged
`Clone_default` to `Use_import`, and `mk_include_declaration` builds only
use declarations (`gnat_ast_to_ptree.ml:125–173`). The separate
`Clone_declaration` branch builds genuine clones (`:1240–1280`). Its
substitutions are type/function/predicate symbols, never program variables or
routine refinements. The accepted Image-model templates do not add another
program-module clone family.

All retained library module headers lack an implementation interface, and the
accepted current native Main Modules entries have interface `None`.
`Typing.open_module/close_module` therefore never reaches
`mod_impl_register` (`typing.ml:1808–1825,1900–1931`). The implementation-copy
`impl_cl`/`mod_table` traversal is not an additional clone caller here.

The new inventory checks complete retained bytes for the 69 origins. It
enumerates every val/let head with comment/string-aware tokens. Logical
`constant`, `function` and `predicate` declarations produce logical routine
representatives, not global pvsymbols (`parser_common.mly:903–907`,
`expr.ml:112–153`). Ordinary top-level functions have parameters. Every
remaining plain nullary let candidate in these origins has its own lexical
`in` before another binding/declaration; they are local terms or the local
allocation in `set.SetImp.singleton`. There is no top-level LDvar, no
top-level RKlocal definition, no program `let rec`, and no type invariant in
these original modules. There is also no `by` token, excluding explicit type
witnesses independently of the invariant check. Copied declarations from an earlier clone satisfy
the same property by induction over the accepted acyclic clone graph.
In particular `Dexpr.let_defn:1801–1841` makes parameterized declarations
LDsym, wraps nullary RKfunc/RKpred declarations in Cfun/LDsym, and rejects
top-level RKlocal. Its only accepted top-level LDvar row is an unqualified
nullary declaration, precisely the source category excluded above.

Across the whole 21-file corpus the four plain nullary val objects are
`_gnatprove_standard.Main.__HEAP`, its `no__return` and attribute-bearing
`spark__branch`, and
`mach.int.Random63.s`. Neither defining module is a clone origin.
Random63 is outside the origins' use/clone dependency closure. Three origins
use standard Main—Discrete_Base, Fixed_Point_Base and Floating_Point_Base—
for types and stateless symbols. No other module in the complete origins'
dependency closure refers to `__HEAP`, `no__return` or `spark__branch`, and
those names occur
in standard Main itself only at their
declarations, so there is no hidden state-reading callable from that module.
Use retains the imported namespace/declarations; it does not copy its
program variables into the clone map. Consequently no reached cloned
contract/body has a foreign program-variable dependency. Unchanged foreign
types and logical symbols remain ordinary references and introduce no free
term variable. This conclusion is tied to the checked source graph, not an
assumption that every imported module is stateless.

This corpus fact is joined to the **origin boundary**, not generalized to
Main's generated body. The only source-dependent clone origins are the six
selected retained module names above; the generated Main module and its
instrumented expressions are never originals passed to `clone_export`.
The converter supplies CStsym/CSfsym/CSpsym, and
`Typing.type_inst:1593–1642` places the latter two solely in `mi_ls`.
Its `mi_pv`/`mi_rs` rows require CSvsym, which this converter does not emit.
Replacing a logical symbol does not inline the target's definition or
introduce its program reads. Thus a variable synthesized in ordinary Main
JSON/Ptree generation, including a possible `spark__branch` instrumentation
reference, cannot enter these original clone terms by that route.

The fixed originals are parsed from the retained WhyML files. Their parser
if-rules only construct Eif (`parser_common.mly:1029–1033`);
`Typing` maps its three children to DEif (`typing.ml:1112–1116`), and
`Dexpr`/`Expr.e_if` compose exactly those children and their effects
(`dexpr.ml:1588–1589`, `expr.ml:975–987`). They inject no foreign branch
variable. The remaining helper-created variables are fresh lexical proxies
(`expr.ml:859–900`), formal/result/oldie variables, local routine variables
or pattern binders, all covered by the scope induction below. Callable
lemma generation derives its formals/posts from the closed input formula
(`typing.ml:1560–1580`, `expr.ml:781–833`) and emits a separate LDsym.
This excludes hidden parser/type helper state for the cloned origins; it
does not claim that ordinary Main itself has no external state.

### The whole map history at actual use cuts

Fix one `clone_export` invocation. Its original module is already fully
constructed before `cl_init`, so every variable identity in its stored terms,
including old keys/images and pattern binders, precedes this invocation's
fresh allocation history. The transported Ident guard remains required.

`cl_init` calls `empty_clones`, whose `pv_table` is empty; it validates
instantiations but never seeds pv_table with caller-chosen replacements
(`pmodule.ml:586–600,696–725`). At each declaration boundary in this frontier,
`cl.pv_table` is still empty. Here is the complete induction:

- Pure/type declarations do not write pv_table. The invariant/witness term
  clone branches are absent for these origins. Namespace uses and clone
  metadata do not execute an origin's declarations or write pv_table.
- Every top-level ordinary program declaration is LDsym. Its representative
  is RLnone, RLls or RLlemma, so `sm_save_rs` changes the routine/logical maps
  and leaves `sm_pv`/`sm_vs` unchanged. Top-level LDvar/RKlocal/LDrec are absent
  by the source classification above, including generated callable lemmas
  and nullary constant wrappers.
- Thus the ordinary PDlet row writes an empty `sm.sm_pv` back to pv_table
  (`:1448–1465`). The three fixed `val eq` refinement rows use `cl_save_rs`,
  which likewise does not seed a program-variable substitution (`:838–849`).
  Their constructed contracts are still visited and counted below.

Therefore `sm_of_cl`'s inherited `sm_vs` is empty at every top-level contract
use in this frontier. This is a derived property of the complete declaration
history, not an assumption that fresh current formals somehow sanitize an
unknown inherited map. It directly answers the #211 counterexample at the
actual source boundary.

Within a declaration, maintain the following lexical induction: sm contains
a distinct new pvsymbol for every original program variable in the current
source scope that can occur freely in a cloned term; every target was
allocated after this clone invocation began. Logical binders are left to the
accepted generic mapper. Source typing resolves a free program occurrence
through this lexical scope, with no foreign program variable by the corpus
lemma. The saved-support invariant extends that coverage to every old image.

The native extension rows establish this induction as follows.

| Native site | Coverage and identity argument |
| --- | --- |
| `clone_cty:902–915` | `clone_pv` allocates each argument separately, then `sm_save_pv` installs it before mapping preconditions. Oldies are cloned separately before normal/exceptional postconditions. Post-result variables are epsilon bound and handled by the mapper. |
| `clone_cexp Cfun:1042–1047` | `sm_save_args` and `sm_save_olds` reuse precisely the fresh arguments/oldies just constructed for that Cfun. The body therefore receives both maps. `Cany` has no body. |
| `clone_let_defn LDvar:1051–1056` | Clone the initializer in the old scope; `let_var` registers a fresh symbol; install it only for the subsequent body. Local proxy/sequence bindings obey the same rule. The declaration's outer map is persistent. |
| `sm_save_rs:879–883` | A local RKlocal routine gets an RLpv from `create_rsymbol`'s fresh `create_pvsymbol` (`expr.ml:120–137`). Install that target only after cloning the definition. Other routine kinds add no variable mapping. No arbitrary external routine target is introduced into this lexical map. |
| `clone_ppat:970–982` | The source pattern's distinct variable names receive fresh pvsymbols from `create_prog_pattern`. Its per-pattern name table reuses a variable across an or-pattern, and native pattern constructors reject duplicate distinct bindings. `sm_save_vs` extends the branch scope only. |
| Exception/for binders:1002–1005,1010–1017 | Each original carried/index variable gets a fresh clone; the equal external/internal index case reuses one target deliberately for the same original key. Branch/body scopes receive the extension. |

The last two rows explain the native lexical rule without expanding the
admitted Main grammar. The inventoried origins have no program loops,
exception handlers or recursive program definitions; pure logical cases can
still occur and remain in the generic mapper's separate context domain.

Oldies require one additional source fact. `Dexpr.find_old` memoizes by the
original current pvsymbol in one label table and creates a fresh old pvsymbol
only on its first use (`dexpr.ml:1141–1170`). `get_oldies` reverses that table
(`:1193–1194`); `create_cty` may restrict it but does not merge different
entries. `cty_of_spec:1309–1324` and `lambda:1773–1789` each supply their
single fresh `old_label` table to that operation. Original Cfun/Cany
specifications therefore have at most one oldie
for each current variable. Because the clone's current-variable map is
injective, the reverse map in `sm_save_olds:965–968` cannot collapse two
different entries. It recovers the exact new oldie already allocated by
`clone_cty`. Applied Capp contracts may alias actual arguments, but those are
rebuilt by `c_app`; they are not the original Cfun/Cany oldie maps to which
this argument is applied. Clone-created Cfun/Cany records retain this
property inductively: their oldie keys are fresh and their current-variable
images are injective. Before `create_cty` can restrict the map, `clone_cty`
adds all fresh oldies to its reads (`:919`), so the subsequent
`sm_save_olds` does not lose a body-only oldie.

All inherited lexical targets are newer than the entire original module;
new extensions remain distinct and have the same property. Type projection
commutes with the clone type constructors: `ty_of_ity (clone_ity cl ity)` is
`clone_ty cl (ty_of_ity ity)`. `ity.ml:182–185` erases region metadata and
projects only the type-symbol arguments. The variable/app cases follow the
same `ty_table`/`ts_table` substitutions in `pmodule.ml:604–638`, with
`ity_full_inst`/`its_match_regs` projecting to the same `ty_inst` formal
substitution. The Ityreg case follows `clone_reg:641–649`; a symbol in
`ty_table` is pure by `:1240–1248`, so cannot be the mutable symbol of an
Ityreg. Cloned aliases preserve their defining projections. Thus
`create_pvsymbol` (`ity.ml:745–756`) gives `clone_pv` the required type
compatibility. Local routine targets project the same argument/result
mapping type; pattern targets are checked against cloned constructor
arguments. Together, the scope, oldie and freshness
inductions establish the accepted bridge's sufficient coverage/injection/
all-stored-identities disjointness premise at every reached `clone_term`
contract/body call. No weaker ad hoc map premise or caller-supplied
certificate is needed for this source frontier.

Pure `clone_fmla` calls use the empty map on closed definition axioms,
inductive cases and propositions. Their source declaration constructors close
the logical formals; source typing rejects a genuinely unbound variable.
Generated callable lemmas are separate LDsym declarations handled above.
Hence the empty map satisfies coverage for these roots, including formulas
with logical cases or saved images.

### Finite direct caller multiplicities

The accepted #185 declaration fold constructs the actual ordered program and
pure declaration records from source, including implicit posts, callable
lemmas and generated type declarations. Evaluate the following recurrence on
those records, **not on a supplied size certificate**. It does not need to
recover saved-map histories from the opened terms merely to count roots.
Let `Q(c)=|pre|+|post|+sum_x |xpost[x]|` for the stored original contract.

| Reached clone constructor | Direct `clone_term` roots and other entries |
| --- | --- |
| Cany | Q(c); one `clone_cty` |
| Cfun e | Q(c) plus the expression recurrence for e; one `clone_cty` |
| Capp | One direct `c_app`, whose nontrivial contract substitution is the accepted bridge's separate stage-4 row; no direct `clone_term` |
| Cpur | No direct `clone_term`; its typed constructor work is separate |
| LDvar / LDsym | Initializer-expression / cexp recurrence, respectively |
| Elet, Eif, Ematch | Sum over exactly the visited declaration and child/branch expressions |
| Eassert / Epure | One root |
| Other leaf expressions | Zero roots; this does not make their constructors allocation-free |
| Dlogic group | One root per definition axiom, including substituted definitions constructed only for equality checking |
| Dind group | One root per inductive case formula, including substituted comparison cases |
| Dprop | Zero when the source guard skips it, otherwise one |
| Program-val refinement | Q(c), one `clone_cty` and one direct `c_app` (`pmodule.ml:1385,1390`) before creating the refinement function/VC; subsequent VC construction is separate |
| Uuse / Uclone metadata / meta | Zero direct roots; no recursive traversal of the referenced module at this point |
| Uscope | Sum in native child order |

For completeness the native loop row would add the invariant and variant
roots to its child expression recurrences, and a recursive-definition member
would add `Q(rec_cty)-1+|variants|` plus its body, with one `clone_cty`.
The source inventory makes those rows zero in this frontier. It is therefore
unnecessary to assume a bound on `let_rec`'s effect fixed point here.

The recurrence is additive over the **actual ordered input units at each
clone boundary**. Define `Build(m)` by the accepted declaration fold in source
order: local declarations append their typed records; a clone directive
appends the output records of cloning `Build(origin)` with that directive's
substitution; use edges append references. The accepted acyclic origin graph
makes this a finite construction. Evaluate the table on `Build(origin)` with
the current clone's substitutions to obtain its direct caller counts.
Do not sum the numerical caller weights of unchanged ancestor origins:
earlier clones can omit substituted definitions, change proposition kinds,
or generate refinement declarations. In particular a comparison attempt
consumes its formula root even when its output contains no corresponding
definition for a later clone to visit. Input work and emitted records remain
separate. The packet's simple weighted DAG diagram checks only the
unchanged-weight special case; it is not the actual declaration fold.

Each source-generated Main clone has a selected origin and substitutions in
this construction. Fixed comparison/discard decisions can be retained
exactly or overcounted by keeping their attempted input roots. A failure
stops a finite list/structural traversal at a prefix; no already constructed
root is refunded. No retry edge returns to an earlier clone root, and nested
Uclone metadata does not initiate another clone execution. Unknown source
declaration families are not zero-cost cases.

This closes source attachment of the **direct clone root/contract entry
counts**, including discarded comparison attempts. It does not count every
internal term/type/effect operation in `create_cty`, `c_app`, declaration
construction or namespace merging. Apply the accepted bridge separately to
each actual stored root, then price the still-open native consumers. The
distinction preserves the original #202 construction-demand boundary.

## Contract-builder internals — first Main partition

The accepted clone-caller result is followed by the
[contract-builder packet](../evidence/retained-main-construction-demand-20261024/contract-builders/README.md).
It replaces `create_cty` and selected `c_app` entry tokens by computable
internal term/map/type requests on their **actual stored input records**.
It preserves external read/write effects and counts intermediate construction.
The new result closes these request families for the source partitions below;
it does not supply all native bytes for the new Ity helper frames or their
shared hashcons backing, nor finish source-to-VC construction.

### Actual sites and source conditions

Reuse the accepted current Main type, typed-call and declaration folds.
Their types are closed monomorphic pure snapshots, plus one-field mutable
references with one own region and no nested region or type arguments.
Snapshot field types are pure. The initial program declarations have no
old-value references or exceptional posts; the ordinary Main/internal Cfun
closure supplies the latter property even though Exit/Return handlers occur
inside Main. This is the complete escaping-exception argument in
`retained-main-callers-profile.md`, not an inference from source handler syntax.
The eleven-key output-state family from `retained-main-typed-profile.md`
remains present in the effect records.

A separate new inventory follows **clone edges** from Main's six possible
origins. It reaches exactly eleven originals: Array__1, Array__Index,
Constr_Array, Discrete_Base, Dynamic_Discrete, Index_Type, Rep_Proj_Base,
Rep_Proj_Int, Static_Discrete, Static_Discrete_Base and Unconstr_Array, qualified
as recorded in `sites.json`. Complete retained tokens contain no type-variable,
old/at, raises/exception or ghost syntax in these originals. Their only
explicit executable definitions are Index_Type.first/last and
Unconstr_Array.to_array/of_array: projections and construction of immutable
bounds/String snapshots. All other explicit program declarations are abstract
vals or the already classified constant wrappers. Clone ancestry preserves
these properties; accepted Main substitutions replace their nullary abstract
types by the same closed flat type frontier. Generated callable lemmas are
separate ghost Cany declarations with pure formals and closed posts, and do
not add executable calls. WellFounded's separately reviewed builtin contains
closed pure declarations, not program contract constructors.

The following is a partition of the named current operations, **not a new
admission check**. Entries outside this first partition remain required work.

| Actual current site/family | This packet's disposition |
| --- | --- |
| `Dexpr.cty_of_spec:1309–1324`, reached from generated ordinary vals and Cany | Flat `create_cty` fold, including defensive effect adjustment. |
| `Expr.c_fun:827–835`, for Main, internal ignored Cfun and nullary Pterm wrappers | Flat `create_cty` fold after the actual body/effect is constructed. Its upstream body construction is not charged again here. |
| `Expr.create_constructor:193–211`, for current immutable records and one-field references | Flat `create_cty`, including a reference result's reset/escape region. |
| `Expr.rs_of_ls:213–221` / `c_pur:846–854`, when creating a closed current Main contract | Flat `create_cty`; surrounding symbol/result-post builders remain separate callers. The generic polymorphic builtin signatures are not relabelled monomorphic. |
| `Pmodule.clone_cty:959` for the eleven Main-origin originals, and their generated callable lemmas | Flat `create_cty`, after its already-counted term mapping and type/effect cloning. `clone_cty`'s earlier work remains separate. |
| The five current public API calls: Input_Is_Valid, First_Or_Default, Reject, Put, Put_Line | Saturated snapshot `c_app` row below. Their existing external effect sets remain intact. |
| Current monomorphic snapshot arithmetic, Int comparisons, overflow/range checks, Integer.length, array concat/equality, String conversions/accessors and Image/to_string calls | Saturated snapshot `c_app`; use the actual symbol/signature selected by the accepted Main caller fold. Int relations with polymorphic equality machinery require the distinct row below if the routine signature itself still contains type variables. |
| Boolean True/False applications | Nullary original-contract return, then one Capp/cexp wrapper; no contract substitution. |
| Unit applications | Nullary original-contract return, then the separately charged `cty_tuple []` replacement. |
| Calls inside Index_Type.first/last and Unconstr_Array.to_array/of_array | Saturated immutable-record projection/construction and I1.mk; same snapshot `c_app` row. |
| Mutable-reference projections/constructors, polymorphic equality/application candidates | Required residual `cty_apply` type/region-instantiation rows. Monomorphism alone does not remove region changes. |
| Other fixed clone origins and their copied/generated contracts | The other 58 origins are explicitly retained in `sites.json`; no generic pure/flat/no-oldie conclusion is asserted for them. |

The no-promotion condition for the selected ordinary runtime calls follows
from the actual program-expression constructors: the converter's parameter
and field ghosts are false (`:1022–1035,1165–1173`); its expression let
constructor uses `Elet(...,false,RKnone,...)`
(`ptree_constructors.ml:123–124`). It emits neither an Eghost nor an Epure
expression constructor. Selected runtime values use program representatives;
logical assertions/specifications use the term converter. Regular variables,
literals, the selected visible-result callables, records, ifs and lets preserve
visible values. With the initially regular function environment this keeps
`eval_args`'s promotion test false and `proxy_args` regular
(`dexpr.ml:1409–1444`). A logical-only symbol cannot silently provide a regular
runtime operand: `c_pur:1450–1454` rejects it outside a ghost/allowed context.
The four explicit origin functions above have no ghost qualifier or ghost
operand. Generated ghost callable lemmas have Cany bodies, not these runtime
applications. Thus these selected calls satisfy
`existing_eff_ghost || not(actual_ghost && not formal_ghost)` at every argument.
A different ghost context is an explicitly retained residual, not a zero row.

Ground pure type matching supplies the other important gate. With no Tyvar
or Ityreg, `ity_match:426–446` only recursively compares equal constructor
symbols and their type arguments. A successful match therefore gives equal
canonical types; live source type identities and the transported unwrapped
owner histories justify physical equality. Saturation leaves no formals for
`cut`, and the resolved pure result has the same property. Consequently the
selected successful applications take `same=true`, never call `eff_inst`,
and retain the old freeze/effect metadata before adding actual reads.
An overload candidate that mismatches fails at matching before the effect
stage; its preceding requests still count. This argument deliberately does
not apply to a reference: two distinct Ityreg identities can match.

### Flat `create_cty` request fold

`builders.create_cty` follows `ity.ml:1359–1431`, with empty oldies and xposts,
visible/ghost scalar masks, and the actual flat effect maps. It performs these
source operations in their dependency order:

1. Check pre/post shapes and mask, create the argument set, and project the
   result's program type. **`check_post` computes `ty_of_ity result` even when
   the post list is empty.** Each projected Tyapp occurrence requests Hsty;
   record fields are not extra type arguments.
2. Compute pre/post free-program-variable sets using native `t_vars`' stored
   caches, restore each variable through `Ity.vs_to_pv`, and update the actual
   running sets. This charges each root's traversal and every map insertion,
   including repeated variables across different roots.
3. Perform post read checks, the oldie intersection/disjoint operations (their
   operands are empty where justified), read unions and formal subtraction.
   Flat types have no frozen nested region; a stale own-region check still
   compares the actual reset/cover sets. A failing diagnostic's preceding
   work is retained.
4. Freeze external reads. A pure closed type is traversed without a type-map
   write. Each flat reference performs native reg_match/Mreg.change; repeated
   occurrences retain their lookup/callback work even if the binding exists.
   The output freeze carries exactly those region identities, not their count.
5. Check type-variable closure. `t_gen_fold:1177–1196` visits the stored body,
   every trigger and **every saved image**, plus explicit quantifier-variable
   types. It does not merely scan the opened term or `bv_vars`. All reached
   types are closed, so the resulting type-variable sets are empty, while the
   traversals remain charged.
   Context cases retain the subject, each pattern's types, branch body and
   saved images; their free-variable pass uses cached branch support. This
   read-only extension does not broaden the accepted case-free substitution
   kernel or its byte coefficient.
6. Keep exception-filter work as an empty-map operation. The singleton-post
   test's `open_post` is unreachable only because the actual xpost map is
   empty; this packet does not generalize that exclusion to fixed contracts.
7. Intersect writes/taints with covers; derive reachable own regions from
   reads/result; filter writes/covers/resets; then reset taints using actual
   visible fields and non-ghost read variables. This can allocate intermediate
   effect records even when the final set is unchanged or empty.
8. Construct the escape-type set from result and written fields. Each field
   still invokes `its_match_regs` and `ity_full_inst`; a pure closed field
   returns unchanged after its `ity_closed` walk, with no Hsity request.
   Apply the empty type-variable spoil intersection, defensive reset union
   if selected, final read update and `cty_unsafe` record.

For a valid entry let `P(result)` be the number of applications in its logical
type projection, counting repeated arguments. This partition exports exactly
`P(result)` Hsty requests for a completed projection, and at most that many
for an abandoned prefix; it adds zero Hsity requests and zero Ident
registrations from `create_cty` itself. It also exports the new builder map
operation/cardinality sequence, the accepted term callbacks' own ledger
totals, Wvs restore lookups, source helper visits and ordinary
record/list candidates. The exception value formed at function entry is
counted even on a successful return. No callback/table is assumed fresh
merely because another contract begins.

### Saturated application and Unit replacement

For a selected non-nullary application let n be its formal/actual arity,
d the number of nonidentity formal-to-actual entries, and
`r=|pre|+|post|`. Native `cty_apply` still matches all n program types before
using `same`. It adds the d entries, maps **all d** to fresh Tvar records,
constructs the actual-read set, applies `eff_read_pre` and maps all r contract
roots. Actual aliases are allowed: two distinct formal keys mapping to one
actual retain both occurrences and their cache coefficient sum.

The accepted ordinary substitution kernel supplies the stored results and
term/map demand for those roots; no new generic type-map table is needed in
this row. Its source wrapper additionally accounts for the rebuilt pre/post
lists and final cty record. The result does not open its post binders. Thus
this row adds no Ident/Hsty/Hsity requests. External effect reads/writes,
resets, covers and frozen regions survive as source records; only the read
union changes. A nonempty taint set is still checked against the supplied
pure actuals, for which the visible-region walk immediately stops.
The apply/cut/oldie result tuples are retained as constructor candidates.
`is_rs_tuple` probes `fs_tuple_ids` for every RLls with `ls_constr=1`, including
a non-tuple record constructor; this lookup is counted separately from the
decision to construct a tuple contract.

The failed-argument prefix uses an evaluation-order-independent envelope.
At `ity.ml:1445`, `match_v isb u v` and `vsb_add vsb u v` are arguments of
the same recursive call; source order does not sequence the match first.
For the first mismatch at pair j, charge every earlier pair's spent work and
the current pair's nonidentity `Mvs.add` before raising. This covers both an
order that allocates the current map before failing and an order that fails
before that allocation. The latter is conservatively overcounted; no claim
about the target's particular argument evaluation order is required. The
recursive callee is never entered for the failed pair, so pairs after j,
the apply/cut result tuples, later `Mvs.map` Tvar construction and completed
cty/Capp/cexp records are absent. Ident/Hsty/Hsity histories are unchanged.
`Dexpr.c_oop:1486–1489` catches these candidate `TypeMismatch` failures and
continues, so their spent requests remain owed even when a later candidate
succeeds. Candidate multiplicities still require the separate source fold.

Independent review R1 (#213) of author freeze
`49c18b7ef37967c8b6f486721fd006d61857a8fb` found that the original Python
fold checked the type before charging this possible current-pair add. The
repair moves only that charge before the possible failure. First-pair and
second-of-three mismatch diagrams in `contract-builders/exports-r1.json`
retain respectively one and two adds, without invented later work. The
original ten exports, source inventory and historical result/round receipts
remain intact; the revised checker verifies their unchanged results.

If n=0, the native early return occurs **after** the empty cut/oldie/map
prefix. It returns the old contract and does not map its specifications.
`Expr.c_app` then creates its Capp/cexp wrappers unless it first takes the
tuple replacement. For ordinary Unit, that replacement is `cty_tuple []`:

- Two `ty_tuple []` calls request Hsty, including the one inside `t_tuple []`.
- `ity_tuple []` requests Hsity once. The arity-zero tuple-symbol memos are
  already populated by `ity.ml:794–798` and `expr.ml:948–951`; their reads
  remain counted, and no cold arbitrary-arity constructor is assumed.
  Its `ity_app` also forms an unused `id_fresh "rho"` preid before selecting
  the pure result (`ity.ml:531–534`); that discarded preid is counted, without
  inventing an Ident registration for it.
- One fresh result vsymbol registers one Ident. The tuple application,
  result variable, equality, epsilon post, argument/post lists and cty are
  constructed even if a surrounding expression later discards the value.
  Equality's two polymorphic `ty_match` map updates are included; they do not
  request Hsty.

The preceding `cty_apply` is never skipped. In this arity-zero row it returned
an existing contract; a nonzero tuple can instead discard a newly built one.
Nonzero tuple calls remain in the finite residual inventory, with that
already-spent construction explicitly owed.

### Export, cumulative ownership and remaining joins

`builders.Demand.export()` returns the term/map byte subtotal from the
accepted kernels, the map operation stream, new helper visits and ordinary
record/list candidates, Wvs/tuple-memo reads, and Ident/Hsty/Hsity requests.
The Extmap cubic bound is extended to set-submap's own temporary nodes:
`extmap.ml:459–470` splits the same disjoint key-pair rectangles as the
accepted disjoint proof. At most n*m root pairs are compared and one temporary
node is formed at each unequal pair; `4096*(n+m+1)^3` covers this operation
and its fixed set wrapper. It does not pay for a nontrivial client callback.

Add outputs for **every source-derived entry**, including candidate prefixes
and repeated clone occurrences, to the existing owner histories. Hsty/Hsity
requests are not distinct-result counts and receive no cache-hit discount.
Their increments are bounded by those requests; Ident's fresh result uses the
same incoming counter as the accepted term kernel. A second call continues
that counter and table state. This creates no extra exceptional/save allowance.

The new helper visits and record candidates are not assigned an arbitrary
4,096-byte price. That allowance belongs only to the previously reviewed term
helpers and the Extmap lemma. A complete native-byte result still needs the
new Ity local-frame/closure request correspondence and the shared Hsty/Hsity
backing/equality/hash callbacks; the export marks both joins incomplete.
The current packet therefore improves the cumulative **internal request
vector**, not a whole-builder byte bound.

The exact residual site/branch inventory is retained in `sites.json`:
reference/type-variable/partial or promoting cty_apply rows; nonzero tuples;
fixed origins outside the eleven-module Main clone closure; nonempty oldies,
xposts, tuple masks or nested type regions there; clone_cty's preceding
clone_ity/effect builders; surrounding create_rsymbol/c_cty_enrich/c_pur/post
construction; and parser/proxy/overload-attempt multiplicities not already
supplied by accepted folds. The known direct clone counts now consume this
partition where its source conditions hold; other entries remain visibly
unpriced. Kode/SP/WP, later printing and failure continuation retain their
separate obligations. #202 and #119 remain open; Oracle/admission/tool pins,
`e <= 2`, two save-entering callbacks and three saves are unchanged.

## Local representation safety for the accepted builder partition

The [builder-local packet](../evidence/retained-main-construction-demand-20261024/builder-locals/README.md)
continues the repaired contract-builder author
`93fdabb2232e0fc7fe2fd7c39f167c1985991f5a`, independently accepted by
`ed10f9ba6201024b5053a84b6595bc770b2bcfeb`. It closes the new **local
representation obligation** for flat closed `create_cty`, saturated closed
snapshot application without promotion, ordinary Unit replacement and their
declared failure prefixes. Earlier evidence remains unchanged.

The relevant obligation is that each local allocation request has a
representable size and that its source traversal is finite. There is no
native scalar storing the accumulated bytes of all helper calls, closure
objects or stack frames. Sufficient ordinary RAM and stack remain physical
resource premises. Consequently a cumulative local byte coefficient is
unnecessary for this obligation. This explicitly disposes of the earlier
unpriced local-frame/closure entry; it is not deferred indefinitely behind
the historical `complete_native_bytes=false` field. Shared owner/backing
and callback representation obligations remain required below.

### Source constructor and native request correspondence

The new packet reuses the accepted term/map kernel method—source-selected
branches plus retained native body correspondence—but does **not** transplant
its 4,096-byte coefficient to Ity. It reads the existing disassembly and the
same pinned Linux x86-64 ELF, without executing or redisassembling the target.
There are 212 retained helper/closure bodies and 120 application-adapter
bodies, with 38,376 instruction bytes reconciled to executable segments.
Twenty-four labelled constant closures have their block headers, extents
and callback code pointers reconciled to ELF data. The source callback
arguments in `source-closure.json` supply the indirect joins; a direct symbol
reference inventory by itself would not supply them.

Every own heap-pointer reservation in this finite native set subtracts a
constant immediate. The largest reserves **104 bytes**. A reservation can
contain several blocks; each individual block is therefore bounded by that
size, including its header, and by 12 payload words. This is below the
64-bit OCaml header limit `2^54-1`. No selected local branch constructs a
length-scaled string, array, buffer, arbitrary-width integer or C allocation.
Hashcons/table services reached through the listed cuts are not included in
that last statement. The native stack adjustments are also fixed immediates;
their observed sizes do not constitute a peak-stack or aggregate-memory gate.

Representative exact joins are:

| Source operation | Retained own native reservation sites | Interpretation |
| --- | --- | --- |
| `create_cty` entry/body, `ity.ml:1359–1431` | `24,40,48,40,40,80,80,80,80,80,80` bytes | Exception candidate, closures and intermediate effect records remain present even if later records replace them. This site list is not one 672-byte request. |
| Raw `reg_match`, `:437–446` | `104,24` | A fixed ref/closure group and substitution record; the finite map callback has its own source body. |
| Checked `ity_match`, `:448–449` | `40` | A fixed mismatch exception, retaining existing types/substitution by reference. |
| `cty_unsafe`, `:1305–1315` | `80` | Nine-field contract record. |
| `cty_apply`, `:1436–1489` | `64,32,40,32` | Fixed wrappers/closures; recursively invoked helpers and map/list callbacks remain distinct sites. |
| `t_gen_fold`, `term.ml:1177–1196` | `56,56,40` | Fixed traversal closures, with recursive term/type/pattern visits. |
| Ordinary Unit, `cty_tuple:1491–1501` | `16,24` in its own body | Its child type, term, identifier and epsilon constructors are included separately or imported from the accepted kernel. |

The complete census retains excluded native arms as a finite superset.
`native-boundary.json` classifies every external direct code reference as an
accepted term/map service, a required shared-service join, a source-excluded
branch, or the existing allocation/exception runtime premise. In particular,
empty oldies/remaining formals exclude new pvsymbol construction; same-type
applications exclude `eff_inst` and type-changing term substitution; pure
closed written fields return before `ity_full_inst`'s instantiation recursion;
scalar masks and Unit's empty mask list exclude nontrivial mask callbacks.
The native relation remains the existing trusted source/compiler/runtime
premise, corroborated by byte identity, not a new machine-checked compiler
refinement theorem.

### Finite descent and actual scalar operands

For each source-derived entry, assume the accepted valid immutable records,
finite persistent maps and acyclic stored term/type construction history.
Each local traversal is then finite by the following source measures:

- Projection, closedness and matching descend into proper type arguments.
  A flat reference has no nested region/type arguments. A field's closedness
  walk terminates before returning the original pure type.
- Pre/post/formal/actual/field lists consume list cells. Effect callbacks
  traverse finite map domains; the existing Extmap recurrence bounds their
  own internal operations. These client callbacks do not recursively grow
  and revisit the source collection being traversed.
- `t_gen_fold` descends into proper term/pattern children, all saved images,
  triggers and explicit quantified variable types. The construction history
  supplies acyclic descent even when a saved image is dead or shared. Empty
  trigger groups still consume their outer list cells. `local.py` records
  that extra list-spine witness instead of inferring it from term visits.
- Cached free-variable traversal reads binder support; it does not open
  binders or recurse through saved images implicitly. Specification
  substitution imports the accepted case-free termination/request argument.
- Application consumes one formal/actual pair per recursive step. R1's
  current-pair map envelope remains intact on failure; later pairs and
  post-apply construction are absent. Unit's replacement has empty argument
  lists, a fixed two-argument equality and already populated arity-zero memos.
  Fixed-arity application adapters consume a bounded number of arguments.

The auxiliary shape fold counts occurrences and list spines in actual input
records, including shared subgraphs when revisited. It is a mathematical
finiteness witness, not a native stored total or a claim that a failing call
visited all its inputs. This distinction permits reuse across successful
calls and abandoned prefixes without introducing another execution counter.

The new local arithmetic is equally bounded. `List.length` is used at the
selected type-constructor arity checks and Unit memo queries. The accepted
concrete Main type frontier supplies nullary scalar/private/record/reference
symbols and binary function types used by array projection; normalized
projection does not retain an alias constructor. Thus these arities are at
most two, and Unit's memo keys are zero. The eleven Main-origin originals
contain only two existential syntax sites, both `exists i : I1.t.` in
Array__1; they introduce no multiple-witness result tuple. This supplements
the accepted generated-Main frontier and does not classify the other fixed
origins or nonzero tuple applications.

The local helpers add no new numeric owner or aggregate size/index field.
Ident/Hsty/Hsity requests and endpoints remain exactly those of the accepted
builder vector. Map heights and term occurrence arithmetic retain their
existing guards. The export separately records local header and arity guards
and source-domain support; an out-of-domain diagram does not receive a true
local-closure flag. These are proof observations on source-fold inputs, not
new user-supplied admission data.

### Disposition and remaining joins

The local fixed-request/header and finite-traversal obligation is closed
under those premises. **An uncomputed cumulative local frame/closure byte
total is not an unfinished representation obligation.** The preserved older
request vector still contains its historical byte-completeness flags; the
new export records this explicit disposition rather than silently mutating
the frozen packet or pretending to have computed a whole native-byte sum.

The genuinely required joins remain Hsty/Hsity owner endpoints, backing
request sizes and hash/equality callbacks; Wvs and strong memo services;
source-derived entry/candidate multiplicities needed by cumulative owners;
other builder families and their surrounding symbol/proxy/clone work; and
later kode/SP/WP and continuation construction. Their actual representation
obligations are not relabelled physical-resource assumptions. #202/#119 remain
open. Oracle/admission/tool pins, one process-global `e <= 2`, two save-entering
callbacks and three saves are unchanged.
