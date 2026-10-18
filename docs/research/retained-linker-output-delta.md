# Fixed linker delta for literal output

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-18, Linux x86-64. This extends the fixed-input part of the
[null-link composition](retained-linker-null-composition.md) to Main bodies
containing direct qualified `Silver_IO.Put`/`Put_Line` calls on ordinary
String literals, interspersed with `null`. Main has `with Silver_IO`,
`pragma SPARK_Mode (On)`, and no declarations, branches or loops. Literal
lengths and call counts remain symbolic; this does not change the current
4096-byte library/admission rule or establish a larger semantic domain.

The additional fixed inputs are **two** objects, `silver_output_libc.o` and
`silver_io.o`, and an output-family binder. The installed library-file set
does not expand. This packet establishes their retained byte identities,
external interfaces and symbolic count/payload delta. Main's eventual
object/relocation envelope, binder compiler lifetime counters, and the
whole output-link capacity join are separate unfinished obligations.

The [offline checker](../evidence/retained-linker-output-delta-20261018/README.md)
verifies nine prior input identities, 153 retained artifacts and 13 complete
source files. No compiler, assembler, linker, solver, prover or Lean command
was run for this packet. Source references below count literal LF bytes.

## Retained witnesses and their limits

The literal-options witness compiled `Silver_IO.Put ("a");`, returned zero
and printed `a` in the previously recorded native-options managed run.
Thirty-eight copied historical source, ALI, binder, log and output artifacts
hash-match that packet's original manifest. Surviving object files were
collected now from that run's workspace; their identities and origin paths
are retained here, rather than represented as files present in the original
archive. Four surviving options-workspace copies and the indexed-output
workspace contain identical Silver library objects.

The indexed output witness is the existing `static-image-mutation` program
from the indexed-Main experiment. Its surviving executable still hashes to
the independently recorded identity. It is used only to bridge indexed
binder source/object shape, not as a literal-only Main compilation witness.
The original output links used the GCC driver's ordinary plugin selection;
they did **not** explicitly request the later no-LTO/no-plugin descriptor.
Consequently this packet does not label them successful exact-descriptor
output links. A source-based no-plugin compatibility transfer or a focused
exact-descriptor witness remains necessary when closing the output join.

## Fixed library interface and installed inputs

The three retained Silver source files match the current library sources.
The ordinary link commands put both Silver objects before `libgnat`.
`silver_io.o` is2456 bytes; `silver_output_libc.o` is1000 bytes. The former
defines both output procedures, `silver_io_E` and `silver_io__max_length`;
its only external undefined names are `__gnat_set_exit_status`, `putchar`
and `fflush`. Its488-byte text uses PLT32 calls to those functions; its
EH relocations are PC32. The specification object defines only the two-byte
`silver_output_libc_E` and contains no code or relocations.

The targeted lookup against the existing fixed installed-input inventory
finds the first import in `libgnat.a(exit.o)` and the other two in the already
included `libc.so.6`. They are ordinary default-visibility functions;
`fflush` is weak, the others global. No installed fixed input defines any
of the five added Silver names. Both Silver objects have no COMMON, TLS,
IFUNC, version alias, allocated merge or LTO section.

The Main lowering contract supplies only undefined `silver_io__put` and/or
`silver_io__put_line` in addition to its `_ada_main` definition. As both
fixed definitions are linked directly, their presence and the fixed three
imports are independent of call count, ordering, literal contents/lengths,
or which of the two output operations Main uses. After those objects have
been processed, the external-name resolution state relevant to installed
archive selection has the same read projection across this family. Main's
symbol sizes, local tables, relocation multiplicity and layout still need
their own variable bounds. This is not a byte-identity claim for Main or a
claim that arbitrary additional relocations have no linker cost.

The output binder additionally references Ada.Text_IO elaboration, but
those runtime objects lie in the already charged complete `libgnat.a`.
The previous inventory charged every archive member, not only the members
chosen by the null witness. Under the same controlled file lookup,
script/search-path and source-to-installed-behavior premises, no new
installed file or DSO dependency is required. Library runtime semantics
and host resource availability keep their existing separate assumptions.

## Binder read projection

Starting from literal Main's ALI and `s-stalib.ali`, the W/Y/Z dependency
walk visits83 ALI files: Main, the two Silver files and80 runtime files.
Their U records contain140 distinct units. The binder spec exports exactly
140 Version_32 constants and every retained export matches its U checksum.
Fixed ALIs contain no `[main standard ...]` invocation signature.

Varying calls in Main changes its ordinary invocation records, including
source coordinates and the chosen Put/Put_Line target. It does not change
the library elaboration root reachability. Invocation edges point from
invoker to target (`gcc/ada/bindo-builders.adb:133–153`); root registration
selects Elaborate_Body/Elaborate_Spec constructs
(`bindo-graphs.adb:4986–5033,5334–5349`); elaboration dependency augmentation
starts at those roots and follows target edges
(`bindo-augmentors.adb:185–200,285–300`). Main is an ordinary subprogram
construct. No fixed ALI provides an incoming Main signature, and the
selected Main contains only output calls. Thus varying its outgoing
invocations introduces no path from an elaboration root into Main.
The fixed W/Z unit closure and elaboration order remain the same. This
argument does not bound the graph's total transient capacity; call/record
growth must still be charged by the producer/binder argument.

One binder scalar **does** vary: Main's unit checksum. The generator emits
one eight-digit hexadecimal Version_32 constant and export per unit
(`bindgen.adb:3039–3101`). For the retained literal and indexed witnesses,
the specs differ only in this checksum. Bodies differ only in the two
indexed source-name strings and trailing object/options comments. An
indexed Image dependency in the second witness is already within the same
fixed runtime closure; it supplies no broader grammar claim.

This public readonly32-bit scalar is never read by the generated executable
code. The selected constant declaration path preserves its readonly constant
initializer (`gcc-interface/decl.cc:659–747,1610–1640`,
`gcc-interface/utils.cc:3018–3099`). Readonly non-COMMON constants do not
move to BSS even when their value is zero (`gcc/varasm.cc:1107–1122`);
section selection uses readonly/nonmerge storage (`:7383–7424`), and emission
uses the fixed DECL_SIZE_UNIT, including zero emission of that size
(`:2452–2480`). Therefore checksum zero is covered rather than silently
excluded. It changes the four data bytes, not executable instructions,
relocations, symbol type/size or the allocated section layout. This is a
source read-projection argument under the selected compiler/options, not
an assertion that a sample establishes all compiler capacity conditions.

Direct ELF comparison confirms that all243 resolved symbol records agree
except the local STT_FILE spelling `b__main.adb`→`b__main~1.adb`.
All relocation records agree. Section payloads differ only in `mainB`'s
four `.rodata` bytes, the serialized symbol-name offsets and the string
table's two added basename bytes. Code, CFI and every external symbol record
agree. The output binder has17952 bytes,16 section headers and134 relocation
records. A direct EH entry walk finds one CIE and six FDEs in224 bytes;
the Silver_IO object has one CIE and two FDEs in96 bytes. These counts are
parsed from EH records, not inferred from relocation counts.

## Symbolic addition to the linker envelope

Let the eventual source-derived Main contract supply `Rm`, `Qm`, `Qrelm`,
`Trelm` and `Bm` for symbol records, section headers, relocation headers,
relocation records and the original section-byte sum. The existing
processed fixed-input allowance includes repeated processing and is larger
than an unweighted census. Adding the two Silver objects and indexed
output binder yields:

```text
R                    = 49,337 + Rm
Q                    = 36,473 + Qm
P                    = 1,485       (including Main)
Qrel                 = 7,910 + Qrelm
Trel                 = 546,512 + Trelm
original section sum = 46,235,378 + Bm.
```

The three fixed generated objects contribute285 named symbol/section
occurrences,6020 NUL-inclusive name bytes, and a maximum name length46.
Their symbol-size sum is12701; their maximum section alignment is32.
Original section sums include NOBITS payload size and all section headers'
payloads, consistent with the prior envelope convention.

These are inputs to the existing linker storage/layout/relocation formulas.
They are not a final positive capacity verdict: the Main object contract,
its emitted-call/CFI ranges, the descriptor transfer, and the numerical
join remain to be supplied. The null binder's captured compiler counters
also cannot be reused as output binder lifetime bounds. The current
4096-byte semantic restriction remains intact pending the separately
authorized library work in #93.
