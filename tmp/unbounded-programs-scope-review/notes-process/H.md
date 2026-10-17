TITLE: Unbounded programs: Validation, review and delivery
LABELS: type: work package, area: assurance, area: docs, area: tooling
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in session memory. It depends on #{B}–#{G}. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#validation-plan) governs it.

**Order 8.** Revise the development checkpoint for a language without capacity caps, run it once on the stable inputs, obtain independent review and publish consistent support records.

- **Revise `development.md`'s checkpoint.**
  - Boundary tests at each explicit limit and one past it.
  - Universal Lean theorems with no size hypothesis beyond the derived source bound.
  - The scaling ladder recorded, not used as thresholds.
  - No incompleteness outcome anywhere.
  - Resource-failure tests under `ulimit -v`, `-s`, `-f` and `-t` and a full disk: never status 0 or 2, and nothing published.
- **Run the complete checkpoint.** A complete native audit, a complete Lean run with a fresh axiom audit, and the full test suite on the stable inputs, with actual input identities and cache provenance recorded.
- **Independent review.** Review covers the language, admission, confirmation, premises, validation records and Rosetta. Findings follow the usual disposition.
- **Synchronize the records.** `language.md`, the catalogue, the scope and capability record, `docs/assurance.md`, `docs/trusted-boundary.md`, the README, roadmap, RESUME and session memory. Reassess Rosetta tasks whose only blocker was a capacity limit.

**Completion criteria**

- The checkpoint passes with recorded evidence, review findings are dispositioned, and the records agree.
- Native macOS re-probes of the tool-derived limits remain independent and nonblocking. Hosted CI stays disabled.
- The milestone closes through the completing commit.
