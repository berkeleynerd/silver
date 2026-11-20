# PR #403 delivery evidence recovery — 2026-11-20

The recovered records establish complete applicable validation for the sample
implementation at `001c50dce1bcf3ad2d174b4426f684fe78cb2e64` (tree
`77b0d2c24ebc37a69fcca2edabf5ddd93aee391a`), on main
`a03c7987bbba29569db2709820bd26ced20bed40`. This continuation changes delivery
records only. The [original implementation packet](../README.md) remains a
historical focused checkpoint; its pending-validation statements are superseded
by this record. The [independent closing review](../../../reviews/review-bounded-string-building-closing-20261120.md)
accepted the implementation and frozen delivery inputs with no material findings,
from 13:00:21 to 13:03:58 UTC on November 20. External review remains pending.
No merge or post-merge bookkeeping is claimed.

## Regression and sample coverage

The [independent regression review](recovered-regression-review.md) reconstructs
the original complete run from its raw log and exact inputs. Run
`20261118T173931-305d1781f71e` finished **724 tests: 722 passed, two ARM-specific
skips**, in 1,128.481 unittest seconds (1,128.900 managed seconds). The former
712/710 headline was a parser subtotal: twelve further tests printed intervening
output before their successful `ok`. The original log is preserved unchanged.

All four original runs captured identical inputs: 1,340 repository files match
the PR, and eight support files match recovered compiler/generated/context/Python
bytes. The recovered checked commit `7d5967240779a46f73d1c29746d77e530f81f906`
has exactly the PR tree. The compiler build `9b5b2d99aaf6f4bfca5226b36af744502b095990`
has identical governed compiler inputs. Original workflow exit records and test
phase exits are zero; final managed outcome is success. Its final-event return
code is null, the normal context-manager default, and has not been rewritten.
Contemporaneous after-run input comparison is retained alongside receiver checks.

Fresh x86 run `20261120T125015-03ea0dfd16e0` passed precisely the two skipped IDs
in 3.816 unittest seconds (4.749 managed seconds). Its repository inputs match
the PR and the retained ARM run; all eight current support inputs also rehash.
Thus **722 retained ARM passes + two fresh x86 passes cover all 724 final IDs**.
The two results are not a new x86 full suite. The existing shared-binding
discovery identities remain counted as the suite runs them.

| Retained focused run | Result | Unittest seconds |
| --- | --- | ---: |
| `20261118T173513-f3c45b223d1e` | String/Character: 18 passed | 22.123 |
| `20261118T173536-c2d8662ad230` | Manifest: two tests passed, 90 programs / 153 cases | 230.875 |
| `20261118T173927-90b8193aa993` | Rosetta: 12 passed | 2.466 |

All four new samples completed their application proof/audit/build/execution
routes. The entire bottles output is 495 lines / 11,357 bytes. Independent
inspection confirms whole-literal append/prepend refusal, exact fit, reverse
shift order, logical clear/reuse, and the repeat fixture's complete 0..10 domain.
Ten earlier focused full routes passed and five negative controls rejected as
expected. No failed or interrupted #400 test run was found in the recovered
registry; `develop-check-failed.md` duplicates the successful report.

Rosetta accounting is independently reproduced: 86→90 programs, 149→153 cases,
85→89 Stage 1 tasks, twelve assessment changes, only four surface mappings,
and 472 generated pages (twelve content changes, 460 position-only changes).
All 63 existing construct Stage values stay unchanged. Broad `string-building`
remains unsupported and #395 stays open. Live issue/project reconciliation is
expressly post-merge.

## Complete assurance applicability

The [assurance recovery addendum](assurance-applicability-recovery-addendum.md)
accepts C9 and the assurance component of C8 under the existing sample-batch
reuse policy. It supersedes missing-byte observations in the
[initial review](assurance-applicability.md). No compiler, runtime, proof,
auditor, build, catalogue or Oracle input changed in this PR.

Retained complete Linux ARM64 native run `20261117T034048-8c22c1e6a33d` and build
`20261117T055412-08a00820e2ef` cover **19,726 discharged checks** (1,751 flow,
17,975 proof; 78 units / 1,252 entities). The current Python auditor freshly
accepted all 80 retained reports. All 147 native and 1,142 Lean repository inputs
match; all 40 source candidates freshly regenerate byte-identically.

Retained complete Lean run `20261117T064945-d458c99ae977` covers **1,035 modules /
166,332 declarations**, with only `propext`, `Classical.choice` and `Quot.sound`.
The recovered merged workspace has exactly the recorded 1,037 inputs and 6,202
compiled artifacts (1,304,912,624 bytes). All hashes match; all 1,035 build traces
pass the current kernel-bypass policy. The lower and upper overlay layers alone
are incomplete; the receiver checked the merged view and resolved archive
hardlinks. Original tool markers and source-link spelling remain intact.

All 2,622 native inputs were locally rehashed: 147 PR files and 2,475 recovered
support files. Original ARM Python bytes were rehashed locally. The other
eleven native executables and the Image layout are reviewed collector
observations checked against the original manifest, not transferred executable
bytes. Original Lean/lake executable bytes and the original live mount were
not checked here. The addendum details these limits and the retained successful
provenance checks. Log/trace/hash inspection is **not** a new Lean import/axiom
audit, kernel replay, complete native proof or x86 assurance checkpoint.

No proof rerun is needed for these unchanged inputs. The ARM cache was streamed
for inspection and kept separate; it was not installed into the x86 runner or
given rewritten tool identities.

## Accounting and settings

The original tests ran on Linux aarch64 `silver-m4pro`, with twelve available
CPUs and twelve managed workers. Their invoking stack, child threads and cache
hits were **not recorded**. The documented ARM recommendation is 16 MiB; today’s
stack cannot reconstruct that historical setting. This missing settings record
is disclosed, not replaced by an invented limit or a repeated successful suite.

The fresh x86 run used Linux x86-64 `silver`, 22 CPUs / 22 managed workers,
an 8 MiB soft invoking stack and unlimited hard stack. Both selected tests
explicitly impose their 8 MiB child limits. It ran from 12:50:15.590985 to
12:50:20.339708 UTC on November 20. Launcher, logs and events are retained below.

There was one recovered complete suite and three focused managed test attempts,
all successful, spanning November 18 17:35:13.835719–17:58:20.146428 UTC
(23 min 6.311 s; summed managed durations 1,385.262 s). The successful render
has no separately recorded duration. The ten earlier application routes and
five refusals span 17:23:41–17:26:18; reported application compile time totals
24.209 seconds, without claiming a cold cache. This continuation adds one
two-test run and no complete native or Lean attempt.

Owner authorization to original PR commit spans **19 h 23 min 1 s**
(November 18 17:14:53 to November 19 12:37:54 UTC). Validation recovery was
established by November 20 12:57 UTC, **43 h 42 min 7 s after authorization**.
These are wall intervals including unmeasured waiting and host transfer, not
active development time. Internal closing acceptance followed at 13:03:58 UTC, **43 h 49 min 5 s after
authorization**. External review/publication and merge follow separately; final
delivery elapsed time is not claimed before that closeout. Active time,
complete waiting time and token/cost totals are unavailable.

Published selections were GPT-6.1 Sol / Extra High for implementation and GPT-6
Astra / Extra High for criteria review. Recovery applicability used GPT-6 Astra /
Max; regression extraction used GPT-6.1 Sol / Extra High. Runtime settings were
not independently exposed. The reviews identify their scope and responsibility.

## Retained files and reproduction

- `original-test-records.tar.gz`: the four original managed runs, workflow
  logs/exits, checked identity, input comparison and contemporaneous after-run
  comparison. Its paths retain the recovery packet layout.
- `x86-skipped-tests/`: original launcher evidence and compressed managed
  log/events for the fresh two-test run.
- `collector-observations.tar.gz`: original collection/verification scripts,
  native hash observations, input mapping, Image layout and recovery provenance.
- `*.json.gz`: exact receiver verification results and inventories, compressed
  without content changes. Report references to `.json` mean these decompressed
  files. `SHA256SUMS` covers this delivery packet except itself.
- The retained Python helpers are exact task-local scripts. Their original
  working layout is `tmp/pr403-delivery-20261120/`, delivery checkout
  `tmp/pr403-delivery/`, and recovery folder
  `tmp/silver-pr403-recovery-20261120/`. They are evidence scripts, not new
  project tooling; paths are not portable entry points from this directory.

The supplied [recovery README](recovery-README.md) and
[transfer hashes](recovery-SHA256SUMS) identify the two original archives:
`pr403-records.tar.gz` (3,787,888 bytes) and `lean-392-cache.tar.zst`
(645,062,353 bytes). Both transfer checksums passed. All 2,571 extracted record
files match the records archive. Large cache/support binaries remain in the
local recovery folder rather than Git; neither transfer archive is required
to execute the delivered samples. Detailed exact-byte checks are retained here.
