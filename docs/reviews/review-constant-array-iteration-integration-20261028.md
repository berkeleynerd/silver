# Constant Integer-array iteration integration review — 2026-10-28

Interim verdict: no native admission or semantic integration defect found. One low-severity catalogue/specification consistency finding (R1, #267) was repaired during this review. The typed bridge's final proof and complete validation checkpoint remain pending; this report does not describe the feature as supported.

## Scope and inputs

Owner-authorized #264, stacked PR #266. Reviewed integration `7c18c6a02fbf9d222fd801be31f44ccada20edd5` against parent `0a85336c83`, principally `src/silver_output_profile.adb`, specification/catalogue changes, new tests/sample, capacity account and changed source pins. Native scanner SHA-256: `09858656aa96cdff7cc6f1ebc6683ce70885840e94df9706420b4c4e45ed6abc` (confirmed). Read `AGENTS.md`, Oracle, capability record and relevant assurance, trusted-boundary and validation requirements.

Reused the positive independent core/source-model review in `docs/reviews/review-constant-array-iteration-core-20261028.md`, covering core `73a40b56e5` and source-model `b7649bafed`; those arguments were not reviewed again. Reused the bounded producer-source review recorded in `docs/constant-array-iteration-report-capacity.md`; checked its integration premises and revised formula without rerunning its probes or duplicating producer-source inspection.

Also reviewed frozen typed-bridge definitions in `tmp/constant-array-native` over `995e71879e9669d4d719f86da3573bccb7a49a35`: `PredicateLoopNative`, `PredicateLoopImports`, `PredicateLoopHelpers`, and `PredicateLoopSizing`. The changing `eval_equation` tactic proof was intentionally excluded until its final commit. Exact interim hashes:

| Input | SHA-256 |
| --- | --- |
| `PredicateLoopNative.lean`, prefix before `theorem eval_equation` | `c8e491bf82b2d711e7d7b008ad384d2153ddf63a824d139b7caf4d5db982e6fc` |
| `PredicateLoopImports.lean` | `52971100fbbfaf6ad446722c4bcd26cca9e95eaecc05a41534bb35c095a481c8` |
| `PredicateLoopHelpers.lean` | `66d5c07ab69ab67c30ea38abc58641e9f64ceb82d454f800530266a3eec1be76` |
| `PredicateLoopSizing.lean` | `1a8837141512eec98a50bb22cea4581ff6ce2bd1a3616e29f69bf5e32fb2c4b2` |
| Updated guarded-singleton test file | `deb766a45a461cc9fcaf114193e44782cf6ad8ba0b7f44c856291fb1f1eae953` |

Selected reviewer configuration: GPT-6 Astra / Extra High. Runtime confirmation, token and cost measurements unavailable. Review started 11:02:34 UTC. Read-only inspection, including token-delta extraction; no Lean, native, build or test run, repository changes, GitHub mutations or additional agents.

## Findings

**R1 — Low, catalogue/specification consistency, repaired.** Existing `integer_expression.conditions.operand_kinds` omitted scoped elements and `scalar_guard_refinement.conditions.target` listed only mutable objects and indexes, contradicting the new iteration entry and native behavior. Related hiding, staticness and immutable-binding summaries also omitted elements. The lead recorded #267 and updated `catalogue/silver.json`, its embedded Ada emitter and `language.md` together. Reviewed repair bytes include `scoped_for_element`, bare element refinement targets, singleton-element nonstaticness and enclosing-element preservation. No scanner change was required. Byte-parity/build/audit validation remains the lead's checkpoint work.

Reviewed repair hashes: catalogue `52064c3ce8c53b9f972a520f3fceb6eaba1a1f454e2d2b6d8ac9a9540d8fa2f5`; emitter `7a6db9d3c8bebf914f79cbf2d375a1b7b0de797cf24a9038eeaf68ca140a3191`; language `79f4f6fd32729eb6c135380bea71c94f231cc6acef56da1d961a8e3a796f4cfe`.

## Critical integration checks

- Native `Loop_Body` resolves a bare existing array through `Array_Target` before extending scope; active scalar bindings hide arrays. It rejects mutable iterables and the element's own spelling in its iterator specification. Closing syntax rejects slices, expressions, filters and subtype indications. The same name restrictions and body reader retain existing nesting, operation/type hiding, assignments, output and argument-shell Reject.
- The appended binding has Full declared/current bounds, `Static = False` and `Mutable = False`. `Reading_Names` changes only current bounds; a guard refining an element to a singleton cannot turn it into an Ada-static threshold. The added negative regression `if E=1 then if N=E then B(N):=0` specifically distinguishes that property. Direct element assignment fails the existing mutability check.
- Mutable scalar facts are widened on entry and remain widened on exit. Outer immutable/index/element facts retain their entry bounds. Full is nonempty and admitted arrays are nonempty, so the body path is retained while the scoped binding disappears. Reject remains returning/sticky rather than eliminating its branch; no scalar contradiction prunes independent String/input paths. These native transfers agree with the previously reviewed universal composition argument.
- Actual-component semantics come from compiling/proving the unchanged author source and the inspected frontend's component-renaming expansion, together with the reviewed recursive component-preservation and source-derived binder-separation theorems. The implementation adds no snapshot or rewritten author program.
- The typed command/render definitions reproduce the new Ada `of` branch, local array lookup, immutable Full binding and common body/exit flow. New imports are linked to existing checked lexical equality and `ArrayBodyNative.linked_target`, rather than assuming scanner/model equality. The `of` token and Full interval are included in the import contract. The unchanged `eval_equation` conclusion has only the existing count premise; the new array case introduces no program-author assumption.
- Both changed source pins carry exactly the same semantic delta: the `of` branch and relocation of the common progress guard after the two headers. `ReviewedOutputShape.outputImplementation` grows from 36,435 to 36,617 tokens; `PredicateLoopCandidate` from 962 to 1,144. The rendered-tree/source-candidate and generated byte-certificate checks must still complete; updating these pins alone is not correspondence evidence.
- The producer account retains actual-component renaming, one-dimensional counted-range lowering, single executable body traversal and no new report class. The conservative `24*L + 8*W <= S` warning charge and separate element-reference/renaming index charges yield 31,269,376 bytes within 32 MiB. The regression formula matches the account. This reuses the recorded producer inspection, not sample-based universal inference.

## Remaining completion evidence

Final typed-bridge commit and proof result; complete Lean/module/axiom/source-correspondence checkpoint, including generated certificate; complete native audit/build/regression coverage on final inputs, including the catalogue repair; final Rosetta/capability-status reconciliation. These are assigned delivery obligations, not additional review-infrastructure requests. Final inputs and evidence can be appended to this report without repeating established core or producer reviews.
