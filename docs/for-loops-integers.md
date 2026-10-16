# For loops and integers

The owner selected this milestone on 2026-10-15 and resumed it with standard
Integer `'Image` in [decision #34](https://github.com/berkeleynerd/silver/issues/34),
recorded on main in
[`39d0ad38e6`](https://github.com/berkeleynerd/silver/commit/39d0ad38e6).
The subsequent instruction to fix the selected review findings before further
feature work is recorded in
[`618c28a77c`](https://github.com/berkeleynerd/silver/commit/618c28a77cdf011f338a31fcb0e9022743a338de).
The [repair record](review-343c2f8-repairs.md) tracks that prerequisite work.
Existing feature work remains unfinished and preserved; this scope record
does not claim implementation, validation or admission of any new construct.

[Milestone 1](https://github.com/berkeleynerd/silver/milestone/1) and
[stage #10](https://github.com/berkeleynerd/silver/issues/10) track delivery.
The [roadmap](../roadmap.md#for-loops-and-integers) records the order: report
capacity repair #17 first, scope/automatic-proof boundary #13, native admission
#14, universal and actual-source assurance #15, then validation/review/delivery
#16. Scope work can inform the repair; no new construct precedes its completion.

## Motivating programs

- [Loops/For](../rosetta/l/loops/for/silver.md): nested loops whose inner upper
  bound reads the outer index, printing the specified triangle of asterisks.
- [Loops/For with a specified step](../rosetta/l/loops/for-with-a-specified-step/silver.md):
  declare `Step : constant Integer := 2`, loop `I` over `1 .. 5`, and print
  `Integer'Image ((I * Step))` with `Put_Line`. Expected lines are ` 2`, ` 4`,
  ` 6`, ` 8` and ` 10`, including the leading spaces. This exercises immutable
  declarations, grouped arithmetic, loops and formatting together.
- [Loops/Downward for](../rosetta/l/loops/downward-for/silver.md): a reverse loop
  prints the countdown from ` 10` through ` 0`, preserving standard image format.

Colour bars/Display is no longer a milestone driver: its corrected assessment
requires actual coloured pixels in a PPM image and future file output. The
[Rosetta review](../rosetta/review-343c2f8.md) records the correction. Generated
stages are planning candidates: this owner-selected milestone covers for loops
and a bounded immutable Integer/Image fragment, not every integer form or every
sample in the later ranged-subtype stage. No construct identifier becomes
supported merely because its first fragment has an implementation.

## Selected fragment

Immutable scalar values are initialized `constant Integer` declarations and
scoped `for` indexes. The pinned GNAT `Integer` range is -2147483648 through
2147483647. Constants may read earlier Integer constants. Scalar and String
declarations share names, with separate typed values; existing String rules and
the first immutable argument declaration retain their meaning.

Scalar expressions use literals, visible scalar names, parentheses, unary signs
and fully parenthesized binary `+`, `-` and `*`. Each intermediate result must
fit Integer throughout the inferred operand interval, including negation of the
minimum value. Grouping preserves the selected evaluation order. Comparisons
compose with existing conditions; they do not yet narrow scalar intervals.
Admission therefore requires no facts about mutable scalar values carried
between iterations and no author annotations.

Forward and `reverse` loops evaluate scalar lower and upper bounds once on
entry. Nested bounds may read differently named enclosing indexes. An index is
immutable, local to its loop and hides outer homonyms, including use-visible
operation names; its own name is also hidden in its bounds, so an inner
`for I in 1 .. I` cannot read the outer `I`. Scalar declarations must respect
visibility of the `Integer` type mark. Existing String objects named `Integer`
remain legal, and package-name restrictions remain shell-dependent.

Bodies compose with nested loops, conditionals, `null`, String assignments,
output and returning `Reject`. Fixed String bounds and selected-input facts
remain central to the composition argument. Empty loops preserve entry facts;
definitely nonempty loops retain body exit facts; uncertain loops join entry
and body exit facts. Membership and proofs must not enumerate iterations.
Finite Ada ranges establish termination, and application proof uses
`--no-loop-unrolling` so expansion is not the admission or discharge argument.

`Integer'Image (E)` uses Ada's standard decimal representation of an admitted
scalar expression: one leading space for a non-negative value, or a minus sign
for a negative value. No trimming, replacement formatting or hidden source is
permitted. Its result is an ordinary String expression for output and the
existing String-expression positions. Signed 32-bit images have at most eleven
characters; admission must derive the actual possible length or length interval
from `E` and prove intermediate concatenation capacity and equal-length
assignment in every admitted composition. A maximum length alone does not
establish assignment length equality. Image evaluation, its predefined source
semantics and native emitted obligations belong in the universal discharge and
source-correspondence arguments.

Mutable Integer objects, custom scalar types/subtypes, conversions, division,
other scalar images and additional loop forms remain excluded. Mutable scalar
values require separate value-flow and loop-carried assurance; subtypes and
conversions require their own range-check rules. These are Silver scope choices,
not claims that Ada/SPARK forbids the features.

The earlier selected resource design uses 64 scalar leaves per expression and
one shared 63-operator source budget for concatenation and scalar arithmetic,
with the existing 4096-byte source/value bounds. Nonnegative literal exponents
are capped at 4096; exponent signs do not consume arithmetic operators. These
choices must be checked again with Image's generated checks and compositions
under #13/#17. They are not supported language limits until delivery.

## Report capacity and automatic proof

[B1/#17](https://github.com/berkeleynerd/silver/issues/17) is a defect in the
current language: the reviewed dense static construction leaves only
5,772–6,141 bytes in the 2 MiB report buffer, and additional prover credits can
exceed that margin. The review observed the near-limit reports and credit-growth
mechanism, not an overflowing dense run. Its approximately 2.37 MB bound covers
that construction; it is not a bound for every admitted program. A suggested
4 MiB allocation is a candidate size, not a derivation.

Completion requires capacity derived from report records and admitted source
shapes, including multiple prover credits, six-digit step counts and
interrupted-loser records; moving the buffer off `Compile`'s stack; affected
reader/policy proofs; and a format-derived capacity regression. The derivation
must be extended for scalar, loop and Image checks before they are admitted.
L2 capacity claims and L4 placement are part of that repair; L1/L3 establish the
effective proof configuration and its regression coverage.

## Completion and preserved work

Deliver decidable admission, execution and termination, universal safety and
automatic obligation discharge, and correspondence to the authoritative source
and actual native compiler. Update the language, catalogue, implementation,
proofs, samples, Rosetta supported identifiers and capability status together.
Run the stable native Linux proof/build/full-test checkpoint and complete
cached Lean check with a fresh audit, then independent review. macOS validation
remains independent and nonblocking. A pin update or passing sample does not
establish source correspondence or the universal guarantee.

Exploratory implementation and partial proofs remain on the local
`feat/for-loops-integers` branch and its focused worktrees, based on
`343c2f8f5a`. Preserve `tmp/for-loops-probes/`,
`tmp/for-loops-integers-active.json` and proof caches. Their earlier results
predate the Image scope change and are not evidence of complete delivery;
recheck exact inputs and live issue handoffs before resuming feature work.
