# Original literal Main construction: requests and remaining joins

2026-10-18, Linux x86_64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
This supplies a source-derived request ledger for original gigi construction
of selected Main, its empty elaboration wrapper, the Silver_IO namespace and
the at most two referenced external procedure profiles. It includes discarded
candidates, literal subtype layouts, literal bytes, descriptor construction,
constant folding and backannotation. It is **conditional on the fixed context
visit and shared backing joins below**, and does not establish complete original
gigi or whole-toolchain capacity. No admission, tool, Oracle or invocation
changes are proposed.

The family is exactly the accepted one: one explicit `with Silver_IO;`, the
Main/SPARK shell, C >= 1 qualified direct-literal Put/Put_Line calls, N >= 0
source nulls, no declarations/use clauses, and decoded lengths
0 <= L_i <= INT_MAX. Let D be the number of distinct called procedures,
1 <= D <= min(2,C), and W = sum L_i. Retain the selected Linux non-LTO O0,
no-debug, no-instrumentation configuration and source/installed-behavior
premise at GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
The selected default GNAT encoding is GDB; ALL is not silently substituted.

## Boundary and disjointness

Begin immediately before `Compilation_Unit_to_gnu` and account original
constructors through the saved Main/elaboration trees. The following nested
or subsequent intervals are excluded, with their demands retained in their
own owners:

| Other interval | Existing owner; do not add it here |
| --- | --- |
| Cold `gnat_to_gnu_entity(Standard.String,NULL,false)` | Complete cold String residual packet, including its scalar dependencies |
| Its two `self_referential_size` constructors | 94 events, 6832+2P caller bytes, 80 ordinary bytes in the [helper packet](retained-literal-original-string-storage.md) |
| Elaboration/helper function structures and helper initial gimplifications | Existing 173-event synthetic interval |
| Main struct-function, CF/CFG/SSA and direct initial gimplification | Existing Main structure and `10C+2N+2` rows |
| Main unsharing and materialization helpers | `33C+9N+3` and `8C` rows |
| Constant-pool materialization | Existing `10C` row; original STRING_CST/CONSTRUCTOR objects are separate |
| Cgraph, symbol registrations and forced hard-register dummy | Existing graph rows, including dummy declaration/identifier |
| Warning map and location machinery | Existing warning/location interfaces |

Main's **language_function** is allocated separately from its struct-function
at `trans.cc:4025` and is owned here. The historical null helper 11-event
packet, null structural tree packet and null identifier/global-vector packet
are nonadditive cross-checks: their binding/group/language/elab/stack/tree/name
sites are replaced by this selected-family ledger. The active literal
aggregate does not already attach their totals. No declaration UID or type
UID from an excluded interval is included below.

## Scaffolding and statement lists

`Compilation_Unit_to_gnu` creates the elaboration FUNCTION_DECL/result using
the existing `void_ftype`, pushes its procedure stack, starts one group and
binding, processes the context and Main, then saves one empty BIND and one
24-byte `elab_info` (`trans.cc:5967–6097`). Its later empty-tree guard skips
body finalization/gimplification (`:698–723`). Empty therefore does not mean
allocation-free. Main acts as its own spec and has no executable auxiliary,
inline, handler, At_End, CICO or parameter-cache continuation. The complete
[selected frontier](retained-literal-warning-residual-bound.md) supplies these
exclusions.

Main adds its framework and body bindings, body/handled-sequence groups,
one return-label-stack null push and a 32-byte language_function
(`trans.cc:3947–4291`, `utils.cc:3829–3872`). Each call opens one group/binding
before elaborating the actual's local types (`trans.cc:4899–4921`); each source
null opens a group, creates LABEL_DECL, DECL_EXPR, GOTO_EXPR and LABEL_EXPR
(`:7733–7754`). Bindings cost at most one 16-byte wrapper and one 96-byte
BLOCK apiece; freelist reuse is not required (`utils.cc:682–779`). Thus there
are at most C+3 binding requests. BIND_EXPR requests are at most C+2, including
the elaboration and a conservative extra root Main BIND; the body block can
actually be recycled when its declarations all belong to call blocks.

Use the accepted **Main** source syntax visit bound
V = 73+81C+4N from the [frontend interface](retained-literal-native-frontend.md).
It is used only at specific direct sites: one empty `alloc_stmt_list` request
per selected metadata/pragma/with/body visit, and at most one group per visited
Freeze_Entity. Literal subtype freezing creates no freeze node; a possible
final Main freeze sees its cached function and returns
(`retained-native-expansion.md`, native literal freeze discussion;
`trans.cc:8624–8629,9757–9776`). This conservative V allowance does not assume
that node was absent. It is not an allocation multiplier for arbitrary gigi
helpers. The accepted frontier excludes other expression/action group paths.

Let **I** be the count of implicit-with visits in this compilation-unit context
that are supplied by fixed frontend construction **outside the Main-only V
interface**. An implicit with returns one empty list at `trans.cc:8333–8339`
and does not recurse into namespace or library construction. I is deliberately
an unresolved fixed-interface input, not assigned zero by a sample. The
implicit-with arm has zero pool insertion/lookup/replacement demand regardless
of I, because it returns before namespace or entity translation. A fixed
frontend/context census or a proved zero-trigger argument must supply it.

Define G = V+C+N+3 group starts and A = 4C+3N+2 ordinary statement insertions.
The A allowance consists of 2C local type declarations, C calls, C call BINDs,
3N null statements and one return, with one spare root insertion. Global
DECL_EXPRs are built then discarded, not inserted. A statement-list insertion
transfers existing links; it does not recreate every member link
(`tree-iterator.cc:34–102,188–219`). Hence links <= A, and a safe count of
`alloc_stmt_list` operations is

```text
H = V + I + G + A = 2V + 5C + 4N + 5 + I.
```

The three terms charge direct empty returns, empty end-group results, and
first non-list appends, respectively. Each operation allocates at most one
32-byte header. Every freed list first came from one such operation, so
`stmt_list_cache` pushes <= H; cache reuse changes no lifetime upper bound.
The elaboration and return-label stacks each begin null at this frontier and
receive one push. Their four-slot growth is 40 bytes before GGC rounding;
charge one **64-byte caller request** each because `va_gc::reserve` rounds
before calling `ggc_realloc` (`vec.h:253–260,394–425,833–837`).

## External profiles, names and context

Complete-entity cache hits return before naming/construction
(`decl.cc:400–445`); repeated calls therefore do not create C profiles.
Each of D ordinary procedures has void return and exactly one IN String
formal (`src/silver_io.ads`, `decl.cc:6159–6710`). The cold String interval is
charged separately. Completed String's reference representation is its existing
fat record. This profile adds one PARM_DECL, one result, one FUNCTION_DECL,
one argument TREE_LIST and at most one canonical argument TREE_LIST. No CICO,
padding return, foreign convention, intrinsic, method, alias or address-clause
branch applies. `create_param_decl` and result construction do not push their
declarations (`utils.cc:3377–3383,3690–3820`).

`build_function_type` creates its candidate before a hash hit and can recurse
once for canonical inputs (`tree.cc:7669–7792`). Charge <=2(D+1) candidates,
hash attempts and 16-byte hash records, including Main. Its optional Ada flag
unsharing branch is conservatively paid once per profile: <=D+1 type copies
and <=D+1 16-byte lang_type payloads (`decl.cc:6677–6687`,
`utils.cc:2822–2845,4081–4088`). This avoids relying on the absence of a
preexisting flag-different hashed type. No qualifier variant is selected:
void return clears pure_flag and these procedures are not No_Return.
Callee addresses demand <=2D pointer types/layouts; subsequent calls reuse
the pointer chain. No pointer hash insertion is implied.

The explicit one-component with creates at most one namespace declaration,
one cold map control (128-byte structural ceiling), one 13-slot table of
16-byte entries (208 bytes), and one put (`trans.cc:6416–6515`). No second
namespace component or package body is traversed. The map's embedded
hash_table has a nontrivial destructor: `create_ggc` uses `ggc_alloc`, so export
**one scalar finalizer registration/vector push**, rather than treating this
object as finalizer-free (`hash-map.h:155–162`, `hash-table.h:728–753`,
`ggc.h:175–200`, `ggc-page.cc:1331–1343`). Its backing is part of the shared
collector finalizer-vector join. Main, elaboration, the D
external functions and namespace push D+3 global declarations. Each builds
one DECL_EXPR **before discarding it** in `add_decl_expr`
(`trans.cc:9117–9137`). Parameters/results do not add global pushes.

Identifier insertion-capable lookups are bounded by
K = C+4D+5: each literal subtype; each external's entity, external and two
parameter-name requests; Main entity/external, elaboration and two namespace
requests. Each miss contributes a 40-byte identifier and a NUL-terminated
character request <=32 bytes (`stringpool.cc:40–129`, `libcpp/symtab.cc:148–180`).
The longest conservatively fully qualified fixed parameter spelling is
`silver_io__put_line__item` (25 characters); generated literal names have
<=12 characters before the optional `main__` prefix, hence <=18. This uses
the accepted native generated-name counter/width premise. The other fixed
names are `main`, `_ada_main`, `main___elabb`, `silver_io` and its two procedure
names. No homonym, child, interface-name, Ghost or versioned target mangling
branch applies. Get_Encoded_Name/Get_External_Name copy/append into the fixed
global bounded name buffer rather than interning new Ada names
(`decl.cc:11271–11304`, `exp_dbug.adb:613–908`, `namet.ads:157–163`).
Identifier **hash backing** remains separate from these allocated strings.

`get_debug_scope` skips package/Standard scopes and returns only subprogram
or record scopes (`utils.cc:816–860`). Local literal types find current Main;
the namespace/procedure scopes do not enqueue deferred record contexts.
Thus this interval contributes zero deferred-context entries. Prefix queue
emptiness must still hold at the cold String boundary. The first external
profile has force_global active and does not increment defer_incomplete_level;
the latter guard is E_Subprogram_Type, not E_Procedure (`decl.cc:507–517,
4186–4190`).

## Literal types, scalar folding and original descriptors

Each uncached literal subtype uses bounds 1..0 when empty and 1..L otherwise
(`decl.cc:3142–3193`). It creates two nonshared range types, one 3-slot RM
TREE_VEC (48 bytes), one index lang_type (16 bytes), one index TYPE_DECL,
<=2 Character ARRAY_TYPE candidates/layouts and the final literal TYPE_DECL.
The common continuation adds no padding, named-bound variable, volatile copy,
debug aggregate or extra declaration for this family; the accepted
[local metadata exhaustion](retained-native-ingress-bound.md) fixes that
frontier. Both local declarations create DECL_EXPRs. A data-address pointer
request adds <=2 types/layouts, for **6C** type nodes before profiles.

The following scalar requests apply the accepted
[constant/type transfers](retained-backend-capacity.md), including cache misses
and discarded integer-hash candidates. All arithmetic operands here are
INTEGER_CSTs of precision <=128; successful constant folds return before the
generated matcher. Widths include 8L <= 17,179,869,176 and the empty reversed
range, not merely nonempty strings.

| Per literal work | Scalar requests |
| --- | ---: |
| Low-bound traversal/conversion, length UI_To_gnu, both null constants, one conversion/minus/PLUS helper, sizetype endpoints | 24 |
| Two nonshared ranges | 4 |
| Two array layouts, including empty-array hook | 26 |
| validate_size conversion and TRUNC_MOD | 13 |
| set_rm_size conversion | 12 |
| Two possible nonnegative size annotations through UI_From_gnu | 62 |
| Data pointer's two layouts | 8 |
| Bounds-template endpoint conversions | 2 |
| Both two-element constructor sorts | 12 |
| CALL_EXPR operand count | 1 |
| **Total** | **164** |

UI_To_gnu has an explicit type and at most three base-2^15 digits for both L
and 8L: two initial constants plus <=2 repetitions of one digit constant and
two constant folds gives 2+2(1+2+2)=12. The explicit type prevents widening
retries (`cuintp.cc:76–158`). The source lower bound is immediate one. The
24 row conservatively pays both empty/nonempty branches; its decomposition is
1+1+12+2+1+1+4+2. Function and callee pointer layouts add <=16D+8 requests.
Thus **R = 164C+16D+8**. Each request costs <=one 40-byte INTEGER_CST plus
at most one 2040-byte small-constant TREE_VEC. Charging R of each is safe
without claiming that R distinct type caches exist. Large-constant hash
insertions/lookups remain <=R and require their shared backing join.

The two annotation roots are nonnegative constant sizes. They return directly
at `decl.cc:9347–9358`, giving **zero Rep_Table additions, annotation-cache
entries, negative-expression nodes or dynamic annotation serial increments**.
UI_From_gnu uses a signed32 immediate conversion or at most five stored digit
words (`cuintp.cc:171–213`): export <=2C Uint entries, <=10C digit words and
<=2C UI_Ints wrapper calls. The alignment is immediate one and adds no Uint
entry. Do not substitute the generic Q bound that fabricates representation
nodes for these constant roots.

`trans.cc:6705–6731` makes exactly C original STRING_CST requests, with total
caller bytes W+21C. Scratch bytes are L_i: ordinary heap requests occur exactly
for L_i>=1000; otherwise alloca uses <=999 bytes (`trans.cc:87–90`). Empty
literals still request a 21-byte STRING_CST. Neither a descriptor nor later
pool insertion copies its character payload at this point.

Conversion through `utils.cc:4794–4905,5591–5627` and
`utils2.cc:1570–1601,1740–1782` creates three addresses (data, bounds, callee),
at most one pointer NOP, two CONSTRUCTORs, one discarded
UNCONSTRAINED_ARRAY_REF and one CALL_EXPR per call. Including the two local
DECL_EXPRs gives **10C ordinary expression requests**, before BINDs/global
DECL_EXPRs/nulls/return. The accepted pointer-address matcher closure applies;
there is no SAVE, temporary, copy-back or null-fat-pointer alternative.
Each constructor vector grows from null to at least four elements, even
`vec_alloc(v,2)`; its raw 72-byte backing is rounded before allocation, so
charge **two 128-byte caller requests per call**, not two 40-byte requests.
The one-argument auto_vec in Call_to_gnu stays inside its 16 inline slots.

Each record sort has two elements, hence one comparator in gcc_qsort's
netsort; its scratch fits the inline buffer (`sort.cc:167–175,255–280`). Each
comparator calls bit_position twice, each with one constant conversion and
two size_binop operations (`utils2.cc:2125–2164`, `stor-layout.cc:941–955`).
This explains the 12-request sort row. Selected initializer_constant_valid_p
walks constant/address/NOP leaves without cache allocation or pool insertion
(`varasm.cc:5052–5168,5328`). Original tree-pool API demand is **zero**:
zero insertion, lookup and replacement calls, independently of I. The external
and Main/elaboration `rest_of_decl_compilation` calls have no alias/register
attribute, skip non-function varpool finalization and use the selected no-op
function relayout hook (`passes.cc:176–250`; the accepted
[counter/hook argument](retained-literal-counter-emission.md)). They do not
introduce a hidden pool call. This zero does not include the later accepted
Main gimplification pool interval and is pending independent review before
any aggregate pool condition is restored.

Alias accounting must not be erased by O0: get_alias_set explicitly preserves
type alias construction under no-strict-aliasing (`alias.cc:873–880`). The first
literal copies the completed old XUA alias set. On the selected nonaliased
component path, an unknown XUA demands <=one new alias ID and <=two vector
appends (including a possible sentinel); ARRAY has no component-recording
branch (`alias.cc:980–1015,1171–1177,1253–1340`). No alias child hash entry is
created. Later literals copy the known ID. The cold String packet owns any
separate Positive/Integer alias demand.

## Callable ledger and precise remaining obligations

The [callable](../evidence/retained-literal-original-main-storage-20261018/derive.py)
exports rows, individual caller ceilings, per-request power-of-two GGC
rounding ceilings, the symbolic +I list row, and these identity demands:

```text
DECL_UID increments <= 2C+N+3D+5
type UID increments <= 6C+5D+3
alias ID increments <= 1
identifier insertion-capable lookups <= K
type-hash insertion-capable lookups <= 2(D+1)
integer-hash insertion-capable lookups <= R
global_decls appends <= D+3
stmt_list_cache pushes <= H
alias_sets appends <= 2
scalar finalizer registrations/vector appends <= 1
```

The individual requests are concrete for supplied C,N,D,lengths and I. The
conditional sum is not a complete capacity result until all of these joins
are discharged:

1. Supply I from the fixed frontend/context source interface; the executable
   leaves it unspecified by default and reports the exact +I event/+32I
   caller-byte dependence. It does not infer I=0 from the one explicit with.
2. Apply the existing shared backing transfers to incoming **occupied and
   allocated** identifier, type-hash, integer-hash, global_decls,
   stmt_list_cache, alias_sets, scalar-finalizer vector and Uint/Udigits/UI_Ints
   state plus these demands.
   The cold namespace map and two null-origin procedure/return-label stack
   backings are already charged locally. Incoming state is not reset to zero.
3. Join the disjoint cold String, 94-event helper, 173-event synthetic,
   Main struct-function/ingress/lowering, pool, graph and warning/location
   packets. Original names and type candidates here do not replace those
   intervals' names or candidates.
4. Check all incoming UID/index/counter endpoints and allocation products
   using native widths, then apply the collector/host stack and full process
   lifetime transfers. Local L<=INT_MAX ensures the character-loop i+1 is
   representable, not that a whole process fits.

These are named source sites and container demands, not an unexplained
allocation multiplier. They identify exactly why the callable reports
`complete_original_gigi_storage_closed=false` and
`whole_toolchain_capacity_established=false`.

The [packet](../evidence/retained-literal-original-main-storage-20261018/README.md)
freezes complete upstream files and repository predecessors. Its offline
checks verify identities, arithmetic, empty/threshold/INT_MAX lengths,
distinct procedure count, dependency exclusions and symbolic I growth.
They do not execute GCC or establish universal correctness by sampling.
Independent source review remains required. Selected worker: GPT-6 Astra /
Extra High; runtime setting confirmation and token/cost measurements are
unavailable. Work began approximately 21:24–21:26 UTC; the packet records its
actual completion clock. No compiler, prover, build or full test suite ran.
