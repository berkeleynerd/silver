# Scalar function raw-source repair review — 2026-11-07

No remaining R1 defect was found in the reviewed repair. The previously assumed
normalized body-reader and return-import meanings are now derived from raw
definition equations, verified contracts and directly linked callees. This
resolves the code-level derivation gap in the
[original R1 review](review-scalar-function-source-integration-20261107.md) for
#298 / #340; downstream
integration validation remains outstanding as described below.

## Exact target and independence

Implementation target: `e76a3f9420300dec1011b8a549814769a0eb85db` (five files).
Integration consumers: `bc800d4e82feaf5e51316ce63ee0fc64f375638d`, as designated
by the lead. All five implementation files match those in the integration
commit byte-for-byte. The author's evidence-only follow-up is `6343eea91a`.

The author stream's older consumer baseline was not treated as the integrated
root interface. This review inspected the actual integrated
`ComposeSourceBridge`, `PredicateInheritedReady`, `PredicateSourceBridge` and
`PredicateEquations` consumers at `bc800d4e82`, plus the relevant lower library,
contract, wrapper, body-domain and return-domain definitions at the implementation
target. It did not review unrelated uncommitted sequence/proof-completion edits.

The reviewer did not author this Lean repair. The earlier two-line Ada condition
assertion repair was a separate bounded task and is not the subject of this
review. This review performed read-only source/evidence inspection; it launched
no proof runs and edited no source. Only this report was written and committed.
Selected role setting was GPT-6 Astra / Extra High; actual runtime model/effort
and token/cost measurements were unavailable. No subagents were spawned or CLI
memory updated. The live harness goal returned null.

## R1 disposition

1. **Body-reader meaning is a conclusion.**
   `FunctionDeclarationSourceBridge.lean:32` retains the lexical source link,
   raw `BodyLibraries.Calls` / `Definitions`, and actual body-callee identities.
   `source_reader_equations` at line 54 obtains `BodyNative.Equations` through
   `BodyLibraries.body_equations`. The latter, at
   `PredicateBodyLibraries.lean:139`, applies
   `BodyNative.equations_of_definitions` to the arbitrary native reader and its
   raw definitions. Predicate meaning is derived through helper links plus
   `Native.DefinitionEquations` and `Native.Contracts`; it is not supplied as a
   separate scanner-correctness assumption.

2. **The wrapper input is raw despite its existing type name.**
   `PredicateBodyLibraries.lean:69` supplies both explicit parameters to
   `Adapter.Wrappers.ModelEquations`: the actual `Initial_Flow` call and inherited
   `Take_Token` call. These equations describe typed expression evaluation with
   those callees. `wrapper_models` at line 97 first applies `normalize_tokens`,
   then `normalize_models` using the flow-library interpretation and native
   initial-flow contract. The default normalized wrapper equations that were
   formerly frontend premises are now the conclusion of this chain.

3. **Return imports use the linked condition/scalar readers.**
   `actualLinks` at `FunctionDeclarationSourceBridge.lean:42` links the imported
   calls to the same raw predicate bundle and inherited helpers.
   `source_actual_meaning` at line 64 derives `ImportsMeaning` through
   `FunctionCallNative.imports_meaning`, which derives condition correctness from
   definitions/contracts and scalar correctness from interpreted helper calls.
   `actualLink` remains the direct identity of the declaration's `Actual_After`
   callee. The derived meaning is used by `source_return_imports`; it is no
   longer a field of `InterpretedSource`.

4. **The construction does not require its own function-declaration law.**
   `BodyLibraries` accepts `RawHelperEquations`, whose separate completed
   `HelperEquations` extension contains the function-declaration law.
   `InheritedEquations` adds the already separate Boolean-declaration law,
   not function-declaration correctness. Independent traversal of the new
   module's local import graph found no `PredicateOuterModel`,
   `PredicateInheritedReady`, `PredicateEquations`, `ComposeSourceBridge` or
   `FunctionDeclarationSourceBridge` dependency. The completed outer bundle is
   consumed only downstream by the `PredicateEquations` adapter.

5. **The model witness and root consumer exercise this construction.**
   `FunctionDeclarationModelSource.model_interpreted` supplies raw library
   definitions, lexical interpretation and actual-import links. It no longer
   fills `readerSource` or `actualMeaning` directly with normalized model laws.
   In the integrated consumer, `ComposeSourceBridge` retains direct identities
   for the inherited helper bundle, declaration callee, metadata lookup and
   formal visibility; it derives `functionDeclaration` through
   `interpreted_native_declaration`. `PredicateInheritedReady` constructs the
   lower inherited bundle from the raw projection and Boolean-declaration law
   before calling the repaired model constructor. No new circular hypothesis
   was found on this path.

The factoring preserves the native text/context/scan/catalogue domains in the
body definitions and the complete `ReadDomain`/`ActualDomain` return-reader
interfaces. `BodyLinks` still identifies `Context_Of`, `Body_Of` and `Body_Tail`.
`ExactDomain` and the `StateInput.ofNative` adapter are unchanged; no new
reachability, declaration-history or function-only input restriction was added.
Out-of-domain model values remain the existing formal totalization, with
executed-call legality still requiring native validation. The fifth file's
`Compose.Expressions` qualification and final reflexive proof step do not change
those definitions or domains.

## Validation inspected and remaining work

The retained [focused evidence packet](../evidence/scalar-functions-20261107/focused/20261107T230226-02ff494be2c6/README.md)
records successful Linux x86-64 managed run `20261107T230226-02ff494be2c6` for
`PredicateBodyLibraries`, `FunctionDeclarationSourceBridge` and
`FunctionDeclarationModelSource`. Its log records 351 completed jobs and a fresh
49,907-declaration audit with only `propext`, `Classical.choice` and `Quot.sound`.
Actual runner settings were four Lake workers and 22 threads per Lean process.
This was incremental validation, not a clean rebuild or independent kernel
replay. The recorded five-file hashes match the reviewed commit.

`PredicateEquations` is absent from that run's audited module inventory. Its
adapter was inspected here but was not compiled by that focused evidence.
The lead still needs the downstream integrated check, final authoritative-source
correspondence, complete axiom/module-coverage audit, and matching complete native
evidence. This bounded review does not claim those checks passed, close #298 or
#340, or establish language support by itself.

## Reviewed implementation hashes

SHA-256; paths are under `proof/Silver/`.

| File | SHA-256 |
| --- | --- |
| PredicateBodyLibraries.lean | `a2b167e6d15a20766e746ac469263194694f02aae572b692b95a9812645d8325` |
| PredicateEquations.lean | `acb2f4402f52bc3036cd4db9bc5d0de9691e400ca06670dc599749b21d105dfb` |
| FunctionDeclarationSourceBridge.lean | `d33cf2c4b7f0d37a813eacb59a3372fde77c57354c699dad2879c611394c9f45` |
| FunctionDeclarationModelSource.lean | `e3626d279d6d62b00f082b55be63c656dbd175e0b8f1291ae42415e7206e72e7` |
| PredicateFunctionCallLibraries.lean | `0ee827b6d1c7752b893d3cb58f7202929350c95aa73edabd8bf5aa0fd9ed7b71` |
