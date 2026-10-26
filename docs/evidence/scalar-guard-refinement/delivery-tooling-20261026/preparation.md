# Guard #234 / PR #242: narrow final-evidence repair

Owned scratch only; root is sole governed-source writer, validator and exporter.
Selected GPT-6.1 Sol Extra High; runtime settings unconfirmed; token/cost data
unavailable. No project validator, Git mutation or GitHub mutation was launched
by this subthread.

The original complete run `20261026T110119-3b18a2302af0` remains **failure**:
511 tests in 3540.751 s, one Image malformed-message error. Its original events
and log hashes are pinned. The exporter records that failed run separately from
the successful final-input Image (5) and Evidence (60) focused runs. It makes no
claim of a fresh 511-test pass.

The only historical-input allowance is the exact independently reviewed
`scripts/check_evidence.py` replacement at lines 465–466, from baseline
`e88a218c7e935be6d885a5d1c43f0d94e9ebf031` to implementation `d4d564cf35`.
Both whole-file SHA256 values, exact replacement bytes and every other governed
source-tree byte are checked. The reused baseline capture must match its own
Git inputs, with all other captured native/proof/test/sample/tool/configuration
inputs matching final/live bytes. Final native, build, Lean and focused evidence
use the unchanged strict ordinary comparison; there is no general hash exemption.

The exact independent applicability analysis is the follow-up #245 in
`../guard-array-advisory-assessment-20261026/assessment.md`, SHA256
`62b32229ad71b6cc9343eba34f6240cc8ecd040c6b6eb9fe89a629040931d34d`.
It explains why unchanged completed cases remain applicable and why the two
focused modules cover the sole failure and exact guard delta. The patch changes
the exception type for a malformed message, preserving rejection and all valid
marker decisions; it does not change native/proof code or valid-report acceptance.

`reconciled/suite-renderer-before-after.json` identifies the actual outer suite
using its real registry path and worktree/kind/scope/arguments/command/task/workers
and enclosing timestamps. Four fixture announcements use other registries. The
separate reconciled capture preserves the original snapshot/log SHA256, original
rejection and actual exit 1, verifies managed/before/after sample-manifest hashes,
and records a valid capture of a **failed** suite. The original `suite-final/`
capture and launch log are untouched.

`run-suite-with-renderer-capture.py` repairs future root-run selection using that
ledger identity, and also provides a validator-free reconciliation mode:

```sh
python3 tmp/guard-suite-evidence-repair-20261026/run-suite-with-renderer-capture.py \
  --reconcile tmp/guard-final-evidence-20261026/suite-final/suite-renderer-before-after.json \
  --out NEW_RECONCILIATION_DIRECTORY
```

The repair exporter imports the original full exporter only after checking its
reviewed SHA256; the baseline exception is confined to the new baseline method.
It launches no validator, including no duplicate auditor. Root supplies the
explicit final-auditor complete Lean success after its running frozen checkpoint
finishes and the cached final-input audit succeeds:

```sh
python3 tmp/guard-suite-evidence-repair-20261026/export-guard-evidence-repaired.py delivery \
  --target d4d564cf35 \
  --native-full 20261026T121322-fc9f4056f886 \
  --build 20261026T121505-a32d8e0916ec \
  --lean FINAL_AUDITOR_COMPLETE_LEAN_SUCCESS_ID \
  --repair-image 20261026T120715-ae60c9d42d98 \
  --repair-evidence 20261026T120722-6e5bfb5dcbea \
  --renderer-snapshot tmp/guard-suite-evidence-repair-20261026/reconciled/suite-renderer-before-after.json \
  --out NEW_EXPORT_DIRECTORY
```

Use `inspect` in place of `delivery` to perform the identical evidence/input
checks and write only `inspection-only.json`, without artifact copies. Delivery
retains both original/reconciled captures, actual failed full-suite events/log,
auditor before/after/patch, focused success events/log and all ordinary native/
Lean evidence. The checkpoint schema explicitly sets
`full_suite_checkpoint.fresh_full_suite_success: false` and retains the baseline
`outcome: failure`. It rechecks inputs before writing `validation.json`.

`check-exporter-repair.py` performed 17 tooling-only inspections/mutation checks
in 16.883489859 s on the final script bytes. Its exact script hashes and actual inputs are in
`inspection-checks.json`. The checks extracted all 739 baseline suite inputs,
both 739-input final focused runs, strict final-input native/build success,
and reconciled the actual capture. They rejected missing/changed inputs, any
other auditor bytes, an additional governed source delta, wrong focused scope,
failed-run substitution, wrong worktree and failure-to-zero capture promotion.
The ordinary successful-run extractor still rejects the baseline failure.

One preliminary selfcheck expected the wrong rejection order for a failed native
suite substituted for a canonical focused run; the ordinary extractor correctly
rejects the wrong worktree first. That expectation was corrected; no exporter
acceptance was weakened. An inherited Lean reporting sentence was also corrected
to say that certificate parity passed in a complete run that remains failed,
instead of calling the full suite successful. The final tooling checks were
repeated to bind that changed script, without rerunning any project validator.
First timestamped inspection was 12:06:46 UTC; completion was observed at
12:21:29 UTC (14 minutes 43 seconds, including coordination/waiting, not isolated
model compute). Final complete Lean and whole-checkpoint export were
pending when these checks ran. Independent exporter review and root delivery
integration remain separate; no successor work is authorized by this tooling.
