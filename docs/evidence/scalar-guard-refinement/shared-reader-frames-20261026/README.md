# Shared-reader frame snapshot — 2026-10-26

This retains existing Linux x86_64 build/admission/recognizer observations for
source `042998ad3a`, after executable `Reading_Names` was shared by the two flow
readers. The exact commit and native run commands/times appear in
[validation.json](validation.json). No runner was launched to retain this record.
The [feature-local account](../parser-frame-account-20261026.md) gives the claims
and limits. The earlier [native frame record](../native-frames-20261026/validation.json)
is preserved separately.

`retention-index.json.gz` indexes every compressed payload, recording both its
uncompressed and compressed SHA-256 and original byte count. `retain.py` checks
every current shape-run input hash, compares all 129 tracked `src/` files with
the explicit commit, retains the data, and verifies every indexed gzip record.
It reads named scratch paths and Git objects; it runs no compiler/prover/test.
The index and verification script are outside the payload index; the index hash
is recorded in `validation.json`.

The payload contains all 132 scratch source files (129 tracked plus three
generated), 27 assembly files, 28 stack-usage files, the generated binder,
project switches, commands/events/logs for three successful runs, admission and
shape summaries, all 20 shape inputs and their stdout/stderr, the historical
review and accounting draft, frame deltas and reproducible arithmetic checks.
`secondary-call-sites.json.gz` maps the actual assembly calls to their containing
functions. Initial shape launch rejection is retained in
`shapes-shared-reader.log.gz`; it failed before a managed shape run because
admission still held the workspace. The later successful retry is the reported
shape observation.

`historical-pre-helper-inputs.json.gz` is the earlier scratch manifest, whose
parser hash predates this helper. It is retained as history. This snapshot's
source correspondence is the fresh `source-comparison.json.gz`, together with
the 183 checked hashes in `shape-results/summary.json.gz`. Those checks bind
retained native observations to inputs; they do not replace semantic proof or
complete actual-source correspondence proof.
