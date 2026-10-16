# Rosetta mapping for Integer loops and Image

Review date: 2026-10-16. This targeted review covers the three driver tasks of
[#10](https://github.com/berkeleynerd/silver/issues/10), following the selected
scope in [the capability record](../docs/for-loops-integers.md). It preserves
original model attribution and retained page revisions. It is not a new
corpus-wide assessment or evidence for universal automatic discharge; those
claims belong to the capability's source and semantic assurance record.

The earlier [targeted review](review-343c2f8.md) selected immutable Integer
arithmetic and standard Integer image. This update splits the assessed surface
so delivery does not mark the broader `integers`, `for-loops` or `scalar-image`
identifiers supported for forms that have not been assessed against the
admitted fragment. Those broader identifiers retain their original meanings
and remain unsupported. Every assessment except the three listed below is
unchanged.

| Supported identifier | Delivered fragment |
| --- | --- |
| `integer-for-loops` | Inclusive ascending and reverse Integer range loops, nested loops, immutable indexes and admitted scalar bound expressions. |
| `immutable-integers` | Immutable signed 32-bit Integer constants and interval-checked grouped arithmetic, unary signs and scalar comparisons. |
| `integer-image` | Standard Integer image with Ada's leading spaces and signs, with bounded String length composition. |

The language and catalogue define the exact grammar, interval rules and
resource limits. Each binary scalar arithmetic operation and nonliteral unary sign needs
explicit grouping. A signed numeric literal may stand alone; signed binary
operands need their own grouping, for example `((-1) + 2)` and `(1 + (-2))`.
The identifiers do not admit mutable Integer objects, custom subtypes,
conversions, division, enumeration or array iteration, or other scalar images.

## Reviewed tasks

**Loops/For**, revision 415373, requires the five rows of asterisks produced
by outer `I in 1 .. 5` and inner `J in 1 .. I`. `Put ("*")` emits each star,
and `Put_Line ("")` follows the inner loop to end its row. The surface is
`integer-for-loops` plus the existing `put`; no constant declaration or
Integer image is needed.

**Loops/Downward for**, revision 412893, requires the countdown from ten
through zero. The retained Ada solution uses `reverse 0 .. 10` and
`Integer'Image (I)` directly. The selected sample retains that form and Ada's
leading spaces. Its surface is `integer-for-loops` and `integer-image`.

**Loops/For with a specified step**, revision 412896, asks for a for-loop
whose step exceeds one. Its retained Ada explanation calls the supplied
versions approximations because Ada does not offer a direct stride clause.
The selected program follows its `Looper_2` idiom: `Step : constant Integer := 2`,
a loop over `1 .. 5`, and `Integer'Image ((I * Step))`. The computed values are
2, 4, 6, 8 and 10 while the immutable index advances by one. This sample does
not demonstrate a stride clause or modification of the loop index. Its
surface is all three narrow identifiers. The selected `Put_Line` program
prints one value per line, correcting the former assessment's conflicting
"one line" effect description; the task imposes no line layout.

## Rendered progression mapping

With these three identifiers added to `supported`, the reviewed drivers need
no future construct: Downward for is position 8, For is position 13, and For
with a specified step is position 17, all in stage 1. The next generated stage
is stage 2: the broader for-loop, integer, ranged-subtype and scalar-image
forms retained by [#11](https://github.com/berkeleynerd/silver/issues/11).
Procedures occupy stage 3 and arrays stage 4
([#12](https://github.com/berkeleynerd/silver/issues/12)). The selected milestone
[#10](https://github.com/berkeleynerd/silver/issues/10) closes only when its
capability delivery criteria are met; the remaining broad forms belong to #11.
Generated stage movement does not authorize that future work.

The render uses the existing manifest and retained sources, with no downloads.
Only these three assessment records change; other generated task pages change
only their progression position/stage line and the surface heading. The
heading now describes the surface recorded by the assessment, including any
constructs subsequently admitted; it no longer calls supported constructs
"beyond today's Silver". The canonical source description,
coverage, generated pages, roadmap mapping and stage issue fields must be
published together with the completed capability delivery.

Focused Linux x86-64 managed run `20261016T165337-cf4205a5867d` passed both
existing renderer tests, including full-corpus output comparison under two
Python hash seeds. A separate draft audit compared all assessment records and
all changed task pages with the base commit: exactly the three records above
change, and every other changed task page differs only in its progression
line or surface heading. This validates the rendering/update scope, not the
compiler or assurance of the proposed samples.

A separate read-only review confirmed task faithfulness, the narrow construct
split and the rendered stage mapping. Its grammar wording correction limits
the grouping requirement to scalar arithmetic, leaving ordinary comparisons
and String concatenation described by their existing language rules.
