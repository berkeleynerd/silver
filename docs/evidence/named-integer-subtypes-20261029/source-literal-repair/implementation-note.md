# #286 / #290 bounded source-literal repair

Base: `288337f8ce`; governed implementation: `6020416906`.
Only the five assigned handwritten Lean proof files changed. No Ada, script,
test, catalogue, native workspace, generator, domain, or semantic tree changed.
Integration `tmp/named-integer-subtypes` was not mutated. This worker ran no Lean
build/source checkpoint; root retains the existing successful expensive objects.

## Extraction and exact deltas

`source_literal_diagnose.py` imports the existing
`proof/generate_source_certificate.py:lex_candidate`, then mirrors the existing
unique header/body selectors from `SourceDeclarations.headerEnd`,
`SourceLexer.balanced`, and `PredicateSourceRequirements.ordinaryFunctions`.
It extracts current authoritative source rather than consuming renderer output.
The resulting candidates still require normal Lean kernel checks and final
authoritative-source correspondence. It is a diagnostic, not new trusted logic.

- `ScalarExpressionSourceShape.spec`: 820 tokens, one replacement `12` -> `7`.
  `ScalarExpressionSourceChecks.Declarations`: corresponding expected source
  declaration `/ 12` -> `/ 7`. The complete body pin (3496 tokens) is unchanged.
  Source `silver_scalar_expressions.ads:11`,
  `ScalarExpressionEnvironment.maxBindings` and
  `ScalarEnvironmentSourceBridge.Checked.maximum` already agree on `/ 7`.
  The admitted scalar environment remains 585 slots; this patch changes no
  capacity or proof domain.
- `PredicateBasicSourceCandidate.candidateBody`: 729 -> 783 tokens. Six call
  sites gain the nine-token final argument `, Context.Subtype_Hiding
  (Names.<operation>)`: test and update calls for Output_Call,
  Partial_Output_Call, and Reject_Call. Authoritative `Basic_Body` is at
  `silver_output_profile.adb:3277`. `PredicateBasicExpressions.Test.eval/render`
  and `Update.eval/render` already pass the same resolved operation's hiding
  bit to Call_After. This preserves the model's call-visibility behavior.
- `PredicateLoopCandidate.candidateBody`: 1144 -> 1165 tokens. Inside the
  constant-array target scope, immediately after taking Loop_Keyword,
  `Index_Bounds := Context.Array_Names.Items (Target).Component_Bounds;`
  replaces the later `Scalars.Full` assignment. Thus `Target` is still in scope,
  and the element binder uses its declared component interval. `Update.arrayBounds`
  eval/evalWith/render and `array_tail` already use `componentBounds`.
  The copied inner environment also uses the authoritative in-place count
  increment and fresh-slot assignment rather than the obsolete whole-record
  `Scalar_Expressions.Append` call. `Update.inner` eval/evalWith already models
  precisely the preserved prefix through Context.Count plus that fresh binding;
  render already emits the two assignments. `enterScope` copies Context first.
  Counted-loop handling, static annotations and all proof scripts are unchanged.
  The source selector excludes forward declarations and uniquely chooses the
  implementation at `silver_output_profile.adb:3508`.
- `PredicateAdapterSourceCandidate.context_ofCandidate`: 58 -> 68 tokens,
  adding `Subtype_Hiding => Scan.State.Subtype_Names.Hidden_Calls`.
  `expand_bodyCandidate`: 63 -> 67, adding `Subtype_Names => Subtypes`.
  `read_statementsCandidate`: 89 -> 95, adding
  `Scan.State.Subtype_Names` as Expand_Body's fourth argument.
  Authoritative source is at lines1757,1831,3699. `PredicateAdapter.contextOf`,
  `expand`, `adapterEval`, the corresponding typed expressions/renderers, and
  their context_eval/expand_eval/adapter_eval equations already carry the same
  state and hidden-call projections. The body_of/body_token/at_body_stop pins
  were checked and remain byte-identical.

Full token-index deltas are in `source_literal_token_deltas.txt`:

```sh
python3 tmp/source_literal_diagnose.py --baseline 288337f8ce
python3 tmp/source_literal_diagnose.py
```

The final diagnostic matches all ten owned token lists to authoritative source.
An adjacent read-only sweep also matched all56 directly literal header pins
from PredicateSourceRequirements; composite/nonliteral header checks remain in
Lean. No additional literal mismatch, stale capacity model or nonliteral mismatch
was identified by this bounded analysis. `git diff --check` passed. A structural
comparison confirms only token-list/expectedTokens literal content changed;
imports, definitions outside these literals and theorem proof scripts are intact.

## Dependency retention and smallest focused checks

Source import-closure analysis confirms none of these five modules is imported
by `Silver.OutputBodyCertificate`, `Silver.ComposeSourceCandidate` or
`Silver.PredicateScalarBodyCandidate`. Their Ada/source/generator/model inputs
are unchanged, so those completed expensive objects remain applicable under
ordinary Lake invalidation and the fresh final audits.

The three Predicate candidates are directly imported by
PredicateSourceRequirements, which feeds PredicateSourceCandidate. ScalarShape
feeds ScalarExpressionSourceChecks, then ScalarExpressionSourceBridge. Both
routes eventually feed PredicateSourceBridge. Root should wait for the current
complete run to become terminal before synchronizing this reviewed commit.

Smallest immediate targets, using root's existing managed workspace only:

```sh
python3 scripts/check_lean.py \
  --target Silver.ScalarExpressionSourceChecks \
  --target Silver.PredicateBasicSourceCandidate \
  --target Silver.PredicateLoopCandidate \
  --target Silver.PredicateAdapterSourceCandidate
```

Then `Silver.PredicateSourceCandidate` checks the previously blocked actual
function extraction/header route, followed by the complete cached
`scripts/check_lean.py` checkpoint with its fresh whole-project coverage/axiom
audit. Focused success alone does not establish the complete-source result.
Root coordinates the final28 affected proof-tree regressions separately.

## Round accounting

The bounded worker was explicitly selected as GPT-6.1 Sol / Extra High;
runtime model/effort confirmation and token/cost metadata are unavailable. Work consisted of cheap
source extraction, semantic/source comparison, minimal literal edits and
dependency analysis. No expensive native or Lean execution was launched.
Independent review and all authoritative Lean validation remain with root.
