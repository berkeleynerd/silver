# Flattened token-value certificate diagnosis

This is a focused diagnostic for owner-authorized Boolean work in #291, reviewed
against `d2db22c443df3434f1b82644886d0c71ccb886e1` on native Linux x86-64 on
2026-10-30. The lead identified `5198f2b7b5` as the frozen source/proof checkpoint.
Selected reviewer settings were GPT-6 Astra / Extra High. Runtime confirmation
and token/cost measurements were unavailable. No language, source-correspondence
requirement, theorem statement or trusted assumption was changed by this review.

## Failure and diagnosis

Complete run `20261030T132736-e452c95bd00d` reported:

```text
Building Silver.OutputBodyCertificate (11216s)
error: Silver/OutputBodyCertificate.lean:65975:78: maximum recursion depth has been reached
```

The 11,216 seconds cover the whole failed module build, not the failing tactic
alone. The exact failure is the token-value theorem:

```lean
theorem outputBodyTokens_values :
    outputBodyTokens_certificates.flatMap (·.tokens) = outputBodyTokens := by rfl
```

It precedes the `_correct` theorem and its `rw` proof. The latter is not the
reported failing location. The module has `maxRecDepth 100000`; larger local
settings for source reconstruction joins do not cover this theorem.

The pinned Lean `rfl` implementation calls
`approxDefEq <| isDefEqGuarded lhs rhs` in the elaborator before constructing
`Eq.refl`. The existing [kernel_exact helper](../../../../../proof/Silver/CertificateWitness.lean)
elaborates an explicit witness without that expected-type conversion and passes
it to `mkAuxLemma`, which uses checked `addDecl` at the exact goal type. It neither
bypasses kernel checking nor introduces a proof axiom.

## Controlled comparison

Managed run `20261030T164610-79542966b746` reserved one worker and ran Lean with
one thread, an 8192 MiB memory limit and a 300-second diagnostic wall-time cap.
It finished in 293.252 seconds. Both equality variants imported the same compiled
fixture and used `maxRecDepth 100000`.

| Phase | Result | Seconds |
| --- | --- | ---: |
| Prepare shared fixture | Passed | 265.516 |
| `kernel_exact (Eq.refl tokens)` | Passed; `#print axioms` reported no axioms | 12.952 |
| `rfl` | Failed with `maximum recursion depth has been reached` | 14.782 |

The fixture preserves all 44,843 actual source tokens, their 4,396 per-line list
boundaries and the balanced block projection/append shape. It replaces the
certified line and reconstruction records with plain token/line records, omitting
lexical proofs, source-text fields and reconstruction proofs. This comparison
isolates the reproduced elaborator conversion limit: the kernel checks the same
token-value equality shape without increasing the recursion limit.

Lean's recovery theorem after the failed `rfl` elaboration reported `sorryAx`.
That failure produced no `.olean`; it is not a successful proof or reusable
artifact. The successful `kernel_exact` theorem has no axioms.

Two earlier 60-second diagnostics expired while preparing their shared fixture,
before either equality was checked. They establish no equality-proof outcome:

| Local retained run | Preparation | Seconds |
| --- | --- | ---: |
| `20261030T164221-bdb56ec9807e` | Original per-line lexer proofs; omitted reconstruction | 60.227 |
| `20261030T164407-07731199b190` | Plain token/line records | 60.457 |

The extended allowance followed the main run's measured 134-second
`ReviewedOutputShape` compilation. It was not a response to a new proof failure.
The preliminary scripts, inputs and reports remain under the integration
checkout's `tmp/boolean-values-preflight/` and
`tmp/boolean-values-token-preflight/`. The successful fixture and compiled objects
remain under `tmp/boolean-values-token-preflight-extended/`; they are not archived
in Git. The retained evidence names and hashes the successful fixture sources,
runner and `.olean` objects.

## Repair recommendation and remaining validation

Use a private 32,768-token cutoff in the
[generator](../../../../../proof/generate_source_certificate.py) to select
`kernel_exact (Eq.refl <prefix>)` only for large `_values` proofs, retaining `rfl`
for smaller lists. This is a proof-strategy selection, not a claimed universal
recursion bound. OutputBody has 44,843 tokens; the next-largest current certificate
has 3,496. Regenerating all 28 certificates should therefore change only
OutputBody's `_values` proof. Keep theorem statements, tokens, source proofs,
reconstruction depth settings and the final `_correct` proof unchanged.

In the existing native certificate regression, force the large-list strategy on
a tiny fixture by temporarily lowering the private cutoff. Check both successful
compilation/audit and rejection of a mutated flattened-token list with
`(kernel) declaration type mismatch` and no emitted object. Preserve the normal
small-list `rfl` mutation check. No large regression fixture is needed.

**The actual generated OutputBodyCertificate and complete fresh source/axiom audit
remain mandatory.** This reduced-record diagnostic is not a replacement for
checking the omitted lexical and reconstruction fields in the real certificate.
No additional expensive proof run was performed for this retention step.

## Retained evidence

- `original-failure.log.gz`: exact relevant excerpt from the complete run's log.
- `controlled-comparison-events.jsonl.gz`: original managed lifecycle records,
  resource settings and phase commands.
- `controlled-comparison.log.gz`: complete diagnostic output for all three phases.
- `controlled-comparison-evidence.json.gz`: exact input, tool, helper, fixture and
  artifact hashes; results/timing; selected review settings and limitations.

The compressed records are small; generated fixture source and compiled objects
remain local. Decompression preserves the original event and log bytes. This
record documents diagnosis and a proposed repair, not completed integration or
assurance for #291.
