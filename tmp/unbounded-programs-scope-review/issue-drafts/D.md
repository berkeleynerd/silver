TITLE: Unbounded programs: Compiler storage and complexity that scale with input
LABELS: type: work package, area: compiler, area: assurance
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in a dated session-memory entry on `main`, before it moves to Ready. It depends on #{B}. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#removed-limits) governs it. Once authorized, it takes up the deferred recognizer stack redesign (review O1).

**Order 3.** Make every Silver-owned structure scale with its input, so the compiler can fail only through resource exhaustion. Admission is unchanged.

- **Separate the roles merged in 4096.** Source length, String value domain (also the length-literal domain), argument length, per-call output length, identifier length and exponent each get one named native constant. #{E} ties each to its Lean counterpart, and #{C} uses them.
- **Files.** Source reads, the `main.adb` snapshot write and its re-reads use growable heap storage with ghost sequences in place of the fixed 16 MiB `Silver_Platform.Max_File_Length` and its ghost arrays. No read or size failure maps to status 2.
- **Reports.** The report audit becomes 64-bit-indexed or streaming, so retained reports are bounded only by host resources. Remove report-sized stack copies.
- **Report writer.** Verify from producer source whether GNATprove can write reports beyond about 2 GiB. If not, record the writer as a confirmation-only tool limit.
- **Name bound.** Replace the 4,096-character name bound in both report policies (`src/silver_library_reports.adb:1213`, `:2088`) and `scripts/check_evidence.py` with the identifier constant.
- **Recognizer.**
  - Size environments at run time, and push and pop loop scopes in place, giving constant stack per nesting level.
  - Handle declarations with procedures, classify conditions with a bracket-matching table, and intern names.
  - Share one scan between `Accepts` and `Uses_*`, drop the `Normalized` copies, and make quantified preconditions static-level.
  - Use explicit heap work stacks if raising the stack limit proves insufficient.
- **Image adapter.** Widen `Original_Node_Id` to the 63-bit byte-count range.

**Completion criteria**

- Admission is identical on the regression corpus and under differential fuzzing.
- Measured stack per nesting level is constant, and admission time is near-linear on generated maximal shapes.
- Report audits accept reports larger than 16 MiB, and beyond 2 GiB where the producer can write them, without changing policy.
- Changed units have complete Bronze and Silver evidence. Their source pins and Lean certificates are re-established with #{E}, with one proof-workspace writer at a time.
