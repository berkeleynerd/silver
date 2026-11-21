# External Claude review of PR #406, 2026-11-20

The [original report](../../../reviews/review-pr406-claude-20261120.md) is an
**exact byte copy** of the completed Claude report against
`8dc409b303ac8bd9a836ed169467064441a76d8d`, base
`a412827d6c54f925cf4e55cac128eb4ef48647ad`. Its SHA-256 is
`2c3f52b2d6f1b634f14f47f832acf6f8170e446c782cd1659e839e27fa106912`.
The report's verdict and recommendation to defer C406-M1 are preserved unchanged.
The owner later instructed **“I agee. Fix them, then merge.”**, selecting
[#407 (C406-M1)](https://github.com/berkeleynerd/silver/issues/407),
[#408 (C406-L1)](https://github.com/berkeleynerd/silver/issues/408) and
[#409 (C406-L2)](https://github.com/berkeleynerd/silver/issues/409) for repair before
merge. That later owner decision and repair validation are separate from the
original review, which neither verifies subsequent code nor establishes a merge.

## Reviewer settings and actual command evidence

[Request](run-metadata/request.json), [launch](run-metadata/launch.json),
[prompt](run-metadata/prompt.md), [navigation brief](run-metadata/review-brief.md),
[launcher source](run-metadata/launch.py), [exit record](run-metadata/exit.json) and
[CLI final result](run-metadata/result.json) preserve the completed direct Claude
CLI session. Selected settings were `claude-fable-5-2` / `--effort max`, CLI
2.1.329. All **214 assistant events** in the source stream reported
`claude-fable-5-2`; independent server-side effort confirmation was unavailable.
No Worca or subagent was used by that review.

The launcher measured **2,104.443806377996 seconds**, exit zero. The CLI reported
2,103,235 ms elapsed, 1,966,885 ms API time and **$21.6415692 at its reported list
cost basis**; this is not independently verified billing. Its final usage record
reports 180 input tokens, 510,370 cache-creation input tokens, 28,080,246 cache-read
input tokens and 196,454 output tokens (including 132,750 thinking tokens).
These are the CLI's final counters, not a reconstruction from partial in-flight
usage. [Structured summary](review-summary.json) retains their scope and limits.

[Eight selected command/result records](run-metadata/probe-command-results.json)
were extracted from the original stream, including probe iterations and scratch
probe corrections. They retain the actual shell pipelines and returned output;
pipeline exit status is not silently equated with each underlying probe's status.
The source stream's hash is retained without duplicating the full conversation.
The [original review status](run-metadata/status.md) and
[lead's read-only M1 confirmation](run-metadata/lead-m1-check.json) are also kept.

## Findings and supporting probes

- **C406-M1:** [focused fixture probe](probes/probe_focus.py) and
  [recorded output](probes/probe_focus.out) reproduce alternating spec/body
  spellings recording different unit scopes while both select the same body.
  The original target permitted five failed attempts on the same helper/check
  before a hold. These are mocked native-runner fixtures, not new GNATprove
  executions. The [real-unit reader probe](probes/probe_unit_mode.py) and
  [output](probes/probe_unit_mode.out) independently show the spelling/command
  mismatch on retained producer data.
- **C406-L1:** [base/target comparison](probes/diff_auditor.py) and
  [output](probes/diff_auditor.out) retain **248 outcomes**: two complete-compiler
  comparisons, six positive application comparisons and **240 mutations**.
  **247 match**. One deliberately invalid trusted-unit caller configuration
  changes the exception from `EvidenceError` to `KeyError`; the original reviewer
  found it unreachable from production callers and retained-test call sites.
  The comparison script deliberately exits nonzero when any difference exists;
  its output is evidence of the disclosed difference, not a claimed all-equal
  success. All six application results match their previously recorded statistics.
- The [regression census probe](probes/verify_regression.py) and
  [output](probes/verify_regression.out) reproduce the original delivery's
  **757 = 282 fresh + 475 retained** accounting. The
  [final-record reader](probes/verify_final.py) and
  [output](probes/verify_final.out) preserve its checks and limitations. The exact
  original report supplies its interpretation; intermediate reader output is
  not silently rewritten into a stronger result.

[Explicit shared-auditor coverage](shared-auditor-coverage.json) enumerates all
**16 modules / 111 original retained IDs**, including both historical
`test_shared_bindings` import spellings. Only **14 of those 111** were freshly
rerun by Claude (`test_image_setup` and two pure-Python `test_image_reports`
classes); **97 were not rerun** because the review worktree lacked the native
toolchain. The [regression README](../README.md#explicit-retained-applicability-for-shared-auditor-users-c406-l1)
now states the equivalence basis explicitly.

Two external managed test attempts are retained under task
`#406-external-claude-review`:

| Managed run | Outcome | Managed seconds |
| --- | --- | ---: |
| `20261120T192655-0a719b502bc8` | 195 executed tests, two toolchain-dependent class setup errors; exit 1 | 7.276090007 |
| `20261120T192916-8dbc8ff09f96` | Excluded those unavailable classes; 195 tests passed; zero skips | 7.426302770 |

The [initial log](managed-tests/initial-failed/native.log.gz) and
[events](managed-tests/initial-failed/events.jsonl.gz),
[successful log](managed-tests/successful/native.log.gz) and
[events](managed-tests/successful/events.jsonl.gz),
[status](managed-tests/status-after.json) and external wrapper outputs retain
both outcomes. The first setup errors were missing installation/context paths,
not proof failures. The later **195** tests include the 14 auditor-dependent IDs
above; they are not additional original-delivery IDs and do not replace the
original 282/475 census. Later owner-selected repair validation has its own scope.

## Reproduction inputs without duplicate archives

The five probe scripts are preserved exactly, with their invocation docstrings.
Their original reviewed target must be checked out when reproducing the original
behavior; subsequent repairs can intentionally change probe outcomes. The
[input reference map](input-references.json) records hashes and extraction paths:

| Probe scratch input | Existing source |
| --- | --- |
| `old/old_check_evidence.py` | Git blob `a412827d6c:scripts/check_evidence.py` |
| `final-native/reports/` | [Final native producer archive](../final/native/producer-reports.tar.gz) |
| `final-src/` | [Final source input archive](../final/source-inputs.tar.gz) |
| `accepted/` | [Six accepted application report sets](../../advisory-policy-391-20261116/auditors/accepted-reports.tar.gz) |
| `focused-sub/` | [Subprogram producer archive](../focused-native/subprogram/producer-reports.tar.gz) |
| `focused-unit/` | [Unit producer archive](../focused-native/unit/producer-reports.tar.gz) |

Assembly verified the reviewer's extracted copies against **82 native-report,
1,152 source-input, 48 accepted-application, 80 focused-subprogram and three
focused-unit archive members**. Cases and expected application statistics remain
in the existing #391 packet. No vendor distribution, public GNATprove source
corpus or duplicate proof/source archive is added; hashes of the three public
reference source files are retained in the input map.

[Archive manifest](archive-manifest.json) binds copied originals by size and
SHA-256, using deterministic gzip timestamps for large raw records. The exact
report hash and derived extraction metadata are recorded separately. No probe,
test, proof, bootstrap, GitHub action, implementation edit, commit or CLI memory
update occurred during this archival step. The external review's observations
are evidence from its own earlier run. Selected collector: GPT-6.1 Sol / High;
independent collector runtime and cost telemetry were unavailable.
