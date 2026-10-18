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

## Reporting phase separation

Response parsing remains in the required chain. `Collect_One_Result` waits for
one child and parses its response before waiting for the next; it is not an
all-children barrier. Per-unit `.spark` output follows collection for that unit,
but other units can still be running. After GPRbuild returns, GNATprove kills
the proof-server process tree (`gnatprove.adb:625–676`). Consequently neither
an in-process parse failure nor a per-unit write failure is automatically an
observation-only event under [#88](https://github.com/berkeleynerd/silver/issues/88).
Generation-before-collection alone does not establish independence of discharge.

The separate `spark_report` executable is later: all phase2 work has returned
and server cleanup has occurred before it starts. Its percentage calculation
`100 * Part` in Integer (`spark_report.adb:315–317`) is summary-only; the first
part exceeding the reviewed 32-bit multiplication domain is 21,474,837. This
is a source-derived boundary, not an observed failure or an admission cap.
However, the reporter runs on both the normal and recoverable-failure paths
(`gnatprove.adb:1314–1330`). Its control file's `has_errors` field is normally
deleted, its summary log also appears on failures, and its per-file exception
handler prints a generic skipped-file message (`spark_report.adb:743–764`).
No completed reliable detector for that boundary is established here. #88
must identify the exact failed operation and preserve earlier/independent
defects; a generic reporter failure remains status 3. There is no reason to
turn this late formatting arithmetic into a source restriction merely because
it uses Integer.

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
separate multiplicity. The response-source record below supplies a finite key
domain; a registration bound remains distinct from a response-byte bound.

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

The [response-source evidence](../evidence/retained-producer-response-20261018/identity.json)
adds the SPARK candidate's Why3 gitlink
`9390baf120ef260547dfa14f08e11c890b203d9c`, selected installed command/driver
bytes, and source at the retained solver versions. These are explicit source
behavior premises, not historical installed-binary/source attestations. Its
[offline checker](../evidence/retained-producer-response-20261018/check.py)
checks source identities and the scalar arithmetic below without executing a
native tool.

`Gnat_report.msg_set` is keyed by `(id, check_kind)` and rejects duplicate
registration (`gnat_report.ml:59–86`; `gnat_expl.ml:183–186,650–655`). The kind
domain has 65 constructors. Under the existing label-ID correspondence premise,
the coarse response-result bound is therefore `65 * registered_VCs`, not a
bound on tree nodes. Splitting can leave several top-level goals in one result.
The later [combined check-label derivation](retained-producer-response.md#registered-ids-bound-result-records-without-a-kind-domain-product)
removes this unnecessary kind-domain product: per response,
`R <= V + 2*V_loop <= 3V`, and ordinary Main has `R <= V`. The
[concrete null and literal-output Main paths](retained-producer-zero-check-sources.md)
register no Why3 check and launch no Main backend, so their Main counts are
exactly `G = R = 0`. The five fixed output-library responses remain separate;
their [source-derived task calculation](retained-producer-fixed-paths.md)
now gives combined `G <= 2981` and `R <= 51`, with warning and string terms
still explicit in the response-size account.
The [selected-driver diagnostic transfer](retained-producer-diagnostic-strings.md)
reduces answer strings and consecutive-answer warnings to a linear function of
captured solver-output bytes; that output domain and other warnings remain open.
The [startup context and clone-warning account](retained-producer-import-context.md)
now closes one of those warning families and records the full configured
driver/file closure, including the unselected drivers loaded at startup.
`Gnat_report.register` gives every Proved result an empty counterexample list
(`gnat_report.ml:62–69`), independently of old models in the session; that
closes the eager counterexample-list domain for the all-proved path. Failure
paths still need the selected counterexample/session premise.

### Statistics narrowing and preferred configuration repair

There is a scalar narrowing before `.spark` output: `Prover_Stat.Count` and
`Max_Steps` are Natural and are read directly from JSON
(`vc_kinds.ads:1290–1294`, `.adb:1203–1210`). Selected commands retain statistics
with `--steps=0`: CVC5 uses `--stats-internal`, Z3 uses `-st`, and the selected
Alt-Ergo driver reads the steps on its ordinary Valid result. Why3 parses those
decimal counts using OCaml `int_of_string` and back-converts with
`max(0, raw-add)/mult + 1` (`call_provers.ml:120–127`,
`gnat_config.ml:577–625`). There is no saturation at Ada Natural'Last.

| Prover | First raw count whose normalized value is 2,147,483,648 | Source domain |
| --- | ---: | --- |
| Alt-Ergo | 2,147,483,647 | OCaml int counters in 2.6.1 `steps.ml:42–43,87–129,185–186`. |
| CVC5 | 75,161,942,645 | `resourceUnitsUsed` references a uint64_t in 1.3.2 `resource_manager.cpp:104–113,165`; cumulative count is uint64_t. |
| Z3 | 1,717,987,367,600 | 4.15.4 `reslimit.m_count` is uint64_t, even though its configured limit argument is unsigned32. Large statistics convert to double and print fixed decimal notation; the selected regexp reads the integer prefix (`statistics.cpp:97–137,225–245`). |

Each value fits the Why3 signed63 domain on this host; each Z3 value here is
also exactly representable as double. Thus selected output types/configuration
alone do not exclude this narrowing. This is not evidence that an admitted
program actually consumes that much solver work. No finite timeout or step cap
is proposed to make the statistics fit.

**Prefer a private driver configuration that omits step-count parsing.** This
supersedes the output adapter below as the first proposed #88 repair. The
retained [candidate configuration](../evidence/retained-producer-response-20261018/proposed-driver-overlay/why3.conf)
has no prover overrides. Alongside it, four private driver snapshots differ
from the installed files only by deleting six `steps` directives: one in
`cvc5_gnatprove.drv`, two in its imported `cvc5.gen`, one in `z3_gnatprove.drv`
and two in `alt_ergo_gnatprove_smt2.drv`. The offline checker verifies the exact
deletions and the complete 14-file import closure. They are research fixtures,
not installed or executed configuration.

GNATprove passes `--why3-conf` through (`configuration.adb:3249–3253`). Although
gnatwhy3 rejects attempts to redefine built-in prover records
(`gnat_config.ml:283–290`), it resolves each built-in driver beside the extra
configuration before its installed fallback (`gnat_util.ml:63–106`, called
from `gnat_config.ml:354–355`). Imported files prefer their importing file's
directory before the installed driver directory (`driver_lexer.mll:126–133`).
Thus a private copy of `cvc5.gen` is selected with its private parent. The
effective working directory must contain no competing same-named drivers;
the selected files and imported dependency bytes belong in configuration
identity. External executables and installed files remain unchanged.

With no `StepRegexp` in any selected driver/import, `grep_steps` returns None
without parsing a numeric substring. Why3 stores `pr_steps = -1`
(`call_provers.ml:120–127,358`); the existing back-conversion turns that into
`1` for the three real solvers. **That `1` means unavailable step statistics,
not one measured step.** Synthetic Trivial/Checker records retain their own
existing conventions. Preserve the `--steps=0` configuration: the only use of
the parsed count in result classification is guarded by `stepslimit > 0`
(`:361–370`). All result/error/resource regexps, exit mappings, task
transformations, solver commands and resource settings are byte-preserved.
Counts of goals and measured times remain available. No new timeout, step cap,
proof suppression or alternative obligation set is introduced.

The switch requires a **new private confirmation session namespace** at
adoption, preserving old workspaces as evidence. Why3 can otherwise reuse a
nonobsolete attempt's old `pr_steps`: the same prover identity and unchanged
task do not mark an attempt obsolete solely because its statistics regexp
changed (`gnat_main.ml:134–145`, `gnat_checks.ml:381–453,769–801`). Subsequent
reuse is limited to sessions created under the selected configuration; do not
import old sessions into that namespace. This is ordinary proof-workspace
isolation, not language-version compatibility machinery. #88 must implement
the configuration selection/identity, retain the unavailable-statistic meaning,
and validate actual driver resolution and old-session separation before relying
on it. The source argument and offline diff do not replace that validation.

### Fallback: a narrow verified output adapter

The protocol has a finite repair using verified Silver-owned code, without
changing external tools. `Parse_Why3_Prove_Result` explicitly accepts missing
`stats` and supplies an empty map (`gnat2why-error_messages.adb:1255–1258`).
Proof bookkeeping uses Id, Kind, Proved and entity independently of Stats
(`:338–390`); the map only flows to diagnostic/report construction. Under
`--report=all`, `Stat_Message` does not print it
(`flow_error_messages.adb:782–799`). Empty statistics are omitted from `.spark`
(`errout_wrapper.adb:185–187`), and `spark_report` still counts the proof result
while conditionally skipping statistics processing (`spark_report.adb:690–714`).
Current native and Python success policies do not require the optional stats
field. No pinned gnatwhy3 option to omit its successful-result statistics was
found; the reviewed producer emits them unconditionally.

If the configuration route cannot be validated, the fallback is a
**statistics-only output projection** at the existing gnatwhy3 adapter boundary:

- Capture the unchanged native child's complete response and status, retain
  the raw response, and replace only a structurally validated immediate
  `results[*].stats` value with `{}` before gnat2why consumes it. Never clamp
  a number or invent a proof result.
- Preserve every other field and value, especially result/id/kind/entity,
  `check_tree`, `unproved_status`, errors, warnings, counterexamples and proof
  coverage. Retain raw statistics for diagnostics; successful confirmation
  still uses the complete required audit and unsuccessful classification
  still uses original leaf evidence.
- Fail closed on malformed input, ambiguous/duplicate fields, unsupported
  schema or native failure. Capturing merged stderr must not turn an invalid
  native stream into a valid success response. Propagate native completion,
  interruption and errors through the explicit #88 process/status interface.
- Verify a bounded-storage streaming implementation in SPARK, prove that the
  projection changes only the permitted optional field, connect that proof to
  actual source, and independently review the interface and malformed-input
  policy. Allocation/read/write failures remain operational outcomes; the
  adapter must not interrupt the native solver because of its own fixed
  buffer limit.

This fallback is a proposed design, **not an implemented or verified adapter**. It
prevents the coupled Natural narrowing; it does not excuse that narrowing as
an observation-only failure. It preserves prover commands, required work and
all proof outcomes. Native response construction before projection, check
trees, timings, warnings, final `.spark` output and all other producer domains
still need their bounds. Statistics magnitude is consequently a scoped
implementation dependency, not a demonstrated impossibility of the capacity
direction.

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
The [response-schema transfer](retained-producer-response.md) now supplies
conditional byte/container bounds, closes the fixed timing-name domain, and
identifies narrow downstream projections and the separate clock interface.
Its source-to-leaf, diagnostic-string and final-report joins remain unfinished.
The current arithmetic checker deliberately continues to say **producer core**.
There is no complete-process or whole-#119 completion claim.

Reproduce the retained source frontier, without native execution:

```sh
python3 docs/evidence/retained-producer-tail-20261018/check.py
```
