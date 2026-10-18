# Selected null linker representation composition

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-18, Linux x86-64. This joins the selected Main and binder interfaces,
fixed input acceptance, and the variable linker representations. The scope is
one retained no-LTO, ELF64 x86-64 PIE link of the selected null-Main family.
It is not a whole compiler/prover result, an admission rule, a resource
availability guarantee, or a result for the broader Silver grammar.

The [callable offline descriptor](../evidence/retained-linker-null-composition-20261018/README.md)
rechecks twenty prior result identities, the selected installed inputs and
linker bytes, and the supplemental source archive. Its arithmetic and byte
checks accompany the source argument below; Python does not prove the C
control flow. All source citations count literal LF bytes. The existing
source-to-installed-behavior, LP64, selected options, filesystem lookup,
filename/path and host-resource premises apply. This packet adds no library
or operating-system qualification.

The selected ld/BFD representation join is complete under those explicit
premises. Independent native-lane review accepted the supplemental ID
envelope and replayed its offline checker. Integration review accepted the
read-projection composition and LD array/counter joins. Neither review ran a
native tool.

## Contract and read projections

The inputs are the [selected link descriptor](retained-link-inputs.md),
[source-derived Main object envelope](retained-assembler-capacity.md), accepted
[indexed binder projection](retained-binder-capacity.md), and
[stable external-interface transfer](retained-linker-interface.md). Main is
not identified byte-for-byte with the historical witness. Its local labels,
section/string indices, code length and CFI offsets may vary within the
source-derived envelope. Its sole external is the defined, global/default
`_ada_main`, with value zero and positive size at most26; it adds no external
undefined, COMMON, IFUNC, TLS or instruction relocation. The indexed binder
changes only the historical binder's local file name and its serialized
string offsets; its code, relocations, CFI and external records agree.

This gives the following division of work. Each row states what controls
the behavior or representation; observing a successful link is used only for
inputs whose relevant read projection agrees.

| Consumer | Input projection and discharge |
| --- | --- |
| Fixed object/archive/script decoding | Exact retained bytes, format, options and file lookup outcomes. Header/string/archive-map lengths and the fixed parsing requests therefore agree with the successful link. Main contributes no input script, archive, group or dependency record. |
| Archive/global resolution and fixed instruction compatibility | The external-interface transfer establishes the same global definitions, undefined transitions, archive selections and fixed TLS instruction checks. Main's size is saved but has no competing definition or nonzero-size declaration. |
| Main object reader | Valid ordinary ELF64 headers, at most22 section headers,98 symbol records,281 relocation records and the bounded string/payload tables. The additional reader requests below use those envelopes. No compression, extended indices, sectionless input, dynamic input table or foreign object format is introduced. |
| Global/dynamic symbols and all name tables | The [symbol transfer](retained-linker-symbols.md) and [count join](retained-linker-join.md) separately bound live entries, lifetime dynamic registration, rollback snapshots, positive string references, version indices, ordinary symbols and every serialized name table. Stable global resolution is not used to assume identical hash traversal or allocation order. |
| Local GOT, dynamic relocations, GOT/PLT and optional output | The [dynamic-section transfer](retained-linker-dynamic-sections.md) and count join pay for all original relocation records and generated entries. Local IFUNC is absent. Copy storage and property rewrites are explicitly charged; new build-id, package, SFrame, CTF and attribute payloads are absent under the existing selected descriptor. Empty fixed initialization records still execute. |
| Merge and unwind data | The [auxiliary transfer](retained-linker-layout.md#auxiliary-layout-mergeeh-and-final-link-requests) pays original and rewritten buffers, hash entries and per-section arrays. The [EH range/field join](retained-linker-eh-frame.md#selected-function-ranges-and-emitted-fields) establishes function-interval validity, nonoverlap and emitted relative fields for fixed inputs, binder and Main. |
| Layout, relocation and output serialization | The count/payload join supplies every original and synthetic payload, alignment4096, bounded mapping convergence, headers, retained/trial address endpoints and final file offsets. The [relocation transfer](retained-linker-relocations.md) separately pays signed addends, special/absolute symbols, merge cancellation, TLS and every selected final encoding. |
| LD/BFD administrative state | The supplemental reader, ID, iteration, start/stop and section-check joins below cover state shared across those work families. Fixed-size constructor records transfer their request size; repeated constructors do not enlarge that size. |

The resulting joined quantities are `R=49,358`, `Q=36,471`, `P=1,483`,
`Trel=546,740`, `H=221,088`, `I=48,872`, `S=48,965` and `N=48,970`.
The per-item maximum payload union is `B=462,778,637`, the retained virtual
endpoint `V=871,701,307`, the trial endpoint `2V=1,743,402,614`, and the file
endpoint `F=42,687,993,785,710`. These are conservative representation bounds;
F is not an estimated output file size or a requirement to reserve that much
disk. The common signed32 relocation envelope is1,745,421,669.

## Remaining input-reader representations

`bfd/elfcode.h:702–726` allocates internal ELF section headers, their pointer
array and one creation flag per header. For Main these are at most1,760 bytes,176 bytes
and22 bytes, respectively. Header-to-section creation is bounded by the
existing section-chain proof. The symbol reader allocates the external
records, internal records and optional extended indices from the input symbol
count (`bfd/elf.c:441–568`). The linker allocates external-symbol hash pointers
from the global suffix (`bfd/elflink.c:4828–4859`). Original relocation reads
have one24-byte internal/external record per input relocation, already used
by the final scratch transfer. Conservatively using aggregate R/Trel even
for one object's request gives:

```text
external symbols          24R = 1,184,592 bytes
internal symbols          32R = 1,579,456 bytes
optional local indices     4R =   197,432 bytes
external hash pointers     8R =   394,864 bytes
original relocation data 24Trel =13,121,760 bytes.
```

Fixed input headers/string tables retain their successful read operands;
Main's tables use its source envelope. String-length-plus-terminator
requests and section contents remain within the named string and payload
bounds. These are separate requests, not a sum of lifetime allocation.

External symbol/relocation reads may use the temporary mmap wrapper rather
than a same-size heap block (`bfd/libbfd.c:1072–1123,1195–1241`). Its selected
file backend rounds an n-byte range to a page span at most`n+2(G-1)`
(`bfd/bfdio.c:742–763`, `bfd/cache.c:499–541`). The bound`B+2G` therefore covers
these mapped spans, including contents reads, under the existing host-page
premise G. Archive origins are fixed file offsets; the generated Main is an
ordinary file of at most14,352 bytes. At the retained G=4096 it is below the
16,384-byte mmap threshold, so its reader uses the ordinary allocation path.
The arithmetic statement is parameterized and does not infer G from ELF
alignment. Persistent mapping bookkeeping adds fixed G-byte pages; its
within-page index is bounded by that page's fixed entry capacity.

## BFD object and section IDs

Both IDs are finite state that cannot be dismissed as memory statistics.
`_bfd_new_bfd` increments the32-bit object ID once per shell
(`bfd/opncls.c:50,66–100`); `bfd_section_init` increments the32-bit section ID
and the object's section count (`bfd/section.c:836–862`). The checker reads
initial values0 and16 directly from the selected installed linker, along
with its18-entry configured target vector. It executes no linker command.

The complete input census contains zero COMMON or x86 LARGE_COMMON symbols;
Main's source interface and the accepted binder do too. Script/synthetic
symbols are defined or undefined, not common. Consequently the common-only
`elf_link_is_defined_archive_symbol` probe at `bfd/elflink.c:6347–6361` is
unreachable. Archive member access returns cached BFDs keyed by file offset
before allocating another shell (`bfd/archive.c:319–392,671–794`). All
archives are ordinary rather than thin. The temporary first-member format
lookahead disables the cache once, restores the flag and closes its temporary
BFD (`:934–957`). Known-format objects return without another format parse;
a successful current ELF target goes directly to the success return
(`bfd/format.c:446–562`).

The two script inputs start with literal `/*`. The installed target-vector
projection matters here: each possible format rejects that prefix before
constructing sections. ELF rejects its magic; PEI rejects the import/DOS
magic (`bfd/peicode.h:1486–1535`). Raw PE/COFF checks its architecture magic
before calling the section-building reader (`bfd/coffgen.c:387–445`,
`bfd/coffcode.h:1683–1691`, `include/coff/i386.h:32–55`,
`include/coff/x86_64.h:24–44`). SREC, symbolsrec, TEKHEX and IHEX require
`S`, `$$`, `%` and `:` respectively (`bfd/srec.c:643–691`,
`bfd/tekhex.c:608–620`, `bfd/ihex.c:487–507`). Verilog's object reader is
dummy (`bfd/verilog.c:400–408`); automatic probing skips binary
(`bfd/format.c:570–599`), and the descriptor excludes plugins. Failed
format probing also preserves/restores the global section-ID cursor
(`bfd/format.c:136–157,198–228`).

The supplemental envelope charges the already conservative P object
processings, twice the65 recorded ordered library probes, twice the15 fixed
file spellings, and one output. Doubling this sum additionally pays a
temporary archive lookahead per opening:

```text
object ID increments <= 2(P + 2*65 + 2*15 + 1) = 3,288
section ID high water <= 16 + 2(Q + I + S)     = 268,632.
```

For sections, Q pays original decoding, I pays the complete synthetic/input
chain and S pays output constructors. The second copy covers temporary
first-member decoding; it deliberately overcounts retained original
sections. The largest archive member has only55 headers, independently
rechecked from the retained bytes. The descriptor excludes plugin
replacement, object-only secondary links, thin/nested archive reopening and
foreign-format input section creation. Both ID bounds fit unsigned32;
per-object section counts and per-BFD section hash keys are smaller still.

## LD arrays, counters and arenas

The one input-section start/stop walk and one output-section startof/sizeof
walk each attempt at most two definitions per section
(`ld/ldlang.c:7109–7140,7215–7231,7275–7280,8731–8732`). Only a successful
definition appends a pointer. The vector grows by `a := 2a+10`
(`:7076–7101`), so at most`2(I+S)=195,674` entries require327,670 slots,
or2,621,360 pointer bytes. Both the recurrence and its products fit size_t.

The final section-address check uses at mostS records, each a pointer and
Boolean with LP64 padding:16S=783,440 bytes
(`ld/ldlang.c:5685–5689,5738–5797`). Its sorts and scans use size_t counts;
its addresses are inside the established V envelope, and the layout proof
supplies nonoverlap. `lang_record_phdrs` initially allocates ten pointers,
80 bytes (`:9244–9253`); no selected script contains PHDRS, so its growth
loop is not entered. Map-output arrays and their per-symbol counts are
unreachable because no map file is selected (`:2480–2525,5002–5015`).

The output-statement hash has at mostS+1 names, including the special ABS
statement (`ld/ldlang.c:1337–1445,1600–1655`); the existing BFD hash growth
argument therefore applies with a smaller key count than H. Fixed script
wildcards, expressions, parser nesting and prefix-tree shape retain their
successful input projection. Matching nodes, sort nodes, padding statements
and orphan statements allocate individual fixed-size records. A matched
input section cannot extend the fixed script's syntax nesting; orphan
insertion makes one output statement and then returns. Selected generated
names use the existing bounded spelling projection.

`stat_obstack`, `matching_obstack` and `pt_obstack` finish each allocated
object (`ld/ldlang.c:185–223,452–465,784–799,864–883`;
`include/obstack.h:383–418`). Thus the live unfinished-object size is reset
between records. `_obstack_newchunk` grows from that current object and
request, with checked size_t sums and a fixed minimum chunk
(`libiberty/obstack.c:188–209`); it has no cumulative-byte admission counter.
The previously joined BFD objalloc allocator likewise has no cumulative
byte counter. BFD `alloc_size`/`cache_size` remain the separately reviewed
[unobserved statistics](retained-linker-capacity.md#cache-statistics-do-not-constrain-the-selected-link)
under the selected unlimited cache setting. This does not remove individual
request/container limits or make physical memory infallible.

There are at most16 statement-iteration increments and9 sizing-iteration
increments. The selected path has one input-open increment, one mapping
increment, one mark assignment, one final assignment, and at most one
preliminary mark sizing pass. Initial allocation and at most two mapping
iterations call `lang_size_sections` at most three times total. Each call
has at most three sizing passes. Each mapping iteration additionally calls
at most one assigning pass. Summing gives`2+2+1+9+2=16` statement increments
and nine non-mark sizing increments. See `ld/ldlang.c:4716–4727,6593–6715,
6903–6914,8077–8129,8428,8636,8673,8747,8761`,
`ld/emultempl/elf.em:180–191`, and `ld/ldelfgen.c:259–326`.
The selected descriptor excludes relaxation/RELR loops, plugin rescan,
map printing and the secondary object-only link. This also independently
supplies the16-visit allowance consumed by the global-symbol join.

## Meaning of the composition

The joined result covers selected ld/BFD format, scalar representation,
container request, counter, address/file-position and relocation conditions.
Fixed-input parsing and compatibility transfer only through the stated read
projections; every dependency on variable Main/local/CFI fields or combined
layout/table size uses an explicit bound. Repeated fixed-size records do
not require summing all allocations into a new intrinsic source limit.
Host-page scratch remains parameterized by the existing host-page premise G:
`max(4G,B+7)` and `max(4G,24Trel)`. ELF's4096 layout alignment does not establish
an operating-system mmap page size.

This packet runs only offline Python and reads retained/installed bytes.
It performs no compiler, assembler, linker, solver, prover or Lean execution.
Broader source grammar, the rest of the producer/native/prover composition
and a useful admitted-domain comparison remain outside this result and
must be supplied before #119 or implementation #88–#94 can complete.
