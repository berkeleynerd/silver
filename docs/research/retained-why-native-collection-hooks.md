# Retained native collection hooks: partial selected linkage

2026-10-19 UTC, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). **The selected ELF,
direct-load and identified-address-route results are established; four-hook null
preservation remains open.** The native residual in the accepted
[save-preservation argument](retained-why-save-preservation.md) is retained.
A legitimate source-level assignment can compile to a shared-base-plus-offset
store without an exact hook-address operand. The packet has no complete selected
source/compilation relation or effective-address proof excluding that case.

[Independent review `144d7013b7`](../reviews/review-why-native-collection-hooks-fae1a1ebd0.md)
identified this gap in author `fae1a1ebd0be76b247eae0ad8778483dbdc71cd0`.
The finding is tracked as [#143](https://github.com/berkeleynerd/silver/issues/143).
That commit's null-preservation induction and removal of the hook condition are
**withdrawn**. Its valid partial evidence is unchanged, and its original result
and round remain explicitly historical. No actual setter, nonnull hook or
interference has been demonstrated. The existing faithful-runtime,
fixed-loaded-code and no-forged-mutation premises have not been expanded.

This remains a source/interface investigation supported by installed-image
evidence, not a machine-checked arbitrary native alias theorem or a measurement
of live hook values. Complete `R` and exceptional identifier charge remain
**null**. Exception continuations, ordinary-ending nested saves and exit/output
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

## Direct references and ordinary linkage routes

The distinction is between reading a hook's **function-pointer value** and
obtaining the **address of its writable cell**. All four enumerated direct references
perform the former. They load, test and conditionally call the value. No such
load returns or publishes the cell's address.

The census reads the retained full disassembly and matches **1,102,177
instructions / 4,986,162 bytes** to the pinned ELF. These records cover every
byte of its five executable sections, with no undecoded gap. Numeric operands,
including base/index displacements, and decoded RIP-relative targets yield only
the four loads into the 32-byte hook range. There is no direct store or `lea`
for a cell. Matching all bytes establishes that this is the selected installed
code; it does not turn the extractor into control-flow or pointer analysis.

The independently decoded ELF tables and data cover these additional ordinary
linkage routes. They do not enumerate all possible compiled address computations:

| Capability route | Selected result and implication |
| --- | --- |
| Named object or subobject alias | Both symbol tables identify each cell as its own 8-byte `GLOBAL DEFAULT OBJECT` in `.bss`. No other named object overlaps any cell. The inspected definitions are independent objects; the symbol table supplies no named enclosing object. This does not constrain the compiler's temporary machine-address bases. |
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

## Identified bases and the unclosed lowering case

A census of exact hook addresses is insufficient to exclude all computed
accesses. The additional anchor check resolves the following particular bases;
it is not a proof that the listed bases exhaust legitimate compiled accesses.

Within `0xfaaf00–0xfaaf7f`, the only address-taking instructions are in
`caml_parse_ocamlrunparam`: `&caml_verb_gc` at `0xfaaf18` and
`&caml_runtime_warnings` at `0xfaaf08`. The pinned `startup_aux.c:89–143`
passes each to `scanmult`, whose four arms write exactly `*var`, one `uintnat`.
The retained installed `scanmult` body agrees. Neither destination object
encloses a timing hook, so these concrete writes do not affect the cells. This
is a fact about those bodies and their identified arguments; it is not a reason
to interpret every compiler-generated machine base as a source-level pointer
to an unrelated object.

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

The unresolved case is **legitimate compiler/linker lowering**, for example:

```text
materialize a shared base B into a register
store callback at [register + (hook_address - B)]
```

This is a missing-case form, not an instruction sequence found in this image.
The base need not be in the 128-byte neighbour window or the eight-name anchor
set, and neither operand need equal a hook address. Well-formed source can
compile this way: the temporary machine base need not carry the source object's
identity. The no-forged/out-of-object mutation premise therefore cannot exclude
it. Original static relocations may have been resolved away in the final ELF;
absence of surviving dynamic relocations does not close the case either.
The extractor does not propagate register/data values across instructions.
Decoded-byte coverage and the four exact-target matches cannot supply that
missing analysis. The accepted reflection result addresses another route.

## The precise missing join and the bounded repair attempt

The repair first checked the **retained selected compilation/source-relation
route**, rather than launching global native pointer analysis. The callback and
formatter packets pin the reviewed sources and installed image identities.
The retained release/recipe investigation identifies the selected package route,
and `spark2014.anod` includes and installs the `why3` dependency. Those inspected
records do not establish a complete native translation-unit/object relation for
this `gnatwhy3`, or a compiler/linker behavior restriction that excludes the
shared-base form. Source revision pins and the ELF `STT_FILE` labels alone are
not such a relation. No generic claim that x86 compilers normally use RIP-relative
accesses is substituted for it.

The [source-identity policy](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
allows explicit source-reviewed behavior premises without historical binary
attestation. That policy does not make an incomplete native client set complete,
or imply a particular address-lowering convention. Requiring recovery of every
historical build input is not the repair; identifying and reviewing the actual
relevant source/interface relation is.

The smallest constructive next input is either:

1. A bounded selected native object/client-to-reviewed-source relation covering
   all legitimate static hook accesses, including native inputs outside the
   already searched OCaml runtime/otherlibs projection. It must account for
   aliases and applicable preprocessing/link choices, with the existing faithful
   source behavior relation applied to that complete selected client set. The
   retained `STT_FILE` labels, including `caml_z.c` and startup objects, are
   locating evidence rather than a complete link manifest. If instead relying
   on an address-lowering restriction, establish its selected compiler/linker
   applicability and why it excludes shared bases; a default-option guess is
   insufficient.
2. A bounded installed-code effective-address argument covering the candidate
   computed bases and writes to these four cells, including register/data
   propagation. The current exact-target and fixed-anchor extraction cannot be
   relabeled as that proof.

Neither input has been established here. No broad source/native scan, compiler
experiment, pointer-analysis project or new capture was started. A live zero
snapshot would not prove absence of later computed setters. The precise residual
is unjoined **legitimate static client/address lowering**, not an alleged native
bug or an arbitrary new no-mutation assumption.

## Preservation remains conditional

The definitions and ELF zero-fill semantics support initial null values, and
selected dynamic relocations do not replace them. The known direct uses read
them. Preservation through initialization and the first-fold/serial-save
interval still needs the missing static-client/lowering join. The original
null-preservation induction and its zero-callback-effect conclusion do not
follow from the retained partial facts.

`runtime/caml/misc.h:190–192` additionally says timing hooks must not allocate,
change heap values or call OCaml code. That is a client API obligation. The
argument does **not** treat the comment as proof that an unknown installed
client complies. It does not discharge the remaining ownership/effect join.

The accepted typed/private-state and registered-OCaml-client preservation
lemmas are unchanged. Shape's buffer, the fresh formatter/printer, the first
fold's empty private cache and backward work list remain conditional on the
four-hook native join during serial SIGINT saves. The accepted **1,074-byte**
buffer-growth and preserved-cache miss implications retain that condition.
Neither an actual escaping exception nor an exception-free save is established.
The two finalization hooks remain excluded by the already accepted
empty-finalizer-registration argument.

Remaining work includes this four-hook ownership/lowering join, the actual
save/exit exception sources and receiving continuations, and the ordinary ending
save's later forest and nested shared buffer behavior. The captured **66 roots**, **966 binders**, **315**
insertion/reset bound and accounted endpoint **61,641** are unchanged.
`counter_end <= 63,573 + 2R` remains conditional on completing `R`; it is not
an established 63,573 endpoint. Normal completion, later invocations, auxiliary
capacity, full-current-grammar capacity and whole-pipeline assurance remain open.
