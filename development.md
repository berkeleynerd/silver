# Developing Silver

The [Oracle](oracle.md) governs correctness. [language.md](language.md) describes
current support, and [roadmap.md](roadmap.md) records proposed work. Follow the
current human task; a roadmap entry alone does not authorize implementation.

## Pre-1.0 development policy

Silver is one evolving language. Prioritize the current capability, foundational
correctness and development speed. Add infrastructure when it meets a
demonstrated need or avoids a costly architectural mistake. Record independently
addable hardening as deferred. Review suggestions are inputs to engineering
judgment, not automatic requirements.

Use Git history instead of maintaining historical language editions. Keep
existing samples working by default; deliberate changes to syntax or behavior
must update the specification, catalogue, implementation, proofs and affected
examples together. The current language must retain its complete assurance
guarantee. Do not silently remove cases or suppress obligations to make a
failing proof pass.

Intermediate builds and experiments need no proof gate. Before describing a
capability as supported, validate its current implementation and assurance.
Binary attestations, comprehensive per-program dependency manifests and
additional adversarial workspace defenses are deferred until distribution or
stronger reproducibility claims require them. Existing safeguards remain.

Additional solvers, proof assistants and checkers must address a concrete gap
in end-to-end proof coverage or automatic discharge for the current or authorized
next capability. Defer redundant solver runs, second kernels and duplicated
proof developments until practical use justifies them. Solver certificates can
reduce an approved trust assumption, but do not by themselves establish faithful
obligation generation or that every admitted program automatically proves.
Use the existing SPARK/Lean tools for missing arguments where they suffice.
This preserves existing checks and the work needed for a fast cached proof loop.

## Admit one coherent capability

Prefer a small capability motivated by a sample. Closely coupled syntax may
arrive together. Do not add extra operations solely to create intermediate
examples, or turn every anticipated infrastructure component into a project.

When a task cannot be completed as one increment, create one issue per increment
in its GitHub milestone, with scope and completion criteria, when making that
decision. Record the order, direction and remaining decisions in `roadmap.md`;
keep live work status and handoffs on the issues and board, as
[planning](docs/planning.md) describes. Preserve all requirements from the parent
task and update the plan when scope changes; do not leave the split only in
conversation or mark the parent complete after a partial result.
This is the agent's responsibility. Related increments may share a validation
checkpoint within the authorized scope; recording a split adds no approval gate
and does not itself authorize implementation.

For each authorized increment:

1. Specify syntax, behavior, bounds and permitted compositions. For libraries,
   include operation identity, elaboration, effects, failure behavior and trusted
   assumptions. Use a focused experiment to discover actual obligation classes
   before choosing new proof/report infrastructure.
2. Implement and verify affected Silver-owned code in SPARK. Extend membership,
   composition, correspondence and automatic-discharge arguments over the entire
   resulting language. Preserve the author's source through proof and build and
   maintain correspondence with the selected library specifications and bodies.
3. Audit all required obligations and coverage. The application-unit safety-obligation set
   follows the source-selected static/argument/assigned/selected policy; finite exact entity
   alternatives cover sequences without output and producer elimination.
   The shared-binding checkpoint admitted proved range and length checks. The
   scalar/loop policy also admits proved overflow checks, supported by the
   scalar intermediate-interval, Image-length and loop-composition schemas.
   Interval-checked division also admits proved nonzero-divisor checks, with
   explicit quotient/remainder semantics and corresponding
   [discharge schemas](docs/assurance.md#interval-checked-integer-division). Its
   [feature-local envelope](docs/integer-division-report-capacity.md) retains the
   existing report storage bound; report classification alone does not establish
   discharge. Every emitted Main safety check must be proved with the exact required provenance; applicable
   static elimination may leave an empty list. All output forms precisely classify initializer advisories;
   assignment-bearing forms additionally classify the exact unused-assignment
   advisory. All sequence policies classify the exact ineffective-statement
   and unreachable-statement advisories for constant equality, and the four
   exact overwritten ghost-output advisories for each of Put and Put_Line.
   The scalar/Image policy also classifies the exact pinned Image advisory under
   its own complete warning/provenance rules; it never waives a safety check.
   Fixed-size Integer arrays add proved index checks and the exact pinned
   array-loop initialization advisory in Main. The latter withholds a flow fact;
   it never replaces initialization or safety checks. Its
   [producer/capacity account](docs/fixed-integer-arrays-report-capacity.md) covers
   repeated nested-loop notes within the unchanged source/operator budgets.
   Other diagnostics remain rejected. A new accepted obligation class
   needs a corresponding semantic/discharge argument, not just report handling.
   The [shared-binding checkpoint](docs/shared-bindings.md) records the completed
   assurance and validation for that earlier policy; the
   [scalar/loop delivery record](docs/for-loops-integers.md#delivery-assurance-chain)
   records its extension. Every output form
   still requires the complete nonempty selected library reports.
   Extend report handling when new
   obligation classes or selected units require it. Keep [assurance claims](docs/assurance.md) and
   [trusted assumptions](docs/trusted-boundary.md) accurate.
4. Update the specification, catalogue, motivating sample, roadmap capability
   status and capability record together. Update the Rosetta supported constructs,
   current-language description and rendered progression, then update or close
   the stage issue, following [planning](docs/planning.md#rosetta-progression). Exercise
   boundaries, nearby rejected forms and interactions with existing constructs.
   Shared typed rules are useful when expansion makes duplicate metadata costly;
   a general catalogue framework is not a prerequisite now.
5. Run full validation, record actual evidence and mark the capability supported.
   Samples exercise the rules; universal proofs establish their guarantee.

The fixed Ada/SPARK editions define inherited meaning. Changes to the Oracle
need explicit human approval; routine authorized implementation does not need
repeated approval. Source-pin updates in `ReviewedSourceShape.lean` and
`ReviewedOutputShape.lean` receive
ordinary semantic review with the source diff: examine declarations, bindings,
operators and the modeled equations. Regenerating a matching pin alone does not
establish correspondence.

## Proof loop and validation

Run from the repository root. Use `scripts/bootstrap.py` and
`scripts/bootstrap_lean.py` when tools need installation. Moving the installation
requires bootstrap and rebuild. During iteration, run the smallest check relevant
to the change: a build and focused tests for executable behavior, incremental
GNATprove for SPARK changes, or focused Lean proofs for the changed argument.
The commands below are a menu, not a sequence to repeat after every edit:

```sh
python3 scripts/dev.py prove
python3 scripts/dev.py build
python3 scripts/dev.py test -- -p test_string_assignment.py
python3 scripts/check_lean.py --target Silver.PredicateChecks
```

Use the managed run summary at startup, after interruption and before an expensive
checkpoint. Compare retained evidence with the current inputs and configuration,
then choose the smallest outstanding check. The
[proof-iteration record](docs/proof-iteration.md) describes the ledger, workspace
leases, provenance preflight and runner interface. These controls record and
coordinate development work; required proof manifests and actual artifact checks
remain authoritative.

Choose the test file for the affected behavior. Batch recognizer and proof edits
before rebuilding the expensive source certificates; focused model proofs give
early feedback, while actual-source correspondence remains required at the
capability checkpoint. `check_lean.py --target MODULE` synchronizes the proof
workspace, builds that module and its dependencies, and freshly audits their
actual imported declarations. Repeat `--target` to select several modules.
Focused results are recorded separately and do not establish complete
source correspondence, even when every selected proof passes. Use the runner
instead of invoking Lake on potentially stale workspace copies. After changes
to embedded Ada source,
queue the complete source-correspondence run for a stable checkpoint, normally
the end of the session or day. Keep the capability pending until that checkpoint
passes; record the exact inputs and outstanding validation when handing it off.
Preserve a running checkpoint and its completed objects rather than restarting
it for unrelated work. Keep its captured source/proof/tooling inputs stable;
continue with documentation, read-only work or an isolated worktree. Run only
one writer against a host's proof workspace. Reuse successful native checks
whose inputs remain unchanged.

`python3 scripts/check_lean.py` performs a complete cached build and fresh
whole-project axiom/module-coverage audit. It still rebuilds certificates affected
by embedded-source changes. Choose model targets during exploration; complete
the source proofs at the stable checkpoint. Shared dependencies can rebuild
in either mode. Independent kernel replay is optional, selected by `--replay`
(`--full` remains an alias), and cannot be combined with `--target`.
Documentation-only changes need link, consistency and whitespace checks,
without unrelated proof or test reruns.

GNATprove uses incremental analysis and its native local filesystem result cache.
The default `--jobs 0` reserves the available managed worker budget; use `--jobs N`
to reserve a smaller share for concurrent work or memory pressure. With no other
managed run, the budget starts at the detected CPU count. Incremental runs preserve
sessions and reports but invalidate the previous completed full-audit manifest. They
provide development feedback, not a new full assurance record.

Lean retains Lake artifacts and rebuilds changed dependencies. The
[measured source partition](docs/lean-compartmentalization.md) gives each
embedded Ada file its own handwritten binding and binary Lake dependency.
Changing just that file invalidates its binding, certificate and transitive
importers; unrelated certificates and source-independent model modules can
remain cached. Shared Lean changes can invalidate additional modules. Import
only the certificates a source check uses; retain the complete facade at the
project root. The [focused source-check record](docs/focused-source-checks.md)
documents the dependency reduction and invalidation controls. The stable
checkpoint and complete source-correspondence requirement remain. The module/axiom
audit executes on every invocation, including cache hits, with the selected
import scope. Ordinary proof files use Lean's `module` system, preserving existing
reexports with public imports and exposing computational definitions used by
downstream proofs. Private theorem-body edits can retain consumer artifacts;
public interface or exposed-definition changes still propagate. Keep `Audit.lean`,
`AxiomAudit.lean` and generated focused audit drivers legacy so their fresh audits
retain transitive private-declaration coverage. Preserve `.olean.server` and
`.olean.private` alongside ordinary objects and Lake metadata when copying a
cache. See the [module migration](docs/lean-modules.md) for measurements and
invalidation controls. `--workers N` controls Lake's workers for independent
modules; its default `0` reserves the available managed worker budget.
`--threads N` separately controls each Lean build/audit process. Its default `0`
selects the CPUs available through process affinity and Python's CPU count.
Start future Lean runs with these automatic defaults, allowing all available
CPUs. Use explicit lower counts when CPU quotas, competing workloads or observed
memory pressure require them, and record the reason in the run's `--reason` or
task record. Reassess that reduction for the next run instead of inheriting a
one-worker or one-thread setting. Worker pools can multiply across modules;
these settings are not strict OS-thread caps or a promise that every proof uses
every core. The
[concurrency record](docs/lean-concurrency.md) measures the selected settings and
explains the remaining serial certificate and kernel work. Independent per-file
source-certificate modules can still build concurrently. The runner re-elaborates
Lake configuration
so each invocation actually applies its requested thread and memory settings.
`--memory-mb N` sets Lean's internal per-process resident-memory threshold in
MiB for build/audit processes. Lean checks it periodically; it is neither a hard
OS-enforced cap nor a budget for all concurrently scheduled modules. The separate
pinned `leanchecker --fresh` executable has no memory-limit CLI option; observe
host headroom during that phase as well.

Once a capability's implementation and proof inputs are stable, run one complete
validation checkpoint before describing it as supported. Enter it with:

- Planned Ada implementation and annotation edits finished, and known failures
  requiring source changes resolved through focused iteration. Inspect retained
  diagnostics and report obligations; tool exit status alone is insufficient.
- Applicable cheap certificate-parity and handwritten source-shape/pin checks
  reviewed together with their source and semantic changes. Expensive source
  proofs belong inside the checkpoint, not in a mandatory entry precheck.
- A preferably committed snapshot, with captured input bytes verified against
  it; an equivalent verified exact-byte snapshot is valid. Keep those inputs
  stable throughout the run and record outstanding checks at handoff.
- Retained results classified using the [invalidation matrix](docs/proof-iteration.md#input-changes-and-evidence-refresh),
  and resources chosen for the actual host, concurrent work and memory headroom.

The commands below form the complete checkpoint, without prescribing serial
order. A focused native check can expose annotation repairs before a long Lean
build; independent native and Lean work can usefully overlap when reservations
and host headroom permit. Run the full regression/sample suite on the stable
delivery inputs, using only the reviewed reuse provision below for retained
results from a failed run.

```sh
python3 scripts/dev.py prove --full
python3 scripts/dev.py build
python3 scripts/dev.py test
python3 scripts/check_lean.py
```

The regression and sample-test requirement may be satisfied by a completed
full-suite run plus successful repair reruns when a recorded independent review
accounts for the complete final test inventory and establishes which successful
results remain applicable to the final inputs and settings. Review the exact
input changes and dependencies; rerun every failed or affected test, including
effects through shared fixtures, tooling or generated artifacts. No required
test may remain uncovered or failing. Retain failed runs as failed and distinguish
reused results from fresh passes. If coverage or applicability cannot be
established, rerun the full suite. Use existing run records and ordinary change
review; no new evidence format is required. This composes test results only:
successful complete native proof/audit and Lean/source-correspondence checkpoints
remain mandatory.

After successful validation, repeat only checks invalidated by changed inputs,
a failure or a concrete unresolved concern. Preserve successful work and caches;
do not repeat the whole checkpoint for documentation-only follow-ups. This
cadence allows incomplete experiments during development, but does not defer
complete obligation discharge or source correspondence beyond capability
completion. The compiler's proof and report checks on each admitted user program
remain mandatory and unchanged.

Before an expensive repeat with identical successful inputs and settings, record
the concrete reason, such as a cache investigation or explicit measurement.
Changing only an output directory does not justify redoing successful work.
The runner still executes requested checks; it neither accepts ledger success as
proof nor silently substitutes an old result. Routine cached iteration needs no
boilerplate rationale, and a reason requires no additional owner approval.

When an obligation repeatedly fails, stop blind reruns and write a diagnostic
checkpoint: the failed obligation, attempts and changed inputs, retained evidence,
current hypothesis and next experiment. A failed solver attempt within an
otherwise successful proof does not count as an unresolved obligation. The
checkpoint makes the next attempt deliberate; it adds no fixed proof timeout,
retry ceiling or weaker discharge rule. Keep the diagnostic with the run history
and identify it in the issue handoff.

Full GNATprove validation forces unit analysis, regenerates reports and audits
complete coverage and provenance; native sessions and solver-cache results may
be reused. It establishes a complete audit, not an uncached runtime bound.
Optional `dev.py prove --cold` implies full validation and allocates a unique
fresh output/session/cache workspace. It prints the separate evidence path and
preserves the normal warm state and every other host's artifacts. Cold mode
rejects custom `--subdirs`. Use it for a fresh-proof measurement, toolchain
investigation or suspected cache problem, not as a mandatory capability gate.

Routine Lean validation trusts the pinned local toolchain and Lake's imported
objects, checks stable inputs between phases, and freshly audits the expected
module coverage and transitive axioms. `--replay` additionally runs the independent
`leanchecker --fresh` over the whole project. Reserve it for toolchain changes,
cache investigations or an explicit audit; the Oracle does not require this
second replay. `--provenance` adds detailed input, workspace and artifact
inventories to the concise content-bound result and streamed log.

Kernel checking must stay enabled in every module. The runner rejects direct
kernel-bypass names in proof sources, generated candidates and Lake configuration,
and checks retained build traces for unsafe compiler arguments even after a
configuration edit is reverted. The sole permitted reference is the audit's
exact read-only option guard. Keep bypass experiments in separate scratch
projects. A rejected cache remains intact for diagnosis; preserve it before
rebuilding with safe inputs. This source policy retains the trusted local
tool/cache boundary and does not sandbox arbitrary metaprograms.

If inputs change during a long build, the runner stops before later expensive
work and retains completed module objects. `--clean` discards only the current
host's proof workspace; it does not imply replay. Use it when investigating
cache or toolchain problems, not for everyday edits. These choices do not remove
source-correspondence proofs or change allowed axioms. Cached evidence must
apply to the current inputs and configuration. The
[focused-runner record](docs/lean-iteration.md) documents this workflow change
and its validation.

For exploratory GNATprove options, use a separate output directory:

```sh
python3 scripts/dev.py tool -- gnatprove -P ../../../silver.gpr \
  --subdirs=explore/trial --timeout=60 \
  -XSILVER_HOST="$(python3 scripts/dev.py paths --field host)"
```

Direct `gnatprove` calls through `dev.py tool` require `--subdirs=explore` or a
directory below it; help and version queries are exempt. An optional filesystem
solver cache must be outside the managed `.silver/<host>/proof-cache/` tree and
the cold workspaces' `cache/` directories. This guard prevents ordinary command
mistakes; it is not an adversarial boundary for arbitrary commands or wrappers.
Exploratory runs do not produce the audited success manifest.

GNATprove failures remain failures; no automatic retry is performed. The
recorded `DOC_END` diagnostic identifies an unexpected end of JSON input. A
parallel-write race has not been established. `--jobs 1` is a diagnostic
comparison, not a verified workaround; the default allocates the available managed
worker budget. Preserve
a recurrence's logs and inputs before another run replaces them. See
[the workflow record](docs/proof-workflow.md) and
[Hello World evidence](docs/hello-world.md) for observed failures and subsequent
validation. Cold success does not establish that the warm-state defect is fixed.

Use the symlinked-TMPDIR regression to exercise path portability on Linux.
For Markdown-only changes, check links, current-language consistency and
`git diff --check`; rerun proofs only when affected inputs or claims warrant it.
Record incremental, full, clean and reused results accurately. Keep timings and
counts in the relevant [capability or workflow evidence record](README.md#proofs-and-platform-evidence),
not acceptance thresholds.

## Samples, platforms and handoffs

[samples/null.adb](samples/null.adb) preserves the original source bytes. The
[sample manifest](samples/manifest.json) links supported samples to capabilities,
specification references and expected output/exit status. Proposed examples stay
in the roadmap; rejected fixtures stay in tests. The manifest-driven test admits,
proves, builds and executes every supported sample, comparing application output
separately from compiler diagnostics.

Linux is primary; native macOS validation is independent and nonblocking.
Distinguish native evidence, mocked routing and configured-but-unrun CI.
Use `scripts/dev.py paths` and preserve native host isolation under `.tools/`
and `.silver/`. See [platform coexistence](docs/platform-coexistence.md).

[AGENTS.md](AGENTS.md) supplies session guidance and
[docs/session-memory.md](docs/session-memory.md) records dated owner decisions
and authorizations; affected issue comments carry handoffs. Use subthreads with
explicit ownership for separable work. Keep
temporary experiments separate and preserve unrelated scratch files.

Runtime source edits require refreshing bootstrap, rebuilding Silver and
rechecking compiler and Lean evidence together. Bootstrap embeds exact selected
library bytes; a stale compiler rejects changed installed runtime files. This
source binding is part of correspondence, not deferred binary attestation.

## Goal and review bookkeeping

Consolidate candidate findings before verification, merging duplicates and
checking the governing requirement and actual evidence scope. Use additional
independent verification for blocker claims or unresolved disagreements,
proportionate to impact. Before repeated broad review or validation, make a
whole-team cost checkpoint that includes all subthreads, existing successes
and the smallest remaining check. Do not prescribe a fixed verifier count or
repeat an expensive success solely to obtain a new record. Required obligation
discharge, source correspondence and independent review remain unchanged.

Use the portable [model and delegation policy](AGENTS.md#models-effort-and-delegation)
and [host configuration guidance](docs/agent-workflow.md). At a substantive round
boundary, retain a compact row in the existing task/evidence record with the
actual model and effort, intended result, achieved result, material findings or
rework, and available elapsed time/token/cost evidence. Include all subthreads
when making a whole-team comparison. Separate native execution time from total
elapsed time; label unavailable measurements and never infer model quality from
token volume, agent count or an uncontrolled comparison. Reassess when work
fails repeatedly, stalls or reaches a context handoff; integrate established
results before opening another investigation. This monitoring adds no approval
ceremony and does not replace required verification.

Every new review report records the reviewed commit or exact inputs, reviewer
model(s) and effort actually used, elapsed time and token/cost evidence when
available, and material findings/disposition. If a setting or measurement is
unavailable, say so. Record selected settings separately from runtime-confirmed
settings. Use the existing report format; no additional template or duplicate
review is required merely to populate these fields. Preserve historical reports
as history rather than inventing their missing model or cost data.

- When resuming goal-driven work, read the live harness objective and status and
  reconcile them with the owner's current authorization. For an explicitly
  requested new goal, record its scope and completion/stop conditions and keep
  the separate conversation title aligned where title controls are available.
  A roadmap proposal or display title does not start, replace or complete a
  harness goal. Mark completion only when its actual work, validation and any
  required local commit are finished.
- At completion or handoff, update the affected documents under the workflow
  above and comment on the affected issues, closing those that are complete. The
  comment identifies the implementation commit, any relevant later documentation
  commit, the exact review target, evidence links, unresolved items and next
  authorized step. Add a concise dated memory entry for owner decisions and
  authorizations, as [planning](docs/planning.md) describes. Report the closing commit
  and remaining Git state, preserving unrelated files. Git history identifies
  the commit containing an entry; do not create another commit merely to insert
  that entry's own commit hash. Keep volatile results in the evidence record.
- Tie each review to its reviewed commit even when later documentation changes
  advance HEAD. In the existing capability or repair record, retain a short
  disposition of material findings: independently confirmed or unconfirmed,
  fixed, deferred with a reason, or rejected with a reason, with supporting
  evidence. External validation keeps its actual host/input scope. File open
  actions as `type: finding` or `type: follow-up` issues without treating every
  suggestion as mandatory work. Reuse existing records and ordinary validation rules.
