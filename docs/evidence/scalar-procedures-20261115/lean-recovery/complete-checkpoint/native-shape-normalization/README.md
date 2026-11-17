# Native shape specification-header recovery — 2026-11-15

## Retained complete-run failure

Complete continuation `20261115T205032-5834a8189332` ran on reviewed production
`24115ffd2` (equivalent integration production `451b5761a`). It completed
`PredicateNativeHelpersCandidate`, then reported explicit 8,192-MiB kernel memory
failures in six independent `PredicateNativeShapeCandidate` header equalities:

| Original private theorem | Original line | Characters / tokens |
| --- | ---: | ---: |
| `native_primary_model_spec_header` | 196 | 701 / 149 |
| `native_relation_model_spec_header` | 202 | 705 / 149 |
| `native_condition_tail_spec_header` | 220 | 948 / 196 |
| `native_condition_model_spec_header` | 226 | 709 / 149 |
| `native_boolean_factor_model_spec_header` | 262 | 729 / 149 |
| `native_boolean_relation_model_spec_header` | 272 | 737 / 149 |

These are individual equality declarations, so they already identify the failed
fields. No additional field probe or speculative normalization is needed.
The first-memory-diagnostic guard sent source-only SIGINT and interrupted the
subsequent `PredicateBodySourceCandidate`. Original execution session `72203`
returned outer exit 254; the monitored child returned -2. This was an interrupted
failed complete attempt with no whole-project audit.

Monitored elapsed was 665.628 s. Sampled process peak was 8,435,184 KiB RSS,
tree peak 9,477,264 KiB, and minimum host availability 6,390,096 KiB. Neither
the 10-GiB source-tree guard nor the 1.5-GiB host-headroom guard triggered.
The managed log SHA-256 is
`0e57e3707a539921ed8eac74ec461d0d298a77c2b7352abb3c13cce34ea105e1`.
The exact original source, logs, resources, summary and events are retained here.
All 1,113 prior captured input hashes and both tool hashes matched before repair;
659 ordinary objects and 3,950 variant/hash files were inventoried and preserved.

## Authorized bounded repair

Only the six private proof bodies and required imports change in
`PredicateNativeShapeCandidate.lean`; the new
`PredicateNativeShapeExpectedTokens.lean` proves their exact expected literals.
The helper first checks each string's character list using the existing
`String.toList_ofList` / `kernel_exact` mechanism, then proves its token list
through the unchanged alphabet, lexer and fuel checks with `decide +kernel`.
Each original full-source selector equality remains kernel checked.

All original theorem statements, other private proofs, `Checked` fields and
public assembly remain byte-identical. The six original expected definitions in
`PredicateNativeSourceChecks.lean`, native source, contracts, semantic models,
domains, extraction and duplicate rejection remain unchanged. This is a bounded
test of the established literal-decoding memory diagnosis.

The full focused target is `Silver.PredicateNativeShapeCandidate`, covering all
six helper contracts, every original private field and the public caller.
Use one worker, automatic twelve Lean threads and 8,192 MiB, with the existing
10-GiB tree / 1.5-GiB host / first-memory-diagnostic source-only guards. The
productive two-worker native audit on this 15.8-GiB host justifies that allocation.
The focused candidate must pass and receive independent critical acceptance
before the next complete cached continuation. Preserve all matching successful
objects and prior evidence; no clean build, replay or repeat of successful gates.

| Work | Model / effort | Current result | Available cost evidence |
| --- | --- | --- | --- |
| Exact failed-header normalization and source correspondence | Selected Astra Max; live lead setting not independently exposed | Six-header repair and complete focused candidate passed; final evidence review and whole-project continuation pending | Complete failed attempt 665.628 s; focused success 285.288 s monitored elapsed; token and whole-team costs unavailable |

No complete-source/facade or whole-project assurance is claimed by this record.

## Complete focused success and retained continuity

Run `20261115T210927-f5ecbbed5260` passed on immutable production `3c94de830`.
The original execution session `18170` returned exit 0, with no interruption or
guard. The new helper completed in 2.2 s, followed by the complete candidate.
Managed build elapsed was 272.099 s and fresh audit elapsed was 1.172 s.
The actual imported environment contains **127 project modules and 21,408 audited
declarations**, using only `propext`, `Classical.choice` and `Quot.sound`.

All six normalized header helpers and the original complete source-shape
candidate pass together at the unchanged memory threshold. All **63** original
private theorem statements and the original `Checked` fields/public assembly
remain unchanged; only the six diagnosed proof bodies changed. The initial
input-review record's count of 58 came from incomplete multiline parsing; the
corrected inventory explicitly compares all 63 statements. This is an evidence
count correction and changes no production proof or validation input.

The run used one worker, automatic twelve Lean threads and 8,192 MiB. Sampled
peak process RSS was 4,252,992 KiB, peak tree RSS was 5,296,592 KiB, and minimum
host availability was 11,302,496 KiB. Monitored elapsed was 285.288 s. These are
observed measurements for this run, not resource guarantees for other modules.

After terminal collection, all **1,114 input, 1,009 workspace-input, 3,962 artifact
and two tool hashes** were reverified. All **659** prior ordinary objects and
3,950 variant/hash files remain byte-identical. Exact success evidence, managed
and outer logs, resources, summary, events and verification are retained here.
The exact managed log SHA-256 is
`5dd4f2fbd93910de0ced79ecb108a00a2c22719a108090f9ba0120fda51c345e`.

Textual `Silver.Audit` import preflight reaches all **1,007** current project
modules with no missing project import or unreachable module. There are 661
retained ordinary objects, with 346 modules lacking an object. This is a textual
preflight and object-presence inventory; the complete cached continuation must
still establish actual whole-project module coverage, axiom auditing, stable
inputs and source correspondence. No clean build or kernel replay was performed.
The exact patch received independent static acceptance while the focused check
ran; independent acceptance of this terminal evidence and coordinated resource
release precede the next complete continuation. Do not repeat the passed gate.
