# Scalar guard delivery exporter review — initial checkpoint

No blocking code finding. This is a delivery-evidence review, not a semantic
re-review or acceptance of the still-pending final checkpoint. Owner scope is
#234 / PR #242 delivery, followed by a stop for external comprehensive review;
no successor or deferred roadmap work is authorized here.

The lead supplied implementation target `d039e68dba2f8e2448b095849e8d9e7c4ee2a500`
and canonical HEAD `e0f11e30fe`. No Git action was performed. Exact inspected byte
hashes are in `initial-review.json`, including all three scripts, the preparation
report, and the runner/input-policy sources. Exporter SHA-256:
`ea6180a6d2989831636b509b35792edcb3c4bcbbf0c5d60018207bf4e67c22d7`.
Suite wrapper SHA-256:
`9978a5fbf7bab7da412ef4dbbb155012e113ce97a8ce83369f182b6208e3f3c5`.

Reviewed conclusions:

- `expected()` / `compare()` (exporter lines 115–183) correspond to native
  `input_hashes`, suite `hash_paths`, and Lean `capture_shared_inputs`. Expected
  inventories cannot become an empty successful intersection: mandatory paths
  are required, every expected tracked path is checked, governed untracked
  additions are rejected, and target/canonical/reused-workspace bytes are
  compared. Captured generated/configuration/external files are checked too.
- Lean extraction (185–228, 280–324) uses `started.inputs.sources` and the real
  `phase_started.command` records. It requires complete scope, successful build
  and audit phases, an input digest bound to the selected result, matching tool
  identities, and a fresh audit marker/result/module transcript. The captured
  runner enforces exact project-module coverage. Generated candidate exclusions
  match runner policy; complete-suite certificate parity separately checks the
  checked-in candidates. The prior PR #221 M1 event mismatch is addressed.
- Native extraction (230–278) checks the full ordinary mode, retained report
  inventory/digests, initial and final provenance agreement, source/tool capture,
  effective command, audit phase, and unique complete-audit output. Inspected
  `dev.py` freshly invokes `check_evidence.py` with checked exit before phase-end
  and retention; `complete_proof` verifies source/tool stability and regenerated
  report provenance. This is more than a successful ledger marker. Reconstructed
  command, inferred child exit zero, and enclosing phase timing are accurately
  labeled. No duplicate auditor execution is required for this claim.
- The complete suite requires the exact discovery command, nonzero test count,
  terminal OK, no skips/failures, and generated-certificate parity. The wrapper
  captures the three actual omitted renderer inputs before/after the sole
  selected suite and confirms its managed sample-manifest capture. Export checks
  run association, successful outcome, interval bracketing, and target hashes.
- Retention uses deterministic compressed bytes with content hashes; conflicting
  artifacts are rejected. The final delivery index is written only after all
  four selected checks pass and all four input sets are checked again.

The prior exporter-check report was inspected, not rerun. Its three script hashes
match the inspected bytes. It records 739/739 final-profile focused-suite inputs,
582/582 historical Lean inputs with real commands, 141/141 historical native
inputs, and expected rejection of missing/mismatched/empty/unfinished evidence.
The historical subclass deliberately omits live reused-workspace checks and is
not reachable from the delivery CLI. Those records do not establish current
final-source success. README examples predate the supplied target and explicitly
instruct the lead to select the actual later target; the final invocation/index
must use the supplied implementation target or a justified later input target.

Remaining checkpoint: inspect the eventual selected final native, build, Lean,
suite, renderer snapshot, compressed artifacts, and integrated capability record
against their source ledger. At assignment native
`20261026T084316-ffe7696c9a8a` and Lean `20261026T094105-ac4e120bd9f9`
were active, not success evidence. This review makes no later status claim.
No validator, exporter, Git/GitHub action, or source-tree edit was performed.
Only this assigned scratch directory was written.

Selected reviewer settings: GPT-6 Astra, Extra High. Runtime model/effort not
independently confirmed; token/cost measurements unavailable. Inspection began
2026-10-26T09:57:39+00:00, ended 2026-10-26T10:01:06.948475+00:00, elapsed 207.948 seconds including report
preparation. No native validation execution time was incurred.
