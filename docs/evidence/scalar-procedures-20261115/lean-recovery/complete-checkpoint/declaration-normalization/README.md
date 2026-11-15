# Declaration source normalization — 2026-11-15

## Actual complete-checkpoint failure

Complete run `20261115T190543-9bda6434802c` used frozen production `46c849d81`
(equivalent proof/src/scripts bytes to published integration `8ccbc8421`). It
built the source-certificate and `Source` facades plus expression/catalogue source
candidates, preserving their new objects. `ComposeDeclarationSourceCandidate`
then reported explicit 8 GiB kernel-memory failures in exactly two private facts:

| Fact | Original complete source extractor | Exact expected characters / tokens |
| --- | --- | ---: |
| `declaration_fact_11` | `Lexical.SourceBridge.recordDeclaration "parser_state"` | 650 / 79 |
| `declaration_fact_22` | `Source.expressionBody "valid_state"` | 922 / 160 |

The failed module elapsed 327 s. Its two diagnostics were followed by the
monitor's source-process-group SIGINT, which interrupted the newly started
`ComposeContractSourceCandidate`. The whole build was interrupted at 2,027.557 s;
the monitor elapsed 2,037.495 s. No complete module/axiom audit occurred.
Sampled process peak was 8,390,944 KiB RSS, process-tree peak 9,395,360 KiB and
minimum host availability 3,942,336 KiB. The diagnostic guard triggered; neither
the 10 GiB tree nor 1.5 GiB host-headroom guard caused the stop. This is a real
module memory failure followed by intentional interruption, not an unexplained
interruption or successful complete run.

All 1,110 captured input files and both Lean/Lake tool hashes still matched the
preceding focused input inventory before any repair. The exact managed full
log has SHA-256
`e81f4be701031aafbfba7c9f3d5be23efb7333575ce1f1504223a6ea50c11707`.
The original module, managed/outer logs, resources, terminal summary and managed
registry events are retained. All **287** completed module objects and their
variant/hash identities were captured before repair and remain preserved.

## Bounded repair and focused gate

The parent authorized exactly two private proof-body changes in
`ComposeDeclarationSourceCandidate` and one isolated
`ComposeDeclarationExpectedTokens` helper. Each helper normalizes its exact
literal with the established checked `String.toList_ofList` identity, then
kernel-checks the unchanged alphabet/fuel/lexer computation. Each original leaf
rewrites only that proved token equality and kernel-checks its original complete-
source extractor result. Every original theorem statement, selector, token,
record field, predicate clause, duplicate check, contract and domain is retained.
No public conjunction or source pin changes. Native source/scripts remain fixed.

The prospective `_17`, `_18` and `_21` inventory facts are unchanged. Their
original proof bodies produced no diagnostic in the failed module; this is not
claimed as an independently audited success. There is no speculative wider
normalization or inferred memory threshold. Existing mechanism corruption
controls apply only to the unchanged character-normalization/lexer path, not as
new tests of record/expression extractors. Complete-source uniqueness/equality
remains a kernel obligation and part of independent exact-data review.

Before another complete attempt, run the full focused
`Silver.ComposeDeclarationSourceCandidate` target, which covers both new helper
contracts and every declaration fact. Use one Lake worker, automatic 12 Lean
threads and the unchanged 8,192 MiB threshold, with the existing source-tree,
host-headroom and first-memory-diagnostic guards. Independent review of the
concrete committed patch and focused evidence is required before a full retry.
The native run and all completed caches remain untouched.
