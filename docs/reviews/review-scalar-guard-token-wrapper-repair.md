# R1 disposition: token-wrapper interpretation repair

2026-10-26. Independent bounded recheck; selected GPT-6 Astra at Extra High.
Runtime model/effort are not independently exposed. Inspection interval:
05:06:22–05:08:51 UTC (2 minutes 29 seconds), including a context handoff.
Report writing and the final five-file hash check completed at 05:09:29 UTC
(3 minutes 7 seconds total). Token and cost measurements are unavailable. The
lead remains the sole runner.

## Verdict

**R1 is addressed by the exact five candidate files below.** No residual issue
was found within this recheck. The raw wrapper preserves the full existing
formal `ValidToken` domain, its inherited `Take_Token` meaning is now derived,
and the narrower semantic projection requires fixedness established for all
three caller families. This is a source-review disposition, conditional on
successful elaboration and subsequent integration checks; it is not a claim
that the complete actual-source correspondence is finished.

## Exact inputs

Candidate working-tree bytes in `tmp/scalar-guards-source-author`, whose HEAD
was `ec8b4754e226711847f73155e7479c992f0f2fe0`. These are pending edits, not a
review of that HEAD. Compared with the original finding's canonical target
`4a4435a5ba9807884d0b1bab9855e182730376b6`; the lead's later canonical target
`5620276682` does not substitute for these exact candidate bytes.

All five SHA-256 values matched the author's
`tmp/guard-token-wrapper-repair.json` during this recheck:

| File under `proof/Silver/` | SHA-256 |
| --- | --- |
| `PredicateAdapter.lean` | `cd5e7761061ccd77b90979c332f3d5ad739c337f5c470e87e858247831e086c9` |
| `PredicateAdapterEnvironment.lean` | `6b46802be94968ff65dd574ba511214f0a7ea17e61429f64a31377aeeee2d764` |
| `PredicateBasicLibraries.lean` | `b45b70c3fd3880dc633a8a02ea8180034b3e07f0c24ea085cbf6fdccab039b05` |
| `PredicateLoopHelpers.lean` | `485ea109568aa94ef2f39ca94b0f19e8b3fc2e30dc6d2ea8db104e367ee0bcc4` |
| `PredicateEquations.lean` | `2fa25c220e1c9617c791b5521483cf21507ff9e9189ff76d441c8ff00bc67ee4` |

The last two author updates affecting this scope changed record-update field
layout in BasicLibraries and Equations. The current contents were inspected;
the previous hashes for those two files are superseded by the table above.
Other pending work in the author checkout is excluded.

## Why R1 is resolved

`PredicateAdapter.lean:207` defines `takeTokenModel` using `fixedAfter`,
`Expressions.spelling` and `Expressions.isWord`. `Expr.eval` retains an arbitrary
`takeTokenCall` and uses it for both `.bodyToken` and `.takeToken`. Consequently,
the original legal capacity-token witness (text `"0"`, position 1, valid empty
context and zero-count flow) now normalizes to position **2**, matching the
native operation, rather than the old semantic-only result of zero.

`PredicateAdapterEnvironment.lean:138` retains the original `TokenDomain`.
`ModelEquations` carries the arbitrary raw callee. The
`token_expression_projection` theorem derives its equality to the normalized
model from `Expressions.interpreted_take`, using the legal text, cursor and
token premises. `normalize_tokens` composes that derivation with the raw model
equation. The remaining `normalize_models` token-field copy therefore occurs
only after token normalization; it no longer conceals the missing dependency.

The semantic projection `token_interpreted` now additionally requires
`Adapter.FixedToken`. BasicLibraries, LoopHelpers and Equations each prove
fixedness for their finite token set and derive fixedness of the complete typed
token-call inventory using the existing completeness theorem. Each corresponding
helper interpretation supplies the fixedness premise. In Equations,
`Definitions.wrapperModels` explicitly names the inherited raw token function,
and `Implementation.wrapper_models` consumes inherited helper equations through
`normalize_tokens` before normalizing the initial-flow call.

The explicit raw-interface witness `model_raw_equations`, Basic/Loop links and
implementation model calls were updated to use the complete native token model.
They therefore no longer preserve the old full-domain contradiction behind a
semantic-only concrete witness.

The repair changes no native contract, source call site or admitted language
input. The restriction is on projection to the existing fixed-token body
semantics. This recheck uses the full existing formal `ValidToken` domain; it
does not independently re-audit representation of the entire native enum.

## Limits

Only R1 from `report.md` was reopened. Earlier semantic findings were reused;
unrelated source drafts, source-shape pins and top-level SourceBridge integration
were not approved. No Lean/native runner, GitHub post, project edit or Git
mutation was performed. The author reported partial focused build results and
parser-layout fixes; this report makes no independent validation claim. The
lead must retain the required proof, source-correspondence and final integration
checks. Only this supplemental scratch report was written.
