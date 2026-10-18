# Indexed Main repair evidence

This packet accompanies the [repair record](../../indexed-main-discovery.md).
Implementation target: `ce4d2fee36` on Linux x86-64. Final documentation and this
packet do not change its source, proof or test inputs.

- `native-proof-provenance.json` retains the complete native audit's actual
  source/configuration/tool/report hashes. Original installation and cache:
  `tmp/bounded-mutable-integers-native`. The manifest records existing sessions
  and cache entries; it is not an uncached proof-time measurement.
- `lean-evidence.json` records the complete cached build and fresh axiom audit,
  including source, workspace and compiled-object inventories. Original cache:
  `tmp/review-b79-b1-lean`. No clean rebuild or independent kernel replay ran.
- `programs/` retains the five successful focused regressions' exact sources,
  generated projects, selected ALIs, Main proof reports, full text/SARIF summaries
  and data-representation JSON. Runtime reports and executables remain in the
  named workspaces; `programs.json` records their source and executable hashes.
  The test audits all runtime reports and executes each produced binary.
- `validation.json` and `logs/` identify the managed runs and test outcomes.
  `test-inputs.json` retains the full suite's shared source/test/proof hashes
  from its managed preflight; installation-specific inputs remain in the ledger.
  Full native/Lean logs and native report snapshots remain in the shared Git
  run ledger at `.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/<run-id>/`.

Run `python3 docs/evidence/indexed-main-20261018/check.py` from the checkout.
It checks the packet's byte inventory, native/Lean shared-input equality with
the current tree, and the indexed regression identities. It does not rerun
proofs, authenticate historical tool binaries or substitute for the recorded
native and Lean audits. Native macOS and hosted CI were not run.
