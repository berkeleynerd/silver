# Selected literal native invocation and fixed-input join

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119),
Linux x86-64. The [callable packet](../evidence/retained-literal-invocation-join-20261018/README.md)
computes one native launch graph from the actual recognized Main bytes and the
reviewed fixed configuration. It binds the compiler, assembly, ALI, generated
binder and final-link roles. It selects the existing **fixed Silver object and
ALI bundle** as configuration inputs. There is no fixed-Silver compiler job or
GPR rebuild route in this graph.

This supplies the design-time invocation/input edges behind the literal
aggregate's three `Main_assembler_object_interface`, `Main_GAS_BFD_storage` and
`literal_output_linker_representation` residuals. It must be integrated using
the same actual source bytes, launch roles and component guards. The graph is
computable without running a program to decide its capacity. The aggregate's
other storage/counter/proof obligations remain separate; this packet does not
change their values or establish whole-pipeline capacity.

Production launcher adoption belongs to #88–#94. Its absence is **not a missing
source argument for this selected design configuration**. A launcher that
regenerates the fixed Silver children selects a different graph and still needs
that compiler/interface transfer. Required proof of the fixed Silver library
is unchanged by native object reuse.

## Callable inputs and exact routing

```python
import runpy
api = runpy.run_path("docs/evidence/retained-literal-invocation-join-20261018/compose.py")
context = api["Context"]()
result = api["build"](source_bytes, context, path_bytes=512,
                      host_page_bytes=4096)
```

`Context` verifies the pinned repository inputs, complete selected source files,
retained object/ALI identities, current Silver source equality and selected
installed configuration. It reuses the accepted literal linker callable; the
linker still reports each representation guard independently of graph
computability. `build` calls the complete literal recognizer and accepted
emission calculation on **the supplied bytes**, not a fixture's counts.

The native projection calls the existing null `launch_graph` function with
its light-phase list empty. It preserves the reviewed 109-byte project root,
113-byte object/binder directory, 127-byte binder source names and common
48-byte TMPDIR. The default symbolic paths retain the null packet's spellings;
they identify roles in a fresh selected workspace, not a claim that those
paths were executed here. A caller may substitute another normalized ASCII
root of the same widths. P covers each complete raw/resolved/generated/search
path including NUL. PID names bound any positive signed-32-bit PID by ten
positions; `cc000000.s` and `cc000001.s` stand for distinct live six-character
GCC temporary names. The selected driver creates these names; its frontend
output and GAS input share the actual name, not necessarily these placeholders.

The `materialization` array supplies exact contents or archive-member/byte
identities for twelve initial files. The explicit order is:

1. Create a fresh owned root, `obj`, `bin` and temporary directories. Copy the
   actual Main bytes, three fixed Silver source files, two fixed Silver objects
   and two fixed ALIs; write the naming, source mapping and two binder inputs.
2. Compile Main in `obj`; its output roles are `main~1.o` and `main~1.ali`.
3. Bind that **actual generated ALI**, producing `b__main~1.ads/.adb` and the
   object-list file in the selected temporary role.
4. Compile that generated binder body/spec pair in `obj` to `b__main~1.o`.
5. Link those two variable objects and the two fixed Silver objects, followed
   by the selected installed library graph, to `root/bin/main`.

The job list contains exactly `Main_compile`, `binder_generate`,
`binder_compile` and `link`. It does not invoke GPRbuild, Gprbind or an implicit
rebuild helper. Missing/changed fixed inputs fail the configuration check; no
fallback compiles them. Both GCC compile jobs have one input source operand.
GNAT reads dependencies without introducing another driver compilation job;
the accepted Main emitter supplies one emitted body. The binder driver's
selected successful path reads ALIs, checks them, computes elaboration order
and calls `Gen_Output_File` (`gnatbind.adb:754–819,900–935`); it does not invoke
a dependency compiler. The no-LTO linker route below excludes compiler workers.
Consequently this graph cannot silently regenerate Silver objects.

The four common Main bindings all name the same path and byte identity. The
native source map has four explicit triplets for Main and the three Silver
sources. `Fmap` defines this unit/filename/path format (`fmap.ads:29–40`),
reads complete triplets and inserts both mappings (`fmap.adb:279–396`). The
327-byte indexed naming input is copied unchanged and launched as `.TMP`.
The accepted null configuration-dependency argument therefore applies. System
is the same checked installed file. Native/source-role substitution does not
supply full datarep/light-producer argv, parent storage, or proof-library work.

## Compiler and assembler command source

The emitted GCC Main vector, including argv0, has seventeen positions:

```text
GCC -c -x ada -gnatA -gnat2022 -gnata -gnato
    -gnatx -Wno-free-nonheap-object -fsplit-wide-types
    -gnatec=NAMING.TMP -gnatem=MAPPING.TMP
    ROOT/main.adb -o main~1.o -gnateI1
```

This is the accepted indexed native vector with the three reviewed native
selectors. `-gnatx` suppresses Xrefs, the warning switch has its separate warning
handling, and the stock split flag reaches the existing RTL lowering. The
[split-option argument](retained-split-options.md) establishes the unchanged
Ada/gigi/GIMPLE/expansion prefix, added option storage and ALI row; it is not
an O1 request. The selected O0, no-debug, x86-64 generic, small-PIC, ordinary
PLT choices remain the existing defaults/premises. A complete controlled
environment fixes PATH, locale, runtime include/object roots and TMPDIR; it
provides no user specs, plugin, response file, alternate search or comparison
option. The native frontend retains its reviewed **25-position envelope**;
the packet does not invent an exact frontend dump-option vector.

Ada's spec forwards the `g*`, `m*`, `f*` options and selects `invoke_as` for
this compile-only command (`lang-specs.h:35–52`). The split flag adds no
assembler selector. `invoke_as` supplies one temporary assembly input;
`asm_options` adds the explicit object operand, and the selected target adds
`--64` (`gcc.cc:1328–1350`, `gnu-user64.h:34–53`). GNAT options do not enable
GCC debug level, so the debug assembler fragment stays inactive. With no
`-S`, `-pipe`, include, pass-through or comparison selector, the exact vector is:

```text
AS --64 -o main~1.o MAIN_ASSEMBLY
```

The output spelling is eight bytes, or nine with NUL, as required by the
[accepted invocation transfer](retained-assembler-invocation.md). The packet
retains the driver's raw relocated assembler path, including its `bin/../`
spelling, rather than substituting the shorter PATH alias. Main's emission
interface and linker callable are recomputed from the same actual source;
the assembler output and link input both resolve to `obj/main~1.o`. Every
source/representation guard remains required. An argv equality does not by
itself discharge GAS allocation or representation arithmetic.

## Fixed Silver and dependency materialization

The fixed [output-link delta](retained-linker-output-delta.md) already supplies
the Silver object/source correspondence and external interfaces. This packet
checks the current three Silver source files against the indexed and literal
capture sources; each object agrees with all four retained options-workspace
copies and the indexed copy. It selects those exact two object byte strings,
not freshly compiled objects under a newly inferred command.

The callable binds `closure/silver_io.ali` and `closure/silver_output_libc.ali`,
which equal the retained literal-proposed ALIs. They are deliberately **not**
identified with the indexed ALIs: their Silver D timestamps are
`20261018061955`, whereas the indexed versions have `20261018085527`.
Source bytes, checksums and U versions agree. Materialization copies the fixed
source bytes to their selected root roles and assigns the literal ALIs'
recorded timestamps. Main then sees the same fixed source names, bytes and
metadata that the binder consumes. The current checkout's mtime is irrelevant;
copying its bytes without this timestamp binding would leave a real coherence
edge open. No repository or installed file timestamp is modified by this
research callable.

The accepted [binder ALI census](retained-literal-binder-ali.md) supplies 82
fixed files and 163 coherent dependency metadata pairs. The two Silver ALIs
are copied into `obj`; the remaining eighty are byte-equal to the selected
installed runtime ALIs. The checker verifies all eighty and checks the runtime
source timestamps against the fixed D records. The relevant installed-source/
ALI coherence and compiler behavior remain the existing source-correspondence
premises. The Main ALI is the actual compiler output, with its matching current
Main timestamp/checksum, and fixed dependencies selected above. `-x` and the
coherent D contract preserve the accepted exclusion of timestamp-triggered
source checksum rescans. No captured Main ALI is substituted for that edge.

The native fixed source/ALI copies have finite constant sizes. This does not
establish the materializing parent's whole storage implementation. In
particular, it does not apply the old fresh **three-compilation-job GPR**
projection to this different, explicit **two-compilation-job** graph. Existing
local reader bounds may be retained as conservative components, but GPR parent
adoption and any fixed-child regeneration remain separately labeled.

## Generated binder family, not fixed fixture identity

The generator command retains the accepted indexed roles:

```text
GNATBIND -o b__main~1.adb OBJ/main~1.ali -x -F=EMPTY_MAP -O=OBJECT_LIST
```

Its complete environment uses PATH, LC_ALL, TMPDIR and
`ADA_PRJ_OBJECTS_FILE`; the last file contains exactly `OBJ/` plus LF. This is
the existing controlled binder route. `gnatbind.adb:485–491,728–729` reads the
empty mapping; `osint.adb:475–484` adds the object-path-file directory. Default
runtime lookup supplies the eighty pinned ALIs. The same fixed W/Z closure,
unit order and elaboration-root read projection used in the output delta
apply to the recognized Main family.

`binder_source_from_ali(actual_main_ali, result, context)` exposes the family
binding. It reads the unique `U main%b main.adb` eight-hex-digit version from
the **Main compiler-output edge** and changes exactly the corresponding
`u00001` Version_32 declaration. It is a transfer witness under the accepted
ALI writer contract, not an arbitrary-ALI validator or a replacement binder.
`Gen_Versions` copies `Units.Table(U).Version` into its fixed-width declaration
and exports it as `mainB` (`bindgen.adb:3039–3101`). No raw-source SHA is
mistaken for this token checksum.

The body retains the two indexed source-name spellings and all semantic code.
Object-directory changes are same-width substitutions in trailing comments;
the selected installed runtime path shortens those comments by 27 bytes.
Thus the exhibited body is 10,316 bytes, dominated by the retained 10,343;
the spec remains 19,920 bytes for every uint32 checksum. Binder source paths
still have the accepted 113/127 widths. The [null graph's argument](retained-null-pipeline.md)
for the shorter assembly temporary operand applies equally here: GNAT skips
that output operand, GCC excludes it from recorded command text, and it
changes no semantic source name.

Binder compilation uses the exact retained split-option command after rebinding
its tool path and cwd. It retains the two `-c` and `-gnatA` occurrences, ordinary
binder flags, warning option, generic target selectors, one
`-fsplit-wide-types`, indexed input and explicit indexed object name. Gprbind's
source would filter GNAT/include/runtime flags and forward the warning,
`-m*` and split options (`gprbind.adb:865–943`); this direct graph constructs
that vector explicitly and invokes no Gprbind process.

The [accepted split-binder comparison](retained-binder-options.md) and
[checksum lifetime closure](retained-binder-checksum-closure.md) compose:

- The split output object has 16 sections, 243 symbols, 134 relocations,
  224 EH bytes and maximum alignment 32. Its final procedure/FDE shrink by six
  bytes relative to the old output delta; the old linker envelopes dominate.
- Checksum variation changes four readonly data bytes. Zero stays readonly
  storage; code, relocation kinds, external symbols and allocated layout have
  the established fixed projection. The compiler allocation bound is
  5,167,732 cumulative rounded GGC bytes, 56,378 positive events and a
  262,144-byte largest rounded request.

The generated binder object's identity is therefore **variable**. Its exposed
family interface contains no captured-object SHA. Neither it nor Main is
required to hash-equal a retained fixture. The linker receives the actual
`obj/b__main~1.o` emitted by this compiler job, under the family projection.

## Link expansion and fixed installed inputs

The link driver selects `-fno-lto -fno-use-linker-plugin`. The callable takes
the accepted no-plugin null expansion, rebinds Main and binder basenames,
rebinds **both** local `-L` directories and the executable output, then inserts
`silver_output_libc.o` and `silver_io.o` after the binder and before libgnat.
All other target operands and their order remain unchanged. Literal `$ORIGIN`
is an argument byte sequence, never shell-expanded or copied with the display
escape from GCC's `-###` output. There are 47 collect2 argv positions and
46 ld positions after collect2 strips `-fno-lto`.

The [fixed-input/no-LTO source transfer](retained-link-inputs.md) establishes
that plugin discovery/initialization and LTO workers are absent; the selected
collect2 route launches exactly one linker. Adding two direct ordinary ELF
inputs adds no compiler jobs or search flags. The accepted literal linker
callable accounts for their representation/storage contribution. The historical
successful output link is not relabeled an exact-descriptor run.

The checker revalidates the fifteen fixed installed input spellings and their
bytes, plus the retained selected linker identity, and tests the earlier
installed lookup probes. The two local search directories are fresh generated
roles: their exact file inventory contains no library candidate, so the
rebound early probes stay absent. The other twelve command-line search
directories, implicit script, two explicit scripts and complete DSO closure
retain the accepted identities and lookup outcomes. The same-source selected
configuration, ordinary accessible/coherent filesystem, allocator/stack/disk,
process and I/O premises remain explicit. This is not a new build attestation,
a total-RAM gate, or a guarantee about arbitrary environments.

## Evidence and integration boundary

The packet records a focused offline replay, source/input identities and the
computed hello graph. Its checksum cases cover zero, signed boundaries,
uint32 maximum and the fourteen cache-sensitive values identified by the
accepted lifetime proof; these checks exercise the binding, while that source
proof establishes the universal checksum bound. Repeated-call variants recompute
actual counts and retain the same launch structure. No native capture, build,
proof/solver run, full suite, macOS run or production edit belongs to this work.

To attach this packet, evaluate it on the aggregate's exact source bytes and
bind the aggregate's native Main/library paths to these supplied roles. Keep
emission, object/storage, linker and other component guards conjunctive. Close
the selected **design invocation/input** residual separately from
`production_launcher_adopted=False`. No additional native input is presently
missing for this fixed-bundle graph. A regenerating fixed-child configuration,
complete producer launch/proof graph, other native capacity obligations and
production implementation are not supplied by this packet.
