# Main's external interface and the retained successful link

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
For the selected null-Main family, changes in source locations can change
nops, local labels, code length and CFI offsets. They do not change Main's
external symbol interface. This permits the successful fixed link to supply
symbol-resolution and fixed-instruction compatibility evidence, while the
[layout](retained-linker-layout.md),
[relocation](retained-linker-relocations.md) and allocation transfers continue
to pay for the variable fields. It does not identify every Main object with
one witness, or establish complete linker capacity.

The [offline packet](../evidence/retained-linker-interface-20261018/README.md)
retains thirteen complete GCC/Binutils files and the two historical objects
actually used by the successful no-LTO link. The previous relevant-source-
behavior and selected LP64/ELF64 target premises apply. Source citations use
literal LF line numbering. No native tool was executed for this transfer.

## Source-derived external interface

The existing [null-unit and lifecycle derivation](retained-native-expansion.md#null-call-graph-lifecycle-allocation-join)
supplies one public defined Main, fixed assembler name `_ada_main`, default
visibility, no weak/alias/symver attributes, no calls or external address
operands, and a dummy that never reaches assembly. These are premises from
that source derivation, rather than facts inferred from a small object.
The [emission transfer](retained-backend-gigi.md#null-compilation-unit-assembly-emission)
also supplies the fixed file spelling, ordinary `.text` selection, no
user assembly/section/group/visibility directive, and the bounded label,
instruction and CFI forms.

`assemble_start_function` switches to that text section, aligns at its
initial zero offset and globalizes the public declaration before emitting
the function label (`gcc/varasm.cc:2132–2208`). Non-weak globalization takes
the target declaration/name route (`:6454–6494,8090–8103`); the ELF function
macro emits `.type ... function` and the label (`gcc/config/elfos.h:296–308`).
Default visibility emits no override (`varasm.cc:6897–6906`). None of these
decisions depends on the function's later byte length or source line.

GAS's `.globl` finds or creates the same named symbol and sets its external
flag (`gas/read.c:2455–2472`, `gas/symbols.c:2528–2551`). The function `.type`
sets `BSF_FUNCTION`, rather than TLS/IFUNC/COMMON flags
(`gas/config/obj-elf.c:2274–2314,2386–2409`). The entry label defines its value
in the current section (`gas/symbols.c:491–496,557–599`). Its value is zero:
there is no preceding function or positive text payload, and alignment of
zero adds no padding. The `.size` expression records the bounded code length.

Every other compiler-generated label is defined in this compilation unit.
CFI and numeric-property forward references have matching definitions;
section symbols refer to existing sections. There is no instruction fixup,
external reference, weakref, symbol-version alias, COMMON declaration or
linker-warning directive. GAS may discard a temporary label or retain it
for a relocation (`gas/write.c:2427–2448`), but this does not make it global.
The `.file` producer is `BSF_FILE` (`gas/config/obj-elf.c:203–217`). Predefined
GAS symbols are absent from the output chain, as established by the existing
symbol inventory. Thus no unresolved local name can become an external
undefined symbol at serialization.

BFD creates zeroed ELF symbol state (`bfd/elf.c:9789–9797`). With no visibility
override, `st_other` remains zero. Its writer maps `BSF_FUNCTION` to
`STT_FUNC`, the global flag to `STB_GLOBAL`, ordinary defined labels and
section symbols to local binding, and file symbols to local `STT_FILE`
(`:8967–9044`). In particular, the writer's undefined-to-global rule at
`:9012–9016` has no input here. This establishes the following interface for
every object in the selected family:

| Interface field | Value |
| --- | --- |
| External symbol records | Exactly one |
| Name, binding, type, visibility | `_ada_main`, GLOBAL, FUNC, DEFAULT |
| Definition | Ordinary `.text`, value zero |
| Size | Positive selected function length, at most 26 bytes |
| External undefined, COMMON, weak, IFUNC and TLS records | None |
| Main instruction relocations | None |

Local symbol counts/names/offsets, serialized section indices, string-table
offsets and Main's `.eh_frame` bytes are deliberately outside this constant
projection. The existing object envelope pays for their variation.

## Connecting the successful link to the accepted binder

The successful no-LTO link recorded in
[the selected link descriptor](retained-link-inputs.md#invocation-and-implicit-script)
used a 1,224-byte Main object and a **13,424-byte unindexed binder object**.
The later accepted indexed binder object is **13,432 bytes**. Treating them
as the same bytes would be incorrect. The checker retains the original two
objects, matches their hashes to the link's capture and independently parses
both binder objects.

All binder section names, flags, types, alignments and entry sizes agree.
Every section payload is byte-identical except `.symtab` and `.strtab`.
There are 179 symbols in each. Resolving names through each object's own
string table leaves precisely one semantic difference: the local `STT_FILE`
name is `b__main.adb` versus `b__main~1.adb`. The 169 external records,
including their values and sizes, are identical. The index insertion moves
string offsets and file layout; it changes no instruction, relocation,
constant, CFI, property or externally visible symbol. The later
[indexed binder source projection](retained-binder-capacity.md#names-calls-and-retained-object-inventory)
then transfers that accepted binder shape across the selected indexed family.
This bridge is an offline comparison, not a second claim that the unindexed
compiler invocation was the accepted one.

The historical Main's external record matches the source-derived projection,
with size 8. Its successful link is therefore a witness for the same external
interface. The checker additionally rereads the 15 fixed input files and all
1,161 archive members: **no fixed input has an external `_ada_main` record**,
including a name with a GNU `@` version suffix.
The binder's only such record is a global/default, undefined NOTYPE symbol
with value and size zero. This excludes a hidden competing definition or
nonzero-size declaration when Main's function size varies.

## Linker decisions and their read projections

The following source transfer applies with the same selected options,
scripts, ordered fixed files, binder projection, and stable filesystem
lookup results. The native process/resource assumptions remain separate.

| Decision or work | Fields read; reason the fixed result transfers |
| --- | --- |
| Global-name insertion and merging | The object-symbol reader starts at `sh_info`, excluding ordinary locals, and reads name, binding, definition class, type, visibility and value (`bfd/elflink.c:4828–4859,4994–5105,5326–5383`). Main supplies the same sole defined symbol and zero section-relative value; the binder and fixed records agree. Main's nonzero size is saved, but no competing size exists to trigger a mismatch (`:5580–5601`). |
| Archive member selection and GROUP termination | Archive lookup uses fixed map names and the current global hash's undefined/common state (`elflink.c:6298–6370`); subsequent symbol additions are fixed. Induction over the ordered inputs yields the same loaded members and undefined-list transitions. GROUP iteration tests that list's tail (`ld/ldlang.c:3690–3700`). Main creates no new undefined name, COMMON or discarded group. |
| DSO as-needed and dependency closure | The same global references, definitions and ordered input list give the same as-needed decisions. Fixed SONAME/DT_NEEDED bytes and script paths remain those in the existing input-closure derivation. Main has no dependency/version section or dynamic symbol table. |
| Fixed symbol-type/visibility/TLS compatibility | All participating global records and relocation identities are unchanged. The selected x86 symbol merge hook only special-cases common/large-common conflicts (`bfd/elf64-x86-64.c:6113–6142`), which Main cannot introduce. Main is an ordinary function and introduces no TLS reference. |
| Fixed TLS instruction transition checks | The transition selection uses executable mode, binding/TLS class and original relocation type; its instruction test reads the fixed source section bytes, relocation position, bounds and paired relocation (`elf64-x86-64.c:1182–1208,1242–1255,1506–1668`). Those inputs agree for selected fixed objects and binder. Main contributes no such relocation. Final operand magnitudes are discharged separately by the relocation envelope. |
| ELF/property input format | The target/header/ordinary section families are fixed by the existing GCC/GAS object writer transfer. GNU-stack stays non-executable. GCC property selection reads fixed options (`gcc/config/i386/gnu-property.cc:70–131`). GAS's only location-sensitive added instructions are ordinary nops; the selected scalar frame/move/return/nop forms add none of the x87/vector/new-ISA flags at `gas/config/tc-i386.c:12447–12558`, and 64-bit mode supplies the same baseline bit. Property record sizes and the resulting masks therefore agree. |

For archive selection, the induction concerns semantic hash state, not heap
addresses, local-symbol order or hash-table traversal order. Hash capacities
and reference events retain their existing conservative bounds. The fixed
input evidence already charges all archive members, so the capacity argument
does not need to assume an unrecorded exact list of loaded members.

There is also a concrete fixed request interface here: the external-symbol
hash-pointer array at `bfd/elflink.c:4852–4859` has one pointer for Main and
169 for the binder, hence 8 and 1,352 bytes on the selected LP64 target.
Local label growth cannot enlarge those arrays. The complete symbol and
string-table reads still use the accepted object envelopes; the binder's
two extra filename bytes are not discarded from that accounting.

GOT relaxation can additionally depend on final reach. A changed offset may
change whether an optional conversion is selected; successful conversion is
checked before commitment and a failed conversion leaves the original GOT
form. The [relocation transfer](retained-linker-relocations.md) covers both.
Neither exact relaxation decisions nor exact output bytes are transferred
from the witness.

## Capacity scope

Fixed library/script parsing and fixed instruction compatibility need not be
rediscovered for every larger Main input once their read projection agrees.
Their request operands that depend only on retained section/table lengths
remain the same fixed quantities. Requests that also consume Main counts,
layout values, local names, CFI records or combined table sizes instead use
the existing Main/object, symbol, auxiliary and layout envelopes. Input
filenames and host paths continue to use the separate configuration bounds.

This is not an assertion that every allocation or branch in the whole linker
replays identically. In particular, EH parsing/rewrites, merge/layout work,
output serialization, and context-dependent requests still require their
own source transfers. The successful link establishes a concrete compatible
fixed configuration; the source projection explains which decisions transfer.
It supplies neither a universal Main exact-byte witness nor a blanket proof
of all ld/BFD internals. No new language limit or production change is made
by this research packet.

Independent native-lane review replayed the complete packet and inspected
the Main symbol producer/writer, symbol-size guard, archive hash-state
selection and TLS instruction read projection. It accepted this scope.
The binder lane independently replayed and accepted the historical/indexed
bridge, including all 179 symbol records and all section payloads. Neither
review ran a native tool.
