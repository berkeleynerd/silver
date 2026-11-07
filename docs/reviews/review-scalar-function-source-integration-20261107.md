# Scalar function source integration review — 2026-11-07

Bounded read-only review for owner-authorized #298. Selected GPT-6 Astra / Extra High; actual runtime model/effort and token/cost measurements are unavailable. Native host observed: Linux 7.0.14 x86_64. Live harness goal returned null. No builds, proofs, tests, GitHub writes, commits, staging, or CLI-memory updates were performed. This report is the only file written by this review.

The initial target was `5c63818aed78dd015468cebdd61e5a5b5840fbfa` plus seven lead-owned integration edits in `tmp/scalar-functions-298`. The lead committed those same bytes as `2603f6a800428d0da6250bb782ef231d421d2620` during review. All files in the fingerprint table below were compared byte-for-byte with that commit at 22:27 UTC and matched. Relevant AGENTS.md guidance, the function language section, capability record, and assurance source-correspondence policy were read. Native parser repairs and final authoritative source pins are explicitly pending work and are not findings here.

## Finding R1 — high: normalized function-body/return meanings are still frontend premises

`proof/Silver/FunctionDeclarationSourceBridge.lean:32` requires `readerSource : Predicate.BodyNative.Equations reader`, and line 41 requires `actualMeaning : Predicate.FunctionCallNative.ImportsMeaning actualImports`. These are consumed directly at lines 49–61. The root now accepts the complete bundle as a hypothesis at `ComposeSourceBridge.lean:100–106`, then uses it to derive the function declaration helper law at lines 203–207.

The distinction from the customary frontend interpretation premise is concrete:

- `PredicateBodyCorrespondence.lean:46–60` defines those body equations using **modelPrimitives**, including the mathematical basic statement and condition readers. A raw source interpretation instead evaluates the rendered tree with arbitrary linked callees, as `PredicateBodyHelpers.lean:149` does. The main bridge derives normalized equations from raw definitions and library links at `PredicateEquations.lean:107–148`.
- `PredicateFunctionCallHelpers.lean:74–77` makes `actualMeaning` assume full condition/scalar reader equality. In particular, Boolean return checking receives predicate-parser correctness as a premise. `PredicateFunctionCallLibraries.lean:18–40,70–76` already supplies the missing mechanism: direct `ImportsLinks`, condition definition equations/contracts, and `imports_meaning` derive that equality.
- The wrapper input at `FunctionDeclarationSourceBridge.lean:35` also uses the normalized default `Initial_Flow`/token callees. The source-to-normalized steps exist at `PredicateAdapterEnvironment.lean:166–188`; the new bundle does not retain their raw inputs or perform those steps.

Repository search found only the model constructor at `FunctionDeclarationModelSource.lean:83–113`, which supplies `BodyNative.model_equations`, normalized wrapper model equations, and `model_imports_meaning`. The inherited-ready instance at `PredicateInheritedReady.lean:250–261` calls that model constructor. No arbitrary-callee constructor closes these source links. `PredicateSourceBridge.InterpretedSource` carries the main `Implementation.Definitions` independently, with no link to the function bundle's body reader/return imports (`PredicateSourceBridge.lean:58–60`).

This does **not** identify a false Lean theorem, a contradiction, a vacuous domain, or an unsafe admitted Ada example. The conditional theorem and model inhabitant are meaningful. It identifies a missing derivation required before this bundle can be the claimed interpretation of the actual linked compiler source. The normalized scanner laws cannot become additional trusted frontend assumptions merely because the separate model inhabits them. Native proof success or refreshed source pins does not supply these Lean source links.

Smallest repair path:

1. Retain raw body/predicate/wrapper definition equations, verified native contracts and direct callee identities as the input to the function library construction. For the return reader, use `FunctionCallNative.ImportsLinks` plus predicate helper/definition/contract data and derive `actualMeaning` through `imports_meaning`. Preserve `actualLink` to the actual `Actual_After` callee.
2. Factor/reuse the lower helper derivations in `PredicateEquations.lean:103–148` with **RawHelperEquations**, then obtain the reader equations through `BodyNative.equations_of_definitions`. Normalize wrapper models through their existing token/flow library theorems. Reuse the same raw call bundle, or retain explicit identities to the actual function-body callees.
3. Construct the normalized `FunctionDeclarationNative.InterpretedSource` from those data and wire that constructor into the root interpretation. Update the model witness to exercise that constructor. Likely owned changes: `FunctionDeclarationSourceBridge.lean`, `FunctionDeclarationModelSource.lean`, `ComposeSourceBridge.lean`, `PredicateInheritedReady.lean`, and the lower factoring of `PredicateEquations.lean` / root `PredicateSourceBridge.lean`. A small lower library module can avoid an import cycle.

Do not construct the function declaration law by first requiring the full `HelperEquations` bundle: the existing `Implementation.body_equations` signature requires that bundle, which already contains `functionDeclaration`. Its lower derivation uses only the raw helper projection and can be factored without this circular dependency. Keep full native call domains; no strengthened reachability assumptions are needed for this repair.

## Checks with no separate finding

- The new lookup and formal-hiding laws are derived from metadata/visibility interpretations with explicit links (`ComposeSourceBridge.lean:170–192`); `FunctionImportMeaning` is then inhabited, rather than left as an unavailable antecedent. I found no vacuity in this step.
- `ExactDomain` identifies the inherited domain with `NativeValidState`; `StateInput.ofNative` supplies the native record bounds. The ready-state adapter at `PredicateInheritedReady.lean:255–258` does not narrow the native domain. The body metadata-growth premise is already established at the declaration caller; the separately tracked native/pin integration remains pending.
- The declaration termination measure now counts function entries, consistently with declaration admission/fuel. The scalar-type/legal-tree edits handle the added hiding tree without changing the theorem domains. No separate defect was found in these edits by inspection.
- `FunctionDeclarationsAt` retains every accepted function, including unused definitions, in source order. `Sequence.FunctionTokensAt` carries them to `PredicateGrammar.form_reading_valid` and `SourceMeaning`, which require `DefinitionsChecked []` and align final catalogue signatures with the decoded definitions.
- `ScalarFunctionComposition` constructs the executable environment by a prefix fold and proves every checked definition safe over fitting formal arguments, including unused functions. `Program.Valid` retains `DefinitionsChecked`; execution consumes the compiled environment. `PredicateChecks.Program.checks` and `PredicateComposition.Program.obligations` include all function-definition obligations, and `Current.all_obligations_discharge` / `PredicateCorrespondence.executable_main_correct` consume that chain. I found no missing function constructor at these endpoints.

These conclusions are static inspection, not a replacement for complete Lean/native validation or an axiom audit. The review did not independently replay the earlier helper/native audit, analyze every native parser branch, or certify exact source pins. It makes no support/completion/merge claim.

## Exact-byte fingerprints

SHA-256; paths are under the reviewed worktree. Other inspected committed support sections are identified by the target commit above.

| File under `proof/Silver/` | SHA-256 |
| --- | --- |
| ComposeSourceBridge.lean | `204633ed69b637d85454ac2995fe7933c30aedbab2c4f9f0c243eb3828ef299b` |
| PredicateInheritedReady.lean | `b522f5ce85f8808b4dab706f5294307c4d4d1a8ce55f9c94a6c7b667729b8ead` |
| ComposeEquations.lean | `951a3d04862bec1c54c1c00d1891c3f1d34facef6934704e95eac564698262f3` |
| ComposeModelLegal.lean | `7b2eae32de79aecdab7eaffdab965f71a400441cfb4865a1d04d0acd7a167f7c` |
| PredicateEquations.lean | `87f8e42fdf3540366604e2498cefd1b2ebb7d167a76740c1dd5627271738fff2` |
| ComposeCatalogueSourceCandidate.lean | `141aae7a6e2ea030f80c40a543bb418860601070832fa722d33b6b126bf5a416` |
| PredicateAdapterSourceCandidate.lean | `330baf3fa131a86036e203da99c5c5fc687f50ebe9cb7bedee09e885f332a4e2` |
| FunctionDeclarationSourceBridge.lean | `be003788baef5226b7dc8d88f752e66c2d57658b2f8923370155f4f185601b39` |
| FunctionDeclarationModelSource.lean | `38ab532f0063072da24a6a0847f8c8fd986a6f1776ebaeb446f808b700686224` |
| PredicateBodyCorrespondence.lean | `ddd61ffb78bb7cb44d5118fb6e9ee3b55cbc3ffe24fafff3201a2465d27cd190` |
| PredicateBodyHelpers.lean | `80ffc51a081a39bd341cd7457e03587268d5e2b8f392f896f652c03f30a72573` |
| PredicateFunctionCallHelpers.lean | `5932589b650ea18c4eeb01df07dba1e2cabe560cc17f1666a6c7b955bfdc2fdb` |
| PredicateFunctionCallLibraries.lean | `3942fdf204b4da0fb9bd0baa6a90f5fee4a2b367e1e19a074c9ba84aed42ddc6` |
| PredicateAdapterEnvironment.lean | `aee8d6b3784e5d278a1596f42625190d0705f154e322545df2998f35471a75a6` |
| PredicateGrammar.lean | `2a1cb532589e4231c59769d1c7bd4d4a9ec713147c7964a2df1c5eb175c752a6` |
| FunctionDeclarationsTrace.lean | `70d442e6bf3bdef18a76b0272ac830e4c3689de72a96e61b3a191f85fc7b601d` |
| SequenceFunctionTrace.lean | `cd67f6486930d984ca3cb5d95c6cf9691a3cbc7d4c7cfa2f9035cf77d65ac1df` |
| ScalarFunctionComposition.lean | `6dc541536684ee0c4efa479555d52d12ea11f039c45640b12d569187bdd37b82` |
| PredicateComposition.lean | `ed551a54c66f07cce02f56fe7ebe26ad46282d869f56939f882a5507d3f8b5f4` |
| PredicateChecks.lean | `469921d40f0e2b5b4dbd683522e084f046a12cd531ee5ac11e09dd35a317b509` |
| PredicateCorrespondence.lean | `552ee1f4814de74cf11816391b1bea978902bc7f8cc90c0f9c0e063ce64c3256` |
| PredicateSourceBridge.lean | `a4e004c2bab2ec9cf799dde9711c6def19f530d993df50bb18fec73ddd77124c` |
