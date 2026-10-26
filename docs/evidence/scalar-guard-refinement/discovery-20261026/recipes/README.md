# #237 scratch native discovery — prepared, not executed

This directory owns scratch inputs only. It does not implement scalar flow,
change admission, amend the Oracle, change any pin/bound, or establish a pass.
The lead is the sole native/Lean runner. Preparation selected GPT-6.1 Sol Extra
High, as assigned; runtime settings are not independently exposed. Native
elapsed time, tokens and cost are unavailable because no native run occurred.

Inputs read: AGENTS.md, Oracle, selected scalar-guard record and its assessment
plus `refineOrKeep` addendum, current language scalar/condition/loop/report rules,
native condition/environment types, managed-run interface, existing division
scratch projects/retained reports, and mutable/division report-capacity records.
Authorization supplied by the lead is owner continuation `3217d34d1d`, following
division; source ownership is exclusively `tmp/guard-discovery/`.

## Native batch

Seven serial projects ask new guard-specific questions. Each Main is original
Ada/SPARK source, has only `pragma SPARK_Mode (On)`, and has no author contracts,
proof annotations, hidden replacement, or assertion. Source sizes are recorded
in `manifest.json`; each is below 4,096 bytes. These are exploratory native
projects: calling GNATprove directly does not admit them as Silver. The matrix
and composition probes are sparse; there is no dense proof/capacity rerun or
repeat of established division-only evidence.

From the main checkout, the lead can inspect and then execute these absolute
custom projects using the already installed main toolchain. Do not relocate tools:

```sh
python3 tmp/scalar-guard-refinement/tmp/guard-discovery/run.py --runner-root /home/canto/src/github.com/berkeleynerd/silver
python3 scripts/dev.py runs status
python3 scripts/dev.py paths
python3 tmp/scalar-guard-refinement/tmp/guard-discovery/run.py --runner-root /home/canto/src/github.com/berkeleynerd/silver --execute --jobs 2
```

The first command only prints the exact planned command arrays. When invoking
from the guard worktree instead, use `tmp/guard-discovery/run.py` with the same
absolute `--runner-root`; custom source/output paths remain in the guard tree. It was not run
by the preparer. `--only guards flow edges` permits a smaller initial selection.
The executing script prints managed status/paths from `--runner-root`, uses its pinned Alire tool
route via `dev.py tool`, reserves the explicit worker count, declares all
writable project roots and source/configuration inputs, and runs serially.
The application proof options match the division discovery/application recipe:
mode/report all, checks as errors, level 2, cvc5/z3/altergo, 100000 steps, timeout
0, 1000 MiB per prover, no loop unrolling, warnings continue. Each batch receives
a unique `explore/guard/<timestamp>` output subtree, avoiding stale reports.
Do not overlap with division validation merely because the output paths differ;
first check the real worker/memory headroom.

The script retains exact submitted Main/project bytes, full stdout/stderr,
complete GNATprove report/session directories, command arrays, source hash,
exit status, timings, raw `.spark` records and a separate SARIF inventory in
`results/<timestamp>/`. Expected failure is never relabelled proof success.
The status preflight includes all task labels so active division runs remain
visible. Read the complete reports and source-site correspondence; exits alone are not
an acceptance verdict. No repeat-success expensive rerun is requested here.

| Project | Expected native result, not observed | Discriminating source sites / rationale |
| --- | --- | --- |
| `guards` | Pass | 24 constrained assignments: six comparisons × direct/reversed × true/false. Each reached arm supplies the range required by its target. This covers endpoint removal for inequality as well as singleton equality. |
| `flow` | Pass | Guarded counter inside a non-unrolled loop; exact assignment replacement; unrelated scalar/String writes; both-arm hull; captured mutable upper bound changed inside the body; shadowed **outer index** fact restored; empty-loop entry flow restored. |
| `edges` | Pass | Seven endpoint-sensitive arithmetic sites: three decrements at minimum, three increments at maximum, one guarded negation. Five division sites depend on `and then`, `or else`, `not`, or Image RHS reachability. Impossible strict endpoint arms contain only a safe name read. **Proof only; never execute its full-Integer loop.** |
| `conservative` | Pass expected; inspect actual result | Three intentional Silver exclusions: crossing-zero `/=` convex hull; newly empty loop/index-dependent assignment; nonstatic immutable snapshot threshold. Native relational/vacuity reasoning may prove all three. Also includes a contradictory mutable guard with safe self-copy to exercise the nonempty fallback. These are policy controls, **not expected native failures**. |
| `unsafe` | **EXPECTED FAIL** | Five unsafe assignment-range source sites: stale target fact after replacement, explicit branch join, omitted else, preloop fact reused across iterations, hidden mutable object confused with a same-spelled index. One unsafe overflow site: negation at Integer minimum. Counterexamples and expected diagnostic classes are in the manifest. |
| `static` | **EXPECTED FAIL** | Two statically illegal expressions in impossible constant arms: maximum plus one and negation of minimum. Expect static Integer overflow/frontend rejection; retain diagnostics even if no `.spark` is produced. |
| `doors` | Pass, build, exact 100-line output match | Complete 100 doors driver with current directly referenced Silver_IO source; guard on every counter update. `-U` includes complete selected-library obligations. Only this Main is executed by the script. |

The native check **class** expectation for positive sources is the existing
range/overflow/length/nonzero-divisor set, with each emitted safety check proved;
not every source site must survive frontend simplification. Source site counts
above are exact authored-site expectations, **not invented exact report counts**.
The complete observed counts are a result of this discovery and remain pending.
No new producer class is selected. Audit unexpected records rather than widen
an acceptance policy to accommodate them.

Keep raw and normalized labels separate. Retained division empty-loop evidence
already shows raw `.spark` `VC_RAISE` with text `division check proved`; SARIF and
the documented endpoint vocabulary can say `VC_DIVISION_CHECK`. The inventory
script preserves both without equating their rule fields. Similarly, retain
initialization/unused-assignment, ineffective-statement, dead-code, exact output
ghost advisories and Image warnings with complete messages. Existing accepted
advisory schemas are described in `language.md`/`docs/assurance.md`; a label alone
is insufficient. A compiler frontend may diagnose an unsafe site before proof;
the full site-specific diagnostic remains evidence and may prevent later sites
in that file from being reported. Split just the missing site if this happens;
do not claim unreported obligations were exercised.

## Independent driver oracle

`doors.expected.txt` is already materialized. `prepare.py` derives it by a
**pass-major Boolean toggle model**, independently from the driver's door-major
visit count/parity implementation. It preserves Ada Integer Image's leading
space. Open doors are 1, 4, 9, 16, 25, 36, 49, 64, 81 and 100; all other lines
say closed. `run.py` builds and runs the exact proved Main after native success,
retains stdout/stderr/status, and compares all bytes. It uses no Silver admission
or Image adapter, so direct-native success cannot establish the eventual Silver
application/report endpoint. That remains implementation/delivery work.

## Frame/storage experiment, also unexecuted

`frame-proxy/` is standalone Ada measurement tooling, not a compiler change or
Silver application. It compares the current small result shape, two fixed
341-entry scalar interval vectors, and two active-length vectors. Each local
result remains live across a recursive call and is read afterwards. Runtime
seed/level values populate the arrays; `-O0 -fno-inline -fstack-usage` avoids a
meaningless optimized-away array experiment. The program prints actual selected
layout sizes; compiler `.su` files report frame estimates. The proxy does not
mirror the full mutual parser call graph, by-reference rules or all temporaries,
and therefore establishes neither exact parser stack use nor a universal bound.

`recognizer-shapes/` supplies exact 4,096-byte source shapes and 4,097-byte
source-limit controls. Materialized shapes are 1,988 parentheses with one scalar,
1,760 with 32, 1,026 with 128, 258 with 224; 662 not/group pairs; 305 and-then
links; 331 or-else links; 210 nested choices; 142 nested loops; and 81 loop/choice
pairs. Counts are generated from the actual bytes in `prepare_shapes.py`, not
copied from differently shaped historical specimens. The declaration/parenthesis
tradeoffs are deliberate: claiming 341 active bindings **and** maximal nesting
would ignore the common source budget. The fixed-vector representation pays for
341 entries even in the reachable one-scalar/1,988-parenthesis source.

The lead can first inspect the plan, then run the bounded storage experiment:

```sh
python3 tmp/scalar-guard-refinement/tmp/guard-discovery/measure_frames.py --runner-root /home/canto/src/github.com/berkeleynerd/silver
python3 tmp/scalar-guard-refinement/tmp/guard-discovery/measure_frames.py --runner-root /home/canto/src/github.com/berkeleynerd/silver --execute
```

It performs one managed proxy build and twelve quick runs at the existing 8 MiB
stack: current/fixed/active, each at the four jointly feasible declaration/depth
pairs. It retains build logs, `.su`, printed layout sizes, commands/status/timing
and raw outputs in `frame-results/<timestamp>/`. Expected fixed-vector stack
pressure is a hypothesis, not a reported failure. No measured result is claimed.
Two interval arrays have a source-level payload of `2 * 341 * 2` Integer fields;
if native Integer fields are 4 bytes, that is 5,456 bytes per result before
padding, headers, other parser locals or additional call frames. Multiplying by
1,989 simultaneously live proxy frames exceeds 8 MiB. Actual layout and frame
retention must be measured, and a proxy result alone cannot select storage.

For concrete current-parser baseline checks, pass the existing compiler path
reported by `dev.py paths` (do not rebuild it during the division runner):

```sh
python3 tmp/scalar-guard-refinement/tmp/guard-discovery/measure_frames.py --runner-root /home/canto/src/github.com/berkeleynerd/silver --execute --compiler /absolute/path/to/silver
```

This additionally invokes managed `silver check` for all 20 exact-source cases
at 8 MiB and records the compiler hash. The 4,096-byte sources are expected to
be admitted by current grammar; their 4,097-byte neighbors must fail the source
limit. A resource failure is an observation, not permission to reject a valid
source or raise a bound. Avoid another proxy build/run just to add compiler
baseline evidence: the script is a recipe; the lead may reuse successful proxy
artifacts and run only the new concrete question. After implementation, reuse
identical shape bytes for candidate checks and obtain `.su` for actual changed
recursive functions (`Read_Primary`, `Read_Relation`, `Read_Condition`, chain,
choice and loop bodies). Check the chain/nested-loop interaction as well as
parentheses. Until those actual measurements exist, a representation choice is
provisional. No stack architecture or deferred capacity package is resumed.

## Report-envelope delta question

The new flow analysis adds no authored operation, conversion, entity, library or
check site. Existing producer review independently charges assignment/declaration
roots (`floor(S/5)`), comparisons (`floor(S/3)`), 63 arithmetic/String operators,
scalar declarations, loop roots and up to two traversals of each textual Image;
flow advisories have `2*S` coverage. These counts were not conditioned on old
static elimination. Thus more precise guard flow may retain or remove records
within already charged source vertices, rather than multiply them by paths or
iterations. Threshold comparisons already exist in the grammar; the compiler
must pass the same original source to native proof/build.

The division extension conservatively retains overflow and one nonzero-divisor
allowance per arithmetic occurrence. On the existing source/producer premises,
the resulting candidate envelope remains 15,421,440 of 16,777,216 retained bytes,
with 1,355,776 bytes headroom. No new allowance is inferred from the sample
reports. The lead still needs to review the exact selected native producer paths
against observed altered-elimination records, dependencies and Image diagnostics;
new record multiplicity/schema would be a specific missing argument to resolve,
not reason to silently change storage. This source-level delta reuses
`docs/bounded-mutable-report-capacity.md`,
`docs/integer-division-report-capacity.md` and `docs/report-capacity.md`; it does
not replace full source correspondence, complete discharge, or universal proof.
