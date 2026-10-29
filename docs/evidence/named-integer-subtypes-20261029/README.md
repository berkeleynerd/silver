# Named Integer subtypes validation — 2026-10-29

Final validation is in progress for [#286](https://github.com/berkeleynerd/silver/issues/286)
and [draft PR #289](https://github.com/berkeleynerd/silver/pull/289). The complete
native proof and Lean/source/module/axiom validation remain pending on the
repaired source. The one failed native equality has passed focused validation
and independent review. The original full regression suite passed; the
46 results affected by the proof repair have passed their final-input reruns.
The authorized delivery ends with a
reviewable feature PR; merging it awaits the owner's instruction.

The implementation and final code-review target is
`6020416906b5fc3d2bd10d012e70937c80f0617c`. The
[integration review](../../reviews/review-named-integer-subtypes-final-integration-97312a790f.md)
covers the preceding implementation `97312a790f`. The
[Body_Tail repair review](../../reviews/review-named-integer-subtypes-body-tail-equality-20261029.md)
covers the final source change, its mechanical pin/certificate refresh and
regression applicability. Final complete-evidence confirmation remains pending.

## Failed complete native checkpoint

Run `20261029T165015-c6b111fb4f2a` finished at 20:29 UTC with tool exit 1 after
13,129.891 s. Exactly one of 15,385 proof entries remains unresolved:
`Body_Tail`'s static equality to `Body_Tail_Model`, at
`src/silver_output_profile.adb:3414:20`. The 1,432 flow entries passed, and all
76 unit reports were emitted. This is not a complete native success: the final
coverage/provenance audit did not run and no success manifest was produced.

The [failed packet](native-full-reuse/failed-full/README.md) retains the original
reports, inputs, tool identities and managed outcome. The
[diagnostic](native-full-reuse/body-tail-diagnostic/README.md) records the failed
Why3 goal and corrects the provisional completed-session observation. A focused
ghost-equality repair is in progress in an isolated workspace. The pre-repair
Lean run was cleanly interrupted at 20:40:43 UTC after 15,742.412 s, before any
captured input changed. Its [original logs and event record](runs/20261029T161817-0a8089cd7dc3/retained.json)
retain the interrupted outcome. The output body certificate completed, but
`ComposeSourceCandidate` was still running; the complete build and fresh audit
did not finish. Both expensive source candidates depend on the complete output
pin, so finishing those old-input checks would not validate the required source
repair. Completed objects remain preserved for normal dependency-checked reuse.

## Repaired source checkpoint

The repair adds eight lines to `Body_Tail`: six Static ghost/assertion/call lines
and two comments. Existing flow-equality lemmas make the final scan equality
explicit. The endpoint contracts, admission rules, runtime statements and prover
settings are unchanged. The pinned SPARK Static policy erases the added work
from runtime builds; it adds no recursive model execution or scan-frame copy.

Focused run `20261029T203414-0517c9b1e3dd` passed 62 proof and 287 flow checks
in 1,179.240 s, with all 330 Body_Tail session goals proved. The
[focused packet](native-full-reuse/body-tail-repair/README.md) retains the actual
three report files, 50 classified warning entries, input identities and exact
erasure references. Independent review found and corrected an initially empty
report archive; it confirmed the corrected packet without rerunning proofs.

Complete Lean run `20261029T205735-bb72d0625415` now checks the repaired source
with one worker/thread and 24,576 MiB per-process allowance. All 653 captured
inputs match `6020416906`; the [repair input comparison](repair-input-applicability.json)
identifies the three changed files. Native build `20261029T210150-1086727daf3c`
passed on matching governed inputs. All 46 affected tests passed; their
[repair regression packet](repair-regression/README.md) accounts for 509
applicable original results plus 46 refreshed results, covering all 555
identities. Complete native run `20261029T211041-a76eb6753f23` is active with
four workers in the retained native workspace; all 143 tracked inputs match
`6020416906`. Complete native and Lean outcomes remain pending.

## Retained completed checks

| Run | Scope | Outcome |
| --- | --- | --- |
| `20261029T144520-fb1a3732d7f3` | New subtype regressions on the earlier native draft | Ten tests passed, including native proof/build/execution; superseded inputs remain identified by the run |
| `20261029T145959-ad36e50b8dc3` | Sum of squares and Sum and product drivers | Admission, proof, compilation and execution passed with the manifest outputs |
| `20261029T152349-f75d7ed9d693` | Interpreted Compose helpers | Passed; fresh audit of 10,591 declarations |
| `20261029T153109-c0a06d180fd0` | Pre-repair native build after the earlier ghost equality repair | Passed, 12.178 s |
| `20261029T153154-c4df9862d2d0` | Corrected capacity regression | Three tests passed |
| `20261029T153446-d943972d9cb8` | Generated certificate parity | All 28 certificates regenerate byte-identically |
| `20261029T153928-8c628fb8b8bb` | Shared composition equations | Passed; fresh audit of 10,653 declarations |
| `20261029T154650-8200a2184daf` | Recognition/model equations and retained Sequence model | Passed; fresh audit of 20,836 declarations |
| `20261029T161019-1954ab856759` | Scalar-array recursion and native Predicate helper/library closure | Passed; fresh audit of 35,005 declarations |
| `20261029T153819-5626949ad567` | Full regression and sample suite | Passed: 555 tests, 5,255.763 s unittest time / 5,259.531 s managed duration |
| `20261029T170712-d9dc75fa5629` | Pre-repair proof-source tests, including certificate parity | Passed: 12 tests |
| `20261029T170846-5ccd1f3667b8` | Platform fixtures using the pre-repair proof tree | Passed: 16 tests; platform behavior is mocked, not native macOS validation |

`runs/` contains original managed events and available outputs, compressed without
changing their decompressed bytes. Each `retained.json` gives the original source
directory, completed event and file hashes. The
[annotation packet](native-logical-equality/README.md) and
[Predicate closure packet](native-predicate-closure/README.md) retain the failed
and interrupted attempts alongside their focused repairs. A successful focused
audit does not substitute for the complete checkpoint.

## Input identity and reuse

The original [input comparison](input-applicability.json) checks every captured source
input from complete Lean run `20261029T161817-0a8089cd7dc3` against the implementation:
653 of 653 match that pre-repair implementation. The 28 generated certificates are regenerated by the checker
rather than included in that map; parity is separately recorded above. This
comparison establishes input identity, not success of the interrupted run.

The integration workspace began with the retained Lake cache from
`tmp/constant-array-source`, whose previous complete success was
`20261029T084327-720db926b71b`. It subsequently reused the checked
[model closure](model-cache-transfer.json) from run `20261029T154650-8200a2184daf`
and [native Predicate closure](native-predicate-cache-transfer.json) from run
`20261029T161019-1954ab856759`, after source/tool/configuration comparison.
Normal Lake rehash and fresh audits remain enabled. This is incremental
validation, not a clean build or independent kernel replay.

## Regression applicability

Full suite `20261029T153819-5626949ad567` passed on validation commit
`671a4e7931d25dc1d1bc3d2591c1f5bca25a646b`, whose tree equals implementation
checkpoint `2a4cdceb0c3f645d8b5f1b852fb33fbae6cec935`. Of its 800 captured inputs,
787 tracked files match the pre-repair implementation `97312a790f`, five Lean files changed, and
eight identify workspace/generated/tool inputs. The exact differences are in
the original input comparison. At that pre-repair target, compiler sources,
scripts, tests, samples, catalogue and captured Rosetta inputs match.

The log reconciles exactly with all 555 identities in the discovery inventory;
each has an explicit successful outcome. The manifest test admitted, proved,
compiled and executed all 52 sample sources, covering 108 executions including
argument cases. The full suite retains its successful outcome; the two module
reruns below refresh applicability after the later proof edits.

The independent integration review required `test_lean_source.py` and
`test_platforms.py` to run again on the five pre-repair proof edits. Both reruns passed
on matching inputs. The [original reconciliation](repair-regression/prior-test-reconciliation.json)
accounted for 527 applicable full-suite results plus 28 freshly rerun results,
covered all 555 identities at `97312a790f` with none missing or failed.
The repair review subsequently requires 46 refreshed identities: those same
28 tests, all 17 output-integrity fixtures, and the single Silver integration
fixture that rebuilds current sources while exercising tool/source failures.
The other 509 results remain applicable because the repair is erased Static
code and its source/proof dependencies are identified in that review. The
46 repaired-input results have now passed. The current
[reconciliation](test-reconciliation.json) records 509 retained results plus
46 new passes, with no missing or failed identity. All 792 tracked inputs in
each of the four reruns match `6020416906`; the original passing runs retain
their outcomes and input scope. Run `20261029T210251-939fbc67799b` includes
final byte parity for all 28 generated certificates.
The [discovery inventory](test-inventory.json)
contains 555 unique unittest identities, including nine shared-binding methods
executed through two module import names: 546 methods after excluding those
duplicate executions. The original full suite remains successful; the
reconciliation identifies all replacement results. Any later Rosetta delivery
metadata edits will receive their affected renderer tests.

The full suite reserves four workers. Its agent-authored
[affinity record](regression-affinity.json) records restricting unittest and its
descendants to CPUs 8–11 while the managed runner retains host affinity. The
production application's `-j0` setting is unchanged.

## Resource observations and limits

The [stack packet](stack/README.md) records successful admission, compilation and
execution under an actual 8 MiB process stack for 4,096-byte sources with 158
singleton foreach levels, 141 counted-loop levels and 208 conditional levels.
The earlier exponential-execution probe retains its interrupted outcome. These
are observations of the identified shapes, not universal stack or runtime bounds.

All evidence here is Linux x86_64. No native macOS, hosted CI, clean Lean build,
independent kernel replay or external review approval is claimed.
