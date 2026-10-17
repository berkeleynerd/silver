# T1 notes: Silver-owned fixed capacities and an unbounded implementation design

Input: review worktree `tmp/review-b79b986403` (detached at b79b986403). Nothing in the
repository or worktree was modified. All probes ran in this scratch directory.
No GNATprove, Lean build, lake, dev.py, bootstrap or replay was run.
No program-*/imagews-* directory was created (308 before and after).

Legend: PROVED = established by SPARK/Lean in the current tree; PREMISE = trusted
tool/OS assumption; OBSERVED = measured here or by the lead (specific inputs/host).

## 1. Inventory (Silver-owned code)

### 1a. Membership-affecting bounds (language)

| Bound | Where | Class | Necessary? | Replacement |
|---|---|---|---|---|
| Source 1..4096 bytes | `silver_profile.ads:4`, `silver_output_profile.ads:6`; `Cursor`/`Literal_Position`/`Capacity_Value` subtypes (`silver_output_lexical.ads:8,73,276`, `silver_profile.adb:4`); driver buffers `silver.adb:126,420`; Too_Long -> "Rejected" `silver.adb:444-447`; Lean `Admission.lean:103` (471 uses / 100 modules) | arbitrary policy | No | No total cap. Ada's natural bound `Positive'Last - 1` (one-past cursor fits Natural). Driver reads into a growable heap buffer. Keep only a per-line bound forced by GNAT (below). |
| (new) per-line bound | GNAT 16.1 "this line is longer than 32766 characters" (lead) | tool hard limit | Yes, once total cap is removed | Lexical rule: every line (bytes between LF/CR terminators) at most GNAT's accepted maximum. Oracle forbids reformatting admitted source, so this is "truly the only way". |
| String value / intermediate domain 4096 | `Expression_Step` `silver_output_profile.adb:593-594` (uses `Max_Source_Length`!), `Fits` :689-694, `Silver_Path_Facts.Max_Length` `silver_path_facts.ads:4-7,113-118`, `Silver_Length_Intervals`, catalogue `max_result_bytes` | arbitrary policy (tied to Silver_IO) | No | Value bound V = Integer'Last (Ada natural bound for one-based Strings; all admitted operands are one-based). 64-bit arithmetic for `Static + K*d`. |
| Argument length 0..4096 | `silver_arguments.adb:6`, `silver_arguments.ads:16`, `Paths.Initial` `silver_path_facts.ads:37-38`, initializer C=4096, catalogue `max_argument_bytes` | arbitrary policy | No | No Silver cap; analysis uses d <= Natural'Last; Linux MAX_ARG_STRLEN (131071 usable bytes, OBSERVED) and ARG_MAX (2 MiB here) are environmental. |
| Length literal value 0..4096 | `Silver_Integer_Literals.Literal_Value` `silver_integer_literals.ads:6` (= 0..Max_Source_Length) | arbitrary policy (follows value domain) | No | 0..Natural'Last (match V). |
| Exponent <= 4096 | `Silver_Scalar_Literals.Max_Exponent` `silver_scalar_literals.ads:7`, :196,:215; integer literals via `Literal_Value` | policy, but a tool limit exists | A bound is necessary; 4096 is not | 799_999 (GNAT rejects >= 800000 with "exponent too large", any base, any mantissa; OBSERVED). Add Value=0 shortcut to `Silver_Integer_Literals.Power` (today loops Exponent times). |
| 64 leaves per String expression | `Max_Expression_Operands` `silver_output_profile.ads:7`, :526, :593; `Paths.Operand_Count` | proof-work policy | Gated by T4 solver evidence | `Natural` counts; 64-bit products. |
| 64 leaves per scalar expression | `Silver_Scalar_Expressions.Max_Operands` `silver_scalar_expressions.ads:9`, adb:130 | proof-work policy | Gated by T4 | Same. |
| 63 operators source-wide | `Max_Concatenations` `silver_output_profile.ads:10`, `Work_Tail`/`Within_Work_Budget` :388-438; Lean `withinWorkBudget` (16 uses / 10 files) | proof-work + report policy | Gated by T4 (report part removable) | Delete the scan. |
| Max_Bindings = S/12 (two copies) | `silver_output_profile.ads:13`, `silver_scalar_expressions.ads:8`; checks :790, :827, :1571 (`Count = Max_Bindings -> Invalid`) | derived capacity that is coded as a rejection | No (unreachable today; Lean `ComposeSourceChecks.lean:309`) | Environment sized at run time (pre-count or growable heap); no count check. Any allocation failure must raise Storage_Error, never return Invalid. |

Inherited, not capacity: Integer range and magnitude 2**31 (`silver_scalars.ads:4-7`,
`silver_scalar_literals.ads:6`), Image length 2..11 (`silver_integer_image.ads`), the
printable-argument rule, the fixed grammar tables (token arrays <= 100, spellings <= 16/12/10).

### 1b. Compiler capacity / infrastructure

| Bound | Where | Program-scaling? | Replacement |
|---|---|---|---|
| Retained application report 16 MiB | `silver_library_reports.ads:8`, `silver_report_storage.ads:7`, `Offset` adb:124, ~90 Pre clauses | Yes: the envelope E(S) exceeds 16 MiB at S = 4503 | Growable heap buffer (SPARK ownership: double, copy, free), constant becomes `Natural'Last - 1`. Fixed ghost `Report_Bytes` array (`silver_report_reader.ads:14`) is replaced by the existing ghost sequence. |
| Runtime report 262,144 + 256 KiB stack buffer | `silver_library_reports.ads:9`, `silver_libraries.adb:43` | No (fixed runtime) | Same buffer type. |
| Null report 262,144 + report-sized stack copy | `silver_reports.ads:2`, `silver_reports.adb:267` | No | Same. |
| Max_File_Length 16 MiB + ghost arrays | `silver_platform.ads:10-24` | Yes for source reading | Ghost sequences; `Natural'Last - 1`. |
| Source copies on the stack | `silver_profile.adb:266`, `silver_output_profile.adb:1739` (`Normalized`) | Yes (O(S) stack per parse) | Require one-based input (the driver already supplies it); no copy. |
| JSON nesting 64 | `silver_report_projection_types.ads:3,18`, `silver_report_observations.ads:38`, `silver_library_reports.adb:154` | No (producer schema) | Keep as a documented producer-format premise; optional heap stack. |
| Initializer advisory name <= 4096 | `silver_library_reports.adb:1213` (exec), :2088 (raw), `scripts/check_evidence.py:484` | Yes once identifiers > 4096 are admitted | Remove the upper bound. |
| Command text 16,384 | `silver.adb:29-31`, `silver_platform.ads:23-24,49` | No (install path) | Ghost sequence; OS limit is environmental. |
| Paths 4096 | `silver_platform.ads:9`, `scripts/bootstrap.py:178,260`, adapter `-64` | No | Mirrors Linux PATH_MAX; may be dropped (fopen reports). |
| Runtime library file 16,384 | `silver_libraries.ads:7` | No (fixed six files) | Keep, or size from generated constants. |
| Proof command caps | `silver.adb:116-123`: `--steps=100000 --memlimit=1000 --level=2` | Steps/memlimit turn exhaustion into "unproved" | T4 handoff: `--steps=0`/`--memlimit=0` only if pinned GNATprove honours them (expression-headroom.md reports `--memlimit=0` became an internal 1000). |
| Image adapter | `silver_image_model.ads:4-6` (Byte_Count 2**63-1; Original_Node_Id <= 2**31-1), `silver_image_files.adb` streaming | Node id inherited from producer's Natural counter | Keep; documented producer premise (`docs/for-loops-image-schema.md:78-110`). |

### 1c. Runtime value domain

| Bound | Where | Replacement |
|---|---|---|
| `Silver_IO.Max_Length` 4096, guard, ghost `Written_Bytes (1 .. 4097)`, trace n*4097 | `silver_io.ads:5-12`, `silver_io.adb:13,56` | No guard; ghost functional sequence (`SPARK.Containers.Functional.Infinite_Sequences`, already used by Image files and the report reader); ghost count as Big or 64-bit; trace bound becomes Item'Length (+1) per call. |
| `First_Or_Default` Post `<= Silver_IO.Max_Length` | `silver_arguments.ads:16` | Remove; Main VCs use path guards, as they do today. |

## 2. Algorithmic hot spots (OBSERVED on the production binary and scratch variants)

Production `silver check` at the 4096-byte maximum (wall s / min stack KiB):

| Shape | Params | Wall | Min stack |
|---|---|---|---|
| nested loops | 138 levels | 0.047 | 4203 (fails at 4187 with STORAGE_ERROR, exit 1) |
| nested ifs | 200 | 0.024 | 399 |
| condition parens | 1998 | 1.73-1.88 | 4028 |
| scalar parens | 2001 | 0.026 | 2173 |
| String parens | 1999 | 0.032 | ~239 (baseline) |
| String declarations | 269 | 0.051 | 383 |

- Loops: per-level stack slope 29 KiB (20->138 levels: 783 -> 4203 KiB). Cause: `Inner : Body_Context := Context` plus `Append` (`silver_output_profile.adb:1561,1589`) copies two 341-slot environments per level.
- Condition parens: time quadratic (125:0.035, 250:0.052, 500:0.14, 1000:0.46, 1998:1.73 s). Cause: `Read_Relation` (`:1233-1240`) runs the length, scalar and String parsers at every nesting level before `Read_Primary` recurses, each rescanning to the core.

Scratch variants (copied recognizer sources, only `Max_Source_Length` changed,
same flags `-gnat2022 -gnata -gnato -g`, probe driver `build/*/probe_main`):

- Loops, depth 20: L4096 783 KiB, L16384 2973 KiB, L65536 11764 KiB. L16384 depth 40/80: 5242/9766 KiB (113 KiB/level). Depth 560 (16,320 bytes) ran at 64 MiB. Stack is depth x c x S, so O(S^2).
- Base stack grows with S: L65536 needs about 3.3 MiB even for 100 nested ifs (L4096: 287 KiB). The ifs themselves cost about 1 KiB/level at every L.
- Condition parens at L16384: 2000 levels 2.44 s, 4000 levels 7.6 s, 8142 levels (16,384 bytes) 32.0 s, min stack 16,352 KiB (about 2 KiB/level). Extrapolation to 1 MiB: about 1.3e5 s.
- String declarations at L65536: 1000/2000/4000 decls 0.80/1.27/4.92 s with -gnata; 0.54/1.59 s without -gnata. Runtime checking of quantified Pre (`Valid_Names`, `Valid_Environment`, `Valid_State`) is about two thirds of the time; the rest is environment copying and linear lookup.
- `compile` re-parses: `Accepts` plus `Uses_Arguments` plus `Uses_Assignment` each call `Read_Form` (up to 6 full parses).

## 3. Answers

(a) Yes. O(S) memory and O(S log S) time (or O(S) expected) are achievable:
1. Separate the value-domain bound from the source-length bound (they are conflated in `Capacity_Value`, `Literal_Value` and the Lean `maxSourceLength`).
2. Environments sized at run time: a discriminated record allocated once per parse (stack, O(S)), or a heap array under SPARK ownership. No `Max_Bindings` rejection.
3. In-place scope push/pop for loop indexes (the only scoped bindings). Declarations become procedures with `in out` environments, not functions that return `Parser_State` copies.
4. One O(S) bracket-matching table, so condition/expression classification at "(" is O(1) per level.
5. Name interning (sort-based, O(S log S), simplest to prove; or SPARKlib formal hashed maps).
6. Make the quantified preconditions `Static` (they are already proved), or build without runtime checking for them.
7. One scan for `Accepts`/`Uses_*`. No `Normalized` copies.
8. Stack: frames are then O(1) per nesting level (about 1-2 KiB). Either raise RLIMIT_STACK to the hard limit and re-exec at startup (hard limit is unlimited here), or use explicit heap work stacks. Recursion depth is also bounded by GNAT's own recursive parser (T3).

Proof impact: the SPARK refinement pattern already in use (an executable loop proved equal to a recursive Static ghost model) carries over. The Lean certificates pin the exact Ada token shapes of `silver_output_profile`, `silver_output_lexical`, `silver_scalar_expressions`, `silver_names`, `silver_integer_literals`, `silver_io` and `silver_arguments` (`generate_source_certificate.py:16-42`). Every restructuring needs new pins and reconstructions, and heap/ownership constructs would extend the interpreted Ada fragment. This is the dominant cost (XL).

(b) Grow the retained-report buffer on the heap: double on overflow, copy, free, and carry `Model.Matches` across the copy with a loop invariant. Set `Max_Report_Length := Natural'Last - 1`. The bounded policy is unchanged; only its constant changes. Re-prove `Application/Runtime_Projection_Correspondence` with the new constant. No Lean impact: the report policy has no Lean model. The envelope gives S <= 587,402 within `Natural'Last - 1`; measured reports are about 490 B per source byte. Beyond 2 GiB, use 64-bit-indexed byte arrays (L) or streaming (XL). It is also worth checking whether the producer writes `.spark` through Natural-indexed strings (PREMISE, unverified).

(c) No Silver-chosen size or count limit that scales with the program. Byte counts and depth are 63-bit. The node-id bound 2**31-1 is the producer's Natural serialization counter (documented premise). The other bounds are paths and argument counts (Natural'Last - 2).

(d) Make V = Integer'Last and A = unbounded (Natural'Last). Admission arithmetic: Static <= V (checked before each addition), K <= S < 2**31 and d <= 2**31, so `Static + K*d < 2**63` fits Long_Long_Integer; `Expression_Length` becomes 64-bit. Membership is a strict superset: `N + K*min(C,4096) <= 4096` implies `N + K*min(C,2**31-1) <= 2**31-1`. Behaviour change: argument lengths 4097..OS limit become valid. Runtime library: guard removed, ghost sequences used, ledger and envelopes re-derived, embedded `Silver_Library_Sources` regenerated, Lean `OutputRuntime.maxLength` generalized. Risks still to probe:
- static data near 2 GiB. GNAT folds static Strings (2^27 bytes: 548 MB RSS in -gnatc) and emits about 2x the value size in .o (2^24: 33.5 MB; 2^26: 134 MB). Small-code-model/relocation limits near 2 GiB are unprobed (only 8 GB of disk was free).
- large dynamic Strings on the 8 MiB primary stack (environmental Storage_Error in the application).

(e) Today `Storage_Error` exits 1 with "raised STORAGE_ERROR : stack overflow or erroneous memory access", in both `check` and `run` (OBSERVED). In `run`, 1 is also the application's Reject/output-failure status. `trusted-boundary.md:74-79` records this gap. Proposal:
- Status 4 means "resource exhaustion (environmental), not a membership decision". The status set becomes 0 ok, 1 only forwarded from the application, 2 rejection or usage, 3 tool/implementation/infrastructure, 4 resource.
- A top-level SPARK handler `when Storage_Error =>` in `silver.adb`. SPARK RM `exceptions.rst:9-21`: handlers are legal without a choice parameter; GNATprove treats them as unreachable.
- Optional supervisor mode: the parent spawns `silver` as a worker and maps a signal death or an unexpected status to 4. This covers the OOM killer.
- Report overflow wording changes from "missing or incomplete proof evidence" to capacity/resource wording.
- With the source cap removed, no read or size failure may ever map to 2.
- Optional: classify GNATprove results whose unproved_status shows only memory/time resource flags. This depends on T4 removing step and memory caps.

(f) Staged plan: see the structured output. Stages 0 (S), 1 (M), 2 (L+XL Lean), 3 (XL), 4 (L/XL), 5 (gated by T4), 6 (optional XL).

## 4. Probe log

- `scripts/gen.py`, `scripts/fit.py`, `scripts/run.py` (fork/wait4 maxrss, RLIMIT_STACK), `scripts/minstack.py` (bisection, 16 KiB resolution).
- `cases/*.adb` are the generated sources. `out/*.txt` holds outputs.
- `build/L{4096,16384,65536,65536na}` are scratch copies of 13 recognizer units, built with pinned GNAT 16.1 `gnatmake -q -gnat2022 -gnata -gnato -g` (`na` = no -gnata). The probe driver is `build/base/probe_main.adb`. Each build took about 2.5 s.
- `gnat/` holds GNAT probes: exponent bisection (799999 OK / 800000 rejected, base 10; 2#0#E800000 and 16#0#E800000 rejected; 0E799999 34 s, 16#0#E799999 68 s, 2#0#E799999 3.5 s, 0E00000000000799999 51 s), static doubling (-gnatc 2^20 0.035 s/28 MB, 2^24 0.23 s/89 MB, 2^27 1.17 s/548 MB) and object emission (2^24 2.7 s/.o 33.5 MB; 2^26 7.6 s/.o 134 MB; .o files deleted afterwards).
- Host: ulimit -Ss 8192, -Hs unlimited; ARG_MAX 2097152; per-argument limit 131071 bytes (131072 gave E2BIG).
- Concurrency: the T3 agent was running light gnat1 -gnatc probes. No heavy prover processes were present. Background jobs b9ib3jwcr and byvwoj08d (my bisections) completed. No T1 processes remain.
