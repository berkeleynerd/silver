# PR #406: response to the external Claude review

On 2026-11-21 the owner instructed **“I agee. Fix them, then merge.”**
This authorizes repairing the three material findings and merging PR #406 after
validation and independent review. The original [Claude report](review-pr406-claude-20261120.md)
remains unchanged; its suggestion to defer the medium finding was superseded by
the owner's instruction. Work proceeds directly through Codex, without Worca.

## Findings and dispositions

| Finding | Disposition |
| --- | --- |
| C406-M1 / [#407](https://github.com/berkeleynerd/silver/issues/407) | Fixed in `c2b60470ae`. Whole-unit recurrence scopes use the unit stem, so `.ads` and `.adb` share failure counts and successful resets. Subprogram selection, proof options and report auditing are unchanged. Two new CLI tests exercise six subcases covering exact locations, moved helper locations, both reset directions and distinct units. |
| C406-L1 / [#408](https://github.com/berkeleynerd/silver/issues/408) | The evidence READMEs enumerate the 16 auditor-dependent retained modules and distinguish the implementation review's equivalence judgment from Claude's later comparisons and 14 fresh tests. The remaining 97 were not rerun by Claude. |
| C406-L2 / [#409](https://github.com/berkeleynerd/silver/issues/409) | The stale roadmap sentence now describes the delivery in PR #406. |
| C406-I1 | Optional test extension deferred until the focused report checker changes. Preserve Claude's fail-closed probes; no report-checker behavior changes in this repair. |
| C406-I2 | Optional diagnostic hint deferred until that error path changes. The existing interface explicitly requires a declaration line; no broader selector support is claimed. |
| C406-I3 | Accepted limitation: selecting an outer subprogram does not certify its nested helpers. Existing complete-contract policy requires separately covering each changed helper, including nested ones; select their containing unit or their own declarations as applicable. No inferred coverage graph is added. |
| C406-I4 | Retain the documented conservative holds. Clearing failures by inferred helper-name coverage is outside this bounded repair. |
| C406-I5 | Retain the documented distinction between focused checks and complete assurance. Complete audits still classify advisories and assumption dependencies. |
| C406-I6 | Preserve both external-review test records with their actual outcomes: the unbootstrapped-worktree run failed; the narrowed run passed 195 tests. Neither is a proof result. |

The [external-review archive](../evidence/proof-iteration-efficiency-373-20261120/external-review/README.md)
retains the original report, selected settings, probe evidence and managed records.
The historical review and delivery retain their own inputs and outcomes.

## Repair validation

The new tests failed against the old implementation in managed run
`20261121T024037-07bacaed43db`. The two repaired tests passed in
`20261121T024049-e15f45e8ad9f`, and all 42 runner tests passed in
`20261121T024106-8380ee364bdf`. The final inventory is 759 unittest identities:
42 fresh runner passes, 242 applicable passes from the previous tooling run and
475 independently reviewed passes from the earlier complete suite. These sets
are disjoint; the 14 overlapping Claude passes are additional evidence, not
extra identities. No required test is omitted or counted twice.

The changed executable path is only `FocusedProof.scope` for whole-unit runs.
The independent repair review checks the retained tests' dependencies as well
as their unchanged source bytes. Complete native and Lean audit refreshes on
the repaired script inputs are retained separately; cache reuse is explicit.
No Ada, Lean, catalogue, sample, proof option or language rule changed.

The [repair packet](../evidence/proof-iteration-efficiency-373-20261120/repair-20261121/README.md)
retains final current-input Linux x86-64 validation on `c2b60470ae`:

| Check | Managed run | Result |
| --- | --- | --- |
| Complete native audit | `20261121T024227-a19b938a6d86` | 78 units, 1,252 entities, 19,726 proved checks; fresh reports/provenance with existing sessions and solver cache |
| Complete Lean check | `20261121T024324-385324656492` | Cached build and fresh audit of 1,035 modules / 166,332 declarations; only the three approved foundations |
| Native build | `20261121T024405-83ca2639949a` | Both binaries up to date; invocation passed |

These commands used automatic 22-worker allocation; Lean used 22 process threads.
The invoking stack was 16 MiB. Wrapper durations were 47.442, 26.196 and 2.896
seconds respectively. No cold run, independent kernel replay, controlled speedup,
macOS or CI claim is made. Original focused proof smoke results remain applicable:
the change affects their ledger label, not selected proof commands or coverage.
Older ledger records remain unmodified; the only earlier unit-scope run on this
host was successful, with no failing unit history needing migration.

[Independent repair review](review-pr406-repairs-20261121.md) accepted evidence
and documentation candidate `5dc7d8efd0`, with implementation `c2b60470ae`.
It found no remaining material repair or validation requirement. The closing
commit adds that report and this acceptance record only; proof inputs remain
unchanged. PR #406 can merge under the owner's instruction, closing the three
findings and the selected reduced package. #381/#382 remain deferred/open,
and PR #385 remains held.
