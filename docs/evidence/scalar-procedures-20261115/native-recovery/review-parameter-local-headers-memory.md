# Independent review: parameter/local declaration-header normalization

**Disposition: accept `c38f0eedc` with no material finding.** This bounded repair
preserves the six original complete-source statements. The caller, downstream
authoritative-source proofs and complete assurance gates remain required.

The reviewer did not author these changes. The parent selected GPT-6 Astra /
Max for this critical review; independent live model/effort telemetry is
unavailable. Review date: 2026-11-15. Total review elapsed time, tokens and cost
were not measured. The native/Lean run times below do not measure review or
whole-team cost.

| Round | Intended result | Result and rework | Evidence scope |
| --- | --- | --- | --- |
| Independent critical review, selected Astra / Max | Check six unchanged statements, exact normalization, full-source uniqueness and fresh focused evidence | Accepted; no production rework requested | Read-only inspection and independent extraction/hash comparisons; no additional proof run |

## Scope and exactness

The production delta consists exactly of six
`proof/Silver/FunctionSourceParts/DeclarationHeader*Spec.lean` proof bodies and
the new `FunctionParameterLocalHeaderTokens.lean` helper. The two previously
accepted normalization helpers remain byte-identical. Native source, scripts
and project inputs remain those of `8a03ab122`. The
[supporting JSON](review-parameter-local-headers-memory.json) identifies every
file/hash, original statement and independently extracted result.

| Header | Catalogue index | Exact ASCII characters / UTF-8 bytes | Tokens |
| --- | --- | --- | --- |
| `parameter_step` | 2 | 695 | 147 |
| `parameters_model` | 4 | 742 | 153 |
| `parameters_at` | 6 | 722 | 150 |
| `function_local_at` | 8 | 713 | 134 |
| `function_locals` | 12 | 794 | 153 |
| `parameter_frame` | 17 | 697 | 142 |

All six public theorem statements are byte-identical to the baseline, including
the original catalogue indices, `;` terminator and entire
`Output.SourceShape.outputImplementation` argument. Four text occurrences per
header agree exactly, as do both complete character lists. Each helper token
list equals its leaf witness and an independent lexical extraction, including
attribute apostrophes and every parameter, contract, aspect and variant token.
Scanning the complete **72,713-token** reviewed source independently finds one
matching specification header for each name, plus its distinct implementation.

The unchanged catalogue, reviewed source, scanner, trust helper and consumers
were compared with the baseline. `functionHeaders` still scans all suffixes and
collects matching top-level specification headers; `functionHeader` still
accepts only a singleton. No shortened input, contract removal, restricted
domain, source pin change or weakened uniqueness check appears.

Each helper follows the already reviewed `String.toList_ofList` normalization:
the exact original string must convert to the supplied complete character list
in the kernel. The unchanged alphabet check, lexical fuel and complete lexer
result remain under `decide +kernel`. Each leaf rewrites the proved token
equality, then passes a closed reflexivity witness through the existing checked
`kernel_exact` path at its original goal type. The Oracle's complete-domain,
source-correspondence and no-unproved-project-axiom requirements are preserved.

## Focused evidence and controls

Run [20261115T180831-555601b89ece](../lean-recovery/parameter-local-headers/focused-success-evidence.json.gz)
builds all six changed targets and the entire new helper, then freshly audits
**112 modules / 15,639 declarations** on Linux aarch64 with Lean 4.34.1.
Only `propext`, `Classical.choice` and `Quot.sound` occur. The exact retained
runner-log digest matches the evidence. At comparison time, all 1,108 run inputs
and all 42 selected artifact entries for the seven changed modules match; the
production source and workspace hashes also match the committed files. The
module/input/workspace/artifact inventories contain no retired probe, segmented
candidate or temporary control.

The focused build takes 318.152 s, its fresh audit 2.301 s, and the managed run
326.604 s. One Lake worker, automatic 12 Lean threads and the original 8,192 MiB
periodic per-process threshold are retained. Sampled process RSS peaks at
3,861,312 KiB, summed RSS at 4,909,936 KiB, and host availability remains above
10,257,968 KiB. Exit is 0 and no guard fires. Samples can miss peaks and count
shared pages repeatedly. This is an incremental focused success, not a clean
build, independent replay or complete source checkpoint.

The preceding caller attempt has one observed new kernel-memory failure:
`DeclarationHeaderParameterStepSpec`. The monitor then deliberately interrupted
the caller attempt; no successful assembler audit is claimed. The other five
headers were authorized as the same bounded representation class, and are not
misreported as individually observed failures.

Control applicability is the same as in the
[two-header review](review-function-header-memory.md). The retained wrong-
character and omitted-token controls exercise the unchanged checked-witness and
lexical normalization machinery. The reviewer verified identical
`CertificateWitness`, `SourceDeclarations`, `SourceLexer` and Lean/Lake hashes
against that control packet. These are reused mechanism controls, not fresh
negative executions against these six texts. Earlier ordinary-body duplicate
fixtures are not header-extractor tests. Exact comparisons and the fresh
complete-source header proofs separately establish the six current results.

No material finding remains. No production file/cache or proof setting was
changed by the reviewer, and no extra proof job was started for this review.
The separate native full run `20261115T174959-94ae5c6fdf63` continues with
unchanged native inputs and supplies no success claim here. No GitHub write
or CLI-memory update was made. The complete caller/source/facade/module/axiom/
provenance/regression checkpoint remains with the lead.
