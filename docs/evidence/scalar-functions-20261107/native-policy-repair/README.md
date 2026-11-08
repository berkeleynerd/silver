# Exact native auditor correction and focused checks

Implementation `53d3a3b22b` changes only the evidence auditor, its tests and the
trusted-boundary explanation for findings #347/#348. Native Ada source, formal
domains, contracts, semantic proofs and source certificates are unchanged.
The [independent approval](../native-policy-independent-review/README.md)
assesses the exact argument, patch and retained results.

The two final ordinary Python invocations passed 97 and 40 tests: 137 unique
IDs including eight new tests. Existing test methods and shared fixtures are
AST-identical. The initial invocation had four synthetic subtest failures
because prior temporary reports obscured the intended origin-policy mutation;
the corrected isolated fixture clears its own reports without weakening an
assertion. That failed iteration remains distinct from the final passing logs.

The read-only corrected source/report diagnostic accepted the retained 094547
reports: 77 units, 1,605 flow checks, 16,920 proof checks and twelve separately
counted reassociation advisories. It neither completed provenance nor modified
the old snapshot/manifest. The original complete native run remains failed.

Nine compressed payloads retain exact logs, unique IDs, method/dependency delta,
patch and diagnostic. The coordinator verified every payload's decoded size/hash
and the exact committed diff. `index.json` records those identities. Selected
implementation model was GPT-6.1 Sol / Extra High; runtime confirmation and
elapsed/token/cost telemetry are unavailable. Native and Lean full refreshes
remain required.
