# Fixed-size Integer-array checkpoint evidence

Implementation/review target: `899a15a5a0`. This packet currently retains the
completed build, focused model checks and reviewed regression checkpoint.
It also retains the failed composition check, its bounded header repair and
the successful output certificates on the current native source.
Complete native and Lean/source assurance are still pending; this is not a
completed feature delivery.

Each `runs/<run-id>/` directory contains the original managed events and log,
plus the Lean evidence JSON when applicable, compressed without altering the
decompressed bytes. `retained.json` records the original finished event and
file hashes. Events retain the captured input maps and selected commands.

| Run | Scope | Outcome |
| --- | --- | --- |
| `20261027T113126-109aa8ee133a` | Native build in the regression snapshot | Success |
| `20261027T121859-1ce124c7ffc1` | Compose model and predicate helper/source integration | Focused success |
| `20261027T123131-cf131b4f0118` | Current and native predicate bridge | Focused success |
| `20261027T113223-c732210ca335` | Complete 530-test suite | Failed: three failures, two errors |
| `20261027T124103-ca072dcceb1a` | Source fixture/policy repair | 12 tests passed |
| `20261027T124456-035726160aa1` | Shared evidence/dependency fixture repair | 49 tests passed |
| `20261027T132720-978e7f5308f1` | Division rerun | 11 tests passed |
| `20261027T132919-e15867ceed8c` | Maximum-expression rerun | One test passed |
| `20261027T113255-5e15169d81f4` | Composition source candidate | Failed at the kernel-memory threshold; no fresh audit |
| `20261027T142844-8cb1d281bb38` | Three literal-header equalities | Focused success at 4 GiB |
| `20261027T104437-61ba627463df` | Output source bindings and certificates | Focused success; fresh audit of 28,847 declarations |

[Test inventory](test-inventory.json), [inventory comparison](test-inventory-comparison.json),
[original tracebacks](full-regression-failures.txt), [rerun record](regression-follow-up.md)
and [resource notes](regression-runtime.log) retain the test accounting and
execution context. The [independent review](../../../reviews/review-fixed-arrays-closing-899a15a5a0.md)
establishes applicability of 73 fresh and 457 retained successful results at the
reviewed target. The original full run remains failed. Final metadata changes
require their affected checks, and complete assurance cannot be replaced by
composing focused test results.

The [header data comparison](header-literal-repair/token-equivalence.json) was
recorded before the isolated probe. Its later successful run is retained above.
The [independent header review](../../../reviews/review-fixed-arrays-header-literals-5dd2c43b58.md)
checks the four-line repair without treating the candidate generator as an
assurance substitute. Full candidate and authoritative-source validation remain
pending.

The [certificate outcome](output-certificates/outcome.json) records a
14,939.674-second build and 18.845-second fresh audit. Its wall time includes
a [4,375.007-second resource suspension](output-certificates/resource-suspension.json)
and concurrent host work; it is not an isolated timing baseline. The
[artifact inventory](output-certificates/artifact-manifest.json) and
[integration transfer](output-certificates/root-transfer.json) identify the
68 verified output-module files reused for the complete checkpoint, with
matching source and tool inputs. The complete checkpoint remains pending.
