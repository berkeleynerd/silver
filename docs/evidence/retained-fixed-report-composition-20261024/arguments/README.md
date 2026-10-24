# Silver_Arguments report composition

2026-10-24 UTC; owner-authorized #212 under #119. This packet supplies the
actual Arguments source inputs to the accepted producer/reader algebra. The
first specification packet and IO packet remain byte-for-byte unchanged.
IO author 0f39a36c1458f7af4f216fce3f9bcde8d8aab123 and the separate native
configuration author were accepted at their partial scopes by review
d39dc7cff5985a24b81345f23e645e2a237c2a6d. This packet imports only IO and its
accepted capacity providers; it does not import the native configuration
provider or attach its owner-specific fields to GNAT2Why.

The result closes Arguments **report count/name/schema inputs**, subject to
the inherited selected source/native and typed-prefix premises. Actual common
paths, native warning/storage joins and full five-report composition remain
open. No cap on admitted programs or paths is adopted. Global e<=2, two
save-entering callbacks and three saves are unchanged; physical resources
remain separate. No production, launcher, source pin or Oracle is changed.

## Source closure and distinct domains

The exact six Silver sources and complete SPARK/GCC/GNATCOLL input files are
hashed in source-manifest.json. The revisions remain SPARK
42554fc241fcd1fdf08d3a2feccb3f86912acbc0, GCC
6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea and GNATCOLL
1d4374ae9187fd14d42ca99a3deb0ab2ff1ebc55.

Accepted **A_frontend=E_frontend=19,921** and Why allocations **13,070** are
whole-process domains, including imported references, abandoned construction
and earlier translation. They are not replaced by the local flow domains or
eight report identities below. The analyzed graph domain is the package,
Is_Message, Input_Is_Valid, First_Or_Default and Reject, established in the
first accepted packet. Imported bodies and IO's bodies are not analyzed here.

The actual source statement census is:

| Body | Conditions including elsif | Simple function returns | Extended returns | Explicit objects | Nested blocks | Pure calls in body | Procedure calls |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Is_Message | 0 | 1 generated | 0 | 0 | 0 | 0 | 0 |
| Input_Is_Valid | 2 | 3 | 0 | 0 | 0 | 4 | 0 |
| First_Or_Default | 5 | 2 | 2 | 3 | 1 | 6 | 0 |
| Reject | 0 | 0 | 0 | 0 | 0 | 0 | 1 |

The three First_Or_Default objects are Item and the two distinct Result
objects. Its postcondition also contains one Input_Is_Valid call. No source
assignment, executing loop, side-effect function or return cleanup is present.
The two `for all Ch of ...` constructs are quantified expressions.

`sem_ch6.adb:298–390` constructs one simple-return node and one body for
Is_Message, with an empty declaration list and one statement list. Its
spec/body links (`:530–590`) preserve one callable identity. There is no
frontend inlining into callers: `inline.adb:1950–2030` excludes expression
functions and package-spec APIs. Prover-level expression-function inlining
does not introduce a frontend body or instantiation-location chain.

`sem_ch4.adb:4600–4812` preanalyzes quantified iterators and their conditions.
The light-expansion whitelist (`exp_spark.adb:118–205`) does not expand a
quantified expression; its array-iterator expansion selects N_Loop_Statement,
not this node. Thus no new executing loop or repeated statement subtree is
created. `flow_utility.adb:5335–5398` collects the iterator's array expression
and removes its Ch binder from the returned variable sets. The synthetic
quantifier scope is an E_Loop entity, not another object root.

The return analysis in `sem_ch6.adb:780–980,1902–2067` analyzes each extended
return's existing object declaration once and its optional HSS once. These
have no HSS, handlers, controlled types, access values or finalization. Simple
returns of Boolean or the empty String do not take the controlled-aggregate,
access/interface or limited-result rewrite branches. The light expander does
not perform ordinary return/code-generation expansion.

Array actual subtypes and their bounds need separate allowance. For one
dimension, Build_Actual_Subtype makes one subtype with one index range
(`sem_util.adb:1192–1337`); Get_Actual_Subtype returns a cached entity when
available, otherwise analyzes a type attached to the relevant expression
(`:10270–10378`). This can allocate nodes without adding an executing statement.
Process_Range_Expr_In_Decl may force two scalar bounds (`sem_ch3.adb:
22588–22835`). Remove_Side_Effects is gated by full analysis and the allowed
GNATprove declaration/loop contexts (`exp_util.adb:12618–12723`). Each scalar
capture is one declaration; checks are suppressed while analyzing it and
existing safe references are not recursively captured (`:12723–12824`).

For completeness, a captured non-scalar call result is allowed as one String
temporary. GNATprove's fallback copies the result and does not generate the
normal expander's access type (`exp_util.adb:12949–13070` and following object
construction). Reusing that occurrence prevents another evaluation of the
same call during the two bound copies. These are upper allowances, even where
the context gate or side-effect-free attribute test suppresses them:

| Body | Scalar capture slots | String temporary slots | Type/declaration slots |
| --- | ---: | ---: | ---: |
| Is_Message | 2 | 0 | 4 |
| Input_Is_Valid | 2 | 1 | 4 |
| First_Or_Default | 8 | 1 | 12 |
| Reject | 0 | 0 | 0 |

Is_Message charges Item's two possible bounds and two type/index pairs,
including a surplus pair for the quantified context. Input_Is_Valid charges
the one array-valued Argument actual, its two bounds and two type/index pairs.
First_Or_Default charges four bounds of the two explicit return constraints,
two bounds for Item and two for the possible captured Argument result. Its
twelve type slots allow a subtype/index pair for each of Default, function
result, both Result objects, Item and the possible temporary. Cached types,
preanalyzed contract types and safe First/Last references do not recursively
create new type chains. Attribute Length/First/Pos and membership rewrites
add expressions/check flags, not another statement body. Discarded range-check
queries remain in A_frontend; Insert_Range_Checks returns when expansion is
inactive (`checks.adb:8117–8165`).

## Normal-use roots and vertices

Normal-use roots, with constant and generated slack retained, are bounded by:

* Is_Message: Item, Boolean function result, Max_Length and two scalar captures:
  five roots.
* Input_Is_Valid: Boolean result, Max_Length, a surplus imported Number formal,
  one possible String temporary and two scalar captures: six roots.
* First_Or_Default: Default, function result, Item, both Result objects,
  Max_Length, one String temporary and eight scalar captures: fifteen roots.
* Reject: File_System. The package has no object roots.

Allow two facets per root plus synthetic null, yielding **F=11/13/31/3/1**.
This overcharges scalars and constrained arrays. The accepted Get_Components/
Flatten_Variable result applies: scalar/rank-one objects have no record
component or per-character expansion. Formal identities carried by call
attributes are not automatically used/defined variables. Do_Subprogram_Call
recurses into actual expressions and unions effect globals; it does not
insert the callee's result identity as an object of its caller
(`flow_utility.adb:3069–3332`). Pure-call globals are empty; Reject's imported
setter has exactly File_System. The accepted
global effect universe remains six identities. Source constants filtered out
of normal flow remain in the independent E_frontend/proof-reference domain.

Use the accepted constructor coefficients: ten scaffolding vertices, 2F
initial/final vertices after deduplication, three per condition or simple
function return, five per object/capture, four per type position and block,
one per contract expression and fifteen for the one-global procedure call.
Ordinary pure calls belong to the containing expression vertex and its two
possible folded-check vertices (`flow-control_flow_graph.adb:300–345,
6439–6502,7339–7385`). They do not create side-effect call-control vertices.

An extended return processes its declaration list once, adds one dummy join
and one implicit return defining the function result
(`flow-control_flow_graph.adb:2426–2533`). Charge four local vertices in
addition to its separately counted object declaration. No Unwind action
replays a subtree for these non-controlled String objects.

The table in capacity.SOURCE charges join counts 8/11/27/6: declaration and
statement lists, each then/elsif arm, block joins, three contract joins and
all capture-action lists. First_Or_Default additionally charges both return
declaration lists, two surplus optional return-HSS lists, the inner block's
declaration/statement lists and the possible String-temporary action list.
It has two abstract/refined postcondition slots; two are also conservatively
retained for the other functions. The package receives ten scaffolding,
two initial/final, four block and six join vertices.

Summing gives **V=75/99/246/41/22**, respectively. Constructed vertices are
separately bounded by **A_frontend+V per graph**. Additional nonflow
pragmas/markers are null; the accepted clearing/original-program-flag argument
from the IO packet applies unchanged. Substantive vertices later pruned or
flagged dead are already charged to V. This is not a retained graph census.

## Attempts, warnings and outside checks

Do not assume any sanity, initialization or proof check succeeds. Retain the
accepted function side-effect and volatility rows, and the full termination
scan and success-message row. Let C=0/8/16/1 bound typed call occurrences and
each vertex's call set. Input_Is_Valid's four source calls are doubled to
cover the copied Argument bounds. First_Or_Default has six body calls plus
its post call; sixteen covers that frontier, the separate post retrieval and
the two bound copies of its sole Argument call. Capturing that call replaces
it by the existing temporary and does not recursively clone calls. There is
no frontend inlining, predicate, overloaded record equality or indirect call.

The only removed VF family is illegal reads of Proof_In: the three explicit
Global contracts have none; Is_Message has no user-supplied Global and fails
that check's entry filter (`flow-analysis.adb:3642–3725`). No local abstract
state exists. With Q=twice the type-slot count, the accepted generic emitter
table therefore specializes to

```
B_function_or_procedure = QF + 5VF + 12F + V(4+C) + 13C + 6.
```

Using the same formula for Reject deliberately retains impossible function
rows. The package has no objects/calls/loops and uses `6V+12`. The respective
attempt bounds are **4,651 / 7,993 / 44,380 / 875 / 144**.

Outside the graph loop, charge four required-contract attempts. The relevant
nonempty expression roots are Is_Message's expression, First_Or_Default's
Post and imported Argument's Pre. No other imported callable has a pre/post;
the with/constant reference to Silver_IO does not mark all its API bodies or
contracts (`spark_definition.adb:4289–4308`). Scalar/String/Boolean type
references add no predicate/DIC roots. Charge five root positions, twice for
abstract/refined retrieval and twice for the entity-list insertion routes:
twenty visits. Mark_Entity's seen gate and those routes are the accepted
`spark_definition.adb:11834–11852,12208–12249,12873–12892` argument.

Each visited expression has at most32 whole-object references: its explicit
objects are only Item/Max_Length, function result/Max_Length, or Number;
quantified Ch is filtered, Input_Is_Valid and Argument_Count contribute no
effect globals, and all listed generated slots fit within32. Get_Variables_
For_Proof drops bounds and returns entire variables (`flow_utility.adb:
5652–5742`). These three expressions contain no external abstract-state
reference to expand. This local bound does not shrink broader proof-reference
allocation. Outside attempts <=4+20*32=644; total flow attempts **58,687**.

Retain every one of the **13,070** Why-allocation warning slots. There is no
executing for loop, hence the flow array-initialization recognizer has zero
invocations; quantified iterators do not enter it. Retain 13C alias-warning
slots for all25 call occurrences despite the narrower pure/scalar profiles.
Warnings total **13,395**. All accepted successful-prefix warning exclusions
remain in force. Native warning location chains are not assumed to have the
metadata location depth.

Traces retain sum(V+2VF), at most V lines each, and P+12 bytes per line.
The phase-2 counter starts at zero as in the accepted packets. The relative
filename `silver_arguments__flow__` + ten digits + `.trace` is at most40 bytes.
Native print attempts remain 3*flow+2*warning; initial diagnostic tables,
native chains and private-fix strings keep their separate owners.

## Strings, metadata and the composed report

The new census adds function-side-effect, function-volatility, termination
and the no-effect helper to the accepted IO regions. Their literal totals
129/209/689/26 and marker counts do not exceed the accepted maxima: 1,189
literal bytes, fourteen ampersands, one hash. All fixed text is printable
ASCII. The same wrapper, substitution and SARIF surplus proof gives raw text
3818+5P, decoded SARIF text3868+5P and encoded JSON text7738+30P.

Use raw/generated name bound128 to include the longer Arguments scope,
one represented internal serial, selected subtype/FIRST/LAST suffixes and
homonym qualification. Source scopes have depth at most package, function,
return/block; there is no recursive generated-name construction. This leaves
the accepted canonical magic-name substitution maximum unchanged:
`max(4*128+64,760+2)=762`. Serial representability remains an existing premise.
Paths keep the accepted diagnostic-delimiter and UTF-8 premises, with factor
six escaping; no ASCII-path condition is added.

The actual flow/warning constructors are unchanged. The accepted IO schema
and mixed-string helper are imported as frozen functions. Only the trace
string allowance changes from33 to40: adding42 encoded bytes changes neither
container cardinalities nor the maximum decoded-string field. Warnings keep
fixed text192, absent entity/response fields and PC_Trivial. No source
Annotate adds suppression payloads. Optional fields already charged by the
IO overlay remain charged.

The report identity domain is exactly bounded by the eight names in
REPORT_NAMES: the package/four local callable identities, Runtime.Argument,
Runtime.Argument_Count and the output setter. Flow attaches graph/contract
owners; warnings have no E; proof rows belong to the three proved functions.
Get_SPARK/timings select analyzed entities, and call claims may add the three
imported callees. No IO API or imported package becomes a report entity.
Full_Source_Name<=34 and metadata depth one follow the actual names and absence
of frontend generic/inlining chains. Allow every pair over these eight
identities: forty claims and448 edges. This avoids relying on a smaller
observed call-pair count. Timing bounds are nine entities and101 fields.

The accepted canonical IO/Arguments provider supplies **R/G/A/J=11/39/95/3**.
The only source String expressions here are empty; Character/range/attribute
primitives and generated names are at most128, with attribute names<=6.
The accepted stored-Uint image550 dominates, giving W550, printed CP15581 and
proof text31439. Source-copy allocation is still a separate source-span guard.
Reuse canonical_proof unchanged, preserving full proof schema and global
occurrence totals. No per-row multiplication of G/A or renewed callback/save
allowance is introduced.

The checker exports full/projected affine byte bounds and the largest
sufficient integer P in 0..4096 under max-path<=4096 and page-size<=65536.
It checks the closed endpoints and the next failing successor. All imported
guards are monotone. This is a useful conditional interval, not actual common
P attachment or permission to reject a program. Common P must still cover
project argument, initial/saved cwd, object directory, source/reference/sloc
paths and every generated report/config filename. Native service limits are
distinct operands and owners.

## Verification and residual scope

Run only the new focused check with the already available GCC source tree:

```
python3 docs/evidence/retained-fixed-report-composition-20261024/arguments/check.py \
  --gcc-source /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada
```

It verifies complete-source identities, preservation of accepted packet files,
the actual source census, expanded literal census, source correspondences and
composition arithmetic. It does not execute predecessor checkers or a native
compiler/prover/capture. The manually classified source closure requires
independent review. Selected author model/effort: GPT-6 Astra / Extra High;
runtime confirmation and total task token/cost measurements unavailable.
Exact run evidence and selected settings are in result.json and round.json.

Remaining work is the actual common-path/configuration join, native warning
chains and initial-counter/storage joins, header/source-span/private-fix
storage, and five-report collector/SARIF composition with Main. Neither #212
nor #119 is complete. The independent native configuration packet remains
separate and unchanged. Review of this new Arguments freeze is pending.

The focused check passed on its first run in 0.832 seconds. Full pretty bytes
are 564,586,270+2,193,744P; projected bytes are 564,143,292+2,193,744P. The closed
sufficient interval ends at P=395; P=396 fails only the writer's unbounded
alignment guard. These are mathematical source bounds, not measured report
sizes. The run verified 31 repository inputs and 35 complete tool source files,
with zero native/compiler/prover/capture runs and zero predecessor replays.
