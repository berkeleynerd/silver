TITLE: Unbounded programs: Remove source, operator and expression caps
LABELS: type: work package, area: language, area: compiler, area: assurance
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in a dated session-memory entry on `main`, before it moves to Ready. It depends on #{B}, #{C}, #{D} and #{E}. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#removed-limits) governs it.

**Order 6.** Admit larger programs by removing the capacity policies, leaving only the language rules from #{C}.

- Replace the 4096-byte total source cap with #{C}'s derived total-source rule.
- Remove the 63-operator source budget: delete `Work_Tail`/`Within_Work_Budget` and Lean `workTail`.
- Remove the 64-leaf expression limits (`Max_Expression_Operands`, `Max_Operands`), using `Natural` counts.
- Raise the exponent maximum from 4096 to the pinned 799,999 for scalar numerals and length literals. Evaluate in time proportional to the digits, with a zero-mantissa shortcut.
- Update `language.md`, the catalogue (`max_source_bytes`, `max_program_operators`, `max_expression_operands`, `max_operands`, `max_dynamic_references`, the exponent fields), samples, tests and the report-capacity record. The fixed envelope gives way to 64-bit or streaming report storage and the linear producer-structure premise.
- **Scaling ladder.** Run a geometric ladder from 4 KiB to 1 MiB for mixed code, straight-line code, dense String copies, deep nesting, long expressions and nonlinear product chains. Record the size reached, time, memory, maximum steps per goal, report bytes and stack. These are records, not thresholds.
- **Differential fuzzing.** Fuzz admission against the pinned frontend at large sizes.
- **Confirmation runs.** Run confirmation across the corpus and the ladder.

**Completion criteria**

- Native, Lean, specification and catalogue agree on the expanded membership, with complete Bronze and Silver evidence and fresh axiom audits.
- No incompleteness outcome (a definite non-proof with resources remaining) appears in the corpus or the ladder. If one appears, the defect is fixed. Failing that, stop and report it to the owner as a full stop, proposing the narrowest assurance-motivated rule (for example on non-static factors per product) as the only new limit. Adopt it only after the owner's decision is recorded in session memory.
- Every failure observed in the ladder is classified as resource exhaustion or as a filed defect.
