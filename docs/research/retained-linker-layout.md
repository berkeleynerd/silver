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

This is the existing live/traversal symbol-domain bound. It is not a bound on
lifetime dynamic registration or allocation events.

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
- input/output alignment padding, script page adjustments and relaxation;
- a final virtual span that proves signed relative relocation reach and EH
  table offsets, including symbol addends and the fixed runtime inputs;
- file-position growth before the suffix, and individual BFD allocation
  requests/counters through all those phases.

The selected Linux target's maximum/common page size is 4,096
(`bfd/elf64-x86-64.c:6337–6344`); other target vectors in that file use other
constants. The selected script starts at `SIZEOF_HEADERS` and has
`DATA_SEGMENT_ALIGN`, RELRO alignment, and two large-data page expressions.
Those facts are retained for the next join; a section-count bound alone is
not a proof of address or file-position bounds. No aggregate host-RAM cap,
compiler/linker execution, solver run or Lean run is introduced here.
