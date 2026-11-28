# Original package-call lexical imports — 2026-11-27

Run `20261127T222702-375cccdce117` passed 46,622 audited declarations across 295
imported modules. All 1630 captured inputs match the checking worktree;
every existing primary input matches. The new CallLexicalImports module is the
sole absent input before integration.

The association scanner now consumes the source-interpreted Skip_At, Name_After
and Take_Token helpers on derived cursor domains, including failed/empty names.
The named-formal search preserves the original last-match fold for arbitrary
metadata, without introducing name uniqueness or a valid-metadata premise. The
previous callee interpretation remains valid under the combined lexical imports.
Payload, alias and final package-call composition remain required separate work.

One draft failed to rewrite through unreduced local lets; reducing those lets
fixed the proof without any domain, statement or budget change. The failed run
remains failed in the ledger. Linux x86_64, Lean 4.34.1, two workers/two threads,
8192 MiB per process, CPUs6–7 inside the host eight-CPU allocation. Incremental
focused build and fresh axiom audit, no replay or complete-feature assurance.
Selected proof role Astra Max; runtime settings are not independently exposed.
