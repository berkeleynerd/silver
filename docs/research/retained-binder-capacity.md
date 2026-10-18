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
witness. They do **not yet establish the complete frontend/backend transient
allocation projection** or a universal binder object bound. In particular,
full-path interning/hash behavior and all selected compilation phases must be
included before upgrading the observed ELF inventory below.

The specialization does not extend to all GPR temporary paths. GPR creates
`<normalized-temp-root>/GPR.<pid>/GNAT-TEMP-<six digits>.TMP`
(`gpr-tempdir.adb:68–80,103–177`, `s-os_lib.adb:77,780–905`). PID decimal width
varies. With a positive signed-32-bit Linux PID, these paths are at most
`T_root + 36` bytes, derived from the template and ten-digit PID width. The
mapping/response filename does not occur in the generated binder source or
the binder compiler's arguments. It remains a bounded driver/binder input,
with fixed normalized temp-root spelling and ordinary accessible temporary
storage as configuration premises.

## ALI parser and signature-table capacity

This extension bounds the native binder's ALI parser tables, signature map and
contribution to the shared name pools. The following section reduces the graph
core to its fixed successful witness. Shared startup/path pools remain open.
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
arithmetic. This leaves the incoming-pool premise explicit. Startup names,
argv, mapping files, filesystem search and generated-name contributions still
need their own inventory before claiming whole-binder name capacity.

### Binder mapping-file contribution

The null project explicitly lists only `main.adb` and has no imported or
extended project. `Create_Binder_Mapping_File` iterates those project sources
and emits at most one unit/ALI/path triple per selected source
(`gpr_build_util.adb:341–525`); runtime lookup does not enumerate new project
sources. Thus its mapping has **at most one record**, possibly none. This
upper bound does not assume that the indexed ALI name is found by the mapping
producer's default-index `Lib_File_Name` call (`:836–859`).

`Fmap.Initialize` interns its mapping filename, then at most the unit, ALI
basename and complete ALI path (`fmap.adb:278–350`). `Fmap.Add_To_File_Map`
adds at most one entry to each of its two tables, whose initial capacities
are 1,000 (`:55–73,113–133`). Let `T` be the complete mapping filename length
and `A` a bound on the complete Main ALI path; the indexed name gives
`A = O + 2`. Allowing `main%b` and `main~1.ali` gives:

```text
mapping raw file bytes <= A + 19; read buffer including EOF <= A + 20
mapping name additions <= 4 entries and T + A + 20 character slots
T <= T_root + 36
```

These contributions remain separate from the parser's 5,736-entry budget.
They cover the mapping consumer, not all GPR project, response-file or search
storage. In particular, they do not establish a zero contribution from the
remaining startup and filesystem-name producers.

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
2. Complete the incoming shared name/path inventory and compose it with the
   parser contribution above, including normalized filesystem paths,
   diagnostic strings, mapping/options files and generation buffers. The
   graph-core singleton projection does not cover these shared producers.
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
