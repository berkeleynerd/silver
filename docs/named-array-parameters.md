# Named constrained Integer-array parameters

## Selection and boundaries — 2026-11-21

The owner instructed **“Proceed”** after the recommendation of this new language
feature. [The dated authorization](session-memory.md#2026-11-21--named-constrained-integer-array-parameters-selected)
selects [#410](https://github.com/berkeleynerd/silver/issues/410), in
[milestone 27](https://github.com/berkeleynerd/silver/milestone/27), as one coherent
capability with one shared final validation and review checkpoint. Implementation,
validation, independent review and the accompanying feature PR are authorized.
This plan describes selected development; it does not claim current support.

The three included forms share one constrained array identity and bounds model:

1. Named constrained fixed-size Integer-array types and initialized objects of
   those types, reusing the admitted Integer component and index machinery.
2. Read-only array `in` parameters in existing Main-local functions **and
   procedures**, alongside existing scalar parameters and scalar results/outputs.
3. Bounds queries `'First`, `'Last`, `'Length` and `'Range` from the statically
   known bounds of the named Integer arrays and existing anonymous Integer-array
   objects, using their common fixed-bound metadata.

Dot product and Horner polynomial evaluation are the task drivers. Neither is a
samples-only substitute for the selected language work. Array `out`/`in out`
parameters, array results, unconstrained/null/multidimensional arrays, slicing,
whole-array operations and a separate expansion of subprogram-local array
objects are excluded. Existing anonymous-array support remains intact.
Boolean or Character named-array types are not selected. No Oracle amendment,
new trusted boundary, source-limit increase or new proof/report infrastructure
is selected. A necessary semantic mechanism outside these boundaries calls for
a recorded scope reassessment rather than silently extending the batch.

## Selected declaration, call and bounds rules

Declare an ordered Main-level type as `type T is array (L .. H) of C;`, where
`C` is `Integer` or an earlier admitted named Integer subtype. It is one
dimensional, ascending and nonempty with static Integer bounds. Compute its
length using wide arithmetic and require `1 <= H - L + 1 <= 2048`, including
unused types. This is a new explicit per-type scope limit: its numeric ceiling
matches the existing source-derived object-cell pool
([`silver_array_bindings.ads`](../src/silver_array_bindings.ads)), while limiting
the declared type ensures materializable length and an Integer-valued Length.
It does not reuse the stored-object pool as a formal-count or capacity charge. Keep the full signed Integer endpoint domain, including negative and
non-1 lower bounds. A type declaration needs no accompanying object. Multiple
array formals do not collectively consume the object-value capacity.

A named object has `A : [constant] T := ...` with the existing complete positional
aggregate or exact static singleton named choice. Keep complete initialization
and current component update rules for mutable Main objects. A named type's source
declaration supplies its identity: another declaration with identical shape is a
distinct type. An anonymous array does not acquire nominal identity by shape: array actuals
require the same positive named-type identity, even though anonymous Integer-array
objects can supply bounds-query prefixes.
Unknown, later or wrong-kind type names are rejected. Main declarations share
one case-insensitive namespace. Formals/locals cannot collide with an earlier
named type, following the earlier Integer-subtype rule; loop binders may hide
existing type, formal or object spellings. A binder does not resolve to itself
in its own specification. Types remain visible by ordered lookup inside closed
subprogram bodies, without exposing outer Main objects.

An array formal has explicit mode `in` and that named type. Its actual is a bare
visible object or enclosing `in` formal of exactly the same declaration identity.
Repeated read-only inputs and forwarding to earlier subprograms are allowed.
Both existing function and procedure forms admit mixed scalar/array signatures,
with positional, reordered named and positional-prefix/named-suffix associations.
Existing nonrecursive earlier-only calls and placement rules continue. Procedures
still require a writable scalar formal; results, writable outputs and copy-back
remain scalar. There is no array assignment, result, writable formal or additional
whole-array expression use.

Within a subprogram, every array component read is nonstatic with the component's
full declared interval, independent of actual aggregate values or current Main
state. Check the complete index and input domains, every path and all permitted
compositions. Array formal and component writes are rejected. Keep scalar input,
result, procedure initialization, incoming-state and alias/copy-back guarantees.

`T'First`, `T'Last` and `T'Length` return `L`, `H` and wide-computed `H-L+1`.
These queries are static on the named constrained type, its constant/mutable
object or its `in` formal: their values depend on the static subtype, not the
components (Ada RM 4.9 paragraphs 8 and 32). Each scalar query counts as one
operand and zero operators; synthetic bound arithmetic consumes no user operator
budget. `for I in [reverse] A'Range` or `T'Range` uses `L .. H`, retaining finite
forward/reverse iteration and existing range-mask/hiding rules. `'Range` is a
range construct, not an Integer expression or component read.

Query prefixes are simple visible named Integer-array type, object or formal
names, or existing anonymous Integer-array object names. Anonymous-object queries
use the same fixed-bound metadata and static scalar-query rules. Only the default
first dimension is admitted, with no explicit `(N)`.
`'First`, `'Last` and `'Length` are scalar atoms wherever existing scalar/static
expressions are permitted: declarations/bounds, subscript expressions, aggregate
singleton choices, predicates and scalar actuals. `A (A'First)` is one component
read with a bounds query, rather than a nested component read. Local initializers
retain their existing ordering before incoming formals: visible `T'First` is
available there, whereas formal `A'First` becomes available at body entry.
Boolean-array types, parameters and attributes remain unselected.

## Faithful callable drivers

[Dot product](../rosetta/d/dot-product/task.wiki) requires a callable function
multiplying corresponding terms of same-length vectors and summing them.
Arbitrary length is optional. Use the required `[1, 3, -5]` and `[4, -2, -1]`
example, with result `3`, through a genuinely array-parameterized function.
A shared named constrained three-element type supplies equal bounds by type;
use declared bounded components and executable guards wherever arithmetic needs
them. The function must check over every permitted component value, rather than
specializing its proof to the two Main aggregates.

[Horner's rule for polynomial evaluation](../rosetta/h/horners-rule-for-polynomial-evaluation/task.wiki)
requires a routine taking coefficients in increasing power order and a value of
`x`, evaluating by reverse multiply-add. Use `[-19, 7, -4, 6]` at `x = 3`, with
result `128`. A procedure with a read-only coefficient array, scalar input and
existing scalar outputs exercises the second call kind. Use a bounded accumulator
and visible executable refusal when the next step cannot safely fit; do not
truncate, saturate or change the polynomial on a failure path. Derive the required
guards for the entire declared coefficient, `x` and accumulator domains.

Both samples should use the bounds queries meaningfully. Exercise callable
forwarding and named/mixed composition in focused regressions where that makes
the sample clearer. Expected output, including Image spacing and refusal paths,
must be derived independently. Samples demonstrate the rules; they do not supply
the universal assurance argument. Confirm faithful assessments against the task
text instead of copying the stored unconstrained-array approaches unchanged.

## Shared implementation and proof work

Use the existing scalar call-selection, constrained-array checking, loop ranges
and declared-interval evaluation as the foundation. Extend native metadata and
its Lean interpretation together so type identity, bounds and component ranges
are explicit across declaration lookup, formal binding, indexed reads and calls.
The retained source-derived formal pool is not permission to add a separate
arbitrary type, array-parameter or call-frame count limit.

Derive capacity for new type/object/formal metadata from accepted source bytes.
Account for bound arithmetic, storage/stack use, array reads in calls, native
obligation production and report envelopes. Inspect actual pinned-producer
obligations before adjusting report classification; do not accept broader output
messages speculatively. Preserve exact admitted source bytes through verification
and compilation. Keep report provenance and full obligation coverage mandatory.

Extend the semantic composition argument for declared-domain component reads,
range/index checks, attribute results and staticness, matching actual identity,
read-only forwarding and mixed array/scalar binding. Include functions and
procedures, Boolean/scalar contexts, loops, branches and unreachable paths.
Preserve procedure alias analysis of actual payloads and existing scalar writable
outputs; no array copy-back or array-result semantics are introduced.

Review handwritten source-shape pins with their actual native changes and
semantic/source proofs. A new pin or successful separate model does not establish
source correspondence. Source-derived capacity and complete automatic-discharge
claims remain part of assurance, rather than optional later hardening.

## Verification and single final checkpoint

Keep one implementation issue: the work is a single capability, not one increment
per agent or proof component. Commit-sized changes remain reviewable without
creating separate deliveries or declaring a partly implemented form supported.
Live state, claims and handoffs belong on #410; this record holds stable design
and links actual evidence when it exists.

Before expensive integrated validation, read the managed run summary and establish
focused complete-contract native success for every new/contract-changed helper,
including strengthened callees and affected callers. Use canonical
`dev.py prove --unit FILE` or `--subprogram FILE:LINE`; inspect policy and
whole-helper coverage, including malformed/empty states allowed by preconditions.
Check corresponding Lean targets over the full declared domains, batching targets
and reusing matching successes. No pending helper contract enters the checkpoint.

Focused positive and negative controls must distinguish nominal type identity
from equal shape; bounds and component types; initialization; declaration order,
visibility and namespace collisions; component read intervals and staticness;
read-only writes; unsupported array modes/results; all four bounds queries and
permitted contexts; positional/named/mixed calls; forwarding; procedure aliases;
and composition with existing loops, conditions and scalar modes. Exercise source
capacity endpoints and preserve existing source-policy mutation controls. Compile,
prove and run positive fixtures through the full route, checking exact outputs.

On stable captured current inputs, complete native proof/audit, compiler build,
Lean/module/axiom/actual-source audit and the full regression/sample suite under
[development.md](../development.md#proof-loop-and-validation). Reuse only matching
results under its invalidation rules, retain failures as failures and record
actual Linux host, requested/granted resources and fresh/cached scope. Use managed
reservations and all available Lean CPUs by default; record deliberate reductions.
No mandatory cold rebuild or independent kernel replay is added. macOS evidence
is independent and nonblocking.

Update `language.md`, the catalogue, samples, roadmap capability status and this
record together at admission. Add a precise delivered Rosetta identifier, revise
current-language descriptions and affected task assessments with honest review
metadata, render through `rosetta/refresh.py --render`, and update the relevant
stage issue/Stage fields. Broad `arrays`, `functions`, `procedures` or
`unconstrained-arrays` identifiers must not be claimed from this fragment alone.
Record actual mappings gained, elapsed delivery time and expensive checkpoint
attempts with existing run records, including failures, repairs and interruptions.

Independent review must assess the complete implementation, full declared-domain
contracts, source correspondence and final evidence applicability. Resolve
material findings before support/completion; prepare the feature PR within the
owner's authorization. PR #385 remains held and Worca remains stopped. Record any
later merge instruction separately rather than inferring it from feature approval.

## Implementation checkpoints — 2026-11-21

Authorization reached `main` through [PR #411](https://github.com/berkeleynerd/silver/pull/411),
merge `5f97477d5b`, before the [#410 claim](https://github.com/berkeleynerd/silver/issues/410#issuecomment-7061476172).
Integration uses `tmp/named-array-parameters-410`; separate native, mathematical
proof and source-correspondence worktrees retain their own outputs and caches.
These checkpoints are development evidence, not completed capability assurance.
All runs below are Linux x86_64 on the primary host. Automatic worker/thread
allocation was 22 where applicable; no complete native or Lean checkpoint has
yet been started for the feature.

| Round | Selected settings | Result and remaining work | Run/time evidence |
| --- | --- | --- | --- |
| Nominal input and bounds foundation | Proof role Astra Max in current continuation; original launch settings not retained here | Static query bounds, captured component domains, disjoint virtual formals and read-only forwarding proved. Earlier focused failures retained. | `20261121T105037-e0e709fe6caf`: 15 modules, 1,747 declarations, 15.3 s; failures `20261121T104900-79092227dc9a`, `20261121T105011-2ead4d67436d` |
| Native metadata | Original worker model/effort selection not retained | Build and complete focused array-bindings unit passed; this commit alone admits no new source form. | Build `20261121T105134-ba712d6b0261`; canonical focused `20261121T105220-18556e6bb779`: all 140 checks, 12.0 s. Earlier build `20261121T105117-83ee7415b265` failed tool-directory validation before compilation. |
| Call and frame semantics | Proof role Astra Max in current continuation | Nominal and component-domain input checks, incoming-state capture, scalar output restrictions and mixed frame construction proved in focused scopes. Body composition and actual-source binding remain pending. | `20261121T105314-2002184ad6d1`: 44 modules, 6,106 declarations, 26.3 s; `20261121T105612-51641edcbf7d`: 18 modules, 2,120 declarations, 15.6 s |
| Specification/catalogue and examples | Specification worker GPT-6.1 Sol Extra High; lead runtime settings not independently exposed | Specification and emitter updated together. New regressions and callable Dot product/Horner samples committed; production catalogue regeneration and full-route tests pending. | Specification commit `3c26c874e0`; sample/test commits `2999a51fb6`, `e041e10f5d`; whitespace, syntax and emitter JSON inspected |
| Native feature admission | Original worker selection not retained | Named declarations, input frames/calls and bounds queries build; eight-case admission smoke passes. Full helper contracts, broader regressions and source proofs remain pending. | Native commit `c140f4a406`; build `20261121T110038-179aa1d1d507`; smoke `20261121T110157-c2f06dabc56f` |
| Horner producer discovery | Lead runtime settings not independently exposed | The initial ordinary-Ada sample proved 71 checks using the pinned producer and no inlining. The subsequent fully parenthesized Silver sample still needs its own final full route. No new diagnostic class was observed. | Experimental `20261121T110025-374f2b5d399f` passed. `20261121T105910-72724203cefe` remains failed: its input directory incorrectly included generated outputs, despite successful prover checks. |
| Complete mathematical call/body domains | Proof role Astra Max as recorded in the worker handoff; runtime settings not independently exposed | Function and procedure array-call safety and discharge pass over their full declared mathematical domains. This is a focused model result; source integration remains pending. | `20261121T111342-d723a3998162`: 162 modules, 20,315 declarations; automatic 22 workers/threads |
| Parser-state equality diagnosis and repair | Native worker; Astra Max diagnosis recorded in the managed ledger | The array-input wrapper's exact equality and safety checks passed, but its explicit state-equivalence conjunct exhausted the canonical solver budget. A reverse equality lemma was split into fixed-array field cuts, then the complete unchanged wrapper contract passed. No domain or postcondition was weakened. | Failures `20261121T111527-959262a3d853`, `20261121T112113-ef86de8f3f29`; reverse lemma `20261121T112626-39d6f0e49262` passed 38 checks; wrapper `20261121T112912-ae9008e245e5` passed 11 checks. Native allocation 16 workers retained a reason reserving six for independent Lean work. |
| Metadata actual-source correspondence | Source-correspondence worker selected Astra Max | Array, function and procedure binding predicates, type lookup, formal metadata and stored/symbolic reads are tied to their actual native source. This covers these three helper libraries, not the complete compiler. | Model equations `20261121T113021-a313c61ca1f3`; all three source bridges `20261121T113329-3c9a3d794786`: 172.113 s, six regenerated certificates, fresh 10,005-declaration audit, six workers/22 threads |
| Symbolic input flow and bounds grammar | Lead; runtime settings not independently exposed | Native table validity now derives disjoint semantic input segments and component ranges. Predicate flow uses those views. The full-table scalar reader models all, mutable-only and disabled component modes, retaining static bounds queries in subscripts. Cursor, inference and deterministic parse-witness results pass; independent grammar readings and native reader equivalence remain integration work. | Context `20261121T113151-0f3a6dad9e49`: fresh 8,558-declaration audit; reader/cursor/counted-bound model `20261121T113906-0a4ddec8a76d`: fresh 9,571-declaration audit. Focused failures are retained in the managed ledger. |
| Nominal signature and call admission | Proof role Astra Max as recorded in the worker handoff | Source-resolved array actuals, full declared nominal domains, type-prefix preservation and scalar-only writable modes pass focused checks. Mixed payload/source integration remains pending. | Array actuals `20261121T112651-ff0eb757481e`: 8,574 declarations; signatures and call admission `20261121T114015-99d6f4e48f7a`: 9,237 declarations, automatic 22 workers/threads |
| Full-table grammar and expression integration | Proof workers selected Astra Max; lead runtime settings not independently exposed | Independent source grammar, String/Character/index/Image atom readings, whole String expression semantics, declaration dispatch and static subtype endpoints now use the complete table. Named types participate in the declaration termination measure. Snapshot proofs explicitly require stored cells; the declaration-chain derivation remains pending. | Grammar `20261121T121302-5b87a37e822e`; scanner `20261121T122350-3e3dbf84c2c1`: 10,313 declarations; scalar-only source facts `20261121T122558-d975c3d52762`: 6,660; expression/subtype integration `20261121T122902-af18e12cd08c`: 11,173. Each focus used two workers/22 threads to share six workers with the other Lean streams alongside the native run. |
| Full-table actual-source reader endpoint | Source-correspondence worker selected Astra Max | Arbitrary interpreted source calls agree with the independent grammar for complete tables, all three read modes and scalar/Range attributes. The checked source and array helper bridges are included. This closes the scalar reader component; composition source correspondence remains pending. | `20261121T123207-a02cfae7281b`: fresh 16,216-declaration audit, build 15.162 s and audit 3.167 s, two workers/22 threads; implementation `529564cb4d`, integrated as `638f614ac7`. |
| Physical declaration helper repair | Native worker; full-domain diagnosis retained in the managed ledger | The earlier executable-reader check exposed physical append in a generic symbolic-view frame. Matching model/runtime guards reject that internal case while preserving the complete original contracts. Both repaired contracts pass; the remaining loop and outer subprogram caller gates are pending. | Failed reader `20261121T115327-cd1e93904f89` retained as failed. Model `20261121T121211-472d67105ce2` passes all 62 model checks and reader `20261121T122534-e4a9782a41fd` passes all 66 reader checks on native `f57750fd90`, integrated as `4e44cc816d`; 16 workers reserved six for concurrent Lean work. |

The draft delivery is [PR #412](https://github.com/berkeleynerd/silver/pull/412).
These later focused results still do not establish completed support. Remaining
work includes declaration-chain and
mixed callable/header/frame and loop integration, complete source correspondence,
the remaining native caller contracts, the stable complete native/Lean and
regression checkpoint, Rosetta delivery and independent review. No complete
feature validation run has been represented as passed, and merging #412 has
not been authorized.

The function sample uses a fixed three-element vector and sums its three
corresponding products; arbitrary length is optional in the task. Its declared
component range gives each product `-100 .. 100` and the sum `-300 .. 300`.
The procedure sample reads four coefficients in increasing-power order and walks
their range in reverse. Its accumulator guard `-98 .. 98`, argument range
`-10 .. 10` and coefficient range `-20 .. 20` bound each multiply-add by
`-1000 .. 1000`. Failed capacity sets a separate Boolean result and suppresses
numeric output. Independent direct arithmetic gives the required Dot product
`3` and polynomial value `128`; execution must still confirm the exact bytes.

Current source-correspondence work uses an explicitly selected GPT-6 Astra Max
worker for native array/signature metadata and its checked source equations.
The lead owns scalar-expression/attribute integration. Runtime settings are
not independently exposed by these records. Foundational model successes do
not stand in for native correspondence, final discharge or independent review.
