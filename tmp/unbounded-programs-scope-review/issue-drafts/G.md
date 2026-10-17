TITLE: Unbounded programs: String and argument lengths up to Integer'Last
LABELS: type: work package, area: language, area: runtime, area: assurance, area: compiler
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in a dated session-memory entry on `main`, before it moves to Ready. It depends on #{D} and #{E}, and may run alongside #{F}. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#removed-limits) governs it.

**Order 7.** Move the String value, per-call output and argument domain from 4096 bytes to the inherited Ada bound `Integer'Last`, which is 2,147,483,647 on the pinned target. This is an explicit pre-1.0 language change with an observable effect: arguments longer than 4096 bytes become valid input instead of being rejected.

- **Lengths.** Length literals cover 0 through `Integer'Last`. Admission length arithmetic (`Silver_Path_Facts`, `Silver_Length_Intervals`) becomes 64-bit.
- **Runtime library.** `Silver_IO` and `Silver_Arguments` contracts move to ghost sequences, with a re-derived runtime ledger and regenerated library sources. The Lean output, runtime and path-bound models are generalized. Re-derive #{C}'s source-position bound for the regenerated runtime units.
- **Static data probe.** Before fixing the domain, probe whether static String data near 2 GiB compiles and links. This needs a host with at least 20 GB of free disk.
- **OS argument limit.** Linux's 131,071-byte single-argument limit is environmental. `silver run` reports a spawn `E2BIG` as resource exhaustion (status 4), and the language rule names no OS limit. Record macOS's total-only `ARG_MAX` as an independent platform note.
- **Application resource outcomes.** Main's String objects use the caller's primary stack (8 MiB by default), so values far below `Integer'Last` can exhaust it, and GNAT then exits 1. Specify and test the application's resource outcome under `run`:
  - raise `RLIMIT_STACK` for the application as for the tools;
  - map a signal death or `Storage_Error` exit to 4 where it can be observed;
  - document that a directly invoked executable inherits the caller's limits.
- **Records.** Update the specification, catalogue, samples, manifest and tests, including the argument boundary tests.

**Completion criteria**

- The runtime library and changed compiler units have complete Bronze and Silver evidence, and the Lean models pass fresh axiom audits.
- Boundary tests cover the new value domain and the application's resource outcomes. The observable argument change is documented in `language.md` and the README.
- Confirmation runs on representative large-value programs are recorded as confirmations or inconclusive outcomes.
