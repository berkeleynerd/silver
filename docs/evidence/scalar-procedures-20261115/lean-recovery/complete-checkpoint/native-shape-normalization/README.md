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
| Exact failed-header normalization and source correspondence | Selected Astra Max; live lead setting not independently exposed | Six-header repair prepared; focused validation and independent acceptance pending | Complete failed attempt 665.628 s; token and whole-team costs unavailable |

No complete-source/facade or whole-project assurance is claimed by this record.
