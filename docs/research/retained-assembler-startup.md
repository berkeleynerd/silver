# Retained GAS startup and output-BFD metadata capacities

2026-10-18, Linux LP64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This supplies another component of the selected null-Main
[assembler argument](retained-assembler-capacity.md). It bounds fixed GAS
option storage and the output BFD's control and section metadata. It joins
the existing [hash](retained-assembler-hashes.md),
[backing](retained-assembler-backing.md) and
[ELF object](retained-elf-object-capacity.md) packets without claiming complete
assembler storage or a source-to-tool capacity rule. No native tool was run.

The [offline checker](../evidence/retained-assembler-capacity-20261018/check-startup.py)
uses the same retained Binutils commit
`5e56594815854de5eca35c7c04b11705d0f19c02`. Its field accounting assumes the
selected Linux ABI: pointers, size_t, long, bfd_vma and bfd_size_type occupy
eight bytes, int/unsigned int four, and no reviewed field requires alignment
above eight. Relevant source behavior remains an external correspondence
premise. The checker reconciles source bytes and arithmetic, not C semantics.

## Fixed GAS option and include storage

`parse_args` concatenates its short option strings and allocates the combined
long option table (`gas/as.c:459–473,531–629`). Counting every conditional
entry gives 25 non-NUL standard short characters and ten target characters,
so the combined allocation is at most **36 bytes**, including its NUL.
The standard long table has at most 56 entries; the x86 table has 36 named
entries **plus its existing null sentinel** (`gas/config/tc-i386.c:17204–17300`).
The additional sentinel reserved by `parse_args` makes at most 94 entries.
At 32 bytes per `struct option`, the allocation is at most **3,008 bytes**.
Both are ordinary heap requests, not notes-obstack growth. The checker counts
the retained declarations, including mutually exclusive branches.

`init_include_dir` allocates one pointer, **eight bytes**, containing the
static current-directory string (`gas/read.c:6598–6603`). No include option
or include directive occurs in the selected invocation/emission. No response
file, dependency-output option, command-line symbol definition, listing or
debug-output option is selected. The production argv must independently
establish those premises, together with the existing A/P notes contract.

The ordinary `.file "main.adb"` directive uses the previously charged notes
string and ELF file symbol. Its dependency-registration call returns before
allocation because `dep_file` remains null (`gas/depend.c:23–74`). It does not
enter numbered DWARF file tables. `read_begin`'s STABS initialization,
`dwarf2_init` and `eh_begin` reset existing state; their optional debug object
creation is not implied by initialization. First-input opening does not push
an include/macro scrub state. The selected local numeric labels use the
existing static low-label counters. These observations exclude those specific
routes; they do not establish an exhaustive allocation inventory for every
parser operation.

The two unconditional `xatexit` registrations, plus the optional statistics
registration even if conservatively counted, fit its 32-entry static first
block (`gas/as.c:1333,1387–1394`, `libiberty/xatexit.c:45–85`). No additional
heap block is needed for these registrations. Locale, stdio and underlying
allocator internals remain part of the selected host-library premise.

## Output BFD control and section metadata

GAS opens one output object BFD. `_bfd_new_bfd` allocates its control object,
creates its main objalloc, and initializes a separate section-name hash with
13 buckets (`bfd/opncls.c:67–99`). `bfd_openw` copies the output filename
through `bfd_set_filename`; let **P** include that pathname's terminating NUL
(`:729–765,1985–2010`). P is the actual path, not necessarily `main.o`.

The x86 hook allocates **`elf_x86_obj_tdata`**, not just generic `elf_obj_tdata`
(`bfd/elfxx-x86.h:750–763,963–966`, `bfd/elfxx-x86.c:40–44`). It embeds generic
ELF data and adds three pointers. `bfd_elf_allocate_object` also creates the
output-only ELF record (`bfd/elf.c:295–311`). The generic record embeds eight
internal section headers and a `known_obj_attributes[2][77]` array: its 154
sixteen-byte elements alone occupy 2,464 bytes. Ignoring that fixed array
would materially undercount startup storage.

Conservative per-request ceilings are:

| Object | Request count upper | Raw bytes per request upper |
|---|---:|---:|
| Output BFD control | 1 | 1,024 |
| x86 ELF object data | 1 | 4,096 |
| Output-only ELF data | 1 | 192 |
| ELF section data | 13 | 320 |
| Section hash entry, including embedded asection | 13 | 576 |
| Section-hash bucket array | 2 | 248 |
| Objalloc control, for these two arenas | 2 | 24 |
| Initial small objalloc chunk, for these two arenas | 2 | 4,064 |
| Output filename copy | 1 | P |

The layout accounting deliberately overcharges each scalar, pointer,
bitfield and terminating declaration by an eight-byte slot, even charging
all union alternatives separately. Embedded structures/arrays are then
added in full, and comma-separated extra fields are charged separately.
This yields control 784, x86 object data 3,816, output ELF data 176,
section data 304 and section-hash entry 488 bytes, all within the table's
ceilings. It is a source-layout upper bound, not an observed `sizeof` result.
The checker retains the declaration ranges and their counts.

Nine ordinary sections plus GAS's register/expression sections give at most
eleven created section hash entries; charging thirteen covers the two static
ABS/UND sections as well. Those static sections bypass the name hash, but GAS
explicitly calls their ELF section hook (`gas/as.c:1355–1360`). The hook caches
one `bfd_elf_section_data` for each section (`bfd/elf.c:3315–3344`). This is
separate from the previously charged BFD symbol objects. Header-only
relocation sections in the object writer are not extra asection constructors.

The section hash starts at 13, grows once to 31 after its tenth distinct
entry, and cannot grow again with thirteen entries: `13 <= floor(3*31/4)`.
Thus its retained bucket arrays contain 13 and 31 pointers, at most 104 and
248 bytes. Its superclass uses the supplied section-hash object, so it does
not allocate another entry (`bfd/section.c:790–809`). Selected name insertion
uses `copy=false`; it retains the existing names instead of copying them
(`:1114–1152`). This arena is distinct from the output BFD's main objalloc
and from the ELF string tables' own hash arenas.

## Allocator arithmetic and the cumulative BFD counter

The existing [objalloc transfer](retained-linker-capacity.md#bfd-hash-growth-has-a-different-boundary-from-gccs-hash-table)
applies: eight-byte request rounding, sixteen-byte large-chunk headers and
4,064-byte small chunks. For every selected request q it is sufficient to
require `0 <= q` and `q+23 <= PTRDIFF_MAX`; this covers rounding and headers
as well as `bfd_alloc`'s signed-long check. For this packet the largest q is
`max(P,4096)`. Larger later requests retain their own bounds. The number of
small chunks may increase; no aggregate physical-memory limit is imposed.

There is nevertheless a separate representation counter:
`bfd_alloc` adds every successful raw request to the output BFD's 64-bit
unsigned `alloc_size` (`bfd/libbfd.c:434–458`). Successful allocation-size
checks alone do not prove that cumulative addition safe. The listed main-arena
startup requests contribute at most

```text
P + 4096 + 192 + 13*320 = P + 8448.
```

Let R include every other positive raw `bfd_alloc`/`bfd_zalloc` request over
this output BFD's lifetime, including any requests subsequently released.
The sufficient joined counter condition is `P+8448+R <= 2^64-1`. R includes
the already bounded symbols, mapping and serialization requests as applicable;
this packet does not yet provide an exhaustive later-request count. Hash
arenas allocate directly through objalloc, so their requests do not increment
this particular counter. This condition protects a tool representation;
it is not a total-RAM gate or permission to omit later storage analysis.

The output BFD's ID counter advances once and its section count advances at
most eleven times in this stream. Fixed startup does not approach their
32-bit limits. The remaining assembler and whole-link joins include the
complete later allocation inventory, actual production argv/paths, host
library behavior, binder inputs and final-link layout/relocations.
