# Selected linker transformation exclusions

Research for #119, 2026-10-18. This supplies zero-payload cases for the
[linker layout](retained-linker-layout.md) join. It uses the selected Linux
ELF64 x86-64 no-LTO invocation, fixed input inventory, and the accepted Main
emission and binder object-shape transfers. It is not whole-link capacity or
a new admission rule.

## Compression and packed relative relocations

The installed linker's compression default is **none**. This matters because
`ldmain.c:782–784` permits a configure-time default; absence of a command-line
switch alone would not establish absence of output compression. The retained
`ld --help` query reports the current `config.compress_debug` through
`bfd_get_compression_algorithm_name` (`ld/lexsup.c:2278–2282`). Its executable
hash matches the selected installation and is unchanged across the query.
The actual selected argument list has no compression option, so the writer's
switch adds no `BFD_COMPRESS` flags (`ld/ldmain.c:969–990`). The fixed input
census has no `SHF_COMPRESSED` or `.zdebug` sections; neither the Main emission
stream nor the accepted binder object has one. There is therefore no input
decompression or late output-compression growth in this descriptor.

`link_info` is a zero-initialized global (`ldmain.c:172`). The selected
positive setter for `enable_dt_relr` is `-z pack-relative-relocs`
(`ld/emulparams/dt-relr.sh:10–13`), absent from the selected arguments. The
help output corroborates the `nopack` default. Consequently RELR packing is
disabled, and the x86 relaxation hook returns before its packing/layout
work (`bfd/elfxx-x86.c:1093–1097`). This excludes that transformation; it does
not by itself prove that the separate segment-mapping retry loop converges.

## STABS and script-generated payload

The complete fixed input census contains no section name starting with
`.stab`, including empty sections. Main's no-debug emission argument and
the accepted binder section inventory exclude them too. The STABS merger
requires `.stabstr` before finding or optimizing a `.stab` section
(`bfd/elflink.c:6126–6150`); its string-output path is therefore absent.
Ordinary input DWARF bytes remain charged in the fixed payload.

After removing comments, the installed script contains no explicit `BYTE`,
`SHORT`, `LONG`, `QUAD`, `SQUAD` or `FILL` data constructor. Two other script
forms require explicit treatment:

- `LINKER_VERSION` occurs once. `enable_linker_version` starts false
  (`ld/ldlang.c:147`); its positive setter is the unselected
  `--enable-linker-version` option (`ld/lexsup.c:1146–1147`). The constructor
  returns before emitting bytes (`ldlang.c:8786–8806`). Its payload is zero.
- `SORT(CONSTRUCTORS)` occurs once. Legacy constructor sets start empty
  (`ld/ldctor.c:47`). Their two LD registration callbacks are called through
  BFD's constructor/set paths (`ld/ldmain.c:1706–1793`). The selected x86 ELF
  backend inherits `elf_backend_collect = false`
  (`bfd/elfxx-target.h:406–408`), excluding name-based collection at
  `bfd/linker.c:1567`. ELF symbol decoding supplies no `BSF_CONSTRUCTOR`:
  its input flags are zero, global, weak or GNU-unique
  (`bfd/elflink.c:5022–5073`), and its other helper calls supply global,
  indirect or warning flags. The selected x86 symbol hook adds no such
  flag. Thus the set-row branch at `bfd/linker.c:1452–1453` is absent too.
  `ldctor_build_sets` has no set to emit. Ordinary `.init_array`, `.fini_array`
  and input constructor sections are still original payload, not zeroed by
  this legacy-set exclusion.

These arguments give zero additional script-emitted data. Padding from
alignment, page and fill expressions is still charged by the layout transfer.
Neither a textual no-match nor one observed link is used as a substitute for
the programmatic-constructor exclusions.

## Evidence and remaining scope

The [packet](../evidence/retained-linker-defaults-20261018/README.md) retains
12 complete pinned Binutils files, the query and raw output, prior-result
identities and an offline ELF/input checker. The query took 0.00324 seconds
inside managed run `20261018T112705-2e2b04d26400`; it ran `ld --help` only.
No link, compiler, prover, Lean build or test suite was run for this packet.
The replay rehashes 15 fixed file spellings and 1,161 archive members.

The source-to-installed-tool relevant-behavior premise remains explicit;
these files do not establish historical build-source identity. These
exclusions do not settle mapping convergence, relocation/addend legality,
auxiliary linker storage or any earlier compiler/producer phase.
