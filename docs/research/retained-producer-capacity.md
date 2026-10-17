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

### Static literal theory and use overhead

The Main String shape result below excludes the nonstatic-lower-bound literal
path. For one invocation of `Transform_String_Literal` on a static ordinary
String, the work outside the module-cache miss has this maximum, whether or not
the theory already exists:

| Per-invocation work | Nodes | Lists | Elements |
| --- | ---: | ---: | ---: |
| Fresh map type, name and direct module | 3 | 0 | 0 |
| Final function identifier/name and call | 3 | 1 | 1 |
| Eager program-domain low/offset constants and last-index addition | 3 | 1 | 2 |
| **Total** | **9** | **2** | **3** |

The static program-domain check takes the asserted compile-time-known branch;
its low/offset/addition work is nevertheless allocated before being discarded.
The term-domain and empty-literal cases are smaller. The returned literal call
has **fourteen occurrences**: call 1, qualified identifier 6, unit value 4 and
map type 3 (`src/why/gnat2why-expr.adb:30221–30255,30525–30666`).

On the first invocation for an expression, add the following fixed module work,
besides the character predicate and `Close_Theory` imports:

| Module-cache-miss work | Nodes | Lists | Elements |
| --- | ---: | ---: | ---: |
| Eager unused low temporary/name | 2 | 0 | 0 |
| Fresh unit-parameter identifier/name | 2 | 0 | 0 |
| Definition identifier/name and direct module | 3 | 0 | 0 |
| Theory header and its three declaration entries | 1 | 2 | 3 |
| Function declaration, unit binder and default empty effects | 3 | 4 | 1 |
| Definition call on the unit binder | 1 | 1 | 1 |
| Trigger and trigger collection | 2 | 2 | 2 |
| Universal quantifier and its unit binder | 2 | 1 | 1 |
| Definition axiom and dependency | 2 | 0 | 0 |
| Well-formed literal call and predicate | 2 | 2 | 2 |
| Well-formed axiom and dependency | 2 | 0 | 0 |
| **Total** | **22** | **12** | **10** |

`Unit_Param` constructs a fresh identifier/name (`src/why/why-gen-binders.adb:1626–1640`);
it is a function, not a shared preallocated binder. `New_Function_Decl`'s default
`New_Effects` allocates three empty list records;
these count despite containing no elements. The named literal module also
consumes one string-valued temporary name without allocating a Why identifier;
that counter is not silently bounded by identifier allocations alone.
The helper/schema sources are `src/why/why-gen-binders.adb:1222–1307,1392–1412`,
`src/why/why-gen-arrays.adb:3835–3848`,
`src/why/why-inter.adb:1268–1283`, and
`src/why/xgen/xtree_sinfo.adb:112–122,171–194,219–229,579–610,721–735`.

The same source shapes give **seventy-four fixed emitted occurrences** per
static literal theory: header 1, function declaration 19, definition axiom
30 excluding its character predicate, and well-formed axiom 24. The function
row is `1+5+7+1+1+1+3`: node, local function identifier, unit binder, empty
effects, True pre/post, and map return type. The definition axiom row is
`1+(1+7+(1+1+13))+(1+5)`: axiom, quantifier/binder/triggered call, dependency.
The final axiom is `1+(1+3+13)+(1+5)`. Thus imports aside this is a source-derived
shape bound, not an extrapolation of the retained fixture.

If `R_lit` counts literal translations, `K_lit` counts their distinct cache
misses, and `L_i` are the lengths of the literals defined on those misses, the
complete static literal component excluding imports and cached symbol setup is

```text
N <= 9 R_lit + 22 K_lit + sum(7 L_i + [L_i >= 2])
L <= 2 R_lit + 12 K_lit + sum(3 L_i + [L_i >= 2])
J <= 3 R_lit + 10 K_lit + sum(5 L_i + max(L_i-2, 0))
O <= 14 R_lit + 74 K_lit + sum(P(L_i))
```

`O` charges each returned expression once at its caller and each distinct
literal theory once; the later printing-plan multiplier is separate. A miss
adds one theory close and one direct module; each invocation adds one further
direct module through its fresh map type. The frontend derivation bounds the
available literal identities and aggregate generated lengths; caller replay
still determines `R_lit`. Immutable initializer retranslation need not define a
second theory for the same literal identity.

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
occurrences, giving `74 + P(L) + 2*8`. The fixed overhead agrees with the source-derived static shape above. This
fixture is corroboration, not evidence about other literal shapes or the whole
producer. The retained script checks these values and contiguous serialized
occurrence IDs without invoking GNATprove.

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
bindings on the nontrivial path are priced below. The following frontend
argument discharges their shape premise for ordinary Main expressions.

### Main String shape invariant

For successful analysis of the admitted Main grammar, every String type reaching
these ordinary expression/assignment helpers is rank-one Standard.Character,
and is either statically constrained (possibly null) or unconstrained
Standard.String. This statement concerns the GNATprove semantic/light-expansion
path, not later native expansion or arbitrary library implementation types.
The [frontend entity derivation](retained-frontend-entities.md#string-types-under-light-expansion)
retains the GCC source revision and the corresponding Main type-generation
paths. The GCC references in this paragraph are relative to that report's
`gcc/ada` tree, separately from the SPARK producer source cited elsewhere here.

The proof is induction over the ordered declaration and expression grammar:

- A literal, including a folded concatenation, receives a literal subtype with
  static lower bound 1. A static literal initializer creates a static array
  constraint; a static name initializer reuses or aliases its existing static
  subtype. The alias keeps the existing static index bounds
  (`sem_res.adb:13205–13337`; `exp_util.adb:5920–6011`).
- For every nonstatic initializer, `Expand_Subtype_From_Expr` returns before
  rewriting the source `String` subtype mark in GNATprove mode. The subsequent
  `Find_Type_Of_Object`/`Process_Subtype` therefore returns the existing
  Standard.String entity (`exp_util.adb:5873–5899`;
  `sem_ch3.adb:19080–19214`). `Analyze_Object_Declaration` assigns this `Act_T`
  as the object's Etype (`sem_ch3.adb:5341`). This covers mutable copies, Image,
  First_Or_Default and their nonstatic concatenations, regardless of whether
  Silver separately knows their value or length.
- A nonfolded concatenation receives `Base_Type(Typ)`, hence Standard.String;
  Image and First_Or_Default likewise have Standard.String results
  (`sem_res.adb:10786`; the frontend report's Image/call analysis).
- The two object-declaration `Actual_Subtype` setters are guarded respectively
  by scalar type and aliased uninitialized discriminated record conditions
  (`sem_ch3.adb:4800–4840,5305–5348`), excluding these String objects.
  `Set_Assignment_Type` does not create an actual subtype for an ordinary
  named local String target (`sem_ch5.adb:300–365`). Main has no slices,
  explicit dereferences, components, renamings or out/in-out parameters.
  The frontend report closes the remaining actual-subtype/type-generation
  paths and re-entry cases.

No Main String has fixed-lower-bound aspects, user predicates, initialization
wrappers, qualifications or element-type conversions in this grammar. The
producer does not introduce a new Ada constraint when retrieving these shapes:
`Mk_Item_Of_Entity` chooses the existing Actual_Subtype if present, otherwise
Etype (`src/why/why-gen-binders.adb:745–786`); `Type_Of_Node` uses existing binder
and Ada type information (`src/why/why-inter.adb:1579–1632`). Its
`New_Kind_Base_Type` constructs Why names/types/modules, not Ada subtypes
(`:1158–1224`). `Array_From_Split_Form` likewise uses the original content type
entity (`src/why/why-gen-arrays.adb:412–448`). Consequently the Main helper
premise covers source names, generated literal/static alias types and binder
lookups. Fixed-library body types require their own accounting below.

### Ordinary String conversion envelope

The following closes one Main `Insert_Array_Conversion` under the discharged
shape invariant above. The call is not a qualified expression. Cached
symbol/entity-module initialization and caller construction of the
already-supplied expected type remain separate.

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

### Ordinary String concatenation envelope

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

### Ordinary String initializer assignment core

`Assignment_Of_Obj_Decl` prices the executable initialization before
`Transform_Declaration` adds its dynamic-invariant assumption. Exclude the one
initializer translation, its expected-type conversion, binder/symbol setup and
the later invariant suffix from this component. For a mutable unconstrained
String, the UCArray binder path has the following maximum:

| Initialization component | Nodes | Lists | Elements | Emitted overhead |
| --- | ---: | ---: | ---: | ---: |
| Expected abstract type | 2 | 0 | 0 | 0 |
| Discarded move temporary/name | 2 | 0 | 0 | 0 |
| Initializer temporary/name | 2 | 0 | 0 | charged at its uses below |
| Map conversion and contents assignment | 5 | 1 | 1 | 25 |
| Two bound conversions/accessors, equalities and assumptions | 8 | 6 | 8 | 82 |
| Three-statement sequence | 1 | 1 | 3 | 1 |
| Outer initializer binding | 1 | 0 | 0 | 8 |
| **Total** | **21** | **8** | **12** | **116** |

`Why_Type_Of_Entity` retrieves the regular binder type or constructs the UCArray
abstract type (`src/why/gnat2why-util.adb:1889–1909`;
`src/why/why-gen-binders.adb:448–481`). In the UCArray path, each stored bound
identifier has at most six occurrences and is converted to builtin Integer
with one call, giving at most fourteen. The corresponding initializer bound
accessor has at most eighteen. Each equality/assumption therefore has at most
`14+18+8+1 = 41` occurrences. Both conversions allocate their argument lists.
The three-argument `Append` constructs one three-element statement list
(`src/why/why-gen-progs.adb:38–58,329–364`). The map conversion, contents
assignment and outer binding use the previously derived three-occurrence
String types and five-occurrence local initializer temporary.

The regular immutable path creates a temporary, equality, assumption and
binding; its maximum is smaller. The regular mutable path emits only the
assignment. The ordinary Strings have no validity, initialization or move-tree
flags, overlays, tags or borrowing work. Thus **21/8/12/116** is a common
initializer-assignment-core bound for every source String declaration
(`src/why/gnat2why-expr.adb:1384–1460,1621–1831`), with the initializer supplied
once. This is deliberately not called a complete String declaration bound:
`Transform_Declaration` next constructs an object read and dynamic-invariant
assumption, sequence and location label. A generated static alias can be an
itype, preventing the simple named-predicate shortcut. The fixed rank-one
String/Character invariant expansion is priced next.

### String declaration dynamic-invariant suffix

`Transform_Declaration` calls `Transform_Identifier` directly for the initialized
object, then `Assume_Dynamic_Invariant` with `Only_Var => False`
(`src/why/gnat2why-expr.adb:22591–22638`). Unlike a call through `Transform_Expr`,
this read does not separately construct an expected type or insert an array
conversion. The earlier read bound is at most `6/3/5`, with at most forty-eight
emitted occurrences. There are two invariant paths, both with bounded discarded
work (`:6396–6524,6730–6824,7080–7230`).

For a non-itype String type, `Compute_Dynamic_Invariant` calls the existing
five-argument invariant predicate. Its type has no free dynamic-invariant
variables: static array bounds are fixed, and unconstrained Standard.String
uses the fixed Positive index type. However, its following local type-invariant
check **does not return before constructing array helpers**. With
`Include_Comp => True`, `Compute_Type_Invariant` instantiates
`Build_Predicate_For_Array`, which calls the binary helper on the same array
expression twice. That helper eagerly builds a range and **two** element
accesses, then returns True because ordinary Character has no user invariant
(`:8782–8999`; `src/why/why-gen-arrays.adb:473–534,614–630`).

The common rank-one traversal allocation, before its component callback, is:

| Eager array-predicate work | Static array | Nonstatic array |
| --- | --- | --- |
| Index temporary/name | `2/0/0` | `2/0/0` |
| Two bound accessors, two comparisons and conjunction | `5/5/6` | `5/5/6` |
| Two element accesses, including fresh Character types | `6/2/4` | `14/4/6` |
| **Total nodes/lists/elements** | **`13/7/10`** | **`21/9/12`** |

A nonstatic element access first calls `Array_Convert_To_Base`; both calls are
made even though one component callback argument is unused. Each static bound
accessor has the earlier `1/1/1` allowance; a nonstatic accessor has the same
allocation allowance even when its supplied object expression is complex.
The discarded predicates/accesses contribute no emitted occurrences. The
sources are `src/why/why-gen-arrays.adb:3042–3104` and
`src/why/why-gen-expr.adb:4883–4922`.

A static String alias can instead be an itype. The expanded invariant then
returns the array well-formed predicate. The element callback invokes
`Compute_Dynamic_Invariant` on a Character value represented as an abstract
Character, whereas `Pred_Main_Ty` is split. Thus it skips the named predicate
and scalar split-representation property branches; its ordinary abstract type
already carries the scalar range. The callback returns True. It nevertheless
allocates its split expected type and the predicate-guard temporaries before
that return. Both the enclosing String and the Character callback eagerly
call `Pred_Of_Boolean_Term` and build a conditional for the absent dynamic
predicate. `Pred_Of_Boolean_Term` always constructs an equality call; ordinary
`New_Conditional` is a builder, not `New_Simpl_Conditional`
(`src/why/why-gen-expr.adb:4937–4956,5436–5441`). Its `Bool_True` argument also allocates a literal
(`src/why/why-gen-expr.ads:65–68`). The unused literal/call/conditional groups
cost `3/2/2` each, including each empty Elsif list. Global/local type
invariant traversals in this expanded path set `Include_Comp => False`, so
there is only the one array traversal above.

Combining those paths, excluding the allocation of the supplied object read
but including its occurrences where retained:

| Dynamic-invariant path | Nodes | Lists | Elements | Occurrences |
| --- | ---: | ---: | ---: | ---: |
| Named predicate plus discarded local-invariant traversal | 25 | 10 | 17 | 69 |
| Static itype: well-formed predicate plus discarded component traversal | 24 | 12 | 15 | 56 |
| **Componentwise common bound** | **25** | **12** | **17** | **69** |

The named row is type lookup at most three nodes, one predicate call/list with
five arguments, and the larger discarded traversal `21/9/12`. Its occurrences
are at most `48+4*3+6+2+1 = 69`: the read, four Boolean flags, predicate
identifier, result type and call. The static-itype allocation is type lookup
3, enclosing unused guard group 3, well-formed call 1, static traversal 13, and
Character callback 4. Its emitted predicate is at most `48+8 = 56`.

The object read adds `6/3/5` allocations; the assumption, sequence and final
location label add `3/1/2` and three emitted occurrences. Therefore this complete
source String declaration suffix is at most **34/16/24/72**. Combined with the
initializer assignment core, the **ordinary source String declaration wrapper
is at most 55 nodes, 24 lists, 36 elements and 188 emitted occurrences**.
The one initializer and its expected-type conversion, symbol/binder setup,
separate generated subtype declarations, outer entity theories and enclosing
statement list remain excluded. These are caller costs, not silently free work.

### Ordinary String assignment wrapper

Under the same String-shape premise, a whole-object String assignment can be
priced while allowing the target binder's `Actual_Subtype` to differ from the
syntactic target type. The following excludes the one RHS translation and its
initial expected-type conversion, symbol/module setup and enclosing statement
list construction. It includes target-side type creation and two later
conversion allowances.

`Transform_Assignment_Statement` may preserve the target's runtime bounds by
binding the RHS and a reconstructed target value, emitting `New_Length_Equality`
and a located assertion, then binding the RHS once around that check. For the
target read, allow fourteen nodes: two for the expected abstract type, six for
the split-binder reconstruction and six eager nodes for its same-entity array
conversion; its emitted expression is at most forty-eight occurrences. The
read's temporary/name and binding are additional. The overload supplying the
expected type calls `Type_Of_Node` once
(`src/why/gnat2why-expr.adb:25668–25724`).

The remaining ordinary path is captured by this conservative table:

| Assignment component | Nodes | Lists | Elements | Emitted overhead |
| --- | ---: | ---: | ---: | ---: |
| Dispatcher target type and discarded target temporary | 4 | 0 | 0 | 0 |
| RHS expected type | 3 | 0 | 0 | 0 |
| Optional RHS temporary and binding | 3 | 0 | 0 | 9 |
| Target read, temporary and binding | 17 | 3 | 5 | 57 |
| Length equality, located assertion and sequence | 16 | 13 | 18 | 243 |
| Expected types for two subsequent conversions | 4 | 0 | 0 | 0 |
| Discarded move temporary | 2 | 0 | 0 | 0 |
| Target map conversion and assignment | 5 | 1 | 1 | 20 |
| **Subtotal before the two conversion bodies** | **54** | **17** | **24** | **329** |

The check/sequence row adds the RHS temporary's at-most-five occurrences to
the previous length-check suffix of 238. `Type_Of_Node` on a regular binder
reuses its type, whereas a split-array binder may create its abstract type;
two nodes cover each target-type lookup. The RHS expected type may instead
be a static map type, so its allowance is three. Reconstructing a regular
static target or skipping the runtime-length check is smaller than these
combined allowances.

After that check, `Insert_Simple_Conversion` converts to the binder type;
the whole-object assignment helper calls it again before the regular/map
assignment (`src/why/gnat2why-expr.adb:19238–19295, 12286–12440`). Charge the
full array-conversion envelope for **both** calls, even though
an identity comparison commonly returns early. This avoids assuming equality
between the source type and `Actual_Subtype`. The resulting wrapper bound is
**148 fresh nodes, 61 lists, 86 elements and 1,247 emitted occurrences**:
`54/17/24/329 + 2*(47/22/31/459)`. Each conversion preserves its supplied
child once, so the translated RHS still has coefficient one. The ordinary
path has no discriminant/tag/validity/borrow/move-tree work. The Main String
shape invariant covers every ordinary source assignment; this does not price
fixed-library body assignments with richer types.

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

### Ordinary array-representation cache miss bodies

The single ordinary rank-one Character representation key also has a closed
body cost. Keep the earlier seventeen-node charge for **every** cache attempt,
and all `Close_Theory` imports, separate. Cached Standard/Integer/Character
symbol initialization remains in the fixed/setup terms. On a key miss, the
two theory bodies and extra helper symbols contribute at most
**148 nodes, 44 lists, 76 elements and 711 emitted occurrences**.

The common `Prepare_Indexes_Substitutions` helper has one Integer index. It
creates the local `index_*_one` identifier/name, a prefix module, the defining
function with its default effects and constant 1, and seven substitutions with
fresh original names (`src/why/why-gen-arrays.adb:3850–3969`). Its cost is
**20/4/1/44**, counting its emitted function's one declaration-list element but
leaving the seven returned substitutions for the caller's clone list. The
function contributes nine occurrences and each substitution at most five:
substitution, original name/module and image name/module. This helper creates
one direct prefix module. `To_Name` and both `To_Local` overloads allocate fresh
name/identifier nodes; they are not cached lookup aliases
(`src/why/why-gen-names.adb:1136–1180`).

The representation theory first emits that function, a transparent component
type alias and a clone with eight substitutions. Its pre-equality cost is
**30/8/11/56**: header `1/2/0`, index helper `20/4/1`, component substitution
`3/0/0`, type alias `5/1/1`, and clone `1/1/9`. The alias has a fresh name,
Character abstract type/name, transparent-definition node and type-declaration
node; its empty type-argument list still allocates. See
`src/why/why-gen-arrays.adb:981–1068` and
`src/why/why-gen-decl.adb:283–295`. Its occurrences are
`1+44+3+6+2 = 56`, including the clone and its origin module.

`Declare_Equality_Function` has one index and six parameters: two maps and
four Integer bounds. Its ordinary Character path is fully finite
(`src/why/why-gen-arrays.adb:1913–2222`). The allocation accounting is:

| Equality helper part | Nodes | Lists | Elements |
| --- | ---: | ---: | ---: |
| Local map type, two array identifiers, index and four bound identifiers | 16 | 0 | 0 |
| Shifted right index | 2 | 2 | 4 |
| Index range predicate | 3 | 3 | 4 |
| Length equality, including conditional and conjunction | 8 | 8 | 12 |
| Character types, local symbols, two accesses and scalar equality | 16 | 5 | 8 |
| Range implication, one-index quantifier and conjunction | 4 | 3 | 1 |
| Function declaration, six binders, effects and emission | 8 | 4 | 7 |
| Reverse call/comparison, guarded axiom, six binders, dependency and emission | 12 | 4 | 15 |
| **Total** | **69** | **29** | **51** |

The scalar equality eagerly constructs one split Character type, converts both
abstract Character operands to builtin Integer, then calls equality
(`src/why/why-gen-expr.adb:3405–3479`). The two earlier same-Character
expected-type constructions are also charged, although their conversions
return unchanged. The guarded axiom uses one implication connection and a
six-binder universal quantifier (`src/why/why-gen-binders.adb:1346–1371`).

For occurrence accounting, each map/bound/index reference has four occurrences;
the local `get` identifier has at most five. The shifted index costs 28, range
predicate 33, and length equality 92. The two element reads have respectively
17 and 41 occurrences; scalar conversion/equality gives 82. Adding the range
implication and index quantifier gives 126, then the length conjunction gives
**219 occurrences for the shared definition**. This definition occurs once in
the function and again in the reverse axiom: both copies must be serialized.
The function is at most 273 occurrences; the reverse call/comparison is at most
44, and the complete guarded reverse axiom at most 315. Thus the equality helper
emits at most **588** occurrences, not merely the DAG's shared-node count.

The separate comparison theory has a fresh abstract Character type, its header,
five additional substitutions, another Integer index helper and one clone with
twelve substitutions (`src/why/why-gen-arrays.adb:1772–1906`). This costs
**34/7/14/67**. Character has no relaxed initialization and is nonmodular, so
neither wrapper conversion bodies nor bitvector alternatives apply.

The total miss body is therefore:

| Miss component | Nodes | Lists | Elements | Occurrences |
| --- | ---: | ---: | ---: | ---: |
| Representation theory before equality | 30 | 8 | 11 | 56 |
| Equality helper | 69 | 29 | 51 | 588 |
| Comparison theory | 34 | 7 | 14 | 67 |
| Existing rank-one/comparison helper-symbol initialization | 15 | 0 | 0 | 0 |
| **Total** | **148** | **44** | **76** | **711** |

The fifteen extra nodes are the twelve rank-one helper nodes plus comparison
module/identifier/name already identified above. For `a` attempts and `r` misses,
this component adds `17a+148r` nodes, `44r` lists, `76r` elements and `711r`
occurrences before imports. It has `2r` closes and `a+3r` direct module
allocations: the attempt's representation module, plus the comparison module
and two index-prefix modules on a miss. For ordinary Main Character Strings,
`r <= 1`; fixed dependencies with other representation keys remain separate.
The count of attempts still needs its source-to-helper caller closure.

**Memoized entity modules.** `Module_Kind` has twenty-seven members
(`src/why/why-atree-modules.ads:819–851`). `Hashconsed_Entity_Module` allocates
only on a missing `(normalized entity, kind)` key (`.adb:465–504`). Consequently
this component creates at most `27E_entities` module nodes. This does not count
direct `New_Module` calls for literals, VC theories, eager array-cache attempts
or fixed initialization. Keeping those separate makes the remaining module term
concrete without confusing module IDs with unique printed theory symbols.

## Aggregate formula and finite remaining helper families

Use four-component costs in the order `(nodes, lists, list elements, emitted
occurrences)`. The first three count lifetime allocations, including discarded
work. The fourth counts every theory root once, with repeated child references
expanded, before repeating theories between output files. Define `B(P)` as the
sum of all non-`Close_Theory`-import costs for program `P`, including fixed
setup/dependencies, headers, explicit imports, and the finite helper terms
listed below. Let `M(P)` bound all module IDs, `C(P)` all theory closes, and
`F(P)` all printed files in that process. The final aggregation is

```text
Why nodes       <= B_N(P) + C(P) * (2 + 2 M(P))
Why lists       <= B_L(P)
Why elements    <= B_J(P) + C(P) * (2 + 2 M(P))
emitted counter <= F(P) * (B_O(P) + C(P) * (4 + 4 M(P)))
```

Each `Add_With_Clause` allocates one include node, appends one element to the
existing theory includes list, and serializes that include plus its module:
no new list (`src/why/why-inter.adb:361–382`). The prior close/import argument
supplies `2+2M`. The printing-plan walk emits a theory at most once per file;
therefore multiplying the sum of all created theory skeletons by `F` is safe,
including when many are never selected. It deliberately overcounts a source
expression that also appears in a discarded theory. This does not assume the
process-global counter resets, or that Main always has exactly one output file.

For clarity, the **closed numerical part** of `B` can already be assembled from
these rows. Counts here are producer invocations, with caller multiplicities
applied; they are not unqualified raw source-token counts. Disjoint accounting
must avoid charging the extra conversions inside the String-assignment wrapper
again as standalone conversions.

| Charged component | Cost vector |
| --- | --- |
| Normalized Integer tree with `l` leaves and `o` operators | `(2l+4o, 2o, 3o, 11l+20o)` |
| Static nonempty Integer boundary | `(4,1,1,15)` |
| Source Integer declaration wrapper | `(13,3,9,55)` |
| Source Integer assignment wrapper | `(6,0,0,8)` |
| Scalar comparison | `(1,1,2,8)` |
| Boolean not, common program/term allowance | `(1,1,1,8)` |
| Short-circuit wrapper | `(10,2,3,28)` |
| Enabled warning wrapper | `(9,1,3,27)` |
| Nonstatic split-binder String read | `(6,3,5,48)` |
| Full ordinary String conversion | `(47,22,31,459)` |
| Two-String concatenation wrapper | `(60,32,49,484)` |
| String comparison wrapper | `(25,8,14,147)` |
| Integer Image wrapper | `(5,2,3,18)` |
| Complete source String declaration wrapper | `(55,24,36,188)` |
| Source `Name'Length` program/term core | `(20,6,9,92)`; [control derivation](retained-producer-control.md) |
| If skeleton, `q=1+elsif`, `b=q+1` bodies | `(8q+9b,2q+b,2q+3b,26q+27b)`; source children once, action costs separate |
| Positive-source-location statement list of `m` entries | `(m+1,1,m+1,m+5)`; declarations/actions separate |
| Whole-object String assignment wrapper | `(148,61,86,1247)` |
| Static literal use and definition family | The `R_lit/K_lit/L_i` formula above |
| Eager array-representation cache attempt | `(17,0,0,0)` |
| Ordinary rank-one Character representation key miss | `(148,44,76,711)`; imports separate |

Thus write the single pre-import sum as

```text
B(P) = K_fixed + sum(n_q(P) * c_q for the closed rows q)
                + sum(n_h(P) * K_h for the finite helper families h below).
```

`K_h` is a **missing source-derived cost**, not an experimentally fitted
constant or a usable admission allowance. Where a helper receives an expression,
its cost must specify the supplied-child multiplicity; it cannot conceal
retranslation or repeated serialization in a constant. The remaining table is a
coverage obligation, not a claim that the whole producer is already bounded.

| Remaining family | Exact work and source-count connection still required |
| --- | --- |
| `K_fixed` | One-time predefined and selected dependency theories, package processing, symbol initialization, external-constant assumptions, fixed entry/exit work and non-Main entity/list contribution; separate producer processes if the invocation plan has more than one. |
| `K_object` / `K_binder` | Declaration symbol/binder setup and two ordinary object/loop outer theories. Source objects plus at most two generated bound captures per loop are bounded by the frontend report; contents and direct modules are still unpriced. |
| `K_type_int_static`, `K_type_int_loop`, `K_type_string_static`, `K_type_string_literal` | Numerical type/completion contents for the named type families, including range/property/default-initialization helpers. The frontend report distinguishes non-itype object ranges/static-literal String subtypes from Integer index/loop and String alias/literal itypes. Loop-index types can be dynamic or empty and must not be priced as nonempty static source object types. |
| `K_generated_decl` | Executable checks/wrappers for generated static object subtypes, static String index/alias subtypes, loop-index subtypes and at most two loop bound-capture declarations. Attribute/bound-expression translations must be charged here or to the closed expression rows, once consistently. |
| Generated actions and declaration-list wrappers | The [control component](retained-producer-control.md) closes source Length, if skeletons and ordinary source statement lists. It keeps frontend Actions/generated statements without source locations and the distinct `Transform_Declarations` list helper separate; add those actual callers here. |
| `K_loop`, `H_int`, `H_string`, `H_global` | Per-loop fixed framing plus snapshots/preservation for each modified root. The existing `sum(|Q_loop|) <= F_loops(D+G)` bound applies; the finite actual fixed-library write-global set must determine `G` and its helper shapes. |
| `K_call[j]` | One wrapper family for each admitted library operation: Put, Put_Line, First_Or_Default, Input_Is_Valid and Reject. Count source call sites and any immutable initializer replay; price actual binding, conversions, checks, contracts/effects and globals. The frontend report excludes body inlining into Main, but fixed package source size alone is not a per-call bound. |
| Invocation map and counters | Close `n_q(P)` and `n_h(P)` from the source grammar and frontend-generated counts, including expected-type construction and all conversion/lookups. Ordinary initializers need at most program plus term translation; Main-local constants have no third assumption pass. Generated captures, type helpers and fixed call wrappers still require their own counts. Bound `M`, `C`, `F <= E_list` and the temporary-name counter from the same accounting. |

The [frontend report](retained-frontend-entities.md) now supplies the Main entity,
type and literal multiplicities, including generated literal lengths; they are
no longer an undifferentiated missing frontend inventory. Standard and selected
dependencies still contribute separately to `E_list` and the fixed terms.
Known caller bounds include twenty-seven memoized module kinds per entity,
two object/loop outer closes, the type/completion close table, and one close
per distinct literal theory. Remaining direct modules and helper closes must
be added; source entities are not themselves counts of translation attempts.

This is one aggregate target with finitely named reachable helper families.
It still has unpriced terms and unclosed invocation counts, so it is **not** a
source-capacity rule and supplies no new admission threshold. The derivation
must additionally compare every independent representation counter with its
actual range. Samples, retained JSON sizes and successful proof runs cannot
replace those missing source arguments. Continue closing these helper families
before dependent admission changes; retain the current language and Oracle.

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
