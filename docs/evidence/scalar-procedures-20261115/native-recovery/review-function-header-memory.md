# Independent review: two function-header memory repairs

**Disposition: accept `e70ad1ffd` with no material finding.** The three production
files are byte-identical in integration commit `1684b88fa`. This is a bounded
proof-memory review; caller integration, authoritative-source correspondence
and the complete assurance checkpoint remain required.

The reviewer did not author the changes. The parent selected GPT-6 Astra / Max
for this critical review; independent live model/effort telemetry is unavailable.
Review date: 2026-11-15. Total review elapsed time, tokens and cost were not
measured. Reported prover time below is separate from review/whole-team cost.

| Round | Intended result | Result and rework | Evidence scope |
| --- | --- | --- | --- |
| Independent critical review, selected Astra / Max | Check unchanged statements, exact header normalization, full-source uniqueness, checked witnesses and evidence | Accepted; no production rework requested; control reuse explicitly bounded | Read-only inspection and independent Python comparisons; no additional proof run |

## Exact scope and findings

Relative to frozen baseline `8a03ab122`, only these production files change:
`DeclarationHeaderFunctionLocalsModelSpec.lean`,
`DeclarationHeaderFunctionBodyAtSpec.lean`, and the new
`FunctionDeclarationHeaderExpectedTokens.lean`, all under
`proof/Silver/FunctionSourceParts/`. Their exact hashes, independently checked
inputs/artifacts and extraction results are in the
[supporting JSON](review-function-header-memory.json).

Both exported theorem statements are byte-identical to the baseline, including
their header indices, specification terminator and complete
`Output.SourceShape.outputImplementation` argument. No source slice, input-domain
restriction, new scanner, contract omission or additional assumption appears.
The source/header catalogue, scanner, reviewed token list and existing consumers
are unchanged. Native source, Python scripts and native project inputs are also
unchanged, so this repair does not invalidate the separately running native audit.

| Header | Catalogue index | Exact ASCII characters / UTF-8 bytes | Ordered tokens |
| --- | --- | --- | --- |
| `function_locals_model` specification | 10 | 834 | 156 |
| `function_body_at` specification | 21 | 839 | 167 |

For each header, four literal occurrences were compared, and both complete
character lists equal the original text. The helper and leaf token lists agree
with each other and an independent lexical extraction, including all attribute
apostrophes, parameters, contracts, Static ghost aspects and variant text.
Independent extraction scans the complete **72,713-token** reviewed source:
each name has exactly one specification header with the expected ordered
tokens, plus its distinct implementation header.

The helper uses the same standard `String.toList_ofList` theorem and existing
`kernel_exact` mechanism examined in the
[function-local review](review-function-source-memory.md). Kernel conversion
checks the original string against the complete supplied character list.
Unfolding the unchanged `expectedTokens`, `lexLine` and `compilerSource`, then
rewriting that equality, preserves alphabet validation, lexical fuel and the
complete lexer result checked by `decide +kernel`. Each leaf rewrites its proved
token equality and supplies a closed reflexivity witness checked at the exact
original goal type. No project axiom, unfinished proof or kernel bypass is added.

The unchanged `functionHeaders` examines every suffix, collects matching headers
with the requested top-level terminator, and `functionHeader` succeeds only on
a singleton. The original candidate assembler and authoritative-source transport
remain required consumers. This review does not infer their integrated success
from the two leaf results.

## Focused evidence and control applicability

Run [20261115T175133-2b096066a6f7](../lean-recovery/header-capacity/focused-success-evidence.json.gz)
builds both original header targets and their new helper, then freshly audits
**108 modules / 15,611 declarations** on Linux aarch64 with Lean 4.34.1.
Foundations are exactly `propext`, `Classical.choice` and `Quot.sound`.
The reviewer verified the exact runner-log hash, all 1,107 current run-input
hashes at comparison time, production input/workspace hashes, and 18 current
artifact entries for the three changed modules. No retired probe, segmented
candidate or temporary control occurs in the recorded module/input/workspace/
artifact inventories. Integration production bytes match the reviewed commit.

The run uses one Lake worker, automatic 12 Lean threads and the same 8,192 MiB
periodic per-process threshold as the failed baseline. Build takes 130.998 s;
fresh audit 0.957 s; monitored invocation 140.088 s, exit 0. Sampled largest
process RSS is 4,217,760 KiB and summed RSS 5,269,488 KiB; minimum sampled host
available memory is 11,059,808 KiB. These samples are not hard peak bounds.
The baseline's two kernel-memory failures remain failures. The success reuses
dependency objects; it is neither a clean build nor independent kernel replay.

The coordinator selected reuse of the already reviewed wrong-character and
omitted-token controls from run `20261115T173611-b27c8626e3d1`. They rejected
an incorrect complete character candidate through kernel type checking and a
missing expected token as a false proposition. This review independently checked
that `CertificateWitness`, `SourceDeclarations`, `SourceLexer`, and the Lean/Lake
tool hashes match the retained controls' environment. These controls apply to
the unchanged checked-witness and lexical normalization implementation; they
are **not new executions against either header**. Independent exact comparisons
and the freshly audited complete-source header statements cover the new texts.

The earlier ordinary-body duplicate fixtures are **not header-extractor tests**
and are not claimed as such. Header uniqueness here is established by the
unchanged complete-source theorem statements and their successful proofs,
corroborated by direct inspection of the unchanged extractor and independent
extraction of this complete reviewed source. No sample-based universal-uniqueness
claim is made.

The reviewer changed only this report and its supporting JSON. No production
file/cache or proof setting was changed, and no additional Lean/native run was
started for this review. The separate native full run
`20261115T174959-94ae5c6fdf63` is still ongoing and supplies no success claim here.
No GitHub write or CLI-memory update was made. Further inherited leaves may need
their own bounded repairs before the complete source and language gates pass.
