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

### Sharper selected bound for dynamic symbol indices

Extended ELF headers do not remove every section-index constraint.
`check_dynsym` rejects an ordinary dynamic symbol whose output section index
is at least `0xff00` and below BFD's internal `SHN_LORESERVE`
(`bfd/elflink.c:10542–10555`). The broader `N` above cannot discharge that
guard. The selected descriptor admits a sharper bound without assuming a
particular order for allocated or dynamic-symbol-bearing sections.

Let `Qrel` count original `SHT_REL`/`SHT_RELA` header processing occurrences.
ELF input decoding sets a target section's `SEC_RELOC` flag and relocation
count from such a header (`bfd/elf.c:2802–2911`). Headers represented as
ordinary sections, ignored secondary headers and zero-entry headers can
only reduce the domain. The dynamic-relocation constructor requires a
nonzero input relocation count and `SEC_RELOC`, and caches its result on
that original target section (`elflink.c:4295–4310,15616–15654`,
`elfxx-x86.c:958–1003`). One relocation header refers to one target. Thus
the earlier extra `Q` allowance for these constructors can be replaced by
`Qrel`; the other synthetic families retain their existing charges:

```text
Isharp = Q + Qrel + 3 P + 35
Ssharp = Isharp + 93 = Q + Qrel + 3 P + 128.
```

This bounds every input/output section chain covered earlier; it does not
subtract headers which fail to become BFD sections. The
[offline census](../evidence/retained-linker-layout-20261018/check-section-indices.py)
reads all fixed headers again: 7,897 explicit relocation-header occurrences,
plus one per each of the eight additional loader processings, give
`Qrel_fixed = 7,905`. Main's source-derived writer bound supplies at most
nine more. Generated binder headers remain an incoming term.

There are also **no separate hidden output REL/RELA headers** in this
descriptor. `emit_relocs` is false because neither a relocatable link nor
`emitrelocations` is selected (`elflink.c:12672–12673`). Output relocation
counts are first reset. Ordinary indirect orders add nothing when that flag
is false and the target's `elf_backend_count_relocs` hook is NULL; the
selected x86-64 target retains that generic NULL default
(`elfxx-target.h:644–646`, `elflink.c:12792,12856–12873`).

Explicit section/symbol relocation orders need a separate exclusion: they
would add one even with `emit_relocs` false (`elflink.c:12800–12802`).
`ldwrite.c:155–203` creates those orders only for a `lang_reloc_statement`.
The sole statement constructor is `lang_add_reloc` (`ldlang.c:9039–9055`),
whose sole selected caller is guarded by `bfd_link_relocatable`
(`ldctor.c:368–372`). The parser and selected emulation do not add another
producer. Nonrelocatable constructor sets use ordinary data statements.
Thus these orders are absent too.

The final-link pass consequently clears each output section's `SEC_RELOC`
before file-position/header setup (`elflink.c:12925–12952`). Output section
private-data copying does not copy input relocation-header pointers
(`elf.c:8448–8545`, `elf64-x86-64.c:6165–6184`), and hidden-header creation
requires that now-cleared flag (`elf.c:3840–3871`). Ordinary dynamic
relocation sections remain BFD sections already counted in `Ssharp`; they
are distinct from these hidden headers.

Section-number assignment now assigns each BFD section an index at most
`Ssharp`, with at most five null/special table headers in total
(`elf.c:4127–4231`). Therefore

```text
Nsharp <= Ssharp + 5
Ssharp <= 48943 + Qbinder + Qrelbinder + 3 Pbinder
Ssharp < 0xff00
```

is sufficient for dynamic section-index representability. Equivalently the
still-open binder contribution must satisfy
`Qbinder + Qrelbinder + 3 Pbinder <= 16336`. This discharges the selected
index guard conditionally; it is neither a new general 65,535-section ELF
limit nor a complete link-capacity result. Existing broader bounds remain
valid for the other interfaces. Binder substitution and all payload/reach
requirements are still needed.

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

### Fixed merge-section growth

Merge output can add inter-entry padding, so the original merge-byte sum
is not used as its output bound. The same checker now segments every fixed
`SHF_MERGE` section into strings or fixed-width entries, including the
possible extra zero character supplied by `record_section`
(`bfd/merge.c:354–386,736–776`). It finds 116,433 weighted entries in 4,895
weighted sections. Every fixed String is already terminated, so the extra
terminator allowance is zero. The per-entry effective alignment is the
smaller of the section alignment and the largest power of two dividing its
input offset; offset zero takes the section alignment (`758–771`).

| Merge allowance | Bytes |
| --- | ---: |
| Original entry lengths, including terminators | 3,147,288 |
| Sum of each entry's alignment minus one | 17,428 |
| One final alignment minus one per input section | 3,483 |
| Total merged payload envelope | **3,168,199** |

These are additive charges, so they remain valid for any subset of archive
members actually selected. A merge group requires the same entity size,
String status, section alignment and output section (`677–684`). Hash
deduplication retains one equal-length entry and the maximum of its
occurrences' alignments (`403–427`); its charge is no larger than the sum
of those occurrences' charges. Suffix folding removes entries. Both the
String and fixed-entry output paths align once per retained entry and add
its length (`938–950,1021–1039`), then align the representative section at
most once (`1042–1045`). Charging that final alignment to every input section
covers any grouping. A skipped/nonmerged input retains its original length,
which is also no larger than its assigned charge.

For the `B` requirement on per-input maxima across passes, retain the
**entire** merged allowance in addition to the original fixed payload:

```text
fixed original payload + fixed merge output <= 49,374,640.
```

This deliberately charges the pre-merge payload and the possible merged
representative payload together. It does not presume that the representative
keeps only its original bytes, nor subtract absorbed members before a
possible earlier placement. `bfd_merge_sections` is called once on the
selected ordinary link path before final sizing (`ld/ldlang.c:8695,8747`);
representatives and their merged lengths then remain fixed through RELRO
recomputation. Generated entries may share a group with fixed entries:
their own length/alignment/final-padding charges must be added. The fixed
subtotal does not bound those entries or their alignment. EH, property,
SFrame, dynamic and hidden-table transformations remain separate.

### Property-note rewriting and unwind composition

The [property checker](../evidence/retained-linker-layout-20261018/check-properties.py)
parses every fixed `SHT_NOTE`, checking record extents and alignment. Every
GNU property note is in `.note.gnu.property`; no other note section hides
another property type. The fixed inputs contain four types, all with four
data bytes: `0xc0000002`, `0xc0008002`, `0xc0010001` and `0xc0010002`.
Their union needs 64 serialized bytes after eight-byte property alignment.
Repeated archive or loader processing cannot enlarge this type union.

`_bfd_elf_get_property` reuses a type and keeps the maximum data size;
merging adds at most the union of existing types, while pruning/fixup only
removes types or changes values (`bfd/elf-properties.c:94–133,430–567`,
`bfd/elfxx-x86.c:4926–4970`). Charge all five possible source-added types
even when the selected options leave them absent: x86 feature/ISA properties,
generic needed, memory-seal and stack-size properties. Their data sizes
4/4/4/0/8 serialize to 72 bytes (`bfd/elfxx-x86.c:4340–4363`,
`bfd/elf-properties.c:761–802,868–884`). One note header/name prefix adds 16.
Thus, with `Pgenerated` bounding padded property-record bytes from generated
inputs (their complete property-note byte sum suffices),

```text
Property_output <= 152 + Pgenerated
                <= 296 + Pbinder_property.
```

The second line uses the earlier Main emission allowance of 96 compiler
property bytes plus 48 GAS property bytes. Rewriting aligns records to eight;
new sections also use eight-byte alignment (`elf-properties.c:572–598,692`,
`elfxx-x86.c:4271,4378`). Existing section alignment is included in its input
bound. The writer takes `unsigned int size` despite the preceding wider
size calculation, so require `152 + Pgenerated <= UINT32_MAX`
(`elf-properties.c:604–606`). Add the whole rewritten note to the original
payload charge for per-input maxima. This does not infer validity of future
generated property contents from their size alone.

The [unwind join checker](../evidence/retained-linker-layout-20261018/check-unwind-join.py)
combines the prior fixed EH transfer, Main's source-derived 92-byte/one-FDE
allowance and the linker-created PLT templates. Every lazy PLT variant is a
64-byte array; the nonlazy template is 48 bytes. There are at most three
sections, sized by assignment from those templates, for 160 bytes, six
entries and three FDEs (`bfd/elf64-x86-64.c:705–869`,
`bfd/elfxx-x86.c:2504–2526`). Each has one 24-byte CIE and one FDE; template
selection changes instructions/values without adding entries. All three
input sections have eight-byte alignment (`elfxx-x86.c:4795–4825`).

Use `Aeh` for the eventual output EH alignment and binder inputs `Bbe/Ebe/Nbe/Fbe`
for original EH bytes, entries, sections and FDEs. Main is conservatively
charged `92/4 = 23` entries, including any terminator; its one-FDE source
bound is retained. Applying the established local/cross-input editing
transfer gives

```text
EHedited <= 733772 + 1179 Aeh + Bbe + 11 Ebe + (Aeh + 2) Nbe
F        <= 14952 + Fbe
EHheader <= 119628 + 8 Fbe
EH search-array bytes <= 24 (14952 + Fbe).
```

At `Aeh = 8`, the nonbinder edited payload contribution is 743,204 bytes.
That alignment remains an incoming generated-section condition. Retain the
existing requirements: `Aeh` is a power of two no greater than `2^30`,
each input satisfies `B + 11 E + Aeh + 2 <= UINT32_MAX`, and
`14952 + Fbe <= 536870911`. The PLT-template emitter additionally writes each
PLT byte size into a four-byte FDE range (`elfxx-x86.c:2693–2722`), so each
such size must fit `UINT32_MAX`. Relative address encodings need the separate
reach argument. Replacing the original EH charge with this sum would require
a per-input phase argument; adding it in full to original bytes is sufficient.
The generated PLT sections are included in this edited sum, rather than
being charged as having zero payload.

These joins still require the binder contribution, valid generated DWARF/CFA,
nonoverlapping function ranges and relocation targets. The fixed EH evidence
does not establish those semantics. SFrame has its own format, merger and
late writer; the EH transfer does not cover it.

## Copy storage and optional-section joins

The [copy/optional checker](../evidence/retained-linker-layout-20261018/check-copy-optional.py)
joins the fixed symbol-size census to Main's emission bound and the accepted
binder object-shape transfer. For each input symbol record, charge its ELF
`st_size` four times. `_bfd_elf_merge_symbol` can assign that size once
(`bfd/elflink.c:1724–1741`); its ordinary input call and the two default-version
alias calls give at most three assignments per record
(`elflink.c:2027–2029,2186–2188,5326–5330`). The ordinary loop can additionally
assign the same input size at `elflink.c:5580–5601`. The other positive-size
branch is COMMON (`elflink.c:5610–5611`), absent from all fixed inputs, the
selected Main stream and the accepted binder transfer.

New ELF hash entries initialize `size` to zero (`elflink.c:8240–8242`). The
generic and x86 indirect-copy hooks transfer flags, lists and counters without
copying `size` (`elflink.c:8257–8336`, `bfd/elfxx-x86.c:3143–3186`). The warning
wrapper copies only the base `bfd_link_hash_entry`, leaving the newly constructed
ELF size zero (`bfd/linker.c:1839–1849`). As-needed rollback restores old entries
and removes new ones; it does not leave two live sized entries for the restored
one (`elflink.c:5834–5893`). Consequently the sum of surviving positive sizes is
bounded by the fourfold charge across input-processing occurrences, including
the previously retained extra loader processing allowance.

Dynamic adjustment sets `dynamic_adjusted` before weak-alias recursion, so
each global entry reaches its backend adjustment at most once
(`elflink.c:3329–3379`). An x86 weak alias reuses the definition's location and
returns before allocating storage (`elfxx-x86.c:3525–3542`). The copy path chooses
`.dynbss` or `.data.rel.ro`, then calls the generic copy allocator
(`elfxx-x86.c:3592–3639`). That allocator starts with the defining section's
alignment, only reduces it according to the symbol address, aligns the current
size once and adds `h->size` (`elflink.c:3413–3440`). Original definitions have
alignment at most 64; already copied definitions preserve that bound. Thus, if
`H` bounds the processed global ELF hash entries,

```text
Copy <= 4 SumSizes + 63 H.
```

Fixed `SumSizes` is 8,850,737. Main's sole emitted `.size` describes its
26-byte function. Empty BFD symbols start at zero and the ordinary ELF writer
preserves their size (`bfd/elf.c:9793,8882`); GAS resolves the size expression
and can copy sizes between symbols (`gas/config/obj-elf.c:2598–2603,2104–2111`).
Charge every one of Main's at most 98 outgoing symbols 26 bytes, rather than
assuming only one is nonzero: `SumSizes_Main <= 2,548`. The accepted binder
transfer contributes 11,766. Therefore

```text
SumSizes <= 8,865,051
Copy     <= 35,460,204 + 63 H.
```

The component is 49,388,748 bytes when the external symbol join supplies
`H <= 221,088`. This is a conditional substitution, not a new independent
derivation of `H`. Add the entire copy-storage bound to both `B` and `Bfile`;
that is conservative for the NOBITS portion. Copy relocation bytes `24 H`
remain a separate synthetic-relocation charge. This establishes storage and
alignment bounds, not the absence of protected-copy diagnostics or relocation
range errors.

The selected `collect2` argv contains no `--build-id` or `--package-metadata`.
Their state starts as null globals (`ld/ldelf.c:52–56`), and their positive
setters are the explicit option handlers (`ld/emultempl/elf.em:859–880`).
The `sha1` spelling at `elf.em:849` is the default argument of an enabled
build-id option, not unconditional enablement. The after-open creation gate
requires a nonnull value (`ldelf.c:1264–1287`). Both new payload contributions
are therefore zero. Existing input notes are already charged in original
payload and are not excluded by this statement.

The selected interpreter override is `/lib64/ld-linux-x86-64.so.2`, 28 bytes
including NUL. The earlier x86 default `/lib/ld64.so.1` is shorter
(`elfxx-x86.c:29,750–751,4732–4734`), and the late override assigns its exact
string length (`ldelf.c:1846–1855`). A 28-byte, alignment-one per-item maximum
covers both phases; it is added once to `B` and `Bfile`.

There are no fixed input SFrame names or types. Main's pinned assembler
defaults and selected stream leave the SFrame gate false; the binder transfer
has no SFrame section. The x86 PLT constructor requires an actual input
`.sframe` section (`elfxx-x86.c:4836–4839`; the scan is
`bfd/elf-sframe.c:178–189`), so it creates no synthetic SFrame inputs. The later
mapped-input predicate stays false (`elf-sframe.c:199–212`), and the final
encoder returns when its merged section is null (`elf-sframe.c:709–715`).
Thus SFrame contributes no input/synthetic payload or encoder backing requests.
An empty `.sframe` output declaration in the default script does not invalidate
this result; this is not a claim that no output-section declaration exists.

The checker separately verifies absence of fixed `.ctf` names, including
empty sections; zero byte totals alone would not suffice. Main emits none,
and the binder section inventory has none. `ctf_bfdopen` returns
`ECTF_NOCTFDATA` before reading section contents when `_CTF_SECTION` is absent
(`libctf/ctf-open-bfd.c:50–64`; its `.ctf` spelling is
`libctf/ctf-open.c:35`). `ldlang_open_ctf` therefore leaves `ctf_output` null,
and both merge and write return (`ld/ldlang.c:3840–3869,3897,3990`). CTF output
payload is zero. The libctf initialization/debug call is not excluded from
ordinary process bookkeeping by this payload argument.

Fixed, Main and binder inputs also have no object-attribute sections. The
selected x86 backend retains null GNU-property/attribute translation hooks
(`bfd/elfxx-target.h:569–573`), and has no frozen object-attribute configuration
writer. The input search returns a candidate with no attributes
(`bfd/elf-attrs.c:712–792`); the null translation hooks return immediately
(`elf-attrs.c:824–847`), and the empty merge leaves its lists empty
(`elf-attrs.c:1991–2032`). Setup then returns before creating a section
(`elf-attrs.c:2153–2183`). Object-attribute output payload is zero. Empty-list
bookkeeping remains outside this zero-payload claim.

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
- binder substitution into the sharper `Ssharp < 0xff00` dynamic-symbol
  section-index condition above;
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
