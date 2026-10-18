# Retained assembler input and frame-record transfers

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This joins selected GNU assembler representations to the
[null Main backend shape](retained-backend-gigi.md). It covers the selected
instruction encodings and frame serializers, but does not yet close every
output section, ELF symbol generation or linking.

The reviewed source is Binutils 2.46.1 commit
`5e56594815854de5eca35c7c04b11705d0f19c02`, the release already selected by the
[linker evidence](../evidence/retained-linker-capacity-20261018/README.md).
The [companion evidence](../evidence/retained-assembler-capacity-20261018/README.md)
pins complete retrieved source bytes. Installed-source correspondence and
selected Linux LP64 types remain explicit external premises. No compiler,
assembler, linker or prover was executed for this record.

## Streaming source buffer

`input_file_buffer_size` is 32,768. The scrubber initializes a 65,536-byte
payload area plus three sentinel/terminator bytes. It reads one block at a
time and doubles only when the current partial line leaves insufficient room
for another block (`gas/input-file.c:40,71–74`,
`gas/input-scrub.c:50–74,141–151,380–438`).

Let L bound the longest line in the byte stream returned to the scrubber,
excluding its terminating newline, for a file without include/macro nesting.
This is a consumer-input bound: a source-to-scrubbed-line transfer is separate.
Set

```text
B = 32768
C = max(65536, least power of two >= L+B).
```

At each growth, the current payload capacity c satisfies `c < L+B`, because
the accumulated partial line is at most L and growth requires
`c-B < partial_size`. Consequently the next doubled capacity is at most C.
Every buffer allocation requests at most `C+3` bytes. Requiring
`C+3 <= PTRDIFF_MAX` suffices for these size additions, doubling and
in-object pointer differences under the selected allocation semantics.
For example `0 <= L <= 32768` keeps the initial **65,539-byte** request;
`L=32769` can require 131,075 bytes. There is no 32-KiB language-line limit
implicit in this observation. Old/new backing may coexist during realloc;
allocator storage is accounted separately.

The input buffer is bounded by the longest partial line, not total file
length. Include/macro buffers, source-location counters, directive-produced
strings and the actual GCC-to-assembler input transfer are not discharged by
this buffer lemma.

## Null frame directives through GAS's CFI parser

For the following transfer assume GCC uses its assembler-directive CFI path
and emits one balanced `.cfi_startproc`/`.cfi_endproc` pair, at most the five
frame-rule directives derived for null Main, and no explicit personality,
LSDA, escape, signal-frame, section-switch or extra-register list directives.
The already derived rules mention columns 6, 7 and 16 and offsets 8, 16,
-8 and -16. This is a conditional consumer input contract; it does not claim
that the alternative raw-DWARF compiler output takes the same parser path.

The start directive creates one `fde_entry`, one `frch_cfi_data` and one
temporary start symbol. The x86 initial-frame hook adds exactly two CFI nodes:
`CFA=RSP+8` and the saved return address at `CFA-8`. Each subsequent selected
directive adds one rule node and can add one advance-location node plus one
temporary location symbol. The end directive adds one temporary end symbol
and clears the current frame-state pointer (`gas/dw2gencfi.c:393–459,499–553,
573–640,802–883,1337–1394`, `gas/config/tc-i386.c:18757–18762`). Hence:

```text
FDE / per-frchain CFI state objects = 1 / 1
initial and function rule nodes <= 2+5 = 7
advance-location nodes <= 5
CFI nodes in total <= 12
temporary-symbol requests while parsing these directives <= 1+5+1 = 7
```

The restore directive's general parser accepts a comma-separated register
list; this transfer relies on GCC's single-register restore output. The
`notes_calloc(1,sizeof(...))` calls are individual typed requests; obstack
backing and the symbol/BFD subsidiary objects require separate accounting
(`gas/symbols.c:251–286`).

## Selected `.eh_frame` serialization

Consider just this FDE's ordinary ELF64 `.eh_frame` serialization, with no
linkonce/compact frame grouping, four-byte FDE relocations and CIE version
1, 3 or 4, into an initially empty `.eh_frame` section. The default CIE version
is 1 (`gas/dwarf2dbg.c:3108–3118`). The source defaults and x86 data alignment give code alignment 1,
data alignment -8 and return column 16. At most one CIE is created. Its initial
rule prefix and the remaining FDE rules partition the twelve-node list; they
do not duplicate it (`gas/dw2gencfi.c:47–75,2208–2290,2385–2500`).

Every selected non-advance rule needs at most three bytes: its register,
positive CFA offset or scaled saved-register offset fits one LEB128 byte.
There are at most seven such rules. An advance needs at most five bytes,
including the cross-fragment case's one fixed byte plus four reserved bytes.
Require its final nonnegative displacement to fit 32 bits; the selected
instruction transfer below supplies this condition. The argument takes no
credit for the smaller one-byte advance available for null Main
(`gas/dw2gencfi.c:1658–1790`). The cross-fragment relaxation helper retains
at most four payload bytes beyond the opcode, and may delete the opcode for
a zero advance (`gas/ehopt.c:480–582`).

The CIE's non-rule payload is at most 19 bytes, including the two extra
address/segment-size bytes for version 4. The FDE's non-rule payload is
17 bytes. CIE and final FDE alignment add at most three and seven bytes.
Therefore this local section contribution, including pessimistic advance
reservations, is at most

```text
19 + 17 + 3 + 7 + 7*3 + 5*5 = 92 bytes.
```

The length and CIE-offset fields consequently fit four bytes. The FDE's
relocation to `.text` still needs the later layout/displacement argument;
small `.eh_frame` contents alone do not establish relocation reach
(`gas/dw2gencfi.c:1910–2154`).

The serialization directly requests three CIE symbols, two FDE size symbols,
at most one code-offset symbol and one `eh_loc` symbol. Each of the five
possible cross-fragment advances can additionally request one expression
symbol plus one expression-location record. Together with parsing, this
gives at most **19 direct temporary/expression-symbol requests** and **five
expression-location records** for these CFI paths. These are calls at the
listed sites, not every symbol/BFD allocation caused transitively by them
(`gas/expr.c:57–100`, `gas/symbols.c:903–924`).

## Selected instruction encodings

Use the native driver's selected assembler command, `as --64 -o main.o TEMP.s`,
and the already derived register-only frame sequence: at most eighteen plain
`nop` instructions, one `pushq %rbp`, one `movq %rsp,%rbp`, one `popq %rbp`
and one operand-free `ret`. This is a consumer transfer from that shape;
it does not replace the frontend/backend source-correspondence argument.

The opcode table supplies base-space register forms: push/pop permit a short
register opcode or an opcode with ModR/M, the register move uses one opcode
and one ModR/M byte, and plain nop/ret each use one opcode. `%rsp` and `%rbp` have low register
numbers 4 and 5, without extended-register flags. The qword move sets REX.W;
push/pop/ret carry `NoRex64`. Register addressing sets ModR/M mode 3, so there
is no SIB, displacement or immediate (`opcodes/i386-opc.tbl:192,246–248,260–262,
521–524,636`; `opcodes/i386-reg.tbl:135–136`;
`gas/config/tc-i386.c:4281–4287,4837–4919,10466–10507,11581–11603`).

The ordinary output branch writes those prefixes/opcode/ModR/M bytes once.
The selected forms do not enter jump relaxation, vector encodings or the
fence replacement branch (`gas/config/tc-i386.c:12603–12640,12689–12861`).
The same conservative instruction bounds used by the backend give:

| Instruction | Count | Bytes each, at most |
| --- | ---: | ---: |
| nop | 18 | 1 |
| pushq | 1 | 2 |
| movq | 1 | 3 |
| popq | 1 | 2 |
| ret | 1 | 1 |

Thus the function's selected instruction contribution is at most **26 bytes**,
now derived from the assembler output path as well as GCC's length attribute.
There are no instruction fixups or instruction-dependent relaxation fragments
on these register/no-operand forms. Internal compiler label alignment is zero,
as established in the backend record; any function-entry section alignment is
outside the start/end frame interval. Therefore each nonnegative CFI advance
and the FDE function size are at most 26 and fit their four-byte fields.
Final cross-section PC-relative relocation reach remains separate.

Assembler branch-alignment power starts at zero; all three automatic
padding/prefix helpers return immediately. The command supplies no option
which changes that state. LFENCE injection flags likewise start at zero and
are not selected (`gas/config/tc-i386.c:728–749,777,6672–6674,6752–6754,
12289–12357`). Synthesized CFI has a zero-initialized `SYNTH_CFI_NONE` flag;
only its explicit option enables it (`gas/as.h:331–337`, `gas/as.c:1012–1018`).
No debug option or `.loc` directive is present, so `dwarf2_emit_insn` returns
before allocating line information (`gas/as.c:75`,
`gas/dwarf2dbg.c:1071–1082`). The ordinary `.file` directive does not enable
that path by itself.

## Optional SFrame and x86 property sections

No-debug GCC output does not establish the absence of assembler-generated
SFrame. `gas/as.c:116–120` initializes `flag_gen_sframe` from `DEFAULT_SFRAME`;
`gas/dw2gencfi.c:2598–2624` runs that serializer when enabled by configuration,
an option or a selected CFI section. Charge the enabled branch too. The selected
source emits only SFrame version 3 (`gas/as.c:123`,
`gas/gen-sframe.c:2509–2521`). Its AMD64 hook supports the ABI, uses fixed
return-address offset -8 and disables per-row return-address tracking
(`gas/config/tc-i386.c:12158–12185`, `gas/config/tc-i386.h:472–484`).

The serializer requests one translation context and one function descriptor.
The first `def_cfa` creates the initial row. Only advance-location creates a
further row on the selected five-rule path; each of the at most five advances
creates at most one. The last scratch row is linked without another allocation.
No remember/restore-state stack is used. Thus **six row allocations** suffice,
and the emitted row count also fits six, well below the actual 16-bit FDE row
field (`gas/gen-sframe.c:591–627,1070–1117,1204–1243,1250–1303,
2398–2437,2467–2505`).

The CFA is always SP/FP based, its offset is 8 or 16, and the saved FP offset
is -16 when present. The return-address rule stays at its fixed -8 offset.
The selected rule handlers therefore leave `flex_p` false; all data words
fit signed one-byte values. Each ordinary AMD64 row has one CFA data word
and at most one FP data word (`gas/gen-sframe.c:1310–1454,1600–1637,
392–421,428–506,649–738`). All offset and register checks succeed for these
values; no SFrame warning/failure branch is needed for this CFI class.

The header is 28 bytes, the function descriptor index 16 bytes, and its
attributes five bytes. Each row reserves at most four start-address bytes,
one info byte and two data bytes. The local section contribution is therefore

```text
28 + 16 + 5 + 6*(4+1+2) = 91 bytes.
```

The field widths are declared in `include/sframe.h:148–188,279–319`; the
serializer is `gas/gen-sframe.c:742–1037`. Its seven possible `rs_sframe`
reservations comprise one one-byte function-info field and at most six
four-byte row-start fields. Relaxation selects only 1, 2 or 4 bytes for a row
start and one byte for function info; final conversion writes only that chosen
length (`gas/sframe-opt.c:34–190`). Function size and all local row offsets
are at most 26, so this transfer takes no credit for their eventual one-byte
encoding. Cross-section function-start relocation remains a layout obligation.

The enabled path's direct additional requests are one one-pointer symbol
array (eight bytes on LP64), six temporary symbols (four section markers,
one per-FDE row marker and one function-offset marker), and three expression
symbols per function-info/row-start composite: at most **21 expression
symbols plus 21 expression-location records**. This is at most 27 direct
temporary/expression-symbol requests, in addition to the earlier CFI count
(`gas/gen-sframe.c:526–588,761–767,830–837,878–885,921–930`). As before,
transitive symbol/BFD allocations and fragment backing are separate.

GAS also initializes `x86_used_note` from `DEFAULT_X86_USED_NOTE`
(`gas/config/tc-i386.c:205`). Charging either setting avoids assuming the
configured default: the enabled ELF64 path allocates exactly **48 payload
bytes** for a 16-byte GNU note header and two 16-byte aligned property
records (`:12045–12146`). Its section alignment is eight bytes. This is GAS's
own note contribution; a compiler-produced property note, other sections and
inter-section padding still require the output-inventory join.

## Remaining composition

The current record leaves the complete assembly-input transfer, generated section and
symbol counts, fragment events, relaxation and fixups, object-file metadata,
startup state and aggregate allocator demands open. In particular, GAS
fragments have their own unsigned allocation count and a 16-bit region field
(`gas/frags.c:28–41,76–94`, `gas/frags.h:73–84`); these are not GCC's UID or
block counters. Their actual uses and sufficient bounds must be reviewed
before assigning them any language restriction. The existing
[ELF/BFD string-table transfer](retained-linker-capacity.md) supplies a later
consumer contract, not this missing source-to-object composition.
