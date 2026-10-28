# Fixed-size Integer-array checkpoint evidence

Implementation target: `6e18e13c06`; Rosetta metadata: `64c9f8036e`.
The complete Linux native and Lean/source/module/axiom checkpoints passed;
the final regression inventory has 76 fresh and 454 retained successful results.
Earlier records preserve their actual inputs and outcomes, including failed
runs. The directory retains the date the delivery checkpoint began; the final
Lean repair and metadata checks completed on 2026-10-28.

Each `runs/<run-id>/` directory contains the original managed events and log,
plus the Lean evidence JSON when applicable, compressed without altering the
decompressed bytes. `retained.json` records the original finished event and
file hashes. Events retain the captured input maps and selected commands.

The response also retains the [earlier advisory discovery](advisory-discovery/retained.json)
from `20261027T075301-f654f3d5d925`: source, SPARK/SARIF reports, producer output
and managed events/log. That historical run failed because the then-current
auditor rejected two array-initialization notes despite all 71 checks proving.
It is not a successful delivery checkpoint.

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
| `20261027T104107-f971342569f8` | Complete native proof and coverage/provenance audit | Success; 16,697 checks, 76 units, 1,068 entities |
| `20261027T150301-0958f36e542b` | Complete Lean build | Failed in retained Sequence state model; large source candidates passed and were reused |
| `20261028T025314-cf98bda4f234` | Complete cached Lean repair check | Failed on the remaining empty-array initial-state proof |
| `20261028T025546-5dcc21502246` | Complete Lean/source/module/axiom checkpoint | Success; 531 modules, 112,162 declarations, approved foundations only |
| `20261028T025725-858b560a8320` | Final Rosetta metadata | Three tests passed |

[Test inventory](test-inventory.json), [inventory comparison](test-inventory-comparison.json),
[original tracebacks](full-regression-failures.txt), [rerun record](regression-follow-up.md)
and [resource notes](regression-runtime.log) retain the test accounting and
execution context. The [independent review](../../../reviews/review-fixed-arrays-closing-899a15a5a0.md)
establishes applicability of 73 fresh and 457 retained successful results at the
earlier reviewed target. The [header applicability addendum](../../../reviews/review-fixed-arrays-applicability-529df9a6c4.md)
and [Sequence repair review](../../../reviews/review-fixed-arrays-sequence-state-20261028.md)
assess subsequent proof-only changes. The final three Rosetta passes replace
their retained results, yielding 76 fresh plus 454 retained. The original full
run remains failed; composing test results does not replace complete assurance.

The [header data comparison](header-literal-repair/token-equivalence.json) was
recorded before the isolated probe. Its later successful run is retained above.
The [independent header review](../../../reviews/review-fixed-arrays-header-literals-5dd2c43b58.md)
checks the four-line repair without treating the candidate generator as an
assurance substitute. The complete checkpoint above subsequently validated the
candidate and authoritative-source chain.

The [certificate outcome](output-certificates/outcome.json) records a
14,939.674-second build and 18.845-second fresh audit. Its wall time includes
a [4,375.007-second resource suspension](output-certificates/resource-suspension.json)
and concurrent host work; it is not an isolated timing baseline. The
[artifact inventory](output-certificates/artifact-manifest.json) and
[integration transfer](output-certificates/root-transfer.json) identify the
68 verified output-module files reused for the complete checkpoint (50 copied
and 18 already matching), with ten matching dependency paths. The originating
run’s [events](runs/20261027T104437-61ba627463df/events.jsonl.gz) retain the
complete 642-entry `started.inputs.sources` map. Its SHA-256, calculated as
`sha256(json.dumps(sources, sort_keys=True).encode())`, is
`ece72b6440531cb05382b62ccc596d698681ae95d22426e85ab26177d204f50b`.
That is the originating input identity, not a claim that every source input
remained unchanged in the final integration. The transfer compares its actual
dependencies. The complete checkpoint used those certificates.

Cache provenance has a separate limitation. The external review of
`10cdcd274c` reconstructs four final module rebuilds and 527 reused modules:
257 without a contemporaneous seed-copy inventory and 270 other reused modules.
Its separate origin count identifies 261 from other workspaces: those 257 plus
four recorded output binding/certificate modules within the 270. The two counts
describe overlapping categories, not additional modules. Those historical seed
origins are reviewer-reported; the retained
packet does not independently identify the source and copy time for each of
the 257 modules. No retrospective copy manifest or fresh-build claim is
inferred from that count.

Successful modules from failed runs were also reused. The external review
identifies six final reused objects from failed runs `20261027T104101-ac593bb25952`
and `20261027T113341-7baf6c78f64b`, including the #262 caller-domain repairs.
Their original local managed logs under the shared Git directory’s
`silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/<run-id>/reports/0/lean-focused.log`
record successful prerequisite builds while the overall runs failed. These
logs were inspected during the response, but the six-object subset is the
external review’s census, not a newly reconstructed object-origin manifest.
The complete successful checkpoint freshly audits all 531 modules; it neither
turns those failed runs into successes nor proves missing historical seed
origins.

[Native input applicability](native-input-applicability.json) verifies all 143
tracked provenance inputs against the delivered tree and all 78 retained report
digests. The native run's compressed `proof-evidence/` files include original
reports, input inventory and provenance. [Lean input applicability](lean-input-applicability.json)
verifies all 646 captured source inputs. These inputs exclude the 28 generated
certificate modules, which the runner regenerates in its workspace. Of the 531
audited project modules, 503 have captured Lean-source hashes; the remaining
28 are regenerated certificates. The source-certificate parity tests passed in
`20261027T124103-ca072dcceb1a`; hashing 646 inputs does not mean hashing every
audited generated module. The final Lean build took 39.708 s and
its fresh audit 10.449 s because the earlier successful modules were cached.
The native provenance instead records `mode: full` and an initial state with
`sessions_present: false` and `cache_entries_present: false`; its 28,417.217-second
duration includes the complete coverage/provenance audit without initial native
sessions or solver-cache entries.
Lean results are complete-scope incremental checks, not clean-build timing
baselines. Native and Lean cache conditions must not be conflated.
No independent kernel replay, macOS or hosted CI result is claimed.

The [final delivery review](../../../reviews/review-fixed-arrays-delivery-20261028.md)
independently confirms these input comparisons, complete module inventory,
regression coverage and narrow support scope, with no consequential finding.
