TITLE: Unbounded programs: Compiler storage and complexity that scale with input
LABELS: type: work package, area: compiler, area: assurance
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in session memory. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#removed-limits) governs it; it un-defers the recognizer stack redesign (review O1).

**Order 4.** Make every Silver-owned structure scale with its input, so the compiler can fail only through resource exhaustion. Admitted programs do not change.

- **Separate the roles merged in 4096.** Source length, String value domain (also the length-literal domain), argument length, per-call output length, identifier length and exponent each get their own named constant. Each has one source of truth tied mechanically to its Lean counterpart.
- **Growable storage.** Source reads and GNATprove reports use growable heap storage up to `Natural'Last - 1`. Ghost sequences replace fixed ghost arrays, and report-sized stack copies go. Replace the 4,096-character name bound in both report policies (`src/silver_library_reports.adb:1213`, `:2088`) and `scripts/check_evidence.py` with the identifier rule.
- **Recognizer.** Environments are sized at run time. Loop scopes push and pop in place, giving constant stack per nesting level. Declarations are handled by procedures. Conditions use a bracket-matching table. Names are interned. `Accepts` and `Uses_*` share a single scan, `Normalized` copies go, and quantified preconditions become static-level.
- **Image adapter.** Widen `Original_Node_Id` to the 63-bit byte-count range.

**Completion criteria**

- Admission is identical on the regression corpus and under differential fuzzing.
- Measured stack per nesting level is constant, and admission time is near-linear on generated maximal shapes.
- Changed units have complete Bronze and Silver evidence. Their source pins and Lean certificates are re-established, coordinated with #{E} so only one proof-workspace writer runs at a time.
- Report audits accept reports larger than 16 MiB without changing policy.
