# Fixed inputs to the selected null-program link

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This supplies fixed target-link inputs and archive/read-pass bounds for the
[ELF linker transfer](retained-linker-capacity.md). It closes file selection
for the descriptor below, including shared-library dependencies. Generated
Main/binder objects, generated linker names, reference events and layout still
need separate transfers. The whole [capacity rule](retained-tool-capacity.md)
remains incomplete.

The [evidence](../evidence/retained-link-inputs-20261018/README.md) retains raw
queries, argv/environment, fixed-file/archive-member identities and nine
complete source files. It uses the existing relevant-behavior premise for GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and Binutils
`5e56594815854de5eca35c7c04b11705d0f19c02`. This is not a historical build
attestation. Installed library bytes are configuration inputs; their sizes are
neither guessed allowances nor new source-length limits.

## Invocation and implicit script

The retained successful null-proposed build supplies the link command.
Managed run `20261018T073114-aea68992351d` ran GCC `-###` and ten
`-print-file-name` queries under the captured seven-entry environment. It ran
no frontend, assembler or linker. The eleven queries took 0.037602 seconds;
their managed run took 2.032823 seconds. This link descriptor is separate
from the Main compile descriptor; production launch changes remain pending.

The expansion has 54 collect2 argv positions: ELF64 x86-64 PIE, the installed
LTO plugin, `--eh-frame-hdr`, interpreter `/lib64/ld-linux-x86-64.so.2`,
fourteen `-L` directories, two generated objects, five startup/end objects,
explicit libgnat.a, and `-ldl -lgcc -lgcc_eh -latomic_asneeded -lc -lgcc -lgcc_eh`.
The capture passes argv directly, preserving literal `$ORIGIN`. The inventory
inverts GCC's own display quoting (`gcc/gcc.cc:3351–3380`): the backslash
before `$` in `-###` output is an escape, not an argument byte. Ordinary Python
`shlex` retains it inside double quotes. The retained corrected argv therefore
starts its rpath value with `$ORIGIN/`.

Managed run `20261018T074453-3dae2df9fffa` queried the internal default script
with `--verbose` and the script-selecting options, but **no input files**.
The child took 0.008207 seconds, returned zero and produced no executable.
Its script equals installed `elf_x86_64.xdc`, apart from two display newlines.
It has ten additional `SEARCH_DIR` entries and no `INPUT`, `GROUP`, `INCLUDE`
or `STARTUP`. Its input-section patterns use wildcards, excluding another
filename through `lookup_name` (`ld/ldlang.c:3668–3676`). This excludes another
input route; script evaluation, section mapping and layout remain separate.

## Library and dependency closure

Each directory's dynamic lookup tries `.so` before `.a`
(`ld/ldfile.c:540–597`, `ld/ldelf.c:1925–2004`). Every selected library is
found within the fourteen command-line directories, before default-script
directories. The inventory records all preceding absent candidates and checks
the selected format. None is a thin archive. The five archives contain only
ordinary ELF64 x86-64 members, or are empty. Two selected files are scripts:

```text
libatomic_asneeded.so:
    INPUT ( AS_NEEDED ( -latomic ) )
libc.so:
    GROUP ( /usr/lib/x86_64-linux-gnu/libc.so.6
            /usr/lib/x86_64-linux-gnu/libc_nonshared.a
            AS_NEEDED ( /lib64/ld-linux-x86-64.so.2 ) )
```

Unrecognized files are parsed as scripts once and marked loaded
(`ld/ldlang.c:3100–3181`). These exact scripts introduce only the listed
entries. The three selected DSOs have the complete DT_NEEDED graph
`libatomic.so.1 -> libc.so.6 -> ld-linux-x86-64.so.2 -> empty`.
Every target already has an explicitly selected matching SONAME. The loader's
as-needed entry may be reopened at its **existing explicit path**.
`ldelf_check_needed` matches SONAME and `ldelf_handle_dt_needed` prioritizes
that path before rpath/environment/system-config searches
(`ld/ldelf.c:977–1093`). Forced opening of the valid ELF loader succeeds under
ordinary filesystem/resource assumptions; it has no further DT_NEEDED entries
(`:276–413`). These dependencies add no new file bytes or search configuration.
Repeated processing is charged below.

All inspected members and generated sample objects lack `.gnu.lto_*`,
`.gnu.offload_lto_*`, `.gnu_object_only`, `.zdebug*` and SHF_COMPRESSED sections.
The fixed property is checked from every section header. The generated-object
transfer must establish the same property from the selected compile settings
before applying this specialization universally. The LTO plugin claims only
through its LTO-symbol/offload paths; otherwise it frees its temporary filename
and returns unclaimed (`lto-plugin/lto-plugin.c:1089–1137,1192–1400`). With no
claimed/offload files its final hook returns before launching LTO or adding
files (`:771–781`). LD therefore has no plugin-added statements to rescan
(`ld/ldlang.c:8436–8518`). Plugin scans and counters still need accounting.

This is target-link input closure. Runtime libraries used to execute the
linker/plugin belong to the selected external-tool configuration; they are
not target sections to add to this inventory.

## Inventory and archive backing

Charge every archive member, even if resolution would select only a subset;
weight both libgcc/libgcc_eh occurrences. Exclude generated main.o/b__main.o
from fixed sums. Their small observed sizes remain observations.

| Fixed-input quantity | Bound before loader revisits |
| --- | ---: |
| File spellings, including scripts | 15 |
| ELF occurrences | 1,473 |
| Input sections | 36,241 |
| Symbol records | 48,769 |
| Relocation records | 546,356 |
| Allocatable-section bytes | 11,474,416 |
| Sum of input alignment minus one | 65,259 |
| Nonempty section/symbol-name occurrences | 71,531 |
| Unshared bytes of those names, including NULs | 1,561,216 |
| All SHT_STRTAB bytes | 1,442,204 |
| Longest section/symbol name, excluding NUL | 171 |
| Largest individual section | 2,019,360 |

These are input counts, not output sizes or lifetime reference counts.
Versioned aliases, synthetic symbols and serialization events need their
actual callers. The allocatable-byte sum even includes DSO sections, which
ELF linking discards from the output list (`bfd/elflink.c:4767–4779`). It does
not bound all output padding and is not an aggregate-RAM membership gate.

Every archive map here uses four-byte big-endian offsets. For C symbols and
map-string extent S, `do_slurp_coff_armap` requests `4C` scratch bytes and a
`16C+S+1` canonical-map object on LP64 (`carsym` is one pointer/file offset).
Symbol processing has a separate C-byte inclusion array
(`bfd/archive.c:150–163,1059–1159`; `bfd/elflink.c:6251–6282`). The inventory
checks every map offset points to a retained member header.

| Archive | Members | C | Canonical-map bytes |
| --- | ---: | ---: | ---: |
| libgcc.a | 298 | 699 | 23,479 |
| libgcc_eh.a | 6 | 36 | 1,381 |
| libc_nonshared.a | 4 | 5 | 157 |
| libgnat.a | 853 | 17,201 | 936,621 |

Empty libdl.a is eight bytes and uses the empty-archive path. Maximum offset
scratch/inclusion arrays are 68,804/17,201 bytes. Sizes, file offsets and
indices fit their actual integer/individual-object representations. Repeated
independent allocations create no additional total-memory rule.

## Repeated input passes

An archive rescan repeats only after loading a member that appends undefined
symbols. Cached members cannot be loaded twice into that input chain
(`bfd/elflink.c:6292–6434`; `ld/ldmain.c:1417–1427`). With M members, at most
M+1 scans of its C entries occur per invocation, including the final
unproductive scan. This bounds the number of repeated common-symbol probes;
their inner symbol scans are charged separately below.

The only GROUP contains libc, four libc_nonshared members and the loader.
A productive group pass must newly load at least one of those six objects.
An unneeded as-needed trial restores the previous undefined-list tail
(`bfd/elflink.c:5834–5850`), so cannot alone keep the loop running. Once
retained, the shared object loses AS_NEEDED and is not reloaded by the group
(`ld/ldlang.c:3677–3741`). Thus **seven group scans** suffice. There is no
nested GROUP or plugin-added input. Across these scans and both explicit
libgcc occurrences, the map bounds give **15,108,335 candidate visits**.
This bounds work/events, not live symbols or retained allocations.

The two DT_NEEDED hooks each traverse unique dependency names once
(`ld/ldelf.c:1062–1070,1217–1232,1412–1413`). Allowing a loader reopening in
each plus all seven group visits charges its metadata at most nine times.
Adding eight copies to the inventory's first copy gives add-symbol input-pass
bounds of **49,081 symbol records**, **36,433 sections** and **72,019
section/symbol names**. These are inputs to ordinary symbol-loading passes,
not a bound on all symbol-record visits.

In particular, `elf_link_is_defined_archive_symbol`
(`bfd/elflink.c:3702–3796`), reached for common candidates in the archive-map
loop, rereads and scans a member's external symbol table. The largest complete
symbol table in any fixed archive member has **711 records** (`g-spipat.o` in
libgnat.a); an external-only scan cannot exceed it. Charging a full scan for
every candidate therefore adds at most
**15,108,335 × 711 = 10,742,026,185 common-probe symbol visits**. This product
is cumulative work, not a live array, shared 32-bit counter or admission cap.
Each scan's pointer/index starts anew and is bounded by its member's own table.
Aliases, reference increments and generated per-pass structures remain separate
functions of the appropriate input and event allowances.

Focused independent review of `849a24f688` confirmed input selection, seven
GROUP passes and nine loader processings, and identified the missing distinction
between add-symbol input passes and common-probe scans. This revision repairs
that scope overstatement; it does not claim closure of other symbol consumers.

Remaining joins are generated Main/binder objects, collect2/plugin storage
and launch, linker-created sections/names/reference events, ELF consumers and
final code/data/relocation layout. This fixed input closure supports those
arguments; it does not complete #119.
