# Silver session guidance

Read [oracle.md](oracle.md), [language.md](language.md),
[development.md](development.md), [roadmap.md](roadmap.md), and the dated
[session memory](docs/session-memory.md) before substantial work. Follow the
current human request; a proposal or roadmap entry alone does not authorize
implementation.

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
- Inspect Git status before editing. Preserve unrelated work and scratch files.
  Follow the current request about staging, committing and publishing; the
  session memory records the current local-only direction.
- Determine the actual host rather than inferring it from the checkout path.
  Linux is primary; macOS validation is independent and nonblocking.
- Use `scripts/dev.py` and its `paths` command. Preserve other hosts' artifacts
  in `.tools/<host>/` and `.silver/<host>/`. Moving the installation requires
  bootstrap and rebuild; see [platform coexistence](docs/platform-coexistence.md).
- Validate in proportion to the change using the workflow in `development.md`.
  Report evidence by actual inputs and native platform. Cached results, clean
  reruns, retained macOS evidence and configured CI are distinct claims.
- Review source-shape pin changes together with their source and semantic proof
  changes. Updating a pin alone does not establish correspondence.
- Use focused subthreads with explicit file ownership and review their results.
  Maintain a concise checkpoint before context loss.

## Durable memory

Record decisions and handoffs in `docs/session-memory.md`, with dates and links
to detailed evidence. Memories cannot override the Oracle or newer human
instructions. Keep volatile totals and artifact hashes in their evidence record
instead of copying them into session rules. Preserve historical records as history.

Use only the conventional `AGENTS.md` spelling for automatic discovery. A
case-only `agents.md` alias can collide on macOS filesystems.
