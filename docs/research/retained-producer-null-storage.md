# Null-family report and local flow storage

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This composes the [null-family metadata result](retained-producer-null-tail.md)
with caller-specific JSON storage and the local flow graph. It uses the same
source-token family and configuration premises; trivia length changes neither
the report shape nor the local flow graph. No native or proof execution ran.
The [offline evidence](../evidence/retained-producer-null-tail-20261018/README.md)
pins the complete external sources and evaluates the arithmetic separately.

## JSON references are live aliases, not lifetime allocations

GNATCOLL's JSON_Value is a tagged controlled handle. `Adjust` increments only
the referenced object's counter; copying a handle does not recursively copy
its children (`gnatcoll-json.ads:651–659`, `.adb:1011–1030`). JSON_Value formals
are passed by reference. A parent map/array retains one handle per field or
element. The selected producer builds a tree: it does not put the same object
under several report fields, and all empty arrays are separately constructed.
Parent-local/result aliases therefore do not multiply descendant counters.

For each producer JSON object/string, simultaneously live handles are its
constructor local, result/assignment temporary and parent slot. The raw
JSON_Array builder additionally holds element handles in its source vector;
`Create(array)` copies that vector, and vector growth can temporarily retain
old and new storage. The selected arrays have at most two elements, are
populated before embedding, and are not modified afterward. Charging two
vector copies, two old/new storage slots and four local/result handles gives
the conservative **eight live references per object**. Empty vectors retain
no elements. `Set_Field` adds one ordered-map slot; no existing report object
is copied or recursively cloned (`.adb:1158–1166,1196–1216`). The recursive
writer reads those handles by reference and uses string accumulators; it adds
no retained JSON_Value collection. Its container `Element` calls return a
controlled temporary, charged within the four local/result handles; recursive
ancestor temporaries refer to different objects in this tree (`:727–879`).

For a subsequent GNATCOLL parse, the fixed builder stack has 32 slots and
does not grow at schema depth five. Even charging every slot as a reference
to one object, plus the three locals Result/Cursor/Tmp, one parent slot, two
transient vector slots and four active constructor/result temporaries gives
**42 live references**. The parser is iterative; completed nested values
remain as one parent edge, not as a recursive series of constructor calls
(`.adb:555–689`). Scalars do not increment a JSON counter. GNATCOLL.Atomic
uses the installed runtime's unsigned32 atomic counter, so both bounds fit.
These are bounds for the producer and parser calls, not for arbitrary callers
which deliberately save repeated handles. Downstream consumer retention must
still use its own call structure.

## Backing strings and report readers

Let `D=max(P,32)` bound a producer filename/string and every fixed field name,
and let `B=1246+6P` be the JSON.Write String envelope. Each producer XString
is created empty then Set once. It therefore uses `Growth_Strategy(0,D)`;
the `Current*3/2` step is zero, and capacity is at most `D+4096` after page
rounding (`gnatcoll-strings_impl.adb:43–61,317–339,455–477`). Its UTF-8 byte
width is one. For a parser-built decoded string, `D_read=max(2P,32)` covers
even the conservative two-byte decoding of each escaped input byte. Every
growth happens with old capacity below the requested decoded length, giving
capacity at most `floor(3*D_read/2)+4096`. Check the unsigned32 multiplication
and rounding, Ada String index/length and size_t header addition separately.

Unbounded_String's selected Append paths allocate with required length `L`
and reserve `floor(L/2)`, where `L<=B`; the alignment helper adds fewer than
two maximum-alignment units (`a-strunb.adb:503–551,1237–1294`). Thus a backing
String has at most `B+floor(B/2)+2A` characters for maximum alignment `A`.
The full allocation additionally includes its fixed header `H`. Required
conditions include representability of `H+B+floor(B/2)+2A`, `B+1` for Text_IO's
column, and each filename/token's own operations. This does not replace these
per-object conditions by a total-memory limit.

For the Linux descriptor example `P=222`, using conservative `A<=64,H<=64`
gives backing String capacity at most 3995 and allocation at most 4059 bytes.
The final file has at most 2579 bytes. Even the existing Silver path envelope
`P=4096` gives a file of at most 25,823 bytes and the same backing allocation
bound below 39,000 bytes. These are evaluations of existing path/configuration
domains, not newly chosen source limits.

The alignment envelope covers all selected x86 target alternatives: GCC's
`BIGGEST_ALIGNMENT` is at most 512 bits, including AVX512, and gigi maps
`Standard'Maximum_Alignment` to that value divided by eight
(`gcc/config/i386/i386.h:843–845`;
`gcc/ada/gcc-interface/targtyps.cc:124–126,170–176`). The header envelope uses
the selected ordinary Linux record-layout premise: `Shared_String` is an
untagged record containing its Natural discriminant, a 32-bit atomic counter
and Natural Last before the character data (`a-strunb.ads:1573–1581`;
`s-atocou.ads:79,106–108`). H<=64 includes its fixed layout padding. The checker
records these target/layout parameters; it does not claim a runtime measurement
or that every Linux compiler option uses 16-byte maximum alignment.

GNATCOLL's parser/state arrays each start with 32 entries; the report needs
at most six including the sentinel. All array lengths are at most two, and
all object maps have at most twelve entries. The two coordinate values fit
Positive, entity references are 1, and timing images round-trip through
Long_Float. The complete file and even its longest escaped token fit the
existing 64 KiB buffer example for `P<=4096`; no stream-window growth is
required. Parser-produced strings still use their separately charged decoded
bound above.

Silver's current null reader uses `Silver_Platform.Read_File`, then
`Silver_Reports.Complete_Null_Proof`; it does not invoke the output report
projection. The raw report buffer is larger than the null recognizer's
262,144-byte bound. At the existing path envelope, the derived file fits
both. Compaction allocates at most one report-length String and its slice;
all executable scans advance within those bounds. The source schema supplies
the required `spark` single-entity status, progress/stop fields and empty
flow/proof/skip/Assume/warning arrays. Source-length relaxation in this token
family therefore does not increase this reader's report-buffer requirement.
Its ghost recursive specifications are erased, as the implementation states.
Changing the configuration/path domain still requires checking these same
actual consumer limits, or separately completing an authorized reader repair.

## Local flow graph

Let `A` be the existing semantic Main node bound. For the null family, the
[Main composition](retained-producer-composition.md) gives `A<=39`, independent
of case/trivia. The control-flow constructor contributes:

| Family | Vertices |
| --- | ---: |
| Start/helper/exceptional/end and two null exports | 6 |
| Initializer placeholder, even though unused for a subprogram | 1 |
| Empty pre/post/exceptional-contract joins | 3 |
| Subprogram exit placeholder | 1 |
| Processed null/ignored/synthetic statement nodes | at most A |
| Empty statement-list joins | at most A |

The last two rows overcharge the actual null/pragma shape. Each statement
node and each list is visited once: there is no loop unrolling, inlining,
handler or finally-copy path; the handled sequence only moves its connection
record. The one subprogram-body Join is nonempty and its exit placeholder is
already counted (`flow-control_flow_graph.adb:1357–1395,2591–2705,4381–4408,
6556–6620,7186–7215,8441–8460,8742–8750,8753–8843`). Thus

```text
V <= 2A+11 = 89.
```

The synthetic export is the sole flow-variable key; no ordinary object,
formal, global, callee or cleanup record is added. Phase-1 global discovery's
extra vertex loops have empty variable/callee domains (`:9053–9258`).
Simplification/pruning preserves vertex IDs and does not append vertices.
Derived CFG copies, inversion, dominance frontier, DDG, TDG and PDG reuse
that same vertex set (`graphs.adb:606–639,777–800,1287–1304`;
`flow-data_dependence_graph.adb:268`;
`flow-interprocedural.adb:452`; `flow-program_dependence_graph.adb:34–39`).

Each graph has at most V vertices, each adjacency set/map at most V keys,
and at most V² edges even when every possible edge is pessimistically charged.
Ordinary DFS marks a vertex when scheduling it, so its stack has at most V
entries (`graphs.adb:644–771`). The dominator DFS marks at visit time; charge
one pending entry per traversed edge plus the root, at most **V²+1=7922**,
not merely V (`:838–905`). Its backing vector capacity is at most 8192.
Dominator arrays have V+1 entries, buckets contain at most V entries, and the
visited-count/DFS-depth domains are bounded by V. The `Link` size fields also
stay within V: initially every visited vertex forms a singleton component;
reverse DFS order links the completed component rooted at W into the disjoint
component rooted at its parent V exactly once. A component root's Size is its
cardinality. The internal Child-chain rearrangements only copy an existing
size within that component, so nonroot sizes cannot exceed the component
cardinality. The root update adds disjoint cardinalities, at most V. The
comparison sum and doubled operand are each at most 2V=178, including
`Size(S)+Size(Child(Child(S)))`, where disjointness is unnecessary for that
comparison (`graphs.adb:963–986,1015–1031`). These quantities fit the existing
signed32 vector/index and hash-container conditions. Independent
copied graphs and local allocation pools contribute memory cost; they do not
share a finite total-node counter in `Graphs.Graph`.

This closes these local graph/container dimensions. The subsequent
[global metadata and ordinary-report analysis](retained-producer-null-global.md)
adds scope visibility, the selected GG ALI records and ordinary report
consumers. Other frontend ALI data, SARIF/VSS and process orchestration remain
separate joins needed for complete null-family feasibility alongside native
compilation. #119 remains incomplete.
