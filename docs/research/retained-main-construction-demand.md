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
