# Session memory

## 2026-10-09 — Named strings and command-line message authorized

The owner now explicitly requested a goal to implement the previously queued
features and drive to completion. This supersedes the earlier wait-for-go-ahead
restriction. Finish and locally commit the review repairs first, then admit:
(1) a named `constant String` initialized from a literal and printed through its
identifier; (2) initialization through a narrow verified command-line interface,
with missing-argument default, preserved empty input, bounded printable ASCII,
and specified unsuccessful outcomes for oversized/unsupported/extra arguments.
Finalize the provisional API and failure propagation from a focused obligation
experiment; do not silently return a successful fallback for invalid input.

Preserve the existing null and literal-output samples. Extend actual-source
SPARK/Lean correspondence, complete report handling, language/catalogue,
manifest-driven samples and docs with each supported increment. End with full
Linux validation, independent review and local commits. macOS remains secondary;
no Oracle amendment, remote publication, concatenation, reassignment, general
array/access surface or versioned-profile infrastructure is authorized by this
scope. The roadmap records the active milestones. The preceding repair goal
must be completed before registering the succeeding implementation goal.

The review-repair baseline is complete: final compiler audit/build, full suite,
final binding regressions, Lean replay/axiom audit and fresh independent kernel
check passed on Linux. Stable evidence copies and qualifications are recorded in
[hello-review-repairs.md](hello-review-repairs.md). Continue into the authorized
feature increments after the local baseline commit; macOS remains independent.

## 2026-10-09 — Review repairs authorized; language expansion remains queued

The owner requested resolving the `3fdda42` review issues as an active goal,
with autonomous progress through validation and local commits. This authorizes
repairs to the current output capability, not the named-string/command-line
proposal below. No Oracle amendment or remote publication is authorized.

The repair replaces the libc exit/divergence mismatch with ordinary status
assignment and return through the single-call `Main`, preserving specified
application output/status outcomes. It binds installed library bytes to expected
compiler inputs, restricts Lean ghost erasure, strengthens source identity
observations and fixes path bounds. Current claims distinguish modeled empty
obligation lists from the reviewed Ada correspondence and genuine tool evidence.
See [hello-review-repairs.md](hello-review-repairs.md) for scope, evidence and
remaining limits. Proof/source pin changes require semantic review together.

Retained native macOS review evidence validates `3fdda42`, with qualifications
recorded in [hello-world.md](hello-world.md); it does not validate these repairs.
The actual repair environment is Linux ARM64. Preserve other-host artifacts and
unrelated `tmp/` material. Continue to use caching and proportionate parallelism,
without automatic proof retries or suppressed obligations.

The already requested macOS runner and queued roadmap documentation are part
of the local commit handoff. Their earlier uncommitted status below is history.
The older planning-only and null-only notes describe their dated stages, not
current support or the authority for this repair goal.

## 2026-10-08 — Next language task recorded; awaiting go-ahead

The owner selected **Hello World with a command-line message** as the next task
and explicitly requested waiting for a go-ahead while a fresh review is coming.
The proposed scope is recorded in the
[roadmap](../roadmap.md#next-task-hello-world-with-a-command-line-message): first
a named string constant initialized from a literal and printed by identifier,
then initialization through a narrow verified command-line wrapper with defined
default, empty-input, bound and failure behavior. Reassignment and concatenation
remain later increments. The proposal requires no Oracle amendment.

Only planning documentation is authorized now. Do not start implementation,
proof experiments, new sample files or language/catalogue changes until the
owner's go-ahead. Independently assess the forthcoming review when it arrives;
its recommendations alone do not authorize the proposed language expansion.
The earlier Hello World implementation goal is complete; this is a queued task.
The macOS runner and its documentation remain uncommitted, as previously reported.

## 2026-10-08 — macOS application runner

The owner requested an easy macOS prove/build/run script.
[scripts/run_macos.py](../scripts/run_macos.py) bootstraps native tools, builds
Silver, and delegates application/library proof, report checks, build and
execution to `silver run`. It defaults to Hello World and accepts caller-relative
source paths. Compiler-wide GNATprove and Lean audits remain separate. Host
selection uses the existing native paths; this is development orchestration,
with no language or Oracle change. Validation here uses Linux smoke checks and
simulated macOS tools, not a native macOS execution claim.

## 2026-10-08 — Hello World goal authorized

The owner approved the proposed implementation goal and autonomous progress
through its milestones, using judgment about sub-agent models and effort.
The previous null-program goal is complete. The new goal is a supported class
of bounded string-literal output programs, represented by
`samples/hello_world.adb`, producing `Hello, world!` followed by LF and a
successful exit. Preserve the null baseline, move it into a small manifest-driven
sample collection, verify all owned SPARK code and extend the language-wide Lean
assurance and actual-source correspondence. Finish with Linux validation,
independent review and local commits. Native macOS and remote CI remain
nonblocking; do not publish.

The owner chose to leave the Oracle unchanged after discussing the scratch
draft `tmp/oracle-draft-bullets.md`. That draft is not a requirement. In
particular, it does not mandate a new solver, a universal certificate pipeline,
or new release machinery. Keep “If it compiles, it proves” and the existing
complete automatic assurance requirement.

Begin with an isolated runtime/obligation experiment before selecting the
output binding and necessary report changes. New syntax remains experimental
until implementation, proofs, catalogue and specification agree. Routine proof
failures are implementation work; do not weaken guarantees or treat a working
sample alone as completion. The checkpoint and evidence are recorded in
[hello-world.md](hello-world.md).

The sample-collection increment is complete: the original 69-byte null source
now lives at `samples/null.adb`, unchanged. `samples/manifest.json` drives the
baseline's admission/proof/build/run test and separates actual application
output from compiler diagnostics. Focused native tests passed. Earlier entries
describing the root sample location are historical.

The output implementation now selects `Silver_IO.Put_Line` over existing libc
`putchar`, `fflush(NULL)` and `exit`, with no Silver-owned C or SPARK-off bodies.
Its exact source domain is printable ASCII literals (empty and doubled quotes
included) within the 4096-byte complete-source bound. Context, literal and one
qualified call arrive together; context-only null and repeated calls are excluded.
Library source snapshots and complete nonempty library-report checks are required.
External byte/status meaning, physical delivery and progress remain explicit in
[the trusted boundary](trusted-boundary.md#literal-output-boundary).

Seven independent Lean source-certificate modules replace the monolith so Lake
can schedule them concurrently. Authoritative source bindings and the import
facade remain handwritten protected inputs; only reconstruction candidates are
generated. Keep cached incremental feedback and full independent kernel checks.
The independent source review found no blocking correctness issue. The capability
is complete: native Linux compiler verification/audit, build, complete suite,
Lean replay/axiom audit and independent fresh kernel recheck passed, followed by
a fresh Hello World compilation/execution. The local capability commit contains
the implementation, proofs, specification, catalogue and motivating sample.
Consult [hello-world.md](hello-world.md) for exact evidence and input/mode scope.

The successful compiler audit used the existing cold mode with four workers.
Warm all-core and four-worker audits encountered the pre-existing temporary-result
JSON failure; a serial comparison was deliberately stopped for excessive proof
cost. The failures and partial diagnostic state are retained, and the cause is
unresolved. Cold success is not a demonstrated warm-cache repair. The successful
complete provenance lives in the cold report directory linked by the capability
record, not the canonical directory containing the failed warm run. No automatic
retry, obligation suppression or default-worker change was introduced. Do not
reopen completed capability work merely to add deferred hardening; diagnose the
tool issue separately when needed. Native macOS and hosted CI remain pending and
nonblocking. Oracle bytes are unchanged; publication remains unauthorized.

## 2026-10-08 — Pre-1.0 direction and completed workflow changes

The owner chose **one evolving language before 1.0**. Git records its history;
we do not maintain separately selectable language versions or impose historical
compatibility obligations. Intentional changes to admission rules or examples
must be explicit and consistent across specification, catalogue, implementation,
proofs and samples. Every currently admitted program still receives the complete
Oracle guarantee. Failed proofs cannot be hidden by suppressing obligations or
weakening declared guarantees.

Prioritize foundations needed for the authorized capability. Defer independently
addable release/deployment hardening, including binary attestations, full
per-program dependency provenance, additional adversarial-environment defenses,
and compatibility machinery, until the intended use requires it. Keep existing
checks and source correspondence. The policy lives in
[development.md](../development.md) and the [Oracle](../oracle.md).

The owner subsequently requested the modest review adjustments and local
commits, superseding the earlier staging-only instruction. The completed scope
adds optional cold GNATprove validation and a guard against accidentally sharing
exploratory proof state, and clarifies the evidence and documentation. The
previously approved Oracle amendment is recorded in commit `ddd8249`, with the
owner's approval cited in its message. No further Oracle amendment or approval
ceremony is needed. Publication remains outside this instruction.
[proof-workflow.md](proof-workflow.md) records exact results and limitations
instead of duplicating them here.

Everyday `dev.py prove` and `check_lean.py` reuse native caches; their `--full`
modes perform the additional validation described in `development.md`. GNATprove
defaults to all detected cores. Lean's per-process thread count is configurable;
its conservative default is not a measured optimum, and cold source-certificate
checking remains expensive. The transient GNATprove failure recurred in a warm
full run after a successful cold run. Subsequent manual serial and all-core
audits passed, with no automatic retry added. The cause remains unexplained.
The JSON parser reached end-of-input before a value; the failed input and root
cause are unidentified. A parallel race is a hypothesis, and `--jobs 1` is a
diagnostic comparison rather than a demonstrated workaround.

`prove --cold` is an optional full audit in fresh output/session/cache
directories for toolchain or proof-workflow changes and cache investigations.
Routine capability validation may reuse native proof results. Keep exploratory
GNATprove output under the reserved `explore` subdirectory and use a separate
cache. The direct-command guard prevents accidental mixing; it does not police
arbitrary shell wrappers or direct tool invocations.

Final Linux cold and warm full audits, the complete suite under symlinked
temporary paths, and the fresh Lean audit passed. The final Lean check reused
the exact proof objects, tools and workspace inputs of the earlier independent
kernel recheck; only the two GNATprove development scripts changed among its
captured inputs. The
independent kernel check was not repeated for this follow-up. See the workflow
record for the retained failure, subsequent successful diagnostics and final
current-input evidence. This work does not start a roadmap language capability.

**Historical scope of that workflow task (superseded by the Hello World
authorization and completed capability above):**

- The admitted language remains null-only. `silver-null-0` is the existing
  compiler/catalogue label, not an ongoing version-management requirement.
- `null.adb` remains in the repository root, unchanged.
- Moving it to `samples/`, creating a manifest and adding sample-driven tests
  remain proposed work.
- Hello World, context clauses, runtime calls and string-literal arguments
  remain proposed. No output API, trusted output binding, encoding/newline rule,
  or failure policy has been selected.
- The intended growth model is a small coherent capability with a motivating
  sample, exact rules and universal assurance. Samples exercise the language;
  they do not define membership or prove the language-wide guarantee.

The owner requested `roadmap.md`, `development.md` and `language.md` at the root
for review. Session guidance uses the conventional `AGENTS.md` spelling, with no
case-only alias. A roadmap entry does not authorize implementation.

## Earlier decisions and evidence

The earlier approved Oracle proposal clarified narrow library admission,
verified Silver-owned libraries, specified external effects/failures, and source
correspondence. Those requirements remain. Its versioned-specification, absolute
historical-preservation and per-program dependency-identity requirements are
superseded by the newer pre-1.0 direction above. The earlier Markdown-only task
restriction is also superseded by the authorized proof-workflow work.

Commit `8b8619f` (`Close assurance gaps and harden native proof workflow`) is the
implementation baseline before the current changes.
[review-repairs.md](review-repairs.md) records its Linux compiler verification,
integration tests, clean Lean replay and independent kernel recheck. These are
historical results. Consult the current workflow record for validation of the
present changes.

A later independent macOS review reported verification and Lean replay of that
baseline, with three test-fixture errors under a symlinked temporary directory.
A subsequent review validated the staged incremental workflows on macOS ARM64:
the compiler audit, tests and all four Lean modes passed. Linux-side read-only
checks corroborated the retained compiler and final clean Lean evidence against
the then-current source/script hashes. That run preceded the new cold option
and exploratory guard; it does not validate those additions natively on macOS.
See the workflow record for results, hashes and attribution. Remote CI has not run.

Read [assurance.md](assurance.md) for proved claims and limits, and
[trusted-boundary.md](trusted-boundary.md) for assumptions. In particular, the
Ada-to-Lean interpretation relies on documented frontend semantics; it is not a
verified general Ada parser. Current user programs have empty obligation sets.
Output needs specified effects and failure behavior, correspondence to actual
wrapper implementations, and complete handling of whatever obligations the
selected API generates.

The older [implementation checkpoint](implementation-checkpoint.md) predates
the review repairs. Its totals, paths and pending items are historical, not the
current task list. Do not reopen completed repairs from that checkpoint.

## Platform and repository decisions

- Linux is primary; macOS is secondary and validated independently. Determine
  the actual execution host rather than inferring it from the checkout path.
- Preserve native host isolation under `.tools/<host>/` and `.silver/<host>/`;
  see [platform-coexistence.md](platform-coexistence.md).
- The owner named `github.com/berkeleynerd/silver` as the intended remote, then
  requested local work because it did not yet exist. Do not create or publish
  a remote without a subsequent instruction. Check current Git configuration
  before later authorized remote work.
- No remote CI run is recorded. Distinguish a configured workflow from a run,
  and retained native artifacts from fresh validation of changed inputs.
- Preserve `tmp/` review and scratch material; keep it outside staged project
  changes unless specifically requested.

Update this handoff when scope or decisions change. Link detailed evidence
instead of duplicating counts, hashes or machine-specific paths.
