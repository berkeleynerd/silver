# Boolean admission and composition review

Read-only independent review for #291. Selected reviewer: GPT-6 Astra / Extra
High, explicitly selected by the lead's spawn controls; runtime confirmation and
token/cost measurements unavailable. Inspection interval: 2026-10-30
12:53:34–12:58:06 UTC (4m32s). No builds, proofs, tests, compiler invocations,
repository edits or GitHub changes were performed by the reviewer.

## Inputs and result

Reviewed `d8c65ba9543b5ea7bd75a520118a35b2b3aed2e1` against parent
`fa6b5e982cad5662b18f498e75cafbac9fb07cc9`. HEAD advanced to
`5ffdf80d060d65cf069e29082c8bed09de8eb330`; the reviewer confirmed the native
source, language, catalogue, tests, samples and Boolean records were unchanged.

No concrete native admission or Ada-semantics defect was found in this bounded
review. It does not establish complete assurance or close #293/#294. The review
covered name hiding, initializer masks, eager/short-circuit safety, stored flags,
initialization versus body ranges, loop composition, Boolean grouping and the
xor operand scanner. The consequential paths agree with the documented rules:

- `silver_output_profile.adb:2506` resolves binding kinds before predefined
  literals, applies the initializer mask, and gives loop scalar bindings
  precedence over Boolean names. Declaration type visibility and masking are
  enforced at lines 3600–3615.
- Eager operands use incoming flow at lines 3392–3395 and their outcomes restore
  it at lines 3462–3466. Boolean equality independently evaluates its factors and
  discards derived facts at lines 3093–3109.
- Stored Boolean reads preserve incoming facts at lines 2972–2975. Assignment
  changes no scalar or input facts at lines 3673–3677, so stored predicates
  cannot revive stale relations.
- Initializers use exact earlier scalar values and array components at lines
  3610–3615. Body context resets scalar interpretation at lines 1888–1898. Loop
  contexts preserve Boolean metadata while appending scoped Integer bindings
  at lines 4118–4126.
- Xor checks cover both complete operand spans at lines 3339–3341 and 3403–3404.
  The scanner at lines 2739–2773 handles comments, doubled quotes and identifier
  boundaries consistently with the restriction. Equality and grouping cannot
  hide nested xor from those scans.

Line references name the reviewed source, before the later constant-identity
native proof repair.

## Nonblocking coverage observations and lead disposition

The reviewer recommended direct Boolean operation-name hiding controls for
`Put`, `Put_Line` and `Reject`, both Integer-mark initializer hiding paths, and
one compiled accepted hiding/scope-restoration program. Existing hiding tests
used admission checks only. These were coverage opportunities, not demonstrated
admission defects or new required language restrictions.

The lead added the controls to `test_boolean_objects.py`: unqualified operations
are rejected despite use visibility, qualified operations remain admitted, the
Boolean objects remain readable/writable, the two Image initializer paths are
rejected, and a combined compile/run fixture checks loop-name restoration and
qualified output. Validation of these additions remains pending the final
native binary and regression checkpoint. This response is separate from the
reviewer's no-defect conclusion.
