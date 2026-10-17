# Retained GNATprove producer capacity: partial derivation

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-17, on Linux x86_64. This closes several producer-cost components and
identifies the remaining source-to-producer obligations. **It does not establish
a complete capacity rule, choose a new language limit, or authorize admission
changes.** The dependent implementation still needs that complete rule.

The inspected source is SPARK revision
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`, from the source archive already retained
by the [frontend representation research](frontend-representation-result.md).
The installed package is Alire GNATprove 16.1.0, release archive digest
`82528bef29857e239373fcc36732837d743f5a00805d502c70455422ffc97191`.
Source/recipe/package correspondence retains the explicit premise of the earlier
research; this work neither rebuilds nor attests the external compiler binary.
The existing [producer review](../for-loops-image-producer-review.md) remains the
source of the Image producer/consumer correspondence claims.

Evidence is in
[`docs/evidence/retained-producer-capacity-20261017`](../evidence/retained-producer-capacity-20261017/).
The [manifest](../evidence/retained-producer-capacity-20261017/source-manifest.json)
hashes complete source files; the
[excerpts](../evidence/retained-producer-capacity-20261017/source-excerpts.md)
retain numbered LF-based source ranges. References below are paths relative to
that pinned source tree. Every complete file in the current manifest
hash-match their copies in the previously retained source archive, checked by
[`source-archive-check.json`](../evidence/retained-producer-capacity-20261017/source-archive-check.json).
No compiler invocation, proof invocation, installation,
or expensive validation was performed for this research.

## The producer has two different counting problems

`src/why/why-types.ads:35–43` defines signed 32-bit `Why_Int` and
`Why_Node_Id = 0 .. 2^30 - 1`; zero is reserved. Lists occupy the other part of
the ID range. The node and list vectors are defined in
`src/why/xgen/why-atree.ads-tmpl:101–116`.
`New_Why_Node_Id` and `New_List` append to those vectors
(`src/why/why-atree.adb:74–89`). Generated builders append one node, including
nodes subsequently discarded or omitted from output
(`src/why/xgen/xtree_builders.adb:238–249`). Their list-valued fields also allocate
list records (`:207–225`). A count of the final printed syntax alone cannot bound
these lifetime allocation totals.

Separately, the JSON emitter has a package-global
`Why_Node_Counter : Natural := 0`. It increments once per emitted node occurrence
and writes the integer as the occurrence ID
(`src/why/xgen/xtree_why_ast.adb:169–230`). The intended maximum is
`2^31 - 1`. The inspected generator contains no reset between output files.
Prior binary inspection recorded unchecked native increments; no checked overflow
guard is asserted here.

This is input production for proof, not optional reporting afterward.
`Do_Generate_VCs` calls `Print_GNAT_Json_File` **before** `Run_Gnatwhy3`
(`src/why/gnat2why-driver.adb:590–604`). Making user-facing confirmation optional
does not remove this representation limit from an automatic-discharge argument.

## Exact serialization recurrence

The serializer follows every referenced node, including repeated references to
the same internal node. It does not memoize a previously emitted subtree:
`Why_Node_Id_To_Json` calls `Why_Node_To_Json(Node_Table(Id))`, and list traversal
does the same for every element
(`src/why/xgen/why-atree-to_json.adb-tmpl:113–156`). For a finite acyclic Why DAG,
the exact emitted-occurrence recurrence is therefore

```text
occ(absent) = 0
occ(node)  = 1 + sum(occ(child) for every serialized node field/list entry)
occ(plan)  = sum(occ(root) for every theory root in that printing plan)
counter   = sum(occ(plan) for every emitted file in the process)
```

Primitive fields, strings and symbols contribute bytes, but no further node
occurrences. The AST schema in `src/why/xgen/xtree_sinfo.adb` identifies which
fields are node references. Internal sharing can save allocation without saving
emitted occurrences.

`Build_Printing_Plan` visits each theory symbol once **within that invocation**,
following includes with no external filename
(`src/why/gnat2why-util.adb:503–540`). It does not establish a single-print bound
across files. `Do_Generate_VCs` clears `WF_Main` per entity but does not free the
node tables; `Why.Atree.Free` occurs after all entity processing
(`src/why/gnat2why-driver.adb:507–525, 1432–1455`).

There is a useful compositional import bound. `Close_Theory` unconditionally adds
two standard imports. Its definition import and axiom-closure loops each visit
a set of module IDs once (`src/why/why-inter.adb:578–746`). If `M` bounds all module
IDs, a close adds at most `2 + 2M` include nodes. Each include serializes its
module once, so contributes two occurrences. The still-needed bounds on `M`,
the number of closes, and emitted files cannot be replaced by a raw source-byte
count without deriving their source relation.

## A closed ordinary String-literal component

Consider a static ordinary `Standard.String` literal, with `Standard.Character`
components, static Integer indexing and no relaxed initialization. Charge
standard symbol/module setup separately. The character loop in
`Transform_String_Literal`
(`src/why/gnat2why-expr.adb:30325–30362`) allocates these nodes per decoded
character:

| Operation | Fresh Why nodes |
| --- | ---: |
| Integer index constant | 1 |
| Character name/type for array-access result | 2 |
| Array-access call | 1 |
| Character numeric constant | 1 |
| Character-to-integer conversion call | 1 |
| Equality call | 1 |
| **Total per character** | **7** |

The helper paths are `New_Discrete_Constant`, `New_Array_Access`, `EW_Abstract`,
`New_Kind_Base_Type`, `To_Why_Type`, `Insert_Simple_Conversion`, `Conversion_Name`
and `New_Comparison`. They are retained in the excerpts. Standard symbol lookup
can lazily initialize symbols; it is not free setup for a whole program.

For decoded length `L`, the loop and `New_And_Pred` together add:

```text
fresh nodes         = 7L + [L >= 2]
fresh lists         = 3L + [L >= 2]
fresh list elements = 5L + max(L - 2, 0)
```

The three argument lists per character have lengths two, one and two. For two
or more conjuncts `New_And_Pred` creates one connection, whose `More_Right` list
holds the remaining `L-2` operands
(`src/why/why-gen-expr.adb:3533–3569`). Its two temporary predicate arrays are
also length `L`; these are a memory requirement rather than additional Why IDs.
For `L=0` this component reuses `True_Pred` and allocates none of the above.

The serialized equality subtree is larger because it repeats shared type,
name, function and argument structures:

| Serialized subtree | Occurrences |
| --- | ---: |
| Builtin Integer/Boolean/Unit type | 2 |
| Character or array-map type with module name | 3 |
| Equality identifier | 4 |
| Character `to_rep` identifier | 5 |
| Array `get` identifier | 6 |
| Literal function identifier | 5 |
| Unit parameter identifier | 4 |
| Literal function call | `1 + 5 + 4 + 3 = 13` |
| Array access | `1 + 6 + 13 + 1 + 3 = 24` |
| Conversion | `1 + 5 + 24 + 2 = 32` |
| Equality | `1 + 4 + 32 + 1 + 2 = 40` |

Thus this **character-definition predicate**, excluding the enclosing theory,
declarations, quantifier, trigger, imports and other producer work, emits

```text
P(0) = 1
P(1) = 40
P(L) = 40L + 1, when L >= 2
```

This is a component result, not a safe literal-length cutoff. For example,
dividing `2^31-1` by forty omits the rest of the producer and its earlier files.
`L` is the length of the frontend literal reaching this transformation. A future
source-sensitive rule must include frontend-generated/folded literals and
transformation multiplicities; summing only source token contents is unjustified.

### Retained-artifact corroboration

The evidence extracts three unchanged literal theories from the existing
`program-cKuh3x/obj/gnatprove/main.gnat-json`, alongside its original source.
The full original JSON and source hashes are recorded in
[retained-input.json](../evidence/retained-producer-capacity-20261017/retained-input.json).
This is inspection of an existing artifact, not a new validation run or a claim
about the provenance of the whole old run.

Each equality has forty occurrences. The three module totals are:

| Decoded length | Character predicate | Whole observed literal theory |
| ---: | ---: | ---: |
| 1 | 40 | 130 |
| 3 | 121 | 211 |
| 7 | 281 | 371 |

All three observed theories have eight imports and seventy-four other
occurrences, giving `74 + P(L) + 2*8`. That observed fixed overhead is
corroboration, not a universal whole-module bound. The retained script checks
these values and contiguous serialized occurrence IDs without invoking GNATprove.

## Source-child multiplicities that are now closed

These facts concern reachable ordinary Main transformations, conditional on
their stated frontend shape. They do not price all helper work.

**Concatenation.** `Transform_Concatenation` introduces temporaries for both
operands before using them repeatedly for lengths, bounds and reconstruction
(`src/why/gnat2why-expr.adb:21976–22351`). `New_Temp_For_Expr` replaces a nontrivial
operand with a fresh identifier; an existing identifier/dereference needs no
binding. `Binding_For_Temp` inserts the original definition once and removes its
map entry (`src/why/why-gen-expr.adb:311–348, 4962–4996`). The `W_Binding` schema
has one `Def` and one `Context` field. Hence concatenation repeats bounded-shape
temporary references, not entire complex child expressions. For occurrence cost,
the two complex child coefficients are one; the helper overhead remains to price.

**Branches.** Each then/elsif/else body is translated once and assembled once
into nested conditionals; conditions are likewise translated once at this layer
(`src/why/gnat2why-expr.adb:29733–29862`). There is no enumeration of combinations
of execution paths in this transformation. Predicate and warning helper costs
still need their own bounds.

**Loops.** With `--no-loop-unrolling`, no body declarations or invariant pragmas,
and whole-object assignments, the source-derived recurrence per loop occurrence
has the form

```text
O(loop) <= O(body)
         + Prog(low) + Prog(high) + Term(low) + Term(high)
         + K_loop + sum(H(entity) for entity in Q_loop).
```

No-invariant processing moves the body to `Final_Stmts`, empties `Initial_Stmts`
and clears `Frame_Constants`; the body is translated once. `Wrap_Loop` uses it
once in a try block, and later bindings preserve that context once
(`src/why/gnat2why-expr-loops.adb:510–573, 787–813, 2194–2334`). The repetition
branch is gated by `not No_Loop_Unrolling` (`:1812–1814`). Numeric trip count is
therefore absent from this recurrence.

Both endpoint-domain costs are needed: range-invariant generation re-translates
the endpoints in the term domain, while outer bindings translate them in the
program domain (`src/why/gnat2why-expr-loops.adb:1398–1415, 1937–1960`;
`src/why/gnat2why-expr.adb:14857–14920`). These are frontend range nodes; any
frontend-generated captures or rewrites remain part of source correspondence.

`Q_loop` is a set of distinct non-discarded modified root entities from the loop
and its descendants, including applicable library globals. The frame write map
deduplicates root entities, traverses nested-loop bodies and discards nested
indexes (`src/why/gnat2why-expr-loops-inv.adb:1940–1976, 2291–2350`). For `F` loops,
`D` mutable program objects and `G` applicable fixed library globals, the coarse
bound is `sum |Q_loop| <= F(D+G)`; counting distinct assigned descendant targets
per loop is sharper. Repeated assignment to one object does not add frame entries.

For frame entries classified `Entire_Object`, the preserved-components helper
returns `True_Pred` because `Only_Vars` defaults to true. `Not_Written` entries
instead generate whole-object equality, including where an assignment lies on
a path irrelevant to the invariant. The loop-entry snapshot argument
is nevertheless evaluated eagerly, so snapshot creation must still be charged
(`src/why/gnat2why-expr-loops-inv.adb:181–196, 775–807, 1266–1270`). Snapshots are
deduplicated by Ada `Node_Id` identity in separate `No_Checks` and `Regular` maps
(`src/why/gnat2why-util.adb:1347–1454`). The frame path supplies the root entity
node, allowing at most one frame-created snapshot per entity per loop in that
map. This is not general deduplication of semantically equal expressions.
`H` still needs numerical bounds for identifier/type processing, dynamic
invariants, preservation checks and snapshot bindings. `K_loop` still needs
the fixed index/control/warning wrapper bound. Allocation of discarded nodes
also remains to price independently of this serialization recurrence.

## Normalized signed Integer arithmetic cost

For an ordinary signed Integer expression translated in the program or term
domain with expected Why type `EW_Int_Type`, the nonstatic arithmetic core has
small fixed overhead. Charge operand translations, identifier leaves, any
conversion at a surrounding abstract/subtype boundary, and initial symbol
setup separately. The separate pretty-printing label is only enabled in the
predicate domain, so does not add overhead in the stated program/term scope
(`src/why/gnat2why-expr.adb:23600–23647, 25500–25510`).

`Transform_Expr` translates each operand of binary `+`/`-`/`*` once at the builtin
Integer type (`src/why/gnat2why-expr.adb:24127–24205`).
`New_Binary_Op_Expr` then returns one call with those two operands
(`src/why/why-gen-expr.adb:3754–3997`): its simple operand conversions see equal
base types, and `Apply_Modulus` immediately returns for a nonmodular type
(`:147–157`). Signed Integer multiplication has matching result and operand
base types, so its additional final-conversion condition is false. Unary minus
similarly emits one call with its operand; unary plus
emits no core operation (`src/why/gnat2why-expr.adb:24012–24110`).

An optional overflow check passes the whole expression once to `New_VC_Call`
(`src/why/gnat2why-expr.adb:12039–12056, 25514–25573`). This adds one call, one
VC label, and at most one location label
(`src/why/why-gen-expr.adb:1956–1983, 5282–5323`; the `New_VC_Prog` forwarding
function is in `.ads:305–311`). With expected `EW_Int_Type`, the final scalar
conversion returns the result without another conversion/check node: equal
base types return immediately unless a check is flagged; in that remaining
case the builtin Integer target has no Ada range type and no conversion is
necessary (`.adb:2399–2476, 2478–2910`). A conversion to an actual declared
subtype remains outside this component.

The builtin Integer type has two serialized occurrences. A binary operator
identifier has five (identifier, name, module, type and its name); unary minus
has four because it has no module
(`src/why/why-atree-modules.adb:703–756`). The ordinary signed range-check
identifier also has five; its return type is the existing builtin Integer
(`:3962–4006`; `src/why/why-inter.adb:943–1017`). The overflow wrapper therefore
adds `8 + 3 + 1 = 12` occurrences: call, VC label with type, location label.

| Core operation, excluding children/setup | Fresh nodes | Fresh lists | List elements | Serialized overhead |
| --- | ---: | ---: | ---: | ---: |
| Binary `+`, `-` or `*`, without overflow wrapper | 1 | 1 | 2 | 8 |
| Unary `-`, without overflow wrapper | 1 | 1 | 1 | 7 |
| Optional overflow wrapper | at most 3 | 1 | 1 | at most 12 |
| Binary `+`/`-`/`*`, allowing that wrapper | at most 4 | at most 2 | at most 3 | at most 20 |
| Unary `-`, allowing that wrapper | at most 4 | at most 2 | at most 2 | at most 19 |

The term-domain case has no overflow wrapper. Compile-time-known discrete
expressions can instead use a single discrete constant without traversing the
arithmetic children (`src/why/gnat2why-expr.adb:23700–23710`); that simplification
does not enlarge these conservative per-tree bounds. This closes normalized
arithmetic operator overhead, not the identifier, declaration-type, or String
conversion costs needed by the complete language.

### Ordinary Integer leaves and static subtype boundaries

An ordinary Integer object or loop index uses a `Regular` binder whose type is
`EW_Split`: `Mk_Item_Of_Entity` calls `Type_Of_Node` and the scalar split-form
predicate is true (`src/why/why-gen-binders.adb:1082–1125`;
`src/why/why-inter.adb:1579–1632`; `src/why/gnat2why-util.adb:1875–1883`).
An Integer split type has two serialized occurrences, its type and the
pre-existing builtin Integer name. Creating that type allocates one new node
(`src/why/why-inter.adb:1195–1211`), which must be charged whenever the caller
actually asks for a fresh type; reading a regular binder's existing type does
not allocate one (`src/why/why-gen-binders.adb:448–453`).

With no overlays, relaxed initialization, invalidity or volatile annotations,
`Transform_Identifier` reconstructs the regular binder without further checks
(`src/why/gnat2why-expr.adb:26847–27088`). `Reconstruct_Binder` returns the
existing identifier, or adds one dereference for a mutable object with
references enabled (`src/why/why-gen-binders.adb:1457–1524`). An identifier has
at most five emitted occurrences, including an optional module; a dereference
adds three. Normalizing an Integer split value to builtin `EW_Int_Type` adds
at most one empty label with that builtin type, hence at most three more
occurrences. The scalar conversion does not emit an actual conversion call:
`Insert_Single_Conversion` compares the split type's builtin representation
with the target and returns its input; the enclosing function may then add the
label (`src/why/why-gen-expr.adb:2642–2910, 2988–3044`).

A compile-time-known Integer expression instead creates one integer constant,
with no type child and no Why list (`src/why/why-gen-expr.adb:4488–4501`;
`src/why/xgen/xtree_sinfo.adb:371–381`). Thus the normalized leaf allowances,
excluding initial symbol/binder creation, are:

| Leaf | Fresh nodes | Fresh lists/elements | Total emitted occurrences |
| --- | ---: | ---: | ---: |
| Integer constant | 1 | 0 | 1 |
| Ordinary Integer object/index, allowing mutable read | at most 2 | 0 | at most 11 |

For a conversion between these Integer representations and an existing
nonempty static Integer target subtype, allow one range-check wrapper and one
type label: **at most four nodes, one list, one element and fifteen emitted
occurrences**, excluding the child. `Type_Is_Modeled_As_Base` is false for
that target shape; `Do_Range_Check` consequently passes the expression once to
the existing range function (`src/why/why-gen-expr.adb:2349–2391`;
`src/why/why-gen-names.adb:1182–1220`). The wrapper costs at most twelve as
above; the final split-type label costs three. `Range_Check_Applied` prevents
a second range check. No abstract conversion, predicate, initialization or
cross-base conversion applies to these ordinary split Integer types.
The expected-type node, if freshly constructed by a caller, remains a separate
one-node allocation. Dynamic or empty target types require the separate
dynamic-bound path and are not covered by this boundary component.

For one normalized program/term translation of a scalar syntax tree containing
`L` literal/name leaves and `O` unary/binary arithmetic operators, these
components give the following conservative envelope:

```text
fresh nodes         <= 2L + 4O
fresh lists         <= 2O
fresh list elements <= 3O
emitted occurrences <= 11L + 20O
```

Unary plus is covered by the operator allowance even though it has no core
call. Compile-time folding can replace a subtree with one constant and does
not enlarge the envelope. Charge each invocation separately, including the
program/term endpoint and initializer multiplicities already described; add
the static-subtype boundary charge when the expected type requires it. This
closes the admitted scalar-expression core, not declaration wrappers, scalar
comparison wrappers, String attributes or fixed-library translations.

### Ordinary Integer declaration and assignment wrappers

For an initialized source Integer object, its type is `Standard.Integer` or
the non-itype subtype generated for the explicit nonempty static range. Its
regular binder has no initialization, validity or move-tree flag. Exclude
the initializer/RHS translation and its expected-subtype boundary charge,
initial binder/symbol creation, outer entity theories and enclosing sequence
construction from the following wrapper costs.

There is an allocation that is invisible in the emitted result:
`Insert_Move_Of_Deep_Parts` eagerly creates a temporary identifier before
deciding whether any move occurs. On the admitted scalar expressions no move
occurs, but the identifier and name still cost **two fresh nodes**
(`src/why/gnat2why-expr.adb:11961–12034`;
`src/why/why-gen-names.adb:786–808, 838–870`). Both object initialization and
assignment call that helper once. The temporary-name counter is also advanced;
its call count must be included if bounding that counter separately.

The ordinary mutable initializer then adds one assignment: at most eight
emitted occurrences excluding its RHS (assignment, identifier/name/module,
two copies of the two-occurrence split type). The immutable case creates one
temporary identifier/name, an equality call, an assumption and a binding,
with at most twenty-four emitted occurrences excluding its initializer.
`New_Tag_And_Ext_Update` returns the input for untagged Integer
(`src/why/gnat2why-expr.adb:1756–1831`;
`src/why/why-gen-records.adb:5048–5125`). Starting with `Void`, `Append`
returns the nonvoid result without allocating a sequence.

`Transform_Declaration` then assumes the object's dynamic invariant
(`src/why/gnat2why-expr.adb:22591–22638`). For these non-itype static Integer
types, the existing `dynamic_invariant` predicate is called with the object
and four boolean flags. There are no additional variables in the type's
dynamic invariant (`:6730–6824, 30936–31120`). The local type-invariant
traversal returns `True` because Integer and its subtype parents have no
user invariant (`:8782–8916`). The boolean conjunction simplifier returns
the other child without a new node. Allow at most five fresh nodes for this
declaration suffix: optional mutable dereference, eagerly constructed split
type, predicate call, assume statement and sequence; two lists with seven
elements. Its emitted cost is at most thirty, including the object's read,
four flags (at most three occurrences each), call, assumption and sequence.
The final declaration location label adds at most one node/occurrence
(`:23187–23195`).

Combining the larger allowances above, a source Integer declaration adds at
most **thirteen fresh nodes, three lists, nine list elements and fifty-five
emitted occurrences**, excluding the separately charged initializer and
boundary. This deliberately combines maxima from mutable and immutable paths.
The eager move temporary is charged even though it is never serialized.

For an Integer assignment, `Transform_Statement_Or_Declaration` also eagerly
creates an unused target-name identifier/name: the language has no `@` target
names, but this costs another two fresh nodes
(`src/why/gnat2why-expr.adb:29520–29561`).
`Transform_Assignment_Statement` creates one split expected-type node, calls
the RHS once, then reaches the regular assignment helper; its array, tag,
discriminant, validity and move conditions are false
(`:19042–19142, 19238–19345`). The conversions back to the existing target
binder type compare equal Ada subtype identities and allocate nothing
(`:12286–12368, 12402–12423`). Thus this assignment wrapper adds at most
**six fresh nodes, zero lists/elements and eight emitted occurrences**,
excluding the RHS/boundary and any enclosing statement-list location label.

These bounds cover source Integer objects/assignments. Generated loop subtype
declarations, loop framing, String declarations and fixed library bodies still
need their own costs; the source Integer range's separate subtype declaration
is not included merely by pricing its object wrapper.

### Scalar comparison, boolean and warning wrappers

For an Integer comparison translated in the program or term domain,
`Transform_Comparison` translates each operand once at builtin Integer and
`New_Comparison` adds one call with the two operands
(`src/why/gnat2why-expr.adb:21942–21968`;
`src/why/why-gen-expr.adb:4289–4332`). Its operator is either an existing
Integer relation, equality/inequality, or a Boolean-valued Integer comparison
function; each identifier has at most five occurrences
(`src/why/why-gen-expr.adb:5446–5541`;
`src/why/why-atree-modules.adb:2699–2747`). The comparison overhead is therefore
**one node, one list, two list elements and at most eight occurrences**.
Expected `EW_Bool_Type` adds no scalar conversion. The predicate-domain
pretty-printing label, when that separate domain is used, must be charged
separately; it is not part of this program/term component.

Boolean `not` translates its child once. In program domain it adds one
`W_Not` node/occurrence and no list; in term domain it adds one call to the
existing `notb`, one list/element and at most eight occurrences
(`src/why/gnat2why-expr.adb:24547–24570`;
`src/why/why-atree-modules.adb:1132–1150`).

The dead-code/branch warning helper can be bounded independently of whether
the invocation's options enable it. Its enabled path creates a located
assertion of false, wraps it in `New_Ignore`, adds a comment and a three-item
statement sequence (`src/why/gnat2why-expr.adb:31162–31211`). This costs at
most **nine fresh nodes, one list, three list elements and twenty-seven emitted
occurrences**, excluding the original child, which occurs once. The fresh
nodes are three for the labeled/location assertion, four for the ignored
binding (identifier/name, binding, abstract expression), one comment and one
sequence. `New_Ignore` and `New_Located_Assert` are defined in
`src/why/why-gen-progs.adb:199–215, 243–257`. For the emitted upper bound,
allow three occurrences per true/false literal, four per local identifier
with a builtin type, and two per builtin type. The disabled path creates
nothing and returns the child.

At the short-circuit connective layer, each child is translated once and at
most one warning wraps the right child
(`src/why/gnat2why-expr.adb:24630–24712`). `and then`/`or else` add at most
one connection with an empty `More_Right` list in program domain, or one
Boolean call with two arguments in term domain; simplification can remove
that final node (`src/why/why-gen-expr.adb:3575–3596, 4816–4837`). A common
program/term allowance is consequently **ten nodes, two lists, three list
elements and twenty-eight occurrences**, excluding the two children and any
frontend `Actions` attached to the connective. Those actions, if present,
are translated separately and must be charged from the frontend action bound.

### String representation leaves and conversion primitives

For ordinary rank-one Character Strings, every existing array/map/abstract
index type used here has at most three occurrences (type, name, module), and
an existing typed identifier has at most six. A fresh static-array or array
split type costs three nodes, including a directly constructed module; a
fresh nonstatic abstract String type costs two nodes plus a possible
memoized entity-module miss (`src/why/why-inter.adb:1158–1224, 1547–1577`).
Keep that memoized setup in the separate `27E_entities` allowance; the
three-node map-type charge already includes its direct module.

A regular String binder reconstructs to its identifier or one dereference,
so `Transform_Identifier` contributes at most one fresh node and ten emitted
occurrences before any expected-type conversion. For a mutable nonstatic
String binder, `Mk_Item_Of_Entity` stores its contents and two immutable
abstract Integer bounds (`src/why/why-gen-binders.adb:888–947`).
`Array_From_Split_Form` reconstructs the contents, converts each bound once
to builtin Integer, then calls `of_array` with the three arguments
(`src/why/why-gen-arrays.adb:412–448`). The bound conversions add at most one
call each, eight occurrences excluding the existing bound identifier
(`src/why/why-gen-expr.adb:1987–1996, 2642–2692, 2988–3044`). The return type
construction costs two nodes and the reconstruction call costs one.

Consequently the nonstatic split-binder String read contributes at most
**six fresh nodes, three lists, five list elements and forty-eight emitted
occurrences**, excluding binder/symbol/module setup and expected-type
conversion. The emitted calculation is `10 + (6+8) + (6+8) + (1+6+3)`:
contents with optional dereference, two converted bounds, and the
reconstruction call/identifier/result type. No whole initializer is expanded
at this read. `Type_Of_Node` on a split array binder may independently construct
its expected abstract array type; charge those caller-side nodes separately.

Two reusable conversion primitives have simple costs once their arguments
and cached symbols are supplied (`src/why/why-gen-arrays.adb:311–410`):

| Primitive | Fresh nodes | Lists | Elements | Emitted overhead |
| --- | ---: | ---: | ---: | ---: |
| `Array_Convert_To_Base` | 4 | 1 | 1 | at most 10 |
| `Array_Convert_From_Base`, already normalized Integer bounds | at most 4 | 1 | 3 | at most 10 |

The first includes its fresh split map type and direct module. The second
includes its fresh abstract type, with a conservative static/nonstatic maximum;
its ordinary nonstatic case costs three nodes. An overload supplied abstract
Integer bounds additionally charges each bound's representation conversion;
the three supplied children otherwise occur once. Array conversion symbols
are defined in `src/why/why-atree-modules.adb:3297–3323`.

The full `Insert_Array_Conversion` is not yet priced by those primitives.
In particular, it constructs `From_Split` and `To_Split` **before** its
same-type return (`src/why/why-gen-expr.adb:1136–1158`). Even a conversion
that returns its original expression can therefore allocate up to six fresh
nodes, including two direct map modules, if both source and target are
nonstatic array representations. Sliding, length/range checks and temporary
bindings on the nontrivial path are priced conditionally below; their
frontend-shape premise remains to be connected to all reachable callers.

### A conditional ordinary String conversion envelope

The following closes `Insert_Array_Conversion` under an explicit frontend-shape
premise: source/target are ordinary rank-one Character Strings, each either
statically constrained (possibly null) or unconstrained; neither uses fixed
lower bounds, initialization wrappers, user predicates or an element-type
conversion. This is not yet promoted to an unconditional Main bound: the
frontend correspondence must cover `Actual_Subtype` and any generated type
reaching the caller, as well as source declarations. The call is not a qualified
expression. Cached symbol/entity-module initialization and caller construction
of the already-supplied expected type remain separate.

First, on those shapes, a static type bound is either an existing bound symbol
possibly converted to builtin Integer, or a compile-time-known bound/literal
constant. It costs at most one new node/list/element and fourteen occurrences.
A nonstatic array's first/last/length accessor on a cheap reference costs at
most one node/list/element and eighteen occurrences: eight call overhead plus
a reference of at most ten occurrences (`src/why/why-gen-arrays.adb:2813–2892`;
`src/why/why-gen-expr.adb:3600–3749`). A cheap reference here is an identifier,
dereference, or temporary identifier of the already supplied array type.

`New_Length_Equality` has six calls, one conjunction and one conditional.
Its two left bounds occur twice each and its two right bounds three times each;
the bound expressions are allocated once and serialized repeatedly
(`src/why/why-gen-arrays.adb:3396–3599`). Using the accessor maximum above gives
**twelve fresh nodes, twelve lists, sixteen elements and 232 occurrences**,
including four accessor constructions: `10*18 + 6*8 + 1 + 3` occurrences.
Its outer conjunction with `True` allocates nothing. A located length assertion
adds at most three nodes and five occurrences; sequencing that check with the
converted value adds one node/list, two elements and one occurrence. Thus the
whole length-check suffix is at most `16 / 13 / 18 / 238` in the order
nodes/lists/elements/occurrences.

An unconstrained-target range check is smaller. The dynamic-property helper
uses two object bounds, two type bounds and one four-argument predicate call
(`src/why/why-gen-expr.adb:4337–4385`;
`src/why/why-gen-arrays.adb:3305–3363`): at most five nodes/lists, eight elements
and `2*18 + 2*14 + 8 = 72` occurrences before the same assertion/sequence suffix.
The larger length-check allowance covers it.

The frontend-shape premise makes sliding possible only when the target is
statically constrained (`src/why/why-gen-expr.adb:3219–3277`). Therefore the
nonstatic-target sliding reconstruction and fixed-lower-bound range branches
are absent. The remaining source path has this conservative accounting;
mutually exclusive alternatives are deliberately added rather than minimized:

| Conversion component | Nodes | Lists | Elements | Occurrences excluding original input |
| --- | ---: | ---: | ---: | ---: |
| Eager source/target split types | 6 | 0 | 0 | 0 |
| Optional input temporary and binding | 3 | 0 | 0 | 9 |
| Map/slide/accessor alternatives combined | 17 | 8 | 10 | 148 |
| Split type label | 1 | 0 | 0 | 4 |
| Split temporary and binding | 3 | 0 | 0 | 9 |
| Optional three-argument reconstruction | 1 | 1 | 3 | 51 |
| Larger check/sequence suffix | 16 | 13 | 18 | 238 |
| **Total** | **47** | **22** | **31** | **459** |

The map/slide row adds: sliding `7/4/6/62`, nonstatic-target argument packing
`6/3/3/56`, static-to-static reference `0/0/0/10`, and conversion to a static
map `4/1/1/20`. The reconstruction occurrence allowance deliberately also
charges its two bound accessors even though argument packing already charges
them. A temporary/binding costs three fresh nodes and at most nine emitted
occurrences besides its definition/context. The supplied child occurs once
as the input binding's definition if complex; otherwise all repeated uses
have the cheap-reference bound already charged. Adding one full input cost
therefore remains sound in both cases.

The implementation is `src/why/why-gen-expr.adb:982–1512`. Empty/predicate
branches and early returns can only reduce this envelope under the stated
premises; the eager type allocations still count. This envelope prices one
conversion invocation, not the number of caller invocations or the complete
String expression language.

### A conditional ordinary String concatenation envelope

Under the same ordinary String shape premise, with two String operands
(neither operand is a Character component), `Transform_Concatenation`
has a finite wrapper envelope. Its result and ultimate ancestor are
unconstrained `Standard.String`, with the static nonempty Positive index
type and no fixed-lower-bound feature. This removes the constrained-ancestor
sliding branch, but retains both the static-empty-left and dynamic-empty-left
paths. Charge supplied child translations and cached symbol/module setup
separately (`src/why/gnat2why-expr.adb:21976–22351`).

As above, `New_Temp_For_Expr` either replaces a complex operand with a cheap
temporary or retains an identifier/dereference with at most ten occurrences.
Both bindings preserve each supplied complex child exactly once. An
`Add_Array_Arg` on such an operand costs at most six nodes, three lists,
three elements and fifty-six occurrences: map conversion plus first and last
accessors (`src/why/why-gen-arrays.adb:223–304`). `Build_Length_Expr` on the
already normalized Integer bounds adds one call/list with two elements and
eight occurrences (`:537–580`).

The complete additive accounting, deliberately summing mutually exclusive
static-empty and nonempty alternatives, is:

| Concatenation component | Nodes | Lists | Elements | Occurrences excluding original children |
| --- | ---: | ---: | ---: | ---: |
| Eager Character type, unused for two String operands | 2 | 0 | 0 | 0 |
| Left first-bound helper | 1 | 1 | 1 | counted where referenced below |
| Static-empty alternative, including unused right-first helper | 1 | 1 | 1 | 10 |
| Two packed arrays, no-slide last bound and concat call | 21 | 12 | 20 | 188 |
| Reconstructed last bound, range check and array reconstruction | 16 | 11 | 18 | 171 |
| Dynamic-empty-left condition and reconstructed right alternative | 13 | 7 | 9 | 97 |
| Two optional temporary/binding pairs | 6 | 0 | 0 | 18 |
| **Total** | **60** | **32** | **49** | **484** |

The no-slide last bound costs at most `6/5/7/66`: an eagerly allocated but
unused `One_Term`, the Positive last-bound helper, two right-bound accessors,
one length call and one addition. The concat call itself adds three nodes
(fresh nonstatic result type and call), one seven-element list and at most
ten occurrences (`src/why/why-gen-arrays.adb:3261–3281`). With two packed-array
arguments this gives the `21/12/20/188` row.

The reconstructed last bound has four bound accessors, two length calls,
three arithmetic calls and one constant: ten nodes, nine lists, fourteen
elements. Its 131 occurrences include one reference to the already computed
left first bound: `4*18 + 2*8 + 3*8 + 18 + 1`. Add the optional static Positive
range wrapper (`3/1/1/12`), one further first-bound reference (eighteen
occurrences), and ordinary nonstatic array reconstruction (`3/1/3/10`).
That gives the second row's sixteen nodes and 171 emitted overhead, with the
concat result supplied once.

The dynamic-empty-left suffix constructs two right-bound accessors, a right
map conversion, a left-length accessor, zero, equality, reconstruction and
conditional. Its condition costs at most twenty-seven occurrences, its right
alternative sixty-six, and the conditional/type four, totaling ninety-seven.
The preceding result occurs once as the other branch. Each temporary/binding
pair costs three fresh nodes and at most nine occurrences excluding its
definition and context. Unused eager constructions remain in allocation totals.

This gives `child(left) + child(right) + 484` as a serialized wrapper allowance
for one concat translation under these premises, with the separate lifetime
components in the table. It does not count an enclosing expected-type array
conversion, frontend-generated folded literal translation, or a second
translation of an immutable initializer.

### Ordinary String comparison and Integer Image wrappers

Using the same String/accessor premises, the program/term String comparison
wrappers also preserve each complex supplied operand once
(`src/why/gnat2why-expr.adb:18547–18735`). Their initialization-check helper
returns the original operand for ordinary initialized String/Character, but
**first eagerly calls `New_Temp_For_Expr`**, allocating up to two discarded
nodes per operand (`src/why/why-gen-init.adb:502–554`). These are in addition
to the useful operand temporaries later created by the comparison itself.
String/Character have no user type invariant, so the equality helper's
invariant check returns before allocating a Why expression
(`src/why/gnat2why-expr.adb:11736–11778`;
`src/spark/spark_util-types.adb:1521–1620`).

Both paths pack two array arguments, at most `12/6/6/112`, and add two useful
temporary/binding pairs, at most six nodes and eighteen occurrences.
The ordering path then calls the six-argument comparison function and compares
its Integer result with one new zero. Equality calls the six-argument array
equality function, with an optional one-argument Boolean negation for `/=`.
Including the four discarded initialization-check nodes, the common wrapper
allowance is **twenty-five nodes, eight lists, fourteen elements and 147
emitted occurrences**, plus each supplied child once. The ordering maximum
is `112 + 18 + 8 + 1 + 8` occurrences. This excludes enclosing expected-type
conversions, symbol setup and predicate-domain pretty labels.

`Integer'Image` translates its scalar argument once at builtin Integer, calls
the existing image function, then calls `to_string` with that result and one
new maximum-image-size constant (`src/why/gnat2why-expr.adb:20256–20300`).
The returned `EW_Abstract(Standard_String)` adds two fresh nodes; the two
calls and constant add three. Thus the Image core costs **five nodes, two
lists, three elements and at most eighteen emitted occurrences**, excluding
the scalar child and expected-type String conversion. The first call's
identifier has at most six occurrences; allowing its optional type field
three gives ten overhead. The outer call contributes at most eight:
call, three-occurrence `To_String_Id`, three-occurrence String type and the
constant. The relevant fixed symbols/types are in
`src/why/why-atree-modules.adb:870–893, 2765–2775, 3962–3975`.
Symbol/theory initialization and the later Image adapter remain separately
accounted stages; this prices the retained producer's actual Image syntax.

## Declaration, type and module caller closure

The following additional results close invocation multiplicities. They remain
parameterized by the frontend-generated object/type set; they do not equate
that set with the number of declarations spelled by the user.

**Entity passes and file count.** `Entities_To_Translate` iterates `Entity_List`
(`src/spark/spark_definition.ads:215–232` and `.adb:14999–15035`). For ordinary
nonpackage object/type entities, `Mark_Entity` returns immediately if the entity
was already marked and inserts it into `Entity_Set` before recursive marking;
the successful path appends it once (`.adb:11848–11890, 12186–12248`). The driver
then makes one pass each for translation, completion and VC generation
(`src/why/gnat2why-driver.adb:1323–1335, 1432–1445`). If `E_list` bounds all list
entries, including fixed dependencies, the number of printed files satisfies
`F <= E_list`: each entry reaches `Do_Generate_VCs` at most once, and that call
prints at most one file. This deliberately avoids the still-stronger assertion
that Main always produces exactly one file.

**Initializer multiplicity.** One ordinary object-declaration transformation
calls `Assignment_Of_Obj_Decl`, which translates its initializer once in the
program domain (`src/why/gnat2why-expr.adb:1384–1460, 22591–22638`). In the
regular mutable case the assignment contains that result once. A regular
immutable value is bound once before the equality assumption. A dynamic String
in split form is likewise bound once before using the temporary for contents
and its two bounds (`:1621–1809`). Thus these wrappers do not duplicate the
translated initializer subtree.

For ordinary immutable constants, the entity translation pass can separately
translate the initializer once in the term domain
(`src/why/gnat2why-decls.adb:122–270`). Even when its defining axiom is omitted
because the result contains a dereference, those allocated nodes still count.
The child-cost allowance is consequently `Prog(init) + Term(init)` for such a
constant, and `Prog(init)` for an ordinary mutable object. This is an upper
allowance: the separate term path can be skipped by its guards or simplify a
static scalar expression.

At the enclosing regular-subprogram layer, `Generate_VCs_For_Subprogram`
translates declarations and handled statements once
(`src/why/gnat2why-subprograms.adb:5840–5872`), and `Transform_Declarations`
traverses each declaration once (`src/why/gnat2why-expr.adb:23201–23215`). The
later `Assume_Value_Of_Constants` excludes constants declared in that unit
(`:2669–2703`), so it does not introduce a third initializer pass for Main's own
ordinary constants. Assumptions for fixed external constants remain a separate
dependency cost. Later references to a constant use its identifier; they do not
recursively translate its initializer again.

**Object/loop theories.** Per ordinary object entity, the translation pass
creates two outer theories: a definition plus either a value axiom or an empty
axiom. Per loop entity it creates the loop-exception theory and an empty axiom
(`src/why/gnat2why-driver.adb:1462–1590`; `src/why/gnat2why-decls.adb:66–115,
122–382, 451–490, 496–812`). The expressions inside those theories can create
their own literal/type-related material, which must not be hidden in the count
of two.

**Generated Integer/String type theories.** Under the ordinary scalar/String
shape, without relaxed-initialization or validity wrappers, access/tagged
features, type invariants or user equality, the outer theory counts are:

| Invocation | Theory opens/closes |
| --- | ---: |
| `Translate_Type(Integer subtype)` | One main, plus at most one scalar representative |
| `Translate_Type(String subtype)` | One main, plus representation-cache miss work |
| `Generate_Type_Completion(itype)` | One axiom |
| `Generate_Type_Completion(non-itype)` | One axiom, plus at most one default-initialization theory |
| `Translate_Type(Standard_String)` | String row, plus one String Image theory |

The translation source is `src/why/gnat2why-types.adb:1623–1739`; completion is
`:895–1101`. Itype completion skips dynamic-invariant and scalar-bound axiom
helpers as well as the non-itype default-initialization branch. For a nonempty
static Integer subtype, `Type_Is_Modeled_As_Base` is false and the representative
branch applies (`src/why/gnat2why-util.adb:1609–1615`). The ordinary equality and
wrapper conditions are defined in `src/spark/spark_util-types.adb:3050–3064` and
`src/why/gnat2why-util.ads:579–581`.

Ordinary rank-one Character String types share a representation key regardless
of their bounds or subtype name. `Get_Array_Theory_Name` uses index representation,
component root name and the relaxed-initialization flag; literal subtypes recurse
to their underlying array type (`src/why/why-gen-arrays.adb:2990–3036`). The first
ordinary-key miss creates two theories, representation and discrete comparison
(`:981–1068, 1075–1142, 1772–1906`). Later hits create none. For `I` Integer
itypes and `A` String itypes translated/completed once each, this gives

```text
outer type/completion closes <= 3I + 2A + 2R
```

`R` is the number of new representation keys, at most one for the stated
ordinary String family. Fixed predefined/non-itype types and any other
expression-created theories remain separate. `Declare_Ada_Array`,
`Declare_Scalar_Type` and `Define_Scalar_Rep_Proj` emit into their caller's
theory; their declaration costs are not included merely by counting closes.

**Eager array cache allocation.** Every ordinary
`Create_Rep_Array_Theory_If_Needed` attempt allocates seventeen Why nodes and no
Why lists **before testing the cache**, including on a hit:

```text
1 module + 2 names + 2 types + 6(identifier + name) = 17 nodes
```

These are the declarations at `src/why/why-gen-arrays.adb:1078–1085`, expanded by
`Init_Array_Module` (`src/why/why-atree-modules.adb:918–974`) and `New_Identifier`
(`src/why/why-gen-names.adb:786–808, 825–832`). A first miss additionally
initializes rank-one helpers with twelve nodes, and comparison module/helpers
with three nodes, excluding the theory construction itself
(`src/why/why-atree-modules.adb:980–1047`). If `C` counts all attempts,
seventeen times `C` belongs in the lifetime allocation bound even though
discarded cache-hit nodes never appear in JSON.

**Memoized entity modules.** `Module_Kind` has twenty-seven members
(`src/why/why-atree-modules.ads:819–851`). `Hashconsed_Entity_Module` allocates
only on a missing `(normalized entity, kind)` key (`.adb:465–504`). Consequently
this component creates at most `27E_entities` module nodes. This does not count
direct `New_Module` calls for literals, VC theories, eager array-cache attempts
or fixed initialization. Keeping those separate makes the remaining module term
concrete without confusing module IDs with unique printed theory symbols.

## Precise remaining obligations

A whole-source rule needs both lifetime allocation bounds and emitted-occurrence
bounds, then safe checks against the respective representation ranges. The exact
DAG recurrence above is computable **given the generated DAG**, but is not yet
an independent admission calculation from authoritative Silver source.

| Missing term | Concrete caller closure required |
| --- | --- |
| Frontend-to-producer inputs | Bound generated entities, anonymous types, range captures and static/folded literal nodes for the admitted Main grammar and fixed dependencies; link these to source-derived quantities. |
| Declaration/helper cost | The ordinary initializer child multiplicities, source Integer declaration/assignment wrappers and object outer-theory count are closed above. Price String wrappers and handle frontend-generated declarations/types. |
| Type/module cost | The ordinary itype outer-theory and memoized entity-module counts are closed above. Price the declarations emitted inside those theories, fixed initialization and remaining directly created modules. |
| Expression helper overhead | The normalized scalar-expression core and static Integer boundaries are closed above. Price dynamic String reconstruction, comparisons, Image and String assignment helpers, including lazily initialized symbols. Child-once properties do not make these costs zero. |
| Loop per-entity overhead | Close `H` and `K_loop` for the Integer/String shapes and actual library write-global set, retaining the two endpoint domains and snapshot accounting. |
| Fixed libraries at call sites | Separate one-time fixed library theories from per-call argument binding, contract/check substitution, globals and any permitted inlining. Fixed library source size does not imply constant total call-site cost. |
| Printing-plan source bound | The coarse `F <= E_list` bound is closed above. Supply the frontend/dependency bound on `E_list`; sharpening Main to one file would require closing generated-entity and type-VC guards. |
| Lifetime nodes and lists | Charge builders and list creation in paths whose results are simplified, discarded or never printed. The final JSON tree cannot observe them. |

The existing source/certificate model supplies useful grammar and semantic
quantities, including declaration/expression/loop structure. It does not yet
establish these external producer transformation bounds. Samples, observed JSON
growth, or a successful large proof run would not close that gap.

The next feasible step is a cost model for this finite reachable grammar,
parameterized by the frontend-generated entity/literal bounds: maintain separate
node, list, list-element and serialized-occurrence components; first close
ordinary declarations and their subtype theories, then expression helpers and
library calls, then emitted-file selection. Each leaf needs source justification
and a composition lemma. The closed literal and child-multiplicity results above
can be reused directly. This investigation does **not** establish that the work
is impossible or that an external toolchain modification is necessary.

Until those terms are closed, no sound expanded threshold follows from this
producer analysis. Retain the current admission rules and the unchanged Oracle;
record the capacity prerequisite as incomplete rather than selecting an
empirical cutoff or proceeding with dependent admission changes.

## Reproducing the evidence checks

Run only the retained-fixture/arithmetic checks:

```sh
python3 docs/evidence/retained-producer-capacity-20261017/capture.py
```

To regenerate source excerpts, add `--source-root` pointing at the already
archived SPARK source snapshot. `--retained-json` and `--retained-source` can
re-extract the old fixture from paths recorded in `retained-input.json`.
Add `--source-archive` with
`docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz`
to verify every manifest file against that retained archive.
Outputs are deterministic; no toolchain or proof subprocess is launched.
These checks validate the arithmetic and captured tree shapes, not a completed
producer theorem or the whole application assurance argument.

A focused independent source/evidence review found no defect in the numerical
literal components. Its loop-entry wording correction above distinguishes
`Entire_Object` from `Not_Written`; the recurrence already includes both in `H`.
The review also requested the additional retained conversion/base-type excerpts.
It independently checked the original artifact hashes, exact three-module
extraction, retained-source equality and complete source-file hashes.
