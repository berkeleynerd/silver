# Named-body candidate compiled; wrapper rewrite failure retained

Run `20261108T032945-867186df7c99` used governed snapshot `f00205b5f8`,
eight Lake workers and 22 process threads. It finished with failure at
2026-11-08 04:35:49 UTC after 3,962.136 seconds, including a 3,909.089-second
build. The retained log's build start at 03:30:40 matches the managed event.

`PredicateSourceRequirements`, `ComposeSourceBridge`, `PredicateInheritedReady`
and `PredicateOuterModel` compiled. `PredicateBodySourceCandidate` compiled in
3,834 seconds, including all named body/header/declaration checks and the
required `basic_body`, `loop_body` and `scan_step` extraction comparisons.
The successful object is retained for reuse. The run still failed, so this
record does not claim a focused axiom audit or complete source assurance.

The sole failure is `PredicateEquations.lean:92`: the existing
`adapter_interpreted` rewrite was instantiated with
`calls.bodyCalls.bodyWrappers.bodyOf`, while the goal names
`calls.bodyWrappers.bodyOf`. `Calls.bodyCalls` copies that exact field.
The prepared repair explicitly gives the existing `definitions.wrappers`
its direct `Adapter.Wrappers.Refinement calls.bodyWrapperModels calls.bodyWrappers`
type. It changes no premise, native/model definition, theorem statement or domain.

The [bounded independent review](../../../../reviews/review-scalar-functions-delivery-20261108.md#supplemental-static-review--body-candidates-and-wrapper-projection)
found no material defect in this exact annotation, patch SHA-256
`e17b7aa08e94b4f7cdd19343da042e300bf75123caa045366aac8e7dba9f8c44`.
It was held in scratch until this run exited. Its actual compilation is the
next focused check, followed by the complete Lean/source/module/axiom audit.
The native continuation and full regression suite remain independent pending
requirements; neither is replaced by this source-candidate result.
