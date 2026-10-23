# Remaining preparation through printer entry — candidate source bound

2026-10-23 UTC, #119 / #153, Linux x86_64. This packet extends the accepted
[R58 cut](retained-why-postinline-preparation.md) through entry to
`Driver.print_task_prepared`, before printer lookup/execution. It is submitted
for independent review; it is not yet an accepted capacity closure. The
[evidence packet](../evidence/retained-why-printer-entry-20261020/README.md)
contains new projections, source witnesses and arithmetic. The right-only
split interface is the independently accepted root freeze
`d551c0c33ea767057fa732904faf2e1325dfe07c`.

The result is conditional on the accepted fixed-input/source-origin,
valid-representation, typed ownership, freshness and guarded-mutation premises.
It bounds selected producers, returned fields, validators and failed prefixes;
it does not establish primitive collision costs, physical resource sufficiency,
printer execution or the whole quiet-capacity rule. Oracle, tools, pins,
admission and launch behavior are unchanged.

## Cut, routes and initial private state

R58 ends after `remove_unused` on Alt-Ergo and `detect_polymorphism` on Z3/CVC5.
`Driver.prepare_task` resolves **all** transformation closures before updating
the task and folding their applications. `eliminate_literal`'s environment
lookup of integer/real helpers has therefore happened before this entry. This
packet charges the remaining applications, not that earlier initialization.
Printing begins only after the transformation fold returns.

| Driver | Remaining selected applications, in source order |
| --- | --- |
| Z3 | inductive elimination; conditional algebraic; literals; guard epsilon; general epsilon; Introduction; simplification; discrimination; SMT encoding |
| CVC5 | conditional definition elimination; inductive elimination; guard epsilon; general epsilon; literals; simplification; explicit projections on sums; discrimination; conditional algebraic; SMT encoding |
| Alt-Ergo | recursion elimination; inductive elimination; general epsilon; full algebraic; literals; right premise splitting; simplification |

R57's chronological ground-type/metadata argument makes discrimination and
SMT encoding identities. Conditional algebraic means compile-match followed by
projections on sums. The accepted empty `get_counterexmp` meta, explicitly
attached to these five process/input identities by the
[model-meta result](retained-why-model-meta-control.md), makes CVC5 conditional
definition elimination select recursion elimination. R58 proves that every
remaining singleton definition has no self-reference. Both recursion passes
therefore retain declarations; no definition-to-axiom producer is selected.
Retention still entails task reconstruction and validation.

The new physical join identifies the only two Dind declarations:

| Process | Dind object | `acc` lsymbol | Clause prsymbol |
| --- | ---: | ---: | ---: |
| Put_Line | 140318122694992 | 140318123061608 | 140318122724384 |
| Put | 140306443684184 | 140306444050800 | 140306443713576 |

These are the `acc` component in R54/R57's dependency census. All three drivers
import the common `smt-libv2.gen` four wf-axiom removals through the same source
loader/clone relation. After builtin removal, unused removal drops the complete
`well_founded`/`acc` component. Other processes contain no Dind. Every later
`eliminate_inductive` is consequently a retaining pass. Its source arm reusing
an old clause prsymbol for a construction axiom is unavailable; it is not
misclassified as a fresh-head producer.

Introduction's private `Wid`/queue and `Hsdecl`/`Wdecl`/queue families are
initially empty at all five cuts. This is a new source attachment:

1. Module initialization creates empty tables. `Gnat_main` calls
   `add_unique_prefix`, which only changes the attribute-prefix list.
2. Accepted fresh Per_Check, nonreplay/nonmanual initialization reaches
   `normal_handle_one_subp` → `init_subp_vcs` →
   `apply_split_goal_if_needed`. The sole strategy entry is
   `split_goal_wp_conj`: `split_goal_right`, `unfold_trans`,
   `Gnat_rewrite.elim_to_of_array`, then `split_conj`. None invokes Introduction.
   Registration of `spark_simpl`, `split_vc` and other closures does not apply
   them. In particular, `spark_simpl`'s `simplify_intros` is not selected.
3. Accepted prefix observers exclude earlier driver applications at the first
   four cuts. Input has one pre-cut `counterexamples_dependent_intros`; the
   false-meta result selects `remove_unused_from_context`. Its helpers do not
   call `ls_of_vs` or `find_fresh_axiom`. The standard-formatter initial-state
   theorem allowed both branches and did not itself establish this fact.
4. `add_ce_goal` requires the counterexample result branch after prover results.
   Registration does not call it. Further splitting uses the selected strategy.
   Accepted loader/native-client and failure/recovery exclusions remain in
   force: a failed initialization cannot reinstall this continuation.

After the cuts the accepted selected-owner envelope permits the selected
applications and existing save/escape paths, not arbitrary registered frontend
transforms. This provides the initial case for the chronological cache proof.

## Fixed generated producers

The type inventory has 21 / 21 / 18 / 15 / 16 Ddata entries. Only bool has more
than one constructor: two nullary constructors. All others have at most two
arguments. Every type head has zero parameters. There are 7 / 7 / 3 / 2 / 3
range types and no float. Removed entries are still charged. R58 supplies the
common `algebraic:kept bool` directive; R57 supplies its loader/clone attachment.
No intervening selected pass removes it.

On Z3/CVC5, projections on sums retains singleton records. Bool's projection
list is empty, but `elim_proj` creates its fresh local `v` **before** folding
that list. Charge one variable per actual pass, at most three in the conservative
per-episode union. It emits no definition or case. Compile-match sees only the
six context Dlogic cases, with two nullary patterns, a leaf scrutinee and
binder-free branches. No pattern variable is created. Goals and side axioms
are case-free.

On Alt-Ergo, bool's `kept_m` entry bypasses constructor replacement and the
multi-constructor selector/indexer/discriminator branches. All other Ddata
entries are singleton, so selector/indexer dispatch returns immediately.
Remaining producers are constructor clones, at most two projection completions
and clones with defining axioms, and one inversion axiom per type. Formulas,
including triggers, have mass at most 32 and at most two bound slots. Projection
axioms have mass at most seven; a two-projection inversion has mass at most
twelve. Fresh binders close with empty maps and axiom heads are fresh.
`add_tags`' material-argument list is empty; there is no material index
increment or array access. Type foundness/positivity uses R58's finite ground
forest. The complete R54 metadata inventories have no initial material-argument
meta, and the Alt-Ergo import closure supplies none; its configuration flags
remain at their defaults. Thus this excludes initial material arrays as well
as arrays from later zero-parameter data tags. A deferred tuple is an original Ddata, not a foreign formula producer.

Literal elimination replaces a constant/projection with a constant or nullary
application through a safe map. Each distinct encountered literal emits at most
a parameter and one fresh axiom of mass four (a string's axiom is `true`). No
float finite-predicate or exponent path is selected. Each range emits at most
three declarations and one ten-node, one-variable bound axiom. Caught
`UnknownIdent` during addition can retain only a prefix. Literal memo values
are nullary applications in the per-transformation fold state.

After wf removal, epsilons occur only in First's context and in First goal 13
and Input goal 3. Each is closed and case-free; its body is a binder-free
conjunction of `x = witness` and a property, with witness mass two and property
mass three. Optional inline preserves closedness, the conjunction/equality
shape and absence of binders: eligible bodies have no bindings, equality is
not eligible, and formal coefficients are at most one. Exact physical heads
and trees are in the inventory; no inline replay is claimed.

Guard epsilon replaces the epsilon by its closed witness and wraps its closed
property locally, adding no quantified variable. General epsilon then sees no
epsilon on Z3/CVC5. On Alt-Ergo the conjunction canonicalizes to `Nothing`;
a surviving epsilon emits a fresh nullary parameter and binder-free axiom.
The new parent projection places every surviving epsilon under the same
`infix <=` head. Its defining body has a disjunction root, so optional trivial
inline cannot replace that parent. General epsilon's equality-special arm is
therefore unavailable. No identity/partial canonical cache is entered; the initializer's `identity_def` cannot seed this family.

## Goal and generated returned fields

R57 remains the smaller envelope for original context keys. Its `V = 1`
leaf-image result is **not** assigned to goals or new premises. R56 supplies
complete stored goal seeds: every saved image, including unused entries, is
binder-free and has at most six nodes. This concerns the complete stored image,
not just its opened semantics.

The new projection has one exception to binder-free let **values** per
Put-family route: Put_Line goal 62 and Put goal 52. Its `(10,1,0,4)` value contains
one inner let, but its `(13,0,0,10)` body is binder-free. The paused note's common
“goal 62” label was incorrect. Its initial three uses are not relied upon;
later simplification may change the count.

| Producer/helper | Preservation of complete binder-free saved images |
| --- | --- |
| Opening, safe maps, compile-match, projections | Renaming adds variable images; retention keeps every field; closing resets the current saved map. Fixed context case branches are binder-free and no goal case is introduced. |
| First inline, already accepted | Eligible bodies contain no binder. R56 supplies the complete input seed envelope. |
| Guard/general epsilon | Witness/property bodies are binder-free and closed; equality-special substitution has a binder-free target. Put goals contain no epsilon. |
| Literal/full algebraic | Constant/nullary substitutions introduce no binder. Bool cases are kept; singleton data axioms have explicit empty-map constructors. |
| Introduction | Binder replacement uses nullary applications. Dequantification turns an exposed let into equality plus body, rather than substituting its value. A top-level let value moved to a nullary Dlogic remains a value-typed term. No term is moved into another let's value. |
| Right splitting | Case-free reconstruction rewraps source lets/quantifiers and adds logical connectives. It neither substitutes values nor puts premises into value-typed children. |
| Formula simplification | Formulas use `TermTF.t_map_simp`; values use `TermTF.t_map`. Nonleaf formula-let substitution requires live count one; zero drops it, and `small` otherwise admits only variables/constants. Binder-free images compose to binder-free images. The sole binding-bearing value can only substitute into its binder-free body. There is no let-value ancestor around that exception, and no selected producer creates one; its result cannot later become another let's value. |

This argument covers hidden fields: an image has no binder record in which to
hide another saved image. `bv_subst_unsafe` maps **all** old values, including
dead ones, then joins its restricted new map. Binder-free substitutions preserve
that complete property. The exception is checked at its real target; merely
observing a binder-free opened result would not suffice.

The new structural potential retains every let and also expands its value at
every use. A variable receives its environment weight; a nonlet costs one plus
child potentials; a let costs `1 + value + body[v := value]`, with bound names
shadowing the environment. It dominates every partial expansion, including
unused values. It is not the old scratch experiment that discarded all lets,
and is not simplifier execution. R56's optional-inline body mass ≤ 5 and formal
coefficients ≤ 1 multiply the potential by at most five. Process maxima Q are
7,170 / 5,795 / 5,210 / 99 / 610; the 99 floor covers context.

Give each field a source occurrence in this acyclic lexical expansion. Renaming
preserves it. Simplification substitutes the selected term's own let value;
its dependencies are lexical predecessors. Constructor/nullary replacement
does not increase value size. Dequantification and splitting change formula
structure, not that value-dependency graph. Newly saved nonleaf values are
bounded by Q. An initial dead CE image has at most six nodes, each free leaf
receiving at most a predecessor expansion, so `V = 6Q` covers the complete
image and later renaming. This is a source-origin invariant, not a consequence
of strict equality.

Successful public/private hashcons returns choose a **whole** older declaration.
Keep its existing origin and field bounds; do not merge them with candidate
fields. Subsequent rewriting opens that returned declaration and takes let
values from it. Strict equality is used only to attach its visible shape to
the candidate. Thus a cache hit does not mix one origin's hidden image with an
unrelated origin's new nonleaf expression. A reused nullary lsymbol has a
signature, not a stored term body. A Dlogic candidate using it can return an
old same-head Dlogic only on strict body equality, selecting the whole old body.
Goals use `Hsdecl.unique`; task/tdecl pointer reuse cannot substitute an
unrelated formula.

All fields preserve type mass T ≤ 5/3 and signature arity A ≤ 7. Generated
signatures are ground and have arity at most two. Introduction's initial
`t_ty_subst` has an empty type map; it still walks fields and issues type
hashcons requests, which are charged. It preserves typed shape and cardinality;
`gen_fresh_vsymbol` may clone a variable when physical type identity differs.
Each clone inherits the old variable's source occurrence and the same type
shape. Such renaming neither adds a binder to an image nor enlarges a saved
map or creates a new lexical dependency. The field/provenance bounds therefore
need no exact variable-identity or weak-table-entry-retention premise. The
extra registration charge below includes dead saved keys and failed prefixes.
Ignored polymorphic signatures are not confused with proposition-field types.
No selector type variable or encoding writer occurs in this branch argument.

## Introduction caches and chronological lineages

`ls_of_vs` has a weak bound-identifier table and queues of nullary lsymbols.
It returns the first symbol absent from the current known map or appends a
fresh one. `compat` examines signatures, not terms. `find_fresh_axiom` first
constructs the real ordinary Decl, then calls its private content Hsdecl. If
that representative's head is already known, it searches/extends its Wdecl
queue. Every private value originates after the initial-empty cut and satisfies
the field invariant. An older queue value is not assigned the candidate's
storage bound merely because content equality succeeded.

Successful outputs update `knl` before the next output. A queue-selected symbol
or proposition head is therefore used at most once in an invocation. Weak
clearing may cause fresh candidates; it cannot invent a value or exceed append
requests. Failure after an append still consumes that request. Real Decl-tag
allocation precedes private lookup, including content hits. The private Hsdecl
tag is discarded by the accepted
[Introduction-counter result](retained-why-introduction-counter.md); real Decl
tags, queue lengths and requests remain charged.

Guard epsilon can duplicate its binder-free witness into its property;
charge mass at most 2M after epsilon processing. For that goal and total source
slots P, dequantifying disjoint antecedents has total mass at most 8M. Right-intro splitting gives at most that many premises.
Names moved from bound to free remain included in P. Charge at most `8M+P`
variable/queue requests and `8M` premise/content requests per episode. Local
Hvs, substitution and known-map writes have the same source-occurrence bound.

A live binding cache has at most P keys; unused saved keys are counted separately.
A restricted substitution adds at most P keys. One productive walk opens at
most P source binders along a retained binding's lineage, hence adds at most
P² keys. The accepted right-split interface supplies `K + 4PL`, with live
keys L ≤ P: core opens original ancestors; optional `drop_byso` traverses the
original current subtree; an outer drop discards descendant results. Rebuilding
only recloses. No case compile-and-recur arm is selected.

Charge 64 productive walks per preparation lineage. This exceeds entry/inline
two; algebraic/projections three; literal one; guard/general epsilon four;
simplification two; premise splitting four; and sixteen for Introduction's type
map, dequantification, right split, opening/nullary substitutions and closure.
Validator temporary openings start from immutable fields and add no persistent
edge. Fresh side heads originate once; queue guards allow a reused head only
once per invocation; each selected stage handles it once. A memo hit jumps
backward in chronological history. An ancestry thus has at most `64E` walks,
with the **same** `E = 3N + e`, `e ≤ 2`, two save callbacks and three saves.
Failed-prefix objects are included before task insertion succeeds.

Let K0 be the larger of the R56 goal seed and accepted R57 context envelope.
Use `K = K0 + 64EP²`. With binder-free images, stored skeleton mass is no greater
than opened mass: replacing a variable by a nonempty image does not erase an
ordinary constructor. Thus `R = S(1 + KV)` covers all stored edges, including
dead entries. Independent validator walks use `K_open = K + 2P²`,
`R_open = S(1 + K_open V)`, and `U = S + (P+1)R_open`. These apply to returned
fields, not only fresh candidates.

## Composition, validators and integer owners

Let F be accepted maximum context formula mass sum plus M. Before literals use
`F_lit = 2F + 128 Ddata + 32` for all side producers, including removed entries.
A literal adds at most two declarations and four formula nodes; a range adds
at most ten formula nodes. A right-split family has at most input-mass members,
each at most three times its input mass. Introduction starts from disjoint
antecedents. The common envelope in `compose.py` is therefore

```
D = C + 16 F_lit + 16 Ranges + 8 Ddata + 8M + P + 4
S = 24M + 32
```

D bounds the declaration family and S every intermediate visible formula.
C is raw context count; M has context floor 99; P includes source formals and
bound names even after they become free. R58's raw-chain/driver-metadata bound
is extended by `9D` task nodes for declarations and metadata wrappers. The
new metadata attachment checks at most two dependency heads per original
axiom; no selected producer increases that set. A split clone therefore needs
at most two dependency metas. Projection/kept/tuple wrappers fit within the
same nine-node allowance. These
are upper bounds, not newly observed task lengths.

There are fewer than sixteen primitive subpasses in the selected union. Charge
64 traversal/callback units per subpass and an `(S+1)` factor for right-split
reconstruction: `units = 1024 D(S+1)` per episode. Covered source sites are
mapper/open-close callbacks; both successful-comparison operands; closure
free/type scans; definition opening/termination; used-symbol and known-map
scans; task type positivity/foundness/match checking; declaration hashing;
split reconstruction and internal term helper walks; Introduction dequantification,
free-variable discovery and nullary replacement; and side-formula constructors.
Original singleton recursion is absent and new nullary definitions cannot
mention their newly introduced head. There is no recursive termination-call
component. Match validation has only the fixed nullary context patterns.

The additional categories are `units·U` term/opening entries, `units·S·U`
free-variable entries and `units·(A+2)T²·U` read-only type entries.
`units·(P+1) + 3R_intro` bounds direct Ident registrations. The first summand
covers opening/generated-symbol sites: hidden-image walks open no binders
because the complete image is binder-free. The second separately covers
variable cloning in Introduction's generic type map, including dead saved
keys. Separate rows charge
logical-declaration, tdecl/task, metadata, literal-map and private cache/queue
requests. The splitter's scoped kernel count excludes internal substitution
and validation; these U-based categories provide them. Memo/old-return paths
retain the same envelope. Unsuccessful collision-comparand primitive costs
remain a separate interface.

The R59 comparator effect proof extends directly to this binder-free-image
family. Use fully **exposed** right-operand mass S and total source slots P,
not stored skeleton size. Virtual descent may encounter a nonleaf image, but
no additional binder. R59's paired entries ≤ S, bound counter ≤ P, private
map height ≤ P+2 and probes ≤ 2S² retain their source proof. No comparator
callback acquires an Ident or mutates a stored term. Hidden-image storage
bounds above remain separately necessary for producer/type/validator walks.

Overlapping traversal totals may exceed 2^62; no native integer stores those
mathematical audit totals. Actual arithmetic owners have different bounds:

- `t_vars` additions and `add_nt_vars` multiplication use visible/image
  occurrence counts, conservatively at most `max(S,V)²`, not total visits.
- List indices/cardinals, AVL heights and private queue lengths use their
  family/map/request bounds. Projection `i+1` is at most two; material arrays
  are empty; selector/indexer loops are absent.
- Decl/tdecl/Task/Ident tag demands come from actual constructors/registrations.
  Introduction's discarded private tag remains separate.
- Actual type hashcons requests use the separate constructor-site argument
  below, not the read-only type-entry total. Every request may conservatively
  increment the type tag; no unproved mandatory-hit/liveness claim is needed.
- Specified modular hash mixing is not treated as an identifier counter.
  Table backing/resize and primitive memory costs receive the insertion and
  key/image bounds but remain with their later resource owner.

Type hashcons has a separate source bound. Introduction's sole generic type
map runs on the **unique goal before Introduction and simplification**, so no
private returned premise is an input. The earlier selected passes only rename
its saved images; guard-epsilon witnesses do not become saved images. Set
`K_intro = K_goal_seed + 16P²` and `R_intro = 2M(1 + 6K_intro)`, with no E in
K_intro. For `t_gen_map`, count term nodes N (including every saved value),
bound slots B (including unused quantifier variables), saved keys J (including
dead keys), and free prepass keys F. Each is at most R_intro here: B ≤ P ≤ 2M
is checked from the retained family, J ≤ 2M K_intro, and F ≤ P. The unmemoized
bound is `T(N+B+J+F) ≤ 4T²R_intro`; no weak-memo persistence is assumed.
`gen_fresh_vsymbol` is called on the B bound slots, J saved keys and F free
prepass keys, and may register one fresh variable on each call. Add the explicit
`B+J+F ≤ 3R_intro` Ident charge per Introduction invocation. The common E-based
envelope charges it in every episode, overcounting the non-Z3 routes without
allocating another escape allowance. `direct_Ident_components` exposes this
summand inside the total, so it must not be added a second time by a caller.
This removes the earlier physical-identity argument: post-call uses establish
liveness but are not used to establish retention of a canonical table entry
through an earlier interrupted resize. Successful returned fields retain the
existing typed/source-correspondence premise and provenance-preserving variable
renaming; failed constructions still consume their preceding registrations.

Other reached type writers are algebraic/type/range `ty_app`, inversion's
`t_app_infer`, `create_data_decl`, and `Theory.create_meta`'s implicit type-symbol
to type conversion. Charge `64 H [F_type + F_constructor + (A+1)T]`, where H
is the complete task-node bound and the two F counts are R58's ground forest.
This deliberately covers all declaration/meta visits. Full algebraic's
`is_ts_tuple` only requests arity zero: its Ddata and single-Ddata Use heads
belong to the ground raw export family. A cold `ts_tuple 0` registers a type
symbol but issues no type hashcons request; a cold `tuple_theory 0` adds at most
two requests. These are included in the same charge and declaration envelope.

Ordinary explicit-type `t_app`/`fs_app`/`ps_app`, variable/symbol constructors,
term-only substitution, open/close and symbol/type folds reuse type pointers.
Successful `ty_match` is read-only. Mismatch diagnostics are excluded by the
valid typed-correspondence premise for differing type shapes. Ground Tyapp
matching is structural, but repeated polymorphic-variable matching compares
physical types and can reach the diagnostic when identity is not assumed.
Allow its `ty_inst` constructor work: at most one such diagnostic escapes a
preparation prefix, with signature-size-bounded input and at most T² requests,
already covered by the `64 H [F_type + F_constructor + (A+1)T]` allowance.
`ty_equal_check` raises with existing type objects and constructs no type.
Pattern's nonexhaustive diagnostic instantiates missing constructor arguments;
there are none in the only reached nullary patterns. Selected transformations
do not call the omitted-field record helpers, tuple term constructors or beta
helpers. Epsilon `All` with the exact conjunction/`Nothing` case excludes
lambda/closure/partial canonical builders. Split's type-building pattern
condition is unavailable on case-free inputs. Driver theory cloning happened
before R58; ordinary task additions/uses do not re-enter it.

The sum of these two actual request charges is 352,934,955,742,024 across the
five processes, including their shared e allowances. The same value is a
conservative possible type-tag increment bound. This refinement was prompted
by root review of an earlier provisional equation that incorrectly assigned
the entire read-only traversal envelope to constructor requests; that equation
is not the interface exported by this packet.

The arithmetic checks listed scalars/products and additional registration/
constructor demands against 2^62. It does not claim final initial-counter-plus-
whole-suffix headroom: preceding R56–R59 and later printing still have to be
composed at their owners. No aggregate-RAM gate or new environmental premise
removes a source obligation.

| Process | E | S | P | K | V |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 155 | 27,440 | 236 | 552,663,046 | 43,020 |
| Put | 128 | 22,424 | 190 | 295,862,278 | 34,770 |
| First_Or_Default | 68 | 19,208 | 144 | 90,312,710 | 31,260 |
| Is_Message | 8 | 2,408 | 8 | 40,966 | 594 |
| Input_Is_Valid | 5 | 2,408 | 15 | 77,126 | 3,660 |

No native target, solver, proof, capture or predecessor checker ran. New finite
checks use retained bytes; source simulation/provenance arguments are reviewable
mathematics, not machine-checked OCaml semantics. Selected author setting:
GPT-6 Astra / Extra High; runtime confirmation and token/cost telemetry are
unavailable. The 2026-10-20 start and owner-requested 2026-10-21 pause remain
historical entries in `round.json`; the owner authorized this continuation.
