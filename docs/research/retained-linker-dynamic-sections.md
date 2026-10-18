# Selected x86 linker GOT/PLT sizing transfer

2026-10-18, Linux x86_64, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This supplies a conditional sizing transfer within the selected ELF64 PIE
link. It continues the [fixed input](retained-link-inputs.md) and
[ELF representation](retained-linker-capacity.md) arguments. Counts below
are caller obligations, not a completed source predicate. The
[source packet](../evidence/retained-linker-dynamic-sections-20261018/README.md)
uses the same pinned Binutils behavior premise. No native tool ran.

## Event inputs and phase boundary

Consider the GOT/PLT and dynamic-relocation size updates in
`_bfd_x86_elf_late_size_sections` through its TLS-descriptor PLT setup,
before EH-frame, SFrame and dynamic-tag handling (`elfxx-x86.c:2275–2462`).
For all invocations of that selected phase, retain:

- W: calls to `elf_x86_allocate_dynrelocs` with a non-indirect symbol,
  including local IFUNC calls through `elf_x86_allocate_local_dynreloc`.
- L: local-symbol GOT entries visited with a positive refcount by its
  separate input-BFD loop.
- Q: sum of the incoming `p->count` values in local and callback dynamic
  relocation lists processed by these invocations, counting repeated visits.
- K: number of late-size phase invocations; S0 and N0 are incoming section
  sizes and PLT relocation counts at the beginning of the composed region.

The selected lifecycle must preserve `0 <= pc_count <= count`, distinct
live list ownership, correct section association and nonnegative sizes.
Do not infer W, L, Q or K solely from final emitted symbol/relocation counts.
The fixed inventory is an input to their later source derivation; generated
Main/binder objects and linker-created symbols remain required. No numerical
whole-link verdict is claimed here.

## Payload additions

For ELF64 x86-64, GOT entries are eight bytes and RELA records are24 bytes
(`elfxx-x86.c:733–750`; `include/elf/external.h:224–228`). The selected
standard, BND and IBT layout variants use PLT entries of at most16 bytes;
ordinary non-lazy entries use8 and IBT variants use16
(`elf64-x86-64.c:576–581,1009–1161`). No VxWorks branch applies.

An ordinary non-IFUNC callback adds at most:

| Contribution | Byte addition |
| --- | ---: |
| Initial PLT header, conservatively charged on every call |16|
| PLT plus optional second PLT (or the alternative GOT PLT) |32|
| GOTPLT jump slot and its RELA record |8+24|
| TLS descriptor GOTPLT pair plus ordinary TLS GOT pair |16+16|
| GOT relocation alternatives plus descriptor relocation |48+24|
| Incoming dynamic-relocation lists |`24*q`|

Thus its addition is at most **`184+24*q`**. The source may take only
one of several alternatives; charging their upper bounds together preserves
the bound (`elfxx-x86.c:113–385,387–553`). List filtering removes entries or
subtracts pc counts before sizing; it cannot increase q under the stated
invariants. Dynamic-symbol/name recording at these sites is separate storage.

A regular IFUNC takes the early helper route
(`elfxx-x86.c:131–163`). The helper adds at most16 header bytes,16 PLT
bytes,8 GOTPLT bytes and24 relocation bytes; an optional GOT adds8+24.
The caller's second PLT adds at most16. Its total **`112+24*q`** is below
the same184 envelope (`elf-ifunc.c:198–345`). In PIE, the helper puts the
q relocation records in `.rela.ifunc`; its static-executable alternatives
are not selected. Local IFUNCs call the same helper through the local hash
traversal (`elfxx-x86.c:562–576,2420–2425`).

Each positive local GOT entry adds at most16 descriptor bytes,16 ordinary
GOT bytes and48+24 relocation bytes: **104 bytes**
(`elfxx-x86.c:2349–2400`). The local relocation-list loop adds24 times its
retained count (`:2302–2340`). Finally each phase can add a two-slot local
dynamic TLS GOT and one RELA (40 bytes), plus TLS-descriptor GOT/PLT setup
including a conservatively new initial PLT header (40 bytes)
(`:2404–2414,2443–2462`).

The selected sizing additions therefore satisfy

```text
Delta_payload <= 184*W + 104*L + 24*Q + 80*K.
```

This is the summed addition to the named output sections, usable in later
single-image layout accounting. It is not an aggregate heap/RAM limit.
Incoming section sizes S0, the initial GOTPLT header, ordinary input sections,
dynamic tags/symbol/string/version/hash tables, copy relocations, unwind
tables, alignment and ELF headers remain separate contributions. The equation
does not charge those as zero. Individual section allocation requests require
their own final sizes within `PTRDIFF_MAX`; repeated bounded requests do not
add a new membership ceiling.

## A narrower intermediate than ELF64 sizes

`elf_x86_compute_jump_table_size` is defined as

```c
((htab)->elf.srelplt->reloc_count * (htab)->got_entry_size)
```

Both operands are **unsigned32**: `section.c:495` and
`elfxx-x86.h:698,812–813`. Assignment to a64-bit field does not widen this
multiplication. With eight-byte GOT entries a sufficient condition is

```text
N <= floor((2^32-1)/8) = 536870911,
```

where N bounds the PLT relocation count at every use, including the earlier
TLS descriptor offset computations. On the selected PIE path each callback
adds at most one to this count. The IFUNC q records go to `.rela.ifunc`;
TLS descriptor records enlarge a section without incrementing the jump-slot
count. Therefore **`N0+W`** is a sufficient count bound for this region.
Counts established before this region and later consumers still need their
own lifecycle join. PLT jump-table subtraction also relies on the existing
association between counted jump relocations and allocated GOTPLT slots.

The adjacent assignment `next_irelative_index = reloc_count - 1` intentionally
produces an unsigned sentinel for an empty table. It is not a reason to reject
a zero-entry program. Its subsequent uses require actual IRELATIVE entries;
their full emission lifecycle is outside this sizing transfer.

Require each incoming list count and its accumulated Q, all `24*q` products,
and each S0 plus the additions to fit their actual64-bit size fields. The
stronger individual-object condition above suffices for the byte products;
earlier refcount accumulation and dynamic-symbol indices are separate. This
records a real32-bit intermediate constraint without inventing a source cap.

The remaining link work is the source-to-event join, other generated
sections and names, unwind/relocation consumers and complete file/address
layout. The broader [capacity design](retained-tool-capacity.md) stays open.

## Selected source-to-event join

Use the previous selected descriptor, complete original input inventory and
empty local-IFUNC table. To avoid confusing this section's relocation count
with the layout's header count Q, write `Trel` for the total **original
relocation-record processing** envelope. Fixed inputs contribute 546,356
records; the eight extra loader processings add eight. Main contributes at
most 281, hence

```text
Trel = 546645 + Trel_binder.
```

This charges every retained input relocation, including nonallocated records
and DSO records that the selected scan actually skips. Generated binder
records remain an explicit input until that object's projection is joined.

The selected dynamic sizing schedule calls `bfd_elf_size_dynamic_sections`
once, with one early and one late target hook (`bfd/elflink.c:6958–6960,
7767–7769`; the earlier symbol-registration schedule supplies the caller).
The x86 early hook walks each input BFD once and scans each eligible section's
relocation array once (`elf64-x86-64.c:3127–3141`; `elflink.c:4260–4331`).
For each relocation, the scan selects either its global-symbol list or its
local-symbol section list, and performs at most one `count += 1`. Its optional
`pc_count += 1` is a subset (`elf64-x86-64.c:3010–3061`). No relocation is
charged into both lists.

Indirect-symbol merging moves the list, combines matching counts and clears
the old owner; it does not retain two live copies (`elflink.c:8263–8292`).
The x86 adjustment and allocation filters remove records, remove pc counts,
or replace a count by its smaller pc count. Thus the sum of all list counts
present at late sizing is at most Trel, with `0 <= pc_count <= count`.
The separate original-section scan and late sizing do not rescan generated
GOT/PLT relocations into these lists. The later relocation emitter is a
different phase. The scalar fields here are 64-bit `bfd_size_type`, not the
32-bit final section relocation count (`elf-bfd.h:3281–3293`). Each new list
record requires an original relocation event; it has 32 bytes on LP64, so
there are at most Trel such fixed-size allocations. This establishes its
relevant cumulative counter and constructor inputs without summing heap
allocations into a new admission limit.

The late sizing hook has one global hash traversal, hence W<=H. Its local
IFUNC traversal emits zero callbacks under the established empty-table join.
Its ordinary local-GOT loop visits each input's local-symbol index once, so
L<=R (`elfxx-x86.c:2294–2425`). The local-GOT backing is one allocation of
`18*local_symbol_count` bytes per participating input, using a 64-bit count:
two eight-byte arrays and two byte arrays (`elfxx-x86.h:1019–1040`). Each
such request is bounded by 18R. Together these specialize the local transfer:

```text
K = 1, W <= H, L <= R, Q <= Trel
Delta_payload <= 184H + 104R + 24Trel + 80.
```

The initial GOTPLT header adds 24 bytes, once (`elflink.c:229–269`;
`elf64-x86-64.c:572,6351`). The newly created PLT relocation section starts
with zero count; its only selected sizing increments are the previously
charged callback/IFUNC paths. Therefore N0=0 and `H <= 536870911` suffices
for the earlier eight-byte jump-table multiplication.

Copy-relocation sizing adds at most one 24-byte record per adjusted global
symbol (`elfxx-x86.c:3635`). The generic `dynamic_adjusted` guard permits
the backend adjustment once per symbol (`elflink.c:3331–3338,3394`), so 24H
bounds those additional records. **The copied symbol bytes themselves are
separate**. Including this initial header and copy-relocation allowance gives

```text
GOT/PLT/dynamic-relocation payload <= 208H + 104R + 24Trel + 104
                                 <= 64102152 + 728R_binder
                                      + 416Q_binder + 24Trel_binder.
```

The second line substitutes the previously derived H bound at V<=51 and
fixed-plus-Main R/header counts. It is an addition envelope for these named
sections, including their earlier maxima if later entries are removed. It
does not include copy BSS, dynamic symbol/String/hash tables, tags, property,
unwind, RELR packing or other generated sections. Each accumulated list/size
and intermediate still must fit the actual field and individual-allocation
conditions above. In particular, this source-to-event join does not certify
the later relocation field values or all auxiliary linker storage.

## Dynamic tags have fixed selected storage

The `.dynamic` table grows one 16-byte ELF64 record per successful
`_bfd_elf_add_dynamic_entry` call. Its new-size accumulator is 64-bit
`bfd_size_type` (`elflink.c:3794–3829`). The selected calls are bounded by:

| Source family | Maximum calls |
| --- | ---: |
| Direct sites in the once-only generic sizing function, excluding auxiliary-filter and null-tag loops | 29 |
| Spare terminating null entries | 9 |
| DT_NEEDED attempts | 22 |
| Generic late dynamic-tag helper, charging both REL and RELA alternatives | 14 |
| x86 PLT tag additions | 3 |
| Total | **77** |

The checker inventories all 31 direct generic sites: the omitted auxiliary
loop has no configured entries; the null loop is charged separately. Every
other direct site is reached at most once, even though several are excluded
by this descriptor. `spare_dynamic_tags` starts at five, with at most three
extra for RELR and no `--spare-dynamic-tags` option; the inclusive loop adds
at most nine (`ldmain.c:780`; `ldelf.c:86–88`; `lexsup.c:1697`;
`elflink.c:8204–8206`). Later RELR finalization replaces spare entries without
growing the table (`elflink.c:13570–13606`).

The existing `.dynstr` lifetime join supplies the conservative 22 needed-tag
attempts. The generic late helper is called once through the x86 late hook's
VxWorks wrapper; that wrapper excludes VxWorks-only additions on this target
(`elfxx-x86.c:2746–2754`; `elf-vxworks.c:305–314`). The helper has 14 literal
sites, including both alternatives that cannot execute together
(`elflink.c:15802–15886`). The selected x86 target adds only its three PLT
tags. Therefore the whole selected `.dynamic` backing/output request is at
most **1,232 bytes**. Tag deletion/replacement cannot increase this bound.
It is valid even when repeated needed-tag attempts are suppressed as duplicates.

The [offline join checker](../evidence/retained-linker-dynamic-sections-20261018/check-join.py)
verifies 31 complete source identities and eight prior input identities,
inventories direct tag sites using literal LF line numbers, and reconciles
the event arithmetic. It executes no compiler, linker or prover. The result
supplies conditional terms for composition; #119 and the full capacity rule
remain incomplete.

Independent narrow review replayed the 31-source join checker and accepted
the scan/list-ownership, late traversal, initial-header, copy-relocation and
tag-site arguments. Its scope is these conditional transfers, with the
previous input multiplicities and H/R premises; it does not establish all
linker intermediates or final layout.
