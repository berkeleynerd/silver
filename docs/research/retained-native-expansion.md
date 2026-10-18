# Native String concatenation allocation component

2026-10-17, #119. This component closes the **direct native concatenation
emitter's** control-flow and primitive allocation accounting. It does **not**
close the construct's semantic and generated-action callees, and supplies no
whole-program capacity predicate or new admission limit. Counting generated
syntax alone misses allocations made while GNAT analyzes that syntax.

The source is GCC Ada commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The
[retained evidence](../evidence/unbounded-programs/retained-native-expansion-20261017/local-envelope.json)
records fifty-one inspected files hash-checked against the complete source
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

## Scalar bound capture and slice subtype transfer

The following closes two more **specified helper transfers**. It does not
silently include the rest of `Resolve_Slice` or the action-placement callback.

### Capturing an analyzed scalar variable

For `Force_Evaluation` of an already-analyzed ordinary scalar identifier,
assume it denotes a nonvolatile local Integer-family variable, has no renaming,
`Current_Value`, `Actual_Subtype` or `OK_To_Rename`, has no pending
`Do_Range_Check`, and its type/base/first subtype are already frozen. The new
object has the same local, fresh, internal, non-Ghost/no-aspect/no-delayed-freeze
properties specified for the pointer capture above; `Related_Id` is empty.
This is the shape of the mutable bound capture to be established at its caller,
not a claim that every arbitrary scalar expression has this cost.

`Force_Evaluation` sets `Variable_Ref => True`
(`exp_util.adb:7221–7245`). `Side_Effect_Free` rejects the variable name
(`14465–14468`), and the elementary branch builds a constant of the existing
type (`12749–12828`). Including relocation and a possible saved original in
`Rewrite`, the transfer is at most **five ordinary nodes, one entity/internal
name and one insertion-wrapper list**. There is no growing-slot event: an
identifier is rewritten to another identifier. The name requires at most 13
characters including NUL under the shared serial-bound premise.

Analysis of that declaration and final reference adds no further node, entity,
list, name, String or Uint allocations, for these reasons in addition to the
common object-declaration/freezing trace above:

- The analyzed initializer survives relocation. `Analyze` and `Resolve`
  return without re-expanding it. `Assignment_OK` bypasses initialization
  checking, and `Apply_Scalar_Range_Check` returns under the local suppression
  before range arithmetic because no `Do_Range_Check` is pending
  (`sem_ch3.adb:4750–4760,4848–4849`, `checks.adb:3238–3274`).
- If the source variable is known valid, the optional `In_Subrange_Of` call
  compares its exact same type and returns at the identity guard
  (`sem_ch3.adb:4823–4831`, `sem_eval.adb:5336–5337`). The inherited
  `Actual_Subtype` is that same existing type. Scalar types do not enter the
  array/access branch of `Selected_Length_Checks`
  (`checks.adb:10251–10272`).
- Explicit-initialization expansion's constraint check is likewise suppressed.
  The identifier has no renaming flag, function result or unaligned view, and
  a scalar has no tag, finalization or special-return machinery
  (`exp_ch3.adb:8395–8715`). The new constant has no `Current_Value`;
  `Expand_Entity_Reference` therefore introduces no replacement
  (`exp_ch2.adb:482–522`).

A **second** forced evaluation of this result costs zero. Its current root is
an identifier of an `E_Constant`, so `Side_Effect_Free` returns true in the
entity-name branch before examining `Original_Node`
(`exp_util.adb:14447–14475`). This differs from the dereference case above,
where a mutable original renaming can remain relevant. Consequently the
`Resolve_Slice` force followed by `Set_Slice_Subtype`'s second force does not
recapture an already-captured scalar bound. More general scalar expression
capture/reanalysis still needs its corresponding shape transfer.

### Building the subtype of an ordinary String slice

Consider `Set_Slice_Subtype` with an already-resolved, nonpacked one-dimensional
String slice whose discrete range is `N_Range`. After any separately charged
bound captures, assume each bound is side-effect-free under `Variable_Ref`,
its scalar types/entities are external to the copied range, and the range
has no owned actions/entities/itypes or syntax lists. Let **t** be the number
of ordinary nodes in that range including both bound expressions. For the
literal/name leaf case, `t = 3`. This scalar-tree premise permits already
resolved scalar operators over immutable references; it does not require
every bound to be a leaf.

The helper adds **t + 2 ordinary nodes, two entities/internal names and two
syntax-list headers**, with no growing-slot event, Elist/hash entry or String
value. The transfer follows the whole body (`sem_res.adb:13100–13199`):

1. It creates one index-list header, one signed index itype, and a
   `New_Copy_Tree` of the range. The decorated-copy transfer above reduces to
   exactly `t` ordinary nodes here because there is no owned semantic type or
   list. `Set_Size_Info`/`Set_RM_Size` reuse the existing scalar values.
2. It creates one String array-subtype itype and one occurrence of the index
   itype, appending that occurrence to the existing list. Both entity names
   use the internal serial scheme, so together require at most 26 characters
   including their NULs.
3. Native `Ensure_Defined` adds one `N_Itype_Reference` and its immediate
   insertion-wrapper list (`exp_util.adb:5400–5413`). Its semantic analyzer is
   explicitly empty (`sem_ch3.adb:3718–3722`); the native expander selects its
   `when others => null` arm (`expander.adb:519–522`). **It does not call
   `Freeze_Itype`**. Later freezing and backend elaboration must be charged
   where they actually occur. `Insert_Actions` context/transient handling
   remains a separate callback.

`Check_Compile_Time_Size` adds at most **four retained Uint entries** on this
path (`freeze.adb:800–915`). Standard Character's component size is 8. When both
bounds are compile-time-known, it computes `High - Low + 1`, then, for a
positive length, multiplies by 8. The subtraction allocates at most two
entries; addition and multiplication at most one each. With bound magnitudes
at most **H**, every newly retained value has magnitude at most
`8*(2*H+1)`. A stored result needs at most the base-32768 digit count of that
value. `Expr_Value` for these scalar literals/constant-name chains returns
existing Uints and only writes its fixed cache (`sem_eval.adb:4589–4689`).
When either bound's value is unknown, the nonattribute scalar `Value_Known`
walk performs no arithmetic and this size calculation allocates no Uint.

`UI_Mul` has two operand vectors and one product vector, with total transient
length `2*(left_digits+right_digits)`; the product conversion adds at most one
retained Uint and its significant digits (`uintp.adb:2020–2071,2361–2433`).
Thus multiplication by 8 needs at most `2*(k+1)` transient digit words when
the other operand has at most k digits. This is a peak working-storage charge,
separate from the retained four-entry envelope and the addition/subtraction
peaks already recorded. No narrowing to host `Int` occurs for the mathematical
bound value in this path.

This transfer excludes the input slice syntax, earlier resolution and range
checks, incoming bound-expression analysis, separate scalar captures, action
placement, later type freezing and backend costs. For the three-node
post-capture range, its ordinary allocation is **five**, not a recursive
re-expansion of the original Image or concat operand.

### Freezing the slice's String/index subtype pair

The generated pair from `Set_Slice_Subtype` also has a closed freezing case.
Assume the ordinary local scope remains current; Standard String, Character
and Integer and any preexisting ancestor subtype are frozen; the generated
types carry no representation/aspect/predicate/remote/controlled/task flags;
and their scalar bounds retain the preceding resolved scalar-tree shape.
The index has the existing Integer size fields (32 bits), while the array
subtype's `Esize` remains unknown, as initialized by `Create_Itype`. Both types
are artificial rather than `Comes_From_Source`. These premises describe the
pair just built, before unrelated whole-scope or backend processing modifies
its layout or freezing state.

`Freeze_Entity` for this pair adds **no node, entity, list, name, String or Uint
allocation** unless a caller has explicitly requested delayed freezing. For
each previously unfrozen member with `Has_Delayed_Freeze`, add at most **one
ordinary freeze node and one list header**. The analysis/expansion of those
freeze nodes adds nothing in this class. An explicit `Freeze_Itype` of the
fresh array subtype therefore costs at most **one node and one list**, before
its separately charged `Insert_Actions` placement. The untouched pair has no
delayed-freeze flag: `Create_Itype` and `Set_Slice_Subtype` do not set it
(`itypes.adb:38–89`, `sem_res.adb:13100–13199`). Repeated freezing returns at the
`Is_Frozen` guard (`freeze.adb:6537–6552`).

The complete selected routes support that claim:

- The base/ancestor, component and index freeze calls reach already-frozen
  standard types or the one generated index. `Freeze_And_Append` allocates no
  wrapper list when its callee returns `No_List`
  (`freeze.adb:2804–2826,7226–7260,3656–3670`). Subtype aspect inheritance finds
  no new aspect; the scalar/index and array branches avoid derivation,
  private, tagged, record, access and concurrency handling. Generated types
  return before `Check_No_Parts_Violations` can allocate its hierarchy Elists
  (`3312–3314`). The non-Ghost guard excludes Ghost-type checking
  (`ghost.adb:1403–1405`).
- `Freeze_Array_Type` skips its base-type processing, copies Standard String's
  alignment if needed, and returns from `Adjust_Esize_Alignment` because the
  array `Esize` is unknown (`freeze.adb:4093–4102`, `layout.adb:77–79`). It
  never enters the packed-array path. `Set_Component_Alignment_If_Not_Set`
  returns for a subtype (`freeze.adb:10968–10970`).
- The earlier size check has already marked a compile-time-sized array known,
  so another `Check_Compile_Time_Size` returns immediately. An array with an
  unknown bound still executes no size arithmetic. Scalar size checking is
  immediate. `Check_Unsigned_Type` reads existing bound values and flags;
  `Expr_Rep_Value` for the specified scalar leaves/constant-name chains does
  not allocate (`freeze.adb:2418–2488`, `sem_eval.adb:4505–4531`).
- Scalar `Layout_Type` reuses the copied size fields. `Set_Elem_Alignment`
  computes the small direct value 4 from 32/8, without a retained Uint. Array
  layout has no packed/full-access/representation work, and its discriminant
  dependence walk only examines bound kinds and sets a flag
  (`layout.adb:180–220,359–418,426–670,939–1052`). Unknown array `Esize` prevents
  final size/alignment adjustment. If a caller supplies a different subtype
  with an as-yet-uncomputed size, the earlier four-Uint size transfer applies
  instead; do not reuse the zero charge without its prior-size-check premise.
- Delayed freezing alone creates the freeze node and lazily creates its list
  (`freeze.adb:8265–8286,2974–2977`). `Freeze_Entity_Checks` has no applicable
  tagged/record/predicate/aspect case (`sem_ch13.adb:14450–14921`). In the same
  current scope, `Expand_N_Freeze_Entity` performs no scope-stack insertion.
  Its array dispatch calls `Expand_Freeze_Array_Type`, which explicitly skips
  an initialization procedure for Standard String and has no controlled
  component (`exp_ch13.adb:535–599`, `exp_ch3.adb:5703–5785`).
  `Freeze_Stream_Operations` returns for artificial types; the itype path
  bypasses invariant/DIC body generation (`exp_ch3.adb:9775–9776,10155–10156`).
  No freeze actions or runtime lookups result. Scalar signed-subtype freeze
  similarly has no enumerated-image or other special expander action.

The class excludes previously modified size fields, foreign/aspect-bearing
subtypes, out-of-scope freeze-node analysis and later backend elaboration.
This closes the subtype pair's own freezing cost; it does not close the
construction of an explicit object-derived String subtype declaration.

### Explicit subtype index layout

The explicit constrained String subtype takes a different route from
`Set_Slice_Subtype`: `Constrain_Index` creates one signed scalar itype,
shares the existing range, and calls `Set_Discrete_RM_Size`
(`sem_ch3.adb:15316–15492`). When `Related_Id` is present its name is derived
from that entity; the earlier thirteen-character internal-name bound therefore
does **not** apply. The range-analysis and name-production costs are separate
from the following closed layout transfer.

For an ordinary, unpredicated signed Integer subtype, suppose its finite
ancestor chain reaches the frozen Standard Integer base, and every bound that
`Minimum_Size` selects is an existing integer literal or finite constant-name
chain with value in **-2^31 .. 2^31-1**. There is no biased representation.
`Set_Discrete_RM_Size` adds at most **95 retained Uint entries and 285 digit
words**, no ordinary/entity nodes, syntax/Elists, names or String values.
At most 95 `UI_Ints` cache insertions is a sufficient additional envelope;
the actual path inserts fewer. These are per-call append bounds, valid without
assuming a warm cache.

The static-matching shortcut compares existing bounds without arithmetic:
`Predicates_Match` returns immediately for the unpredicated types;
`Subtypes_Statically_Match` checks flags and the two `Expr_Value` equalities
(`sem_eval.adb:6314–6351,6702–6835`). Otherwise `Minimum_Size` follows the
ancestor chain to existing compile-time-known bounds and uses
`Expr_Rep_Value`, which follows constant references without allocating
(`sem_ch13.adb:16076–16209`, `sem_eval.adb:4505–4531`). Its discrete null-range
case returns zero. The signed case performs at most **32 loop tests**, each
with at most two negations of B, and requests powers no larger than **2^31**.
The unsigned case requests the same largest power and performs no negations
(`sem_ch13.adb:16229–16303`). `UI_Expon(2,S)` with S <= 31 takes the cached
power-of-two route, extending at most 31 entries by one multiplication each
(`uintp.adb:1361–1405`). Each multiplication or negation appends at most one
Uint, hence `31 + 2*32 = 95`. Every result has magnitude at most 2^31 and uses
at most three base-32768 digits. The returned size lies in 0..32, so its final
`UI_From_Int` allocates nothing (`layout.adb:900–933`).

The largest local Uint working vector total is **eight digit words**: a
power-extension multiplication uses at most three left, one right and four
product words. A negation or `UI_From_Int` conversion uses at most three;
comparison uses at most six. Cache extensions update `Uints_Min` and
`Udigits_Min`, potentially retaining an older prefix of the pools. A
whole-phase bound based on cumulative append counts remains safe; a live-only
bound cannot assume those older values are released. Ancestor/constant-chain
traversal depth and cache-wrapper representation need their own stack/byte
charges. This transfer does not justify its 32-bit bound premise for an
arbitrary generated expression.

### Range-check trees are constructed before suppression

`Process_Range_Expr_In_Decl` resolves the range, captures both scalar bounds,
and then calls `Get_Range_Checks` without testing check suppression
(`sem_ch3.adb:22588–22734`). `Get_Range_Checks` delegates to
`Selected_Range_Checks`. Only the later `Insert_Range_Checks` tests
`Checks_On` and returns when checks are suppressed
(`checks.adb:8044–8054,8118–8141`). **Suppression can discard an allocated
tree; it does not avoid its allocation.** The secondary-stack concat subtype
uses this suppressed route. The plain object route deliberately keeps checks
enabled and additionally analyzes any inserted check.

The dynamic `N_Range` builder has a useful structural transfer. Assume no
discriminants/access/fixed-lower-bound case, no compile-time range error, and
already-analyzed side-effect-free scalar bound trees with **b** total ordinary
nodes and **l** syntax-list headers, no owned itypes/entities or expression
actions. For example, a scalar conditional owns its Expressions list but
no declaration or action list. Exclude any
side-effect-removal capture by the incoming purity premise. The builder adds
at most **2*b + 28 ordinary nodes and 2*l syntax-list headers**, with no entity,
name, growing-slot, String or Uint allocation of its own:

- It duplicates each bound twice: `2*b` nodes and `2*l` syntax lists by the
  no-owned-decoration case of the preceding tree-copy transfer.
  `Remove_Checks` only walks the
  copies and clears flags (`checks.adb:9822–9887`).
- Six `Convert_To` calls each allocate at most a shallow relocation,
  conversion and type occurrence: eighteen nodes. Unlike the concat emitter's
  specialized `To_Ityp`, `Convert_To` does not return the original node just
  because the type already matches (`tbuild.adb:104–121`).
- Two target-bound attributes each add an attribute and a type occurrence:
  four nodes. Less-than, greater-than, `or else`, greater-or-equal, `and then`
  and the conditional raise add six more
  (`checks.adb:10603–10682,11117–11134,11423–11436`).

This is the check-tree constructor transfer, **not** a bound for the entire
`Get_Range_Checks` call. Before construction, `Not_Null_Range` can call
`Compile_Time_Compare`, whose numeric work is additional. Its range analysis
follows internal constant initializers **before** consulting its cache
(`checks.adb:5142–5163`); captured names are therefore not a constant-cost
numeric-analysis boundary. Likewise, prior range resolution/capture,
compile-time-error handling, enabled-check analysis and placement remain
separate. For two known in-range literal/constant-chain bounds the selected
check path performs value comparisons and constructs no tree.

### Scalar range-analysis and comparison transfer

The numeric callback can be closed for a specified finite scalar graph. This
is a semantic input-shape transfer, not yet the missing derivation of that
graph from an arbitrary admitted source program. Its expressions have signed
Integer-family types, literals/names, unary plus/minus, binary `+`, `-`, `*`,
discrete conversions, scalar conditional expressions, and ordinary String
`First`, `Last` and `Length` attributes. There are no modular, real, generic,
discriminant, representation, descriptor, Interfaces-array or expression-action
cases. Every compile-time-known expression, including a queried scalar-type
bound, reduces to an existing literal or finite constant-name chain. Unknown subtype bounds
have the usual existing Standard Integer fallback. Current-value conditions
are well-typed scalar comparisons, so the Boolean-variable special case in
`Get_Current_Value_Condition` cannot apply to the Integer entity queried here.

Expand the following edges into trees, counting shared targets each time:
ordinary scalar operand edges; an internal constant's initializer (or full
view initializer); the index low/high bounds reached by String `Length`;
and the bound substituted for a constrained array `First`/`Last`. For a
String-literal `Last`, count the existing low-bound/length inputs and the
virtual literal that `Compare_Fixup` constructs. Require this graph to be
acyclic. Include the original comparison operands and all four scalar-type
bounds used by its recursive comparisons as roots. Let **A >= 1** bound the
node count of each fully unfolded rooted tree. This definition deliberately
counts initializer sharing repeatedly; the helper's fixed cache need not hit.

One `Determine_Range` query adds at most **6*A Uint entries**, no ordinary
nodes, entities, lists, names or String values. A sharper additive recurrence
charges only the following local weights plus the recursively reached child
weights (`checks.adb:4620–4913,5071–5654,6112–6127`):

| Node processed after the cache/known-value checks | Local Uint append bound |
| --- | ---: |
| Unary plus, discrete conversion, internal-constant forwarding | 0 |
| Unary minus | 2 |
| Binary addition | 2 |
| Binary subtraction | 4 |
| Binary multiplication | 6 |
| Ordinary String Length | 6 |
| Literal, ordinary name, conditional, First/Last, other unrefined leaf | 0 |

Multiplication needs **six**, not four: after four endpoint products,
`Release_And_Save(M,Lo,Hi)` may append both selected values again
(`uintp.adb:719–760`). Those two saved digit vectors have total length at most
2*k when k bounds the product digits. Length computes at most two
`High-Low+1` expressions; its minimum/maximum selections share existing
Uints. The selected String types avoid `Half_Address_Space`. A conditional
expression is not recursively range-refined by this implementation; it uses
the type bounds. Traversal before the cache, static value queries and cache
updates allocate no syntax or numeric values under the stated shape.

One complete `Compile_Time_Compare` query then has the sufficient envelope

```text
ordinary nodes <= 20*A
Uint appends   <= 80*A + 60
Uint digits   <= k*(80*A + 60).
```

Its explicit recursive comparison depth is at most two: the initial call
makes at most four calls with `Rec => True`, and those do not recurse again
(`sem_eval.adb:1585–1642`). Across those five calls there are at most ten
`Determine_Range` queries, contributing `60*A`. Each comparison calls
`Is_Same_Value` at most twice. Each such recursive pair walk has at most A
visits and calls `Compare_Fixup` for both inputs; each fixup adds at most one
ordinary literal and one Uint addition for a String-literal `Last`
(`sem_eval.adb:995–1067,1078–1218`). This contributes `20*A` to both counts.
All other numeric operations contribute at most twelve per comparison call:
two decomposition negations, up to two entries each for a known-value
difference, offset difference and singleton-range difference, and up to four
for adjusting/comparing a current-value condition. Mutually exclusive return
paths are intentionally overcounted (`1321–1759`). No entity, syntax/Elists,
name, String or growing-slot event is introduced. The auxiliary generic,
constraint-error and current-condition searches only read the specified trees
(`sem_util.adb:2409–2542,27826–27864`, `exp_util.adb:7317–7750`).

The numeric magnitude must cover intermediate range estimates, not only
valid runtime results. It can be propagated over the same unfolded trees:
start with **H >= 2** covering all existing literal/type-bound/length and
current-condition magnitudes; use `max(H,B1+B2)` for add/subtract,
`max(H,B1*B2)` for multiplication, `max(H,B)` for unary/conversion,
`max(H,2*max(B1,B2)+1)` for Length, and `2*H` for a literal-Last fixup.
Unrefined nodes use H. Internal constants use their initializer's bound.
Let B bound every resulting node value and intermediate; **2*B+1** also
covers the comparison's differences and unit adjustments. The corresponding
base-32768 digit count supplies k above. This is conservative even where
range refinement returns an estimate disjoint from the base type rather than
clipping it back to Integer (`checks.adb:5582–5605`).

The maximum local arithmetic-vector demand is at most **5*k+3 digit words**:
addition's earlier bound covers the multiplication peak of 4*k and the
saved-product peak of 2*k. Recursive expression traversal has its own stack
depth. At most one `UI_Ints` cache insertion per charged Uint append is a
sufficient cache-wrapper envelope. Neither cache reuse nor Uint release is
needed for these cumulative-append bounds. No compiler query is proposed as
the membership predicate: a whole-source derivation must still establish A,
the magnitude summary, acyclicity and the number of comparison invocations.

For the preceding `Get_Range_Checks` shape, `Not_Null_Range` invokes this
comparison at most once. Its other value and conditional-branch tests only
compare existing values. Thus the complete no-static-error selection adds at
most **2*b+28+20*A ordinary nodes, 2*l syntax lists and 80*A+60 Uint appends**,
with the earlier purity/no-owned-decoration premises. If both bounds are known,
the direct value-comparison route still allocates nothing. Enabled insertion
and analysis of the resulting check remain separate from selection.

### Constrained subtype declaration with resolved pure bounds

There is now a closed declaration transfer for the native suppressed-check
case with **already-analyzed**, nonoverloaded scalar bounds satisfying the
preceding pure-tree, finite-analysis-graph and 32-bit index-layout premises.
The declaration is a fresh artificial local subtype of Standard String with
one explicit range, no aspects/predicates/representation flags, no enclosing
generic or spec expression, and no diagnostic. Standard String/Integer and
all scalar types referenced by the bounds are frozen. It is not the root of
a transient wrap. Checks are suppressed for the
whole analysis. Its existing defining identifier and input syntax have
already been charged.

With b the total ordinary bound-tree nodes, l their syntax-list count,
A the analysis-graph bound, and
L the subtype identifier's character length, semantic analysis/expansion adds
at most:

```text
ordinary nodes       2*b + 32 + 20*A
entities             1
new name entries     1
name characters      L + 4, including NUL
Uint appends         80*A + 155
growing-slot events  2
syntax lists         2*l
Elists               0
String values        0.
```

The counts combine the closed check selection, the 95-entry index layout,
and at most two static-bound folds. They overcount paths that do not coexist.
Use the scalar-analysis digit bound enlarged to at least three digits for
the index-layout addend. The direct dynamic-slot charge is therefore at most
`9*(2*b+34+20*A) + 61`, before table-link and original-node costs.

`Process_Subtype` reuses the explicit defining identifier, dispatches to
`Constrain_Array`, and creates only the one scalar index itype
(`sem_ch3.adb:23010–23020,23117–23118,14339–14484,15316–15492`). The existing
constraint list becomes `First_Index`; the scalar range is shared rather
than copied. The index's `Create_Itype` calls `New_External_Entity` with
prefix `T`, suffix `P`, index 1, producing the subtype name plus three
characters. `Name_Find` adds at most one entry and its characters plus NUL
(`itypes.adb:38–89`, `sem_util.adb:25630–25655`,
`tbuild.adb:632–666`, `namet.adb:1185–1274`). No unit serial is incremented by
this derived-name operation.

`Analyze_Range` first sets `Any_Type`; its two nonoverloaded operands give
one `Add_One_Interp`, which stores the type directly without an overload-table
entry (`sem_ch4.adb:4818–4932`, `sem_type.adb:441–458`). Writable-actual
analysis returns for the artificial range. `Resolve_Range` returns immediately
from each already-analyzed bound's `Resolve`, then performs only existing-value
base-range checks and at most two `Fold_Uint` calls. A signed-Integer fold
allocates one literal plus at most one saved old-node copy, with at most one
growing-slot event. Its literal analysis and resolution only set fields or
compare existing bounds; no new Uint is evaluated
(`sem_res.adb:2547–2551,11161–11302`, `sem_eval.adb:478–658,2772–2834,
5150–5222,7354–7504`, `sem_ch2.adb:111–132`). Generated ranges bypass the
source-only null-range-warning comparison. The retained validity setting
disables `Validity_Check_Range` (`checks.adb:11491–11508`), and purity under
`Variable_Ref => True` makes both `Force_Evaluation` calls no-ops.

The remainder of `Analyze_Subtype_Declaration` copies standard attributes,
shares the primitive-operation list, and performs no further range check:
its array-index check requires an identifier or subtype-indication index,
whereas this index remains `N_Range` (`sem_ch3.adb:6190–6440`).
`Conditional_Delay` only updates a flag and the standard base is already
frozen (`sem_util.adb:6326–6331`). No aspects or dimensions are present.
The dynamic-size restriction check only updates fixed restriction records;
the registered local-restriction hook returns for this restriction
(`restrict.adb:380–565`, `local_restrict.adb:127–148`). Native subtype
expansion selects the no-op case, with transient wrapping excluded by premise
(`expander.adb:519–557`).

For the secondary-stack concat subtype, L <= 12 gives at most **16 name
characters** for its additional index itype. The plain result object's
`Find_Type_Of_Object` first constructs an explicit subtype from its inline
indication: **two ordinary nodes, one entity, one insertion-wrapper list and
one derived name** (`sem_ch3.adb:19080–19198`). If the object name has length
O, that subtype's name has O+2 characters; its name-pool charge is O+3.
Its index name later adds O+6 including NUL. With O <= 12 these two derived
names need at most **33 characters**. Find_Type's placement callback and
subtype analysis are additional; the frozen Standard String base adds no
freezing syntax. The plain path enables range checks, so the suppressed
declaration transfer cannot cover its subsequent check analysis.

Actual concat-generated high-bound arithmetic and conditional expressions
may enter this declaration **unanalyzed**. Their earlier Analyze/Resolve,
capturing, conditional expansion and any transient context must still be
closed before this transfer can stand for the actual full declaration. It
does not silently price arbitrary scalar-expression analysis as zero.

### Placement of ordinary for-range captures

The scalar capture's declaration is placed before its ordinary for loop,
including a loop nested in another loop or an if body. This statement is
conditional on the ordinary scalar range parent chain, no spec expression,
and no transient scope. The capture uses `Expression => Relocate_Node(Exp)`
and `Insert_Action(Exp,E)` (`exp_util.adb:12765–12824`). `Insert_Actions`
climbs from the bound through the range and loop parameter specification.
The iteration-scheme special case requires `Present(Condition(P))` and
`N = Condition(P)`; an ordinary for range does not meet it
(`8289–8314`). The loop is a statement-list member, so the helper reaches
`Insert_List_Before_And_Analyze(P,Ins_Actions)` (`8318–8462`).

An `Expression_With_Actions` wrapper is created by the distinct already-
analyzed short-circuit-right-operand branch (`8159–8182`), which is absent
from this parent path. The loop's enclosing if statement is not traversed:
the search stops at the loop. The declaration initializer therefore occupies
one executable list location. Proof-domain translation multiplicity and the
proof-mode exclusion of transient scopes/itype-reference replay remain the
producer component's separate obligations.

### Generated Integer addition and subtraction

One generated binary `+` or `-` has a small closed local semantic transfer
when its operands have already been analyzed/resolved to the same frozen
Standard Integer base, are nonoverloaded, and any constant-folded intermediate
fits Integer. There are no operand errors, pending overflow flags, dimensions,
modular/real/user-defined operators, transient wrapping, or applicable unset-
reference diagnostics. The generated node uses the normal `Make_Op_Add` or
`Make_Op_Subtract` constructor; all checks are suppressed throughout its
analysis/resolution. Input syntax and child transfers have been charged.

Its additional cost is at most **two ordinary nodes, one growing-slot event
and two Uint appends**, with no entity, overload-table entry, list, name or
String allocation. Uint magnitudes are bounded by the maximum of the existing
operand magnitudes and their sum; use the preceding addition/subtraction
digit and local-vector transfers. A nonfolded, nonzero-identity operation
adds nothing under these premises.

`Make_Op_*` already sets the Standard operator entity, so
`Analyze_Arithmetic_Op` selects one operand-type pair without searching
visible homonyms (`gen_il-gen.adb:2659–2693`, `sem_ch4.adb:931–989,
6691–6793,7143–7202`). Its one interpretation is stored in the node;
`Operator_Check` has no abstract/error route. Resolution selects the Integer
base and reuses its operands. Artificial Standard operators create no xref
entry (`sem_res.adb:6149–6324`, `lib-xref.adb:275–317`). Staticness and
nonstatic-context checks either return or compare existing values
(`sem_eval.adb:7166–7351,478–658`). Folding performs one add or subtraction,
then `Fold_Uint`: one literal plus at most one saved original-node copy and
one growing-slot event (`sem_eval.adb:1985–2109,5150–5222`). It introduces no
secondary type or name. The no-overflow premise excludes the diagnostic
branch even though runtime checks are suppressed.

With a surviving arithmetic node, suppression prevents
`Enable_Overflow_Check` (`sem_res.adb:6323–6326`). Native expansion's strict
overflow helper returns for the clear flag; validity-operand checking is
disabled. The only applicable optimization is `X+0`, `0+X` or `X-0`, which
rewrites to the existing operand and costs at most one saved original and one
growing event. Integer excludes universal narrowing, fixed/real and modular
expansion (`exp_ch4.adb:7918–7976,10678–10728`,
`checks.adb:756–814`). Frozen types and ordinary context exclude freeze or
transient additions in the common Resolve epilogue.

The direct concat emitter creates at most **4*n+2** such operator nodes:
`n-1` aggregate additions, two high-bound operations, and three slice-endpoint
operations per operand, plus one last-operand high-bound subtraction for a
final null literal (`exp_ch4.adb:2884–2888,3078–3099,3246–3252,3553–3563`).
For one
initial analysis of those nodes **when all the local premises hold**, their
extra envelope is therefore `8*n+4` ordinary nodes, `4*n+2` growing events
and `8*n+4` Uint appends. The aggregate and slice insertions suppress checks;
the plain-storage high-bound analysis keeps checks enabled and needs its
separate route. Copied/reanalyzed operators and first analysis of attribute,
conditional or other leaf operands are additional. This count is not a claim
that every generated operator is analyzed exactly once in the compilation.

### Generated scalar conditional expressions

One artificial three-expression `if` has an additional envelope of **two
ordinary nodes and one growing-slot event**, and zero Uint, String, entity,
name, overload-table or list allocations, under these premises:

- The condition has already been analyzed/resolved as Standard Boolean; both
  branches have already been analyzed/resolved as the same frozen Standard
  Integer base used for the conditional's context. Input syntax, including
  the three-element Expressions list, and child transfers are charged earlier.
- No branch has attached Then/Else actions, delayed expansion, errors,
  dimensions, unset-reference diagnostic or pending check. No enclosing
  conversion, return, aggregate, transient or spec-expression context changes
  this shape. All checks are suppressed and overflow mode is strict.
- The retained default `Validity_Check_Tests = False` and
  `Suppress_Control_Flow_Optimizations = False` apply; Standard Boolean has no
  hardbool representation. Native rewriting callbacks add no allocation.
  Known condition values and static branch values are existing literals or
  constant chains, not new scalar evaluations.

`Analyze_If_Expression` analyzes/resolves the condition and analyzes both
branches. The children's Analyzed guards return. With compatible,
nonoverloaded branch types it stores just one interpretation in the node;
no interpretation-table entry is needed (`sem_ch4.adb:2528–2720`,
`sem.adb:104–116`, `sem_res.adb:2545–2551`). `Resolve_If_Expression` resolves
the same children, but its Apply_Check returns because their types equal the
context. Excluding an enclosing conversion avoids the distinct generated
conversion route in `Resolve_Dependent_Expression`
(`sem_res.adb:7866–7893,9521–9689`).

When all three operands are static, `Eval_If_Expression` rewrites to a shallow
relocation of the selected branch (`sem_eval.adb:2534–2614`): one relocation,
at most one saved original, and at most one growing event. Subsequent native
dispatch sees the replacement node, so this does not also incur the if
expander's fold. For a surviving conditional, `Adjust_Condition` returns for
Standard Boolean; its preceding optional validity path is disabled by the
stated setting (`exp_util.adb:316–447`, `validsw.ads:114`).

Integer is a definite copy type and cannot be an anonymous-access actual
(`exp_ch4.adb:5774–5797`, `accessibility.adb:1965–1984`). The parent scan only
reads the chain (`exp_util.adb:15023–15050`), and the excluded contexts prevent
delayed expansion/assignment/return/object optimizations. With a nonstatic
but known condition, the expander performs the same relocate-and-rewrite
charge. Both action helpers return for No_List; no selected delayed child is
unanalyzed, so final Analyze_And_Resolve returns on the relocated child's
Analyzed flag (`exp_ch4.adb:5857–5974,15228–15245`,
`exp_util.adb:8030–8050`, `atree.adb:2109–2160,2222–2311`). With an unknown
condition, empty actions and the default coverage option, the node is left
for gigi without allocation (`exp_ch4.adb:6498–6653`, `opt.ads:1471`).

The direct concat emitter constructs at most **n+2** conditional expressions:
the lower-bound selector spine plus two null-result selectors. One initial
pass for which these local premises hold therefore adds at most `2*n+4`
ordinary nodes and `n+2` growing events. First analysis of the generated
Boolean comparisons and their scalar children remains additional. The two
null-result selectors can enter the plain-storage path with checks enabled;
this suppressed local transfer alone does not close that route or prove
single compilation-wide analysis multiplicity.

### Generated Integer equality and inequality

The generated selectors and slice guards compare captured length names or
copied aggregate-length leaves with zero. For one generated `Make_Op_Eq` or
`Make_Op_Ne`, assume already analyzed/resolved, nonoverloaded operands of the
same frozen Standard Integer base; Standard Boolean result/context; strict
overflow and suppressed checks; no errors, dimensions, unset-reference
diagnostics, transient wrapping or allocating rewrite callbacks. Both the
operator and its Original_Node are artificial. Neither operand is a Length
attribute of an entity, even through an artificial type conversion. Their
finite initializer graphs satisfy the earlier comparison transfer with
unfolded bound A, including every operand and queried type-bound root.

The additional semantic/expansion envelope is:

```text
ordinary nodes        40*A + 5
growing-slot events   2
Uint appends          160*A + 120
syntax list headers   1 for equality; 0 for inequality
entities/names/Elists/String/overload entries  0.
```

Use the comparison transfer's magnitude bound and multiply the Uint term by
its base-32768 digit count for cumulative digit words. The two comparison
queries run sequentially, so their local vector-peak bound is unchanged.
This deliberately charges both mutually exclusive successful folding routes.

The generated constructor already carries the Standard operator entity.
`Analyze_Comparison_Equality_Op` installs one interpretation directly;
`Check_Function_Writable_Actuals` returns for artificial code. With these
same operand types, Find_Unique_Type is a read-only selection, and both
Resolve child calls return on Analyzed. Standard/artificial xrefs and the
source-only low-bound check add nothing
(`sem_ch4.adb:2069–2201`, `sem_util.adb:2920–2950`,
`sem_type.adb:2350–2366`, `sem_res.adb:7672–7739`,
`lib-xref.adb:275–317`, `sem_warn.adb:782–817`).

`Eval_Relational_Op` performs one Compile_Time_Compare, with the earlier
`20*A` nodes and `80*A+60` Uint envelope. Scalar Integer excludes its array-
length and real-folding branches. A successful Fold_Uint of Standard Boolean
adds one Boolean occurrence and at most one saved original/growing event;
Get_Enum_Lit_From_Pos selects one of the two existing enumeration literals
without a Uint operation or name insertion. The comparison-specific warning
paths require a source Original_Node and therefore do not perform an extra
Test_Comparison (`sem_eval.adb:3548–3638,3720–3870,5150–5222`,
`sem_util.adb:10598–10662`, `sem_warn.adb:3548–3649,3770–3810`).

When an equality survives semantic folding, **Expand_N_Op_Eq still allocates
one empty Bodies list**, even for Integer: it is initialized before the
type dispatch (`exp_ch4.adb:8249–8256`). Integer otherwise bypasses the
Boolean, array, record, access-equivalent and narrowing branches. Inequality
selects its elementary Standard-operator branch without this list. Both call
Rewrite_Comparison, whose Test_Comparison makes one additional
Compile_Time_Compare. A successful rewrite adds a Boolean occurrence,
Convert_To's shallow relocation (types already match), and at most one saved
original/growing event. The new Boolean occurrence has its entity and type
set, but is **not** already analyzed. Find_Direct_Name selects its existing
entity without visibility search; Resolve_Entity_Name's enumeration branch
sets fields and Eval_Entity_Name returns after marking staticness. Native
entity expansion has no applicable transformation for the existing Boolean
literal (`sem_ch8.adb:6246–6301`, `sem_res.adb:8096–8105`,
`sem_eval.adb:2454–2465`, `sem_util.adb:28750–28807`,
`exp_ch2.adb:372–533`). Optimize_Length_Comparison returns because neither root
operand has its required attribute shape; it does not follow internal-constant
initializers to invent that shape
(`exp_ch4.adb:8532–8588,8760–8844,10162–10258,14665–14700,
14800–14863,15251–15306`, `sem_eval.adb:7085–7161`,
`tbuild.adb:105–121,732–802`).

There are at most **2*n+2** direct generated comparisons: up to n lower-bound
selectors, two null-result equalities, and n slice guards. Consequently one
initial pass satisfying all premises adds at most `(2*n+2)*(40*A+5)` ordinary
nodes, `4*n+4` growing events and `(2*n+2)*(160*A+120)` Uint appends, plus at
most **two syntax lists** for the equality expander. This does not include
additional comparisons constructed while analyzing inserted range checks,
first analysis of scalar children, or source-to-reanalysis multiplicity.

### Generated ordinary String bounds and length attributes

For one artificial First, Last or Length attribute, take an already analyzed,
resolved and nonoverloaded prefix denoting an ordinary one-dimensional String
object/view or constrained subtype. Referenced prefix entities are frozen.
Its nominal and available actual subtypes are ordinary String subtypes, with
signed Integer indices; they are frozen,
nonpacked, nonprivate, nongeneric, nonpredicated and not String-literal
subtypes. The prefix is not access-typed (an already expanded explicit
dereference whose result is String is allowed), a build-in-place function,
concurrent self-reference or unchecked union. There is no dimension argument,
error, dimension annotation, transient/spec context or pending prefix check.
The result context is the frozen Standard Integer base, constant-folded values
fit it, checks are suppressed and overflow mode is strict. Known bound values
are existing literal/constant chains. Prefix/input syntax and its first
analysis are charged earlier; native rewrite callbacks add nothing.

The extra envelopes are:

| Attribute | Ordinary nodes | Growing events | Uint appends |
| --- | ---: | ---: | ---: |
| First or Last | `2` | `1` | `0` |
| Length | `20*A+4` | `2` | `80*A+64` |

A is the preceding finite graph bound for a comparison of the chosen index
bounds, including its queried type bounds. There are no additional entities,
names, syntax lists, Elists, String values or overload entries. Use a numeric
magnitude bound covering both the comparison transfer and `2*H+1` for the
extra length arithmetic, where H bounds the two existing index values. Uint
digit charges follow that maximum. An unconstrained ordinary String object
with no constrained actual subtype also fits: its evaluation returns without
folding and native expansion leaves the attribute for gigi.

The common analysis prologue analyzes the existing prefix and finds no
attribute expressions. Check_Array_Type's dereference helper only resolves
the already analyzed prefix; it does not insert a dereference when the
prefix's type is already String. First/Last select the Integer index base,
and Length initially selects Universal_Integer. There are no source-only
restriction/predicate additions
(`sem_attr.adb:1794–2015,2097–2138,3208–3450,4434–4440,4832–4834`,
`restrict.adb:661–705`). Resolution resets a universal result to the context
base, resolves the prefix, and calls Eval_Attribute once. Frozen prefix
entities/types, already resolved expressions and ordinary context exclude
freeze additions (`sem_attr.adb:11559–11620,13628–13736`).

The evaluator's Get_Actual_Subtype_If_Available is a lookup, **not** the
separate allocating Get_Actual_Subtype helper. It selects an existing actual
subtype or Etype without constructing one (`sem_util.adb:10380–10409`,
`sem_attr.adb:8727–8750`). Set_Bounds reads the existing index range; the
String-literal-subtype branch that manufactures a high bound is excluded
(`sem_attr.adb:8308–8405`). Static-subtype checks only inspect existing bounds
under the no-error/known-value premises.

First and Last fold a known bound through Fold_Uint, at most one literal,
one saved original and one growing event. Otherwise the concurrent-
discriminant helper cannot apply. Native expansion may replace a local
constrained array's bound attribute with one occurrence of an existing
nondiscriminant bound entity, with the same two-node/one-growth envelope.
The semantic-fold and surviving-attribute routes are mutually exclusive
(`sem_attr.adb:9590–9620,9817–9847`, `exp_attr.adb:4121–4201`,
`exp_util.adb:7756–7779`).

Length performs its known-bounds calculation, if available, using one
subtraction and one addition: at most three Uint appends. **It does not
return after this fold.** It next performs one Compile_Time_Compare of the
bounds, then may fold again using the returned Diff plus one, adding at most
one further Uint append. The two Fold_Uint calls are conservatively charged
as four nodes and two growing events, in addition to the comparison's
`20*A` nodes and `80*A+60` Uint appends
(`sem_attr.adb:9898–9977`). Its common evaluation tail only updates staticness
or checks the empty expression list (`11425–11459`). A surviving native
Length has no packed/access/minimized-overflow expansion; its universal-
integer check returns for suppression (and independently for artificial
attributes) before constructing anything
(`exp_attr.adb:2496–2588,5129–5346`, `checks.adb:3978–4007`).

There are at most **n+2** direct First/Last attributes and **n** direct Length
attributes in the concat emitter. One initial pass satisfying these premises
therefore adds at most `20*n*A+6*n+4` ordinary nodes, `3*n+2` growing events,
and `n*(80*A+64)` Uint appends. Earlier scalar conversions around last-operand
bounds, first prefix analysis, nonfrozen copied slice itypes, insertion
contexts and compilation-wide reanalysis remain separate charges. This
attribute result does not silently establish their shape or freezing premises.

### Generated same-type Integer conversions

An artificial ordinary type conversion whose target/context and already
analyzed/resolved nonoverloaded operand are the **same** frozen Standard
Integer base adds at most **two ordinary nodes and one growing event**, and
no Uint, entity, name, list, Elist, String or overload-table allocation. Its
type occurrence is already bound to that existing type. There are no errors,
dimensions, predicates, callbacks, transient/spec context or pending checks;
checks are suppressed. A known value is an existing literal/constant chain
and fits the target. Input conversion/mark syntax and child costs are separate.

Analyze_Type_Conversion finds the existing type, analyzes the child and
returns at the artificial-node guard. Numeric Valid_Conversion is a read-only
success; remote-type checks have no applicable scalar branch
(`sem_ch4.adb:6419–6455`, `sem_res.adb:14258–14329`,
`sem_cat.adb:1914–1955`). Resolve returns on the analyzed child, then either
Eval_Type_Conversion folds the existing integer value via Fold_Uint or leaves
the conversion unchanged. Same specific Integer type excludes all three
Simplify_Type_Conversion rewrites; suppression skips both scalar-conversion
check branches before range analysis
(`sem_res.adb:12440–12480,12703–12722,13343–13412`,
`sem_eval.adb:4178–4300`, `checks.adb:3788–3828,3881–3919`).

If semantic folding did not replace the conversion, native expansion reaches
the identical-type guard before general conversion processing. It rewrites
to a shallow relocation of the already analyzed child: at most one new copy,
one saved original and one growing event. Its Done tail has no predicate work
for Standard Integer (`exp_ch4.adb:12107–12139,12817–12853`). This is mutually
exclusive with the semantic literal fold, yielding the stated envelope.

The concat emitter's two explicit Convert_To calls around the last operand's
First/Last can construct conversions before their attributes have types.
Once those attributes are analyzed to the same Integer base, one initial
analysis of these two conversions adds at most **four ordinary nodes and two
growing events**. The emitter's specialized To_Ityp/To_Artyp wrappers remain
no-ops under Artyp=Ityp. Conversions constructed by range-check selection,
other type pairs, child reanalysis and caller suppression are separate.

### Collected scalar constant declaration skeleton

The emitter collects at most **2*n** scalar constant declarations: n dynamic
lengths, n-1 aggregate lengths and one lower-bound selector
(`exp_ch4.adb:3015–3045,3078–3102,3219–3228`). The direct emitter already
charges their defining entities, names, declaration/type-occurrence syntax
and collection list. Their initializer expression transfers are separate.

For a fresh artificial local non-Ghost constant of the frozen Standard
Integer base, its declaration analysis/expansion adds **zero further nodes,
entities, lists, names, Uint or String values** once its initializer analysis
and resolution are charged. Here the object definition is an occurrence of
that existing type; the initializer is a well-typed scalar literal, ordinary
name, arithmetic, bound attribute, conversion or scalar conditional in the
preceding classes, with no pending range check, error, unset diagnostic,
allocators, function call, renaming/OK_To_Rename reference or expression
actions. An initializer root that is an entity name has the same declared
type as the new constant. Its known value, if any, fits Integer. The scope is
an ordinary local procedure/block, with no transient wrapper, deferred
completion, special return, address/representation/aspect, foreign/static
allocation or delayed-freeze property. All checks are suppressed. The
initializer has not become a renaming or declaration through expansion.

The pointer/scalar-capture declaration trace above supplies the common
type/name-entry, scalar/no-length-check, explicit-initialization and ordinary
object-freezing paths. One distinction must be checked explicitly: these
direct concat declarations do **not** rely on `Assignment_OK`.
Check_Initialization only handles limited initialization and the
`not Expander_Active` scalar check. Native Standard Integer satisfies neither,
so it allocates nothing (`sem_ch3.adb:4800–4802,13042–13124`). This argument
does not apply to GNATprove's light expansion.

Analyze and Resolve process the initializer at `sem_ch3.adb:4704–4750`.
After its own charged transfer, the remaining semantic path only sets the
completion/validity/type fields. Constants do not get Current_Value from the
variable-only branch. If a known-valid entity initializer is considered,
In_Subrange_Of returns at its identical-type guard; any inherited
Actual_Subtype is that same existing type. Suppressed Apply_Scalar_Range_Check
returns before analysis with a clear pending-check flag; scalar
Apply_Static_Length_Check has no array/access path
(`sem_ch3.adb:4805–4852`, `sem_eval.adb:5336–5337`,
`checks.adb:3238–3274,10251–10272`). Definite Integer cannot enter the
unconstrained array/discriminant subtype-generation cases.

The native explicit-initialization path suppresses constraint/range checks.
Scalar Integer has no tag, copy alignment/array validity, controlled/task,
accessibility, predicate/DIC or return-object transformation; the stated
initializer shapes exclude capture and renaming transformations
(`exp_ch3.adb:8395–8715,8750–8817,9485–9487`). Freezing the fresh ordinary
constant reuses the frozen type, runs the no-op Layout_Object, and requests
no delayed freeze node, as in the capture transfer. This closes the
declaration **skeleton** only: child analysis and copying, the collection's
Insert_Actions placement, context-dependent declaration movement and
compilation-wide multiplicity remain additional.

### Ordinary initial action placement

The placement portion of Insert_Actions adds **zero nodes, entities, lists,
names, Uint or String values** for the following ordinary initial-analysis
parent paths. The supplied action list and each action's analysis (including
actions generated recursively by that analysis) are charged separately.
Assume no transient scope/wrapped node, record/concurrent/generic/spec
context, aggregate-loop placement or allocating rewrite callback, and that
any encountered enclosing short-circuit or scalar conditional expression has
not yet been analyzed. These are local placement premises, not a proof that
every source or replayed concat invocation satisfies them.

The parent walk can cross ordinary expression nodes until it reaches a
declaration/statement list member, including a source assignment, output call,
if statement or loop. It splices the existing list immediately before that
member and analyzes its entries. For a right operand of an unanalyzed
short-circuit, a dependent branch of an unanalyzed conditional, or an elsif
condition, it attaches the same list to the appropriate Actions field, or
splices it into that field's existing list, and analyzes its entries
(`exp_util.adb:8050–8134,8138–8240,8289–8314,8318–8462`). A left short-circuit
operand or the condition of a scalar conditional continues outward. Nested
statement bodies stop at their own list member; the walk does not move an
action past that enclosing statement.

List splicing rewires existing links without adding a list header;
Insert_List_Before/After_And_Analyze and Analyze_List walk the existing
entries. Mark_Rewrite_Insertion only sets a flag
(`nlists.adb:468–602`, `sem.adb:873–883,1269–1332`,
`atree.adb:1824–1827`). The short-circuit branch's two Kill_Current_Values
calls clear fields and existing saved-check records; they do not append to
those tables (`sem_util.adb:22609–22691`, `checks.adb:8922–8968`). Suppression
wrappers save/restore the fixed check-status array; each Insert_Action's
one-element list wrapper remains charged in the earlier direct/helper count.

Attaching already analyzed actions does **not** close their later enclosing
expression expansion. In particular, Expand_Short_Circuit_Operator converts
useful right-operand actions into Expression_With_Actions. That wrapper can
capture a Boolean expression into a fresh constant even when there are no
controlled objects (`exp_ch4.adb:13123–13248,5625–5712`). The already-analyzed
short-circuit insertion branch can also create the wrapper immediately. Those
wrapper/capture transfers, transient placement and any replay remain separate;
zero-cost list movement is not a zero-cost conditional-expression claim.

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
  their costs when the class invariant holds. Establish the incoming premises
  for the closed mutable-renaming/scalar captures and slice subtype transfer,
  and cover operands outside those classes.
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
