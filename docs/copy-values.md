# Copy String Values

Authorized on 2026-10-11 after the desktop handover, starting from `96b98e1`.
Implementation and assurance are complete. The complete physical Linux
checkpoint passed on 2026-10-11. This supported increment extends the existing
assignment and selected-result shells with reusable literal-backed constants.

The bounded scope is up to two additional `constant String` declarations before
the mutable result (after argv in argument-bearing shells). Each constant has a
literal initializer and a distinct case-insensitive name. The result initializer
and each existing assignment may use a literal or either constant. Assignment
values must have exactly the result's fixed decoded length. Both constant names
are also available in the existing bounded output expressions; every occurrence
contributes its own length. The final output still has to use the mutable result.

This retains one mutable result, the existing control flow, one terminal output
on each successful path, and the current validity/capacity rules. Constants do
not copy other constants; argv copies, self-assignment, extra mutable objects,
general statement sequences and repeated output are outside this increment.
No Oracle amendment or new runtime operation is required.

Native obligation experiments confirmed the existing report policy. Implementation
extends source-decidable admission, initialization/copy semantics, weighted
output bounds, complete automatic discharge and actual-source correspondence.
Focused checks provided iteration feedback; the stable complete Linux checkpoint
and independent review passed. Separate kernel replay
remains optional. Hosted Actions stays disabled and macOS proof work is outside
this task.

Evidence is retained under `.silver/linux-x86_64/copy-values/`, including prior
canonical reports and certificate identities in `preserved-before-integration/`.
The physical Linux host passed the separate tool-readiness check recorded in
`/home/canto/.local/state/silver/host-handover-2026-10-11-s_qucqpv/handover.json`.
Preserve previous microVM evidence with its original attribution. Physical host
and microVM share the native artifact namespace, so use one writer per cache.
Commit and publication authorization persists.

## Implementation and assurance

The six new concrete forms cover one or two constants in the assignment,
selected-result and capacity-guarded selected-result shells. The shared parser
retains each constant's declared name span and literal-initializer position.
Scalar initialization and assignment lookup exposes only those immutable
bindings; output lookup also exposes the existing result and argument slots.
Name collisions are rejected ignoring case. Constant output references add their
decoded length on every occurrence and do not satisfy the required result use.

The Lean grammar and typed source equations cover all fifteen concrete output
forms. Admission remains their union; canonical meaning and report routing use
the first accepted form. The constant elaboration proof tracks each slot's exact
bytes through every parser step. A separate direct-read relation evaluates names
from those slots, and proves agreement with normalized initializer, replacement
and output payloads. The public source theorem retains that correspondence next
to the declaration/statement execution result. Bounds and automatic discharge
reuse the existing weighted expression and fixed-length assignment arguments.
Source pins and regenerated certificates cover both changed recognizer files;
the complete kernel-checked source checkpoint passed.

The motivating [copied-result sample](../samples/copied_result.adb) initializes
`Result` from `Ready`, copies `Detailed` or `Ready` in the selected branches, and
prints the result with reusable named decorations. Tests include every literal
or constant choice at each copy position, unused/different-sized constants,
empty and escaped values, case-insensitive collisions, exact source/output and
operand limits, both branches, invalid input and output failures.

## Experiments and review

The native obligation experiment retained in
`.silver/linux-x86_64/copy-values/experiment/REPORT.md` exercised eighteen
positive cases and seven negative controls. Positive cases passed the existing
complete report auditor with only proved range checks and at most the already
classified ineffective-initialization advisory. Unused constants introduced no
warning class. Unequal-length copies produced the expected unproved length
check; proof-valid self-copy remains syntactically excluded. No report policy,
runtime API or trusted dependency was added. These observations corroborate the
explicit external-tool premises; they are not universal solver proofs.

Independent review examined the native implementation, Lean binding and
execution semantics, typed source trees and complete source-pin changes. It
confirmed exact token correspondence for the changed specification and body.
One material proof-link finding was fixed: normalized named operands now carry
an explicit immutable-slot read derivation through the public source theorem.
The reviewer confirmed that repair and found no remaining material defect.
Canonical first-form selection is intentional and documented; it is not a claim
that arbitrary independent shell derivations were proved disjoint.
The native reviewer also found an obsolete literal-only initializer label in
the assignment composition's catalogue metadata. Both the exported and checked-in
catalogues now list literal and preceding-constant operands. The successful
first full native audit was preserved; a new audit of the corrected source,
the final build and the complete test suite then passed.

The review target is the implementation commit introducing
`samples/copied_result.adb`, based on `96b98e1`. Review evidence is retained in
`copy-values/review.json` and `copy-values/native-profile-review.json` under the
native artifact directory. Complete validation and independent evidence
corroboration passed. The closing commit and remote state are recorded in
`copy-values/publication.json`; Git also identifies the implementation with
`git log --diff-filter=A -1 --format='%H %s' -- samples/copied_result.adb`.

## Physical Linux checkpoint

The current host is physical Ubuntu 26.04.1 Linux x86-64 with 22 available CPUs
and approximately 91 GiB RAM. It uses the retained pinned Alire 2.1.1,
GNAT-FSF/GNATprove 16.1.0 and Lean 4.34.1 installations. This is fresh execution
on the desktop host with reusable local caches; previous microVM and macOS
evidence is preserved separately with its original scope.

The host CPU is an Intel Core Ultra 7 165H. During the body-certificate build,
a five-second sample of its busy Lean worker stayed on performance-core logical
CPUs 1, 3 and 4, using 99.9% of one CPU. Linux's `cpu_core` PMU identifies CPUs
0–11 as the performance-core threads; `cpu_atom` covers 12–21. Process affinity
remained unrestricted across all 22 logical CPUs, with the `performance`
frequency governor. This is an observed placement sample, not a claim that every
phase or every scheduling interval ran only on performance cores. The record is
`copy-values/cpu-placement.json`; no affinity or power setting was changed.
A second five-second sample again observed 99.9% of one CPU on performance-core
threads 3 and 4; it is retained in `copy-values/cpu-placement-followup.json`.

- The isolated recognizer check proved all 510 checks across 26 entities.
  Focused admission/rejection tests passed, as did five newly compiled native
  copy programs, including output-failure paths.
- The first full native audit passed 2,623 checks. After the catalogue correction,
  the final `scripts/dev.py prove --full --jobs 12` audit passed the same complete
  set: 17 units, 214 entities, 403 flow checks and 2,220 proof checks, with no
  unproved checks. It retained the 49 documented recursive-contract/numeric-variant
  notes and 14 approved imported entities. The first audit took 384.704 seconds;
  the final cached audit took 43.503 seconds. Both report sets are retained.
- The final native compiler build passed in 2.071 seconds.
- All 217 regression tests passed in 639.293 seconds, with no skips. The sample
  test admitted, proved and built all 10 samples and checked 28 executions.
  A post-test native audit confirmed all 2,391 recorded input hashes, tool
  hashes and 19 report hashes. The archived report copy was independently
  digest-checked. See `copy-values/native-checkpoint-summary.json` and
  `copy-values/native-final-reports/`.
- The complete Lean checkpoint passed in 6,233.796 seconds, finishing at
  19:53 UTC. It used 12 Lake workers, 12 threads per process and a 12,288 MiB
  per-process threshold. The build took 6,230.756 seconds; the fresh audit took
  1.356 seconds and covered all 108 modules and 27,360 declarations, using only
  `propext`, `Classical.choice` and `Quot.sound`. The body certificate accounted
  for 6,010 seconds; the new composition source bridge took 105 seconds.
- The final digest matches all 133 captured source, proof and tooling inputs.
  Both checked-in certificate candidates match the freshly generated versions.
  The two affected certificate objects were rebuilt; the other ten retain their
  exact previous hashes and modification times. See
  `copy-values/lean-checkpoint-summary.json`,
  `copy-values/candidate-correspondence.json` and
  `copy-values/certificate-preservation.json`. This was a complete incremental
  check with cache reuse; no clean build or optional independent kernel replay
  was requested. macOS validation was not run.
- Independent read-only corroboration matched current inputs, tool identities,
  protected workspace bytes, all module objects and fresh audit coverage, with
  no warning or error diagnostics. It did not rerun validation. The record is
  `copy-values/final-lean-evidence-review.json`.

Phase commands, timings and logs are in `copy-values/native-*.json`,
`copy-values/native-*.log` and `copy-values/lean-checkpoint-launch.{json,log}`.
The final canonical reports are under `compiler/obj/gnatprove/` and the Lean
runner records current-input validation in `lean-evidence.json` and
`lean-proof.log`, all under `.silver/linux-x86_64/`. Copies of the completed Lean
record and log are retained in `copy-values/` beside the native evidence.

Repeated output remains the next proposed capability and requires a new owner
instruction. No further language increment has begun.
