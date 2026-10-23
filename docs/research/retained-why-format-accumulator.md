# Selected formatting accumulators: representation and finite progress

2026-10-23 UTC, #119 / #153. **Author candidate, pending independent review.**
This closes the selected CamlinternalFormat/Format accumulator and local-object
representation interface under the existing typed-state, source/native,
runtime-service and physical stack sufficiency premises. It supplies finite
structural descent and source-controlled object/operand bounds. It does not
prove allocator/GC/kernel operation or replace sufficient physical stack with
an aggregate quota. The [packet](../evidence/retained-why-format-accumulator-20261023/README.md)
contains exact source and retained native witnesses plus fifteen arithmetic joins.

Base `75ac621aeb` includes independently accepted
[R66 output/core/Buffer bounds](../reviews/review-printer-output-20261023.md)
at author `b5aad6d57b2f215ac047edb931314812c6687905`, and the separately
accepted raw-name/attribute origins. Those results are inputs, not rerun here.
Why3 source is `9390baf120ef260547dfa14f08e11c890b203d9c`; OCaml is
`8eb41f72ded84df884c3671734c947f612091f84` (4.14.2). The single global
`e≤2`, two save-entering callbacks, three saves and `E=3N+e` are unchanged.
No source, Oracle, tool pin, admission rule or current-grammar claim changes.

## Reached formatting routes

| Client | Actual continuation and owners |
| --- | --- |
| SMTv2, Driver wrapper, Pp separators, location and integer output | `Format.fprintf → kfprintf → CamlinternalFormat.make_printf → Format.output_acc`. Each call builds a fresh immutable accumulator rooted at End_of_acc. It passes the existing request formatter to its callback. |
| Name helpers | SMTv2 opens Format then Pp, so `sprintf = Pp.sprintf = Format.asprintf`. `kasprintf` owns Buffer512 and its formatter, then uses output_acc, flushes, obtains contents and resets. It receives one `%a` name callback. |
| Box annotations | Formatting_gen/Open_box creates a separate annotation accumulator. `compute_tag` owns Buffer16 and a formatter, prints that annotation, flushes, and slices its contents. Raw bytes≤7, parsed description≤5; descriptions are fixed, with absent or one-digit indentation0/1/2. |
| Syntax-index diagnostic | `Printer.int_of_string`'s broad catch uses `Format.eprintf`, hence the same make_printf/output_acc construction with shared stderr. Its already accepted64E/8E output fragment is unchanged. |
| Annotation conversion failure | `open_box_of_string` catches Failure from the tiny integer conversion and invokes `CamlinternalFormat.failwith_message "invalid box description %S"`. This owns **Buffer256**, builds an accumulator and consumes it with **CamlinternalFormat.strput_acc**, then raises Failure with its contents. It does not write to a Format owner or channel. |

The last route matters even though the fixed descriptions are valid: a
callback-origin Failure can reach the catch. The handler is outside that
conversion trap. It either raises its own Failure or escapes earlier; it cannot
repeat the annotation, return to the request, or recursively catch itself.
Therefore there is at most one attempted annotation-error message per request.
Its prefix is24 bytes, its escaped five-byte description is at most22 bytes,
and its whole message is at most46 bytes. Buffer256 never resizes on this route.
The accepted caller drops the propagated exception payload. This does not
assign zero to unrelated later exception rendering.

`Format.sprintf`/ksprintf's differently typed strput_acc path is absent from
the selected name helpers. SMTv2's explicitly qualified Format.sprintf in its
string-literal escape function is excluded by the accepted absence of string
constants. Model-output formatting is excluded by CE-off. No selected source
uses dynamic format substitution `%(...%)`, format-to-string `%{...%}`, a
Custom/Reader/Scanf node, runtime format parsing, dynamic format concatenation,
tags, tab boxes, Magic_size or ignored conversions. All driver templates and
preludes enter as string data. This excludes the generic recast/concat/parser
and custom-arity recursion, not merely its successful executions.

## Fixed formats and immutable accumulator shape

The finite source census covers every selected producer region, including
both alternatives of the fixed format branches. It conservatively includes
non-format string literals in those regions. The largest quoted source token
is90 bytes. The source-to-typed-format relation supplies a finite immutable
format tree: ordinary characters contribute literal nodes; each conversion or
format directive consumes source characters, and an opening annotation has a
separate fixed subtree. Counting wrappers and terminators conservatively gives
`R=4(90+1)=364` nodes per format and all its annotation subtrees. No datum
supplied at a call changes this tree or its length. `%s`/`%S` data and `%a`
values are payload pointers; a large body is not copied into the format AST.

`make_printf` consumes its current format constructor and continues on the
proper `rest`. Padding helpers receive that same proper rest. For Open_box it
first consumes the annotation subtree, then resumes on the saved proper rest;
the sum of unprocessed tree nodes decreases. It adds at most one main
accumulator cell per processed node, with a one-field annotation wrapper.
Arguments/continuations are fixed-arity closures, not arrays that grow with
the accumulated output. All selected formats have no precision; the only
argument padding is Number.print_in_base's `%0*o`, `%0*i`, `%0*X`, with width≤64.
`%a` creates `Acc_delay(old_acc, fun formatter -> printer formatter value)`;
`%t` stores its supplied fixed source callback in the same two-field form.

Every accumulator tail points to a strictly earlier constructed accumulator.
Annotation tails terminate separately at End_of_acc. None of these fields is
mutable, and no callback receives the accumulator itself. Induction on creation
therefore gives finite acyclic local chains/annotation trees of at most R nodes,
with no repeated link publication or variable-size array allocation.

`Format.output_acc` first recursively consumes the proper predecessor, then
executes exactly one action. For Open_box it consumes the independently finite
annotation before opening the main box. `Acc_delay` invokes its printer
synchronously after the predecessor; it does not put that closure in the
Format queue. One invocation contributes at most R+1 local descent frames.
CamlinternalFormat.strput_acc for the error message has just a fixed literal
and one converted string, with the same proper-tail progress.

Recursive printer callbacks can keep several such local descents live.
Their further work uses the already accepted finite body/type/binder/list
traversals, affine type templates, bounded rotation repeats and one-time
deferred lists. They do not recurse into an earlier accumulator. Substituting
these finite callback trees into the fixed local descents gives finite overall
work, even when native compilation retains ordinary recursive frames.
This progress argument does not infer a formatting-call count from emitted
core events. A `%a` callback can print nothing, and accumulator construction
can fail before any core event: the former returns after its finite selected
source traversal, and the latter abandons a prefix of a fixed format tree.
Neither creates a cycle or a fresh retry. Literal scalar continuations consume
the selected finite support/fallback chain; they do not reenter an old local
accumulator. The source callback tree, rather than emitted-event cardinality,
supplies the outer well-founded measure.
The accepted service premise supplies actual stack space for the finite call
tree; no conclusion is drawn from a cumulative product fitting a machine word.

## Actual local object layouts

Under the selected 64-bit OCaml representation, each source field below is one
word. Payload strings and closures are referenced, never flattened into the
containing record. The source declarations and reached constructors, compiler
closure lowering and retained instruction bytes support these layouts.

| Object | Payload words |
| --- | ---: |
| Accumulator atom / delay / formatting-gen cell | at most2 |
| Open_box annotation wrapper, option or ref |1 |
| Selected immutable format constructor | at most4 |
| Formatting Break / ordinary break tuple |3 |
| Pp_text / Pp_begin / Pp_break variant |1 /2 /2 |
| Queue element / scan entry / format-stack entry |3 /2 /2 |
| Queue wrapper / queue cell |3 /2 |
| Stack wrapper / list cell |2 /2 |
| Buffer record |4 |
| Formatter record |28 |

The formatter's five stack fields and all its scalar/callback fields are
fixed; its queue is a linked owner. R66 already bounds the queue/stack length
fields and depth. A long queue or a deep callback tree does not enlarge one
cell. After an interrupted queue/core mutation the selected private owner is
abandoned, so no additional dirty-reuse representation claim is needed here.

Compiler closure lowering uses a fixed list of function descriptors and free
variables (`cmmgen.ml:368–408`). A captured term, map, formatter or previous
closure occupies one environment slot. The selected dynamically created
closure classes are exhausted as follows; captures count stored values, not
the structures those values reference:

| Formation site | Dynamic group and captured environment |
| --- | --- |
| make_printf argument functions, make_padding and make_int_padding_precision | One function. The largest environment is drawn from `k, acc, fmt/rest, trans, iconv, padty, width, precision`: at most8 slots; selected precision-free arms use fewer. |
| `%a` delay / `%t` reuse | One delay function captures `printer,value` (two slots); `%t` references the existing callback. |
| Formatting_gen annotation continuation | One function captures `k,acc,rest` (three slots). |
| kfprintf / kasprintf / failwith_message continuations | One function; `k,formatter,buffer` are the largest combined set (three slots). |
| formatter_of_buffer and default newline/blank adapters | Partial applications capture an existing Buffer/formatter; their compiler curry cells are treated separately below. No recursive dynamic group is created. |
| open_box_of_string | One invalid_box closure captures `str`; the only dynamic mutually recursive formatting group has three scanners, with shared `str,len` (two slots). |
| String.escaped | Its recursive scanner has no external environment beyond its parameters; static or a fixed empty-environment closure. Bytes.escaped uses scalar loop state, not a closure group. |
| Selected Why3 printer callbacks | Local closures in print_par, type/term/header printing, template replacement, list separators and integer printing capture existing `info/fmt`, source arguments or scalar references. The largest template callback environment is `args,tys,t,print_arg,print_type`; global_substitute's local replace uses `search_fun,repl_fun,text,fmt,len`. Deferred-print callbacks capture existing lists rather than their elements. print_decls captures `vc_loc,vc_attrs,args,info,fmt`; Number's aux captures `radix,fmt`. No selected local group has more than one function here. A conservative16-slot allowance includes the remaining fixed local continuations and ordinary lexical state. |

The top-level mutually recursive Format/CamlinternalFormat and SMTv2 groups
are static module values; a call does not reconstruct their whole global
closure group. The only reached dynamic group has at most three members;
every dynamic environment above has at most16 slots. The compiler emits at
most four descriptor/infix words per member plus these captured slots, so
`4×3+16=28` bounds their payload. This source formation argument is the
universal local bound; it does not infer coverage from a largest observed
header. The retained instruction inventory corroborates the lowering and
also includes excluded generic branches.

Generic partial application adds a
four- or five-word closure referencing the previous closure and argument
(`cmm_helpers.ml:1997–2027`); it does not copy all accumulated arguments into
a growing block. The relevant installed-module instruction inventory has
maximum closure payload103 words, in an excluded dynamic-format parser.
The packet uses a conservative **128-word bound for every selected fixed
non-string formatting object**, or1032 bytes including its header. This is
a local representation bound, not a promise that an allocator has that space.
Retained native function/closure witnesses corroborate these concrete routes;
the scoped external source/native behavior relation remains required.

## Strings, scalar conversions and allocation operands

The main single-token payload is at most347 bytes by R66's driver/literal/name
census; names are at most163/163/157/126/130 bytes. Raw comments have at most
74/74/71/56/58 bytes. `%S` uses string_to_caml_string, String.escaped and
Bytes.escaped. The escape pass increments its length by1/2/4 per input byte,
so the intermediate escape is at most4Lc and the quoted result at most4Lc+2
(at most298 bytes). The loops use indices bounded by the source input length
or allocated escaped extent; the final quote addition is represented.
String.escaped's unchanged-string branch aliases immutable input safely.
Characters use String.make1; annotation slices have length≤5 and endpoints≤7.

Scalar `%d`/`%i` conversions include represented location coordinates and sort
arity. Selected native integers are signed63-bit values; their decimal output
has at most20 bytes including a minus sign. Number.print_in_base uses native
conversion only when BigInt.is_int succeeds; its nonnegative octal/hex/decimal
values need at most21 bytes. The actual native format strings are fixed `%d`,
`%i`, `%o`, `%X`, with no width or precision passed to C. `parse_format`'s
32-byte local format buffer easily contains each two-byte string plus the
selected integer suffix and terminator. Linux's caml_alloc_sprintf uses a
128-byte temporary; the existing faithful C99 integer-formatting service
premise gives `0≤n≤21`, so its small-result branch allocates exactly n bytes.
No arbitrary libc format string or encoding conversion is supplied.

Padding is applied afterwards in OCaml. With width in[0,64], abs(width) is
safe; fix_padding either returns the existing string or makes at most64 bytes.
Every destination offset is width−length (plus the guarded sign/prefix
adjustment), and the blit length is the remainder of that same input. The
guards width>length, length>0/1 prove the subtraction and slice endpoints.
No selected precision path calls fix_int_precision; no integer alternative
format invokes transform_int_alt's underscore insertion. BigInt digit-state
and its arithmetic service remain in the separate selected scalar/input owner
interface; this result consumes the accepted value/output envelope.

open_box_of_string scans a description of at most5 bytes. Each recursive
scanner increases an index until that bound; its substrings remain inside the
description. Its nonempty indentation substring is one decimal digit0/1/2.
The selected runtime integer parser's sign/base scan, accumulation and terminal
check therefore use those bounds. A Failure takes the bounded error route
above. Scanner faults cannot mutate the main formatter before its open action.

For every string or bytes allocation of n bytes, the retained native source
uses `w=(n+8)/8`, clears word w−1 and writes the padding count at `8w−1`.
R66 supplies `n≤2^57−9`, including the clamped request Buffer capacity. Hence

```
n+8 ≤ 2^57−1
1 ≤ w ≤ 2^54−1 = Max_wosize
0 ≤ 8w−1−n ≤ 7
8(w+1) ≤ 2^57
```

The rounded payload fits the selected header word-size field; its header plus
payload, byte offsets, length copies and padding arithmetic fit native unsigned
size/pointer-offset operands (and are below max_int). Header tags and colour
bits occupy their separate low bits. The full Buffer's **temporary doubling**
may equal2^57, but R66 proves the allocation clamps before this string routine;
the temporary is never treated as n here. Buffer contents/sub results on name,
annotation and error routes use their actual smaller bounds. Each individual
string layout is joined in result.json; all15 rows pass.

## Scope and source correspondence

The concrete relation required of the identified installed gnatwhy3 is: its
reached fixed format constructors, make_printf branches, continuation/closure
layout, immutable accumulator traversal, Format adapter calls, escaping,
small scalar conversion, annotation failure and string-allocation rounding
follow the retained source behavior described above. The existing
[external behavior premise](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
authorizes that scoped relation; it is not a premise that all programs fit.
The packet reuses the retained disassembly, checks selected instruction bytes
against the identified executable and freezes the witnesses. No new
disassembler, native invocation, compiler, proof, solver or capture runs.
Neither a historical build attestation nor universal binary refinement is
claimed.

Within this scope, no indispensable accumulator representation or structural
progress lemma remains open once its providers/premises are supplied. Actual
allocator/GC success, physical stack/memory, channel/kernel progress and
unwinding behavior retain their existing external assumptions; ordinary
environmental exhaustion is not a new language limit. Private printer maps,
shared-stderr whole-interval composition, other failure boundaries and the
whole #119 rule remain separate. A finite native operand proof does not
establish a complete resource reservation or whole-printer guarantee.

Selected author setting: GPT-6 Astra / Extra High. Runtime confirmation and
token/cost telemetry are unavailable. Exact inputs, observed elapsed time,
focused checks and rework are recorded in the packet's round.json. Root owns
issue/memory/publication bookkeeping. No GitHub or harness write is made here.
