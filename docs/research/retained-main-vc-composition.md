# Ordinary Main from source profiles to terminal goals

Started 2026-10-23; review freeze 2026-10-24 UTC. Research for #185 under
owner-authorized #119. This construction
composes the accepted [Main caller interface](retained-main-callers-profile.md)
at `ebe36e4b9c9a12cc6a5ad4fd4269f2faafeec58c`, its receipt
`7ab729be0bfaf393f462f070d9a09af614c87567`, and independent
[acceptance](../reviews/review-main-callers-4a4d15cd02.md) at
`6031a189e0`. The [packet](../evidence/retained-main-vc-composition-20261023/README.md)
checks the new composition seams. Its Python models are focused checks of
the displayed construction, not a replacement Silver parser or a verified
implementation of Why3. Exact-freeze independent review remains required.

The result is a **mathematical source/configuration function** producing
structured kode, initial formulas, their actual declaration maps, and a
terminal-goal bound. It is not a production admission change, an automatic
proof-success theorem, or the complete #119 capacity predicate. Native
current-grammar compiler attachment, whole-process creation counters,
downstream consumers and the separate fixed-library #153 stream remain with
the parent. The Oracle, pins and invocation are unchanged.

## Inputs and the meaning of exact structure

Use an admitted source tree `s`, the fixed tool/configuration/dependency bytes
`c`, and the accepted **source-derived** frontend decisions. These determine
the typed occurrence tree `T(s,c)`: types and symbol identities; actuals and
their lexical definitions; complete instantiated contracts; logical terms;
effects; and binding/outcome scopes. The String-shape, all-solid/flat-reference,
ordinary Main grammar and frontend-guard premises are exactly those of #178.
No new caller-supplied size certificate or arbitrary typed tree is an input.

There is a distinction between the accepted packet's envelope and the native
choices within it. The packet reserves an actual proxy even where a variable
can be reused and counts an optional trace/tag. For the construction below,
resolve these choices by their source guards: `var_or_proxy` tests the actual
typed node; trace selection uses `env.keep_trace`, callable kind and arity;
WP/SP selection and simplification use the actual attributes. Restore those
attributes from their source-emitter/converter sites, including annotation,
stop-split, case-split and pretty labels. Their term-node cost is zero but
their effect on transformation control is not zero. Do not infer them from
an affine term record that intentionally omitted metadata.

An exact object here is an opened, typed syntax tree up to capture-avoiding
renaming, with attributes, declaration identity and source occurrence links.
Fresh names are pairs `(construction site, local ordinal)` over mathematical
integers. They are not native hash-cons tags or OCaml counters. Equality,
free-variable tests and substitutions are decidable finite-tree operations.
Preserve native constructor simplifications when deriving an exact `f`; an
unsimplified envelope can be used for E0 costs, but is not silently substituted
for the formula used in the matcher or split-skeleton analysis.

Each repeated occurrence stays separate even if its representation is shared.
In particular, every sequence has its anonymous Unit LDvar, arithmetic has
independent overflow and expected-range call occurrences, and ordinary String
`/=` first follows the frontend rewrite to `not (=)`. Read/write sets use
program-variable keys; opened contract results, quantifier/epsilon binders
and post-write logical names are not extra program-variable keys.

## First edge: typed occurrences to structured kode

The function `K(e,r,X)` carries a result program key `r` and a map `X` from
exception identities to their outcome/result pairs. `F(cty,e,X)` is `k_fun`.
The recursion uses exactly the reached branches of `vc.ml:598–1052` in the
accepted [kode provider](retained-producer-kode.md). Its output is a tree,
including every attached term and effect map, not the provider's scalar B.
Write `Seq(a,i,b)`, `Par(a,b)` and `Unit(r)=Val([r],True)` for kode constructors.

| Reached typed row | Structured construction |
| --- | --- |
| Variable or scalar constant | `Let(r,value,True)`, preserving the actual value term and attributes. |
| LDvar, including sequence | `Seq(K(def,v,X),0,K(body,r,X))`; use the occurrence's own scoped `v`. |
| Saturated application | Evaluate each actual once in the accepted right-to-left order, binding its actual key if required; then use the call row below. Contracts substitute **variables**, not the actual expression trees. |
| Whole-field assignment | Evaluate value before reference. Build the actual region/field write map with `Some(value_key)` and `Seq(Havoc(writes),0,Unit(r))`; an empty cover uses Unit alone. |
| Assert, Check, Assume | Respectively `Seq(Cut(p),0,Unit(r))`, `Par(Stop(p),Unit(r))`, `Val([r],p)`, with the actual annotated predicate. |
| Conditional | Derive both branches at `r`, evaluate/reuse its condition key `v`, then use the conditional extraction rule below. |
| Raise | Look up `(i,v)=X[exception]`; `Seq(K(value,v,X),0,Cont(i))`. |
| Singleton generated handler | Allocate its outcome and Unit payload key before traversing the protected body. Derive the handler in the **outer** X, the protected body in the extended X, and serialize with `Seq(body,i,handler)`. A catch cannot catch its own handler's raises. |
| Generated while True | `Par(Stop(init),HavocThen(Seq(Val([],prev),0,Seq(K(body,r,X),0,Stop(keep)))))`. The body occurs once. The native invariant list is empty; implicit source frame/index assumptions are already body children. Keep the annotated empty-variant decrease True and its permitted conjunction in `keep`. |
| Nullary ignored Cfun | The call contract row **and** its distinct `F(cty,body,X)` check, joined by Par. Empty escaping exceptions do not remove the body check. |
| Cany | The call contract row, with its complete pre/post and no body check. The executable Main helper is Unit; the source-generated nullary declaration wrappers below can have any of the admitted pure value types. |
| Ghost/exn wrappers and pure terms, if present in elaboration | Recurse without added kode; Epure uses its value, or `if predicate then True else False` for a proposition. |

For the call row, open the conjunction of normal posts with its actual result
key. Use the already accepted `term_of_post` selection: `Let(r,definition,
residual)` when it extracts a value, otherwise `Val([r],opened_post)`.
The definition and residual are separate term occurrences. They cannot be
replaced by the complete post's scalar weight. Add the optional trace binding
at its actual guard; prepend the actual havoc and old-value bindings; add
`Seq(Cut(pre),0,call)` for `keep_precondition`, otherwise `Par(Stop(pre),call)`
when the pre-list is nonempty. A Cfun adds `Par(F(...),call)`. #178 proves
`h=o=0` for these ordinary calls; all-solid types remove the extra invariant
wrappers, and Main's inherited divergent attribute removes only the
missing-divergence wrapper. The native test for havoc is the effect cover,
not merely whether an assumed postcondition mentions a mutable key.

`F` allocates its own normal result and constructs

```text
Seq(Val(cty.args,sp_of_pre(cty.pre)),0,
    Seq(K(body,result,X),0,Stop(wp_of_post(cty.post,result))))
```

with the actual outer WP/SP tag and old-value maps at the source positions.
The completed exceptional-post set is empty by the accepted ignored-child
and escaping-exception argument. The ordinary body introduces no LDsym,
LDrec, RLlemma or RLpv enrichment; this exclusion applies to body-local
definitions, not to the whole imported context.

These ignored Cfun calls do not carry `vc:white_box`. `New_Ignore`
(`why-gen-progs.adb:199–215`) creates a binding inside an Abstract_expr with
True post and no added label. The converter's Abstract_expr row
(`:889–905`) adds only `rac:call_id:<ordinal>` to its discarded binding;
the outer generic attribute path adds source-location attributes. Comment
attributes have the fixed `GNAT-comment:` prefix. The accepted ordinary
label emitters add check/explanation, branch and pretty/source labels, not
`vc:white_box` or `vc:wp`; source authors cannot supply arbitrary labels or
proof pragmas. The complete retained SPARK source literal inventory and
these construction sites are checked in the packet. The converter adds
`vc:divergent` to a Prog definition and no expression-level classical WP
attribute. Thus the distinct white-box Eexec row is unreachable here; empty
lost-exception counts alone would not have justified omitting it.

Internal F checks remain inside Main's Kpar tree. They are **not** counted
again as separate top-level initial VCs. The Main program declaration produces
one candidate `vc_fun` formula. The source-generated nullary declarations
below can also construct candidate formulas. The index j covers **all** these
source-dependent declaration candidates that survive the native syntactic
triviality/attribute test; it is not a source-assertion or internal-Cfun index.

### Source-dependent declaration VC coverage

The declaration fold below does not silently move variable Main obligations
into the parent's fixed-context account. `Vc.vc:1714–1789`, converter
`mk_function_decl/mk_declaration`, and the clone sites give this exhaustive
dispatch for the admitted source-generated declaration families:

| Family | Candidate VC construction |
| --- | --- |
| Main Prog definition | Its single F traversal above; generated ignored Cfun checks are internal Par children. |
| Nullary Pterm constant, with or without definition; nullary undefined Pred | Converter `:1044–1063,1133–1140` selects RKfunc/RKpred. `Dexpr.let_defn:1817–1833` wraps Eexec(Cany) in `c_fun [] [] [] ...`, so `Vc.vc` visits **LDsym Cfun**. Include every reached candidate in j's construction. |
| Global reference / zero-arity RKnone Eany | LDvar Eexec Cany; the first Vc.vc branch returns no VC. |
| Nonempty-parameter abstract Pterm/Prog/Pred declaration | Its callable is Cany, not an executable definition; the Vc.vc fallback returns no VC. A Pterm/Pred definition additionally emits its separate Dlogic record. |
| Native scalar, array, reference, alias and opaque type declarations | Converter sets `td_inv=[]`, `td_wit=None`. `PDtype` returns no VC for `(None,[])`; range bounds are a type definition, not a Why3 type invariant/witness. |
| Pure logical definitions/axioms/meta and exception declarations | PDpure/PDexn have no Vc.vc traversal. Typing's optional callable lemma for an axiom is explicitly added with `vc:false`. Native Goal is supported by the declaration fold, but no New_Goal emitter occurs in the complete SPARK source: the only W_Goal identifiers are its xgen schema and node-kind declaration/comment in why-sinfo.ads. |
| Native source-dependent clones | Only type/function/predicate symbol substitutions are generated; `mi_rs` stays empty, excluding `clone_pdecl`'s program-refinement `mk_vc`. In `clone_type_decl` the only `vcs` append is guarded by a nonempty **origin** type invariant (`pmodule:1234–1238`). The reached integral/array/reference clone origins have no such invariant under the accepted concrete type frontier. Remaining cloned program declarations are added with `vc:false`; clone metadata is not a new clone execution. |

For a nullary wrapper, retain the exact cty and Eexec(Cany) derived by those
constructors. The outer Cfun has no pre/post, arguments, writes, oldies or
exceptions. `let_sym` adds result-equals-logical-constant to the **rsymbol**,
not the stored Cfun cty (`expr.ml:112–147,726–729`). The inner Cany only
assumes the optional result definition; it has no pre or effect. Its K is
therefore a result Let/Val, possibly followed by a trace binding, enclosed by
F's True pre and True final post. `sp_implies(assumption,True)` returns True;
trace-preserving lets can surround that True. Apply `is_trivial_vc` and
`has_attr` exactly, including any retained definition metadata. We need no
assumption that every such candidate is dropped: any retained one is a
separate f_j in the terminal sum with its own prefix and known-map snapshot.
Its complete initializer term remains in the declaration's logical context
regardless of whether this candidate VC is omitted.

The wrapper's initial program-key set is derived from its cty/term free keys;
the local VC traversal adds at most one F result and one optional trace key,
no outcome increment, and no new alias/type family. This is a separate
per-candidate U set, not an uncounted extension of Main-body U0. The same
process incoming counters persist across all candidates. If N is the
source-derived number of these wrappers and `U_i0` their actual initial
key-union envelopes, their separate exports are

```text
U_i <= U_i0+2; Delta_i=0; H_i<=H0+1
B_i<=7; B_reflow_i<=23
U_all <= U_Main + sum_i(U_i0+2)
sum B_reflow <= B_reflow_Main + 23*N.
```

The seven kode nodes are the optional three-node Cany post/trace row plus
F's four pre/post nodes; these wrappers have no WP/SP attribute. Each
reflow call separately allows its two initial SP/Out nodes. These are
constructor counts only: the entire source-derived definition/residual terms
remain attached, and enter each candidate's formula transfer. The union
formula safely overcounts shared free keys across candidates. The total
outcome increment remains Main's `1+2F`, because wrappers add zero. Their discarded
trivial formulas and temporary allocations remain in the parent's creation
account. In contrast, the six already accepted startup formulas from the
fixed 21-file closure and the fixed-library implementation-body processes are
constant independent inputs, outside this **source-dependent** j family.

### Both conditional extraction outputs

`term_of_kode` (`vc.ml:503–542`) is a finite structural walk returning
`(value,predicate,residual_kode)` or failure. Retain its saved stack in traversal
order: a nonresult Let saves a definition; Val saves Unit for a Unit key and
None otherwise; Cut and Axiom retain residual checks; sequences follow their
actual outcome; tags and `Par(Stop(...),...)` preserve residual structure.
Other branches fail. At the result Let the remaining leaf is `Cont(0)`.

Unwind the stack separately into the value and predicate. A saved None is
allowed only when that key is unused in that output; a closed predicate needs
no unwind. Each definition can therefore occur at its saved position and at
every use in **both** outputs. The accepted lexical `Let(a,b)=3+a+a*b` bounds
each unwind separately. A failure in either output fails the whole shortcut;
its partial terms are not retained in addition to the original branch.

For pure, nonfragile Boolean branches with successful extractions, construct

```text
Seq(Tag(SP,If(v,residual_then,residual_else)),0,
    Let(r,if v=True then value_then else value_else,
          sp_if(v=True,predicate_then,predicate_else)))
```

Otherwise retain `Tag(SP,If(...))` for pure branches, or `If(...)` for impure
branches. Conditions, attributes and branch terms remain available. A plain
code-node count cannot determine either extracted output.

### Reflow and its well-formedness

Apply the actual finite `mark`/`push` recursions (`vc.ml:1065–1173`). Maintain
the outcome map with True meaning one pushable exit and False meaning a repeated
exit or a barrier. Remove the consumed key at sequence; dead continuations
disappear; WP/SP switches insert Out and make all exported entries False.
The ordinary generated tags satisfy the switch precondition: switching to
classical WP is permitted only for code with no outcomes. In particular F's
tag encloses its terminal post check; expression-level pure-condition SP tags
can export outcomes and are switched to from WP, not conversely. No source
pragma admits an arbitrary expression-level WP tag.

The accepted singleton-exit induction proves that push inserts each pending
continuation at most once. Hence `B_reflow<=3B+2`; its attached-term multiset
is a submultiset of the input's. Reflow changes neither term contents nor
program keys nor outcome labels. Preserve its actual tree and Out maps for
the next edge; the B inequality is only an auxiliary check.

## Second edge: kode to the initial formula

Evaluate the structural SP/WP equations, not just their size projections.
The WP state is a map `q:outcome -> formula`. The SP state is

```text
(safety, { outcome -> (postcondition, write_destination_map) }, reads)
```

with input post-read sets and destination logical names. The complete source
equations are `vc.ml:1319–1330,1420–1646`; their numerical projections were
accepted in [SP/WP](retained-producer-spwp.md). Every map domain is retained.
The construction includes these distinctions:

- WP Seq first derives the continuation formula and inserts it at exactly
  the consumed outcome before deriving its left child. Par conjoins; If
  uses the Boolean test; Let closes its actual definition around
  `residual -> q[0]`; Val universally closes `predicate -> q[0]`; Cut
  conjoins its check and continuation; Stop returns its check; Cont selects
  its own outcome. Axiom derives its closed child WP and makes it an
  assumption. Off keeps its solder/stop metadata; Out restricts map keys.
- SP's special `Seq(Let(v,t,p),0,k)` closes **each** safety/postcondition
  with p and t. The read-visible `sp_let` uses `v=t /\ post`; a hidden key
  uses a let; Unit substitutes Unit. Do not collapse these cases into one
  shared scalar definition charge.
- General SP Seq derives the right child first, computes its read/write
  destinations, then derives the left. Extract `(p0,wr0)` at the consumed
  key. Safety is `safety_left /\ forall(bound_and_written,
  p0 -> adjusted_safety_right)`. Each retained right outcome gets its own
  existentially closed conjunction of the advanced p0 and adjusted post.
  Other left outcomes remain, advanced to their destinations. Merge equal
  outcome keys with `sp_complete` and disjunction. Keys absent from the
  post-read map are removed by the native intersections.
- SP Par merges actual outcome vectors. If completes each branch's writes
  before merging shared outcomes with `sp_if`; a one-sided outcome has its
  branch guard conjoined. Stop has no exported outcome. Cut has a checked
  safety predicate and an assumed copy at outcome 0. Val existentially
  closes exactly the declared variables not visible in the post-read set.
- Flat Havoc uses the actual region/field maps and the accepted all-solid
  type table. It creates the projection/value equalities, logical destination
  renamings and quantifiers of the direct-written-region branch
  (`vc.ml:1224–1266,1530–1561,1609–1625`). Known assigned RHSs are variables.
  Pure field values stop descent; no Kcase or arbitrary composite region
  name can enter. Thus the retained SP/WP costs are respectively bounded by
  `3+10U` and `q[0]+10U+1`, without erasing their terms from the construction.
- A WP-to-SP tag appends one `Seq(k,i,Stop(q[i]))` per actual q entry and
  keeps SP safety. An SP-to-WP tag has empty outcome input and keeps WP
  with no exported SP outcomes. These are decreasing calls on a child plus
  a finite continuation wrapper, not recursion on source loop executions.

In particular the special and general SP sequence costs stay distinct:

```text
W_special <= a*W2 + (h2+1)*(3+2*a+a*b)
W_general <= W1+W2+h2*s0+3+2*h2+H*(8*U+1).
```

Here `s0` is the actual consumed post cost and `h2` the actual surviving
right-outcome count. At a terminal Stop, h2 is zero. This is the point at
which a global scalar kode or exception count would lose the composition.

Let `g_j = WP(reflow(F_j),empty)`. Follow `add_vc_decl`'s syntactic triviality
and annotation test; it is not solver success. For every retained j set

```text
f_j = Typeinv.inject(Known_j, forall free_logical_variables(g_j). g_j).
```

The quantifier has the actual ordered free-variable list and no triggers.
All-solid injection introduces no new invariant/case family here. Carry any
simplification and attributes exactly. This is the input to `eval_match` in
`mk_vc_decl` (`vc.ml:1672–1693`). In particular f_j includes this outer
quantifier; using only the body cost g_j would omit matcher destruction of
Unit/reference variables. Even a zero-goal Main still has its already
constructed body/context costs in the parent account.

The actual task goal is `simp_cast_projections(eval_match(f_j))`, not literally
`eval_match(f_j)`. The cast pass (`vc.ml:1649–1657`) replaces only a range-to-int
projection of a typed integer constant by that constant. The original
application arm of every E1 application cost dominates the replacement, so
E1 cannot increase. It changes no propositional connective/quantifier/let
skeleton; its replacement lies in a typed term position. Thus the
post-matcher skeleton remains a valid first-split factor, and the later task
prefix uses this actually simplified goal.

## Third edge: deriving the two declaration maps

`I_j` uses the **program known-map at VC construction**. `D_j` uses the
**pure task prefix passed to marked unfolding after the first right split**.
They are not one freely supplied context. Neither map is an admission
parameter inferred from a successful capture.

### A finite source declaration fold

Construct a declaration graph from the same source/frontend entity/type
identities as T, the selected Silver specifications/templates and the pinned
theory files. A vertex is a declaration identity qualified by its source
module and clone instance; a symbol spelling alone is not an identity.
Read a complete dependency file on first use, memoized by resolved path and
environment, and select its named module only afterwards. Fixed configuration
chooses the loadpath and builtin tables. The accepted
[startup closure](retained-producer-import-context.md) identifies the 21
fixed files and nine drivers; startup loading does not itself import every
loaded declaration into a Main task. No imported driver context is appended
to a goal merely because it was loaded.

The fold's **values** are finite typed declaration records, not numeric
coefficients. Use the following total constructor operations on the reached
declaration syntax; rejected foreign grammar is outside the accepted source
construction, not a prover-based membership shortcut.

| Declaration constructor | Record construction used by the maps |
| --- | --- |
| Scalar/opaque/alias/record type | Record exact types, constructor identities, ordered named fields and pure/mutable flags from the accepted Main type constructors. Alias and clone substitutions act on those identities. |
| Logical symbol with no definition | Record signature/attributes and no Dlogic body. Its occurrence alone creates neither map entry. |
| Logical function/predicate definition | Translate its complete source term with formal scope and type resolution, retaining ordered formals, type variables and symbol/body attributes; store its Dlogic declaration group and program known-map ownership. |
| Pterm definition with parameters | Converter emits the logical definition **and** the RKnone program val with result equality (`converter:1067–1090`). Both records exist; only the former is an I/Dlogic candidate. |
| Nullary Pterm, abstract program val, regular Prog definition | Follow the distinct converter branches (`:1044–1066,1092–1132`) and the dispatch above. Retain cty and derive its actual pure declarations through `Pdecl.create_let_decl:531–640`: an RLls Cfun can extract a logical definition with `term_of_expr` when its pre-list is empty, otherwise a parameter plus the selected definition/post axioms. In particular a nullary Pterm's assumed result equality can yield its exact initializer as a nullary Dlogic body; without an extractable term use the actual `post_of_expr`/parameter branch. An arbitrary contract axiom is not relabelled Dlogic. Imported program bodies are not inlined at calls. |
| Axiom/lemma | Translate its complete formula and attributes; retain proposition kind and source order. The optional callable lemma generated by typing is a separate program record, not an eligible Dlogic alias. Preserve generated definition/post axioms and their actual equality orientation. |
| Explicit Goal | Translate the logical formula and snapshot its task prefix; it is a goal, not a D-map axiom. Ordinary Main uses its program VC, with no additional source-emitted explicit Goal family under the accepted Main shell. Imported goals are dropped by task flattening. |
| Exception declaration | Record its exception identity and payload type (Unit if absent), used by K's handler map. It creates no Dlogic or marked axiom entry. The ordinary generated declarations are Return/Exit/Continue; imported exception declarations do not create an escaping Main path. |
| Use/export/scope | Merge the referenced module's known declarations under native identity/deduplication rules, record its unit and namespace; recursively fold scope children in order. A use is a reference, not repeated definition-body substitution. |
| Clone | Fold the origin's already constructed ordered units. Substitute types/symbols/variables by the actual instantiation, alpha-freshen newly cloned declarations, preserve source-defined attributes and skip substituted declarations exactly as `clone_pdecl`/`clone_decl` do. Uuse stays a use; nested Uclone is mapped metadata, not a fresh recursive clone execution. |
| Metadata | Retain symbol/type references and transformation attributes. It creates no D/I entry by itself. |

Term translation in this fold is the finite ordinary logical grammar: typed
variables/constants/applications, equality/connectives, conditionals, lets,
quantifiers with triggers, and epsilon. Each binder is alpha-fresh; resolving
a program symbol uses its logical representative and the retained conversion
rule. Static-range declarations construct their own named bounds; dynamic
range declarations use formal bound variables. Immutable object initializer
terms, including guarded-query epsilon, come from the separate #178 entity
context, not by replaying an executable initializer at each name use. String
literal defining axioms stay in context and do not become large body trees.

Fixed library syntax is interpreted once by its retained parser/typing
constructors. This is a constant finite input to the mathematical fold, with
the accepted fixed source/configuration correspondence; no native captured
typed tree is its definition. The maps need its symbol/type/definition records,
not a new bound on all temporary allocations made while constructing them.
In particular, nonreached fixed match/recursive declarations may be stored:
the Main frontier never treats the entire installed file as case-free.

The constructor list is exhaustive for the native source-dependent graph:
`mk_declaration:1175–1313` handles namespace/type/global/function/axiom/goal/
exception/clone/meta; module includes are handled by the enclosing converter
module fold. The earlier converter rows supply their generated extra
declarations. Scalar, array, reference, literal, immutable-object and Main
entity-context families are the accepted producer source cases. Fixed callable
contracts come from the five immutable source templates. Native clone
substitutions are type/function/predicate symbol substitutions, with axioms;
they do not introduce program-routine refinements. The fixed parser/typing
frontier and its other clone kinds are already constant input, not a claim
that the native restriction holds for every installed declaration.

This is a terminating construction, not an unspecified traversal oracle.
Entity discovery marks a source entity before recursively discovering its
dependencies (accepted producer-capacity:1062–1076). There are finitely many
source/generated entities. The retained fixed file graph is finite; ordinary
module declarations are constructed in order, uses resolve existing modules,
and clones visit the already finite origin list. The clone dependency
recurrence in the accepted import provider is acyclic. Each term/binder/type
operation recurses on a proper finite syntax component; first-order type
matching is over the finite resolved types. No Ada execution, recursive
function evaluation or source loop trip count is used. Thus the graph and
every requested definition are computable from s,c with mathematical storage.

Native `Ptree.Modules` entries remain triples `(ident,None,decls)` under the
parent's native attachment. This declaration fold does not read Modules and
does not assert that a pair-layout proxy is that native interface.

### Actual marked map and ordered overwrites

Project the declaration graph through its recorded pure declarations and
uses to the goal's actual theory task. `Pmodule.add_pdecl:549–553` first adds
the declaration's uses, derives VCs against the prior program known-map,
adds the generated VC declarations, and only then adds the original pdecl.
Snapshot `Known_j` at that call; a definition later in the same pdecl is not
retroactively visible. `Task.flat_tdecl/use_export/split_theory:180–220`
flattens each used theory once, converts imported lemmas into axioms, omits
imported goals and snapshots the pure prefix at each local goal. These
source-defined operations, including identity-based use deduplication,
determine the prefix supplied to D; it is not the final module's declaration
list. First right
splitting is `Trans.goal_l`: it changes the goal declaration and retains
the prefix, so all children of one initial VC have the same marked map.
If an earlier configured task transformation changes that prefix, apply its
source-defined declaration transformation first; do not use a map from a
different stage. No solver-driver transformation precedes this selected
`split_goal_wp_conj` chain in the interface being composed here.

Now fold that prefix in the **same order** as `task_fold fold` in
`gnat_split_conj.ml:240–319`, starting with the empty map. The task is linked
newest-first and `task.ml:225–226` applies the current declaration before
recursing to `task_prev`. Thus reverse the chronological/source-ordered
prefix before folding:

1. A singleton `Dlogic [ls,definition]` enters only when ls has `GP_Inline`
   and the opened body has a `GP_Pretty_Ada` label under the source's
   `has_pretty_labels` traversal. That traversal does not descend into an
   application's arguments or quantifier triggers. Store the actual ordered formals and body with
   the added `GP_Inlined` attribute. A multi-definition group is skipped.
2. A `Paxiom` enters only through `extract_def_from_axiom`: there must be at
   least one outer universal quantifier, followed by the recognized oriented
   equality/equivalence. Its left application must be marked, all its actuals
   must be variables, and the RHS must pass the same pretty-label test.
   For `f(vars)=True <-> rhs`, store `if rhs then True else False`. Check
   `is_true` exactly, including proposition True and nullary Boolean True
   regardless of their attributes.
   Other accepted equivalences keep their own left application. Do not reverse
   an equality, infer a definition from an implication, or silently accept an
   unquantified nullary equation.
3. Every other declaration is a no-op. A later **visited** accepted entry for
   the same identity overwrites the earlier visited entry, exactly as Mls.add
   does. Consequently the earliest accepted declaration in source order wins.

This supplies the full `D^full_j`. Restricting it for cost evaluation is safe
only after the reachability construction below. The complete imported files
in the retained 21-file closure contain **no** `GP_Inline` or `GP_Pretty_Ada`
token (checked as bytes); loading their many unrelated modules therefore
does not invent a marked body. Generated declarations and substituted symbols
still require their actual attribute fold. Native source-dependent marks
come from the three accepted SPARK emitters. Main has no expression function
or explicit type invariant, so its variable family is exactly the scalar
range/dynamic-property family. Selected APIs are not expression functions.
Any fixed dependency's generated marked declaration is constructed from its
fixed source template by the same rules, not assigned an unknown constant.

For integral range entries the actual two-comparison body gives
`5+2*w_x` for static named bounds and `3+w_first+w_last+2*w_x` for dynamic
formal bounds. The Boolean-axiom route adds three nodes. Record which route
actually wins the ordered fold; do not multiply every call by a guessed
maximum or import a source endpoint expression into the range body.

### Actual alias map and reachability

Use `Known_j`, not D, for `Eval_match.find_inlineable:62–82`. A symbol is a
candidate only when its **declared** `ls_args` has exactly one argument and
that declared type is destructible. Clone substitutions have already acted
on this signature; occurrence-level type matching has not. In particular a
Tyvar argument does not become eligible merely because one occurrence uses
Unit. Only after finding an eligible body does `unfold_inlineable:84–92`
match its formals to actuals and instantiate the result. Named record
projections take their earlier dedicated
branch and terminate alias lookup. Resolve the candidate's actual Dlogic
definition by its known-map owner and open its formals; record an entry only
for a formal-variable, constant, or unary-application-of-formal body. The
case-bodied alternative is excluded by the accepted Main type/definition
frontier. A body merely being small is not an eligibility condition.

The reached destructible declared types are Unit and single-field flat
references. Boolean has two constructors; String and bounds have two fields;
Integer/Character/maps/images/private snapshots and functions have no
destructible constructor. Generated and installed reference wrappers have
the actual `field(formal)` definition. Other eligible unit-argument definitions
are tested by the exact body criterion above. A unary scalar arithmetic
definition is not an eligible alias. Preserve instantiated type arguments
and named-field identities for every lookup.

Derive the needed slice by this finite worklist, beginning with every symbol
and type occurrence in f_j, including definitions, predicates and triggers:

1. Look up each candidate alias in Known_j and follow its eligible target;
   retain both the original identity and every target. Add the destructible
   constructor/field identities required by its concrete types and by
   quantifier destruction. Include builtin equality and Boolean constructors
   that the matcher itself can introduce.
2. For each reached symbol retain its D^full entry, if any, with complete
   ordered formals and body. Record all body free-variable/type identities
   and its **E0** affine coefficients. Calls introduced only inside that
   one unfolded body do not recursively consult D or I in this pass.
3. Bindings and projections use subterms already in the worklist. Repeat
   step 1 for newly exposed alias targets/type instances. No source name
   guessed by basename and no arbitrary alias edge may be added.

Each alias step preserves the argument and its instantiated type; its
eligibility test remains on the target's declared signature. The
accepted declaration-termination argument proves there is no returning
symbol cycle: such an Equal-only cycle fails `check_termination`, and
separate ordered declaration groups cannot create a backward cycle. Thus a
chain has at most the context's finite logical-symbol count. There are only
finitely many starting type instances in f_j and the finite constructor
frontier; alias following adds no independent polymorphic choices. The
worklist terminates. Call the resulting maps `I_j` and `D_j`. This is their
concrete source/configuration attachment, not an existential certificate.

One-level marked unfolding can leave new calls inside a D body, but E0 charges
their whole syntax. It does not run the matcher again after unfolding. That
is why the reachability operation must follow I targets but need not chase
D-body calls as another marked expansion. Retaining the full maps instead
is also computable and yields the identical lookup results on this slice.

## Joined transfer and construction induction

Evaluate M0 and M1 on the actual f_j and maps just constructed, using the
accepted [matcher/unfolding transfer](retained-producer-match-unfold.md).
Every marked application uses the maximum of its original constructor cost
and the actual definition's affine E0 cost at its actual argument weights.
Every alias uses the maximum along its finite chain, including original
marked entries that can survive in skipped triggers. Constructor equality
uses the accepted product bound; scalar/opaque equality may use the accepted
additive refinement only at its resolved type. Quantifier destruction charges
the actual Unit/reference constructor and both its definition and uses.

The source-computable terminal-goal envelope is

```text
G_Main(s,c) <= sum_j 6 * M0(f_j)^2 * M1(f_j,D_j,I_j).
```

If the actual post-matcher formula skeleton is retained, the accepted
`6*s(eval_match(f_j))^2*E1(eval_match(f_j),D_j)` is a sharper alternative.
Do not replace that skeleton by the pre-matcher skeleton. The restricted
`2*k` check-conjunction interface can be used only after checking its stated
attribute and atom-family conditions on the constructed formula; ordinary
source sequencing alone does not establish them. No positive constant bound
is asserted for arbitrary source-dependent term nesting.

The universal argument is the following simultaneous construction induction,
rather than the packet's finite diagrams:

1. Induct over the accepted source constructor tree and generated declaration
   graph. #178 supplies every body/contract/actual/effect/binder occurrence;
   the declaration fold supplies symbol and type resolution with the same
   scopes. Its finite graph/order argument closes import/clone lookup.
2. Induct mutually on K and F. Every leaf/call uses those exact terms and
   keys. LDvar sequences retain definitions once and their uses; branch
   condition results and singleton-handler outcomes are fresh. Handler
   extension is local to the protected body. F's result is fresh and its
   checks stay in Par. The complete reached table excludes every unmatched
   kode constructor. Conditional extraction's stack induction proves that
   **both** outputs are substitutions of exactly the saved definitions and
   that residual checks remain. Failure retains the original code.
3. Apply the accepted mark/push induction to this structured result. It
   preserves term occurrences, lexical well-formedness and exported outcomes
   while deleting dead continuations and inserting only unique continuations.
4. Induct mutually on the reflowed kode and finite WP continuation/SP outcome
   maps. The special Let sequence and general consumed-outcome sequence
   preserve their distinct formulas and scopes. All adjustments rename
   variables; Havoc's flat-type induction closes its only reached recursion.
   Tags consume a proper child with finite wrappers. This proves the
   computed g_j equals native VC construction up to alpha-renaming and the
   same constructor simplifications, and the SP/WP size projections bound it.
   The explicit outer quantifier/type-injection step gives f_j.
5. Induct over the ordered declaration prefix for D and the finite eligible
   chains for I. Each update is precisely the native guard and overwrite;
   symbol identities and type instantiations agree through clone/use. The
   worklist retains every lookup reachable in matcher and one-level unfolding.
6. Apply the accepted lexical matcher induction, then the first-split,
   one-level unfolding/rewrite and final-split inductions. This proves the
   displayed sum for every admitted source satisfying the original source/
   tool/type/configuration premises, not merely the checked diagrams.

## Finite domains and the parent boundary

All mathematical measures use nonnegative unbounded integers. An eventual
decidable admission implementation must evaluate them with checked integers
or saturation at the relevant representation threshold; native wraparound
is not acceptable arithmetic for this decision. Short-circuiting a known
threshold violation must remain separate from prover outcome. Structural
construction is finite; that alone does not show that native finite tags,
string lengths, list indexes or task identifiers fit.

The accepted executable Main-body unions remain

```text
U0 <= 1+|R|+B+A+2J+sum(arity(signature))+|Fields|
U  <= U0+I+P+2C+Y+2F+2
Delta = 1+2F;  Cfinal <= C0+Delta;  H <= H0+2F+2.
```

The handler counter is a process counter: require its incoming C0 and all
this process's increments to remain in the supported nonnegative native
outcome-key domain: a sufficient local condition is `0<=C0` and
`C0+Delta<=max_int` on the selected OCaml platform, with the parent's other
increments included in the same total. Outcome 0 remains reserved for normal
completion; positive fresh labels remain distinct. Nested F calls do not
reset it. Any reached native length/cardinality conversion also needs its
own domain check; the mathematical U/H envelope alone does not license a
wrapping list/map counter. Logical freshening in
SP/WP and declaration/term hash-cons creation have **other** lifetime counters;
neither U nor retained M1 bounds those counters. The parent's account must
join their incoming values and all temporary, failed-extraction and discarded
construction requests before claiming native representation safety. Likewise
G bounds retained terminal goals, not every split intermediate, captured
response byte, solver object, or session task identifier. Use the actual
representation-specific projections for those consumers.

Sufficient physical memory, stack and disk and the ordinary runtime/OS
behavior remain explicit environmental premises. There is no invented
aggregate RAM admission gate. The single global `e<=2`, two callbacks and
three saves are unchanged; this deterministic construction creates no fresh
allowance at any edge. #185 provides ordinary Main's source-to-terminal-goal
mathematical interface under those premises. It does not complete #119,
authorize merging draft PR #121, start production #88–#94, or discharge
the independently tracked fixed-library and whole-tool obligations.
