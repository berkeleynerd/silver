# Retained GAS startup and output-BFD metadata capacities

2026-10-18, Linux LP64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This supplies another component of the selected null-Main
[assembler argument](retained-assembler-capacity.md). It bounds fixed GAS
option storage and the output BFD's control and section metadata. It joins
the existing [hash](retained-assembler-hashes.md),
[backing](retained-assembler-backing.md) and
[ELF object](retained-elf-object-capacity.md) packets without claiming complete
assembler storage or a source-to-tool capacity rule. No native tool was run.

The [predefined-symbol correction](#predefined-symbol-accounting-correction)
supersedes the first published allocation totals. Its adjacent entry/exit
inventory checks startup, input setup and shutdown routes; complete inner
parser/writer and emitted-event composition remain open.

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
the subsequent lifetime join below supplies the selected R. Hash
arenas allocate directly through objalloc, so their requests do not increment
this particular counter. This condition protects a tool representation;
it is not a total-RAM gate or permission to omit later storage analysis.

The output BFD's ID counter advances once and its section count advances at
most eleven times in this stream. Fixed startup does not approach their
32-bit limits. The remaining assembler and whole-link joins still include
parser/relaxation storage, actual production argv/paths, host-library behavior,
binder inputs and final-link layout/relocations.

## Selected output-BFD lifetime counter join

GAS closes this output once. Before invoking BFD close, `output_file_close`
sets `stdoutput=NULL`, so a subsequent exit handler cannot retry the writer
(`gas/output-file.c:69–101`). `bfd_close` calls the format writer once and
then closes/releases the BFD (`bfd/opncls.c:859–865`). Section writes and the
final object writer share `_bfd_elf_compute_section_file_positions`; its
`output_has_begun` guard and successful final assignment ensure that header
initialization, numbering, symbol mapping and symbol serialization run once
(`bfd/elf.c:4695–4790,7221–7231,10035–10045`). A failed initialization aborts
this selected successful assembly path rather than supplying a retry budget.

In addition to the startup objects, the selected main objalloc receives:

| Request class | Total raw bytes upper | Source |
|---|---:|---|
| 104 previously charged BFD symbol objects | 13,312 | `bfd/elf.c:9788–9797` |
| Nine relocation headers | 720 | `bfd/elf.c:3561–3592,3836–3874` |
| Nine relocation-name copies | 288 | `bfd/elf.c:3535–3553` |
| 22 section-header pointers | 176 | `bfd/elf.c:4233–4248` |
| Null internal section header | 80 | same |
| Section-symbol map | 104 | `bfd/elf.c:4527–4557` |
| Reordered symbol pointer array | 776 | `bfd/elf.c:4612–4616` |
| Serialized relocation buffers, combined | 6,744 | `bfd/elfcode.h:930–975` |
| Serialized section-header array | 1,408 | `bfd/elfcode.h:1101–1155` |
| **R** | **23,608** | |

These are the already established symbol and object-writer bounds, joined to
the counter's allocator domain. In particular, 281 relocations are shared
across the section buffers: the 6,744-byte bound is their sum, not a per-section
amount multiplied by nine. The two symbol serialization arrays are ordinary
`bfd_malloc` requests, not `bfd_alloc` requests (`bfd/elf.c:8764–8783`). Their
3,920/2,352-byte individual bounds remain required, but they do not increment
this BFD's `alloc_size`. The two ELF string tables likewise allocate through
their own hash/ordinary-heap storage; they retain their separate transfer.

No extra main-arena request comes from `bfd_set_symtab`: it retains the supplied
pointer (`bfd/syms.c:478–488`). Ordinary section writes use an existing buffer
or pass the bytes to the file writer (`bfd/elf.c:10035–10088`,
`bfd/libbfd.c:1338–1351`). Selected relocatable output has no segment-map or
program-header construction, input-object symbol/relocation slurping, groups,
extended symbol indices, debug compression, CTF rewrite, secondary relocation
sections or build-id/package callbacks. Those exclusions are the same selected
writer contract as the [object transfer](retained-elf-object-capacity.md),
including its target-hook review. They are necessary for this finite request
list; the count is not a claim about arbitrary BFD API usage.

Relocation names are initialized once with their headers. The alternate late
name-copy sites at `bfd/elf.c:7180–7187` are inside the delayed debug-compression
name branch and are absent here; they are not a second unconditional copy.
The final writer visits each section's relocations once and writes the external
header array once (`bfd/elf.c:7245–7289`). Thus the selected lifetime counter
has the sufficient bound

```text
alloc_size <= P + 8448 + 23608 = P + 32056.
```

Together with `max(P,6744)+23 <= PTRDIFF_MAX`, this also fits the unsigned
64-bit cumulative counter for every allowed P; there is no separate RAM
admission condition. This closes the output BFD's listed main-arena request
counter for the selected successful stream. Complete GAS lifecycle storage,
all BFD hash/allocator contexts and whole-link capacity are broader claims
and remain separate.

## Predefined-symbol accounting correction

Finding [#125](https://github.com/berkeleynerd/silver/issues/125) corrects an
omission in the earlier selected-lifetime claim: `perform_an_assembly_pass`
calls `predefine_symbol("version",...)`, and optionally the same constructor
for `"date"`, after the output BFD has opened (`gas/as.c:1203–1220,1254–1267`).
Both branches are charged, regardless of whether the installed version string
selects the date branch. This is separate from the previously counted
`.gasversion.` local symbol. The earlier **88 allocated GAS objects, 102 BFD
objects, R=23,352, P+31,800 lifetime counter and 31,809 indexed specialization
are superseded**, not retained as alternative valid bounds.

Each predefinition uses one full GAS object, one retained name and one BFD
symbol. The corrected totals are **90 GAS objects, 104 BFD symbols,
R=23,608, P+32,056 and 32,065 for indexed P=9**. The name/hash increment does
not trigger another symbol-hash growth. The existing notes request ceiling
and its 65,769-byte backing chunk remain unchanged.

The temporary `xasprintf` request is larger than the resulting string.
`xasprintf` delegates to `xvasprintf`, which allocates the result of
`libiberty_vprintf_buffer_size`. That helper begins with `strlen(format)+1`,
adds 30 for each conversion and adds the argument length for `%s`
(`libiberty/xasprintf.c:41–51`, `xvasprintf.c:48–61`,
`vprintf-support.c:40–68,117–119,157–159`). For `"GAS(%s)"` it requests
**45 bytes for version** and **42 for date**. The retained names use only
13 and 10 bytes including NUL; each temporary is freed after insertion.
Both formatting requests fit the existing 67-byte named parser-scratch
envelope. That envelope bounds individual requests, not their sum or libc's
formatting internals.

Allocated and serialized symbols now have separate bounds. The selected
`flag_strip_local_absolute` is zero and the argv has no
`--emit-local-absolute`. The constructor consequently calls `symbol_create`,
which initializes and clears list pointers, rather than `symbol_new`, which
appends to `symbol_rootP` (`gas/as.h:344`, `gas/as.c:705–711,1212–1218`,
`gas/symbols.c:330–424`). Hash insertion does not append
(`gas/symbols.c:714–719`), and the later hash-wide local-symbol resolver
tests `local_symbol`, false for these full objects (`:1805–1823`). The
generated stream has no reference to either name. Therefore the existing
**88 output-chain symbols, 704-byte GAS output-pointer array, 98 serialized
ELF entries and 14,352-byte object bound remain valid**. This reasoning
would need revisiting if the assembler option or generated stream changed.

The [lifecycle replay](../evidence/retained-assembler-capacity-20261018/check-lifecycle.py)
checks retained source identities, constructor/formatting anchors, corrected
component inputs and the arithmetic. It records the superseded totals
explicitly. As elsewhere, source checks reconcile the manual reachability
argument; they are not a mechanized C semantics proof.

## Adjacent successful entry and exit paths

The omission was found by following `main` through initialization, the single
assembly pass and exit, rather than starting from output-producing directives.
This table records that adjoining review. Inner parser/serializer transfers
retain their own scope and do not become exhaustive merely by being linked.

| Reached path | Storage disposition for the selected invocation |
|---|---|
| `gas_early_init` | Existing notes obstack, include pointer and static exit-handler entries are charged above. `expandargv` skips every argument lacking a leading `@`; selected options, `main~1.o` and the ordinary temporary-file path take that route. Locale, signal and time calls retain the host-library premise. |
| `bfd_init` and output-target selection | Initialization clears/free-resets error state. `bfd_openw` receives explicit `TARGET_FORMAT`; the matching static ELF x86 target vector is selected without target-list allocation or `GNUTARGET` lookup. |
| `gas_init` | Symbol/pseudo-op/macro hashes, fragments, section chains, notes, conditional obstack, streaming buffers, output BFD and section metadata retain their existing bounds. ELF's read hook has no selected ECOFF action. `itbl_init` is an empty macro without `HAVE_ITBL_CPU`; x86 uses neither CGEN nor an additional `tc_init_after_args` hook. |
| `perform_an_assembly_pass` | The two predefinitions are newly charged above. `elf_begin` caches the existing text/data/bss section symbols; `md_begin` creates the already charged opcode/register hashes and initializes static tables. One input file is opened. |
| Input setup and scrubbing | The first file uses `input_scrub_new_file`, not the include/macro push route. `do_scrub_begin` initializes static lexical state. No `#APP` region, macro, repeat or include is emitted; a fixed `#NO_APP` comment does not enter the `sb_build`/push route. |
| Conditional/listing/debug finish | No conditional frame exists. `codeview_finish` is empty for the selected non-PE target. Existing DWARF finish guards and CFI serializer bounds apply. Listing is zero: `listing_newline` returns, and `listing_print(NULL,...)` selects stdout but enters no listing/symbol/general-info allocator path. |
| Filename remapping | `remap_debug_filename` would duplicate its argument even with no map. Its `obj-elf.c` caller is inside STABS section initialization; no selected debug/STABS directive or debug filename table reaches it. No prefix-map option is selected. |
| Dependency finish | `dep_file` remains null, so both `.file` dependency registration and `print_dependencies` return before allocation. |
| Output close and exit | The already charged 112-byte notes composite retains fragment-obstack pointers before BFD close. The BFD writer follows the existing object/lifetime transfers. Target/ELF/macro/expression/read/symbol/subsection cleanup deletes or frees existing state; the `stdoutput=NULL` guard prevents a second writer attempt. |
| BFD file cache | Uses links in the existing BFD object, not separately allocated cache entries. Its source has no direct heap allocator site. One output open/close keeps the open-file count bounded; libc stdio internals remain external. |

The retained excerpts cover `gas/as.c:1304–1447,1502–1587`,
`libiberty/argv.c:359–396`, `bfd/bfd.c:818–829,1962–1969`,
`bfd/targets.c:1473–1497,1551–1586`, `bfd/cache.c:556–591`,
`gas/read.c:253–302,947–1036`, `gas/app.c:169–269`,
`gas/input-scrub.c:141–169,243–275`, `gas/cond.c:547–565`,
`gas/listing.c:285–295,1426–1472`, `gas/codeview.c:620–632`,
`gas/config/obj-elf.c:2076–2098,2467–2494,2989–3036`,
`gas/config/tc-i386.c:3644–3655,3744–3779`,
`gas/depend.c:57–74,183–190`, and `gas/output-file.c:33–53,69–124`.
The complete retained source bundle adds these helper implementations so the
early returns can be inspected in context. No compiler, assembler, linker,
prover or Lean process was executed for the correction or this inventory.

Remaining GAS composition is the complete selected inner-call inventory and
a total emitted line/event bound, including zero-byte directives and label
events. The existing 420-byte payload and 924 fragment bounds alone do not
supply that line count. Host-library internal representations and actual
indexed-environment validation also retain their explicit boundaries. Neither
this correction nor the adjoining inventory completes #119.

Independent review by the native-expansion lane replayed the lifecycle
checker against all 87 retained sources and confirmed that the prior 70
identity rows are unchanged. It followed predefinition, initialization,
hash insertion/local resolution and formatting helpers, accepting the
90/104 allocation correction and separate 88/98 output bounds without a
material finding. The review relied on the previously reviewed generated
stream inventory; it did not claim a fresh derivation of that inventory or
complete GAS capacity. The adjoining guard wording retained its inner-call,
event-count and host-library gaps.
