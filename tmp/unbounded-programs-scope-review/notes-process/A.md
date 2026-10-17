TITLE: Unbounded programs: Scope and design
LABELS: type: work package, area: planning, area: language, area: assurance
---
The owner asked on 2026-10-17: "Let's turn it into a milestone scope document and add relevant issues." That direct request authorizes this scope and design work package only: the scope proposal, its evidence record, the roadmap entry, the milestone and its work packages, with routine commits and publication of that planning. Implementation packages #{B}–#{H} remain Backlog until the owner says "proceed" and a dated session-memory entry on `main` records it.

The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md) records the owner's direction: no unadjustable or unnecessary arbitrary limits; compilation fails only through resource exhaustion; and per-program GNATprove becomes a non-gating confirmation whose failures are defect reports. The [roadmap](https://github.com/berkeleynerd/silver/blob/main/roadmap.md#unbounded-programs) records the order. The [session memory](https://github.com/berkeleynerd/silver/blob/main/docs/session-memory.md#2026-10-17--unbounded-programs-scoping-requested) records the owner's words. Current support stays in `language.md` and the catalogue.

**Order 1; scope and design.** Turn the research-backed proposal (five read-only tracks covering native capacities, Lean generalization, pinned-tool hard limits, proof scaling, and Oracle and assurance consequences) into a reviewable milestone scope.

**Completion criteria**

- Publish the scope proposal. It must state the goal, the compile and confirmation design, the outcome and exit-status contract, the confirmation prover configuration, the removed limits, the kept pinned-tool and inherited limits with their evidence, the trusted premises, the research evidence by class (proved, observed, premise), the work-package order, the validation plan, and the risks and non-goals.
- Publish a curated evidence record (`docs/evidence/unbounded-programs/scoping-research.json`) and retain the raw research locally with a SHA-256 manifest.
- Record the milestone order and the single remaining owner step in the roadmap, and the owner's direction in session memory.
- Create the milestone and one issue per work package with scope and completion criteria, in Backlog except this package.
- Pass independent read-only review of the scope documents and issue drafts, local link and anchor checks, and `git diff --check`. Do not implement, build, prove or test any implementation change.
