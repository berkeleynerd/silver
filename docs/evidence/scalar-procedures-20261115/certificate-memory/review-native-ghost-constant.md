# Independent native ghost-constant review — 2026-11-15

Accepted for integration and the remaining focused/complete validation, with
**no material finding**. This is a bounded source, contract, erasure and evidence
review; it does not establish the still-pending complete assurance checkpoint.

The reviewed native/semantic commit is
`d19baabc5d1e6c21d453df48e92f1b08cf7358b5`, integrated by the lead as
`03141a9fe`. Its implementation files are `src/silver_output_profile.adb` and
`proof/Silver/ComposeArrayDeclarationSource.lean`. I also reviewed the lead's
exact `ReviewedOutputShape.outputImplementation` update and
[token delta](../recovery/reviewed-output-pin-delta.json), with complete pin-file
SHA-256 `191e1d95d40e1d0c85765093acc7aec80ad17c7b7cce2d6eb8c51eb5cb2b2684`.
The native [repair packet](../native-recovery/README.md) retains the author's
commands, outcomes, reports and prepared inputs.

The runtime `Result` initializer and the exported raw-model postcondition are
byte-identical. The change binds the same `Array_Declaration_Model (Text,
State, Arguments)` expression once as `Model_State` with `Ghost => Static`,
then uses that constant in the existing logical-equality assertion and equality
lemma call. The complete direct `Declaration_At` caller is also byte-identical.
The model and wrapper preconditions are identical; neither requires positive
`State.Position`, and `Valid_State` retains its existing zero-position domain.
No guard, input restriction or native contract is weakened or strengthened.

The fixed renderer includes the whole new declaration, all model-call arguments,
the `Ghost => Static` aspect, the Static assertion, the equality call and the
unchanged return/terminator. Independent lexical comparison matched all 45
tokens from the new ghost declaration through the function's named terminator.
The model call is total over the wrapper's admitted domain under its unchanged
verified contract; its new call precondition is present and proved. The
existing lemma's checked header still requires logical equality and exports
raw record equality as well as logical equality.

The erasure argument is specific to the fixed source shape: the new constant
is explicitly Static, its two uses are the Static assertion and a procedure
whose exact checked header is `Ghost => Static`, and the runtime initializer
does not read the constant. Pinned SPARK 16.1
`references/spark/16.1/docs/ug/en/source/specification_features.rst:2210`
describes the predefined Static level as always ignored independently of
compiler switches or assertion policy. Thus retaining the unchanged
`Body.eval`, `eval_eq_expression` and `equation_of_definition` does not erase
runtime work or assume equality of arbitrary parser states. Their equations
remain universal in the callee interpretation and local environment.

I independently read the retained reports and compared both complete prepared
input archives. All 2,606 names agree, and the sole changed native input is the
intended `.adb`. Its retained bytes equal the frozen reviewed commit. The new
whole-helper report has 56 successful proof records and two flow records,
with no skip or assume entries. The first 53 proof identities precede the
unchanged ghost tail; two model-call precondition checks become one because
the expression is evaluated once, while the equality assertion and lemma
precondition remain. The canonical 30-second, three-prover, level-2 policy
was not enlarged. The old session is retained as incremental evidence, and
the old failing run is not relabeled successful.

The baseline's complete caller has 11 successful proof records and two flow
records. Its exact declaration/body and the callee's unchanged exported
contract support the stated focused reuse. This is not a complete fresh audit
of all callers or the entire implementation.

Independent old/new tokenization matched the old/new complete reviewed pin:
72,709 versus 72,713 tokens. The change is precisely the 18-token ghost
declaration and replacement of each of the two eight-token model calls by
`model_state`. Applying the three retained delta operations reconstructs the
new pin exactly; every other pin byte is unchanged. Source hashes are
`619f4fb8e2b0f318dac7c6278d5f644198816ce7733959ed71ca03917546b2b8`
before and
`9ede490b6cf72b352a39072cd37f4ef39774409c6024135487cf076567b59b9c`
after. Independent checks and fragment identities are recorded in
[native-review-facts.json](native-review-facts.json).

The focused Lean wrapper check and final binding of its exact renderer to the
authoritative source remain separate required gates. Updating a pin supplies
no semantic or source-correspondence proof by itself. Complete native,
Lean/module/axiom, source/provenance and regression validation remain required.
No additional prover run was launched for this review and no author-owned
implementation file was modified. This independent critical review selected
Astra / Ultra; actual runtime model/effort telemetry was not independently
available.
