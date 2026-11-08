# Silver session guidance

The lead reads [oracle.md](oracle.md), [language.md](language.md),
[development.md](development.md), [roadmap.md](roadmap.md), and the dated
[session memory](docs/session-memory.md) before substantial work, then check the
open issues of the current milestone and open `type: decision` issues as
[planning](docs/planning.md) describes.
Follow the current human request; a proposal, roadmap entry or issue alone does
not authorize implementation.

For a bounded subthread, the lead supplies the objective and authorization,
applicable Oracle requirements, exact owned files, relevant milestone decisions
and evidence, and completion criteria. The subthread reads this file and the
relevant linked sections; it need not reread the entire session memory or all
governing documents. Expand that context whenever a guarantee, dependency or
scope is uncertain. This briefing never waives an applicable requirement.

The primary coding agent implements owner-authorized work. The planning agent
maintains the board, issues, Rosetta assessments and reviews. Start only Ready
items whose owner authorization is recorded, or work the owner requests directly.

## Models, effort and delegation

This project policy travels with the repository; it does not depend on another
agent having the lead's global instructions. Favor more intelligence when the
task's uncertainty or consequences are unclear. Use the following starting
points when available (mapping clarified by the owner on 2026-11-08).
Use the more specific work category when roles overlap:

| Work | Model | Effort |
| --- | --- | --- |
| Lead or unclassified work; uncertain research, architecture, capacity, soundness or consequential judgment | GPT-6 Astra | Extra High |
| New proof or contract design, source correspondence, uncertain proof diagnosis, proof-memory strategy or cross-system proof integration | GPT-6 Astra | Max |
| Independent review of a critical proof, contract or source-correspondence argument | GPT-6 Astra | Max |
| Independent review of another high-consequence change | GPT-6 Astra | Extra High |
| Substantial implementation, debugging or proof with an established approach | GPT-6.1 Sol | Extra High |
| Directly checkable extraction, inventory or transformation | GPT-6.1 Sol | Extra High |
| Routine implementation, documentation, monitoring, evidence collection/scripts or coordination | GPT-6.1 Sol | High |

Use Sol in place of Luna. When proof implementation leaves an established
approach, use Astra Max for the unresolved design or diagnosis. Repeated
unsuccessful repairs, unclear solver/model behavior, or unresolved integration
or memory strategy call for reassessment before another expensive complete run;
do not wait for the runner's recurring-failure threshold. Record the question
and next focused check in the existing task record. Return to established
implementation or routine settings when the remaining work fits those categories.

Elapsed compiler or prover time alone does not justify escalation. Keep routine
monitoring at Sol High and preserve productive running jobs; additional agent
reasoning does not accelerate an already-running proof computation. Effort cannot
replace missing evidence or required validation. Honor explicit owner choices;
consult current official guidance when model availability changes. Do not silently
lower the tier when a model or usage allocation is unavailable.

Before a fan-out, briefly state the expected subthreads, models/efforts and
deliverables. Delegate only separable work with explicit ownership and review
the results. Reserve Ultra for a named unresolved problem where meaningful
parallel investigation justifies it; automated delegation follows the same
ownership, permissions and resource rules. Select
second opinions by the unresolved question and consequences, across providers
when available and authorized; avoid a fixed vendor or verifier-count rule.

Agent concurrency is separate from native worker and memory allocation. Respect
actual session slots, workspace leases and host headroom. Use managed runners
and their worker reservations. Start Lean runs with all available CPUs: omit
`--workers` and `--threads` unless a current resource constraint calls for fewer.
Scale down as needed and record the reason with that run; do not carry a previous
run's one-worker or one-thread restriction forward by habit. Serialize dense runs
when their combined requirements exceed available resources. A read-only role
instruction is not a separate sandbox. Apply the
[configuration and reporting guidance](docs/agent-workflow.md)
and [round monitoring rules](development.md#goal-and-review-bookkeeping).
Report actual settings; changing saved defaults does not prove a live lead
model or effort changed.

## Authority and priorities

- The Oracle supplies the guarantees and requires the owner's explicit approval
  for amendments. Routine work within an authorized task needs no extra approval.
- Follow the pre-1.0 policy and workflow in `development.md`: one evolving
  language, explicit intentional changes, and assurance for every currently
  admitted program. Do not introduce versioned-profile maintenance, historical
  compatibility machinery, release gates, or additional approval ceremonies.
- Prioritize the foundations needed for the authorized capability. Independently
  addable hardening, such as binary attestations and deployment provenance, stays
  deferred until its use case requires it. Keep existing checks; do not classify
  source correspondence or complete obligation discharge as optional hardening.
- Use [docs/assurance.md](docs/assurance.md) for exact proof claims and
  [docs/trusted-boundary.md](docs/trusted-boundary.md) for assumptions. Samples
  exercise language rules; they do not establish universal assurance.

## Working conventions

- Keep `oracle.md`, `language.md`, `roadmap.md` and `development.md` at the root
  for human review. Current support and future plans must remain distinct.
- If a task is split into increments, create one issue per increment in its
  milestone, with scope and completion criteria, in the same planning step, and
  record the milestone's order and remaining decisions in `roadmap.md`. Keep
  issue status current on the board as work progresses; a partial increment does
  not complete its parent. Reference the issue in each commit that advances it,
  and close it with `Fixes #<n>` in the commit that completes it. This
  bookkeeping is the agent's responsibility, without another user reminder; see
  [planning](docs/planning.md).
- Inspect Git status before editing. Preserve unrelated work and scratch files.
  Follow the current request about staging, committing and publishing; the
  session memory records the current publication authorization.
- Other agents may share the checkout. Use a separate worktree and branch for a
  separate stream; never use a bare `git stash`. Keep unrelated tooling outside
  `scripts/`: its Python files feed the proof-provenance hashes.
- When admitting a construct, update the language, catalogue, samples, roadmap
  capability status and capability record together. Follow the
  [Rosetta update steps](docs/planning.md#rosetta-progression), including the
  supported identifier, current-language description, render and stage issue.
- Determine the actual host rather than inferring it from the checkout path.
  Linux is primary; macOS validation is independent and nonblocking.
- Use `scripts/dev.py` and its `paths` command. Preserve other hosts' artifacts
  in `.tools/<host>/` and `.silver/<host>/`. Moving the installation requires
  bootstrap and rebuild; see [platform coexistence](docs/platform-coexistence.md).
- Validate in proportion to the change using the workflow in `development.md`.
  Report evidence by actual inputs and native platform. Cached results, clean
  reruns, retained macOS evidence and configured CI are distinct claims.
- Read the managed run summary before starting or resuming expensive validation.
  Before an expensive integrated native or Lean checkpoint, establish focused
  success for each new helper's complete contract and each changed helper contract,
  including affected callees and callers. Use whole-subprogram native checks and
  the relevant Lean targets over the full declared domains; batch targets and
  reuse matching successes as [development.md](development.md#proof-loop-and-validation)
  describes. Focused checks do not replace complete assurance.
  Coordinate actual workspaces and worker allocations across subthreads; retain
  successful evidence and record the reason for an identical-success expensive
  rerun. Recurring failed obligations need a diagnostic checkpoint with evidence,
  the attempted changes and the next hypothesis. Follow the
  [proof-iteration workflow](docs/proof-iteration.md); its ledger never replaces
  required obligation, source-correspondence or provenance checks.
- Review source-shape pin changes together with their source and semantic proof
  changes. Updating a pin alone does not establish correspondence.
- Use focused subthreads with explicit file ownership and review their results.
  Maintain a concise checkpoint before context loss.
- Follow the [goal and review bookkeeping](development.md#goal-and-review-bookkeeping)
  at handoffs. Read the live harness goal; its objective/status and the conversation
  title are separate. Keep the review target, implementation commit, evidence and
  proposed next work distinct.

## Durable memory

Record owner decisions and authorizations in `docs/session-memory.md`, with
dates and links to detailed evidence. Record work status and handoffs on the
affected GitHub issues. Memories cannot override the Oracle or newer human
instructions. Keep volatile totals and artifact hashes in their evidence record
instead of copying them into session rules. Preserve historical records as history.

When CLI memory is available, keep a concise Silver-scoped recall entry aligned
with durable decisions and pointing to these checked-in documents. Recheck live
state at handoff; CLI memory is not authoritative. Report whether it was actually
updated rather than assuming background memory generation has completed.

Use only the conventional `AGENTS.md` spelling for automatic discovery. A
case-only `agents.md` alias can collide on macOS filesystems.
