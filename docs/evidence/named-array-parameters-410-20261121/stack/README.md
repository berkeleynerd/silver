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
