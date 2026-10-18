# Selected GAS parser and writer allocation coverage

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This finishes the GAS-owned dynamic-request inventory for the selected null
Main parser and writer. It composes the existing
[invocation](retained-assembler-invocation.md),
[emitted-stream](retained-backend-gigi.md#total-emitted-lines-and-assembler-events),
[fragment/symbol](retained-assembler-capacity.md),
[backing](retained-assembler-backing.md),
[hash](retained-assembler-hashes.md),
[startup](retained-assembler-startup.md) and
[ELF object](retained-elf-object-capacity.md) transfers. It adds no allocation
to their bounds. It does not close every BFD call, host-library internals,
the other native phases or #119. No native compiler, assembler, linker,
prover or Lean process ran.

The input is the source-derived selected vector
`AS_PATH --64 -o main~1.o ASSEMBLY_TEMP_PATH`, one LF-terminated compiler
stream of at most 114 lines / 7,410 bytes, with at most 64 bytes per line.
The selected x86_64 ELF configuration, effective compiler options, fixed
identifier, controlled environment and source-to-installed-tool premises
remain those of the earlier transfers. This is not an argument for arbitrary
assembly or a new language admission rule.

## Corpus and method

The [replay checker](../evidence/retained-assembler-capacity-20261018/check-inner.py)
checks the earlier 90-file source capsule and a supplementary 33-file capsule
at the same Binutils commit, then reconciles eleven prior result identities.
No earlier source or result bytes change. The reviewed GAS corpus is the 36
`GAS_CFILES` from `gas/Makefile.am:67–103`, the x86 and ELF target modules,
and the two `.c` files included by `tc-i386.c`, plus all 33 listed `HFILES`
and four selected target/attribute headers: **40 C modules and 37 headers**.
The build's optional `itbl-ops.c` and `cgen.c` are outside the selected x86
configuration; their absent hooks were checked in the startup transfer.

The [allocation inventory](../evidence/retained-assembler-capacity-20261018/inner-allocation-inventory.json)
retains **264 lexical allocator, wrapper, callback and declaration occurrences**.
Every occurrence has a disposition and an existing bound or exclusion argument.
The census deliberately retains declarations and wrapper bodies; 264 is not an
allocation-event count. It includes `XCNEW*`, `reconcat`, `notes_concat`,
`obstack_grow0` and hash callbacks, not only direct `malloc` spellings. It finds
no explicit `alloca` call in this corpus. Fixed automatic objects and host stack
availability are separate from this dynamic-request claim.

This inventory is a completeness cross-check on the handwritten dispatch and
callback review below. A matching regex, source anchor or hash does not establish
C reachability, successful assembly or semantic equivalence by itself. All source
locations and the replay use literal LF line boundaries.

## Selected input dispatch and storage

`read_a_source_file` dispatches named labels, numeric labels, pseudo-operations
through the registered table, and machine instructions through `assemble_one`
(`gas/read.c:1069–1412`). The selected output has one statement or label per
line, no assignments/equates and no user assembly. Its only pseudo-operation
families and their storage effects are:

| Selected family | Allocation route and existing charge |
|---|---|
| Bare-string `.file`, `.ident` | `demand_copy_string` appends at most 32 bytes to notes. The ELF filename replacement can copy the same fixed spelling. The file symbol and comment section are in the symbol/section inventories. |
| `.text`, `.section` | Section-name copies fit 32 bytes. `subseg_new` creates/reuses the bounded section and chain objects. Names contain no `%S`, groups or linked-to symbol. Every subsection is zero. |
| `.align` / `.balign` | Constant alignment and fixed fill use the bounded fragment allocator; there is no arbitrary space/org count. |
| `.globl`, `.type`, `.size` | Unquoted `.globl` scratch fits 26 bytes and is freed. `.type` sets flags on the symbol. `.size` contributes its already counted location symbol and at-most-40-byte expression. |
| `.long`, `.string` in fixed property notes | Fixed integer/label-difference expressions and the literal `GNU` use the existing payload/fragment/fixup envelope. No floating literal, arbitrary symbol expression or multiline literal is supplied. |
| `.cfi_startproc`, `.cfi_endproc` and the five simple frame rules | The ordinary ungrouped frame route uses one FDE, one state, at most twelve CFI nodes and one CIE. Compiler-emitted rules and GAS's two implicit CIE rules are distinguished in the earlier event transfer. |
| Named and numeric labels | Existing symbol constructors, local conversion and bounded name copies; numeric labels 0 through 4 use static low counters. |
| `nop`, `push`, `mov`, `pop`, `ret` | AT&T register-only operands, fixed encodings and already charged fragments. All four named retry/fallback scratch paths remain charged up to 67 bytes even when not needed. |

String copying, section/chain creation and fixups are reached indirectly through
these handlers; they do not disappear merely because the handler itself contains
no allocator call. Symbol creation goes through `symbol_create` or local-symbol
construction/conversion, preserving the earlier **90 GAS / 104 BFD** allocation
ceilings. `symbol_clone_if_forward_ref` does not create an additional ordinary
clone: there is no volatile/equated/redefined symbol; replacing the dot symbol
uses the already counted location temporary (`gas/symbols.c:839–890`).
The expression-symbol line records remain charged alongside their constructors.

`get_symbol_name` normally edits delimiters in the scrub buffer rather than
copying a name; the bounded `.globl` allocation is the separate
`read_symbol_name` path. Quoted symbol names do not occur. A quoted `.file` or
`.ident` string is not a quoted symbol name (`gas/read.c:1720–1783,2450–2487,
6341–6371`). ELF section parsing likewise uses its bounded name route, not the
excluded group/link-order allocations (`gas/config/obj-elf.c:503–639,1071–1124,
1406–1430`). The x86 subsection hook returns for subsection zero before its
subsidiary-state allocation (`gas/config/tc-i386.c:18799–18829`).

The line/byte bound fits the initial **65,539-byte input buffer**. No line
spans its 32,768-byte input quantum, so its resize site is absent. Input-push
objects require includes, macros or `#APP`, none of which occurs. The optional
initial `#NO_APP` is a comment and does not activate that route. The event
transfer independently bounds the physical line counter by 115 and retains
the disabled logical counter; payload bytes alone were not used as a bound on
zero-byte directives or labels.

## Excluded allocation families and indirect helpers

| Family | Source guard / absence used by the selected path |
|---|---|
| Macro/repeat/include and conditional objects | No matching directives, `macro_defined=0`, and the initial file does not use push/include. The empty macro hash and conditional obstack initialization are still charged. |
| Dependency storage | No dependency option; `dep_file=NULL` makes registration and finish return before allocation (`gas/depend.c:57–74,183–190`). |
| Listing storage | `listing=0`; `listing_newline` returns and finish enters none of its output allocators. `listing_file` only records a pointer (`gas/listing.c:285–295,1426–1478`). |
| DWARF, STABS, CodeView and remapping | Debug type remains unspecified and no `.loc` or numbered `.file` appears. Bare-string `.file` delegates to the ordinary file handler. DWARF instruction/finish guards return; no STABS section or debug remap call is reached (`gas/dwarf2dbg.c:1071–1080,1166–1180,3141–3169`; `gas/read.c:6621–6653`). CodeView is excluded by non-PE configuration. |
| Floating/ECOFF/literal-pool storage | No floating-data syntax; ECOFF and `NEED_LITERAL_POOL` are absent on the selected x86 ELF configuration. Fixed integer parsing does not call `atof_generic`'s dynamic arithmetic storage. |
| Synthetic CFI, ginsn and SCFI | `flag_synth_cfi=0` and no enabling option. Its instruction, function and label hooks cannot build a graph or states (`gas/config/tc-i386.c:7785–7793,14427–14429`; `gas/config/obj-elf.c:2227–2228,2415–2416`). |
| CFI grouping and extra rules | No multiple/linkonce/compact frame grouping, CFI labels, escapes, remember-state, personality or inline LSDA. No composed debug-section name, lazy `dwcfi_hash`, debug-segment record or extra CFI buffer is built. The ordinary CIE/FDE records remain charged. |
| SFrame | The installed-default and invocation join excludes it. The earlier conservative optional six-row SFrame charges are retained, not subtracted. |
| Optional symbol/section/expression forms | No `.symver`, `.eqv`, `.pushsection`, group/link-order section, `%S`, `.reloc`, `.func`, `.endfunc`, `.errif`, `.warnif`, `.startof.`, `.sizeof.`, MRI form or `.nop` directive. A machine `nop` is a different dispatch. No dollar/high-numbered label or complex-relocation form occurs. |
| Architecture and alternate operand handling | No `.arch` stack or feature directive, architecture/comment/help option, Intel syntax or folded-name lookup. The selected case-sensitive target has no symbol canonicalization hook. |
| Compression | No debug section or compression option; `write_object_file` never calls `compress_debug`. Its fragment growth and indirect zlib/ZSTD allocators are excluded together (`gas/write.c:1488–1612,2521–2530`; `gas/compress-debug.c:31–45`). |
| Diagnostic-only storage | No selected valid expression produces a symbol cycle, broken-word recovery or error-name expansion. Diagnostic/locale internals on external failure remain part of the host boundary, not a reason to infer a capacity bound for arbitrary invalid input. |

The selected allocation callbacks are not additional uncounted families.
`gas/as.h:117–118` maps obstack chunk allocation/free to `xmalloc`/`free`;
`notes_*` forward to that obstack. The five hash tables use the retained
libiberty constructor/growth implementation: the symbol table uses direct
`xcalloc`, the other four use `notes_calloc`, and string tuples invoke the
table's same callback (`gas/hash.h:52–58,96–117`). Their source-derived table
sizes and tuple insertion counts are in the hash transfer. The macro-formal,
repeat, ECOFF, grouping and ginsn hashes require the excluded routes above.

There is no selected caller of `str_hash_find_n`, `xmemdup0` or
`notes_memdup0`. The callers of the byte-copy helper present in the corpus are
in excluded DWARF, listing and macro paths; `str_hash_find_n` and
`notes_memdup0` have no C-module caller in this corpus. The inventory retains
these inline bodies and declarations, so their allocations are not silently
omitted. `notes_concat` callers are confined to the excluded CFI grouping and
STABS routes. The `sb_*` buffer wrappers likewise occur only in excluded
macro, `#APP` and input-insertion routes. Formatting of GAS predefinition names remains separately charged
at 45/42 bytes in the startup correction.

## Writer composition and remaining boundary

`write_object_file` chains/finalizes sections, relaxes, resolves symbol values,
applies fixups, builds relocations, sets the symbol table and writes contents
(`gas/write.c:2115–2533`). The selected fragment-class argument establishes one
inner sweep and at most two outer walks, without new relaxation allocations.
No `rs_leb128` oscillation repair, broken-word reconstruction or branch-padding
fragment is introduced. Object attributes have size zero and return before
section/payload construction (`:1901–1905`); the optional 36-byte build note
and its two relocation records remain charged.

The writer's reached allocation sites are the existing `fixS` objects,
relocation pointer array, output-symbol pointer array and optional build-note
relocation records (`:150,1300,1786,1941`). The x86 relocation hook's two
notes requests were already charged (`gas/config/tc-i386.c:18635–18636`).
Content fill uses a fixed 256-byte local buffer rather than a dynamically sized
heap object (`gas/write.c:1687–1720`). Closing still builds the 112-byte notes
composite before handing control to BFD; it does not re-enter a second writer.

Consequently the existing selected request bounds are unchanged: notes raw
requests **65,528**, notes chunks **65,769**, symbol-hash pointer arrays
**16,312**, parser scratch at most **67** bytes, and fragment/frchain chunks
**4,064** bytes. The distinct BFD interface still receives at most thirteen
GAS sections, 104 GAS-created BFD symbols, 281 relocations and the previously
bounded names/payload. Its existing cumulative output-arena charge is
**32,065 bytes** at output spelling `main~1.o`, and its ELF-object envelope is
**14,352 bytes**, with independent ELF string-table allocator contexts.

This closes the selected **GAS-owned parser/writer dynamic-request coverage**
under the stated input and callback premises. The earlier BFD transfers are
interfaces reused here, not a fresh proof of every internal BFD call. Host
allocation success, pointer placement, stdio/locale/diagnostic internals and
stack availability remain explicit external premises. Compiler, binder,
fixed-library and final-link composition remain separate. This result neither
establishes complete retained-tool capacity nor changes admitted Silver source.

Independent review by the native-expansion lane replayed 90+33 complete source
identities, eleven prior inputs and the 264-site inventory byte-equal. It
searched additional wrapper and obstack/BFD spellings, and inspected the
`sb_*`/input/`#APP` gates, x86 line hook, notes/hash callbacks, clone flags,
bare `.file` and DWARF exclusions, CFI grouping and zero-subsection state.
It found no missing selected GAS-owned allocation family and accepted the
unchanged request ceilings with the stated BFD/host-library boundary.
