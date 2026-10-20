# Retained timing-template Float_f extension

2026-10-20 UTC, Linux x86_64, research #119 / #153. Author base `825412d96b`;
selected GPT-6 Astra / Extra High, without runtime-setting or token/cost telemetry.

The static Debug Stats timing template `<stats>@[%s: %f, %d@]@.` can reuse the
[private formatter closure](retained-why-save-binder-formatter-stack.md) with
**zero additional OCaml bodies or own stack bytes**. Its unpadded, default-precision
`%f` has a **conditional 317-byte normal output bound**, including all binary64
special values under the retained scalar/libc relation. This extends the
formatter's selected format environment; it does not establish the state or
callbacks of the global formatter used by exit diagnostics.

The [packet](../evidence/retained-why-exit-timing-format-20261020/README.md) reads
retained Why/OCaml sources, the installed executable and existing disassembly.
It checks the selected bytes, branch tables, allocation arithmetic and capture
identities without running the target, a disassembler, an old checker or a solver.
The source/native transfer remains the existing
[scoped behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary);
the byte checks do not constitute binary refinement.

## Selected template and native route

`why3/src/util/debug.ml:183–187` passes the exact template to `Format.fprintf`
for each timing-map entry. The preceding registered-statistics `%t` template is
outside this extension. This packet supplies no timing-map size, update count,
counter-value or repetition bound.

`Float_f` is ordinal zero and `Float_g` ordinal three in the retained
`float_kind_conv` source. The installed relative dispatch table at `0x9ef180`
sends both entries to **`0x96f31c`**: `format_of_fconv`, the C bridge and
`caml_format_float`. The hexadecimal, `%F` decimal-point/special-value and
uppercase-map branches remain excluded. The character table at `0x9eea68`
sends Float_f to `0x968a0c`, which returns tagged character `f`.

The already selected no-padding/no-precision argument closure `fun_6659`
supplies tagged -6. `format_of_fconv` takes its absolute value and constructs
**`%.6f`**, four bytes, in a fresh internal buffer of capacity 16. Its index
never exceeds four, so this construction does not resize. Both the source
route and installed branch/constant witnesses are retained.

The template's bare `@[` additionally requires the empty annotation case.
The static format parser represents it as `Format(End_of_format, "")`.
`compute_tag` evaluates the empty accumulator, and `open_box_of_string ""`
immediately returns `(0,Pp_box)`. The existing box/token bodies cover this
case; no parser-helper traversal or invalid-box continuation is added. There
are no new token constructors, tags, tabs, dynamic formats or setting changes.

The static template has nine main accumulator nodes: literal `<stats>`, empty
open-box annotation, `%s`, literal `: `, `%f`, literal `, `, `%d`, close-box and
flush-newline. There are zero annotation nodes. Counting both terminators gives
at most **11 output_acc entries for this template's own evaluation**. This is
not a bound on any reentrant global output callback. The data strings total at
most `name_bytes + 11 + 317 + 20 = name_bytes + 348`; the template also requests
one flush/newline. A preserved default newline callback supplies one LF byte.
Queued output, indentation and callback behavior remain separate.

## Normal output and allocation bounds

The [scalar conversion packet](retained-why-save-scalar-format.md) supplies the
selected typed-source/native relation, GNU conversion contract and effective C
numeric-locale premise. Its previous `%g` bound does not cover `%f`; the following
arithmetic is the extension. For a finite binary64 value, the magnitude is less
than `2^1024`. Rounding to six fractional digits changes that magnitude by less
than one, and the exact integer check establishes `2^1024 + 1 < 10^309`.
Thus at most 309 integer digits are needed. One sign, one decimal point and six
fractional digits give **`1 + 309 + 1 + 6 = 317` bytes**. Signed zero also fits.
Under the retained GNU contract, infinity and NaN use `inf`/`nan` with an optional
sign, at most four bytes. The domain covers every binary64 value/bit pattern
whose selected conversion returns normally, including specials; it does not
assert success in the presence of a service error or a floating-point trap.

All five retained process records have `LC_ALL=C`. The checker matches both the
archives and extracted process records to the frozen capture manifest. This is
an observation, not proof that `caml_locale` was successfully initialized and
remained valid. Successful locale selection/restoration and preserved effective
C numeric semantics are still explicit premises. The actual continued-service
join remains false and the actual float-size export remains null.

The 128-byte first destination in `caml_alloc_sprintf` suffices only when normal
`n<128`. Values with `128<=n<=317` enter its long branch. That branch duplicates
the format, allocates the OCaml result string, performs a second `vsnprintf`
with destination size `n+1<=318`, and frees the saved format. The argument
therefore requires successful first and second formatting calls. A negative
first return takes the unsigned long-branch test and is outside this theorem.

The saved `%.6f\0` needs five payload bytes. `caml_stat_alloc_noexc` requests
either that size or size plus the installed 16-byte pool prefix, so the malloc
request is at most **21 bytes**, without assuming that the runtime pool is null.
Allocator metadata and rounding remain service-owned. The result string uses
`floor((317+8)/8)=40` payload words, or **328 bytes including its header**.
This is 296 bytes more than the prior unified 32-byte scalar result allowance.

The selected normal OCaml conversion requests these blocks, including headers:

| Object | Bytes |
| --- | ---: |
| Eagerly allocated, unexecuted hexadecimal closure | 48 |
| Internal format-buffer record | 24 |
| Buffer backing string, capacity 16 | 32 |
| Precision digit string `6` | 16 |
| Constructed format string `%.6f` | 16 |
| Converted result string | 328 |
| **Conversion subtotal** | **464** |

The selected returned float-argument closure is another **64 bytes** and its
`Acc_data_string` node another **24 bytes**, giving **552 bytes** for that wider
subtotal. The native reservation for the eager 48-byte closure precedes float
dispatch even when the hexadecimal branch is never called. These subtotals
exclude the other template nodes, formatter construction/queues, runtime/GC
allocation and callback work; they are neither aggregate heap bounds nor a
claim about physical memory sufficiency.

## Stack interface and remaining premises

The reusable OCaml expression stays **`F(H,J,O)=2392*H+176*J+32*O`** with the
Float_f and empty-annotation additions in `extension-spec.json`. Its old
private-save choice `H=4,J=64,O=68` is not automatically a global-exit choice.
An importing composition must justify its own simultaneous-instance counts
and supply the stated token, callback and formatter-state premises. This packet
does not assert that a preexisting standard/error formatter is fresh or empty.

The installed C wrappers have own bounds, including return slots: format_float
48, alloc_sprintf 400, stat_strdup 16, stat_strdup_noexc 32,
stat_alloc_noexc 16, alloc_string 32, alloc_initialized_string 32 and stat_free 8.
Their selected normal DAG has a **512-byte wrapper shell**:

```text
48 + 400 + max(32+32, 16+32+16, 32, 8) = 512.
```

This shell stops at explicit locale, libc formatting/string, malloc/free, small
allocation/GC and error-service frontiers. Normal `n<=317` selects the small
string-allocation arm, excluding the large-allocation/check-urgent-GC arm.
The shell belongs to **R**, separate from F; libc/allocator/GC internals and
bridge frames are not included. The existing 4,104-byte direct bridge interface
and ambient preparation **A_pre** remain separate.

Registered-statistics callbacks, timing updates, global queue/box/tag/tab state,
custom callbacks, formatter-setting preservation, service failures, reentrancy
and complete exit composition retain their existing owners. Global budgets
`r<=3` and `e<=2` are not reset. Complete-save, complete-exit stack and capacity
flags remain false. No Oracle, production source, tool pin or language change is
made; the earlier packets remain unchanged.
