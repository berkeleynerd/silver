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
compilation units. It excludes configuration files and the unanalyzed System
dependency. The selected null Main has no with clauses or runtime operations
that analyze another unit. Its empty declaration list and null/pragma body
introduce no additional scope. `Register_Flow_Scopes` gives Standard two
vertices, Main a spec and body vertex, and one Main hierarchy-map entry. The
constructor for Main's hierarchy identifies Standard as its parent and has
no template, instance parent or nested container
(`gnat2why-driver.adb:644–680,781–793`; `flow_visibility.adb:484–660,855–951`).
Thus each phase's entity visibility graph has **four vertices**, at most
16 distinct directed edges, four SCC numbers and adjacency maps of at most
four entries. Phase 2's name visibility graph independently reconstructs the
same four-vertex domain (`flow_generated_globals-phase_2-visibility.adb:
352–423,634–700`). Graph copies do not share a total-node counter.

The phase-1 traversal tree has Main as its sole entry, no children and no
constants. `Write_Contracts_To_ALI` consequently executes once. Its global
and call sets are empty; locks, task accesses and source objects are absent.
`GG_Register_Flow_Scope` executes once for Main. The source constructor and
all conditional finalization cases therefore produce these five GG rows:

| Kind | Nonempty entity payload | Maximum line bytes, excluding LF |
| --- | --- | ---: |
| `EK_DIRECT_CALLS` | Main; empty call set | 25 |
| `EK_PROOF_DEPENDENCIES` | Main; empty dependency set | 31 |
| `EK_GLOBALS` | Main; empty parents/global/call/task sets and Boolean properties | 288 |
| `EK_FLOW_SCOPE` | Main and `__standard`; five Boolean properties | 62 |
| `EK_END_MARKER` | none | 16 |

`Unique_Name` returns the four-byte canonical Main name: no homonym exists,
and a subprogram whose scope is Standard gets no parent prefix
(`sem_util.adb:30080–30193`). Case/trivia cannot lengthen it. The fixed
`__standard` spelling comes from `phase_1-write.adb:46–53`. Boolean images
have at most five bytes, and the empty-set count is one `0` byte. This is a
size envelope; the checker deliberately uses the longer Boolean image for
every property instead of claiming each property is false. The five rows
occupy **at most 427 bytes including their LF terminators**. The separate QQ
version header occupies `16+V_version` bytes including LF, where V_version
is the configured fixed tool-version string length. This parameter is a
tool-build input, not a source-program-dependent term.

The complete emission frontier is `phase_1.adb:139–199,387–493,670–846` and
`partial.adb:1958–2001,2693–2740`. Ghost annotations, abstract states, volatile
objects, protected/task entries, constants and special initialization objects
have no members; their conditional extra rows do not execute. In particular,
Standard's special visibility vertices do not create a Standard hierarchy
entry for `Iterate_Flow_Scopes` to serialize.

The phase-2 GG line reader copies a whole line, skips its three-byte prefix,
and advances `Token_Start` to `Last+1`. Hence its selected buffer is at most
285 bytes and its cursor at most 286; no GG token is longer than the longest
fixed label (the checker computes it), and entity-name tokens are at most
ten bytes. Every parsed list count is zero. `GG_Resolve` does read the other
ALI lines with `Text_IO.Get_Line`; the **non-GG frontend ALI envelope remains
a separate join**, as do its generic `Scan_ALI` tables. The five-row result
does not substitute for that envelope.

The selected GG-derived structures have the following distinct domains:

| Structure | Maximum elements |
| --- | ---: |
| Phase-1 scope tree / contract map | 1 each |
| Phase-2 traversal tree | 2 (Standard and Main), one child edge |
| `Phase_1_Info` / `Global_Contracts` after synthetic Standard insertion | 2 each |
| Direct-call / proof-dependency map | 1 key each, empty values |
| Name hierarchy / Children map | 1 key each; Standard's child set has Main |
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
(`:1184–1245`). Its derived call graphs start from Main and have no callee,
with'ed package or protected-operation edges (`:743–1176`). Closure can
therefore add no distinct key or source-dependent iteration count.
These are independent per-container bounds. The existing fixed-context
name-pool charge continues to cover elaboration names and Standard metadata;
the GG reader does not introduce arbitrary program text into those pools.

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
