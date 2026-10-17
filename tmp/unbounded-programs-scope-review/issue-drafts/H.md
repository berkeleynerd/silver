TITLE: Unbounded programs: Validation, review and delivery
LABELS: type: work package, area: assurance, area: docs, area: tooling
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in a dated session-memory entry on `main`, before it moves to Ready. It depends on #{B}–#{G}. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#validation-plan) governs it.

**Order 8.** Revise the development checkpoint for a language without capacity caps, run it once on the stable inputs, obtain independent review and publish consistent support records.

- **Revise `development.md`'s checkpoint.**
  - Boundary tests at each explicit limit and one past it.
  - Universal Lean theorems whose only size hypotheses are the explicit language limits and the recorded side conditions.
  - The scaling ladder recorded, not used as thresholds.
  - No incompleteness outcome anywhere.
  - Exit-status tests for every observation mechanism.
  - Resource-failure tests under `ulimit -v`, `-s`, `-f` and `-t` and a full disk. When admission or build exhausts a resource, the command never returns 0 or 2 and publishes no executable. When only confirmation exhausts it, `compile` and `run` keep their build status and executable and report the confirmation as not confirmed, and `silver confirm` returns 4.
- **Run the complete checkpoint.** A complete native audit, a complete Lean run with a fresh axiom audit, and the full test suite on the stable inputs, with actual input identities and cache provenance recorded.
- **Independent review.** Review covers the language, admission, confirmation, outcome classification, premises, validation records and Rosetta. Findings follow the usual disposition.
- **Synchronize the records.** `language.md`, the catalogue, the scope and capability record, `docs/assurance.md`, `docs/trusted-boundary.md`, the README, roadmap, RESUME and session memory. Reassess Rosetta tasks whose only blocker was a capacity limit.

**Completion criteria**

- The checkpoint passes with recorded evidence, review findings are dispositioned, and the records agree.
- Native macOS re-probes of the tool-derived limits remain independent and nonblocking. Hosted CI stays disabled.
- The milestone closes through the completing commit.
