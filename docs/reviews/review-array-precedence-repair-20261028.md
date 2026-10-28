# Independent review: array expression precedence repair

Review target: uncommitted four-file patch in `/home/canto/src/github.com/berkeleynerd/silver/tmp/constant-array-source`, branch `fix/array-precedence-review`, against `873f5910d2a1eaf2be00c397848c6a7bf872a5c1`. Authorization supplied by lead: response PR stacked on #266; no merge. Read-only review; no repository edits or builds run by reviewer.

Reviewer settings: GPT-6 Astra / Extra High selected by parent. This subthread has no separate runtime model/effort attestation, so selected settings are not reported as runtime-confirmed. Review began 2026-10-28 18:37:25 UTC; substantive review finished 18:41:44 UTC (4m19s). Token and monetary-cost measurements unavailable. Tool runtime is not total native validation time.

## Disposition

No blocking implementation finding in this bounded repair. The patch strengthens the expression categories, retains every current checked tree, and connects the new predicate array guard to the authoritative source requirement. Completion still requires the active focused run and the lead's complete source/module/axiom checkpoint; this review does not substitute for either.

One non-blocking evidence-quality observation was sent to the author:

- `proof/Silver/PredicateArrayBodyNative.lean:287`: `negation_collision` uses `condition := eqNat zero zero`, so its common rendering is `not 0 = 0 or else 0 = 0`. Its alternate tree also violates the new primary-operand rule for `not`; this fixture should not be described as a valid Ada expression whose interpretation diverges. The negative category test remains useful and correct. If a valid-source collision is desired, use Boolean primaries such as a Boolean-returning call, together with explicit evaluation assumptions or fixed imports. This does not affect the repaired checks or the actual checked source trees.

## Checks and reasoning

- Read the repository AGENTS guidance, Oracle requirements, source-correspondence/trusted-boundary explanation, and review bookkeeping requirements. The relevant source-language rules are the pinned Ada 2022 RM 4.4 (expression categories), 4.5(8) (left association), 4.5.7 (conditional syntax), and 4.5.9 (declare expressions).
- `ComposeExpressions.lean:1373`: `primary` now explicitly enumerates allowed constructors and defaults to false. The `term`, `simple`, `relation`, and `expression` layers keep new constructors out until classified. `tokenEq` is correctly relational. Integer add/subtract require a simple left operand and a term right operand (`:1478`); integer comparisons require simple operands. Ordinary Boolean inequality also uses the narrowed simple category (`:1499`), closing `boolNe (andThen p q) r` and nested-comparison cases.
- `ComposeExpressions.lean:1465`, `:1554`: full expression categories in call arguments and conditional arms preserve the prior valid call/branch allowance while arithmetic/comparison operands become restrictive. `andLeft`/`orLeft` retain left association and disallow ungrouped mixed logical operators. Bare nested `ite` is excluded from dependent-expression positions; `elsif` is admitted only as the conditional tail and rejected by direct grouping. The supplied subtraction and Boolean collision witnesses show the intended semantic distinction; the private kernel controls cover grouped counterparts.
- `ArrayBindingsNativeExpressions.lean:228` through `:282`: the new grammar checks cover all current constructors, function application spines, prefixes, conversion/index arguments, arithmetic association, comparisons, `not`, short-circuit operators, and conditional/elsif placement. `scoped` preserves the previous variable/type checks; every conjunct of `WellFormedTrees` still requires both grammar and scoping (`:284`). No default-variable behavior becomes admitted by this split.
- `PredicateArrayBodyNative.lean:211` through `:273`: primitive expressions are separated from conditionals, declarations, and statements. `groupable`, `declarationSequence`, `expressionBody`, and `functionBody` prevent `guardReturn` and bare declaration fragments from entering expression positions. The ordinary body requires the declared sequence ending in guarded return statements; a declare expression instead ends in an expression. Numeric relation operands can use `primary` because this AST has no numeric arithmetic constructors. The fixed existing target and assignment trees remain checked by `checked_precedence`.
- `PredicateArrayBodySource.lean:320` makes precedence mandatory in `Checked`. The existing kernel constructor at `PredicateScalarBodyCandidate.lean:21` must now discharge that field. The requirement flows through `PredicateSourceRequirements.lean:316` (`Checked.array_helpers`), `PredicateSourceCandidate.lean:581`, and `PredicateSourceChecks.lean:21` (`actualSource.profile`). The authoritative source path cannot omit the guard.
- `ArrayBindingsSourceChecks.lean:46` retains `Native.WellFormedTrees` as the first conjunct of `ExpressionTranslation`; `actual_expressions`, `CheckedSource.expressions`, and `checked_source` continue requiring it. Compose's source translation likewise retains the existing base and array tree requirements.
- Diff inspection confirms no renderer, evaluator, fixed source tree, endpoint, Ada source, or source-shape pin changed. `git diff --check` passed. The changed Compose acceptance behavior is restrictive; replacing the former broad `simple` with `expression` in full-expression contexts preserves that former allowance rather than introducing unchecked new forms.

## Evidence inspected and limitations

Inspected `.silver/linux-x86_64/lean-focused.log` for managed run `20261028T183022-b6f6878a4f91`. At 18:40:52 UTC it showed successful builds of `ArrayBindingsNativeExpressions` (6.0s), `ComposeExpressions` (39s), `ComposeArrayExpressions` (8.7s), and `PredicateArrayBodyNative` (5.2s), including their current-tree theorems and private `decide +kernel` controls. Later dependencies were still running; no completed candidate/fresh audit or full assurance result is claimed. The four staged proof-source files matched the reviewed working files byte for byte at 18:41:44 UTC. No extra native job was started.

This is a review of the requested guard repair and its fixed checked source trees, not a proof that every possible value of the older Compose AST renders a valid Ada expression. Older direct wrapper/local constructors were not comprehensively redesigned. Existing complete token/source checks, native verification, and the documented Ada/frontend interpretation boundary remain required. Samples and finite kernel fixtures alone do not establish universal language assurance.

Exact reviewed SHA-256 inputs:

| File | SHA-256 |
| --- | --- |
| `proof/Silver/ComposeExpressions.lean` | `732ab33404b83821025553c7a6125cec04c60cec31c2f27d3027b2947f879e51` |
| `proof/Silver/ArrayBindingsNativeExpressions.lean` | `7a59c90c66c6c4bdd187177dff733bfa2c8edfa5166dcc1bfe568608f419610b` |
| `proof/Silver/PredicateArrayBodyNative.lean` | `3194c329e11058b58946b09a6f7bd5b12aa4e38086faa8d35f3b8407ff1ef067` |
| `proof/Silver/PredicateArrayBodySource.lean` | `6a9a50d00a16485334dc598b3a987f995de4bcfffa975b280ad760c92d87080a` |

SHA-256 of `git diff --` over those four files in the table order: `1a2406f6c409b3c4a46ccdbe4af503a368f407e417c4be6299e972aff9b7650b`.

## Bounded follow-up: final private controls

Follow-up target: author commit `66bb50c3d73d15f2559ecba52a8d832fe3056d0a`; integrated commit `5e53345a0069eec81d94fecbb8819ee51381e803` has byte-identical contents for all four reviewed files. Reviewed only the final private-control delta, without a broad rereview or a new build. Selected reviewer settings remain GPT-6 Astra / Extra High; separate runtime attestation and token/cost measurements remain unavailable. Follow-up inspection ran from 2026-10-28 18:52:05 UTC to 18:53:23 UTC (1m18s).

Disposition: clean. The initial non-blocking collision-fixture observation is resolved. The replacement Boolean primary is `isEmpty (resultBounds localValue)`. Under its explicit true-value hypothesis, the rejected `not (orElse atom atom)` tree evaluates to false, while the alternate `orElse (not atom) atom` tree evaluates to true. Both share the ungrouped token sequence; a kernel control now explicitly requires the alternate tree to be well formed. The relation-based rejection controls remain, and the correctly grouped negation is accepted.

The additional Compose kernel controls reject the three requested exact structural shapes and accept their correctly grouped counterparts: subtraction with an ungrouped additive right operand; an outer group around addition whose left operand is a bare `ite`; and subtraction of a bare `ite` supplied to the `arrayPut` function. An outer group or call context cannot repair grouping missing inside arithmetic; these controls exercise that boundary directly.

The only follow-up changes are six private Compose control conjuncts and the private predicate Boolean fixture/theorem/three controls. This is mechanically checked, not merely author-reported: reversing those exact edits in memory reproduced the two original file SHA-256 values in the initial table. The other two file hashes are unchanged. Thus the initially reviewed guards, renderers, evaluators, public APIs, fixed source trees, and source-check wiring are byte-identical through this follow-up.

Retained managed evidence was inspected directly:

- `20261028T183022-b6f6878a4f91` completed successfully: build 1173.268s, fresh audit 9.795s, 19,970 declarations, foundations only `propext`, `Classical.choice`, and `Quot.sound`. Its targets included `PredicateScalarBodyCandidate`, which discharges the new mandatory source-candidate field. This supersedes the initial report's pending status for that run.
- Final control run `20261028T185112-d630b7abbbea` completed successfully: `ComposeArrayExpressions` and `PredicateArrayBodyNative`, build 54.986s, fresh audit 4.517s, 15,099 declarations, the same permitted foundations. This checks the final private controls.

The complete actual-source/module/axiom checkpoint remains the lead's next required step. The successful focused candidate run and final private-control run are distinct evidence, not a claim that this follow-up performed that complete checkpoint.

Final exact reviewed SHA-256 inputs:

| File | SHA-256 |
| --- | --- |
| `proof/Silver/ComposeExpressions.lean` | `4f329643de5ff97dea327bddfdaa82d6013d4d626f255376de307060e183fb14` |
| `proof/Silver/ArrayBindingsNativeExpressions.lean` | `7a59c90c66c6c4bdd187177dff733bfa2c8edfa5166dcc1bfe568608f419610b` |
| `proof/Silver/PredicateArrayBodyNative.lean` | `34f3e387b35459b1700dfbf4417d49310fda6d72bfd07317484f9f2b72a49145` |
| `proof/Silver/PredicateArrayBodySource.lean` | `6a9a50d00a16485334dc598b3a987f995de4bcfffa975b280ad760c92d87080a` |

SHA-256 of the four-file diff from base `873f5910d2a1eaf2be00c397848c6a7bf872a5c1` to author commit `66bb50c3d73d15f2559ecba52a8d832fe3056d0a`: `e4bbdad05fed840c74323effa76be80f76003a881010e39627883e27ed6d0108`. `git diff --check` passed before the author commit; the observed integrated checkout was clean. No repository edits were made by the reviewer.
