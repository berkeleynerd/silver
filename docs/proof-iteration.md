# Proof iteration controls

## Authorization and scope

On 2026-10-16, the owner answered the proposed proof-iteration controls with
“Make it so.” [Session memory](session-memory.md) records that authorization.
This is one cohesive tooling milestone,
[Proof iteration controls](https://github.com/berkeleynerd/silver/milestone/2),
with one [work package #39](https://github.com/berkeleynerd/silver/issues/39).
Its components support the same proof loop and are delivered together.

The authorized work is:

- A durable run ledger for `dev.py` and `check_lean.py`, including exploratory
  GNATprove, that identifies actual inputs, command/mode, native host, resolved
  workspace, start/completion, outcome and retained evidence.
- Locks on actual resolved workspaces and coordinated worker use across agents.
- Cheap provenance and input preflight before expensive proof work.
- A recorded rationale for an expensive rerun after success with identical
  inputs and configuration.
- A diagnostic checkpoint when the same proof obligation repeatedly fails,
  preserving evidence and identifying the next hypothesis or experiment.
- A concise resume and handoff readout of completed, running, failed and
  outstanding validation.

These controls preserve every required native obligation/report check, complete
source correspondence and the fresh Lean axiom/coverage audit. They do not add
an arbitrary proof timeout, change language membership or the Oracle, require
owner approval for routine runs, or excuse a failed required check. A run ledger
is workflow evidence; it is not a replacement assurance manifest.

The selected For loops and integers implementation remains preserved separately.
Its harness goal remains paused; this tooling task does not resume it or admit
any new language construct. Existing publication authorization applies. Hosted
CI remains disabled, and native macOS work remains independent and nonblocking.

## Delivery criteria

Implement and review the controls as one work package. Focused runner tests must
cover durable outcomes and interruption, resolved-path writer exclusion, worker
coordination, preflight before expensive work, identical-success rerun rationale,
recurring-failure diagnosis and resume readout. Use proportional native Linux
validation; preserve useful existing caches and earlier evidence. Record the
actual command/input/platform scope of each check and distinguish mocked runner
tests from proof execution and cached artifacts from fresh auditing.

Update [development guidance](../development.md), [session guidance](../AGENTS.md)
and [the handoff](../RESUME.md) for the concrete runner interface once it exists.
Implementation details, validation evidence and review disposition belong below
in this record. The authorization-only change did not claim delivery; the evidence below records the implementation.

## Managed interface

Read the current managed runs before resuming proof work:

```sh
python3 scripts/dev.py runs status --task '#39'
```

Omit `--task` to include all task labels in this repository's native host and
machine history. Status shows the latest 20 completed runs plus every active run;
`--limit 0` shows all runs. The latest 20 checkpoint/diagnostic notes and required
obligation diagnoses accompany the readout. Read live Git status, issue authorization and harness goal
separately: a task label organizes records and never authorizes or resumes work.

`dev.py prove`, `build`, `test` and `tool`, and `check_lean.py`, accept `--task REF`
and `--reason TEXT`. Put these before the `--` that introduces forwarded tool or
test arguments. Use the issue reference as a stable task label across subthreads.
The existing proof commands still determine what is checked:

```sh
python3 scripts/dev.py prove --task '#39'
python3 scripts/check_lean.py --task '#39' --target Silver.PredicateChecks
python3 scripts/dev.py prove --full --task '#39' \
  --reason 'Investigate the retained report discrepancy on identical inputs'
```

The last command illustrates the recorded reason needed before repeating a
successful **expensive** mode with matching inputs and effective settings:
native `prove --full`/`--cold`, or Lean `--clean`/`--replay` (`--full` is the replay
alias). Ordinary incremental GNATprove and cached complete or focused Lean checks
remain recorded without requiring that rationale. A reason can explain an
explicit measurement or concrete unresolved concern; it is an engineering note,
not an owner permission request. The runner always executes an accepted command.
It never silently skips a required check or treats the ledger as its proof.

Exploratory GNATprove continues through `dev.py tool`. The reserved `explore`
output and separate-cache rules in [development](../development.md) still apply.
For a custom tool or project whose inputs and writable paths cannot be derived
from the reviewed native project (including explicit executable paths and output
redirection), declare the actual writable workspace roots with repeatable
`--workspace PATH` and additional source/configuration inputs with repeatable
`--input PATH`, before `-- gnatprove ...`. These declarations let the managed
runner record and coordinate the custom run; they do not prove that an arbitrary
project description lists all of its dependencies.

## Durable history and workspace coordination

Managed run records live below the repository's shared Git common directory at
`silver-runs/<native-host>/<machine-identity>/`, outside the source/proof input
hashes. Worktrees therefore see one history and worker allocation on the same
machine. Non-Git runner fixtures use the host artifact directory's `run-history`.
The run ID, task, source/configuration/tool identities, command, mode, effective
worker request, resolved workspace paths, times, outcome and evidence locations
remain available after the chat or runner ends. Git revision alone is not the
input identity: changed worktree bytes matter, while documentation-only changes
do not invalidate unchanged proof inputs.

The start record is durable before tool launch. Completion records distinguish
success, failure and interruption. A start with a live lease is active; if its
lease has been released without a completion record, status reports it as
interrupted rather than inferring success. Original records remain intact.
Completed proof objects and failed-run evidence should be preserved for diagnosis.

Exclusive leases compare resolved writable paths, including ancestor/descendant
overlap. Separate branch or worktree names do not make a shared output/session/
cache safe for concurrent writers. A conflicting run reports the existing owner
instead of starting another writer. Use a genuinely separate workspace or wait
for the active run; do not remove its lock or restart it to obtain the cache.

The native worker pool is shared by managed runs on this repository and machine.
Default GNATprove `--jobs 0` and Lean `--workers 0` allocate available workers;
explicit positive counts reserve that many and must fit the remaining budget.
Coordinate allocations when launching independent proof streams. Reservations
are scheduling declarations, not an operating-system thread or memory limit:
Lean's per-process threads and prover subprocesses can multiply actual work, and
unmanaged commands are not included. Keep the existing memory/headroom guidance.

Cheap preflight checks input/provenance and workspace assumptions before the
expensive proof phase. A stale or incomplete record cannot establish current
assurance; the existing native manifest audit and Lean input/artifact/axiom checks
remain required. Neither a matching ledger fingerprint nor a matching Git commit
replaces those checks.

## Input changes and evidence refresh

Use this matrix to select the smallest outstanding checks, not to exempt inputs
from hashing. [The retained assessment](development-velocity.md#assessment-and-evidence)
distinguishes failed runs, successful objects and fresh audits. A changed run
identity does not by itself mean every compiled proof must rebuild.

| Changed input | Invalidation and required evidence |
| --- | --- |
| Ada implementation, contracts, annotations or other bytes | Native source/provenance inputs change. Each embedded file's binary dependency in `proof/lakefile.lean` invalidates its handwritten binding, certificate and transitive importers; unrelated certificates/models can remain cached. Review pins with source/semantics and complete native/source assurance on final bytes. |
| Lean private theorem body | Recheck the module and fresh applicable audit. Lean's module artifacts may preserve consumers; follow actual Lake dependencies rather than assuming a whole-project rebuild. |
| Lean public interface, exposed definition or imports | Rebuild affected consumers and review changed statements/dependencies; complete source correspondence and whole-project axiom/coverage auditing remain required. After a `Compose.ParserState` or shared-validity change, check `Silver.SequenceModel` early, before the complete build: it shares that state even when the current Predicate source route does not change. |
| Certificate generator, toolchain or build/configuration | Regenerate affected candidates and validate affected proofs/configuration. `check_lean.py` captures noncandidate Lean, Lake/toolchain/generator files, all root `src/*.ads`/`*.adb` and `scripts/*.py`; `CANDIDATES` are regenerated in the workspace and captured there, not trusted from checked-in copies. Tool executables have separate identities. |
| Auditor-only logic | Refresh applicable complete native/Lean checks, provenance and fresh audits with current inputs; unchanged expensive proof objects can remain cached. Establish that source, semantic proof dependencies, build configuration and obligations are unchanged, and check affected auditor behavior. This does not excuse changed semantic proofs or a failed audit. |
| Tests, fixtures, samples or test tooling | Run affected tests during iteration and cover the final inventory at the stable checkpoint under the existing [regression reuse provision](../development.md#proof-loop-and-validation). A failed run remains failed. Shared tooling/generated-artifact effects count as affected inputs. |
| Documentation only | Check consistency, links and whitespace; unchanged proof/test inputs need no unrelated rerun. |

For native `dev.py` proof/build inputs, `proof_provenance.input_hashes` includes
Ada/generated sources, recursive Python scripts, project files, Alire manifests,
Alire configuration/lock and generated build configuration; tools are identified
separately. Thus even auditor-only Python edits change provenance and require
current matching evidence, while native sessions/cache can retain valid solver
work. Lean likewise freshly audits its selected import scope on cache hits.
Use the [stable-checkpoint entry guidance](../development.md#proof-loop-and-validation)
and existing managed modes; this matrix adds no hash exclusions or replay gate.

## Recurring failures and handoff

Before an expensive integrated native or Lean run, follow the
[complete-helper-contract checks](../development.md#proof-loop-and-validation):
cover every new helper and changed helper contract with whole-subprogram native
checks and applicable focused Lean targets over the full declared domains.
Include affected callees/callers, inspect all selected obligations and record
coverage in the existing task/evidence record. Batch targets and reuse matching
successes. Resolve outstanding helper obligations before the integrated run;
focused success still does not replace the complete assurance checkpoint.

Apply the [model policy](../AGENTS.md#models-effort-and-delegation) as soon as
proof work leaves an established approach. Uncertain solver encoding, Lean
reduction or memory behavior, and cross-system proof integration belong with
Astra Max, as do new proof/contract design, source correspondence and critical
proof review. Repeated unsuccessful repairs require this reassessment before
another expensive complete run, without waiting for the diagnostic threshold below.
Keep the question, retained evidence and next focused check in the existing
diagnostic/task record. Use available focused checks to resolve known integration
failures before the next complete checkpoint. Preserve applicable successes and
productive running jobs; a slow tool computation alone does not require a stronger
monitoring agent. Complete native and Lean assurance remains mandatory.

After three retained attempts report the same failed obligation for the same
task, run kind and target, the next relevant attempt needs a diagnostic checkpoint:

```sh
python3 scripts/dev.py runs diagnose RUN_ID \
  --summary 'The same range obligation remains after the two recorded changes; see retained reports' \
  --next-step 'Test the missing bound in the focused model before another native attempt'
```

Identify the obligation, earlier attempts and evidence, what changed, and the next
hypothesis or experiment. A failed solver attempt within an otherwise successful
proof is not an unresolved obligation. The diagnosis is durable and appears in
the resume readout. It adds no automatic retry, arbitrary timeout or final retry
limit, and never reclassifies a failed proof as success. Automated obligation
identity covers GNATprove report locations and recognized Lean source locations
plus the first diagnostic line. Moving or rewording a Lean diagnostic may change
its key; the agent must also
notice recurring failures that the parser cannot identify.

At a meaningful checkpoint or interruption, save a concise pointer:

```sh
python3 scripts/dev.py runs checkpoint --task '#39' \
  --summary 'Focused checks passed; the stable complete checkpoint is still outstanding' \
  --next-check 'Run the complete cached Lean check once source inputs are stable'
```

Use actual current facts in that text. The pointer supplements the dated session
memory and issue handoff; it does not overwrite their authorization or completion
criteria. At handoff, identify the implementation/review target, relevant run IDs
and evidence, unresolved obligations and the next smallest required check. Read
status again on resume so an old pointer cannot hide a later run or interruption.

The controls govern managed entrypoints. Direct tool commands and arbitrary shell
wrappers can bypass them. The ledger is locally trusted workflow history rather
than tamper-proof storage, and resource reservations cannot establish that a proof
strategy is economical. Review the observed evidence and next experiment.


## Delivery and Linux evidence

Implemented at `666b87ecf8e98b5731e56465541dad4143bf2b0d` on
2026-10-16. Later completion edits are documentation only. The working branch is
`feat/proof-iteration-controls`; the authorization remains PR #40. No Ada, Lean
proof, Oracle, catalogue or admitted-language source changed.

Validation ran on native Linux x86-64. The integration checkout is
`tmp/iteration-workflow`. Native full validation used the preserved repair
checkout `tmp/review-repairs-343c2f8`, detached at the same implementation commit,
to reuse its original-path sessions and solver cache. Its prior branch, ignored
scratch and evidence remain retained. The canonical feature checkout and its
nine tracked modifications were left intact.

| Check | Evidence and result |
| --- | --- |
| Run-history regressions | 19 tests: real process death/inherited leases, cross-worktree and symlink overlap, worker grants, torn journal recovery, recurrence scope and diagnostics, retained nested reports. |
| Native command integration | 24 tests: full/cold rationale, preflight-before-mutation, real short-process logging/FD inheritance, custom declarations and input/executable drift including retargeted symlinks, report retention, status and zero-exit unresolved checks. Native proof execution is mocked in these fixtures. |
| Native provenance regressions | 27 tests: existing evidence/tool/configuration binding plus early tool rejection preserving prior evidence. |
| Lean regression suites | 72 runner, source and module tests passed in 134.789 s, including small native Lean fixtures. The 10 new ledger integration tests were also rechecked after the core updates. |
| Platform routing | 16 tests passed in 46.400 s, covering mocked native/foreign tools, concurrent host isolation and symlinked temporary directories. |
| Native build | Passed in 3.546 s at `9d733b6f07`; the later selector repair changes only custom-tool drift checks. Native sources were unchanged. |
| Complete native audit | Passed in 31.094 s, with eight workers and reused sessions/cache: 61 units, 830 entities, 1,070 flow checks and 12,848 proof checks. Required report and provenance audits passed. |
| Complete cached Lean | Passed in 16.450 s, with four Lake workers/four threads per process and a fresh audit of 57,302 declarations. Independent kernel replay was not requested. |
| Native exploratory failure probe | A small scratch overflow obligation produced tool exit 0; the managed command correctly failed, retained `iteration_probe.adb:3:11:VC_OVERFLOW_CHECK` and its reports, and recorded the distinction in 2.783 s. This is a runner probe, not admitted Silver source. |

These are 158 distinct focused tests, plus the native checks above. The native
command, provenance, ledger and platform suites were checked on the final runner;
the earlier broader Lean suite was supplemented by its affected ledger cases and
the final complete project check. The full
application test suite, a cold full proof, native macOS validation and hosted CI
were not rerun for this tooling change. Hosted Actions remains disabled.

The durable ledger is in the shared Git common directory under
`silver-runs/linux-x86_64/d140f139bb2e1ef1/`. Each listed run has its command,
input identities, resolved workspaces, phase timestamps and outcome in
`runs/<run-id>/events.jsonl`:

- Build: `20261016T130946-96feac6342a1`.
- Complete native audit: `20261016T131452-4eaf28ae2657`; its `proof-evidence/`
  retains the manifest, input snapshot and reports. The convenience manifest is
  `.silver/linux-x86_64/compiler/obj/gnatprove/proof-provenance.json` in the
  original repair checkout.
- Final complete Lean: `20261016T131453-0287972fb552`; its log and
  `lean-evidence.json` are copied into the run directory. The convenience files
  are in the integration checkout's `.silver/linux-x86_64/`.
- Exploratory probe: `20261016T131351-1d967ce5f947`, task `#39-probe`; its retained
  reports and `native.log` explain the expected failure with tool return code 0.
- Managed native-command tests: `20261016T131537-a16020f7fe73`, task `#39-tests`.
- Managed platform tests: `20261016T131607-32018c63248a`, task `#39-tests`.

Additional fixture logs and a ledger snapshot are under
`tmp/iteration-workflow/.silver/linux-x86_64/iteration-validation/`. The managed
platform-test run is discoverable under task `#39-tests` in the same ledger.
The native and Lean checkpoints ran concurrently with reservations totaling
12 workers. The native audit records 1.308 s preflight, 24.078 s native tool
time and 4.791 s audit time; its remaining elapsed time covers ledger/report
retention and setup. A conflicting test request was refused while the Lean workspace
was leased, then passed after that lease ended.

Two development attempts are retained explicitly. The initial build exposed
GPRbuild's required attached `-jN` syntax; its failed run
`20261016T130828-80fc59745e00` took 1.973 s before the repair. Native audit
`20261016T131044-c3fd4b080352` was interrupted after 156.827 s when the copied
worktree's cache was observed recomputing solver work after path relocation.
Its partial reports and log remain intact; it is not successful proof evidence.
The checkpoint note records the move to the original cache location. An earlier
complete cached Lean check took 13.649 s; only the later check covers the final
selector-repair inputs.

Copying GNATprove cache files to a new checkout path does not guarantee reuse.
Preserve the original cache location where practical, inspect actual activity,
and record a diagnosed change of validation location. Lean cache reuse in this
check was effective. Neither cache presence nor a prior successful ledger entry
establishes current proof validity.

## Review and disposition

Independent source review targeted `9ace0e10bc0a8db51099bc6c8174fc5022d66945`,
then `9d733b6f07bcfa82ef815fd9e3e1b4e5fd6e4df7`. The following findings were
independently confirmed and repaired within #39:

| Finding | Disposition |
| --- | --- |
| [#41](https://github.com/berkeleynerd/silver/issues/41): a torn shared notes append could corrupt the next note | Fixed in `d1564ab227`: retain the incomplete bytes separately, truncate to the last committed newline, then append under the metadata lock. Regression verifies repeated interruption and subsequent diagnosis. |
| [#42](https://github.com/berkeleynerd/silver/issues/42): exploratory exit 0 could hide unresolved obligations | Fixed in `08d011bce7` and `0a585427a3`: inspect current reports independently of exit status, retain failed validation with tool status 0, and count its obligation. Fixture and native probe passed. |
| [#43](https://github.com/berkeleynerd/silver/issues/43): retargeted custom selectors could evade drift checks | Fixed in `666b87ecf8`: re-resolve original input/executable selectors and compare paths and bytes. Three regressions reproduced the old defect and now pass, including retargeting to identical bytes. |

Integration review also corrected native output redirection/resource inference,
actual executable identity, report/log retention, stale-report recurrence,
proof-mode/target scoping, and the concise status readout. The two original
findings were re-reviewed as repaired; the final selector change received source
review and the targeted regressions above. No review action remains outstanding
for this tooling package. Direct unmanaged commands, arbitrary wrappers and
adversarial workspace mutation remain outside the cooperative control boundary.

The For loops and integers harness remains paused. CLI memory was unavailable
and was not updated; checked-in session memory, issue handoffs and the live
ledger carry the continuation record.
