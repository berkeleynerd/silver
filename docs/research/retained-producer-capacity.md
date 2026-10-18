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
This derivation lane performed source and retained-evidence analysis, with
read-only debugger metadata inspection. The separately coordinated
[fixed-producer measurement](retained-producer-fixed.md) records its actual
producer invocations and their narrower scope; no proof run or toolchain
modification was performed by this lane.

## The producer has two different counting problems

`src/why/why-types.ads:35–43` defines signed 32-bit `Why_Int` and
`Why_Node_Id = 0 .. 2^30 - 1`; zero is reserved. Lists occupy
`2^30 .. 2^31 - 1`, with `2^30 - 1` the empty-vector last-index sentinel.
Thus a list vector's length is `Last_Index - 2^30 + 1`, not its last index.
Optional lists still designate allocated lists; their empty case is list
length zero, unlike optional nodes' zero sentinel
(`src/why/xgen/why-atree-to_json.adb-tmpl:121–139`).
The node and list vectors are defined in
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
The later range-loop section supplies the numerical `H` and `K_loop`
allocations and occurrence bounds, including eagerly discarded work. The
recurrence here identifies the source-child multiplicities used there.

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
The Main entity-invocation section below closes the attempt count.

**Memoized entity modules.** `Module_Kind` has twenty-seven members
(`src/why/why-atree-modules.ads:819–851`). `Hashconsed_Entity_Module` allocates
only on a missing `(normalized entity, kind)` key (`.adb:465–504`). Consequently
this component creates at most `27E_entities` module nodes. This does not count
direct `New_Module` calls for literals, VC theories, eager array-cache attempts
or fixed initialization. Keeping those separate makes the remaining module term
concrete without confusing module IDs with unique printed theory symbols.

### Ordinary Main type translation and completion

The following closes the **contents** of the ordinary Main type families,
in addition to the earlier close-count argument. Each row includes one
`Translate_Type` and one `Generate_Type_Completion` visit, their theory
headers, declaration-list entries and explicit imports. It excludes
`Close_Theory` imports, memoized entity symbols/modules, array-representation
attempts/misses, and executable subtype-declaration checks. Those are separate
callers. The [frontend shape argument](retained-frontend-entities.md) supplies
the type-family classification and count, including non-itype object ranges
and static String subtypes; this is not an assumption that all generated types
are itypes.

| Ordinary Main type | Nodes | Lists | Elements | Occurrences | Closes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Static nonempty signed Integer itype | 97 | 39 | 33 | 205 | 3 |
| Static nonempty signed Integer non-itype | 137 | 53 | 48 | 305 | 4 |
| Dynamic or empty signed Integer loop/index itype | 68 | 23 | 24 | 147 | 2 |
| Static rank-one Character String itype, including literal itype | 37 | 14 | 11 | 57 | 2 |
| Static rank-one Character String non-itype | 112 | 43 | 45 | 143 | 3 |

These are componentwise upper bounds, deliberately using a uniform function
declaration allowance: even a raw AST function builder with omitted effects
or pre/post fields is allowed the binder helper's one empty effects node,
three empty effects lists and two True predicate occurrences. No such
allowance is multiplied by a hidden source expression. All names/types in the
counted signatures have at most three type occurrences and five local typed
identifier occurrences; builtin Integer/Boolean have two type occurrences.
This convention makes smaller raw-builder paths safe without pretending that
their omitted effects are actually allocated.

**Signed Integer declaration.** `Declare_Scalar_Type` eagerly constructs a
local Why name and abstract base type (three nodes), including on the dynamic
path. The remaining accounting is:

| Declaration part | Static nonempty | Modeled-as-base itype |
| --- | --- | --- |
| Eager name/base type | `3/0/0/0` | `3/0/0/0` |
| Range definition or transparent alias | `2/1/1/3` | `2/1/1/6` |
| First/last attributes | `10/8/2/28` | `2/0/0/0` |
| Range/dynamic-property predicate | `16/7/6/51` | `18/7/8/65` |
| Clone and substitutions | `12/1/5/14` | `12/1/6/19` |
| **Total** | **`43/17/14/96`** | **`37/9/15/90`** |

The source is `src/why/why-gen-scalars.adb:410–927,1117–1279`.
Static bounds have no proof-variable binders
(`src/why/why-gen-binders.adb:268–277`). A modeled-as-base itype omits
first/last declarations, but its two eager compile-time-known bound literals,
when present, are still counted. Its predicate binds first, last and value;
the static predicate binds only value. The range helper makes two comparisons,
two pretty labels and a conjunction (`src/why/why-gen-expr.adb:4883–4922`).
Its definition has at most 35 occurrences, included once in the function.
The dynamic clone adds a representation-type substitution and two cached
base-conversion names; its five substitutions have at most 17 occurrences.

The shared reference/havoc suffix is at most **29/10/9/55**, including the
two local type-name calls made by its caller. The reference record plus field
projection and two projection metas contributes `19/6/6/36`; the havoc
function contributes `10/4/3/19`. The record field type is serialized both in
the field identifier and field binder; the havoc parameter appears in its
binder and its writes effect. These repeated references are counted
(`src/why/gnat2why-types.adb:1538–1580`,
`src/why/why-gen-decl.adb:94–269`,
`src/why/why-gen-binders.adb:1127–1145,1377–1388`).

A static signed Integer also adds the representation helper
**22/6/10/51**: eight nodes for three substitutions, one explicit include,
`10/5/3/34` for the `to_rep` projection function including its abstract
parameter type, one clone with its three substitutions, and two projection
metas (`src/why/why-gen-scalars.adb:1285–1468`). Its explicit include belongs
here, separately from close-time imports. Static itypes therefore total
`43/17/14/96 + 29/10/9/55 + 22/6/10/51 + 3/6/0/3`.
Dynamic/empty itypes omit that helper and have only two headers. Their type
completion body is empty: itype guards exclude dynamic-invariant, bound-axiom
and default-initialization generation. No dynamic loop bound expression is
silently translated inside these type-theory rows; its executable and
attribute-use callers remain separate.

**Static String declaration.** `Declare_Ada_Array` and its rank-one
`Declare_Constrained` branch have the following common bound:

| Declaration part | Cost |
| --- | --- |
| Eager local type name | `1/0/0/0` |
| Character component alias | `5/1/1/6` |
| Four map/bounds/equality substitutions | `12/0/0/16` |
| Two bound functions and their substitutions | `14/8/2/28` |
| Index representation substitution | `2/0/0/3` |
| Clone skeleton and seven substitution-list entries | `1/1/8/2` |
| **Total** | **`35/10/11/55`** |

The bound-function row includes eleven occurrences per function and three
per returned substitution. `New_Identifier (Attr_Name)` copies the supplied
name as well as allocating an identifier; its two-node charge is distinct
from a raw builder supplied the same name
(`src/why/why-gen-names.adb:774–784`). The source has the same two-attribute shape for
literal subtypes and ordinary static arrays
(`src/why/why-gen-arrays.adb:1534–1620,2526–2645`). The clone-of-existing-type
branch is smaller: at most six nodes, one list, two entries and seven
occurrences, including its explicit export and optional transparent alias.
Static arrays do not receive the reference/havoc suffix
(`src/why/gnat2why-types.adb:1548–1565`). Two type/completion headers give
the stated itype total, while the representation-cache attempt remains a
separate charge for every array `Translate_Type` visit.

**Non-itype completion.** Ordinary static bounds have no free dynamic-invariant
or default-initialization variables, predicates, initialization wrappers,
default aspects, user invariants, access fields or user-defined equality.
`Generate_Type_Completion` creates one invariant predicate and one additional
default-initialization theory; scalar-bound axioms are absent for static
bounds (`src/why/gnat2why-types.adb:207–575,895–980`). The contents are:

| Completion helper | Static Integer | Static String |
| --- | --- | --- |
| Five-parameter invariant function setup | `20/4/6/44` | `22/4/6/46` |
| Expanded invariant body, including discarded work | `8/4/6/31` | `24/12/15/13` |
| **Complete invariant** | **`28/8/12/75`** | **`46/16/21/59`** |
| Two-parameter default-init function, including body | `11/4/3/24` | `28/11/13/26` |

The expanded scalar body uses two cached static bound identifiers, one
dynamic-property call and at most one representation conversion of its value.
The discarded default-predicate guard adds a Boolean literal, equality and
conditional; its freshly computed split type is also counted. The static
nonempty premise skips the extra initialization-versus-empty-range condition
(`src/why/gnat2why-expr.adb:6818–6887,7085–7124`,
`src/why/why-gen-expr.adb:280–304,3600–3747,4337–4363`).

The static String invariant repeats the earlier expanded-invariant derivation:
its emitted body is only a well-formed call on the five-occurrence array
parameter, at most thirteen occurrences. Its discarded Character component
walk still allocates the range and both element accesses. A literal subtype
omits that traversal and is smaller. The default-init body returns True, but
an ordinary static array first spends `13/7/10` on that same eager traversal
and two nodes on the Character element's unused temporary
(`src/why/gnat2why-expr.adb:5465–5592,5726–5851,6004–6011`,
`src/why/why-gen-expr.adb:4962–5000`). Thus its function setup `13/4/3/26`
plus discarded `15/7/10/0` gives the listed bound. The scalar body needs no
default-value work. Both families add the default-init header `1/2/0/1`.

The String non-itype suffix creates at most three direct map module IDs
(its function parameter types and expanded-invariant expected type); its
invariant/default-init paths use at most ten fresh temporary names. The
Integer non-itype suffix uses at most seven fresh temporary names and no
direct module IDs. Other symbols/modules are the separately charged caches.
These conclusions concern the static Main-generated families above.
Unconstrained Standard.String and predefined/dependency type bodies remain
in the fixed dependency term; dynamic **non-itype** scalar/array types from
library sources are not covered by the loop-itype row.

### Ordinary range-loop framing and modified roots

Under the earlier loop shape, the fixed producer cost is at most
**69 nodes, 23 lists, 43 elements and 267 occurrences**. Add the body and
its final statement-list wrapper once, each of the two frontend endpoints
once in each program/term domain, and the per-root costs below. The bound
includes the loop-local `Mk_Item_Of_Entity` visit; separate entity-pass setup
and loop exception theories remain in the object component. This is a
per-producer-visit formula, not a bound based on the numeric iteration count.

| Fixed loop part | Nodes | Lists | Elements | Occurrences excluding supplied children |
| --- | ---: | ---: | ---: | ---: |
| Index binder and two bound temporaries | 9 | 0 | 0 | 0 |
| Empty initial statement sequence | 1 | 1 | 1 | 0 |
| Eager index and unused iterator dereferences | 2 | 0 | 0 | 0 |
| Index range invariant | 4 | 3 | 4 | 33 |
| Entry condition | 3 | 3 | 6 | 48 |
| Index update and location label | 4 | 1 | 2 | 26 |
| Exit condition | 1 | 1 | 2 | 20 |
| Combine index and frame invariants | 1 | 1 | 2 | 8 |
| Initialize index and prepend | 2 | 1 | 2 | 13 |
| Bind low and high once | 2 | 0 | 0 | 14 |
| `Wrap_Loop`, including two possible dead-code warnings | 40 | 12 | 24 | 105 |
| **Total** | **69** | **23** | **43** | **267** |

Allocation-only rows have their references charged at every use in the later
occurrence rows. In particular, an index identifier has at most five
occurrences and a dereference eight; each bound temporary has four. The
program-domain range conjunction and combined invariant call `Andb`, whose
overhead is eight occurrences and two argument-list elements, rather than
the predicate-domain conjunction's one occurrence and empty extra-operand
list (`src/why/why-gen-expr.adb:3485–3504`). The second iterator dereference
is eagerly allocated even for an ordinary range and is then unused.

`Wrap_Loop`'s allocation rows are respectively two exception names,
before-sequence/comment `2/1/4`, after-sequence/three comments/assumption/
try/handler/conditional/raise `9/3/8`, loop and location `2/2/0`,
outer body sequence/comment `2/1/2`, outer try/handler `2/1/1`,
two warnings `18/2/6`, and final sequence/comment/conditional `3/2/3`.
Its 105-occurrence allowance is `15+17+2+2+8+58+3`; this conservatively
includes the empty initial sequence and Void arguments even where sequence
filtering removes them. The body, implicit invariant, entry/exit conditions,
update and snapshot-bound context each occur once
(`src/why/gnat2why-expr-loops.adb:690–813,970–1050,1292–1505,1763–1984,
2194–2334`; `src/why/why-gen-progs.adb:329–370`). Empty source variant and
invariant sets introduce no hidden assertion translations. The explicit
`--no-loop-unrolling` guard excludes the repeating branch even if static
unrolling candidacy is computed.

The admitted `low .. high` syntax remains `N_Range` under light expansion.
`Make_Index` attaches the generated index type to that range without changing
it to `N_Subtype_Indication`; the light-expansion loop rewrite applies to array
iterators, which are absent here. Thus the extra subtype-indication check at
`gnat2why-expr-loops.adb:1976–1984` does not occur. The frontend source loci are
`gcc/ada/sem_ch5.adb:3301–3400`, `sem_ch3.adb:20504–20605,20712–20761`, and
`exp_spark.adb:896–913` at the revision used by the
[frontend entity derivation](retained-frontend-entities.md). Captured bound
declarations and their own costs remain separate from this syntactic fact.

For each non-discarded modified root, the frame code reads the current value,
computes a dynamic invariant or preservation equality, creates a loop-entry
snapshot even when the equality simplifies to True, and binds that snapshot
once around the loop. The following maxima cover the two possible statuses
for whole-object writes:

| Root family/status | Nodes | Lists | Elements | Occurrences |
| --- | ---: | ---: | ---: | ---: |
| Static signed Integer, `Entire_Object` | 16 | 5 | 6 | 57 |
| Static signed Integer, `Not_Written` | 9 | 2 | 2 | 42 |
| Ordinary String, `Entire_Object` | 49 | 19 | 27 | 126 |
| Ordinary String, `Not_Written` | 25 | 8 | 12 | 118 |

The Integer entire-object row is current read `2/0/0`, invariant
`8/4/6`, snapshot identifier/name `2/0/0`, snapshot read/binding `3/0/0`,
and accumulated conjunction `1/1/0`. Its emitted invariant is at most 38
occurrences including the eleven-occurrence current read. The named invariant
alternative is smaller; the expanded static property and discarded guard
are covered by the preceding type-helper derivation. Snapshot binding is
at most eighteen occurrences. Its conversion has the identical scalar type
and returns unchanged. `Not_Written` replaces the invariant by one equality,
at most 23 occurrences including current value and snapshot references.

The String entire-object row is current read `6/3/5`, invariant `25/12/17`,
snapshot setup `4/0/0`, snapshot read/conversion/binding `13/3/5`, and
conjunction `1/1/0`. Its invariant has the earlier 69-occurrence bound
including the current read. `Why_Type_Of_Entity` may construct a two-node
abstract type for a split String binder before creating the snapshot
identifier/name. On the later read, the conversion to that same array type
returns its argument, but first may eagerly construct both split map types:
six discarded nodes. The binding adds eight occurrences to the read's
forty-eight, giving 56. `Not_Written` instead uses a single equality with
at most 61 occurrences. These are direct identifier reads, not repeated
initializer/source-expression translations.

The relevant paths are `src/why/gnat2why-expr-loops-inv.adb:327–343,775–807,
1079–1398`, `src/why/gnat2why-util.adb:1347–1454,1889–1907`,
`src/why/gnat2why-expr.adb:946–954,2707–2805,2864–2894`,
`src/why/why-gen-binders.adb:448–476`, and
`src/why/why-gen-expr.adb:1136–1160,2399–2438`.
The String row creates at most five direct map modules, and both rows use
one snapshot temporary plus the temporary names already present in their
bounded helper calls. Init/validity flags and borrower state are absent for
these initialized ordinary objects. Each frame conjunction has at most two
non-True operands because `Entire_Object` and `Not_Written` select mutually
exclusive invariant/preservation branches, so it allocates no extra operand
elements. Nested indexes are discarded as previously established.

The concrete Silver_IO globals also fit these rows: `Written_Bytes` is a
static Character String, `Written_Count` a static Natural subtype, and
`Flushed`/`Succeeded` Standard.Boolean. Boolean is smaller than the Integer
row: it skips the named invariant and scalar property and only constructs
the discarded default-predicate guard. Thus these four globals contribute
at most one String and three scalar rows per loop that can write them.
`Ada.Text_IO.File_System` contributes no frame row: `Process_Call` ignores
`Magic_String`; for `Direct_Mapping` it inserts only `Is_Object` entities
(`gnat2why-expr-loops-inv.adb:1641–1689`). An `E_Abstract_State` is not in
`Object_Kind` (`gcc/ada/einfo-utils.adb:354–357`,
`gen_il-gen-gen_entities.adb:308,1087`). This exclusion is only for the loop
frame helper; File_System's call effects, symbols and dependency setup still
require their separate charges.

For `q_i` concrete scalar roots and `q_s` String roots in a loop's
non-discarded write set, including the applicable four globals, the closed
loop contribution is therefore

```text
LoopCost = (69,23,43,267) + q_i*(16,5,6,57) + q_s*(49,19,27,126)
           + BodyAndList + Prog(low) + Prog(high) + Term(low) + Term(high).
```

`Get_Proof_Globals` does expand abstract states independently of ordinary
scope visibility, so opacity must also cover that route. Its
`Expand_Abstract_State` converts every non-SPARK constituent object to
`Magic_String`; an unknown abstract state is also a magic string
(`src/flow/flow_utility.adb:2519–2681`,
`src/flow/flow_generated_globals-phase_2.adb:4793–4875`). The selected
Ada.Text_IO body declares its File_System refinement under `SPARK_Mode (Off)`
(`gcc/ada/libgnat/a-textio.adb:46–58`). Thus both the visible abstract entity
and expanded constituents are excluded from this frame helper. The selected
Silver sources add no `Part_Of` constituents. The call companion retains the
fixed specification/dependency scope; this does not cover arbitrary changes
to those external or Silver library sources.

The coarse root bound is consequently `sum(q_i+q_s) <= F_loops*(D+4)`;
the source-derived descendant write sets are sharper. Neither numeric trip
count nor the number of repeated assignments to one root multiplies this
producer cost.

### Generated declaration and action wrappers

`Check_Scalar_Range` for an ordinary signed Integer range with a supplied
static Integer/Positive base has the compositional upper bound

```text
allocations <= (17,7,10) + Term(low) + Term(high)
                         + Prog(low) + Prog(high)
occurrences <= 69 + 2*Term_O(low) + 2*Term_O(high)
                  + Prog_O(low) + Prog_O(high).
```

The optional program-domain evaluations occur only when the corresponding
endpoint comes from source and is not an OK static expression. The two
term-domain results are each **allocated once but serialized twice**, in a
range-membership comparison and the nonempty-range guard. The fixed core is
`7/5/6/41`: three comparisons with cached static base attributes, conjunction,
implication, any-expression and location. Each optional endpoint evaluation
adds an ignore wrapper `4/0/0/13` and a prepending sequence `1/1/2/1`.
Source: `src/why/gnat2why-expr.adb:3707–3834`,
`src/why/why-gen-progs.adb:126–150,199–215,275–280`.
The enclosing generated scalar subtype declaration adds at most one location
node/occurrence. No absent or dynamic base type is silently covered by this
helper row; those would need their own base-attribute translations.

For a static range that is empty or fits its static base,
`Check_Scalar_Range` returns the shared Void immediately, with no endpoint
translations. A static Integer subtype declaration normally skips the call
altogether. Ordinary generated static String aliases/index subtypes have no
component constraint, fixed-lower-bound aspect or nonstatic index expression;
any reached range check also has the immediate-return condition. Thus a
static generated subtype declaration contributes at most **1/0/0/5**,
its final location wrapper around Void. This executable-declaration row is
separate from the type-theory contents priced above
(`src/why/gnat2why-expr.adb:22840–23012,23187–23194`).

Generated bound-capture objects can use the existing ordinary Integer
declaration/binder/theory rows when their initializer type is the captured
source object's static nonempty subtype or predefined Integer. They are
distinct declarations: charge their initializer translation and any entity
term-domain replay, then charge the loop's references to those captures as
references. Do not charge the unrewritten complex bound at every reference.
The frontend analysis must provide that rewrite/count map; the numeric
wrapper does not establish it.

There are two additional finite wrapper families, kept explicit until their
actual generated-node multiplicities are established:

- `N_Itype_Reference` with an associated node having an Etype calls
  `Transform_Prog` on that node and wraps it in `New_Ignore`. The wrapper is
  at most **4/0/0/14**, with the associated expression once. It returns before
  the declaration's final location-label path. Other associated-node kinds
  return shared Void. This is a possible additional translation caller,
  rather than permission to assume every initializer is translated only
  twice (`src/why/gnat2why-expr.adb:23122–23134`). The complete frontend
  reference-site argument below now excludes this caller from ordinary Main;
  fixed library translation and native expansion remain separate.
- An ordinary scalar constant in an `Actions` list receives one local
  `Mk_Item` during preparation and another during the reverse binding pass.
  The two visits plus the binding cost **11/0/0/8**, excluding the initializer,
  which is translated once into its binder's supplied expected type. The
  surrounding expression occurs once in the binding context. Type
  declarations in these lists are ignored by both passes. Itype-reference
  actions in the program domain instead invoke the preceding wrapper and
  prepend its result (`src/why/gnat2why-expr.adb:15420–15569`).

**List wrappers.** `Transform_Declarations` creates one Void sequence and
appends each returned declaration. In these ordinary families a declaration
has at most two immediate statement entries if its final source location
label is absent; a label or other node contributes one. `Append` flattens
only that immediate list, not every descendant. For `d` declarations this
list wrapper costs at most **`(1,1,2d+1,5)`**, excluding all supplied
declaration results. A declaration-block wrapper additionally appends the
core's immediate statement entries without making a new Why node/list
(`src/why/gnat2why-expr.adb:23201–23232`,
`src/why/why-gen-progs.adb:52–102,366–370`).

For a mixed executable list of `m` source statements and `g` such ordinary
generated declarations, the earlier source-list bound becomes
**`(m+g+1,1,m+2g+1,m+g+5)`**. It allows a separate outer source-location
wrapper for every entry, including generated entries if they carry a
positive location; without that wrapper, at most two immediate entries are
copied. This is disjoint from the declaration's own final location label.
No labels, goto or Assert_And_Cut are admitted, so those list-restructuring
branches do not apply (`src/why/gnat2why-expr.adb:30068–30155`).

### Main entity and representation invocation counts

The frontend counts now close the ordinary **entity-pass** portion of the
producer independently of expression accounting.
Use the [frontend report's](retained-frontend-entities.md) `D`, `R`, `D_s`,
`D_lit`, `D_alias`, `F` and `K_literal`. Let `G <= 2F` count actual captured
loop bounds. These are identities, so including an entity that marking omits
only enlarges the following allowances.

There are at most `D + F + G` ordinary object entities: source objects, loop
indexes and bound-capture constants. Each receives at most one global
registration and one object-definition/axiom pair. The mutable definition's
second `Mk_Item` is already in the [object component](retained-producer-objects.md).
Taking componentwise maxima over its regular/constant/split cases gives

```text
B_object_pass <= (D + F + G) * (33,9,6,33)
                 + F * (6,4,2,6)
C_object_pass <= 2D + 4F + 2G <= 2D + 8F.
```

The first vector includes the largest eleven-node registration and the
largest theory costs `(22,9,6,33)`; summing these independent maxima is
deliberately conservative. The second row is the loop-scope exception/empty
theory pair. The local loop-index setup is already charged in the executable
loop row and must remain there. Executable object-declaration wrappers and
initializers are likewise separate. `Register_Symbol`, `Translate_Entity` and
`Complete_Declaration` are single entity-list passes; none of the ordinary
objects has a partial/full view (`src/why/gnat2why-driver.adb:1381–1445,
1462–1590`). The hidden-global pass does not create another Main-local object
definition: it acts on subprograms and translates previously unseen opaque
global names, which belong to the selected fixed dependencies (`:1596–1638`).

For the five Main type families, use the larger static Integer-itype row
also for a dynamic/empty loop-index subtype; it dominates that row in every
component. Then

```text
B_type_pass <= R * (137,53,48,305)
             + D_lit * (209,82,78,348)
             + (D_alias + K_literal) * (37,14,11,57)
             + F * (97,39,33,205)
C_type_pass <= 4R + 6D_lit + 2D_alias + 2K_literal + 3F.
```

Each literal-initialized String declaration contributes its non-itype String
and its signed Integer index itype, hence the sum `(209,82,78,348)` and six
closes. A static-name String alias adds only the String itype. The frontend
bound is `D_lit + D_alias <= D_s`; nonstatic String declarations reuse
Standard.String and add no Main String subtype. Fixed predefined/library
types, cached symbols and executable declarations remain outside these rows.

The representation-cache **attempt count is also closed**. A complete source
search finds only one external caller of `Create_Rep_Array_Theory_If_Needed`:
`Translate_Type` calls it once on each translated array type
(`src/why/gnat2why-types.adb:1623–1634`). Its public overload calls the ordinary
representation once; its additional call and conversion theories require
`Has_Init_Wrapper`, excluded for these Main types
(`src/why/why-gen-arrays.adb:1144–1161`). Array expression helpers only look up
the populated maps; constructing a direct map module does not retry this
cache. Consequently

```text
T_array_attempts_Main <= D_lit + D_alias + K_literal
                       <= D_s + K_literal
B_array_attempts_Main <= T_array_attempts_Main * (17,0,0,0).
```

All these types share one ordinary rank-one Character key. Add at most one
miss row `(148,44,76,711)` and two closes, even if the earlier fixed
Standard.String translation already paid that miss. No per-expression or
per-String-read attempt multiplier is needed. The allowance intentionally
counts dead frontend type identities as though they reached the producer.

### Bound-capture placement and source expression replay

For an ordinary scalar loop bound, the frontend relocates the complete
expression into its capture constant and calls `Insert_Action`. The upward
walk reaches the loop statement and inserts the declaration immediately
before that loop in its containing statement list. The iteration-scheme
condition-action branch requires a while condition, absent for an explicit
for range. The `N_Expression_With_Actions` branch requires the already
analyzed right operand of a short-circuit expression, also absent on this
parent path. Source: pinned GCC `exp_util.adb:12765–12824,8159–8182,
8289–8314,8431–8470`, retained in the frontend invocation excerpts below and
the [native expansion report](retained-native-expansion.md). GNATprove's
expansion dispatcher exits before normal transient-scope processing
(`expander.adb:105–127`); an ordinary scalar bound has no unconstrained-result
call or other transient-scope construct. Nested loops and loops in if arms
retain the same list placement. Thus these captures do not
cause an action initializer to be replayed separately by both endpoint-domain
transformations.

This gives the following source-expression caller accounting for the ordinary
execution path:

| Source expression context | Translation invocations |
| --- | --- |
| Mutable object initializer | One program translation |
| Immutable object initializer | At most one program plus one term translation |
| Assignment RHS, call actual, if/elsif condition | One enclosing translation |
| Uncaptured loop endpoint | One program plus one term translation |
| Captured loop endpoint | At most one program plus one term translation of its relocated initializer, plus two reads of its generated constant |

Each translated arithmetic, comparison, concat, Image or Boolean connective
visits its supplied source children once; ordinary names do not replay their
initializers. Length's eager prefix read is already in its closed wrapper.
The at-most-two replay factor therefore applies to each ordinary source
expression tree in these contexts. Bound captures add at most `2G <= 4F`
generated leaf visits and `G` ordinary Integer declaration wrappers; their
global object pass is already above. No runtime iteration count multiplies
these costs. Generated static subtype declarations add no expression replay.

The Itype-reference exclusion below removes that potential independent
associated-expression replay for ordinary Main. This caller result still
does not count native expansion, where different generated actions exist,
or the fixed dependencies' expressions and setup.

### No generated Main Itype-reference replay

The pinned frontend contains **37 constructor/helper call sites**, including
the bodies of `Build_Itype_Reference` and `Ensure_Defined` themselves. The
[inventory](../evidence/retained-producer-capacity-20261017/frontend-invocation-audit.json)
and [numbered excerpts](../evidence/retained-producer-capacity-20261017/frontend-invocation-excerpts.md)
retain every site and its relevant guard. The reproducer scans every `.adb`
and `.ads` file in the previously retained complete frontend manifest,
verifies each complete file's hash, and asserts the exact call-site list.
It also records every raw `N_Itype_Reference` mention; manual inspection
finds no additional direct node-construction route among them. This inventory
is evidence for the following manual reachability argument, not an automatic
proof that arbitrary Ada inputs cannot use these paths.

| Sites in pinned GCC | Why they do not create an Itype reference from ordinary Main |
| --- | --- |
| `exp_util.adb:5408`, `sem_ch3.adb:11269` | These are the two constructor helper bodies. Their callers are all covered by the remaining rows. |
| `checks.adb:3551,3554,3557` | `Apply_Selected_Length_Checks` returns when expansion is disabled; its references additionally require a compilation-unit package scope. |
| `checks.adb:10330` | The selected-length helper requires the current compilation unit to be a package specification. Main is a procedure. |
| `exp_aggr.adb:4350,4376` | Record aggregate expansion; no admitted Main expression or generated scalar bound capture is a record aggregate. |
| `exp_ch3.adb:4934,4938` | Record initialization-procedure aggregate component processing; Main creates no record type or initialization procedure. |
| `exp_ch4.adb:2084,2085,10341`, `exp_pakd.adb:1605,1606` | Boolean-array binary/not expansion, including packed arrays. Main's Boolean operations are scalar and its String components are Character. |
| `exp_ch5.adb:1024,1025` | Native array-assignment expansion. GNATprove light expansion has no assignment handler and skips normal expansion. |
| `exp_ch9.adb:14231` | Task-body procedure access type during task initialization; absent from Main. |
| `freeze.adb:4360` | Large modular-index array runtime check; it returns with expansion disabled and Standard.String has signed Integer indexing. |
| `freeze.adb:5200,7374,8311` | Respectively record access-component, class-wide, and discriminated-record access-subtype freezing; none is a Main-generated type family. |
| `sem_ch3.adb:891,980,999,1004,1013` | Anonymous access definitions, including protected/formal/return/object cases; Main and its generated bound captures have no access definitions. |
| `sem_ch3.adb:8633,14915,16633,23105,23198` | Respectively derived-type access discriminants, concurrent subtype, inherited access formal, access constraint, and private/concurrent full-view subtype. Ordinary Main creates only the classified Integer/String subtypes. |
| `sem_ch6.adb:2164,2169,9532` | Null-excluding access result and generated build-in-place access formal. Main has no parameters or result; library declarations remain fixed dependencies. |
| `sem_ch7.adb:2123` | Limited-with anonymous-access references; the helper also returns with expansion disabled. |
| `sem_res.adb:13197` | Slice-subtype reference is gated by `Expander_Active`. Main has no slice; native Image/concat slicing is absent under light expansion. |

The light-expansion dispatch is `exp_spark.adb:120–213`, reached through
`expander.adb:105–127`. Its special delegation for String `/=` calls only
the non-elementary `Expand_N_Op_Ne` rewrite to `not (=)` with the original
children; this does not enter Boolean-array expansion or construct an Itype
reference (`exp_spark.adb:1008–1023`, `exp_ch4.adb:10162–10259`). Ordinary
for-range semantic processing creates the index itype but does not call either
reference helper. The earlier frontend derivation excludes Main inlining,
generic instantiation and source renaming, so a fixed dependency's pre-existing
Itype-reference subtree is not copied into Main.

Consequently **the Main `N_Itype_Reference` translation count is zero** for
this grammar and selected proof frontend path. This conclusion does not
exclude such nodes inside fixed library translations or native expansion,
does not eliminate their own capacity costs, and retains the explicit
source-to-installed-tool correspondence premise.

### A uniform ordinary expression transfer

There is a conservative way to assemble the closed expression rows without
requiring a separate counter for every possible expected-type lookup. Let `X`
count the value-expression syntax nodes in the source grammar, counting each
literal, value-name, operator, attribute and function call once, plus its value
children. Parentheses may be counted too, although the frontend does not need
a separate expression node for them. Declaration range endpoints may also be
included, even when their static type helpers already charge their processing.
Let `U` count String `/=` source operators, and let `P` be the frontend report's
plain-literal parser-flattening count. Define

```text
V = 2 * (X + U + 3P) + 2G,       G <= 2F.
```

This is an upper count of ordinary expression-node visits. The two-pass source
caller argument above supplies the factor two. Scalar constant folding and
String concatenation folding replace a value subtree with a leaf, so do not
increase the number of visited expression nodes; the new literal's definition
cost is charged separately below. String `/=` may add one `not` node while
retaining its two value children. Each parser flattening creates at most the
two replacement literals and one artificial concat, all three charged here
without credit for the removed long chain. The relocated bound expression is
charged in its initializer; the two generated constant reads per capture
supply `2G`. The source byte/token budget can bound `X` directly, but `X` is
sharper and has an explicit grammar definition. It is not a measured AST count.

The producer's preliminary rewrite does not expand this Main expression
forest. Its relevant name/operator case only changes the entity to an
existing ultimate alias. Its other transformations require excluded real
literals, old/size attributes, generic/wrapper units or null procedure
declarations (`src/spark/spark_rewrite.adb:253–276,340–544`). No source line
is excluded in the selected invocation. All normal value children are visited
once by the closed expression transfers. The Length wrapper already prices
its eager prefix read; counting that source prefix again in `V` is harmless.

At each visit, allow three fresh nodes for construction of its supplied
expected type, even when that type was cached or supplied by the parent.
`Type_Of_Node` on these shapes returns an existing binder type, a one-node
scalar split type, or an abstract/map type of at most three nodes; it creates
no list (`src/why/why-inter.adb:1158–1224,1579–1632`). Allow the full ordinary
String conversion once at each String visit. Scalar final conversions either
compare identical/builtin representations or use the previously priced static
subtype boundary. A dynamic loop-index subtype is not a source assignment or
declaration target, and a bare loop index is not captured as a variable; its
ordinary value-use callers request builtin Integer. The dynamic target-bound
conversion path therefore does not enter this transfer.

The largest resulting local vector is the concat row plus its expected-type
and conversion allowances:

```text
c_expr = (60,32,49,484) + (3,0,0,0) + (47,22,31,459)
       = (110,54,80,943).
```

All other ordinary expression cases fit componentwise below it: normalized
Integer leaves/arithmetic and static range boundary, Length, scalar/String
comparison, Boolean/not/short-circuit wrappers, literal **use**, ordinary
String reads, Image, and the two selected query-function wrappers. The
predicate-only label/Boolean-to-predicate wrappers also fit below this
maximum: one equality call on the supplied Boolean and True, plus one
optional label, is bounded by `(3,1,2,13)` including an allowance for a
fresh True node (`src/why/why-gen-expr.adb:5436–5442`,
`src/why/gnat2why-expr.adb:25500–25509`). No predicate-valued String concat
exists. Procedure calls and
declaration/assignment/loop/list skeletons are charged separately. One supplied
complex child occurs once in these transfers; their cheap-reference overhead
already covers repeated identifier/dereference uses. This bound intentionally
does not take credit for static folding, identity conversions, or disabled
warnings.

Let `D_copy <= D_s` count String declarations whose initializer is replaced
by a copied literal. GNAT performs this late in object-declaration analysis
when the initializer names a constant whose `Constant_Value` is a literal
(`gcc/ada/sem_ch3.adb:5436–5453`, `sem_aux.adb:93–141`). The target object may
be mutable; the source object must be constant. Constant chains may propagate
the same bytes through several declarations. `New_Copy` shares `Strval` and
the analyzed type but creates a distinct expression identity. The producer
keys each static literal's module by its actual node, not by `String_Id` or
`Original_Node` (`gnat2why-expr.adb:30226–30256`,
`why-atree-modules.adb:465–504`). Therefore these copies need additional
literal-definition/character charges even though they add no Stringt bytes.

Let `K <= S + A + 3P + D_copy` bound distinct translated literal identities
and define the corrected aggregate decoded-length bound:

```text
H = sum(source literal lengths)
    + sum(length bound of each source concat result)
    + 2 * sum(length of each parser-flattened chain)
    + sum(length bound of each copied declaration initializer).
```

Charging every String declaration in the final sum and using `D_copy = D_s`
is a conservative source-computable alternative that avoids needing a separate
propagation classifier. Replacing one name leaf by one literal leaf does not
increase `V`; sharing the analyzed type leaves `K_literal` unchanged. These
distinctions matter: an expression cache miss can create a complete character
axiom even when frontend character storage and type identities are shared.

The cache-miss/character formula above is bounded by
`K*(23,13,10,75) + H*(7,3,6,40)`. It charges no per-use work a second time.
The executable/value-axiom expression contribution consequently satisfies

```text
B_expressions <= V * (110,54,80,943)
                 + K * (23,13,10,75)
                 + H * (7,3,6,40)
C_literals <= K.
```

Literal **type entities** still use `K_literal <= S+3A+5P` in the type-pass
formula. Those entity identities and the expression module-cache misses `K`
are different counters. This transfer excludes fixed library expressions,
cached symbol initialization, all other theory contents and imports. Its
source/tree relation and local case coverage are manual arguments supported
by pinned source, not a new machine-checked producer theorem.

### List transfer including ignored frontend entries

Counting only source statements and bound captures is insufficient for list
accounting: frontend freeze nodes, call markers and other ignored entries can
remain in the lists. `N_Ignored_In_SPARK` includes them
(`src/spark/spark_util.ads:69–111`). Their executable handler returns Void;
the declaration handler may additionally attach its final location label
(`src/why/gnat2why-expr.adb:23148–23194,29496–29517`). They do not replay an
expression or create a nested body list, but the enclosing list still visits
them and may attach its outer location label.

Let `A_Main` be a **source-derived frontend node-allocation upper bound**
covering every Main node, including generated, ignored and discarded ones.
The [Main semantic-node aggregate](retained-main-semantics.md#node-identity-aggregate-and-remaining-resource-obligations)
now supplies this expression, including parser nodes, semantic actions,
generated entities, freeze entries and call markers. Its `C_lib` input counts
source library-call occurrences, and its `N_ref` term counts source
references; both are source counts. It bounds Main node identities and excludes
fixed dependencies; physical frontend slots and auxiliary
tables are separate capacity domains. Using that source expression here avoids
a second, independently maintained formula just for ignored producer list
entries; a measured AST count is not substituted.

Each ordinary Main declaration/statement list is translated once, and each
entry has one containing list. The no-unrolling loop path translates the body
once, while the if handler translates each arm once. Thus the total number
of visited entries is at most `A_Main`. There are at most two top-level lists,
one body list per loop, and `q+1` body lists for an if with `q` condition points,
allowing an absent else as an additional empty list. Each loop, if and elsif
has its own frontend node, giving `L_lists <= 2 + 2A_Main`.

For each list, charge its initial Void sequence `(1,1,1,5)`. For every entry,
charge two optional location nodes, at most two appended elements and four
additional Void occurrences: `(2,0,2,6)`. This deliberately covers both the
declaration's own final label and the executable-list outer label, even where
one is already in the sharper declaration wrapper. Ordinary declaration
sequences have at most two immediate elements without a location label;
source statements carry their positive source-location wrapper and cannot
flatten their whole subtree into the parent list. Ignored entries are smaller.
The resulting conservative transfer is

```text
B_lists <= A_Main * (2,0,2,6) + L_lists * (1,1,1,5)
        <= (4A_Main+2, 2A_Main+2, 4A_Main+2, 16A_Main+10).
```

This includes the Void core of null/ignored entries, whose allocations are
otherwise zero. Supplied nonempty statement/declaration cores remain in their
own rows. The extra label/Void allowance is an intentional overcount, not an
additional transformation. A sharper frontend entry bound can replace
`A_Main`; the conservative transfer itself requires no unpriced producer
helper or invocation count.

### Assembled ordinary Main contribution

In addition to the source counts already defined, let `I_a` and `S_a` count
Integer and String assignments; `P_o` count Put/Put_Line statements; `P_r`
count Reject statements; `Q` sum the if/elsif condition points; and `B` sum
`q+1` across source if statements, conservatively including absent else arms.
The executable declaration/statement skeleton is bounded by

```text
B_skeleton <= (D - D_s + G) * (13,3,9,55)
              + D_s * (55,24,36,188)
              + (R + D_s) * (1,0,0,5)
              + I_a * (6,0,0,8)
              + S_a * (148,61,86,1247)
              + P_o * (9,6,4,9)
              + P_r * (4,6,4,13)
              + Q * (8,2,2,26)
              + B * (9,1,3,27)
              + F * (69,23,43,267)
              + F * (D + 4) * (49,19,27,126).
```

The static subtype-declaration allowance covers at most one generated subtype
declaration per explicitly ranged Integer object and per String declaration.
Their implicit index itypes are entity-pass work, not additional explicit
subtype declarations. The last row uses the larger String frame vector for
every possible modified root. There are at most `D+4` roots per containing
loop, including the four concrete output globals; the opaque File_System
state was excluded from frame roots above. The Integer and Not_Written rows
are all componentwise smaller. Query functions are expression visits and are
already in `B_expressions`, so they are not additional statement rows here.

All source/generated initializer and endpoint translations are in
`B_expressions`, including their expected-type conversion allowances. The
String-assignment row already contains its two subsequent internal conversions;
those are not added again as expression visits. `B_lists` intentionally
overcounts some already-priced location/Void nodes, so it also covers the
source SPARK_Mode pragma, null statements and ignored frontend entries.

One conservative ordinary Main sum, with **no unpriced per-construct helper
coefficient**, is therefore

```text
B_Main = B_object_pass + B_type_pass + B_expressions + B_skeleton + B_lists
         + (D_s + K_literal) * (17,0,0,0)
         + (148,44,76,711)
C_Main <= (2D + 8F)
          + (4R + 6D_lit + 2D_alias + 2K_literal + 3F)
          + K + 2.
```

The single array miss and its two closes are charged even when fixed setup
already created that representation. `B_Main` here explicitly excludes
memoized entity-symbol/module setup, Main's enclosing subprogram
definition/completion/VC wrapper, the predefined and selected library
translations, and imports. Those setup terms still have to be derived and
added to obtain `B(P)`; the next section supplies the built-in initializer and
ordinary symbol/module cache allowances. The name `B_Main` does not mean all producer work
caused by Main has already been charged. `A_Main` also remains an input from
the frontend allocation derivation. This is a closed transfer of ordinary
Main syntax/entity work into the aggregate, **not a complete capacity rule**.

### Built-in initialization and ordinary entity symbol caches

The one-time `Why.Atree.Modules.Initialize` call precedes Standard translation
and `Translate_CUnit` (`src/why/gnat2why-driver.adb:998–1013`). Its body calls 23
fixed helpers once each. The only helper loops range over the six `BV_Kind`
values and three `Floating_Kind` values
(`src/why/why-atree-modules.ads:609–618`). No helper invokes another helper or
translates source-dependent syntax. The complete body/helper inventory in
[`initializer-inventory.json`](../evidence/retained-producer-capacity-20261017/initializer-inventory.json)
is reconstructed from the pinned source by
[`initializer_inventory.py`](../evidence/retained-producer-capacity-20261017/initializer_inventory.py).
It checks the helper closure, constructor vocabulary and loop cardinalities.

The executed constructor counts, with both finite loops expanded, are:

| Constructor | Executions | Nodes per execution |
| --- | ---: | ---: |
| `New_Module` | 117 | 1 |
| `New_Type` | 20 | 1 |
| Explicit `New_Name` | 24 | 1 |
| `New_Identifier` from a symbol | 639 | 2 |

The identifier overload creates its name and identifier
(`src/why/why-gen-names.adb:786–814`); the module string overload creates only
the module (`:825–833`). None of these node kinds has a list-valued field.
Thus this initializer contributes **`(1439,0,0,0)`**, including 117 modules.
The zero occurrence term means it adds no independently serialized theory
root: occurrences of the cached types/names/modules are already charged at
their use sites. `Why.Gen.Names.Initialize` allocates the symbol pool, not Why
nodes (`:575–578`). `Why.Atree.Initialize` reserves node zero
(`src/why/why-atree.adb:59–68`), which is already excluded from the usable
`1 .. 2^30-1` ID domain. These are initializer costs only; they do **not**
include `Translate_Standard_Package`, dependency translation or other
package elaboration work.

`E_Symb` normalizes a type with `Retysp`, then initializes all of that entity's
symbols together on the first missing-key lookup
(`src/why/why-atree-modules.adb:297–324,3006–4588`). Subsequent ordinary lookups
find their precreated key. Main uses signed Integer types and rank-one
Character arrays without relaxed initialization, user equality, invariants,
allocated parts or validity wrappers. Counting the normal shared and
type-specific paths gives the following upper bounds. As a conservative
allowance, the two non-itype dynamic/default-initialization identifiers are
included even though the Main-generated types are itypes.

| Entity cache fill | Identifier/name nodes | Additional type/map nodes | Total nodes |
| --- | ---: | ---: | ---: |
| Signed Integer type | `2*(2+12+2)=32` | two `EW_Abstract` calls, 4 | 36 |
| Ordinary String type | `2*(10+9+2)=42` | two `EW_Abstract` calls, at most 6; component type, 2 | 50 |
| Ordinary object or loop index | `2*3=6` | 0 | 6 |
| Procedure Main | at most `2*2=4` | 0 | 4 |

For scalar types the shared pair is dummy/equality and the twelve scalar
symbols include optional integer projection and static range predicates
(`:3210–3253,3959–4084`). For Strings, shared initialization has dummy/equality,
five array operations and first/last/length; type initialization adds four
size/alignment attributes, dynamic property, component-to-representation and
three index symbols (`:3297–3387,4394–4510`). The `EW_Abstract` calls allocate
at most three nodes for an ordinary String (type, name and uncached map module),
or two for signed Integer/Character
(`src/why/why-inter.adb:846–880,1160–1223`). `Get_Array_Theory` is a cache lookup,
not another representation-construction attempt
(`src/why/why-gen-arrays.adb:2951–2955`). Main is a nondispatching procedure;
charging its optional variant and dynamic-termination symbols covers the entire
procedure arm without needing either annotation to be present
(`src/why/why-atree-modules.adb:3118–3209`).

Let `T_i,T_s,O` count distinct ordinary Main signed Integer types, String types
and object/index entities respectively. Cached entity modules are separate:
the memoized `(entity, Module_Kind)` table has 27 kinds and creates one module
on a miss (`:465–504`). With `E_all` bounding **all** normalized entities whose
modules may be requested, including fixed dependencies and lazy close-time
requests, the additional pre-import allocation allowance is

```text
B_init_symbols <= (1439 + 36T_i + 50T_s + 6O + 4 + 27E_all, 0, 0, 0).
```

There is no new `Close_Theory` here. The scalar/String `EW_Abstract` allocation
terms include their uncached map modules; the `27E_all` term covers only the
memoized entity-module family. Fixed-library symbol fills with richer shapes
remain in the dependency term. Taking `T_i+T_s <= E_Main` and `O <= E_Main`
gives the deliberately looser but directly entity-based allowance
`1439 + 56E_Main + 4 + 27E_all`. These allocation bounds close ordinary Main's
previously unpriced symbol cache family; they do not close the enclosing Main
subprogram theory/VC construction or the remaining fixed translations.

### Enclosing Main theories and VC wrapper

Main is a nondispatching procedure with no formals, user pre/postconditions,
contract/exit cases, subprogram variant, dynamic termination condition,
handlers, borrows or source `return`. The [selected public call shapes](retained-producer-calls.md#reachable-branches)
also have no exceptional or program-exit contract. The corresponding guards
read contracts, rather than inferring a handler from a possible implementation
exception (`src/spark/spark_util.adb:2450–2540,3092–3153`). The default
termination condition is unspecified or static, never dynamic
(`src/spark/spark_util-subprograms.adb:786–859`). Thus the wrapper does not
introduce handlers for library effects, variant expression translations or
body-level contract expressions.

There are four enclosing theory closes:

1. `Translate_Subprogram_Spec`: one regular definition header/close
   (`src/why/gnat2why-subprograms.adb:9049–9134`). Main has no logic-function or
   dispatch theory.
2. `Generate_Subprogram_Completion`: program declaration and post-axiom
   headers/closes (`:7431–7610`). The procedure's post-axiom body is empty, but
   its header and close still count. Its `Generate_Axiom_For_Post` eagerly
   computes logic binders **before** the procedure early return (`:6644–6688`).
3. `Generate_VCs_For_Subprogram`: one directly created VC module and one
   header/close (`:4455–4483`).

`Register_Symbol` also registers Main itself using the subprogram arm of
`Mk_Item_Of_Entity`: one identifier/name pair
(`src/why/gnat2why-driver.adb:1381–1391`,
`src/why/why-gen-binders.adb:820–886`). Memoized entity modules remain in
`27E_all`; the direct VC module is charged here.

The declarations and handled statements are translated once at
`gnat2why-subprograms.adb:5840–5872`. With no handlers/finally statements,
`Transform_Handled_Statements` returns its one statement-list translation
unchanged (`gnat2why-expr.adb:26695–26734,26822–26841`). Every subsequent
sequence, try block or binding embeds its supplied body once. No whole Main
body is copied into the specification or completion theories.

Two otherwise easy-to-miss allocation families are retained:

- A zero-parameter `Compute_Binders` call creates a fresh two-node
  `Unit_Param`, not a shared constant. Completion calls it in its ordinary
  program declaration, dynamic-effect helper, access-preservation helper and
  eager post-axiom setup. The VC declaration creates one more unit parameter
  (`gnat2why-subprograms.adb:1220–1246,1368–1384,6644–6688,7614–7631,8515–8522`,
  `why-gen-binders.adb:1629–1640`).
- Finalization eagerly creates two Void sequences. It scans declarations,
  but ordinary scalar/String objects contain no allocated parts and introduce
  no borrows. Their memory-leak checks return Void; appending Void adds
  nothing. Thus this scan adds no per-local-object Why allocation
  (`gnat2why-expr.adb:2945–2990,3057–3121,9558–9676`,
  `why-gen-progs.adb:52–102`).

Empty contracts can still allocate Boolean literals (`gnat2why-util.adb:644–698,
840–856,1007–1018`). Their two ignored runtime-check expressions each allocate
an identifier/name, binding and abstract expression, even though the contract
is True (`why-gen-progs.adb:199–213`). These discarded/empty cases are included
in the following core allowance. Supplied source declarations/body and the
fixed-effect work below are separate children, included once.

| Core wrapper part | Nodes | Lists | Elements | Occurrences beyond supplied children |
| --- | ---: | ---: | ---: | ---: |
| Main registration, four headers and direct VC module | 7 | 8 | 0 | 4 |
| Completion: local name, eager unit binders, declaration, effects, empty pre/post | 15 | 4 | 2 | 16 |
| Twelve possible sequences, 39 total argument slots | 12 | 12 | 39 | 168 |
| Final return raise, try block and handler | 3 | 1 | 1 | 13 |
| Two eager finalization Void sequences | 2 | 2 | 3 | 10 |
| Four comments | 4 | 0 | 0 | 4 |
| Two ignored empty contracts, including their literals | 10 | 0 | 0 | 32 |
| Other empty-contract literals, including possible assertions/warnings | 3 | 0 | 0 | 0 |
| VC effects | 1 | 3 | 0 | 0 |
| VC function declaration with unit binder | 4 | 1 | 2 | 12 |
| **Core total** | **61** | **31** | **47** | **259** |

The sequence arities are `5,3,5,2,4,3,2,2,2,6,3,2`: initial body,
post-finalization body, output checks, result append, contract/body assembly,
input assumptions, moved-output assumptions, precondition runtime check,
precondition assumption, outer assembly, postcondition checks, and final
external-constant prepend. Each is charged even where Void filtering avoids
allocation. The occurrence allowance `1+4n` per `n`-slot sequence allows a
four-occurrence Void in every slot in addition to separately charged supplied
children. This overcount is safe for empty/nonempty cases and is not an
assertion that all sequences are emitted. `Declare_Exceptions` has no entries:
the sole insertion path handles `N_Label`, excluded from source syntax and
absent from ordinary light expansion. A parser-generated loop
`N_Implicit_Label_Declaration` is a different node kind and does not trigger
that path (`gnat2why-expr.adb:30068–30112`). The parser's `N_Label` constructor
is in the explicit `<<name>>` parser; loop label declarations use
`N_Implicit_Label_Declaration` (`gcc/ada/par-ch5.adb:1101–1127`,
`par-labl.adb:496–525`).

The five possible fixed effect roots are the four concrete Silver_IO output
objects plus opaque File_System. They are unioned sets, so repeated source
calls do not multiply the enclosing wrapper's effect count. Let `g <= 5`;
charging every root as an ordinary static scalar/String overcounts the opaque
state, which is ignored by invariant processing. Source Main objects are not
global effects.

| Additional work per possible fixed effect root | Cost |
| --- | --- |
| Eager unused logic binder/localization plus read/write effect references | `(11,0,2,12)` |
| Input assumption and output dynamic property | `2*(34,16,24,72)` |
| Three discarded type-invariant traversals | `3*(19,10,15,0)` |
| **Per-root allowance** | **`(136,62,95,156)`** |

For the first row, an opaque-name binder costs at most three nodes and
localization two; each of its read/write references allows another three-node
identifier/module construction and six occurrences. Existing registered
ordinary binders are smaller (`why-gen-binders.adb:281–364,613–690`,
`gnat2why-subprograms.adb:1544–1696,2067–2097`). The input/output row uses the
already-derived ordinary declaration suffix allowance. The static String
and nonempty scalar globals introduce no dynamic predicate-variable inputs.
The three type-invariant passes are the completion's outputs and the VC's
inputs/outputs. They can allocate an unused object read `6/3/5` and static
array traversal `13/7/10` even though the final invariant is True. The two
Booleans and constrained Natural cost less. These paths are
`gnat2why-subprograms.adb:1283–1362,1368–1540,2018–2051,8113–8157` and
`gnat2why-expr.adb:14615–14858`.

`Check_Ceiling_Protocol` eagerly translates the platform's Default_Priority
before iterating protected-object locks. No selected Main operation introduces
such a lock. The pinned Linux `libgnat/system-linux-x86.ads:112` defines this
constant as the scalar literal 48; the retained GCC inventory now also captures
that line. The unused read fits the earlier static leaf plus expected-type
allowance `(5,0,0,0)` (`gnat2why-subprograms.adb:548–590`).

Consequently the enclosing contribution is bounded by

```text
B_Main_wrapper <= (61,31,47,259) + 5*(136,62,95,156) + (5,0,0,0)
               = (746,341,522,1039)
C_Main_wrapper <= 4.
```

There is no additional external-constant assumption body in Main under this
selected grammar/API. `Assume_Value_Of_Constants` computes the Ada nodes of
modules directly referenced by the supplied Why body; it does not traverse
imported theories or the module-dependency closure
(`gnat2why-expr.adb:2669–2703`, `why-inter.adb:140–159,165–326`). The reachable
module identities in that body are Main's local declarations/expressions,
predefined types and operations, the five selected subprograms, the four
mutable output objects and their static types, or the opaque external state.
Main has no admitted direct reference to an external constant. Generated bound
capture constants remain declared in Main. Static subtype bounds are emitted
as numeric values or type attributes, not as reads of their declaration's
defining constant; no library formal is substituted into a returned Main call.
The [selected call transfer](retained-producer-calls.md) uses registered callee
symbols and actual expressions, without inlining the callee's postcondition.
In particular, `Max_Length` occurs in the imported library theory, not Main's
call expression. The Default_Priority translation above is discarded before
the no-lock branch returns, so it is not in this body's module set.
The assumption filter explicitly skips Main-declared constants and accepts
neither types, subprograms, mutable globals, opaque names nor expression nodes.
It therefore has no matching entity here. Its final Void prepend is already
covered by the enclosing sequence allowance. This is a source exclusion, not
an inference from an observed empty assumption list.

`Assume_Dynamic_Invariant_For_Variables` skips Main-local objects and processes
each remaining referenced entity at most once using `Already_Included`
(`gnat2why-expr.adb:2362–2462`). The fixed-global allowance above therefore
does not conceal a replay per source declaration or per use of a local
constant. Fixed types/constants and assumptions generated in their own
dependency theories remain part of the imported closure. The core/global
allowance and four closes can now be
added to the ordinary Main sum without changing source-expression multiplicity.

The six cached Boolean literals from `Why.Gen.Terms` and `Why.Gen.Progs` add
a further `(6,0,0,0)` bootstrap term
(`src/why/why-gen-terms.ads:31–38`, `src/why/why-gen-progs.ads:38–42`). Their
occurrences are charged at use sites. `Init_Why_Sections` initializes Ada lists,
not Why list IDs (`gnat2why-util.adb:1035–1040,1265–1268`). This still does not
claim an exhaustive package-elaboration allocation inventory.

### Temporary-name counter and the fixed-case alternative

`New_Temp_Identifier_Counter` starts at zero and increments once in the
String-returning overload (`why-gen-names.adb:838–848`). The complete scan in
[`producer-counter-inventory.json`](../evidence/retained-producer-capacity-20261017/producer-counter-inventory.json)
checks all 279 Ada source files against the retained source archive. There
are 145 calls selecting the identifier overload and six direct String calls.
Each identifier overload call invokes the String overload once and allocates
a fresh name/identifier pair (`:850–868`). The six direct String-call sites
are accounted for as follows:

| Direct String call | Distinct fresh node charged to its increment |
| --- | --- |
| Identifier and generated-identifier wrappers, `why-gen-names.adb:865,880` | The returned identifier; the first is the same wrapper already counted above, not another increment. |
| Dynamic invariant name, `gnat2why-expr.adb:7371` | Its enclosing `New_Identifier`. |
| String literal name, `gnat2why-expr.adb:30276` | The identifier immediately declared at `:30278`; its module is additional. |
| Container aggregate helper, `gnat2why-expr-aggregates.adb:2565` | The first module created by `Insert_Extra_Modules` at `:2576`. Both callers (`:3687,4300`) unconditionally insert their modules. |
| Array aggregate helper, `gnat2why-expr.adb:15981` | The first module unconditionally created at `:16051`, after the name is obtained at `:15989`. |

These allocations are fresh and distinct for different increments; none is a
close-time include. Thus the complete producer bound implies
`temporary counter <= B_N`. Its `Natural` range does not add a tighter
restriction once `B_N` fits the Why node domain. This is an allocation charging
argument, including discarded allocations, rather than an observation about
names appearing in JSON. It applies to the aggregate/other fixed paths too;
no Main-only exclusion is needed. The inventory checks source completeness
and overload sites, while the call-to-allocation connection remains a manual
source argument.

Fixed dependency bytes suggest an alternative to manually pricing every
fixed subprogram: exhaustively enumerate the relevant fixed configurations
and measure their producer allocations. The driver always translates Standard
first (20 `S_Types` entries and five explicit types), then processes each
selected entity once in registration, translation and completion. VC generation
only runs where `Analysis_Requested` is `Analyzed`
(`gnat2why-driver.adb:998–1013,1318–1457,1644–1687`). Imported ordinary package
bodies are therefore not replayed per Main call. However, fixed bytes alone
do not prove that all dependency subsets, translation orders, cache states and
context-sensitive paths have been covered.

Retained JSON cannot supply the missing allocation measurements: its IDs count
emitted occurrences, and eager discarded work is absent. `Why.Atree.Free`
clears both lifetime tables after translation (`why-atree.adb:38–54`,
`gnat2why-driver.adb:1452–1457`). A complete fixed-case method would need either
actual table/element counters at those phase boundaries or source bounds for
the omitted work, together with an argument covering all reached fixed cases.
The Standard phase is now covered by the following fixed-state argument and
separate measurement. The imported dependency frontier remains distinct; no
complete dependency constant is inferred from one observed JSON file.

### Fixed Standard phase and allocation measurement

For a pinned target, runtime and producer configuration, Standard translation
starts from a fixed producer state:

- `Mark_Standard_Package` installs a fixed 20-entry membership table before
  Main marking. Only its Short_Float and Long_Long_Float decisions inspect
  target floating-point representation. It also installs the universal and
  explicit integer entities (`spark_definition.adb:13771–13843`). Subsequent
  `Mark_Entity` calls return for these already-marked entities (`:11852–11857`).
- Main's admitted declarations and expressions cannot change a predefined
  type's shape, representation aspects, predicates, initialization policy or
  component/index types. Main has no type, representation or aspect declaration.
  Different node identities and source locations do not change these fixed
  allocation shapes.
- The driver initializes the Why names/modules and output sections immediately
  before Standard translation, and enters `Translate_CUnit` afterward
  (`gnat2why-driver.adb:998–1013`). Main's symbol registration and entity
  translations happen inside that later procedure (`:1415–1444`). They cannot
  prepopulate the Standard producer caches.
- `Translate_Standard_Package` visits the fixed `S_Types` order, then the five
  explicit integer types. Each visit stores information, translates the type
  and completes its declaration (`:1644–1687`). There is no traversal of Main
  expressions at this boundary. Standard scalar/array information storage
  returns directly (`gnat2why-tables.adb:785–810`).

This gives one fixed Standard case for that target/configuration, rather than
an extrapolation from a representative Main. The
[measurement record](retained-producer-fixed.md) and
[raw evidence](../evidence/retained-producer-fixed-20261018/README.md) retain the
bootstrap and post-Standard table snapshots, installed-binary identity and
debugger reader. The source-to-installed-binary correspondence limitation
stated above remains; debugging metadata does not establish a source rebuild.

The snapshot's node/list counts include discarded allocations. Its retained
list-element sum also equals lifetime list appends/prepends up to that point:
`List_Table` is private; its content is mutated only by `Append` and `Prepend`
in `why-atree.adb:10–32`, newly allocated lists start empty (`:74–80`), and
`Free` is the only table clear (`:38–54`). `Get_List` returns a controlled
container value, not a writable reference into the table. The complete source
inventory has no deletion or replacement of table-list contents; generated
traversal/serialization only reads them. Transient container copies do not
allocate additional Why list IDs and are not included in this counter.

Expanded occurrences across retained theory roots are a per-file upper bound,
not a measured serializer count. `Build_Printing_Plan` keeps a fresh `Seen`
symbol set and appends each visited theory at most once (`gnat2why-util.adb:
503–540`); serialization then visits that list (`gnat2why-driver.adb:1204–1215`).
An include serializes its module node, while printing-plan traversal handles
the imported theory separately. The aggregate still multiplies the all-root
occurrence bound by the number of printed files. Standard's closed theory
handles are local to type/representation translation; later entity passes
access its cached module/name/type/identifier values. Those node kinds are
immutable. The schema's mutable kinds are effects, statement sequences and
theories (`xtree_sinfo.adb:115,531,724`); the only complete-source uses of theory
append mutators are `Emit` and `Add_With_Clause`, through their current theory
handles (`why-gen-decl.adb:46–88`, `why-inter.adb:361–381`). `Find_Decl` is used
by the printing traversal, not to append to a closed Standard theory. Thus
later Main translation does not enlarge the Standard-root trees whose
occurrences are subtracted when measuring a post-Standard delta.
Fixed Standard imports are
already present in the measured state; a combined calculation can start there
and charge `C` only for subsequent, unpaid closes, or conservatively charge
those imports a second time. This does not establish the remaining imported
library contribution.

### Imported dependency frontier

The possible direct API roots are `Silver_IO.Put`, `Put_Line`, and
`Silver_Arguments.First_Or_Default`, `Input_Is_Valid`, `Reject`. Their selected
specifications are fixed and use only ordinary scalar/String objects and
contracts, plus the opaque `Ada.Text_IO.File_System` state. Main supplies no
generic actuals, derived types, access values, user predicates, record fields,
dispatch overrides or expression-function definitions that could specialize
those specifications.

The source gives a finite **marking** frontier:

1. Imported `with` clauses mark their package's initial-condition expressions,
   not every declaration (`spark_definition.adb:4289–4307`). Neither selected
   Silver specification has an initial condition. Repetition and reordering of
   context clauses therefore do not add imported marking roots.
2. A normal call marks its callee and then its actuals (`:6497–6498`);
   `In_SPARK` also delegates to `Mark_Entity` (`:2414–2428`). Actual expressions
   introduce only Main entities, already-marked Standard types, and the same
   five API roots. Integer Image analysis has Standard.String result and no
   runtime-API load in this frontend mode (`gcc/ada/sem_attr.adb:1541–1618`);
   its producer translation is the already-priced Image path.
3. `Mark_Entity` returns immediately for an already-marked entity
   (`spark_definition.adb:11852–11857`). Each ordinary newly marked entity is
   appended once (`:12186–12248`). An imported ordinary subprogram body is not
   recursively marked; the body exception covers expression/predicate
   functions, followed by marking contracts (`:9540–9625`). None of the five
   public operations is an expression function. `First_Or_Default`'s fixed
   postcondition itself refers to `Input_Is_Valid`, so the closures overlap.
4. Project an arbitrary Main's marking trace to the first encounters of the
   five distinct API roots. It is an ordered subset of five elements, hence
   belongs to the finite superset of
   `1 + 5 + 20 + 60 + 120 + 120 = 326` words. Some words cannot occur in the
   admitted grammar or collapse to the same closure; keeping them is
   conservative. A set of 32 subsets alone would discard translation order.

This proves a finite API-root/marking frontier, **not yet an exhaustive producer
measurement frontier**. Interleaved Main translation must also be eliminated
from the fixed-state calculation. The relevant state boundaries identified so
far are:

| Shared state | Source relation and consequence |
| --- | --- |
| Entity translation sequence | `Translate_CUnit` performs separate all-entity registration, translation, hidden-global and completion passes (`gnat2why-driver.adb:1415–1444`). Main expression evaluation does not execute imported bodies. |
| Entity symbols and modules | The symbol key is `(Retysp(E), Why_Name_Enum)` and the module key is `(E, Module_Kind)` (`why-atree-modules.adb:85–126,297–324,465–504`). A Main-local entity does not alias a fixed library entity. Earlier lookup may pay a fixed cache fill sooner; its cached value is not specialized to the caller's actual expression. |
| Symbol-table bindings | Bindings are keyed by entity or fully qualified opaque entity name. Local contract bindings use push/pop scopes (`gnat2why-util.ads:58–158`; `gnat2why-subprograms.adb:7643–7658,8446`). Main's local spelling does not rebind a fixed library formal. |
| Array representations | The key depends on rank, index representation, component root type and relaxed initialization (`why-gen-arrays.adb:2990–3036`). Main reaches only the ordinary one-dimensional Character key, populated by Standard.String before Main. The seventeen eager nodes are still charged per call before the cache test (`:1075–1093`). |
| Other representation families | Fixed-point, access-subprogram, higher-order specialization, lemma specialization and unchecked-conversion maps are distinct (`why-atree-modules.ads:622–652,712–803`). Main has no constructs that populate them. |
| Literal/aggregate modules | Their entity-module key is the actual fixed expression node, not Main's actual-argument value; the shared-literal distinction discussed above remains necessary. |
| Hidden global declarations | `Translated_Object_Names` inserts each opaque effect name once before emitting its module (`gnat2why-driver.adb:1596–1638`). Main's possible external name is the same fixed File_System state. Repeated calls cannot add new hidden states. |
| Current subprogram/result names | Entity translation sets `Current_Subp` to that entity and clears it afterward (`gnat2why-driver.adb:1495–1502,1589`). Fixed function completion establishes and clears its result name (`gnat2why-subprograms.adb:7521–7570`). |
| Module dependency graph and imports | Closing a theory traverses its own Why tree and dependency sets (`why-inter.adb:165–326,562–749`). The existing global `M`/`C` allowance bounds import growth without assuming one witnessed order is maximal. |

### Additive isolated-root envelope

The marking orders need not all be measured if fixed shared work is paid more
than once. Let `r` range over the five roots and let `D_r` be the complete
post-Standard allocation vector from a fixed witness containing that root.
Witness Main work is retained in `D_r`; only the common completed Standard
phase may be subtracted. `First_Or_Default`'s witness also includes the
`Input_Is_Valid` specification reached by its postcondition. This deliberately
overcounts overlapping closures when the five vectors are summed. Use all
five witnesses in the fixed constant, even when a particular Main calls no
library operation; their repeated ordinary-Main scaffolding also covers the
mandatory helper dependencies, such as the fixed Default_Priority reference.

The sufficient source reduction for **non-import fixed work** is:

- Marking a root traverses its fixed signature, fixed global contract and
  fixed contract expressions. Repeating a root does not replay this traversal.
  The public signatures have no controlling/access parameters, generics or
  user predicates; the effects are the same four scalar/String output objects
  and opaque state. Their declaration subtypes and the quantified/slice
  expressions inside contracts belong to the fixed dependency tree. These
  dependencies cannot refer backward to Main declarations.
- Each fixed entity receives one information-store/registration/translation/
  completion visit. The registration pass happens before any translation.
  Main cannot add record descendants, invariant procedures or specializations
  to these scalar/String/opaque shapes. Imported ordinary bodies receive no
  Main-process VC generation. Subprogram translation resets its current-entity
  context, and contract local bindings are scoped and restored.
- For entity symbols/modules, a hit returns the previously generated value;
  a miss adds the value determined by that same fixed entity and module/symbol
  kind. Neither path uses the caller's actual String expression to specialize
  the fixed value (`why-atree-modules.adb:297–324,465–504,3006–3059`). Main
  references may pay a fixed cache fill earlier, but cannot give it a larger
  tree shape. Summing complete isolated witnesses retains that fill regardless
  of which of their phases paid it. No subtraction of witness Main work is
  permitted.
- The array-representation shared key is already paid by Standard.String.
  Eager work before its cache check remains charged in every witness. The other
  representation families in the table are unreachable from Main and these
  fixed public interfaces. Fixed expression-module cache keys are fixed
  expression identities; Main expressions cannot collide with them. The
  selected specifications contain no ordinary String literal initializer
  whose first translation could choose a caller-dependent literal type.
- A combined closure can suppress an already-completed fixed entity or a
  cache fill; it does not multiply a fixed entity's pass. The non-import
  emitted shape refers to immutable cached module/name/type/identifier nodes.
  Mutable Why effects, statement sequences and theory handles are constructed
  for the current transformation, not specialized cached values exported by
  a Main caller. The only whole-set traversal affecting fixed Why size is
  dependency import closure, which is deliberately charged separately.
- Hidden-global generation is a union by name. Root witnesses that need
  File_System already pay its declaration. The empty exception theory and
  other enclosing Main scaffolding may be paid repeatedly in the sum; no
  selected operation introduces an exceptional contract or exception handler.
  The earlier direct-module argument excludes external-constant assumptions
  from Main's wrapper.

Consequently an additive envelope can use `sum_r D_r` for non-import imported
work, while retaining the general `C*(2+2M)` allocation and `C*(4+4M)`
occurrence allowances for **all post-Standard closes**. Measured import nodes
already included in the witnesses are harmless additional overcount; do not
assume their observed import count bounds other orders. The same source
reduction bounds the number of fixed closes by the sum of the isolated
fixed-closure close counts; a witness's enclosing Main closes can also be
retained conservatively. The [checked five-root measurements](retained-producer-fixed.md#selected-imported-dependencies)
now give `sum_r D_r = (8868,2017,3015,13059)`, and hence the completed
Standard plus selected imported-dependency envelope is
**`(15349,3310,4729,22621)`**. The 219 additional retained theory roots bound
the corresponding completed close paths by the source argument in that
record; they are not an independently observed close-call counter. These
measurements close these four fixed components, not auxiliary peaks or
whole-process name/counter domains.

Separate compiler/prover processes for library bodies are fixed-input cases
of their own. Their phase-one prerequisite generation is not a measurement of
their Why allocations, and Main's five imported-specification witnesses do
not cover those body processes. The separate four fixed-unit measurements
are now retained in the [fixed-process record](retained-producer-fixed.md#separate-fixed-library-processes);
their per-process resource domains must be checked independently rather than
added to Main's simultaneous table lengths.

## Auxiliary map domains and interned-name arithmetic

The four-component Why bound does not by itself bound every producer
representation. The following source domains connect several auxiliary
containers to already identified quantities. Write `A_total` for all available
frontend node identities in this process, including fixed dependencies and
reserved node values that can be keys, and
`E_total <= A_total` for its entity subset. `A_Main` alone omits the fixed
dependencies. Cardinalities are per container, not sums of all containers.
The [storage argument](retained-producer-storage.md) supplies the corresponding
Ada container arithmetic; these rows supply the actual key domains.

| Container family | Cardinality bound and source |
| --- | --- |
| Node/entity-keyed map or set | At most `A_total` (`E_total` for entity-only keys). This includes `Common_Containers.Node_Maps`, `Node_Graphs`, `Node_To_Bool_Maps`, `Node_To_Int_Maps`, marking sets, information maps and `Ada_Ent_To_Why.Entity_Ids`. Every inner node set in `Node_Graphs` has the same bound; total graph edges can be quadratic and are not bounded by the outer cardinality. |
| `Entity_Modules` outer map | At most `A_total`; each ordered inner map has at most **27** `Module_Kind` values (`why-atree-modules.adb:84–95,465–504,2991–3000`; `.ads:819–857`). The nonentity insertion path may retain an empty inner map, so counting modules alone is insufficient for its outer map. |
| `Why_Symb_Map` and `Why_Relaxed_Symb_Map` | Each at most **`160 E_total`**, from the product key `(Entity_Id, Why_Name_Enum)` (`why-atree-modules.adb:97–125,3048–3059`). The enumeration has 160 values. A sharper allocation injection may be useful, but is unnecessary to establish this domain. |
| `Symbol_To_Theory_Map` | At most the number of completed theory roots, including Standard, hence at most `B_N`. Its sole insertion associates the current theory's name at close (`why-inter.adb:60–67,747`). |
| `Entity_For_Axiom_Module` | At most `M <= B_N`, because its keys are actual module-node IDs (`why-inter.adb:69–81,1359`). All other Why-node-keyed maps have domain at most the allocated Why-node count. |
| `Projection_Names_Decls` | At most `B_N`; every new key accompanies a fresh function declaration (`why-gen-decl.adb:138–236`). For a key used `p` times the stored Positive value is `p+1`, because the first insertion stores 2. Each use allocates that function declaration, so the largest stored value is at most `B_N+1`, safely representable when `B_N <= 2^30-1`. This is separate from the number of keys. |
| Symbol-keyed representation maps | Each at most the number of distinct names in the Why symbol pool. For Main, ordinary rank-one Character array representations already exist after Standard, and the richer specialization families are unreachable as established above (`why-atree-modules.ads:539–599,631–652,732–803`). Counting distinct representation keys does not count subsequent name lookups. |
| `Common_Containers.Name_Cache` | At most `E_total`, because it is keyed by entity (`common_containers.adb:38–43,87–103`). Its separate `Symbol_Cache` and `String_Cache` each have at most `U_entity` entries, the number of distinct nonempty names passed to the string overload. `U_entity` includes names loaded from dependency metadata; it is not automatically equal to `E_total`. |

The scoped symbol table also has an undo list. Each `Push_Scope` adds one
boundary. A new scoped key adds one inverse action, while replacing an
existing scoped key adds two: restore the old item and remove its replacement
(`gnat2why-util.adb:159–219,255–284`). Its length is bounded by outstanding
boundaries plus **twice** the number of outstanding scoped insertions, **not**
by the current map's distinct-key count: repeated replacement of the same key
adds actions.
This source identity exposes the additional peak bound still required.

### Two separate symbol pools

`Why.Gen.Names.NID` calls `GNATCOLL.Symbols.Find` on `Why3_Symbol_Alloc`
(`why-gen-names.adb:42,816–819`). `Common_Containers.To_Entity_Name` uses a
different `Intern_Strings` pool (`common_containers.adb:50–63`). These are
GNATCOLL allocators, not the frontend Namet table.

The retained recipe selects GNATCOLL's `26-sustained` branch. The inspected
revision is `1d4374ae9187fd14d42ca99a3deb0ab2ff1ebc55`; the complete relevant
[specification](../evidence/retained-producer-capacity-20261017/gnatcoll/gnatcoll-symbols.ads)
and [body](../evidence/retained-producer-capacity-20261017/gnatcoll/gnatcoll-symbols.adb),
recipe and hashes are retained with the
[source/inspection record](../evidence/retained-producer-capacity-20261017/gnatcoll/identity.json).
This retains the external-tool relevant-behavior premise; it does not establish
the branch resolution at the historical build or a complete binary attestation.

`Symbol_Table_Record` holds an ordinary Ada hashed set and three counters
(`gnatcoll-symbols.ads:102–118`). `Allocate` reserves 98,317 buckets through
the ordinary `Reserve_Capacity` routine (`.adb:35–40,222–227`). `Find`
(`.adb:79–103`) has these independent charges:

1. An empty string returns the static empty symbol with no counter charge.
2. Every nonempty call increments `Calls_To_Find : Natural`, **including hits**.
3. A miss adds the string length to `Total_Size : Long_Long_Integer`, allocates
   a complete String and inserts its pointer into the set.
4. A hit instead adds the same length to `Size_Saved : Long_Long_Integer`.

Static GDB type inspection and disassembly, with no inferior execution,
confirm that the installed `Find` uses a 32-bit `0 .. 2147483647` call counter
and checks its increment before lookup. The two 64-bit byte accumulators
also have explicit overflow checks. The retained
[disassembly](../evidence/retained-producer-capacity-20261017/gnatcoll/symbol-static-gdb.txt)
identifies these checks at offsets `+48..+62`, `+124..+134` and `+203..+213`.
Their diagnostic purpose does not make their capacity irrelevant.

For either pool, let `F_pool` bound lifetime nonempty calls and `U_pool` bound
distinct nonempty strings. Sufficient conditions are

```text
F_pool <= 2^31 - 1
U_pool <= 1,610,612,741       (the checked hashed-container growth envelope)
each constructed String and intermediate concatenation is representable.
```

The byte accumulators then need no additional independent numeric restriction:
every valid String has length at most `2^31-1`, and each call contributes to
only one sum, so each is at most
`(2^31-1)^2 = 4,611,686,014,132,420,609 < 2^63-1`.
Likewise an individual String allocation plus its small descriptor/alignment
overhead fits 64-bit allocation arithmetic. This proves representability, not
availability of physical memory.

`Common_Containers.To_Entity_Name (S)` also evaluates
`String_Cache.Last_Index + 1` **before** testing whether the symbol is already
cached (`common_containers.adb:63–82`). Consequently reaching
`Entity_Name'Last` entries would make a later hit unsafe as well as a miss.
The sufficient hashed-container bound on `U_entity` is already smaller than
that 2,147,483,647 endpoint. Nevertheless, lifetime interning calls still require
their own bound. The entity overload caches `Unique_Name(E)` and interns only
on a missing entity key; direct string calls used for dependency records must
be counted separately.

### Name construction and the remaining lookup connection

The complete archived SPARK Ada-source inventory contains **671** calls to
`NID`. The checker retains their locations and lexical enclosing constructors;
it does not promote lexical containment to an allocation theorem. Most calls
name fresh identifiers, modules, axioms, comments or labels. The finite
exceptions include initializer constants, trace/VC labels and representation
name lookups. In particular `Get_Array_Theory_Name`
(`why-gen-arrays.adb:2990–3036`) calls `NID` even when its caller only reads
an already populated representation map. All Main String types share that
ordinary rank-one Character key, but every lookup still increments the pool
counter. Therefore neither `U_pool` nor `B_N` alone establishes `F_pool`.

The inventory permits a tighter separation than treating all 671 sites as
unpriced. The 639 calls lexically inside constructors have an allocation
charge: raw name/identifier/module/axiom/comment/label/meta/namespace/theory
builders allocate, while the identifier, guarded-axiom and function-declaration
wrappers reach their raw builders. At most two direct `NID` calls share one
such constructor invocation; those two-site cases are the meta declarations
at `why-gen-decl.adb:100–110`. This contributes at most `2B_N` calls. The 32
remaining sites partition as follows:

| Sites/family | Lifetime call bound and allocation connection |
| --- | --- |
| Ten initialization literals | Exactly ten calls at `why-atree-modules.adb:514–519,894,2755–2758`, all outside source-sized loops. |
| Three trace-label sites | At most `2B_N`. The entity overload interns twice; the string overload once. All requests accompany a fresh constant/function/global-ref declaration, quantifier or local record-field identifier. `Emit_Global_Ref_Or_Function` allocates in all three branches (`gnat2why-decls.adb:526–575`), including when `Get_Counterexample_Labels` discards labels for a generated entity. Direct record calls have `To_Why_Id(..., Local => True)` or their freshly allocated field association (`why-gen-records.adb:1389–1410,3183–3202,3252–3267`). |
| Two VC-label sites | At most `2B_N`: `New_VC_Labels` interns one check and at most one shape. Its three callers allocate a fresh label, any-expression or variant (`why-gen-expr.adb:5309–5323`; `why-gen-progs.adb:135–147`; `gnat2why-expr-loops.adb:2026–2038`). |
| String module overload | At most `B_N`, charged to its fresh module (`why-gen-names.adb:825–834`). |
| Loop-head and branch markers | Together at most `B_N`, charged to distinct fresh location-label or assignment nodes (`why-gen-expr.adb:1956–1981,4728–4750`). |
| Four exception/namespace sites | Together at most `B_N`: goto and loop-exception helpers return fresh names, and the two mutually exclusive namespace arms return a fresh identifier (`why-inter.adb:1023–1028,1127–1146,1496–1513`). |
| Eager inline marker | At most `B_N`, charged to the eager `Result_Id` temporary constructed before the marker in each `Declare_Logic_Functions` invocation (`gnat2why-subprograms.adb:3342–3358`), even if later code chooses another declaration branch. |
| Comparison/logical-array theory suffixes | Together at most `B_N`; their only uses construct fresh modules on a representation-cache miss (`why-gen-arrays.adb:1111–1114,1130–1133`). |
| One pretty-expression marker | Charge its requests separately as `F_pretty`. The ordinary `Transform_Expr` caller interns before the constant-True/False early returns (`gnat2why-expr.adb:23630,23654–23656`), so a fresh label at `25502–25508` cannot fund every request. The other caller allocates a label at `25847–25853`. |
| One array-representation name site | Charge every lookup as `F_array`, including hits (`why-gen-arrays.adb:3035`). String-literal-subtype recursion delegates and does not intern an additional name. |
| Two fixed-point name sites | Charge requests as `F_fixed_point` (`why-gen-scalars.adb:1515,1539`). These are confined to fixed Standard work for the current Main grammar and selected API contracts, but their exact fixed total is separate from Why-node measurements. |
| Three profile/specialization/unchecked-conversion sites | Unreachable from the current Main grammar and selected fixed interface shapes; preserve a separate `F_special` if that shape set is extended (`gnat2why-subprograms-pointers.adb:1250`; `gnat2why-unchecked_conversion.adb:180`; `why-atree-modules.adb:389`). |

Thus the current process can use the compositional bound
`F_Why <= 10 + 11B_N + F_pretty + F_array + F_fixed_point`, with
`F_special = 0` for the specified domain. The coefficient 11 is the sum of
the allocation charges above, not a fitted multiplier. It remains necessary
to connect the three residual request counts to source invocations/fixed work;
introducing their names is not itself that connection. In particular distinct
array keys do not bound `F_array`, and emitted pretty labels do not bound
`F_pretty`.

### Array-name lookup requests have an allocation charge

The representation-map hit path still interns names, but the callers provide
an allocation injection. The complete `Get_Array_Theory_Name` caller family
is the two creator routines and seven accessors at
`why-gen-arrays.adb:653–654,1078,2933–2985`, plus the direct module argument
in `New_Kind_Base_Type` (`why-inter.adb:1188`); the String-literal-subtype recursion
at `:3000–3002` delegates without performing an extra intern. The accessor
families issue one lookup, or two for conversion and wrapper pairs.

| Caller family | Fresh allocation funding each invocation |
| --- | --- |
| Conversion-theory creation | Two lookups at `why-gen-arrays.adb:653–654` precede a fresh module at `:658–660`, even when the cache hit later returns at `:694–695`. |
| Representation-theory creation | One lookup at `:1078` precedes its fresh module at `:1080–1081`, before the cache test at `:1085–1086`. |
| Abstract/split array base type | The direct query at `why-inter.adb:1188` belongs to its fresh module at `:1185–1188`, nested inside the freshly allocated type/name pair. |
| Array type symbols and declaration | Each lookup at `why-atree-modules.adb:3310,3328` belongs to a fresh identifier. The lookup at `why-gen-arrays.adb:1571` precedes an unconditional fresh type declaration at `:1577–1581`. |
| Direct expression/accessor calls | Every lookup in `gnat2why-expr.adb:18591–18709,18850–18997,22176–22320`, `why-gen-expr.adb:1227,1387,1430`, and `why-gen-arrays.adb:3274,3296,3693,3715,3735` is the name/type argument of a fresh call. The two-name wrapper accessors consume at most two lookup credits per such call. |
| Precomputed array operation names | `New_Array_Access` and `New_Array_Update` query at `why-gen-arrays.adb:3052,3117` and allocate their result calls on every returning branch. `Transform_Array_Logical_Op` queries at `gnat2why-expr.adb:18774` and allocates its operator call at `:18867–18873`. The Boolean-array case is outside current Main, but this charge covers it too. |
| Array `Conversion_Name` branch | Its two-name query at `why-gen-names.adb:347` is reached from the final fresh call in `Insert_Single_Conversion` (`why-gen-expr.adb:3032–3038`). Other `Conversion_Name` callers select scalar component/index or scalar attribute conversions in the current rank-one Character-array domain, so they do not execute this branch. |

These funding allocations are distinct between invocations and caller rows;
the two queries of one pair share only their own allocation. This gives
`F_array <= 2 B_N`, without extrapolating from the number of representation
keys or observed cache misses. Consequently the current-domain pool bound
simplifies to

```text
F_Why <= 10 + 13 B_N + F_pretty + F_fixed_point.
```

### Pretty-marker requests are confined to fixed contracts

`Usual_Params` starts with `Gen_Marker = GM_None`
(`gnat2why-util.ads:296–304`). The complete flag-setting frontier is:

- specification conjunctions (`gnat2why-util.adb:644–698`);
- subprogram postconditions and expression-function axioms
  (`gnat2why-subprograms.adb:5310,8864`);
- dynamic predicates (`gnat2why-expr.adb:7533,13240`);
- cutpoint/assertion or forced pre/postcondition pragmas
  (`:25760,28105,28471`);
- type invariants (`:30702`).

The assignments inside `Transform_Expr` only consume or propagate an already
set flag (`:23627–23643,24803`); they do not turn ordinary `GM_None` Main
parameters into marker requests. Current Main has none of the annotation,
predicate, invariant or expression-function forms above. Its API calls use
precomputed callee specifications, as established in the call transfer, and
its ordinary branches/loops start from the ordinary parameters. Thus
**`F_pretty_Main = 0`**. Selected imported contracts may still request markers;
they belong to the fixed entity translation/completion frontier above.

This reduces the remaining request count to fixed contract work; it does not
supply its numerical allowance. Marker requests that reach a fresh label can
be charged to that allocation, but the early Standard.True/False returns
(`gnat2why-expr.adb:23645–23657`) still require counting the fixed requests.
The predicate-function early return (`:24996–25000`) is another reason not to
claim a universal allocation injection outside this grammar. The ordinary
Main domain and fixed dependencies must remain distinct in this accounting.

### Serialized label sets have cardinality at most three

All nonempty symbol-label construction paths produce singleton markers,
trace labels, counterexample labels or VC labels. The entity trace helper
constructs at most two symbols and its String overload one
(`gnat2why-util.adb:932–959`). `Get_Counterexample_Labels` can add at most one
`Model_Projected` symbol to that two-element trace set (`:375–444`).
`New_VC_Labels` adds one check label, at most one shape label, and exactly one
of `Model_VC_Post`/`VC_Annotation` (`why-gen-expr.adb:5329–5372`), hence at
most **three** elements. Its bound of two *intern calls* above does not count
the preinterned third symbol and must not be mistaken for set cardinality.
Other marker paths use `Symbol_Sets.To_Set`; binder, declaration and projection
paths pass the constructed set unchanged rather than unioning independently
growing sets (`why-gen-binders.adb:1139,1300,1332`;
`why-gen-decl.adb:131–134,223`).

The separate `String_Sets.Set` identifier-attribute field has at most two
members: temporary identifiers add `mlw:proxy_symbol` and `introduced`
(`why-gen-names.adb:850–867`); Old and Loop_Entry helpers add at most one
(`gnat2why-util.adb:1379–1417,1478–1505`). Identifier/binder copies preserve
that field unchanged (`why-gen-names.adb:1157`; `why-gen-binders.adb:648`).
The constructors otherwise default to an empty set. Therefore a serializer
weight may use **`h = 3`** for every set-valued primitive field in this source
domain. This bounds each individual set; it imposes no aggregate physical-
memory limit on copies of those sets.

Several compositional length costs are already explicit:

| Name operation | Additional characters or bound |
| --- | --- |
| `Short_Name` | At most underlying `Chars` length + 2, because keyword avoidance only changes case and possibly appends `__` (`gnat2why-util.adb:466–475,1594–1595`). |
| `New_Temp_Identifier` | At most base length + 18: `temp___`, optional underscore and at most ten decimal digits. Its independent counter is bounded above by `B_N` (`why-gen-names.adb:838–848`). |
| `Append_Num` | At most base length + 11, for underscore and Positive decimal suffix (`why-gen-names.adb:68–71`). |
| `Ref_Append`, content and havoc | Base length + 5, + 9 and + 7 respectively (`why-gen-names.adb:151,564,916,956,961,971`). |
| Entity modules | `Full_Name` plus one of the 27 fixed suffixes (`why-atree-modules.adb:134–167`); this concatenation happens before a module-cache hit returns. |
| Projection name | Type-name length + field-name length + 25: separating underscore, optional `__` and at most ten digits, then `__projection` (`why-gen-decl.adb:171–190`). The occurrence counter bound above makes those digits representable. |

`Full_Name` delegates to frontend `Unique_Name` except for Standard Boolean
(`spark_util.adb:2323–2340`). For an ordinary non-child, non-generic scope path
of `d` unique entities, this is bounded by the sum of their `Chars` lengths
plus `14d`: each homonym suffix contributes at most `__` and ten digits,
and each enclosing separator contributes `__`
(`gcc/ada/sem_util.adb:30080–30200`). This is a compositional bound; establishing
the generated frontend `Chars` lengths and scope-path domain remains part of
the frontend name argument. `New_Internal_Name` itself contributes one prefix,
at most ten serial digits and one body/spec character
(`gcc/ada/tbuild.adb:61–99,719–726`); its serial counter must also fit.

For the classified **Main light-expansion entity frontier**, the underlying
`Chars` input can be made source-sized. Let `I_max` be the largest source
identifier length (zero if none) and `F` the number of source loops. Source
objects and loop indices retain their identifier spelling. Generated object
subtypes add `T` and `S`, and the rank-one String index subtype adds at most
another `T`, `P` and the digit `1`
(`gcc/ada/sem_ch3.adb:5832–5840,14339–14484,15317–15343,19120–19123`;
`itypes.adb:51–61`). Literal, alias and loop-index itypes use internal names
of at most twelve characters (`sem_res.adb:13224`; `exp_util.adb:5985`;
`sem_ch5.adb:3434`; `sem_ch3.adb:20478–20483,20712–20724`). A captured bound
uses an internal temporary or appends `_FIRST`/`_LAST` to its loop subtype's
internal name, hence at most eighteen characters
(`exp_util.adb:12575–12608`; `sem_ch3.adb:22715–22718`). Object and String
index bounds are static here and introduce no extra related-name capture chain.
Consequently `Chars_Main_max <= max(I_max+5,18)` for this entity frontier,
conditional on the independently required serial/count arithmetic.

Parser-created loop scope names are `L_` plus a Natural counter, also at most
twelve characters (`gcc/ada/par-ch5.adb:2344–2352`). Main has no nested
subprogram, package, block, generic or type scope; the remaining scope chain
contains Main and at most `F` loop scopes. Full qualification of `Chars` is
skipped in GNATprove mode (`frontend.adb:506–508`), so repeated scope prefixes
are not hidden in these raw names. Applying the conservative twelve-character
homonym suffix even to each loop and Main, plus separators, gives

```text
Full_Name_Main_max <= max(I_max+5,18) + 26F + 30.
```

This bound deliberately counts all loops rather than only nesting depth.
Fixed dependency names and their scope forms remain separate. The bound is
an input to the Why-name composition table, not a bound on all completed
Why strings or on native-code expansion names.

VC/trace labels add source names, node/VC decimal IDs, source locations and
`Shape_Of_Node`. The latter walks the parent path, not a complete repeated
subtree (`spark_util.adb:7005–7338`); its loop-name and source-name contributions
must be charged along that path. Location labels follow instantiation locations
(`spark_util.adb:5944–6006`); Main has neither generic instantiations nor enabled
inlining, while fixed dependencies remain fixed cases. These functions cannot
be replaced by a fixed short-label assumption.

The label-length part of that connection has explicit source-sized bounds.
Let `H >= 18` bound every raw `Chars`/attribute name on the relevant frontend
parent paths, `A_path` bound their acyclic length, `P_file` bound the file names
used by `Location_String`, and `P_ref` bound the reference names used by
`Build_Location_String`. These are per-string/path quantities, not sums of
physical memory use.

| Label or location string | Sufficient length bound |
| --- | --- |
| `Shape_Of_Node` | `A_path * (2H + 8)`. Each iteration adds at most two raw names plus bounded punctuation/tags; the two-name attribute-definition branch is the largest name multiplicity. Other branches satisfy the same bound for `H >= 18` (`spark_util.adb:7005–7338`). No source subtree is recursively serialized into this shape. |
| Shape label | `9 + A_path * (2H + 8)`, adding `GP_Shape:` (`why-gen-expr.adb:4714–4722`; `vc_kinds.ads:1248`). |
| Main check location | `P_file + 22`, from one filename, two colons and two at-most-ten-digit positive images (`spark_util.adb:5944–6006`). Main has no instantiation/inlining chain. Fixed dependency chains must be bounded separately. |
| Main check label | `P_file + 78`: `GP_Check:` (9), VC id (at most 10), two colons, the longest `VC_Kind` image (35), and the previous location bound (`why-gen-expr.adb:4272–4283`; `vc_kinds.ads:48–187`). |
| Main comment location | `P_ref + 11`, from one reference name, a colon and an at-most-ten-digit logical line number (`gcc/ada/sinput.adb:231–277`). This is the different `Build_Location_String` function, not the check-label formatter. |
| Pretty marker | At most 24: `GP_Pretty_Ada:` (14) plus an at-most-ten-digit node id. The special range-bound images `-1`/`-2` are shorter (`why-gen-expr.adb:4876–4877,4911,4918`; `vc_kinds.ads:1247,1272–1273`). |
| Branch/loop marker | At most 20 / 15: `branch_id=` plus a trimmed ten-digit node id, or `Loop` plus the eleven-character nonnegative `Node_Id'Image` (`why-gen-expr.adb:1967,4733–4735`). |

For Main paths, `A_Main` may conservatively replace `A_path`; its `H` is the
maximum of `max(I_max+5,18)` and the fixed called-entity/attribute spellings.
The longest entity-module suffix above is exactly 24 characters
(`why-atree-modules.adb:138–167`). String-literal theory/function/axiom names
use `New_Temp_Identifier ("String_Literal")` and fixed `__def`/`__well_formed`
suffixes; the literal payload is represented by numeric value nodes, not copied
into these names (`gnat2why-expr.adb:30274–30335,30472,30508,30525`). These
bounds are ready for the serializer's per-string parameter, but are not by
themselves an exhaustive maximum for generated identifiers, localized binders,
projection names or theory comments.

The remaining closure work is precise: bound precomputed pretty-expression
markers, fixed-point and metadata-name calls from the source
invocation counts; propagate the frontend name and path lengths through the
listed constructors; and bound scoped undo peaks. The additive fixed Why
measurements do not supply these quantities. The checked map domains and
64-bit-sum reduction above remain usable independently of that unfinished
connection.

Reproduce the auxiliary source inventory, dependency-file checks and arithmetic:

```sh
python3 docs/evidence/retained-producer-capacity-20261017/auxiliary_domains.py \
  --source-root /path/to/archived/spark-source \
  --source-archive docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz
```

This verifies all 279 archived Ada files and the complete 671-site inventory;
it launches no compiler, proof process or debugger inferior.

## Aggregate formula and finite remaining helper families

Use four-component costs in the order `(nodes, lists, list elements, emitted
occurrences)`. The first three count lifetime allocations, including discarded
work. The fourth counts every theory root once, with repeated child references
expanded, before repeating theories between output files. Define `B(P)` as the
sum of all non-`Close_Theory`-import costs for program `P`, including fixed
setup/dependencies, headers, explicit imports, and the finite helper terms
listed below. A measured fixed phase can include its already-paid close-time
imports conservatively. Let `M(P)` bound all module IDs, `C(P)` all unpaid theory closes, and
`F(P)` all printed files in that process. The final aggregation is

```text
Why nodes       <= B_N(P) + C(P) * (2 + 2 M(P))
Why lists       <= B_L(P)
Why elements    <= B_J(P) + C(P) * (2 + 2 M(P))
emitted counter <= F(P) * (B_O(P) + C(P) * (4 + 4 M(P)))
temporary counter <= B_N(P)
```

Each `Add_With_Clause` allocates one include node, appends one element to the
existing theory includes list, and serializes that include plus its module:
no new list (`src/why/why-inter.adb:361–382`). The prior close/import argument
supplies `2+2M`. The printing-plan walk emits a theory at most once per file;
therefore multiplying the sum of all created theory skeletons by `F` is safe,
including when many are never selected. It deliberately overcounts a source
expression that also appears in a discarded theory. This does not assume the
process-global counter resets, or that Main always has exactly one output file.

A separate count of direct module constructions is useful for a tighter result,
but is not necessary to close this import bound. A module is itself an allocated
`W_Module` node (`src/why/xgen/xtree_sinfo.adb:293–298`), and the excluded
close-time imports allocate `W_Include_Declaration` nodes, not modules.
Therefore **`M(P) <= B_N(P)`**, provided `B_N` includes all fixed setup and
memoized entity-module creation, including cache misses reached from
`Close_Theory`. Replacing `M` by `B_N` above is conservative and noncircular:
`B_N` excludes only the import/include allocation, not those module allocations.
This avoids leaving every expression helper's direct-module count as a
separate aggregate gap. A sharper `M` may still substantially improve the
eventual admission envelope.

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
| Built-in symbol/module initializer | `(1439,0,0,0)`; includes 117 modules, no theory roots |
| Cached Boolean literals | `(6,0,0,0)`; other package elaboration still separate |
| Ordinary Main symbol caches and all memoized entity modules | `(36T_i+50T_s+6O+4+27E_all,0,0,0)`; richer fixed-library symbol fills separate |
| Enclosing Main core and five selected effect roots | `(746,341,522,1039)` and four closes; direct-module exclusion establishes no extra external-constant assumption body |
| Ordinary rank-one Character representation key miss | `(148,44,76,711)`; imports separate |
| Main type translation/completion | Five classified rows in the preceding table; representation attempts and symbol caches separate |
| Ordinary object/loop symbol and outer theory setup | [Object component](retained-producer-objects.md): per-visit regular/split `Mk_Item`, constant/mutable definitions, constant axioms and loop exception theory pair |
| Ordinary range loop, excluding supplied body/endpoints | `(69,23,43,267) + q_i*(16,5,6,57) + q_s*(49,19,27,126)`; outer entity theories separate |
| Static generated subtype declaration | `(1,0,0,5)`; type-theory generation separate |
| Scalar range check with static signed Integer base | `(17,7,10,69)` plus endpoint formula above; term children emitted twice |
| Ordinary scalar action preparation/binding | `(11,0,0,8)` plus one initializer translation |
| Declaration-list wrapper with `d` declarations | `(1,1,2d+1,5)`; supplied declarations separate |
| Mixed statement list with `m` source and `g` generated entries | `(m+g+1,1,m+2g+1,m+g+5)` |
| Selected library call wrappers | [Call component](retained-producer-calls.md): Put/Put_Line `(9,6,4,9)`, Reject `(4,6,4,13)`, First_Or_Default `(18,9,9,74)`, Input_Is_Valid `(18,9,9,78)`; argument/result conversions separate |

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
| `K_fixed` | Bootstrap/Standard plus selected imported dependencies now have the additive four-component envelope above; Main external-constant assumptions are zero. Other fixed entry/exit work and non-Main frontend entity/list contribution remain separate. Distinct fixed library processes have their own measured four-component results in the linked fixed-process record. |
| Auxiliary producer domains | Source/Why map key domains, projection counters and GNATCOLL 64-bit string sums are bounded above. Lifetime intern calls, generated-name lengths and undo-stack peaks still require source connections; the four-component fixed envelope does not supply them. |
| Frontend node input | The linked Main semantic-node aggregate supplies `A_Main` used by the ignored-entry/list transfer. Separate fixed dependency node/entity counts remain to be resolved. |
| Whole-process counters | Use `M <= B_N` or a sharper explicit module sum and finish the total close count with fixed setup. `F <= E_list` and `temporary counter <= B_N` are established. |

The [frontend report](retained-frontend-entities.md) now supplies the Main entity,
type and literal multiplicities, including generated literal lengths; they are
no longer an undifferentiated missing frontend inventory. The linked semantic
aggregate closes the ordinary Main node-identity input. Standard is paid by its
fixed phase; selected dependencies still contribute separately to `E_list` and
the remaining fixed terms.
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

To reproduce the independent GCC caller inventory and excerpts, run

```sh
python3 docs/evidence/retained-producer-capacity-20261017/frontend_invocations.py \
  --frontend-root /path/to/pinned/gcc/ada
```

That command checks every scanned complete source file against the already
retained GCC manifest. Its inventory assertions do not mechanically prove the
manual path exclusions in the report.

To reproduce the fixed built-in initializer count, run

```sh
python3 docs/evidence/retained-producer-capacity-20261017/initializer_inventory.py \
  --source-root /path/to/pinned/spark-source
```

The helper source file is also hash-checked against the archive by `capture.py`.
This inventory counts source constructor execution and does not invoke or
instrument a compiler.

To reproduce the whole-source temporary-name inventory, run

```sh
python3 docs/evidence/retained-producer-capacity-20261017/producer_counter_inventory.py \
  --source-root /path/to/pinned/spark-source \
  --source-archive docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz
```

This checks the complete scanned source set against the retained archive and
does not execute the producer.

A focused independent source/evidence review found no defect in the numerical
literal components. Its loop-entry wording correction above distinguishes
`Entire_Object` from `Not_Written`; the recurrence already includes both in `H`.
The review also requested the additional retained conversion/base-type excerpts.
It independently checked the original artifact hashes, exact three-module
extraction, retained-source equality and complete source-file hashes.
