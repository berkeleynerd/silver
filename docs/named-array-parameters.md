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
All runs below are Linux x86_64 on the primary host. Early rows used the
then-available 22 CPUs, with concurrent reservations as recorded; the owner
later reduced the host allocation to eight. The native audit eventually passed
after the retained advisory failure and repair. Complete Lean integration is
still pending. Selected settings are recorded separately from live runtime
settings, which were not independently exposed; token/cost totals are unavailable.

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


| Shared declaration/sequence integration, 14:00–15:24 | Source/proof workers selected Astra Max; lead runtime selection unavailable | Full-table helper equations, declaration models, callable type history and Sequence state propagated. Candidate/model tactic failures were repaired without narrowing domains. Actual-source bridge integration remained open. | Core `20261121T151323-ce0329351d9d`: 29,186 declarations; retained focused attempts and commits are detailed below. |
| Native readiness and complete audit, 13:55–19:19 | Native implementation/checks as recorded above; lead runtime settings unavailable | All 27 original and 17 supplemental helper/caller gates passed. The first complete audit failed on an arithmetic-reassociation advisory despite proved checks. Grouping the Length arithmetic in Ada and its typed tree repaired it; final audit passed 19,994 checks. | Failed `20261121T135513-089c46fa489d`; successful `20261121T191055-5cced625eb47`, 492.560 s, two workers with existing sessions/cache. |
| Eight-CPU constraint and restart | Resource implementation/review selected settings in the [resource review](reviews/review-eight-cpu-limit-20261121.md); lead runtime settings unavailable | Managed reservations, worker/thread grants and OS affinity now honor the host allocation. Productive jobs and caches were preserved. Post-reboot detection and cpuset both report eight CPUs. | Runner batch `20261121T170437-0119c07b2615`: 155 tests, 54.420 s. Resource evidence distinguishes original flags from in-place confinement. |
| Callable actual-source continuation, 19:00–19:50 | Function/procedure source workers selected Astra Max | Complete raw domains and typed source helper/caller proofs passed in focused scopes; the actual Output certificate closure and final global audit remained pending. | Procedure `20261121T194543-302f3f4f1b24`: 65,809 declarations; function source run `20261121T193933-afb215e6c72b` remains active. |
| Independent import review and #414 repair, 20:00–20:34 | Independent critical reviewer and repair worker selected Astra Max | Review found independently assumed array imports and Boolean predicate meanings. Narrow source-derived import repairs and exact-domain transport passed; combined root bridge/model validation still pending. No native change. | Array focus `20261121T201800-abfe1344ac75`: 25,031 declarations; Boolean focus `20261121T203235-079f1f0196b2`: 46,520 declarations. |
| Serial regression diagnosis and controls, 19:46–20:40 | Independent proof/runtime diagnosis selected Astra Max; lead test/evidence settings unavailable | One-worker Why3 scheduling invalidated the all-three-observed-solvers fixture assertion. Corrected policy controls and manifest passed on their recorded versions. The original maximal-expression proof continues after its failed test timeout; final full coverage remains required. | Manifest `20261121T195853-82a961e9e416`: 92 samples, 806.234 s; final policy controls `20261121T202537-af32fdd0a5e1`; initializer composition `20261121T203944-26f0b795d617`: 7.850 s. |
| Final callable import and initializer source repair, 20:54–21:09 | Source implementation and independent review selected Astra Max | String/Character source consumers and both callable Boolean paths passed their focused audits; #414 repair independently accepted. Whole-project validation remained pending. | Runs `20261121T210103-c7ca3f0d2b24` and `20261121T210207-8de88d24fdb5`; [source review](reviews/review-named-array-source-20261121.md). |
| Serial maximal-case measurement and fresh regression, 21:13–ongoing | Lead evidence collection; monitoring selected Sol High | Original timed-out test remains failed; completed reports passed 19 flow and 110 proof checks after 116.2 minutes. One test deadline raised to three hours; fresh 785-test suite started. | [Measurement](evidence/named-array-parameters-410-20261121/serial-policy/maximal-case/README.md); active suite `20261121T211830-07948902a0f6`. |
| Retained source/flag consumer repair, 21:22–21:41 | Proof repair and independent review selected Astra Max | Three failed consumers repaired with unchanged native code and public theorem statements. Focused audit passed 111,610 declarations; the failed first draft is retained. | Complete failure `20261121T210604-4b2b25ed79cf`; focused success `20261121T214023-0f622151717c`; [review](reviews/review-named-array-final-consumers-20261121.md). |
| Procedure metadata interpretation, 21:42–21:48 | Proof design and independent review selected Astra Max | Array formal signatures now use the type table from the same selected native scanner, retaining SourceMeaning alone and the native count equation. Focused source audit passed 148,749 declarations. | Complete failure `20261121T214156-37d0db242e83`; focused success `20261121T214735-7e1a499a3d93`; [metadata review](reviews/review-named-array-procedure-metadata-20261121.md). |
| Complete audit inventory and final success, 21:48–21:55 | Independent critical reviewer selected Astra Max; lead integration settings unavailable | Removed an orphan duplicate of a fully audited, consumed theorem after exact-domain review. All 1,083 modules and 173,026 declarations passed complete audit; failed attempts retained. | Final `20261121T215449-12cec2fc5976`; [complete packet](evidence/named-array-parameters-410-20261121/final-lean/README.md) and [coverage review](reviews/review-named-array-audit-coverage-20261121.md). |
| Downstream actual String/Character bounds integration, 20:30 onward | Implementer and independent reviewer selected Astra Max | Review found unbuilt consumers needing full tables, stored-array facts and the new type trace case. Four-file repair is prepared while the productive function source run finishes; no final theorem premise is weakened. | Focused validation pending the source-run lease boundary; this remains #410 integration work. |

The subsequent integration round retains focused success for the native Range
loop equation, the mutable-only counted-bound reader and their flow/sizing
adapters (`20261121T134623-0e8435d0923e`, 20,100 declarations). The exact Loop_Body
source candidate also passes its kernel-checked rendered-token comparison
(`20261121T134718-422136f4d2fc`, 16,884 declarations). Function actual/call meaning,
closed read-only array frames and native-helper interpretations pass their focused
audit (`20261121T134818-d631a41f1b28`, 27,395 declarations). The generic array-view
loop lemmas pass separately (`20261121T134942-021ed35c21b6`, 5,640 declarations).
These source/proof subthreads were selected at GPT-6 Astra Max and used four
managed workers with 22 threads per Lean process, sharing the 22 available CPUs
with the native caller queue. Runtime model/effort is not independently exposed.

The lead's shared declaration/equation integration remains in progress. Focused
failures preserve obsolete metadata-interface errors and local reduction-cost
failures; completed leaf objects remain reusable under ordinary Lake checks.
In particular the Boolean aggregate trace compiles after keeping the scalar
reader opaque locally, with its theorem and admission domains unchanged. No
complete native or Lean capability audit is claimed by these partial checks.

All 17 supplemental whole-subprogram caller gates requested by the independent
native review subsequently passed the canonical final policy. The
[readiness inventory](evidence/named-array-parameters-410-20261121/supplemental-native-readiness.json)
names each run and check count. Before the complete native audit, all 2,635
captured input paths were rehashed against the stable native workspace; every
one matched, and its source/tooling trees match the integration workspace. The
native workspace includes the copied final catalogue emitter as an uncommitted,
verified exact-byte snapshot. Complete native run `20261121T135513-089c46fa489d`
is running alongside Lean integration, with a 16 MiB invoking-shell stack and
automatic allocation of the remaining ten managed CPUs. No complete-native
success is claimed yet.

The final native direct-caller gates also passed on the same source: `Loop_Body`
(`20261121T123923-1aacb72aa836`, 96 checks), function declaration
(`20261121T124523-203873ac4b3e`, 18) and procedure declaration
(`20261121T124733-b214ad9e49e2`, 17). Together with the earlier gates, all 27
selected full-helper/caller checks passed. This is focused coverage; the complete
compiler audit remains pending. The source-identical managed build
`20261121T125341-99e4ce810915` and feature regression
`20261121T125607-826b7d51ebf2` passed (15 tests, including five compile/prove/run
routes), using an explicit 16 MiB stack and 16 native workers.

Subsequent independent native review is selected at GPT-6 Astra Max. Its
[stack observations](evidence/named-array-parameters-410-20261121/stack/README.md)
require updating the x86_64 setup environment to 16 MiB and retaining three
source-limit full-route checks. This is part of #410 delivery, not a deferred
finding or a source-language restriction. The native review found no additional semantic defect. Managed rerun
`20261121T130801-77ed9650af68` passed all three routes and over-limit controls;
the earlier harness-policy failure remains retained as failed in the linked
record. Independent confirmation of this repair and final source/proof review
remain pending.

Focused Lean results now include the exact type-and-callable hiding inventory
(`20261121T124937-eaec773a13b7`, 15,436 declarations), subtype endpoint obligation
readings (`20261121T125316-bec1a0a83f4b`, 11,079), shared typed call/predicate
equations (`20261121T125422-3d0964f25d9e`, 22,604), and the nominal object source
trees (`20261121T125753-1e14687b406a`, 15,331). Earlier failures remain failed,
including `20261121T124825-e5d04924d67b`, whose successful build/audit was
invalidated by an input edit during verification. The stable repeat above is
the accepted hiding-inventory evidence. Complete semantic/source integration
and the complete feature checkpoint remain pending.

The draft delivery is [PR #412](https://github.com/berkeleynerd/silver/pull/412).
These later focused results still do not establish completed support. Remaining
work includes declaration-chain and
mixed callable/header/frame and loop integration, complete source correspondence,
the stable complete native/Lean and
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

### Source and callable integration continuation — 2026-11-21

Focused callable initialization and frame validity passed in
`20261121T142322-58073c6d7e7e` (22,802 audited declarations), followed by the
installed-array descriptor and mixed-frame analysis bridge in
`20261121T142702-f98a1e7babb5` (21,145). Procedure frame validity and preservation
of array inputs through scalar-output initialization passed in
`20261121T142914-8768b4b274bb` (21,461). The three updated procedure actual/callee
source checks passed in `20261121T143052-f20a55b4b5da` (17,538). These retain the
complete native helper domains; read-only array descriptors and their declared
component ranges are not specialized to sample values.

Primitive statement meaning, array-aware flow preservation and String assignment
passed in `20261121T143424-243b2cee0701` (27,869 declarations). Body semantics,
source reading uniqueness, binder separation and procedure frame shape passed
in `20261121T143716-7a42fd7c8b1d` (24,739; 24.131 s managed duration). Integration
commits `76c44c1632` and `8aadedd8ac` carry those two checked slices. These are
focused successes, not the complete endpoint checkpoint.

The three continuing proof/source subthreads were selected at GPT-6 Astra Max;
runtime settings are not independently exposed. The function stream used three
workers and the procedure stream one while the statement and root streams each
reserved four, alongside the complete native run's ten. Lean process threading
remained automatic at 22; deliberate worker reductions and their reasons are
retained per run. The resumed lead's runtime model/effort was not independently
exposed. No new cost or token measurements are available.

The root preserved the successful 715-second `ReviewedOutputShape` build from
failed run `20261121T141959-a78ee1a5c1f6`, corrected a record-update syntax error,
and continued focused shared-helper integration. Subsequent failed runs remain
failed, including `20261121T143717-e66ffcac4617`: their corrections address
changed constructor arguments, equivalent Boolean guard normalization and
visibility of the standard decimal-rendering definition in source checks.
Array-type denotations pass; the full shared helper/source interface is still
being checked. The complete native audit remains in progress. Final Lean/source
assurance, complete regression coverage, Rosetta support promotion and independent
delivery review are still required; PR #412 remains draft without merge authority.

The subsequent primitive native-equation/statement-flag focus
`20261121T144012-a8a69d5f53bd` passed with a fresh 27,491-declaration audit.
Normalizing the full-table projections before branch simplification closed the
previous expensive reduction; `PredicateBasicEquations` built in 43 s. This
particular run automatically reserved the twelve CPUs then available; the next
concurrent source run returned to four workers with the sharing reason recorded.
The root's run `20261121T144143-f287ea3b22d2` built the shared evaluation transport
and exact named-array-type source candidate (137 s for the latter), while failing
on three unused simplifier arguments in the array model. Its overall outcome
remains failed; those compiled modules are retained for the repaired focused
model/equation check, not represented as a successful complete audit.


### Shared equation and callable integration — 2026-11-21 14:58 UTC

The callable type-history argument passed focused run
`20261121T144718-120bda7bfd59` (10,510 audited declarations). It derives nominal
IDs from accepted formal lookups over the parser's actual declaration suffix;
it does not narrow the native helper domain. The procedure header, mixed input
frame and scalar output-prefix argument passed
`20261121T145443-8954ea711745` (23,603 audited declarations), integrated as
`7704beb609`. Its prefix noninterference follows the writable scalar target
bounds, while preserving array descriptors and the declared component intervals.

Shared full-table helper equations compiled in
`20261121T145102-a9d90d2ecfc3` and were committed as `0759963356` for the parallel
statement and call adapters. That run remains failed: the new type-equation
proof needed projection normalization and concrete operation-name rewriting,
and the concrete String declaration equation needed Boolean guard normalization.
The successful modules are reused through ordinary Lake checks; their compilation
is not represented as a complete or freshly audited combined success. The next
focused batch checks those repairs and the shared declaration/model consumers.

The source/callable/procedure subthreads remain selected as GPT-6 Astra / Max;
runtime model and effort are not independently exposed. The native audit keeps
ten workers; the shared/source/function/procedure proof streams reserve
four/four/three/one respectively, with automatic 22-thread Lean processes and
sharing reasons in their run records. Available memory was about 54 GiB during
this round; this is a point observation, not a peak measurement. No new token or
cost data is available. No CLI memory update or harness goal change was made.
Complete native and Lean/source assurance, final regression coverage, Rosetta
support promotion and independent delivery review remain outstanding.


### Restart and final-audit repair — 2026-11-21

The owner resumed after the microVM restart. Linux now reports eight CPUs, with
process affinity and the effective cpuset both guest 0–7; the managed budget
agrees. The resource evidence records the verification. The three continuing
source proof streams are selected GPT-6 Astra / Max, each with two managed
workers and two threads per Lean process while sharing the eight-CPU allocation.
The lead's runtime model/effort is not independently exposed. No new token/cost
measurements are available; the ordinary run records retain elapsed times.

The first complete native run `20261121T135513-089c46fa489d` finished after
16,179.599 seconds. GNATprove exited 0 with all 19,994 checks proved, but the
strict audit rejected an operator-reassociation warning at
`silver_scalar_expressions.adb:127:41`. The overall run remains failed. The
repair explicitly groups the wide subtraction in the Length calculation and
adds the same grouping to its typed Lean tree and reviewed source literal;
mathematical evaluation and admitted domains are unchanged. No warning-policy
expansion or suppression was introduced.

Focused run `20261121T185720-c8b8943aaecb` passed the complete native
`Read_Array_Attribute` contract with 38 checks, at its declaration selector
`silver_scalar_expressions.ads:83`. The preceding body-line selection
`20261121T185537-7700045ce968` proved the same checks but remains failed because
the runner could not match that selector to the analyzed declaration. This was
a selector correction, not a contract or policy relaxation. Lean source checking
of the grouping repair is in progress.

The full regression `20261121T151924-a0eaed03062c` remains failed: 776 test
identities in 8,049.133 seconds, with 11 failure entries. These are the obsolete
8 MiB explicit stack test, eight certificate-parity subcases and their parent
failure, and output-body reconstruction. The stack test now uses the documented
16 MiB setting, and the checked-in certificates have been regenerated. Their
repair reruns and the rebuilt one-worker application driver remain required.
The restart checkpoint preserves the complete logs and failure census; no final
regression coverage is claimed from these edits alone.

Previously audited helper and callable trace commits have been integrated:
`db71f53160`, `095a59cb6d` and `520316b4c3` (their focused records above remain
the evidence). Function/procedure typed-source correspondence and the combined
root bridges remain unfinished. Complete native and Lean/source assurance,
reviewed regression coverage, Rosetta support promotion and independent review
still precede delivery. PR #412 remains draft; no merge is authorized.


### Corrected native assurance and source integration — 2026-11-21 19:19 UTC

The [corrected complete native audit](evidence/named-array-parameters-410-20261121/final-native/README.md)
passed: run `20261121T191055-5cced625eb47`, 78 units, 1,265 entities and 19,994
checks (1,775 flow and 18,219 proof). It forced complete analysis while reusing
native sessions/cache, at two workers and 16 MiB invoking-shell stack; managed
duration was 492.560 seconds. The retained packet preserves the original failed
complete run, focused selector failure/repair and successful complete reports.
Exact comparison covers all 135 Ada sources and ten Python scripts with the
integration tree; installation-specific generated paths retain their native
worktree identity. No cold-runtime claim is made.

The grouped Length helper's complete Lean source bridge passed fresh audit
`20261121T185802-2485bf0d1681` (16,247 declarations). Shared Compose source
candidates passed `20261121T185321-405f9610c412` (121 modules, 15,891 declarations),
on their captured inputs before that scalar grouping edit. Their unchanged
output-profile correspondence is retained; final combined applicability remains
part of the complete Lean checkpoint.

The formal-metadata model now carries the finite Type_Count range already
imposed by each native Formal.Type_Id field. Both admitted constructors derive
that bound, and native predicate equivalence retains invalid, zero and capacity
cases. No declaration-history or current-table-count premise was added.
Focused run `20261121T191841-33ce803f0c2d` passed 22,242 declarations; the
[independent bounded review](reviews/review-array-formal-type-count-2372feb90f-20261121.md)
found no material issue. This is a necessary native-domain correspondence repair;
remaining consumers and endpoint integration still require validation.

The rebuilt driver uses one worker per application proof/build. Repair batch
`20261121T190708-ab70670dd3e5` ran 23 tests: 22 passed, covering all earlier
stack/certificate failures and the named-array feature routes. Its maximal
64-operand test reached the old 300-second harness deadline, so the batch remains
failed. The single test's harness deadline was increased to 1,800 seconds to allow
serial solver attempts; production solver steps, timeout and proof requirements
are unchanged. The discriminating rerun and final regression accounting remain
pending. Successful partial batches do not establish complete feature assurance.

## Source review and serial regression continuation — 2026-11-21 20:27 UTC

The first delivery source review found [#414](https://github.com/berkeleynerd/silver/issues/414):
new Compose array imports and the two Boolean wrapper predicate records must
consume source-derived helper meanings, including their nested callable paths.
The array-import module passed a focused 25,031-declaration audit in
`20261121T201800-abfe1344ac75`; Boolean wrapper/callable integration and the
complete checkpoint remain pending. This is required source correspondence,
not deferred hardening. No native source changed after the successful complete
19,994-check audit.

The [serial policy evidence](evidence/named-array-parameters-410-20261121/serial-policy/README.md)
records the manifest assertion correction, its positive/negative controls,
the passing 92-sample run and the separate unresolved maximal-expression
regression. The independent applicability review requires a fresh final full
suite; the current inventory has 784 unittest identities. No complete Lean or
final regression success is claimed.

[Stage issue #415](https://github.com/berkeleynerd/silver/issues/415) tracks only
`named-integer-array-parameters` and its two faithful drivers. It is In progress
at unpromoted Stage 38; broad arrays #12 stays open. Supported promotion waits
for the shared assurance/regression/review checkpoint. Board #414 is In progress;
#413 is In review with its measured stack evidence retained. PR #412 remains
draft and has no merge authorization.

At 20:40 UTC, the source-repair regression in
[the initializer composition packet](evidence/named-array-parameters-410-20261121/initializer-composition/README.md)
passed compilation, proof, audit and execution (`20261121T203944-26f0b795d617`).
It covers bounds-query initialization in Main, Boolean aggregates, both callable
local forms, and String/Character snapshots from a named array. The first test
fixture was corrected to use visible type queries before formal installation;
its rejected result is retained. The final suite now contains 785 identities,
subject to its final census, and remains pending.

## Checked source repair checkpoint — 2026-11-21 21:09 UTC

The [independent source review](reviews/review-named-array-source-20261121.md)
confirms that `ba0e9fee9a` resolves #414 across Main and both callable-local
Boolean paths. It independently matched the exact focused Lean inputs and all
135 Ada sources per reviewed run. The String/Character repair preserves both
public source-assurance theorem statements. The [focused source packet](evidence/named-array-parameters-410-20261121/focused-source-continuation/README.md)
retains the earlier actual-source and import checkpoints.

The final two repair scopes passed separately: String actual bounds
`20261121T210103-c7ca3f0d2b24` (28,231 declarations, 344 modules), and complete
Compose bridge plus inherited readiness `20261121T210207-8de88d24fdb5`
(138,806 declarations, 650 modules). The earlier local inference/layout failures
remain failed. The whole-project Lean/source checkpoint is now running on the
integrated sources with automatic six-worker/six-thread allocation on CPUs 2–7,
while the retained serial application proof keeps the two-worker reservation on
CPUs 0–1. Neither a complete Lean pass nor final full regression coverage is
claimed yet; no merge is authorized.

## Complete-checkpoint continuation — 2026-11-21 21:28 UTC

The retained maximal-expression reports completed after 6,972.609 seconds and
passed their independent audit: 19 flow and 110 proof checks, with no advisory
or unproved record. The original test remains failed at its old 1,800-second
deadline. The [measurement packet](evidence/named-array-parameters-410-20261121/serial-policy/maximal-case/README.md)
supports the three-hour deadline introduced by `4373508bf6` for this one test.
It does not claim a completed compile or executable test. Fresh full-suite run
`20261121T211830-07948902a0f6` is active on that commit with 785 test identities,
two managed workers, guest CPUs 0–1 and the documented 16 MiB invoking stack.

Complete Lean run `20261121T210604-4b2b25ed79cf` remains failed after 954.892
build seconds. Three stale consumers were reached: an auxiliary Boolean
declaration literal omitted the already-modeled array-type lookup; two exact
Predicate source requirements omitted the new `Type_Keyword`; and the retained
function-assignment flag proof needed the new array-type declaration case and
current array-declaration constructor arity. Repairs retain the actual native
code, full domains and public theorem statements. The successful module objects
are preserved for the focused repair batch and subsequent complete audit.

The resumed repair and independent review subthreads remain selected Astra Max;
routine monitoring is selected Sol High. Runtime settings are not independently
exposed. The host reports eight CPUs and its effective cpuset is guest 0–7.
The Lean repair batch automatically receives the remaining six workers/threads
and CPUs 2–7 alongside the two-worker regression reservation. No new native run
is needed for these proof-only repairs. Final Lean/source assurance, regression
coverage, Rosetta promotion and delivery review remain pending.

## Complete native and Lean assurance established — 2026-11-21 21:55 UTC

The [complete Lean/source packet](evidence/named-array-parameters-410-20261121/final-lean/README.md)
records successful run `20261121T215449-12cec2fc5976` on `7f449246ce`:
1,083 modules, 173,026 declarations and exactly the three permitted foundations.
This is a complete cached build with a fresh axiom/module audit, not a clean
build or independent kernel replay. All previously failed complete and focused
attempts retain their actual outcomes. The complete 19,994-check native audit
remains applicable: these final changes affect only proofs and delivery records.

The final integration additionally repairs the procedure metadata interpretation:
nominal array formals now resolve through the type table from the same accepted
native scan. `SourceMeaning` remains the only program hypothesis, and the native
procedure-count/report equation is unchanged. The
[independent metadata review](reviews/review-named-array-procedure-metadata-20261121.md)
accepts its focused 148,749-declaration audit. The final inventory reconciliation
removes an orphan duplicate of the already-used full-domain array-frame theorem;
the [coverage review](reviews/review-named-array-audit-coverage-20261121.md)
confirms the retained theorem, its three consumers and all final module hashes.

The 785-test run remains active on its frozen `4373508bf6` inputs. Independent
review identifies exactly 15 identities affected by the six final proof-file
changes, including the orphan deletion. Their rerun uses the corrected proof
tree in a separate worktree while preserving the full suite. Rosetta promotion,
its affected tests and final delivery reconciliation remain pending. PR #412
stays draft; no merge is authorized.

The selected proof-reader rerun `20261121T215753-de0dae34a5b9` passed all 15
identities on `7f449246ce` in 174.128 test seconds. It ran in the separate proof
worktree with six automatically allocated workers while preserving the primary
two-worker suite. The [regression packet](evidence/named-array-parameters-410-20261121/final-regression/README.md)
retains its exact inputs and readers. The full run passed the sample manifest
and began the maximal-expression compile at 22:00:13 UTC; its final result and
the post-promotion Rosetta checks remain pending.
