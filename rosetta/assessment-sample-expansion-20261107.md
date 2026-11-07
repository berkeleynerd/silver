# Eleven sample-expansion task assessments

Targeted metadata reconciliation for [#300](https://github.com/berkeleynerd/silver/issues/300),
2026-11-07. The [authorized scope](../docs/rosetta-sample-expansion.md) is ten
programs with eleven task mappings using the current language. This record
reviews sources and expected outputs at integration commit `ff4fdb9c8b`,
including source commits `e84a7c10a3` and `c9f9ab272e` and the manifest at that
integration target. The integration lead subsequently completed application
proof audits, build and exact manifest execution for these unchanged sources
in run `20261107T164659-9f6192441d21`. Independent closing review status is recorded in the linked
[delivery account](../docs/rosetta-sample-expansion.md#delivery-and-validation--2026-11-07);
this metadata assessment does not itself supply that acceptance.

The metadata subthread selected GPT-6.1 Sol / High (`gpt-6.1-sol`, `high`).
Live runtime settings were not independently exposed; whole-round elapsed time,
tokens and cost are unavailable. This is a targeted reconciliation, not an
independent review. The inputs read were all eleven captured `task.wiki` pages,
their `manifest.json` revisions, the ten sources, their manifest cases, the
existing assessments and prior FizzBuzz/parity review records, and both retained
expected-output derivations. No task page was refreshed.

| Task (captured revision) and source | Source correspondence and expected behavior | Nonblank lines |
| --- | --- | ---: |
| [FizzBuzz](f/fizzbuzz/task.wiki) (415487), [source](../samples/rosetta_fizzbuzz.adb) | Computes all 100 values; checks modulo 15 before 3 and 5. Numeric lines retain ordinary Integer Image spaces. | 16 |
| [Even or odd](e/even-or-odd/task.wiki) (415382), [source](../samples/rosetta_even_or_odd.adb) | Classifies actual values -3 through 3 by `rem 2`, including negative odd values and zero. | 12 |
| [Empty string](e/empty-string/task.wiki) (412762), [source](../samples/rosetta_empty_string.adb) | Assigns an empty mutable String variable; checks it and a nonempty variable. Argument cases distinguish missing/empty input, `Silver`, a space and 4096 bytes, and reject extra arguments, 4097 bytes or a tab. | 25 |
| [Array concatenation](a/array-concatenation/task.wiki) (414063), [source](../samples/rosetta_array_concatenation.adb) | Copies the exact inputs `(-3, 0, 5, 5)` and `(8, -1, 2)` into the seven-element result in order; displays both inputs and result. | 39 |
| [Bubble sort](s/sorting-algorithms/bubble-sort/task.wiki) (415490), [source](../samples/rosetta_bubble_sort.adb) | Adjacent comparisons/swaps with nine shrinking passes suffice for ten elements. A pass without swaps disables later pass bodies. Output preserves duplicate -5, 0 and 12 values. | 39 |
| [Sort an integer array](s/sort-an-integer-array/task.wiki) (414484), same bubble-sort source | The shared source computes ascending `(-100, -5, -5, 0, 0, 3, 7, 12, 12, 100)` and displays before/after arrays. No generic sorting facility is currently admitted. | 39 |
| [Greatest common divisor](g/greatest-common-divisor/task.wiki) (415534), [source](../samples/rosetta_greatest_common_divisor.adb) | Normalizes signs and computes eight GCDs with magnitudes at most 1000. Two Euclidean steps at least halve the second operand, so 20 steps suffice because `2**10 > 1000`. Cases include zero, sign changes, `(610, 987)` and the explicitly stated convention `gcd(0, 0) = 0`. | 35 |
| [Factors of an integer](f/factors-of-an-integer/task.wiki) (413796), [source](../samples/rosetta_factors_of_an_integer.adb) | Tests every divisor from 1 through each positive input; lists complete factors for 1, primes and composites up to 100. | 18 |
| [Leap year](l/leap-year/task.wiki) (415546), [source](../samples/rosetta_leap_year.adb) | Computes the Gregorian predicate for twelve years, including ordinary cases, common centuries and 1600/2000/2400. | 19 |
| [Multiplication tables](m/multiplication-tables/task.wiki) (414747), [source](../samples/rosetta_multiplication_tables.adb) | Computes the full 12-by-12 upper triangle including diagonal, row labels and headings. The output has 13 lines of 52 characters before LF. Padding uses literal spaces and Integer Image. | 38 |
| [Count the coins](c/count-the-coins/task.wiki) (413676), [source](../samples/rosetta_count_the_coins.adb) | Enumerates all quarter/dime/nickel choices; remaining cents uniquely determine pennies. At most `5 * 11 * 21 = 1155` triples exist, so the counter guard cannot skip required work. Prints only the required one-dollar result 242. The optional $1000 extension is excluded. | 21 |

Sizes count every nonblank source line, including comments. The task revision,
original assessment date, rubric, tier, model and effort remain unchanged in
`coverage.json`. New review metadata identifies this actual source review.
Only the eleven named task records change; the supported identifier list is
unchanged. Their revised dependencies use currently supported narrow fragments
or baseline String/argument operations. No broad arrays, integer division,
Boolean functions, user routines, general String building or other feature is
promoted.

## Expected-output evidence and validation checkpoint

The retained [simple derivation](../docs/evidence/rosetta-sample-expansion-20261107/expected-simple.py)
uses divisibility classes, parity by the low bit, paired divisors through the
integer square root and `calendar.isleap`, with a separate argument-boundary
model. The [algorithm derivation](../docs/evidence/rosetta-sample-expansion-20261107/expected-algorithms.py)
uses list concatenation, Python sorting, `math.gcd`, fixed-width table formatting
and coin dynamic programming, rather than the Silver enumeration. Both derive
manifest expectations independently of Silver execution, including Ada Image
spaces, LF terminators, empty stderr and exit status. This subthread read those
derivations and compared their intended results with the manifest and sources;
it did not run the derivations or execute the applications. That preparation
preceded the integration lead's successful validation below and retains its
separate static-review scope.

The risks in the revised assessments describe the actual interval/index/division
checks and bounded algorithms. A counted loop's termination alone does not
establish enough passes to solve a task; the GCD and bubble-sort bounds above
supply that separate argument. Finite sample cases do not establish universal
language assurance or comprehensive task-input coverage.

The integration lead's Linux x86_64 manifest run
`20261107T164659-9f6192441d21` passed for all 71 source samples and 134 execution
cases. The retained [result](../docs/evidence/rosetta-sample-expansion-20261107/manifest-result.json)
records success, zero errors/failures and stable native inputs/tools; the
[managed terminal record](../docs/evidence/rosetta-sample-expansion-20261107/manifest/terminal.json)
records the same successful run. The unchanged manifest test checks admission,
byte-identical proof/build source, the required application/library proof policy
and complete report audit, build success, and executable stdout/stderr/status
against the exact manifest cases. The
[delivery evidence](../docs/evidence/rosetta-sample-expansion-20261107/README.md)
records native/Lean input applicability and the broader integration checks.
This metadata subthread did not run compilation, proof, build or application
execution; its final wording uses that separately retained integration evidence.
The delivery account carries independent closing review and publication status.

Stage 1 has a 61-assessment baseline; FizzBuzz and Even or odd already belong
there, so this reconciliation adds nine mappings, to 70. There are 71 source
samples, 134 manifest execution cases and 48 Rosetta source files. The successful
finite executions and the rendered assessment count are distinct facts, and
neither establishes universal language assurance. Only the ordinary final
metadata render runs in this subthread; no language identifier is promoted.

Static JSON consistency checks confirmed exactly eleven changed task records,
unchanged supported identifiers and original assessment provenance, and only
supported identifiers in the revised dependency sets. Source/manifest inventory
counts above were checked directly. `git diff --check` passed on Linux x86_64.

## Earlier FizzBuzz and parity review provenance

The new review object replaces this identical object on both FizzBuzz and Even
or odd, preserved here verbatim:

```json
{
  "date": "2026-10-27",
  "record": "assessment-arrays-20261027.md",
  "setting_evidence": "Integration lead; live model and effort not independently exposed",
  "method": "Targeted task/specification/sample review and retained external admission evidence; no new complete validation claim"
}
```

That [array/division reconciliation](assessment-arrays-20261027.md) retains its
own source/admission scope and links the earlier
[2026-10-25 division assessment](assessment-division-20261025.md). The earlier
review selected GPT-6.1 Sol / High (`gpt-6.1-sol`, `high`), with runtime settings
not independently exposed, and used targeted task, current-language and
retained-prototype review without new native admission, proof, build or execution.
The 2026-10-27 record preserves that attribution and the historical delivery
checkpoints; this sample review does not replace their dates or validation
claims. Both tasks retain their original 2026-10-15 assessment attribution to
`claude-sonnet-5-5`, effort `medium`, tier `standard`, at their captured revisions.
