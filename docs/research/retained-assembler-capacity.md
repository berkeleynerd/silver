# Retained assembler input and frame-record transfers

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This joins selected GNU assembler representations to the
[null Main backend shape](retained-backend-gigi.md). It covers the selected
instruction encodings, frame serializers, GAS symbols and fixups, but does
not yet close BFD's ELF metadata generation or linking.

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

## Selected fragment and obstack growth

GAS uses the same version-2 `include/obstack.h` and `libiberty/obstack.c`
bytes as the pinned GCC sources. The [individual-object obstack
transfer](retained-backend-obstacks.md) therefore applies with GAS's actual
constructor choices. `chunksize` and `debug_memory` start at zero; the selected
command does not change them. A new subsection initializes one default obstack,
sets its alignment to `alignof(fragS)`, and allocates its initial fragment
(`gas/as.c:91–95,1319–1320`; `gas/subsegs.c:131–145`). Its preferred chunk
request is **4064 bytes**, not GCC's separate 65536-byte pool setting.

Write `H=offsetof(fragS,fr_literal)`. Under the selected LP64 layout,
`76 <= H <= 160` and fragment alignment is at most 16. The lower bound
already follows from five eight-byte address/value fields, four pointers and
the line number. The upper bound charges the optional listing pointer,
separate storage units for the generic unsigned/enum bitfields, the four-byte
subtype, alignment padding and at most 48 bytes for the x86 extension. The
selected ELF x86 shape has neither CGEN nor an `OBJ_FRAG_TYPE` extension
(`gas/frags.h:38–108`, `gas/as.h:140–147,274`,
`gas/config/tc-i386.h:308–338`). These are selected ABI layout bounds, not
observed `sizeof` measurements.

For these serializers every positive append or room request is at most 48
bytes. If `frag_grow(n)` finds insufficient room, the remaining room is
`< n <= 48 < H`. Finishing cannot increase that room, so the next fragment
header forces a new chunk immediately. The requested temporary preferred size
is at most `H+2n <= 256`, below 4064. The new chunk has at least
`4064-16-15-160=3873` bytes after its header/alignment and fragment header;
thus **one** loop iteration suffices. This is a specialization of
`frag_grow`, not a claim about arbitrary large GAS requests
(`gas/frags.c:76–141,162–202`).

`frag_alloc` finishes the old object before appending a fresh header. Its
obstack growth therefore copies zero partial bytes and requests at most
`max(4064,H+15+100)=4064`. `frag_more` and `frag_var` append only after the
room check. `FRAG_APPEND_1_CHAR` also starts a new fragment when room is at
most one, after which the same new-chunk argument applies. Each selected
fragment allocation requests at most one chunk; finishing requests none
(`:211–267,395–405`; `libiberty/obstack.c:188–236`). In-chunk offsets and
pointer differences consequently fit the existing individual-allocation
conditions. Other obstack users, allocator overhead and source-address
placement retain their separate premises.

The already bounded instruction, CFI, SFrame and GAS property paths reserve
at most `26+92+91+48=257` payload bytes in total. Charging a separate append
primitive per positive byte bounds those primitives by 257. Charge another
257 room checks to cover `emit_expr_with_reloc`'s preliminary `frag_grow`,
even though most writes do not use it (`gas/read.c:4547–4559,4618,4686`).
Those CFI expression fields have four/eight-byte widths; one-byte frame opcodes
use the direct helper, so the additional raw-DWARF `check_eh_frame` recognition
cannot enter its `state_saw_loc4` fragment path
(`gas/ehopt.c:390–440`; `gas/dw2gencfi.c:113–147,1929–1934,2059–2122`).
The explicit preallocation calls add at most five for CFI and seven for
SFrame. Closing variant fragments adds five CFI advances, two CFI alignment
fragments and seven SFrame fields. Thus these selected paths make at most

```text
2*257 + (5+7) + (5+2+7) = 540 fragment allocations.
```

Zero-length `frag_more(0)` probes allocate no payload and do not start a
fragment; the instruction-end forced split is disabled by zero branch
alignment (`gas/config/tc-i386.c:12870,12956–12965`). This intentionally loose
event bound excludes subsection initialization, compiler-produced extra
directives and final section padding/sentinels. If their bound is `F_other`,
the unsigned counter condition is
`initial_totalfrags + F_other + 540 <= UINT_MAX`; the corresponding number
of individual chunk requests is bounded without turning their sum into a
language memory gate.

The 16-bit fragment `region` is a different representation. Its per-section
counter starts at zero and increments only after alignment or `.org`
fragments; CFI/SFrame variants do not increment it
(`gas/write.c:2681–2784`). These selected paths add at most **two** such
events, both CFI alignment. Complete section composition must still ensure
that each stored region fits 16 bits and the local integer increment fits;
neither the global fragment count nor source length is itself the region
count.

## Null unit sections and final fragments

The [GCC unit-emission transfer](retained-backend-gigi.md#null-compilation-unit-assembly-emission)
adds one function-entry alignment, the fixed file/function outline, one
configured identifier of I bytes and up to three 32-byte compiler property
notes. There is no data definition, constant pool, source assembler, `.loc`,
include, macro or separate debug output. The CFI configuration premises remain
explicit in that transfer.

An additional assembler default must be charged: `flag_generate_build_notes`
comes from `DEFAULT_GENERATE_BUILD_NOTES` (`gas/as.c:113`). Its enabled
ELF64 branch writes one **36-byte** GNU build-attribute note per ordinary
code section, with two eight-byte-address relocations. Only `.text` is a
code section here; the stack marker is non-executable. Thus charge one note
and two relocations, irrespective of the configured default
(`gas/write.c:1988–2111`). This is distinct from `.note.gnu.property`.

The generic object-attribute serializer adds no `.gnu.attributes` section.
The selected x86 backend creates zeroed object state
(`bfd/elfxx-x86.c:40–44`, `bfd/elf.c:292–321`). Its attribute version starts
at `OBJ_ATTR_VERSION_NONE=0`; x86 does not define `TC_OBJ_ATTR`, so the
assembler's attribute-version initialization/directive entries are absent.
No selected input sets attributes. `bfd_elf_obj_attr_size` returns zero for
that version and the section creator immediately returns
(`gas/config/obj-elf.c:118–123,2986–3016`, `bfd/elf-bfd.h:2225–2232`,
`bfd/elf-attrs.h:26–34`, `bfd/elf-attrs.c:314–330`, `gas/write.c:1901–1925`).

The complete selected GAS section/subsection inventory before BFD serializes
its ELF metadata is:

| Section | Subsection | Payload bytes, at most |
| --- | ---: | ---: |
| `.text` | 0 | 26 |
| `.data`, `.bss`, `.note.GNU-stack` | 0 each | 0 |
| `.eh_frame` | 0 | 92 |
| `.sframe`, when enabled | 0 | 91 |
| `.note.gnu.property`, charging both producers | 0 | `96+48=144` |
| `.comment` | 0 | `I+2` |
| `.gnu.build.attributes`, when enabled | 0 | 36 |
| Internal register/expression sections | 0 each | 0 |
| Static absolute/undefined sections | 0 each | 0 |

There are at most **nine ordinary sections plus two internal sections** in
the BFD output list, plus the **two static absolute/undefined sections**.
The assembler initializes `.text`, `.data`, `.bss` and its two internal
sections (`gas/as.c:1425–1447`); the selected remaining constructors reuse
their named section and subsection zero. Both the direct CFI section route
and its linkonce helper select subsection zero, including for `.sframe`
(`gas/dw2gencfi.c:284–345,1399–1438,2608–2624`). Each distinct pair creates one
fragment chain and initial fragment (`gas/subsegs.c:131–153`). The two calls
to `bfd_std_section_init` also call `subseg_new`, creating two more chains
and initial fragments (`gas/as.c:1352–1361,1443–1444`). These use static BFD
sections returned by `bfd_make_section_old_way`, outside the output section
list (`bfd/section.c:1114–1132`). Thus there are thirteen initial chains.
They add no final-alignment event because `subsegs_finish` visits only the
output section list. Internal
sections are removed before output (`gas/write.c:2131–2146`). File/type/size
directives and labels add symbol metadata, not another payload section.

`.ident` creates a leading NUL once, then appends the string and its
terminating NUL (`gas/config/obj-elf.c:2431–2467`, `gas/read.c:6019–6083`).
The compiler property notes are each 32 bytes and GAS's property note is
48, so either emission order preserves eight-byte alignment. Function-entry
alignment is at offset zero; its fill size is zero. For ELF x86,
`SUB_SEGMENT_ALIGN` is zero and `md_section_align` is the identity
(`gas/config/tc-i386.h:97,234–236`). Final subsection alignment therefore
adds no output bytes; `.comment`'s entry size one does not raise it.
Each subsection still creates one zero-alignment variant plus an empty
terminal fragment, including the late build-note section
(`gas/write.c:1835–1897,2106–2111`, `gas/frags.c:311–332,364–374`).

The output payload sum is at most `391+I` bytes, or **420 bytes at I=29**.
This is neither ELF file size nor address-span accounting: BFD headers,
symbols, strings, relocation sections, file alignment and final link layout
remain separate. All per-section payload offsets are already small.

For backing-store events, compiler property notes reserve at most 96 positive
bytes: each has 28 ordinary bytes and three one-byte alignment patterns,
so `3*(28+3)=93 <=96`. Add `I+2` comment
bytes, 36 build-note bytes, one function-alignment pattern and eleven final
alignment patterns to the earlier 257-byte reservation bound. This gives
`403+I` positive reservation bytes. The maximum single room/append request
remains 48, so the one-iteration/4064-byte fragment-chunk transfer still applies.

Charging up to two fragment allocations per positive byte (append plus a
preliminary expression room check), the earlier twelve preallocation calls,
the earlier fourteen variant closes plus nine property, one function and
eleven final alignment closes, and thirteen initial fragments gives

```text
2*(403+I) + 12 + (14+9+1+11) + 13 = 866+2*I.
```

At I=29 this is **924 fragment allocations**. The global unsigned counter
starts at zero (`gas/frags.c:28–41`); fixed zero/predefined/dummy fragments
are static objects, not additional `frag_alloc` calls. Each initial subsection
also initializes one 4064-byte fragment obstack; its initial chunk is counted
separately from later growth. The common frchain/notes obstacks and BFD symbol
objects have their own request types and remain to be composed.

The largest per-section region increment count is ten: nine compiler property
alignments plus that section's final alignment. `.text` has at most two,
`.eh_frame` at most three and every other selected section at most one.
There is no `.org`. These counts fit the actual 16-bit region field; they
are not inferred from the global fragment count. No assembler was run.

The first unit-emission record counted eleven initial chains and omitted
the absolute/undefined startup calls. The corrected count is thirteen;
payload and final-alignment counts are unchanged. This is a correction to
source accounting, not a new execution result.

## GAS symbols and fixups

The fixed unit outline and selected frame serializers give the following
upper bound on GAS symbol creation requests. A forward reference and its
later definition reuse one symbol; declarations such as `.globl` and `.type`
also reuse the named symbol (`gas/symbols.c:659–683,730–761`).

| Producer | GAS symbols, at most |
| --- | ---: |
| Compiler ordinary labels, CFI labels, FDE labels, Main and property labels | `3+5+2+1+15=26` |
| CFI direct temporary/expression requests derived above | 19 |
| SFrame direct temporary/expression requests derived above | 27 |
| One cached section symbol per ordinary, internal and ABS/UND section | 13 |
| `.file "main.adb"` | 1 |
| Current location in `.size _ada_main, .-_ada_main` | 1 |
| Startup `.gasversion.` local symbol | 1 |
| **Total** | **88** |

The startup local is created before the output BFD opens
(`gas/as.c:1368–1388`). Section symbols are cached in `seginfo->sym`; a
second request returns the existing object (`gas/subsegs.c:235–281`). The
`.file` directive creates one symbol and retains the same spelling, so its
name-extension branch does not allocate another copy
(`gas/config/obj-elf.c:203–234`). `.size` reads its expression in normal mode:
the single `.` creates one location temporary, and a nonconstant difference
retains at most one `expressionS` (`gas/expr.h:157`, `gas/expr.c:729–750`,
`gas/config/obj-elf.c:2183–2231`). It does not emit another data field.

These selected expressions are constants, symbols or differences of two
symbols. Numeric property forward references do not set the separate
`.eqv`/deferred-expression `forward_ref` flag. There are no volatile
assignments, redefinitions, weak references, symbol versions, groups,
`.startof`/`.sizeof`, GOT references or debug directives. Thus the clone and
general-complex-expression routes add no symbols
(`gas/read.c:3366–3385`, `gas/symbols.c:839–897`,
`gas/expr.c:2108–2143`, `gas/config/obj-elf.c:2728–2813`,
`gas/config/tc-i386.c:18268–18284`). The direct composite SFrame expression
constructors are already included in its 21 expression-symbol allowance;
their emitted field expressions reference those symbols. Synthetic CFI is
disabled, so the `.type`/`.size` ginsn hooks are absent. The selected ELF
symbol hook only initializes two pointers; ECOFF and target symbol extensions
are absent (`gas/config/obj-elf.c:2086–2098`). These exclusions are properties
of the selected generated stream and target, not of arbitrary assembly.

Each full symbol copies its name once and allocates `symbolS+xsymbol` in one
request, then one BFD symbol. A local symbol first allocates its smaller
object and copied name; conversion allocates one `xsymbol` and one BFD
symbol, resets `local_symbol` and reuses the original object/name
(`gas/symbols.c:330–424,439–487`). Hence conversion is charged at most once,
including when a local is first used in a relocation. The 88 GAS objects
cause at most 88 BFD symbol allocations. BFD section construction adds at
most thirteen, including the two standard-section hooks, and initializing
the static dot symbol adds one. The bound is therefore **102 BFD symbol
allocations through GAS**, including section-symbol allocations that are
subsequently replaced by an existing section symbol
(`bfd/section.c:817–855`, `gas/as.c:1352–1361`,
`gas/symbols.c:3131–3167`). Later BFD-generated ELF metadata symbols are
outside this count.

The selected symbol names fit 26 bytes including NUL: the compiler's
previously bounded local labels dominate the fixed section, file, Main and
fake-symbol spellings. The property notes use only labels 0 through 4, each
defined at most three times. They use the ten static low-label counters,
never the heap sparse-label arrays. Their `.Ln\002m` spelling needs at most
six bytes including NUL, within the static 24-byte formatting buffer
(`gas/symbols.c:2037–2165`, `gas/config/obj-elf.h:127–129`).

For individual raw requests, the selected LP64 field layouts give these
conservative ceilings. They are source-derived ABI bounds, not new `sizeof`
measurements or aggregate memory requirements.

| Request | Bytes, at most |
| --- | ---: |
| Full GAS symbol plus extension | 160 |
| Initial local symbol | 64 |
| Local-to-full extension | 96 |
| ELF BFD symbol | 128 |
| Retained `.size` expression | 40 |
| Expression-location record | 32 |
| `fixS` | 128 |
| `arelent` and its separate symbol-pointer cell | 32 and 8 |
| Optional build-note `reloc_list`, including embedded `arelent` | 72 |

The GAS symbol layouts have four pointer/value fields plus flags/hash; the
extension has one expression, two pointers and the ELF symbol extension.
Charging at most 40 bytes for the expression and 32 for the ELF extension
fits the 96-byte extension ceiling (`gas/symbols.c:35–172`,
`gas/expr.h:116–144`, `gas/config/obj-elf.h:72–101`). ELF's BFD object combines
a 48-byte `asymbol`, 32-byte internal ELF symbol, eight-byte union and
version/padding, within 128 bytes. Its constructor makes exactly that one
request (`bfd/syms.c:177–197,306–324`, `include/elf/internal.h:128–140`,
`bfd/elf-bfd.h:74–94`, `bfd/elf.c:9788–9797`). The 26 previously counted
expression-location records each contain three pointers and one unsigned
line number (`gas/expr.c:38–100`). There are no CGEN or target `fixS`
extensions; its ten pointer/value fields, flags, relocation enum and line
number fit 128 bytes. The relocation record contains four eight-byte fields,
and `reloc_list` combines it with four additional pointer-sized fields and
the line number/padding (`gas/write.h:47–169`, `bfd/reloc.c:100–115`).

Every selected `fix_new`/`fix_new_exp` attaches to a positive-width field,
with width at most eight bytes. Each field creates at most one fixup via
`emit_expr_fix` and `x86_cons_fix_new`, or the mutually exclusive direct CFI
relocation branch (`gas/read.c:4868–4916`,
`gas/config/tc-i386.c:13331–13352`, `gas/dw2gencfi.c:2075–2115`). Charging one
fixup per reserved byte therefore gives

```text
F <= 92 CFI + 91 SFrame + 96 compiler property bytes = 279.
```

The zero-width linkonce CFI relocation is excluded by the existing selected
CFI configuration. The instruction encodings are register-only and create no
fixups. The comment, alignment patterns and GAS property note write bytes
directly. The x86 `WORKING_DOT_WORD` definition excludes late broken-word
fixup reconstruction; selected relaxation variants serialize directly rather
than create another fixup for an already charged field
(`gas/config/tc-i386.h:343`, `gas/write.c:2211–2237`).
`fix_new_exp` retains the existing symbols for constants/symbols/subtractions;
it does not create expression wrappers for these selected fields
(`gas/write.c:238–287`). The unsigned `n_fixups` counter therefore stays at
most 279, and every `fx_size` fits its eight-bit field
(`gas/write.c:129–215`).

Fixup processing reuses the fixups and cached section symbols. Each unresolved
fixup yields at most one `arelent` and one symbol-pointer cell; the x86 ELF
target has no relocation-expansion macro
(`gas/write.c:955–1030,1258–1388`, `gas/config/tc-i386.c:18617–18639`). The
optional build note adds two `reloc_list` objects, each embedding its own
`arelent` and symbol pointer, without allocating `fixS`
(`gas/write.c:1927–1985`). Thus the per-section relocation pointer array has
at most **281 slots / 2248 bytes**, conservatively charging every fixup and
both note relocations to one section. Its unsigned count and multiplication
fit. The final GAS symbol pointer array has at most **88 slots / 704 bytes**;
the signed count and index in `set_symtab` fit independently
(`gas/write.c:1764–1810`). Neither count establishes ELF relocation reach.

This closes the selected GAS symbol/fixup object counts and their individual
request bounds. The shared notes obstack has other users, including file/path
metadata and fixed startup tables. Its chunk composition, allocator overhead,
BFD output metadata and final object layout are still separate obligations;
the small requests above do not silently close those obligations.

## Remaining composition

The subsequent [shared backing transfer](retained-assembler-backing.md)
supplies notes/frchain chunk arithmetic and CFI/SFrame raw request ceilings.
Remaining relaxation state, fixed startup tables and BFD initialization
still need their inventory. The subsequent
[ELF object transfer](retained-elf-object-capacity.md) supplies the selected
writer's metadata counts and complete object-file envelope; fixed BFD
initialization and shared backing remain separate. The selected
unit's GAS symbol/fixup counts, unsigned fragment-allocation counter and
16-bit region field now have separate sufficient bounds above; these are not
GCC's UID or block counters. A broader admitted family still needs its own
source-to-fragment transfer before any corresponding language restriction
can be justified. The existing
[ELF/BFD string-table transfer](retained-linker-capacity.md) supplies a later
consumer contract, not this missing source-to-object composition.
