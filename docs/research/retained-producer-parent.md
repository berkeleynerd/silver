# Producer parent and bundled GCC prefix

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This joins two missing interfaces: indexed Main discovery in GNATprove's GPR2
parent, and the fixed setup of the compiler selected for data representation.
The [packet](../evidence/retained-producer-parent-20261018/README.md) retains
48 inspected source files, the exact installed identities, a small guarded
execution and an offline event replay. Production admission is unchanged.

## Which compiler performs data representation

`SPARK_Install.GNSA_Dir` is `GNSA_ROOT` when set, otherwise `Libexec_Spark`;
`GNSA_Dir_Bin` adds `bin` (`configuration.ads:292–297`). GNATprove prepends
that directory and `Libexec_Spark_Bin` to PATH before spawning its children
(`gnatprove.adb:882–934`). The selected isolated environment excludes
`GNSA_ROOT`. The Image installation preserves the vendor layout and links its
GCC tools to the original archive; only gnatwhy3 is replaced by the adapter
(`scripts/bootstrap.py:266–297`).

`Call_Gprbuild` omits `--gnatprove` in the data-representation phase, selecting
GCC rather than gnat2why, and supplies `-S -gnatR2js -gnatws -gnatx -gnatis`
(`gnatprove.adb:180–330`). Under the existing effective-search premise this is
the **bundled producer GCC**, not the separately selected native GNAT compiler.
Their installed gnat1 SHA-256 values differ:

| Compiler | SHA-256 |
| --- | --- |
| Native GNAT | `5bf9b821ec0388ca6a6962dbc4bcb5773799926445fede6356069357c48dd58e` |
| Bundled producer | `5e93a62546d5538c3744c04c1b5989dc248f4a90ff47f6ea2f2d0bf3e2e2e1f6` |

The selected `system.ads` files are byte-equal. This equality does not make the
executables interchangeable. Source accounting retains the documented
[relevant-behavior premise](retained-tool-source-identity.md), including the
unavailable historical SPARK source revision.

`-gnatws` controls Ada warnings; it does not disable GCC's
`warn_free_nonheap_object`. The candidate producer invocation must additionally
carry the same `-Wno-free-nonheap-object` selected by the native capacity route.
GNATprove forwards explicit `-cargs` to GPR (`gnatprove.adb:293–296`). This is
a proposed future driver option, not a production change or suppressed proof
obligation. It gives **19 arguments excluding GCC**, one more than the
[indexed data-representation descriptor](retained-producer-gpr-descriptor.md).

That forwarding also reaches both gnat2why phases. Its backend accepts `-W`
switches without semantic effect (`gnat2why-driver.adb:1151–1173`); Adabkend
stores the switch once (`adabkend.adb:186–202`). Thus both child argument counts
become 17; phase1 has ten stored A rows with payload sum 77 and maximum 24,
and phase2 stores nine with sum 70 and maximum 24 (ALI output remains disabled
there). This increases the null ALI envelope by 27 bytes to **29,622,804** and
its line bound by one to 77,551; the largest record stays 789. The 24-byte
option does not change any admitted program's required proof obligations.
The top-level GNATprove command/configuration serialization includes the two
extra `-cargs`/option arguments. Its cmdline array now has 17 entries and
capacity at most 32. Each extra fixed JSON string adds its length plus three
bytes (quotes and separator); the [same six-field schema](retained-producer-null-global.md#configuration-and-ordinary-report-consumption)
therefore gives **349+12P file bytes**, while command joining gives **213+P**.
At the existing P=4096 path bound, the file envelope is 49,501 bytes and still
selects the 64 KiB small-file reader. The eight-reference per-object argument
is unchanged: the longer array contains distinct scalar strings, not repeated
references to one aggregate. The earlier 15-argument parent record is not
silently reused.

## Bundled fixed-prefix witness

Managed run **`20261018T125235-75f8d948d55b`** captured one prefix in **6.3148 s**.
It used the bundled GCC, the exact 69-byte null sample, the reconstructed
327-byte indexed naming configuration, one Main mapping and the options above.
No source is rewritten. The prepared configuration is not represented as a
GPR-produced temporary file. Its three naming pragmas match the established
descriptor's semantic projection.

The capture begins at frontend exec, checks the binary hash and initial counter
values, installs four hardware write watchpoints, and stops before Main
translation at the `Compilation_Unit_to_gnu` call (`trans.cc:685`). The
installed call address is `0x9a93d9`. The retained executable map binds every
observed store to its instruction bytes and counter; source sites identify
make/copy declarations, make/copy types, type-hash rollback and rounded GGC
allocation. A collection guard and new-thread observer remained clear.

| Quantity | Observed prefix |
| --- | ---: |
| Event records | 47,707 |
| Positive rounded GGC allocations | 39,257 |
| Rounded GGC bytes | 3,318,768 |
| Declaration identity increments | 5,832 |
| Type identity increments / rollbacks | 2,277 / 341 |
| Next type identity, final / peak | 1,937 / 1,938 |
| Debug declaration identity changes | 0 |

The replay reconstructs every transition and all five phase snapshots, rejects
wrap/reset or an unexpected store site, verifies the installed ELF bytes, and
checks the seven-entry launch environment and ten-entry frontend environment.
The latter adds GCC_EXEC_PREFIX, COLLECT_GCC and COLLECT_GCC_OPTIONS; no debugger
LD_LIBRARY_PATH enters the frontend. The driver resolves its relocated prefix
through the original vendor symlink target, which is recorded explicitly.

The frontend is deliberately killed at the stop. The driver's retained
“Killed signal terminated program gnat1” is expected capture termination,
not a successful full compilation. No Main translation, assembler, linker,
solver or complete proof run occurs.

The [fixed-root source projection](retained-native-expansion.md#fixed-root-read-projection-and-no-collection-before-main)
provides the transfer argument: fixed target, Standard definitions, builtin
setup and options determine the counted constructor requests before Main.
The source-dependent filenames, line maps, pointer arrays and intern backing
remain charged separately in full. The new witness supplies the same
conservative fixed allowances for this actual compiler: 39,257 GGC requests,
5,832 declaration identities and 2,277 fresh type requests. Its byte total is
an observed input result, **not an aggregate memory gate** or a universal bound
on variable allocations.

The earlier [gigi option analysis](retained-backend-gigi.md#gigi-delta-for-the-producers-data-representation-compilation)
shows zero extra gigi constructors for level-two representation output on the
same expanded tree. In the complete Ada-side option-use inventory, the only
additional uses outside switch/option declarations, driver control and repinfo
are the JSON output-name selector in `osint-c.adb:275` and setting
Back_Annotate_Rep_Info for an unchecked conversion whose source/target sizes
are not both statically known in `sem_ch13.adb:19843`. They do
not add a null-body expansion. The selected body still uses Generate_Object,
not Declarations_Only. The [four-byte empty representation JSON](retained-producer-null-global.md#data-representation-json)
and its consumer remain separate established terms. This closes the missing
fixed-prefix identity bridge; a complete alternate-invocation/backend join
still has to apply the source, argv and remaining phase predicates together.

## GPR2's indexed Main read projection

GNATprove calls `Tree.Load`, then `Tree.Update_Sources` without overriding its
default `Sources_Units` (`configuration.adb:1739–1755`,
`gpr2-project-tree.ads:381`). The public update delegates to Tree_Internal,
then Tree_Db.Refresh (`gpr2-project-tree.adb:1249–1273`,
`gpr2-tree_internal.adb:3909–3915`). For the generated project, Main has the
explicit naming exception `for Body ("Main") use "main.adb" at 1;`.

The complete selected Main discovery route is:

1. `Process_File` obtains the known unit name, body kind and positive index
   from the naming attribute (`update_sources_list.adb:768–811`).
2. `Source_Base.Create` copies only path, timestamp, language, kind, source
   directory index and flags; `Update_Unit` records that one known unit
   (`:912–935`, `gpr2-build-source_base.adb:15–38,95–100`). It does not read
   Main bytes or its file size.
3. The naming-convention parser branch is excluded, and the naming-exception
   parser is guarded by `not Units.Is_Indexed_List` (`:941–1086`). Main's
   indexed list makes that guard false.
4. The modified-source branch updates the timestamp but invokes the parser
   only without a naming exception (`:1200–1230`).
5. `View_Tables.Refresh` checks a separate only when `not S_Ref.Has_Index`;
   Main is indexed and a body (`gpr2-build-view_tables.adb:809–870`).
6. Tree_Db's remaining validation checks names, source presence, languages and
   library interfaces (`gpr2-build-tree_db.adb:860–1008`). `Check_Mains` looks
   up the fixed filename; `Check_Name_Validity` checks the stored name with
   path-only diagnostic coordinates (`gpr2-project-view.adb:1073–1144`,
   `gpr2-build-compilation_unit.adb:205–233`). Neither reads Main text.

Thus **GPR2 source discovery makes zero Main text/ALI parser calls** for this
indexed route. Main content, line count and byte length contribute no variable
parser/AST/source-buffer representation to that parent operation. The result
extends beyond the null token family to any authoritative Main bytes routed by
the same project. It does not assert those bytes are valid Silver or Ada.

Filesystem presence/timestamps, fixed runtime source discovery, project/config
parsing, process arguments and later report consumption retain their own
premises and accounting. This is a read projection for the selected operation,
not a claim that the complete GNATprove parent never reads generated data or
that its whole capacity is established. GPRbuild's child source reader is the
different [native/GPR descriptor route](retained-gpr-parent.md). No additional
libc/OS implementation audit or native GPR2 run was required.

Independent focused review replayed both offline checks and accepted the
compiler selection, forwarded-switch deltas, complete selected discovery route
and null-family prefix transfer. Its three source-citation corrections are
included. It did not claim a completed producer or whole-toolchain predicate.
