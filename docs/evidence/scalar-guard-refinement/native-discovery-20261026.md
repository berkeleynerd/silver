# Scalar guard native discovery

2026-10-26, authorized #237 following division #229. The owner continuation on
main `3217d34d1d` selects guards next. The guard planning input is
`12dbab608b564068260798e583ec551ffa969606`; the selected rules and proof design
remain [the capability record](../../scalar-guard-refinement.md) and
[implementation/proof design](proof-design-20261026.md).

Five positive native projects passed, the complete doors driver built and
matched its independent oracle, both illegal static expressions were diagnosed,
and six **isolated** unsafe controls each failed at its intended site. These are
ordinary original Ada/SPARK discovery inputs. They establish neither Silver
admission nor the universal automatic-discharge/source guarantee. No Oracle,
grammar, library, tool pin, source/operator bound or deferred #119 scope changes
are selected by this evidence.

## Retained inputs and reproducible checks

The [evidence index](discovery-20261026/README.md) links the exact Main/project
sources, complete raw `.spark` and SARIF reports, `gnatprove.out`, compiler and
proof stdout/stderr, frame sources and logs, expected/actual driver bytes, and
the [27 managed run records](discovery-20261026/run-index.md). Events retain exact
command arrays, UTC times, worker reservations, prepared tool/input hashes and
native phase outcomes. The native projects use level 2, all reports/checks,
cvc5/z3/altergo, 100000 steps, timeout 0, 1000 MiB per prover, two workers and no
loop unrolling. Frame commands reserve one worker. The event snapshots record
Alire 2.1.1, GNAT/GNATprove 16.1.0 and the actual tool binary hashes; no tools were
relocated or changed. The native platform is Linux x86_64, `codex-silver`.

The portable [verification](discovery-20261026/verification.json) passed using:

```sh
python3 docs/evidence/scalar-guard-refinement/discovery-20261026/verify.py
```

This read-only check invokes no native tool. It checked the 334 retained original
files against the [retention manifest](discovery-20261026/retention-index.json),
all 27 copied immutable event streams, and **60 nonempty** source/project/runtime
comparisons against prepared-event SHA-256 captures. It also regenerated the
doors expected bytes independently, checked the actual diagnostic sites, and
compared positive Main raw/SARIF class counts and exact advisory fields. It is a
focused evidence consistency check, not a substitute for the compiler's complete
report audit or source-correspondence proofs. Gzip uses `mtime=0`; solver
sessions, objects and binaries are omitted. Complete proof trees remain inside
the retained `.spark` files.

## Actual source and Main-check results

The [complete Main-check table](discovery-20261026/main-checks.md) maps every
reported Main proof record to an exact retained source line and column. The
machine-readable [analysis](discovery-20261026/analysis.json) preserves raw and
SARIF records separately, including full message text and runtime roles.

| Original Main | Bytes | Native status | Actual Main proof records | Interpretation |
| --- | ---: | --- | --- | --- |
| [guards](discovery-20261026/native/guards/src/main.adb) | 1,409 | 0 | 24 range, all proved/info | All six operators, each direct/reversed and true/false, emitted the intended target-assignment checks. |
| [flow](discovery-20261026/native/flow/src/main.adb) | 1,061 | 0 | 7 range, all proved/info | Guarded counter; exact replacement; unrelated writes; branch hull; captured mutable bound; restored shadowed outer index; empty loop. |
| [edges](discovery-20261026/native/edges/src/main.adb) | 1,042 | 0 | 7 overflow + 5 division, all proved/info | Strict minimum/maximum guards, negation, `and then`, `or else`, `not`, and reached Image argument. Proof only: its full-Integer loop was not executed. |
| [conservative](discovery-20261026/native/conservative/src/main.adb) | 609 | 0 | 2 division, both proved/info | Native relational/vacuity reasoning proves selected Silver exclusions. This does not justify widening selected admission. |
| [combined unsafe](discovery-20261026/native/unsafe/src/main.adb) | 919 | 1 | 2 unproved range; later 3 range + 1 overflow info | Only the first two failures are independent controls; the later four are vacuous after earlier failure assumptions. |
| [static](discovery-20261026/native/static/src/main.adb) | 260 | 1 | No `.spark` or SARIF | Both impossible constant arms receive frontend static Constraint_Check errors. |
| [doors](discovery-20261026/native/doors/src/main.adb) | 529 | 0 | 3 range + 2 division, all proved/info | Complete 100-door driver, followed by successful build and exact output comparison. |

Thus the positive projects contain **50 proved Main safety records**. Their raw
classes are existing `VC_RANGE_CHECK`, `VC_OVERFLOW_CHECK` and
`VC_DIVISION_CHECK`, with their exact `... check proved` messages. No new class
was observed. No length record survived these particular inputs. Raw and SARIF
counts agree for these reports; historical `VC_RAISE` normalization is not needed
to interpret this batch.

The complete positive Main advisories are two `DEAD_CODE` / `this statement is
never reached` records at edges `17:29` and `18:29`; one `INEFFECTIVE` /
`initialization of "Visits" has no effect` at doors `4:4`; and the exact existing
`imprecise-image` message once at edges `25:32` and twice at doors `14:37` and
`16:37`. The flow advisories have warning severity, flow provenance and empty
proof trees. Image advisories retain warning/trivial/empty-tree fields and the
raw empty suppression value; their SARIF records retain open/warning and the
external suppression marker. No additional positive Main advisory was observed.
Individual solver attempts include failures in complete proof trees; every
positive safety record nevertheless has a proved/info result. An individual
solver failure is not counted as a failed obligation or erased from retention.

The doors `-U` run also proves the **original selected runtime** separately:
`silver_io.spark` has 36 proof records (13 range, 8 index, 5 overflow, 4 invariant
initialization, 4 invariant preservation, 2 postconditions) and 12 flow records
(10 initialization and 2 data-dependency records). `silver_output_libc.spark`
has no proof/flow/warning records. These library classes are not Main acceptance
classes. Complete runtime metadata, source and reports are retained. The native
summary's 53 proved checks comprise 5 Main + 36 runtime proof + 12 runtime flow
checks; advisories are separate.

## Failure controls and conservative cases

The original combined unsafe source fails at `11:18` (high) and `17:15`
(medium), both `VC_RANGE_CHECK` / `range check might fail, cannot prove upper
bound for (X + 1)`. Its later `22:15`, `27:42`, `32:36` and `37:12` info records
cannot demonstrate rejection of those unsafe sites. The lead therefore ran only
the missing discriminating work as six isolated originals; no successful
positive case was repeated. Each isolated run returned 1 and has exactly one
unproved high-severity record at its designated source location:

| Isolated source | Bytes | Site | Raw diagnostic |
| --- | ---: | --- | --- |
| [stale replacement](discovery-20261026/negative/stale_replacement/src/main.adb) | 226 | 9:18 | `VC_RANGE_CHECK`, upper bound for `(X + 1)` |
| [branch join](discovery-20261026/negative/branch_join/src/main.adb) | 221 | 8:15 | `VC_RANGE_CHECK`, upper bound for `(X + 1)` |
| [omitted else](discovery-20261026/negative/omitted_else/src/main.adb) | 208 | 8:15 | `VC_RANGE_CHECK`, upper bound for `(X + 1)` |
| [loop reentry](discovery-20261026/negative/loop_reentry/src/main.adb) | 243 | 8:42 | `VC_RANGE_CHECK`, upper bound for `(X + 1)` |
| [minimum negation](discovery-20261026/negative/minimum_negation/src/main.adb) | 243 | 8:36 | `VC_OVERFLOW_CHECK`, upper bound for `(-Wide)` |
| [shadowed mutable](discovery-20261026/negative/shadowed_mutable/src/main.adb) | 243 | 9:12 | `VC_RANGE_CHECK`, upper bound for `Wide` |

These remain proof failures, not native passes. The static source independently
diagnoses both `Max + 1` at `7:34` and `-Min` at `8:30`: `value not in range of
type "Standard.Integer"` and `static expression fails Constraint_Check`. Native
success of an impossible arm cannot waive either static illegality.

The conservative source's crossing-zero `D /= 0` division and nonstatic snapshot
threshold division are proved natively at `11:30` and `21:36`. Its newly empty
loop/index-dependent assignment and contradictory mutable self-copy emit no
proof records. The selected Silver convex-hull, static-threshold and nonempty
assignment rules remain intentional restrictions; sample native success supplies
no universal `refineOrKeep` argument and no admission-monotonicity claim.

## Complete 100-door execution

The driver's door-major visit count/parity implementation and the expected
pass-major Boolean-toggle model use different computations. The retained
[expected bytes](discovery-20261026/native/doors/expected.txt) and
[actual bytes](discovery-20261026/native/doors/program.stdout) are identical:
100 lines, 1,372 bytes, SHA-256
`3225966de56a69f5097ba77497b24195b548445c1f169b776f6cfafc007d338a`.
Open doors are 1, 4, 9, 16, 25, 36, 49, 64, 81 and 100. Every line preserves
Integer Image's leading space and says ` is open` or ` is closed`, followed by
LF. Build and execution returned 0; execution stderr is empty.

Proof and build prepared-event captures match the same nonempty Main/project
bytes and all three selected runtime source files. The runner built that original
Main and executed its `bin/main`; execution status is retained in `run.json` and
byte comparison is independently repeatable. Execution itself was a direct
subprocess rather than a separate managed event, and no binary attestation is
claimed. This native project does not exercise Silver admission, its generated
application project, or the eventual application report endpoint.

## Frame/storage observations and limits

The [standalone proxy](discovery-20261026/frame/proxy/src/main.adb) builds with
`-O0 -fno-inline -fstack-usage`. Each result stays live across recursion and is
read afterwards. All twelve proxy runs used an 8,192 KiB stack. Counts and depths
come from the same 4,096-byte source budget, rather than combining maximum
bindings with maximum nesting independently.

| Active scalar count | Parenthesis depth | Current-shape proxy | Fixed 341-cell vectors | Active-length vectors | Active result bytes |
| ---: | ---: | --- | --- | --- | ---: |
| 1 | 1,988 | 0 | 1, stack overflow | 0 | 48 |
| 32 | 1,760 | 0 | 1, stack overflow | 0 | 544 |
| 128 | 1,026 | 0 | 0 | 0 | 2,080 |
| 224 | 258 | 0 | 0 | 0 | 3,616 |

The printed interval size is 64 bits. Current result size is 224 bits (28 bytes),
fixed result size is 43,872 bits (5,484 bytes), and active result sizes are shown
above. The compiler's [`.su` report](discovery-20261026/frame/results/main.su)
records `Current` 96 bytes static, `Fixed` 5,552 bytes static, and `Active` 96
bytes **dynamic**; the latter is not the total active-array storage. Both fixed
failures explicitly report `STORAGE_ERROR : stack overflow or erroneous memory
access`. The source-level payload calculation and these observations rule out
treating two full fixed vectors as a harmless small recursive result.

All four **current-shape proxy** runs succeeded. No existing or changed Silver
parser was executed in this experiment: `recognizer` is empty in the frame
summary. Twenty exact source shapes (4,096-byte specimens and 4,097-byte
neighbors) are retained, not claimed to have passed. The proxy omits the actual
mutual parser graph, calling conventions, overlays and multiple simultaneously
live condition temporaries. Active-length success makes it a candidate, not a
parser-capacity proof or sufficient representation decision. The implementation
must settle those live temporaries and measure the actual changed recursive
functions, chains, choices and loops, then run the retained exact-limit shapes.
No universal frame bound is inferred here.

## Feature-local retained report delta

Reuse the source-derived [mutable](../../bounded-mutable-report-capacity.md),
[division](../../integer-division-report-capacity.md) and
[baseline](../../report-capacity.md) producer reviews, with their unchanged
producer/frontend/tool premises. Scalar flow changes Silver's analysis of the
same original source; it adds no authored operator, conversion root, type/entity,
call, Image traversal or library. Comparisons are already in the grammar.
Preserving declaration staticness is necessary: an inferred singleton is not a
new static constant, and these checks do not authorize replacing source by
annotated or simplified text.

The existing counting argument charges source vertices before relying on which
ones survive static elimination: assignment/String roots `floor(S/5)`, scalar
comparison roots `floor(S/3)`, declaration roots `floor(S/13)`, two loop-bound
roots per `floor(S/18)`, the shared 63 arithmetic/String operator budget, the
additional 63 division-check allowance, and up to two traversals per textual
Image. The `2*S` flow allowance and fixed metadata/library envelopes are retained.
Altered elimination may retain more of those already charged sites; paths and
loop iterations do not become authored copies or multiply these buckets. The
observed new reached checks/advisories use those existing classes and schemas.
The feature-local **additional charge is zero**, giving the unchanged division
envelope of **15,421,440 < 16,777,216 bytes**, with **1,355,776 bytes** headroom.
This is a delta argument on the existing source/producer premises, not a bound
inferred from these sparse report sizes and not a reopening of #119. Candidate
implementation must preserve these premises and complete report/source checks;
a new record multiplicity, entity or schema would require revisiting this local
argument before claiming support.

## Remaining obligations and round record

Native discovery resolves the observed automatic-check class and site questions.
It does not implement scalar flow or prove its composition. Native work must
still preserve staticness/binding identity, carry reached flow into every scalar
and Image read, replace assignment facts, join branches, capture loop bounds
before widening, and restore indexes/empty-loop entry facts. Representation and
actual recursive-frame checks above remain required. Compiler Bronze/Silver
verification, complete application/library report audits, universal containment
and automatic-discharge proofs, typed arbitrary-callee/source correspondence,
full source/axiom checks, samples/regressions and independent integrated review
remain implementation/delivery obligations in #238–#240.

The retained corpus is sparse. It does not separately exercise `elsif`, a
parenthesized scalar target's intentional nonrefinement, a complete
input-length-fact/scalar-write/live-Image composition, or every selected
loop-exit/outer-index transfer case. Exact-limit shapes are only prepared. Such
candidate regression/source-proof obligations are not reported as discovery
passes. No unexplained Main diagnostic or missing intended isolated failure
remains in these completed native reports.

| Round | Selected settings | Intended and achieved result | Available measurements |
| --- | --- | --- | --- |
| Bounded retention/extraction | GPT-6.1 Sol, Extra High, as assigned; actual runtime model/effort not independently exposed | Retained exact completed inputs/reports/events, checked 60 nonzero source correspondences, separated vacuous combined controls and runtime roles, regenerated exact driver output, and documented the proxy's limits. No native/proof runner, GitHub mutation or implementation edit performed by this subthread. | Artifact construction/check interval 00:34:10–00:40:08 UTC, 5m 58s; earlier inspection elapsed is unavailable. Tokens/cost unavailable. Native managed intervals, distinct from extraction elapsed, are in the run index. |

The retained managed intervals total 111.543 seconds for seven native proofs plus
the driver build, 49.955 seconds for the six isolated failures, and 69.264 seconds
for the proxy build and twelve proxy executions. These sums include managed
preflight; individual native-tool phase timestamps remain available and are not
conflated with overall agent elapsed time. Successful positive runs were reused.
