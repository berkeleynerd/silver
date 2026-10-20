# Fresh save formatter: core arithmetic and output transfer

2026-10-20 UTC, research #119 / #153, Round 30. This is a conditional
source theorem for the fresh XML formatter, not complete Format or save capacity.
The [packet](../evidence/retained-why-save-formatter-core-20261020/README.md)
retains source excerpts, installed instruction witnesses and a checked arithmetic
interface. No native execution, capture, disassembler or prover run is needed.

## Selected stream and premises

`Session_itp.save` creates a private `formatter_of_out_channel`. Its reachable
XML printers (`session_itp.ml:2021–2209`, `Pp.html_string`, `Pp.print_list`,
`Pp.space`, `Termcode.pp_sum_shape_version`) use ordinary text/characters,
boxes with indentation zero or one, ordinary breaks of width one and offset
zero, forced newlines, closes and the final flush/newline. The only explicit
box descriptions are `<h>`, `<v 0>`, `<v 1>` and `<hov 1>`. No selected printer
changes formatter settings, installs an output wrapper, emits a tag/tab token,
uses `Magic_size` or calls `print_if_newline`. A variable string is data to
`pp_print_string`, including any `@` bytes; it is not a format program.
`%a` executes its supplied printer synchronously through `Acc_delay`, rather
than storing that function in the pretty-printing queue.

Let B bound the sum of text-token byte lengths, and E bound direct core
operations (text, open, close, break, forced newline, flush), over one attempted
save. The previously reviewed [operational transfer](retained-why-save-operational-bounds.md)
supplies candidates `B = 1024*Q + 6*U + 32*Q*d`, `E = 128*Q + U` where
`Q = 1+F+Th+G+T+Axml+A+Args+Paths`. Its occurrence, continuation, U and d
premises are required. They are not established merely by substituting the
Round 29 candidate values.

The theorem requires the selected source/native behavior relation, valid typed
state, default fresh settings, the stated input bounds, and private-frame
integrity: callback activity does not mutate this formatter or resume it after
an escaping partial core operation. Nested saves allocate their own formatter.
The sole `save_ident` Not_found catch encloses path lookup/concatenation, before
its `fprintf`; it does not enclose a call on this formatter. This observation
does not independently discharge every runtime callback/exception premise.
Native output/allocation services and the remaining caller/error obligations
retain their separate owners. The usable interface remains null until its
premises are supplied explicitly.

## Arithmetic induction

Put `L=B+E`, `P=1000000010` (the actual `pp_infinity` literal, regardless of
the adjacent comment), and `N=4*(E+1)`. Require

```text
L + 79 <= P
N + 2 <= 2^62 - 1
```

The first is a sufficient sentinel/draining guard for this transfer, not a
new Silver admission rule or a claim that every larger stream fails.

A fresh formatter has margin 78, maximum indentation 68, left/right totals 1,
depth 1, a system box and a scan sentinel. Between resets, all token lengths
are nonnegative: text length or ordinary break width; other selected tokens
have length zero. Their sum is at most L. Hence both running totals are in
`[1,1+L]` before flush; left remains in that interval during draining.
Unknown sizes are `-right_total`, with the initial sentinel -1; `set_size`
adds the current right total to one such stored negative value. Monotonicity
within the segment bounds resulting sizes by `[0,L]`. Discarding obsolete
scan entries restores the sentinel and introduces no larger value.

`pp_flush_queue` first closes remaining user boxes, then assigns P to the
right total. It does not subsequently call `set_size` before reset. During
draining, `P-left_total >= P-(1+L) >= 78`; thus even an unknown system box
can advance, since space left is at most 78. Each step removes one queued
token. Reset clears containers/totals and reinstates the system box. No
arithmetic argument assumes P was added to the old total.

Inductively space left is in `[-L,78]`, current indentation in `[0,68]`, and
each stored box width in `[-L-1,78]`. Text and same-line breaks decrease space
by a total at most L. A newline computes `78-width`, lying in `[0,L+79]`,
then clamps it to 68; space resets to at least 10. Opening a box computes
insertion point `78-space_left` in `[0,L+78]`, may first break the line, then
subtracts its zero/one indentation to form the stored width. The system box
uses zero. These cases preserve the bounds. Selected break before/after
strings are empty and their newline offset is zero, so the extra additions
in the generic custom-break branches introduce no unaccounted quantity.

Known token sizes, pending counts, negated totals, depths and all intermediary
addition/subtraction results therefore fit signed 63-bit OCaml integers under
the guards. `pp_curr_depth <= E+1 < max_int` excludes ellipsis suppression.
Queue and stack lengths are separately covered below. This claim concerns
the selected core arithmetic, not native allocation-size arithmetic or all
of CamlinternalFormat.

## Queue, stack and output extents

At most E source operations enqueue a token. Flush may add at most E closing
tokens across the entire stream: each consumes a previously opened user box.
Initialization and flush resets introduce at most E+1 system-box tokens.
Thus at most `3E+1` queue insertions occur. The queue length and each live
format/scan-stack length are bounded by N; the scan sentinel adds one and
reset replaces, rather than retains, the old stack. This bounds the integer
length fields of the selected `Queue`/`Stack` operations, not total allocated
cells, heap bytes, recursive stack usage or allocator metadata.

Every formatted text token contributes its length to output. Each selected
box-opening, break or forced-newline token produces at most one newline and
68 indentation bytes, or at most one same-line space. A flush operation may
add one final newline; system boxes add no automatic break because they are
opened with fresh space 78 and indent zero. Consequently

```text
XML bytes offered to output <= B + 70*(E+1)
core output/flush callback calls <= 4*(E+1)
```

Default indentation uses the fixed 80-byte blank string. Here indentation is
at most 68 and same-line blanks at most one, so `display_blanks` never takes
its recursive `n-80` branch. This is an offered-byte bound conditional on the
core premises; it asserts neither physical delivery nor channel/file-offset
capacity. Shapes output is a separate channel and is not included.

## Auxiliary box-description formatters

Every `Acc_open_box` first calls `compute_tag`: a fresh Buffer16 and buffer
formatter print the annotation, flush, and take `contents`/`sub` before
`open_box_of_string` parses it. These allocations must not be omitted just
because tags are disabled on the XML formatter. For the four fixed selected
descriptions, raw annotation length is at most seven (`<hov 1>`), returned
description length at most five, and decimal indentation is absent or one
digit (`0`/`1`). There are at most E such helpers. Each helper sees one text
token and one flush, so the same core transfer applies with B=7,E=2.
Its Buffer16 does not resize on these seven bytes; its slicing indices and
box-description parser indices stay within the five-byte description.
This bounds those data extents; it does not count all helper closures,
accumulator records or native conversion/allocation operations.

## Remaining joins and scope

The packet evaluates the five candidate U values with d=20 and the imported
occurrence bounds. Every candidate passes the core guards. Actual bounds remain
null: later restored-path registrations, input/table/continuation contracts,
scalar service joins and private callback integrity are not established here.

| Case | Q | Candidate B | Candidate E | Conditional XML bytes offered |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 532 | 910,898 | 72,371 | 5,976,938 |
| Put | 451 | 771,890 | 61,299 | 5,062,890 |
| First_Or_Default | 295 | 504,782 | 40,077 | 3,310,242 |
| Is_Message | 45 | 77,394 | 6,179 | 509,994 |
| Input_Is_Valid | 49 | 83,840 | 6,656 | 549,830 |

The separate restored-path result's max-string fallback is intentionally far
too large for this guard; finite output alone is not useful capacity.

CamlinternalFormat accumulator construction and recursion, total allocated
objects and native layout, allocator/GC/stack resource joins, integer-parser
internals for box annotations, native channel and pathname/error/exit effects
still need composition. No complete-save or complete-#119 flag is set. Relevant
installed bytes corroborate the selected source route under the existing
[external behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary);
they are not a full binary refinement proof. The old zero-direct-identifier
formatter result remains a different claim. Oracle, tools/pins and admission
are unchanged; production #88–#94 remains unstarted.

Lead-authored; live model/effort and individual token/cost attribution are
unavailable. Round-level selected subagent settings and observed costs belong
in the aggregate round record. Independent acceptance is recorded there.
