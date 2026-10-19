# Selected literal Ada remainder audit and named closures

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
