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
(`elfxx-x86.c:733–750`; `include/elf/external.h:205–212`). The selected
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
