# Bounded mutable integers implementation review

Independent source review for [#70](https://github.com/berkeleynerd/silver/issues/70),
Linux x86_64, 2026-10-17. **Interim: final source integration and validation remain pending.**

## Scope and target

The initial snapshot starts at implementation commit
`52571901fe6791c9220ee7c39061f4ac1834be6e`, with the changes from
`9a337d0c39` (environment projection), `b89c36a0cc` (declaration denotations),
`edd9187247` (capacity and probe evidence), and `1023037fcb` (Rosetta).
The review worktree is `tmp/bounded-mutable-integers-review`, branch
`review/bounded-mutable-integers`, at `1a24088ec8` before copied working changes.

The snapshot also includes the root checkout's then-current tracked changes to
`catalogue/silver.json`, `language.md`, `src/silver_catalogue.adb`,
`docs/assurance.md`, `docs/trusted-boundary.md`, `docs/bounded-mutable-integers.md`,
`proof/Silver/PredicateSourceCandidate.lean`,
`proof/Silver/PredicateSourceRequirements.lean`, `samples/manifest.json`,
`tests/test_silver.py`, and the new `samples/find_square_difference.adb`.
Its 11,816 file identities are retained in the review worktree's
`tmp/review-target-initial.json`, SHA-256
`f7fcbe647ff8830225cf1a01113ffc75cf7e708098778a548b734c2caffab955`.
This is a working snapshot, not a claim that the named base commit alone reproduces it.

The owner-authorized [scope](../bounded-mutable-integers.md) governs the review.
Review covered declaration/staticness/snapshot rules, assignment admission,
whole-range body abstraction, loop stores and index scope, Image composition,
changed producer/report-capacity routes, and language/catalogue/sample/Rosetta
consistency. The pending helper equations and integrated validation are tracked
separately below.

## Findings

### L1 — Low: constrained constants missing from token inventory (#74)

At the initial target, [catalogue/silver.json:1023](../../catalogue/silver.json#L1023)
and [src/silver_catalogue.adb:1144](../../src/silver_catalogue.adb#L1144)
list unconstrained constants, unconstrained variables and constrained variables.
No token skeleton represents a constrained constant such as
`A:constant Integer range 0..99:=7;`. The catalogue's construct conditions,
language specification, native implementation and existing admission regression
all admit that form. This is an incomplete catalogue syntax inventory.

The implementation owner independently confirmed the omission. Commit
`b0f0af3522` adds `integer_constrained_constant_declaration_tokens` to both
catalogue sources. Delta source review confirms the repair. The implementation owner subsequently
reported the native build and exact catalogue export comparison passed; final
validation evidence remains separately recorded. No runtime change is required. Tracking: [#74](https://github.com/berkeleynerd/silver/issues/74).

### L2 — Low: sample audit misses scalar assignment policy (#75)

[tests/test_samples.py:100](../../tests/test_samples.py#L100) selects assignment
policy only when `string_assignment` is in the sample capabilities. The new
Find square difference sample records `integer_assignment`, so its independent
audit selects `static`, although native admission selects `Assigned_Output`
([src/silver.adb:86](../../src/silver.adb#L86)). The audit policies are observably
different: `unused assignment` is accepted only for `assigned`/`selected`
([scripts/check_evidence.py:347](../../scripts/check_evidence.py#L347),
[line 479](../../scripts/check_evidence.py#L479)). A scalar sample with an
unused overwritten assignment can therefore be accepted and compiled by Silver
but fail this audit. The current driver may pass without exposing the mismatch.

Commit `b0f0af3522` selects assignment policy when either `string_assignment`
or `integer_assignment` is present. Delta source review confirms the repair;
manifest validation remains part of the pending integrated test run. Native
production policy already sets the assignment flag for scalar writes. The
implementation owner raised the candidate; this review independently confirmed
the policy difference. Tracking: [#75](https://github.com/berkeleynerd/silver/issues/75).

## Reviewed conclusions

No runtime or universal-model correctness defect was found in the reviewed
snapshot. The implementation separates exact declaration values from Ada
staticness and mutability. Constants copied from mutable objects remain snapshots
without becoming legal constraint endpoints. Body contexts widen only mutable
bindings to their declared ranges; assignments check every RHS interval against
the target and preserve input-length facts without retaining mutable Image
value equalities.

The execution model threads both stores through statements and iterations,
captures loop bounds at entry, and restores only the scoped index. The native
compiler preserves the author's Ada source, so ordinary Ada execution supplies
the corresponding runtime behavior. String/Image initializers use exact
elaboration values; body Image uses the current scalar store and declared
intervals. The two retained composition probes exercise snapshots and frozen
bounds, and the proof witnesses exercise scope restoration; these examples do
not replace the universal argument.

The changed producer routes support the stated 15,292,416-byte retained Main
envelope under the documented inherited producer/tool premises. Source inspection
confirmed the explicit static subtype route, suppression of extra type VC/metadata
entities, scalar assignment conversion path, mutually exclusive flow advisories,
and the GNATprove nonstatic String subtype expansion guard used for Image.
The existing assignment bucket counts scalar and String assignments together.
The new 13-byte scalar declaration minimum is included. The capacity record
separates native observations, source reasoning and pending full assurance.

All 17 cited upstream file hashes, three retained source/report pairs and seven
retained log hashes matched their records: 30 identities checked. The result is
retained in `tmp/review-retained-evidence-check.json` in the review worktree,
SHA-256 `eb80214833e8e937a71cac7d0d5a498944cd00afedaf00993283edab2d99a5b1`.
The Rosetta mapping uses the narrow bounded-mutable identifier and leaves broad
integer/subtype/loop/Image surface unsupported.

## Remaining delivery checks

The snapshot intentionally precedes the completed declaration/basic-helper
source equations and complete integrated source bridge. These are required
implementation work already in progress, not newly discovered review defects.
At this review point the complete native audit, lexical certificate and final
integrated validation were being coordinated by the implementation owner.
No completed-delivery verdict is given here until their actual inputs and the
last source changes have been reviewed.

This review ran no builds, application compiles, prover runs, clean/replay checks,
or repeated test suites. It used source inspection, retained artifact identity
checks and Git whitespace checking. No root checkout files, issues or board entries
were modified. Final repair and integration disposition will be appended here.

## First integration delta

Reviewed `700b39de58` and `b0f0af3522`, integrated into the review lane as
`6d4be52dd8` and `d4b267a536`. Compared with the initial snapshot, only the two
catalogue sources, `tests/test_samples.py`, and three scalar-source candidate
files changed. Earlier uncommitted documentation remained at its initial bytes.
The updated target manifest is `tmp/review-target-delta1.json`, SHA-256
`ddf6343df4474c5f1c1e1696414f244289f89ea7cbc2b3e7065457ae43ff76c8`.

Both findings are repaired at source level as recorded above. The scalar-target
extractor correctly handles its qualified `Scalar_Expressions.Binding_Count`
return type. The six independent requirements check both typed bodies and both
specification/implementation headers; the complete predicate candidate imports
this result. This change retains exact header checking and typed body denotation.
The retained focused evidence for run `20261017T013421-bcdee034fa2a` reports a
successful build and fresh axiom audit of `Silver.PredicateScalarBodyCandidate`.
It remains a focused check, not the complete source-correspondence result.
No additional findings arose from this delta.

Reviewed source-contract delta `12fd4d87dd` (review-lane `0924646f24`). It connects
the typed `Scalar_Constraint_At` expression, result record and native contract to
the authoritative token stream, updates the declaration expression, and includes
`range` in the finite word-token mapping. No new defect was found. Its native
lexical certificate dependency and the remaining helper equations still await
the integrated check; source inspection alone does not establish that check.

The implementation owner was also given the remaining delivery-document edits:
replace the old current-envelope wording in `docs/assurance.md`, distinguish the
now-closed mutable capacity source review from pending complete assurance in the
capability record, and replace its stale broad Rosetta description. These are
unfinished delivery records already within #70; they are not additional language
or implementation findings.
