# Literal native ingress: occurrence weight and binding correction

2026-10-18, selected Linux x86-64/LP64 native configuration; research
[#119](https://github.com/berkeleynerd/silver/issues/119), with the binding
accounting repair tracked in
[#130](https://github.com/berkeleynerd/silver/issues/130).
This packet supplies a bounded source argument for Main's whole-body unsharing
input, the retained literal data-address copy, and BIND accounting. It changes
no production code, source rule, option or Oracle guarantee. #119 remains open.
The [offline evidence](../evidence/retained-native-ingress-bound-20261018/README.md)
records exact source identities and exposes an additive callable.

Let C >= 1 count direct literal Put/Put_Line calls and N >= 0 count nulls in
the already established declaration-free, straight-line Main shell. Each
literal has decoded length 0 <= L <= INT_MAX. The current source recognizer,
library semantic admissibility, selected options and whole-unit Main
preservation premises remain those of the
[accepted literal lowering](retained-native-expansion.md#direct-literal-output-source-to-initial-gimple-and-data-operands).
Here **W is ordinary tree occurrence weight**, not the predecessor's sum of
literal byte lengths. No null whole-lifetime allowance is used. The fixed
39,257-event prefix is neither a post-gigi byte bound nor an ingress allowance.

The resulting interfaces are:

| Interface | Source-derived upper bound |
| --- | ---: |
| Whole-body ordinary occurrence weight W | 9C + 3N + 1 |
| Whole-body fresh ordinary tree requests, using accepted 3W transfer | 27C + 9N + 3 |
| Whole-body copied constructor-vector requests | 6C |
| Whole-body GGC requests, trees plus vectors | 33C + 9N + 3 |
| Materialization data-address copy, additional to accepted selected 6C | 2C trees of 32 bytes |
| Selected helper subtotal after that addition | 8C GGC requests |
| GENERIC protected BIND identities / GIMPLE bind tuples | C + 1 |
| Corrected direct gimplifier subtotal, replacing 9C + 2N + 2 | 10C + 2N + 2 |
| Corrected CF block-location calls | 4C + 2N + 2 |

These rows have different ownership. In particular, the last helper subtotal
already contains the accepted 6C; it is not an 8C addition to that subtotal.
Whole-body copying happens before materialization and is a separate addition.
Original gigi constructions, shared caches/maps and complete compiler lifetime
remain separate obligations.

## Retained data address has at most two ordinary nodes

The literal branch builds a STRING_CST and sets its TREE_TYPE to the literal
subtype (`trans.cc:6705–6731`). The type producer makes a nonshared array with
the static literal index (`decl.cc:3142–3193`; `tree.cc:7575–7642`). Taking this
object's address selects the common `build_unary_op` path, then
`build_fold_addr_expr` (`utils2.cc:1712–1732`). For a STRING_CST the latter
builds exactly ADDR_EXPR with a pointer to that array type
(`fold-const.cc:9150–9196`). The special INDIRECT_REF, MEM_REF and
VIEW_CONVERT_EXPR alternatives do not match.

`convert_to_fat_pointer` calls `convert(p_array_type, expr)` for P_ARRAY
(`utils.cc:4794–4894`). Both source and target are ordinary pointers to arrays
of ordinary Character. `build_array_type_1` inherits the element address
space (`tree.cc:7593`); there is no address-space attribute in the selected
String/Character inputs. Neither pointer designates a template record, so
the thin-pointer adjustments in `convert` are excluded. A fat/extended
pointer operand is also absent. Exact type identity returns the input
(`utils.cc:5005–5007`); related types use `fold_convert` (`:5425–5427`);
the normal pointer branch ends in `fold(convert_to_pointer(...))` (`:5533`).
For same-address-space pointer conversion, `convert_to_pointer_1` constructs
a folded NOP_EXPR (`convert.cc:54–74,126–129`).

The generated matcher is part of the exhaustion argument. The retained
`match.pd` has 882 simplify forms when both preprocessor branches are kept.
The check resolves enclosing `for` lists, includes optional outer operators
and extracts all 19 forms whose root can be conversion. The only wildcard
operand pattern is `cvt(@0)` at lines 5721–5725. Its GENERIC condition is
**exact** `type == TREE_TYPE(@0)`, and its result is the same operand. It
cannot enlarge the address subtree. All other candidates require an operand
whose root is different from ADDR_EXPR:

| match.pd simplify line(s) | Required child shape |
| --- | --- |
| 1156; 12089 | negate |
| 2308; 2318 | bit operation |
| 2590 | multiply |
| 3260 | pointer difference |
| 4253 | equality/inequality |
| 5025 | min/max |
| 5705 | left shift |
| 5806 | another convert/float conversion |
| 5939 | bit-and |
| 6253; 6682 | vector/scalar conditional |
| 9500; 9511; 9524; 9539 | floating builtin/internal call or min/max |
| 9687 | plus, minus, multiply or real divide |

The included `cfn-operators.pd` cannot add a conversion alias: its producer
only prints BUILT_IN, IFN or null entries (`gencfn-macros.cc:123–135`). The
local rounding macros likewise define only builtin lists. `genmatch` rejects
a captured or predicate outermost simplify expression (`:5814–5839`), lowers
optional operators by keeping or stripping that unary operator
(`:1915–1945`, including optional group suffixes at `:5336–5373`), and
routes NOP_EXPR and CONVERT_EXPR through CASE_CONVERT
(`:4110–4115,5057–5060`). The inventory conservatively keeps GIMPLE-only
patterns; their removal cannot create an extra GENERIC rewrite. Full matched
forms and their resolved conversion aliases are retained in the check result.

The handwritten folder is also exhausted. ADDR(STRING_CST) is not a
constant-class node, so the scalar constant folder does not select it.
Stripping operand NOPs does nothing. The common unary distribution requires
COMPOUND_EXPR or COND_EXPR (`fold-const.cc:9204–9310`). CASE_CONVERT's remaining
rewrites require comparison, ADDR of a handled component, MODIFY_EXPR,
BIT_AND_EXPR, POINTER_PLUS_EXPR, BIT_NOT_EXPR or MULT_EXPR
(`:9319–9516`); STRING_CST is not a handled component. None applies. The
outer `fold` repeats the same dispatcher and returns the original expression
when no rewrite succeeds (`:13518–13563`). Thus the retained subtree is an
ADDR(STRING_CST), possibly wrapped in one NOP_EXPR. The bound does not depend
on proving inequality of the two pointer-type identities.

For the selected `internal_get_tmp_var` unshare, constants/types/declarations
are cut points (`gimplify.cc:944–973,1096–1100`). P_ARRAY therefore adds at most
**2C requests of 32 bytes**: no string payload, type, declaration, vector or
UID event. Earlier gigi allocation of these nodes and pointer types is not
included in this copy delta. This completes the missing P_ARRAY term of the
accepted two-constructor materialization-copy interface. Adding it to the
accepted 6C gives 8C selected helper events, still not a complete lifetime.

## Main-local declaration and metadata exhaustion

The declaration inventory is a projection of this selected native shell,
not a count inferred from executable GIMPLE statements.

1. Each literal supplies one associated `E_String_Literal_Subtype`
   (`sem_res.adb:13224–13236`). The existing entity-association transfer prevents
   repeated full conversion of that same entity. Its gigi branch calls
   `create_index_type` once; this creates a new sizetype range and one artificial
   TYPE_DECL (`decl.cc:3142–3193`; `utils.cc:2861–2870`). `create_range_type`
   makes the separate Ada-index/RM range, with constant endpoints, and **no
   declaration** (`utils.cc:2877–2892`). The array is made nonshared and the
   common type tail creates its one TYPE_DECL (`decl.cc:5012–5020`). Thus there
   are at most two local TYPE_DECL/DECL_EXPR pairs per literal.
2. The common type path adds no padding declaration for this subtype.
   Creation initializes unknown size/alignment (`itypes.adb:38–79`); the
   literal-specific freeze calculation can set only its ordinary static
   component-size times length (`freeze.adb:773–794,822–833`). The fixed
   ordinary Character component is eight bits with byte alignment. No source
   or inherited representation, volatile, atomic, packed or address-space
   clause changes this type. Its range is 1..L, including 1..0 when empty,
   so `layout_type` computes constant 8L-bit/L-byte size with unchanged
   component alignment (`stor-layout.cc:2662–2767`). Array
   `make_type_from_size` returns the original type. Equal requested size is
   cleared, and `maybe_pad_type` returns the original for unchanged
   size/alignment (`decl.cc:4533–4637`; `utils.cc:1522–1613,1734–1748`). The
   `gnu_type != orig_type` extra-declaration branch is false. The later common
   branches for symbolic size elaboration, record-field elaboration,
   full-access checks, derived/volatile types and packed-array implementation
   types do not apply (`decl.cc:4640–5010,5121–5127`). In particular there is
   no padding-XVZ or named-bound local variable.
3. Imported procedure profiles and Standard.String/Character dependencies
   do not add Main-local DECL_EXPRs. A public nondefining entity reference
   increments `force_global` for its whole recursive conversion and restores
   it on return (`decl.cc:507–517,5118–5119`). `global_bindings_p` observes
   that flag; `gnat_pushdecl` sends those declarations to the global list
   (`utils.cc:674–676,982–987`). `add_decl_expr` marks external/global
   declarations instead of appending them to Main (`trans.cc:9117–9137`).
   Helpers generated while constructing those imported array/profile types
   inherit that global context. The Main function declaration is made before
   `begin_subprog_body` enters Main (`trans.cc:4010–4043`;
   `utils.cc:3830–3846`). The fixed hard-register dummy is also a global, as
   established in the predecessor. Mere callee/type references do not open
   arbitrary declaration or expression metadata in `walk_tree`.
4. A source null can create one local LABEL_DECL; `gnat_pushdecl` emits its
   DECL_EXPR, followed by the GOTO_EXPR and LABEL_EXPR
   (`trans.cc:7736–7750`; `utils.cc:3660–3668`). These are the only additional
   local declarations. The accepted source expansion excludes source objects,
   generated object temporaries, secondary-stack cleanup/finalizer, nested
   functions, checks, handlers and call copy-in/copy-out. A direct call's
   temporary actual list/vector is not an operand list in the retained call:
   `build_call_array_loc` stores the callee and one argument in CALL_EXPR
   (`trans.cc:5382–5388`; `tree.cc:11050–11059`). Empty call markers and
   statement lists contribute no ordinary copy weight.

Every expression-bearing metadata edge of this inventory is then bounded:

| Reached root family | Selected values / traversal |
| --- | --- |
| BIND declaration INITIAL/SIZE/SIZE_UNIT for local TYPE_DECL/LABEL_DECL | Null. `build_decl` lays out only VAR/PARM/RESULT, and the selected push/type/label helpers set none of these fields (`tree.cc:5567–5585`). |
| Main RESULT SIZE/SIZE_UNIT | Null for void; result construction/layout copies the void type's absent sizes (`utils.cc:3789–3797`; `stor-layout.cc:695–699,2624–2629`). |
| Local index TYPE_DECL generic MIN/MAX, SIZE/SIZE_UNIT | Integer constants. Its range constructor uses constant endpoints and copies sizetype's constant sizes (`tree.cc:7460–7478`). |
| Local array TYPE_DECL SIZE/SIZE_UNIT | Integer constants 8L and L, including zero. |
| Array element/domain type links | Ordinary Character scalar and the index range; no record fields or pointer chain. |
| DECL_ORIGINAL_TYPE | Null. The only selected setter requires a named, nonartificial pointer/fat/extended-pointer type; the index is unnamed and the array is not a pointer (`utils.cc:1005–1034`). |
| Ada scalar RM endpoints on the local index declaration | Null: its fresh range does not set TYPE_RM_VALUES. TYPE_INDEX_TYPE uses a separate language-specific field (`ada-tree.h:249–265,336–351`), so its separately constructed RM range is not substituted for this root. |

The generic DECL_EXPR walker opens the declared type's expression fields and
follows ordinary type links; BIND opens its declarations' initializer/size
fields (`tree.cc:11830–11993`). It does not follow an arbitrary expression's
TREE_TYPE into all its metadata. For the actual local array/index roots,
`walk_type_fields` has no pointer-chain duplicate-set path
(`tree.cc:11637–11711`). Pointer-type walker duplicate-suppression sets thus
add **zero** requests in this whole-body invocation.

Later local TYPE_DECL lowering opens the same type sizes and the separate
DECL_ORIGINAL_TYPE/RM entry points (`gimplify.cc:2124–2158,21600–21739`;
`trans.cc:9375–9407`). Character's scalar bounds/sizes are also constants.
All selected roots are null/constant; `gimplify_one_sizepos` exits before its
unshare/materialization path. No placeholder exemption is needed for the
local literal types. This conclusion concerns these local metadata roots;
it does not price original global type construction, global warning-map
activity or all other gimplifier helpers.

## Whole-body weight and copying requests

Use exactly the occurrence forest of the established
[3W transfer](retained-backend-capacity.md#whole-body-copying-include-protected-children-and-declaration-metadata).
It cuts at constants, types, declarations and protected identities, and
expands each protected identity's children and reached declaration metadata
as that transfer requires. It allows preexisting visited marks. It does not
replace occurrence counts with unique-node counts.

| Ordinary occurrences | Count | Raw bytes each |
| --- | ---: | ---: |
| Literal index/array DECL_EXPR | 2C | 32 |
| CALL_EXPR with one actual | C | 56 |
| Callee ADDR(FUNCTION_DECL) | C | 32 |
| Fat and bounds CONSTRUCTOR | 2C | 24 |
| P_ARRAY ADDR and optional NOP | 2C | 32 |
| P_BOUNDS ADDR | C | 32 |
| Null label DECL_EXPR, GOTO_EXPR and LABEL_EXPR | 3N | 32 |
| Bare RETURN_EXPR | 1 | 32 |

The call has four physical operand slots: count constant, callee, null static
chain and actual. The count constant is a cut point; it adds no ordinary
weight. LP64 tree sizes use the accepted layout correspondence;
`build_vl_exp` requests `sizeof(tree_exp)+(len-1)*sizeof(tree)`
(`tree.cc:11025–11059`). Statement-list headers/links and protected BIND nodes
have zero copy weight. There are no SAVE/TARGET identities here. The metadata
rows above contribute zero ordinary expression occurrences. Therefore

```text
W <= 9C + 3N + 1
weighted raw tree bytes <= 296C + 96N + 32
fresh ordinary tree requests <= 3W = 27C + 9N + 3.
```

Each of the two constructors has a two-element vector. A copy reserves from
null with minimum capacity four, then resets logical length/capacity to two:
the allocation request is `8+4*16=72` raw bytes, rounded to 128, even though
the final reported vector capacity is two (`tree-inline.cc:5770–5790`;
`tree-core.h:1636–1648`; `vec.h:731–740,999–1016`). At most three copies per
constructor occurrence give 6C vector requests. Thus whole-body copying adds

```text
GGC allocation events <= 33C + 9N + 3
raw request-byte sum <= 1320C + 288N + 96
rounded request-byte sum <= 1728C + 288N + 96.
```

The sums describe these requests; they are not a peak-memory or aggregate
RAM admission rule. Individual tree requests are 24, 32 or 56 bytes, rounded
to 32, 32 or 64; individual constructor-vector requests round to 128. These
copies allocate no string payload, scalar constant, type or declaration, so
they introduce no TYPE_UID or DECL_UID increments. `copy_node`'s special
type/declaration/option copying paths are never selected (`tree.cc:1466–1549`).

One ordinary `hash_set<tree>` is created by this Main `unshare_body`
invocation (`gimplify.cc:1028–1040`). It has at most C+1 protected identities.
Its nonlazy initial backing has 13 pointer slots (`hash-set.h:34–41`). With
no deletions/reserves, the existing hash transfer gives
`prime(max(13,2(C+1)))` slots and at most C+2 backing requests, each eight
bytes per slot (`hash-table.h:648–675,833–858,1029–1040`). Repeated attempts
are allowed: expansion happens before checking whether a key already exists.
The callable reports failure of the selected prime-table condition if that
prime does not exist. The set object, ordinary allocator bookkeeping and
host-stack realization remain separate from the GGC rows. This packet does
not infer stack safety for arbitrary recursion depths from a tree-count bound.

## Type-only call scopes still allocate binds

The earlier direct-site subtotal reserved one outer GIMPLE bind. That is not
sufficient justification when literal type declarations can retain a call
scope. A procedure call sets `returning_value=false`, starts a statement group
and pushes its binding **before** translating its actual
(`trans.cc:4896–4922`). The literal's first type lookup may therefore put
its TYPE_DECLs there. `gnat_poplevel` tests whether BLOCK_VARS is empty, not
whether it contains a VAR_DECL (`utils.cc:732–759`); a nonempty type-only
block survives. `end_stmt_group` then makes a BIND_EXPR
(`trans.cc:9255–9273`), and the call closes that group at `:5631–5637`.

The already established binding transfer allows at most C call binds plus
one Main body bind. This bound is valid regardless of the exact timing of
literal freezing/type lookup, so no native counterexample or new freeze-timing
premise is necessary. Calls are sequential and nonnested: maximum retained
GENERIC bind nesting is two. `gimplify_bind_expr` unconditionally builds and
emits a GIMPLE_BIND even when its list consists only of TYPE_DECLs
(`gimplify.cc:1680–1687,1836–1838`). `gimplify_body` reuses the sole outer
bind or supplies one when needed (`:21794–21829`). At most **C+1** GIMPLE
bind tuples suffice. The corrected direct-site subtotal is therefore
**10C+2N+2**, increasing the old subtotal by C requests under its existing
128-byte tuple ceiling. This is a correction to the argument; no observed
native event count is claimed.

The binding-stack byte correction is independent of the tuple correction.
Each push calls `reserve(8)`, meaning eight **additional free slots**, then
pushes (`gimplify.cc:427–430`). A fresh outer push reserves capacity eight
(72 bytes); an inner push at length one needs nine slots and doubles the
small capacity to sixteen (`vec.h:253–260`; `vec.cc:150–168`), requesting
136 bytes. Later sibling calls reuse that capacity. There are at most two
ordinary backing requests, **208 cumulative bytes and 136 maximum request
bytes**. Capacity twelve / 104 bytes would use the wrong large-vector growth
branch; the parent caught and corrected that preliminary calculation before
this packet was frozen. The context object retains its existing 128-byte
ordinary bound.

No cleanup is added: gimplification's cleanup loop requires VAR_DECL, while
the original BIND lists contain only type/label declarations
(`gimplify.cc:1708–1748`). Descriptor temporaries are attached only when the
context is popped, after this loop. The flat executable GIMPLE shape,
no-local-EH result, CF/CFG/SSA shape and descriptor count remain unchanged.

CF calls `gimple_set_block` before dispatching even a GIMPLE_BIND
(`gimple-low.cc:701–711`). The outer bind is processed directly by
`lower_function_body` (`:122–147`), so at most C extra inner-bind calls must
be added to the prior **3C+2N+2** interface: the safe bound is
**4C+2N+2**. `lower_gimple_bind` calls `record_vars`, but `record_vars_into`
skips every non-VAR_DECL (`:942,1440–1456`). The local-declarations vector
still receives at most C descriptor variables. Binds are then removed
(`:974–976`), so they do not add executable/CFG vertices.

The direct warning interface also stays **C+1** copy_warning calls. Bind
construction adds no copy_warning; the assignment site requires a comparison
RHS, which these pointer stores do not have (`gimplify.cc:7597–7602`). The
selected call and bare-return copies remain the named direct sites. This is
not a population bound on the already existing nowarn map: gigi can suppress
warnings while inserting declarations, and a repeated map insertion can
resize before lookup. That incoming map/backing join remains open.

## Integration boundary and retained evidence

The additive interface replaces neither the existing direct-site nor pool
ownership. Consumers should apply the C-bind correction once, add the 2C
address delta once to the accepted selected 6C, and add the whole-body
33C+9N+3 requests once. Bounds-pool declarations/descriptors, original gigi
arrays/strings/type declarations, shared type tables, and original statement
list allocation stay in their existing or still-open producers. The protected
set and bind stack are ordinary requests. Global GGC event counters, map/hash
capacity, type/declaration UIDs from original constructors, collector/page
accounting and complete launch inputs still need composition. The callable
deliberately leaves `complete_gimplifier_GGC_request_events_upper` null and
`complete_gimplifier_lifetime_closed=false`.

The evidence pins 28 complete immutable GCC source files at
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. All common Ada interface files were
also byte-compared between the two retained source trees. It does not pin a
mutable aggregate report/callable. Accepted predecessor interfaces are named
above and were read at worktree base `d60dc37edbc1fbb66be52759f8e1b6ad42457821`;
source identity is additional to, not a replacement for, the handwritten
branch/metadata argument. Installed behavior corresponding to the retained
source and accepted LP64 layout remains an explicit premise.

The focused check verifies source identities, extracts conversion candidates,
checks vector growth, exercises 257 small hash populations with repeated
insertions, and evaluates eight arithmetic/prime-table boundary cases plus
six invalid-counter cases. It runs Python only. No compiler, prover, debugger,
native execution, broad audit or GitHub mutation was performed by this
subthread. Independent review and aggregate integration are the parent's next
steps; this packet does not claim that review has occurred.

| Round | Selected model/effort | Intended result | Result/rework | Time/cost evidence |
| --- | --- | --- | --- | --- |
| Named ingress escalation | GPT-6 Astra / Max; runtime model/effort confirmation unavailable | Resolve retained data-address multiplicity, reached metadata W and binding ingress after Extra High investigation | W/address interfaces closed conditionally; #130 bind/CF/stack correction; preliminary stack growth corrected by parent | Start 2026-10-18 19:07:08 UTC; completion and elapsed recorded in evidence README; token/cost measurements unavailable |

The live harness goal query returned no goal in this subthread. No goal state
was created or changed. Durable task/milestone/session-memory integration and
the independent review target belong to the parent; CLI memory was not updated.
