# Selected save typed formats and accumulators

2026-10-20 UTC, #119 / #153 Round 33; five retained Linux x86_64 processes,
base `2cb11d8b5dcb7146694103616d1abea13ab8808d`.

The selected save uses **29 static format call sites**. One invocation builds
at most **26 main accumulator nodes**, or **27 including its box annotation**.
Variable string length does not increase these chains. The transfer below
bounds construction attempts, evaluation visits and native accumulator/format
continuation storage, including abandoned prefixes and the global budget of
three saves. It also closes the fixed box-description parser's successful
representation arithmetic. It is not a whole-formatter allocation or native
stack theorem.

The [packet](../evidence/retained-why-save-format-accumulator-20261020/README.md)
binds the finite template census, source cases and retained installed instruction
bytes. Every template's literal bytes also occur in the retained executable;
this corroborates fixed data, not a complete typed-AST refinement theorem.
This is a reviewable source/native argument under the existing behavior
relation; the checker does not prove its semantics. No native execution,
disassembler, capture, fetch, solver or predecessor checker was run.

## Exact roots and static typed formats

The XML roots are `Session_itp`'s `opt`, prover/attribute/result/path/attempt,
identifier, goal/transformation/theory/file printers and `save` itself
(`session_itp.ml:2019–2209`). Include `Pp.space` for transformation arguments,
the shapes header's `Format.asprintf`, and `Termcode.string_of_shape`'s single
`Format.asprintf "%a"`. There are 27 format sites in the session slice and one
in each of `pp.ml` and `termcode.ml`. The commented `save_option_def` contains
no format call. Error diagnostics outside these roots retain their own owner.

Every format argument at these sites is a fixed OCaml literal. Under the
selected typed-source/native relation, its `Format(fmt,text)` value and typed
`fmt` constructors are fixed program data established before the selected cuts.
There is **no dynamic typed-format AST construction** during this stream:
no `%(` substitution, `%{` format argument, `Custom`, reader, ignored argument,
variable width/precision or dynamically parsed format occurs. `fprintf` and
`asprintf` select their existing `fmt` field and call `make_printf`; they do
not parse `text` at each invocation. This does not charge the binary's existing
static data as newly allocated save storage.

The bounded census recognizes exactly `%s`, `%i`, `%d`, `%g`, `%b`, `%a`,
literal runs, ordinary breaks/newlines/closes/flush and the fixed boxes `<h>`,
`<v 0>`, `<v 1>`, `<hov 1>`. Literal runs produce one string/character node;
each directive/conversion produces one main node. An open box additionally
has one literal annotation node. These rules correspond to the retained
`CamlinternalFormat` format constructors and literal/parser cases. The maximum
is the prover template: 26 main nodes plus one annotation node. The largest
template text is 103 bytes; none contains recursively nested annotation formats.
The maximum number of `%a` nodes per template is four.

`%s` uses `make_padding` with `No_padding` and the identity string conversion.
It stores the existing string reference in `Acc_data_string`. `%a save_string`
calls `Pp.html_string`, whose byte loop calls only `pp_print_string` or
`pp_print_char`. Thus `@`, `%`, angle brackets and arbitrarily long valid data
strings cannot grow or alter the typed format. HTML output, single-character
strings, escaped token bytes and queues belong to the existing core/data
charges, not to the accumulator-node count.

## Construction and evaluation invariant

`CamlinternalFormat.make_printf` builds an immutable reversed accumulator
(`camlinternalFormat.ml:119–140,1515–1605`). For a selected ordinary node it
creates one `Acc_*` node, or returns a finite argument-taking closure that
creates that node when applied. `%a` captures its printer and value in one
delay closure; it does not call the printer during accumulator construction.
The open-box branch constructs the one-node annotation accumulator, then
creates an `Acc_open_box` wrapper and main `Acc_formatting_gen` node before
continuing with the remaining main format. `End_of_format` calls the existing
continuation. Numeric arguments use only the no-padding/no-precision branches;
their converted strings retain the [normal d=20 contract](retained-why-save-scalar-format.md).

Each step consumes a node of the fixed format or its annotation. Returning an
argument closure suspends that finite suffix; applying it does not restart
earlier construction. There is no mutation or cycle introduction in an
accumulator. Each successful or interrupted invocation therefore creates at
most its census number of nodes, even if output subsequently raises. The
argument remains valid when no output byte has yet been offered.

`Format.kfprintf` and `kasprintf` both use `Format.output_acc` here. The shape
`asprintf` uses **output_acc**, not the differently typed `strput_acc` used by
`sprintf`. `output_acc` first recursively visits the predecessor, then emits
the current node. It is non-tail recursion over a chain bounded by 26; it does
not recurse through the bytes of an `Acc_data_string`. The `%a` delay is
executed synchronously after the predecessor. Annotation evaluation uses a
fresh private Buffer/formatter and its separate one-node accumulator.

The selected `%a` call graph has at most **two simultaneous formatted
invocations within one save**:

- The outer goal/theory template may call `save_ident`, or an attribute helper,
  whose inner template ends in HTML/scalar printing.
- The outer prover/attempt template may call an option/attribute template,
  whose remaining printer is HTML or `pp_print_int`.
- The outer transformation template calls `Pp.print_list`; an argument or its
  separator invokes one inner fixed template. Items finish before the next.
- The file template calls `save_file_path`; each component finishes its inner
  fixed template before the next. `pp_sum_shape_version` prints one fixed digit.
- Shape `asprintf "%a"` calls the list printer with `Pp.int` and constant `H`;
  neither callback constructs another typed-format accumulator.

The goal/transformation forest recursion is outside completed opening-format
calls. It does not retain one unfinished opening accumulator per forest level.
It still retains serializer/native frames, which are a separate stack charge.
List and HTML callback work is not declared constant: HTML takes at most U
byte iterations per save, arguments at most Args item visits, and a shape list
at most M visits per goal under the accepted operational `M=max(m0,J)` bound.
Those callbacks have no additional recursive typed-format construction.

The installed `Pp.print_list_pre` repeats by a native backward jump after its
two callbacks, while `print_list` tail-jumps to that loop; `html_string` also
loops without accumulating a native frame per byte. Their callback/core costs
remain additional. This distinguishes finite source traversal work from
linear native recursion.

## Computable occurrence and storage transfer

Reuse the occurrence quantities and their continuation premises from the
[operational transfer](retained-why-save-operational-bounds.md). Let
`Q=1+F+Th+G+T+Axml+A+Args+Paths` and let `1<=r<=3` be the **global remaining
save budget**, as in the [Round 32 input join](retained-why-save-path-input-join.md).
Do not restart this budget at ordinary save entry.

Count evaluations of a format expression even if construction/output aborts.
A conservative weighted bound per attempted save is

```text
C = 6 + 4F + 4Th + 6G + 3T + 8Axml + 3A + 2Args + Paths <= 8Q
O = 1 + 2(F+Th+G+T) + Axml + A + Paths                 <= 2Q
Z = 27C
```

C includes the fixed prolog/root/close/flush/header calls; each file/theory's
opening, identifier/attributes and closing; each goal's opening, identifier,
explanation, proved attribute, shape `asprintf` and closing; each transformation's
opening/proved/closing; up to eight calls per attempt; three per saved prover;
one per argument and separator; and one per path component. Empty/omitted
branches reduce the count. The number of saved provers is at most A. O counts
the actual syntactic box openings, improving the old safe but loose `O<=E`.
The five selected cases have no proof-script paths; Paths already counts the
remaining file path component occurrences.

Consequently there are at most Z new accumulator nodes, `Z+3C` make_printf
dispatches, `Z+3C` output_acc entries and `4C` `%a` executions per save. The
three includes one main terminator and up to two annotation terminators per
template. These are implementation visits, not CPU instruction or GC bounds.

The retained native branches give the following requested block sizes,
including each OCaml block header:

| Selected construction | Native charge |
| --- | ---: |
| Ordinary two-field accumulator node | 24 bytes |
| Open-box wrapper | 16 bytes |
| String/Boolean argument closure | 64 bytes |
| Integer argument closure | 72 bytes |
| Float argument closure | 64 bytes |
| `%a` argument closure, delay closure, optional unary curry bridge | 64 + 40 + 40 bytes |
| Open-box continuation | 56 bytes |
| `fprintf` wrapper plus `kfprintf` continuation | 48 + 40 bytes |
| `kasprintf` accumulator continuation | 48 bytes |

The `%a` node plus its three closures costs at most 168 bytes. The open-box
main node, wrapper and continuation cost 96 bytes; its annotation node is
counted separately. Other selected nodes are cheaper. Thus **192 bytes per
counted node** and **128 bytes per attempted format expression** safely cover
the displayed accumulator and Format-owned continuation/argument blocks:

```text
requested accumulator/format-continuation block bytes <= 128C + 192Z
interval subtotal                                      <= r*(128C + 192Z)
```

This is an aggregate requested-block subtotal for a named class of allocations.
It does not count GC relocation, unused allocation-region reserve, allocator
metadata, static ASTs, converted scalar strings, one-character output strings,
caller-built partial printer closures, Buffer/formatter/core objects or callback
internals. In particular, it is not derived from B or from offered XML bytes.
An allocated delay can exist even when its callback prints nothing.

Native selected `make_printf` suffix/annotation transitions are backward or
tail jumps; each argument closure and open-box continuation restores its frame
before jumping back. There is **zero direct native stack growth per consumed
format node**. Numeric converters, callback bridges, GC and signal machinery
are additional and are not covered by that statement.

Each installed `output_acc` frame reserves 24 stack bytes plus its eight-byte
return slot. Allow 32 main nodes (above the actual maximum), the terminator,
two simultaneous formatted calls and one two-entry annotation evaluation.
Its own direct frame subtotal across all suspended/nested saves is at most

```text
32*r*(2*(32+1)+2) <= 6,528 bytes.
```

This counts only `output_acc` frames, including suspended outer frames. It is
not the process's stack requirement. The selected `make_printf` own frame is
48 bytes including its return slot; `compute_tag` has 48; other callers,
converters, core operations and runtime frames must still be composed.

## Fixed annotation parser, including its allocations

Each of the at most O box openings runs `compute_tag` on a one-node literal
annotation. The [accepted core transfer](retained-why-save-formatter-core.md)
already covers its private formatter with B=7,E=2 and Buffer16 without resize.
`compute_tag` takes a substring excluding the two delimiters. The four returned
descriptions are exactly `h`, `v 0`, `v 1`, `hov 1`; lengths are at most five.
No variable formatted output enters this parser.

`open_box_of_string` scans spaces, a lowercase word and an optional integer
(`camlinternalFormat.ml:1968–2005`). Its indices stay in `[0,5]`; every tested
character is strictly before length. Each scan's recursive step increments an
index by one. Five scanner invocations, each at most six entries, give **30
source scan entries per helper**. The installed scanners use backward jumps
and a 16-byte own frame including return, with no per-character stack growth.
The substrings have lengths at most three for the box name and one for the
optional indentation. The returned indentation is exactly zero or one.

The optional `int_of_string` receives precisely `"0"` or `"1"`. The retained
C `parse_intnat` parses that digit, tests its trailing NUL, checks the string
length and the signed-63-bit range, then returns the tagged immediate. For
`"0"`, `parse_sign_and_base`'s `p[1]` is the valid string terminator; no prefix
is selected. There is no multiplication iteration, no overflow and no successful
heap allocation in this integer conversion. This closes the earlier annotation
integer-parser arithmetic gap without importing a generic unbounded parser
claim. There are at most O such conversions per save.

The normal installed parser allocates a 136-byte closure group and 24-byte
result pair. The returned description, box-name and optional digit strings each
need at most a 16-byte OCaml string block. Thus **208O bytes per save** bounds
this additional parser/description subtotal, or `208rO` over the interval.
Its Buffer16 backing/record and formatter/core allocations are still separate.
For aggregation this packet exports at most O annotation Buffer/formatter
pairs, and at most G+1 other `asprintf` Buffer/formatter pairs per save.

The native parser's own frame is 64 bytes including return, plus a 16-byte
exception trap while converting its optional digit. `parse_intnat` uses five
saved registers and 32 local bytes, or 80 bytes including return;
`caml_int_of_string` uses 16, and `parse_sign_and_base` is a leaf. The runtime
C-call bridge, substring/string/runtime primitives and GC retain separate stack
charges; these fixed frame observations do not close their composition.

## Abandoned prefixes, nesting and applications

The [private formatter lifetime argument](retained-why-save-formatter-ownership.md)
applies to these same roots. A failing accumulator/core operation unwinds its
save; a higher catch may start another budgeted save, with distinct private
accumulator and formatter state. No local handler repeats an accumulator
construction or resumes a partial mutation. Argument evaluation, an interrupted
allocation prefix and completed accumulators whose output later fails are
charged to that attempt. Multiplying the per-save work by the existing global
r covers nesting and abandoned prefixes without assuming allocator reclamation.
It does not bound the allocator's own failed-service/GC work.

Under the named source/native and valid-value relation, faithful pending
callbacks/private frames, retained occurrences/global budget, and normal
numeric/allocation services, the five applications are:

| Case | C per save | O per save | Accumulator/format-continuation interval bytes | Parser/description interval bytes |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 2,877 | 645 | 45,847,872 | 402,480 |
| Put | 2,426 | 553 | 38,660,736 | 345,072 |
| First_Or_Default | 1,565 | 371 | 24,939,840 | 231,504 |
| Is_Message | 219 | 63 | 3,489,984 | 39,312 |
| Input_Is_Valid | 228 | 77 | 3,633,408 | 48,048 |

These are conservative capacity subtotals, not observed allocation totals.
The four explicit premises are required by the usable interface; absent/false
premises leave its bound null. The constant per-object sizes fit the retained
representation. Cumulative totals are mathematical charges, not claims that a
single object of that size is allocated.

Remaining obligations include aggregation with all scalar/character/Buffer/
formatter/core and caller allocations, native stack and GC/runtime capacity,
channel/path/error/exit behavior and failed numerical/allocation services.
The selected templates exclude format/parser errors on successful valid-state
evaluation; they do not turn arbitrary runtime failures into normal conversion.
Whole-formatter/save/pipeline flags remain false. Oracle, admission, production
code and tool pins are unchanged. Integration, aggregate review, issue/memory
bookkeeping and publication remain lead-owned.
