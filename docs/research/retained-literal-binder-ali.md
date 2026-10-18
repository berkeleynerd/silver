# Literal Main and fixed-output ALI consumers

2026-10-18, research for [#119](https://github.com/berkeleynerd/silver/issues/119).
The [offline callable](../evidence/retained-literal-binder-ali-20261018/README.md)
joins the accepted [literal Main ALI interface](retained-literal-ali.md) to the
retained output closure and the native binder/Gprbind scanners. It establishes
local parser-table, signature-map, reader-buffer and payload bounds, and exports
additive shared-name requirements. It does **not** establish complete name-pool,
graph, driver, binder or pipeline capacity. Independent review of this join is
pending; predecessor results retain their own accepted scopes.

The descriptor is the selected indexed no-Xref native output configuration,
including `-fsplit-wide-types`, x86-64 Linux, `Table_Factor=1`, a case-sensitive
filesystem, coherent regular-file contents and D timestamps/checksums, `-x`,
and no aliased ALI requests. P bounds complete raw/normalized/resolved path
spellings, as in the writer interface. Relevant installed behavior must match
the reviewed sources. This does not materialize the still-incomplete output
launch/options/search descriptor, establish physical resources or change any
current admission/library rule.

## Inputs and fixed census

`Context(ada_root)` verifies its pinned predecessor files before loading the
accepted ALI callable. That callable checks the actual complete Silver source,
source-position representations, serializer sources and selected specifications.
The consumer packet additionally verifies every member of the retained binder
source capsule and output artifact archive. No installed-input inventory is
remeasured and no native tool is executed. The exact source revisions remain
GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and GPR
`bdfb879cf03643ec8e48a09ce07b08c4a6ff0263`, with the predecessor's
source-correspondence premise rather than a new binary attestation.

The [output-closure argument](retained-linker-output-delta.md) supplies 82 fixed
ALIs plus Main. The new census excludes the historical `closure/main.ali`,
counts parser rows only before each first Xref header, but charges each entire
fixed file, including ignored Xref text, to its raw reader. It reproduces:

| Fixed contribution | Count |
| --- | ---: |
| ALI files / complete bytes / largest file | 82 / 655,467 / 58,770 |
| U records | 139 |
| W / Z records; no Y | 421 / 118 |
| A records / payload bytes / largest payload | 823 / 5,979 / 27 |
| D records / distinct dependency names | 1,007 / 163 |
| G construct / relation / attribute records | 1,271 / 6 / 82 |
| Distinct invocation signatures | 1,271 |
| L / N records | 1 / 7 |
| Largest consumed row before LF | 108 bytes |

The fixed D versions/timestamps agree for every repeated source name. There
are seven plain ASCII subunit D rows. These differ from the null closure's
six and must be charged if its nonparser name argument is later generalized.
All G constructs have ordinary kind Z. The six relations have kind `c`, extra
name `none`, and signatures already present among those constructs. They
connect Silver_IO's two output routines to the three Silver_Output_Libc
operations. The maximum fixed signature hash text is 93 bytes. No fixed
signature names Main in Standard. The seven notes have no explicit source
filename. There are no CUDA, No_Dependency, interrupt, dispatch-policy or
external-version records. The sole L group is `"-ldl"`.

## Native parser and signatures

Main contributes the accepted source-independent bounds: 41 unit/dependency
slots, at most 41² with records, ten A records with 110 payload bytes, at most
19 invocation constructs/signatures and 361 relations. The unit allowance
intentionally exceeds the actual Main U count. The producer deduplicates
entity pairs **before** appending invocation records; source call count C
does not multiply these limits. The accepted empty auxiliary-table closure
excludes Main L/N/No_Dependency/CUDA/interrupt/dispatch/version rows.

The native scanner creates at most one row at each corresponding record site
(`ali.adb:1741,1914–1915,2625,2944,3112,3136,3246`; invocation appends at
`:291–342,751–763`). Existing initialization adds the linker-option and note
sort dummies (`:639–657`). Combining the contributions gives:

| Native table | Demand bound | Allocated slot bound |
| --- | ---: | ---: |
| ALIs | 83 | 500 |
| Units | 180 | 100 → 300 |
| Withs | 2,220 | 5,000 |
| Args | 833 | 1,000 |
| Sdep | 1,048 | 5,000 |
| Source | 204 | 1,000 |
| Invocation_Constructs | 1,290 | 2,500 |
| Invocation_Signatures | 1,290 | 2,500 |
| Invocation_Relations | 367 | 2,500 |
| Linker_Options, with dummy | 2 | 200 |
| Notes, with dummy | 8 | 200 |
| No_Deps | 0 | 200 |

The callable checks the declarations in `ali.ads`, `ali.adb:128–150` and
`ali-util.ads:95–102`. It uses the actual `Table.Reallocate` growth,
`max(length*(100+increment)/100,length+10)`, with its wide intermediate
(`table.adb:168–207`). Every demand, increment, next slot and sentinel remains
below the signed Int and `0 .. 99,999,999` domains. All allocations except Units
stay at their fixed initial capacities, including the empty auxiliary and Xref
tables. The successful initial-allocation transfer is the existing
[generic consumer argument](retained-binder-capacity.md#ali-parser-and-signature-table-capacity);
zero demand never means zero initial allocation in these native tables.

Units retains the reviewed 40-field, at-most-320-byte component argument.
Its sole growth is the same 100-to-300-slot request as before: at most 96,000
new bytes and 128,000 bytes charging old and new together. This is an individual
representation calculation, not a process-memory promise.

`Sig_Map` interns signatures independently of how often relations mention
them (`ali.adb:751–763`). At most 1,290 distinct nodes require 500 buckets,
then 1,000 after insertion 751; the next threshold is 1,500. Rehash moves
existing data nodes and temporarily retains both bucket arrays
(`libgnat/g-dynhta.adb:1003–1099,1192–1297`). The reviewed 64-byte conservative
component bound gives `(1290+1500)*64 = 178,560` bytes for nodes plus
coexisting bucket heads, separately from the fixed map descriptor. Hash
collisions cannot add nodes or require another expansion.

`Hash` builds `scope__name__line_column[__locations]` in a 2,052-character
buffer (`ali.adb:580–610`). Main has no instantiation-location suffix. Its
accepted frontier has at most 36 name and 31 scope bytes, giving at most
`36+31+20+5=92` hash characters. Charging the existing 97-byte serialized
signature allowance safely covers this and the fixed maximum 93, including
the `To_String` temporary. Coordinate parsing accumulates a nonnegative Nat;
every decimal prefix is no larger than the final valid coordinate
(`:1345–1368`). This relies on the accepted writer/source-position contract,
not on a claim about arbitrary ALI input.

The 833 A strings allocate 6,089 payload bytes, maximum 27 each, separately
from their pointer table (`ali.adb:1880–1917`). These payload totals do not
remove allocation metadata or become a total-process heap bound.

## Native buffers and additive names

`ALI.Scan_ALI` marks each loaded ALI name; `Read_Withed_ALIs` checks that mark
and frees a raw buffer before descending (`ali.adb:1741–1744`,
`ali-util.adb:173–266`). The driver also frees its Main buffer before the
dependency walk (`gnatbind.adb:774–782,819`). Under the no-alias premise, there are at most 83 raw
reads and recursion depth at most 83. `Read_Library_Info_From_Full` allocates
file length plus one EOF byte (`osint.adb:2471–2613`). At P=512:

```text
Main file / reader including EOF <= 2,152,396 / 2,152,397 bytes
largest fixed reader including EOF = 58,771 bytes
peak native raw ALI buffer <= 2,152,397 bytes
cumulative native raw ALI allocation <= 2,152,396 + 655,467 + 83
                                     = 2,807,946 bytes
```

The cumulative figure is neither a peak-live total nor a RAM gate. Every
individual buffer/cursor/EOF extent fits signed Integer and LP64 arithmetic.
The selected `-x` and coherent D records retain the existing exclusion of
timestamp-triggered source-checksum rescanning. Main must refer to the same
coherent fixed dependencies; the fixed-only census alone does not prove an
arbitrary Main ALI's timestamps.

`Name_Find` adds at most one entry and payload-plus-NUL per call, and
`Name_Enter` always does so (`namet.adb:1138–1168,1190–1278`). The selected
case-sensitive `Get_File_Name` path uses one lookup. The parser contributions
are two events per U, three per W/Z or D, three per G construct, one per L
group and at most one per N. Each **G relation adds seven events**: its extra
name and three names for each of two signatures (`ali.adb:1526–1629`). Even
`none` lookups are charged; distinct signature nodes are bounded separately.

```text
fixed events <= 2*139 + 3*539 + 3*1007 + 3*1271 + 7*6 + 1 + 7 = 8,779
Main events  <= 2*41 + 3*1681 + 3*41 + 3*19 + 7*361 = 7,832
parser entry events <= 16,611
parser character slots <= 8,779*109 + 7,832*R
```

R is the accepted Main maximum row length **including LF**; replacing LF by
the stored name's NUL safely bounds each contribution. Quoted-file decoding
does not expand the row. The L group's decoded option text plus embedded NUL
also fits its fixed row; the additional stored NUL is charged by 109. At
P=512, R=1,184, so the character contribution is **10,229,999 slots**.
Each Main name payload is at most 1,183 bytes and each fixed payload at most
108; both fit stored Short and the 131,064-byte scratch. A strings and note
argument scratch are separately accounted by their row bounds.

These are **additive contracts**, not complete pools. If all nonparser
producers contribute `E_in,C_in`, the total demands are `E_in+16611` and
`C_in+10229999` at P=512. Apply the existing Name_Entries initial 6,000 and
Name_Chars initial 50,000 capacities, both with 100-percent growth, to those
totals. Preserve their actual origins/sentinels, index ranges, byte products
and old/new backing. The entry layout is 16 bytes. Every incoming payload
must also fit its representation. No numerical incoming values are supplied
here: startup, mapping-file, lookup/object-name, consistency/subunit probes
and output-name producers remain obligations of the caller. In particular,
the null closure's 8,282-entry complete-pool result is not reused.

## Gprbind's separate Main read

Gprbind reads only Main with `Read_Lines => "A"`; the scanner unconditionally
also reads U and the V header (`gprbind.adb:875–901`,
`gpr-ali.adb:673–677,715–769,897–936`). D/with rows are disabled and unknown G
rows are skipped without parsing coordinates. No fixed ALI recursion occurs.
The same complete Main reader envelope applies to its separate process:
2,152,397 bytes including EOF at P=512 (`gpr-osint.adb:459–553`).

Keeping the conservative 41-unit writer interface gives GPR table demands
`ALIs=1, Units<=41, Args=10, Withs=0, Sdep=0`. `GNAT.Table` delegates to the
lazy `GNAT.Dynamic_Tables`, so the backing bounds are respectively
`500,100,1000,0,0` slots (`gpr-ali.ads:200–205,356–361,414–440,492–497`,
`libgnat/g-table.ads:60–65`, `g-dyntab.adb:134–209,227–247`). No table grows
beyond its initial allocation. Actual Main has one unit; using 41 here avoids
needing a tighter exported writer interface and does not accept arbitrary
multi-unit ALI text as valid input.

GPR's ten A strings contain 110 payload bytes, maximum 24. Its filter's local
Argv copy is at most another 24 bytes (`gprbind.adb:912–929`); surviving
Compiler_Options/vector copies remain separate. The version conversion uses
its existing 32-byte scratch.

GPR has its own name implementation. Charge the complete Main ALI path,
`GNAT 16`, and at most two names per U:

```text
GPR name entry events <= 2 + 2*41 = 84
GPR name Value bytes <= P + 7 + 41*(70+P) = 24,381 at P=512
```

The nonpath bound 70 is read from the accepted serializer descriptor.
`Get_File_Name` does not perform a second casing lookup on this filesystem.
`GPR.Names` stores each Value in a discriminated record with integer metadata
and hash link, through an indefinite vector (`gpr-names.adb:44–78,395–473`).
Its Value has no extra NUL. The fixed hash has 65,536 slots and scratch has
1,000,000 bytes; the longest selected payload and C filename including NUL
fit. **Incoming names and vector/record backing remain explicit**: add these
events/value bytes to the actual incoming pool, charge metadata, capacity,
growth overlap and indices. These additions never assign earlier process
names zero or combine GPR.Names with native Namet.

## Graph and driver boundary

The callable exports native invocation table demands; these are not Bindo
graph-container allocations. The accepted output-delta source argument
preserves the fixed library elaboration closure/order: Main is ordinary,
fixed signatures have no incoming Main edge, and Main has only outgoing
output calls. The new census confirms all fixed constructs are ordinary.
This transfer does not justify copying the null graph's entire singleton
execution. Main's signature insertion can change IDs shared with fixed ALIs,
and Put versus Put_Line changes graph edges. Container capacities, buckets,
transient records and recursion for those graph inputs still need an actual
backing argument. Counts 1,290/367 bound the serialized construct/relation
input interface; they are not an invented graph object-size allowance.

The complete native nonparser name projection, GPR incoming name/vector
storage, the native parent **GPRbuild D/W reader** (distinct from the
Gprbind A/U-only parser above), mapping/search/response/argument lifetimes, graph backing, complete
output launch descriptor and remaining producer pipeline are open. The
result therefore keeps `whole_binder_or_parent_capacity_established=False`
and `whole_literal_pipeline_capacity_established=False`. No aggregate RAM
gate is introduced.

Fourteen offline cases exercise Hello, an 8,192-byte literal, 5,000 calls,
both operations/empty/escaped literals, case and CR comments, exact consumer
joins, inherited path/column failures and malformed sources. The three
required examples pass this local consumer component; the 5,000-call
linker's separate conservative failure is unchanged. P=976 passes and
P=977 fails the inherited writer envelope. Neither boundary changes actual
language membership or establishes a tool maximum.
