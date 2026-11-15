# Final regression: complete execution, four failed results

Original managed run `20261115T220916-99f1eaeea331` ran on native Linux ARM64
(`silver-m4pro`) from 22:09:16 to 22:23:32 UTC on 2026-11-15. The original
launcher session 84822 returned **1**, matching the monitored child and managed
failure. No restart, duplicate suite, interruption, resource guard or attachment
was needed. The failed run remains failed.

All **691 distinct test IDs** match the prepared inventory, with no missing,
unexpected or duplicate IDs: **687 passed, two failing test IDs, two expected
Linux-x86-only skips**. Unittest reports **four failures** because one failing
case has three failed subtests. The collector accounts for multiline docstring
descriptions, interleaved diagnostic output and subtest results; it checks the
complete ID inventory rather than counting only single-line status rows.

The complete 85-entry manifest sample test passed, including admission,
compilation/proof/audit/build and declared execution cases. The maximum dynamic
expression test also passed. These sample results do not establish universal
assurance or make the full regression successful.

## Failed results

- `test_lean_modules.LeanModuleTests.test_output_body_chunks_reuse_objects_across_content_and_occurrence_edits`
  fails at its **initial fixture build**, before the edit/reuse loop. The fixture
  lacks `Silver/CertificateJoinWitness.lean`; Lake reports the missing file and
  `OutputBodyCertificate` reports a bad import. Exact traceback:
  `tests/test_lean_modules.py:217` through `assert_success` at line 66.
- `test_scalar_guards.ScalarGuardTests.test_admission_exact_source_limit_with_active_scalar_counts`
  has three failed subtests: `(count=0, depth=2001)`, `(count=1, depth=1993)` and
  `(count=32, depth=1765)`. Each admission check returns 1 with
  `raised STORAGE_ERROR : stack overflow or erroneous memory access`.
  Exact traceback: `tests/test_scalar_guards.py:209` through
  `tests/test_shared_bindings.py:46`.

[Full failure traces](failure-traces.txt.gz) preserve the emitted errors and final
`Ran 691 tests in 853.431s` / `FAILED (failures=4, skipped=2)` summary. No repair
or rerun is included in this packet.

## Input identity and resources

Launch HEAD was `4de5d4e519b040e3208632bafb12bc0d9ffcf0f4`; terminal verification
HEAD was `defb4589b6a5d33dd61e9a5c415c6eb332d97ae3` after documentation/evidence
integration. All **1,316 regression inputs and 2,606 native inputs** match their
launch snapshots. Native inputs also match the accepted full-audit manifest;
all 80 report hashes remain valid. Exact native and Lean tool identities and
both built binary identities match the launch snapshots. The compiler SHA-256
is `683925c9b33cda887a58ecc2ad1d0e8feedf51590653e7aee3dd2889b06267d9`, and the
image adapter is `832aff2ba73cd07954a9e30e9b06340ee49c16d77664a5071df2540d286d1b5e`.

The command used automatic managed allocation: **12 workers**, with no explicit
jobs restriction. Captured application GNATprove commands retain canonical
`-j0`. The monitor kept its **1.5 GiB host-headroom guard and no process-tree
cap**. It collected 172 samples, with maximum interval 5.0113 seconds; peak
sampled tree/process RSS was 1,694,448 / 936,512 KiB and minimum host available
memory was 14,320,320 KiB. Wrapper elapsed time was 855.607 seconds; managed
elapsed time was 853.963 seconds. This run has no original-launcher continuity
gap; the separately accepted earlier full-native audit retains its documented
gap and dependency erratum.

[verification.json](verification.json) records exact identities and scope;
[test-results.json](test-results.json) accounts for every ID;
[terminal-managed-run.json](terminal-managed-run.json) retains the managed
record. `run-packet.tar.gz` contains all 31 retained launch, preparation,
monitor/resource, terminal, input/tool/binary, collector and managed-log members.
Every member's size and SHA-256 were read back from the archive and checked against
[retained-files.json](retained-files.json), as
[retention-verification.json](retention-verification.json) records.

Selected monitoring/evidence role: GPT-6.1 Sol, High. Runtime model/effort
telemetry and token/cost measurements are unavailable. Scope was continuity,
terminal collection, exact result inventory and evidence retention; no
production or test source was edited.
