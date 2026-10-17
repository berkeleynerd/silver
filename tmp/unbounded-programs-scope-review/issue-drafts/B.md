TITLE: Unbounded programs: Proof confirmation and resource outcomes
LABELS: type: work package, area: compiler, area: assurance, area: language, area: tooling, area: docs
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in a dated session-memory entry on `main`, before it moves to Ready. It depends on #{A}. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#design) governs it; the [roadmap](https://github.com/berkeleynerd/silver/blob/main/roadmap.md#unbounded-programs) records the order.

**Order 2.** Separate building from proving. Compilation becomes verified admission plus build. Per-program GNATprove becomes a non-gating confirmation: a definite non-proof or rejected report is a defect report, and a resource-limited confirmation is inconclusive. No source changes admission status.

**Commands**
- `silver compile` admits, builds, prints the executable path and then confirms unless `--no-confirm` is given.
- `silver run` admits, builds and executes without confirming.
- `silver confirm WORKSPACE` confirms the exact `main.adb` and library snapshots of a printed build workspace. It rechecks their identity before and after GNATprove.
- Confirmation has no time limit. An interrupt ends GNATprove and reports "not confirmed" without changing the build status or the executable.
- A confirmation never removes or blocks the executable. Replace the `Publish` ghost contract: publication follows admission, build and identity checks, and a "confirmed" report follows only an audited report.

**What confirmation proves.** Confirmation keeps today's `-U` project. It proves Main and the six identity-bound runtime library files, and audits the Main report and all four library-unit reports under the existing exact policy. Only its result stops gating the build.

**Prover configuration**
- Keep `-U --mode=all --report=all --checks-as-errors=on --no-loop-unrolling` and the mode's `--warnings`, and drop `--level`.
- Use `--prover=cvc5,z3,altergo --timeout=0 --memlimit=0 --steps=0 --counterexamples=off -j<max(3, CPUs)>`. Never use a finite `--steps` above 5,368,146.
- Confirm on real programs that `--memlimit=0` without `--level` removes every prover memory limit.
- The driver re-executes itself once with `RLIMIT_STACK` raised to the hard limit, and GNATprove, GPRbuild and the Image adapter inherit it.
- On Linux, set `oom_score_adj` to 1000 for confirmation children.
- After a not-confirmed outcome, print the paths and sizes of retained `program-*` and `imagews-*` workspaces.

**Outcome classification.** Read `unproved_status` together with the per-prover `check_tree` results.
- *Confirmed*: some prover proved every check and the audit accepted all five reports.
- *Inconclusive* (status 4 from `confirm`): every unproved check ended only through attributable resource exhaustion (an `OutOfMemory`, `Timeout` or `StepLimitExceeded` answer, or a prover the driver observed killed by `SIGKILL` or `SIGXCPU`), a recorded confirmation-only tool limit, or interruption.
- *Defect* (status 3 from `confirm`): some check had no proving attempt, with at least one `Unknown`, `Invalid` or crash not attributable to resources; or the audit rejected a report. A defect writes a bug-report bundle with the source, reports, tool identities and commands. A defect takes precedence over an inconclusive result.

**Exit statuses**
- 0: `check`/`catalogue` admitted or exported; `compile`/`run` built; `confirm` confirmed.
- 1: forwarded by `run` only.
- 2: rejection or usage.
- 3: defect.
- 4: resource exhaustion or an inconclusive confirmation.

Implement the observations explicitly:
- Decode `system()` wait statuses, documenting how `/bin/sh` and `alr exec` propagate a child's signal.
- Read `errno` after Silver's own failed I/O (`ENOSPC`, `EFBIG`, `ENOMEM`, `EMFILE`).
- Replace or supplement GNAT `Spawn` for `run`, so a spawn `E2BIG` is status 4. Today `Spawn` reports a failed `execve` as 1 and a signal death as −1.
- Add top-level `Storage_Error` handlers to `silver.adb` and `silver_image_adapter.adb`.
- Either run under a supervising parent that maps the driver's own `SIGKILL`, `SIGXCPU` and `SIGXFSZ` deaths to 4, or document those deaths as uncaught environmental terminations.
- Classify an ambiguous tool failure as 3 unless a rule marks it as resource exhaustion.
- List every new libc import in `docs/trusted-boundary.md`.
- A source read or size failure never maps to status 2; growable reads are #{D}.

**Records**
- `development.md`: per-program proof checks "remain mandatory".
- `language.md`: the resource premise, the mandatory library obligations, and meaning and assurance.
- `AGENTS.md`: complete obligation discharge stays required and proved, while confirmation no longer gates the build.
- `README.md`: CLI and statuses.
- `docs/assurance.md`: including the quoted proof command.
- `docs/trusted-boundary.md`:
  - the solver row becomes "given sufficient resources";
  - a new resource-outcome premise;
  - the per-program producer and Image premises are now checked by confirmation rather than by the build;
  - the quoted proof command.

**Lean.** Add a build-only pipeline (parse, fixed-library evidence, build) whose preservation and realization theorems do not use proof completion. Keep `automatic_pipeline` and `admitted_assurance` proving that every member's generated checks are discharged under `boundedProofCompletes`. Add no new axioms.

**Completion criteria**

- Changed Silver-owned code has complete Bronze and Silver evidence.
- Focused tests cover:
  - building without proof;
  - confirming a printed workspace with identity checks;
  - each confirmation outcome (recorded report fixtures are acceptable for the defect class);
  - every exit status that the implemented mechanisms can observe, under `ulimit -v`, `-s`, `-t` and `-f`, a full disk, and `E2BIG`.
- Update `tests/test_samples.py`'s pinned proof options and why3session limits. All supported samples build, run and confirm with the expected outcomes. The report policy and accepted diagnostics are unchanged.
- Lean focused builds of the changed modules pass with a fresh axiom audit allowing only `propext`, `Classical.choice` and `Quot.sound`.
- The specification, documentation, catalogue and README agree.
