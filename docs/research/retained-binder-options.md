# Binder compilation under the split-wide option

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119),
native Linux x86-64. The [native option join](retained-split-options.md)
established that `-fsplit-wide-types` is written to Main's ALI and forwarded
by Gprbind to binder compilation. This record reconciles that option with
both retained fixed binder inputs: the null binder and the distinct output
binder needed for literal output. The [offline packet](../evidence/retained-binder-options-20261018/README.md)
retains the complete executions, predecessor inputs and source/binary checks.
Production flags, supported language and admission rules are unchanged.

## Exact executions and source interface

The old null object/compiler run is `20261018T111407-352fea7c3696`; its
separate lifetime run is `20261018T115025-40fa63ff60dc`. They remain valid
historical evidence under their original options. The new command adds
exactly one argument, `-fsplit-wide-types`, to that selected compiler command.
It keeps `-Wno-free-nonheap-object`, O0, no debug information, generic tuning,
x86-64 and the existing indexed relative input/output basenames.

The output input is the indexed binder in the
[output-link packet](retained-linker-output-delta.md), whose source came from
the retained `static-image-mutation` workspace. It is used as an output-binder
input, not as a literal-only Main compilation. Its spec has 19,920 bytes and
its body 10,343; the null spec/body have 14,556/8,014 bytes. Source copies are
byte-identical to their respective predecessors. The output compiler reads
nine fixed runtime specifications, compared with four for null; the new ALI
dependency records and their retained source bytes are checked separately.

Both scratch source directories have 113 bytes and both generated full source
names have 127. Their temporary directories have 52 bytes. The actual
frontend executable, 20 arguments, temporary assembly name and complete six-entry
environment are retained. The initial environment contains only the selected
tool `PATH`, `LC_ALL=C` and scratch `TMPDIR`; the driver adds its three ordinary
GCC entries. The debugger's library-path entry does not reach the frontend.
Each execution first performs one driver-only `-###` query, then one actual
compiler/assembler delivery with four hardware counter watchpoints and the
previous collection/value-expression guards. No binder generation or link is
repeated.

| Input | Managed run | Debugger seconds | Managed seconds |
| --- | --- | ---: | ---: |
| Null | `20261018T141731-1615498c5848` | 7.6371 | 9.9091 |
| Output | `20261018T141951-b4f17b9f45aa` | 7.9181 | 10.1042 |

Both reserved one worker, used distinct scratch workspaces and exited zero.
All retained inputs stayed unchanged. There was no native retry, full audit,
solver/Lean execution, full test suite, macOS validation or hosted CI run.
The combined managed cost is 20.0133 seconds, including 15.5553 debugger seconds.

## Object deltas and linker interfaces

Neither previous binder object is byte-identical under the new command:

| Property | Null before / after | Output before / after |
| --- | ---: | ---: |
| File bytes | 13,432 / 13,424 | 17,952 / 17,952 |
| Section headers | 16 / 16 | 16 / 16 |
| Symbol records | 179 / 179 | 243 / 243 |
| Relocation records | 95 / 95 | 134 / 134 |
| Executable bytes | 1,000 / 994 | 1,284 / 1,278 |
| Allocated bytes, including NOBITS | 12,023 / 12,017 | 12,499 / 12,493 |
| Sum of all symbol sizes | 11,766 / 11,760 | 12,206 / 12,200 |
| Sum of nonlocal symbol sizes | 1,443 / 1,437 | 1,827 / 1,821 |
| EH bytes, CIEs, FDEs | 192, 1, 5 / unchanged | 224, 1, 6 / unchanged |
| Maximum section alignment | 32 / 32 | 32 / 32 |

The new null object SHA-256 is
`c7dce906697df7a5b5edc21097d35f807f37deb642dbe98c07a58945d75919dc`;
the new output object's is
`b668f70341f147da7340df4ad5436206b052ec158a7108cd4bbc1b11fd9f3b4a`.

In each object only `.text`, `.rela.text`, `.eh_frame` and `.symtab` payloads
change. The final `ada_main___elabb` procedure shrinks from 38 to 32 bytes;
all preceding code is byte-identical. Its start is unchanged, at 962 for
null and 1,246 for output. Exactly one symbol record changes, solely that
size. Every symbol name, binding, type, section, value and other symbol size
is preserved. Exactly one relocation changes, moving the final call operand
six bytes earlier while retaining its symbol, relocation type and addend.
The final FDE's address range and epilogue advance each shrink by six; all
other EH bytes agree. Data, names, section kinds and alignment are preserved.
The changed move sequence and all these deltas are checked from object bytes.

Thus the preceding count/payload/alignment envelopes still dominate these
fixed objects, including the output-link packet's symbolic fixed contribution.
Their byte-identity premise must instead name the new objects. This does not
claim a successful complete link with the split option; the earlier link's
descriptor transfer and final Main/link conjunction remain separate.

## Complete counter observations

The replay validates every counter write, its initial state, permitted delta,
installed post-store PC and all five phase snapshots. Source-attributed
instruction windows and complete collector guard bytes remain pinned to the
installed `gnat1` SHA-256 used by the predecessor.

| Counter | Null with option | Output with option |
| --- | ---: | ---: |
| Replayed counter changes | 58,074 | 60,311 |
| Positive rounded GGC allocation events | 48,889 | 50,974 |
| Cumulative rounded GGC bytes | 4,155,416 | 4,481,000 |
| Largest rounded request | 65,536 | 131,072 |
| Normal declaration increments / peak | 6,390 / 6,390 | 6,512 / 6,512 |
| Type increments / rollbacks / peak | 2,431 / 364 / 2,068 | 2,446 / 379 / 2,068 |
| Debug declaration changes | 0 | 0 |
| Heuristic collection calls | 353 | 418 |
| Actual marker / value-expression calls | 0 / 0 | 0 / 0 |

The old null lifetime had 48,889 allocation events and 4,155,400 rounded
bytes. The option preserves its event count and UID statistics but adds
16 cumulative rounded bytes; collection calls increase from 343 to 353.
Consequently neither a hash-equal object nor identical whole-event history
is assumed. The old null proof's 4 MiB sufficient threshold still covers
the new null total, by 38,888 bytes.

## Supplemental first-collection bound

The output total exceeds 4 MiB. That observation does not defeat the existing
source method: the actual heuristic threshold includes its growth allowance.
`ggc_min_expand_heuristic` returns an integer between 30 and 100
(`gcc/ggc-common.cc:1067–1083`); the heap-size heuristic clamps its result to
at least 4,096 KiB after resource-limit adjustment (`:1086–1122`).
`init_ggc_heuristics` stores both defaults (`:1126–1132`), after initialization
of the option structure (`gcc/toplev.cc:2320–2327`). Neither selected command
contains a parameter override. The split option changes neither default.

The packet separately reads the installed ELF, without recompiling it, and
retains the heuristic code and constants. The initializer calls the inspected
minimum-expansion routine, stores its result at `global_options+0x1f0`, and
stores a heap result of at least 4,096 at `+0x1f4`. The already retained
`ggc_collect` instructions load those same fields, convert to binary32 and
perform the multiply, divide by 100, add and comparison described by
`gcc/ggc-page.cc:2297–2306`. The constants include 30, 70, 4,096 and 100;
the offline checker validates their bytes and RIP-relative source/destination
addresses. This is additional correspondence for these exact installed
instructions under the project's documented relevant-behavior source premise,
not a new claim identifying all historical binary build inputs.

At the minimum endpoint, the installed binary32 arithmetic gives
1,258,291.25 growth bytes and a 5,452,595-byte comparison threshold. A
conservative **5 MiB** lower bound leaves ample rounding margin: 30% of
4 MiB exceeds 1 MiB; conversion and the positive multiply/divide/add operations
are monotone. The pre-first-collection allocated-byte values here are below
2^24 and therefore exactly representable as binary32 integers. As before,
`G.allocated` cannot exceed cumulative rounded allocation; explicit frees only
reduce it (`ggc-page.cc:1493–1498,1753`). At a hypothetical first heuristic
collection, the fixed-source/path projection therefore gives:

```text
null:    G.allocated <= 4,155,416 < 5,242,880   (margin 1,087,464)
output:  G.allocated <= 4,481,000 < 5,242,880   (margin   761,880).
```

The heuristic must return before marking, contradicting that first collection.
The predecessor's source exclusions of forced collection, disabled statistics,
self-tests and RTL-reader paths are preserved. The observed mode-zero calls
and zero markers corroborate that argument. This supplements the historical
null 4 MiB proof and introduces no command-line override or physical-memory cap.

For these fixed source/path classes, the existing GGC storage formulas give
65,536 slots / 524,288 bytes for each independent page-pointer vector.
Conservatively assigning a finalizer registration to every allocation gives
null scalar/array requests of 1,173,320 / 2,346,632 bytes and output requests
of 1,223,352 / 2,446,696. These are individual backing-request bounds,
not measured process peaks.

## Transfer boundary and remaining obligation

For the **null family**, the predecessor's same-width-comment/filename,
location, name-interning and fixed dependency read projection applies with
the newly selected option held fixed. It supplies the same semantic request
graph for the new witness and transfers its new counter and object bounds;
the supplemental first-collection argument excludes collector scheduling
variation. Earlier driver/frontend/ALI storage receives the separate option
deltas already recorded in the native option join.

For the **output binder**, the new run establishes the complete lifetime and
object interface for its exact retained specification and body, with the
same fixed-source/path-renaming projection. The preceding output source
argument additionally establishes that changing Main's eight-digit
`Version_32` checksum changes four readonly data bytes without changing the
object layout or executable semantics. That object argument remains usable
with this option: its first selected semantic consumer is after expansion,
and the checksum constant is never read by generated code.

It does **not** by itself establish that all earlier Uint/scanner and GCC
integer-constant/cache allocation events are bounded by this particular
checksum's complete lifetime. The new packet explicitly records that broader
checksum-lifetime transfer as **unestablished**. The next precise join is to
bound the single varying 32-bit literal's frontend representations and cache
sharing/growth, then compose that increment with the retained lifetime and
761,880-byte first-collection margin. Repeating the successful fixed checksum
execution would not answer it. The output object/count interface and the
fixed-source no-collection result are complete components; a universal output
binder lifetime or whole-tool capacity verdict is not claimed. Ordinary
compiler/assembler/process and Main/link/producer composition retain their
other existing obligations. #119 remains open.
