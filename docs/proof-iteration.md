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
in this record. The authorization-only change does not claim delivery.

## Managed interface

Read the current managed runs before resuming proof work:

```sh
python3 scripts/dev.py runs status --task '#39'
```

Omit `--task` to include all task labels in this repository's native host and
machine history. Read the live Git status, issue authorization and harness goal
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
For a custom project whose inputs and writable paths cannot be derived from the
normal project, declare the actual writable workspace roots with repeatable
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

## Recurring failures and handoff

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
identity only covers diagnostics the runners recognize; the agent must also
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
