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
