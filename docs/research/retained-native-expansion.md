# Native String concatenation allocation component

2026-10-17, #119. This component closes the **direct native concatenation
emitter's** control-flow and primitive allocation accounting. It does **not**
close the construct's semantic and generated-action callees, and supplies no
whole-program capacity predicate or new admission limit. Counting generated
syntax alone misses allocations made while GNAT analyzes that syntax.

The source is GCC Ada commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The
[retained evidence](../evidence/unbounded-programs/retained-native-expansion-20261017/local-envelope.json)
records forty-one inspected files hash-checked against the complete source
manifest. Adjacent `derive.py` regenerates the arithmetic and lexical inspection
aid from that source directory. Its rows encode the manual control-flow argument
below; it is not an automatic reachability proof or a membership implementation.
No compiler, prover, Lean build or large program probe was run. Independent
review remains required.

## Phase and type premises

This is the native expansion path in `exp_ch4.adb:2552–3639,8005–8097` under
the selected Linux options: Ada 2022, assertions enabled, strict overflow
checking, optimization level zero, no frontend inlining/debug override.
It does not apply to GNATprove's light expansion. The separate native data
representation invocation must establish the same relevant options before
reusing it. Source-to-installed-tool correspondence remains the premise in the
[capacity contract](retained-tool-capacity.md).

All admitted concatenation operands are Strings: the grammar excludes Character
operands, user-defined array types and overloaded `&`. Thus `Atyp` is
`Standard_String`, its index subtype is `Standard_Positive`, and its index base
`Ityp` is `Standard_Integer`. On the selected 32-bit Integer target,
`Artyp = Ityp` (`exp_ch4.adb:2790–2825`). The local `To_Artyp` and `To_Ityp`
functions return their argument unchanged. This does not exclude the explicit
`Convert_To` calls at 2996 and 3003, or later generated conversions.

`Binary_Op_Validity_Checks` is a no-op under the selected validity switches:
`Validity_Check_Operands` defaults to False (`validsw.ads:85`), and guards its
two `Ensure_Valid` calls (`exp_ch4.adb:298–304`). Configuration closure must
exclude a validity-operand override. Other validity checks remain enabled.

## Dispatch multiplicity

`Expand_N_Op_Concat` returns for a concat that is the left child of another
concat. At the highest node of a surviving left spine it collects that spine's
operands and calls `Expand_Concatenate` (`exp_ch4.adb:8023–8060`). The outer
loop repeats for different array types; the common `Standard_String` base type
excludes that repetition here. Right subtrees have their own spines.

For a finite tree with `a` surviving concat nodes and `g` maximal left spines,
spine `i` with `a_i` concat nodes has `n_i = a_i + 1` operands. Therefore

```text
g <= a
sum_i n_i = a + g <= 2*a.
```

This bounds the initial expansion of that tree. **Copied/reanalyzed trees and
independently generated concatenations need separate charges**. It does not
establish that each source `&` is expanded only once in the entire compilation.
Fixed library sources also have a broader grammar.

Within one call let `n >= 2` be the input operand count and `r <= n` its
retained count after known-null operands are dropped. Its operand loop runs
exactly `n` times. `Get_Known_Bound` visits at most `r` successively larger
indices. The assignment loop visits at most `r` entries. These compile-time
counts do not depend on an enclosing program loop's runtime trip count.

## Direct event envelope

The following charges include constructors, shallow `Convert_To` copies,
the saved old node of the terminal `Rewrite`, and the immediate one-list
wrappers of direct `Insert_Action` calls. Open callees are additional.
Some mutually exclusive branches are deliberately overcounted.

| Direct event | Upper charge for `n` operands |
| --- | ---: |
| Ordinary node identities, excluding `New_Copy_Tree` | `25*n + 45` |
| Fresh temporary entity identities | `2*n + 4` |
| List headers, including dispatch/action lists and immediate insertion wrappers | `3*n + 11` |
| Direct `New_Copy_Tree` invocations | `5*n + 6` |
| Direct `Duplicate_Subexpr` invocations | `2*n + 2` |
| Growing-slot events from the terminal direct `Rewrite` | `1` |
| Internal names from the direct temporaries | `2*n + 4` |

Each ordinary-node term comes from a named emitter region, rather than a
measured coefficient. A constructor contributes one identity independently of
the allocation costs of its child expressions.

| Region in `exp_ch4.adb` | Ordinary charge |
| --- | ---: |
| Initial aggregate zero, 2829 | `1` |
| Per-operand lower bound and length capture, 2870–3045 | `4*n` |
| Last-operand bound capture, 2879–3007 | `8` |
| Aggregate length construction, 3054–3099 | `5*n` |
| Conditional lower-bound spine and optional capture, 3176–3228 | `4*n + 3` |
| High-bound construction, 3237–3253 | `3` |
| Two null-result selectors, 3273–3290 | `6` |
| Static maximum and optional slice range, 3306–3315 | `2` |
| Result subtype syntax, 3326–3342 | `4` |
| Maximum of the two result-storage paths, 3374–3433 | `12` |
| Runtime concat call, 3512–3538 | `3` |
| Slice assignment and optional guard, 3554–3617 | `12*n` |
| Result reference and optional slice, 3629–3632 | `2` |
| Saved original in terminal rewrite, 3453 or 3637 | `1` |

For example, general operand setup makes at most one lower-bound attribute
plus the length declaration, its type occurrence and its length attribute:
four nodes. Aggregate fallback makes one current-length leaf, a declaration,
type occurrence, addition and result identifier: five; copying the previous
aggregate length is separate. Last-operand capture makes two attributes plus
two `Convert_To` calls costing at most three shallow allocations each: eight.
The slice path makes four endpoint nodes, four assignment/slice/range/reference
nodes, and at most four guard nodes.

Temporary entities comprise `n` operand-length captures, at most `n-1`
aggregate captures, one lower-bound capture, one result object and three
secondary-stack declarations: `2*n+4`. Lists comprise one operand list, one
action list, at most `n` lower-bound conditional lists, two null-result lists,
one constraint list, four storage insertion wrappers, two runtime-call lists
and at most `2*n` assignment guard/insertion lists: `3*n+11`.

Generated `Nmake` constructors allocate one node/entity and set its fields
(`gen_il-gen.adb:2610–2699`). `New_Occurrence_Of` makes one identifier without
interning another name (`tbuild.adb:732–756`). `Make_Temporary` makes one
defining identifier and one name (`567–577`). `Convert_To` makes at most one
shallow relocation, type occurrence and conversion (`105–121`).
`Make_Implicit_If_Statement` makes one node after a restriction check
(`286–304`); configuration closure must exclude a restriction diagnostic.

`Rewrite` can save one shallow copy and perform one slot-growing `Copy_Node`
(`atree.adb:2255–2276`). The error-path rewrite and normal terminal rewrite
cannot both execute, because the error branch returns. Its error-reporting
helper is separate. The direct entity-kind change needs no additional entity
slots because entities are allocated at maximum size. Mutations in generated
action callees remain additional.

### A closed leaf-copy subset

Each `Aggr_Length` entry is an integer literal or simple identifier referencing
a captured scalar (`exp_ch4.adb:2621–2628,3054–3099`). It has no owned subtree,
defining entity or associated itype inside the copied subtree. Copying it makes
one ordinary node, with no new entity, list, name, String or Uint value.
`New_Copy_Tree` preserves literal values and references to external entities
(`sem_util.adb:24481–24586,24637–24721,25096–25125,25237–25279`).

There are at most `n-1` such copies for aggregate captures, one for the high
bound and two for null selection: `n+2`. Including these gives **`26*n+47`**
ordinary nodes. Remaining direct copies are at most **`4*n+4`**: operand low
bounds `n`, last literal bounds two, lower-bound recursion `n`, high-bound low
expression one, error-path copy one and assignment low expressions `2*n`.

The [allocator component](retained-table-capacity.md#exact-slot-sizes-from-the-pinned-generator)
gives the direct dynamic-slot contribution

```text
9 * ((26*n + 47) + 1) + 61 * (2*n + 4).
```

The extra one is the possible growing rewrite. Node-link and original-node
tables need separate envelopes. This expression excludes allocations in the
remaining copy/semantic helpers.

### Internal names

`New_Internal_Name` uses one letter, decimal unit serial and a body/spec suffix,
then `Name_Enter` (`tbuild.adb:52–98,719–726`). A serial fitting `Nat` has at
most ten digits, so each direct temporary adds at most twelve characters plus
NUL: **`13*(2*n+4)` name-pool characters**. The unqualified individual name
fits `Short` independently of source identifier length.

The **shared** unit serial must not overflow: `Increment_Serial_Number`
increments a `Nat` (`lib.adb:1062–1067`). Other name-producing helpers count
toward it. Later debug qualification and external names have additional costs;
the twelve-character bound does not apply to them. `Name_Enter` always appends
an entry and every character plus NUL (`namet.adb:1142–1161`).

### Direct Uint work

Explicit emitter expressions make at most `3*n+2` additions and `2*n+2`
subtractions: at most two `Hi-Lo+1` computations per operand (2925,3029), one
aggregate addition per retained operand after the first (3071,3082,3086), and
two add/subtract pairs for result/known maximum (3243,3310). `UI_Max` returns
an existing Uint. Numeric constructor conversions here use only zero/one or
existing Uints.

`UI_Add` allocates at most one retained entry; `UI_Sub` at most two, because
negating its right operand can allocate (`uintp.adb:791–977,2153–2179,
2222–2240,2361–2425`). Thus these expressions add at most **`7*n+6` entries
and `k*(7*n+6)` digit words**, when `k` bounds every operand, negation,
intermediate and result in base-32768 digits. The `UI_From_Int` cache can gain
at most one entry per new retained result through that path; its representation
is separate.

`Get_First_Index_Bounds` has at most `2*n` invocations. Its literal-subtype
branch adds one add/subtract pair (`exp_ch4.adb:13542–13560`). Including those
pairs gives **`13*n+6` entries and `k*(13*n+6)` digit words**. Its `Expr_Value`
calls remain separate.

If `H >= 1` bounds the magnitude of every queried input low/high bound and
literal length, a sufficient magnitude bound for this arithmetic is

```text
M = n * max(2*H + 1, 256) + H + 1
k = max(1, number of base-32768 digits of M).
```

256 is `Too_Large_Length_For_Array` (`exp_ch4.adb:83`), an optimization
sentinel, not a String limit. `Max_Aggr_Length` can accumulate it once per
unknown-length operand. Runtime String lengths alone therefore do not bound
this metadata. The formula covers every `Hi-Lo+1`, partial aggregate and both
result-bound computations. Evidence examples use integer arithmetic only.

Full-circuit addition uses two operand vectors of length at most `k` and three
work vectors of length at most `k+1` (`uintp.adb:825–864`): a local sufficient
peak is `5*k+3` digit words. Check `k+1`, byte products and address arithmetic
separately. Negation returns before addition begins. `UI_Max` comparison uses
at most two length-`k` vectors. Temporary arrays and retained pool demand are
different. Semantic evaluation/generated-expression arithmetic is additional.

## Closed copy transfer for decorated String views

`New_Copy_Tree` can be bounded beyond scalar leaves without charging a general
compiler run. The following transfer covers a specific finite decorated-tree
class. The source analysis must derive the decoration summary below; it cannot
obtain it by invoking the opaque compiler as its admission predicate.

Assume the copied root has no defining normal entities, blocks, quantified
expressions or expression actions, no dimension annotations, no entity-list
fields, and no packed or discriminated types. Its owned itypes may only be:

- One-dimensional `E_Array_Subtype` values with one index occurrence and
  external base `Standard_String`.
- Signed Integer index subtypes, each with one scalar-range tree and an external
  predefined scalar base.
- `E_String_Literal_Subtype` values with no `First_Index`; their literal bound
  and length fields are shared, not copied by `Update_Semantic_Fields`.

Here “owned” means the helper's actual test: the itype's associated node is
inside the original root according to the `Parent` chain. `In_Subtree` follows
that chain (`sem_util.adb:15031–15046`); it does not mean every type referenced
by the expression. Referenced object entities, base types, scopes and linked
entities remain external. The default entity map and new scope are empty.
Include every itype reached while visiting the root and owned-type semantic
fields; simply counting the root's `Etype` would miss its index subtype.

Let `t,l` be the ordinary-node and syntax-list traversal counts for copying the
root, following the helper's parent-owned fields. Let `a` be the owned array
subtype count, and `r_j,s_j` the ordinary-node/list counts for each owned signed
index subtype's scalar-range tree. These are occurrence counts: copying the
same subtree through two roots incurs two charges. Let `e` be the total owned
itype count and `q` their number of distinct associated ordinary nodes.

The complete helper allocation transfer for this class is:

| Representation | Additional demand |
| --- | ---: |
| Ordinary node identities | `t + a + sum(r_j)` |
| Entity identities and internal names | `e` |
| Syntax-list headers | `l + a + sum(s_j)` |
| Pending-itype Elist headers | `q` |
| Pending-itype Elist elements | `e` |
| New-entity hash wrappers | `e` |
| Pending-itype hash wrappers | `q` |
| Growing-slot mutations | `0` |
| String/Uint value allocations | `0` |

Phase one deduplicates every owned itype before visiting its semantic fields,
copies its entity once and creates one name (`sem_util.adb:25237–25348`). It
groups pending types by associated node (`24341–24374`), so one Elist header
is created per group and one unique element per copied type. Phase two first
updates each copied entity exactly once (`24922–24940`). An array type copies
its single-index list/identifier; a scalar type copies its scalar range
(`24970–25051`). Its other relevant fields map entities rather than copying
their declarations. The root is then copied once using `New_Copy` per ordinary
node and `New_List` per list (`24603–24721,25597–25623`).

This is why a final syntactic node count is insufficient but the transfer above
is finite: copied semantic ranges are explicit additional roots, and owned
entity visits are deduplicated. There is no semantic analysis, rewrite, numeric
evaluation or new literal-pool materialization inside this transfer.
`Copy_Dimensions` allocates only when an input carries dimensions, excluded by
the class (`sem_dim.adb:2507–2520`). For the current Integer/String sources,
no dimension aspect is admitted.

Both NCT hash tables have 511 fixed buckets. `Simple_HTable.Set` allocates one
wrapper for a new key, and `Reset` frees wrappers (`libgnat/s-htable.adb:357–385`;
`GNAT.HTable` delegates to it). A new public copy resets prior map contents.
**The Elist headers/elements are not freed by that reset**: they are allocated
in the separate `Elists`/`Elmts` tables (`elists.adb:108–128,152–169,355–371`).
Retain their cumulative charges across calls even when map-wrapper peak demand
is bounded by one call. The existing node/list/name/table envelopes and shared
unit serial checks apply to all these events.

### Image slice and pure-view duplication

Predefined `Integer'Image` does not take the Ada 2022 `Put_Image` route:
`Image_Should_Call_Put_Image` returns False for a predefined scalar without a
Put_Image aspect (`exp_put_image.adb:1247–1286`). Native expansion declares
`Snn : String (1..Integer'Width)` and `Pnn : Natural`, invokes the
`Image_Integer` procedure and rewrites the expression as `Snn(1..Pnn)`
(`exp_imgv.adb:1113–1116,1265–1437`). Slice resolution can capture the mutable
upper-bound identifier, leaving another scalar leaf; it does not turn this
expression into an unconstrained function call.

`Set_Slice_Subtype` creates one signed index itype and one array itype, both
associated with the slice, and copies its range into the index's semantic
range (`sem_res.adb:13145–13178`). For a resolved Image slice with ordinary
identifier prefix and leaf bounds, `t=5,l=0,a=1,r_1=3,s_1=0,e=2,q=1`.
The full `New_Copy_Tree` charge is therefore **9 ordinary nodes, 2 entities,
2 internal names, 1 syntax list, 1 Elist header, 2 Elist elements and 3 hash
wrappers**. No String or Uint value is copied. Copying a First/Last/Length
attribute with that slice as prefix adds its attribute node, giving ten
ordinary nodes when there is no explicit dimension-argument list.

For a nonvolatile, already-analyzed tree of ordinary identifiers/literals,
scalar arithmetic/comparisons/conditionals, bound attributes, conversions,
explicit dereferences and slices, `Side_Effect_Free` is compositional when
`Variable_Ref=False` (`exp_util.adb:14246–14678`). For scalar conditionals it
checks all three children. For slices it checks the range and prefix; for
dereferences it checks the pointer prefix. No expression action, function call,
or unsafe unchecked conversion is included in this class.

One additional guard is essential: exclude a non-entity expression whose
`Original_Node` names a mutable object renaming of an indexed component or
dereference. That special case is deliberately considered to have side effects
(`exp_util.adb:14479–14514`). The freshly expanded Image slice has an Image
attribute as its original node and passes this guard. Ordinary object-name
nodes return earlier and also pass it. References expanded from mutable
renamings need the separate capture analysis below.

On this pure-view class, `Remove_Side_Effects` returns before generating any
action (`12720–12725`), so `Duplicate_Subexpr` costs exactly the complete copy
transfer above. In particular, duplicating a simple analyzed Image slice has
the nine-node/two-entity charge, not a second Image procedure call or function
result allocation. This discharges a real concat operand family; the full
grammar-to-pure-view invariant remains a separate obligation.

### Mutable renaming dereference capture

For a nonvolatile explicit dereference that fails the special renaming guard,
`Remove_Side_Effects` takes its dedicated pointer-capture branch
(`exp_util.adb:12834–12850`). It creates one temporary pointer constant and
rewrites the expression to its dereference. Before delegated analysis, this
adds at most six ordinary nodes (including the relocated old prefix and saved
old root), one entity/name and one insertion-wrapper list. The root rewrite
has the same dereference kind, so it needs no growing slot event. The pointer
initializer is moved, not recursively copied.

The pointer declaration and final dereference have the following additional
closed case. Assume the old prefix is an already-analyzed ordinary identifier
of a generated, nonvolatile pointer object, with no renaming, `Current_Value`,
`Actual_Subtype` or `OK_To_Rename` flag. Its type is an existing named access
type to ordinary String, and its own type, base, first subtype and designated
subtype are frozen. The pointer is known non-null. The newly declared constant
is local, fresh and internal, with no aspects, address clause, delayed freeze,
foreign convention, static allocation or initialization compound statement.
The setting is native expansion in ordinary non-Ghost procedure/block code;
`Related_Id` is empty and no restrictive configuration reports a diagnostic.
These are shape premises, not assertions about every source renaming.

Under these premises, analyzing/expanding the pointer declaration and final
dereference adds **zero ordinary nodes, entities, lists, names, String values
or Uint values** beyond the direct capture charge:

- The type occurrence already has an entity. `Find_Direct_Name` sets its type
  and returns (`sem_ch8.adb:6246–6294`); `Process_Subtype` returns that existing
  entity without an itype (`sem_ch3.adb:22932–23010`). The fresh internal
  definition produces no xref entry (`lib-xref.adb:224–269`). `Enter_Name` links
  existing entities (`sem_util.adb:8077–8360`, `einfo-utils.adb:634–662`).
- `Relocate_Node` shallow-copies the initializer without clearing its analyzed
  flag (`atree.adb:2109–2135`). `Analyze` therefore returns immediately, and
  `Resolve` returns after dimension processing (`sem.adb:111–117`,
  `sem_res.adb:2547–2551`); absent dimension annotations add nothing. An access
  type is definite and nonlimited, so no actual-subtype, scalar-range or
  indefinite-object construction applies. Predicate/aspect/controlled/task
  branches are excluded by the declared shape.
- **Suppressed checks alone are insufficient to show this.**
  `Apply_Static_Length_Check` still calls `Selected_Length_Checks`
  (`checks.adb:3509–3541,3620–3627`). For this same-type pointer initializer,
  both designated subtypes and their index entities are identical.
  `Get_Actual_Subtype` returns the pointer type (`sem_util.adb:10270–10374`);
  the access case skips numeric length evaluation, and identical index types
  statically match before any length-condition construction
  (`checks.adb:10251–10412`, `sem_eval.adb:6702–6712`). Both the semantic and
  expander length-check calls therefore return empty results. Range checks
  return under suppression (`checks.adb:3063–3072`).
- The ordinary explicit-initialization expander path has no tag, validity-copy,
  unaligned-copy, anonymous-access, return-object or renaming transformation
  (`exp_ch3.adb:8395–8715,9485–9487`). A pointer identifier cannot satisfy
  `Is_Captured_Function_Call`; `OK_To_Rename_Ref` is false by the input premise.
  The new constant inherits known non-null status.
- The final dereference resolves its pointer name, sets the existing designated
  type, and needs no actual subtype (`sem_ch4.adb:2182–2326`,
  `sem_res.adb:9253–9380`). Its access check returns on known non-null before
  constructing anything (`checks.adb:8481–8509`). It has no checked storage
  pool or atomic type, so dereference expansion adds nothing
  (`exp_ch4.adb:5604–5618,13694–13762`).
- Freezing the newly introduced constant is included. Its type is already
  frozen; its object-declaration checks have no applicable aspect/address or
  categorization work, `Layout_Object` is explicitly a no-op, and no delayed
  freeze node is requested (`freeze.adb:4518–4716,6939–7024,8265–8286`,
  `layout.adb:225–229`). Debug-information marking only sets flags in existing
  entities (`freeze.adb:1405–1418`, `sem_util.adb:28572–28713`).

The rewritten expression is now a two-node dereference/name tree with external
types. Its following `New_Copy_Tree` has `t=2`, all other copy-summary parameters
zero. Thus one `Duplicate_Subexpr` on this case costs at most **8 ordinary
nodes, 1 entity/internal name and 1 syntax-list wrapper**, with no growing-slot,
pending-itype or numeric/string-value allocation. Its name adds at most thirteen
characters including NUL, subject to the shared serial bound. `Insert_Actions`
**placement/context processing remains additional**: this result closes the
generated declaration and final expression analysis, not arbitrary enclosing
conditional/transient-scope handling.

It introduces no new access type or runtime helper itself. It does not justify
assuming that a second duplication is free: the original mutable-renaming node
can survive the rewrite, causing the same guard to fire again. The result again
has the stated pointer-name shape after successful analysis, so repeated calls
can use this bound when the surrounding placement and frozen-type premises are
preserved. The grammar-to-shape proof must establish those premises.

## Native generated allocator expansion

The secondary-stack concat route sets `Associated_Storage_Pool` to
`RE_SS_Pool`, creates `new ConstrT` with a subtype identifier, and sets
`No_Initialization` (`exp_ch4.adb:3390–3402`). `ConstrT` is a constrained,
untagged, uncontrolled String subtype, and the access type is named. It is not
a qualified-expression allocator, coextension or special return object.

For this exact shape on Linux x86_64, `Expand_N_Allocator` selects
`RE_SS_Allocate` (`4637–4660`). It bypasses anonymous controlled collections,
the 32-bit-address size check, qualified-expression expansion and all default
initialization/task branches; the `No_Initialization` branch has no body unless
this is a special return object (`4897–4902`). With the selected configuration
and no restriction diagnostic, the expander itself adds **zero node, entity
or list allocations** beyond runtime lookup, and leaves allocation to the
backend.

Both `RE_SS_Pool` and `RE_SS_Allocate` map to `System.Secondary_Stack`
(`rtsfind.ads:3493–3498`). This path adds no Storage_Pools/Subpools helper seed.
Runtime lookup/loading and backend representations are additional. The
helper-seed conclusion was passed to the source-closure lane. The next two
transfers close the specific access-type and allocator semantic paths, with
their incoming frozen-subtype and placement premises stated separately.

### Generated named access type

Consider the direct `type Ayy is access ConstrT` declaration emitted at
3382–3387, in the current ordinary procedure/block scope. `ConstrT` is an
already-analyzed and frozen ordinary constrained String subtype; the declaration
has a fresh internal defining entity, no aspects, storage-size clause, partial
view, predicates, invariants, default-initial-condition or stream operations.
The selected configuration has no `Default_Storage_Pool` override.

Analyzing and expanding this declaration adds **one empty Elist header** and
no node/entity/name/String/Uint allocations beyond its already-counted syntax:

- `Find_Type_Name` takes its fresh-name branch (`sem_ch3.adb:18760–18772`).
  `Access_Type_Declaration` analyzes the prebound subtype identifier and
  returns it through `Process_Subtype`; it mutates the existing defining entity
  to `E_Access_Type`, with itself as its base, and sets its designated type.
  No anonymous designated subtype is needed (`1335–1500`).
- `Analyze_Full_Type_Declaration` allocates one empty
  `Direct_Primitive_Operations` Elist because `Etype(T)=T` (`3353–3360`).
  It sets `Has_Delayed_Freeze` but does not allocate a freeze node at this point:
  the preallocation branch requires `Base_Type(T)/=T` (`3422–3451`). The
  incomplete/private/derived and aspect branches do not apply.
- `Expand_N_Full_Type_Declaration` calls `Build_Master`, whose two allocating
  branches require task parts or a limited class-wide designated type. String
  has neither (`exp_ch3.adb:6844–6913`). The remaining component/derived-TSS
  work does not apply to this fresh access-to-object definition.

When this named access type is first frozen in the same scope, it adds at most
**one ordinary `N_Freeze_Entity` node and one syntax-list header**, with no
entity/name/Elist-element/String/Uint-pool allocation. `Freeze_Entity` sets its
size-known flag directly for an elementary type (`freeze.adb:800–814`), and
`Layout_Type` uses the 64-bit address size for access to a constrained String
(`layout.adb:244–366`). `Init_Size` and `Set_Elem_Alignment` use only directly
represented small Uint values here (`einfo-utils.adb:574–582`,
`layout.adb:939–1045`). The delayed freeze allocates its single node and lazily
creates the result list (`freeze.adb:8265–8286`, `nlists.adb:258–269`). Repeated
freezing returns the empty result (`freeze.adb:6536–6550`).

Analysis of that freeze node has no applicable tagged/record/predicate/aspect
case (`sem_ch13.adb:14450–14921`). Its expansion has no generated actions:
`Freeze_Type` has no storage-size clause to materialize a bounded pool; the
subpool branch cannot load a previously unloaded unit and cannot generate a
check for the non-class-wide secondary-stack pool. Generated access types
without private completion/indirect-temp status skip finalization collection
creation, and ordinary String independently has no finalization need
(`exp_ch3.adb:9849–10117`). `Freeze_Stream_Operations` immediately returns for
the generated type (`9762–9776`), and no invariant/DIC exists. Thus the freeze
node remains, with empty actions (`exp_ch13.adb:383–710`). Context placement
by `Insert_Actions` and any scope-stack storage are separate.

The emitter sets `Associated_Storage_Pool` **after** analyzing the access-type
declaration, so the preceding declaration argument matters: it performs no
early pool expansion. Even a preliminary access-type freeze has no default
pool lookup without a configuration override (`freeze.adb:7740–7766`). This
path introduces no Storage_Pools, Subpools, task or finalization runtime seed.

### Allocator semantic transfer

For `new ConstrT` with its exact same designated subtype as the now-frozen
named access type, `No_Initialization` and no subpool/qualified expression,
`Analyze_Allocator` adds exactly **one entity and one internal name**. It first
looks up the already-decorated `ConstrT` identifier, then creates one
`E_Allocator_Type` through `Create_Itype` (`sem_ch4.adb:613–644,728–733`).
`Create_Itype`/`New_Internal_Entity` allocate that entity/name, link it into the
existing scope chain and set its association; they allocate no syntax or
Elist headers (`itypes.adb:38–89`, `sem_util.adb:25661–25679`). There is no
missing-initialization, limited/tagged or task/protected branch for this String
subtype (`sem_ch4.adb:735–925`).

`Resolve_Allocator` changes the allocator expression's type from this temporary
allocator itype to the existing named base access type (`sem_res.adb:5476–5484`).
Its subtype mark is already frozen. The accessibility/coextension/task branches
are excluded by the exact generated shape (`5634–5898`). The general resolution
tail freezes only already-frozen types, and native allocator expansion has the
zero-allocation transfer above, apart from its runtime lookup. The orphaned
allocator itype/name still consumes retained table capacity; replacing the
expression's type does not reclaim it. Subsequent whole-scope processing is not
silently credited as reclaiming storage.

Combining **only these access-type and allocator semantic transfers**, the
secondary-storage path needs one extra ordinary node, one extra entity/name,
one syntax-list header and one empty Elist header, beyond the direct emitter
count. This does not include `ConstrT` construction/freezing, the allocator's
enclosing object/renaming declarations, action placement, runtime loading or
backend data. Do not treat it as the completed secondary-storage branch.

## Required transitive closure

At optimization level zero, two through nine retained operands use an available
`System.Concat_n.Str_Concat_n` helper; the actuals loop moves operands without
deeply copying them. Ten or more take the slice-assignment loop
(`exp_ch4.adb:3492–3624`). Fewer than two return the retained operand after
setup. The direct envelope overcounts helper and slice paths, so it does not
assume helper availability. Runtime loading and call analysis remain separate.

Storage has another independent branch. When the enclosing scope already uses
the secondary stack and `RE_SS_Pool` is available, GNAT generates a constrained
subtype, access type, allocator-backed object and renaming (`3355–3419`).
Otherwise it generates an ordinary constrained object (`3430–3433`). The author
grammar's exclusion of access types does not exclude generated access types.
The input initializer's unconstrained result can affect secondary-stack state. The
secondary path additionally invokes `Freeze_Itype` and runtime lookup.

`Duplicate_Subexpr` calls `Remove_Side_Effects` then `New_Copy_Tree`
(`exp_util.adb:5323–5332`). `Name_Req => True` does not make it constant-cost:
native side-effect removal can generate an access type, reference and object
declaration for an unconstrained function result (`12984–13121`). GNATprove
explicitly uses a different path. This general branch is excluded for the
resolved Image slice above, but further input/alias shape closure is required
before excluding it for all generated concat operands.

General `New_Copy_Tree` can clone associated itypes and entities in expression
actions, then copy their semantic fields, array indices, scalar ranges, entity
lists and names (`sem_util.adb:24136–25624`). Its internal maps/pending-itype
lists are additional representations. A syntactic-descendant count alone does
not discharge it. The leaf-copy result avoids these cases by input shape.

`Insert_Action` allocates its immediate one-element list and delegates to
`Insert_Actions` (`exp_util.adb:7984–8012`). The latter can attach actions to
conditional contexts, preserve transient scopes and analyze inserted actions.
Suppressing checks does not suppress this analysis. The emitter calls it once
with at most `2*n` collected declarations, and calls `Insert_Action` at most
`n+5` times. Generated declaration/access/allocator/call/slice/conditional and
freezing transfers must cover those calls. Final `Analyze_And_Resolve` and the
error path are additional entries.

## Exact remaining obligations

The following missing addends prevent calling the native construct closed:

- Bound incoming String subtype/operand shapes and values. Earlier semantic
  `Eval_Concatenation`/`Fold_Str` work needs its own String/Uint/node/entity costs.
- Derive the decoration summaries for `4*n+4` remaining direct copies and
  `2*n+2` duplications. The transfer and pure-view/Image cases above supply
  their costs when the class invariant holds. Close mutable-renaming capture
  declaration/reanalysis and any operands outside that invariant.
- Close `2*n` collected declarations, `n+5` individual insertion calls, one
  explicit `Freeze_Itype`, up to two runtime-availability and two runtime-entity
  lookups, final analysis, value/comparison helpers and conditional error path.
  Dependency sharing requires a cache invariant.
- Bound generated/reanalysis multiplicity before replacing expanded-tree `a`
  with the source `&` count.
- Cover caller arithmetic: `List_Length`, `NN`, and the final `J := J+1`
  increment must fit `Nat`, requiring `n+1` to fit. Seven local arrays have
  bounds `1..n` or `0..n` (`exp_ch4.adb:2598–2621`); lengths and representation
  byte products need checks. Lower-bound recursion has depth at most `n`;
  physical stack exhaustion is separate.
- Add backend/object/linker and fixed-dependency costs. There is no direct
  Stringt write in this emitter or the closed primitive subset; that does not
  establish zero String demand for its open callees.

Current source/operator/String limits remain unchanged. This component does
not complete #119 or unlock dependent admission changes.
