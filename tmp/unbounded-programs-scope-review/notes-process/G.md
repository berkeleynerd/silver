TITLE: Unbounded programs: String and argument lengths up to Integer'Last
LABELS: type: work package, area: language, area: runtime, area: assurance, area: compiler
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in session memory. It depends on #{F}. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#removed-limits) governs it.

**Order 7.** Move the String value, per-call output and argument domain from 4096 bytes to Ada's inherited bound, `Integer'Last` (2,147,483,647). This is an explicit pre-1.0 language change with an observable effect: arguments longer than 4096 bytes become valid input instead of being rejected.

- Length literals cover 0 through `Integer'Last`. Admission length arithmetic (`Silver_Path_Facts`, `Silver_Length_Intervals`) becomes 64-bit.
- `Silver_IO` and `Silver_Arguments` contracts move to ghost sequences, with a re-derived runtime ledger and regenerated library sources. The Lean output, runtime and path-bound models are generalized.
- Before fixing the domain, probe whether static String data near 2 GiB compiles and links. A host with at least 20 GB free disk is needed.
- Linux's 131,071-byte single-argument limit is environmental. `silver run` reports a spawn `E2BIG` as an infrastructure outcome; the language rule names no OS limit. Record macOS's total-only `ARG_MAX` as an independent platform note.
- Update the specification, catalogue, samples, manifest and tests, including the argument boundary tests.

**Completion criteria**

- The runtime library and changed compiler units have complete Bronze and Silver evidence, and the Lean models pass fresh axiom audits.
- Boundary tests cover the new value domain, and the observable argument change is documented in `language.md` and the README.
- Confirmation runs on representative large-value programs are recorded as resource outcomes or confirmations.
