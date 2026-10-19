# Retained native collection hooks: selected ownership closure

2026-10-19 UTC, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). **The four collection
timing hooks remain null on the retained first-fold / serial-SIGINT-save
interval, at the inspected source and native-link interface level.** This joins
the native residual in the accepted
[save-preservation argument](retained-why-save-preservation.md). The conclusion
uses its existing faithful-runtime, fixed-loaded-code, no-forged-mutation and
reflection/capability boundaries. It does not add an assumption that legitimate
hook clients are harmless: the selected address-acquisition routes below supply
no installer or writable cell capability to such a client.

This is a reviewed-source-style argument supported by an installed-image census,
not a machine-checked arbitrary native alias theorem or a measurement of live
hook values. Complete `R` and exceptional identifier charge remain **null**.
Remaining exception continuations, ordinary-ending nested saves and exit/output
effects are not closed. No production, tool, Oracle or admission change is made.

## Exact selected inputs

The base is `d8e9c70e373de172280b87a1459ece88114c2eaf`, containing author
`3700c2adc718dc011ec047256d9b3ceade936ab2` and its
[accepted review](../reviews/review-why-save-preservation-3700c2adc7.md).
The [new packet](../evidence/retained-why-native-collection-hooks-20261019/README.md)
projects only metadata from the already accepted run
`20261019T000304-fcb988ec2c03`, PID **97103**. Its mapped-file identities exactly
match the earlier callback packet's seven selected images: `gnatwhy3`,
`ada_terms.cmxs`, `gnat_json.cmxs`, libc, libm, libgmp and the ELF loader. No
process, capture, saved graph, binder certificate or old checker is replayed.

`gnatwhy3` remains the 24,561,432-byte image with SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
It is a PIE (`ET_DYN`); addresses below are **ELF-relative**, not sampled
process addresses. The retained map places its base at `0x55a661b32000`.
Source is the already pinned OCaml revision
`8eb41f72ded84df884c3671734c947f612091f84`.

| Cell | ELF-relative address | Only direct instruction reference |
| --- | --- | --- |
| `caml_major_slice_begin_hook` | `0xfaaf48` | Load at `0x9c551d` |
| `caml_major_slice_end_hook` | `0xfaaf40` | Load at `0x9c595e` |
| `caml_minor_gc_begin_hook` | `0xfaaf38` | Load at `0x9c6b8f` |
| `caml_minor_gc_end_hook` | `0xfaaf30` | Load at `0x9c6e01` |

The predecessor's four null definitions and four guarded source calls are reused.
The new check reads the selected native image, including statically linked code;
it is not another same-name search of OCaml runtime files.

## Where a legitimate client would obtain the cell

The distinction is between reading a hook's **function-pointer value** and
obtaining the **address of its writable cell**. All four installed references
perform the former. They load, test and conditionally call the value. No such
load returns or publishes the cell's address.

The census reads the retained full disassembly and matches **1,102,177
instructions / 4,986,162 bytes** to the pinned ELF. These records cover every
byte of its five executable sections, with no undecoded gap. Numeric operands,
including base/index displacements, and decoded RIP-relative targets yield only
the four loads into the 32-byte hook range. There is no direct store or `lea`
for a cell. Matching all bytes establishes that this is the selected installed
code; it does not turn the extractor into control-flow or pointer analysis.

The independently decoded ELF tables and data provide the remaining ordinary
linkage routes:

| Capability route | Selected result and implication |
| --- | --- |
| Named object or subobject alias | Both symbol tables identify each cell as its own 8-byte `GLOBAL DEFAULT OBJECT` in `.bss`. No other named object overlaps any cell. These are four independent objects, not fields of an addressable enclosing hook array or structure. |
| Static stored pointer | An every-byte-offset search of 6,039,220 allocated nonexecutable PROGBITS bytes finds no 32-bit or 64-bit encoding of any byte address in the cells. The search includes unaligned encodings. It is a concrete stored-address check, not an argument about all computed values. |
| Linker/loader relocation | The main image has only `.rela.dyn` and `.rela.plt`, with no relocation targeting a hook slot or materializing its address. No selected external image has a hook-named relocation or symbol. |
| Ordinary external symbol binding | All four cells are genuinely exported; export alone is not absence. Neither selected plugin nor libc, libm, libgmp or the loader imports or defines any hook name. The plugins have no `DT_NEEDED` entries; the main image's libgmp/libm/libc dependencies and their loader dependencies are exactly within the retained seven-image set. |
| Dynamic lookup | The accepted callback packet already closes the selected Dynlink/Dll/Symtable and native `dlsym` capabilities. That argument, not absence of a string, excludes obtaining these cells by lookup. The only allocated occurrences of the four names are the main `.dynstr` entries; `.strtab` and `.debug_str` occurrences are nonallocated metadata. |

The last row reuses the **Reflection and native loading** portion of the
[accepted callback argument](retained-why-inline-callback-closure.md): external
Dynlink consumers select private loading and error/native metadata, not the
module-value accessor; the bytecode Dll/Symtable path has no exercised external
lookup client; selected plugin imports do not acquire reflection APIs. Loader
handles remain retained even on errors, so an initialized then hidden/unmapped
hook plugin is not an omitted route under that fixed-image argument. This note
does not replace those source/capability facts with the captured map alone.

## Base addresses and legitimate computed aliases

A census of exact hook addresses would be insufficient if a selected client
legitimately held an enclosing object or ELF-section capability and then indexed
into the cells. The additional anchor check distinguishes those cases.

Within `0xfaaf00–0xfaaf7f`, the only address-taking instructions are in
`caml_parse_ocamlrunparam`: `&caml_verb_gc` at `0xfaaf18` and
`&caml_runtime_warnings` at `0xfaaf08`. The pinned `startup_aux.c:89–143`
passes each to `scanmult`, whose four arms write exactly `*var`, one `uintnat`.
The retained installed `scanmult` body agrees. Neither object encloses a timing
hook. Advancing either pointer outside its own object to write a hook is not a
legitimate subobject operation; it is precisely an out-of-object mutation
excluded by the already accepted well-formed/no-forged-mutation boundary.
No additional whole-BSS object capability is inferred from adjacency.

The explicit section-anchor set is `__bss_start`, `_edata`, `_end`,
`__data_start`/`data_start`, `_DYNAMIC`, `__TMC_END__` and
`_GLOBAL_OFFSET_TABLE_`. The actual address-taking references are the four
`lea` instructions in `register_tm_clones` and `deregister_tm_clones`, all to
`0xfaa9e8`. Each compares equal start/end addresses (or their zero difference)
and returns before publishing a range to an ITM registration callback. Other
numeric references at `__bss_start` are loads of the coincident **`stderr`
pointer object** at `0xfaaa00`; they do not materialize a BSS base. The one
stored anchor pointer is the usual first GOT word pointing to `_DYNAMIC`.
It belongs to the loader's relocation/resolution metadata, not an application
accessor for writable BSS. The selected relocation/import relation above has no
hook target. Standard ELF zero-fill and relocation semantics are part of the
existing faithful-loader boundary; they do not install a nonnull callback here.

The main image imports `getauxval` in addition to `dlsym`/`dlopen`. Its single
call is in `unix_environment`, immediately supplied with constant **0x17**
(`AT_SECURE`), matching `otherlibs/unix/envir.c:40–70`. It returns the secure
execution flag used to decide whether to expose `environ`, not a program-header
or image-base capability. No selected image imports `dl_iterate_phdr`, `dladdr`
or `dlinfo` through the inspected dynamic tables. The existing native lookup
owners remain the relevant reflective route, already discharged above.

Consequently there is no remaining identified legitimate address source from
which a client could compute a hook-cell alias. Constructing one from an
unrelated object, function address or numeric constant without such a capability
would require the forged/out-of-object mutation already outside the accepted
boundary. This is not a new prohibition on native hook use: an actual import,
address-taking instruction, enclosing-object range or exercised symbol lookup
would have required its real setter and callback effect to be joined. None is
present in these selected routes. The conclusion is intentionally scoped to
ordinary faithful source/link interfaces, not arbitrary self-inspecting or
self-modifying native programs.

## Null preservation and the remaining obligation

Initially the pinned definitions and ELF loader's zero-fill semantics give
null values. Relocations do not replace them. For the selected interval, direct
cell uses only read those values; static/external/reflection/legitimate-alias
routes above supply no setter capability. Induction through initialization and
the retained first-fold/serial-save execution therefore keeps all four cells
null. Their guarded calls do not run, including collection initiated during
pending-action processing or allocation. This establishes their zero callback
effect without choosing a hypothetical callback implementation or observing live
BSS contents.

`runtime/caml/misc.h:190–192` additionally says timing hooks must not allocate,
change heap values or call OCaml code. That is a client API obligation. The
argument does **not** treat the comment as proof that an unknown installed
client complies; absence of an installer on the selected interfaces is what
closes this join.

Combined with the accepted typed/private-state and registered-OCaml-client
lemmas, this removes the four-hook condition on preservation of Shape's buffer,
the fresh formatter/printer, the first fold's empty private cache and backward
work list during its serial SIGINT saves. It also removes that particular
condition from the accepted **1,074-byte** buffer-growth and preserved-cache
miss implications. It establishes neither an actual escaping exception nor an
exception-free save. The two finalization hooks remain excluded by the already
accepted empty-finalizer-registration argument.

The next work is the actual save/exit exception sources and receiving
continuations, and the ordinary ending save's later forest and nested shared
buffer behavior. The captured **66 roots**, **966 binders**, **315**
insertion/reset bound and accounted endpoint **61,641** are unchanged.
`counter_end <= 63,573 + 2R` remains conditional on completing `R`; it is not
an established 63,573 endpoint. Normal completion, later invocations, auxiliary
capacity, full-current-grammar capacity and whole-pipeline assurance remain open.
