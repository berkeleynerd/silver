# Fixed raw-task prefixes into inlining

2026-10-20 UTC, Linux x86_64, Round 51; #119 / #153.
The actual CE-off prefix has a finite stored-input family and a direct Ident
charge for all five retained raw-task domains on the **retained serial
continuation**. Alt-Ergo adds no fresh type
symbols, but its goal reattachment still opens binders. Under the named source,
cache, representative and interrupted-episode premises below, these prefixes
register at most **317,937 identifiers across the five separate processes**,
or **317,465 after the retained cuts**. This is a component bound; it excludes
update, transform initialization, callbacks and inlining itself. It does
**not** close the stored-input family for the intended parallel launch.

The [packet](../evidence/retained-why-preinline-prefix-20261020/README.md)
contains a new stored-term CE evaluator, complete same-key table projections,
per-goal certificates and explicit stored graphs. It reads retained evidence
without a native execution or predecessor-checker replay. Finite extraction,
source excerpts, graph joins and arithmetic are checked; the source simulation
and continuation argument are reviewed mathematical obligations, not a
machine-checked OCaml theorem. Why3 is pinned to
`9390baf120ef260547dfa14f08e11c890b203d9c`, with the inherited source/native
and faithful-runtime relation.

## Actual routes and domains

The retained driver bytes and accepted
[dispatch result](retained-producer-driver-envelope.md) agree:

| Driver | Transformations through the inline entry |
| --- | --- |
| CVC5 | `counterexamples_dependent_intros`, `inline_trivial` |
| Z3 | `inline_trivial` |
| Alt-Ergo | `counterexamples_dependent_intros`, `monomorphise_goal`, `inline_trivial` |

`prepare_for_counterexmp.ml:15–35` selects
`Introduction.remove_unused_from_context` when counterexamples are off.
The registered raw session task, rather than another driver's prepared task,
is supplied on every preparation entry, as established by the accepted
[task interface](retained-cvc5-task-acceptance.md). The metadata-only prefix
preserves its logical declarations under that interface's valid-cache relation.
The direct cost of its final raw-goal reattachment is the separate
[Round 50 summand](retained-why-goal-revalidation.md).

The current PIDs are 17310 / 17514 / 17631 / 17704 / 17869. The selected
supersets are all 64 / 53 / 32 / 3 split leaves in the first four cases and
only goal 3 of Input_Is_Valid. Root goals are also decoded and checked, but
are not selected solver inputs. Every task within a process has exactly the
same preceding tdecl sequence: 1,043 / 1,043 / 535 / 367 / 433 nodes,
including metadata and uses. There are 573 / 573 / 301 / 205 / 243 logical
context declarations. This shared raw prefix is checked by physical tdecl
identity, not inferred from similar printed text.

Z3's inline input is the raw logical family. CVC5 and Alt-Ergo use the CE
family below; monomorphisation preserves its formula and context here. This
result is specific to these fixed graphs and the controlled quiet-prefix
transfer. It does not classify arbitrary later invocations.

The accepted [parallel launch analysis](retained-solver-launch-profile.md)
expressly distinguishes its prospective `J > 1` owner theorem from the
retained serial states. The numeric episode composition and the first-fill
argument here use Round 34's serial attachment. Listing all three driver
prefixes does not establish their arbitrary-order or parallel stored-input
coverage.

## Source-shaped CE transfer

`Introduction.remove_unused_in_decl` (`introduction.ml:513–524`) drops an
unused parameter or unused singleton logic definition, leaves other
nonpropositions unchanged, and maps each proposition with
`Term.remove_unused_in_term`. The evaluator follows that function's polarity
routes (`term.ml:1850–1888`), `t_map_simp` (`:1794–1814`), simplifiers
(`:1589–1765`), delayed substitution (`:739–780`), opening and optimized
closing (`:799–862`), and attribute copying (`:648–658`). It preserves stored
bodies, triggers, free-variable occurrence maps, saved substitution maps and
physical identities used by close shortcuts. A saved map entry remains in the
export even when the opened term no longer uses its key.

Substitution composition is left-biased at the same places as the source.
An opened bound variable shadows a saved entry; a replacement term is then
interpreted using the remaining outer frames. The let simplifier can both
substitute its expression and retain a let, and quantifier pruning can open
a binder a second time. Both effects are modeled and charged. The local
evaluation order may name fresh variables in another order; the attachment
is modulo fresh-variable renaming, with existing physical symbols and types
preserved. No allocation-address, wall-time or complete native-heap equality
claim follows.

Every evaluated proposition closure is case-free. Logical definitions remain
unchanged; their twelve pattern occurrences per task are all nullary
constructor patterns, with no bound variables. The evaluator visits Tiff and
formula-Tif source branches, but the conditions that expand them never hold
on these inputs. The unused-equality rewrite also never fires. These are
checked finite facts, not general assumptions about CE removal. Counts over
all decoded raw goals plus the single shared context are:

| Case | Eliminated lets | Kept lets | Let substitutions | Iff / if expansions | Unused equality rewrites |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 2,267 | 277 | 956 | 0 / 0 | 0 |
| Put | 1,730 | 239 | 749 | 0 / 0 | 0 |
| First_Or_Default | 529 | 297 | 327 | 0 / 0 | 0 |
| Is_Message | 34 | 7 | 20 | 0 / 0 | 0 |
| Input_Is_Valid | 10 | 3 | 8 | 0 / 0 | 0 |

Equality uses the physical BuiltIn equality lsymbol. The checker identifies
the fourth logical declaration after three Dtypes, verifies its unique
`infix =` name and binary polymorphic predicate signature, and preserves that
pointer throughout evaluation. The pinned BuiltIn source creation/order
(`theory.ml:180–203,1020–1029`, `term.ml:538–554`) supplies its attachment
under the inherited source/native relation. The raw capture does not expose
the enclosing `Use` theory payload, so this is not an independent dynamic
proof of the BuiltIn global's address.

For each mapped root, n counts opened term occurrences, b counts opened
binder slots, p counts pattern occurrences, and a counts applications.
Triggers contribute with their full multiplicity. A logical definition's
mapped root is its body after opening its formal parameters; formal arity is
recorded separately. Maxima of the **sum over mapped roots in a selected
task** are:

| Case | Raw n | Raw b | CE n | CE b | CE p | CE a |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 4,797 | 612 | 4,381 | 441 | 12 | 1,836 |
| Put | 4,588 | 566 | 4,260 | 432 | 12 | 1,786 |
| First_Or_Default | 2,677 | 352 | 2,414 | 240 | 12 | 994 |
| Is_Message | 1,496 | 173 | 1,425 | 148 | 12 | 520 |
| Input_Is_Valid | 1,637 | 179 | 1,613 | 168 | 12 | 594 |

Every decoded proposition, including hidden saved values and quantifier
variable types, has no free type variables; the transfer preserves this.
At `libencoding.ml:263–276`, `monomorphise_goal` therefore takes its empty-set
branch, creating neither a fresh type symbol nor a Dtype declaration. It
returns the existing goal formula with the existing prsymbol. `Trans.goal`
still passes that goal through `Task.add_decl`; its validator's binder charge
is retained below.

## Stored representatives: initial family and continuing invariant

Opened alpha equality alone cannot bound hidden maps. `Hsdecl` may choose an
older strict-equal proposition whose unused saved entries differ. Accordingly,
the checker reads **every occupied slot of each complete retained Hsdecl
table**, validates bucket/hash correspondence and graph closure, and projects
every `Dprop(Paxiom,pr,_)` with the physical prsymbol of a raw context axiom.
Goals use `Hsdecl.unique` and do not select old declaration representatives
(`decl.ml:55–75,409–419`).

| Case | Old declaration objects | Raw Paxiom keys | All same-key objects | Coordinate-compatible old objects |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 6,917 | 243 | 243 | 241 |
| Put | 6,917 | 243 | 243 | 241 |
| First_Or_Default | 6,763 | 75 | 75 | 69 |
| Is_Message | 6,672 | 53 | 53 | 51 |
| Input_Is_Valid, after first CE | 6,704 | 61 | 64 | 61 |

For the four registration cuts, each same-key object is exactly the raw
context declaration: there is no additional old same-key object. An old row
is excluded only if its opened n/b/p/a/trigger-group coordinates differ from
the candidate's. Strict equality implies equal coordinates, so this exclusion
is safe. Conversely equal coordinates do **not** prove strict equality; such
rows are conservatively retained. For example First_Or_Default's
`input_is_valid__post_axiom` is rebuilt but keeps coordinates (7,2,0,2), so
both its candidate and raw stored forms remain in the family.

The initial family for each context declaration contains its source candidate
and every compatible old same-key representative. Input_Is_Valid instead
uses its already observed successful CE context and its source candidate.
Nonpropositions pass through unchanged or are dropped. The Input source
candidate has 244 logical declarations and 143 mapped roots. Every full
candidate formula equals the retained inline-entry formula modulo alpha,
including triggers and existing symbol/type pointers. Its 1,933 stored terms,
157 binder records, three nonempty maps, eight saved entries and maximum map
size six also equal the observed counts. This is an observed logical join
and a count comparison, **not complete stored-graph isomorphism**.

The family remains sufficient for later successful prefix entries under the
following source/cache/freshness induction. These premises supplement, rather
than replace, the accepted valid immutable-task/cache relation:

1. On the retained **serial** route, before the first successful CE fill for
   a raw context key, no downstream task transformation has run on a task
   sharing this context. The fresh scheduler selects
   the first untried CVC5 pair (`gnat_checks.ml:714–724`); failed preparation
   does not advance through its downstream list or requeue that failed
   goal. `has_been_tried_by` requires a non-None proof state and treats
   Not_found as false (`gnat_checks.ml:469–482`); InternalFailure leaves the
   state unset and the GNAT callback only warns (`gnat_main.ml:110–114`).
   Only a nonvalid Done can select another prover for that goal; Done
   requires the preceding preparation to have returned. Every goal has the
   same checked context, so a successful CVC5 preparation for a different
   leaf has also filled all these keys before downstream transformations
   run. All transforms are resolved
   before update/CE (`driver.ml:373–389`), and resolution can read fixed
   libraries (`eliminate_literal.ml:193–199`), as recorded by the accepted
   [tuple-preparation analysis](retained-why-tuple-preparation-bound.md).
   Parsing a new proposition creates a fresh prsymbol
   (`parser/typing.ml:1576–1580`); a core clone likewise creates a fresh
   prsymbol (`theory.ml:706–711,842–851`); the program-module clone also
   creates a fresh proposition head (`pmodule.ml:821–833`). Symbol-reference
   lookup is not a new Dprop constructor. Under the inherited freshness/no-wrap and
   source relation, new library heads cannot acquire the raw physical
   Paxiom key. Reused exported declarations are already in the retained/raw
   family. Metadata update does not construct a new logical axiom. Thus the
   only new same-formula candidates before first fill are the modeled CE
   candidates themselves, including candidates from interrupted first fills.
2. `remove_unused_from_context` is one top-level `Trans.decl` closure. Its
   `Trans.store_decl` memo is keyed by each raw declaration, and goals bypass
   this per-declaration memo (`trans.ml:114–140`). Immutable session tasks
   keep the raw context keys strongly reachable. Ordinary Wdecl ephemeron
   semantics therefore keep a completed memo result reachable while its key
   and the closure remain live. Only a successfully returned mapping is
   installed. No cache clear/remove, foreign mutation or invalid hash/tag
   behavior is introduced by this route.
3. A live result does **not** rule out recomputation. `Weakhtbl.memoize`
   catches `Not_found` from its find (`weakhtbl.ml:95–100`); a signal-origin
   exception can force a false miss. During that recomputation, the previous
   successful family value remains live until replacement: `let v = fn e`
   completes before `set h e v`. Its strict-equal
   Hsdecl representative is therefore also live. `Weak.merge`/`find_or` has
   no catch around `H.equal` (`weak.ml:272–294`): an exception there aborts
   the operation; it cannot convert a found equal object into a new insertion.
4. Hence a later downstream constructor of the same strict formula returns
   a live family representative. Other formulas with the same prsymbol may
   enter the table, but fail strict equality against the deterministic CE
   candidate. A successful recomputation can select an existing family value
   or its modeled candidate, never a new representation accumulated from
   unbounded downstream history. Replacement by such a value preserves the
   invariant. Before the first successful fill, interrupted constructions
   can add only the same candidate family, so the same argument initializes.

This uses ordinary successful memo/table semantics and the inherited valid
cache-preservation relation. It does not claim immunity to arbitrary
interrupted table corruption, forged identifiers or foreign mutation.
Freshness is a semantic/source premise here; unlike Round 50's local
variable-shape charge, this result is not claimed independent of freshness.
An eventual first-overflow proof must use the conditional prefix lemma up to
its first invalid counter state, not assume a completed no-wrap theorem.

This first-fill step is **unclosed for the intended parallel route**.
`gnat_checks.ml:1055–1079` queues CVC5, Z3 and Alt-Ergo when parallelism exceeds
one. `controller_itp.ml:528–534` catches a preparation exception and reports
InternalFailure; the parallel callback ignores it, and idle processing may
pop the already queued Z3 item. Thus CVC5 may fail before a context key's
first fill, Z3's downstream transforms may run, and Alt-Ergo may later make
that key's first successful CE call. The serial proof does not exclude new
same-key stored representatives in this interval. Closing that concrete
parallel predecessor family remains a #119 obligation; the current union
must not be used as its unconditional inline input. Input_Is_Valid's already
observed successful seed still supplies the local post-fill invariant.

The local **opened-dimension and direct Ident** argument is separate: CE
receives the fixed raw declarations, and a valid Hsdecl lookup returns a
strict-equal candidate. That equality preserves the opened binder charge
even if an additional hidden representative exists. Hidden substitution
traversal itself registers no identifiers. Those local claims do not need
the serial first-fill stored-family closure; the numerical episode total
below still uses its separately named serial caller theorem.

The exported union keeps both possible stored representations when needed,
all hidden map images, variables, symbols, root indices and ordered raw task
declarations. Source candidates are taken up to consistent fresh-variable
renaming. These are per-task envelopes, not a bound on the total live heap
over all retries. Coordinatewise maxima over selected CE seed unions are:

| Case | Stored terms | Binder records | Nonempty maps | Saved entries | Largest map | Largest saved image n / b |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 4,917 | 360 | 12 | 32 | 10 | 6 / 0 |
| Put | 4,802 | 353 | 12 | 32 | 10 | 6 / 0 |
| First_Or_Default | 2,723 | 241 | 20 | 25 | 6 | 6 / 0 |
| Is_Message | 1,706 | 130 | 1 | 6 | 6 | 1 / 0 |
| Input_Is_Valid | 2,038 | 163 | 4 | 14 | 6 | 6 / 0 |

The union can be larger than any actual task. It is a finite concrete input
for a subsequent inline analysis; it is not justified by merely multiplying
Input_Is_Valid's old single-call inline bound. The packet also exports raw
stored graphs for Z3. Every decoded input/candidate/family binder's free-map
counts are independently recomputed from its opened body and triggers:
8,143 / 6,421 / 2,657 / 224 / 262 binder records pass.

## Direct Ident charge and episode composition

The CE mapper charge counts every actual fresh binder opening and unused-copy
constructor in its source-shaped execution. Substitution, closing, ordinary
term construction and proposition reconstruction register no identifiers.
The latter reuses its prsymbol. This direct charge is distinct from stored
term/map size and from the cost of later traversing that state.

`Trans.gen_decl` folds every resulting declaration through `Task.add_decl`.
The conservative charge ignores beneficial cache hits and early known-map
rejections. `Decl.decl_fold` opens each logic definition's formal variables
before visiting its body (`decl.ml:635–649`). `check_match` then opens the
mapped-root binders once (`:743–752`). Thus validation charges the sum of
mapped-root b plus the logical definitions' formal arities. The twelve
nullary pattern nodes have zero branch-bound variables and zero constructor
arguments, so their second branch opening and Pattern.compile fresh argument
lists contribute zero. Pattern compilation receives a nonempty scrutinee
list and does not create a dummy input variable (`pattern.ml:115–156`).
Ddata positivity/foundedness checks add no Ident registrations.

Old strict-equal axiom representatives have the same opened binder charge;
their extra unused map entries do not introduce opened binders. Only binder
opening, rather than arbitrary hidden-map traversal, registers here. The
case-free proposition fact and unchanged nullary-pattern logic context
therefore apply equally to every selected family member.

Write C_g for CE mapping plus validation on selected leaf g, and B_g for
its post-CE goal binder mass. Alt-Ergo's empty-type-set mono branch adds B_g
through `Trans.goal -> Task.add_decl`; it is not assigned zero merely because
it creates no type symbols. Z3 has no transformation in this prefix.

| Case | max C_g | sum C_g | sum B_g | max (C_g+B_g) | Full prefix allowance | After current cut |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 1,269 | 72,593 | 2,340 | 1,335 | 150,196 | 150,196 |
| Put | 1,214 | 59,124 | 1,743 | 1,271 | 122,533 | 122,533 |
| First_Or_Default | 775 | 18,743 | 747 | 847 | 39,927 | 39,927 |
| Is_Message | 436 | 1,246 | 6 | 440 | 3,378 | 3,378 |
| Input_Is_Valid | 472 | 472 | 5 | 477 | 1,903 | 1,431 |
| Sum over separate processes | | | | | **317,937** | **317,465** |

The accepted [Round 34 interrupted-episode theorem](retained-why-path-writer-capacity.md#actual-cut-and-repeated-pair-charge)
injects first preparation episodes into selected (goal, prover) pairs and
repeated episodes into a **single global e <= 2 budget per process**. Each
preparation invokes each listed transformation at most once. A failed prefix
costs no more than a completed source walk. First CVC5 and Alt-Ergo pairs each
charge C_g; first Alt-Ergo also charges B_g. Any repeated pair is bounded by
max(C_g+B_g), giving

```text
R_prefix,p <= 2 * sum_g C_g + sum_g B_g + e_p * max_g(C_g+B_g).
```

This includes cache recomputation and failed first fills without claiming that
every service failure consumes e. The injection, rather than a per-service
assumption, bounds repeated preparation entries. It also deliberately charges
the shared context once per episode, although its successful memo normally
allows reuse; the context mapping alone is 365 / 365 / 176 / 151 / 167.
The global escape budget is inherited, never renewed per goal or transform.
This composition is attached only to the retained serial continuation;
no parallel episode-bound transfer is claimed.

Input_Is_Valid's active first CVC5 CE prefix has already returned at the cut.
Its mapping charge is 181 and validation charge is 291 (168 mapped binders
plus 123 formal openings), totaling 472. Removing that completed allowance
gives the post-cut column. This subtraction is not a measured Ident delta.
Both remaining ordinary pairs and up to two repeated pairs remain charged.

The result excludes Round 50's update charge, transform lookup and fixed
library initialization, pending save/report callbacks, inline itself and
later transformations. These are component boundaries, not zero-cost claims.
Full preparation capacity and `I + R_all <= 2^62-1` still require those
remaining charges and all inherited preservation/source obligations. This
packet neither completes #119 nor changes Oracle, language admission, tools
or pins; production #88–#94 remains unstarted.
