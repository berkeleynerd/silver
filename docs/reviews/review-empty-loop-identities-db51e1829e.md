# B5 / #313 independent implementation review — 2026-11-05

**Result: pass for the bounded B5 implementation.** No concrete correctness or
regression finding was identified in the reviewed change. This is not approval
of the final integrated capability: source pins/certificates, language/catalogue
integration and the complete validation checkpoint remain with the lead, as
assigned before this review.

## Review identity and exact inputs

- Reviewer: independent subthread `/root/assess_inherited_blockers`.
- Selected model/effort: GPT-6 Astra, Extra High, as assigned. Runtime model and
  effort were not independently exposed; no runtime confirmation is claimed.
- Review clock interval: 2026-11-05 09:08:57–09:11:36 UTC, 159 seconds before
  writing this record. Token/cost measurements were unavailable.
- Authorization: owner-authorized repair round, communicated by the lead after
  authorization PR #308 / main `200e91a892`; this review itself makes no issue,
  publication or merge changes.
- Implementation: `db51e1829e36861edc7232233b608b90962037a4`, compared with
  `0d308417955545a225378ed6e31f83733b40e4ce`.
- Worktree: `/home/canto/src/github.com/berkeleynerd/silver/tmp/empty-loop-repair`.
- All eight reviewed working files were byte-compared with the implementation
  commit and matched. `git diff --check` passed. The tracked worktree was clean.

Exact changed files:

1. `src/silver_scalars.ads`
2. `proof/Silver/IntegerIntervals.lean`
3. `proof/Silver/IntegerDivision.lean`
4. `proof/Silver/ScalarsNativeExpressions.lean`
5. `proof/Silver/ScalarsNativeEquations.lean`
6. `tests/test_empty_loop_folds.py`
7. `tests/test_integer_division.py`
8. `tests/test_mutable_integers.py`

Additional inputs were `tmp/B5-handoff.md`, the retained test/proof logs and
managed-run summary, the focused Lean evidence JSON, scalar-expression parsing,
the shared compile/audit/execute test helper, and the existing scalar source
bridge/check definitions. The earlier review's Oracle/language requirements
continue to govern: intentional restrictions must be explicit, source/model
correspondence remains mandatory, and example success is not universal assurance.

## Implementation and correspondence

At `silver_scalars.ads:109–113`, multiplication adds rejection only inside the
empty-operand branch and only when either interval contains zero. At
`:133–153`, modulo/remainder retain divisor-zero rejection first, then reject
an empty-operand case if the divisor interval contains either unit. Other
empty cases still return `Unreachable`. No previously rejected expression is
newly admitted by these changes, and every nonempty arithmetic branch is
unchanged. Rejecting harmless empty-loop instances as well is an intentional
conservative restriction, rather than a statement that each such source would
fail GNAT.

The Lean definitions implement the same order and conditions. The added
nonempty and rejected-identity lemmas state the relevant distinctions directly;
existing value-soundness arguments remain applicable because their concrete
operand-membership premises imply nonempty intervals. Boundedness proofs cover
both new empty-branch outcomes.

The actual typed source trees changed with the semantic models:
`ScalarsNativeExpressions.lean:247–252,267–285`. Their grouped nested
conditionals correspond to the Ada parentheses; the negative-unit argument is
represented as unary negation of one. The existing `checked_precedence` theorem
still covers these trees. `ScalarsNativeEquations.lean:28–30,53–68,117–128`
connects their denotations to the revised model and includes multiplication's
new dependency on `contains`. There is no model-only repair or pin-only claim.
Final token/certificate equality has deliberately not been claimed here.

## Bounded frontend argument

I inspected the retained GCC `exp_ch4.adb` and `sem_eval.adb` at
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Their byte lengths, SHA-256 values
and Git blob identities independently matched `tmp/gnat-identity-audit.json`.
This establishes the identity of the inspected release sources, not a rebuilt
binary-to-source attestation.

The source supports the handoff's argument:

- `exp_ch4.adb:9959–10007` creates zero for either known-zero multiplication
  operand, but multiplication by one returns the other operand.
- `:9809–9859,9868–9927,10558–10621` covers modulo's redirect to remainder,
  literal-zero production for divisor one, and the generated zero-result
  conditional for possible divisor minus one. The implementation conservatively
  rejects both units without relying on GNAT's additional range heuristics.
- The inspected addition, subtraction, division and unary expansion paths do
  not introduce another corresponding integer constant identity: their
  zero/one simplifications retain an operand. In particular subtraction's
  identity is `X-0`, not `X-X`.
- `sem_eval.adb:7226–7350` requires both nonstatic arithmetic operands to be
  compile-time known before ordinary folding. Its one-sided exceptions are
  Boolean And/Or, which do not supply Silver integer arithmetic operands.

The rule applies at every parsed arithmetic node. Consequently a known zero
or unit from a literal, constant, computed expression or constant-array seed
is covered by its containing nonempty interval, and an identified producer
cannot first erase an empty child without meeting the new rejection. This is
a sufficient bounded source argument for the reported B5 arithmetic identity
class; I found no specific omitted producer within the inspected supported
operator paths. It is not a proof of every GNAT transformation or every
empty-loop build behavior. The handoff states that limitation accurately;
other guards, array-bound behavior and B1–B4 remain separately assessed.

## Tests and retained evidence

The new tests preserve the failing shape through six consumer positions and
three empty-loop headers, including reverse negative bounds. Eleven seeds
cover both zero-product orientations, named/computed/array zeros, both unit
signs and named positive units. All 198 combinations assert both admission and
compile rejection with status 2 before a program workspace is created. Six
nonempty controls retain admission. The old empty `mod/rem 1` cases remain
explicit rejection assertions, with separate divisor-two positives; they were
not simply overwritten.

The full-route retained control covers Image, String assignment, nested-loop
bounds, comparison, Boolean assignment and a nonstatic sibling, plus `/1`,
`mod/rem 2`, `*1` and `I-I`. The shared helper checks captured source bytes,
audits Main and selected-library reports, and checks execution status/stdout/
stderr. This is meaningful coverage beyond an admission-only test.

I read the following successful logs; I did not rerun their work:

| Evidence | Observed retained result |
| --- | --- |
| `20261105T085829-a5494c5d077f` | Two admission methods passed, 14.310 s unittest time |
| `20261105T090058-59fe629af086` | Full-route control method passed, 11.001 s unittest time |
| `20261105T090125-005ff9bca9d1` | Focused native scalar proof: 44 checks proved |
| `20261105T090418-fdbc03e9b012` | Focused Lean targets and fresh audit: eight modules, 1,548 declarations; only `propext`, `Quot.sound`, `Classical.choice`; 28.056 s build + 5.487 s audit |
| `20261105T090525-f2b949dad850` | Nine existing division-admission methods passed, 3.938 s unittest time |

The failed audit-kind label and two Lean development failures are disclosed in
the handoff and followed by successful corrected runs. The Lean record also
discloses reuse of older verified cache objects; this review does not relabel
the run as a clean build. The native unit run is exploratory evidence, not the
complete compiler native audit. No expensive validation was rerun for this
review, and only this review document was written.
