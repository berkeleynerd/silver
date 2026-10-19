# Literal later shared consumers and residual endpoints

2026-10-18, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). This joins the
reviewed Main gimplifier, CF, initial SSA, direct constant-pool and graph
demands to the corrected original shared state. It establishes a disjoint
named-consumer transfer, not the entire later compiler lifetime. The
[packet](../evidence/retained-literal-later-shared-storage-20261018/README.md)
keeps unresolved endpoint inputs null and makes no production change.

Review identified [#140](https://github.com/berkeleynerd/silver/issues/140):
the initial AST validator selected the first definition but its execution map
selected the last. The repair rejects duplicate definitions and compiles the
same unique nodes it validates. Thirty-three focused correspondence checks
pass, including unchanged Hello output. The original 40-check result is
retained with its original input; no accepted component suite was rerun.

For C>=1 literal calls and N>=0 nulls, the new named demands are:

| Owner | Identifier insertions | DECL_UID increments | type_UID increments | Scalar registrations |
| --- | ---: | ---: | ---: | ---: |
| Main descriptor materialization | 0 | C | 0 | 0 |
| CF common return label | 0 | 1 | 0 | 0 |
| Initial SSA .MEM/default-definition hash | 1 | 1 | 0 | 1 |
| Direct String/bounds pool declarations | 2C | 2C | 0 | 0 |
| Graph call-site/value-range controls | 0 | 0 | 0 | 5 |
| **Named total** | **2C+1** | **3C+2** | **0** | **6** |

Each row contributes demands to shared backing; its direct objects are already
owned elsewhere. This packet adds **zero new direct GGC objects** and **zero
GGC backbone events for these named shared demands**. Identifier-table and
scalar-finalizer backing allocations are ordinary heap requests. Their
request counts are at most 2C+1 and six, respectively, while their byte ceilings
must include any interleaved unjoined consumers.

## Source, boundary and unchanged ownership

Use the existing complete literal recognizer and the retained selected
Linux x86-64 SysV O0, no-debug/no-instrumentation/no-LTO/no-PCH configuration.
Keep its proposed native split-wide-types and source/installed-behavior
premises. Source bytes, complete recognized counts and decoded lengths must
match the caller's original shared result. The callable then requires exact
equality with the source-bound indexed identifier correction from
[#137](https://github.com/berkeleynerd/silver/issues/137). A retained Hello
input cannot be attached to another source merely because C and N coincide.

The incoming cut is the return from `finalize_size_functions`, before
ordinary Main analysis. The
[original shared argument](retained-literal-original-shared-storage.md)
already includes original Main/String/helpers, initial gimplification of both
cold size helpers, the forced dummy, and five scalar-finalizer allowances.
Those five include the namespace map, two helper SSA controls, warning map
and assembler-name map. The last two may be created conditionally or later;
their allowance is deliberately retained in the incoming ownership budget.
It is not a claim that all five objects are live at the cut.

The graph ledger spans both sides of this cut: its fixed Main/helper/dummy
nodes and dummy identifier/DECL_UID are not new later contributions. Likewise
the pool interface's one assembler-name-control registration is already in
the original five. This transfer selects only its 2C direct pool declarations
and identifiers. No original direct pool demand exists under the accepted
original pool-frontier proof.

Main's `allocate_struct_function` occurs during original translation
(`trans.cc:4024`) and owns five direct requests: function, EH status, two EH
vectors and machine state. It is separate from the three non-Main structures
inside synthetic173. Neither is allocated again by this packet; Main's later
`init_function_start` is RTL preparation, not another struct-function
constructor (`function.cc:5026–5038`). Helper94, synthetic173, original
warning/location backbones and existing direct pool/SSA/graph event subtotals
are never added to this shared delta.

## Why the named rows have these demands

**Materialization and CF.** The accepted initial lowering creates C descriptor
VAR_DECLs with already complete fat-pointer types. `create_tmp_var_raw`
requests a name only for a nonnull prefix; the constructor's `get_name` is
null (`gimplify.cc:629–721,6157–6284`; `gimple-expr.cc:439–466`). Thus this row
adds C declaration UIDs and no identifier. CF creates one unnamed common
return LABEL_DECL (`gimple-low.cc:1208–1217`; `tree.cc:12039–12052`). Original
null-statement labels are already original Main declarations. The deep-unshare
ingress cuts at types/declarations/constants, and the selected constructor
copies and pointer-cache helpers create no declaration/type candidate; those
accepted zero UID deltas are checked separately.

**SSA.** `create_vop_var` builds the single artificial `.MEM` VAR_DECL using
the existing void type and `get_identifier(".MEM")`
(`tree-ssa-operands.cc:232–251`). Layout copies the existing type fields; it
does not create a second type or declaration. The initial SSA interface owns
its node, identifier and five-character string, as well as the default-def
hash control/backing. Only that control has a nontrivial destructor. SSA_NAME
objects have their separate version/creation counters, not DECL_UID/type_UID.
No PHI or real SSA name is introduced by the reviewed selected shape.

**Pools.** `build_constant_desc` constructs one VAR_DECL using `TREE_TYPE(exp)`
and interns its LC label (`varasm.cc:3720–3748`). The retained literal pool
interface supplies at most 2C fresh descriptors. Each label may miss, yielding
2C identifiers and declarations. Existing size/alignment fields are reused;
String/bounds payloads are not copied. The 10C direct pool event owner already
includes the identifiers, their character objects, declarations, descriptors
and duplicated symbol strings. Hash-table growth must not charge these again.

**Graph.** The reviewed four call-site-table lifetimes give four controls,
and the value-range map gives one. Summary managers use no-dtor allocation,
records use raw allocation and their embedded pointer maps do not become
additional standalone controls. Fixed graph nodes and dummy objects precede
this boundary or have other owners. The source-bound graph interface exports
five registrations and supplies the needed lifetime bound; four scans are
not four copies of every table or symbol.

These statements are about the named constructor routes. They do not certify
zero identifier/type/alias demand in every remaining selected pass. In
particular `get_alias_set` explicitly retains type construction under
no-strict-aliasing, and its pointer canonicalization can call pointer/reference
type builders (`alias.cc:873–880,1094–1134`). That route requires its own
selected-input exclusion or demand. Absence of optimizing transformations is
not by itself a complete shared-container proof.

## Corrected history, projected endpoints and residuals

The accepted corrected ingress has 1,589 Source_File entries, 1,590 filename
lookups and 3,180 separately owned direct filename requests. Its identifier
incoming history is 40,847. With D the number of distinct Put/Put_Line callees,
original post-ingress additions are `C+4D+31`. Consequently the corrected
original endpoint is `40878+C+4D`. Adding the named `2C+1` gives the projection
`40879+3C+4D`.

Identifier capacity uses the unchanged accepted transfer
`max(incoming_capacity,16384,rho(floor(4H/3)+1))`. It checks `4H<=UINT_MAX`,
`3*slots<=UINT_MAX`, doubling and the pointer-array byte product. A first-wrap
argument for temporary-name serials consumes the complete historical
identifier count, including deleted entries; current occupancy is insufficient.
This packet never asserts that the named projection alone closes that proof.

The original declaration endpoint is `5867+2C+N+3D`, with the existing fixed
prefix and String/helper/synthetic/dummy terms. The named projection is
`5869+5C+N+3D`. Original type history is `2295+6C+5D`; named rows add zero.
Use signed32 for the declaration endpoint and unsigned32 for types.

The incoming scalar-finalizer budget has occupancy <=39,262 and allocated
capacity <=58,891. With the named six, its projection is 39,268 and capacity
58,900, or 942,408 bytes per potential ordinary backing request. The accepted
heap-vector transfer is `F(L)=max(4,L,2min(15,L-1),floor(3(L-1)/2))`; retain
the incoming capacity, check unsigned growth/length, 31-bit capacity and
the `8+16*capacity` byte product. Collection can remove entries but cannot
erase historical allocation/registration demand.

For Hello, the named projections are identifier history **40,886**, identifier
capacity **65,536**, next DECL_UID **5,877**, next type_UID **2,306**, and the
scalar figures above. They are diagnostic projections over a specified set
of owners. They are not full chronological endpoints or sufficient byte bounds
when other consumers interleave.

The full conditional interface therefore requires four explicit residual
ceilings: other identifier insertions, declaration increments, type increments
and scalar registrations after the same cut, excluding demands already owned
by the original allowances or the five named rows. It adds each to the incoming
state plus named demand before recomputing the corresponding guard/capacity.
Unspecified residuals remain null, and the corresponding full endpoint remains
null. Supplied numbers permit conditional arithmetic only; their source bounds
remain unestablished here. Even supplying zero does not turn a completeness
flag true. Whole global-counter, gimplifier, collector and native flags stay
false, and total GGC events stay null.

## Remaining selected-route shared lifetime families

The machine-readable [remaining-family checklist](../evidence/retained-literal-later-shared-storage-20261018/remaining-families.json)
is the exhaustive category partition for finishing this native shared/counter
join. It deliberately distinguishes direct mem_attrs records from interned
hashes and from collector bookkeeping:

| Family | Next source join |
| --- | --- |
| Other tree IDs and identifiers | Complete the constructor/name partition through fixed setup, RTL passes/frame and unit output, including pointer-type helpers and spill/debug exclusions; discharge the three identity residuals. |
| Type/integer hashes and global_decls/stmt_list_cache/alias_sets | Source the remaining lookup/insertion/push lifetimes and apply the existing incoming-state transfers; a GIMPLE tuple is not a statement-list-cache push. |
| CONST_INT cache | Join incoming history/capacity, fixed setup, operation expansion, alias analysis and later RTL calls, including pre-hit growth and weak-cache reinsertion. |
| reg_attrs cache | Join declaration RTL assignment, split offsets and later copy/rename/LRA calls to the complete incoming hash state. |
| mem_attrs | Reconcile direct changing setters in operation expansion, adjustment/copy, fixed frame and any selected spills. There is no shared mem_attrs hash. |
| Remaining scalar registrations | Bind fixed startup/real-pool/frame controls, then exhaust selected loop-exit and other pass controls with their recreation lifetimes. |
| Array/outer finalizer and collector state | Finish typed-array registration and depth histories, then apply total-event/per-object page and vector guards; allocation-free callbacks do not close this input. |
| Other counters and ordinary allocators | Reconcile SSA/RTL/DF/symbol/label/alias reset and increment interfaces, dynamic register capacities and ordinary pool/stack lifetimes. |
| Ordinary source line-map array | Parent preallocation slice `9c52c43a6f` is completed but unreviewed; this packet consumes none of its values. Review/attach that slice, then exhaust later selected ordinary-map writers. Keep these GGC events distinct from combined-location storage and ordinary-heap arrays. |

Two concrete residual facts prevent accidental zeros. First target RTL setup
already owns 120 non-saved CONST_INT candidates and at most 121 hash backbones
inside its 437-event envelope. Its source-projected zero tree UID change does
not imply zero cache growth. The hash's individual bytes still need complete
incoming state. Second, cold setup creates a temporary-address and dummy
constant-pool hash; real Main creates another pool hash, while prologue and
epilogue recording can each create a control (`function.cc:1239–1253,5734–5740`;
`varasm.cc:4149–4167`). These five potential registrations are outside the
named six. Recorded loop-exit controls (`cfgloop.cc:1126–1141`) also require
the actual selected pass lifetime; an empty loop exit set alone is not proof
that its control is absent.

The conditional `rtl_hash_transfer` exports a lookup-driven subtotal: one
possible backing per insertion-capable lookup, a prime/capacity bound from complete incoming
history and new-entry demand, and probe/load/byte guards. It supplies no
missing source multiplicity, assumes no absent prefix, and adds no already
owned direct entry objects. Constructors, `empty()`, resizing `traverse()` and
explicit resize sites require separate source ownership; the generic hash
implementation can allocate without an insertion-capable lookup
(`hash-table.h:910–955,1188–1194`). Its complete-cache flag therefore stays
false and its non-lookup event count null. The default result does not evaluate it using a
made-up zero residual. The accepted operation/split inventories' C+2C
reg_attrs and 5C mem_attrs direct objects retain their existing owners.

## Evidence and round record

The packet reuses accepted pure constructor functions with exact AST pins,
and validates the complete relevant retained source files and repository
inputs. It compiles only the pinned function definitions and native-width
assignment into an isolated namespace: no aggregate module or Context is
executed, and no accepted component suite is run.
AST pins cover only the reused functions and their native-width/require
dependencies, so unrelated later aggregate attachment does not silently
change their semantics or force a broad replay. Prior source inventories and
reviews remain accepted evidence; this packet does not reproduce them.

Focused checks bind actual source identity/counts, reject altered shared or
corrected ingress, reconcile all named ownership rows, test neighboring
capacity/width endpoints and keep absent residuals distinct from explicit
numbers. No compiler, capture, debugger, build, prover, broad suite or GitHub
action is performed. Independent review and aggregate attachment remain with
the parent; CLI memory was not updated.

Selected worker: GPT-6 Astra / Extra High. Runtime confirmation and token/cost
measurements are unavailable. The round and checker records retain actual
timestamps/elapsed evidence. Source review found that the six obvious
registrations exclude fixed RTL/frame controls and that mem_attrs is a direct
record allocator; both findings are preserved as concrete next joins rather
than hidden in an endpoint. Base: `e8c320431fd3edf034da3d77d6bbc9a8a85768a0`.
