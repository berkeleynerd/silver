# Silver session guidance

Read [oracle.md](oracle.md), [language.md](language.md),
[development.md](development.md), [roadmap.md](roadmap.md), and the dated
[session memory](docs/session-memory.md) before substantial work, then check the
open issues of the current milestone and open `type: decision` issues as
[planning](docs/planning.md) describes.
Follow the current human request; a proposal, roadmap entry or issue alone does
not authorize implementation.

The primary coding agent implements owner-authorized work. The planning agent
maintains the board, issues, Rosetta assessments and reviews. Start only Ready
items whose owner authorization is recorded, or work the owner requests directly.

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
