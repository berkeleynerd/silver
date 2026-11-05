# B4 independent policy review — 2026-11-05

**Result: PASS for the committed implementation and policy coherence.** No
concrete acceptance defect was found. One documentation attribution is
recommended below. The native proof checkpoint remains incomplete because one
required obligation timed out; this review does not discharge it.

- Implementation target: `fe74231e42c0ec686bb618d2dc71059ece5ca65b`, equivalent
  to worker `475f0aa13a439d45f47b9907ed541f181305c24d`. Reviewed
  `src/silver_library_reports.adb`, `.ads`, `scripts/check_evidence.py`,
  `tests/test_image_reports.py` and `tests/test_main_discovery.py` through
  committed sources.
- Documentation target: `a5ecdea358017284cd97b7ada58085361372c696`, especially
  `docs/for-loops-integers-image.md`, `docs/for-loops-report-capacity.md` and the
  interim response's native-proof diagnostic.
- Reviewer: `/root/assess_inherited_blockers`; selected GPT-6 Astra / Extra High.
  Runtime settings, token counts and cost were unavailable. Review interval:
  2026-11-05 10:50:46–10:54:19 UTC, 213 seconds to the report-finalization clock
  checkpoint.
- Scope: owner-authorized B4 repair; read-only independent implementation review.
  Only this report was written. No tests, builds, expensive checks, GitHub actions
  or additional agents were started. Current ghost-annotation experiments were
  explicitly excluded.

`Image_Message` enumerates exactly the three complete native strings, differing
only at `"Image"`, `"image"` and `"IMAGE"`. Both executable `Record_OK` and
bounded ghost `Record_Policy` call that helper. `Raw_Image_Message` enumerates
the same constants for `Raw_Record_Policy`. The two added
`Mixed_String_Congruence` calls cover the lower/upper alternatives alongside the
existing mixed-case message. The congruence premise still consists of byte/field
observations and entity identity; it does not assume policy acceptance.

Python uses tuple membership over the same three complete decoded messages.
A read-only extraction comparison of the committed Ada literals and Python
constant confirmed exact equality, three distinct alternatives, and 192 decoded
bytes for each. There is no case folding, prefix acceptance or arbitrary
attribute-name substitution in either policy.

The surrounding requirements are unchanged: application warning placement,
`imprecise-image`, warning severity, trivial producer state, `main.adb`, positive
integer positions, unknown status, empty proof tree, empty suppression text,
and absence of entity/justification fields. Advisory accounting remains
separate from discharged proof/flow checks. Main safety checks still require
the original proved rule classes, provenance and entity. The `.ads` index-check
addition corrects a comment about an already enforced class; it does not relax
acceptance. The array-initialization alternative retains its own exact rule and
message.

The tests exercise all three messages under all four application-policy forms,
preservation of a failed original safety-check rejection, malformed/missing/
duplicate/misplaced advisory fields, nearby message spellings, SARIF producer
classification and inherited array-advisory cases. The new Main test uses actual
lower/upper unit names, preserves both author and compiled source bytes, checks
the exact emitted warning, audits the report and verifies native output/status.

The capacity conclusion is sound: the replaced attribute name is five ASCII
bytes in every alternative, with identical JSON escaping and schema. No field,
warning-count bound, projected-report limit or source/operator allowance changed.
The existing 1024-byte warning charge therefore needs no enlargement for this
repair.

The dated producer correction at
`docs/for-loops-integers-image.md:106–108` should attribute its universal
unit-casing mapping to the retained external B4 review. The local retained
routes directly establish `main → image` and `MAIN → IMAGE`; the statement that
the other 14 admitted spellings produce `Image` comes from
[external B4](../docs/reviews/interim-review-0d30841795-20261105.md#b4-lower-case-main-with-integerimage-since-2026-10-16),
which cites `spark_util.adb:4847` and `par-ch6.adb:1301–1305`. Recommended wording:
“The external B4 review reports that the pinned producer spells …”. This is an
evidence-attribution clarification, not a counterexample to the mapping or an
implementation blocker. The finite policy and equal-length conclusion were
verified directly in this review.

Retained Linux x86-64 logs inspected under the common Git managed-run registry:

| Run | Actual evidence |
| --- | --- |
| `20261105T085752-50b007645cba` | Native build passed. |
| `20261105T085848-f125490fccc8` | Eleven report-policy methods passed, 4.612 s unittest time. |
| `20261105T090547-f17c9d1eccac` | Two Main-discovery methods passed, 45.842 s unittest time; seven full routes across both methods. |
| `20261105T090739-d879074d7877` | Required native checkpoint failed: retained diagnostic at `silver_library_reports.adb:4186` is the `Observe_Object_List(..., JSON_proof)` field-name precondition in `Mixed_Object`; provers reached their time limit. The task record reports 3,201/3,202 checks proved. |

The implementation diff whitespace check passed. The later repeated-lemma
attempt is also recorded as failed in the interim response. Neither the scoped
policy PASS nor the distant location of the timeout makes that obligation
optional. Complete native proof/audit and integrated assurance remain with the
lead; no success is claimed for the excluded annotation repair.

## Addendum: proposed ghost wrapper and attribution disposition

At the lead's subsequent request, the same reviewer inspected the frozen
`tmp/image-case-repair/src/silver_library_reports.adb` diff that adds
`Observe_Proof_List` and replaces the single `Mixed_Object` proof-list call.
Exact file SHA-256, checked before and after inspection:
`d4769797028160de4fa9598250e48a103699050654d0d071c4f200c7c2f1392e`.
Selected settings remain GPT-6 Astra / Extra High; runtime/token/cost evidence
remains unavailable. Addendum review interval: 2026-11-05 10:55:32–10:56:04 UTC,
32 seconds to the final clock checkpoint. No proof was run by this reviewer.

**Soundness inspection: PASS; native proof result pending.** The new procedure
is a `Ghost => Static`, `Global => null` specialization of
`Observe_Object_List` at `JSON_proof`. It preserves the original text-bound,
object-observation and entity-field preconditions and has exactly the original
postcondition with that fixed name, including the final `False` argument. Its
body invokes `Projection_Field_Names` and then the unchanged general helper.
The eliminated name-choice premise follows from the existing proved equality
`JSON_proof = Projection_Observations.Proof_Name`; both constants are `"proof"`.
This moves the fixed-name instantiation into a small proof context without
assuming its conclusion, weakening a contract, suppressing an obligation or
changing executable acceptance. Both the wrapper and its caller still require
native verification. The diff whitespace check passed.

The lead also applied the requested documentation attribution. The inspected
working copy of `docs/for-loops-integers-image.md` has SHA-256
`aa5dc3d9d616e1dada8588c269c0792aa703b1f6db719d4361d0b06ea099d833`;
it links the external B4 review for the complete mapping and labels the local
lower/upper routes as corroboration. That resolves the wording recommendation
for this inspected copy; it was not yet committed at inspection time.
