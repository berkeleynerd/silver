# Discharged native obligations; failed source-policy audit

Complete native run `20261108T094547-29491e1d3036` finished with **failure**
at `2026-11-08T15:10:54.746037Z`, after 19,505.655 seconds. The actual owning
tool session exited 1. GNATprove itself exited 0 at `15:10:52.291581Z` and
reported **all 18,525 checks proved**. The subsequent mandatory source-policy
audit rejected `pragma Annotate` in `silver_library_reports.adb`. There is no
successful complete native audit or final `proof-provenance.json`.

This is native Linux x86-64 evidence from the ordinary warm
`dev.py prove --full --jobs 12` run. Its exact command and tools are retained
in the managed events: all units, mode/report `all`, warnings and checks as
errors, level 2, CVC5/Z3/Alt-Ergo and the original 30-second prover limit.
The run retained existing sessions/cache. No proof domain, obligation, source
or option changed during execution; no cold run, retry, build or sample run
belongs to this packet. Earlier [failed and interrupted evidence](../warning-cleanup/README.md)
remains historical and unchanged.

## Exact source-policy failure

The frozen report body has four `GNATprove, Hide_Info,
"Expression_Function_Body"` annotations naming `Raw_List_Spec` and
`List_Spec`: lines 4589/4591 in `Mixed_Termination_Witnesses` and 4614/4616
in `Mixed_Object`. The unchanged `audit_source_policy` gate in
`scripts/check_evidence.py` rejects the `Annotate` pragma category. The
managed error records that rejection; no Python traceback was emitted.
The audit stopped before completing report/provenance verification.

`native-identities.json` distinguishes the source-only commit `ee02fce26ac`
and focused-evidence baseline `8f39d74fa588` from this failed full outcome.
The parser SHA-256 is
`036a53b4bd9a9d7c711b4ddf8d83467a6b470184bfce2ac6677b15cf4f57ef47`;
the report body SHA-256 is
`3254d7d3236cbaa689e61a4dc13478d29ab9cafe6cfdd5f0ba8b2ecff4d13b25`.
Both remained frozen. The source-policy diagnostic is preserved for the
coordinator's independent Astra/Max review; this record proposes no exemption,
repair, suppressed check or reinterpretation of the Oracle.

## Raw report coverage and retained artifacts

`final-report-inventory.json` records all 77 expected compilation units,
without missing or unexpected units. All report progress/stop markers are
`PROGRESS_PROOF`/`STOP_REASON_NONE`, with no skipped proof, skipped flow/proof
or pragma Assume entries. The 16,920 proof and 1,605 flow records all have
severity `info`; no proof/flow record is unproved. `gnatprove.out` agrees on
18,525 checks. `final-session-inventory.json` separately records 866 saved
Why3 root goals, all proved. These raw inventories do not replace the failed
mandatory audit or establish complete provenance.

`runs/20261108T094547-29491e1d3036/index.json` indexes 1,973 gzip artifacts
by uncompressed SHA-256 and length: complete managed log/events, SPARK/SARIF/text
reports, proof-input snapshot, solver configuration, every saved session and
shape, frozen native/generated/script/project/toolchain inputs, actual tool
exit, driver log, diagnostic checkpoint and collection scripts. Its
`artifact_root` resolves to this directory. All files were captured after
actual completion and checked for stable size/mtime while read.
`artifact-verification.json` confirms exhaustive gzip indexing, every artifact
hash/length, and all 151 archived native inputs matching preflight. The ledger
also retains 2,437 Alire index/settings input identities and tool identities.

The canonical warm output/session/cache remains available. No required native
obligation failed, so there is no unresolved native task packet; the exact
source-policy failure and offending source bytes are retained instead.
No successful Lean, regression, macOS, language-delivery or merge claim follows.

## Handoff and round record

The coordinator activated a separate Astra/Max read-only diagnosis. New design,
repair or validation requires its disposition and the coordinator's bounded
instruction. This evidence owner stops without a source change or retry.

| Role/settings | Intended result | Actual result | Available time/cost evidence |
| --- | --- | --- | --- |
| Routine validation/evidence role: selected Sol/High; runtime confirmation unavailable | One complete native obligation, coverage and provenance audit on frozen final inputs | GNATprove discharged every check; subsequent source-policy gate failed; complete evidence retained for independent Astra/Max diagnosis | Managed elapsed 19,505.655 s; native-tool phase 19,496.905 s; whole-team elapsed/token/cost telemetry unavailable |

The live harness goal was null at completion. No CLI recall was updated.
Implementation merge remains held; issue #298 and broader delivery remain open.
