# Retained linker section and header transfer

Research for #119, 2026-10-18. This extends the selected
[link inputs](retained-link-inputs.md),
[dynamic section](retained-linker-dynamic-sections.md),
[EH frame](retained-linker-eh-frame.md) and
[symbol](retained-linker-symbols.md) records. It establishes section-walk,
output-section and ELF-header count interfaces. Final virtual placement,
file length and relocation reach remain open; this is not an admission rule
or complete linker-capacity result.

## Scope and inputs

Use the selected no-LTO ELF64 x86-64 PIE descriptor, installed default
`elf_x86_64.xdc` script and exact fixed input bytes. There is no plugin,
custom output script, `PHDRS`, `MEMORY`, `OVERLAY`, object-only output,
relocatable link or non-ELF input. All selected ELF inputs have ordinary
section headers. The source-to-installed-tool behavior premise is unchanged:
the pinned release source describes the retained executable; these pins are
not a historical build attestation.

Let `Q` count original ELF section-header record processing occurrences,
including unused/null headers, and `P` count processed ELF object occurrences.
Both deliberately include the conservative archive/loader multiplicities
from the selected-input derivation. They upper-bound the smaller live input
domain. `P` is distinct from the dynamic-symbol lifetime registration variable
`J` in the symbol record.

```text
Q = 36,433 + Qmain + Qbinder
P =  1,481 + Pmain + Pbinder
```

The fixed inventory has 1,473 ELF occurrences and 36,241 header records.
The already derived allowance for eight additional loader processings adds
eight objects and `8 * 24` header records. The retained
[Main object transfer](retained-assembler-capacity.md) gives `Qmain <= 22` and
`Pmain = 1`. Binder quantities stay symbolic. The observed binder object is
not a universal source-derived envelope and is not substituted here.

All source line references below count literal LF characters. Complete
reviewed files, identities, input hashes, the family census, and a Python-only
replay are retained in
[the evidence directory](../evidence/retained-linker-layout-20261018/README.md).

## Input sections added by the linker

Header-derived input sections consume at most `Q` section objects. The
selected ELF header reader creates at most one BFD section for each header
(`bfd/elf.c:878–953`; target unwind hook
`bfd/elf64-x86-64.c:6002–6011`). The sectionless-Dynamic fallback, segment/core
pseudo-sections and non-ELF backends do not apply to these inputs. Symbol
tables and relocation headers which do not become input BFD sections are
still included in `Q`.

There are three additions to this domain:

1. **At most three common section names per processed object.** Ordinary
   common, large common and TLS common use `COMMON`, `LARGE_COMMON` and
   `.tcommon`. `bfd/elflink.c:5113–5147` selects TLS common or the target hook;
   `bfd/elf64-x86-64.c:6014–6049,6112–6142` selects/merges large common.
   Generic common handling uses the selected section's name
   (`bfd/linker.c:1635–1657,1688–1705`). Named lookups and
   `bfd_make_section_old_way` reuse an existing section
   (`bfd/section.c:1114–1151`). The plugin-specific common branch is excluded,
   although charging the name once already covers it numerically.
2. **At most one dynamic relocation section per original header record.**
   The selected x86 relocation check calls
   `_bfd_elf_make_dynamic_reloc_section` on the current source section
   (`bfd/elfxx-x86.c:983–1003`). The helper caches `sec->sreloc` and reuses an
   already named linker section (`bfd/elflink.c:15615–15656`). New relocation
   sections have neither `SEC_RELOC` nor a nonzero input relocation count,
   so the walk's guard excludes recursive creation from those new sections
   (`bfd/elflink.c:4283–4310`). The common and other synthetic section
   constructors likewise do not introduce input relocation records. Thus
   this contribution is at most `Q`, even if the checks are repeated.
3. **A union of 35 once-per-link synthetic sections.** The table deliberately
   charges optional alternatives together. It does not assert that all
   these sections coexist or are nonempty.

| Family | Count | Selected guard/source |
| --- | ---: | --- |
| GOT, GOT.PLT, GOT relocation | 3 | `sgot` guard, `bfd/elflink.c:229–280` |
| Interpreter, three version sections, dynsym, dynstr, dynamic, two hashes, RELR | 10 | `dynamic_sections_created`, `bfd/elflink.c:335–460` |
| PLT, PLT relocation, dynamic BSS/read-only copy sections and their relocations | 6 | Same once-per-link dynamic creation, `bfd/elflink.c:466–577`; GOT charged above |
| PIE IFUNC relocation | 1 | `irelifunc`/`iplt` guard, `bfd/elf-ifunc.c:35–105`; static IP(L)T/GOT alternatives excluded |
| PLT.GOT, PLT.SEC, TLS relocation, three EH frames, three SFrames | 9 | One GNU-property setup from after-open, `bfd/elfxx-x86.c:4720–4882` |
| x86 and generic GNU property sections | 2 | One each; generic creation sets `first_pbfd`, `bfd/elfxx-x86.c:4257–4529`, `bfd/elf-properties.c:678–805` |
| Object attributes | 1 | One setup/result BFD, `bfd/elf-attrs.c:797–820,2132–2205` |
| EH header, build-id note, package note | 3 | One after-open invocation, `ld/ldelf.c:1260–1413,1508,1623` |

The `dynamic_sections_created` guard is not cleared by as-needed symbol-table
rollback. GOT and IFUNC helpers retain their separate guards when called
from property setup. `ldelf_after_open` calls object/property setup once;
the x86 GNU-property hook calls its generic merger once. The relocatable-only
synthetic GNU-stack section is excluded. CTF processing reuses the existing
input/output `.ctf` section rather than creating another BFD output section
(`ld/ldlang.c:3825–4044`). Input attributes, SFrame or CTF payload accounting
is a separate question; their possible presence does not invalidate this
count union.

Consequently define

```text
I = 2 Q + 3 P + 35.
```

At every relevant phase, all input BFD section chains together have length
at most `I`. This is a deliberately coarse common bound, including synthetic
families not yet created at the first start/stop-symbol walk. The single
`lang_init_start_stop` walk traverses each live input chain once
(`ld/ldlang.c:7109–7138,7275–7280,8632`), hence **`Qin <= I`**. Its name
character filter only reduces the number of actual symbol-definition calls.
Each visited section can make two such calls. Repeated fixed-input
processings have already been charged in `P`/`Q`; they are not multiplied
into the live-chain walk again.

## Output section and symbol-walk join

The exact installed script has **93 output-section declarations**, counting
both `ONLY_IF_RO` and `ONLY_IF_RW` alternatives. `/DISCARD/` is a separate
discard statement and does not create an output section. The complete
declaration list is retained in `check-results.json`. This is a count of the
selected script, not a guessed cap on arbitrary scripts. Library input
scripts contain `INPUT`/`GROUP` and introduce no output sections.

`init_os` creates at most one output BFD section for each output statement,
reusing an existing section unless duplication was requested
(`ld/ldlang.c:2533–2564`). Expression-driven `ADDR`/`LOADADDR` initialization
finds an existing output statement (`2587–2643`). The internal ABS statement
uses `bfd_abs_section_ptr`, outside the output BFD section list (`1444`).

The orphan pass visits each input section once and reuses an output section
or creates at most one new statement for that input
(`ld/ldlang.c:7669–7705`; `ld/ldelf.c:2104–2391`).
`lang_insert_orphan` enters one output statement and adds that input section;
the following code rearranges lists without duplicating their nodes
(`ld/ldlang.c:2009–2270`). Merging removes/combines contents and does not
introduce output BFD section objects. The other direct output constructors
in `ldlang.c:10573,10899` belong to object-only copying, outside this descriptor.

Thus, at output mapping and thereafter,

```text
S = I + 93 = 2 Q + 3 P + 128
output BFD section count <= S
Qout <= S.
```

`lang_init_startof_sizeof` walks this output list once, making two lookups
per section (`ld/ldlang.c:7215–7231,8731–8732`). The selected x86 backend does
not add more output BFD sections after the orphan pass. Dynamic relocations
are input sections already charged above; ELF's hidden table headers are
charged separately below.

Substitution into the existing dynamic-symbol domain interface is now
available without guessing either walk count:

```text
D <= 285 + 44 R + 24 Q + 13 V + 2 Qin + 2 Qout
  <= 611 + 44 R + 32 Q + 12 P + 13 V.
```

`D` bounds the dynamic-symbol count's high water, using the existing lifetime
registration-event transfer (including rollback losses). This substitution
closes its section-walk inputs; it does not replace that event argument with
the separate live/traversal global-entry bound `H`, or bound allocation events.

## ELF section headers and program headers

`assign_section_numbers` charges a null header, each output BFD section,
at most two separate REL/RELA headers per BFD section, a symbol table, its
string table, a possible extended symbol-index table and the section-name
table (`bfd/elf.c:4117–4231`). Retaining both possible relocation headers
avoids depending on a tighter selected-output relocation flag argument:

```text
N = 3 S + 5
ELF section headers, including null, <= N.
```

The internal reserved-index threshold is `SHN_LORESERVE = -0x100u`, or
`2^32 - 256`, not `0xff00` (`include/elf/internal.h:38–61`). Extended ELF
encoding stores large section counts in section zero and large program
header counts in its `sh_info`
(`bfd/elfcode.h:287–305,1129–1134`). There is no general 65,535-header cutoff
in this selected writer.

For program headers, actual automatic mapping creates at most:

- `S` ordinary load segments and one separate header-only load segment;
- `S` note segments and `S` memory-bind segments;
- nine singletons: PHDR, INTERP, DYNAMIC, TLS, GNU_PROPERTY, GNU_EH_FRAME,
  GNU_SFRAME, GNU_STACK and GNU_RELRO.

See `bfd/elf.c:5113–5709`. The selected x86 target has no segment-map mutation
hook (`bfd/elfxx-target.h:518–519`), and generic map cleanup only removes
sections/empty loads (`bfd/elf.c:5033–5078`). Actual mapping therefore has
at most `3 S + 10` entries. The preliminary size estimate has two presumed
loads, at most `S` notes and `S` memory-bind entries, nine singletons, and
two additional x86 large-data estimates
(`bfd/elf.c:4816–4950`; `bfd/elf64-x86-64.c:6180–6199`), or `2 S + 13`.
The common bound

```text
T = 3 S + 13
actual and reserved program-header counts <= T
```

covers both. Layout iterations may retain a larger prior reservation; every
such prior count is bounded by the same `T`
(`ld/ldelfgen.c:259–326`). This is a per-layout count,
not a lifetime allocation count across those iterations.

ELF64 external header sizes are 64 bytes for the file header, 56 for a
program header, and 64 for a section header. A sufficient arithmetic
interface for these particular count/header operations is

```text
64 N <= UINT32_MAX
56 T <= UINT32_MAX.
```

These imply the writer's internal index threshold and signed section-loop
index range with substantial slack. They prevent the 32-bit products in
`bfd/elf.c:5717,5933,7214` from wrapping before assignment to a wider type:
`sizeof_phdr`/`sizeof_shdr` are unsigned-byte fields and the counts are
unsigned int (`bfd/elf-bfd.h:840–841`, `include/elf/internal.h:67–81`). The
section-header product requires `N <= 67,108,863`. This is a derived
sufficient condition on the eventual source projection, not a new source
admission gate. The 8-byte pointer table request is `8 N`; its corresponding
serialized section-header request is `64 N`.

For the final section-header suffix only, if `O` bounds the preceding file
offset, the suffix ends no later than `O + 7 + 64 N`: the writer aligns once
to eight, then adds the section-header product (`bfd/elf.c:7203–7215`). The
independent condition `O + 7 + 64 N <= INT64_MAX` would keep this suffix in
the selected signed file-offset range. This does not yet derive `O`.

## Conditional virtual placement transfer

The selected script also supplies a placement transfer once payload and
alignment envelopes arrive. Define these caller inputs over every layout
pass, after common allocation, input decompression/merging, target relaxation,
EH editing and dynamic sizing:

- `B`: the sum of per-input-section upper bounds on logical payload lengths
  that can be mapped, plus per-item upper bounds on script-emitted data such
  as `LINKER_VERSION`. Each individual bound holds over every layout pass;
  a bound only on the largest aggregate single-pass total is insufficient
  for the prefix/suffix argument below.
  Include NOBITS and nonallocated contents. Exclude only the padding that
  `ldlang` itself adds and that is charged below.
- `A`: a power of two at least 4,096, bounding every effective input and
  output section alignment, including target adjustments. This is a maximum
  alignment in bytes, not an alignment exponent. It is an incoming bound;
  the fixed inventory alone does not discharge generated/common alignment.
- `Hfile = 64 + 56 T`: the file plus reserved program-header envelope.

Then a sufficient envelope for retained section virtual/load-address endpoints is

```text
V = Hfile + B + (I + S + 5) (A - 1) + 8 * 4096.
```

This is a transfer from still-symbolic payload/alignment inputs, not a
numerical final-layout result for null Main. Its terms follow from the
selected layout source:

| Advance | Bound | Source |
| --- | ---: | --- |
| Initial location | `Hfile` | Script `SEGMENT_START("text-segment", 0) + SIZEOF_HEADERS`; selected command has no segment-address override |
| Mapped input payloads and script bytes | `B` | `size_input_section`, `ld/ldlang.c:5665–5671`; script data sizing |
| One alignment per mapped input | `I (A-1)` | `ld/ldlang.c:5610–5633` |
| One alignment per output section | `S (A-1)` | `ld/ldlang.c:6100–6114` |
| Five ordinary script ALIGN expressions | `5 (A-1)` | ALIGNOF(NEXT_SECTION), inside .bss, after .lbss, inside .ldata, after .ldata |
| Data-segment initial adjustment | `2 * 4096` | ALIGN plus possible page residue, `ld/ldexp.c:453–495` |
| RELRO adjustment | `2 * 4096` | Rounded desired end and checked recomputation, `ld/ldlang.c:6627–6686`, `ld/ldexp.c:499–534` |
| Two large-data address expressions | `4 * 4096` | Each script expression is ALIGN(page) plus a residue below one page |

There is one mapped occurrence per input section: duplicate wildcard matches
return without adding another statement when noncontiguous regions are
disabled (`ld/ldlang.c:2701–2736`). Orphan insertion adds no new address
expression for allocated input sections; nonallocated orphans use address
zero (`2009–2055`). Output block size defaults to one, and its only
target-specific alteration is for TIC54x (`1367,2898–2903,7876`), outside this
descriptor. Thus block rounding adds no further padding. Every listed
ordinary ALIGN advances by at most `A-1`; script expressions specifying
address zero cannot increase the envelope.

The RELRO term does not assume that the backwards packing loop moves each
section by less than a page. That would be false when it also eliminates
old gaps. Instead, its target end is the preceding RELRO end rounded up to
a page (`6633–6637`). After the changed-base pass, if the actual RELRO end
exceeds that target the code restores the original base and reruns
(`6674–6686,6710–6714`). Hence the retained RELRO prefix end is bounded by
the initial prefix end plus one page; two pages conservatively cover the
rounding and `DATA_SEGMENT_RELRO_END` expression. Prefix payload/padding are
charged in the initial pass, suffix payload/padding in the retained pass,
without adding entire passes together. Existing padding statements are
reset and recomputed (`6470–6476`), and memory regions are reset before each
recalculation. The same `I/S/B/A/Hfile` envelopes cover every iteration.

The changed-base pass executes before the check and may exceed the retained
envelope before being discarded. Its new base is no larger than the rounded
initial RELRO end: backwards packing subtracts section lengths and rounds
down, and the initial RELRO target is already covered by `V`
(`6633–6663`). Before that base, the original prefix is bounded by `V`.
After it, a fresh full payload/alignment/script envelope is also at most
`V`. Therefore a separate bound on temporary endpoints is

```text
Vtrial = 2 V.
```

This charges the entire envelope again for the trial suffix, without relying
on the subsequent revert to protect arithmetic already executed. Rerunning
with the original base restores the retained bound. The later adjustment
without RELRO uses the common/max-page expression already charged above
(`ld/ldexp.c:469–473`), rather than this changed-base pass.

There is no `AT`, separate load region or overlay in this script.
`bfd_set_section_vma` sets both VMA and LMA (`bfd/section.c:637–643`), and the
default LMA inheritance preserves their equality
(`ld/ldlang.c:6167–6240`). Default region origin is zero (`1516`). Nonallocated
debug sections at zero do not advance the allocated region cursor
(`6284–6291`). TLS BSS can overlap the following non-TLS address domain, but
counting its whole payload in `B` still bounds both endpoints. Therefore
every retained section start/end is in `[0,V]`, with LMA equal to VMA,
subject to the stated input projections and representable arithmetic.

For this placement calculation, requiring `2 V + A <= INT64_MAX` suffices to
keep the positive sums and alignment round-up intermediates, including
discarded changed-base trials, in the selected 64-bit address/file-offset
arithmetic. It is a derived arithmetic condition,
not a host-memory budget. It does not by itself establish relocation reach:
that also needs the selected relocation operand/addend domains and the
signed widths of each encoding. Nor does it prove termination within the
linker's ten mapping attempts or rule out semantic linker diagnostics.

`check-virtual.py` reuses the unchanged source capsule, checks the selected
script's five ordinary alignments/two large-data expressions and the reviewed
reset/recompute guards, and retains this symbolic transfer. No measured
binder object or executed link supplies `B` or `A`.

## Conditional file-position transfer

Given the preceding retained `V`, add a separate caller input `Bfile`: a bound on the
sum of file-backed ELF section payload lengths, including hidden symbol,
index, relocation and String tables, at every writer sizing stage. This
includes `ldlang` padding inside output sections and any late compressed/CTF
contents. It excludes file/program/section headers and file-placement gaps,
which are charged here. Extend `A` to bound these headers' effective byte
alignments too. The existing `A >= 4096` already covers the fixed 1/4/8-byte
hidden-table alignments.

A conservative file-position envelope is

```text
F = (64 + 56 T) + (S + 1) (V + A)
    + 4 Bfile + (3 N + 5) A + 64 N.
```

This is an arithmetic envelope, not a file-size prediction. It intentionally
recharges payloads across disjoint writer phases to avoid assuming that
initial and final non-load section sets are identical. The writer uses the
retained layout after RELRO trial/revert processing; its `V` input does not
replace the separate `2 V + A` condition on trial placement arithmetic.

The load-position routine starts at the 64-byte file header and adds the
reserved program-header area exactly once, whether outside or inside the
header-containing load segment (`bfd/elf.c:5996–6014,6078–6079`). Automatic
mapping has at most `S+1` load segments. Each uses one bias below `A` to make
file position congruent to its virtual address (`6083–6136`). The selected
x86 target has `no_page_alias = 0`, so it does not add the HPPA extra page
(`6141–6148`; default `bfd/elfxx-target.h:121–122`, with no x86 override).

Within a load segment, the code advances through section LMAs and contents;
NOBITS holes later followed by contents are charged through the segment
memory extent (`bfd/elf.c:6295–6433`). Under the preceding selected-script
placement, LMAs equal VMAs, sections are ordered, and all endpoints are in
`[0,V]`. TLS BSS is explicitly excluded from the ordinary load extent. Each
load segment can therefore add at most `V` bytes beyond its alignment.
Charging `V+A` to each of `S+1` segments also covers temporary NOBITS offsets
that are subsequently subtracted (`6136–6161,6452`). The result is saved in
`elf_next_file_pos` (`6512`).

The remaining phases have the following upper bounds:

| Writer phase | Payload allowance | Alignment allowance |
| --- | ---: | ---: |
| Initial non-load-header walk (`bfd/elf.c:6600–6673`) | `Bfile` | `2 N A`, allowing both page bias and section alignment |
| Direct symtab, optional index table and strtab append (`bfd/elflink.c:13023–13031,13442–13478`) | `Bfile` | `3 A` |
| Pending relocation/debug/CTF header walk (`bfd/elf.c:7122–7201`) | `Bfile` | `N A` |
| Final section-name table (`7203–7208`) | `Bfile` | `A` |
| Section-header suffix (`7210–7215`) | `64 N` | `A` |

Each header walk visits at most `N` entries once. The placement helper aligns
the current offset by the section alignment (or a smaller fixed cap) and
adds its size unless it is NOBITS (`bfd/elf.c:4663–4687`). The special
`.shstrtab` finalization is charged separately even if that header was
visited in the preceding walk. The direct symbol-table writer advances its
recorded table size and then corrects `elf_next_file_pos`; its whole payload
is included in `Bfile`. Subsequent content writes seek to the assigned
section offsets and use their bounded section lengths
(`bfd/elf.c:7245–7288`). The selected x86 backend has no begin/section-write
override; its generic final processing changes header flags/OSABI, not file
placement (`bfd/elfxx-target.h:434–435,509–513`,
`bfd/elf.c:13485–13525`). There is no output archive or import-library writer
in this descriptor.

Together with the preceding header-product conditions, `F + A <= INT64_MAX`
is sufficient for these nonnegative file-offset additions, alignment
intermediates and recorded offsets to fit signed64. It leaves physical file
capacity and I/O success external. It also leaves the actual `Bfile` source
projection, relocation processing and layout convergence open. In
particular, it does not infer `Bfile` from input file bytes: decompression,
NOBITS, merged sections, new tables and late writer changes require their
own source-derived interfaces.

`check-file.py` checks the retained source identities, selected hook
exclusions and writer-phase anchors; `file-results.json` records the
conditional interface and its unresolved inputs.

## Original fixed payload and alignment inputs

The [fixed-payload checker](../evidence/retained-linker-layout-20261018/check-fixed-payload.py)
reads the pinned installed ELF/archive bytes without executing them. It
rehashes all 15 fixed file spellings and 1,161 archive members, and reconciles
the existing section, symbol, allocated-byte and alignment-padding counts.
Its new totals cover all original sections, including nonallocated debug,
symbol and String sections. Section zero's extended-count fields are not
payload. The parser checks every file-backed section range, ELF64 symbol
width and power-of-two alignment. Generated Main and binder objects are
neither read nor inferred from a measured output.

| Original input quantity | Explicit fixed inputs | Eight extra loader processings | Processing envelope |
| --- | ---: | ---: | ---: |
| Logical section bytes, including NOBITS | 44,226,801 | 1,979,640 | 46,206,441 |
| File-backed section bytes | 44,102,586 | 1,958,136 | 46,060,722 |
| NOBITS section bytes | 124,215 | 21,504 | 145,719 |
| Allocated section bytes | 11,474,416 | 1,968,904 | 13,443,320 |
| Sum of original symbol sizes | 8,772,513 | 78,224 | 8,850,737 |
| Dynamic symbol size sum | 763,664 | 78,224 | 841,888 |

The last two rows are raw record sums, not automatically bounds on output
copy storage or on repeated allocation events. The existing multiplicity
argument supplies the eight loader allowances; the parser does not infer
them from which objects an observed link extracted. Charging every archive
member at each explicit archive occurrence remains conservative for original
payload. It does not assert every such input is mapped into the output.

Every original fixed section's alignment is at most **64 bytes**. No fixed
symbol has external `SHN_COMMON` or `SHN_X86_64_LCOMMON`, so these inputs
contribute zero common-symbol storage or common-alignment requests.
The external constants are `0xfff2` and `0xff02`
(`include/elf/external.h:40–46`, `include/elf/x86-64.h:123–125`); this is
distinct from BFD's widened internal index encoding. Every fixed symbol's
index fits the ordinary ELF field, so an extended-index companion cannot
hide a common symbol. The checker retains the complete additional x86
header alongside the existing 27-source capsule.

There are no fixed compressed or `.zdebug` sections, `.ctf` payload,
`.sframe` section/type, or GNU attributes section/type. The processing
envelope includes 3,147,288 merge-section bytes, 803,284 `.eh_frame` bytes
and 90,352 property-note bytes. These remain distinct transformation inputs;
in particular, counting original EH bytes is not a claim that EH editing
preserves size. The earlier ET_REL-only EH inventory and editing transfer
are still required. The fixed alignment of 64 does not discharge generated
sections, linker-created alignments, or table-header alignment.

Thus **46,206,441** is the original fixed contribution before transformation
to `B`, and **46,060,722** is the original file-backed input contribution
before transformation to `Bfile`. Neither number is substituted for the
complete post-edit envelope. The source-derived Main object transfer separately
supplies at most 12,712 section-payload bytes (420 ordinary, 2,352 symbol,
6,744 relocation, 2,523 symbol-String and 673 section-String bytes), with
zero NOBITS payload. Binder, EH/SFrame/property processing, synthetic dynamic
payloads and final hidden tables remain to be joined.

## Main substitution and residual work

Substitute only the source-derived Main object envelope:

```text
I <=  77,391 + 2 Qbinder + 3 Pbinder
S <=  77,484 + 2 Qbinder + 3 Pbinder
N <= 232,457 + 6 Qbinder + 9 Pbinder
T <= 232,465 + 6 Qbinder + 9 Pbinder.
```

The constant polynomial terms account for at most 14,877,248 section-header
bytes and 13,018,040 reserved program-header bytes before adding binder
terms. These are coarse upper-bound components, not predicted file sizes or
bounds for a link with the required binder omitted.

The checked source/header joins do not settle the remaining layout work:

- source-derived binder section/payload/alignment and symbol interfaces;
- synthetic payload/event joins, common storage, EH editing and table bytes;
- concrete input/output payload and alignment projections for the conditional
  placement transfer above, plus the selected relaxation/convergence argument;
- a final virtual span that proves signed relative relocation reach and EH
  table offsets, including symbol addends and the fixed runtime inputs;
- the `Bfile` projection for the conditional file-position transfer, and
  individual BFD allocation requests/counters through all those phases.

The selected Linux target's maximum/common page size is 4,096
(`bfd/elf64-x86-64.c:6337–6344`); other target vectors in that file use other
constants. The selected script starts at `SIZEOF_HEADERS` and has
`DATA_SEGMENT_ALIGN`, RELRO alignment, and two large-data page expressions.
The conditional placement transfer now charges those script adjustments;
the source-to-payload and alignment joins remain open. A section-count bound
alone is not a proof of address or file-position bounds. No aggregate host-RAM cap,
compiler/linker execution, solver run or Lean run is introduced here.
