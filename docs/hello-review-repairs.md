# Hello World review repairs

The owner authorized resolving the review of `3fdda42` on 2026-10-09 before
further language expansion. Work is local, under the unchanged Oracle. The
owner subsequently authorized the named-string/command-line task; it follows
completion and local commit of this baseline.
The original [capability record](hello-world.md) preserves Linux and independently
corroborated macOS evidence for the baseline, distinct from these repairs.

## Repairs and interpretation

- **Library selection:** bootstrap generates exact expected bytes in
  `Silver_Library_Sources` and an explicit source directory in `Silver_Build`.
  Capture rejects differing installed files before snapshotting. The audit
  rejects bindings that differ from deterministic rendering of current sources.
  Phase guards retain exact snapshot equality; driver ghost facts name the
  actual compared source set and its compiler binding. This closes ordinary
  stale-checkout/source-selection gaps without binary-attestation machinery.
- **Failure semantics:** libc `exit` was declared without `Program_Exit`, which
  described its process exit as noncompletion to GNATprove. Replace it with
  existing GNAT `__gnat_set_exit_status(1)` and ordinary early return. The
  sole-call `Main` returns unsuccessfully; no application annotation is needed.
  A conditional success contract distinguishes full output from failed return.
  Success bytes/status and the admitted grammar are unchanged. Future
  multi-statement compositions must explicitly design failure propagation.
- **Runtime correspondence:** replace arbitrary erased token slots with fixed
  ghost actions/annotations, check their Static declarations, bind the actual
  numeric length constant, and model status assignment/return. Interpretations
  still rely on the approved frontend and external effects; this is not a
  verified general Ada parser.
- **Claims:** use the actual literal grammar, give an output structural safety
  argument, and identify modeled empty application obligations, reviewed Ada
  correspondence and faithful tool generation separately. The library proof
  marker is required by the pipeline; behavioral preservation is an explicit
  external tool premise. Correct catalogue and historical platform wording.
- **Paths and regressions:** reserve the actual contract-required 60 bytes
  below the workspace root (maximum root length 4036), select sources directly
  rather than through `.silver/../src`, require exact detected status 1, and
  exercise divergent source bindings and present-but-rejected library reports.
  Retain the null recognizer's executable membership cross-check.

The catalogue compares parsed JSON values with compiler export; its formatting
and key order need not be identical. Its two-element `decoded_bytes` and
`comment_printable_bytes` values are inclusive ranges; other byte lists enumerate
values. Construct metadata and output word selection are explicit maintained
fields, constrained by source checks and integration tests. No general catalogue
framework or stable schema/version compatibility is introduced before 1.0.

## Validation

The repair environment is Linux ARM64. Focused runtime GNATprove checks passed
for the returning status setter and conditional success contract. Native probes
confirmed exact healthy output, detected write/flush failure status 1, ordinary
return on failure, empty/max/oversized inputs, arbitrary String lower bounds and
all Character values. The complete Linux suite passed all 115 tests. Independent
source/runtime and Lean reviews found no blocking correctness issue; a wording
clarification now distinguishes prohibited `pragma Assume` from approved
reported dependency assumptions.

The first cold compiler audit finished with two unproved library-source
postconditions. Its log and reports are retained in
`.silver/linux-aarch64/review-repair-proof.log` and
`compiler/obj/cold-sudxrsmq/gnatprove/` under that host. The cause was costly
unfolding of complete source literals through an expression function. An
equivalent ordinary case/return body keeps those constants out of callers'
proofs while preserving the function contract and actual returned bytes.
Focused verification then passed all 83 checks, including both previously
unproved contracts. No timeout increase, suppressed obligation, narrowed domain
or automatic retry was used. The earlier single-prover exploration was stopped
and is not counted as verification evidence.

The final full compiler audit passed **1,374 checks** (251 flow, 1,123 proof),
with complete coverage of 15 units and 128 entities. Only the 14 approved
imported entities and 19 known limitation notes were accepted; no check was
unproved, justified or suppressed. It used four workers, the native solver
cache and a new `review-repairs` report directory, with forced complete
analysis. It is full audited evidence, not a claim of uncached replay.
The manifest is
`.silver/linux-aarch64/compiler/obj/review-repairs/gnatprove/proof-provenance.json`,
SHA256 `7f10875c0d3499eded5e564abc40bbad15b78a3cb04559a14e0987a55d38b3ae`.
Its completed status and all recorded input hashes were independently rechecked.
The final native build passed.

The only source change after the 115-test run is the equivalent function-body
rewrite. All eight source-binding integration tests passed again on that final
source, including divergent installation files, rejected reports, snapshot
mutations and symlinked artifact selection. Logs are
`.silver/linux-aarch64/review-repair-tests.log`,
`review-repair-integrity-final.log`, `review-repair-build-final.log` and
`review-repair-proof-final.log` under that host. These are Git-ignored local
artifacts. The macOS helper's Linux host guard was checked; the retained baseline
macOS review does not claim execution of that helper.

The final canonical Lean full replay, fresh axiom audit and independent
`leanchecker --fresh Silver.Audit` kernel recheck passed. It checked all 32
project modules and 7,739 declarations using only the standard foundations
`propext`, `Classical.choice` and `Quot.sound`. Elapsed full-check time was
904.888 seconds; native caches were retained. All 58 recorded source/script
inputs, three tool hashes and the log hash were independently checked afterward.
Stable copies of the completed Lean evidence, both logs and compiler manifest
are retained in `.silver/linux-aarch64/review-repairs-final/` before subsequent
capability work updates the live paths. The copied `lean-evidence.json` SHA256 is
`a45faff925593e1467dd5acb9fddccdd44e29b4b12f91b72c49e16b1824a79d1`.

The repair baseline is complete on Linux. The Oracle is unchanged. Native
macOS validation of these repairs and hosted CI remain unclaimed and
nonblocking under the existing platform policy.

## Remaining limits and deferred recommendations

The application report checker retains its verified empty-report recognition
contract and trusted-producer premise. Exact call-graph authentication, SARIF
cross-checks inside the executable, a general JSON parser theorem, exhaustive
malformed-report matrices and release provenance remain outside this repair.
Source binding and complete actual obligation discharge remain mandatory.

The library scanner's safety is proved; its full JSON interpretation is reviewed
and tested. GNATprove completeness, frontend interpretation, standard runtime
startup/finalization and physical output remain documented external premises.
The intermittent GNATprove JSON failure is unresolved and may affect a future
application run; failure prevents publication and must be investigated as a
tool defect. No automatic retry or default worker reduction is introduced.

Keep native caches, configurable workers and independent Lean certificate
scheduling. CI capacity and memory limits need measurement on real hosted
runners; no speculative scheduler or timeout policy is added here. No x86-64 or
hosted CI result is claimed, and macOS repair validation is independent and
nonblocking. Binary attestations and deployment provenance remain deferred.
