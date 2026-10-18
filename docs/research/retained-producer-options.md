# Null-family producer options and driver control files

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This closes the selected GNATprove option files, installed prover configuration
and idle-server caller dimensions for the complete 15-token null family with
permitted ASCII case/trivia. It continues the [global metadata analysis](retained-producer-null-global.md).
The [offline packet](../evidence/retained-producer-options-20261018/README.md)
pins source inputs and a copy of the installed configuration data. No compiler,
prover, capture, installation or Lean run was performed. Source behavior is
distinct from historical installed-binary/source attestation.

## The two phase-option files

The selected project has only Main, no imported project and no Prove attributes.
`Parse_Proof_Switches` inserts an `Ada` row, copies it to `default`, deletes
`Ada`, then inserts a row for each own unit's main source. The final map has
**two rows: `default` and `main.adb`**, not one
(`configuration.adb:1837–2008`). The source's spelling, comments and whitespace
do not enter this map. Each phase independently serializes that map.

`Pass_Extra_Options_To_Gnat2why` constructs a JSON root with eight common
fields, thirteen additional phase-2 fields, then `file_specific`. Each row has
five common fields, with `proof_warnings` and `why3_args` added in phase 2.
The row's `warning_status` contains all 63 `Misc_Warning_Kind` keys. Their
longest name is 36 bytes; the longest status image is the eleven-byte
`WS_DISABLED` (`gnat2why_opts-writing.adb:83–189`; `vc_kinds.adb:2164–2173`).

The fixed CLI selects level 2, the three available provers CVC5/Z3/Alt-Ergo,
100,000 steps, timeout zero and 1000 MiB memlimit. The unset counterexample
options retain level 2's enabled values; CE steps remain zero and the CE
timeout is therefore ten. Proof mode defaults to `per_check` and lazy mode
to true. There is no Proof_Dir attribute, manual prover, custom Why3 config,
memcached wrapper, limit, logging or debugging argument
(`configuration.adb:2343–2540,2629–2698,3071–3304`). Semaphores remain enabled.
The resulting phase-2 `why3_args` has **26 strings**, at most 213 payload
bytes in total with a ten-digit worker count, and a longest string of 23 bytes.
These are constructed even though null has no VC and launches no gnatwhy3.

Let P bound the object-directory string's bytes. The checker conservatively
charges each Boolean at five bytes and every warning status at eleven;
the envelopes do not assert those are their actual values. The only variable
JSON string is phase 2's `why3_dir`, charged at six emitted bytes per byte.

| Dimension | Phase 1 | Phase 2 |
| --- | ---: | ---: |
| Root fields | 9 | 22 |
| File-specific rows / fields per row | 2 / 5 | 2 / 7 |
| Warning-map fields, each independent map | 63 | 63 |
| Maximum container nesting | 4 | 4 |
| Largest JSON array / backing capacity | 0 / 0 | 26 / 32 |
| Compact JSON String B | 5710 | `6634+6P` |
| Option file including Text_IO closing LF | 5711 | `6635+6P` |

The filename is eight SHA1 hex bytes followed by `.tmp`, hence twelve bytes.
`Compose(Obj_Dir, File_Name)` has at most `P+13` bytes, and its `-gnates=`
argument at most `P+21` (`writing.adb:59–77`; `gnatprove.adb:182–197`).
Those generated names must satisfy the existing path/argument descriptor;
the JSON calculation does not imply a new allowable filesystem pathname size.

The [previous JSON storage derivation](retained-producer-null-storage.md)
applies to each independently constructed tree. Per-object live references
remain at most eight during construction/writing and 46 during parsing plus
the file-reader wrappers. The two warning objects and two argument arrays
are separately constructed; the repeated schemas do not create shared JSON
parents. Largest maps have 63 nodes, largest vectors have capacity 32, and
the parser's 32-slot initial stack covers four container levels plus sentinel.

For XString data, use `D=max(P,36)` in the writer and `D=max(2P,36)` in the
parser: capacities are respectively at most `D+4096` and
`floor(3D/2)+4096`. The existing unsigned32 multiplication/rounding, String
index and size_t conditions apply individually. A JSON.Write accumulator
has backing String length at most `B+floor(B/2)+2A`, plus header H. With the
selected conservative `A<=64,H<=64`, at P=4096 the phase-2 file is at most
31,211 bytes and each such allocation at most 47,007 bytes. Phase 1's file
is at most 5711 bytes and allocation 8757 bytes. Both fit GNATCOLL's existing
64 KiB small-file branch; this evaluation selects no new source/path limit.

`Gnat2Why_Opts.Reading.Load` retains the root, selects the matching source row,
copies its 26 argument strings into a String_Lists list in phase 2, and reads
63 warning statuses into a fixed enum-indexed array. Limit_Lines is empty.
No parsed argument is a source-trivia string. Parent edges, R/Ar locals and
the active Get/result temporaries fit a conservative sixteen live references
per JSON object after parsing; they do not retain a list of JSON aliases
(`gnat2why_opts-reading.adb:35–152`). Independent processes and phases have
independent counters. Their allocations are memory costs, not an aggregate
RAM admission predicate.

## Installed configuration and generated why3.conf

`Write_Why3_Conf_File` runs before the proof phase even when the source has no
VC. It reads the installation's fixed `gnatprove.conf`, not a source-derived
file, and writes every configured prover/editor entry. The retained selected
input is 3023 bytes and contains nine prover rows and one editor row, including
entries not selected by the proof CLI. Its complete schema inventory is:

| Dimension | Value |
| --- | ---: |
| Objects / arrays / string values | 11 / 30 / 99 |
| Object fields / array elements across the tree | 84 / 59 |
| Maximum fields per object / elements per array | 10 / 9 |
| Maximum string/key bytes | 23 |
| Maximum depth to scalar | 4 |

Each largest array has capacity at most sixteen. The raw input fits the
small-file reader; parser stacks/refcounts have the bounds above. After
parsing, `Config`, `Editors`, `Provers`, a single row temporary and the
`Args`/`Args_Add` temporaries introduce no recursively copied subtree. Sixteen
live references per object again overcharges the selected consumer locals.

The ordinary, non-benchmark, non-memcached `Build_Executable` returns the fixed
executable string. `Build_Prover_Command` appends its selected argument arrays
once. The longest command is **61 bytes**; its Unbounded_String allocation
is at most 283 bytes with the same A/H envelope. `Set_Key_Value` materializes
one line, never the whole output. Reconstructing all selected writer branches
gives **1946 bytes in 71 LF-terminated lines**, with a **76-byte maximum
payload line**, retained as `why3.conf.reconstructed`. Integer'Image contributes
its actual leading space. Text_IO closes after the last Put_Line, so no extra
LF is added (`gnatprove.adb:1022–1274`). The output filename has at most `P+10`
bytes. Every per-line column, String and list counter is therefore small and
source-trivia independent. The reconstruction is offline arithmetic, not a
captured native artifact. Null's absent gnatwhy3 launch means the OCaml
configuration/driver loader does not consume this file in this path.

## Idle server and semaphore caller

Zero gnatwhy3/solver launches do **not** imply zero server launches.
`Flow_Analysis_And_Proof` starts the standalone C `why3server` for GPM_All,
then stops it after Call_Gprbuild. The selected caller supplies four arguments:
`-j`, J's decimal image, `--socket`, and the socket pathname. It neither
enables `--logging` nor opens a readiness connection
(`gnatprove.adb:623–675,940–980`). Null produces no client request.

Silver selects `-j0`, so GNATprove sets J from the host's Number_Of_CPUs
(`configuration.adb:2057–2068`). The server's signed32 additions and backlog
multiplication require **`1<=J<=floor(INT_MAX/2)`** in the selected host
descriptor. These are worker-configuration conditions, not source-length
or total-memory gates. The independent
[idle-server source analysis](retained-idle-why3server-capacity.md) gives the
client/process lists, fixed request queue, poll allocation and zero-growth
invariant, including each individual allocation's size_t requirement.

The socket basename is `why3server_` + positive PID decimal + `.sock`: at
most 26 bytes for a signed32 PID. Linux selects a writable TMPDIR, else `/tmp`,
else Artifact_Dir. A directory of D bytes gives at most `D+27` pathname bytes;
the C server splits dirname/basename before bind, so the basename easily
fits its 107-byte payload limit (`configuration.adb:436–474,2934–2948`).
The semaphore uses Ada.Directories.Base_Name, stripping `.sock`, and has at
most 21 bytes; its C copy including NUL has at most 22. Its initial count is
`max(1,floor(J/3))`, converted from Natural to unsigned, and it is never
waited/released on the zero-client path (`configuration.ads:353–354`;
`gnatprove.adb:965–978`; `named_semaphores.adb:62–65`). The platform must
support that initial count under its SEM_VALUE_MAX. No source-dependent
counter can increase it.

The existing [trusted boundary](../trusted-boundary.md#trusted-computing-base)
already assumes functioning OS/libc filesystem, process and resource-allocation
services, stable configuration and sufficient resources. `getcwd`, spawn,
socket/pipe creation, named semaphore creation/unlink and environment updates
terminate at that interface; this work does not recursively re-prove libc or
the kernel. Explicit finite C/Ada arithmetic in the selected caller/server is
still accounted for. Socket-name collisions, service failure and resource
exhaustion remain infrastructure assumptions rather than language membership.

## Whole-null composition still required

This packet closes these selected control-file/caller dimensions. The next
source-dependent finite-width join is the generic producer ALI file: phase-1
non-GG rows plus QQ/GG, writer append-before-flush behavior, phase-2 full-line
reads and Scan_ALI table/index counts. The native ALI algebra is reusable, but
its expanded native unit/record descriptor is not automatically the producer's
`-gnatc` descriptor. GPR2/GPRbuild project/configuration orchestration also
still needs its actual per-container/cardinality composition. Existing OS
assumptions cover system services, not these unexamined user-space counters.
The final conjunction must join those results with the frontend, producer,
native alternative invocation and reader results for the same complete null
family, then receive independent review. #119 remains open; current admission
and the 4096-byte source bound remain unchanged.
