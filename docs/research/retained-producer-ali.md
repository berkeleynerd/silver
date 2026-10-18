# Null-family generic producer ALI capacity

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This continues the [global metadata packet](retained-producer-null-global.md)
for the complete 15-token null family, including permitted ASCII case and
trivia. It closes the **conditional generic ALI equations**, with production
GPR-generated compiler arguments and configuration inputs still explicit.
It is not a complete null-pipeline capacity result or an admission change.
The [evidence checker](../evidence/retained-producer-ali-20261018/check.py)
uses retained sources and offline Python only.

## Selected writer and reader frontier

In GNATprove mode `gnat1drv.adb:1492–1502` calls
`Write_ALI(Object => True)` before the proof backend so that phase 1 can append
QQ/GG records. The translation phase disables that output; its prescan reads
the phase-1 ALI. `Prescan_ALI_Files` initializes ALI tables, reads and scans
Main, frees its text buffer, then calls `Read_Withed_ALIs`
(`gnat2why-driver.adb:470–501`). The latter reads each unseen with dependency,
frees its text buffer before recursion, and records previously scanned names
(`ali-util.adb:173–266`).

The implicit System dependency established in the global packet means there
are **two ALI reader inputs**, generated Main and installed System. System has
no W/Y/Z dependency, so recursion depth is at most two, and the two file buffers
are not simultaneously live. The pinned installed `system.ali` is 2,428 bytes,
95 lines, with maximum line length 67 excluding LF. It contains one U, one D,
ten A records (72 payload bytes, maximum 14), five invocation constructs and
no invocation relations, QQ or GG records.

Main's generic invocation graph is empty for a source reason, independent of
the retained example: `Invocation_Graph_Recording_OK` returns False immediately
in GNATprove mode (`sem_elab.adb:12228–12252`). The normal recording entry honors
that guard (`:12959–12986`). Main therefore emits the single `G a Z` attribute
row and no `G c` or `G r` rows. The five System constructs are precompiled
input; scanning their signatures creates five signature entries.

`Scan_ALI` returns at the first X header (`ali.adb:3348–3378`). This version
of the parser never consumes the following Xref section, even though its
public default still says `Ignore_Lines => "X"`. Consequently its Xref tables
stay empty. The separate GG reader nevertheless reads **every line** with
`Text_IO.Get_Line` before inspecting its three-byte prefix
(`flow_generated_globals-phase_2.adb:1979–2024`), so Xref line sizes still matter.

## Explicit descriptor inputs

The equations use these fixed invocation inputs:

| Input | Meaning |
| --- | --- |
| `P` | Maximum bytes in every relevant full pathname, including configuration files and the derived object/ALI names |
| `A, A_sum, A_max` | Count, sum of payload lengths and maximum payload length of Main's actual `Compilation_Switches` entries |
| `C` | Number of extra dependency/unit-table entries registered for selected configuration/preprocessing inputs |
| `V_lib, V_spark` | Configured library-version and SPARK-version string lengths |

Configuration inputs here must be the selected generated naming configuration,
with no extra source unit, pragma semantics or preprocessing substitutions that
change the established Main/System frontier. `C` counts registered dependencies,
not every file opened: `frontend.adb:165–240` omits temporary configuration files
from `Prepcomp.Add_Dependency`; `prepcomp.adb:153–160` turns registered dependencies
into dummy Units entries using `Add_Preprocessing_Dependency`.
Thus the writer unit-table population is at most `u = C+2`, and D rows at most
`C+2`. The two semantic units remain Main/System; only Main emits U information.
The sole with row names System.

These parameters must be derived from the production GPR invocation and its
selected configuration before claiming production closure. The historical
null probe has eight A rows and one naming dependency. Those are **probe
inputs**, not a substitute for that derivation. Likewise, the separate native
compile's six A rows and 41-unit allowance do not describe this producer.
The current Silver project and GNATprove `Call_Gprbuild` establish the fixed
project switches and producer phases, but GPRbuild's generated switches and
naming-file contents remain the next join.

## Generic writer records and whole file

The selected null source has ten word tokens regardless of case/trivia.
The [source-binding Xref derivation](retained-main-semantics.md#main-source-binding-refinement),
with its existing fixed-context allowances, gives:

```text
X = 50 + 16(10+1) + 2(12784+1) + 1 = 25797 backing slots.
```

This deliberately retains the loose definition/orphan term and tentative
insertion slot. Xrefs grows from 5,000 to 20,000 to 80,000 capacity; the separate
sorting vector is at most `4(X+1) = 103192` bytes. This does not assert 25,797
actual emitted references.

The [native writer algebra](retained-native-expansion.md#native-main-ali-serialization-and-local-objects)
applies to the same serializer after checking this producer's entity frontier:
Main has only its four-letter procedure name; System has no generic/interface
or tagged type and its source identifiers fit the existing fixed-name allowance.
Standard type names retain that fixed allowance. No nested instantiation or
arbitrary external entity-name branch is added. Hence the native envelope of
788 bytes for a fixed entity header and 334 for a continuation remains
conservative here. Before a reference is appended the writer starts a new
continuation if its column exceeds 72 (`lib-xref.adb:2678–2715`); it cannot
accumulate all references on one line. Case changes preserve lengths, and
locations still use at most ten decimal digits under the frontend conditions.

The following bounds include each record's final LF. Tab stops are charged
as spaces; alternatives and absent flags are intentionally overcounted.

| Record kind | Count bound | Bytes per record |
| --- | ---: | ---: |
| V | 1 | `V_lib+5` |
| M / P | 1 each | 64 each |
| A | A | payload+3 |
| Named restrictions | 110 | 56 |
| RN and its preceding blank | 1 pair | 5 |
| U | 1 | `P+161` |
| System W/Y/Z | 1 | `2P+81` |
| D | `C+2` | `2P+65` |
| Invocation attributes | 1 | 6 |
| Other blank rows | at most 10 | 1 |
| Xref section/header/reference | at most X each | `P+14`, 789, 335 |
| QQ / GG append | as previously derived | `16+V_spark`, 947 total |

U uses the actual unit/file names, two tab-stop allowances, checksum and all
25 literal unit flags; the row above overcharges those writes. W allows both
file names and optional flags. D doubles a quoted pathname and adds two
quotes, the tab stop, timestamp, checksum and unit name
(`lib-writ.adb:432–619,835–1011,1510–1608`). The named restriction enumeration
has 90 Boolean and ten parameter cases, with longest name 40; allowing both
set/violated parameter records gives 110. The selected switches do not enable
the positional debug restriction format. Null/System/configuration inputs add
no CUDA, interrupt, dispatching, linker-option, note, external-version,
No_Dependence, Source_Reference or SCO record. Task-stack counts are zero.

Let `F` be the sum of that table, charging Xref records as
`X(P+1138)`, and `R` its largest individual record bound. A sufficient writer
condition is:

```text
R <= 2112  OR  F < 2112000.
```

These constants are `2*Hostparm.Max_Name_Length+64` and 1,000 times that,
respectively (`lib-util.adb:32–40`). Writes append before the flush check;
`Write_Info_EOL` reserves one whole maximum record, or flushes and resets the
buffer (`:101–119,307–323`). A full-file bound below the buffer size is the
alternative when one loose record estimate exceeds the reserved maximum.
No whole-file String is created by this writer. Quoted pathname assembly also
requires `2P+2 <= 131064`, separately from stored-name length `P <= 32767`.
The frontend/name-pool conditions remain required.

Five Boolean arrays and one Yes_No array have `u` elements each. A deliberately
loose four bytes per element bounds each independently. The dependency vector
has `u+1` four-byte entries; `Write_With_Lines` has another `u`-entry vector.
The existing Units table, with initial30/growth100, is bounded by `cap(30,100,u)`;
its component bound is 104 bytes. These are independent allocations, not a sum
used to reject programs for aggregate RAM consumption.

## Reader objects, counters and tables

`Read_Library_Info_From_Full` converts file length to Integer and allocates
`Text_Buffer(0..Len)` (`osint.adb:2478–2608`). Require `F+1 <= 2147483647`
for the Main buffer, text cursor and one-past arithmetic. System requires only
2,429 bytes. A loose line-count bound is `A+C+150+3X`; its one-past value must
also fit the signed32 Logical_Line_Number. The installed System count is fixed.
Successful stable-file I/O and allocation are the existing trusted environment
assumptions; this result does not recurse into libc or filesystem internals.

The GG reader's Text_IO implementation uses recursive `Get_Rest`: the first
buffer has 500 bytes, and later buffers have the number of bytes read so far
(`a-textio.adb:717–766`). For a line of length L, every Buffer and concatenated
String has at most `max(500,L)` bytes, with logarithmic recursion. The checker
exports a conservative depth bound from R. It checks each object and length
arithmetic; stack/heap totals are resource estimates under the same environment
assumption. The GG-specific 285-byte buffer and 286 cursor bound are unchanged.

These generic-parser populations count **both** input files:

| Table | Logical population bound | Initial / growth percent |
| --- | ---: | ---: |
| ALIs / Units | 2 each | 500/200; 100/200 |
| Withs | 1 | 5000/200 |
| Args | `A+10` | 1000/100 |
| Sdep | `C+3` | 5000/200 |
| Invocation constructs / signatures | 5 each | 2500/200 each |
| Invocation relations | 0 | 2500/200 |
| Linker options / Notes | 1 dummy entry each | 200/400 each |
| No_Deps | 0 | 200/400 |
| CUDA / Interrupt / Specific dispatch | 0 each | 100/200 each |
| Xref section / entity / reference | 0 each | 50/300; 500/300; 2000/300 |
| ALI.Util.Source | 0 in this prescan | 1000/200 |

The dummy linker/note entries are explicitly inserted by Initialize_ALI;
zero actual L/N records does not mean those table counters are zero.
`ALI.Util.Source` is initialized but neither this prescan nor GG loading calls
`Set_Source_Table`. Initial backing is conservatively charged even for empty
or lazily allocated tables. The parser's id types have maximum 99,999,999;
its table indices, capacity and one-past values must fit their actual types.
`cap(initial,increment,demand)` uses Table_Factor1 and the pinned recurrence
`max(floor(old*(100+increment)/100), old+10)` until sufficient. Each backing
object is `cap * component_size`, with wide intermediate arithmetic in
`table.adb:167–216`. The checker derives deliberately loose component-size
bounds from the retained record fields: sixteen bytes per scalar/pointer or
short fixed String field, 264 for the version String, and 304 for
Restrictions_Info. These include per-field alignment on the selected 64-bit
host; they are bounds, not measured layouts.

Each A payload is copied to its own String, of length at most
`max(A_max,14)`, using Name_Buffer first; it must fit the 131,064-byte buffer.
Total payload is `A_sum+72` only as a memory estimate. Invocation signatures
use a separate dynamic hash table with 500 **Node** buckets, not 500 pointer
buckets (`g-dynhta.ads:460–500`). There are five additional nodes, no growth
at expansion threshold1.5, and no deletion/compression in this parse. Using
128 bytes per node and64 for its attributes bounds each object; bucket backing
is64,000 bytes. The five-entry signature table remains independently charged.

The parser alone can introduce at most `3C+64` name entries: U/with/D fields,
five signature name/scope/location triples, and file/object identities fit
this overcount. Each has at most `max(P,70)` bytes. Add that conservative
increment to the existing frontend name-pool allowance when joining phases;
it is not a fresh independent pool. Filesystem search-path candidate names
remain in the production driver/path descriptor, not this parser-only count.

## Result and remaining join

The checker reproduces a conditional illustration with `P=222` and the
historical probe's A/C shape: maximum record789 bytes, loose whole file
35,093,723 bytes, and reader buffer35,093,724 bytes. This satisfies the writer's
record alternative and the reader's signed32 bound. It is an algebra example,
not evidence that production GPR emits those A/C inputs.

At `P=4096` the same loose formula gives R8273 and F135,066,167. The reader
still fits signed32, but neither writer alternative is established by these
bounds. This is incompleteness of the sufficient research envelope, not a
finding that the actual file overflows and not a new path cap. Tighter Xref
emission counts or record-specific path lengths could recover that domain.
Current language membership and its 4096-byte **source** bound are unchanged.

The next work is to derive A/C and the naming configuration from the selected
GPRbuild sources, connect the fixed startup/project/process objects, and join
these conditions with frontend, Why, native, report and idle-server capacities.
Output/integer/branch/loop extensions and an independent whole-rule review
remain further work. #119 remains open.
