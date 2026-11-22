# Named array type source correspondence review

Independent review for [#410](https://github.com/berkeleynerd/silver/issues/410),
2026-11-21. No material finding was identified in the bounded scope below.
This review does not establish the pending complete native and Lean checkpoint.

## Exact inputs and scope

- Implementation commits `c0901f893d0c34f4af49e09305bb2154ef2bae19` and
  `53bd4db9b01c53e4a6eecb3cf2e50cfe48d08b8a`: `ComposeArrayTypeNative`,
  `ComposeArrayTypeDenotations`, `ComposeArrayTypeEquations`,
  `ComposeArrayTypeSourceCandidate`, and their additions to `Expr`, rendering,
  evaluation, scope, precedence and `ComposeContracts`.
- The native `Array_Type_At` and `Array_Type_Declaration_At` helpers in
  `src/silver_output_profile.adb`, lines 1482–1558; complete file Git blob
  `ae934266954e5576ef2af16fcf96f59fe7768e3e`.
- Lead's stable, uncommitted authoritative-source transport: `ComposeSourceChecks`
  blob `7e24db47210ca9213143171c408a1e176bd7878d` and `ComposeSourceBridge`
  blob `cf55971217db86baa6aca0f228bf776ab672c825`. Both hashes were rechecked
  at review completion. Review of these files is limited to
  `actual_array_type_helpers`, `ArrayTypeHelperTranslation` and the
  `CheckedSource.arrayTypeHelpers` field and construction.

The governing Oracle requirements are full declared input domains, assurance
derived from actual source, and no substituted model equality or hidden premise
that bypasses implementation correspondence.

## Findings and disposition

`Array_Type_At` retains cursor failure, each String/scalar/array/Boolean/function/
procedure mask, `Formal_Hides`, and the final type lookup in native order. Both
active callable formal slices remain in the hiding check. The interpreted
equation uses full native state/table validity and valid cursors, including
zero. It does not require stored arrays, a closed frame, or a source-history
known-type premise.

The declaration tree matches native constants, helper calls, rejection guards
and field updates. Scalar bound readers receive the full array table with the
native defaults; purity is an explicit rejection guard. Static singleton bounds,
nonempty ordered bounds, type capacity and the widened element-count difference
are preserved. The resulting state appends the type entry, advances position and
updates the two Boolean and five operation hiding flags while retaining array
objects and values. Scope and precedence cover every new operand and binder.

The new denotations are definitional for arbitrary helper calls. Raw helper
equations assert evaluation of typed bodies, and the interpreted equations derive
parser-model equality from those bodies and the applicable full-domain callee
equations. `Name_Is` is used after `New_Name_Allowed` establishes name validity;
the rejection branch does not assume it. Unconditional body legality introduces
no extra parser equality or accepted-state premise.

Candidate checks bind complete native headers and rendered bodies through kernel
decisions. The reviewed transport rewrites authoritative output body tokens using
`Output.SourceBridge.actual_complete_shape.2.1` before applying the candidate
theorem, and supplies that result to `CheckedSource.arrayTypeHelpers`. This
transport was inspected but was not compiled as part of this review.

The adjacent array-object declaration renderer mismatch has a separate repair,
`5aa201e407` (lead import `ff90431be2`): qualified `array_bindings.type_count`
is rendered as three tokens. That change affects neither evaluation nor declared
domains; its caller/source validation remains part of integration. It was not a
mismatch in the two type-helper bodies reviewed here.

## Evidence and review settings

Retained Linux x86-64 managed success `20261121T150902-18295d6a4f42` checks
`Silver.ComposeArrayTypeEquations`, `Silver.ComposeArrayTypeSourceCandidate` and
`Silver.ComposeModelHelperEquations`, with a fresh 18,623-declaration audit. The
four-worker run completed at 15:09:33 UTC. Its successful source kernels were
reused, not rerun solely for review. Retained evidence is under
`.git/silver-runs/linux-x86_64/78cde64c3e47f2cb/runs/20261121T150902-18295d6a4f42/`.

Selected reviewer settings: GPT-6 Astra, Max, for independent critical
source-correspondence review. Runtime model/effort were not independently exposed.
The review ran approximately 15:12–15:20 UTC, overlapping callable trace
compilation; this interval is not isolated reviewer compute time. Token and cost
measurements are unavailable. No material rework was requested in the reviewed
scope; authoritative transport compilation and complete integrated assurance
remain outstanding.
