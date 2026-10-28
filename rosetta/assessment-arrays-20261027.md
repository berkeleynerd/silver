# Selected array driver and current division assessments

2026-10-27; targeted planning update for [#260](https://github.com/berkeleynerd/silver/issues/260)
and the triggered [#255 follow-up](https://github.com/berkeleynerd/silver/issues/255).
The integration lead read the three task descriptions, their coverage entries,
the current language rules and the rotation source. The live lead model/effort
and token/cost measurements are unavailable. This review adds no native,
Lean or full-suite validation claim.

**Shift list elements to left by 3** asks for rotation, with the explicit result
`4 5 6 7 8 9 1 2 3`. The 21-line
[sample](../samples/rosetta_shift_list_left_3.adb) computes that permutation using
two anonymous Integer arrays and two copy loops. The first loop reads `I+3`
for `I` in `1..6`; the second reads `I-6` for `I` in `7..9` and writes result
index `I`. Both source and destination intervals are within `1..9`, and the two destination ranges cover
the complete result without overlap. The print loops expose both lists.
No named type, attributes, helper procedure or modulo is needed. The narrow
`fixed-integer-arrays` identifier describes this source; broader `arrays`
remains unsupported. The capability record retains implementation and pending
[delivery obligations](../docs/fixed-integer-arrays.md#delivery-obligations).

**Even or odd** needs remainder by two over a fixed range including negatives
and zero. **FizzBuzz** needs modulo by 15, 5 and 3 over `1..100`, testing 15
first. These literal divisors exclude zero and the inferred result intervals
fit Integer. Their existing approaches require only the delivered
`interval-integer-division`, `integer-for-loops` and `integer-image` identifiers;
neither needs `abs` or broader integer division. The
[external review I8](../docs/reviews/review-22838bc809.md) also confirmed their
admission. Retagging closes the stale mapping identified by #255 without
creating new samples or claiming new proof/build/execution evidence.

The initial assessment dates and model attributions remain historical.
`coverage.json` records this targeted revision under `review`; generated pages
are produced by the ordinary renderer at the delivery checkpoint.

## Delivery metadata reconciliation

This bounded reconciliation prepares the narrow `fixed-integer-arrays` support
mapping for #260. Its integration depends on the complete native/Lean delivery
checkpoint tracked in the [capability record](../docs/fixed-integer-arrays.md).
The reconciliation itself makes no completed validation claim.

Exact inputs: integration commit `899a15a5a0`, the downloaded driver task at page
revision 406577, `language.md#fixed-size-integer-arrays`, the 21-line driver
source and its `samples/manifest.json` entry, plus the existing assessment and
renderer records. The source's first copy loop has `I` in `1..6`, source index
`I+3` in `4..9` and destination index `I`; its second has `I` in `7..9`, source
index `I-6` in `1..3` and destination index `I`. Thus every destination is
written once and the output is exactly the task's rotation. The manifest's
expected bytes include Ada Integer Image's leading spaces and both line
terminators. This is a static source/expected-output comparison, not a program
execution or source-correspondence proof.

The supported list gains only `fixed-integer-arrays`; only the statically
reviewed exact rotation assessment uses that narrow identifier. Broad `arrays` and
its stage issue #12 stay open. Loops/Foreach retains its broad assessment: an
index loop does not establish support for Ada's distinct foreach form. The
assessor's current-language description now includes the bounded array rules,
including singleton initialization, scalar-only checked subscripts, declaration
snapshots and full-Integer body reads. The rotation summary and review metadata
no longer describe an in-progress implementation as their assessment basis.
The earlier planning sections retain their historical scope.

Selected setting: GPT-6.1 Sol / High. Runtime model/effort, whole-round elapsed
time and token/cost measurements are unavailable. This subthread runs only the
ordinary local metadata renderer and light consistency/whitespace checks on
Linux x86_64; no compiler, native proof, Lean, build, admission probe or test
suite runs here.

`python3 rosetta/refresh.py --render` rendered all 1,782 tasks. A second render
with `PYTHONHASHSEED=2` left all 1,784 generated task/progression/index pages
byte-identical. Source-record checks confirmed that the supported list gains
only the narrow identifier and the only changed task assessment is the rotation;
all other broad-array assessments are unchanged. The exact sample loop shapes
and independently derived rotation output agree with the manifest.
`git diff --check` passed.

The progression retains 1,576 candidates in 44 stages, two unlikely, 203 excluded
and one design-pending assessment. Stage 1 grows from 47 to 50 candidates:
rotation moves from stage 3/position 57 to stage 1/position 36. Rendering also
picks up the already-reconciled Even or odd and FizzBuzz source records, moving
them from stage 6/positions 105 and 106 to stage 1/positions 27 and 28. Their
assessment records are unchanged by this patch. All construct-stage positions
are unchanged: closed #9/#10 remain Stage 1, #11 remains Stage 2, and broad
arrays #12 remains open at Stage 3. Broad integer division stays at Stage 6.
Loops/Foreach remains in Stage 3 (position 51 becomes 54).
