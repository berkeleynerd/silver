# Retained assembler input and CFI evidence

2026-10-18, Linux x86_64, Refs #119. Supports the
[source derivation](../../research/retained-assembler-capacity.md).

`sources.tar.gz` retains 90 complete files from Binutils release commit
`5e56594815854de5eca35c7c04b11705d0f19c02`. `source-manifest.json` records
their byte counts, SHA256 identities and immutable retrieval URLs. The checker
also matches the commit against the previously retained linker release-tag
record. This is source identity, not historical binary-build attestation.

Run without an assembler, compiler, linker or prover:

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check.py \
  --output /tmp/retained-assembler-capacity-check.json
```

The checker reads archive members without extracting or executing them,
checks the exact LF-numbered excerpts, selected branch/source anchors and
buffer/instruction/frame arithmetic. The report supplies the manual reachability
argument. The conditional results are a longest-line buffer transfer, twelve
CFI nodes, 26 bytes of selected instruction encodings, a 92-byte local
`.eh_frame` contribution, at most six SFrame rows and 91 SFrame bytes, an
optional 48-byte x86 property note, and selected symbol-request counts.
The initial fragment join bounds those paths by 540 fragment allocations.
The unit-emission extension then includes compiler property notes, the
identifier, optional 36-byte build note, thirteen subsection starts and eleven final
alignment/sentinel events. At the selected 29-byte identifier it bounds payload
by 420 bytes and fragment allocations by 924, with individual 4064-byte
obstack requests and at most ten per-section region increments. The generated
line-length bound fits the initial scrub buffer. These are not ELF file size,
whole assembler capacity, complete allocator storage or final relocation reach.
Configuration can independently enable SFrame/property/build-note output;
all three branches are charged.

The symbol/fixup extension bounds GAS symbol objects by 90, including two non-output predefinitions,
and BFD symbols allocated through GAS by 104, fixup objects by 279, and optional build-note
relocations by two. Its selected LP64 raw request ceilings are separate from
shared-obstack chunk storage. The largest relocation pointer array is 2248
bytes and the GAS output symbol pointer array is 704 bytes. This excludes
later BFD-generated ELF metadata symbols and final relocation reach.

The subsequent [ELF object transfer](../../research/retained-elf-object-capacity.md)
reuses these inputs. Its separate source-only replay is:

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-object.py \
  --output /tmp/retained-elf-object-check.json
```

It bounds the selected null Main object by 22 section headers, 98 serialized
symbol entries, 281 relocations and 14352 file bytes. Symbol mapping reuses
existing BFD section symbols. Common allocator storage and final-link reach
remain separate; the file bound is not an observed native output size.

The [shared backing transfer](../../research/retained-assembler-backing.md)
adds frame/subsection structure ceilings and common GAS obstack arithmetic:

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-backing.py \
  --output /tmp/retained-assembler-backing-check.json
```

The thirteen fragment-chain control objects fit one initial 4064-byte chunk.
Shared notes chunks are bounded by `max(4064,Q+241)`, where
`Q=max(2248,8*(A+1),P,H)` records actual argument-count, copied output-path
and remaining hash-table request inputs. Shared string hashes use
`notes_calloc`; their pointer arrays are not covered by 2248. The descriptor
example `as --64 -o main.o TEMP.s` gives `Q=max(2248,H)`; no numerical
whole-notes chunk bound is claimed. The production phase join must supply
its actual argument/path inputs and a separate table inventory must bound H.
This bounds individual requests, not aggregate RAM or the remaining fixed
parser/opcode/hash and BFD initialization inventory.

The subsequent [hash inventory](../../research/retained-assembler-hashes.md)
supplies H=65528 from the pinned generated opcode/register tables, all
conditional pseudo-op rows and libiberty's actual prime/growth rules:

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-hashes.py \
  --output /tmp/retained-assembler-hash-check.json
```

It charges 2613 opcode entries, 352 register rows and 263 pseudo-op insertions,
plus the empty macro table and 90 symbol objects. The largest shared-hash
pointer request is 65528 bytes; the descriptor example's joined notes chunk
bound is 65769. The actual production argument/path join, non-hash startup,
expression/parser subsidiary storage and BFD backing remain separate.

The [installed SFrame default join](../../research/retained-assembler-capacity.md#selected-installed-sframe-default)
retains the selected assembler's ELF startup fields and the regions needed
to reread them. `flag_gen_sframe=0`, `cfi_sections=1` and
`all_cfi_sections=0`, together with the selected argv and emitted null-unit
directives, exclude SFrame in that invocation. The prior optional union is
unchanged. The final link's fixed and generated inputs remain separate.

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-defaults.py \
  --installed --output /tmp/retained-assembler-defaults-check.json
```

Without `--installed`, the checker uses retained ELF regions only. With it,
the full pinned executable is also hashed and each region is re-extracted.
Neither mode executes the assembler. The new execution is limited to
reading bytes, hashing, source guards and arithmetic.

The [fixed startup transfer](../../research/retained-assembler-startup.md)
bounds GAS option/include storage and the output BFD's control, x86 object
data, section metadata and section hash. It extended the bundle to 69 complete
source files, preserving previous member bytes.

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-startup.py \
  --output /tmp/retained-assembler-startup-check.json
```

It also joins the selected output BFD's cumulative `alloc_size` requirement:
startup contributes `P+8448`, selected later requests at most 23,608, giving
`P+32056`. This fits the counter under the individual main-arena request
condition `max(P,6744)+23<=PTRDIFF_MAX`. Actual production arguments/paths,
parser subsidiary storage, the other BFD allocator contexts and host-library
behavior remain separate. This packet does not
claim whole-assembler closure or add a total-RAM limit.

The [concrete ELF string-table transfer](../../research/retained-elf-object-capacity.md#concrete-elf-string-table-allocator-requests)
adds the seventieth complete file, `bfd/elf-strtab.c`, and specializes the two
object-writer string tables' allocator contexts. Both use 4,051 buckets without
growth; their individual bucket chunks are 32,424 bytes. The symbol-name hash
needs at most two small chunks, the section-name hash one, and their largest
entry-pointer arrays are 1,024 and 512 bytes. These requests use neither GAS
notes nor the output BFD's `alloc_size` counter.

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-elf-strings.py \
  --output /tmp/retained-elf-string-check.json
```

This checks source-level requests; libc allocator and `qsort` internals remain
outside this packet. The complete GAS lifecycle and production invocation join
remain open.

The [indexed invocation and subsidiary transfer](../../research/retained-assembler-invocation.md)
adds a separate six-file GCC source capsule and an exact copy of the reviewed
indexed native descriptor. This source-derived projection supplies the selected
GAS vector `AS_PATH --64 -o main~1.o ASSEMBLY_TEMP_PATH`, A=5 and output P=9.
It gives a 65,769-byte notes-chunk bound, a 32,065-byte cumulative output-BFD
counter bound, direct parser scratch requests at most 67 bytes, and the selected
relaxation fixed point. It is not a new captured argv or complete GAS call audit.

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-invocation.py \
  --output /tmp/retained-assembler-invocation-check.json
```

No compiler, assembler, linker, solver, Lean build, test suite or near-limit
allocation ran for this evidence. Source retrieval, hashing and arithmetic
checks were the only new execution.

The [predefinition correction and adjoining lifecycle inventory](../../research/retained-assembler-startup.md#predefined-symbol-accounting-correction)
fixes [#125](https://github.com/berkeleynerd/silver/issues/125). It adds 17
complete helper sources while preserving all prior member bytes. GAS's own
`GAS(version)` and optional `GAS(date)` were missing from allocation totals;
they do not enter the selected output symbol chain. Corrected allocated counts
are 90 GAS / 104 BFD, while output-chain 88 and ELF/object bounds are unchanged.
The temporary formatting requests are 45 and 42 bytes. The earlier allocated
88/102, R=23,352, P+31,800 and indexed 31,809 totals are explicitly superseded
in the record and replay result.

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-lifecycle.py \
  --output /tmp/retained-assembler-lifecycle-check.json
```

The adjoining review follows successful initialization, predefinitions, input
setup, optional finish paths and exit cleanup. It does not claim complete
inner parser/writer call coverage or a total emitted-line/event bound.

The [selected symbol-name transfer](../../research/retained-elf-object-capacity.md#selected-symbol-names-contain-no-literal-)
joins the compiler's fixed name classes to GAS temporary, numeric, file and
section symbols, excludes the absent `.symver` renaming route, and follows
BFD's name-preserving object writer. Every name in the selected null Main ELF
symbol table has no literal `@`. Three selected include files extend the
capsule to 90 complete sources while preserving all earlier member bytes.
Fixed dependency and linker-generated symbols remain separate inputs.

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-symbol-names.py \
  --output /tmp/retained-assembler-symbol-name-check.json
```

No assembler or other native tool runs for this check. The handwritten
selected-stream argument remains part of the transfer.

The [total emitted-line/event interface](../../research/retained-backend-gigi.md#total-emitted-lines-and-assembler-events)
charges zero-byte directives and labels independently of emitted payload.
The selected null compiler emits at most 114 LF-terminated lines, hence at
most 7,410 assembly bytes at the retained 64-byte line bound. This also bounds
selected nonempty parser events by 114 and the physical line counter by 115;
the logical line counter remains disabled. That packet left the inner allocation
inventory open. The additional GCC manifest binds 24 complete sources
and two reused arithmetic results; it leaves the existing manifests unchanged.

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-events.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --output /tmp/retained-assembler-event-check.json
```

The subsequent [inner allocation join](../../research/retained-assembler-inner-allocation.md)
reviews all 40 candidate GAS C modules and 37 GAS headers, following the
selected input dispatch and writer callbacks. `inner-sources.tar.gz` and
`inner-source-manifest.json` add 33 complete files at the same pinned commit
without changing the earlier 90-file capsule or its result identities.
`inner-allocation-inventory.json` classifies all 264 lexical allocator,
wrapper, callback and declaration occurrences. This count is a reproducible
census, not an allocation-event count or automatic C reachability proof.

```sh
python3 docs/evidence/retained-assembler-capacity-20261018/check-inner.py \
  --output /tmp/retained-assembler-inner-check.json
```

The handwritten selected-path argument finds no additional allocation family:
the existing GAS request ceilings remain unchanged. It closes GAS-owned
parser/writer dynamic-request coverage for the source-derived null Main input.
The earlier BFD transfer interfaces, host-library and stack premises, actual
controlled invocation, and other native phases remain separate. The checker
performs only archive/hash, inventory, source-anchor and arithmetic checks;
no compiler, assembler, linker, solver, Lean build or test suite runs.
