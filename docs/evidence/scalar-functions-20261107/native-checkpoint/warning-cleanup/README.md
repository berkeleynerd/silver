# Warning cleanup and failed corrected-source native audit

Full native run `20261108T040128-2651963b8574` **failed**, with managed and
execution-session exit code 1 at `2026-11-08T08:23:26.557874Z`, after
15,717.688 seconds. Four parser postconditions remain unproved. No successful
complete obligation/coverage/provenance audit is established, and no
`proof-provenance.json` was generated. This is native Linux x86-64 evidence;
it makes no Lean, regression, macOS, cold-proof or language-delivery claim.

The frozen native source is source-only commit `560144172c`. Parser body
SHA-256 is `9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`;
report body SHA-256 is
`3254d7d3236cbaa689e61a4dc13478d29ab9cafe6cfdd5f0ba8b2ecff4d13b25`.
The compiler built by `20261108T014016-bd4b52349efa` has SHA-256
`ded6d3063fa2b0860d6fd3a07729d0cc23a20bb95211d1e45f2bb8a4d7902f22`.
`native-identities.json` records these identities separately from the outcome.

The reviewed cleanup removes one ineffective initializer and unused Source
formals/actuals in five private report-policy helpers. It changes no parser
source, input domain, contract meaning, warning handling or obligation policy.
Focused report flow run `20261108T014000-e499f2abc850` passed 306 flow records
without warnings in 6.967 seconds; the rebuild passed in 5.178 seconds.
Their ten retained artifacts are indexed by `index.json`. These successful
focused checks do not substitute for the failed complete audit.

## Final report and session inventory

`final-report-inventory.json` records 77 SPARK units, all at `PROGRESS_PROOF`
and `STOP_REASON_NONE`, with no skipped proof/flow or pragma Assume statements.
There are 16,915 proof and 1,605 flow records with severity `info`, plus four
proof records with severity `medium`. `gnatprove.out` totals 18,524 checks:
18,520 discharged and four unproved functional contracts. No flow warning
remains. All four failures are in `silver_output_profile.adb`:

| Location | Entity | Failed obligation |
| --- | --- | --- |
| 4794:16 | Actuals_Model | Postcondition |
| 5615:19 | Function_Local_At | Returned-frame postcondition |
| 5709:20 | Parameter_Frame | Equality with Parameter_Frame_Model |
| 5736:16 | Function_Return_After | Postcondition |

Each unresolved branch records timeout results for CVC5, Z3 and Alt-Ergo at the
unchanged 30-second prover limit, with no memory-limit report. This is a proof
failure; it does not establish that the contracts are false or justify relaxing
them. Other signaled solver attempts occur within successfully proved checks.

`final-session-inventory.json` separately lists 866 saved Why3 roots: 862
proved and four unresolved, in the four entities above. Saved sessions include
retained work and do not themselves establish complete current obligations or
provenance. The final SPARK inventory and mandatory audit remain authoritative
for their respective scopes.

`failed-run-report-comparison.json` compares the retained inventories. The
earlier warnings-as-errors failure `231059` recorded 66 units and 12,558
discharged checks; its inventory omitted the parser report and ten other units
present here. That earlier count cannot establish the current 77-unit proof
coverage. The comparison records this scope difference without inferring its
scheduling cause or treating either failed run as successful assurance.

`runs/20261108T040128-2651963b8574/index.json` identifies 1,958 gzip artifacts
by uncompressed SHA-256 and size: final managed events/log, all SPARK reports,
SARIF, text summary, input snapshot and solver configuration, every saved
session and shape, exact generated task inputs for unresolved roots, frozen
native/generated source and project files. Its `artifact_root` resolves from
the index directory to this warning-cleanup directory. Files were captured
after actual managed completion and checked for stable size/mtime while read.
`artifact-verification.json` records successful SHA-256 and byte-length checks
of all 3,711 indexed gzip files across the focused, interrupted and final
packets; every retained gzip file is indexed.

## Continuation and reuse limits

The preceding corrected-source full run `20261108T014042-81a35c010d1f` was
interrupted without a finished event or exit code. Its
[separate packet](interrupted-014042/README.md) preserves partial reports,
sessions and complete scratch archive inventories before reuse. The earlier
claim that execution would survive turn finalization was retracted; the actual
termination cause is unrecorded. Interrupted evidence is not successful proof.

After that preservation and a fresh managed resource readout, the coordinator
authorized identical-option continuation using the existing sessions/cache.
The final run reserved 12 workers, with `--mode=all --report=all`,
`--warnings=error --checks-as-errors=on --level=2`, CVC5/Z3/Alt-Ergo,
`--timeout=30`, and full mandatory native mode. Its exact command, input/tool
identities and failure keys are in the retained events. The owning turn stayed
active until actual completion, and its execution session was polled for the
actual exit. Monitoring did not change native source, options or validation
outputs.

Both earlier failed and interrupted outcomes remain historical. No repair,
retry, new validation or implementation merge is part of this evidence commit.
Complete native proof and required provenance remain outstanding.
