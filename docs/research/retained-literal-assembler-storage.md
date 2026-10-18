# Literal-output GAS and output-BFD storage composition

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This consumes the independently reviewed
[literal assembly/object interface](retained-literal-assembler.md) and extends
the reviewed [null allocation inventory](retained-assembler-inner-allocation.md).
The [callable composition](../evidence/retained-literal-assembler-20261018/storage.py)
keeps selected command/configuration premises explicit. It closes the variable
GAS/BFD storage interface under those premises; production invocation, other
objects and final-link composition remain required. No native process ran.

## Reached allocation routes

The existing 40-C-module/37-header GAS inventory and its 264 lexical allocation
occurrences remain the completeness cross-check. New output introduces `.rodata`,
pool labels, ordinary `.long`, `.ascii`/`.base64`, RIP-relative LEA, register
moves and direct calls. It adds no macro/include, debug, symbol version, group,
TLS, CFI rule, local EH, branch-padding or additional function route. The
ordinary null dispatch/cleanup exclusions therefore continue to hold with
these concrete changes:

| Changed route | Storage/counter transfer |
| --- | --- |
| `.ascii` | `stringer` and `stringer_append_char` decode and append characters to the current fragment, without an intermediate heap string (`gas/read.c:5983–6146`). Escapes are those produced by the reviewed GCC writer, so no malformed-string/error branch is used. |
| `.base64` | `s_base64` uses a four-element automatic group, decodes into one-byte fragment appends and accumulates at most 255 decoded bytes per generated directive (`gas/read.c:5780–5980`). The unsigned-long `num_octets` cannot approach overflow. ELF x86 uses one octet per byte, so no additional target padding occurs. |
| `.long` bounds constants | The existing integer/expression parser and fragment path; two nonnegative signed-32-bit integers per bounds record. There is no symbolic relocation or large-integer parser demand. |
| RIP-relative LEA and direct `@PLT` call | Existing ordinary instruction/fixup routes plus `lex_got`'s single temporary operand copy. Its `first+second+2` request is at most 66 bytes from a 64-byte instruction line. No GOT symbol, TLS/complex-relocation wrapper or Intel-syntax path is introduced. The previous four instruction-parser fallback/retry buffers remain at most 67 bytes. |
| `.rodata` and pool labels | One additional section/chain/segment-info object and up to 2C local symbols; conversion/reference storage is already in the reviewed symbol ceiling. Section names fit 32 bytes and retain subsection zero. |

The selected valid expressions remain constants, symbols and bounded fixed
metadata differences. There is no symbol cycle, volatile/equated redefinition,
arbitrary expression wrapper or deferred `.eqv` clone. CFI expression-location
records and optional SFrame storage keep their earlier fixed ceilings. Final
relocation and output-symbol arrays use the variable counts below. Ordinary
local-to-full symbol conversion adds its existing extension/BFD object, not a
second name or uncounted GAS symbol.

The earlier relaxation argument also transfers. Instructions use fixed-size
encodings, literal data uses fixed `rs_fill` fragments, and pool alignment uses
ordinary constant alignment with no maximum-skip or symbol-dependent origin.
The initial sequential address pass already computes those alignments. Its
relaxation sweep therefore has zero growth. The existing CFI advances reserve
their full four-byte form before relaxation; they introduce no new dependence
on literal data. There is one inner sweep and at most two outer section walks,
as in the [selected fixed point](retained-assembler-invocation.md#selected-relaxation-fixed-point).
With the interface's `F<=UINT_MAX`, even the unsigned-long `frag_count²`
iteration-limit product fits the selected 64-bit type. Region/offset/line
checks remain the separate interface predicates.

## GAS hashes and obstacks

Let S be the interface's GAS allocation ceiling and R its relocation ceiling.
The fixed opcode/register/pseudo-op/macro tables retain the reviewed maximum
notes request 65,528 bytes. The direct-heap symbol table may now grow. Its live
and ever-occupied keys are bounded by S; replacing an existing key does not
create another occupied key. The source's pre-lookup growth test is charged
even when the subsequent lookup hits. Every reached pointer capacity is at most
the least libiberty listed prime `p >= max(1024,2S)`
(`libiberty/hashtab.c:134–193,517–575,633–695`). The evaluator requires that
prime to exist, `2p-3<=UINT_MAX` for the 32-bit probe addition, and `8p<=PTRDIFF_MAX`.
Size/load products and element counts use 64-bit size_t and fit these bounds.
The diagnostic search/collision counters keep their defined modular behavior;
they do not affect equality or allocation decisions. This uses the GAS
libiberty table, not the different GCC C++ or BFD hash-growth formula.

Fourteen frchain objects still fit one initial 4,064-byte chunk:
`32+14*(192+15)=2930`. The fourteen fragment obstacks and variable fragment
allocation count keep the separately established 4,064-byte individual chunk
ceiling. The conditional obstack stays empty after its initialization.

For the five-argument vector `AS --64 -o OBJECT ASSEMBLY`, let P bound each
actual path spelling including NUL. The shared notes object bound becomes

```text
Q = max(65528, 8R, 8(S-2), 48, P).
```

The variable terms are the relocation pointer array and final GAS symbol
pointer array; 48 is the six-pointer filtered argv including its terminator.
All other typed objects, tuples, name copies and startup formatting fit the
fixed allowance. `lex_got`'s scratch uses direct heap and is separately at most
66 bytes. The notes close composite now has fourteen obstack pointers plus its
terminator, at most 120 bytes. The largest unfinished prefix is therefore 120,
while larger Q-sized bulk requests finish before another request. With mask
at most 15, `_obstack_newchunk` has

```text
partial + append + mask + (partial >> 3) + 100 <= Q + 250.
```

Require `max(4064,Q+250)<=PTRDIFF_MAX`. This updates the null proof's 112-byte
prefix/241-byte overhead rather than silently reusing it. Completed objects,
old hash backing and realloc overlap can retain physical storage; their sum
is not an admission RAM gate. The relevant counters/requests are bounded
separately.

## Output BFD and its separate string-table arenas

The one-output-BFD lifecycle, writer guard and no-compression/no-group/ET_REL
exclusions are unchanged. Ten ordinary sections plus two internal and two
static ABS/UND sections give at most fourteen section metadata requests. The
section hash still starts at 13 and grows to at most 31: even fourteen entries
lie below its next growth threshold 23. Every section hash entry fits 576 bytes,
ELF section data 320, BFD control 1,024, target data 4,096 and output data 192.

Using the reviewed writer's allocator domains, the output BFD's main objalloc
receives the following lifetime raw-byte sum. Ordinary-heap symbol serialization
arrays and independent hash arenas are intentionally kept separate.

```text
P + 4096 + 192 + 14*320                 startup
  + 128*(S+15)                        all BFD symbol allocations
  + 10*80 + 10*32                     relocation headers and their names
  + 24*8 + 80 + 14*8                  header pointers, null header, section map
  + 8*(S+8)                          reordered output-symbol pointers
  + 24R + 24*64                      relocation buffers and serialized headers
= P + 136S + 24R + 13792.
```

This bounds the unsigned-64 `alloc_size` updates without invoking its separate
linker-statistic erasure argument. Individual objalloc requests q require
`q+23<=PTRDIFF_MAX`, covering eight-byte rounding and sixteen-byte headers.
The largest main-arena q is `max(P,4096,8*(S+8),24R,1536)`; other raw metadata
requests are smaller. The ordinary symbol serialization arrays remain 40Y and
24Y bytes, already checked by the interface, for Y=S+9. Header-only relocation
sections do not create extra asection objects or section hash entries.

Apply the [generic ELF string-table contract](retained-linker-capacity.md#elf-string-table-input-contract)
to two distinct arenas: symbol names D=Y-1, length including NUL at most 26,
and section names D=23, length at most 32. Their positive-reference ceilings
are Y-1 and 46. The existing writer establishes additions-before-finalization
and balanced offset/reference uses; the number of symbols does not alter that
lifecycle. No rollback/save or copy-name route occurs.

Each BFD hash starts at 4,051; its exact larger-prime sequence is computed until
`D<=floor(3p/4)`. Require `D<=805306341` and every reached triple to fit unsigned
32 bits. The separate entry-pointer array starts at 64 and doubles to the least
power of two at least D+1. Sorting requests 8(D+1) bytes; each hash entry fits
64, and the control 96. All `copy=false` insertions retain existing names, so
there are no extra hash-name copies. The no-wrap name/refcount/offset conditions
remain explicit. Each arena's eight-byte request rounding and sixteen-byte
chunk-header addition fit the generic objalloc contract. There is no aggregate
allocation counter for these independent hash arenas to substitute for the
output BFD's main-arena counter.

This completes the selected GAS-owned dynamic-request coverage and the output
BFD storage join for the reviewed literal stream, conditional on all local
checks and the unchanged selected target/library/configuration behavior. It
does not materialize or validate a production command, prove final relocation
reach, or discharge the other compiler/producer/binder phases. The callable's
whole-pipeline flag remains false. The retained examples and boundary replay
check the arithmetic implementation; the source argument establishes why the
named consumers are reached and why the other allocation families stay absent.
