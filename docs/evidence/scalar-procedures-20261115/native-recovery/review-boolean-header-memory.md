# Independent Boolean header memory review — 2026-11-15

**Accepted with no material finding.** Reviewed author commit
`46c849d818699d8d7d87d6fb099b12d4e5d19c62`, integrated as `7064c1863`, against
production snapshot `7fa2549f82e679359795e799482f0461ed6eaaf7`. The substantive
acceptance was sent to the lead and author before this report was formatted;
it does not require delaying the complete checkpoint for the remaining inventory.

This is an independent read-only review selected as GPT-6 Astra / Max for
critical proof diagnosis and source correspondence. Live model/effort telemetry
and review token/cost totals are not independently exposed. The companion
[JSON record](review-boolean-header-memory.json) contains the exact hashes,
module closure, checks, resource summary and evidence identities.

## Exact repair and complete contract

Only `BooleanDeclarationExpectedTokens.lean` and the Boolean declaration proof
in `ComposeHelperSourceCandidate.lean` change. Native source, scripts, original
`ComposeBooleanDeclarationSource` contract, extractors and all other proof files
are unchanged. All **44 public and private theorem statements** in the candidate
remain byte-identical.

The original specification is the unchanged **78-character / 15-token**
implementation header followed by the **674-character / 119-token** specification
aspect expectation. Independent extraction confirms every copied suffix literal,
both complete character lists, the helper's 119-token witness and the candidate's
134-token witness. The operation remains concatenation of the two token lists.

The helper applies standard `String.toList_ofList` through the unchanged
`kernel_exact` tactic, then proves the original expectation using the unchanged
alphabet predicate, lexer and fuel. `kernel_exact` synchronously checks the
closed witness at the exact goal through `mkAuxLemma`. It adds no axiom or native
evaluation result. The candidate rewrites only the expected suffix and checks
the full extractor equality. Its other four `decide +kernel` fields remain:
precedence, scope, complete ordinary body and implementation header.

Independent extraction from **all 72,713 reviewed source tokens** finds exactly
one selected specification with all 134 tokens and one implementation with all
15 tokens. The full-source input and the original singleton/duplicate rejection
remain in the kernel obligation. This is not a bounded source excerpt check.

## Diagnosis and successful evidence

The retained baseline run `20261115T184604-a5d7f98394c3` explicitly failed with
kernel memory exhaustion at `ComposeHelperSourceCandidate.lean:201:18` under
8,192 MiB. The unchanged five-field diagnostic probe
`20261115T185313-4da734829393` emitted its sole error at the specification field,
`BooleanDeclarationFieldProbe.lean:38:2`; the other four fields emitted no
diagnostic. Both runs exited 1 normally, without guard or monitor interruption.
Neither failed module is claimed as an audited success.

The complete repaired helper run **`20261115T185653-905487da1ee4` passed**, including
the new helper and every field in the complete candidate. Its fresh imported
audit covered **104 modules / 14,576 declarations**, using only `propext`,
`Classical.choice` and `Quot.sound`. Build elapsed 183.949 s and audit 1.564 s.
It used one Lake worker, 12 Lean threads and 8,192 MiB per process on Linux
aarch64; the recorded reason is concurrent host headroom, not a permanent worker
default. Sampled peak process RSS was 3,533,248 KiB and tree RSS 4,570,848 KiB,
with no interruption or guard. Normalizing only this suffix while preserving
the complete source and obligations supports the literal-decoding diagnosis;
it does not establish a universal length or memory threshold.

I independently verified all **1,110 source inputs, 1,005 workspace inputs,
1,280 artifacts and 2 executable hashes**, the input digest, and agreement
between the frozen author commit, integrated commit, current files and successful
run for both changed files. The exact retained **runner** log decompresses to
`bcfecbbc994f51eeaa2d9b96982e35fab0db3a9629f2162654875a21e78c6d1b` and its emitted
module list matches the evidence. The temporary Boolean probe is absent from
production, synchronized source, successful imported closure and artifacts.

Previously reviewed wrong-character and missing-token controls apply to the
unchanged mechanism and identical Lean/Lake executable hashes. No new corruption
controls were run for this literal. Ordinary-body duplicate fixtures are not
header-extractor tests; the unchanged full header obligation and independent
complete-source extraction are the relevant checks here.

## Scope and handoff

This is focused incremental evidence, not a clean build, independent kernel
replay, macOS result or complete-project assurance. Complete source transport,
facade integration, native obligations and whole-project validation remain
separate requirements. No production/cache edits or new prover runs were made
for this review, and no #373 work is included. No GitHub mutation or CLI memory
update was performed; the live harness goal was null. Routine native monitoring
remains delegated to its designated owner.
