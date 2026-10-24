# Fixed KB materialization and predefined ordered sets

2026-10-24, #212 under #119. This additive packet gives numerical bounds for
the target/fallback objects created while loading the selected GPR knowledge
base, its sorted input-file sets, directory list and file buffers, and the two
predefined attribute/package sets. **Complete KB parser and process capacity
remain open.** In particular, XML schema validation being disabled does not
remove the embedded metaschema parser and grammar initialization.

The accepted parsed-table author is
`17569ceaa8daf41892852cc4ab8b423b28d9091e`; its additive reset repair is
`c7f0191bb8de07a1ebe2988c35f5a8f66ef89f58`, accepted by review
`7431f0087b546477ea5a0f84c9e2905356429082`. The current unit starts from
`10c46aa5628ee0ad1e0aa7dc610d16151308fa9f` and preserves those packets. Their
nine prospective Reference_Prefix resets/pushes, primary table bounds, raw
child RTS spelling, P188 and e <= 2 / two callbacks / three saves are unchanged.
This packet changes no source admission, production code, tool pin, Oracle or
physical premise. Its figures are separate object bounds, not an aggregate
RAM or stack gate.

## Inputs and process boundary

[source-manifest.json](source-manifest.json) pins the accepted providers,
complete selected GPR sources and newly retained GCC container/regexp sources.
GCC remains at `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The existing
GNAT-FSF-builds recipe at `0334dd54a2c479faa3dfad47a911373581b11739` selects
XML/Ada 26.0.0; its tag resolves to
`5e5b761eb827f458efd2043a5e9ab03e1a614720`. The complete 1,084,228-byte archive
is retained with SHA256
`a202f1c9955d26973d30e6d0357ba83f4031bc218006d620fa916420316a4f24`.
The recipes and complete GCC files are in `sources.tar.gz`; XML/Ada tag/API
provenance is in [xmlada-provenance.json](xmlada-provenance.json). These are
source identities under the existing source-correspondence obligations; this
packet does not assert a new installed-library attestation.

The base database is the accepted 63-file `db/` projection. Phase1 adds the
fixed `frames/config.xml`; translation adds `gnat2why/config.xml`. Each selected
GPRbuild process loads its own database once per distinct directory, with
`Parse_Compiler_Info => False` (`gpr-util-knowledge.adb:82`). The 104 target sets,
279 target patterns, three fallback sets and six fallback strings are common
to all three phases. The phase additions contain neither kind of set.
[kb-targets.json](inputs/kb-targets.json) retains exact values and order.

The boundary is **KB initialization and the predefined-set initialization**.
It does not include subsequent Get_Targets_Set/Normalized_Target/Find_Targets_Set
calls, the list copies returned by those APIs, regexp matching execution or
unknown-target insertion. Gprconfig shares these initializer implementations,
but also constructs compiler/configuration objects, performs discovery and
generates output. It must attach those additional objects before claiming its
complete capacity. Counts from different processes are not added together.

## Object widths and target/fallback vectors

The accepted conservative native convention uses 16 bytes per ordinary scalar,
pointer or tag field, and 16 bytes for an ordinary unconstrained String/array
header allowance. These are sufficient widths, not measured layouts.
`a-finali.ads` and `s-finroo.ads` give Controlled a tagged null root.
`a-conhel.ads:43–46` gives Tamper_Counts two scalar fields. Thus the list header
is six slots: tag, First, Last, Length, Busy and Lock (96 bytes). A target-set
element adds one Name_Id (112 bytes). A vector header has tag, Elements, Last,
Busy and Lock (80 bytes). The vector backing has one discriminant/header slot
plus its element array (`a-convec.ads:729–746`).

Each target list node is three slots, Element/Next/Prev (48 bytes), from
`a-cdlili.ads:272–278`. The element is a pointer to a matcher; copying this node
does not copy the pointed-to matcher. Each indefinite fallback list node is
also three slots, and separately allocates its String
(`a-cidlli.ads:266–277`, `.adb:118–176`). The longest fallback String payload is
14 bytes, hence its individual object bound is 30 bytes.

`gpr-knowledge.adb:1079–1177` builds a local list, then appends it to the
appropriate vector. The one-item Append path is `a-convec.adb:202–232`;
Insert's initial allocation and growth/copy path is `:1153–1315`. Starting
from empty, capacities double. The exact target-set weights in sorted XML
order give the following sufficient bounds:

| Object | Elements / capacity | Maximum backing | Gross events during initialization |
| --- | ---: | ---: | ---: |
| Targets_Sets vector | 104 / 128 | 14,352 bytes | 8 backing allocations |
| Fallback_Targets_Sets vector | 3 / 4 | 400 bytes | 3 backing allocations |
| Target list node | At most 11 in an individual list | 48 bytes per node | At most 2,322 node allocations |
| Fallback list node | At most 2 in an individual list | 48 bytes per node | At most 48 node allocations |
| Fallback String | 14-byte payload | 30 bytes | At most 48 separate allocations |

The gross node allowance deliberately includes temporary controlled copies.
Let P be the total weight of all incoming lists and R the sum of old-list
weights at each growth. The packet charges `6*P + 2*R`. The six incoming charges
cover the original local list, the target-record aggregate, singleton element
array aggregate, enclosing Elements_Type aggregate, allocator initialization
and assignment destination; branches with fewer shells are overpaid. Tagged
List and composites containing it are passed by reference, so Append/Insert
forwarding itself introduces no uncounted by-value parameter copy. For an old
slice relocation, both a possible intermediate slice value and its assignment
destination are charged. Spare capacity slots hold default empty lists.
Controlled Adjust walks and copies each existing node once
(`a-cdlili.adb:118–155`, `a-cidlli.adb:118–176`). These are source-level upper
counts including every aggregate/assignment shell, not a claim that GNAT
necessarily materializes all optional intermediate objects.

For targets P=279 and R=324, giving 2,322. For fallback strings P=6 and R=6,
giving 48. Final retained list-node counts are respectively 279 and six.
Temporary finalization and freeing old vector backings do not subtract from
the gross event bounds. Maximum individual backing objects are independent
of those cumulative counts. This packet supplies no aggregate allocation sum.

Each set also makes at most one canonical/first-target GPR.Names request. The
104 such requests were already counted by the accepted baseline and must not
be added a second time. Its 2,405 / 2,443 / 2,467 known requests remain partial.

## Anchored target regexp compilation

GPR allocates `new Pattern_Matcher'(Compile("^" & Val & "$"))` once per target
pattern (`gpr-knowledge.adb:1145`). The largest retained payload is 31 bytes;
the anchored expression has at most 33 bytes. All these values are ASCII.

The bound `96*n + 32` for compiled bytecode is obtained from the complete
`s-regpat.adb` compilation code, not Python's regexp compiler. A 3-byte node is
emitted at `:583–594`; a character-class bitmap adds 32 bytes (`:548–565`).
The parser consumes a new syntactic atom before each Parse_Piece iteration.
Literal runs may put back the last character before a quantifier, so charging
twice for each source character covers that local rescan as well as each
literal's fixed header. A sufficient charging decomposition is:

| Emission family | Charge in terms of anchored source length n |
| --- | ---: |
| Literal payloads and headers, including last-character rescan | 6n |
| Character classes, including 3-byte node and 32-byte bitmap | 35n |
| Other simple atoms and backreferences | 4n |
| Capturing/noncapturing group open/close nodes | 8n |
| Alternation branch insertion and branch nodes | 6n |
| Empty branches plus final outer EOP | 3n + 6 |
| Repetition operators including non-greedy prefix and WHILEM/NOTHING | 16n |

Their sum is `78n + 6`, below `96n + 32`. These charges intentionally overlap
syntax categories. Parenthesized recursion consumes a source opening delimiter;
alternation consumes `|`; every nonempty piece consumes an atom. Repetition
uses a fixed-size CURLY/CURLYX instruction with encoded min/max, not unrolling
its argument. `Insert_Curly_Operator:661–672` uses seven bytes, plus at most a
three-byte MINMOD and two three-byte loop nodes; `Parse_Piece:1666–1763` accounts
for all quantifier branches. Link_Tail/Optimize modify existing bytecode and
do not enlarge it. `Parse_Literal:1539–1653`, `Parse:835–961` and
`Parse_Branch:1133–1179` contain the remaining emissions.

At n=33 the bound is 3,200 bytes. The Size discriminant plus the six scalar
matcher fields (`s-regpat.ads:653–662`) add 112 bytes, giving **3,312 bytes per
matcher object**. The function's fixed `Dummy(1000)` is at most **1,112 bytes**.
The input String is at most 49 bytes. Program_Size's actual limit is 32,767;
the bound plus one-past/operator intermediates fits. Fewer than 255 capturing
groups fit trivially. A compile has one initial pass and at most one second
pass when the dummy is insufficient (`s-regpat.adb:2004–2038`): at most 558
passes for 279 explicit matcher allocations. Return-value temporaries are
charged separately, with the same matcher object maximum. No regexp matching
recursion or backtracking capacity claim is made here.

## Sorted file sets, directory list and file-input buffers

The prospective recipe retains the same Image overlay and vendor layout.
The parent authorized narrow read-only directory/path metadata as new
configuration evidence. [first-directory-metadata.json](inputs/first-directory-metadata.json)
records the 59 entries in the private first compiler directory;
[effective-path-metadata.json](inputs/effective-path-metadata.json) resolves
exactly the two GPR executables and three KB directories. This is neither a
native execution nor a fresh runtime-corpus capture. The future configuration
must preserve that membership and resolution under the existing overlay
constructor/validator (`scripts/bootstrap.py:268–343`); current metadata by
itself does not prove future stability.

`Executable_Prefix_Path` resolves the selected executable and strips its bin
component (`gpr-util.adb:809–878`). Default_Knowledge_Base_Directory adds
`share/gprconfig` (`gpr-knowledge.adb:4343–4349`). Its canonical prefix is the
existing 113-byte vendor root plus `/libexec/spark`, so the default database
directory is 143 bytes. SPARK's existing frames/gnat2why constructors and
overlay resolution give the other canonical directories, at 139/141 bytes.
The longest base filename is 33 bytes: **177 bytes** for the full path, still
inside the unchanged P188. All exact effective paths are retained in
[phase-inputs.json](inputs/phase-inputs.json).

`Parse_Knowledge_Base:1195–1214` deduplicates the directory list, initially four
String-access slots. The selected processes use one/two/two directories:
one 80-byte initial backing, no growth and one/two/two directory String
allocations of at most 159 bytes. Its retained directories are not cleared
between files.

The file set is Ada.Containers.Indefinite_Ordered_Sets(String)
(`gpr.ads:273`). Each Include of a fresh directory member allocates a five-slot
node, at most 80 bytes, and a String, at most **193 bytes**
(`a-ciorse.ads:374–381`, `.adb:1245–1290`). Its controlled Set header includes
both the outer tag and the tagged red-black Tree: eight scalar/tag slots,
128 bytes (`a-crbltr.ads:44–50`). Base members are unique and the sorted set is
not copied. Peak nodes per directory are 63; gross node and String events are
63/64/64 by phase. GPR clears each directory's set, without reducing gross
events. Each top-level file allocates and frees a Shortname String with at
most 33 payload bytes, hence 49 bytes. Ada.Directories Search_Type and its
native enumeration buffers are separate outstanding OS/container objects.

`input_sources-file.adb:35–125` allocates exactly the fixed file length (or one
byte for an empty file). The maximum top-level input is linker.xml at 60,282
bytes; the maximum referenced external entity is vxworks.ent at 17,183 bytes.
The largest individual file buffer is consequently **60,298 bytes** with the
ordinary String allowance, and length/one-past values fit Integer.

The new offline XML expansion records 151 external-file references in the base
database; neither phase addition introduces one. XML/Ada's external-entity
branch creates File_Input and calls Open at each such expansion
(`sax-readers.adb:2643–2693`), with no custom resolver in this GPR reader.
Thus these fixed-file buffer allocations have gross bounds 214/215/215,
including 63/64/64 top-level opens. The exact external input sequence is
retained per phase; freed entity buffers are not subtracted. This closes the
enumerated buffer objects, not the File_Input record, public/system-id strings,
internal String_Input objects or the remainder of XML/Ada parser storage.

## Predefined attribute/package sets

The accepted baseline supplies 216 Add_Attribute and 19 Add_Package calls.
`gpr-attr.adb:178` inserts into Attr_Set; each Add_Package clears Attr_Set and
inserts into Pack_Set (`:233–234`). Both use Ordered_Sets(Name_Id), whose node
has Parent, Left, Right, Color and inline Element (`a-coorse.ads:358–364`).
There is one node allocation per successful insertion and no separate element
allocation. Gross allocations are at most 216 and 19, each node at most
80 bytes, each set header at most 128 bytes. Peak nodes are bounded by the
same respective totals, even though the 19 clears lower Attr_Set's actual
peak. Finalization/clears do not erase gross allocation events. These two sets
are now joined; other startup maps/sets remain separate.

## Mandatory remaining parser and discovery work

Schema.Dom_Readers.Tree_Reader derives from the validating reader.
`schema-readers.adb:1116–1117` calls Initialize_Symbols and Initialize_Grammar
**before** testing Schema_Validation_Feature. Initialize_Grammar creates the
grammar/NFA, predefined types, XML attributes, two UR-type NFAs and calls
Add_Schema_For_Schema (`schema-validators.adb:1263–1430`). That routine parses
the embedded Metaschema through a nested Schema_Reader even when validation
is disabled (`schema-validators-xsd_grammar.adb`).

The exact embedded literal is retained as [metaschema.xml](inputs/metaschema.xml):
32,248 bytes, 685 elements and 884 attributes. Its String_Input Open receives
an access to the literal. The nested parser, symbols, schema type/attribute
tables, NFA states/transitions, DOM nodes and vectors, SAX buffers/attributes/
entity records and namespace/id objects still need numerical source-derived
allocation bounds. These input counts are not themselves those bounds.

The authorized first-directory metadata and fixed compiler regexps yield ten
matching descriptions and 14 description/filename pairs, using only gcc,
x86_64-pc-linux-gnu-gcc, x86_64-pc-linux-gnu-g++ and gnatls. Exact descriptions
are in [candidate-descriptions.json](inputs/candidate-descriptions.json).
This finite inventory makes the next discovery obligation concrete, but it
does not bound query output or establish the successful batch callback.
GPR gets target/version/variables/runtime information before that callback
(`gpr-knowledge.adb:2310–2454`); an explicit RTS does not bypass those queries.

The remaining query families are GCC `-v`, `--version`, `-dumpmachine`, one
`-mno-cygwin -dumpmachine`, and `gnatls -v --version`. GNAT's runtime patterns
also traverse relative lib/lib32/lib64 gcc(-lib) and target/gnat directories.
Get_Command_Output_Cache retains whole outputs (`:1933–1968`). Required next
steps are source/static-input bounds for those outputs, finite directory
membership for the runtime traversals, and a proof that GNAT's successful
selection stops before unconstrained later PATH directories. The final
selected configuration alone does not prove that earlier unsuccessful
candidates did no work. No large vendor download, child execution or new
capture is imposed as a prerequisite.

Other remaining joins are nonparsed GPR.Names (including prior capacity and
later process/ALI requests), remaining startup/hash/list/comment/OS objects,
Gprconfig's full compiler-description/configuration containers and generated
output, and separate GNATprove GPR2. Later Main/fixed-report and native storage
joins retain their other owners. #212/#119 remain open.

## Validation and monitoring

The author selected GPT-6 Astra / Extra High; runtime model/effort confirmation
and token/cost telemetry are unavailable. The unit began at
2026-10-24 09:30:28 UTC. The focused offline checker verifies the exact new
source/input pins, target/fallback and external-input reconstruction, directory
candidate extraction, metaschema literal and numerical object guards. Source
branch receipts support the manual argument; matching snippets are not a
standalone proof. The check does not replay any successful predecessor checker,
parsed-project baseline or all-package selector.

The first focused check found a handwritten candidate-pair total of 15 where
the retained inventory contains 14. Its exact reconstruction comparison had
already passed. Only that expected/exported total changed; the inputs and
capacity formulas were unchanged. The failed checker/manifest and receipts
are retained in `first-check/`. The corrected check passed in **0.403203
seconds**, checking ten provider files and 35 complete selected sources.
The exact result is recorded in `result.json`, `check.stdout` and
`check.stderr`. No target, compiler, prover, Lean, native
service, capture, runtime-corpus rescan, GitHub write or publication was run.
Independent review of the frozen author commit remains pending.
