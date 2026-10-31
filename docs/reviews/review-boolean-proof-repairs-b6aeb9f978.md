# Boolean source-proof repairs and regression applicability

Independent read-only review of
`b6aeb9f978597ac025de21a8574c76c42389cf82`, 2026-10-30
18:52:31–18:57:57 UTC (5m26s). Reviewer selected GPT-6 Astra / Extra High;
runtime confirmation and token/cost measurements unavailable. No tests, builds,
proofs, repository writes or GitHub writes were performed by the reviewer. The
lead retained the returned conclusions here.

No blocker found in these three repairs. They preserve theorem statements,
modeled behavior, admission domains and authoritative Ada bytes. Successful
complete actual-source validation remains required.

- **Array wrapper:** only the missing outer parentheses were added to
  `Body.render`. Evaluation, `Checked`, initializer and surrounding assertion
  and return tokens are unchanged. Independent lexical extraction matches all
  800 body tokens and 818 function tokens in the retained successful kernel
  check `20261030T184922-9ba9fdaacabb`; its inspected input hashes match integration.
- **Adapter numeral:** only the proof body changes. Proved core lemmas normalize
  zero rendering before the existing kernel decision. All 108 candidate tokens
  independently match Ada `Context_Of`; statement, expression and domain are
  unchanged. Focused success `20261030T184802-f5496b2d5331` applies to the repair.
- **Flattened certificate:** the generated OutputBody file differs by exactly
  the `_values` proof tactic. `kernel_exact (Eq.refl outputBodyTokens)` must prove
  the original flattened-list equality through checked `mkAuxLemma`/`addDecl`.
  The helper is unchanged, and no axiom or unchecked declaration path was added.
  The cutoff selects a proof strategy, not accepted source. Tokens,
  reconstruction and the final lexer theorem remain unchanged.

The controlled reduced-record experiment establishes the witness strategy's
viability, not completion of the actual 44,843-token certificate. Its lexical
and reconstruction fields, downstream source correspondence and whole-project
audit still require successful complete validation. See the
[diagnosis](../evidence/boolean-objects-20261030/source-integration/flattened-values/README.md),
[wrapper check](../evidence/boolean-objects-20261030/source-integration/array-wrapper-repair/README.md)
and [adapter check](../evidence/boolean-objects-20261030/adapter-numeral-repair/README.md).

## Regression applicability

Run `20261030T184849-3885f48eaec2` passed all 12 `test_lean_source` identities,
including 28-certificate regeneration parity and positive/negative kernel
checks of the forced explicit-witness branch. Captured generator, certificate
and test bytes match integration. Its two older proof-file versions differ
only in text ignored by these tests' whole-project scans; import graph,
`include_str` uses and module markers are identical. These passes remain
applicable to the reviewed target.

The smallest additional refresh is the 12 `PlatformIsolationTests` methods
plus `InstallationEnvironmentTests.test_symlinked_tmpdir_preserves_platform_setup_and_routing`:
13 identities using the changed proof/generator fixture. Running all 16 methods
in `test_platforms.py` is a convenient superset. No additional
`test_output_integrity` or `test_lean_evidence` refresh is needed for this delta:
the former uses unchanged Ada/GPR inputs, and the latter's sole generator
reference reads unchanged `SOURCE_BINDINGS`.

The inventory remains 568 IDs representing 559 underlying methods. With all
16 platform IDs refreshed, the composition after the planned final Rosetta
metadata refresh is 534 retained passes + three earlier repair passes + 12
source-test passes + 16 platform passes + three Rosetta passes = 568.
The platform run was still active during this review; its terminal result and
the future Rosetta rerun need confirmation in the final record. Native assurance
and complete Lean/source validation remain separate pending obligations.
