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
at most 88 **output-chain** symbols and at most 281 relocations, including optional build-note
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
count is at most `88+9=97`, plus the mandatory null symbol. The corrected 104
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

The subsequent [startup and lifetime transfer](retained-assembler-startup.md)
supplies BFD/section initialization and the output BFD's allocation counter;
the concrete string-table arena specialization follows below. The remaining
assembler storage includes parser/relaxation subsidiary state and the actual
production invocation/path join.
The object result supplies nine ordinary sections, at most 98 serialized
symbols, 281 relocations and this file-size envelope to the linker lane.
Fixed library objects, generated binder objects, linker-created sections and
the final image's relocation reach still require their own joins.

## Concrete ELF string-table allocator requests

The [offline specialization](../evidence/retained-assembler-capacity-20261018/check-elf-strings.py)
reuses the two name/reference envelopes above. Each `_bfd_elf_strtab_init`
creates an ordinary-heap control object, one independent hash objalloc, and
a 64-slot ordinary-heap entry-pointer array (`bfd/elf-strtab.c:47–126`).
One instance is created by file-header initialization; the other by symbol
serialization (`bfd/elf.c:7017,8748`). Both execute once under the output
lifecycle already reviewed. No selected route changes BFD's default hash
size; GAS's historical hash-size and reduce-memory options are no-ops
(`gas/as.c:1184–1188`).

Each hash starts at **4,051 buckets**, requesting **32,408 bytes**. Its
count never exceeds 97 for symbol names or 21 for section names; both lie
below `floor(3*4051/4)=3038`, so neither hash grows
(`bfd/hash.c:344–345,406,424–487,611–661`). These are BFD chaining hashes,
distinct from the libiberty open-addressed GAS tables. Their bucket requests
do not use the shared notes obstack and do not increment the output BFD's
main-arena `alloc_size`.

On the selected ABI, a `bfd_hash_entry` has three eight-byte fields.
`elf_strtab_hash_entry` adds two four-byte fields and an eight-byte union,
so its actual reviewed layout is 40 bytes; use a conservative **64-byte**
request ceiling. The string-table control has the already bounded hash
control plus four eight-byte fields; **96 bytes** suffices
(`bfd/elf-strtab.c:29–58`). Its subclass constructor supplies the entry to
the superclass and does not allocate a second hash entry (`:62–90`).

All selected string-table calls use `copy=false`: fixed metadata names,
ordinary/relocation section names and symbol names retain already charged
storage (`bfd/elf.c:3547–3549,3650–3656,7072–7077,8843–8849`). Thus the hash
name-copy branch in `bfd/hash.c:571–584` is absent. The symbol table's pointer
array grows from 64 to at most 128 slots; the section table remains at 64.
Their respective largest ordinary-heap requests are **1,024** and **512**
bytes. Finalization allocates a separate sorting array of at most D+1 pointers,
giving **784** and **176** bytes (`bfd/elf-strtab.c:161–179,387–415`). No save
or rollback record is created on this ordinary object-writer path.

Objalloc gives each hash a 24-byte control and a 4,064-byte initial small
chunk with sixteen-byte header. The 32,408-byte bucket request takes a
separate **32,424-byte** large chunk; its size already satisfies eight-byte
alignment. It leaves the initial 4,048 bytes available for entries. Using
the conservative aligned 64-byte entry ceiling, the symbol hash needs at
most two small chunks and the section hash at most one:

```text
floor((4064-16)/64) = 63 entries per small chunk
ceil(97/63) = 2,  ceil(21/63) = 1.
```

These bounds preserve all distinct allocator contexts and individual request
sizes. Old/new pointer arrays may coexist during reallocation. Their physical
storage costs are not added into a language RAM ceiling. The generic
string-table transfer still supplies the length/refcount/offset and suffix-
merging argument; this specialization only supplies concrete storage counts
for the selected object. These are source-level GAS/BFD/libiberty requests;
the trusted libc allocator and `qsort` internals are not expanded here.
It does not establish the remaining GAS lifecycle, binder object or final-link
capacity.

Independent narrow review replayed the seventy-source checker and inspected
the complete hash/objalloc constructors, growth branches, string-table layouts,
add/finalize paths and selected no-copy calls. It accepted these storage
specializations, retaining the earlier name-count and two-initialization
lifecycle results as inputs. It did not re-establish those inputs, whole GAS
capacity, libc internals or the final link.

## Selected symbol names contain no literal `@`

The compiler's selected null stream emits `_ada_main`, fixed `main.adb`,
internal labels with prefixes `.L`, `.LCFI`, `.LFB` and `.LFE` followed by
decimal counters, and GNU-property numeric labels 0–4. Its section names are
the fixed inventory above. The [native symbol/output transfer](retained-native-expansion.md#null-symbol-constructors-and-direct-unit-output-closure)
supplies this premise; the forced dummy variable emits no assembler symbol.
Directive tokens such as `@function` and `@progbits` are not symbol spellings.
The following GAS/BFD transfer extends the premise to the object symbol table.

| Name-producing or preserving route | Selected source argument |
| --- | --- |
| Ordinary and local/full symbols | `save_symbol_name` duplicates the input spelling; the selected headers define no `tc_canonicalize_symbol_name`. Both full construction and local conversion use that spelling; cloning copies the original BFD name (`gas/symbols.c:345–424,437–487,767–792`). Even optional ASCII uppercasing introduces no `@`. |
| Temporary and expression symbols | `symbol_temp_new`, `symbol_temp_make` and `make_expr_symbol` use `FAKE_LABEL_NAME`, whose selected default is `L0\001` (`gas/write.h:24–40`, `gas/symbols.c:903–924`, `gas/expr.c:57–94`). The selected Linux/x86/ELF headers do not override it. |
| Numeric labels | `fb_label_name` uses optional prefix `.`, literal `L`, unsigned decimal numbers and the `\002` separator (`gas/symbols.c:239,2148–2165`, `gas/config/obj-elf.h:127–129`). No arbitrary name is interpolated. |
| Dot and predefinitions | Dot is `.` (`gas/symbols.c:3157–3167`); `GAS(version)` and optional `GAS(date)` have no `@` and do not enter the selected output chain, as the [lifecycle correction](retained-assembler-startup.md#predefined-symbol-accounting-correction) establishes. |
| File and section symbols | The file-symbol hook uses the selected `main.adb` spelling (`gas/config/obj-elf.c:203–215`). GAS section symbols reuse BFD section names (`gas/subsegs.c:235–281`), and the BFD section hook assigns `newsect->name` directly (`bfd/section.c:817–833`). The fixed optional `.sframe` union has the same property. |
| Version renaming | New symbols initialize `versioned_name` to null. Only the absent `.symver` input route populates its list; rename and alias creation are guarded by a nonnull list (`gas/config/obj-elf.c:1801–1862,2086–2098,2616–2656`). |
| Serialized ELF names | The object writer emits the empty name for selected local section symbols or interns the existing `syms[idx]->name`; it does not synthesize a version suffix (`bfd/elf.c:8830–8849`). |

The established stream has no user assembly, arbitrary section/group names,
GOT operand or `.symver` directive. CFI and optional SFrame temporary labels
use the same temporary constructors; their section symbols reuse the fixed
names. These selected constructors and preservation paths therefore establish
that **every serialized symbol name in the null Main object contains no
literal `@`**. This is the input-name premise needed by the linker's symbol
version accounting, not a claim about symbols in fixed dependency objects or
those subsequently created by the linker.

The [offline replay](../evidence/retained-assembler-capacity-20261018/check-symbol-names.py)
checks the existing source capsule plus three complete selected include files
(`te-linux.h`, `obj.h`, `tc.h`), retaining all earlier source identities. It
checks name-constructor anchors and the absence of selected overrides, with
literal LF source numbering. Its [result](../evidence/retained-assembler-capacity-20261018/symbol-name-check-results.json)
is a conditional source transfer, not an execution or a full parser/writer
allocation inventory. Whole-assembler and whole-tool capacity remain open.

Independent review by the native-expansion lane replayed all 90 source
identities and obtained a byte-equal result. It checked the constructor,
selected-header, version-list and serialization paths and accepted this narrow
transfer; no whole-assembler allocation claim was reviewed or implied.
