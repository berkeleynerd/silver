# Final complete suite for #391

The single complete invocation ran **699 tests: 697 passed, two platform-specific
skips, no failures or errors**. Managed run
`20261117T002818-40d684ec306c` ran from the authoritative integration workspace
at `e8921bd091a4b0552de45d8205277008c236ba7a`, using the governed implementation
from `d60bd8a899fcc66e5ef40112423b7f94b2e4becc`. Documentation-only commits
followed; the governed source, proof, scripts, tests and fixtures stayed frozen.

The lead released this invocation after complete Lean run
`20261116T233445-6dce1a7dbb80` and the accepted native proof/build checkpoint.
The original command was `python3 scripts/dev.py test --task '#391-suite'
--reason ...`; the managed command was exactly
`python3 -m unittest discover -s tests -v`, with no method filters or fail-fast
option. It used 12 available managed workers and a 16 MiB soft stack on Linux
ARM64. No focused tests, rebuild or second suite invocation was substituted.

## Actual outcome and coverage

Unittest reported `Ran 699 tests in 1111.461s` and `OK (skipped=2)`.
The supervised duration was 1112.333 s. All 699 emitted test IDs match the
frozen discovered inventory exactly: no duplicate, missing or unknown ID.

Both skips are existing Linux x86-64-specific checks on this ARM64 host:

- `CountedBoundReviewTests.test_maximal_nested_loops_keep_filter_scratch_out_of_frames`:
  `8 MiB stack evidence is native Linux x86-64`.
- `OutputIntegrityTests.test_large_argument_vector_with_eight_mib_stack`:
  `the retained 8 MiB / 190,000-argument regression is Linux x86-64`.

All 33 methods covering the [88 unchanged full-route twins](../full-route/inventory.json)
passed: 24 function sources and 64 procedure sources, with all 196 execution
cases. The reviewed helper checks admission, byte-identical proof/build source,
all selected report obligations, and exact exit/stdout/stderr. The original
test-source hashes and fixture inventory remain retained; coverage is tied to
their actual passing method IDs in this invocation.

The manifest sample test also passed all **85 sources and 148 execution cases**,
including proof/build/source identity and output checks. The separate maximum
dynamic-expression test passed. The sample manifest, source copies, expected
cases and covering method outcome are retained. Per-program workspaces are
cleaned by the unchanged tests after their assertions; the suite evidence does
not claim to retain every temporary application's report separately.

## Preserved collector failure

The actual managed driver and its unittest phase both returned **zero**, and
the managed run finished `success`. Original supervisor terminal session
**62811** was collected with outer exit **one** after the successful suite.
That outer failure came from the untracked launcher's post-run ID collector:
`run.py:87` removes the `tests.` prefix, but the discovery inventory contains
nine `tests.test_shared_bindings` IDs that are distinct from nine top-level
`test_shared_bindings` IDs. Its final reconciliation guard therefore failed.

The original launcher remains byte-identical, with SHA-256
`612f19c5d8b6bec6c327d65e59959f0d0b6c6413924dd6576e558e6806d1c679`.
The archive preserves that script, its original incomplete result, exact
defective line and nine ID pairs, the original terminal output and both exit
codes. A separate `reconcile.py` reads the **same original full log** using exact
IDs and confirms the complete 699-ID result. It executes no tests. The collector
failure is retained as a collector failure; the successful test run is not
repeated or reconstructed from partial runs.

## Inputs, resources and retained evidence

All **1,307 frozen file hashes**, **2,606 native input hashes** and both compiler
binary hashes matched before and after the run. The current completed native
provenance still validates its 80 report hashes, 12 tool identities and selected
command. The Silver executable hash is
`6af90a7588444f63c31ffcb5166b2a2e45af2cc741c691db7c2626e46503d1ce`;
the Image adapter hash is
`832aff2ba73cd07954a9e30e9b06340ee49c16d77664a5071df2540d286d1b5e`.

The 223 five-second resource samples measured peak process-tree RSS of
2,454,880 KiB and minimum available memory of 14,348,416 KiB. The existing
1.5 GiB headroom guard did not fire. Native cache and accepted binaries were
preserved.

[`summary.json`](summary.json) records the outcome, inventory reconciliation, scope, timings,
coverage, input checks and distinct exit statuses.
[`suite-evidence.tar.gz`](suite-evidence.tar.gz) contains the original complete
child log, managed log/events, original and exact-ID collectors, both result
files, terminal collection, frozen input/discovery inventories, native
provenance, binary identities, all resource samples, pre/postflight, fixture and
sample inventories, test sources and sample source copies. Every archive
member's digest was checked after creation. Temporary managed runs printed by
the runner/platform self-tests belong to those tests; they are not additional
complete-suite invocations.

The [independent closing review](../../../reviews/review-advisory-policy-391-20261117.md)
accepts the original raw log, managed events, exact discovery inventory, fixture
mappings, stable hashes and all 169 archive members. It independently separates
the collector failure from the successful single complete suite. The reviewer's
selected setting was GPT-6 Astra / Max; runtime confirmation was unavailable.
