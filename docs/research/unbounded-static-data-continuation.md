# Unbounded programs: Linux static-data continuation

Research date: 2026-10-17. This completes the backend investigation for
[#108](https://github.com/berkeleynerd/silver/issues/108), subject to the combined
research review and disposition. It follows the [partial checkpoint](unbounded-static-data.md)
and [handoff](unbounded-feasibility-handoff.md), at research input
`df4af4588612f8f0b605570a7dd07e5b0c366b2c`. It changes no language rule,
compiler/runtime, tool pin, proof input or implementation status.

## Recommendation and exact stop

Do not adopt the complete proposed `Integer'Last` String family with the unchanged
pinned frontend. The frontend investigation identifies a representation obstacle
in compile-time String storage before the backend runs: separately live constant
Strings can require more character entries than its signed 32-bit index represents.
This applies even when each String is within the intended per-value ceiling.
The combined source-capacity record owns the lifetime/reclamation argument and
the source-to-installed-binary premise. It is not an observed native giant-build
failure, and an unsafe table-growth expression is not itself a measured native
cutoff. Backend flags cannot repair that frontend representation.

The appropriate follow-up for the owner's desired breadth is a separately
authorized investigation of a wider or lazy compiler representation that preserves
Ada static evaluation and the exact authoritative source. This is a toolchain
engineering direction, not an implemented or verified solution. If preserving the
current pin is instead required, the source-sensitive capacity alternative must
include String folding storage, not just source bytes and object lengths. Neither
alternative is adopted here; parent implementation #93 remains unstarted.

**Linux relocation is not the stop.** The retained Linux zero-fill controls and
the new complete small Ada links show a viable build-mode avenue. Prefer a fixed
large-model candidate over using a default small-model failure as a language cap:
the documented large model removes address/section-size assumptions, while medium
still constrains the aggregate code and small-data region. Neither option solves
frontend tables, finite address space, storage exhaustion or all runtime and
tool-library interactions. These findings do not prove universal backend
acceptance; they establish that the measured default relocation failure has an
available same-source alternative.

## Evidence and host identity

This continuation ran on **`codex-silver`, Linux 7.0.14, x86_64**, distinct from the
handoff's earlier Linux host `nix`. `scripts/dev.py paths` was read; no installation
was bootstrapped in the worktree. The unchanged shared Alire installation is
`gnat_native_16.1.0_9f74f58a`, GCC/GNAT 16.1.0, target
`x86_64-pc-linux-gnu`, configured with default PIE. The driver and selected linker
hashes equal the handoff's Linux identities. The
[identity record](../evidence/unbounded-programs/static-data-continuation-20261017/identity.json)
also records the actual `gnat1`, assembler, binder, linker driver, `gnatmake`,
`readelf`, runtime input hashes and environment. No application was executed.

The pinned Linux upstream source is GCC commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, selected by the retained release recipe.
Additional exact-pin files and hashes are in the
[source retrieval record](../evidence/unbounded-programs/static-data-continuation-20261017/sources/retrieval.json)
and compressed source capsule. Source correspondence to this installed compiler
is an external premise; this is not a reproducible-build attestation. The already
verified raw handoff supplied prior source and assembly evidence; it was not
recompiled to refresh timestamps.

## What the actual Ada path does

The relevant stages are distinct:

| Stage | Evidence | Consequence |
| --- | --- | --- |
| Ada semantic evaluation | `sem_eval.adb:2342–2443`, `Test_Expression_Is_Foldable` | Static String concatenation constructs a String-table value before backend optimization. Ordinary `-O` settings do not defer this mandatory frontend work. |
| GNAT-to-GCC lowering | `gcc/ada/gcc-interface/trans.cc:6705–6731` | A Character String literal is copied into a contiguous byte buffer and passed to `build_string`; large values use an allocated compiler buffer, then free that temporary. This is another materialization, not a lazy String representation. |
| Object placement | `gcc/ada/gcc-interface/decl.cc:1553–1564` | An aggregate constant with constant initializer is forced into static storage to avoid an initialization copy. A constant declared locally in `Main` need not occupy its stack. |
| Mutable object lowering | New 3 MiB local probe | Three mutable 1 MiB objects occupy an actual 3,145,760-byte local stack reservation and use `memcpy`, despite large-model data addressing. Mutable and immutable storage cannot be conflated. |
| Native link | New unchanged-source 1 MiB probes | Both medium and large complete compilation, Ada binding and linking against the selected GNAT runtime. The final ELF images contain initialized `PROGBITS` large data, not just zero-fill extents. |

The inspected GNAT allocation helper has an `INT_MAX` heuristic for an individual
static allocation (`decl.cc:7116–7124`). Its call path can choose indirect dynamic
allocation for a too-large top-level/static object (`1406–1502`). This is neither
an aggregate-data limit nor evidence that the proposed String family is secretly
heap-backed. In particular, the proposed single String ceiling is already
`INT_MAX`; the earlier frontend folding obstruction remains. The later constant
placement rule also means the helper should not be treated as a universal policy
for every constant. No changed compiler source is proposed by this inspection.

The prior actual Ada assembly gives the important bridge beyond C proxies:

| Model | Retained 1 MiB Ada assembly |
| --- | --- |
| Small | `a20.20` resides in `.rodata` and is addressed with RIP-relative `leaq`. |
| Medium | Large constants reside in `.lrodata`; `a20.20@GOTOFF` uses a 64-bit immediate `movabsq`. |
| Large | Large constants use `.lrodata` and 64-bit offsets; calls include indirect `PLTOFF` addressing. |

All three retained assemblies declare the 21 chain constants, with total payload
2,097,151 bytes. The native backend may retain cumulative constants even though
frontend String-table tail sharing avoids duplicating every left prefix. Those
counts must not be exchanged. Existing
[line-numbered assembly excerpts](../evidence/unbounded-programs/feasibility-20261017/static-data/linux-retained/probes/linux-ada-1mib-large/main.s.nonliteral-excerpt.txt)
and hashes remain the evidence for the original runs.

## Three discriminating Linux probes

The unresolved hypotheses were (1) whether the actual Ada source and pinned
runtime can bind/link with the observed medium/large lowering, and (2) whether
initialized mutable locals behave like the zero-fill globals used to isolate
relocations. Three serial bounded probes answer those narrow questions:

| Probe | Result | Wall time | Sampled process-group peak | Child maximum RSS |
| --- | --- | ---: | ---: | ---: |
| Unchanged 1 MiB Ada, medium model | Compile/bind/link succeeds; 3,485,344-byte executable | 0.442 s | 52,344 KiB | 49,516 KiB |
| Unchanged 1 MiB Ada, large model | Compile/bind/link succeeds; 3,489,488-byte executable | 0.444 s | 45,572 KiB | 50,172 KiB |
| 1 MiB constant plus three mutable 1 MiB locals, large model | Assembly succeeds; 3,145,760-byte stack reservation | 0.165 s | 43,040 KiB | 57,340 KiB |

The first two use the retained Ada input byte-for-byte, copied with the six
unchanged runtime source units from the frozen research tree. The driver command
is `gnatmake -v -f main.adb -o main -cargs -O0 -gnat2022 -gnata -gnato
-mcmodel=MODEL -largs -mcmodel=MODEL`. GNAT compiles the imported units it actually
needs; retaining six files does not mean all six execute or compile in this
static-output case. The third source adds only three initialized String variables,
same-length assignments and output calls, and uses `gcc -S` with the same Ada
checks and large model. No source replacement is used to obtain the two link
results. The third is a separate named lowering probe, not a replacement for them.

`readelf` identifies both linked executables as `DYN` PIE images. Their `.lrodata`
sections are initialized `PROGBITS`, each 1,966,104 bytes including alignment,
with further constants in `.rodata`. This is materially different from the
retained C globals, whose multi-gigabyte virtual span is `.lbss` `NOBITS` and
requires almost no file bytes. Successful zero-fill linkage cannot establish
initialized-object disk/layout feasibility; the small Ada links add that path
only at their measured size. No multi-gigabyte initialized object was created.

These inputs deliberately exceed today's 4096-byte String value rule and bypass
Silver admission as research inputs. The unchanged `Silver_IO` contract and body
still impose today's length ceiling, so linking these calls makes **no** claim
that today's runtime would perform a 1 MiB output, or that its call preconditions
prove. No GNATprove invocation or application execution occurred. #93 would have
to implement and verify any new runtime domain after the full stop is resolved.

The mutable assembly reserves approximately 3 MiB on the primary stack, copies
the constant initializer into the three objects, performs the assignments and
passes their addresses to output. It also emits an extra 1 MiB anonymous literal
initializer in addition to named constants. Increasing a code model does not
remove such stack or copy demands. Other forms can use the GNAT secondary stack;
the vendor `System.Secondary_Stack` distinguishes dynamically allocated chunks,
static-stack exhaustion and size overflow. No general heap/stack outcome follows
from one lowering shape. Runtime stack/heap exhaustion is separate from a
frontend representational rejection and must remain an observable operational
outcome, not be assumed equivalent to an attributable OOM report in advance.

The retained guard runner first verifies process sampling, then enforces 30-second
wall/32-second CPU bounds, 16 MiB per-file limits, disabled core dumps and a
512 MiB process-group RSS limit sampled approximately every 50 ms. No guard fired.
Sampled group RSS and `getrusage` child max-RSS measure different things; neither
is an exact aggregate high-water mark. Total measured child-command wall time is
1.051 seconds. These are research safeguards, not proposed product limits.

## Alternatives examined and obligations left for an authorized design

| Alternative | Finding |
| --- | --- |
| Fixed Linux large model | Available and directly exercised through Ada compile/bind/link. Removes the measured small-model relocation assumption without altering source or disabling checks. Candidate build configuration only; not adopted. Review runtime/archive references, symbol placement and any very large code/debug/unwind sections if the frontend obstacle is resolved. |
| Linux medium model | Also works in both retained large zero-fill and new small initialized Ada cases. It retains lower-address constraints for code/small data; it is less suitable as a blanket answer to an unbounded source family. |
| `-O1`/`-O2`, dead-data removal, constant merging or linker garbage collection | Can reduce emitted data for particular programs. Cannot remove the frontend's earlier required static evaluation; distinct live values and mutable copies remain admitted compositions. Not a universal remedy. No redundant optimization probe is needed to establish phase ordering. |
| `-gnatd.f` | Rejected. `debug.adb:732–734` explicitly says suppressing static folding causes "seriously non-conforming behavior"; `sem_eval.adb:7242–7246` exits before normal staticness/folding work. It is a debugging flag, not a semantics-preserving option. |
| `-fstack-check=generic` | Not a solution to static folding. GCC documentation says its threshold-based dynamic allocation can change semantics and that its static-frame limit can make checking unreliable. No generic claim that it relocates all large Strings safely is made. Ordinary specific stack checking is a separate operational design question. |
| Shared immutable storage, heap allocation, indirection or runtime construction | Potential compiler representations for unchanged source. Any solution must preserve Ada compile-time legality and static evaluation as well as runtime values, and account for allocation/failure behavior. Source rewriting to hidden initialization calls does not satisfy the Oracle. No sufficient existing switch was established. |
| Wider/lazy GNAT frontend | Directly addresses the first obstacle. Requires a separately authorized toolchain engineering study, not merely bigger Silver buffers. The frontend, GCC bridge, backend and producer need coordinated review. No current pin or source is changed. |

On macOS, retain the native evidence as independent and nonblocking for Linux:
the three-global C proxy fails an `ADRP` relocation and the selected Darwin GCC
rejects the large model, including with PIC disabled. GOT indirection and other
storage representations remain counterevidence to a universal Mach-O data bound.
No new macOS run or cross-platform feasibility claim is made. A Linux build flag
is not automatically a Darwin solution; source pin/runtime/backend review remains
platform-specific.

## Retention and scope

The [evidence bundle](../evidence/unbounded-programs/static-data-continuation-20261017/README.md)
contains exact inputs, diagnostics, commands, identities, timings, readelf output,
source excerpts, hashes and complete compressed probe artifacts. Scratch remains
at `/tmp/silver-unbounded-continuation-20261017/backend`; the original archive,
shared installation/caches and other worktrees are preserved. No GNATprove, Lean,
full suite, bootstrap, giant initialized build or executable run was launched.
Independent review and the root research record determine issue closure; this
record alone does not complete #93 or authorize implementation #88–#94.
