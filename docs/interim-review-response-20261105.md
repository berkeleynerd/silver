# Interim external review response — 2026-11-05

Status: implementation and focused validation in progress. PR #307 is draft,
open and unmerged. The owner authorized this response in PR #308, merged as
`200e91a892b852e823494f2eaac7cde48602b123`. The exact
[interim external report](reviews/interim-review-0d30841795-20261105.md)
reviews `0d308417955545a225378ed6e31f83733b40e4ce`; its remaining review is
unfinished. Prior completion claims are superseded by the reported counterexamples.

## Scope and disposition

| Finding | Tracking | Selected work |
| --- | --- | --- |
| B1 | [#309](https://github.com/berkeleynerd/silver/issues/309) | Restrict maximum slice endpoint inversion to signed-Integer maximum in wide arithmetic; retain ordinary null slices. |
| B2 | [#310](https://github.com/berkeleynerd/silver/issues/310) | Prototype a conservative source-context restriction with full-build controls, including constant-array-derived guards; settle it before the complete source checkpoint. No native `Ignore_Pragma` workaround. |
| B3 | [#311](https://github.com/berkeleynerd/silver/issues/311) | Exclude direct constant-array reads from counted-loop bounds, preserving snapshots, mutable-array bounds and constant-array iteration. |
| B4 | [#312](https://github.com/berkeleynerd/silver/issues/312) | Accept the three exact pinned Image advisory spellings throughout the native and Python policies, retaining every other check. |
| B5 | [#313](https://github.com/berkeleynerd/silver/issues/313) | Reject the identified empty-operand arithmetic forms that the pinned frontend folds into static failures; preserve mathematical and actual-source assurance. |
| Med-1 | [#314](https://github.com/berkeleynerd/silver/issues/314) | Qualify structural-check claims now. Remaining explicit tree guards stay a next-edit follow-up; current semantic/source review remains mandatory. |
| Med-2 | [#315](https://github.com/berkeleynerd/silver/issues/315) | Complete: isolated fixture/record repair merged through PR #321 (`805818a6cd`); both installed-Lean fixture methods pass without skips. Integrated on #307. |
| Low-1 / Low-5 | [#316](https://github.com/berkeleynerd/silver/issues/316) | Add discriminating slice boundary tests. Existing lower-endpoint tests support the literal historical wording; no separate Low-5 record error is asserted. |
| Low-2 | [#317](https://github.com/berkeleynerd/silver/issues/317) | Add uncertain-loop path and definite-boundary tests. |
| Low-3 | [#318](https://github.com/berkeleynerd/silver/issues/318) | Add short-circuit join and Boolean fact-disposal controls. |
| Low-4 | [#319](https://github.com/berkeleynerd/silver/issues/319) | Add kind/hiding, mutability and empty array-assignment controls. |
| Low-6 | [#320](https://github.com/berkeleynerd/silver/issues/320) | Correct remaining safety-class lists and the earlier #269 closure claim. |

The unnumbered B2/B4 wording findings accompany those repairs. The two
information observations require no new machinery. Unverified candidates in the
unfinished review are not treated as findings or clearance.

B1 violates native execution meaning, while B2–B5 reject admitted source later
in the pipeline. Their different symptoms do not change the requirement to
repair the current language's guarantee. The report's candidate patches and
private probe results are not complete validation of this response.

## Validation and resource basis

Preserve the original failing cases as rejection regressions whenever a rule
intentionally excludes them, with separate retained positive controls. The
external appendix adds 39 admission cases across five files and two methods;
it does not replace full-build regressions for the blockers.

Complete native proof/audit, matching build, Lean/source/module/axiom assurance,
regression coverage, resource observations where affected, and independent
integration review remain outstanding. Do not reuse old totals as results of
the repaired tree. Existing source and expression limits, proof/report settings,
and the prior `-gnatdM` correction remain in force.

The deleted tmp caches are unavailable. Fresh tool installations are bootstrapped
at their actual worktree paths. An older surviving root Lean build was copied
after capturing its 467 actual source inputs, two tool identities and 7,472
artifact files; destination bytes were rechecked. The
[seed record](evidence/interim-review-response-20261105/README.md) does not claim
that those sources match #307. Managed runners and Lake must revalidate and
rebuild changed dependencies; complete current source assurance is still required.

## Work rounds

| Round | Selected settings | Result and limits |
| --- | --- | --- |
| Assessment and authorization | Two GPT-6 Astra / Extra High bounded blocker assessments; GPT-6.1 Sol / Extra High lower-finding inventory; lead runtime setting unavailable | Source inspection supports the findings and identifies incomplete candidate dependencies. No execution was repeated in assessment. PR #308 retains authorization/report; issues #309–#320 track work. Token/cost metrics unavailable. |
| Initial implementation | GPT-6 Astra / Extra High for B1–B3; GPT-6.1 Sol / Extra High for B4 and B5; lead coordinates integration and records | Isolated implementation and focused validation underway. No complete repaired assurance or merge claim. |

## Focused implementation checkpoint

B5 is integrated as `0e6c00e539` from reviewed worker commit `db51e1829e`.
The [independent review](reviews/review-empty-loop-identities-db51e1829e.md)
found no concrete implementation defect. The
[handoff](evidence/interim-review-response-20261105/b5/B5-handoff.md) records
the pinned frontend identity argument, 198 rejection sources, retained native
execution control, 44 focused native checks and eight-module Lean audit.
The matching handwritten source pin and certificate have since been refreshed;
the integrated focused source check passed in `20261105T092234-74a1da901d7b`: 15 modules / 3,108 declarations, 375.467 s build and 13.875 s audit.
Complete combined assurance remains pending.

B4 is integrated as `fe74231e42` from `475f0aa13a`. Its build, eleven report
methods and two Main-discovery methods (seven complete native routes) pass.
The focused report-unit proof is still running. Exact `Image`, `image` and
`IMAGE` alternatives have equal lengths, preserving the existing capacity
argument. No other diagnostic or safety-check policy is relaxed.

B1/B2 native prototype `71911ad049` passes its targeted admission/build/output
controls and admits all 59 existing samples. The [independent native review](reviews/review-slice-native-71911ad049.md)
found no concrete blocker; matching Lean/source integration is underway; these focused results are not complete
assurance. B3 has a separate bounded implementation thread, keeping filtered
array metadata out of retained loop frames.

The earlier #269 completion claim has a dated correction linking the remaining
class-list work to #320. #315 has a completion comment and board status Done.
All other response items remain open; PR #307 remains draft.

The B1/B2 native prototype and B3 gate are integrated as `b9181a8a76` and
`4f3323450d`. The language/catalogue changes explicitly state their purpose and
retained alternatives. Combined build `20261105T093643-b607ae3babc0` passes.
Eight combined admission/catalogue/B5 native-control methods pass in
`20261105T093917-6adad5bc1721` (35.764 s); the nine appendix/catalogue methods
also passed in `20261105T093209-1f22046ff96c` (4.281 s) before this native
integration. Every run retains its actual input map; none is a final full-suite
claim. The slice helper native proofs passed in the isolated source worktree:
49 checks for `Guarded_At`, 24 for `Read_Counted_Bound`, and 34 for `Indexed_At`.
Matching Lean helper/loop integration remains in progress.
