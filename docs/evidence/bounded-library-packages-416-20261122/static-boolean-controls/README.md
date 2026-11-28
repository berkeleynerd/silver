# Static Boolean literal fallthrough diagnostic

`Static_Boolean_Primary` has the complete `Valid_State` input domain, which
allows Boolean bindings with `Known = False`. With such a binding named `True`
or `False`, the old helper skipped its known-value branch and then recognized
the name as a predefined literal. The native Boolean atom reader still returns
the binding's end cursor, so that extra check did not prevent the fallthrough.
The exact evaluator correctly returns no value for an unknown binding.

The repair adds `Found = 0` to the literal branch. Known Boolean bindings still
supply their own value, including when that value differs from the literal's
spelling; unknown bindings cannot supply an exact elaboration value. This
retains the full helper domain and changes no contract. Normal nonlocal package
elaboration uses known bindings; local initializers use the separate dynamic
initializer checker and do not invoke this static evaluator.

Focused before/after controls are prepared in
`tmp/static-boolean-controls/`. Each snapshot copies the complete compiler
sources and adds only an exported wrapper and a test main. The production
helper body is preserved byte-for-byte and hashed. The controls distinguish
predefined literals, unknown bindings (both stored Boolean values), and known
bindings (both matching and opposing the literal spelling). These are finite
helper controls, not Silver application replacements or universal assurance.
**Execution and canonical complete-helper proof are pending.**

Required native focus coverage: changed `Static_Boolean_Primary` and its
`Static_Boolean_Factor` caller; the recursive `Static_Boolean_At` and
`Static_Boolean_Relation` contracts and `Package_Object_At` caller remain part of
the new-helper readiness inventory. `Read_Reference` and scalar lookup have
retained whole-unit evidence; Boolean lookup and lexical helper obligations
remain required under the Output_Profile coverage plan.
