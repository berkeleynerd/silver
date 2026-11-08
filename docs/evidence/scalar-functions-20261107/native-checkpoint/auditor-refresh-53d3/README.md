# Successful complete native audit after the auditor correction

Run `20261108T155015-d9cbdb714cbd` completed successfully at
`2026-11-08T15:52:34.717857Z`. The actual owning driver session exited 0.
GNATprove discharged all **18,525 checks**: 1,605 flow and 16,920 proof checks
across 77 expected compilation units and 1,165 owned entities. The mandatory
source/report audit, current-input `proof-provenance.json`, and final standalone
evidence checker all passed. The managed top-level returncode field is null;
its native-tool phase records exit 0, and actual driver exit 0 is retained.

This ordinary Linux x86-64 `dev.py prove --full --jobs 12` used the preserved
canonical warm sessions/cache and original full mode/report, warnings/checks
as errors, level 2, CVC5/Z3/Alt-Ergo and thirty-second prover limit. The native
tool phase took 118.322 seconds; the complete managed run took 138.579 seconds.
Those timings describe this cache state and input/configuration only. No cold
run, source/contract/domain change, suppressed check or prover-option change
was introduced. All 866 saved Why3 root goals are proved.

The exact auditor-only correction `53d3a3b22b` is applied to the isolated native
checkout as `1ce5335e24`, after [independent Astra Max approval](../../native-policy-independent-review/README.md).
The 133 Ada inputs exactly match integration. The parser remains
`036a53b4bd9a9d7c711b4ddf8d83467a6b470184bfce2ac6677b15cf4f57ef47`;
the report body remains
`3254d7d3236cbaa689e61a4dc13478d29ab9cafe6cfdd5f0ba8b2ecff4d13b25`.
The reviewed auditor SHA-256 is
`e88e27676d7b5dacc18c67d9dff1bcc6aa2ed0dda8025487a59be46505cfffa6`.
The new complete provenance captures that script digest. Original run
[094547](../final-036a/README.md) remains failed; its snapshot was not restamped.

The audit separately classifies 330 proof limitations, 6 array-initialization
advisories and 12 exact compiler reassociation advisories. None contributes a
discharged obligation. The existing 18 imported entities, 62 vendor specification
entities and 6,253 trusted mathematical notes retain their documented scope.
Reports contain no skipped proof/flow or Assume markers, no missing/unexpected
units, and zero non-info proof/flow records.

The run index records **1,974 gzip artifacts**, including complete raw reports,
provenance and input snapshot, all saved sessions/shapes, source/script/project/
generated/toolchain inputs, actual commands/logs/phase exits, resource preflight
and collection scripts. `artifact-verification.json` confirms every decoded
length/hash and exhaustive indexing; all 151 archived native inputs match the
preflight map. The events separately retain the Alire index/settings and tool
identities. No required native task remains unresolved.

This completes native assurance for the frozen native/auditor inputs only.
The separate live complete Lean run retains its prior script input until exit;
a cached complete Lean/fresh audit on the reviewed script, remaining regressions,
Rosetta reconciliation and final delivery review remain required. No complete
#298, macOS or merge-readiness claim follows.
