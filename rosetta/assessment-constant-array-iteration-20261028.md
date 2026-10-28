# Constant Integer-array foreach assessment

2026-10-28; bounded delivery-metadata preparation for
[#264](https://github.com/berkeleynerd/silver/issues/264). Selected setting:
GPT-6.1 Sol / High; runtime model/effort and token/cost measurements are not
independently exposed. Whole-round elapsed time is unavailable.

Exact review inputs: integration commit `949300e8b5`, cached
[Loops/Foreach task](l/loops/foreach/task.wiki) revision 415246, the constant-array
iteration rules in [language.md](../language.md#constant-integer-array-iteration)
and [capability record](../docs/constant-array-iteration.md), the nine-line
[sample](../samples/rosetta_loops_foreach.adb), its `samples/manifest.json` entry,
and the existing assessment/renderer records.

The task asks for each collection element in order, using the language's foreach
construct when available. The exact sample declares constant `Values`, indexed
`1 .. 5`, initialized to `(-1, 0, 1, 2, 3)`, then uses `for Value of Values loop`
and `Silver_IO.Put_Line (Integer'Image (Value))`. It needs no user-defined
procedure. The immutable, nonstatic element starts with full Integer bounds;
Image accepts that complete range without guard refinement. Independent static
output derivation agrees with the manifest bytes: `-1\n 0\n 1\n 2\n 3\n`.
This checks ordered foreach output and Ada Image spacing, not execution or proof.

Only Loops/Foreach is reconciled, replacing its stale indexed-loop approach and
broad surface tags with `fixed-integer-arrays`,
`constant-integer-array-iteration` and `integer-image`. Original assessment date,
revision and model attribution remain historical; the dated `review` records
this static reconciliation. The supported list gains only the narrow iteration
identifier. Broad `arrays` and issue #12 remain open. The current-language
assessor description includes constant forward/reverse iteration, nonstatic
full-range elements, captured identity, hiding and scalar/String flow limits.

This preparation branch is for lead integration only after the complete
native/Lean/source/regression assurance checkpoint. Its support metadata is not
a separate delivery decision. This record and review establish no compiler,
native proof, Lean, build, admission-probe or test-suite evidence. Validation
here is limited to the ordinary local deterministic metadata renderer and light
source-record, expected-output and whitespace checks on Linux x86_64. The lead
owns GitHub stage-field updates and delivery bookkeeping.

`python3 rosetta/refresh.py --render` rendered all 1,782 tasks. Repeating with
`PYTHONHASHSEED=2` left all 1,784 generated task/progression/index pages
byte-identical. Source-record checks confirmed that only the narrow identifier
was added and only Loops/Foreach's assessment changed, with its historical
attribution preserved. The static source/output check and `git diff --check`
passed. No further validation was run.

The progression retains 1,576 candidates in 44 stages, two unlikely, 203
excluded and one design-pending assessment. Foreach moves from Stage 3/position
54 to Stage 1/position 13. Stage 1 grows from 50 to 51 samples; Stage 3 shrinks
from 14 to 13. The 41 other changed task pages update positions only;
Segmentation fault protection gains the broad-array stage-driver label. All
construct-stage mappings remain unchanged: closed #9/#10 stay Stage 1, #11
stays Stage 2, and open broad arrays #12 stays Stage 3.
