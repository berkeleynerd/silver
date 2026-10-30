# Complete native run: two unresolved proof checks

Issue #291, native Linux, 2026-10-30. Complete strict run
`20261030T194142-1f663fdf10c2` terminated with failure at 19:52:53 UTC,
return code 1, after 667.844 s. GNATprove produced the complete output-profile
report and rejected two unresolved checks. GNATprove reports 17,192 total checks: 1,468 flow, 15,722 proved and
two unproved. The subsequent complete report and provenance audits did not run; this is not a successful assurance checkpoint.

| Exact check | Retained result |
| --- | --- |
| `silver_output_profile.adb:3022:20:VC_POSTCONDITION` | `Read_Boolean_Relation_Into` exact Static equality to `Boolean_Relation_Model`; CVC5, Z3 and Alt-Ergo each reached the 30-second limit. |
| `silver_output_profile.adb:3395:19:VC_PRECONDITION` | Ghost `Lemma_Condition_Equality` immediately after the eager-chain reader; CVC5 and Alt-Ergo timed out, Z3 reported out of memory after 84.882 s under its original 1000 MiB limit. |

Neither report records a counterexample. The executable reader precondition at
3394 and the later equality assertions passed. These are two source checks,
not additional failures for their parent or transformed Why3 goal nodes.
The failed primitive session goals are respectively `def'vc.94` and
`def'vc.529`; their `introduce_premises` children were not separately attempted.

All 2,561 captured input hashes still match at terminal diagnosis. The exact
143 tracked native source/script/project inputs are archived here; they match
integration `59cfd9c3dc55c843686c5d5d07df120afbde20e6`. All complete unit reports,
SARIF, summary, original log/journal and both failed sessions are retained.
The large original generated tasks remain in the local managed run snapshots,
with their compressed-copy paths and hashes recorded in `retained-sha256.json`.
The complete available task/report inventory is retained through the
`supplemental-failure/snapshot-index.json` chain: 2,543 files, with 313 changed
files (50,758,238 bytes) newly copied and byte-verified. Earlier unchanged files
reuse the previously verified recovery snapshots. No cache tuning occurred.

The smallest next hypothesis is checked model-equality anchors in the Boolean
relation branches, plus using the existing named `Right_Model` in the eager
chain's equality-helper call. Exact contracts, helper domains, runtime behavior
and production proof limits remain requirements. No candidate has yet been
validated. The two temporary installed-source replacements remain frozen;
their original backups are intact and restoration remains outstanding.

Selected recovery/diagnostic worker: GPT-6 Astra / Extra High; runtime setting
confirmation and token/cost measurements are unavailable. This round recovered
the full run and reduced the remaining native obligations to the two precise
checks above. The elapsed time above is native managed execution, not total
agent or team cost.
