# Complete named scalar argument regression suite

The corrected frozen head `20e055be873f04a05d520b4e50f0e066515b7d4f` passed one
complete unfiltered suite on Linux aarch64 `silver-m4pro`. Managed run
`20261117T072619-37479dd61ba9` ran **715 tests in 1,160.908 seconds: 713 passed,
two expected platform skips**. Original terminal 77655 was collected with exit
zero. The skipped controls require Linux x86-64 and its separately retained
8 MiB stack measurements; all eight native Lean probes executed.

The [summary](summary.json), [exact outcomes](exact-outcomes.json) and
[archive verification](archive-verification.json) bind the result to its frozen
inputs. [suite-evidence.tar.gz](suite-evidence.tar.gz) retains the original
managed journal/log, external terminal log, frozen inventory, native proof
manifest, unchanged collector source and complete outcomes. Each archive member
was independently rehashed after creation. The collector matched every exact
unittest ID, preserving imported `tests.` prefixes, the single unfiltered
command, successful test-phase/managed terminal events and both expected skip
identities/reasons. No failed, missing or extra method is accepted.

The invocation was:

```sh
ulimit -S -s 16384
python3 scripts/dev.py test --task '#392-suite' --reason '<recorded repair and final-run rationale>'
```

The managed driver invoked `/usr/bin/python3 -m unittest discover -s tests -v`.
Automatic allocation reserved all 12 available workers; unittest methods are
sequential, with native prover children using the available CPU allocation.
The live driver and test process limits were independently observed at 16 MiB
soft stack and unlimited hard stack. The exact longer rationale is archived.
This is fresh complete test execution using retained validated compiler and
pinned tool binaries, not an uncached compiler/prover measurement.

The inventory includes all 16 named-scalar methods and the manifest's 86 source
programs / 149 execution cases. The manifest method compiles the unchanged source,
audits its reports and checks application outputs. The independent packet review
checks these against original records; final acceptance is recorded in the
[closing review](../../../reviews/review-named-scalar-delivery-20261117.md).

The collector rehashed all 1,344 runner inputs and 1,786 additional Rosetta
review inputs after completion. All 2,622 native inputs, the native proof
manifest, compiler and Image-adapter binaries also match the freeze. The only
input changes from the first suite were nine generated certificate copies,
which exactly match the already successful complete Lean workspace. Complete
native and Lean assurance therefore remains applicable under the independently
reviewed [synchronization account](../certificate-sync/README.md).

The [first full suite](../certificate-sync/failed-full-suite/summary.json) remains
failed history: 715 tests in 1,160.365 seconds, with three failure records across
two source-policy methods and two expected skips. The exact nine-file repair
then passed all 17 source-policy methods in 20.469 seconds before this fresh
complete run. No successful subset of the failed run substitutes for this final
715-test result. No test, domain, contract or proof budget was weakened.

The [resource record](monitor-summary.json) and compressed samples retain 33
observations at 35-second intervals from 07:27:01 to 07:45:41 UTC. Maximum sampled
process-tree RSS sum was 2,524,272 KiB; minimum available RAM was 14,667,184 KiB.
Minimum free disk was 1,599,913,984 bytes on the native artifact volume and
4,060,405,760 bytes on `/tmp`. No resource guard or signal interrupted this run.
Monitoring started after launch, and RSS sums can double-count shared pages;
these are sampled observations, not exact peaks or universal resource bounds.

The summary records elapsed time from issue #392 opening at 01:55:25 UTC to
successful final validation. This interval includes overlapping work, retained
failures and the separately recorded Lean scheduling pause; it is not CPU time
or model cost. The shared checkpoint used one complete native proof attempt,
one failed and one successful complete Lean attempt, and one failed plus this
successful complete regression attempt. Focused diagnoses and repair checks are
retained in their respective packets.

Monitoring was assigned Sol High and critical evidence review Astra Max. The
lead collected the exact outcomes and packet. These are selected assignments;
live lead/model/effort and whole-team token/cost telemetry are unavailable. No CI or independent kernel replay was run. CLI
memory was not updated.
