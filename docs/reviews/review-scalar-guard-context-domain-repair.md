# Independent review: guard context-domain repair, 2026-10-26

No material findings in the exact five-file repair. Static review supports closing the identified mathematical domain gap, subject to the separately required kernel checks, affected-consumer validation, axiom audit, and final source-cohort checks. This is not a whole-feature assurance verdict or a claim of successful proof execution.

Selected reviewer: GPT-6 Astra, Extra High, confirmed by the root's explicit spawn selection. Runtime model/effort are not independently exposed. Review interval measured with the session UTC clock: 2026-10-26 05:27:00–05:29:34 (154 seconds); report writing follows that interval. Token/cost measurements are unavailable. No Lean, GNATprove, managed runner, or project/GitHub mutation was performed; only this scratch report was written.

## Exact inputs

Candidate files were read from `tmp/scalar-guard-flow-source-bridge/`, using its `tmp/context-domain-repair-manifest.json`. Baseline: `e2b96b884c205420c369e2369ef4f0bb38d85d84`. All five baseline and candidate SHA256 values were independently recomputed and matched the manifest. Canonical consumer context was read from `tmp/scalar-guard-refinement/` at `938f09d68ff5aa85dd5397b49cdd85008df24ea8`; tracked files were clean. The change from the baseline to that canonical commit is documentation only.

All paths in this table are under `proof/Silver/`:

| File | Baseline SHA256 | Candidate SHA256 |
| --- | --- | --- |
| PredicateFlowInvariant.lean | `fea27a59fcf60b3aaffa1eb3c49b5a96a2c682f30fad25cc888ac5644181be6c` | `20703108ffc001070f35948c80718d30165b5ce242866eecfc020f0ba256b734` |
| PredicateOuterReadiness.lean | `eaa03d1672d2d261bcc1993edbbcdf342a9b912da08ad32458830e34e6f248a8` | `0584b76896a17ef3663cc0de06f82d8285eafd3772a6a0e27f596c5eda900c14` |
| PredicateHeaderFlow.lean | `32ebdc019174e03375b8b8ed74e53ba8ba0d9b2fdc18021a85d0843150bb35a9` | `c62c39f567499a22b27455cfd1775f990624b74bed250b2b0c863eebd87e48cf` |
| PredicateBodyMeaning.lean | `ef6def1cfeb2bf985ed88122b861379479da1ebe58fbb8da95ae4c3b709533e1` | `c5931aaca27a1a3ee596aca1ce3bdbfd25414c99c1a0d8cb474fc75c74abcf5f` |
| PredicateLoopFlowValidity.lean | `8ef9001795e79d38709505c728aff65ad32126e0ed91b187c8942f10146d4345` | `3e844f99ea6e9a906fe8da1ca2bc32653226cfdca4d2ffe6c476587e38f5eaba` |

Native comparison input: `tmp/scalar-guards-native-author/src/silver_output_profile.adb`, independently confirmed SHA256 `81481d9f9352edd5ae27aafb83064a91543b46cd4d7871c12a333f67dad6841d`. Relevant definitions: `Valid_Mutable_Bounds` at line 159, `Valid_Declaration_Values` at 165, `Context_Of` at 1140, and `Valid_Context` at 1213. The earlier finding is canonical `docs/reviews/review-scalar-guard-context-domain-e2b96b884c.md`.

Governing inputs: AGENTS.md, oracle.md, development.md review bookkeeping, and the applicable assurance/trusted-boundary source-interpretation discussion. Consumer inspection included ScalarExpressionEnvironment, PredicateNativeState, PredicateGrammar, PredicateAdapter, PredicateBodyCorrespondence, PredicateLoopImports, PredicateScalarBodyHelpers, PredicateNativeSourceBridge, and PredicateSourceBridge at the canonical commit. Unrelated pending files in the author's checkout were not treated as integration inputs.

## Assessment

1. **Exact mutable clause and both directions.** `ValidMutableBounds` quantifies precisely over active indexes `1 .. names.length`, guarded by `mutable = true`, and supplies nonemptiness and both declared-bound containment inequalities. `BaseReady.mutable_bounds` derives the inequalities from the existing `BodyReady` equality; it derives nonemptiness from the new field, without requiring a flow witness. Conversely, native `Valid_Mutable_Bounds` directly supplies that field. Combined with the unchanged body equality, declaration-count bound and declaration-prefix nonemptiness, `baseReady_iff_native` matches the scalar clauses of `Valid_Context` under the existing active-array/list interpretation. No clause is justified by assuming the theorem's desired conclusion.

2. **Header coverage remains derived.** `HeaderReady.baseReady` uses the existing checked nonempty elaboration interval and containment to show the widened declared subtype is nonempty. `prefix_baseReady` retains its elaboration-value witness, then uses equality of the declaration count and environment length to cover every active mutable cell. Neither public theorem gains a premise. Thus the proof-domain strengthening is supplied by admitted declarations rather than imposed as a new language-membership restriction.

3. **Empty immutable indexes and mutable suffixes remain admitted.** Both append constructors preserve each old mutable binding and discharge the fresh case because its mutable flag is false. Neither demands nonempty loop bounds. The declaration count stays unchanged, so the new index is outside the declaration prefix. These arguments iterate through nested loops. Arbitrary native contexts may still contain mutable suffix bindings when their bounds are nonempty; there is no suffix-immutability restriction, and no added staticness restriction.

4. **Affected endpoints retain their obligations.** The new field is appended after the old three fields; the `Native.ValidContext` conjunction shape and existing projections are unchanged. The four existing direct BaseReady constructors are repaired. `PredicateAdapter.context_valid` obtains the stronger domain through `HeaderReady.baseReady`; the grammar uses `prefix_baseReady`; recursive native loop correspondence uses the repaired append theorem. Context-only target/length interfaces thereby inherit the missing nonempty-mutable premise without inventing a `ValidFlow` premise. Existing flow-preservation consumers continue to receive the stronger BaseReady argument. Static inspection found no omitted constructor or changed public theorem premise.

5. **Source interpretation stays explicit.** The five-file diff changes no native behavior, source pins, source checks, or frontend interpretation interfaces. `baseReady_iff_native` establishes equivalence of the formal scalar clauses; it is not itself an interpretation of arbitrary Ada source. The public source/correspondence endpoints retain their explicit interpretation and executable-refinement premises. Exact final `Valid_State`, `Valid_Context`, `Valid_Flow`, `Valid_Body`, and `Valid_Condition` source checks remain separate required evidence; this report does not attest to those checks or hide them inside the domain lemma.

Disposition: no repair requested from this bounded static review. Root-owned focused validation and final correspondence evidence remain required before integration/completion claims.
