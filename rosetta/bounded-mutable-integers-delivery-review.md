# Rosetta mapping for bounded mutable Integer objects

Review date: 2026-10-17. This delivery update covers **Find square difference**,
retained page revision 412795, under the
[selected capability](../docs/bounded-mutable-integers.md) and work package
[#70](https://github.com/berkeleynerd/silver/issues/70). Original assessment
attribution and the retained task revision are preserved. This is a targeted
source review; it does not claim a completed integrated assurance checkpoint
or reassess the remaining corpus.

The task asks for the least positive `N` whose consecutive-square difference
exceeds 1000. The selected program declares
`Answer : Integer range 0 .. 1000 := 0`, loops over `N in 1 .. 1000`, and assigns
`N` when `Answer = 0 and then ((N * N) - ((N - 1) * (N - 1))) > 1000`.
It then prints `Integer'Image (Answer)` with `Silver_IO.Put_Line`. Each binary
operation is grouped. It produces ` 501` followed by a newline, preserving
Ada's leading space.

The declared range covers every stored loop index. Arithmetic uses the loop
index interval and needs no facts from a prior iteration or scalar guard.
There is no accumulator, exit, custom subtype or conversion. The combined
native driver probe in run `20261017T005429-cfeb5626a484` compiled and executed
this computation with the expected result; the
[capacity review](../docs/bounded-mutable-report-capacity.md#native-corroboration-and-delivery-boundary)
records its source/report identity and distinguishes it from universal
assurance.

The assessment now uses these identifiers:

| Identifier | Required fragment |
| --- | --- |
| `bounded-mutable-integers` | Initialized mutable Integer storage with a static object-local range and assignments contained in its declared range. |
| `integer-for-loops` | A finite ascending Integer loop with an immutable index. |
| `integer-image` | Standard Integer image, including its leading space and bounded length. |

Only this task's assessed surface changes. The broad `integers`,
`ranged-subtypes`, `for-loops` and `scalar-image` identifiers remain unsupported,
and their other task assessments retain their meanings. The new narrow
identifier does not admit declared scalar subtypes, conversions, general
discrete loops, other scalar images, scalar guard refinement or assignment
refinement. Adding it to `supported` and updating the assessment prompt are
delivery edits; final capability completion still requires the integrated
evidence recorded by the delivery package.
