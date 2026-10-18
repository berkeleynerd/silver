# Null-family binder source and object transfer

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This component derives the binder-generated source family for the indexed null
program. It identifies a much smaller route to binder object capacity: fixed
code and source locations, with bounded trailing path comments. The complete
[capacity rule](retained-tool-capacity.md) remains unfinished. In particular,
the observed object inventory below is **not yet a universal object bound**.

The [portable evidence](../evidence/retained-binder-capacity-20261018/README.md)
contains complete reviewed source files, the selected ALI closure and existing
generated sources/objects. No compiler, binder, assembler, linker, prover or
Lean process ran for this component. Existing successful executions are reused
only with their original identities and scope.

## Descriptor and input contract

The family is the null shell's fixed token sequence, allowing precisely the
language's case, comment and whitespace variations. This is not the static or
argument-input shell. Its sole unit is `Main`, source basename `main.adb`,
native ALI/object basenames `main~1.ali`/`main~1.o`, and unit index 1, following
the [indexed-discovery repair](../indexed-main-discovery.md). Source size, line
and column values must already satisfy the native frontend capacity rules;
this binder component does not establish that upstream premise.

The transfer starts from the native null ALI contract: one `main%b` procedure
with `NE OO SU`, the fixed target/configuration/restriction fields, no with or
invocation-relation records, one ordinary Main invocation construct and the
fixed System dependency. Casing flags, source timestamp, source positions and
optional Xref text may vary. This is the join to the native null expansion
argument, not permission to assume the same contract for new constructs.

The installed runtime ALIs, target settings and binder invocation are fixed.
No CodePeer, CUDA, extra library units, binder environment injection, special
library-binding mode or command-line naming override is selected. The source
argument uses GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and GPRbuild
`bdfb879cf03643ec8e48a09ce07b08c4a6ff0263` under the existing relevant-behavior
premise. Source pins are not a historical binary build attestation. This
component neither resolves nor depends on claiming an exact installed SPARK
source commit.

The generated binder compile is a separate frontend process. Gprbind appends
`-c -gnatA -gnatWb -gnatiw -gnatws`, filters Main's `-gnat*`, `-I*` and
`--RTS=*` options, copies the remaining backend options, then appends the
generated source and `-o b__main~1.o` (`gprbind.adb:865–943`). Thus Main's
`-gnateI1` and proposed `-gnatx` do not make the binder an indexed compilation
or suppress its Xrefs. The proposed `-Wno-free-nonheap-object` **does** propagate;
the existing [option experiment](../evidence/retained-native-options-20261018/README.md)
records that unindexed descriptor separately. The current indexed witness
uses baseline options; the two configurations are not silently conflated.

## Read projection of variable Main metadata

| Input | Consumer and consequence |
| --- | --- |
| Case, whitespace and comments | `scng.adb:64–123,1350–1410,1670–1788,2549–2594` folds ASCII letters before checksum accumulation, skips whitespace and consumes comments without checksum updates. Identifier/keyword token checksum events retain the fixed token boundaries. Consequently the null family's checksum event stream is fixed. |
| Main unit version | `lib-load.adb:297–300` initializes from the source checksum; `:1031–1041` XORs a dependency checksum on the selected semantic dependency route. Fixed null syntax and fixed dependencies preserve those events. `lib-writ.adb:432–447` writes the version, and `ali.adb:2744–2752` reads eight hex digits. It is fixed for this family, rather than an arbitrary 32-bit parameter. |
| Identifier/keyword casing flags | `ali.adb:2811–2843` stores `Icasing`/`Kcasing`. The source generator's `Icasing` use is in the elaboration-call branch (`bindgen.adb:1674`). Main's `No_Elab` branch (`:1549–1585`) bypasses it; CodePeer is excluded. Runtime casing is fixed. No `Kcasing` read occurs in the generator. |
| Invocation signature line/column | Parsed as `Nat` and included in signature interning (`ali.adb:580–610,736–768`). Main has no incoming or outgoing invocation relation in this closure. Its fixed name/scope `main`/`standard` cannot coincide with any retained runtime signature; the collector checks that absence. Varying its coordinates changes its hash bucket but not the sequence of new signature IDs, constructs or edges. The hash's `Bounded_String (2052)` needs at most **37 bytes** for `standard__main__<line>_<column>` with ten-digit nonnegative `Nat` values and no instance locations. |
| Invocation graph | `bindo-units.adb:438–463` inserts units/constructs; `bindo-builders.adb:100–124,133–173,202–218` creates vertices and edges from those records. `bindo-graphs.adb:4987–5040` assigns sequential vertex identities and uses construct kind to select elaboration roots. The isolated Main vertex keeps its kind and placement. Source coordinates do not add edges or select elaboration calls. Library dependencies/order therefore remain fixed under this ALI contract. |
| Xref text | GNAT's `ALI.Scan_ALI` returns at the X header and ignores its remaining text (`ali.adb:3348–3377`). With proposed `-gnatx`, EOF at that same point is accepted. This excludes Xref contents from source generation, not the raw ALI input buffer from capacity accounting. |
| Source timestamp | D-record timestamps serve consistency checking. A coherent compile/bind sequence must retain matching source/dependency artifacts. `bindgen.adb` does not read or serialize timestamps. The retained cases differ in timestamp without changing the generated spec. |
| Main source basename, object index and library name | They are fixed descriptor fields. `Gen_Main` declares an imported `Ada_Main_Program` with link name `_ada_main` (`bindgen.adb:1974–2003`); it does not recompile or with Main's body. Gprbind supplies the fixed `b__main~1.adb` output basename. |
| Workspace/object-search paths | `Gen_Object_Files_Options` emits them as trailing comments (`bindgen.adb:2237–2351`). They do not become unit names, version labels or executable source text. They still consume source bytes and command/path storage. |

The graph argument preserves logical graph shape and generation choices, not
every hash-table operation or allocator trace. Signature buckets may differ;
the separate binder table and raw-input capacity obligations remain below.

For null, `gnatbind.adb:802–820` injects `s-stalib.ali` and recursively reads
withed dependencies. Starting with Main plus that fixed runtime seed, the
retained W/Y/Z closure has **61 ALI files and 101 distinct unit entries**.
Its units exactly equal the 101 generated version exports, after `%b`/`%s`
conversion and dot-to-double-underscore encoding. This reconciles selection
with generation; the fixed dependency edges and the native null ALI contract
are what make it a family closure. The broader 98-file/169-unit closure in
[fixed support](retained-fixed-support.md#binder-source-generation) remains
the overapproximation for the wider language.

`Gen_Versions` emits one `Version_32` constant and export per selected unit,
using the eight-character version (`bindgen.adb:3039–3101`). For this family
`mainB` is the fixed `16#73b77761#`, confirmed by all three indexed retained
variants. `Get_Ada_Main_Name` checks fixed unit names for collisions
(`:3124–3184`); none is `ada_main`, so the package name remains `ada_main`.
There are no source-derived extra units, restrictions, tasking settings,
interrupt/dispatch strings, finalizers or secondary-stack counts.

## Generated source size and location contract

Under that projection, the generated specification is a fixed **14,556 bytes,
350 LF-terminated lines**. The body's executable prefix and suffix are fixed.
The only path-bearing lines are 194–197, after the generated subprograms and
before the closing `end ada_main;` at line 203. Each is one LF-terminated
comment. Let `O` be the complete Main object path length, `D1,D2` the two
workspace object-search directory lengths including trailing separators, and
`R` the installed `adalib` path length. Counting the fixed `-L` prefixes
separately gives:

```text
spec_bytes = 14,556
body_bytes = 7,483 + O + D1 + D2 + R
combined_bytes <= 22,039 + 4P       when each complete path length <= P
```

The constants come from the retained generated text after the source argument
has isolated all variable fields; they are not a bound inferred by taking a
maximum of sample lengths. Controlled paths must contain printable ASCII and
no CR/LF or other controls. This is an explicit invocation requirement for
#89: raw paths are inserted in comments without escaping, so a length bound
alone cannot justify the one-line property. The currently retained paths
satisfy it. It is not a restriction on Silver author's source trivia.

At the existing example `P = 4,096`, raw generated source totals at most
**38,423 bytes**. Using `q(b) = 4096 * ceil((b+1)/4096)` separately for spec
and body gives **40,960 source positions**. Adding the conservative entire
installed runtime union and the fixed-support virtual-source allowance gives:

```text
40,960 + 20,496,384 + 4,096 = 20,541,440
```

This is a binder-frontend source-range bound only. Gprbind filters the Main
unit-index switch, so the binder retains the ordinary physical request-name
deduplication premise; it does not inherit indexed Main's source duplication.
The [source closure](retained-source-closure.md) and fixed-support records
supply the runtime/request-name and virtual-source premises. No new Main-size
threshold follows from this number.

All generated code tokens retain their file, line and column. Even the closing
package name has fixed coordinates: changing the byte length of four preceding
single-line comments cannot change its line or column. The raw `Source_Ptr`
value and aligned start positions of subsequently loaded files can change.
Gigi's location conversion reads logical file/line/column rather than forwarding
the raw byte offset (`gcc-interface/trans.cc:11006–11035`); its file maps depend
on source-file order and line counts (`:339–365`), which are fixed here. This
also preserves the particular source-location distinction used by O0 nop
insertion (`gcc/cfgrtl.cc:784–850`). **Debug being disabled alone would not
establish this.** Main itself still has variable code locations and must retain
the separate native backend bounds.

This establishes the generated source/location interface for the next
source-to-object argument. It does not claim that every frontend/backend
allocation or output-name consumer has now been audited.

## Names, calls and retained object inventory

The generator's imported Main name is `_ada_main`; C entry names and the
`ada_main` package name are fixed. Version export names are the fixed unit
name with dots changed to double underscores and `B` or `S` appended.
Elaboration counters and finalizer imports use the same fixed unit closure.
Every explicitly spelled Import/Export name in the retained source uses only
ASCII letters, digits and underscores. Four C imports omit the link-name
argument (`gnat_argc`, `gnat_argv`, `gnat_envp`, `gnat_exit_status`), and their
fixed default spellings use that alphabet too. The generated source contains
no `Machine_Code`, `Asm`, `Asm_Input` or `Asm_Output` construct.

Thus **the generated source interface supplies no `@` name or inline assembly**.
Compiler-created elaboration/init names still belong to the source-to-object
join; the source alphabet observation alone is not a proof about every symbol
the compiler may create. The retained ELF inventory lists all 169 global/weak
symbol records, including those extra names, and confirms none contains `@`.
No generated name depends on an author identifier in this null family.

The fixed generated call structure comprises `adafinal`, `adainit`, C `main`,
the binder package elaboration and the secondary-stack initializer. The
`main` wrapper invokes initialization, `adainit`, `_ada_main`, `adafinal` and
finalization; `adainit` initializes the fixed runtime parameters and invokes
the fixed elaboration entries; `adafinal` invokes runtime and standard-library
finalization. None of these call lists grows with author trivia. Runtime code
itself remains in the [fixed link-input closure](retained-link-inputs.md).

The existing #123 regressions at implementation target `ce4d2fee36` supply
the indexed CR, LF and uppercase/trivia objects. Their specs hash-equal; their
bodies differ only in workspace names in three comment lines; their objects
are byte-identical. The following are **observed fixed-witness quantities**:

| Indexed binder object property | Retained value |
| --- | ---: |
| ELF64 x86-64 relocatable file bytes | 13,432 |
| Sections, including null | 16 |
| Symbol records, including null and local | 179 |
| Global/weak symbol records | 169 |
| Maximum global/weak name length | 40 |
| Relocations | 95: 89 text, 1 read-only data, 5 EH frame |
| Executable-section bytes | 1,000 |
| Allocated section bytes, including NOBITS | 12,023 |
| `.eh_frame` bytes | 192 |

All object section headers lack LTO/offload/object-only/compressed data. These
facts are relevant to the linker transfer but remain witness observations
until the source-to-object projection is completed. The historical proposed
unindexed object is separately retained at 13,424 bytes; its different basename
and options are not normalized into the indexed witness.

## Remaining joins

1. Complete the native null ALI contract and invocation controls, including
   fixed source/object search, printable single-line generated paths and
   matching artifacts. Bounds on variable Main ALI input length remain
   upstream; the Xref ignore rule does not remove reading that buffer.
2. Bound binder ALI parsing, signature maps and elaboration tables, including
   the varying location hash and fixed runtime closure. Fixed logical output
   does not by itself discharge intermediate representation bounds.
3. Complete the compiler/assembler read projection from this fixed code and
   location interface to object shape and transient representations. Account
   for source buffers, filenames, target/runtime dependencies, generated
   elaboration/init names and every relevant option. Either justify reuse of
   the retained fixed witness for this projected class or identify the exact
   additional state requiring a focused witness; a fresh sample by itself
   would add no family argument.
4. Compose the resulting certified object inventory with Main's variable
   native object bound and the fixed-library/linker components. Only then may
   the object quantities above become whole-family linker inputs. Broader
   shells need their own binder closure/projection; this null progress does
   not complete #119 or unlock admission changes.
