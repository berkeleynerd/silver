# Literal-output linker composition

2026-10-18, Linux x86_64, research for
[#119](https://github.com/berkeleynerd/silver/issues/119). The
[callable predicate](../evidence/retained-literal-linker-20261018/compose.py)
composes the accepted literal Main assembly/object and GAS/BFD storage
interfaces with the retained fixed output objects and the generic parts of
the null-linker composition. It derives C calls, N nulls and W decoded literal
bytes from the complete source. It accepts no author-supplied counts.

Under the source/configuration premises below, a true result is a sufficient
representation condition for the selected assembler and output linker. This
argument is [independently accepted](../evidence/retained-literal-linker-20261018/review.md)
within that conditional scope. It is not a production admission rule or a
claim that every literal source satisfies it.
`whole_literal_pipeline_capacity_established` remains false. The Oracle,
language, tool options and current 4096-byte library/admission rule are unchanged;
#88–#94 remain pending the complete rule. The 8192-byte case below explores
capacity and does not establish a larger semantic domain.

## Contract and callable interface

The source family and emission premises are exactly those of
[literal assembly](retained-literal-assembler.md) and
[literal GAS/BFD storage](retained-literal-assembler-storage.md): the complete
Main shell with `with Silver_IO`, `pragma SPARK_Mode (On)`, direct qualified
Put/Put_Line calls on ordinary literals and optional null statements, at least
one call, the selected ASCII source alphabet, O0/split-wide-types and the
retained CFI/emission/source-correspondence conditions. The fixed library and
output binder are the [accepted output delta](retained-linker-output-delta.md).
The binder's four-byte Main checksum may vary, and its local filename uses the
accepted indexed spelling; the established read projection keeps code, CFI,
relocations and external records fixed across those variations.

The [null-linker composition](retained-linker-null-composition.md) supplies
the generic ld/BFD contracts. Retain its ELF64 Linux x86-64 LP64 target,
explicit `-fno-lto -fno-use-linker-plugin` descriptor, fixed script and ordered
library lookups, no relaxation/RELR/object-only replacement, selected unlimited
BFD cache statistic setting, and relevant-source-behavior premise for the
installed tool. Substitute Main, add the two direct Silver objects before
libgnat, and substitute the output binder. Search configuration and fixed-file
lookup outcomes stay explicit premises. This does not materialize that
invocation in production or execute a new exact-descriptor output link.

```python
import runpy
api = runpy.run_path("docs/evidence/retained-literal-linker-20261018/compose.py")
context = api["Context"]()
result = api["evaluate"](source_bytes, context,
                         path_bytes=512, host_page_bytes=4096)
```

`Context` checks retained input/source identities and the additional fixed
ELF relocation/FDE projection. `evaluate` calls the accepted source recognizer
and assembler/storage interfaces, computes the linker bounds with mathematical
integers, and lists each failed sufficient check. Path bound P has the same
NUL-inclusive meaning and invocation premise as the assembler interface. Host
mmap page G is a separate positive power of two; the selected layout alignment
A remains 4096 independently of G. Allocation success, stack, filesystem,
process and I/O resources retain their separate assumptions. There is no sum
of allocated bytes or aggregate RAM admission gate.

## Source compatibility with the no-plugin descriptor

The historical literal output witness used default GCC plugin selection. The
predicate records `historical_output_witness_was_exact_descriptor=False`.
Its successful link is used only after the following source projection,
rather than relabeled as an exact-descriptor success. The new capsule retains
eight complete source files with identities matching earlier source manifests;
citations use literal LF line numbering.

The selected GCC plugin claims a file only after finding `.gnu.lto_.symtab*`;
offload work needs `.gnu.offload_lto_.opts*`
(`lto-plugin/lto-plugin.c:1091–1137,1193–1204,1218–1318`). The earlier complete
fixed-input inventory excludes these names, as do the accepted Main emitter
and fixed output delta. The checker additionally checks the three output
objects and historical literal Main. Every offer therefore leaves
`can_be_claimed=0`, adds no symbols and no offload file. Its all-symbols-read
hook returns immediately when both counts are zero (`:771–781`); pass-through
plugin options do not cause a wrapper or new input in that branch.

The ld plugin adapter discards the speculative dummy BFD on an unclaimed file
and retains the original input (`ld/plugin.c:1282–1364`). The same applies to
archive-member offers (`ld/ldmain.c:1388–1413`); ordinary file selection is
unchanged (`ld/ldfile.c:514–534`). No BFD_PLUGIN definition enters symbol
resolution. Thus `first_hash` stays null: its initializer needs such an input
(`bfd/elflink.c:4452–4471`). Plugin-only definition replacement, IR symbol-type
exceptions, and first-definition tie breaks cannot apply. The extra
`non_ir_ref_*` bookkeeping and relocation scan
(`ld/plugin.c:1416–1542`, `bfd/elflink.c:5771–5826`) do not change ordinary
definition/undefined state: their resolution-sensitive consumers need an IR
definition or non-null `first_hash` (`elflink.c:5346–5360,5716–5721,11829–11848`).
The generic warning branch may change when a warning is emitted
(`bfd/linker.c:1790–1845`); warnings are nonfatal in this descriptor, and its
warning wrappers are already covered by the generic count/name contracts.

The plugin path also performs an earlier DT_NEEDED walk
(`ld/ldelf.c:1217–1233`). Its graph remains the retained three-DSO graph; each
needed SONAME already has an explicit matching input. Already loaded entries
are skipped; an as-needed loader match uses its existing explicit path
(`:977–1017,1047–1093`). It contributes the same fixed loader definitions, not
an additional provider or archive member. The later ordinary walk supplies
them under the no-plugin descriptor. There is no IR input to consume the
early walk's separate bookkeeping. Its empty all-symbols-read result creates
no new statements, undefined tail change or archive rescan
(`ld/ldlang.c:8438–8518`). Removing this unused plugin work preserves the
ordinary symbol/instruction compatibility projection; its speculative BFDs
and extra processing events are **not** included in the selected no-plugin
capacity accounting.

The GCC/collect2 descriptor transfer and selected linker identity remain those
of [link inputs](retained-link-inputs.md#invocation-and-implicit-script).
Historical option-workspace paths are not treated as the current paths. Their
controlled lookup outcomes, fixed target files and order, and the existing
source-to-installed-behavior premise remain required. This source argument
does not attest an unrecorded invocation or claim exact output bytes.

## Main external records and final relocation operands

Main's defined external remains `_ada_main`, GLOBAL/FUNC/DEFAULT, ordinary
`.text` at zero with positive size at most `Ttext = 31C+4N+22`. Its only possible
undefined externals are the two GLOBAL/NOTYPE/default Silver procedure names,
with value and size zero. The earlier public-function producer/writer argument
in [the null interface](retained-linker-interface.md) still applies; the literal
transfer adds direct call names and local constant-pool labels, not aliases,
COMMON, TLS, IFUNC, versions, weak definitions or new visibility directives.

Both Silver procedures are already defined by the directly linked library
object. Its three imports and the output binder's elaboration imports are
fixed. After the direct objects, the undefined-name state used by installed
archives is independent of call multiplicity, literal content and whether Main
calls one or both procedures. The historical witness need only call Put: the
Put_Line definition and its instruction bytes are also present in that same
fixed object. Changing a procedure's reference flag can change synthetic
PLT/dynamic work, which the generic H/R/Trel envelopes cover; it cannot add a
different external name or incompatible TLS/type declaration. The accepted
fixed inventory has no competing Main/Silver definition. The checker verifies
the output binder's Main reference still has zero size/value and no definition.

The null family's absence of instruction relocations is **not reused**. Main
adds at most **2C PC32 LEA fields and C PLT32 call fields**. The accepted x86
encoder supplies their complete four-byte fields inside the seven-byte LEAs
and five-byte calls. Each LEA addresses a local `.rodata` pool start, including
the valid zero-length literal endpoint. When GAS serializes a section symbol,
the addend incorporates that local offset and the RIP bias −4. The target is
still one mapped pool address minus four. It is incorrect to bound this
variable section-relative addend by the fixed-input K. A call either resolves
to the ordinary fixed procedure or its separately charged PLT entry, with
addend −4. Both new domains therefore have signed displacement magnitude at
most **V+4**. No new TLS/GOT instruction-transition predicate appears.

Main's single FDE start reference and optional two build-note addresses retain
their source-derived `.text` start/end domains, now with endpoint at most
Ttext. Constant data has no relocation. All three new fixed objects' relocation
fields are checked from retained bytes: only 64/PC32/PLT32, complete fields
inside their target sections, defined values inside their sections, zero
undefined/ABS values and absolute original addends at most the retained
**K=2,019,040**. Existing fixed merged-target, TLS endpoint, GOT/PLT and
synthetic writers keep the [relocation transfer](retained-linker-relocations.md),
with V substituted. Fixed instruction bytes and their symbol-resolution
projection retain compatibility; optional GOT conversion still checks reach
before commitment.

The predicate conservatively retains the earlier common condition
`2V + K + 15 <= INT32_MAX`, plus the sharper unsigned 32-bit, PLT-index, new Main
and EH field conditions. This common envelope overcharges the ordinary final
address difference; it is a sufficient inherited arithmetic condition, not a
demonstrated necessary limit. No relocation overflow is inferred merely from
its failure.

## Counts, payload and layout substitution

Let Y be the accepted Main serialized-symbol ceiling and Rm its relocation
ceiling. The output delta supplies:

```text
R = 49337 + Y             Q = 36473 + 24         Pobjects = 1485
Qrel = 7910 + 10          Trel = 546512 + Rm
Original = 46235378 + MainOriginal
```

`MainOriginal` sums the accepted ordinary payload, symbol records, relocation
records and both string tables. It includes NOBITS in the ordinary bound and
excludes ELF headers and placement padding. Main object-file size is separately
retained for the reader. Use the unchanged generic formulas from
[the linker join](retained-linker-join.md) for H/I/S/N/T/J/D/Z, GNU hash sizing,
symbol/string/version conditions, complete payload union B, padding, V and F.
Generated names now contribute `Y−1+23+285` occurrences and
`26(Y−1)+32*23+6020` NUL-inclusive bytes. Fixed name maxima still dominate:
ordinary names need at most 196 bytes and output section names 182, before NUL.

Two substitutions deserve explicit treatment:

- Copy storage is `4*(8850737+12701+Ttext)+63H`. The first two terms are the
  accepted installed and fixed-generated size sums. For Main, only external
  records reach the global size assignments (`bfd/elflink.c:4828–4859,4994–5105`);
  its single defined external has size at most Ttext, and undefined imports
  have size zero. Local-symbol count therefore does not multiply the Main size
  charge. The generic four-positive-assignments argument and alignment 64
  remain unchanged. This tightens the earlier null packet's deliberately loose
  all-symbol charge by the existing reader's external/local boundary.
- Every generated object contributes its fixed 31-byte `.comment`; the four
  generated inputs add 124 merge bytes/entry charges. The three fixed output
  objects each have a 48-byte property note, so the complete rewritten property
  charge is `296+144=440`. Only `.comment` is mergeable; its alignment is one.

Main `.rodata` has alignment at most 8 and remains in the same ordinary section
families as the selected layout. Added fixed objects have maximum alignment 32.
No new LINK_ORDER, large-section, MBIND, allocated merge, compressed, group,
TLS, COMMON, CTF or SFrame route appears. Thus the existing selected shape,
alignment 4096, at most 12 actual program headers, at most 2 mapping iterations
and trial/revert arithmetic argument apply with the new payload/count bounds.

## EH, reader and remaining storage joins

The accepted nonbinder EH inputs already include variable Main's bounded
92-byte section, at most 23 entries and **one** FDE, plus the fixed inventory
and three possible PLT templates. Replace the old binder with 224 bytes /
7 entries / 6 FDEs and add Silver_IO 96 bytes / 3 entries / 2 FDEs. This gives:

```text
EH original bytes <= 552148      entries <= 16336
FDEs <= 14960                    header bytes <= 119692
edited EH <= 743204 + (224+11*7+10) + (96+11*3+10) = 743654
```

The checker reuses the pinned existing EH parser definitions on those fixed
objects; it does not rerun the old whole installed inventory. Their two CIEs
use `zR`/PC-relative signed 32-bit encoding, short initial instructions, and no
personality, LSDA or set_loc. Silver_IO's FDE intervals are `[0,259)` and
`[260,488)`. The binder's six intervals are `[0,251)`, `[252,308)`, `[308,348)`,
`[348,1134)`, `[1134,1245)` and `[1246,1284)`. All start references are local
PC32, ranges are positive literals without overlapping relocation fields,
and intervals lie in nonmerge/non-TLS code. Main has one positive interval
at most Ttext in a separate input `.text`. Input-section concatenation and
the separately mapped PLT code preserve disjoint ranges exactly as in the
[EH transfer](retained-linker-eh-frame.md#selected-function-ranges-and-emitted-fields).
Entry offsets, CIE back-references, relocated fields and header signed 32-bit
differences use the substituted EH/V bounds, not the old null numbers.

All variable ELF-reader requests are re-evaluated: Main's 24 headers, 80-byte
internal header and pointer/creation arrays; external/internal symbols 24R/32R,
indices 4R, external hash pointers 8R and relocation storage 24Trel. Large literal
objects may exceed the mmap threshold. The predicate uses the general input
span bound **B+2G**, not the old small-null heap-only observation. Main's file
bound is at most B: the fixed original payload alone covers its excluded
headers/padding. Retained fixed-file/archive read ranges remain the earlier
exact, larger-than-header accounting.

The no-plugin object and section ID bounds become
`2*(Pobjects+2*65+2*15+1)=3292` and `16+2*(Q+I+S)=268824`. The two scripts and
18-target rejection projection, no COMMON/thin/object-only probing and cached
archive reuse stay as in the null argument. The fixed Silver inputs are normal
ELF objects and introduce no additional library search probes.

The auxiliary merge/EH/layout/final scratch formulas are re-evaluated, including
the host-page parameters, hash capacities, string-table positive-reference
counts and pointer growth, global hash rollback snapshot, and allocator
backing overhead. ld start/stop pointer growth uses its actual `2a+10`
recurrence with at most 2(I+S) entries; section checks, PHDR pointers and output
statement keys are charged separately. The existing 16 statement / 9 sizing /
2 mapping iteration bounds still follow the selected no-plugin schedule.
ld/BFD arenas have no newly introduced cumulative allocation counter; erased
cache/allocation statistics are not reinstated as a cumulative memory gate.
Every individual request and count retains its own checked representation
condition. These source contracts remain distinct from physical availability.

## Offline results and remaining scope

The [replay packet](../evidence/retained-literal-linker-20261018/README.md)
executes no compiler, assembler, linker, solver, prover or Lean command.

| Source case | B payload union | V retained endpoint | Common signed bound | Predicate |
| --- | ---: | ---: | ---: | --- |
| `Put_Line ("Hello")` |463,493,782|872,708,982|1,747,437,019|passes|
| one 8192-byte literal |463,501,969|872,717,169|1,747,453,393|passes|
| 5000 one-byte Put calls |670,937,281|1,080,152,481|2,162,324,017|fails sufficient fixed relocation bound|

All three pass the assembler interface/storage and every other linker check.
For the repeated one-byte-call family, 4821 calls give 2,147,468,091 and 4822
give 2,147,551,085 against INT32_MAX 2,147,483,647. These adjacent values describe
**this conservative envelope only**, neither a tool maximum nor a new language
limit. The failing term is `2V+2,019,040+15`; the sharper new Main reach and EH
conditions pass even for 5000 calls. A later tightening must prove the needed
consumer-specific operand envelope, rather than simply delete the failure.

Focused checks also cover complete-source rejection, empty/escaped literals
with nulls, and independent host mmap-page parameters. Successful results are
conditional representation claims with the manual source argument above; the
source snippet checks in Python are identity/landmark guards, not a machine
proof of control flow. Production invocation/materialization, other producer,
compiler and binder phases and whole-pipeline composition
remain separate obligations. No current admission behavior is changed.
