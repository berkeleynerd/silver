# Independent review: remaining long source expectations

**Disposition: accept `91858a579` with no material finding.** The ten changed
checks preserve their original complete-source statements and distinct
extractors. This focused result does not complete the caller, authoritative
source or whole-project assurance gates.

The reviewer did not author the changes. The parent selected GPT-6 Astra / Max
for critical review; independent live model/effort telemetry is unavailable.
Review date: 2026-11-15. Review elapsed time, token usage and cost were not
measured. The tool times below are not review or whole-team cost measurements.

| Round | Intended result | Result and rework | Evidence scope |
| --- | --- | --- | --- |
| Independent critical review, selected Astra / Max | Check original statements/data/selectors, unchanged sibling proof, kernel mechanism and audited provenance | Accepted; no production rework requested | Read-only review and independent extraction/hash comparisons; no additional proof run |

## Authorized scope and exact data

The delta contains exactly the ten assigned leaf files and the new
`FunctionRemainingExpectedTokens.lean` helper under
`proof/Silver/FunctionSourceParts/`. Only the **second** theorem's proof changes
in `DeclarationOrdinaryFunctionBodyAt`: its preceding
`declaration_ordinary_function_body_at` statement **and proof** remain
byte-identical. Every exported statement in all ten files is unchanged.
The [supporting JSON](review-remaining-expectations-memory.json) records exact
file, statement, literal, input and artifact identities.

| Check | Original extractor/selector | Characters / tokens |
| --- | --- | --- |
| Metadata append header | `procedureHeader`, `lemma_function_metadata_append`, `is` | 690 / 149 |
| Parameters-at loop body | `ordinaryFunction`, `parameters_at` | 887 / 179 |
| Parameter-frame loop body | `ordinaryFunction`, `parameter_frame` | 989 / 196 |
| Actual-model specification | `functionHeader`, `actual_model`, `;` | 455 / 98 |
| Actual-after specification | `functionHeader`, `actual_after`, `;` | 541 / 117 |
| Actuals-model specification | `functionHeader`, `actuals_model`, `;` | 660 / 138 |
| Actuals-after specification | `functionHeader`, `actuals_after`, `;` | 708 / 151 |
| Call-model specification | `functionHeader`, `call_model`, `;` | 508 / 112 |
| Read-call specification | `functionHeader`, `read_call`, `;` | 585 / 131 |
| Call-assignment-body specification | `functionHeader`, `call_assignment_body`, `;` | 610 / 126 |

For every row, the original catalogue text and all three copied literals agree,
both complete character lists match, and the helper/leaf token lists match an
independent lexical extraction. All texts are ASCII; the character counts also
give their UTF-8 byte counts. Parameters, contracts, aspects, variants and body
tokens are preserved in order. Independent extraction from the entire
**72,713-token** reviewed source finds exactly one selected result for each row.
The two body results include their complete named `end` terminators.

The original call-spec namespace and shared helper both implement
`expectedTokens` as `(Source.lexLine text).getD []`; neither definition changes.
The leaf's `change` and final proof still must check at the original exported
type. This definitional conversion does not replace the original lexical policy.

All previous successful helpers, source catalogues, reviewed source, scanners,
consumers and trusted proof helper remain unchanged. The only production delta
is the eleven authorized proof files. Native source, scripts and native project
inputs remain those of `8a03ab122`.

## Proof mechanism and focused evidence

Each new character theorem uses standard `String.toList_ofList` through the
previously reviewed `kernel_exact` path. The kernel checks the exact original
literal against its complete character list. The token theorem then rewrites
that equality into the unchanged alphabet check, lexical fuel and lexer result,
proved with `decide +kernel`. Each leaf uses the resulting token equality and a
closed reflexivity witness checked at its original complete-source goal. There
is no source slicing, altered singleton/duplicate policy, narrowed contract or
domain, suppressed obligation, new project axiom or kernel bypass.

Run [20261115T182359-36d64a7ff504](../lean-recovery/remaining-expectations/focused-success-evidence.json.gz)
passes all ten selected modules and the helper, then freshly audits **119
modules / 16,368 declarations** on Linux aarch64, Lean 4.34.1. Only `propext`,
`Classical.choice` and `Quot.sound` occur. The reviewer verified the exact
runner-log digest, all 1,109 current run-input hashes at comparison time,
production/workspace hashes and all 66 selected artifact entries for the eleven
files. The recorded module/input/workspace/artifact inventories contain no
retired probe, segmented candidate or temporary control.

The build takes 211.534 s, fresh audit 0.903 s and managed run 218.591 s.
One Lake worker, automatic 12 Lean threads and the original 8,192 MiB periodic
per-process threshold remain in effect. Sampled process RSS peaks at
5,566,992 KiB, summed RSS at 6,612,816 KiB; minimum sampled host availability
is 8,622,528 KiB. Exit is 0 with no interruption or triggered guard. Samples can
miss peaks and count shared pages repeatedly. Dependency objects are reused;
this is not a clean build, independent replay or complete source checkpoint.

Only the metadata-header theorem is a newly observed failure in predecessor
caller run `20261115T181631-ffc5a0d4c6b1`. That module memory failure was followed
by controlled caller interruption, without a successful caller audit. The other
nine checks were authorized by representation and size; they are not described
as individually failed. The 433-character selection boundary is **not** a proved
memory bound.

Reused wrong-character and omitted-token controls retain the applicability
recorded in the [earlier review](review-function-header-memory.md). Their
`CertificateWitness`, `SourceDeclarations`, `SourceLexer` and Lean/Lake hashes
match this run. They test the unchanged checked-normalization machinery, and
are not fresh negative executions on these ten texts. Earlier ordinary-body
duplicate fixtures are not `procedureHeader` or `functionHeader` tests. Each
current complete-source equality/uniqueness statement is separately proved and
independently corroborated by extraction.

No production file/cache or proof setting was changed by the reviewer; no extra
proof run was started for this review. The separate native full audit
`20261115T174959-94ae5c6fdf63` is still ongoing with unchanged inputs, and supplies
no success claim here. No GitHub write or CLI-memory update was made. Final
caller/source/facade/module/axiom/provenance/regression integration remains
parent-owned.
