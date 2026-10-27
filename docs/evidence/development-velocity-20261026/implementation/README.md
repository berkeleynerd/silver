# First #246 implementation: validation and measurements

Implementation: `80d5ec3e0e5224fe36c705f6be15e429b7fa7468`.
Baseline: `e94c8b4343f429c434900cc2a23e29e870f577bf`.
Linux x86_64, 12 available CPUs, approximately 31 GiB RAM, no swap;
pinned Lean 4.34.1. The [delivery record](../../../development-velocity.md)
explains the change and the retained assessment.

The matched comparison, complete source checks, serialized predicate diagnostic
and invalidation controls passed. The
[final independent review](../../../reviews/review-velocity-final-80d5ec3e0e.md)
records their scope and qualifications.

## Complete validation and comparison

AFTER ran first; both cases passed their complete build and fresh module/private/
transitive axiom audit with exactly `propext`, `Classical.choice` and `Quot.sound`.

| Measurement | BEFORE | AFTER |
| --- | ---: | ---: |
| Build seconds | 9,567.554 | 6,891.336 |
| Complete managed check seconds | 9,591.191 | 6,914.489 |
| OS child CPU seconds (user + system) | 13,218.534 | 13,604.191 |
| Rebuilt modules / audited modules | 19 / 497 | 20 / 498 |
| Largest-child RSS, GiB | 16.81 | 16.70 |
| Minimum sampled host available memory, GiB | 13.13 | 12.55 |

The build saving is **2,676.218 s (44.60 minutes), 27.97%**. Total CPU work did
not fall. AFTER audited 104,251 declarations. BEFORE is managed run
`20261027T001557-ba6697079c60`; AFTER is `20261026T221956-84d1b4b6e429`.
Both use independent copies of the original retained warm seed, two Lake
workers, two Lean threads and a
24,576 MiB per-process threshold. A one-second monitor records process CPU/RSS
and host available memory, stopping this experiment below 3 GiB headroom.

The workload forcibly removes artifacts for `OutputBodyCertificate`,
`PredicateSourceCandidate`, `ComposeSourceChecks` and their importers; AFTER
also includes `ComposeSourceCandidate`. Ada bytes and reviewed tokens stay
unchanged. Actual rebuilt modules are checked against both the Lake log and
changed or created `.olean` files. This measures the selected reconstruction
workload, not a clean build or an actual new feature edit. The fixed AFTER→BEFORE
order, single pair, host and filesystem-cache drift limit generalization.
No other dense managed run overlaps either case. Independent kernel replay,
macOS and hosted CI are not claimed.

| Heavy module, Lake seconds | BEFORE | AFTER |
| --- | ---: | ---: |
| OutputBodyCertificate | 6,257 | 6,447 |
| PredicateSourceCandidate | 3,174 | 3,296 |
| ComposeSourceCandidate | absent | 3,266 |
| ComposeSourceChecks | 3,261 | 2.2 |

AFTER starts the expensive composition candidate alongside the certificate;
the predicate candidate follows it on the second worker. The authoritative
composition adapter waits for the output source bridge and then finishes in
2.2 s. BEFORE puts the 3,261-second composition module after the certificate.
These scheduling observations explain the wall-time reduction without claiming
that the individual decisions became faster.

The successful AFTER run reached 16.70 GiB largest-child RSS and a minimum
12.55 GiB sampled host headroom. A per-process Lean threshold is checked
periodically; it is not an aggregate memory cap. Sampled RSS can miss endpoints,
and summing process RSS can count shared pages more than once. OS child CPU
measurements are distinct from Lean's traced elapsed intervals.

## Profiles and retained diagnostic history

The certificate and original predicate profiles used one worker, two threads
and 16,384 MiB. Their focused audits passed. Instrumented times are not timing
baselines. The certificate's line proofs account for 74.79% and joins for 24.62%
of 5,972.995 s of named traced elapsed time. These percentages do not partition
global wall time or CPU, and do not separate lexing from string conversion.

The normal-async predicate profile contains overlapping environment waits:
332,316.920 s of summed kernel-labelled scopes during a 3,120.989 s frontend.
Its declaration ranking is rejected. Module wall/CPU/RSS and the focused audit
remain valid; the original analysis is retained as invalid, alongside the
corrected summary. The separately labelled serialized diagnostic passed:
launcher wall 3,116.599 s, build 3,093.775 s, focused audit 8.183 s. It changes
only scratch instrumentation, not a supported build setting.

The original strict one-stream assertion rejected two additional
`Lean.Meta.realizeConst` reporting streams, together containing only 0.028499 ms
of unnamed work and no kernel/declaration frames. The saved primary-stream
projection passed the unchanged interval validator: its positive slices exactly
cover the 3,081.945 s frontend; 356 kernel scopes have maximum overlap one;
named and unassigned time conserve the span. Every named cost is identical to
the original ranking. These are exclusive traced elapsed costs for the
serialized diagnostic, not normal-async service or CPU measurements.

| Largest named predicate declarations | Diagnostic traced seconds |
| --- | ---: |
| `native_flow_checked` | 284.762 |
| `native_workers_checked` | 284.024 |
| `native_scalarHelpers_checked` | 275.157 |
| `native_readers_checked` | 164.331 |
| `native_condition_tail_spec_header` | 142.816 |

The [attribution review](../../../reviews/review-velocity-profile-attribution.md)
preserves the original async diagnosis. The serialized case retains the
additional-stream diagnosis, primary ranking and conservation checks.

The first warm complete C1 attempt failed at the 16 GiB threshold in two
long-header decisions after 54.62 minutes. The failure stays failed. A focused
reduced-context check copied the exact two propositions and proof bodies and
passed at 24 GiB in 524.975 s, with 16.60 GiB largest-child RSS. The subsequent
complete AFTER checkpoint establishes the complete candidate's success at the
revised limit. No proof, pin, generator or supported runner changed to repair
this resource failure. The stopped original sequence and revised plan are
retained separately.

## Applicable retained evidence and regressions

The [native-input comparison](native-reuse.json) retains complete native run
`20261026T121322-fc9f4056f886`. The
[independent applicability review](../../../reviews/review-velocity-evidence-reuse-80d5ec3e0e.md)
confirmed all 2,519 captured files, 141 tracked native inputs and 12 tool hashes.
There was no fresh GNATprove execution.

The current 503 unique test methods (512 standard-discovery entries, including
unchanged duplicate discoveries) are covered by applicable retained successes
and repair reruns plus 92 successful current focused tests: 73 Lean-related,
16 platform-isolation and three Rosetta tests, with no skips. The retained full
suite stays labelled failed. No new aggregate full-suite pass is claimed.

## Dependency controls

Eight Lake `--no-build` checks in a separate copy of the successful AFTER cache
passed. Both normal targets were current. Appending a comment to the authoritative
Ada body while restoring its timestamp left `ComposeSourceCandidate` current
but made `ComposeSourceChecks` report `OutputProfileBodySource` stale. Changing
one reviewed implementation token made the candidate report `ReviewedOutputShape`
stale. Restoring the bytes restored both targets. Fifteen observed `.olean`,
`.olean.server` and `.olean.private` artifacts retained their hashes and mtimes.
No proof was rebuilt; exit 3 identifies a stale dependency frontier, not every
stale target. The logs and [control result](invalidation/result.json) are retained.

Raw profiles, compressed logs/samples and original managed events are retained
with the summaries. Scratch measurement/control scripts are evidence of the
method, not additions to the supported runner. Original worktrees and caches
remain on the implementing host.
