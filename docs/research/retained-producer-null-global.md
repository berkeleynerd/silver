# Null-family global metadata and ordinary report consumers

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This continues the [null storage analysis](retained-producer-null-storage.md)
for the same 15-token family with permitted ASCII case, whitespace and comments.
The source and location conditions remain those of the frontend derivation.
No new source, path or aggregate-memory gate is selected. The
[evidence](../evidence/retained-producer-null-global-20261018/README.md) pins
the complete sources and checks the following arithmetic offline.

## Flow scope and generated-global records

`GNAT_To_Why.Process_All_Units` explicitly visits Standard, then analyzed
compilation units. Although null Main has no authored with clause, GNATprove
mode calls `SPARK_Implicit_Load(RE_Interrupt_Priority)` for parameterless Main
(`sem_ch10.adb:1408–1445`). That calls RTE, which loads and semantically
analyzes System and inserts an implicit with clause
(`rtsfind.adb:1102–1208,1261–1333,1562–1639,1856–1863`). This differs from
ordinary native compilation's potentially unanalyzed System checksum dependency.
The initial version of this packet incorrectly transferred that native-only
exclusion to the producer; the counts below correct it.

The selected System specification has one package and five intrinsic Address
comparison declarations. Its types have no DIC/invariant, nested package,
subprogram body or task/protected declaration. The implicit inequality for its
explicit equality is inserted, analyzed and **removed** before this traversal
(`sem_ch6.adb:11359–11436`). Its scalar declarations/freezes and the selected
SPARK rewriting do not add another retained scope declaration. Visibility
traversal walks declarations/statements, not all entities in the entity chain
(`flow_visibility.adb:955–1240`). System's fixed source is retained in the packet.

`Register_Flow_Scopes` consequently gives Standard two vertices, Main two,
System three and the five comparison functions two each: **17 vertices**,
at most 289 distinct directed edges and seven hierarchy-map entries. Main
and System have Standard as parent; the operators are nested in System's
visible part (`gnat2why-driver.adb:644–680,781–793`;
`flow_visibility.adb:484–660,855–951`). Phase 2's name graph reconstructs the
same domain from GG records (`phase_2-visibility.adb:352–423,634–700`). Each
adjacency set/map has at most seventeen entries; copies have independent counters.

The phase-1 traversal tree has Main as its sole entry, no children and no
constants. `Write_Contracts_To_ALI` consequently executes once. Its global
and call sets are empty; locks, task accesses and source objects are absent.
Unlike that contract traversal, `Iterate_Flow_Scopes` visits all seven
visibility hierarchy entries (`flow_visibility.adb:1243–1255`). The source
constructor and conditional finalization cases produce eleven GG rows:

| Kind | Nonempty entity payload | Maximum line bytes, excluding LF |
| --- | --- | ---: |
| `EK_DIRECT_CALLS` | Main; empty call set | 25 |
| `EK_PROOF_DEPENDENCIES` | Main; empty dependency set | 31 |
| `EK_GLOBALS` | Main; empty parents/global/call/task sets and Boolean properties | 288 |
| `EK_FLOW_SCOPE` | Main and `__standard`; five Boolean properties | 62 |
| `EK_FLOW_SCOPE`, once | System and `__standard`; five Boolean properties | 64 |
| `EK_FLOW_SCOPE`, five times | System comparison name, System container and `VISIBLE_PART` | 90 each |
| `EK_END_MARKER` | none | 16 |

`Unique_Name` returns the four-byte canonical Main name: no homonym exists,
and a subprogram whose scope is Standard gets no parent prefix
(`sem_util.adb:30080–30193`). Case/trivia cannot lengthen it. The fixed
`__standard` spelling comes from `phase_1-write.adb:46–53`. Boolean images
have at most five bytes, and the empty-set count is one `0` byte. This is a
size envelope; the checker deliberately uses the longer Boolean image for
every property instead of claiming each property is false. A System comparison
name uses at most 23 bytes, charging `system__Oxx` plus even a full ten-digit
homonym suffix. The eleven rows occupy **at most 947 bytes including LF**.
The separate QQ version header occupies `16+V_version` bytes including LF, where V_version
is the configured fixed tool-version string length. This parameter is a
tool-build input, not a source-program-dependent term.

The complete emission frontier is `phase_1.adb:139–199,387–493,670–846` and
`partial.adb:1958–2001,2693–2740`. Ghost annotations, abstract states, volatile
objects, protected/task entries, constants and special initialization objects
have no members; their conditional extra rows do not execute. In particular,
Standard's special visibility vertices do not create a Standard hierarchy
entry for `Iterate_Flow_Scopes` to serialize. System contributes scope rows,
not another generated Main contract. The previously retained null probe's
`main.ali` already records exactly these seven scope rows and the implicit
System dependency; it corroborates this correction without a new run.

The phase-2 GG line reader copies a whole line, skips its three-byte prefix,
and advances `Token_Start` to `Last+1`. Hence its selected buffer is at most
285 bytes and its cursor at most 286; no GG token is longer than the longest
fixed label/entity-name envelope (the checker computes it), and entity-name
tokens are at most 23 bytes. Every parsed list count is zero. `GG_Resolve`
reads the other ALI lines with `Text_IO.Get_Line`; the **non-GG frontend ALI
envelope remains a separate join**, as do its generic `Scan_ALI` tables. The GG result
does not substitute for that envelope.

The selected GG-derived structures have the following distinct domains:

| Structure | Maximum elements |
| --- | ---: |
| Phase-1 scope tree / contract map | 1 each |
| Phase-2 traversal tree | 2 (Standard and Main), one child edge |
| `Phase_1_Info` / `Global_Contracts` after synthetic Standard insertion | 2 each |
| Direct-call / proof-dependency map | 1 key each, empty values |
| Name hierarchy | 7 entries (Main, System and five comparisons) |
| Children / Nested map | 1 key each; Standard's children are Main/System, System's nested set has five comparisons |
| Per-fold patch list and recursive scope depth | 2 each |
| Main task-instance map and its object list | 1 each; instance count 1 |
| Subprogram, proof-module, lemma-module, tasking and priority call graphs | 1 vertex each; no call edge |
| Constant, protected-operation and state/object graphs/sets | 0 |

`GG_Resolve` explicitly inserts synthetic Standard records before folding,
so claiming all its maps have one entry would be incorrect. `Do_Global`
skips the leaf Main fold, then folds the two-node Standard tree once; empty
sets remain empty and its patch list has at most two entries
(`phase_2.adb:2533–2703,3018–3072`). `GG_Complete` represents Main as an
environment task even though the source declares no task; it uses Main's
existing entity name and one object with instance count one
(`:1184–1245`). Its derived call graphs start from Main and have no callee
or protected-operation edges. The priority graph's Top_Level_Packages comes
from package EK_Globals records, not the frontend implicit-with list; System
adds no such record (`:743–1176,1734–1741`). Closure can
therefore add no distinct key or source-dependent iteration count.
These are independent per-container bounds. The existing fixed-context
name-pool charge continues to cover elaboration names and Standard metadata;
the GG reader does not introduce arbitrary program text into those pools.

The implicit with also causes generic `Scan_ALI` to read the installation's
fixed `system.ali`. The retained selected input has no with/QQ/GG rows and
five invocation-construct records. It therefore adds no global contract or
GG hierarchy entry; it does add fixed generic ALI table populations, which
belong to the remaining generic-reader join. Its file identity and inventory
are now retained alongside the System specification. The GG reader safely
leaves its parsing state Before for a file with no GG section
(`phase_2.adb:1979–2024`).

## Effect of the System correction on earlier components

The correction changes the explicit whole-unit visibility/GG account above.
It does not invalidate the imported fixed-frontend/Why allowances. The
[fixed frontend reduction](retained-main-semantics.md#fixed-light-roots-and-first-freeze-reduction)
already includes analyzed System among its fixed roots and retains the complete
witness Main, including implicit loading/with creation. Its `A_fixed=12784`
and fixed maps were measured through the complete light frontend; the source
argument separately charges Main scope saves when System loads later. This
paragraph clarifies that Interrupt_Priority can force that load before the
marker's Default_Priority request. No second System declaration analysis is
added when the entity is already loaded.

The [fixed producer envelope](retained-producer-fixed.md#selected-imported-dependencies)
and its [composition](retained-producer-composition.md#fixed-imports-can-remain-paid)
retain all five API witness contributions even for zero-API Main. Their
parameterless Main roots take the same implicit-System load, and the retained
null baseline's phase-1 ALI explicitly contains its System scopes. The source
reduction already includes fixed imported entities/cache fills, so System's
fixed declaration/operator roots are not new unpaid Why nodes or module-map
entries. This is a transfer under the existing isolated-root/cache premises,
not an extrapolation from the corrected seventeen-vertex graph.

`Build_Flow_Tree` and `Mark_Current_Unit` use Process_Current_Unit rather than
Process_All_Units (`gnat2why-driver.adb:685–713`). Thus the Main contract tree
remains one entry and the phase-2 contract fold remains Main plus synthetic
Standard. Imported System entities fail Analysis_Requested, so they add no
Main VC, `.spark` reported entity, claim, source flow message or entity timing.
Marking an implicit with visits only package initial conditions, absent in
System; Main's priority marking requests only priority types/constants, not
the package's comparison subprograms (`spark_definition.adb:4289–4307,
14100–14125`). Those imported type/object entries do not add a subprogram
call-graph vertex.
The [Main report shape](retained-producer-null-tail.md), local CFG bound89,
zero gnatwhy3/solver launches and ordinary-report/SARIF entity counts remain
unchanged. Generic ALI parsing and all-unit visibility are explicitly different
consumers and must include the System entries just identified.

## Data representation JSON

GNATprove's data-representation phase uses a separate native invocation with
`-S -gnatR2js -gnatws -gnatx -gnatis` (`gnatprove.adb:298–319`). The `R2js`
switch sets representation level two, JSON format and file output. It leaves
mechanism output false; only `m` would enable that
(`switch-c.adb:1236–1299`; `opt.ads:984`). `Repinfo.List_Rep_Info` visits units
in the extended Main source and brackets each file's entries. Null has one
Main unit, no source type, object, formal, nested scope or block to list.
Compiler-generated child entities are excluded by the Comes_From_Source
test at level two; `-gnatdA` and level four are absent. Main itself gets no
subprogram-mechanism entry (`repinfo.adb:493–632,1910–1982`).

Thus the sole selected `main.adb.json` consists exactly of `[` LF `]` LF:
**four bytes and zero data entries**, for the whole case/trivia family.
`Write_Info_Line` removes the output package's final LF before forwarding;
`Osint.Write_Info` writes one LF again. File close adds no data
(`repinfo.adb:2556–2559`; `osint.adb:3255–3259`;
`osint-c.adb:136–147,270–280,518`). Each line is only one payload byte, so its
output counters and String slices are constant-sized.

`Read_Data_Decomposition_JSON_File` ignores units without a compilation unit,
probes existing representation files, and records a filename only after a
successful parse. Only Main's four-byte array exists in the selected fresh
data-representation directory. The producer's analyzed System dependency has
no representation file. Therefore its File_Names set has one entry, the JSON
array has no element, and `Data_Decomposition_Table` stays empty. `Handle_Entry`
and its `UI_From_Integral` field conversions execute zero times
(`gnat2why-data_decomposition.adb:155–271`). No path, location or source-text
string enters the data table.

This closes the data file's writer/consumer storage, not the entire alternate
native invocation. `-gnatR2js` also enables `Back_Annotate_Rep_Info`; its effect
on native gigi/representation callbacks must be included in the native
capacity argument. Ordinary native-build flags alone do not establish that
variant's callback allocation bound.

## Configuration and ordinary report consumption

The selected project has one source and one object directory, no imported
project, and no Prove attributes. `Generate_SPARK_Report` builds `obj_dirs`
with one element and `cmdline` with 15: `gnatprove`, the 14 arguments in
`src/silver.adb:117–123`, including the project path once. It builds an empty
`proof_switches` object, mode `GPM_ALL`, and two Boolean status fields.
There are no `--assumptions`, `--output-header`, quiet or limit switches.
`GNAT.Command_Line.Define_Switch` initializes these Boolean options to the
opposite of its default True setting, so omitted switches leave them false
(`g-comlin.ads:640–655`; `configuration.adb:818–822,918–921`).

Let P bound both generated paths. The six-field configuration is a depth-two
JSON tree with a longest array of 15 and vector capacity at most 16. Its
compact serialization, final Text_IO LF, escaped paths, fixed arguments and
command-line joining arithmetic give **`313+12P` file bytes**. In particular,
the joined command contains **at most `181+P` bytes**: 167 fixed argument
bytes, 14 separating spaces, and the project path. Configuration JSON and
Main's `.spark` file both fit GNATCOLL's 64 KiB small-file branch when
evaluated at Silver's existing P<=4096 domain. The reader allocates their
actual file length in that branch (`gnatcoll-buffer.adb:299–333`); it does
not grow a source-length-dependent stream window.

The configuration uses the same unique-parent construction discipline as
the producer report. Larger array length increases its vector capacity but
not the number of simultaneously live copies of one element: the raw array,
embedded copy, old/new vector storage and local/result handles retain the
same eight-reference envelope. Parser depth remains below the initial 32
states. Its previous 42-reference budget plus four wrapper/caller return
handles bounds the `Read` / `Read_File` / `Read_File_Into_JSON` chain by 46.
After parsing, the selected `Get`/`Map_JSON_Object` consumers keep no JSON
collection in the report database; their parent edge, raw-array copies,
callback temporary, at most two forwarding return temporaries and two named
locals fit eight live references. The separately retained configuration tree
shares no aggregate with the parsed Main report.

The fresh selected object directory contains one `.spark` file. The ordinary
report pass parses it once, and the later SARIF pass parses it once again;
the first local JSON tree has gone out of scope before the second parse.
Each pass reconstructs the single entity with one location component.
`Parse_Entity_Table` clears the prior entity map/vector and replaces index
one. The two parses make four Assumption_Types Find calls; `Mk_Unit("main")`
adds one. Thus this executable has **five Find calls, at most three distinct
strings and one hash-consed Main record**, with one-element entity map/vector.
The unit name and displayed Main name may have different case and are
charged independently. Neither timing leaf is interned by these consumers.

The report database contains one unit, one subprogram and one subprogram-to-
unit mapping. Ordered output temporarily creates one-element sets. All check,
prover, suppressed-message and Assume collections stay empty; all check and
summary counters stay zero. Assumption-rule importing/search is disabled by
the selected command, even if the producer emits its conservative two-claim
envelope. No division or `100*Part` executes in percentage formatting when
Part is zero. The table has 12 rows, six columns, 72 cells, maximum cell
length 22 and maximum row width 78; cursor values remain at most 13 and 7
(`report_database.ads:117–153`; `print_table.adb:34–213`). Text output uses
bounded cells and one Main location with at most ten line digits; it does
not read or quote the source trivia. The checker reconstructs the ordinary
text output envelope and its longest line, including Text_IO terminators.
The complete ordinary output is at most `1719+P` bytes and its longest line
at most `121+P` bytes. At P=4096 the configuration is at most 49,465 bytes and
the ordinary report at most 5,815 bytes.

The SARIF call is unconditional (`spark_report.adb:1576–1580`). Its result
vector is empty for null; the [SARIF/VSS join](retained-producer-sarif-capacity.md)
separately bounds its fixed rule descriptors, invocation, typed vectors and
output writer. These transfers do not establish complete report-executable
feasibility. Generic project
loading/process orchestration, non-GG ALI data, native compilation and the
remaining fixed startup representations also remain separate. #119 is open.
