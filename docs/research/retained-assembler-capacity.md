# Retained assembler input and frame-record transfers

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This joins selected GNU assembler representations to the
[null Main backend shape](retained-backend-gigi.md). It does not yet close
instruction encoding, every output section, ELF symbol generation or linking.

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
Require its final nonnegative displacement to fit 32 bits; connecting this
to actual machine encoding is still a separate join. The argument takes no
credit for the smaller one-byte advance expected for null Main
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

## Configuration and remaining composition

No-debug GCC output does not establish the absence of assembler-generated
SFrame. `gas/as.c:116–120` initializes `flag_gen_sframe` from `DEFAULT_SFRAME`;
`gas/dw2gencfi.c:2598–2624` runs that serializer when enabled by configuration,
an option or a selected CFI section. The configured default or that additional
serializer must be discharged. Synthesized CFI is another separate path,
guarded by `flag_synth_cfi` after each assembled instruction
(`gas/config/tc-i386.c:7785–7795`). Neither branch is silently excluded by the
version string.

The current record leaves instruction parsing/encoding, generated section and
symbol counts, fragment events, relaxation and fixups, object-file metadata,
startup state and aggregate allocator demands open. In particular, GAS
fragments have their own unsigned allocation count and a 16-bit region field
(`gas/frags.c:28–41,76–94`, `gas/frags.h:73–84`); these are not GCC's UID or
block counters. Their actual uses and sufficient bounds must be reviewed
before assigning them any language restriction. The existing
[ELF/BFD string-table transfer](retained-linker-capacity.md) supplies a later
consumer contract, not this missing source-to-object composition.
