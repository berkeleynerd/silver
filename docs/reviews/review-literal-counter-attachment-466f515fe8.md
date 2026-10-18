# Literal counter attachment and return-ABI storage correction review

2026-10-18, owner-authorized research
[#119](https://github.com/berkeleynerd/silver/issues/119) and correction
[#132](https://github.com/berkeleynerd/silver/issues/132).

**Disposition: scoped acceptance of both frozen changes.** The six additional
hard-register allocation requests are required and correctly counted. The
counter attachment justifies restoring the graph/summary slice's local
condition while retaining four separate unknown conditions and false whole
pipeline capacity. One nonblocking prose timing correction was fixed and
independently confirmed below.
No numerical or gate correction is needed.

## Frozen inputs and scope

The independently reviewed targets are:

- Aggregate attachment `466f515fe8afa8b82dcb5c97a68800be97a7d709`: the seven-file
  change to [the pipeline note](../research/retained-literal-pipeline.md) and
  the aggregate's `README.md`, `compose.py`, `check.py`, `inputs.json`,
  `result.json` and `check-results.json` in
  [its evidence directory](../evidence/retained-literal-pipeline-20261018/README.md).
- Synthetic storage correction `316f40e7b2c0b7ffc57eca81c7aff39784cdd35a`:
  [the source argument](../research/retained-literal-synthetic-function-storage.md)
  and its [corrected evidence packet](../evidence/retained-literal-synthetic-function-storage-20261018/README.md).
- The unchanged numerical counter interface from
  `bc69773b786a6fbc47050a084ff3f5aa72807075`, with the prose corrections in
  `733c3f7000e631400640d5e7c601258f3e793348`. I reused my
  [counter source review](review-literal-counter-emission-bc69773b78.md),
  integrated as `72b21f3fc7`, rather than reopening its accepted argument.

I read the applicable AGENTS/Oracle and reused the established assurance,
source-correspondence and external-resource boundary. The same selected literal
family, O0 Linux x86-64/LP64 SysV target, retained no-debug/no-instrumentation
configuration, and GCC source
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` remain premises. Relevant installed
behavior matching the source is not newly observed here. No admission, tool
option, Oracle or physical-resource assumption changes.

The previous [storage and collector review](review-literal-storage-5706684775.md)
is reused for the unchanged 167-event subtotal, ordinary requests, identifier
demands, release/finalizer behavior and collector-callback argument. Its
167-event numerical total is superseded by the correction. This review does
not repeat the accepted helper folding/body proof or the collector census.

## Six return-ABI register allocations

The packet starts with frozen declarations and bodies and counts three
function-structure allocations plus two helper initial gimplifications. In
this interval each helper executes `aggregate_value_p` exactly three times:

1. Once from `allocate_struct_function` after constant scalar relayout
   (`function.cc:4890`).
2. Once from `gimplify_body(..., true)` through `gimplify_parameters` and
   `assign_parms_augmented_arg_list`
   (`gimplify.cc:21745–21785,21995`; `function.cc:2381–2425,3886–3984`).
3. Once while lowering its unique nonvoid `RETURN(MODIFY(...))`
   (`gimplify.cc:1874–1970`). Distributing the conditional assignment into its
   arms does not duplicate the enclosing RETURN or this query.

I checked the other query routes rather than counting only these landmarks.
There is no transparent aggregate recursion, return-by-reference, hidden result
parameter or CALL_EXPR; the modify-RHS query requires the latter
(`gimplify.cc:7053–7057`). The parameter initializer uses automatic ABI state,
and the two scalar parameters avoid complex splitting and callee-copy bodies.
`use_register_for_decl` and `expand_function_start` queries belong to later
parameter/RTL assignment or SSA coalescing, neither entered by these cold
helpers. Initial gimplification reuses the function structure, so there is no
second allocation query through `push_struct_function`. The empty elaboration
has one allocation-time query but its void guard returns before requesting a
register; it is never gimplified (`function.cc:2086`; `trans.cc:698–723`).

For both helper results, SysV's return-in-memory query is false, then
`hard_function_value` reaches `ix86_function_value` and
`function_value_64 -> construct_container`
(`function.cc:2055–2148`; `explow.cc:2332–2361`;
`i386.cc:4268–4319,4378–4409,4451–4480`). DImode has one INTEGER class and
TImode two. The latter still returns a single TImode REG because the ABI's
return registers begin AX,DX and their numbers are 0,1
(`i386.cc:346–349,2524–2564,2877–2885,2936–2955`;
`i386.md:419–420`). The BLKmode PARALLEL/EXPR_LIST branch and general fallback
are not taken. Classification and fixed hard-register mask checks do not
create another object.

AX is distinct from the special reusable stack, frame, argument and PIC pointer
registers. The ordinary hard-register cache is disabled by `#if 0`, so every
query reaches `gen_raw_REG -> rtx_alloc(REG)`
(`i386.h:1255–1262,1323–1330`; `emit-rtl.cc:463–494,791–854`). The retained
LP64 layout gives an eight-byte header plus sixteen-byte `reg_info`, hence
24 caller bytes and at most 32 rounded slot bytes per request
(`rtl.cc:123–134,220–246`; `rtl.h:223–233,314–455,703`). Initialization sets
mode/register fields and null attributes. It allocates no reg-attribute record,
pseudo, instruction, label, identifier or function/symbol node.

Thus the correction adds exactly six direct GGC requests to this bounded
projection, 144 caller bytes and 192 rounded slot bytes, with no ordinary
request or finalizer increment. The revised ceilings are **173 GGC events,
13,480 caller bytes and 17,408 rounded slot bytes**. Eight ordinary requests
and 584 ordinary bytes remain unchanged, as do ten possible identifier
insertions, eight new DECL_UIDs, three function-definition increments and two
singleton finalizers. Raw REG objects with null attributes introduce no new
allocating collector callback. The six requests still contribute to eventual
collector lifetime; their temporary use does not justify subtracting them.

## Exact attachment and source-count joins

All 137 aggregate repository pins match their frozen bytes. Every attached
synthetic packet file equals the correction target. The counter callable,
numerical interface, result, source manifest, checker and retained check record
equal the previously reviewed counter freeze; the attached note equals the
separately frozen prose correction. The aggregate validates the complete
synthetic source files and all 48 counter files before loading their callables.
The 48 counter files overlap the reported 300 direct source files and must not
be added to that total.

`evaluate` reads actual source bytes and obtains C,N from `shared_counts`.
The same values drive the pool, graph, final-RTL and counter functions. The
assembler receives those same bytes, and its source identity, C,N, decoded
bytes, literal maximum, final chain, text and data envelope are joined before
the counter result is checked. `native_counter_emission` compares the entire
counter result with the exact expected source-derived record; it is not a
loose comparison of selected true flags.

The new join reconciles function structures, helper gimplifications, non-Main
definition increments and zero additional emitted bodies with the existing
generated-body, cold-layout and corrected synthetic packets. It preserves the
historical warning leaf's unknown empty-elaboration registration field while
supplying the separately established zero. C+6 registrations, next UID C+7
and next order C+6 equal the existing pool/graph bounds; the two helper nodes
are retained in the graph's `8C+35` event delta and are not charged again.

Main's saved function number yields `.LFB1`/`.LFE1`. The attachment checks the
inherited local-name, NUL-inclusive symbol-name and line envelopes and both
complete assembly formulas. Nested GAS/BFD interface equality remains checked.
This only carries forward counter/name preservation under the original
final-RTL/data/invocation premises; it does not turn it into whole-stream
correspondence.

## Why the graph condition can be restored separately

The complete selected registered population is Main, up to two external
callees, the forced dummy, B<=C bounds declarations and exactly two helpers.
The accepted counter argument excludes empty-elaboration registration and
hidden target/declaration/name-hook registration. The accepted body frontier
excludes additional executable bodies or imported dependency references.
These facts establish a graph population bound independently of the number
of unregistered imported tree/pool/identifier allocation events.

The helpers remain live during Main's initial lowering. They receive neither
ordinary lowering nor graph analysis themselves, and initial unused-symbol
removal discards them before ordinary IPA. Their frontend `create`/finalize
route does not invoke the middle-end insertion-hook queue. Removal uses a
noninserting summary lookup or an `exists` guard, and `get_summary_id` merely
reads the stored ID (`cgraph.cc:658–681,2260–2285`;
`cgraph.h:1378–1381`; `symbol-summary.h:214–226,298–304,408–429,488–496`).
Therefore no helper summary record, edge, summary ID or released-ID entry
extends the existing Main graph/summary transfer.

The four Main graph generations still give at most 4C edge allocations and C
live edges; summary IDs, records, worklists and graph-indexed backing retain
their already established bounds. The cumulative C+6 population includes the
helper holes and covers the initial live population. The existing graph
arithmetic also checks its own edge/summary/vector/hash/size consumers; its
symbol-population check is stronger than the separately joined signed symbol
endpoint. The new REG requests change none of those graph inputs.

The graph result correctly sets only
`selected_graph_constructor_frontier_established` and evaluates its conditional
local closure from the existing checks. The broader imported-constructor flag
stays false. This is a graph/summary allocation and representation slice,
not a complete original-construction, shared-container or collector bound.

**Nonblocking timing correction:** the new pipeline-note sentence at frozen
lines 1665–1666 says the helpers are "removed before ordinary lowering/IPA".
It should state the timing above: live during Main's initial lowering, never
ordinarily lowered themselves, and removed before ordinary IPA. The existing
graph section and numerical bounds already preserve that distinction. The
parent fixed it in `739e23259ef24299da5ca5bf4a456ed5b088500a`. I inspected that
exact five-line documentation diff and confirmed the corrected timing. The
finding is resolved; no callable/interface/test change or rerun was needed.

## Preserved unknowns and evidence

Only `native_graph_and_summary_lifetime` leaves the former five-condition
unknown set. `native_varpool_and_shared_tree_pool`,
`Main_assembler_object_interface`, `Main_GAS_BFD_storage` and
`literal_output_linker_representation` remain unknown, each with its own
residual. The selected symbol inventory does not price all imported tree-pool
entries, insertion-capable lookups or replacement requests. Counter/name
preservation does not close global RTL/constant-label endpoints, complete
stream/object correspondence or production/fixed-input materialization.

Complete imported allocation events/bytes remain null. Global counter,
collector and whole-pipeline closure remain false, as does the broader
synthetic-counter no-wrap flag. The additional finalized-body count is two,
distinct from the three allocated non-Main functions; Main is still not the
only finalized definition. No RAM/admission gate or total allocation sum is
introduced. The Hello record retains four unknowns and
`evaluated_predicates_pass=false`; the retained 5,000-call case still reports
its separate sufficient signed-relocation failure, not a native failure.

The successful retained 42-case corrected leaf check (0.213 seconds), 147-case
aggregate check (4.474777033 seconds) and Hello generation (3.367727894 seconds)
were reused. Their source/history and direct/nested inventories overlap.
The 38 added aggregate cases cover altered counters, source counts, persistent
holes, exact source manifests/files, pool/graph bounds, emitted envelopes,
premature closure and the signed endpoint. I inspected their changes/results;
no successful full suite, native capture or expensive validation was repeated.

New focused verification checked the 137 pins, exact frozen leaf bytes,
unchanged prior non-REG/ordinary rows and identity/finalizer demands, six-event
arithmetic delta, stored nested leaf equality and the four-unknown result:
0.118904222 seconds. A separate identity audit checked all 49 synthetic source
lengths/SHA-256/Git blobs and 27 historical inputs, including 47 exact origin
path/length/hash matches: 0.161558957 seconds. The two previously accepted
upstream-identity files retain their original evidence; no network recapture
was needed. These are offline Python consistency checks supporting handwritten
source review, not a compiler simulation or machine-checked C++ proof.

Selected reviewer: GPT-6 Astra / Extra High, assigned by parent; runtime
model/effort confirmation and token/cost measurements are unavailable. Actual
host: Linux 7.0.14 x86-64/LP64. The measured review checkpoint ran from
21:07:09 to 21:11:28 UTC, 259 seconds including correction confirmation,
report preparation and its initial commit.
Intended outcome: challenge the exact attachment, graph-only
promotion and complete six-register correction. Achieved: scoped acceptance
with one prose timing clarification. Native/compiler/prover/build/debugger/
solver executions: zero. Only this report was edited. Parent owns integration,
publication, issue status and durable memory; no GitHub or CLI-memory write
occurred. The child harness goal query returned null; no goal state changed.
