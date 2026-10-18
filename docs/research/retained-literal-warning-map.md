# Literal warning-map transfer and original-gigi dependency

2026-10-18, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). This packet derives
the warning map's allocation/counter transfer and exhausts the warning-copy
routes in the selected initial gimplification. Its incoming original-gigi
request count remains a named dependency. It does **not** close original gigi,
the complete gimplifier, the collector or whole-pipeline capacity.

The [callable and offline evidence](../evidence/retained-literal-warning-map-20261018/README.md)
pin complete source files at GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Relevant installed-tool behavior
matching these sources remains the existing explicit premise. There is no
tool change, native run, new admission restriction or aggregate RAM gate.

Use the aggregate's **actual selected recognizer**: exactly one
`with Silver_IO;`, the Main/SPARK shell, qualified literal Put/Put_Line calls
and null statements, with C >= 1 calls and N >= 0 nulls. Repeated context/use
clauses are outside this selected family. Each literal length is at most
INT_MAX. Reuse the reviewed local-declaration/metadata exhaustion, occurrence
weight W <= 9C+3N+1 and selected 8C helper subtotal from the
[native-ingress packet](retained-native-ingress-bound.md); no term below
replaces or repeats those tree/vector requests.

## Warning operations and the incoming prefix

`nowarn_map` is a rooted `hash_map<location_hash, nowarn_spec_t>`
(`gcc-diagnostic-spec.h:144–147`, `.cc:121`). `location_t` is 64 bits on the
selected configuration; `nowarn_spec_t` has one unsigned-int field. A map
entry is therefore **16 bytes**, including alignment, not an eight-byte
pointer. The control has only its inline hash-table state; **64 bytes** is
a conservative LP64 ceiling including the optional checking pointer
(`hash-map.h:40–46,312`; `hash-table.h:595–642`). GATHER_STATISTICS is zero in
the retained configuration; allocator/statistics configurations outside that
projection need their own bookkeeping.

`suppress_warning` rejects reserved locations, otherwise calls
`suppress_warning_at`. That function first looks up the location: an existing
entry is modified in place; a missing entry can create the map at request 32
(prime **61**) and call `put` once (`warning-control.cc:153–183`;
`gcc-diagnostic-spec.cc:150–181`). All-warnings suppression is a nonzero
bitset and can populate the map. Neither `-w` nor the later access-warning
pass gates imply an empty map.

Tree/GIMPLE `copy_warning` performs at most one put, or one remove, and does
not create the map. Location-to-location `copy_warning` has the same
property, **without consulting a tree/GIMPLE no-warning flag**
(`warning-control.cc:190–220`; `gcc-diagnostic-spec.cc:207–230`).
`put_warning_spec_at` is the remaining explicit map-creation route, used for
streamed dispositions; selected native non-LTO gimplification does not stream
trees. No warning API independently reserves a larger table, empties the map
or resets its root. Reserved locations 0 and 1 are respectively the empty
and deleted sentinels (`input.h:28–64`); public insertion paths reject them.

The retained prefix ends immediately before `Compilation_Unit_to_gnu`. Its
hardware-counter replay covers every positive GGC request and reports a
largest rounded request of **65,536 bytes**. Consequently any already existing
warning-map backbone has at most 4096 entry positions, hence at most
**4093**, the largest available prime in that range. Use

```text
P0 = 4093
incoming capacity <= P0
incoming live <= incoming occupied <= P0
incoming deleted <= incoming occupied.
```

This is a conservative incoming-state ceiling, not a measured population or
claim that the map is nonempty. It derives from backing bytes, **not** from
the prefix's 39,257 allocation events: map entries do not allocate individually.
Existing prefix requests must not be charged a second time.

The transfer uses the previously established literal fixed-prefix projection.
Its variable filename identifiers, association arrays and source-map setup
do not invoke a warning mutation API (`trans.cc:320–363`;
`utils.cc:430–450`); the four Standard roots and fixed builtin setup retain
their semantic/location projection. Standard locations map to the reserved
BUILTINS_LOCATION (`trans.cc:11006–11018`), independently of Main's line-map
offsets. The source argument does not transfer the largest request to variable
metadata arrays or to **post-prefix** translation. It transfers only warning
map state under that fixed sequence/projection. The existing complete
behavior/source premise and prefix argument remain required; this packet
does not establish binary provenance anew.

## Original-gigi demand: what is known and what is still required

`gnat_pushdecl` calls `suppress_warning(decl)` for generated entities or
Warnings_Off **before** replacing the declaration's location from its GNAT
node (`utils.cc:954–965`). The common constructors initially pass
`input_location` to `build_decl` (`utils.cc:2919,2954,3053,3663,3705`).
`gnat_to_gnu` and `gnat_to_gnu_entity` set that location from the current
GNAT node (`trans.cc:6540`; `decl.cc:505`). Thus even an artificial type
with no GNAT entity can inherit a real source location and insert a map
entry. A final declaration-location inventory alone misses the relevant
location at the suppression call.

The reviewed local inventory supplies at most **2C+N** such calls: the literal
index and array TYPE_DECLs and the possible null LABEL_DECL. Each suppresses
at most once at this site and can cause at most one put. No claim about fresh
keys is needed: local locations can coincide with each other or with existing
entries. The imported declarations are global, but global scope does not
prevent `gnat_pushdecl` from suppressing warnings.

Define **R** to bound all other `nowarn_map->put` executions between the
prefix stop and entry to Main's `gimplify_body`, excluding only those 2C+N
local declaration suppression calls. Include replacements, not just fresh
keys. The required original-gigi input is

```text
I = 2C + N + R.
```

R is an event bound to be derived from the selected source routes, not a
runtime observation, a guessed fixed multiplier, or another source cap. Its
concrete frontier is:

| Producer | Required accounting |
| --- | --- |
| Unit scaffold, Main, empty elaboration function and forced dummy | Their declaration pushes and any intervening shared helper mutations; these are outside the local literal TYPE_DECL/LABEL_DECL inventory. |
| At most two imported Silver_IO procedures and Standard.String/Character/index/profile dependencies | `decl.cc:507–517,4239–4252,5012–5020`; `utils.cc:2935–2963,3703–3769`. Existing entity sharing prevents treating each call as an independent full imported type graph, but a counted traversal of the fixed global/helper declarations is still needed. |
| Fixed one-with namespace path | `trans.cc:6427–6440,6455–6515,8333–8339`. Its map hit guard avoids repeated namespace creation. There is no selected use clause. |
| Original global type construction and folding | Any further declaration creation or warning mutation in the transitive helpers; unlike the reviewed **local** metadata, the imported unconstrained profile contains bound placeholders and has not been exhausted by that packet. |

The only direct suppress-warning sites in the retained Ada gcc-interface
sources are `gnat_pushdecl` and the gimplifier's scalar NULL_EXPR hook
(`trans.cc:9420`); the latter is excluded below. This does not by itself
exhaust language-independent callees. In particular, `fold_truth_not_expr`
copies dispositions when inverting a comparison (`fold-const.cc:4650`), and
the conversion folder suppresses a COMPOUND_EXPR when extracting an assignment
from a converted MODIFY_EXPR with constant RHS (`:9368–9380`). The selected literal address proof excludes them for its
address subtree; extending that proof to every original imported/global type
helper is part of R's remaining obligation. The fixed prefix cannot pay
these post-prefix events.

This is the irreducible dependency retained by the callable. Omitting R
returns no complete incoming-population, request-event or fit result. An
explicit numerical R enables the **conditional transfer**, while the flag
`original_gigi_source_count_closed` stays false. Supplying zero is a
hypothetical substitution, not evidence that these routes allocate nothing.

## Selected initial gimplifier warning lifetime

The endpoint here is the initial GIMPLE body before CF lowering. Later
`gimple_set_block`/location changes belong to their consuming phase.

The direct interface remains **C+1** tree-to-GIMPLE `copy_warning` calls:
C direct call builders (`gimple.cc:385–431`) and the one bare return
(`gimplify.cc:1874–1889`). The following source projection exhausts additional
warning routes in the selected initial lowering:

| Route | Selected disposition |
| --- | --- |
| Whole-body and materialization unsharing | `mostly_copy_tree_r`/`copy_tree_r` use `copy_node` and constructor-vector copying, not the inline-remapping warning callbacks (`gimplify.cc:944–973`; `tree-inline.cc:5735–5795`). No map operation. |
| Temporary VAR_DECL creation | Uses `create_tmp_var_raw`, not `copy_var_decl`; only the latter calls `copy_warning` (`gimple-expr.cc:375–397,439–466`). No suppression of the fresh descriptor. |
| Local type/declaration sizes and Ada RM roots | The accepted ingress proof makes these null/constant. No recursive warning-bearing expression, NULL_EXPR, SAVE_EXPR or variable-size allocation is reached. |
| Constructor stores | Nonempty fat record and pointer fields, including empty literal data; not empty types, complex part assignments or comparison RHSs. Therefore `gimplify.cc:7296,7406,7601` do not mutate warnings. |
| Conditional, nonvoid return, cleanup and EH filter | No COND_EXPR, return value, conditional destructor cleanup or EH_FILTER_EXPR: exclude `gimplify.cc:1948,1962,5728,8529,20903`. The bare return remains counted above. |
| Ada NULL_EXPR hook | Absent from the retained body and constant/null local metadata; exclude `trans.cc:9420`. |
| Selected pointer/address and GIMPLE folding | Reuse accepted address-shape and zero-replacement dispatch results. Conversion suppression requires a MODIFY_EXPR operand, absent from ADDR of literal STRING_CST and global bounds-pool VAR_DECL. No comparison negation is reached. |
| Location setters | Additional bounded demand below. |

`gimple_set_location` calls the location overload of `copy_warning` whenever
the **old stored value** is not UNKNOWN_LOCATION (`gimple.h:1959–1964`).
Every newly allocated tuple is cleared (`gimple.cc:168–183`). Ordinary first
assignment/label setters therefore add no warning copy. Annotation sets only
missing locations (`gimple.cc:1485–1519`); selected noncall tuples start at
plain UNKNOWN and have no intermediate block-location assignment. Once they
have a nonunknown ordinary locus they are skipped; repeated annotation of a
still-plain UNKNOWN likewise performs no warning copy.

There is one additional possible call per output: `gimple_build_call_from_tree`
first calls `gimple_set_block`, then `gimple_set_location`. Combining UNKNOWN
with a nonnull block can produce a nonzero ad-hoc location with unknown pure
locus (`tree.cc:14936–14942`; `line-map.cc:175–225`). The second setter can
therefore copy/remove a disposition even before the explicit tree-to-call
copy. Charge **C** extra insertion-capable calls without assuming TREE_BLOCK
is null or that the temporary location has no existing map entry. The final
call location has its source locus; later initial-gimplifier annotation does
not reset it. Stores, labels, binds and the bare return have no corresponding
two-step construction. `gimple_build_bind` stores its lexical block in its
own bind field, not through `gimple_set_block` (`gimple.cc:635–644`).

Thus **J = 2C+1** is a sufficient selected warning-mutation demand, split
into C+1 direct and C transitive calls. It is not an exact insertion count.
The earlier direct C+1 claim is preserved; it was not labeled a complete
warning lifetime. None of these copies creates the map, so the selected
gimplifier adds no map control or finalizer on its own.

## Conditional map requests, growth and counters

Given R, use I above, J=2C+1, and

```text
A_in  = 4093 + I
A_out = 4093 + I + J
p_in  = prime(max(4093, 2*A_in))
p_out = prime(max(4093, 2*A_out)).
```

Here prime chooses the first retained GCC prime at least its argument. These
conservative ceilings cover both capacity and live/occupied state. At every
put, occupied increases by at most one; removal increments deleted without
increasing occupied, tombstone reuse decrements deleted, and rehash removes
tombstones. Thus occupied <=4093 plus preceding puts, including repeated-key
and delete/reinsert histories. The actual table keeps at least one empty
slot under its pre-insertion load policy; an envelope equal to 4093 does not
assert an actually full 4093-slot table.

`put` uses INSERT lookup, whose load test happens **before** equality lookup
(`hash-map.h:168–186`; `hash-table.h:1029–1102`). Each put can allocate at
most one replacement backbone, even on a hit. `expand` either keeps the old
size or selects prime(2*live), moves entries, then frees the old GGC backbone
(`hash-table.h:833–905`). Its temporary old/new coexistence is real; the
per-request bound is not a peak-live-memory assertion.

The local sufficient predicate reuses the established hash argument:

```text
A_out <= 1,073,741,823
p_out <= 2,147,483,647
2*p_out - 3 <= UINT_MAX
16*p_out <= PTRDIFF_MAX.
```

The capacity/occupancy/deletion fields and load products are size_t (64 bits):
3p, 4occupied, 2live, element-byte products and pointer spans fit. The probe
index and secondary step are 32 bits, hence the separate 2p-3 condition.
`too_empty_p(unsigned)` multiplies by eight in unsigned arithmetic; its
modular result chooses between two already bounded resize branches. It need
not be forced to mathematical arithmetic. Search/collision counter wrap is
likewise defined and does not affect storage or key equality. Hash truncation
of 64-bit locations affects collisions only; equality compares full keys.

Each backbone requests at most **16p** bytes. For the sufficient region this
is at most 34,359,738,352, rounded by GGC to at most **2^35 bytes**. The
rounding order fits the selected allocator table. The bitset has no heap
payload or destructor, and entry destruction only destroys that inline value.

| Post-prefix requests | Count ceiling | Individual request ceiling |
| --- | ---: | ---: |
| Original-gigi map control, if first creation occurs there | 1 | 64 bytes |
| Original-gigi initial/replacement backbones | I | 16 p_in bytes |
| Selected gimplifier replacement backbones | J | 16 p_out bytes |

The first original-gigi put can create the control and its initial backbone;
that newly created empty 61-slot table cannot expand on its first put. This
is why initial backing plus growth is bounded by I, not I+1. No root reset
or independent reserve is used. The map control has a nontrivial hash-table
destructor, so first creation adds **one singleton-finalizer registration**
(`ggc.h:180–201`; `ggc-page.cc:1331–1346`). Entry backbones add none. Shared
finalizer-vector backing, page allocation, collection and global counters
remain in the collector join, not silently in the 64-byte control request.

The returned additive GGC-event ceiling is **1+I+J** when R is supplied
(C>=1 makes I positive), with at most one singleton finalizer. Prefix events
are excluded. Request sums, if used for collector accounting, are sums of
requests rather than aggregate resource gates. This component adds no tree,
declaration/type UID or identifier allocation.

R's source derivation and the remaining compiler lifetime are still open.
The useful next step is the bounded fixed imported/global gigi declaration
and folding projection named above, then substituting its proven event count
and composing this transfer once with later location-changing phases.
