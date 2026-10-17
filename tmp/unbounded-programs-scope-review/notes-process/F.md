TITLE: Unbounded programs: Remove source, operator and expression caps
LABELS: type: work package, area: language, area: compiler, area: assurance
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in session memory. It depends on #{C}, #{D} and #{E}. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#removed-limits) governs it.

**Order 6.** Admit larger programs by removing the capacity policies, leaving only the pinned-frontend rules from #{C}.

- Remove the 4096-byte total source cap.
- Remove the 63-operator source budget: delete `Work_Tail`/`Within_Work_Budget` and Lean `workTail`.
- Remove the 64-leaf expression limit, using `Natural` counts.
- Raise the exponent maximum from 4096 to the pinned 799,999, evaluating in time proportional to the digits (zero-mantissa shortcut).
- Update `language.md`, the catalogue (`max_source_bytes`, `max_program_operators`, `max_expression_operands`, the exponent fields), samples, tests and the report-capacity record. The fixed envelope gives way to growable storage and the linear producer-structure premise.
- **Scaling ladder.** Run a geometric ladder from 4 KiB to 1 MiB for mixed code, straight-line code, dense String copies, deep nesting, long expressions and nonlinear product chains. Record the size reached, time, memory, maximum steps per goal, report bytes and stack as records, not thresholds.
- **Differential fuzzing.** Fuzz admission against the pinned frontend at large sizes.
- **Confirmation runs.** Run confirmation across the corpus and the ladder.

**Completion criteria**

- Native, Lean, specification and catalogue agree on the expanded membership, with complete Bronze and Silver evidence and fresh axiom audits.
- No incompleteness outcome (definite non-proof with resources remaining) appears in the corpus or the ladder. If one appears, the defect is fixed. Failing that, the narrowest assurance-motivated rule (for example on non-static factors per product) is the only acceptable new limit, with its purpose documented.
- Every failure observed in the ladder is classified as resource exhaustion or as a filed defect.
