# Body-source equality recovery — 2026-11-15

## Complete-run failure and bounded diagnosis

Complete continuation `20261115T211741-9bb82c28fe83` ran on accepted production
`3c94de830` (equivalent integration `438213ec2`). It reported four explicit
8,192-MiB kernel-memory failures in independent `PredicateBodySourceCandidate`
equalities:

| Original theorem | Line | Diagnosed long literal | Characters / tokens |
| --- | ---: | --- | ---: |
| `candidate_body_tail_model_spec` | 163 | Complete model specification header | 712 / 151 |
| `candidate_body_body_tail_spec_header` | 287 | Header prefix before the typed tail-model renderer | 633 / 135 |
| `candidate_body_read_body_spec_header` | 297 | Header prefix before the typed read-contract renderer | 632 / 135 |
| `candidate_valid_context_body` | 468 | Complete validity-context expression | 762 / 147 |

These individual equality diagnostics already isolate the failures. No new field
probe is needed. The two composite headers retain their original semantic
renderers, concatenation order and exact 88-character / 23-token variant suffixes.
The existing `read_body` proof explicitly simplifies its typed renderer; that
route is preserved. The failed equalities alone do not establish a literal-only
cause; the focused complete candidate tests that established repair hypothesis.

Original execution session `15946` returned outer exit 254, with monitored child
-2 after the first-memory-diagnostic source guard sent SIGINT. The subsequent
`PredicateStructuralGuards` build was interrupted. Build elapsed was 510.580 s;
monitored elapsed was 520.532 s. No complete audit occurred. Sampled peak process
RSS was 8,390,032 KiB, peak tree RSS 9,454,224 KiB, and minimum host availability
7,668,128 KiB. Neither the 10-GiB tree nor 1.5-GiB headroom guard triggered.

The complete original candidate, managed and outer logs, resources, summary and
managed events are retained. Exact managed log SHA-256 is
`89dde835943d4fcda5eb5682779e0ff0f8ffac84685a82530033219e82844653`.
All 1,114 prior input, 1,009 workspace-input, 3,962 artifact and two tool hashes
still match. All **661** prior ordinary objects and 3,962 variant/hash files
remain byte-identical and are inventoried for the next gate.

## Authorized exact repair and focused gate

The parent authorized only four private proof bodies/imports in
`PredicateBodySourceCandidate.lean` and the new
`PredicateBodyExpectedTokens.lean`, plus this evidence packet. The helper proves
the four original long strings' character lists with the existing checked
`String.toList_ofList` / `kernel_exact` mechanism, then their exact expected
tokens through the unchanged alphabet, lexer and fuel checks.

The two composite proofs normalize only their long prefixes. They preserve
`(BodyNative.ScanExpr.tailModel .current .input).render` and
`BodyNative.readContractBody.render`, the original suffixes, closing tokens and
variants. The `read_body` `simp only` route is byte-identical. All **108** original
private theorem statements, every other private proof, the `Checked` fields and
public assembly remain unchanged. Original definitions, native source, contracts,
domains, selectors and duplicate rejection remain fixed. Each original complete
source-selector equality is still a kernel obligation.

The required focused target is the entire `Silver.PredicateBodySourceCandidate`:
all four helper contracts, every original candidate field and the public caller.
One worker, automatic twelve Lean threads and 8,192 MiB remain appropriate
because the measured single candidate uses about 9 GiB of process-tree RSS on
this 15.8-GiB host; two simultaneous dense candidates would exceed that headroom.
The native audit and build have completed, so concurrent native work is no
longer the allocation rationale. Retain the existing 10-GiB tree / 1.5-GiB host /
first-memory-diagnostic source-only guards. Focused success and independent
critical acceptance precede the next complete cached run. No clean build,
replay, duplicate successful gate or speculative additional normalization.

| Work | Model / effort | Current result | Available cost evidence |
| --- | --- | --- | --- |
| Four isolated body-source equality repairs | Selected Astra Max; live lead setting not independently exposed | Exact repair prepared; focused validation and independent acceptance pending | Complete failed attempt 520.532 s monitored elapsed; token and whole-team costs unavailable |

Complete source/facade/module/axiom/provenance assurance remains outstanding.
