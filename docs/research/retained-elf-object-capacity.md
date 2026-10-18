# Selected null Main ELF object transfer

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This continues the [GAS symbol/fixup transfer](retained-assembler-capacity.md)
through the pinned BFD ELF64 relocatable-object writer. The resulting file
size and metadata bounds are inputs to later link composition. They do not
establish all assembler storage, binder-object capacity or final relocation
reach. No compiler, assembler, linker or prover ran.

The [source bundle](../evidence/retained-assembler-capacity-20261018/README.md)
retains Binutils commit `5e56594815854de5eca35c7c04b11705d0f19c02`.
[Object-writer excerpts](../evidence/retained-assembler-capacity-20261018/object-source-excerpts.md)
use literal LF numbering; the
[offline result](../evidence/retained-assembler-capacity-20261018/object-check-results.json)
checks identities, external record sizes and arithmetic. The installed-source
behavior and Linux LP64 premises remain those of the earlier transfer.

## Writer and section boundary

GAS opens a new BFD object and closes it once through `bfd_close`
(`gas/output-file.c:34–54,70–107`). It supplies nine ordinary output sections,
at most 88 symbols and at most 281 relocations, including optional build-note
relocations. Internal register/expression sections were removed from the
output list; ABS/UND are static sections outside that list. The selected
output is relocatable: no executable/shared-library flags or input-copy state,
no groups, debug/CTF compression, secondary relocations, linker build-id or
package-metadata callbacks. The `.gnu.build.attributes` payload already
charged by GAS is a separate mechanism.

`_bfd_elf_compute_section_file_positions` initializes the header, makes the
section headers, assigns indices and serializes symbols once; subsequent
calls return through `output_has_begun` (`bfd/elf.c:4695–4793`). The selected
x86 fake-section hook only updates a flag. It does not create a section or
symbol (`bfd/elf64-x86-64.c:6154–6163`). The target does not override the
begin-write, section-processing or final-write hooks; their defaults are
absent or the generic OSABI/flags updater, which allocates no output contents
(`bfd/elfxx-target.h:431–437,509–514`,
`bfd/elf64-x86-64.c:6348–6420`, `bfd/elf.c:13485–13527`).

On the GAS `link_info=NULL` path, each ordinary section can acquire at most
one relocation-section header. The branch creating both REL and RELA belongs
to an actual relocatable link, and is absent here (`bfd/elf.c:3836–3884`).
Charge nine relocation sections even though only the frame/property/build-note
fields can carry fixups. ELF numbering adds the null header, `.symtab`,
`.strtab` and `.shstrtab`:

```text
section headers <= 1 + 9 + 9 + 3 = 22.
```

The `SHN_LORESERVE` rejection and extended symbol-index table thresholds are
therefore not reached (`bfd/elf.c:4117–4260`). This is the selected writer's
actual section-count check, not an assertion that ELF inherently lacks
extended numbering. Each metadata relocation header is 80 bytes on LP64;
the section-header pointer table has at most 22 eight-byte entries. The null
header adds one separate 80-byte object; ordinary headers are already embedded
in their BFD section metadata (`include/elf/internal.h:100–120`).

Relocation names prefix the section name with `.rela` (or the shorter `.rel`)
and a NUL (`bfd/elf.c:3535–3593`). The longest ordinary name is
`.gnu.build.attributes`; every prefixed or fixed metadata name fits 32 bytes
including NUL. The constructor's `sizeof ".rela" + strlen(name)` request
fits that bound independently of string-table storage.

## Symbol mapping, strings and relocation records

`elf_map_symbols` filters and reorders the incoming symbols. For each ordinary
section it may additionally include that section's **existing** BFD symbol;
it creates no new BFD symbol object (`bfd/elf.c:4527–4659`). Thus the outgoing
count is at most `88+9=97`, plus the mandatory null symbol. The earlier 102
BFD symbol allocation bound is unchanged by this mapping step.

The map first allocates an array indexed by original BFD section indices.
The thirteen previously charged initial sections, including the static pair,
conservatively bound `max_index+1` by thirteen; removed internal sections may
leave holes, but they do not increase a prior index. Its request is at most
104 bytes. The reordered output pointer array is at most `97*8=776` bytes.
Symbol numbers written to `udata.i` are 1 through 97 and therefore also fit
the later signed-int lookup in `_bfd_elf_symbol_from_bfd_symbol`
(`bfd/elf.c:7349–7402`). That lookup reuses the section map for local section
symbols, without another constructor.

`swap_out_syms` allocates one temporary `elf_sym_strtab` and one serialized
record per output symbol, including null. On this ABI the temporary record
is 40 bytes, so the two arrays are at most **3920** and **2352** bytes
(`bfd/elf-bfd.h:598–602`, `bfd/elf.c:8723–8784,8804–8850`). The ELF64 symbol
record is 24 bytes, derived from its byte-array declaration rather than a
host structure assumption (`include/elf/external.h:163–171`). No
`.symtab_shndx` array is needed. The CTF callback is guarded by nonnull link
information and is absent for GAS (`bfd/elf.c:9052–9083`).

Apply the [ELF string-table contract](retained-linker-capacity.md#elf-string-table-input-contract)
separately to the two instances:

| Instance | Distinct nonempty names | Bytes/name incl. NUL | Unshared bytes incl. leading NUL | Positive reference events |
| --- | ---: | ---: | ---: | ---: |
| Symbol strings | 97 | 26 | `1+97*26=2523` | 97 |
| Section strings | 21 | 32 | `1+21*32=673` | 42 |

The symbol table inserts at most one name per non-null output symbol; local
section symbols normally have no name, but charging them preserves the bound.
The section table receives its three fixed metadata names and up to nine
ordinary and nine relocation names. Index assignment clears references and
then adds one reference per retained section; counting both the original
add and this addref gives 42 positive events, independent of deduplication
(`bfd/elf.c:4117–4260,7008–7084,8825–8850`). There is no rollback or later
debug-name insertion in this selected path. Finalization and offset uses
consume the corresponding references once per serialized record. These
counts fit the separate length, entry, reference and four-byte offset
conditions of the string-table contract. No suffix-sharing credit is needed.

For relocations, `elf_write_relocs` allocates one buffer and serializes one
record per supplied relocation. It does not synthesize another relocation
or symbol (`bfd/elfcode.h:930–1083`). The selected target uses RELA;
charging the larger ELF64 RELA record also covers REL. Each is 24 bytes, so
at most **6744 bytes** are needed for any one section's buffer, or for all
such buffers' serialized payload combined. The unsigned relocation loop
bound is 281. Source symbol indices remain at most 97 before packing into
ELF64 `r_info`; local section-relative offsets and stored addends use the
existing 64-bit representations. This storage argument does not prove the
later linker's displacement constraints.

## File placement

The selected ELF64 writer uses a 64-byte file header, 64-byte section
headers and `LOG_FILE_ALIGN=3` (`bfd/elfcode.h:129–136,2053–2070`,
`include/elf/external.h:69–84,124–136`). It initializes the file as `ET_REL`
with no program headers (`bfd/elf.c:7008–7084`). The non-executable placement
branch starts just after the ELF header and assigns ordinary section contents
without a segment map. It caps their file alignment at eight bytes, even if
an in-memory section alignment were larger (`bfd/elf.c:4667–4690,6857–6920`).

Symbol and relocation tables use eight-byte alignment; both string tables
use one. Relocations and section names are placed later, followed by the
eight-byte-aligned section-header array (`bfd/elf.c:4750–4793,7122–7218`).
There are at most nine ordinary-content placements, two symbol/string
placements, nine relocation placements and two visits to `.shstrtab`
(the first has zero size before finalization), plus the final header-array
alignment. Charging **24 alignment events**, each adding at most seven
bytes, safely covers all 23 possible visits. `.bss` has no file payload.
No virtual address, load segment or linker-script page gap is inserted into
this relocatable object.

At the selected compiler identifier length `I=29`, the complete bound is:

| File component | Bytes, at most |
| --- | ---: |
| ELF header | 64 |
| Previously derived ordinary GAS payload `391+I` | 420 |
| 98 symbol records | 2352 |
| 281 relocation records | 6744 |
| Symbol strings | 2523 |
| Section strings | 673 |
| Alignment padding | 168 |
| 22 section headers | 1408 |
| **Complete null Main object file** | **14352** |

Every offset, alignment addition, section-size product, header-array product
and file-pointer difference in this placement is consequently small enough
for its selected type. In particular, narrowing `e_shnum` and `st_shndx` is
safe, and the string offsets satisfy their independent 32-bit conditions.
The last serialized header array is also an individual 1408-byte allocation
(`bfd/elfcode.h:1101–1167`). This is a source-derived upper bound, not an
observed object size or a proposed independent language limit.

The remaining assembler storage includes fixed BFD/section/hash initialization,
common notes/frchain backing, other fixed parser tables and allocator overhead.
The object result supplies nine ordinary sections, at most 98 serialized
symbols, 281 relocations and this file-size envelope to the linker lane.
Fixed library objects, generated binder objects, linker-created sections and
the final image's relocation reach still require their own joins.
