# Division assessment reconciliation, 2026-10-25

Planning work for [#229](https://github.com/berkeleynerd/silver/issues/229) and
[#230](https://github.com/berkeleynerd/silver/issues/230), following the owner's
“Agreed. Proceed.” authorization. The capability scope and sequencing are in
[the division record](../docs/integer-division.md). This reconciliation changes
assessment plans and dependencies; it delivers no construct or sample.

Inputs were the five downloaded task descriptions and their existing assessments,
current [language rules](../language.md), the supplied PR #228 advisory
(`tmp/review-pr228-20261025/codex-assessment.md`), and its retained
`next-increment-research/NOTES.md` and `cands/pythagorean_today.adb`. The scratch
paths identify the supplied evidence; they are not newly reproduced validation.

| Assessment | Reconciled approach and dependencies |
| --- | --- |
| Loops/Do-while | Keep the bounded counted sequence with the modulo test and `exit when` after printing. The body executes before the termination test. Add `while-loops`, which covers conditional exit even inside a for loop; its dependency cannot disappear merely because the bound is finite. |
| Variable size/Get | Read `X'Size` and print bits and bytes. Add `integer-object-size-read`, with its own surface description and admission question. Reading an object's Size is distinct from the existing representation-clause identifier. |
| Even or odd | Test `rem 2` directly in Main over -1000 .. 1000 and print each verdict with ordinary Image and Put_Line. Use precise Integer-loop/Image identifiers; drop the procedure, declared-subtype and separate Put dependencies. Remainder remains unsupported. |
| FizzBuzz | Print ordinary Integer Image, including its standard leading space, in the numeric branch. The task requires no trimming. With that approach change, remove string-building and use the precise Integer-loop/Image identifiers. Modulo remains unsupported. |
| Special pythagorean triplet | Use the retained nested-loop plan with `Found : Integer range 0 .. 1` and an initialized Integer product, grouped arithmetic and a short-circuit first-match test. Use only current supported identifiers. The retained prototype passed admission only; no proof, build or execution of that prototype is claimed. It becomes a current-language candidate, not a delivered sample. |

For the triplet plan, A is in 1..333, B in 2..500 and the expression
1000-A-B in 167..997. The conservative product bound 333*500*997 = 166000500,
both squares and their sum fit signed 32-bit Integer. The flag's only values are
0 and 1. These checks explain the assessment; they do not substitute for native
proof or universal language assurance.

The new `interval-integer-division` catalogue entry describes the selected
fully grouped Integer `/`, `mod` and `rem` fragment, without guard or update
refinement. Its admission question includes per-operator Ada sign rules,
nonempty intervals, zero-divisor exclusion, the selected conservative
Integer-minimum/-1 exclusion, exact singleton initialization, the shared
operator budget and complete producer/source correspondence. The existing broad
`integer-division` identifier includes `abs` and stays unsupported. No existing
assessment is migrated to the narrow identifier here; only verified delivered
approaches should migrate at delivery. No global migration of the 883 assessed
uses of the broad identifier is attempted.

`coverage.json`'s supported list is unchanged: `put`, `integer-for-loops`,
`immutable-integers`, `integer-image`, `bounded-mutable-integers`. Only these five
assessment records changed. The render still has 1576 candidates, 2 unlikely,
203 excluded and 1 design-pending assessment; it has 44 stages instead of 43
because Size reads now have a distinct stage. The current-language candidate
stage has 39 entries instead of 38. Stage numbering throughout generated pages
changes accordingly. The narrow division identifier has no stage driver yet.
Generated order does not authorize implementation; the owner-selected division
then proposed guard-refinement order remains separate, and arrays remain
provisional.

## Validation and round settings

The lead selected GPT-6.1 Sol, High, for this bounded planning subthread; runtime
settings were not independently exposed. Inputs were reviewed statically and
edits were confined to `rosetta/**` and the generated root `rosetta.md`. No
compiler, native proof, Lean, build, admission or program execution ran here, and
no compiler/proof input or supported identifier changed. No test code changed.
Whole-round elapsed time, tokens and cost were unavailable.

On native `linux-x86_64`, `python3 rosetta/refresh.py --render` passed and rendered
1782 tasks. The managed status read showed zero reserved workers before the
checks. The lead approved a single worker and this worktree's Python-test lease.

`python3 scripts/dev.py test --jobs 1 --task '#230' --reason '<targeted assessment
reason>' -- -p test_rosetta.py` passed all three existing renderer tests, including
real-CLI determinism under hash seeds 1 and 2. Initial run
`20261025T220209-33d959128517` took 4.735 seconds in unittest. After adding the
narrow division metadata, run `20261025T220237-76cfa5755cc5` passed in 4.101 seconds.
The second run verifies changed renderer input, rather than replaying identical
successful inputs. Exact command arguments, native logs and managed timing are
retained in the corresponding shared Git run records. `git diff --check` passed.
A direct comparison against the baseline verified the supported list is identical
and exactly the five named assessments changed.
