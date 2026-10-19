# Selected literal Ada remainder audit and named closures

The original partial audit is preserved below. The additive completion section
now reconciles all120 fixed-table owners and closes the selected Ada remainder;
its complete flag remains conditional on the existing source interfaces.

2026-10-19, owner-resumed [#145](https://github.com/berkeleynerd/silver/issues/145)
within [#119](https://github.com/berkeleynerd/silver/issues/119). This audit closes
several named Ada representations, but **does not establish complete Ada
frontend capacity**. It finds a concrete missing prerequisite: the current
actual-source join's named table owners do not exhaust even the accepted
120-counter fixed-runtime census. Fixed semantic/local traversal also lacks a
complete per-object/caller partition. Those gaps cannot be replaced with a
Boolean assumption that the frontend is complete.

The [evidence packet](../evidence/retained-literal-ada-residual-completion-20261019/README.md)
provides the arithmetic, precise current-owner reconciliation, exact source
pins and focused checks. All source coordinates below are literal LF positions;
form feeds remain inside their LF line. GCC is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Independent review is pending.

## Domain and already-owned work

The domain is the complete one-with Main/SPARK shell with C>=1 direct qualified
literal Put/Put_Line calls and N>=0 null statements. There are no declarations,
loops, concatenations, Image calls, nested user scopes, contracts, source
instantiations or arbitrary pragmas. The accepted recognizer consumes all source
bytes. The selected indexed naming configuration, fixed runtime/source roots,
Linux x86-64 LP64 layout, Table_Factor=1 and complete pathname bound P=512 are
unchanged. Successful source/installed-tool correspondence remains the existing
external interface; this packet adds no new correspondence assumption.

The following are existing owners, not new residual charges:

| Surface | Existing owner / consequence |
| --- | --- |
| Scanner, parser, constructors and core table growth | `selected_native_frontend_storage`, including the actual constructor and scanner transfer; do not multiply them again by source size. |
| Uint/Udigit/Ureal/Repinfo, numeric local vectors and backend callbacks | `native_Ada_numeric` and frontend `components.numeric`; unchanged AST identity counts do not remove callbacks. |
| Indexed physical/runtime union and lines | Frontend `physical_sources`, with 1589 permanent entries and 1590 insertion-capable filename lookups; the spare failed-load slot is separate. |
| Nine virtual `Dope_Rec` records | `frontend_location_join.virtual_Dope_Rec`: each eight bytes, already discharged. |
| Main ALI writer, including lib.Units and its local arrays | `core_result.Main_ALI_interface.Main_ALI_writer`: Units demand 41, 104-byte component bound; six 41-byte arrays, Sdep 168, With 164, Info_Buffer 2112000 and quoted-path 1026 are already owned. |
| ALI consumers and GPR DW reader | Their existing interfaces refer to their own consumer processes; they do not silently price every separate Main-process table instance. |
| Shared GCC identifiers, locations, queries and late backing | Existing corrected frontend/location and shared-query lifetime joins; this audit adds no GCC owner or GGC event. |
| Driver, binder, linker and parent | Separate assigned work; no claims or recharges here. |

The accepted fixed node allowance is 41234 and the actual Main allowance is
41+19C+4N. Thus n=41275+19C+4N is available as a **node-domain bound**. It is not
an allocation coefficient for arbitrary semantic graph copying. Every older
source/configuration/backing guard remains required, including all 367 keys in
the current accepted attachment. A fixed Hello result is used only to locate
those owners; it is not evidence for arbitrary C/N counts.

## Copy maps and fixed linked records

`New_Copy_Tree`'s two maps are library-level Simple_HTable instances, each with
511 fixed buckets (`sem_util.adb:24064–24125`). Keys and stored Entity/Elist IDs
are four bytes and a next pointer is eight. Each wrapper is therefore 16 bytes;
each bucket array is 4088 bytes on the selected ABI. Hashing is `Key mod 511`,
with index0..510. The iterator tests Table'Last before incrementing its bucket
index (`libgnat/s-htable.adb:40–119`). Linked-chain lookup does not accumulate a
length or convert a chain length to an allocation product.

Simple_HTable.Set creates a wrapper only for an absent key and otherwise updates
the existing payload (`:375–387`). A map's simultaneous keys inject into the
existing node/entity ID domain, hence each map has at most n keys even when the
caller supplies an entity map. **No n*16 array exists.** Each actual ordinary
request remains 16 bytes. Reset walks and frees existing wrappers using pointer
successors (`:357–372`); the next New_Copy_Tree resets both maps before visiting
its source (`sem_util.adb:25567–25624`). No cumulative request count is exported.
This prices the maps even when fixed generic/runtime work populates them.

Pending itypes are additional Elist objects, not data embedded in a wrapper.
`Add_Pending_Itype` creates one list on the first association and appends a unique
itype (`:24342–24372`). The fixed whole-root Elist lifetime and the Main
constructor's pending-copy columns own these objects. They are not recharged.
The selected Main constructor has zero pending-copy columns. General node-copy
phase1 can still follow semantic fields, clone itypes and visit associated
nodes; its recursion is **not** proved by the preceding distinct-key bound.
That separate obligation is retained below.

Exp_Util.Type_Map uses the same 511-bucket/four-byte-ID representation
(`exp_util.adb:106–117`), hence its individual wrapper/bucket bounds are 16/4088.
Its selected Main mapping writers require absent tagged/formal/discriminant/DIC
constructs, as the accepted semantic caller partition establishes. Fixed keys
are permitted; no claim that this map is always empty is needed for its local
representation bound.

Suppress_Stack_Entry has five immediate scalar/pointer fields
(`sem.ads:386–410`); allowing 16 bytes per field gives 80 bytes per real request
at both push sites (`sem.adb:1387–1421`). Its links have no length/capacity field.
Fixed dependency suppression entries are allowed. Absence of Main Suppress,
aggregate-copy and discriminated-iterator constructs removes the variable
writers, but is not used to erase the fixed records.

## Three fixed generic tables and unconditional registry heaps

The accepted fixed-root reduction retains the complete all-roots witness,
including eight fixed generic instances. Its positive lifetime table counts
are Generic_Renamings 16, Instance_Envs 8 and Generic_Flags 4. These are independent
of C/N because Main adds no instantiation/inlining/generic body and the accepted
first-runtime-load/analysis reduction retains the full fixed contribution.
The two naming pattern pragmas and indexed Main naming entry add no generic
construct. No new capture or historical-suite replay is required.

The exact source layouts are (`sem_ch12.adb:999–1128`):

| Table | Low / initial / increment | Component upper bytes |
| --- | --- | ---: |
| Generic_Renamings | 0 /10 /100% |12: two Entity_Ids and Assoc_Ptr |
| Instance_Envs | 0 /32 /100% |512 |
| Generic_Flags | 0 /32 /200% |1 |

Config_Switches_Type contains 26 scalar fields (`opt.ads:2082–2109`), bounded by
26*16=416 bytes. Instance_Env has that record plus six immediate fields, each
at most 16 bytes including the 12-byte Assoc. Thus 512 is an alignment-safe upper
bound. Generic_Renamings' Static_HTable has 37 four-byte Assoc_Ptr headers,
148 bytes, with the links stored in the existing table records.

The existing generic backing envelope yields capacities 32,64,96 and individual
sentinel-inclusive byte bounds 396,33280,97. The source's growth multiplication
is evaluated in Long_Long_Integer before narrowing; low/index/successor and
size_t/PTRDIFF checks remain explicit (`table.adb:128–154,167–218`). These are
three new named table owners, not completion of the fixed table census.

Zero diagnostic messages do not remove package-elaboration allocations.
Errid.Diagnostic_Repository creates nine literal Strings; Switch_Repository
creates 168. Their longest literal is 39 characters, so each request is at most
55 bytes including the conservative 16-byte String descriptor allowance. The
one Diagnostic_Id_Array contains exactly three IDs, at most 28 bytes including
its descriptor. The two fixed registry arrays have ten three-field and
85 six-field elements: padded bounds 480 and8160 bytes. The packet retains
every literal and its exact LF position;
these are actual source constants, not a sampled heap maximum.

Opt also initializes Ada_Final_Name, Ada_Init_Name and Ada_Main_Name with
8-,7-,8-character strings, even though their later mutation is binder-specific.
It creates a four-entry preprocessing String-pointer array before the selected
no-preprocessing switch test (`opt.ads:135–155,1284–1293`). Bounds are 24,23,24,
and80 bytes including descriptor/alignment allowances. No source-level switch
absence is used to discard these unconditional objects.

## Diagnostic, late-name and local traversal partition

The accepted native warning source partition specializes to zero Main attempts
for **every** C/N in this family, not just one Put fixture. There are no loop
warnings; the selected calls, literals and null statements introduce none of
the enabled missing-value/formal/index/unchecked-conversion/contract families.
The fixed input warning inventory has no enabling global warning/style pragma;
its fixed diagnostic counters are zero. Successful legality alone would not
establish this: the source/policy caller partition supplies the exclusion.

The packet prices the eleven initial diagnostic tables from the accepted
source layouts, with zero appended entries. It also retains the fixed 10000-entry
Warnings_As_Errors pointer array. Errout.Output_Messages still creates the
first-filename and `.gnat.sarif` objects before selecting its output mode,
and a 24-byte SARIF_Printer with null list pointers. Their individual bounds
are P+16 and P+11+16; P+12 fits Nat. The default text-mode/empty-chain path
does not construct SARIF lists or rendered warning lines
(`errout.adb:2912–3035`). Backend-created messages need the separately accepted
backend diagnostic route before the whole process can use that empty chain.

The ALI writer's six local arrays, source/name quotation, numeric formatting
and full file extent are already owned, as listed above. The ordinary selected
late Ada names are also source-bounded: literal names are at most 18 characters
including `main__`, fixed parameter names at most 25, and the fixed ordinary
encoded-name envelope is 737. Get_Encoded_Name/Get_External_Name use the existing
bounded buffer without interning more Ada names on these paths; the accepted
original-Main and cold-String source ledgers supply their caller split.
No arbitrary suffix path or diagnostic decoder is admitted by that fact.

`Qualify_Entity_Name` unconditionally declares a String of Name_Buffer'Length,
4*32766 characters, even when it immediately finds an already qualified entity
(`exp_dbug.adb:1214–1240`). Price that actual individual object. Its named
qualification workers recurse through Scope, with their buffer appends bounded
by the existing qualified-name transfer (`:1270–1317,1381–1422`). Namet's
Append_Decoded uses the 4096-character default Bounded_String and a same-length
local String; APIs using Length_Of_Name have at most 32767 characters, separately
from Name_Buffer's larger extent. These object bounds do not imply a safe
physical total stack size.

Main statement repetition is processed through sequential list traversal; C/N
does not nest a call for each preceding output statement. Literal bound queries
and Uint local vectors retain their accepted explicit envelope. The seven
concat arrays and lower-bound recurrence are absent because no source or
generated selected expression is concat. That excludes this family, not all
fixed runtime semantic arrays or semantic recursion.

## Exact unclosed remainder and next source work

The [fixed-table census](../evidence/retained-literal-ada-residual-completion-20261019/fixed-table-census.json)
classifies all 120 retained symbols: 39 have existing owners (including the
separate Main ALI Units owner), 14 are the three generic and eleven diagnostic
tables priced here, and **67 remain unreconciled**. These 67 are obligations to
find an exact existing Main-process owner or supply the missing source transfer;
they are not 67 asserted new allocations. The census is not promoted to a
complete list of every table in gnat1.

This distinction is material: Table.Table's body unconditionally calls Init
at elaboration (`table.adb:413–416`). A zero positive-growth count therefore
cannot remove its initial backing. Concrete positive rows still outside the
named owners include Check_Names 30, Ignored_Ghost_Nodes 21,
Pending_Instantiations 1, Compilation_Switches 5, Load_Stack 121,
File_Name_Chars 204, Unchecked_Conversions 7, Assertion_Levels 3, Externals 11 and
Convention_Identifiers 7. Compilation-switch and pathname rows require the
current invocation transfer, not the old witness's count by itself. Some
zero-growth ALI or driver tables may have an existing owner in another packet;
that must be reconciled by process and actual instance, not an equal table name.

There are three further concrete obligations:

1. Complete fixed non-table/generic-instantiation coverage beyond the maps and
   heaps priced here. An inspection aid over build-listed source units found
   allocator families in Sem_Case, target setup, SCO/optional output and generic
   graph/hash helpers. Some require absent options, but fixed runtime specs
   still contain constructs outside Main's grammar. For example
   `sem_case.adb:3384–3385` allocates Link and increments Num_Choices. Its fixed
   caller closure and choice-count/array backing must be supplied; zero Main
   case statements does not suffice. Optional Atree field-set heaps are behind
   `pragma Debug` (`atree.adb:332–352`): GCC's runtime flag_checking is not by
   itself evidence about how Ada assertions were compiled. Retain or source-join
   their build exclusion/layout instead of assuming zero.
2. Complete fixed semantic/copy/deferred-name **local object and counted-depth**
   partition. New_Copy_Tree follows semantic as well as syntactic fields and
   updates cloned entities (`sem_util.adb:24443–24622,24913–24962`). The node-key
   hash proof above does not establish termination/stack shape of those workers.
   Actual candidate objects include Resolve_Membership_Equality's `Alts(0 ..
   List_Length(...))` (`sem_res.adb:10283–10300`) and discrete-interval workspace
   indexed by Unmerged_Choice_Count (`sem_util.adb:31262–31282`). Establish their
   fixed selected callers, index/successor/product bounds and recursion rank.
   No sum of frames or guessed RAM ceiling may substitute for those checks.
3. Finish the source/owner census itself. The source build list includes generated
   einfo-entities, nmake, seinfo, sinfo-nodes and snames units absent as generated
   files in this retained source directory; generic bodies have their own
   allocation sites. Existing generator/source correspondence can supply these
   interfaces, but a lexical scan of ordinary `.adb` files cannot prove absence
   of every other allocator or dynamic local object. No new binary attestation
   is requested by this gap.

These are open obligations, not new trusted boundaries. `apply` exports only
the named arithmetic when its existing source joins are true; false/unknown
leaves `derived=null`. Its complete-frontend/native flags stay false even when
all named checks pass. There is no caller-settable `remaining_frontend_safe`
premise. The next tractable work is to reconcile the 67 exact symbols against
current Main owners, then price the residual fixed records using the accepted
root reduction and source layouts, while completing the fixed local/generic
caller partition. No native build, capture, compiler/prover/Lean, predecessor
suite, corpus replay or admission change was performed.

## Additive completion of the frozen partial packet

The preceding sections describe the frozen partial result at `d23e7395e3d8`.
This follow-up supersedes its 67-table and fixed-traversal residual status.
[completion.py](../evidence/retained-literal-ada-residual-completion-20261019/completion.py)
exports complete **selected Main-process Ada frontend** storage and local/count
representability conditional on the existing source/configuration interfaces.
It does not establish physical stack/RAM availability, the C/C++ process shell,
other child processes, or complete native/toolchain capacity. Independent review
is pending. No caller can assert that an unexamined remainder is safe.

### The fixed-work projection

The proof is a projection of the already accepted fixed execution and the
complete selected Main constructor/caller closure, not extrapolation from the
Hello example. The fixed native capture reached gigi and the compiler return;
its [README](../evidence/retained-native-fixed-capture-20261018/README.md),
summary and input identities are pinned by this packet. The fixed source
reduction in `retained-native-expansion.md:4258–4385` gives the runtime roots,
once-per-unit analysis, eight fixed generic instances and first-freeze guards.
The accepted literal frontend then retains that entire witness and its explicit
configuration/first-lookup corrections; its fixed node allowance is F=41234.
No fixed witness allocation is subtracted to offset a Main allocation.

This is the same fixed-request acceptance method already used for ordinary
compiler initialization (`retained-native-expansion.md:10910–10938`) and the
binder compiler's preserved semantic execution
(`retained-binder-capacity.md:1384–1415`). It includes fixed objects that no
Table.Last counter measures. Its necessary read projection is explicit:

| Input a fixed semantic worker can observe | Transfer |
| --- | --- |
| Source syntax, declaration order, generic actuals, type completions and semantic flags | Fixed pinned runtime specifications; Main cannot inject names into their reset scope. The once-analyzed guard and first-freeze reduction suppress repeated analysis, rather than replaying a generic for each output statement. |
| Node/entity IDs | An injective renaming preserves kinds, equality, list links, parent relations and semantic references. Changed hash buckets can change lookup probes; they cannot supply a different value for an equal key. Core ID domains retain their existing guards. |
| Numeric cache state | The accepted coherent all-miss fixed trace and numeric transfer retain positive lifetime growth. No local-object proof relies on a cache hit. |
| Outer visibility and current-unit state | Already separated into common scope-save/element-list terms, invocation maps and unit-boundary storage. They are not declared invariant. |
| Serial names, paths, configuration/map contents, source offsets and argv | Existing name/location/scanner/configuration owners plus the explicit path/argument corrections below. Fixed observed spelling lengths are not reused. |
| Main statements and literal values | Main can call only the selected ordinary String-in procedures and has no declaration, aspect, case, membership, aggregate, instance, inline body, type completion or contract. Its actual constructor, numeric and String transfers own these inputs. |

Thus fixed-only semantic workers see the same finite mathematical structures,
up to identity renaming and the separately bounded spelling/location fields.
All fixed local initialization, fixed generic-body objects, linked allocations
and counted traversals remain included in the successful fixed projection.
The result does not require enumerating every transitive fixed helper anew.
The source/allocator inventory is a check on the partition, not its substitute.

### All 120 fixed counters have actual process owners

[completion-tables.json](../evidence/retained-literal-ada-residual-completion-20261019/completion-tables.json)
adds all 67 missing exact symbols to the previous 39 inherited and 14 named
owners. Each row records the literal source declaration, initial count, growth,
lower bound, component layout, demand basis and actual Main-process owner.
`apply` resolves the 39 inherited owners against the fresh frontend record;
lib.Units resolves to Main_ALI_writer, whereas ALI.Units is separately priced
as an initialized Main-process instance. ALI consumer/binder owners are never
substituted merely because their table names match.

The rows group as ALI14, Checks2, Exp_Cg1, Exp_Unst3, Ghost1, Inline5, Lib9,
Osint1, Par_SCO4, Prep1, Prepcomp2, Repinfo4, Restrict2, SCOS3, Sem_Aux1,
Sem_Ch13 2, Sem_Ch8 1, Sem_Ch9 1, Sem_Dim1, Sem_Elab3, Sem_Elim1, Sem_Prag3,
Snames1 and VAST1. The accepted zero-Main caller partition applies to all
fixed-only rows; initial backing remains charged at zero demand. Table.Table
calls Init at actual package elaboration. A local instance is elaborated only
when its enclosing routine is entered.

Most positive fixed rows retain their complete positive lifetime growth:
Check_Names30, Ignored_Ghost_Nodes21, Pending_Instantiations1,
Unchecked_Conversions7, Assertion_Levels3, Externals11 and
Convention_Identifiers7. The two SCO unit tables retain their initialized
sentinel demand1 despite selected no-SCO output. Three demand corrections are
separate from the old capture:

- Compilation_Switches has exactly ten current payloads totaling110 characters,
  checked against `core_result.Main_ALI_interface.stored_native_switches`.
  The current ALI packet already supersedes the old five/six-switch text;
  its serializer owns the corresponding A-record extent. Each copied switch
  String is independently bounded here.
- File_Name_Chars appends each opened non-runtime Source name, plus LF
  (`osint.adb:2685–2703`). Debug printing is not its guard. Charge every one
  of the accepted1580 physical opens, including the repeated indexed-System
  open and even runtime paths, by P+1. This is the accepted request-name/open
  transfer, not a count of distinct inodes. The Load_File cache precedes the
  open (`sinput-l.adb:345–398,418–427`). Failed absent-file lookups return
  before this append. Changed search/alias or retry behavior invalidates the
  existing physical-source interface.
- Load_Stack is a live stack. Its121 observed lifetime increments are not a
  peak argument. At most41 admitted unit records can be active; allow one
  extra already-loaded request, giving demand42. The request pushes before
  lookup and pops on the already-loaded path (`lib-load.adb:672–730`). No new
  Main declaration/body/instantiation can enlarge the unit chain.

Every record is bounded from its fields, with16-byte padding per immediate
scalar/pointer and separately expanded nested arrays/records. In particular,
ALIs.Restrictions has five arrays bounded by the full101-element enum;
Pending_Body_Info includes its26-field configuration,30-check suppression
array and full62-element warning enum; System_Type includes three seven-entry
arrays. `Preproc_Data.Mapping` includes the actual Dynamic_Tables instance
record. No nested record is silently treated as one pointer.
All67 backing checks use the same source-derived growth/sentinel arithmetic as
the partial packet. No new C/N restriction is introduced by these fixed rows.

### Semantic local arrays and recursion

The named examples from the partial packet now have concrete object bounds.
They are fixed-only callers, not arrays whose length grows with C/N:

| Site | Bound and reason |
| --- | --- |
| Membership `Alts(0 .. List_Length(Alternatives(N)))` | At most F+1 two-ID records, padded32 bytes each plus16 descriptor. The source list contains at most F fixed nodes (`sem_res.adb:10283–10320`). |
| Discrete interval workspace and result copies | At most F² intervals,32 bytes each plus16 descriptor. Each direct choice contributes one interval or the length of one Others list; there are at most F direct choices and F nodes per referenced list. Aggregate component choice lists partition their direct syntax nodes (`sem_util.adb:31133–31324`). |
| Case `Choice_Table(0 .. Num_Choices)` | At most F²+1 three-ID records,48 bytes each plus16 descriptor. Direct choices and fixed predicate lists bound the nested enumeration; static-predicate copies remain in the fixed constructor contribution (`sem_case.adb:3535–3576,3637–3830`). Each linked collection record is64 bytes including its next pointer. |

F²=1700242756 and F(F+1)=1700283990 are below signed Int'Last. Count successors
and these individual array byte products fit their actual domains. These large
upper bounds are representability arguments, not requested memory reservations.
Heap_Sort_G guards `C > Positive'Last/2` before `Son := 2*C`, and increments Son
only below Max (`libgnat/g-hesorg.adb:50–148`). Its sifting loops move strictly
toward a leaf or parent; phase two decreases Max.

General fixed New_Copy_Tree does not reduce to a syntactic-descendant count.
Phase1 maps an entity/itype before following its semantic fields
(`sem_util.adb:25094–25158,25243–25357`). A previously mapped entity returns;
ordinary syntax descent requires the source parent relationship, and all
syntax/Elist sibling walks advance their cursor. Elist elements may also be
ordinary nodes, so parent descent alone is insufficient. In the selected fixed
graph, a reachable cycle consisting only of ordinary-node/list transitions
would replay unchanged source fields without a visited-node stopping guard.
The successful fixed traversal excludes such a cycle. Its fixed nonentity
subgraph therefore has height at most F. A rank is the lexicographic pair of
unvisited original entities and remaining height in that fixed nonentity
graph, with finite list cursors as local loop ranks. A semantic transition
that resets this height first removes a previously unvisited entity. This
argument uses the fixed successful projection; it is not a universal theorem
that every possible semantic graph is a syntax tree.
Phase2 looks up entity replacements and copies syntactic descendants; it does
not recurse through replacement entities. Original field references remain
fixed during Phase1. Hash enumeration in the update phase changes no map keys
or source topology. Consequently the fixed counted nesting is conservatively
bounded by F(F+1); successful fixed execution also establishes the required
selected type/parent invariants. This proves no aggregate native stack-byte
bound. Pending Elist objects and node copies retain their accepted owners.

The selected Main has zero general semantic-graph-copy input. Its established
literal/static-bound leaf copying creates no expression-with-actions tree,
generic instance or owned discriminated/composite graph. A String literal's
variable decoded length enters its already bounded String/numeric routines,
not a membership/case workspace. Qualified-name workers follow strict lexical
Scope ancestors; additional statements are siblings, not nested scopes.

For ordinary statement processing, Analyze_List and Analyze_Statements call
Analyze then Next (`sem.adb:873–908`, `sem_ch5.adb:4523–4595`). Atree traversal
likewise finishes a child before advancing the list (`atree.adb:2627–2659`).
Writing only work/depth structure, not elapsed-time or stack-byte estimates:

```text
T(C,N) = T0 + C*Tcall + N*Tnull
D(C+1,N) = max(D(C,N), Dcall)
D(C,N+1) = max(D(C,N), Dnull).
```

The variable total work does not accumulate one active semantic frame per
statement. Local literal queries retain H=4/A=19, with actual digit/character
lengths checked by their numeric/String owners. A fixed dependency entered
from a statement returns before the next statement; outer-scope saves already
include their explicit Main contribution.

### Generic, generated and command-line objects

The [closure owner audit](../evidence/retained-literal-ada-residual-completion-20261019/closure-owner-audit.json)
records312 explicit allocator sites and223 generic-instantiation candidates in
384 build/related source files. This is an overapproximate inspection aid;
generic template declarations are not independent runtime allocations, and
it is not claimed to be an exhaustive semantic call graph.

Allocation owners are the actual instance and Create/elaboration site:

- Modern Sem_Elab's NE_List/NE_Set/NE_List_Map/ECR/UA/ETT/NTS/IR instances and
  ALI.Sig_Map resolve to the existing fourteen invocation hash owners and list
  owners, including initialized buckets at zero pairs. A shared generic body
  does not merge distinct instances. Nested Membership_Sets and generic hash
  implementation allocations are part of that actual owner.
- NCT maps and Type_Map retain the partial packet's wrappers/buckets. Interp_Map,
  UI_Ints, Fmap maps, lib.Unit_Names and Xref static headers retain their prior
  owners. This follow-up adds SFN_HTable's101 eight-byte headers/16-byte wrapper
  and Osint.File_Name_Hash_Table's1021 headers/80-byte padded wrapper, including
  its32-byte aligned File_Attributes. These fixed-header maps have no dynamic
  length field; their keys are existing Name/Unit IDs, and Set replaces an
  existing key without growing a chain.
- Fixed aspect-name registries, generic/private/runtime semantic containers and
  target setup remain in the fixed read projection. Main cannot activate their
  omitted aspect/type/instance writers. Selected no-inline/no-SCO/no-listing/
  no-preprocessing/no-Eliminate options exclude local optional instances;
  library-level Table.Table backing is nevertheless retained. Dynamic_Tables
  starts at its shared empty array; merely declaring its Instance does not
  allocate an initial ten-element heap (`g-dyntab.ads:144–182`).
- Sinfo_Utils.Lists is allocated at Lowest_Common_Ancestor, whose frontend caller
  is goto/label analysis (`sinfo-utils.adb:379–430`, `sem_ch5.adb:1905–1930`).
  Main has neither; any fixed caller remains in fixed semantic work. Diagnostic
  pretty/SARIF list creation is excluded by the established empty-message/text
  route, while its unconditional printer record remains priced.

Generated source is covered through its actual generators and existing
source/installed-tool correspondence. Nmake creates New_Node/New_Entity and
sets fields (`gen_il-gen.adb:2608–2633`); those are exactly the existing
constructor owners. Generated getters/setters access existing fields.
Generated node/entity metadata really allocates `new A` at package elaboration
(`:2188–2249`): each field-sequence array is at most902 padded fields plus16
bytes. There are451 entries in the full generator type enum and902 in the
field enum; generated subtypes cannot exceed those domains. The separate
Seinfo_Tables debug-layout output explicitly says it is not used by the compiler
and is absent from GNAT1_ADA_OBJS; it is not conflated with compiled Seinfo.
Snames' generated convention table is one of the67 reconciled owners.

The optional Atree assertion field sets are conservatively retained: each
array is at most451*902*16+16=6508848 bytes. This closes their layout regardless
of Ada assertion-build selection and does not equate GCC flag_checking with
Ada `pragma Debug`. Their local set-return objects are smaller than the same
bound. Fixed FPT_Mode_Table has1000 six-field records, at most96000 bytes;
its registration inputs and mode-name Strings belong to the fixed selected
x86-64 target projection. No target-description file override is selected.

The driver packet owns C-side child argv construction; this packet owns the
Ada-side copies. At most25 argument positions give a416-byte padded Args
object, and each argument/local copy is at most max(24,P+8)+16 bytes.
Osint's initial Argument_Count+2 name-pointer/index arrays use27 entries:
448 and124 bytes. There is one selected Main source, so Add_File's doubling
branch is absent. The config path allocates one String and one singleton
pointer array, and the mapping/object-name paths allocate their own Strings.
Each path String is bounded by P+16; every selected slice/normalization/join
is conservatively bounded by2P+32+16. The largest such join concatenates two
complete path components and a fixed `rts-`/directory suffix. Complete raw,
normalized and resolved path/environment spellings remain existing invocation
requirements. The search-path-file readers and arbitrary wildcard expansion
are not selected. Runtime/default search String constants and naming-pattern
Strings still allocate and are explicitly priced. File/map source text and
line buffers remain with their existing source/configuration owners.

### Callable interface and verification boundary

Construct `Context(ada_root, repository_root)` once. It checks retained partial
pins, the new source/excerpt manifest, the fixed successful evidence and all
384 source-census identities. Then call
`apply(fresh_predecessor_record, conditions, context)`. The caller supplies the
fresh record produced by the existing complete source recognizer; this small
module does not run a predecessor model or pretend its JSON illustration is a
new source scan. It rejects source/count disagreement, inconsistent literal
counts, changed physical-source populations and a changed saved-switch vector.

The367 retained condition keys must exist and all supplied values must be
three-valued. Any false or unknown supplied condition leaves `derived=null`
and complete-selected-Ada false. Later condition supersets are allowed and
conjoined, including corrected backend guards. The module preserves the full
supplied map and separately reports all pending and retained pending keys.
The final composition owns the derivation of its additional guard values.
Its own residual status is derived from the source partition and object checks,
not a supplied remainder-safe Boolean. All whole-native/whole-toolchain and
physical-resource flags remain false.
