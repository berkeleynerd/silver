# #298 native scalar-function admission review

No confirmed defect or concrete unresolved defect candidate found in this bounded static review. This is an independent review of the native admission code, not of the reviewer's Lean implementation, and is not a replacement for the pending complete native/source validation.

- Reviewed workspace: `/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-298`.
- Review started 2026-11-07T21:00:52Z at `4951979463b5199944bfd7b76e5e0e5acc1854f3`; final source-hash check 2026-11-07T21:03:33Z at `27233919f8c8af7883ae9024a69ea6b513361c9a`. Static inspection elapsed: 2m 41s. Reviewed Ada bytes remained unchanged across the integration change.
- Model/effort: existing GPT-6 Astra / Extra High selected by the bounded-task brief; live runtime settings are not independently exposed. Token/cost telemetry unavailable. No native, proof, build or test commands run; no implementation or GitHub changes.
- Governing scope: `language.md:465–557`, the Oracle's full-domain, exact-source and no-authored-contract guarantees, `tests/test_scalar_functions.py`, and `samples/rosetta_primality_by_trial_division.adb`. The known private `Function_Body_At` precondition repair `e56af1b1a2` was excluded as an already identified integration item.

## Reviewed behavior

- `Parameter_Step` and `Function_Type_At` enforce nonempty, single-name explicit-in formals, positional arity, visible Integer/subtype or Boolean marks, and source-local name collisions. `Append_Parameter` installs full Integer domains as immutable/nonstatic and Boolean formals as immutable. `Declaration_Count` puts formals outside the local declaration prefix; flow refinement and widening retain their entry facts.
- `Actuals_After` passes the same incoming `Facts` to every actual. `Call_Assignment_Result` checks result kind/mutability, fits the declared result range to the destination, replaces only that scalar read interval, and preserves other facts. Calls consume the complete RHS before the required semicolon.
- The closed function frame retains subtype metadata and predefined-name hiding while excluding outer value stores. Locals are parsed before formal installation, so initializers cannot read formals or captured values; the existing static/exact initializer checks remain active. Pure bodies reject output, Reject, String/Character/array statements and non-pure predicate syntax. Local and loop-binder lookups mask earlier callable names.
- Only successfully checked bodies with matching closing names append signatures. All calls during a definition use the earlier catalog; forward/self/mutual recursion have no accepted path. The return-only outer body stop does not admit nested/early returns.
- The source-wide work check runs before declaration/body scanning and does not reset at function boundaries. The formal pool and scalar/Boolean binding bounds are consistent with their shortest explicit source spellings; function slots exceed the possible number of complete declarations in 4,096 bytes. Existing expression bounds remain in the reused readers.
- Existing tests cover malformed formals/returns, arity/kinds, excluded call positions, full-domain unused-function safety, cross-actual refinement rejection, result abstraction, recursion, local captures/effects, formal immutability/loop guards, name hiding, dense storage and budgets. Native compile fixtures retain author source bytes and require every listed function's report coverage. The trial-division sample uses a declared full input domain and a divisor guard supplied by its loop bounds.

## Targeted coverage recommendations (not defect findings)

The function-specific test file does not explicitly exercise Main Boolean actuals containing String/Character comparisons, or predefined literal/type names hidden by earlier function declarations and then used in a later closed function frame. Add a few focused positive/negative fixtures when integrating the existing regression inventory. The reviewed paths retain the required caller context and hiding checks; this recommendation does not assert failure or require an additional broad rerun.

## Exact reviewed SHA-256

| Input | SHA-256 |
| --- | --- |
| `src/silver_output_profile.adb` | `117b2b03ec738aa5c2bc21e29565a1dca6e86f15614410925f75cab7a583c9ac` |
| `src/silver_function_bindings.ads` | `e43fb640c38c516e6a4d0ab4e28acab9c3f71a5638237cc8b4c6c387c6d01d4b` |
| `src/silver_function_bindings.adb` | `5bb7432136235c11a0845269bb1286439b579e30fc45e15b20bad66fe829882b` |
| `language.md` | `cc55b55f6317a1e814ef5991c1857b68b36e491469d469478cfe3d28a0b849bf` |
| `tests/test_scalar_functions.py` | `75b7671090cbce69ba2fbd0952b0f46f03079c2d3403911f3468a0d415047cae` |
| `samples/rosetta_primality_by_trial_division.adb` | `6e2d5263135fb3aa0c36554425303c3b87a375315207c37ee897c5ed71b457a4` |
