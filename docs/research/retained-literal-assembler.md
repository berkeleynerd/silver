# Literal-output Main assembly and object interface

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This extends the reviewed null GAS/ELF transfer to the complete literal-output
source family recognized by the [literal aggregate](retained-literal-pipeline.md).
It establishes the emitted-stream, fragment, symbol, relocation and object-file
interfaces. Assembler subsidiary allocation/lifetime joins and final link reach
remain separate. It is not a whole-pipeline capacity verdict or production rule.

The [offline evaluator](../evidence/retained-literal-assembler-20261018/compose.py)
derives C calls, N null statements and W decoded literal bytes from the existing
complete source recognizer; it does not accept those counts from an author.
The selected O0/split-wide-types, CFI, target, no-debug/no-verbose-output and
source-correspondence premises of [final RTL](retained-output-rtl.md) and
[constant emission](retained-native-expansion.md#literal-output-selected-rtl-constructor-lifetimes)
remain required. Each literal length fits signed Integer. This packet neither
changes tool options nor establishes that those options are installed in Silver.

## Complete stream and sections

Use the established final-chain ceiling `I = 7C+7N+45` and text ceiling
`T = 31C+4N+22`. The null unit's fixed outline, CFI, file-end and property-note
inventory contributes at most 114 lines / 7,410 bytes. Keep that whole allowance,
then charge one line per final-chain object, even for deleted or nonprinting
objects. An instruction, ordinary label or CFI label has one line; the selected
CFI rules are the same five single-rule directives, and no new raw DWARF route
is selected. This deliberately also charges fixed null instructions/labels
already included in 114. Literal data adds its established W+8C lines and
13W+512C bytes. Thus:

```text
assembly lines / nonempty parser events <= 114 + I + W + 8C
assembly bytes                         <= 7410 + 65I + 13W + 512C
longest line excluding LF              <= 512
```

The register/call/LEA lines fit 64 bytes: the longest local label is at most
25 characters excluding NUL, the selected register spellings fit four, and
the external names are `silver_io__put` and `silver_io__put_line`. The call's
`@PLT` suffix is fixed text. No literal payload is interpolated into an
instruction. The earlier constant writer handles quotes/backslashes and bounds
both ASCII and base64 lines. No include, macro, source line marker or embedded
LF is introduced. The physical-line counter starts at zero and its sentinel
step is charged separately; require `lines+1 <= UINT_MAX`. The logical counter
remains disabled exactly as in the null stream. The scrubber therefore retains
its initial 65,539-byte individual buffer request.

The additional section is exactly `.rodata`, containing at most W+22C bytes
including alignment. The null union's other sections persist; `.text` changes
from its 26-byte bound to T. There are at most ten ordinary sections, fourteen
initial fragment chains including ABS/UND/internal sections, twelve final
subsection alignments, and ordinary payload at most `T + W + 22C + 394` bytes.
The constant 394 is the null payload 420 minus its 26-byte text contribution.
Optional SFrame remains conservatively charged, although the installed default
does not enable it. CFI/SFrame use the same bounded frame rules. Require T to
fit signed int, which also protects their four-byte location advances.

## Encodings, fragment allocations and regions

The selected GAS opcode entries give one REX byte, opcode, ModR/M and disp32
for each RIP-relative LEA (seven bytes), and one REX/opcode/ModR/M for each
DI register move (three). RIP addressing uses no SIB. Direct calls use opcode
0xe8 and four-byte displacement through `output_jump`, not the relaxable branch
constructor (`opcodes/i386-opc.tbl:192,287,490–491`,
`gas/config/tc-i386.c:11438–11456,11792–11886,12782–12864,13000–13148`).
Each LEA creates at most one fixup and each call one; register moves create
none. The existing frame/no-padding route supplies all other instructions.
These are the same 7/3/5 byte bounds used in T, now connected to GAS output.

No selected append/room request exceeds the existing 48-byte maximum. ASCII
and base64 append decoded bytes individually; each `.long` adds four bytes.
An alignment reserves one pattern byte, even when its final output padding is
zero. Thus, extending the null reservation count 432 conservatively gives

```text
Q = 433 + max(0,T-26) + W + 10C
F = 2Q + 2C + 62
```

Q adds literal bytes W, bounds bytes 8C, at most 2C alignment pattern bytes,
one `.rodata` final-alignment pattern and any increase in instruction bytes.
The two-per-byte charge covers append and preliminary room requests. F also
charges the earlier twelve preallocation calls, the earlier 35 variant closes,
2C pool-alignment closes, one additional final-alignment close, and fourteen
initial fragments. Zero-length probes do not allocate. Branch padding and its
forced per-instruction fragment split remain disabled. The earlier
[fragment backing proof](retained-assembler-capacity.md#null-unit-sections-and-final-fragments)
therefore gives one 4,064-byte chunk request at most per allocation, besides
the fourteen initial obstack chunks. Require F to fit the actual unsigned
`totalfrags` counter. This is an event bound, not an aggregate RAM gate.

Each section's region counter starts at zero. Only alignment and `.org`
increment it (`gas/write.c:2681–2739`); this stream has no `.org`. The new
`.rodata` has at most 2C pool alignments plus its final alignment. All other
sections retain the null bound of ten. Require `max(10,2C+1) <= 65535` for the
stored 16-bit field (`gas/frags.h:69`). This sufficient rule is derived from
actual alignment events; it is not a claimed inherent call-count limit or
proof that wrapping would necessarily fail for this family. Refining away an
irrelevant region bound would require a consumer argument.

## Symbols, relocations and the ELF file

Reuse all 90 null GAS symbol allocations, including the two non-output
predefinitions. Add I for every chain object, 2C pool labels, one `.rodata`
section symbol and the two external output names. This gives
`S = I + 2C + 93` allocations; it deliberately double-charges null body labels.
Forward references and later definitions reuse their symbols. Local-to-full
conversion retains the object/name and allocates only the already-accounted
extension/BFD symbol. The BFD allocation ceiling is S+15 (fourteen section
hooks and static dot); the output-chain bound is S-2.

The selected `@PLT` operand does not create a GOT symbol: the `PLT` row of
`gotrel` has `need_GOT_symbol=false`. `lex_got` removes that suffix before
ordinary expression parsing (`gas/config/tc-i386.c:1400–1402,13376–13445`). Its
temporary copied operand fits the 64-byte instruction-line bound plus two
terminator bytes. The selected expression remains one symbol, so no general
expression-wrapper or version-renaming route is introduced. Fixed output names
and local decimal labels still fit 26 bytes including NUL, and every serialized
symbol name still contains no literal `@`; the earlier constructor argument
applies after suffix removal.

Constant data has no relocation. Adding the 2C LEA and C call fixups to the
existing 279 gives `3C+279` fixups and `R=3C+281` relocations after the optional
two build-note entries. `output_disp`/`output_jump` and `fix_new_exp` reuse the
named symbols; the ordinary x86 relocation writer emits at most one relocation
per fixup. The existing 128-byte fixup, 32-byte arelent and 8-byte pointer-cell
individual request bounds remain. Relocation resolution/reach at link time is
not established by these counts.

The [ELF writer argument](retained-elf-object-capacity.md) now has ten ordinary
sections, at most ten relocation sections and the four fixed headers: 24 section
headers. Mapping can append at most ten existing section symbols. Including
the mandatory null symbol gives `Y=S+9` serialized symbols. The two string
tables have at most Y-1 and 23 nonempty names, respectively, with at most
26/32 bytes per name and Y-1/46 positive references. The [generic string-table
conditions](retained-linker-capacity.md#elf-string-table-input-contract) must
still hold for their own growth/offset consumers; small-null no-growth backing
bounds cannot be reused for variable S.

Ten ordinary and ten relocation placements need at most 26 alignment events,
each adding seven bytes. The complete object-file envelope is

```text
64 + (T+W+22C+394) + 24Y + 24R
   + (1+26*(Y-1)) + (1+32*23) + 26*7 + 24*64.
```

All arithmetic in the evaluator uses mathematical Python integers. It exposes
separate checks for line/fragment/region counters, text, GAS/BFD signed symbol
indices, relocation counts, four-byte string offsets, and 64-bit file/request
products. Its result is conditional on the source/configuration premises; its
`whole_literal_pipeline_capacity_established` remains false. Remaining joins
include GAS notes/hash/parser and BFD arena lifetime/growth, selected invocation
paths, fixed objects/binder composition and final link displacement. Passing
the examples or these local checks cannot close those obligations.
