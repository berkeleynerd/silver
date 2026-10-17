TITLE: Unbounded programs: Proof confirmation and resource outcomes
LABELS: type: work package, area: compiler, area: assurance, area: tooling, area: docs
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in session memory, before it starts. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#design) governs it; the [roadmap](https://github.com/berkeleynerd/silver/blob/main/roadmap.md#unbounded-programs) records the order.

**Order 2.** Separate building from proving. Compilation becomes verified admission plus build, and per-program GNATprove becomes a non-gating confirmation whose failures are defect reports. Admitted programs do not change.

- `silver compile` and `silver run` admit and build without waiting for GNATprove. The executable is produced when admission and build succeed. `compile` confirms afterwards unless `--no-confirm` is given, and `silver confirm SOURCE` reruns confirmation. A confirmation never removes or blocks the executable.
- Confirmation proves Main against the runtime library, which is proved once per release and bound by identity. The report audit applies the existing exact policy.
- The confirmation configuration drops `--level` and uses `--prover=cvc5,z3,altergo --timeout=0 --memlimit=0 --steps=0 --counterexamples=off -j<max(3, CPUs)>`. Never use a finite `--steps` above 5,368,146.
- Raise `RLIMIT_STACK` to the hard limit before spawning GNATprove, GPRbuild and the Image adapter.
- Classify each report from `unproved_status` together with the per-prover `check_tree` results. Outcomes are confirmed; inconclusive (a resource limit, crash or kill); or defect (only definite non-proof with resources remaining, or the policy rejected the report). A defect writes a bug-report bundle with the source, reports, tool identities and commands.
- Exit statuses: 0 built or confirmed; 1 forwarded by `run` only; 2 rejection or usage; 3 defect; 4 resource exhaustion. Add a top-level `Storage_Error` handler to `silver.adb` and `silver_image_adapter.adb`. Map child-tool signal deaths and `ENOMEM`, `ENOSPC`, `EMFILE` and `E2BIG` to status 4 or 3 as the scope specifies.
- Restate the policy and premise text: `development.md` (per-program proof checks "remain mandatory"), `language.md` (resource premise, mandatory library obligations, meaning and assurance), `AGENTS.md` (complete obligation discharge stays required and proved, while confirmation stops gating), `README.md` (CLI and statuses), `docs/assurance.md`, and `docs/trusted-boundary.md`. The solver row becomes "given sufficient resources"; the resource-outcome premise is new.
- Reinterpret `Current.ToolContract` and `automatic_pipeline` in Lean so build completion no longer depends on proof completion, with no new axioms.

**Completion criteria**

- Changed Silver-owned code has complete Bronze and Silver evidence. Focused tests cover building without proof, each confirmation outcome (recorded report fixtures are acceptable for the defect class), and every exit status. They include `ulimit -v`, `-s`, `-t` and `-f`, a full disk, and `E2BIG`.
- All supported samples build, run and confirm with the expected outcomes. The report policy and accepted diagnostics are unchanged.
- Lean focused builds of the changed modules pass with a fresh axiom audit allowing only `propext`, `Classical.choice` and `Quot.sound`.
- Specification, documentation, catalogue and README agree. No admitted or rejected program changes status.
