# Null-family binder source, object and lifetime transfer

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This component derives the binder-generated source family for the indexed null
program and transfers its fixed object shape under the selected installation,
options and filename descriptor. The source argument preserves code, locations
and semantic requests while allowing bounded trailing path comments and an
injective filename substitution. The complete
[capacity rule](retained-tool-capacity.md) remains unfinished: ordinary process
and assembler interfaces, whole GPR storage and final composition remain separate.

The [portable evidence](../evidence/retained-binder-capacity-20261018/README.md)
contains complete reviewed source files, the selected ALI closure and existing
generated sources/objects. The extension includes one controlled binder-only
capture, one configuration-only capture, one proposed-options binder
compiler/assembler execution, a Gprbind initialization diagnostic and one
complete binder lifetime counter capture, described below. No link, prover run, Lean check
or full validation was performed for this component. Existing successful
executions are reused only with their original identities and scope.

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
records that unindexed descriptor separately. The three historical indexed
witnesses use baseline options. The new controlled compiler capture uses the
exact proposed indexed command, including that warning option. This matters:
`pass_waccess::gate` selects a whole analysis pass using warning controls
(`gimple-ssa-warn-access.cc:2267–2275`); execution changes analysis state,
statement UIDs and diagnostic suppression (`:4857–4905`). No assumption that
the option changes only diagnostic text is needed for the new witness.

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
conversion and dot-to-double-underscore encoding. Every exported version value
also equals its corresponding retained U-record version. This reconciles selection
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

### Specialization to one installed workspace template

The existing Silver workspace construction permits a stronger descriptor
without choosing a new path cap. `Create_Workspace` appends exactly six checked
alphanumeric characters to its installed `program-` prefix
(`silver_platform.adb:194–233`); `silver.adb:91–101` derives the paths from
that same directory. Fix the installation and normalized root spelling, retain
the exact generated project, and exclude a symlink or environment change that
alters the selected source/object directories. Bootstrap and rebuild after
moving the installation remains the existing platform policy.

Let `K` be the byte length of the installed artifact root before `/program-`,
and `R` the complete fixed runtime `adalib/` path length. Then the generated
comment operands have exact lengths, rather than merely an upper bound:

```text
workspace leaf = "/program-" + six characters = 15 bytes
O = K + 28
D1 = D2 = K + 20
body_bytes = 7,551 + 3K + R
```

The retained installation gives **8,014 body bytes**. Together with its fixed
spec, `q(spec)+q(body) = 24,576`; the conservative runtime/virtual source union
is then **20,525,056 positions**. All generated-source token byte offsets now
remain fixed too: the only changed comment bytes are same-width workspace
suffixes. The replay checker verifies this exact noncomment byte projection,
not only line/column agreement. The earlier `P` formula remains the broader
source-range result; it does not make arbitrary installation paths equivalent.

Gprbind constructs `b__main~1.adb` as a relative basename and passes that exact
name to the compiler, with `-o b__main~1.o`
(`gprbind.adb:498–503,928–938`). Its fixed leading/trailing options remain part
of the descriptor. The binder ALI's D records name the generated spec/body
and four fixed installed specs: `system.ads`, `s-parame.ads`, `s-secsta.ads`
and `s-stoele.ads`. The packet retains those actual installed sources. This
dependency reconciliation does not replace the separate virtual-source bound.

The following source consumers clarify what this specialization preserves:

| Consumer | Source-derived transfer |
| --- | --- |
| Full source path | `sinput-l.adb:510–515` keeps both the basename and full path. `back_end.adb:126–131` passes full debug names to Gigi; `trans.cc:282–292,339–365` interns them and builds line maps even when debug output is disabled. Their distinctness, lengths and storage remain charged; changing the six-character suffix is not permission to erase these identifiers. |
| Runtime raise-location text | `utils2.cc:2018–2054` uses `Debug_Source_Name`, the fixed source basename, and logical line/column. Its fallback strips a directory from the location filename. These strings do not acquire the varying full workspace path. |
| External/generated names | `exp_dbug.adb:764–909` derives external names from explicit interface strings or qualified entity names. `tbuild.adb:61–99,719–726` derives temporary names from unit serial counters and body/spec suffixes, not source offsets or workspace paths. Fixed tokens and source offsets preserve their selected inputs. |
| GCC special-function names | Gigi assigns `first_global_object_name` from the unit's external name before translation (`trans.cc:367–370`). `tree.cc:9114–9164` therefore takes the fixed-name branch, bypassing its filename/random-seed fallback. |
| Assembler file name | `varasm.cc:8160–8174,8645–8667` emits the main input basename after removing directories. With the fixed relative compiler input and no remapping option, that name is `b__main~1.adb`. |
| Location-sensitive code generation | File order, source line counts and code coordinates stay fixed. The full-name substitution preserves file equality classes, including the `filename_cmp` fallback used by `cfgrtl.cc:784–800`; the O0 location-nop test therefore receives equivalent locations. |

These joins remove particular path/location objections to reusing the object
witness. The filename-interning step can also be separated from the remaining
compiler execution. Gigi calls `get_identifier` for each loaded full filename
(`trans.cc:282–292`); the selected host canonicalization returns that spelling
unchanged (`adaint.c:3158–3161`). `stringpool.cc:100–126` enters the shared identifier hash;
`libcpp/symtab.cc:99–175` probes existing entries without allocating, then
allocates exactly one identifier and `length+1` characters for a new spelling.
Its 16,384 initial slots grow at three-quarter occupancy by doubling; rehashing
allocates only the new slot array (`stringpool.cc:48–60`,
`libcpp/symtab.cc:182–219`). Different filename hashes can change probe counts
and bucket layout, but not insertion payload sizes or the growth threshold.

At this interface, the varying names are the generated spec/body full paths.
Each is `K+33` bytes; for the retained `K=94`, together they charge at most
**two identifiers and 256 character bytes**, including NULs. They cannot
coincide with each other, an installed runtime path or an Ada symbol: their
basenames differ, the workspace and runtime roots are distinct, and their
absolute path syntax is outside the symbol alphabet. The fixed runtime and
virtual-file names retain their existing contribution. This is an additive
filename contribution, not a bound assigning the other identifiers zero.

The substitution must be injective across **all** existing identifier strings,
including full filenames and the relative translation-unit name. At the
selected paths this holds: both changed names remain absolute workspace paths,
are distinct from the installed runtime and virtual names, and cannot equal
the relative `b__main~1.adb` name or semantic naming alphabet. File resolution
still selects the same source bytes in the same order. The controlled compiler
capture additionally uses a same-length padded scratch path satisfying these
conditions, so its transfer to the generated workspace family uses this same
argument, not a claim that the scratch prefix is the production prefix.

Changing hash layout has no semantic enumeration route in the selected Ada
frontend. Its identifier hook allocates exactly `tree_identifier`, with no
C/C++ language-specific payload (`misc.cc:1405–1406`, `tree-core.h:1620–1623`).
`make_node` clears that node (`tree.cc:1326–1340`), and Gigi's filename consumer
returns only `IDENTIFIER_POINTER` (`trans.cc:282–292`): these disjoint filename
identifiers acquire no declaration/type links. The string pool's remaining
traversals are statistics, GC marking/purging and PCH support
(`stringpool.cc:142–196` and its PCH routines); statistics/PCH are unselected.
Ada does not use a bucket-order traversal to emit declarations or instructions.

GC marking is set membership: marking an already marked object returns
immediately, and first marking sets one bit (`ggc-page.cc:1645–1675`).
`ggc_mark_roots` then clears caches and conditionally purges unreferenced
identifiers (`ggc-common.cc:93–119`); plugins are excluded. A different visit
order through these filename leaves cannot change the reachable semantic
graph or purge a live identifier. Equality of reachable graphs is sufficient
here; equality of physical addresses, hash buckets or allocation traces is
not claimed. In particular `gt_value_expr_mark` owns a hash set and a growing
work vector (`tree.cc:217–269`). Their scratch is **not zero**, and a transient
capacity argument must bound the relevant graph union and coexistence rather
than assuming one observed traversal order or an empty binder value-expression
table.

The source-file sequence, entry/exit reasons and line/column requests remain
fixed. `linemap_add` assigns numeric locations from the existing location and
range state and stores the filename separately (`libcpp/line-map.cc:571–671`).
The filename equality checks are preserved by the injective substitution.
Together with the consumer table above, this leaves the selected semantic
declaration/CFG/RTL requests and their emission order unchanged. The fixed
relative `.file` basename, symbol names, location-sensitive nop decisions and
target/options therefore transfer the emitted object **shape**: section
payloads and alignments, symbol/relocation inventory and name lengths. The
proposed-options compiler witness below supplies that fixed successful shape.
No debug/PCH/LTO/plugin path or source-path-dependent naming branch is enabled.

This closes the filename/GC objection to **semantic request and object-shape
transfer**. It does not establish the complete frontend/backend transient
allocation projection. Source buffers, ordinary compiler tables, GC marker
scratch and process storage still need their separate capacity composition.

The specialization does not extend to all GPR temporary paths. GPR creates
`<normalized-temp-root>/GPR.<pid>/GNAT-TEMP-<six digits>.TMP`
(`gpr-tempdir.adb:68–80,103–177`, `s-os_lib.adb:77,780–905`). PID decimal width
varies. With a positive signed-32-bit Linux PID, these paths are at most
`T_root + 36` bytes, derived from the template and ten-digit PID width. The
mapping/response filename does not occur in the generated binder source or
the binder compiler's arguments. It remains a bounded driver/binder input,
with fixed normalized temp-root spelling and ordinary accessible temporary
storage as configuration premises.

### Generation scratch and output buffers

`Bindgen.Statement_Buffer` has 1,000 characters (`bindgen.adb:46–50`). Its
only index assignments are the five append increments in `Set_Boolean`,
`Set_Char`, `Set_Int` and `Set_String`, and the zero reset after
`Write_Statement_Buffer` (`:3435–3480,3579–3591,3644–3654`).
`Set_String_Replace` overwrites an equal-length suffix; it does not shrink
the occupied interval. Every selected append sequence reaches its flush,
and its strings, names, Boolean spellings and decimal digits contain no LF.
Therefore its occupancy is monotone between flushes and cannot exceed the
length of the line eventually emitted. The fixed generation route also
preserves `Set_Int`'s arguments, none of which is `Int'First`; its negative
conversion does not introduce a new arithmetic failure for this family.

The four path-bearing comments bypass this buffer: `Gen_Object_Files_Options`
calls `WBI` directly for the object path and `-L` options
(`bindgen.adb:2259–2351`). The already-derived generated source family thus
gives **139 characters** as a conservative bound on every buffered line and
every intermediate occupancy, including the fixed buffered comments. The
checker computes this value after excluding only those four direct-write
lines and checks the index-update and replacement sites. This is a transfer
from the source read projection plus a buffer invariant, not a claim that
the longest line in a few executions bounds an otherwise unknown generator.

`WBI` renames `Write_Binder_Info`, which renames `Osint.Write_Info`.
`Write_Info` writes its String argument and one LF directly through
`Write_With_Check` (`osint-b.adb:193`, `osint.adb:3255–3260,3295–3300`).
These routines do not accumulate a generated file in memory. The direct
path-line concatenations have at most `max(O+8,D1+10,D2+10,R+10)` characters,
**191** for this installation; their lengths and native write counts fit
`Integer`. The file/source-buffer representation remains charged by the
earlier generated-size formula.

The separate `-O=` object list uses `Output.Write_Str`/`Write_Eol`, after
`Set_List_File` selects its descriptor (`osint-b.adb:177–187`). Its single
selected line is the Main object path: **122 characters plus LF**.
`Output` has a **32,767-character** fixed buffer
(`output.adb:28,423–463,559–564`, `output.ads:166`,
`hostparm.ads:43–44`, `types.ads:181`). This selected line stays below its
flush boundary; no whole object-list String is accumulated. Optional
verbose/closure/listing routes retain their exclusion in the descriptor.

The generated interrupt-state and priority-dispatch tables have 100 character
slots each (`bindgen.adb:145–165`). The closure has no I or S records;
`Set_IS_Pragma_Table` and `Set_PSD_Pragma_Table` traverse empty input ranges
and append nothing (`:3486–3511,3552–3573`). No bind-environment entries are
selected. These initial representations remain charged even though they
contain no generated settings. This closes these generation/output buffers,
not the generated-source compiler or the complete GPR driver allocation.

## ALI parser and signature-table capacity

This extension bounds the native binder's ALI parser tables, signature map and
contribution to the shared name pools. The following section reduces the graph
core to its fixed successful witness. The composition below also closes the
selected binder's `Namet` pools; argument/search-directory storage remains separate.
All input counts below are computed before the first Xref section, under the
fixed null ALI contract and the exact retained runtime closure.

`ALI.Scan_ALI` marks an ALI's name when creating its entry (`ali.adb:1741–1744`).
`Read_Withed_ALIs` loads a dependency only if that name is unmarked, frees its
raw buffer before descending, and then recurses (`ali-util.adb:173–266`).
Thus each of the 61 distinct ALI names is scanned once. Recursion depth is at
most 61; neither author trivia nor a repeated with edge multiplies that count.
The descriptor excludes aliased requests that would evade the name mark.

There are 900 `G c` records, all regular kind `Z`, 61 `G a e` records, and no
`G r` records. All 900 signatures are distinct. No signature has spec/body
elaboration kind, so this invocation graph has no elaboration roots
(`bindo-graphs.adb:5334–5349`). This does not eliminate the separate library
graph or its ordinary elaboration-order work.

| Parser table | Entry demand | Initial/final slot capacity |
| --- | ---: | ---: |
| ALIs | 61 | 500 |
| Units | 101 | 100 → 300 |
| Withs (`W`/`Z`; no `Y`) | 348 | 5,000 |
| Args, indexed baseline | 617 | 1,000 |
| Args, indexed combined proposal | 619 | 1,000 |
| Source dependencies | 594 | 5,000 |
| Distinct source files | 124 | 1,000 |
| Invocation constructs | 900 | 2,500 |
| Invocation signatures | 900 | 2,500 |
| Invocation relations | 0 | 2,500 |
| Linker options, including sort dummy | 2 | 200 |
| Notes, including sort dummy | 8 | 200 |
| No-dependence entries | 0 | 200 |

The table instantiations are in `ali.ads`, `ali.adb:128–150` and
`ali-util.ads:95–102`. The parser creates one entry at its selected record
site; it does not multiply records by line/column values. `Initialize_ALI`
adds the two sort dummies (`ali.adb:639–657`). The one linker option is one
contiguous option group. There are no CUDA, interrupt-state, dispatch-policy
or external-version-reference records. Xref entity/reference/section tables
remain empty, with their fixed initial allocations retained; ignoring Xrefs
does not erase that initialization.

With selected `Table_Factor = 1`, `Table.Reallocate` uses
`max(length*(100+increment)/100, length+10)` in a wide intermediate
(`table.adb:168–207`). The Units table's 200 percent increment therefore
requires 300 slots, not 200. Its `Max+1`, sentinel and `Last+1` operations
are far below both signed `Int` and the relevant `0 .. 99,999,999` ID types.
All other listed tables remain within their initial capacities. The fixed
initial allocations happen at package initialization (`table.adb:423–424`)
and are covered by the retained successful binder execution; the source
argument shows why no newly admitted null trivia can increase their demand.

Units' sole growth is also small in bytes: `Unit_Record` has 40 fields,
39 scalar and one eight-character `Version_String` (`ali.ads:345–495`).
Each needs at most one eight-byte slot on the selected x86-64 ABI, including
padding, so `Component_Size <= 320` bytes is conservative. The 300-slot
request is at most 96,000 bytes; even charging both old and new storage gives
128,000 bytes. This field-count argument supplies the multiplication bound;
it is not a guessed record allowance or a physical-memory promise.

`Sig_Map` starts with 500 buckets and expands when pairs/buckets exceeds 1.5
(`ali.adb:159–175`). `GNAT.Dynamic_HTables.Put` allocates exactly one node for
a new key, increments the pair count, and performs expansion afterward
(`libgnat/g-dynhta.adb:1192–1297`). At insertion 751 it grows to 1,000 buckets;
900 pairs cause no second growth. Rehash moves existing nodes, retaining both
bucket arrays until the old one is freed (`:1003–1099`). Thus charge 900 data
nodes and up to 1,500 coexisting dummy-head slots. Each node contains the
five-scalar signature, one scalar ID and two pointers; an eight-byte slot per
scalar/pointer gives a 64-byte component bound. Their combined backing is at
most 153,600 bytes, plus the fixed map descriptor. This is independent of
where Main's changed coordinates hash, including the worst collision chain.
No iterator or map traversal exposes bucket order to signature ID assignment.

The hash bucket type is modular 32-bit; `Find_Bucket` reduces the hash modulo
the nonzero bucket count (`gnat.ads:46`, `g-dynhta.adb:772–782`). No key
collision creates an extra signature or an extra rehash beyond these counts.
The greatest retained runtime hash text is 93 bytes. Main's variable hash
text remains at most 37, so the 2,052-character bounded hash scratch and its
`To_String` temporary are sufficient for the entire closure. Parsing a valid
nonnegative `Nat` decimal coordinate cannot overflow an intermediate prefix
of that coordinate (`ali.adb:1345–1368`); its final range is an upstream native
source-position obligation, not established by accepting arbitrary decimal
ALI text.

Each `A` row creates one separately allocated String (`ali.adb:1880–1917`).
The baseline 617 strings total 4,491 payload bytes, with a maximum of 27.
The combined native proposal adds `-gnatx` and
`-Wno-free-nonheap-object`, giving 619 strings and 4,521 payload bytes;
the maximum remains 27. It changes neither the signature nor dependency counts.

The retained fixed runtime files have maximum complete length **58,770 bytes**,
including ignored Xref text. `Read_Library_Info_From_Full` allocates the file
length plus one EOF byte (`osint.adb:2471–2613`). Its coherent regular-file read
and parser cursors therefore fit the signed input/index domains. Source-file
timestamps/checksums agree across every repeated D name in the closure. The
selected `-x` route disables source checking; no timestamp mismatch opens
another source-checksum scan through `ALI.Util` on this coherent input family.

For the **proposed indexed no-Xref descriptor only**, Main's raw ALI has the
following source-derived bound. The retained proposed unindexed template is
344 bytes, with one- and two-digit coordinates. Add the fixed index switch's
11-byte A row, at most six bytes of casing flags, and at most 17 additional
coordinate digits:

```text
Main_ALI <= 344 + 11 + 6 + (20 - 3) = 378 bytes
all raw ALI bytes <= 465,765 - 352 + 378 = 465,791
all raw read allocations, including EOF <= 465,791 + 61 = 465,852
peak raw ALI buffer <= 58,771
```

These are distinct from parser-table backing. The writer's fixed null record
shape, the index-option transfer and the proved no-Xref selector justify the
only variable terms; an observed file maximum would not suffice. The current
baseline includes Xrefs and is not assigned the proposed 378-byte bound.
The largest retained consumed row is 108 bytes before LF; the proposed Main
row with ten-digit coordinates is smaller. Shared name storage, normalized
filesystem paths, diagnostic strings and driver option files still need
their own transfer. Printable path comments above establish no claim about
GPR command quoting or linker path interpretation.

### Contribution to shared name storage

`Name_Find` creates at most one entry per call and appends exactly the name's
payload and one NUL when the name is new; `Name_Enter` always does so
(`namet.adb:1138–1168,1190–1278`). Hash collisions only change lookup traversal.
The selected Linux filesystem is case-sensitive, so `Get_File_Name` calls
`Get_Name` once without the extra canonicalization lookup used on insensitive
filesystems (`ali.adb:1213–1233`). Inventorying every selected caller gives:

| Record | Maximum name-entry events per record | Records |
| --- | ---: | ---: |
| U | 2: unit and source | 101 |
| W/Y/Z | 3: unit, source and ALI | 348 |
| D | 3: source, optional unit/subunit and optional reference file | 594 |
| G c | 3: name, scope and locations, including `none` | 900 |
| L | 1 for the sole contiguous options group | 1 |
| N | 1 optional pragma source filename | 7 |

The retained N rows have no explicit source filename; charging one each is
conservative. Their argument text is copied into the name scratch buffer but
does not call `Name_Find`/`Name_Enter` (`ali.adb:3137–3167`). A rows allocate
their Strings separately, restriction rows compare names against enum images,
and no CUDA, No_Dependence, invocation-relation or external-version row is
selected. Thus the parser contributes at most **5,736 new name entries** and
**625,224 character slots**, including NULs. Each stored payload is at most
108 bytes: each field fits its consumed row, and the single L group's decoded
text plus its embedded NUL fits that row as well. These lengths fit the stored
`Short` and the 131,064-character global scratch buffer; the signature hash
uses its separate bounded buffer already accounted above.

These are additive contributions, not a bound that assigns startup or path
storage zero. If `E_in,C_in` bound name entries/characters from every other
selected producer, require capacity for `E_in + 5,736` and `C_in + 625,224`.
`Name_Entries` starts at 6,000 slots of exactly 16 bytes, and `Name_Chars`
starts at 50,000 byte slots; both grow by 100 percent
(`namet.ads:562–634`, `alloc.ads:88–95`). Apply `Table.Reallocate` to those
total demands, preserving its index origin, sentinel, growth and allocation
arithmetic. This leaves the incoming-pool premise explicit. The composition
below supplies the remaining selected `Namet` producers; separately allocated
argument and directory strings still need their own inventory.

### Binder mapping-file contribution

The null project explicitly lists only `main.adb` and has no imported or
extended project. `Create_Binder_Mapping_File` iterates those project sources
and emits at most one unit/ALI/path triple per selected source
(`gpr_build_util.adb:341–525`); runtime lookup does not enumerate new project
sources. Thus its mapping has **at most one record**, possibly none. This
upper bound does not assume that the indexed ALI name is found by the mapping
producer's default-index `Lib_File_Name` call (`:836–859`).

`Fmap.Initialize` enters its mapping filename, then its `Read_Source_File`
call interns the normalized filename through the Config/Full_Name branch of
`Find_File` (`fmap.adb:278`, `osint.adb:1222–1236,2644`). Both calls are charged:
`Name_Enter` does not add the first name to the hash table. It then interns
at most the unit, ALI basename and complete ALI path (`fmap.adb:294–350`).
`Fmap.Add_To_File_Map`
adds at most one entry to each of its two tables, whose initial capacities
are 1,000 (`:55–73,113–133`). Let `T` be the complete mapping filename length
and `A` a bound on the complete Main ALI path; the indexed name gives
`A = O + 2`. Allowing `main%b` and `main~1.ali` gives:

```text
mapping raw file bytes <= A + 19; read buffer including EOF <= A + 20
mapping name additions <= 5 entries and 2T + A + 21 character slots
T <= T_root + 36
```

The two filename occurrences have equal length under the already normalized
absolute temporary-path descriptor; a different canonicalization must instead
charge its own second length. These contributions remain separate from the
parser's 5,736-entry budget.
They cover the mapping consumer, not all GPR project, response-file or search
storage. The next section charges the remaining startup and filesystem-name
producers instead of assigning them zero.

### Complete selected binder name-pool composition

The selected successful route has the following `Namet` producers in addition
to the parser. `Namet.Reinitialize` creates 256 single-character entries and
512 character slots (`namet.adb:1309–1340`). `Snames.Initialize` interns the
generated preset strings (`snames.adb-tmpl:318–346`). `XSnamesT` reads 955
`Name_*` definitions from the retained spec template; its leading-u, `UP_`
and `Op_` transformations never lengthen a name (`xsnamest.adb:230–281`).
Charging all 955, including already-present single letters, contributes at
most 12,005 more character slots. The largest preset payload is 37 bytes.

| Producer | Maximum entry events |
| --- | ---: |
| Single characters and all preset names | 1,211 |
| ALI parser | 5,736 |
| Mapping input and its normalized filename | 5 |
| Successful ALI lookup and object-name construction, 61 files | 122 |
| Main ALI basename and artificial `s-stalib.ali` seed | 2 |
| `system.ads` basename and successful full-path lookup | 2 |
| Spec/body output: lookup plus unconditional enter for each | 4 |
| Consistency-check body-name lookups, at most two per D row | 1,188 |
| Duplicate-subunit probes, two for each of six subunit D rows | 12 |
| **Total before any deduplication** | **8,282** |

Successful `Locate_File` interns at most one found full path; failed directory
probes allocate no name entry (`osint.adb:1874–1923`). Each raw ALI read calls
`Object_File_Name`, which unconditionally enters the corresponding object
name (`:2186–2197,2493–2494`). `Next_Main_File` and the artificial seed each
intern one basename. `Create_Binder_Output` performs one lookup and calls
`Create_File_And_Check`, which enters the name again
(`osint-b.adb:65–149`, `osint.adb:711–717`). Those unconditional entries are
charged even when the spelling already exists.

The consistency check has two indirect name-producing sites:
`Reified_Child_Spec` and `Check_Consistency_Of_Sdep` call `Uname.Get_Body_Name`
(`bcheck.adb:133–138,232–240`, `uname.adb:56–62`). Charging both per dependency
row avoids assuming the source name was already in the unit table.
`Check_Duplicated_Subunits` appends `%b`/`%s` to each subunit name and interns
both (`bcheck.adb:1314–1332`). The checker inventories the six retained plain
ASCII subunit names, so decoding cannot expand them beyond their original
row bound; the two-character suffix is charged.

The target reader runs once and loads fixed `system.ads`
(`targparm.adb:141–157`); all optional AST/restriction callbacks are null.
The retained file contains no runtime-name or executable-extension String
and no restriction pragma, so their additional interning routes are absent.
Source-checksum rescanning is absent under `-x` and coherent D timestamps;
forced-order names, bind-environment names, source/debug listings and error
branches remain excluded by the selected controls and fixed successful inputs.
`Csets`/`Uintp` initialization and the selected graph core do not add names.
Directory normalization and argv storage use their own String allocations,
not `Namet`; this distinction does not discharge those separate allocations.

For character storage, let `M` bound the complete ALI paths, `S` the complete
installed `system.ads` path, `T` the normalized mapping filename and `A` the
Main ALI path. The preceding table gives the following additive bound:

```text
C_names <= 768,656 + (S+1) + 122(M+1) + 2T + A + 21
```

The constant includes startup/parser payloads, two 109-slot body-name probes
per D row, two 111-slot probes per subunit row, fixed basenames and four
14-slot generated output-name entries. For the retained installation,
`M=193`, `S=195`, `A=124`, and `T<=T_root+36`, hence
`C_names <= 792,737 + 2T_root`. At normalized root `/tmp`, this is **792,745
slots**. The maximum stored payload is the maximum of 110, the selected
complete paths and the temporary filename. Each must fit the retained
`Short` name-length field; this is an existing tool representation condition,
not a newly chosen path cap.

The name-entry table grows once from 6,000 to **12,000 slots**. Its 16-byte
layout gives 192,000 bytes, or **288,000** charging old and new backing
together. The `/tmp` character case grows from 50,000 through 100,000,
200,000 and 400,000 to **800,000 bytes**; old plus new is **1,200,000 bytes**.
Other normalized temporary roots use the displayed formula and the same
growth rule. Even allowing every such temporary filename up to `Short'Last`
needs at most 1,600,000 character slots on this installation. Table origins,
sentinels, doubling and byte multiplications remain inside the signed index
and native allocation domains. `Names_Low_Bound=-399,999,999` and
`First_Name_Id=Names_Low_Bound+2`; 12,000 slots are far below
`Names_High_Bound=-300,000,000` (`types.ads:344–346`, `namet.ads:186–202`).

This closes the selected binder process's shared name-table representation
capacity under the stated filesystem and invocation descriptor. It does not
reuse these totals for Gprbind, the binder compiler or a broader Silver shell.
Their separate processes and input structures retain their own obligations.

### Selected argument storage and exchange-row constraint

For the fixed static-runtime descriptor with no additional configured,
project or command-line binder switches, Gprbind supplies six arguments:

```text
-o  b__main~1.adb  <Main ALI path>  -x  -F=<mapping file>  -O=<object list>
```

`gprbind.adb:561–611,674–696` constructs this list from one Main, no extra
project dependency files and the two temporary paths. The proposed Main
compiler options do not enter that construction. The retained historical
unindexed `build.stdout` corroborates this shape, with its original basename
and installation; it is not an indexed invocation capture.

Let `Tm,To` be the two complete temporary-path lengths. Gprbind's `Size` is
the sum of each argument's length plus one (`:727–745`), hence exactly
`A+29+Tm+To`. For this installation and normalized `/tmp` root it is at most
**233 bytes**. The Linux `__gnat_link_max` is **8,192**
(`link.c:130–135`, imported by `gpr-util.ads:800–801`), under the same
relevant-behavior premise. Thus the selected call uses direct arguments,
without constructing or recursively expanding a response file.

This direct-argument result also holds if both temporary names are at most
1,000 characters: `124+29+2,000 = 2,153 < 8,192`. That number arises from a
different existing tool representation: Gprbind reads its exchange file
with `Line : String (1 .. 1_000)` and `Get_Line`
(`gprbind.adb:85,270–273`). A longer logical row would be split and could be
misinterpreted. The mapping path is one such row
(`gprbuild-post_compile.adb:4412–4422`); the object-list path is generated
by the same temporary-path template in Gprbind. Consequently an admissible
installation descriptor must establish that every exchange row fits the
1,000-character reader. The preceding `Short'Last` calculation is solely a
Namet bound, not permission to use temporary names that violate this reader.

The source-side exchange-row interface separates the quantities to charge:

| Producer | Maximum row length to supply |
| --- | ---: |
| Mapping file | `T_root+36` |
| Main dependency file | `A = K+30` |
| Main project path | `K+27` |
| Compiler path, fixed options, language/version and suffix fields, section labels and project checkline | Maximum of their fixed configured spellings |

These rows are emitted at `gprbuild-post_compile.adb:4412–4561,4662–4793`;
the null project contributes no imported project or additional source row.
At the retained installation, Main ALI and project rows are 124 and 121
characters, and the compiler path is 146. The complete original input
exchange file was not retained: the surviving `.bexch` is Gprbind's rewritten
output. The selected configuration capture and producer join below fill that
premise for the controlled descriptor, without recovering the historical input.
The 1,000-character condition is an identified tool interface requirement,
not an adopted Silver source-size cap.

In Gnatbind itself, `Generic_Scan_Bind_Args` constructs one argument-sized
local String at a time (`gnatbind.adb:545–578`). The selected `-o`, `-F=` and
`-O=` cases retain Strings of 13, `Tm` and `To` bytes; `Add_File` retains the
`A`-byte Main path (`:350–359,485–491`, `switch-b.adb:61–76,451–454`,
`osint.adb:570–585`). These four payloads total **217 bytes** at the `/tmp`
bound, with at most **124 bytes** for the current argument copy.
`Osint.File_Names` and `File_Indexes` each allocate `Argument_Count+2 = 8`
slots (`osint.ads:733–749`); only one slot is used and no doubling occurs.
The artificial runtime seed is an ALI parser input, not another argv file.

`Next_Main_File` additionally allocates the Main directory substring and
its normalized copy (`osint.adb:2005–2052,2128–2129`): **228 character bytes**
for two 114-byte copies. The first allocation is charged even though its
pointer is overwritten. This inventory closes the selected scanner's retained
argument/file payloads and arrays. Default-path/environment reads,
search-directory normalization and tables, OS spawn storage and GPR vectors
remain separate allocations; none is assigned zero by this calculation.

### Selected GPR exchange and argument vectors

Managed run `20261018T110052-6e9404864987` generated one fresh configuration
for the selected `GNAT 16.1`, default runtime and `x86_64-pc-linux-gnu` target.
It ran Gprconfig and metadata queries, with no project build. Selection took
0.123 seconds and produced the retained 7,011-byte `selected.cgpr`. All 71
knowledge-base files and the three selected tool executables were hash-equal
before and after. The complete child environment, command, log, output and
managed records are retained. Five warnings report absent VxWorks/PikeOS
environment variables while reading unrelated compiler descriptions; selection
still exits zero. The verbose log's discovery commands are version/target
queries only. This is the selected proposed configuration, not a claim about
the missing historical configuration file.

The generated configuration supplies four leading compiler switches
`-c -x ada -gnatA`, no trailing compiler switches and one binder switch
`gnatbind_prefix=`. Required-switch lists start empty
(`gpr.ads:812–816,964`). Gprbind consumes the empty prefix without changing
the default executable or appending an option (`gprbind.adb:360–393`), so
the six-argument binder descriptor above is unchanged. The generated Silver
project has no Binder package, command-line binder arguments, imported or
extended project, build script, CodePeer mode or stand-alone library.

The complete initial exchange inventory under those controls has at most
**26 logical rows**:

| Section | Rows, including its label |
| --- | ---: |
| Optional quiet/verbosity | 1 |
| Mapping file | 2 |
| Toolchain language/version | 3 |
| Optional object suffix language/value | 3 |
| Main basename | 2 |
| Compiler path | 2 |
| Four leading compiler switches | 5 |
| Main ALI | 2 |
| Additional dependency files | 1 (label only) |
| Consumed binder prefix | 2 |
| Project path/checkline | 3 |

`Add_Dependency_Files` has `Roots=null` and a unit-based Main, so it adds no
dependency-file payload (`gprbuild-post_compile.adb:3737–3830`); this is not
the 61-file runtime ALI closure traversed later by Gnatbind. Project emission
writes the one Main project and has no imported-project iteration
(`:4764–4797`). Its checkline is 14 timestamp characters, a space and a
32-character MD5 digest (`gpr.ads:206`, `gprbuild-post_compile.adb:3841–3842,3891–3905`;
`g-md5.ads:39–49`, `g-sehamd.ads:45–49`, `g-sechas.ads:160–178`).
Section labels are fixed enumeration images with underscores replaced by
spaces (`gprexch.adb:110–130`). Every fixed row is at most the **146-byte
compiler path**; the only variable-length row is the mapping path, bounded
by `T_root+36`. Thus `max(146,T_root+36) <= 1000` discharges the reader
interface. This derives the limit from the tool; it adds no Silver source cap.

Gprbind's three empty vectors are `ALI_Files_Table`,
`Binding_Options_Table` and `Compiler_Trailing_Options`.
`Project_Paths` receives one record; `Gnatbind_Options` receives six Strings.
The compiler vector receives the four configured switches, five fixed
Gprbind switches, Main's filtered backend options and three source/output
arguments (`gprbind.adb:865–943`). The retained baseline has two backend
options, `-mtune=generic` and `-march=x86-64`, for **14 entries**. The proposed
`-Wno-free-nonheap-object` adds one, for **15 entries**; the proposed frontend
`-gnatx` is filtered. The checker records these two cases separately and uses
the indexed output names when computing the proposed projection.

Both vector instantiations use positive indices and indefinite elements
(`gpr-util.ads:39–40`, `gprbind.adb:173–181`). Under the pinned runtime's
relevant-behavior premise, append allocates one element and doubles only the
backing pointer array when full (`a-coinve.adb:214–246,1349–1354,1498–1531`;
`a-coinve.ads:411–419`). Capacities therefore stay at **8 binder slots,
16 compiler slots and 1 project slot**. Empty-vector appends return without
allocation (`a-coinve.adb:183–191`). Growth copies element pointers; it does
not duplicate all payloads. During growth, old and new arrays have at most
12 binder or 24 compiler slots combined. `To_Argument_List` separately
allocates one String copy per entry and an array of exactly the vector length
(`gpr-util.adb:3751–3761`); those are additional to vector storage.
All these counts are small source-derived demands, independent of author
trivia and source size. The display buffer's initial 1,000 characters suffice
for both commands at the retained `/tmp` descriptor, including executable
paths (`gprbind.adb:143–148,197–221`).

This closes the selected exchange-row and argument-vector representations.
The following joins cover Gprbind's Main-ALI read/scan and generated-output
scan. Whole GPR process storage, including elaboration, filesystem and Text_IO
internals and path search/spawn, remains separate from these components.

### Gprbind's separate Main-ALI parser

Gprbind does not parse the binder's entire runtime closure. It initializes its
own GPR tables, reads **only Main's ALI**, and requests `Read_Lines => "A"`
(`gprbind.adb:875–901`). GPR's scanner also always reads U records and the
version header; `Ignore` starts with U enabled and then enables A
(`gpr-ali.adb:673–677,715–769,897–936`). The proposed no-Xref Main bound above
is 378 bytes. `Find_File` checks that same pathname without adding a search
directory or name; `Read_Library_Info_From_Full` allocates its length plus
one EOF byte (`gpr-osint.adb:298–315,441–453,459–553`). Thus this separately
owned buffer is at most **379 bytes**, and its cursor/line increments remain
far below the signed index domains. Coherent regular-file contents are the
same artifact premise used by the binder.

The selected input yields one ALI, one unit, nine proposed argument rows,
zero with entries and zero dependency entries. D rows are skipped because D
is disabled; unknown G rows, including variable coordinates, are skipped
without parsing their numbers (`gpr-ali.adb:276–292,1170–1181,1314–1330`).
The unit's casing flags change scalar enum values, not table cardinality.
Version text, arguments, unit name and source basename are fixed. No runtime
ALI recursion occurs in this Gprbind path.

| GPR parser table | Demand | Backing slot bound |
| --- | ---: | ---: |
| ALIs | 1 | 500 |
| Units | 1 | 100 |
| Args | 9 | 1,000 |
| Withs | 0 | 0 |
| Sdep | 0 | 0 |

The capacities come from `gpr-ali.ads:200–205,356–361,414–440,492–497`.
`GNAT.Table` delegates to `GNAT.Dynamic_Tables`; its empty instance allocates
on first growth, using the selected initial capacity, and `Init` leaves an
empty table unallocated (`g-table.ads:60–65`, `g-dyntab.adb:134–209,227–247`).
No selected table reaches a second growth. These bounds include the initial
backing arrays; they are not nine entries substituted for a 1,000-slot
argument allocation.

Each A record allocates its own String (`gpr-ali.adb:794–832`). The nine
strings total **92 payload bytes**, maximum **24**. The filter's local
`Argv` copy is at most another 24 bytes (`gprbind.adb:912–929`), separate from
the surviving compiler-vector elements and their argument-list copies.
The version conversion also uses its fixed 32-byte scratch array
(`gpr-ali.ads:75`, `gpr-ali.adb:753–765`).

There are at most four new GPR name entries from this path: the 124-byte full
Main ALI name, `GNAT 16`, `main%b` and `main.adb`, totaling **145 value bytes**.
These are GPR's own names, separate from GNAT binder `Namet`.
`GPR.Names` stores each value in a discriminated `Name_Entry` with a hash link
and integer metadata, through an indefinite vector (`gpr-names.adb:44–78,
395–473`). Unlike the earlier GNAT name pool, this record's `Value` does not
allocate an extra NUL byte; the explicit C-call terminator is written into
the shared scratch. Its hash table has 65,536 static slots and its scratch
has 1,000,000 bytes (`gpr-names.ads:29`, `gpr-names.adb:44–58`). Each payload
and the 125-byte C filename use fit that scratch. Hash collisions only change
chain probes; they add no name or payload. For incoming name count E, vector
storage still must be charged through the capacity for E+4 and any coexisting
growth arrays; these four entries do not erase earlier process/elaboration
names or record metadata.

### Gprbind's generated-output scan

After compilation Gprbind reads the binder's object list and generated body,
then rewrites the exchange file (`gprbind.adb:975–1047`). The source projection
above supplies exactly one 122-character object row. The linked `Bound_Files`
list therefore has one record and one separately allocated 122-byte name
(`:998–1007`). The generated body has 203 lines, each at most 191 characters
at this installation, preserving both loop bounds and the 1,000-character
line-buffer capacity. This is a consequence of the fixed generated-source
family, not a maximum inferred from varying author source samples.

The option list has the Main object, two workspace `-L` paths, the fixed runtime
`-L` path, `-static`, `-lgnat` and `-ldl`. Only the fixed runtime directory
contains `libgnat.a` under this installation descriptor. Its allocated
`Adalib_Dir` is 181 characters. Prefix construction appends at most two
ancestor directory copies, each no longer than that original path, and two
separators (`gprbind.adb:1106–1197`); **545 characters** suffice for every
intermediate and the final separate `Prefix_Path` String. The selected options
never call the optional `libaddr2line`/`libbfd`/`libgnatmon`/`libiberty` search
helper, and the shared-library run-path branch is inactive. The final exchange
has 18 rows, each at most 190 characters, including the full `libgnat.a` path.

The scanner and its per-row payloads are bounded independently of author
trivia. These scan/vector bounds do not include Text_IO file/control storage,
temporary-path/filesystem operations, spawn internals or fixed elaboration
state. The following section supplies the selected runtime-interface terms.

### Runtime argument and Text_IO representations

The runtime-owned copies are additional to the GPR vectors. On the selected
Linux branch, `Spawn_Internal` copies each input argument String once into
`N_Args`, then constructs one contiguous NUL-terminated command buffer and an
array of `argument_count+2` C pointers (`s-os_lib.adb:2871–2979`). The command
buffer is exactly executable length plus one plus the sum of each argument's
length plus one. `Normalize_Arguments` returns without quote expansion because
`__gnat_argument_needs_quote=0` on this platform
(`s-os_lib.adb:2025–2035`, `adaint.c:3194–3198`). Thus:

| Selected spawn representation | Binder | Proposed binder compiler |
| --- | ---: | ---: |
| Extra argument Strings / `N_Args` pointer slots | 6 | 15 |
| Extra String payload bytes | at most 227 with `/tmp` | 119 |
| C argument pointer slots, including executable and null sentinel | 8 | 17 |
| Contiguous command bytes, including every NUL | at most 385 with `/tmp` | 281 |

For another selected temporary root, use the earlier general binder-argument
formula before adding the 152-byte NUL-inclusive executable name. These sizes
remain distinct from `To_Argument_List`'s copies. All sums and append indices
fit their `Positive`/`Natural` domains. On Linux, the C wrapper's selected
branch calls `fork`, `execv` and `waitpid` with those pointers; its Windows
argument rewriting/allocation branch is absent (`adaint.c:2418–2469`).
This establishes the wrapper's representation demands, not OS process or
memory availability. No build-script output is selected, so `Script_Write`
returns before script quoting or file creation (`gpr-script.adb:117–122`).

Gprbind makes four nonstandard Text_IO open/create calls: input exchange,
output exchange, object list and generated body. The input exchange closes
before the others; the object list closes before opening the body. Thus at
most **two nonstandard files** coexist. Each open allocates one fixed
`Text_AFCB`, one NUL-terminated filename and one NUL-terminated form String
(`a-textio.adb:158–162`, `s-fileio.adb:831–850`). The default form is empty, so
its copy has one byte. `Open`/`Create` also own a fixed local dummy control
block; it is additional to the two possible live heap blocks
(`a-textio.adb:231–253,1196–1218`). The standard streams and libc `FILE` state
are separate fixed runtime support, not included in this two-file count.

Let M be the retained runtime's `max_path_len`. `System.File_IO.Open` owns
two `M+1` path buffers and a one-byte form buffer
(`s-fileio.adb:798–819`). Its normal Linux full-name routine either copies an
absolute path or joins the actual working directory, `/`, and the relative
name (`cstreams.c:216–236`). At the retained installation and `/tmp` descriptor,
all four full names are at most **127 characters**, so each allocated filename
is at most **128 bytes** including NUL. This bound charges the full path,
not just the short relative input. The installation premise includes that
these full paths fit M; source trivia does not affect them. A different
temporary root substitutes `max(127,T_root+36)` for this full-name bound.

The selected calls use the bounded-buffer `Get_Line` procedure, not its
recursive String-returning overload. Its fixed auxiliary chunk is **80 bytes**
and it writes within the supplied 1,000-character buffer
(`a-tigeli.adb:45–82,148–215`). ASCII, LF-terminated generated rows fit that
buffer. The largest possible file-line counter is 204, for the 203-line body;
other files have at most 26 input or 18 output rows. `Put_Line` restricts its
local terminator buffer to **514 bytes** even for a longer argument
(`a-textio.adb:1393–1432`). The selected exchange rows are shorter. No input
selects page-length or bounded-line formatting, and all counters stay within
`Count` (`a-textio.ads:80,680–685`).

The one object-list temporary has one registry entry. `Record_Temp_File`
appends once, and deletion traverses that single entry (`gpr.adb:279–327,
1350–1360`); the dynamic table's first backing has ten slots
(`gpr.ads:2916–2921`). Its name/path character storage is still covered by
the earlier temporary-template bound, and is separate from the four ALI-parser
name entries. The following projection supplies fixed initialization and
selected normalization/search evidence. These are caller representation
bounds, not a physical-memory total. The ordinary trusted libc/OS boundary
includes correct library semantics and resource availability; auditing libc
internals is not an additional capacity prerequisite.

### Fixed initialization and selected path interfaces

Managed run `20261018T113833-a859174fb659` invoked the installed Gprbind with
zero arguments, a 113-character empty working directory, and exactly the
selected `PATH`, `LC_ALL=C`, `TMPDIR=/tmp` environment. It reached the expected
`gprbind: incorrect invocation` diagnostic: exit **7**, **30 stderr bytes**,
empty stdout, and **0.00349 seconds** in Gprbind (**2.14444 seconds** managed).
The binary and six retained source identities were unchanged, and the working
directory remained empty. This is a successful initialization diagnostic,
not an admitted-program compilation failure or a complete compile witness.
No binder, compiler, assembler, linker or proof ran in the diagnostic.

The guard is after library/program declaration elaboration, `Set_Program_Name`
and `GPR.Set`, but before the exchange-file name allocation and open
(`gprbind.adb:226–238`). Main source bytes and ALI metadata therefore cannot
affect this prefix. The directly selected source initializers are:

| Initializer | Input and effect |
| --- | --- |
| `GPR` (`gpr.adb:2452–2454`) | Initializes the empty temporary-file table. |
| `GPR.Cset` (`gpr-cset.adb:253–255`) | Initializes the fixed character tables. |
| `GPR.Osint` (`gpr-osint.adb:583–585`) | Resets the fixed unknown-file-attributes record. |
| `GPR.Util` (`gpr-util.adb:6167–6175`) | Obtains the fixed target executable suffix, enters its empty Linux name, and frees the temporary String. This is a preexisting name entry; subsequent name-table bounds must not assume an initially empty table. |
| `GPR.Tempdir` (`gpr-tempdir.adb:248–269,298–299`) | Reads the selected four-character `/tmp`, checks the absolute accessible directory, normalizes it, and returns before `TEMP`, `TMP`, default-directory and current-directory fallbacks. Its seven fallback literal Strings still exist: 42 payload characters in total (`:44–59`). |
| Gprbind declarations and prefix (`gprbind.adb:40–161,226–236`) | Fixed suffix Strings, `gnatbind`, `000`, 1,000-character line/display buffers, empty vectors and the seven-character program name; `GPR.Set` only sets the displayed section (`gpr.adb:373–376`). |

`GPR.Initialize` would append a tool directory to `PATH` and initialize project
attributes (`gpr.adb:1236–1270`), but Gprbind does not call it. The captured
prefix includes transitive library elaboration; the table attributes the
selected source operations rather than claiming an exhaustive heap-byte
inventory for every transitive package. The capture establishes that this
fixed prefix completes in the retained environment. Its transfer uses the
fixed initializer inputs and the absence of any Main/exchange read before
the guard; it does not infer capacity for later code from elapsed time.

For an input path of N characters, `Normalize_Pathname` owns a
**N+2M+4-character** `Path_Buffer`, where M is the installed runtime's
`__gnat_max_path_len` (`s-os_lib.adb:2041–2080`). Its copied return and
`Final_Value` scratch are additional, bounded by the selected normalized
path. Absolute inputs bypass current-directory fill. The selected descriptor
fixes path resolution and symlinks; binder executable normalization explicitly
disables link resolution. Arithmetic and full resulting paths must fit the
runtime's `Integer` and M limits. M is a tool parameter, not an invented
source-size allowance.

Absolute executable search still copies `PATH`: the Linux C wrapper allocates
`strlen(PATH)+1` before calling the locator (`adaint.c:3116–3127`). The inner
locator copies its filename, tests the absolute path, and returns its duplicate
before the search loop (`:2935–2971`). The Ada wrapper has another
executable-length-plus-one C-name buffer, copies the returned path into an Ada
String, and frees the C allocation (`s-os_lib.adb:1644–1688`). The selected
binder is the longer executable name: each of these C-name/return buffers is
at most **152 bytes**, with a **151-character** Ada result. The complete fixed
`PATH` copy is recorded separately in `result.json`; no fallback search is
selected when the absolute executable exists.

Regular library search does use the bounded prefix constructed above. With a
545-character prefix and longest basename `libgnat.a` (9 characters), its Ada
C-name/path buffers total **556 bytes** (`s-os_lib.adb:1716–1738`). The nested C
locator's two stack buffers total at most **566 bytes**: 10 plus
545+9+2 (`adaint.c:2939,2989–2993`). Its loop advances through that finite
prefix; it does not accumulate a buffer per directory. Each path component
is at most the 181-character retained runtime directory, so a successful C
result is at most **191 bytes** including NUL and the copied Ada result at
most **190 characters**. These counts include both sides of the Ada/C
interface. Filesystem predicates, allocation, process launch and stream
operations then stop at their ordinary libc/OS contracts. A changed installed
path, environment or symlink selection needs a new descriptor reconciliation;
source trivia does not enlarge these requests.

### Selected search-directory and default-relocation projection

This join makes the search environment premise concrete. It selects the
default native runtime, no extra binder search switch, empty or absent
`ADA_INCLUDE_PATH`, `ADA_OBJECTS_PATH` and `ADA_PRJ_INCLUDE_FILE`, and the
one generated `ADA_PRJ_OBJECTS_FILE`. The optional installed
`ada_source_path`/`ada_object_path` files are absent. The collector records
their absence at the retained installation on this date, not an observation
of a historical child environment. The packet also retains the installed
`gnat.xml` configuration fragment. No raw GPR child environment was captured.

The standard GNAT configuration uses `-gnatem=` mapping and
`ADA_PRJ_OBJECTS_FILE`. With the default `Use_Include_Path_File=False`, the
compiler preparation route does not create an include-path file when mapping
switches exist (`gprbuild-compile.adb:3363–3370`, `gpr-opt.ads:241`). The
project has one source directory, one object directory, and no imported or
extended project. `Get_Directories` visits that sole project; its
`Executable_Binding` route adds only its object directory
(`gpr_build_util.adb:595–750`). `gprbuild-post_compile.adb:4857–4924` writes
each selected directory followed by LF and sets `ADA_PRJ_OBJECTS_FILE` to
that file. Thus this input has **one row**, at most `K+21 = 115 bytes`
including LF. It cannot grow with Main's comments, case or source size.

`Osint.Add_Default_Search_Dirs` reads that file, normalizes its directory,
then adds the fixed default source/library paths (`osint.adb:456–565`).
`Get_Dirs_From_File` allocates exactly the input byte count, and its local
C-compatible filename is the temporary-path length plus one (`:361–427`).
The four `Getenv` reads copy their values once; under this descriptor only
the object-file variable has a nonempty payload, bounded by `T_root+36`
(`s-os_lib.adb:1177–1201`). Those environment strings are not `Namet` entries.

Both search tables reserve primary slot zero and start at ten pointer slots
(`osint.adb:220–237,1712–1736`). There are at most **two source slots**
(empty primary plus default include) and **three library slots** (primary,
project object directory and default runtime library). No table growth occurs.
Library insertion compares directory text and may deduplicate, but the bound
charges every successful insertion event. Source insertion does not deduplicate
(`:592–657`). The later Main-file selection sets its primary library slot to
the workspace object directory; this explains the two equal workspace `-L`
comments rather than treating them as one allocation.

The three directory-normalization calls copy at most **480 characters**:
114 for the project object directory, 185 for the runtime source directory
and 181 for the runtime library directory. `Normalize_Directory_Name` copies
a trailing-separator path unchanged or appends one separator; it performs
no filesystem traversal (`osint.adb:2100–2152`). The two default-path iterator
calls separately allocate at most **366 characters** before normalization
(`:1487–1514`). The earlier 228-byte pair of Main-directory copies remains
additional; it is not absorbed into the project-directory contribution.

The remaining default relocation work has fixed inputs independent of this
Main family. `Make-generated.in:49–72` constructs `Sdefault` from the tool's
fixed installation strings. Gprbind invokes the fixed absolute binder
executable, so `Executable_Prefix` takes its path-bearing branch, and
`Normalize_Pathname` takes its absolute-name branch without consulting the
variable working directory (`osint.adb:955–1015`,
`s-os_lib.adb:2254–2283`). Retain the fixed symlink/filesystem and absence of
`GNSA_ROOT` and `GCC_ROOT` as descriptor inputs.
`Relocate_Path`/`Update_Path` and the C prefix translator then read only those
fixed values, their fixed initialized prefix state and installed paths
(`osint.adb:2833–2884,3228–3250`, `prefix.cc:90–123,182–225,248–352`).

Consequently that isolated default-relocation execution, including C scratch
allocations, reduces to the successful fixed execution under those same
inputs. The four `Sdefault` return Strings, four separate `Update_Path`
result copies and C allocations are discharged by this read projection;
they are not assigned the size of only the final directory strings.
`Read_Default_Search_Dirs` takes
its absent-file return before allocating or expanding any file contents
(`osint.adb:2324–2375`). Its filename scratch has the fixed prefix, the
15-character `ada_source_path` or `ada_object_path` name and one NUL.

This closes the selected directory acquisition, its table growth and the
default-relocation representations under the explicit descriptor. A changed
environment/search file, runtime, executable path or symlink selection needs
its own accounting. GPR's project/vector storage, native spawn, later
filesystem caches and the binder compiler remain separate; this result is
not a whole-driver or whole-binder allocation total.

### Controlled descriptor witness

Managed run `20261018T104855-09a597637815` executed the retained indexed binder
once with precisely that environment descriptor, fresh output/temporary
directories and the original Main/runtime ALIs kept at their retained paths.
The child environment contains only the selected tool `PATH`, `LC_ALL=C`,
`TMPDIR` and the one-row `ADA_PRJ_OBJECTS_FILE`. The packet records the exact
arguments, environment, input identities, temporary file contents, script,
pre-extension input manifest and managed log/events. This is new controlled
evidence, not a reconstruction of the historical GPR child environment.

The binder exited zero in **0.0122 seconds** (managed run **2.0036 seconds**),
with empty stdout/stderr. Both generated files hash-equal the indexed witness:
14,556-byte spec and 8,014-byte body. The 61 closure ALIs, four compiler-support
specs, two retained generated sources and binder executable were hashed before
and after and remained unchanged. The capture's temporary root is 43 bytes,
so the general command formula gives **311 bytes**; its six actual arguments
use **303 bytes** including terminators. The earlier 233-byte `/tmp` bound is
not claimed for this scratch root.

This supplies the fixed successful execution used by the default-relocation
read projection. It adds no compiler/object witness; the initial exchange and
argument vectors are addressed separately above. The offline checker
reconciles the captured bytes and managed input pins without running the
binder again.

## Fixed library/invocation graph projection

The graph core reads a fixed logical input under the null ALI contract:
ordered units, with edges, invocation kinds/placements and signature IDs,
plus the fixed binder controls. `Read_Withed_ALIs` traverses the same retained
record order; each new unit, construct and distinct signature therefore gets
the same ID. Different Main coordinates affect only the parser signature map's
buckets. They do not change signature equality with any runtime record or
the IDs returned by interning.

This distinction matters: Bindo's unit/signature sets hash the already assigned
IDs (`bindo-units.adb:231–249`), and its signature-to-vertex table does likewise
(`bindo-graphs.adb:5274–5281`). They do not rehash source coordinates.
`Corresponding_Unit` reads the unit ID associated with its interned name
(`bindo-units.adb:140–144`); changing an earlier path/name's numeric ID does
not change that association. Ordering ties compare fixed unit-name text
through `Uname_Less`, not name-table positions (`butil.adb:599–629`).

`Build_Library_Graph` creates the fixed units, spec/body and with edges
(`bindo-builders.adb:384–404`). The optional forced-order input is disabled:
only lowercase `-f` sets `Force_Elab_Order_File` (`switch-b.adb:324–337`), its
default is null, and `Read_Forced_Elab_Order_File` then returns null before
opening a file (`butil.adb:542–553`). `Create_Forced_Edges` still creates and
destroys its fixed 20-slot temporary table, but its iterator has no entries
(`bindo-builders.adb:440–486`). A Gprbind mapping-file option is not this
lowercase binder option.

`Build_Invocation_Graph` inserts the selected constructs and relations
(`bindo-builders.adb:100–124`). All 900 constructs are ordinary kind `Z` and
there are no relation records. Consequently there are no elaboration roots,
and `Augment_Library_Graph` performs no root DFS or extra edge insertion
(`bindo-augmentors.adb:100–132,183–205`). The separate fixed library graph
still runs component discovery and elaboration ordering.

The coordinate consumers in the complete `bindo-*.adb` sources are the graph
accessors, ALI debug writer and invocation diagnostics. No graph algorithm
reads `Icasing`, `Kcasing` or timestamps. The selected invocation has no debug
writer/validator controls, forced order, elaboration listing or closure listing;
the debug writers return before coordinate access (`bindo-writers.adb:95–105,
830–840`). The core success/failure decision uses the fixed graphs and order
(`bindo-elaborators.adb:704–776`); the retained successful execution therefore
cannot become a circularity diagnostic merely from different Main coordinates.

Under those controls and the relevant-behavior source premise, graph-core
container operations, element widths, count/index arithmetic and recursion
reduce to the same finite execution as the retained successful binder. This
reuses a singleton **after** establishing its read projection; it is not a
maximum inferred from three matching generated samples. It covers the intrinsic
library/invocation graph work, including fixed initial allocations and the
empty forced-order temporary. It neither assigns a physical-memory guarantee
nor discharges the shared name/path pools, ALI raw buffers or generated-source
compiler. Their separate obligations remain necessary for the composition.

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

The spelling property can be extended through the selected naming constructors
without first bounding the number of emitted symbols:

| Naming ingress/constructor | Preservation of the no-`@` alphabet |
| --- | --- |
| Ada entities and external interfaces | `Get_External_Name` uses the explicit interface or qualified entity name, `_ada_`/`__`/`___` separators and fixed suffixes (`exp_dbug.adb:764–909`). `create_concat_name`/`concat_name` preserve that spelling; the Windows-only Stdcall adjustment is inactive on this Linux target (`decl.cc:70–86,11282–11319`). |
| Elaboration and initialization | `Elab_Body`/`Elab_Spec` lower to the fixed qualified prefix plus `___elabb`/`___elabs` (`exp_attr.adb:3735–3813`; Gigi's corresponding route is `trans.cc:7212–7221`). Package counters append `_E` (`sem_util.adb:2057–2165`), and init procedures append `IP` to generated type names (`exp_tss.adb:392–427`, `exp_tss.ads:87`). Temporary names use letters, digits and body/spec suffixes (`tbuild.adb:61–99,719–726`). |
| GNAT helper calls | Gigi's fixed helper declarations and exception-check template use `__gnat_*`; the latter appends the fixed exception-code name and optional `_ext` (`trans.cc:388–599,724–765`, `exp_ch11.adb:1929–2015`). Runtime source interface spellings in the four selected specs also lack `@`. |
| Builtins and ordinary libcalls | Ada installs its own, generic and target builtin tables (`utils.cc:7748–7834`). The packet checks all string literals in `ada-builtins.def`, `builtins.def` and its five included definition tables, the x86 builtin table, and `optabs.def`; none contains `@`. Prefix addition/removal preserves this property. Optab name generation concatenates `__`, optional `gnu_`/`bid_`/`dpd_`, operation/mode identifier text and operand-count digits (`optabs-libfuncs.cc:151–181,372–437,508–571,860–942`). The selected x86 libfunc hook supplies fixed `__divmod*`/`__udivmod*` names (`i386.cc:27634–27645`). |
| Private and clone names | Default private names add a decimal number using `%s.%lu` (`langhooks.cc:138–181`, `defaults.h:38–55`). Clone constructors add the selected `.` separator, fixed compiler suffix and optional decimal number; target attribute suffixes are filtered to letters/digits/underscore (`cgraphclones.cc:557–655`, `symtab.cc:2576–2585`). The selected input has no target/versioning attribute; the x86 hook otherwise retains the name (`i386-features.cc:5511–5534`). Alias resolution only substitutes an existing alias target name. |
| Assembler spelling | `assemble_name_raw` removes an internal leading `*` marker or calls the target hook; x86 AT&T output writes the empty ELF user prefix and label verbatim (`varasm.cc:2930–2970`, `i386.cc:1775–1781`, `elfos.h:43–44`). Local labels add `.`/fixed prefix/decimal counter (`elfos.h:121–132`). `@PLT`/`@GOT*` in instruction operands and `@function` in type directives are assembler syntax, not characters added to the ELF symbol name. |

The selected descriptor has no plugins, LTO, offload, sanitizer/profile/split
stack instrumentation, target-clone attributes or user assembly. Generated
sources and the four selected specs have no `Machine_Attribute`, `Linker_Alias`,
`Linker_Section` or `Weak_External` pragma; their Import/Export names are checked separately.
GNU symbol-version aliases require a `symver` attribute
(`cgraphunit.cc:736–816`), absent here. Fixed runtime helper names and ordinary
compiler suffixes contain no source-path text. The filename/random-seed global
name fallback is bypassed by Gigi's fixed `first_global_object_name`, as shown
above. Thus no remaining selected naming ingress introduces `@`.

The selected generated object also has **no `.gnu.warning.<name>` producer**.
An arbitrary section name can enter through `Linker_Section` or a machine
section attribute (`decl.cc:1617–1621,4269–4273,7451–7457`,
`utils.cc:3396–3427`), or through assembly; those routes are absent in the
generated sources and their selected specs. The ordinary ELF selectors choose
fixed data/text/TLS/exception section prefixes and append only the existing
symbol name or a numeric suffix (`varasm.cc:7490–7664`,
`i386.cc:779–929`); none selects `.gnu.warning.`. Fixed metadata sections
do not add that prefix either. No selected section/metadata producer has a
linker-warning route. Consequently a warning-section suffix cannot introduce
a new `@` name through the linker's separate warning-symbol path. This is
the additional warning-name premise needed by the linker; the zero warning
sections observed in the retained object only corroborate it.

The generated binder object also has **no GNU IFUNC symbol**, local or
nonlocal. The ELF alias emitter uses `IFUNC_ASM_TYPE` only when its call-graph
node has `ifunc_resolver` set (`varasm.cc:6558–6565`); the fixed spelling is
`gnu_indirect_function` (`defaults.h:111–112`). That flag starts false
(`cgraph.h:154`). Ordinary node and alias creation set it only for an `ifunc`
attribute (`cgraph.cc:674–675,732–733`); LTO deserialization can also set it
(`lto-cgraph.cc:1359`), but LTO is excluded by this descriptor.
The x86 automatic resolver route introduces the attribute for function
multiversioning (`i386-features.cc:5679–5685`); the selected generated sources
and four dependency specs have neither target/target-clone attributes nor the
Ada `Machine_Attribute` ingress (`decl.cc:7428–7502`). Plugins and assembly
are also absent. Thus neither explicit nor compiler-created resolver ingress
is selected. The zero type-10 (`STT_GNU_IFUNC`) records in each retained binder
object corroborate this source argument. This supplies the binder's empty
local-IFUNC contribution independently of the separate object-count transfer.

Two further selected section-kind exclusions follow from source. **No COMMON
variable is produced.** The compiler's default is `flag_no_common=1`
(`common.opt:1297–1298`), with no selected override. Gigi's sole ordinary
COMMON setter additionally requires both its negation and a target without
global BSS support (`utils.cc:3116–3123`). The generic one-only declaration
fallback that can set COMMON is inactive: ELF defines `MAKE_DECL_ONE_ONLY`,
which sets `SUPPORTS_ONE_ONLY=1`, selecting COMDAT instead
(`varasm.cc:6928–6950`, `elfos.h:227`, `defaults.h:300–305`). Machine attributes,
user assembly, OpenMP and other frontends are outside the descriptor.

**No allocated merge section is produced.** At O0,
`OPT_LEVELS_1_PLUS` disables `fmerge_constants`; the options routine explicitly
applies the inverse zero value (`opts.cc:500–501,541–557,602`). Reading the
initial value in `common.opt` alone would miss that override. Both string and
constant merging require the resulting nonzero flag; otherwise they select
ordinary read-only data (`varasm.cc:865–917,922–943`). No selected target or
explicit-section/assembly route adds an allocated merge section. This does
not exclude the assembler's nonallocated `.comment` merge section, which the
retained object contains. These source kind exclusions are independent of the
object-shape transfer, which supplies payload, count and alignment below.

Under this descriptor, **generated binder nonlocal symbols have no `@` in
their names**. This supplies the binder part of the linker's `W=0` suffix
condition. It is a spelling invariant, independent of the separate object-shape
transfer. The retained inventory reconciles 152 source
interface spellings with 19 additional object spellings: 16 elaboration names,
the package counter and two secondary-stack init procedures; two source imports
are unused. The object has 169 global/weak symbol records, all without `@`.
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
are byte-identical. Managed run `20261018T111407-352fea7c3696` adds the missing
**proposed indexed** compiler witness. It copied the retained source bytes to
a fresh directory with the same 113-byte full directory length, so both full
source names remain 127 bytes. Its complete child environment contains only
the selected tool `PATH`, `LC_ALL=C` and scratch `TMPDIR`. The packet retains
the exact 15-argument compiler command, script, driver-only `-###` selection
query, generated sources/ALI/object, stdout/stderr and managed events/log.
The query and actual compile use the same options; the query's temporary
assembly filename is not represented as the actual compiler's filename.

The compiler/assembler exited zero in **0.0415 seconds** (managed run
**2.3122 seconds**), with empty stdout/stderr. All 11 retained source, runtime
specification and executable inputs stayed hash-equal. The proposed object
hash-equals the baseline indexed object:
`368b82296a24b933d1154f07b54bdad7af2f291302d4db23196f9d89128e2883`.
The new 8,151-byte ALI separately records the proposed compilation; no claim
of ALI byte equality is made. Its six dependency names match the same two
generated sources and four installed runtime specifications.

The following fixed-witness quantities **transfer to the selected null binder
family under the source projection above**. Agreement between the captures
corroborates that argument; it does not replace it.

| Indexed binder object property | Retained value |
| --- | ---: |
| ELF64 x86-64 relocatable file bytes | 13,432 |
| Sections, including null | 16 |
| Symbol records, including null and local | 179 |
| Global/weak symbol records | 169 |
| Sum of symbol `st_size`, all records | 11,766 |
| Sum of symbol `st_size`, global/weak only | 1,443 |
| Maximum symbol `st_size` | 10,320 |
| Maximum global/weak name length | 40 |
| Relocations | 95: 89 text, 1 read-only data, 5 EH frame |
| Executable-section bytes | 1,000 |
| Allocated section bytes, including NOBITS | 12,023 |
| `.eh_frame` bytes | 192 |
| Maximum section alignment | 32 |
| COMMON symbol records | 0 |
| Merge sections | `.comment`: 31 bytes, nonallocated, alignment 1 |
| Allocated merge sections | 0 |
| `.sframe` sections/bytes | 0 / 0 |

All object section headers lack LTO/offload/object-only/compressed data. These
object-shape terms can now enter the selected null-family linker composition,
conditional on the upstream null ALI contract and descriptor. This is not yet
a whole-tool acceptance capacity or proof of every compiler intermediate.
The historical proposed
unindexed object is separately retained at 13,424 bytes; its different basename
and options are not normalized into the indexed witness.

## Fixed binder compiler lifetime and collection exclusion

Managed run `20261018T115025-40fa63ff60dc` supplies a separate complete
fixed-binder frontend lifetime observation. It reuses the reviewed installed
counter sites and four hardware write watchpoints from the
[native prefix witness](retained-native-expansion.md#executed-null-class-gcc-setup-witness),
but continues through normal frontend exit. The exact proposed binder options
are unchanged. The two full source names remain 127 characters, and the fresh
temporary directory preserves the earlier 52-character length. The child
environment is captured at frontend exec: the three selected initial entries
plus `GCC_EXEC_PREFIX`, `COLLECT_GCC` and `COLLECT_GCC_OPTIONS`, with no debugger
library-path entry. The actual 19 frontend arguments and temporary assembly
name are retained. This is not the Main-prefix witness or a reuse of Main's
nonnull-body counts.

The debugger took **7.6263 seconds** (**9.8931 seconds** managed). The frontend
and debugger exited zero, the ordinary driver completed assembly, and the
resulting object hash-equals the accepted 13,432-byte binder object. All
retained inputs were unchanged. No linker, prover, Lean or full test suite
ran. The offline checker replays **58,074 counter changes**, their initial
values, allowed deltas, source-attributed post-store PCs and five phase
snapshots; collection also checks those instruction bytes against the pinned
installed executable. Complete instruction windows for the four extra
collection/value-expression guards are retained with their dynamic symbols.

| Counter | Complete observed lifetime |
| --- | ---: |
| Positive rounded GGC allocation events | 48,889 |
| Cumulative rounded GGC bytes | 4,155,400 |
| Largest rounded GGC request | 65,536 bytes |
| Normal declaration identities | 6,390 increments, peak 6,390 |
| Type constructor identities | 2,431 increments, 364 canonicalization rollbacks, peak 2,068 |
| Debug declaration identities | No changes |
| Calls to `ggc_collect` | 343, all heuristic mode zero |
| Actual root/value-expression marker calls | Zero |
| `decl_value_expr_insert` calls | Zero |

The allocation-byte observation has a narrow use in excluding collection; it
does not introduce an aggregate RAM or address-space admission condition.
The selected installed allocator has no always-collect/checking override.
`init_ggc_heuristics` gives the default heap threshold a **4 MiB lower bound**
even after host resource-limit adjustments (`ggc-common.cc:1088–1131`). No
selected option replaces it. Before the first collection,
`G.allocated` is no greater than cumulative rounded allocation: allocations
add the same `object_size` to both counters, while explicit frees can only
reduce `G.allocated` (`ggc-page.cc:1493–1498,1753`). The heuristic returns
before marking whenever this value is below `allocated_last_gc+min_expand`
(`:2295–2306`). The observed total is **38,904 bytes below 4 MiB**, without
needing the additional nonnegative expansion allowance.

This is transferred by a first-collection argument, not by assuming the
collector's scratch is empty. Before a hypothetical first collection, the
same-length filename substitution preserves the complete fixed semantic and
source-location request graph already established above. The affected
representations must be distinguished:

| Representation | Why filename spelling does not change its pre-collection demand |
| --- | --- |
| GNAT names and source records | Source bytes outside fixed-width comments, token positions, file order, basename, runtime specs and equality classes are unchanged. Full-path names remain distinct and same-length. Name insertion order and occupied entry counts are unchanged; differing hash chains only affect probes. |
| GCC shared `ident_hash` | Gigi converts each full filename to an identifier String (`trans.cc:282–292,339–365`). These two identifiers are plain cleared `tree_identifier` nodes, disjoint from every semantic identifier and the relative translation-unit basename. Probes allocate no node; insertion and growth depend on entry counts (`stringpool.cc:100–138`, `libcpp/symtab.cc:99–175`). The changed filename hashes do not change node or String sizes. |
| Identifier enumeration | The consumers are statistics, GC marking/purging and PCH state (`stringpool.cc:151–196,280–326`). Statistics and PCH are unselected; collection has not yet occurred. This statement concerns the affected identifier table, not every compiler hash table. |
| Line maps and location lookups | The map holds the filename pointer and fixed line counts. File equality remains isomorphic; neither map cardinality nor numeric locations change (`libcpp/line-map.cc`, `cfgrtl.cc:784–800`). The filename identifiers are not inserted as declarations or types, so their changed hashes do not alter declaration/type-cache keys. |
| Emission and synthesized names | Gigi supplies the fixed first global name before translation; basename-based `.file` and raise-location names remain fixed. The previously reviewed source projection excludes filename/random-seed fallback, debug/coverage output and a path-dependent assembler-symbol ingress. |

Consequently the pre-collection allocation and identity events are the same
as the fixed execution, up to the identity-preserving filename substitution.
At a proposed first collection the cumulative allocation is at most
4,155,400 bytes, so the heuristic must return. This contradicts a first actual
collection. Forced collection belongs to the disabled statistics routine or
unselected self-test/RTL-reader paths (`ggc-common.cc:1277–1284`,
`selftest-run-tests.cc`, `ggc-tests.cc`, `read-rtl-function.cc`); the captured
343 mode-zero calls corroborate that source exclusion. Thus the transferred
family has no actual collector traversal and no collector-created weak-cache
or `gt_value_expr_mark` scratch. This does not assign zero to that callback
for configurations where it runs: its nonempty graph remains a separate
problem outside this selected no-collection family.

The lifetime event count instantiates the existing
[GGC storage transfer](retained-native-expansion.md#ggc-object-page-index-and-finalizer-backing).
Both independent page-pointer vectors need at most **65,536 slots / 524,288
bytes**. Even conservatively charging one finalizer registration per event,
each inner vector has at most **73,332 slots**, giving independent requests
of **1,173,320 bytes** for scalar records and **2,346,632 bytes** for array
records. The captured largest rounded GGC request is 65,536 bytes, and every
UID/counter write remains representable. The fixed successful semantic
execution and same representation demands also preserve the selected
compiler's ordinary table/cardinality checks under this filename substitution;
this is a fixed-request acceptance transfer, not a measured peak heap total.
Source/path/argument wrappers, ordinary process setup and shared assembler
storage still retain their separately stated interface obligations.

## Remaining joins

1. Complete the native null ALI contract and invocation controls, including
   fixed source/object search, printable single-line generated paths and
   matching artifacts. Bounds on variable Main ALI input length remain
   upstream; the Xref ignore rule does not remove reading that buffer.
2. Complete the remaining driver/process composition. Fixed initialization
   now has a selected-input diagnostic and source projection; selected
   filesystem normalization/search has caller buffer and request bounds. The
   ordinary trusted libc/OS boundary is not a new internals-audit prerequisite.
   Selected
   binder arguments/search directories, exchange rows, argument vectors,
   Main-ALI parser/name contributions, generated-output scans, generation
   buffers, runtime argument/Text_IO representations, name tables and graph
   core are bounded above; those
   results do not cover every allocation in the GPR/driver or compiler process.
3. Complete the compiler/assembler process composition. The fixed semantic
   request and object-shape transfer close the linker-input term; the lifetime
   witness and first-collection argument now bound GGC/UID events and exclude
   collector scratch for this selected family. Reconcile the shared ordinary
   startup/pass-registry and assembler/caller interfaces. Fixed code is not
   permission to assign those representations zero or infer peak allocation
   from object size.
4. Compose the transferred object inventory with Main's variable
   native object bound and the fixed-library/linker components. Broader
   shells need their own binder closure/projection; this null progress does
   not complete #119 or unlock admission changes.
