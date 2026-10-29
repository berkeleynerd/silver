# Constant Integer-array iteration checkpoint evidence

The implementation is on stacked PR #266, based on `0a85336c83`. The final typed
bridge is integrated as `fd9761af5c`; the validation snapshot is `1e7f42f0c1`.
Complete Linux native and Lean/source assurance passed. Final regression coverage
has 509 applicable retained passes and 31 fresh passes over all 540 test IDs.
Rosetta metadata is integrated as `d9e83fcf02`. The
[recovery handoff](../../constant-array-iteration-pause-20261028.md) retains the
historical owner-requested VM pause; PR #266 remains open pending merge.

Each `runs/<run-id>/` directory retains original managed events and logs, plus
Lean evidence or native reports when applicable, compressed without changing
the decompressed bytes. `retained.json` records the original finished event and
file hashes. Events retain captured inputs and commands. Failed and interrupted
runs keep their original outcomes.

| Run | Scope | Outcome |
| --- | --- | --- |
| `20261028T110633-769e6cd4dab7` | Native build after the catalogue repair | Passed |
| `20261028T110712-42bfb28a9731` | Catalogue output byte parity | Passed |
| `20261028T112717-49ee7b84b5ec` | Final typed bridge and exact loop rendering | Focused build and fresh 34,099-declaration audit passed |
| `20261028T103900-407484c4629b` | Byte-exact output-body certificate | Focused build and fresh 28,400-declaration audit passed |
| `20261028T134726-e1a9c7080656` | Output, named, argument and lexical source bridges | Focused build and fresh 48,060-declaration audit passed |
| `20261028T142057-dfe6a5552d65` | Complete Lean/source/module/axiom checkpoint | Passed; all 532 modules, 112,705 declarations, approved foundations only |
| `20261028T142028-347f04375d6c` | Complete native proof and coverage/provenance audit | Passed; 16,711 checks, 76 units, 1,068 entities |
| `20261028T110929-97e25e5a798e` | Complete 540-test suite | Failed: 539 passes and one 180-second fixture timeout |
| `20261028T123939-44279f5d51d8` | Source policy and certificate tests | All 12 passed |
| `20261028T131129-d738104f578d` | Platform tests, including the timeout case | All 16 passed; timeout and assertions unchanged |
| `20261028T173937-7305e9754f59` | Final Rosetta metadata | All three tests passed |
| `20261028T104216-2bf8dc56c8ec` | Initial complete native attempt without the parent solver cache | Interrupted; completed work and 27 partial reports preserved |
| `20261028T113210-1ee519cf63b5` | Composition and predicate source candidates | Interrupted for the VM upgrade; composition built, predicate and fresh audit unfinished |
| `20261028T131912-7b62c2a618ba` | Final complete native proof/audit, with restored cache and catalogue repair | Interrupted for the VM upgrade; 75 partial reports preserved, complete audit unfinished |

[Test inventory](test-inventory.json) and
[regression applicability](regression-applicability.json) account for 509
applicable retained passes and 31 successful reruns, covering all 540 test IDs.
All 50 manifest samples and 106 executions passed. The
[independent integration review](../../reviews/review-constant-array-iteration-integration-20261028.md)
closed 512 retained plus 28 rerun results before Rosetta integration. The three
final Rosetta passes replace their retained results. Composing regression results
does not replace complete native or Lean assurance; both complete checkpoints
also passed. The original full-suite run remains failed.

The [native cache correction](native-cache-reuse.json) records the restored
parent cache, identical Alire lock and preservation of all existing entries.
GNATprove owns cache matching; the initial run remains interrupted. The final
native run uses the reviewed catalogue repair at `d155e60ccc`.

[Native input applicability](native-input-applicability.json) verifies all 143
tracked provenance inputs against integration and all 78 retained report digests.
The original provenance captures 2,561 inputs, including worktree-generated and
toolchain files. Complete native validation took 11,887.177 seconds with four
workers and retained sessions/cache: 1,418 flow checks and 15,293 proof checks
passed, followed by complete coverage and provenance auditing.

The certificate build took 10,706.620 seconds, followed by a fresh 24.945-second
axiom audit. It used one worker/thread and a 16,384 MiB process threshold.
It ran alongside other managed work, so this is not an isolated timing baseline.
The complete project check reused its verified matching artifacts.

[Lean input applicability](lean-input-applicability.json) verifies all 647
captured source inputs against integration. The complete incremental build took
8,523.114 seconds and its separate fresh whole-project audit 15.738 seconds.
The [independent delivery review](../../reviews/review-constant-array-iteration-delivery-20261028.md)
confirms the complete results, exact module/input inventories, regression
applicability and final narrow delivery scope.

The [producer evidence](producer/files.json) supports the
[feature-local capacity account](../../constant-array-iteration-report-capacity.md).
The unchanged 4,096-byte, 63-operator and 64-leaf limits remain. No clean rebuild,
independent kernel replay, macOS or hosted CI result is claimed.
