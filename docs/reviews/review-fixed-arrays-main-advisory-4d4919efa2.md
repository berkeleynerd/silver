# Fixed-array Main advisory classification review

2026-10-27. Scope: commit `4d4919efa259f98aaba959fa8b51d824fed81388`,
`src/silver_library_reports.adb`, `scripts/check_evidence.py`,
`tests/test_image_reports.py` and `tests/test_evidence.py`. Reviewer: independent
composition subthread, selected GPT-6 Astra / Extra High. Runtime settings and
exact elapsed/token/cost measurements were not exposed. No tests were rerun by
the reviewer; the implementation's managed results are recorded in the
[capability record](../fixed-integer-arrays.md).

No blocking finding. The three Ada policy representations pair each exact rule
with its own exact message. The Python application branch is Main-only and
retains full record validation and SPARK/SARIF multiset correspondence. The new
advisory classification adds no proof/flow waiver; cross-paired rules/messages
are rejected. Compiler and runtime scopes remain explicit.

The [producer analysis](../fixed-integer-arrays-report-capacity.md) explains why
this note withholds initialization knowledge without supplying a positive fact
or removing obligations. The admitted fragment explicitly initializes every
component. This review covers the classifier implementation against that
argument; it is not an independent review of the entire report-size derivation
or a completed capability checkpoint.

One inherited representation difference remains: the native policy checks
required and forbidden fields, while the Python array classifier requires an
exact key set. An extra benign field may therefore be accepted natively and
rejected by the evidence audit. This difference does not permit an obligation
waiver and requires no new generic report-schema machinery for the pinned local
producer.
