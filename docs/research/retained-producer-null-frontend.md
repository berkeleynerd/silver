# Selected null light-frontend source join

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The [callable evidence packet](../evidence/retained-producer-null-frontend-20261018/README.md)
joins managed capture `20261018T142100-ece0ff83ecae` with independent source
analysis and the existing Main/producer derivations. The source analyst ran
no native or proof tool. This is a conditional frontend component; complete
toolchain composition and production admission remain separate.

## Computable input and scope

Use the established 15-token/10-word null recognizer and its permitted ASCII
case/trivia. Require exact installed System bytes, exact 327-byte indexed naming
configuration, two consistent Main/System map triples, selected phase options,
17 arguments excluding executable, no extra `-I`, indexed output names, and the
forwarded `-Wno-free-nonheap-object`. Keep the selected successful source/ALI
lookup frontier and environment; a path-length bound cannot establish that the
frontier is complete. Main/System source basenames stay `main.adb`/`system.ads`;
output ALI names stay `main~1.ali`/`system.ali`. Temporary naming/map serials may
vary without changing file roles or record count. Path spellings must satisfy
the existing individual consumer checks as well as fit the complete bound P.

`null_source_counts(raw)` and `physical_source_shape(raw)` are reusable from
`docs/evidence/unbounded-programs/retained-native-expansion-20261017/compose-null-capacity.py`.
The latter correctly keeps VT/FF in physical-column scans although they end
comments; only CRLF, CR and LF reset physical columns.

## Fixed table transfer through the endpoint

The exact selected captures audit 121 Table.Last positions, including positive
increments before decrements/restores, through `before_name_finalize`. Use the
last snapshot's gross positive count for every table. Retain its observed fixed
backing trajectory where the demand is unchanged. Replace Names/Name_Chars and
File_Name_Chars as below; source text/line buffers need separate variable checks.

The nonzero core counts shared by both phases are: node offsets/original nodes
1279 each; slots24597; next/previous1281 each; lists114; Elist headers20/elements28;
Ureals53; String descriptors18/chars43; scope pushes11; overload interpretations15;
Xrefs8; name-qualify units2; source-search additions5; Units3; load-stack pushes3;
Source_File additions5; Instances1; SFN patterns6/table1; file/path mappings2 each;
assertion levels3; convention identifiers7; check names30; SCO unit/unit-number
entries1 each. Phase1 Uints/digits are191/1025; phase2 are231/1257. Phase1 library
search additions4 and compilation switches10; phase2 are5 and9. Preserve all
other audited zero/fixed tables from the capture, rather than inventing a smaller
inventory. These are gross-allocation demands, not final live populations.

Transfer is source justified: `scng.adb:1683–1785` skips permitted comments;
`:2545–2606` canonicalizes identifiers without changing their lengths. Disabled
style/preprocessing/Source_Reference paths cannot turn trivia into syntax. Exact
System/naming bytes plus the same canonical Main tokens preserve AST/semantic
allocations and the 34 all-miss discrete-range query operands. Slocs, checksums,
case flags and hash-bucket choices may differ; they do not add syntax/semantic
objects. Locations in selected ALI/GG/report output are bounded native-Int images,
not arbitrary Uint conversions. ALI/GG sources have no Uint/Ureal/Stringt allocation
for their variable line/column values. Existing null composition/tail/global
source projections discharge the selected producer branches after frontend
entry; they remain required premises, not replaced by 121 counters.

`Namet.Finalize` immediately returns with Debug_Flag_H=False (`namet.adb:677–679`).
The selected driver then exits; SPARK's `Back_End.Gen_Or_Update_Object_File` is
null (`src/why/back_end.adb:90–96`). Thus no unmeasured normal suffix invalidates
the endpoint transfer. A successful table witness plus this read projection
legitimately transfers those tables' fixed backing arithmetic; it does not
establish a universal inventory of every finite producer object. In particular,
retain the separate Why graph, serialization, metadata and local/global-flow
conjuncts. Do not transplant an entire native table inventory implicitly.

## Names and path corrections

Captured gross name-entry demand is1696 in each phase; gross character demand is
26590/26926. Collision changes can cause additional Name_Find misses, so use:

```
N_phase1 = 1696 + 32 + 10       = 1738
N_phase2 = 1696 + 32 + 10 + 64 = 1802
H_phase  = 32768 * N_phase + 5000
```

The32 is a deliberate overcount of successful path construction roles: six
files (Main, System, naming configuration, mapping file, Main ALI, System ALI),
each charged raw/normalized full spelling and directory with/without separator
(24), cwd with/without separator(2), and every field of the two map triples(6).
Fixed basenames are already present; a variable temporary basename is read as
part of its raw/full config name, not an extra compiler search role. Keep the
baseline Name_Enter events: they always allocate, so changing their spelling
does not increase call multiplicity. The32 is for newly missing deduplicated
spellings, not a claim that every Name_Find call previously missed. Ten source
word events and the published ALI-reader allowance `3*C_dependencies+64=64`
are additionally overcharged. The32768 factor pays maximum signed-Short length
plus NUL for every entry; baseline dummy Name-entry reserves overpay recorded
character reserves, and the extra5000 retains explicit locking headroom.

Relevant closure: `Fmap.Initialize` enters its filename and three fields per
record (`fmap.adb:278–347`); frontend config handling and Config normalization
supply raw/normalized names (`frontend.adb:196–240`, `osint.adb:1230–1237`).
`Find_File`/`Locate_File` return an existing mapped name or the first successful
candidate; failed probes add no Namet entry (`osint.adb:1201–1314,1896–1919`).
`Get_Directory`'s only compiler semantic caller is External_Initialization
(`sem_ch3.adb:3985`), absent here; the other caller is the separate make executable.
The object-path file and its directory lines use ordinary Strings and search
storage (`osint.adb:360–430`), not Namet. Options JSON uses GNATCOLL Strings;
SPARK's remaining Name_Find/Enter callers are excluded counterexample execution.
Repinfo/debug-input auxiliary path branches are disabled.

Separately require each new spelling <=32767 characters, each selected name-buffer
operation <=131064, and the existing mapping-reader/update conditions (including
every eventual update field plus LF <=1500). Use actual map-field lengths where
appropriate, rather than treating every complete-path bound as an attained field
length. Bounding total characters does not discharge these per-name conditions.

The observed File_Name_Chars41 is exactly the40-character Main full filename plus
LF (`osint.adb:2678–2702`). Replace its demand with `P+1` (or conservatively add
`P+1` to41). System is excluded by the fixed include-prefix test; config/map are
not Source-kind inputs. Instance: low1, initial10000, increment100%, component1.

For variable generic tables reuse `native_table_backing_row`: for demand D,
initial I, factor F, increment r and low m,
`p=max(D,I); C=max(I*F,D+D//1000,p*(100+r)//100,p+10)`.
Check I*F<=I32, p*(100+r)<=I64, C+1<=I32, m-1>=I32min, m+C<=I32, nominal
logical last, `(C+1)*record_size<=I64`, and any narrower subtype sentinel.
Native core helper is an extra conservative price for its supported vector,
not justification of layouts it does not share (Source_File is128 here;464 is
an independently safe conservative bound).

## Physical source and ALI interfaces

Successful source-buffer order in both phases is System[0,7503], Main[8192,8261],
naming[12288,12615], System again[16384,23887]. Indexed input bypasses Load_File's
dedup condition (`sinput-l.adb:365–381`); the initial target read and later implicit
semantic System load both need charging. Therefore, for Main byte length n,

```
align(n) = 4096 * ceil((n+1)/4096)
source extent <= align(n) + 20480
source cursor/headroom: extent-1 <= I32-4096
```

There are four physical records and one transient failed load (gross table
demand5). For each physical source require n+1<=I32 and its individual buffer
request including header<=I64. For Main count `1 + CRLF/CR/LF terminators`, take
the least `500*2^k` covering that demand, and require32*capacity<=I32. Reuse the
expanded-column recurrence (HT to the next multiple-of-eight position) and
require final column<=32766. Fixed System/config line checks transfer. The native
backend's extra 24-bit gigi last-logical-line condition is not a light-frontend
requirement; it remains in the separate native/datarep conjunction.

Phase2 ALI tables add ALIs2, Units2, Withs1, Args20, Sdep3, invocation signatures5,
constructs5, and dummy LinkerOptions1/Notes1. Relations/Xrefs stay zero. Phase1
emits A10/sum77/max24, C_dependencies0, ALI filename bound10. The existing loose
writer envelope gives F29622804, R789 including LF, lines77551, reader bufferF+1.
This is separate from the947-byte GG total. ALI Scan_ALI ignores Xref rows and
returns at the first X; the GG reader reads all lines, covered by the line/file
bounds. Do not reuse phase1's10 stored switches as phase2's9; phase2 Args20 includes
ten A rows from Main and ten from installed System.

## Remaining transfer conditions

No new null-frontend arithmetic gap is identified conditional on the exact
selected file/search/option/read projections above and the existing producer
component proofs. Parent GPR/project/process counters, native/datarep backends,
Why/JSON/report objects and complete predicate composition remain separate
obligations. The capture does not by itself prove these conditions, installed
source correspondence, or whole-language coverage; null alone cannot complete
#119's useful-domain/comparison requirement.

## Existing callable integration map

- `retained-producer-parent-20261018/check-parent.py` executes at top level,
  verifies its pinned sources, and prints JSON; no function API. Source-only
  execution passed in this review. Read `proposed_warning_switch_delta` for
  `phase1_A/phase1_A_sum/phase1_A_max`=10/77/24,
  `phase2_stored_A/phase2_A_sum/phase2_A_max`=9/70/24, argc17 in both phases,
  `null_ALI_file_bound/null_ALI_record_bound/null_ALI_lines`=29622804/789/77551.
  Its `parent_configuration` supplies `cmdline_entries`17, `cmdline_capacity`32,
  `file_byte_bound_constant`349, `path_coefficient`12,
  `joined_command_constant`213, `joined_command_path_coefficient`1.
- `retained-producer-orchestration-20261018/check.py --source FILE --output SCRATCH`
  is an actual callable offline CLI. It validates retained inputs, computes
  current source shape, and emits `conditions`/`all_selected_checks_pass`.
  `fixed_GPR_aligned_extent_per_process`=12288;
  `selected_GPR_ALI_rows`={ALIs:1,Units:1,Withs:1,Sdep:2,Args:0};
  `datarep_ALI_file_bytes_upper`=2177456 and
  `producer_ALI_file_bytes_upper`=29622804. Its six conditions cover source and
  ALI interfaces, not all parent containers/processes. No rerun was needed here.
- `retained-producer-null-tail-20261018/check.py` only exports main and writes
  `result.json`/`storage.json`. Consume pinned result keys `pretty_string_bytes`
  (constant1246, `filename_byte_coefficient`6) and `emitted_file_bytes`
  (constant1247, same coefficient). Storage keys include
  `json_producer_live_reference_bound`8, `json_parser_live_reference_bound`42,
  `source_main_node_bound`39, `cfg_vertex_bound`89, `graph_edge_bound`7921,
  `dominator_dfs_pending_bound`7922, `dominator_dfs_vector_capacity_bound`8192,
  `dominator_array_bound`90 and `dominator_size_comparison_arithmetic_bound`178.
  Reevaluate for supplied P: B=1246+6P; producer XString=max(P,32)+4096;
  parser XString=3*max(2P,32)//2+4096; unbounded backing=B+B//2+128;
  allocation=backing+64; file=B+1 against262144,16777216,65536. Preserve separate
  unsigned32 growth and signed String/allocation conditions from the checker.
- `retained-producer-null-global-20261018/check.py` similarly exports only main
  and writes `result.json`. Relevant keys are
  `generated_global_total_bytes_with_lf`947, `generated_global_row_count`11,
  `gg_reader_buffer_bytes`285, `gg_reader_cursor_maximum`286,
  `visibility_vertices_per_graph`17, `visibility_edges_per_graph`289,
  `phase1_scope_contract_entries`1, `phase2_scope_contract_entries`2,
  `report_parser_and_wrappers_live_reference_bound`46,
  `report_consumer_live_reference_bound`8, and `ordinary_output_bytes`
  {constant:1719,filename_byte_coefficient:1}. Its historical configuration
  constant313 and array15/capacity16 are superseded by the parent record's
  constant349 and array17/capacity32 above. The ordinary report formula remains
  unchanged. Pinning a result or invoking a source checker does not itself
  discharge its accompanying source-read-projection premises.

## Implementation and independent review

The callable component prices both corrected vectors and all four physical
sources from actual input bytes. Its frozen descriptor retains the exact phase
options and launch-path set; a complete search/path realization is an explicit
caller obligation. The boundary checker passes 15 offline cases, including a
one-megabyte comment source and rejected column/configuration boundaries.
These are evaluator checks, not additional native compilation observations.

An independent GPT-6 Astra Extra High review accepted this conditional component
without findings or rework on 2026-10-18. It checked the source transfer, actual
formulas and identities, replayed the retained result and all 15 cases, and ran
no native tool. Reviewed `compose.py` SHA-256:
`5b42dd4a1e10f4b9b8de8edad41f46a0edb151ec734127374e8dba06d15b2529`.
Reported review time was approximately 2m46s. The
[round record](../evidence/retained-tool-rounds.md) tracks integration separately
from completed whole-toolchain assurance.
