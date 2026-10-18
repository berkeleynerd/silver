# Null data-representation compiler composition

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The [offline composition](../evidence/retained-producer-datarep-null-20261018/README.md)
applies the actual-byte null compiler predicates to GNATprove's separate
data-representation invocation. Its twelve local predicates pass for the
retained fixture. This joins that compiler component; the remaining producer
and parent components still require their combined rule. It changes neither
production options nor language admission.

## Transfer between the two compiler invocations

The selected compiler is the bundled gnat1 identified in the
[producer-parent record](retained-producer-parent.md). It receives the same
Main bytes, indexed naming pragmas and one-unit mapping. Its System bytes
equal the native compiler's selected System. The source family remains the
complete null-token sequence with the existing case/trivia and physical-source
conditions. There is no application declaration, call, attribute or pragma
that can alter Standard or the selected backend type roots.

The invocation differences have these source effects:

| Difference | Selected null effect |
| --- | --- |
| `-S` | GCC stops after the compiler's assembly output; no assembler, binder or linker child is selected. gnat1 already emits assembly on the native object route. |
| `-gnatR2js` | Level-two JSON representation output. The body still selects Generate_Object. The complete gigi option-use inventory adds no constructor branch, and the Ada option-use inventory adds no null expansion. |
| `-gnatws -gnatis` | Disable Ada warnings/informational messages. The null family has none to retain; semantic analysis and checks remain enabled. |
| `-gnatx -Wno-free-nonheap-object` | Same selected xref and GCC access-warning exclusions as the native component. These are not proof-obligation switches. |
| Indexed `-o main~1.o -gnateI1` | Same one-unit selection and basename-length class. Under `-S`, `main~1.o` contains assembly text, not an ELF object. |

The [bundled fixed-prefix witness](retained-producer-parent.md#bundled-fixed-prefix-witness)
replaces the native executable's fixed setup evidence. Its declaration/type
identity streams and request counts match the conservative native allowances;
the replay checks this explicitly. The source-dependent metadata arrays, paths,
source buffers and intern backing remain charged in full. The observed byte
totals are not transferred as a universal bound or aggregate memory gate.

After that boundary, the expanded null body and the four fixed Standard roots
have the same read projection under the recorded source/tool premise. The
existing native graph, O0 pass, RTL, assembly-writer, callback and collector
arguments apply to those same selected operations. Representation level two
does not select annotation-only mode or the level-three symbolic-inline branch.
The independent native-runtime source facts are reused as source arguments,
not as an assertion that two distinct compiler binaries have identical bytes.
The known GGC request subtotal remains 40,098. Fixed ordinary startup uses the
new successful prefix and the same source-derived variable corrections.

The compiler-child descriptor has 23 entries including its executable,
established by the captured driver invocation and source reconstruction. The
existing conservative 24-entry/48-canonical-entry command envelope covers it.
Its longest fixed switch is 24 bytes. Mapping/configuration paths retain their
separate variable charge. The descriptor supplies a bound for all raw,
normalized and resolved paths; checking listed paths alone does not prove
that the parent has supplied a complete list.

## Late representation output

Null produces exactly `[` LF `]` LF, with no representation data entry, as
derived in the [writer/consumer analysis](retained-producer-null-global.md#data-representation-json).
This is after the backend call; `gnat1drv.adb:1541` unlocks Namet before
`List_Rep_Info` at line 1565. `Create_Repinfo_File` calls `Name_Find` on the
Main basename, and `Create_Auxiliary_File` appends `.json` and calls it again
(`osint-c.adb:153–191,270–280`).

The composition conservatively charges **two additional Name entries and
`2(P+1)` Name characters**, including NULs, although the first lookup normally
finds the existing basename. It recomputes the normal table growth/lock and
index predicates with those additional demands. The unprefixed output argument
has no directory separator, so the auxiliary filename is `main.adb.json` in
the compiler working directory. Its complete pathname is an explicit
descriptor role covered by P. Each output payload line has one byte; the
existing output buffer/column arithmetic suffices. This introduces no new
GCC tree, source range or backannotation expression.

The fixture at P=512 has the same 41,272-node and 16,384-byte aligned source
extent bounds as the native null fixture. Its Name-table demands include the
extra two entries and 1,026 characters. All twelve local predicates pass.
These are source/representation bounds, not actual allocation measurements.

## Checks and remaining conjunction

The wrapper verifies eight retained input identities, the separate prefix
event/identity allowances and the actual compiler hash, then reuses the same
source-checked arithmetic functions. The native helper's default behavior is
unchanged: its prior fixture remains byte-equal and all nine existing focused
checks pass. This work launches no compiler, prover or debugger.

The selected data-representation route has no assembler/linker phase to join.
The two gnat2why frontends, flow/report/SARIF consumers, GPR/GNATprove parents
and idle server remain separate conjuncts. A passing compiler-component result
is not a completed toolchain rule, source-language admission or completion of
#119. Broader source families still need their own semantic and backend joins.
