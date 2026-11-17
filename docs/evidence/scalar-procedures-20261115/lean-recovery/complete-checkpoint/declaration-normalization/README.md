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

## Focused result and continuation preflight

Run `20261115T194603-51d997e177d8` passed on the exact production bytes committed
as `ca1c9b2ce`. The original execution session `16284` returned exit 0 and the
source guard recorded no interruption. The new helper built in 984 ms; the
complete declaration candidate built in 271 s. Managed build time was 275.031 s
and the fresh imported-environment audit took 1.485 s. It covered **101 modules
and 14,411 declarations**, including all 47 original candidate statements,
with only `propext`, `Classical.choice` and `Quot.sound` as foundations.
This is focused partial validation, not a successful complete project checkpoint.

The selected allocation remained one Lake worker, automatic twelve Lean threads,
and 8,192 MiB per process. Sampled process peak was 7,504,784 KiB RSS;
process-tree peak was 8,541,248 KiB, and minimum host availability was
6,189,120 KiB. No source-tree, host-headroom or diagnostic guard fired.
The monitor elapsed 285.415 s. The unchanged full-domain caller and helper
contracts therefore passed within the existing threshold; this measurement
does not establish an asymptotic bound or predict other modules' resource use.

All 1,111 captured input, 1,006 workspace-input, 1,730 artifact and two tool hashes
were reverified after the terminal result. The exact managed log SHA-256 is
`9e2ed6cf35af0f5d22f0761056951ee3de301fc0ee0a637e0309feb5235b2588`.
All **287** prior ordinary module objects and their 1,718 captured variant/hash
files remain byte-identical. The new helper and complete candidate add two
ordinary module objects. The retained success packet contains the original
runner evidence, managed and outer logs, resource samples and terminal summary;
`focused-success-verification.json` records these checks.

`complete-continuation-preflight.json` confirms that the explicit textual
`Silver.Audit` import closure still reaches all **1,004** project modules,
including the new helper, with no missing project import or unreachable module.
There are 289 cached ordinary module objects and 715 modules without an object.
Object presence and textual reachability are preflight facts only. The next
complete cached build must still freshly establish actual whole-project module
coverage, axiom closure, stable inputs and source correspondence. No independent
kernel replay or clean build was requested or performed. Independent critical
review of this patch and focused result precedes that complete continuation.

| Work | Model / effort | Result and remaining work | Available cost evidence |
| --- | --- | --- | --- |
| Exact two-fact normalization and focused candidate | Selected Astra Max for source correspondence; live lead setting not independently exposed | Unchanged 47 candidate statements, both helper contracts and complete caller passed; whole-project checkpoint pending | 285.415 s monitored native elapsed; token and whole-team cost unavailable |
