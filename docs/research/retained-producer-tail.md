# Retained producer registration and output consumers

2026-10-18, Linux x86_64, research for [#119](https://github.com/berkeleynerd/silver/issues/119).
The [producer composition](retained-producer-composition.md) covers the
successful Why-generation/serialization prefix for Main and four separate
fixed library processes. **It does not yet cover their complete process ends.**
This record closes additional registration/container domains and identifies
the exact remaining response/report interfaces. It changes no admission rule,
does not select a report-size membership limit, and runs no native tool.

The [offline inventory](../evidence/retained-producer-tail-20261018/inventory.json)
and [checker](../evidence/retained-producer-tail-20261018/check.py) scan all 279
Ada files in the same SHA-256-pinned SPARK archive used by the composition.
They retain all registration/static-result/label constructor call sites and
the current six selected library source digests. The inventory supports the
source exclusions below; it is not a proof of call multiplicity by itself.

## Where the process continues

`Translate_CUnit` generates all requested VCs, checks safe-guard cycles,
clears the translated-object map, and frees the Why names and node/list tables
(`gnat2why-driver.adb:1445–1455`). The driver then calls `Collect_Results`,
processes unused-annotation warnings, and writes the final `.spark` report
(`:1011–1046`). The relevant stages are:

| Consumer | Source behavior | Capacity status |
| --- | --- | --- |
| Why proof-input JSON | Serializes a printing plan before launching gnatwhy3 | Composed node/list/occurrence/string/byte bounds already cover this input, separately for each process. |
| VC registration and entity VC sets | Every registration appends to `VC_Table`; nonwarning IDs enter the entity's set; Why-present registrations increment a Natural counter | Closed below for the current Main/fixed-library frontier. These are live before Why tables are freed. |
| Child-process bookkeeping | Each launch adds one PID/temporary-path pair; collection deletes it | Map cardinality bounded by that process's 1/2/3/0/0 launches. Command/path string lengths remain configuration inputs. |
| gnatwhy3 response parsing | `Parse_Why3_Results` passes the completed file to `GNATCOLL.JSON.Read_File`, materializes its JSON value, parses every result, then handles warnings/timings | Requires a source/configuration bound on backend response count, strings, nested check trees, counterexamples and aggregate JSON. The outgoing Why-input byte bound alone does not supply it. |
| Proof-message construction | Builds structured messages and appends them to `Proof_Msgs`; preserves each supplied `check_tree` | Response-dependent multiplicities/bytes and frontend message counters remain to be composed. |
| Assumptions/entity metadata | Maintains claim sets, a third symbol pool, a deduplicated subprogram table and JSON metadata | Some cardinality domains close below; lifetime interning calls, strings and final serialization remain explicit obligations. |
| Final `.spark` file | Creates the complete report object, calls `GNATCOLL.JSON.Write (Full, Compact => False)`, then passes the resulting String to Text_IO | Requires its own serialized String, JSON/container and Text_IO bounds. It is not the earlier Why AST serializer. |
| gnatprove's report collection and Silver's readers | Load `.spark` files and apply their own report policies | Separate processes/consumers; not established by this component. |

`Collect_One_Result` calls `Parse_Why3_Results`, deletes the temporary response
file, and removes the PID (`:243–268`). `Run_Gnatwhy3` may collect a result
**during** translation if its subprocess map reaches `Max_Subprocesses` or if
parallel Why3 is disabled (`:1235–1244`). The retained parallel configuration
and at-most-three launches exclude that interleaving for these processes;
changing that option requires revisiting the sequencing statement. No
claim that arbitrary GNATprove configurations serialize everything first is
needed. The current small file counts also bound every PID-map growth.

## Registered VC count is source-bounded

The complete source frontier has exactly two calls to `Register_VC`:
`New_VC_Labels` and `Emit_Static_Proof_Result`. The former has exactly three
consumers, each constructing a fresh `W_Label`, `W_Any_Expr` or `W_Variant`
(`why-gen-expr.adb:5314–5323`, `why-gen-progs.adb:135–147`,
`gnat2why-expr-loops.adb:2022–2037`). The registration occurs before its
constructor returns, but the final allocation envelope covers that fresh node
on every completed prefix. Distinct registrations therefore have distinct
charged fresh nodes. This is an **allocation-count** argument; it assumes
nothing about how often those program nodes later occur in serialized trees.

Static-result registrations need a separate reachability argument. The complete
inventory contains 23 direct `Emit_Static_Proof_Result` calls and two callers
of its `Emit_Always_True_Range_Check` forwarder. Their partition is:

| Static-result family | Why absent from admitted Main and the selected fixed bodies |
| --- | --- |
| Structural loop/subprogram variants and invalid recursive calls | Main has no variants or recursion; the selected library bodies have neither. |
| Unchecked unions, access-result accessibility, overlays, unchecked-conversion instances, allocating functions/allocators and access-to-subprogram termination | These constructs do not occur on the reviewed source frontier. Ordinary references to imported `System.Address` do not instantiate an unchecked conversion or generate its body. |
| Statically invalid empty aggregate | Main has no aggregate; the fixed Character-array aggregates use valid bounds and components. |
| Proved ordinary pragma checks | Main's only pragma is SPARK_Mode. The selected bodies contain four loop invariants but no ordinary Assert/Assume checks. The loop handler extracts the invariants and calls the **procedure** overload of `Transform_Pragma_Check`, then constructs `New_VC_Pred` (`gnat2why-expr-loops.adb:830–866`). It does not use the function overload's static-result branch at `gnat2why-expr.adb:28519`. |
| Always-true range/overflow check | Both forwarder callers explicitly require a floating-point type (`why-gen-expr.adb:2522–2608`; `gnat2why-expr.adb:25574–25618`). Integer/Character/C.int checks do not take them. |

Imported bodies are not executed or generated as VCs in Main; their declarations
do not add an ordinary assertion path. Fixed-library process bounds apply to
their actual bodies/specifications, not to arbitrary code using the same APIs.
Thus, for each of the five current process shapes:

```text
static registrations = 0
registered VCs <= B_N
Why-present registration increments <= B_N
each entity's VC set cardinality <= B_N
VC entity-map cardinality <= E_total.
```

Use the pre-import allocation bound for Main; imported/include nodes do not
carry a registration. The fixed process graphs already include every allocation.
`VC_Id` is derived from Natural (`gnat2why-error_messages.ads:37`), and
`Register_VC` increments a Natural and appends to an ordinary vector
(`.adb:1342–1364`). The existing `B_N <= 2^30-1` condition keeps the zero-based
VC vector's geometric capacity at most `2^30`, its index/length arithmetic
within the signed 32-bit base (`gcc/ada/libgnat/a-convec.adb:205–230,1884–1917`),
and its hash sets below the checked
1,610,612,741 hashed-container endpoint. The ordinary vector's fixed-size
record backbone has 64-bit allocation arithmetic; its Check_Info-owned
strings/continuations retain their separate object bounds. Entity-map capacity
is already covered by the source/entity domain condition. The composition
now reports these cardinalities explicitly.

This does not prove that the response contains exactly one JSON record per
registered ID. Backend splitting/merging and warning results must supply that
separate multiplicity. A registration bound is not a response-byte bound.

## Assumptions have their own symbol pool and container domains

The earlier pool formulas concern `Why.Gen.Names` and `Common_Containers`.
`Assumption_Types.Symbol_Table` is a **third** allocated GNATCOLL pool
(`common/assumption_types.adb:33`). `Mk_Base_Sloc` interns a source filename;
`Mk_Subp` interns the full source name and hash-conses its `(name, location
chain)` record (`:183–201`). `Mk_Unit` is not called from gnat2why. Consequently
the earlier Why/Common call counts cannot be reused for this allocator.

`Entity_To_Subp_Assumption` supplies one stable record per entity: its
`Full_Source_Name` and source/instantiation-location chain
(`spark_util.adb:1917–1951`). References to the same entity do not create a new
distinct name or location chain, but they **do** call Find again before the
hash-cons lookup. Let `N_subp` count such entity-record requests, `h_inst` bound
their location-chain length, and let `K_assume` cover fixed/null initialization
or any other reviewed constructors. The direct transfer is

```text
F_Assumption <= K_assume + (h_inst+1) N_subp.
```

Its distinct-name domain consists of entity full names and configured source
filenames. The same existing GNATCOLL conditions apply: lifetime nonempty Find
calls at most `2^31-1`, distinct strings within the checked hash bound, and each
String/intermediate representable. The bound must include requests from flow,
timings, result messages, assumption serialization and final entity tables.
The currently retained Why/Common intern observations did not measure this
pool, and no measurement is substituted for its missing caller sum.

`Assumption_Types.To_JSON` deduplicates subprogram records in `Subp_Map` and
`Subp_Vector` (`:266–275`). The domain is at most the number of distinct entity
records, plus any separately counted fixed/null records. Its printed entity
table contains one entry per such record; each entry has one name and its
location-chain array (`:74–87,282–303`). This is a source/configuration domain,
not a function of the number of solver attempts.

`Claim_Kind` has five values (`common/assumptions.ads:36–37`). Therefore each
claim map/set and each set of assumptions has at most `5 E_total` keys.
`Get_Assume_JSON` makes at most that many rules and at most `(5 E_total)^2`
token occurrences when all sets are serialized (`gnat2why-assumptions.adb:85–103`).
The actual Main/fixed call graphs allow much sharper sparse bounds, but the
cardinality argument already covers each individual hashed container via the
existing `160 E_total` condition. It does not treat the quadratic serialized
token bound as an already useful complete report envelope.

## Response, diagnostic and final-report obligations

The exact response path is `gnat2why-error_messages.adb:543–1336`, through
`common/call.adb:132–142` into GNATCOLL.JSON. `Handle_Result` constructs its
parsed result and counterexample list **before** the guard that skips RAC for
a proved result (`:841–880`). A successful VC alone therefore does not justify
ignoring response JSON, supplied check trees or parsing allocations. Under a
verified empty-counterexample response premise, those list/map domains are
empty; without that premise they must be charged. The fixed RAC fuel is an
execution-control value, not a bound on all the JSON or interpreter objects.

The remaining interface should supply source/configuration-derived bounds on:

- Result and warning counts, including repeated/split kinds for one VC ID.
- Per-response and total response bytes, JSON values/object fields/array
  lengths, maximum string length and nesting; prover-statistic and timing
  entry counts and their numeric/string encodings.
- Retained check-tree and counterexample shapes, plus any RAC/diagnostic
  objects enabled by the selected options or triggered on failure.
- Flow/SPARK/skip/pragma-assume records, proof-message continuations and names,
  assumption requests, message-ID increments and GNATCOLL hash-cons/reference
  counters through final output.

These are potentially derivable transfers from the already bounded Why graph,
source/frontend domains and exact backend configuration. They are **not yet
derived by this record**. An actual response file's measured size is not a
source admission predicate, and arbitrary coefficients must not replace the
missing backend/schema transfer.

`Error_Msg_Proof` skips failure explanation/fix generation on its all-proved
Info path, but still constructs and appends the message
(`flow_error_messages.adb:889–1007`). Failure fixes call
`Get_Filtered_Variables_For_Proof`, which interns the heap name in the Common
pool (`:1604–1614`); those calls and diagnostic traversal allocations are not
part of the earlier Common prefix allowance. If the complete-process contract
includes failed solver runs, that extension must be composed explicitly. If
it is restricted to all-proved runs, state the restriction and still cover
all eager parsing and successful message construction.

`Add_Json_Msg` copies/preserves `check_tree`, statistics, source locations and
message fields into `Proof_Msgs` (`utils/errout_wrapper.adb:76–190`). Final
`Create_JSON_File` joins those arrays with flow/SPARK status, skip lists,
assumptions, timings and the entity table, then materializes one pretty JSON
String (`gnat2why-driver.adb:351–383`). Consequently:

1. The Why-schema byte sum does not bound `.spark` bytes; the report uses a
   different schema and serializer and can contain backend-produced trees.
2. Clearing Why tables does not free or bound those response/report objects.
3. Silver's later `check_tree` projection cannot prevent a producer-side
   JSON/String failure that occurs before the file is written.
4. Reporting-only classification requires the separate assurance argument
   described by [the capacity contract](retained-tool-capacity.md#producer-limits-and-correspondence).
   Generation precedes collection in this configuration, but that ordering
   alone does not establish complete automatic discharge or a reliable
   incomplete-confirmation diagnostic. Existing strict report/audit checks
   remain required for a claim that confirmation completed.

The next producer step is the response/report interface and its scalar/String,
container and counter implementation bounds, including the third intern pool.
The current arithmetic checker deliberately continues to say **producer core**.
There is no complete-process or whole-#119 completion claim.

Reproduce the retained source frontier, without native execution:

```sh
python3 docs/evidence/retained-producer-tail-20261018/check.py
```
