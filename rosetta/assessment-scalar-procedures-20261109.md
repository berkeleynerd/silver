# Scalar-procedure driver reconciliation

**Prepared source/task review, 2026-11-09; validation and delivery pending.**
This bounded review prepares the Return multiple values mapping for
[#370](https://github.com/berkeleynerd/silver/issues/370) and draft
[PR #371](https://github.com/berkeleynerd/silver/pull/371). It does not promote
support or establish compiler assurance. The
[capability record](../docs/scalar-procedures.md) tracks those separate checks.

The integration lead inspected the cached task, its Ada solution, the sample,
the language rules and the manifest. Runtime model and effort are not
independently exposed. This is a source/task comparison, not an independent
critical review or a new execution result.

## Task and program

The cached **Return multiple values** task is revision **412999**, timestamp
`2026-09-20T05:28:25Z`, at `r/return-multiple-values`. It asks to show how to
return more than one value from a function. Its retained Ada solution uses a
local `SumAndDiff` procedure with two input values and two `out` parameters,
then prints the sum and difference for 5 and 3. The procedure form is therefore
faithful to the task's own Ada interpretation of multiple results.

The [Silver driver](../samples/rosetta_return_multiple_values.adb) uses a local
`Sum_And_Diff` procedure with two `Small` inputs (`-100 .. 100`) and two Integer
outputs. Its two leading assignments compute the sum and difference directly,
without reading an output formal. Both mathematical results lie in
`-200 .. 200`, inside Standard.Integer, for the complete product of input
domains. The two actual output objects are distinct mutable Integer variables,
and neither appears in another actual's input expression.

Main calls the procedure with `(5, 3)`, `(-100, 100)` and `(100, 100)`, then
prints both results. The latter two calls exercise input endpoints. The
expected lines are:

```text
Sum: 8
Difference: 2
Sum: 0
Difference:-200
Sum: 200
Difference: 0
```

Positive and zero Integer Images carry their leading space; negative images
do not. The sample is 912 bytes, SHA-256
`fe82cee9e09fb5911c02049998bb580defec6168af792664427231880c7b547d`.
The manifest records the two output-formal names for the application report
audit. Native admission, proof, compilation and execution of this driver remain
pending; static arithmetic is not a substitute for those results.

## Proposed mapping and provenance

The faithful driver uses these precise identifiers:

- `scalar-procedures` for explicit modes, source-written initialization and
  positional calls returning multiple scalar results;
- `named-integer-subtypes` for the full formal input domain;
- `bounded-mutable-integers` for initialized caller output objects;
- `integer-image` for printed results.

Only `scalar-procedures` would be newly supported after complete capability
validation. Broad `procedures`, `integers`, `ranged-subtypes` and `scalar-image`
remain unsupported; this review does not claim their other assessed forms.
The assessor description, identifier definition, admission question and renderer
label must be updated with the final mapping. The broader stage #11 remains
open for its remaining forms.

Preserve the original assessment fields unchanged: assessed `2026-10-15`,
revision `412999`, rubric `2`, tier `deep`, model `claude-opus-5-5`, effort `high`.
It has no existing targeted `review` object to replace. The later mapping
should receive a separately attributed review pointing here, with a delivery
section added after actual validation. No coverage metadata or generated page
is promoted by this prepared record.
