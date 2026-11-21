# Independent repair and evidence review for PR #406

Reviewed candidate `5dc7d8efd0a2681159221abe87132d9605f2a133` against the external review target `8dc409b303ac8bd9a836ed169467064441a76d8d`. Implementation and regression tests are at `c2b60470aec145d28206cbd27f79ff7f63cb9378`.

## Findings and regression coverage

C406-M1 is resolved. Both whole-unit spellings produce the same ledger scope. Different unit stems stay distinct and subprogram selection retains the exact declaration file and line. The code changes only the scope assigned to whole-unit runs. It preserves the commands and report checks exercised by the earlier real compiler smoke tests. The only pre-repair whole-unit run in this host's ledger was a successful smoke run. Its original recorded scope remains historical.

The new normal-entry tests reproduce the defect on the old implementation. Six subcases cover failures at one exact location without helper metadata, moved locations with a shared producer-named helper, isolation from another unit, and a successful reset under either spelling. I inspected the failed baseline record and both successful repair records. All 42 runner tests passed in `20261121T024106-8380ee364bdf`. [Repair evidence](../evidence/proof-iteration-efficiency-373-20261120/repair-20261121/README.md)

I independently matched unittest discovery to the three raw logs. Each of the 759 unique final IDs has an explicit successful result. The 42 fresh runner IDs include the 40 existing runner tests and two additions. Another 242 IDs come from the prior 282-test tooling run and 475 come from the prior complete 724-test run. The sets are disjoint. Only the runner test module exercises the changed whole-unit scope path. The platform and proof-provenance tests which call the managed entry point use other modes. The application auditor, fixtures, compiler, generated sources, tool identities and proof options keep their established behavior across the repair. Both final binary hashes match the prior accepted checkpoint.

C406-L1 is resolved. I checked the original auditor extraction and its callers, the saved differential results, and the raw logs. The external comparison records 247 matching outcomes in 248 comparisons. The one changed exception type came from an invalid trusted-unit argument outside the production and retained-test call paths. All six real application report sets preserve their recorded statistics. I recomputed the 16 modules and 111 retained IDs using the shared auditor. Exactly 14 of those IDs passed in the external 195-test run. The other 97 retain their original evidence. C406-L2 is resolved in the roadmap. The response gives a disposition for each of the six informational notes. The saved Claude report matches its original bytes, and all 30 source-to-archive entries match their recorded digests. [Response](review-8dc409b303-response.md) · [External-review archive](../evidence/proof-iteration-efficiency-373-20261120/external-review/README.md)

## Current-input assurance

I checked the Linux x86-64 managed events, wrapper results, prepared inputs, native producer reports, Lean audit log and proof evidence. The build and native proof captured identical inventories of 2,585 inputs and 12 tools. All 148 tracked native inputs and all 1,143 Lean source inputs match the candidate bytes. Compared with the prior complete audits, only `scripts/focused_proof.py` changed in either input inventory.

- Native proof `20261121T024227-a19b938a6d86` forced the complete audit with existing sessions and solver cache. I verified all 80 report hashes, the effective command against SARIF, all 78 expected compiler units, and 1,252 coverage entries. The 1,751 flow and 17,975 proof checks agree with the managed audit. Wrapper elapsed time was 47.442 seconds.
- Lean run `20261121T024324-385324656492` reused the cached build. Its fresh audit enumerates the same 1,035 unique modules as the evidence and covers 166,332 declarations using `propext`, `Classical.choice` and `Quot.sound`. The 1,037 workspace and 6,202 artifact hash inventories equal their prior complete counterparts. Wrapper elapsed time was 26.196 seconds.
- Build `20261121T024405-83ca2639949a` reports both executables up to date. Wrapper elapsed time was 2.896 seconds. All three commands used 22 automatically allocated workers and a 16 MiB invoking stack. Lean used 22 threads per process.

I verified the final repair archive manifest covering 31 entries, all 82 native producer archive members against the live retained records, and both changed source archive members against the implementation commit. The complete map resolves to the stated bytes for all 1,347 source/setup entries and 1,037 workspace entries. Each archived regression ID has the expected run assignment. The sole whitespace diagnostic in the candidate diff is a trailing space copied verbatim in Claude’s original probe output. All other changed files pass the whitespace check.

## Review scope and settings

This was a read-only review of source, test discovery and recorded runs. It included byte checks of the tracked inputs, raw native reports, executables and retained evidence. For native tool inputs and identities and for compiled Lean artifacts, I compared current and prior recorded inventories. Execution evidence comes from the managed runs. Independent kernel replay, cold proof runs, macOS and hosted CI were outside the review scope.

Selected reviewer model `gpt-6.2-astra`, effort Extra High. Serving-model confirmation, actual effort, token use and cost telemetry were unavailable to this reviewer. Observed interval on 2026-11-21 from 02:40:48 UTC to 02:50:22 UTC (9 min 34 s), including waiting for validation and archive assembly.

I accept the repair and its evidence for merge. All three material findings are resolved. No outstanding validation or repair remains within this review.
