# Retained JSON byte escaping: fixed padding extension

2026-10-20 UTC, Linux x86_64, research #119 / #153. Author base `9fd8e81a45`;
selected GPT-6 Astra / Extra High. Runtime-confirmed model/effort and token/cost
telemetry are unavailable.

The exact `Json_base.char` and `Json_base.string` routes have a conditional
byte, direct-event, direct-allocation and owned-stack interface for **every
OCaml byte value**. For a string of length n the simple bounds are **6n+2 data
bytes, 2n+2 direct text operations, and 256n+72 requested object bytes before
Format core allocation**. These are mathematical ledger expressions, not
machine computations or physical capacity claims. A composition must check
its representation and core guards before using them.

The [packet](../evidence/retained-why-json-byte-escape-20261020/README.md) attaches
the exact `Int_x / Lit_padding (Zeros,4) / No_precision` route. This is a real
extension of the [private formatter selection](retained-why-save-binder-formatter-stack.md):
the previous selection explicitly excluded literal padding. Its new ordinary
formatter bodies add **64H bytes** to that parameterized owned-stack expression.
This packet does not silently reuse its old selection or private-save counts.
General JSON trees, arbitrary widths/precision, caller occurrence bounds and
preexisting global formatter state retain separate owners.

## Source, native attachment and services

The retained Why3 `src/util/json_base.ml:13–27` partitions bytes into seven
special escapes (`"`, backslash, backspace, LF, CR, tab, form feed), printable
ASCII 32..126 excluding quote/backslash, and the remaining bytes. The branches
use a static two-byte string, `pp_print_char`, and `fprintf "\\u%04x"`,
respectively. The last branch passes `Char.code c`, in 0..255. This is byte
escaping, including zero and bytes 128..255; no UTF-8 validation or general
JSON semantic theorem is implied.

The installed static format object at `0xb25170` points to a String_literal
`\\u`, then an Int node with tagged Int_x=13, a tag-zero padding block
`(5,9)` (Zeros=2, width=4), immediate No_precision=1, and End_of_format=1.
The native format dispatch selects the Int branch; the padding branch selects
`fun_6592` at `0x971130`. Its created closure reserves **88 bytes**, has ten
payload words (`0x28f7` header), and arity one. The ordinary no-padding closure
and a guessed source closure size would give the wrong allocation charge.

`convert_int` selects static `%x`, then `caml_format_int` constructs `%lx` in
its 32-byte C array and passes the nonnegative byte value as an unsigned long.
The retained GNU integer-conversion contract gives one hex digit for 0..15
and two for 16..255, using `0`..`9`,`a`..`f`, with no sign or base prefix.
`transform_int_alt` returns that string unchanged for Int_x.

`fix_padding` receives positive width four and a one/two-byte string. It always
creates four zero bytes, then takes the final Zeros arm: neither the sign nor
`0x` prefix predicate holds. `String.blit str 0 res (4-len) len` has source
range `[0,len)` and destination range `[4-len,4)`. All arithmetic and indices
are represented; `Bytes.unsafe_to_string` creates no copy. The checked native
branch, allocation and blit sites corroborate that source argument. It is not
a Python proof or a complete executable refinement.

The source/native relation is the existing
[scoped trusted external behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary).
The packet preserves the exact Why3/OCaml archives, existing disassembly,
installed executable identity, and the earlier formatter/scalar/core evidence.
It executes no target, disassembler, capture, old checker or solver.

## Data and prospective events

Let s,p,u count special, ordinary-printable and hex-escape bytes in one input;
`n=s+p+u`. These are a partition, with domain sizes 7,93,156. On an ordinary
complete evaluation, before Format suppression/queueing/output effects:

| Byte branch | Data bytes | Direct text operations | Non-core object bytes |
| --- | ---: | ---: | ---: |
| Seven special escapes | 2 | 1 | 0 |
| Other printable ASCII | 1 | 1 | 16 |
| Other bytes, `\\u%04x` | 6 | 2 | 256 |

The hex branch has two accumulator nodes (literal and data), followed by their
terminator; `output_acc` has at most three simultaneous entries for this
template. Each node requests one `pp_print_string` operation. There are no
boxes, breaks, flushes, tags, tabs, `%a` callbacks, dynamic formats or settings
changes in this template. Data never becomes format syntax.

`Json_base.string` prints a quote, iterates `(char fmt)` over its existing
immutable input, then prints a quote. Its exact prospective totals are

```text
B = 2 + 2s + p + 6u <= 2 + 6n
E = 2 + s + p + 2u = 2 + n + u <= 2 + 2n
```

These bounds include every possible byte and every abandoned prefix when the
prospective budget is assigned before conversion. They concern data supplied
to the formatter, not bytes physically delivered. A prior queue may drain,
default boxes may indent, depth suppression may drop a token, and custom
callbacks may do other work. A fresh-formatter composition may feed B/E into
the [core transfer](retained-why-save-formatter-core.md) only after joining its
settings, ownership, complete-stream bounds and integer guards. A standalone
string does not flush; a separately requested final flush adds one to E.

## Direct requested objects and failure prefixes

Charges include the eight-byte OCaml header, using
`S(L)=8*(1+floor((L+8)/8))`. The hex branch has these distinct objects:

| Object / reservation | Bytes |
| --- | ---: |
| `Format.fprintf` returned format-argument closure | 48 |
| `kfprintf` output continuation | 40 |
| `Acc_string_literal` node | 24 |
| Literal-padding integer argument closure | 88 |
| Raw one/two-byte hex result | 16 |
| Four-byte padded bytes/string object | 16 |
| `Acc_data_string` node | 24 |
| **Total before core** | **256** |

The fully supplied `caml_apply2` application does not allocate an intermediate
curry closure: it invokes the arity-one format closure and then the returned
arity-one integer closure. The converter's two arguments select its exact-arity
entry. Static formats, literals, converter closures and End_of_acc are shared.
No format Buffer, precision helper, grouped-integer transform or new four-byte
copy is introduced. `Bytes.make` calls one `caml_create_bytes` and one
`caml_fill_bytes`; `String.blit` is the checked `Bytes.blit_string` wrapper
followed by `caml_blit_string`, and allocates no object.

One string adds a 40-byte iterator closure and two 16-byte character temporaries.
Its complete normal non-core request bound is therefore

```text
Q_json = 72 + 16p + 256u <= 72 + 256n.
```

This owns all direct objects of these JSON/template/scalar operations, but
excludes core queue/token/stack objects, formatter creation, destination Buffer
growth, channels, callers, exceptions, GC and allocator internals. An importing
ledger must replace the corresponding generic argument/scalar charges with
this subtotal, or partition them explicitly; adding both would double count.
The prior `192 bytes per scalar slot` and no-padding accumulator interface are
not asserted unchanged for this new path.

The ownership relation requires immutable valid input, intact module/closure
bindings, synchronous selected callbacks that do not mutate/reenter the current
formatter, and no resurrection of an escaping partial invocation. Native
`String.iter` advances once per byte, each callback completes before the next,
and there is no retry/catch in either JSON helper. Allocation or output failure
may abandon any prefix, including after reserving an object but before a text
event. Charging all prospective sites bounds these prefixes without reclamation
credit. Repeated GC attempts and error-object construction remain runtime-owned,
not additional successful source objects charged to this ledger.

The numeric premise is explicit: a returning GNU conversion service supplies
the contracted 1..2-byte result and valid length, with normal allocation/string
service behavior. A negative `vsnprintf` return is **not** covered by the normal
result theorem: the installed unsigned comparison would enter the long branch.
The packet establishes no continued numeric-service success or physical ability
to allocate. Nonreturning service execution and unwinding keep their named
service owner; they create no subsequent JSON event. Actual joined exports stay
null. Under the normal-service premise, allocation/output/interrupt failures
and abandoned prefixes still have the stated caller-direct bounds.

The cumulative bound deliberately retains every old object. It consequently
bounds the new JSON-owned live-object subset under the ownership relation, but
does not bound preexisting input/queue objects, runtime retained copies,
fragmentation, heap reservation, GC metadata, allocator overhead or physical
resident memory. It is not a whole-heap or resource-sufficiency theorem.

## Stack closure, multiplicity and composition

The newly selected ordinary formatter bodies are `fun_6592` (16 own bytes,
including return slot) and `fix_padding` (48). `Bytes.make` (32) and
`Bytes.blit_string` (16) already occur in the earlier formatter basis; this
packet explicitly admits their padding invocations. Their calls end at the
named creation/fill/blit/GC services. Invalid bounds/sign/prefix/precision arms
are excluded by the preceding byte-range argument, not by symbol absence.

The JSON caller side owns `char` 32, `string` 32, `fun_941` 8 and `String.iter`
48 bytes. The iterator has a native back edge and one selected indirect target,
the created `fun_941`, which tail-calls `char`. It does not retain one frame or
allocate one closure per input byte. Counting even the tail-replaced return
slots gives **120 bytes per simultaneous string lane**, or 32 for a standalone
char lane. These are invocation ownership partitions, not globally unique
symbol ownership; a caller already charging String.iter must avoid duplication.

Writing H/J/O for justified simultaneous ordinary/adapter/output_acc counts,
the extended formatter basis is

```text
F_json(H,J,O) = (2392+16+48)*H + 176*J + 32*O
              = 2456H + 176J + 32O.
```

For one isolated non-reentrant byte/string lane under the earlier selected core
callback environment, `H=4,J=64,O=3` is a deliberately loose sufficient choice:
at most one formatted call is active; conversion completes before its output
continuation; ordinary core helpers and leaf Buffer/channel callbacks return
before the next queued token/byte; there is no annotation or serializer reentry.
The four ordinary and 64 adapter allowances from the wider private closure
overcount these remaining layers. Only `output_acc` descends its two-node
accumulator. Thus **21,184 formatter-owned bytes**, plus 120 (string) or 32
(char), give **21,304 / 21,216 owned OCaml bytes** to the named frontier. These
are conditional local lane bounds, not a substitution for the old per-save F.

An importing composition with nested JSON calls must supply simultaneous
lane counts and compatible H/J/O across its other callers. It may conservatively
add these lane bounds, or recompute the shared expression with explicit instance
ownership. Runtime-mediated reentry is counted in the global composition; this
packet neither rules it out globally nor restarts `r<=3` or `e<=2`.

The retained C wrapper shell is separate from F and belongs to R. On this
normal small-result path, own bounds are: `format_int` 80, `parse_format` 48,
`alloc_sprintf` 400, `alloc_initialized_string` 32, `alloc_string` 32,
`create_bytes` 16, `fill_bytes` 16 and `blit_string` 16. Its deepest selected
chain is **80+400+32+32=544 bytes**, ending at allocation/GC or libc services.
The first 128-byte formatting destination suffices; no saved-format C allocation
or second formatting call occurs. The parse array, variadic scratch and return
slots are included in these own frames; direct bridge/ambient frames, libc
formatting/copy/fill, allocator/GC and error internals remain separate. This
does not turn R into zero or establish physical stack headroom.

Complete formatter capacity, complete-save/exit stack and capacity, and whole
pipeline capacity remain false. Production code, tool pins, Oracle guarantees,
language admission, prior providers and prior evidence remain unchanged.
