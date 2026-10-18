# Literal-output native parent: local DW reader interface

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The [offline callable](../evidence/retained-literal-gpr-parent-20261018/README.md)
joins the accepted [Main ALI writer](retained-literal-ali.md) and retained
[fixed output ALIs](retained-linker-output-delta.md) to the native parent's
`GPRbuild.Compile.Phase_2_ALI` reader. It bounds that consumer's tables, raw
buffers, scratch and additive persistent-name contribution under the explicit
fresh-output job and child interfaces below. Complete output launch/frontend
correspondence, shared name-vector backing, source/project/driver storage and
whole native-parent capacity remain open. This is distinct from
[Gprbind's A/U-only reader](retained-literal-binder-ali.md).

The selected sources remain GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`
and GPRbuild `bdfb879cf03643ec8e48a09ce07b08c4a6ff0263`. The callable verifies
the accepted predecessor pins, all 151 binder source-capsule members, the fixed
output artifact archive, 29 retained split-option sources, and three additional
complete sources: GPRbuild Main, Ada's switch parser and `System.Rident`.
The inherited relevant-installed-behavior premise still applies. No compiler,
prover, binder, native GPR or test-suite execution belongs to this packet.

## Exact consumer and three-call frontier

The descriptor interface is one ordinary non-library executable project/tree
and Ada Main, no imports/extensions/aggregates/Roots, no runtime sources in the
project's source inventory, and fixed Silver source/specification bytes. Main
alone has indexed naming. Native object, ALI and binder-exchange directories
start empty. It selects the ordinary local compile pass with object checks,
without unique/all-source compilation, GNU jobserver, distributed compilation,
keep-going/check-switches/no-split modes or external requeue/injection. These
are explicit descriptor premises; this packet does not claim the complete
output launcher has already materialized them.

`Compute_Compilation_Phases` sets `Closure_Needed` when there is a Main
(`gpr_build_util.adb:2446–2508`). Main initializes the queue once and adds Main
and project sources (`gprbuild-main.adb:205–209,238–254,2744–2765`). In this
ordinary executable project, `Insert_Project_Sources` does not enqueue every
Ada body: its `Unit_Based` condition is false when closure is needed, and there
is no library-project exception (`gpr_build_util.adb:2185–2313`). Thus extra
unused `Silver_Arguments`/`Silver_Runtime` files in the retained indexed
inventory do not become fresh compilation jobs.

The accepted literal Main closure reaches Silver_IO. Its retained W/Z rows
reach `silver_output_libc%s`, and the latter has only runtime W/Z targets.
`Insert_Withed_Sources_For` looks up each source in the **project source
htable**, checks its ALI basename, redirects a package spec to its body when
present, and queues only a matching compilable project source
(`gpr_build_util.adb:2328–2406`). Runtime ALIs are not recursively compiled by
this parent. Hence the possible jobs are Main, the Silver_IO body and the
Silver_Output_Libc spec, each at most once. Silver_IO's separate spec is
represented by the body's two-U ALI rather than another job.

This count is stable under repeated W references. `Insert_No_Roots` rejects
an already queued Source_Id and also deduplicates equal source-path/index and
project-path triples (`gpr_build_util.adb:1790–1851`). Its default `Repeat` is
false; these calls do not request a repeat or clear `In_The_Queue` on dequeue.
`Queue.Next` marks the entry processed and advances it (`:1713–1763`). With the
jobserver disabled, `Start_Compile_If_Possible` calls it after processing the
source (`gprbuild-compile.adb:3608–3637`). `Await_Compile` consumes each ordinary
Ada completion, decrements the outstanding count and returns; its second-stage
dependency subprocess is conditional on **Makefile** dependency kind, excluded
for Ada ALI dependencies (`:243–474`). There is no selected retry/requeue path.
These source facts bound successful reader calls; child success and normal
wait completion remain separate interfaces.

Fresh missing object/dependency files cause `Need_To_Compile` to return before
`Process_ALI_Deps` (`gpr-util.adb:4360–4385,5635,5700–5738`). Therefore its
incremental APDW scans and dependency-source recursion are absent. Every
successful fresh job reaches `Phase_2_ALI` once, which reads its ALI with
`Read_Lines => "DW"` (`gprbuild-compile.adb:2011–2065,3680–3700`). Since Main
needs closure, and discovered jobs have `Closure => True`, it passes the
already parsed ALI to `Record_ALI_For` (`:2143–2150`). That routine queues the
withed sources and calls `ALI.Initialize_ALI`; the W-only raw reread occurs
only when its ALI parameter is `No_ALI_Id` (`:1600–1633`). It therefore adds
**zero** W-only reads to this fresh three-job interface.

Standalone-library/interface-closure scans and existing-binder up-to-date W
scans have separate callers (`gprbuild-post_compile.adb:480–500,897–902,
4340–4354`). The ordinary non-library project and fresh exchange directory
exclude them here. This is a source-backed boundary for the named DW consumer,
not a claim that every possible parent ALI caller has the same schedule.

## Read policy, option rows and fixed-child frontier

GPR's scanner always enables U and then enables the requested letters
(`gpr-ali.adb:673–677`). Its single `Ignore ('W')` branch controls W, Y and Z
(`:1165–1181`); DW therefore reads all three. A is disabled, so no argument
String or Args table entry is allocated. G is absent from `Known_ALI_Lines`
and is skipped without reading invocation signatures or coordinate numbers
(`:40–61,275–292`). L/N/external-version and unrequested policy/restriction
records are skipped. Parsing ends at the first X header, while the complete
file is still read into the raw buffer (`:1260–1320,1425–1465`). The native
binder's signature map/hash bounds are consequently unnecessary for this
separate consumer. The version conversion has its fixed 32-byte local scratch.

The retained two fixed job ALIs have six A rows each: `-gnatA`, `-gnat2022`,
`-gnata`, `-gnato`, `-mtune=generic`, `-march=x86-64`. A selected regeneration
may additionally store each of `-Wno-free-nonheap-object`, `-gnatx` and
`-fsplit-wide-types` once. `-gnateI1` is limited to Main. This gives **nine A
rows, 102 payload bytes and 129 bytes including `A ` and LF** for each fixed
job; it does not infer the inventory merely from the lack of indexing.
GPR's `Add_Multi_Unit_Switches` adds its configured index switch only when
`Id.Index /= 0` (`gprbuild-compile.adb:2759–2789`); the fixed-unit index-zero
premise therefore excludes that insertion route as well as an explicit index
option in the allowed fixed-child switch inventory.

This calculation uses the writer's actual storage boundary: backend switches
are stored unless explicitly filtered (`back_end.adb:240–289`), front-end
`-gnat` switches store the processed spelling unless their branch disables
storage (`switch-c.adb:150–158,299,1692–1695`), and the serializer emits one A
row per `Compilation_Switches` entry (`lib-writ.adb:1212–1217`). Mapping and
ordinary include-path handling are separate from the stored-switch rows;
arbitrary additional or duplicate stored options are outside this interface.
The later launcher must establish this allowed stored-switch inventory.
The accepted [split-option argument](retained-split-options.md) establishes
its **+21 A bytes** and unchanged source/checksum/U/W/D/invocation data.
The no-Xref selector sets `Xref_Active` false; the writer's Xref output branch
is after the ordinary records (`switch-c.adb:1445–1450`,
`lib-writ.adb:1613–1620`). Removing that suffix cannot enlarge the raw file.

For a regenerated fixed ALI the required incoming frontend contract is precise:
preserve the retained version/U/W/Y/Z/D names and row-width envelopes, fixed
timestamp/checksum/metadata field widths, and the retained complete **non-A**
byte envelope except optional Xref deletion, while satisfying the selected
nine-row A envelope. Fixed source bytes, paths, selected runtime/specifications
and option separation must realize that contract. The complete output
descriptor and general fixed-child regeneration correspondence are not yet
established. In particular a future changed source naming/configuration that
changes U/D spellings or other metadata cannot silently use these lengths.
That is the remaining producer/descriptor frontier; this reader packet does
not relabel the historical fixed artifacts as new exact-option executions.

## Tables and raw buffers

The fixed job census, before X, is:

| Job ALI | U | W/Y/Z | D | Complete retained bytes | Complete non-A bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Silver_IO | 2 | 7 | 30 | 4,443 | 4,371 |
| Silver_Output_Libc | 1 | 6 | 28 | 2,933 | 2,861 |

Main contributes the accepted conservative 41 U/dependency slots and at most
41² with rows, independent of literal lengths and call counts. Even retaining
all three scans without an intervening reset gives:

| GPR table | Largest individual scan | Cumulative appends | Initial allocated slots |
| --- | ---: | ---: | ---: |
| ALIs | 1 | 3 | 500 |
| Units | 41 | 44 | 100 |
| Withs | 1,681 | 1,694 | 5,000 |
| Sdep | 41 | 99 | 5,000 |
| Args | 0 | 0 | 0 |

Actual successful scans reset ALIs/Units/Withs/Sdep after queue insertion
(`gpr-ali.adb:67–110`). `GNAT.Table` delegates to `GNAT.Dynamic_Tables`, whose
`Init` releases an allocated array and restores the empty instance; empty
tables allocate on first growth (`g-table.adb:127–130`,
`g-dyntab.adb:134–209,227–247`). Thus each nonempty scan may make another
initial request. These are not cumulative retained table populations, and the
lazy zero-demand Args table has no backing request. The selected parent never
enables A; its absence from the reset list does not create live argument rows.

No table grows past its initial capacity. The packet checks IDs, next slots,
the actual growth formula's spare-slot rules and each individual allocation.
Conservative component bounds are 8,192/320/80/128 bytes for ALIs/Units/Withs/
Sdep. The records have 25/33/10/8 fields; all scalar fields fit an eight-byte
allowance on the selected ordinary ABI, except separately charged arrays.
ALIs contains five restriction arrays: charging every element eight bytes and
each array the complete 101-member `Restriction_Id` enum gives
`24*8 + 5*101*8 = 4,232 <= 8,192`. Units' fixed eight-character Version fits
its allowance; Sdep's 14-character timestamp fits the 128-byte component bound.
The largest initial request is the conservative 4,096,000-byte ALIs backing.
These requests fit the checked bit-size and LP64 pointer-difference domains;
their sum is not an aggregate RAM gate.

`Read_Library_Info_From_Full` allocates complete file length plus one EOF byte
and writes the pathname's C NUL into shared scratch (`gpr-osint.adb:459–553`).
The fixed raw envelopes include **129 replacement A bytes**, rather than
reusing the historical 72-byte A contribution:

```text
Silver_IO reader            <= 4,371 + 129 + 1 = 4,501 bytes
Silver_Output_Libc reader   <= 2,861 + 129 + 1 = 2,991 bytes
Main reader at P=512        <= 2,152,397 bytes
local reader peak          <= 2,152,397 bytes
cumulative local allocation <= 2,159,889 bytes.
```

Phase_2_ALI frees its raw buffer before returning, and its use of an existing
ALI in `Record_ALI_For` does not load another. `Insert_Withed_Sources_For`
queues jobs rather than recursively parsing their ALIs. Therefore only one
buffer from these calls is live at a time, even when child compilations use
multiple slots. Cursors and the physical LF counter are bounded by complete
reader length plus one. D checksums use modular Word arithmetic; fixed D
reference-line integers fit Nat, and Main retains its accepted writer and
source-coordinate contract. Ignoring G numbers removes their numerical parser
obligation only for this consumer, not their bytes from the raw-reader bound.

## Persistent GPR.Names interface

ALI resets erase the `Int_Info` marks but do **not** delete names. GPR.Names
uses a shared indefinite vector of discriminated records with embedded Value,
hash link and integer metadata (`gpr-names.adb:44–78,395–473`). Stored values
have no extra NUL. The fixed static hash has 65,536 slots and scratch has
1,000,000 characters. Hash collisions add probes, not entries.

With case-sensitive filenames, the parser makes at most one name event for
the normalized version, two per U, three per W/Y/Z and three per D. The D
allowance includes a possible subunit/unit lookup and `Name_Enter` for a
reference file (`gpr-ali.adb:1310–1420`). Quoted decoding does not expand its
row. Its paths are already passed as interned `Dep_Path`/F names; their earlier
interning belongs to the incoming/nonparser contract.

```text
Main events <= 1 + 2*41 + 3*41² + 3*41 = 5,249
fixed events <= (1+2*2+3*7+3*30) + (1+2*1+3*6+3*28) = 221
total parser entry events <= 5,470
```

The maximum selected V/U/W/Y/Z/D row in either fixed file is 70 bytes before
LF. At P=512, Main's accepted maximum row is 1,183 bytes before LF. A safe
additive value-byte bound is therefore **5,249*1,183 + 221*70 = 6,225,037**.
Both payload maxima and each full ALI path plus C NUL fit the shared scratch.
These are persistent contributions across all three calls, not per-scan
values to be discarded at initialization.

The exported contract requires all incoming/nonparser producers to add their
entry events and value bytes before establishing Name_Id/Count_Type limits,
discriminated-entry metadata/padding, indefinite-vector capacities and old/new
backing overlap. Their own payload lengths must also fit scratch. This packet
does not price the complete vector or assume an initially empty name pool.

## Verification and scope

Sixteen offline checks passed: actual Hello World plus large literal/repeated
call/case/comment forms, the existing P=976/977 boundary, source-column
overflow and invalid-source rejection, and fixed-reader A/G/Xref policy checks.
Adding the split A row increases the raw charge by 21 while leaving the DW
projection unchanged; a synthetic huge ignored G coordinate creates no
signature requirement. Those helper checks supplement the pinned source
interpretation; they are not native parser acceptance tests or proof by samples.

`selected_parent_DW_reader_local_interface_fits` is true at P=512 under the
stated incoming interfaces. The callable deliberately keeps complete
fixed-child regeneration correspondence, launch materialization, shared name
backing, output parent source buffers, whole parent capacity and whole literal
pipeline capacity false. The earlier null parent's **three physical source
buffers and fixed whole-context witness do not transfer**: additional Silver
source loading, project/name/phase routes, queues, options/search/driver and
pool lifetimes still need their own bounds. Physical resources remain trusted;
capacity stays source/configuration-decidable and independent of prover
success. No Oracle, language, tool invocation or admission rule changes.
