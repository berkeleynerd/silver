# Package audit producer packet (#416)

Prepared 2026-11-22 on Linux x86_64. These are exact original-source producer
probes and a native auditor smoke test. They do not establish compiler admission,
all native contracts, or semantic/source correspondence for package support.

`package-policy-probe` retains 1,381 original source bytes, the exact indexed
project, raw package/Main reports, SARIF, traces and managed run log/events from
`20261122T132325-ae27f95d774a`. Two function termination and one explicit out-formal
initialization checks passed; ten advisories remain accepted under exact policy.

`package-local-policy-probe` retains 1,716 original source bytes and the same
artifacts from `20261122T132803-357d99db9c13`. Its unused `Local_Warnings` body
adds initialized/overwritten locals, repeated internal stateful calls and dead
code. Three checks passed and twenty advisories were emitted. Declaration/formal
messages use spec spelling and `.ads`; ordinary local messages use `.adb`;
internal hidden-output targets use exact bare body spelling. Main's hidden
outputs use lowercase qualified state and unqualified spec-case callee spelling.

Both producer checks are managed experimental GNATprove invocations with
`--no-inlining` and eight automatic workers. The indexed source mapping uses
`at 1` without rewriting source; raw report filenames therefore contain `~1`,
but entity/check origins retain original `.ads`/`.adb` filenames. Full exact
commands and input records are in `events.jsonl` and the shared managed registry.

The initial two probes use a leading configuration `SPARK_Mode` pragma. That
placement is outside the selected compiler grammar. They remain original
producer/auditor evidence and must not be used as a claim of compiler admission.

`package-selected-policy-probe` and `package-selected-local-policy-probe` are
separate new original fixtures, with each pragma placed immediately after its
unit's `is`. All declarations/statements remain the same. Their combined source
sizes are respectively 1,390 and 1,725 bytes. Fresh managed producer runs
`20261122T135034-c924c3680750` and `20261122T135128-c4ed9d2ef0f8` each passed all
three checks with the same ten/twenty advisories. Independent Python audits of
their original reports passed with eight/nine owned entities respectively.
`audit_selected_fixtures.py` retains the source-written expected inventory for
these checks. Native parser admission of these exact new files is a separate
pending integration check; no snapshots were normalized or old reports reused.

`native-smoke` retains the generated hand-constructed-metadata harness, generator
and custom projects. Its corrected 11 positive/negative cases passed in
`20261122T133535-ab4e5a7907bc` after build
`20261122T133523-c45c0b0b9dbe`, both with eight automatic workers. The cases cover
genuine package/Main reports, optional declared/unknown import, missing owned
coverage, termination and out-initialization, wrong initialization file/case,
wrong hidden write effect, and forbidden postcondition claim. Root's integrated
tests independently derive metadata through the actual parser; this smoke does
not replace that check.

Auditor implementation is commit `518a1eda89`; report capacity is `507ef37bd1`.
`capacity-ledger.md` contains the source/producer count derivation for a
256 MiB shared retained-report buffer. Neither that arithmetic nor observed
sample sizes establishes solver discharge. The new metadata adapter separately
passed canonical focused final-policy run `20261122T133802-76f66a8b57a9`, with
22 entities and all 109 checks proved (42 flow, 67 proof). The auditor/projection
unit contracts and complete integration remain outstanding at this checkpoint.

`manifest.json` records every included file's size and SHA-256. The projects'
original source paths are preserved as `src/`; report copies are under
`reports/` rather than their original generated output directories. The smoke
generator expects the original subthread scratch layout and is retained as
test-construction evidence, not as a portable build entry point.
