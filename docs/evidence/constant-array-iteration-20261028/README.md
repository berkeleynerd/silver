# Constant Integer-array iteration checkpoint evidence

The implementation is on stacked PR #266, based on `0a85336c83`. The final typed
bridge is integrated as `fd9761af5c`; the validation snapshot is `1e7f42f0c1`.
Complete native and Lean/source assurance remain pending. This packet does not
yet establish supported delivery.

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
| `20261028T110929-97e25e5a798e` | Complete 540-test suite | Failed: 539 passes and one 180-second fixture timeout |
| `20261028T123939-44279f5d51d8` | Source policy and certificate tests | All 12 passed |
| `20261028T131129-d738104f578d` | Platform tests, including the timeout case | All 16 passed; timeout and assertions unchanged |
| `20261028T104216-2bf8dc56c8ec` | Initial complete native attempt without the parent solver cache | Interrupted; completed work and 27 partial reports preserved |

[Test inventory](test-inventory.json) and
[regression applicability](regression-applicability.json) account for 512
applicable retained passes and 28 successful reruns, covering all 540 test IDs.
All 50 manifest samples and 106 executions passed. The
[independent integration review](../../reviews/review-constant-array-iteration-integration-20261028.md)
closes this coverage before the prepared Rosetta metadata changes. Those changes
still need their three affected tests. Composing regression results does not
replace complete native or Lean assurance.

The [native cache correction](native-cache-reuse.json) records the restored
parent cache, identical Alire lock and preservation of all existing entries.
GNATprove owns cache matching; the initial run remains interrupted. The final
native run uses the reviewed catalogue repair at `d155e60ccc`.

The certificate build took 10,706.620 seconds, followed by a fresh 24.945-second
axiom audit. It used one worker/thread and a 16,384 MiB process threshold.
It ran alongside other managed work, so this is not an isolated timing baseline.
The final project check will reuse its verified matching artifacts.

The [producer evidence](producer/files.json) supports the
[feature-local capacity account](../../constant-array-iteration-report-capacity.md).
The unchanged 4,096-byte, 63-operator and 64-leaf limits remain. No clean rebuild,
independent kernel replay, macOS or hosted CI result is claimed.
