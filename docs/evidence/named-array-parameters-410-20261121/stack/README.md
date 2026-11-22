# Named-array metadata stack observations — 2026-11-21

An independent native review of #410 found that the larger array metadata is
copied in each recursive `Loop_Body.Inner` context. The reviewer used the frozen
Linux x86_64 compiler from managed build `20261121T125341-99e4ce810915`;
[stack.json](stack.json) records its binary SHA256 and the six admission results.
The three exact 4,096-byte source inputs are retained alongside that record.

| Input | Nested levels | 8 MiB stack | 16 MiB stack |
| --- | ---: | --- | --- |
| Existing counted loops with an indexed write | 142 | Storage_Error, exit 1 | Accepted, exit 0 |
| Existing singleton constant-array foreach loops | 159 | Storage_Error, exit 1 | Accepted, exit 0 |
| Named-array Range loops | 128 | Storage_Error, exit 1 | Accepted, exit 0 |

These are reviewer admission-only observations, not managed full-route results
or a universal stack bound. They preserve the source limit and all language
rules. The existing sufficient-stack environmental premise still applies.
The current setup instructions extend the previously documented ARM64 16 MiB
setting to Linux x86_64. The compiler does not change its own process limit.

[record-sizes.json](record-sizes.json) retains the reviewer’s binary-debug-info
measurements: array Metadata grows from 6,804 to 32,168 bytes and Body_Context
from 38,900 to 64,264 bytes, an increase of 25,364 bytes in each. These are record
sizes, not total dynamic stack-frame sizes or a sum over every call route.
The comparison baseline is retained for context; its build provenance has not
been independently audited in this review.

The feature regression `test_source_limit_loop_shapes_complete_the_native_route`
reconstructs these three families at the source limit, checks compilation with
complete native report audits and execution, and rejects the 4,097-byte siblings.
Managed run `20261121T130801-77ed9650af68` passed the test, including all
three native routes and over-limit controls (14.365 s test time, 15.760 s
managed duration). The invoking shell was set to 16 MiB; this is a lead-recorded
launch setting, not a stack-limit field captured by the managed runner.
[Its events](runs/20261121T130801-77ed9650af68/events.jsonl.gz) retain the exact
input hashes and [its log](runs/20261121T130801-77ed9650af68/native.log.gz) records
the passing result. The first run `20261121T130659-ca307255c345` remains failed:
its three compilations/proofs passed, then the test's report-audit helper rejected
an invalid policy name. The corrected test uses the existing `static` policy;
no compiler or proof rule changed. Both runs are retained here.

Selected reviewer: GPT-6 Astra, Max. Runtime settings were not independently
exposed. The lead retained the reviewer-authored scratch records without
reclassifying them as runner output. Complete feature assurance remains pending.

## External review and callable coverage — 2026-11-22

The preceding November 21 observations are historical; complete feature assurance
subsequently passed as recorded in the [delivery account](../../../named-array-parameters.md#delivery-assurance-and-validation).
The [external Claude review](../../../reviews/review-pr412-claude-20261122.md)
found that the Main-only controls missed deeper callable entry frames (C412-M1).
Its admission-only measurements used the delivered x86_64 binary, with stack
bisection at 64 KiB resolution:

| Callable shape | Levels | Measured source bytes | Minimum accepted stack |
| --- | ---: | ---: | ---: |
| Function counted nest | 141 | 4,096 | 13,436 KiB |
| Procedure counted nest | 141 | 4,096 | 13,564 KiB |
| Function formal-array `X'Range` nest | 126 | 4,075 | 12,349 KiB |

[Original reviewer observations](external-review-20261122/results-stack.txt),
fixtures and [their identities](external-review-20261122/inputs.json) are retained
without reclassifying them as managed-run output. The function/procedure fixtures
also pass at 16 MiB and reject their 4,097-byte siblings normally. The baseline
comparison in the original observations is indicative only: its build provenance
was not established. These current measurements are x86_64 only; the earlier
ARM64 evidence describes the November 15 source, before named-array metadata.

The regression now covers all six families. Each uses a source padded to exactly
4,096 bytes and a 4,097-byte rejection sibling. On Linux it explicitly sets the
soft stack limit to 16 MiB, checks that the hard limit permits it, and restores
the original setting afterward. The callable fixtures intentionally leave their
declarations unused: the recognizer parses their bodies and the full native route
audits their declared reports, while execution runs only the empty Main body.
Managed run `20261122T104947-be031f0bee17` passed all six full routes and rejection
siblings in 41.652 test seconds, with six workers on CPUs 2–7 while the external
review reserved CPUs 0–1. The [review-response packet](../review-response/README.md)
retains the fresh result separately from the original three-family run.
