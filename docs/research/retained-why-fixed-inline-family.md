# Weighted first inlining over the fixed five-domain family

2026-10-20 UTC, Linux x86_64, Round 56; research for #119 / #153.
Under the accepted initial-state/source correspondence and guarded mutation
premises, the fixed family needs at most **792,911 direct Ident registrations
inside first `inline_trivial` calls**, summed over its five distinct processes.
This includes all 118 registered roots, all three selected drivers, and the
existing **one e ≤ 2 allowance per process**. It does not allocate an escape
allowance to each stage. The 116 nontrivial registered roots are a subset of
this deliberately conservative family.

The [packet](../evidence/retained-why-fixed-inline-family-20261020/README.md)
extends the accepted weighted one-pair model. These are source-derived upper
bounds, not observed successful execution counts. They close the first-inline
semantic/direct-registration and kernel interface. They do **not** close the
hidden storage of old returned declarations, complete validator work, later
transformations/printers, or the whole quiet capacity rule.

## Exact family and attachment

R54's fixed root map joins each registration `(check_id, root_index)` to its
domain-local raw goal. The new calculation joins that goal to R51's task pointer,
raw formula pointer and ordered declaration sequence. All raw tasks in a domain
share the same context. The registered counts are 51 / 42 / 22 / 2 / 1; the
nontrivial counts are 50 / 41 / 22 / 2 / 1. R51's earlier selected counts
64 / 53 / 32 / 3 / 1 were a broader raw-goal selection, not this registration
map. No old total is silently treated as the new family size.

| Domain | Registered roots | Z3 raw-entry Ident max | CVC5 / Alt-Ergo CE-entry Ident max | Process sum with e ≤ 2 |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 51 | 2,754 | 2,412 | 375,917 |
| Put | 42 | 2,660 | 2,392 | 308,026 |
| First_Or_Default | 22 | 1,618 | 1,462 | 95,281 |
| Is_Message | 2 | 989 | 985 | 7,896 |
| Input_Is_Valid | 1 | 1,167 | 1,145 | 5,791 |

The selected driver order is Z3 → raw → inline, CVC5 → CE → inline, and
Alt-Ergo → CE → `monomorphise_goal` → inline. R51's ground-goal result makes
the last monomorphisation an identity here. Its separate validation registrations
remain a pre-inline charge, not part of the table above. R54/R55 attach the
raw/CE entry family under the inherited guards; the new checker confirms that
every exported CE seed has the corresponding candidate's fully opened typed
shape, including binders, triggers and patterns, modulo fresh alpha names.
It deliberately does not infer exposed attributes from strict equality.

Every matching application has a hit and miss alternative. Thus all actual
`inline:no` sets and additional `notls`/used-symbol exclusions are covered.
The actual R54 Z3 exclusion projections have 19 / 19 / 17 / 14 / 15 symbols;
their original physical symbols are joined to these exports. CVC5/Alt-Ergo
metadata need not be guessed or equated with Z3 metadata. Independent choices
also cover correlations lost when an old equivalent definition is returned.

The prospective mask remains **M = {SIGINT}**, with default unblocked SIGTERM,
supervisor-visible cancellation, SIGKILL fallback and reaping. No launcher was
changed. Unique tags, valid cached maps, well-formed finite bindings, fresh
identities, successful guarded mutations, allocation/stack/capacity and source
correspondence remain premises. This note does not settle the separate combined
quiet/timeless plus J12/logging startup join.

## Weighted model and older declaration returns

The adapter imports only the accepted weighted algebra, not a predecessor
checker. It opens the frozen R51 graph through its saved substitutions, applying
bound-variable shadowing and remaining outer frames, and retains attributes
for eligibility checks. A separate new targeted projection supplies actual
normalized types and signatures from the retained bytes. A body with nonformal
coordinates `c` and formal occurrence coefficients `q_i` contributes
`c + Σ q_i u_i`; Choice takes coordinatewise maxima, not sums. The inlined hit
is not recursively passed through `t_replace_all` a second time.

For every domain and both entry routes, eligibility's possible and certain
answers agree across all optional prior hits. The eligible-definition counts
are 89 / 89 / 57 / 38 / 45. All eligible bodies are binder- and pattern-free;
all formal coefficients are at most one. Each candidate output has no more
binder or pattern slots than its input. The source-only extension includes
the one inductive clause in each Put context, which the earlier pair lacked.

The old local distinct-key argument does not cover arbitrary later invocations.
Instead use the following induction, with the guarded valid-table premise:

1. An old returned Dlogic/Dprop/Dind has the candidate's declaration kind and
   ordered declared physical symbols. Strict equality follows saved frames and
   compares the opened constructors, binder-list lengths, triggers, patterns
   and types. Thus its opened typed shape matches the particular candidate,
   not merely a global dimension maximum. Valid binding free-variable caches
   make `t_closed` agree with that opened shape.
2. `inline:trivial` is absent from all selectable same-key Dlogic stored
   closures, including unused saved values whose attributes could later surface.
   The new complete initial Dlogic/Dind key projection finds only the exact raw
   object for each of 159 / 159 / 95 / 69 / 81 keys. Input's table is correctly
   treated as post-CE; R55's initial subset transfer applies. The raw/CE exports
   contain no force-inline attribute. The producer census below preserves this
   absence. This premise is stronger than strict equality alone.
3. With force-inline absent, `notdef` depends on the opened root, distinct
   variable arguments, closedness and epsilon shape. These are invariant under
   the valid alpha correspondence. Additional symbols found only in hidden
   storage can cause a self-reference exclusion; they can only suppress an
   environment insertion. The optional misses already cover that suppression.
4. An actually eligible returned **opened body** has no binder or pattern
   container. Therefore it has no hidden binder map for `relocate` or
   `t_ty_subst` to traverse. Its free-variable registrations are bounded by the
   distinct used formals. Opening its outer definition may still do arbitrarily
   large hidden-map work; it registers only the fixed formals. That work is
   explicitly outside the kernel operation claim.

Induction over declarations now gives the next candidate's weighted bound;
strict equality gives any old return the same opened shape. It does not require
that old returned maps belong to the input stored envelope. Repetition over
guarded preparations preserves the no-force and fixed-key conditions. Weak
clearing/removal does not invent a representation, and memo hits return a
previously covered result. Failed prefixes are bounded by a full episode.

## No-force producer census

The source archive is pinned at Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`. R54 already supplies the Z3 producer
argument. The new census covers the extra selected CVC5/Alt-Ergo routes and
their encoding branches without assuming CVC5's derived mono decision.

| Producer family | Original-key Dlogic and hidden-value attributes |
| --- | --- |
| Raw/CE entry and driver metadata update | Exact retained closures lack the force attribute. CE copies/substitutes input terms; its extra attributes are `id:unused` and `model_trace:`. Metadata update preserves logical declarations. |
| First inline | Opening/substitution/relocation copy or union existing attributes. The force attribute is tested, never attached. |
| Builtin/unused removal, polymorphism detection | Retain/drop existing definitions or partition their unchanged `ld` records; add metadata, not a force attribute. |
| Conditional definition elimination / recursion elimination | Retain original `ld`, or replace Dlogic by Dparam and a newly headed Paxiom. They do not synthesize an altered original-key Dlogic body. |
| Inductive elimination, introduction, premise splitting | Existing Dlogic is retained. New definitions/clauses use fresh identifiers; premise attributes and split markers are distinct from `inline:trivial`. |
| Guard/general epsilon and formula simplification | Rebuild from input subterms, capture-avoiding substitution, fixed Boolean/equality constructors and fresh lift symbols. Attribute operations copy input or use known model/split attributes. |
| Algebraic and projection rewriting | Match actions and surviving terms originate in input; rewriting copies their attributes. Constructor/projection replacements receive fresh identifiers. This applies to full algebraic and conditional branches. |
| Discrimination and encoding helpers | Retain old declarations or rewrite through input-preserving term maps; changed logical signatures receive fresh `id_clone` registrations. Type/guard/twin helpers use fresh symbols and `encoding:unprotected` / `encoding:unprotecting`, not the force attribute. Metadata selection adds no term attribute. |

This is an origin argument for attributes in all stored fields, including saved
images and variable identifiers, not just visible roots. Bind/open/close/type
maps never manufacture the force attribute from an absent input. New library
and generated definitions cannot have an original physical lsymbol under the
inherited freshness/source-origin premise; existing-key rewrites do not fetch a
foreign definition body by its display name. `id_clone` preserves attributes
unless explicitly extended; the extensions above are named and disjoint.
`source-witnesses.json` pins full source identities and exact excerpts, plus an
attribute-operation census. The whole-source literal scan is supplementary;
absence of a literal alone is not asserted to prove the producer theorem.

## Direct registrations and operations

For a call let `B_in` be input body/trigger/pattern-bound slots, `A` the summed
logic formal arities, `B_logic_out` the mapped logic-body slots, `B_out` all
mapped output slots, and `B_ind_out` the inductive clause slots. Then

```
K_Ident = B_in + Σ_hits (2 B_body + distinct_used_formals)
I_inline ≤ K_Ident + 6 A + B_logic_out + B_out + 2 B_ind_out
```

The six formal-opening sites retain the accepted call-graph accounting. The
additional inductive charge covers clause-prefix opening and the positivity
walk (`decl.ml:543–601`); the latter can open the remaining formulas. Stored
symbol/type folds add no Ident registrations. Pattern compilation introduces
none because every captured pattern is a nullary constructor with no variables.
Task validation uses **output** binder ceilings, including old strict-equal
returns, not an assumed input equality. These are direct source registrations,
not exception-handler, later-stage or allocator counts.

For each process and any additive demand `D`, the composition is
`Σ_registered (D_raw + 2 D_CE) + 2 max_registered,route D`.
There are 354 ordinary root/driver pairs and at most 364 first-inline episodes
over the five processes. The two trivial roots remain included. The same
process-wide escape variable must be used when joining other stages; summing
per-stage maxima with the common e = 2 is an upper bound, not independent
permission for two new interruptions at every stage.

| Summed first-inline demand over five processes, including e ≤ 2 each | Upper bound |
| --- | ---: |
| `t_replace_all` recursive entries | 1,329,417 |
| `t_unfold` hit plus miss calls | 541,742 |
| Optional environment hits | 76,103 |
| `relocate`, body type-map, post-type substitution entries, each | 141,889 |
| Kernel Ident registrations | 201,965 |
| All direct inline Ident registrations | 792,911 |
| Recursive type-instantiation / type-hashcons requests | 952,057 |
| Type-matching recursive entries | 126,500,872 |
| Range integer comparisons | 283,778 |

The targeted type projection and every generated model term have type mass at
most 5 in Put_Line/Put and 3 elsewhere; arity is at most 7 and signatures have
at most two type variables. A single instantiation's intermediate type mass is
bounded by `T²`. Put's extra eligible literals are range integers 0, 1 and
`2^64−1` in `[0,2^64−1]`; `check_range` performs at most two comparisons on
operands of at most 64 bits. Other eligible constants are builtin unbounded
integers. No float/string literal path is silently included in this argument.
These counts do not assign a native time/heap cost to each arbitrary-precision
operation.

## Candidate storage and the remaining returned-value boundary

The finite input inventories check binder-free saved values and the stronger
composition condition: no key with a nonleaf saved value occurs free in any
composable seed value. Put's CE values can have **three** free occurrences;
the original one-pair unary-value condition is therefore not reused. After
the original finite seeds, new substitutions in this candidate path add only
fresh variable renamings. Since a fresh name cannot be an original nonleaf key,
composing these maps only renames leaves. Multiple free leaves do not enlarge
the saved value's fixed node bound `V ≤ 6`. The unused-entry inventory counts
every stored edge, including all allowed CE seed alternatives.

With `E` that seed-entry upper bound, `P` body-bound plus formal slots and `M`
the reconstructed semantic formula mass, use `K = E + 2P` and
`R = M(1 + KV)`. The two traversals cover construction and an independent
candidate validator; repeated validators restart from the immutable candidate.
Maximum `(M,R)` by process is `(1378,828685)`, `(1123,621231)`,
`(943,741494)`, `(99,3465)`, `(105,25047)`. Per-root values, rather than products
of global maxima, produce the summed arithmetic in `result.json`.

The candidate operation envelope gives 1,049,980,883,720 hidden substitution
term entries and 3,119,029,510,765,673 free-variable scan entries over the family.
These are conservative source-operation counts for construction on fixed inputs
and bounded candidates. They fit the signed 63-bit range, but do not assert that
initial shared counters plus later demands fit, or that the computations finish
within a wall-clock/memory budget.

**These candidate bounds do not apply to arbitrary old returned storage.** An
older strict-equal Dlogic can have an unbounded unused map in its formal wrapper;
an old Dprop can have unused binder-map entries and extra stored types. Its
opening/symbol-type validator still observes those fields. The accepted
unused-map counterexample remains applicable. The new semantic argument closes
direct registrations and the binder-free hit kernel without erasing that
counterexample. Whole stored-validator/type folds, collision comparisons,
allocation/collection/stack, map/cache backing and initial shared counters still
need their own producer envelope or another supported invariant. No new bound
for later transformations or printers is exported.

No target, solver, proof, native capture or predecessor checker was run.
Selected author model/effort: GPT-6 Astra / Extra High; runtime confirmation and
token/cost measurements are unavailable. `round.json` records the finite
calculation, the two newly exposed old-contract restrictions and their bounded
repairs. The source arguments are reviewable correspondence arguments, not
machine-checked OCaml semantics.
