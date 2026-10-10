# Session memory

## 2026-10-10 — Lean concurrency tuning

The owner authorized tuning Lean for maximum useful concurrency on the current
proofs, with more RAM available if measurements justify it. This supersedes the
recovery handoff's blanket prohibition on further performance work for this
scheduling task. The certificate-representation investigation remains closed at
`5668806`; no third representation candidate or language expansion is authorized.

The runner now defaults both Lake workers and per-process Lean threads to the
available CPU count, respecting affinity and Python's CPU override. Explicit
`--workers N` and `--threads N` remain independent controls. The
[concurrency record](lean-concurrency.md) contains controlled module and combined
rebuild measurements, resource limits, exact evidence and remaining serial work.
Additional RAM was not needed for the measured workload. Resource choices remain
weak cache inputs; fresh axiom auditing and the full independent kernel replay
are unchanged. GNATprove already defaults to all cores with its native cache.

Final runner regressions, full Lean verification with fresh axiom/kernel checks,
and a cached full all-core compiler audit passed. Independent review found no
blocking issue; the initial new-test fixture error was repaired and its failed
run retained. The full compiler audit refreshes the changed runner's provenance;
its success does not establish a repair of the historical warm-state `DOC_END`
failure. Performance improvements concern the measured handwritten-module
workload; certificate reductions and fresh kernel replay retain serial costs.
Independent final identity/coverage checks confirmed unchanged implementation
and proof inputs, preserved compiled module hashes/timestamps and current evidence.
Existing native/foreign evidence, tool installations and caches remain preserved.
The [handoff](../RESUME.md) now gives the tuned local commands. The feature review
target remains `96b4e3a`; the preceding recovery handoff is `04c6cb7`. Publication
authorization continues, and GitHub Actions remains disabled repository-wide.
Git history identifies the tuning commit carrying this entry; the closing
handoff reports its actual publication outcome. The next project action remains
external review of the feature, with no further language expansion started.
CLI memory was actually rechecked: disabled, absent and unavailable through
tools, so no CLI recall was updated. Checked-in session memory is the durable
handoff. The live harness has no goal; the completed feature goal was not recreated.

## 2026-10-10 — Replacement-host recovery and local validation completed

The replacement Linux x86-64 environment is ready for local development.
Native bootstrap, build, complete tests, full SPARK audit and full Lean
verification passed. The last Lean invocation reused completed native modules
after two host/sandbox interruptions, then passed a fresh axiom audit and
independent kernel recheck. Both interrupted attempts and all caches remain
preserved. Final read-only checks corroborated the actual source, tool and
artifact identities; implementation/proof inputs match review target `96b4e3a`.
See [host readiness](host-readiness.md) for exact results, evidence hashes,
preserved final records and parallelism/cache settings.

Both intended non-dot snapshots, `silver/` and `tools/`, have been recovered
and checked. The owner clarified that a reference to `codex/` meant `silver/`;
no separate Codex backup remains to be located. The old top-level scratch/editor
files, CLI memory and checkout-local Git state were outside these snapshots;
preserve any separate backup. Restored historical evidence retains its original
platform/input scope. Native macOS validation of the sixth form and GNAT Pro
remain independent gaps; the warm-state GNATprove `DOC_END` issue and documented
external-tool premises remain unresolved by this successful fresh-state run.

Recovery checkpoint `eb7262a` was committed, pushed and authenticated against
remote `main`. This documentation follow-up records the completed native result;
Git history identifies its commit and the closing handoff reports the actual
publication outcome. Publication authorization continues. GitHub Actions remains
disabled repository-wide at the owner's direction; do not enable or dispatch
hosted CI. The dormant workflow and local checks remain intact.

CLI memory was rechecked and remains disabled, absent and unavailable through
tools. No CLI recall was updated and no global setting was changed. These
checked-in documents are the durable handoff. The live harness has no goal;
the completed implementation goal was not recreated. No Oracle, language,
implementation, proof or workflow changes were made. External review still
targets `96b4e3a`, and the performance decision remains `5668806`. No further
language expansion or performance candidate was started.

## 2026-10-09 — Local validation; GitHub CI disabled

The owner explicitly instructed: "GitHub CI should be disabled entirely. We are
running local." GitHub Actions is now disabled for the entire repository, with
the setting read back and verified. The existing workflow definition and local
checks are preserved. Do not enable or dispatch hosted CI as a readiness or
publication follow-up; validate locally. This supersedes earlier hosted-CI
follow-up plans. Publication authorization continues and no language expansion
is authorized. See [host readiness](host-readiness.md) for the setting evidence
and actual native validation results. CLI memory remains unavailable; this
checked-in entry is the durable recall.

## 2026-10-09 — Replacement Linux x86-64 host restoration

The owner requested host/resource, Git/remote/CI and toolchain verification,
preservation of evidence/caches, and a refreshed handoff without another language
expansion. The replacement sandbox is Linux x86-64; its observed RAM and Docker
storage match the previous allocation recommendations. Native bootstrap and
compiler build, complete tests and full SPARK audit passed. Two host/sandbox
restarts interrupted Lean; both partial attempts are retained and full replay has resumed
using completed native objects. Use
[host-readiness.md](host-readiness.md) for exact results and local evidence paths.

This checkout arrived with source and intact Git history at `69d294c`, but no
old `.silver/`, `.tools/`, `tmp/`, `.vscode/` or CLI memories. Historical ARM64
and macOS evidence and tools have since been recovered from the authorized
snapshots, with full integrity checks and read-only provenance corroboration.
Top-level scratch/editor files, CLI memory and old local Git state remain outside
those snapshots. Preserve any separate backup of that omitted state. New
tools and caches are isolated under `linux-x86_64`; no existing state was removed.

The workspace received eight fetched migration commits while this sandbox
restarted. Local main was fast-forwarded to `1bf065d`, preserving and merging
the new migration guidance with this handoff. Source/proof inputs are unchanged.
GitHub authentication recovered after the second restart. Authenticated checks
and a fetch confirm remote `main` at `1bf065d`. The repository lists no CI runs,
the previously recorded first run returns 404, and `Verify Silver` was already
manually disabled. The owner's subsequent instruction above disabled Actions
repository-wide; hosted success is neither claimed nor required for this local
readiness task.
The owner-authorized `silver` and `tools` split snapshots are present locally;
recovery preserved the new x86-64 state, original foreign-host evidence and
legacy caches without collisions. Consult the readiness record for exact scope
and the unarchived external-system Python identity limitations.
Publication authorization continues. This documentation checkpoint records
completed recovery while the resumed local Lean check is still running; its
final result will be recorded separately. No change to Oracle,
language, proof inputs, feature implementation/review target `96b4e3a`, or bounded
performance decision `5668806`. The live harness has no goal in this session;
the completed implementation goal was not recreated. External feature review
remains the next project action after environment recovery.

CLI memory was actually checked: its feature is disabled, the memory directory
is absent, and no memory tool is exposed. No CLI recall update was made and no
global setting was changed. These checked-in documents are the durable handoff.

## 2026-10-09 — Non-dot artifact snapshots authorized for migration

After discussing the size and generated nature of `.silver/` and `.tools/`, the
owner explicitly authorized adding their non-dot equivalents to the repository.
This supersedes the previous exclusion of these captured trees from publication;
it does not change the live artifact layout or authorize further language work.

The [silver snapshot](../silver/README.md) and
[tools snapshot](../tools/README.md) preserve the original directories in split,
compressed tar archives. Packaging preserves nested Git repositories, symbolic
links, executable modes and original paths while keeping each part below GitHub's
file-size limit. All parts are needed to restore a tree. Per-directory
`snapshot.json` and `SHA256SUMS` record exact capture identities, checksums and
full comparison against the originals. The live dot directories remain intact
and ignored. Restore to staging first; preserve any newer target-host state.

The original implementation/review target remains `96b4e3a`, with performance
decision `5668806` and completed harness goal. This transfer adds no source or
proof change and establishes no new platform validation. Archive commits use
`[skip ci]` to avoid launching repeated expensive proof runs for binary transfer
batches; archive integrity and source comparisons are checked separately.
Preserve untracked `.vscode/` and `tmp/`. The [handoff](../RESUME.md) now explains
restoration from Git and which remaining local state still needs a separate
backup. CLI memory records the closing commit and actual push outcome.

## 2026-10-09 — Published history and replacement-host handoff refreshed

Read-only remote verification confirmed `main` at `9731278`, including feature
implementation/review target `96b4e3a` and performance decision `5668806`.
Publication has succeeded since the initial rejected push; the credential
blocker below is historical. The first
[GitHub Actions run](https://github.com/berkeleynerd/silver/actions/runs/37983290787)
was in progress at this refresh. Check its outcome separately from retained
native Linux evidence; do not infer success from publication. The harness goal
remains complete, and no further language expansion is authorized.

The owner is preparing a new sandbox on a host with 96 GB physical RAM. The
recommended allocation is now 32 GiB sandbox RAM, automatic CPU allocation and
64 GiB Docker storage. The [handoff](../RESUME.md) contains the verified one-line
`sbx create` command and distinguishes Docker storage from the mounted workspace's
host filesystem. This supersedes the earlier 18 GB plan without claiming the
new VM or evidence transfer has been verified. Keep conservative proof settings
initially; physical RAM and Lean allocation limits are distinct.

The handoff changes are documentation only and preserve the implementation
review target. Publication authorization still applies; commit and push this
refresh so the new host can receive it. Preserve local ignored evidence/caches
and untracked `.vscode/` and `tmp/`. A CLI memory update note records the actual
closing commit and push result after handoff.

## 2026-10-09 — Remote publication authorized

The owner added `origin` at `git@github.com:berkeleynerd/silver.git` and explicitly
requested committing outstanding work and pushing. This supersedes the earlier
local-only direction for publishing the completed project history. The remote
was confirmed to be the owner's empty private repository. This sandbox has no
SSH identity; its authenticated GitHub CLI HTTPS connection was used for the push.
GitHub rejected that push because the available OAuth credential lacks the
`workflow` scope required to publish `.github/workflows/verify.yml`. No remote
branch was created. Publication awaits refreshed credentials with the necessary
repository/workflow access or an authorized SSH identity; preserve the workflow.

All implementation was already committed: performance decision `5668806` and
guarded-greeting implementation/external-review target `96b4e3a`. The combined
harness goal is complete. This later bookkeeping commit records publication
authorization without changing implementation, proof inputs, Oracle or review
target. No next language expansion is authorized.

Only `.vscode/` editor preferences and `tmp/` historical reviews, experiments and
generated artifacts remained untracked. Preserve them locally; they are not
outstanding implementation and are excluded from the push, as are ignored
host-specific evidence, caches and tools. Follow [RESUME.md](../RESUME.md) before
VM replacement; a remote clone alone cannot restore that local state. The
existing native evidence retains its original scope; publication and configured
CI do not establish a successful hosted run. The blocked push and exact closing
commit are reported at handoff and in the CLI memory update note.

## 2026-10-09 — Combined goal completed; guarded greeting ready for review

The owner resumed work and requested completion before VM replacement. Both
units are complete: performance decision in `5668806`, and the sixth production
in the implementation commit carrying this entry and adding
`samples/command_line_greeting.adb`. That implementation commit is the next
external-review target; subsequent documentation alone does not change it.
The goal is to be marked complete at this local-commit handoff, not replaced by
another feature goal. No next language expansion is authorized.

The [capability record](command-line-greeting.md) holds the complete native Linux
SPARK/build/test/Lean/kernel results, exact evidence identities, independent
review and retained failures. It distinguishes the failed performance candidates,
the fixed Lake resource-option bug, two unresolved warm-state GNAT JSON-reader
crashes, the repaired warning audit and platform fixture, and successful final
cold compiler and cached full Lean validation. Compiler and proof source bytes
were rechecked after completion. Native macOS for this increment, x86-64,
hosted CI and GNAT Pro remain untested; macOS is independently handled and
nonblocking. The Oracle and approved external-tool boundary are unchanged.

The next action is external review of the feature commit. VM replacement can
follow this completed goal; preserve the checkout and host-local evidence/caches,
and consult [the VM handoff](../RESUME.md). The future RAM allowance is 18 GB;
resource settings must still respect actual host headroom. Work remains local,
with unrelated `.vscode/` and `tmp/` left untouched. CLI recall receives a small
completion note with the actual commit identifier after the commit; this records
an explicit note write, not assumed background consolidation.

## 2026-10-09 — Performance committed; guarded greeting integrated

The bounded negative result is locally committed as `5668806`. Both permitted
candidates failed to establish an improvement, so the existing certificate
implementation stays; no third approach. See [the record](certificate-performance.md).
The configured CI allowance is now 120 minutes; hosted capacity is unmeasured.

The sixth-production implementation, runtime normalization, independent report
policy and Lean source bridges are integrated. Full native Linux validation is
running; the feature is not yet complete or committed. The first full Lean
attempt was explicitly stopped because Lake reused a cached configuration that
ignored the requested memory limit. Repair that resource-option handling and
preserve the unsuccessful log before final replay. Source/proof checks are not
weakened. The [capability record](command-line-greeting.md) and host-local
`.silver/linux-aarch64/guarded-greeting-validation/` retain current evidence.
The owner still requests completion in this VM before replacement.

## 2026-10-09 — Owner resumed the goal before VM replacement

The owner instructed: "Let's finish the current goal before we make this change."
This revokes the preceding pause. Complete the existing two-unit goal in the
current Linux ARM64 VM before migration: final bounded performance decision and
its local commit, then guarded greeting/report-policy integration, full assurance,
independent review and local feature commit. The replacement VM and its handoff
document are deferred until that work is complete.

At resumption, the harness still returned the original objective with status
paused; the exposed goal tools have no resume operation. The owner's instruction
authorizes resumed work without creating or replacing the unfinished goal.
The existing environment still has about 12 GiB RAM. The owner's future VM limit
is 18 GB; the proposed 6-GiB Lean allowance and 64-GB disk are future settings,
not changes already applied. Keep the current bounded comparison's recorded
4-GiB/3300-second limits and label any resource changes separately.

No proof process survived the pause. The second and final candidate's helper
repair now checks; its first dominant benchmark has started. Focused subthreads
resume the missing source bridges and independent recognizer review. The earlier
pause records and process/session IDs below are history; current files, live goal
and new logs determine progress. No Oracle amendment or remote publication.

## 2026-10-09 — Paused at the owner's request

The owner requested a pause at the next available opportunity. The combined
performance/guarded-greeting goal is paused, not complete. No implementation
commit has been made; HEAD remains 653fe52. Resume only when requested.

The performance baseline and first candidate both hit the experiment's Lean
memory limit. The second and final candidate is prepared but its dominant trial
has not started; its helper needs a small elaboration fix. Detailed state is in
.silver/linux-aarch64/certificate-performance/resume-checkpoint.json.
No third candidate is authorized. Any adopted change still needs full validation
in the frozen performance-only snapshot and its own local commit.

Report-policy refinement and its native tests pass. Draft recognizer, runtime,
core Lean and driver checks pass; complete bridges, final integration, full audits
and local feature commit remain. The supported language is still five productions.
See .silver/linux-aarch64/guarded-greeting-draft/RESUME.md for exact evidence,
file ownership and pending work. Some direct draft edits postdate preparation
scripts. The in-progress [capability record](command-line-greeting.md) is uncommitted.

No proof/benchmark process remains running. Preserve uncommitted report work,
unrelated .vscode/ and tmp/, caches and other hosts. No Oracle amendment or remote
publication. CLI recall received a pending note under memories/extensions/ad_hoc/notes/;
that records an actual note write, not completed background consolidation.

## 2026-10-09 — Active goal implementation checkpoint

The combined goal remains active. Authorization is committed in `653fe52`;
no implementation unit is complete yet. The execution host is Linux ARM64.
After a sandbox restart, the interrupted timing run was retained without being
counted as a baseline result. A replacement dominant-certificate baseline and
candidate comparison use isolated workspaces under
`.silver/linux-aarch64/certificate-performance/`, with one reserved CPU and a
finite measurement budget. Candidate one changes only reconstruction proof terms
and their generator; exact source, lexer, axiom and kernel checks remain required.

The [guarded-greeting record](command-line-greeting.md) captures the concrete
lower-bound issue and owned-SPARK normalization repair. Experiments and exact
reports are retained under `.silver/linux-aarch64/guarded-greeting-experiment/`.
Draft recognition, driver, catalogue, tests and Lean files live under
`.silver/linux-aarch64/guarded-greeting-draft/`; they have not admitted a sixth
form in the supported language. Embedded authoritative sources remain unchanged
through the comparable performance measurements. Report-policy refinement is
being developed in `src/silver_library_reports.*`, with independent byte parsing,
coverage and discharge specifications; its proof work is still in progress.

Resume by checking live agents/processes before restarting long runs. Complete
the bounded performance decision and its validation/local commit before
integrating the embedded language/runtime changes. Then finish full feature
assurance, native validation, independent review and its local commit. Preserve
unrelated `.vscode/`, `tmp/`, experiments and other hosts; no remote publication.

## 2026-10-09 — Performance and guarded-greeting goal authorized

The owner approved the proposed sequence and said, "Update the goal to cover
this remit and then proceed." A new active harness goal was created at
`2026-10-09T14:41:12Z`, superseding the completed literal-backed greeting goal.
Baseline implementation is `a73f85e`, with review/documentation handoff `fee3afe`.

First perform the bounded source-certificate performance pass: fixed-input
baseline, at most two candidate approaches, then a validated improvement or
recorded negative result. Preserve exact authoritative-source checks, axiom
audits, kernel replay, caches and other hosts. The language unit then adds the
fixed guarded command-line greeting, including actual-obligation investigation,
universal bounds/discharge/source correspondence and report-policy functional
refinement. The [roadmap](../roadmap.md#next-goals-after-the-greeting-review)
defines scope and completion conditions. Both units require appropriate native
Linux validation, independent review and local commits; no new prover or Oracle
amendment is authorized. Ordinary proof failures are work to resolve.

Focused performance, language-design and report-proof subthreads are active with
separate ownership; design starts read-only while the fixed baseline is measured.
No new form is supported until full assurance and validation are complete.
Preserve unrelated `tmp/` and other-host artifacts; publication remains outside
scope. Consult the live goal rather than historical completed/proposed entries.
## 2026-10-09 — Greeting external review assessed and evidence recorded

The external review of implementation commit `a73f85e` against `54844c5` has
arrived. Read-only independent checks corroborated retained native macOS
compiler, test and full Lean evidence against the reviewed inputs and Linux
records. No blocking finding emerged. Exact results, mode limits, authorization
chronology and finding dispositions are in
[greeting.md](greeting.md#external-review-and-native-macos-validation).

Corrected documentation premises/pointers and clarified earlier review snapshots,
test chronology and experiment reproducibility. The CI timeout is an unmeasured
capacity risk carried into the proposed performance pass. Optional sample
witnesses and additional regression cases remain deferred; the existing
universal proofs cover them. The non-admitted dynamic-concatenation contrast
confirms new obligations need investigation in the proposed next capability.

This follow-up changes documentation only; the implementation/review target
remains `a73f85e`. The greeting goal remains complete, and the performance pass,
guarded command-line greeting and report-policy proof remain proposed, not
started. The host-local CLI recall pointers were updated. Preserve review logs,
other-host state and unrelated `tmp/`; work remains local.

## 2026-10-09 — Additional proof tools require a concrete coverage gap

The owner deferred extra solvers/provers/checkers that only add redundancy until
Silver offers something practically useful. Additional tooling must close an identified
end-to-end coverage gap or strengthen automatic discharge for admitted programs.
The [development policy](../development.md#pre-10-development-policy) records
the rule; existing checks, source correspondence and proof-cache/performance
work remain in scope under their existing authorization status.

No proposed additional prover is needed now. A read-only source and assurance
check confirmed one existing mechanization gap: the library-report scanner has
verified safety but no independent functional refinement of its acceptance
policy. The [roadmap](../roadmap.md#completed-report-policy-follow-up) records a proposed
soundness/completeness argument for genuine supported reports using existing
tools. This is not a demonstrated bug. The next dynamic-concatenation capability
also needs its own obligation/discharge argument, as already planned. Neither
follow-up starts here; approved external-tool premises and the Oracle remain
unchanged. The host-local CLI memory was updated with this durable decision.

## 2026-10-09 — CLI memory enabled and seeded

The owner enabled Codex CLI memories and requested the same durable guidance
there. The local configuration and this thread's memory mode are enabled. A
concise Silver entry and routing summary were manually seeded in the active
Codex home's `memories/MEMORY.md` and `memories/memory_summary.md`; these are
host-local recall files, outside Git, not evidence of background consolidation.
They point to the repository's authoritative documents and require rechecking
live goal, Git and review state. Other hosts' memory stores were not updated.

[AGENTS.md](../AGENTS.md#durable-memory) now records this maintenance convention.
Keep required guidance checked in; update the CLI recall layer when durable
decisions change and it is available. OpenAI's [memory documentation](https://developers.openai.com/codex/customization/memories)
describes automatic generation as asynchronous. This bookkeeping update starts
no implementation goal and changes no Oracle or proof claim.

## 2026-10-09 — Bookkeeping guidance checked and completed

The owner asked whether session memory preserves our bookkeeping commitments.
The existing admission, evidence, cache/platform and local-work rules remain in
[AGENTS.md](../AGENTS.md), [development.md](../development.md) and the
[roadmap](../roadmap.md). The new
[goal and review bookkeeping](../development.md#goal-and-review-bookkeeping)
makes three practiced conventions explicit: inspect the actual harness goal
separately from its conversation title, record a precise completion handoff, and
retain independently assessed review dispositions tied to the reviewed commit.
Use those shared rules rather than duplicating them in each memory entry.

Current handoff: implementation and pending external-review target `a73f85e`;
subsequent roadmap-only planning commit `c3ca119`; greeting harness goal complete.
The bounded proof-performance pass and guarded command-line greeting remain
proposed, with no active implementation goal. This update changes guidance only.
Later documentation commits do not change the external review's target. Work
remains local; preserve unrelated `tmp/` files and other hosts' artifacts.

## 2026-10-09 — Next goals proposed while greeting review is pending

The owner requested planning and a roadmap update while an external reviewer
assesses greeting commit `a73f85e`. The completed harness goal remains complete;
this request does not start implementation, proof experiments or another harness
goal. The [roadmap](../roadmap.md#next-goals-after-the-greeting-review) now records
the recommended order: independently assess the incoming review, conduct a
bounded source-certificate performance pass, then add guarded command-line
greeting as the next language capability. Both proposed tasks await a go-ahead.

The performance proposal addresses measured certificate cost, preserves every
source/axiom/kernel check, and ends after at most two candidate approaches with
either a validated improvement or a recorded negative result. Keep caches and
native-host isolation; do not treat the unsuccessful raw-byte experiment as a
solution or grow this into general infrastructure work.

The proposed `command_line_greeting.adb` uses the existing initializer and an
explicit `Input_Is_Valid and then Name'Length <= capacity` guard before
`prefix_literal & Name & suffix_literal`. Membership would verify the capacity
against decoded decorations. Actual dynamic concatenation obligations and String
lower bounds must be investigated before admitting the form; existing empty
Main reports and length-only contracts are not sufficient evidence for it.
See the roadmap for proposed behavior, boundaries and completion criteria.

Only planning documents change now. The Oracle, five-form language,
implementation, catalogue, samples and proof evidence remain as committed.
Work stays local; preserve unrelated `tmp/` material and all host artifacts.

## 2026-10-09 — Literal-backed greeting concatenation complete

The owner's harness goal is completed in this change, following repair commit
`54844c5`. [samples/greeting.adb](../samples/greeting.adb) introduces exactly
`prefix_literal & Name & suffix_literal`, where `Name` is a literal-initialized
`constant String` referenced once. All five current forms are covered by the
updated specification, catalogue, SPARK recognizer and Lean assurance. The
combined decoded length follows from distinct consumed literal spans, and the
typed Main interpreter obtains values and binding from ordered parser events.
Existing forms and the Oracle remain unchanged.

Full compiler verification, native build, the complete regression suite, actual
source correspondence, a fresh axiom audit and independent fresh kernel recheck
passed on Linux ARM64. Genuine GNATprove/GNAT application experiments confirm
that the static concatenations retain empty application reports; selected
libraries still require their complete nonempty reports. No runtime or report
policy extension was needed. Independent semantic, source, proof-depth and
documentation reviews found no blocking issue.

The enlarged source certificate first reached an elaboration recursion limit.
A finite local depth allowance fixed it without weakening source checks; related
generator/evidence regressions and final Lean validation passed. Source-certificate
reconstruction remains an observed development cost. An isolated alternative
byte-equality probe did not complete and was not adopted. Preserve native caches
and consult [greeting.md](greeting.md) for exact validation, hashes, failure logs,
review scope and replay costs instead of repeating totals here.

Native macOS validation remains independent and nonblocking; earlier macOS
evidence does not validate this capability. Work remains local. Other-host
artifacts and unrelated `tmp/` material were preserved. The proposed command-line
greeting with an explicit capacity guard still needs a separate go-ahead. This
completed goal does not authorize argument concatenation, repeated references,
assignment or general string expressions.

## 2026-10-09 — Command-line review follow-up complete

The owner approved the independently assessed `e14ba1a` review follow-up and a
local commit. The repair now links the guarded Main's rendering and execution
through one typed composition, removes obsolete named-membership proof plumbing,
and adds existing-style precedence checks and focused regressions. Catalogue/CI
consistency, assurance wording and runtime premises are corrected. No new
language forms, Oracle amendment, publication, general parser or release-hardening
framework were introduced.

Focused proof, tests/CI and documentation subthreads completed their work;
independent read-only review found no blocking mismatch. The full Linux compiler
audit, build, complete tests, Lean build/fresh axiom audit and independent fresh
kernel recheck passed. Final input/tool/report/artifact hashes matched. The
current evidence and exact scope are in
[command-line-review-repairs.md](command-line-review-repairs.md), including the
retained review note. Native caches and previous/other-host artifacts were
preserved. Unrelated `tmp/` remains untracked and untouched.

The independently corroborated macOS evidence validates the `e14ba1a` baseline;
native macOS validation of this follow-up remains independent and nonblocking.
CI, x86-64 and GNAT Pro remain untested. Work remains local, and no further
language increment is authorized by this repair task.

## 2026-10-09 — Named strings and guarded command-line input complete

Named literal constants are committed as `2f76b20`, following the completed
review repairs in `251dd85`. The guarded command-line increment is complete in
this change. Both authorized language increments have full Linux validation;
no further language expansion is authorized by this goal.

The integrated command-line form uses a pure `First_Or_Default` initializer,
mandatory `Input_Is_Valid` guard and `Reject` false branch. Missing input uses
the literal default; an explicit empty argument stays empty. One printable ASCII
argument up to 4096 bytes is preserved; invalid or extra arguments produce no
application output and status 1. The queries require the same immutable GNAT
argument vector. No general conditionals, reassignment or concatenation.

All output forms now select six source files and require all four library-unit
reports. Null programs select none. Existing GNAT argument imports remain the
trusted boundary; no new external tool or runtime exemption was introduced.
See [command-line.md](command-line.md) for the exact scope and validation record.
The compiler-wide audit, native build, complete suite, actual-source Lean replay,
fresh axiom audit and independent fresh kernel recheck passed. Two stale test
fixtures found by the initial full suite were repaired; both their focused tests
and the complete rerun passed. Independent semantic/source and documentation
reviews found no blocking mismatch. Completed evidence and the retained initial
failure log are in the capability record's stable native directory. All recorded
compiler/Lean inputs, tools, reports and proof artifacts matched after validation.
The enlarged source certificate dominates replay cost; preserve native caches
and independent module scheduling. No retry or weakened proof policy was added.
Oracle bytes remain unchanged, macOS validation is independent/nonblocking, and
publication remains unauthorized. Continue with the current specification; old
pending-validation notes below describe their dated stages.

## 2026-10-09 — Repair baseline committed; feature goal active

Review repairs and the earlier macOS helper are committed locally as `251dd85`.
Their completed Linux evidence is in [hello-review-repairs.md](hello-review-repairs.md).
The successor goal now covers both authorized increments: named literal constants,
then guarded command-line initialization. The named compiler audit/build, native tests, actual-source Lean replay/axiom
audit and independent fresh kernel check all passed.
[named-strings.md](named-strings.md) records evidence and the retained warm
GNATprove JSON-reader failure separately. Stable copies of completed named evidence are retained before beginning the
argument increment.

Command-line runtime, report/snapshot integration and recognizer prototypes have
focused proofs and native boundary evidence in ignored Linux experiment trees.
They remain isolated until the named-only increment is committed; then integrate
and validate the guarded argument form without stopping the active goal. Root owns
catalogue/spec/samples/tests; proof subthreads own typed expressions, membership,
semantics and actual-source bridges. No Oracle amendment or publication.

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
[roadmap](../roadmap.md#hello-world-with-a-command-line-message): first
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
