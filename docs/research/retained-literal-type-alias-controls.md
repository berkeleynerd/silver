# Literal String alias graph and its child-map controls

2026-10-19, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
The completed String descriptor graph contributes at most **five further
type-derived alias IDs, four alias-entry records, two child-map controls and
two child-map backings**. The fixed-frame alias contributes at most one more
ID. Together these rows add **14 GGC requests** including six possible alias
vector replacements, and **two scalar-finalizer registrations**. These are
upper bounds; in particular the thin-object record is allowed conservatively
even though the selected executable expressions do not use a thin object.

The [offline packet](../evidence/retained-literal-type-alias-controls-20261019/README.md)
closes this specific graph and the canonical-pointer calls it induces. It
does not claim a complete enumeration of every later type/cache/identity
consumer or every scalar-finalizer owner. The global endpoints, collector
total and whole-pipeline capacity remain open. No admission, invocation,
Oracle or production-tool change follows.

## Boundary and existing ownership

Retain the accepted one-with, declaration-free Main/SPARK family with C >= 1
qualified literal Put/Put_Line calls, N >= 0 nulls, D distinct callees and
each decoded length <= INT_MAX. Retain GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, its installed-behavior premise,
the selected Linux SysV generic O0/no-debug/no-LTO/no-offload configuration,
and the reviewed `-fsplit-wide-types` design route. No native run is made here.

The existing [String constructor packet](retained-literal-string-layout-storage.md)
already owns the Integer alias copied to Positive, including two possible
alias-vector pushes and no entry/child map. The existing
[Main constructor packet](retained-literal-original-main-storage.md) owns
XUA's alias and its copies to all literal subtypes, again with two possible
pushes and no entry/child map. Their four-push allowance includes possible
cold sentinels. The resulting vector is nonnull: C >= 1 ensures at least
one completed original alias construction. No later sentinel is charged.

The original type/field/pointer nodes, scalar constants, pool declarations,
descriptor declarations and direct MEM/RTL objects stay in those owners.
The separate native `reg_base_value`/`new_reg_base_value` vectors are not
the `alias_sets` pointer vector. The frame row below charges only its new
alias ID/vector push, never its already-owned MEM or mem_attrs requests.

## The graph is fixed by String construction

Use XUP for the fat descriptor record, XUB for the bounds record, XUA for the
unconstrained array representation, and XUT for the thin-object record.
These are semantic labels even when the selected GDB encoding uses another
debug name. The cold conversion creates one of each, not one per literal
(`decl.cc:2280–2292,2367–2381,2426–2438,2532–2555`).

| Node queried by `get_alias_set` | Additional alias IDs | Entry records | Child-map controls | Child keys |
| --- | ---: | ---: | ---: | --- |
| XUB | 1 | 0 | 0 | none |
| pointer to XUB | 1 | 1 | 0 | none |
| pointer to XUA | 1 | 1 | 0 | none |
| XUP | 1 | 1 | 1 | the two pointer aliases |
| XUT, conservatively allowed | 1 | 1 | 1 | XUB and the already-owned XUA alias |
| **Total** | **5** | **4** | **2** | **at most two per map** |

XUB's LB0 and UB0 fields are created with addressable=0
(`decl.cc:7320–7333`). This flag is not accepted blindly: `create_field_decl`
would promote it to addressable if the type were unsuitable
(`utils.cc:3357–3369`). The accepted String scalar-ABI argument establishes
that signed-32 Positive is neither must/default-pass-by-reference nor an
aggregate (`utils.cc:6347–6371`), so both fields remain nonaddressable.
The ordinary aligned layout does not introduce a bitfield or change them
back. `record_component_aliases` visits only addressable fields
(`alias.cc:1253–1323`); XUB therefore has no child edges and does not query
Positive's alias through its components. A direct Positive query would
reuse the already-owned Integer alias.

XUP's P_ARRAY and P_BOUNDS fields are explicitly addressable=1 for foreign
language compatibility (`decl.cc:2367–2381`). At completion P_ARRAY is a
default pointer to the completed XUA, replacing the temporary void pointer;
P_BOUNDS is the already-built default pointer to XUB
(`decl.cc:2289–2292,2508–2514`). The cold conversion does not alias-query the
temporary void-pointer field: its accepted alias ledger contains only the
Integer/Positive operation. The later descriptor graph uses the completed
fields. This is why replacing its child-map demand by zero would be unsound.

XUT has two explicitly addressable fields, BOUNDS:XUB and ARRAY:XUA
(`utils.cc:4562–4583`). Its descendants have no children. Allowing an alias
query of this existing record adds one entry/map and two keys without
creating another copy of XUB or XUA. The selected literal arrays inherit
XUA's known alias through ALIAS_SET_COPY; their ARRAY component-recording
arm is empty (`decl.cc:3181–3191`, `utils.cc:2005–2070`,
`alias.cc:1325–1335`). The generic trailing `record_component_aliases` in
`relate_alias_sets` is included in that statement, not overlooked.

## Query roots and canonical pointer reuse

The following selected clients motivate the closed graph above:

* Initial constructor preevaluation may query the descriptor LHS even when
  its two address values are constants (`gimplify.cc:6668–6678`). The
  subsequent preevaluation helper stops immediately on a constant value
  (`:6005–6012`). A constant address is not a dereferenced array element.
* Pool `make_decl_rtl` attaches attributes to the literal-array or XUB
  declaration. It explicitly skips `set_mem_attributes` for FUNCTION_DECL
  (`varasm.cc:1675–1678`); a direct callee's FUNCTION_MODE MEM is not another
  alias root. The earlier pool/type-identity argument also establishes that
  readonly pool storage does not construct a qualified record type.
* The two component stores can query their addressable pointer-field types
  even when the target is a register (`expr.cc:6350–6359`). Scalar bounds
  initializer handling, if queried, uses the already-owned Positive alias.
  Whole-record attribute queries stay inside XUP/XUB. The actual literal
  pointer used as an address value is not an extra pointer-valued memory
  object: the store LHS type is the completed P_ARRAY field type.

These clients use the accepted original/initial-GIMPLE/expansion shapes;
the helper bodies contain only scalar parameters and results and never
reach RTL. They do not turn range domains, Character's debug type, each
literal's address-pointer type, or function-pointer types into component
alias roots. This packet closes alias construction for the listed graph;
it does not use this client list as a whole-program census of every later
type-query API.

`get_alias_set` first canonicalizes and returns known aliases, and stores
the result before recursively recording components
(`alias.cc:919–982,1147–1166`). The maps are held by the rooted `alias_sets`
vector, not by a deletable cache (`alias.cc:267,855–865,1171–1177`). They
cannot disappear and be recreated between equal queries. No selected
operation resets these graph types' aliases or changes their field graph.

The pointer canonicalizer still executes at O0; `-fno-strict-aliasing`
does not disable type construction (`alias.cc:873–880,1035–1131`). Both
pointer roots here have exactly one pointer layer. XUA has complete layout
and nonaliased Character components, so the unnest loop stops at XUA;
it does not descend to Character. XUB is a record and also stops the loop.
Both pointed types are unqualified self-canonical types established by
the accepted cold-construction argument. Rebuilding the one default pointer
therefore finds precisely the pointer already linked in TYPE_POINTER_TO
(`tree.cc:7198–7264`). The check precedes `make_node` and `layout_type`.
The resulting demands are **zero type_UID increments, zero type-hash or
integer-cache requests, and zero pointer-layout constants**. The inline
eight-element reference vector never grows and the reference-builder arm
is not selected.

Two other later calls are also closed locally. Bounds-address
materialization reuses its preexisting pointer, as the accepted gimplifier
helper proof already establishes. `expand_call_stmt` requests a pointer to
each existing callee function type (`cfgexpand.cc:3131–3140`); that same
type's default pointer was used by the original ADDR_EXPR. With unchanged
direct calls, this is another cache hit before type construction. Finally,
the non-LTO/non-offload `free_lang_data` path returns before its standard
integer alias sweep, type-copy walk and gimple type construction
(`ipa-free-lang-data.cc:1126–1156`). These zeros are local consumers, not
a claim that the complete type counter or every tree cache is now closed.

## Entry, map and frame requests

`init_alias_set_entry` allocates one trivially destructible record and stores
it in the existing alias slot (`alias.cc:855–865`). The selected LP64 layout
is 16 bytes: int32, three booleans/padding and one pointer. Pointer aliases
receive an entry to hold pointer flags, but no children; record aliases get
an entry when a subset is first recorded.

`record_alias_subset` creates `hash_map<alias_set_hash,int>::create_ggc(64)`
only once per superset (`alias.cc:1193–1243`). Each of the two eligible maps
has at most two distinct keys. Neither its pointer children nor XUB/XUA has
descendants to copy. Alias zero, if encountered, only sets a boolean or
recurses into the same already-described childless graph. The int/int pair
is eight bytes; the initial request64 selects prime127, hence **1,016 caller
bytes / 1,024 rounded bytes** per backing. The 48-byte control rounds to64.
No pre-hit growth, traversal resize, clearing, deletion or rehash operation
is selected: `4*2 < 3*127` throughout, and this graph uses only put/get on
the maps. Repeated queries cannot make the occupancy or history grow.

The map control's embedded hash table has a nontrivial destructor, so
`create_ggc` registers one scalar finalizer (`hash-map.h:155–162`,
`hash-table.h:728–753`, `ggc.h:175–200`). Its backing uses the raw cleared
allocation path and adds no typed-array finalizer. Entry records have
trivial destructors. The two controls thus add **two scalar registrations,
zero array registrations**, and no other constructor here registers one.

Independently, `gen_frame_mem`/`gen_tmp_stack_mem` call the process-wide
`get_frame_alias_set`; its static cache allocates at most one ID
(`emit-rtl.cc:883–902`, `alias.cc:1376–1386`). This ID has no associated
entry, child map or type. It adds one alias-vector push even when O0 later
discards alias attributes. This row does not price the callers' MEMs.
Other direct native alias sources (spill-slot, GOT, sanitizer/setjmp and
hardening machinery) are outside this bounded row; their global exclusion
or demand remains a separate complete-lifetime obligation.

## Additive export and remaining joins

| New request owner | GGC events, at most | Individual caller / rounded bytes |
| --- | ---: | --- |
| Four alias-entry records | 4 | 16 / 16 |
| Two child-map controls | 2 | 48 / 64 |
| Two initial child-map backings | 2 | 1,016 / 1,024 |
| Alias-vector replacements for five graph IDs and one frame ID | 6 | 8,388,608 / 8,388,608 |
| **Disjoint total for these rows** | **14** | no aggregate RAM sum |

The alias-vector calculation reuses the accepted pure `gc_vector` transfer
with original incoming occupancy/capacity upper414851 and **4+6 pushes**.
It yields occupancy414861, normalized capacity1048575 and alias-ID projection
414860. This is a projection for these joined owners, not a full global
alias endpoint. The packet exports only the six new replacement events;
the original four are not added twice. Native signed/unsigned length,
growth, capacity, request-span and allocator-order guards are retained.

The scalar registration projection joins original5, named-later6,
RTL-controls5 and this graph2 once each: prefix39257 plus18 registrations
is39275. The accepted heap-vector transfer gives capacity58911 and an
individual ordinary backing ceiling942584 bytes. Only two additional
ordinary backing requests belong to this packet. Other controls and array
finalizers still prevent a complete finalizer/collector endpoint.

The existing type-counter projection `2295+6C+5D` receives zero from the
proved pointer hits and graph alias clients. Other later type/identity
consumers remain explicit residuals. In particular the next integration
must finish the type/integer-cache and global-declaration/statement-list
writers, exclude or price other direct alias sources, and reconcile the
remaining typed controls before setting any global lifetime flag. The
focused checker verifies exact source/input pins, the source recognizer,
the additive ownership and native arithmetic; the graph and reachability
reasoning remains a handwritten source argument for independent review.
