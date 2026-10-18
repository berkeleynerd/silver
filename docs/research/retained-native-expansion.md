# Native String concatenation allocation component

2026-10-17, #119. This component closes the **direct native concatenation
emitter's** control-flow and primitive allocation accounting. It does **not**
close the construct's semantic and generated-action callees, and supplies no
whole-program capacity predicate or new admission limit. Counting generated
syntax alone misses allocations made while GNAT analyzes that syntax.

The source is GCC Ada commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The
[retained evidence](../evidence/unbounded-programs/retained-native-expansion-20261017/local-envelope.json)
records seventy-seven inspected files hash-checked against the complete source
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
count. The next transfer closes the enclosing object/renaming skeletons with
their specified premises. `ConstrT` construction/freezing, action placement,
runtime loading and backend data remain additional. Do not treat it as the
completed secondary-storage branch.

### Allocator object and constrained renaming skeletons

The emitter's `Rxx : Ayy := new ConstrT` object and
`Sxx : ConstrT renames Rxx.all` add **zero further ordinary nodes, entities,
names, syntax/Elists, Uint or String values** through semantic/native
declaration processing after the allocator transfer above has been charged.
Assume the named access type and its designated constrained ordinary String
subtype are already frozen, and the fresh local declarations have no aspects,
predicates, delayed freezes, address clauses, foreign convention or special
return property. Both declarations are artificial, non-Ghost and nonvolatile,
in an ordinary nontransient scope; checks are suppressed as at their actual
Insert_Action calls. There is no diagnostic or allocating rewrite callback.
The existing direct declaration/type/dereference syntax is already charged.

The object skeleton differs from the earlier pointer-capture constant only
in being a variable initialized by an allocator. Analyze/Resolve performs the
separately charged allocator transfer, then keeps the exact named access type.
No actual-subtype construction applies to an access type. The static length
checker compares the identical designated/index types and returns no check;
this remains necessary to establish despite check suppression. Compile-time
known-value testing does not classify the allocator as a scalar constant, so
the variable Current_Value branch does not retain it as a replacement value.
Known_Non_Null returns immediately from Null_Status's allocator branch, setting
the object's non-null flag without numeric or syntax allocation
(`sem_ch3.adb:4704–4852`, `sem_util.adb:10270–10374,22698–22741,
26498–26543`, `checks.adb:10251–10412`).

Native explicit-initialization expansion skips even its constraint check for
an allocator carrying No_Initialization. The remaining access-object path
only updates the non-null flag; a plain allocator is neither a captured
function dereference nor an OK_To_Rename reference. Named access excludes
anonymous-access accessibility objects, and ordinary String excludes
controlled/task/unaligned/BIP transformations
(`exp_ch3.adb:8395–8715,8750–8817`, `exp_util.adb:8896–8916`). Freezing the
ordinary pointer object reuses its frozen access type and needs no delayed
freeze node or object layout allocation. If the access type is not yet
frozen, its earlier one-node/one-list first-freeze transfer is additional.

For the renaming, Find_Type selects the existing ConstrT. Analysis of the
two-node dereference reads the existing pointer and designated subtype,
without interpretation-table entries. Resolve's access check is suppressed;
the designated type is already constrained and nonpacked, so no actual
subtype is manufactured (`sem_ch4.adb:2182–2326`,
`sem_res.adb:9253–9380`, `checks.adb:8458–8509`). In Analyze_Object_Renaming,
Check_Constrained_Object's allocating branch requires an **unconstrained**
type; the actual-subtype lookup and subsequent variable/type/atomic/renamed-
object assignments only reuse existing values. Artificial declarations skip
the source object-reference legality and debug-prefix checks; aspects and
dimensions are empty (`sem_ch8.adb:761–960,1080–1198,1360–1602`).

The renaming expander's Evaluation_Required returns false for an explicit
dereference, and ordinary String has no class-wide or build-in-place route
(`exp_ch8.adb:105–215`). The emitter explicitly marks Sxx as needing debug
information, so Debug_Renaming_Declaration **does run**. It walks the simple
dereference/name, prepends only `XA` to the existing bounded name buffer, then
finds no packed/package reason to enable an encoding. It marks Sxx as
Materialize_Entity and returns Empty **before** constructing or interning any
debug object/name (`exp_dbug.adb:290–412,488–516`, `namet.ads:161`). The
two-character scratch-buffer use is bounded; Materialize_Entity's backend
effects are separate. Ignoring the debug helper merely because this renaming
is generated would have been incorrect.

These skeletons do not cover unconstrained renamings, later references to the
renamed object, first analysis of result bounds, generated-subtype freezing,
transient/action placement, RTE dependency loading or backend elaboration.

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
recapture an already-captured scalar bound.

The same five-node/one-entity/one-list transfer extends to an **already
analyzed scalar bound tree** under the same frozen-type, suppression,
no-pending-check and ordinary-placement premises. Permit signed Integer
arithmetic/conversions, scalar conditionals, ordinary scalar references and
First/Last/Length attributes whose prefixes are object-name views. Exclude
expression actions, packed/unaligned references, volatile/aspect-bearing
objects, non-name attribute prefixes and allocating rewrite callbacks.
`Side_Effect_Free` either accepts the whole tree or the elementary branch
captures its whole root with one shallow relocation; it does not copy or
reanalyze the initializer's children. The attribute-prefix special case
cannot intercept this route because each permitted prefix is a name reference;
slices and explicit dereferences satisfy that predicate
(`exp_util.adb:12717–12828,14425–14697`,
`sem_util.adb:19072–19116`). The relocated tree retains Analyzed, so both
Analyze and Resolve return before child processing. The prior declaration
skeleton applies without requiring the initializer to be an identifier.
Every possible captured root has at least the identifier's slot size, so the
final rewrite does not grow a node. A second forced evaluation still costs
zero. This closes capture **after** first bound analysis; it does not give a
size bound for a tree left intact because it is already side-effect-free.

With `Related_Id` empty, the existing internal-name allowance remains 13
characters. A caller supplying a related subtype name must instead charge
the external `_FIRST`/`_LAST` name construction
(`exp_util.adb:12557–12617`); it cannot reuse the serial-name allowance.

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
wrapper/capture transfer below has additional premises. Transient placement and
any replay remain separate; zero-cost list movement is not a zero-cost
conditional-expression claim.

### Boolean expression-with-actions wrapper

A generated Boolean Expression_With_Actions has a closed local transfer when
its existing nonempty action list and expression have already been analyzed,
resolved and expanded, all relevant types are frozen, and no action needs
finalization. The enclosing context is an ordinary non-Ghost procedure/block,
with no transient wrap, spec expression, build-in-place return, diagnostic or
allocating rewrite callback. The inner expression has exact Standard Boolean
type and no pending check; it is an existing name/literal, comparison,
short-circuit, Boolean `not`, ordinary Boolean function call, or another
already analyzed Boolean EWA. A known value reaches an existing Boolean
literal through constant names. There are no anonymous access, renaming or
OK_To_Rename expressions. The enclosing short-circuit's result type is also
Standard Boolean, so its post-wrapper Adjust_Result_Type returns without a
conversion. No action opens a scope or adds pending freeze/use
actions during this replay: its Analyze call returns on the Analyzed guard.
Input action syntax and the original expression have been charged earlier.

Including construction by the short-circuit wrapper route, one such transfer
adds at most:

```text
ordinary nodes              8
entities/internal names     2
name characters incl. NUL   26
growing-slot events          2
Uint appends                1
extra live scope entries    1
syntax lists/Elists          0
String values               0.
```

The Uint charge is for the new block's scope depth: its magnitude is at most
the incoming scope depth plus one. Its retained digit and local arithmetic
vector costs follow the earlier addition transfer. The extra scope entry is
a **live stack** increment, popped on return, not a retained entry per wrapper;
capacity must cover the peak nested depth and Table growth separately.

The direct wrapper makes an EWA, one shallow relocation of the expression,
and at most one saved original with one growing rewrite. It moves the existing
action list without constructing a list
(`exp_ch4.adb:13225–13248`, `exp_util.adb:8161–8182`).
Analyze_Expression_With_Actions always calls New_Internal_Entity for a fresh
E_Block and pushes a scope, including for generated wrappers. New_Internal_Entity
makes one temporary entity/name, appends it to the outer scope and does not run
type layout for E_Block. Push_Scope computes at most one depth addition, pushes
one Scope_Stack_Entry and initializes its list fields to No_List/No_Elist.
Under the already-analyzed-action premise, its loop and Check_Action_OK perform
no allocations; the latter permits generated code. End_Scope/Pop_Scope clear
visibility and restore saved fields, with empty pending-freeze/use/action
fields and a null saved subprogram-name pointer
(`sem_ch4.adb:2413–2522`, `sem_util.adb:25661–25679`,
`sem_ch8.adb:5230–5326,9814–10035`, `sem.ads:499–596`).

Generated/rewrite wrappers resolve their existing expression directly and do
not enter Resolve_Declare_Expression's hidden-map handling. If the expression
is known and all actions are static constants or static renamings, semantic
resolution may replace the wrapper with a copy of its Boolean literal. That
route needs at most two ordinary nodes and one growing event, and excludes
the native capture route (`sem_res.adb:2567–2581,9381–9512`).

For a surviving wrapper with a non-name expression and nonempty actions,
Force_Boolean_Evaluation appends a fresh Boolean constant to the **existing**
action list. It constructs one entity/name and at most five ordinary nodes:
the declaration, its Boolean type occurrence, the relocated initializer,
the final flag occurrence and a saved original for the inner rewrite. There
is at most one growing event (`exp_ch4.adb:5625–5712`). A name expression needs
no capture. The declaration's usual scalar skeleton applies to Standard
Boolean, including native Check_Initialization's nonlimited/no-light-expansion
return, but its checks need not be suppressed: both semantic and native
Apply_Scalar_Range_Check find an interval inside Boolean's existing 0..1
range and return without constructing a check. Determine_Range does not
descend into comparison/short-circuit/not/call/EWA children; they use the type
bounds. Known names/literals use existing enumeration positions, and internal
constant forwarding follows finite Boolean initializer chains
(`sem_ch3.adb:4704–4852,13042–13124`,
`checks.adb:1318–1341,3238–3421,5127–5304,5550–5628,6112–6130`).

The native declaration has no source-only validity copy check, controlled or
array work. Is_Captured_Function_Call requires an explicit dereference, so an
ordinary Boolean function-call initializer cannot trigger that renaming route
(`exp_ch3.adb:8395–8715`, `exp_util.adb:8896–8916`). Constants do not acquire
Current_Value in the declaration's variable-only branch. The final bound
flag occurrence is analyzed without a visibility search; Eval_Entity_Name
sets staticness and returns, and Expand_Entity_Reference has no renaming,
variable or Current_Value transformation for it
(`sem_ch8.adb:6246–6301`, `sem_res.adb:8149–8232`,
`sem_eval.adb:2454–2530`, `sem_cat.adb:2182–2190`,
`exp_ch2.adb:372–521`). Freezing the ordinary flag reuses frozen Boolean with
no delayed-freeze or layout additions, as in the scalar capture transfer.

Process_Transients_In_Expression only calls its allocating worker when an
object declaration passes Is_Finalizable_Transient. For ordinary Integer,
Boolean and String objects, or access objects designating ordinary String,
Needs_Finalization is false; the predicate stops before its alias/container
searches. This includes the appended Boolean flag
(`exp_ch4.adb:15228–15245`, `exp_util.adb:9430–9506`,
`sem_util.adb:23417–23510`). This closes finalization processing for those
action types; it does not exclude secondary-stack **transient placement** in
the enclosing compilation.

The wrapper's first child/action analysis, other action types, pending-freeze
scope exits, enclosing transient handling, repeated wrappers and source-to-
invocation multiplicity remain separate. In particular, the immediate
Insert_Actions branch on an already-analyzed short-circuit must charge the
first analysis of its new actions before reusing this transfer.

## Composed scalar and enabled-check transfers

The following closes the generated **range-check** stage of an ordinary
constrained String subtype, including its condition analysis. It also provides
an executable aggregate for the concat emitter and its scalar expressions.
These are composable stages, with input-shape premises below; the final native
concat transfer still needs operand decoration, storage-object, call/slice,
transient and invocation closure. `derive.py` computes the aggregate from the
individual rows and checks its polynomial, rather than using a measured
compiler coefficient.

### Scalar helpers with checks enabled

The earlier artificial same-type Integer conversion and generated `+`/`-`
transfers extend to enabled checks with at most **6*A additional Uint appends
per operation**, and no extra syntax beyond their existing two-node/one-growth
bound. They still require the frozen Standard Integer base, no diagnostic,
already resolved children, strict overflow and optimization level zero.
Any parent conversion uses that same Integer base; no wider-type conversion
optimization applies. The selected Linux x86 target has
Backend_Overflow_Checks=True (`libgnat/system-linux-x86.ads:132`,
`targparm.adb:802`). This target selection remains part of source/tool identity.

For arithmetic, Enable_Overflow_Check performs one Determine_Range query,
then returns or sets a flag before the optimizer's saved-check table path.
Strict native arithmetic returns at the backend-overflow guard; its two small
size products are directly represented Uint values, not retained appends
(`checks.adb:410–455,756–814,850–966,6283–6450`). For an exact-type conversion,
In_Subrange_Of's identity test prevents the overflow branch. Its scalar range
check may run one Determine_Range query, then either the bounds fit or the
same-type identity test returns; the no-diagnostic premise excludes a disjoint
estimated interval. No check syntax is constructed
(`checks.adb:3325–3479,3805–3919`, `sem_eval.adb:5336–5337`).

The earlier scalar conditional transfer requires no suppression once its
children are resolved to the exact context type: Apply_Check returns on type
identity. An already generated child overflow flag is permitted; the
conditional does not reanalyze that child. Ordinary generated String bound
attributes likewise retain their earlier cost with enabled checks: the
universal-attribute check returns for an artificial attribute
(`sem_res.adb:9521–9689`, `checks.adb:3978–4007`).

For artificial **ordering** comparisons `<`, `>`, `<=`, `>=`, the same
`40*A+5` nodes, two growing events and `160*A+120` Uint envelope as Eq/Ne
applies with **zero** new syntax lists. Suppression is unnecessary when the
children are already analyzed/resolved with no pending range checks: comparison
resolution only resolves those existing children, and strict native expansion
has no additional checking route. Standard Integer excludes array/Boolean/
universal narrowing, and the existing no-root-Length premise excludes the
length optimization (`sem_res.adb:7672–7743`,
`exp_ch4.adb:9494–9697,15251–15301`).

### Empty wrappers in short-circuit checks

One artificial Standard Boolean short-circuit with already resolved,
side-effect-free scalar-comparison/Boolean children, no actions, no diagnostics
and the ordinary frozen/nontransient context costs at most **eight ordinary
nodes, three growing events and one syntax-list header**, with no entity,
name, Uint, Elist or String additions. Child costs remain separate. This
includes a native resolver action absent from the direct source grammar:
Resolve_Short_Circuit always relocates its left operand, constructs an EWA
with a **fresh empty list**, and rewrites the old left node. Save_Interps does
nothing for these nonoverloaded children (`sem_res.adb:11668–11700`,
`sem_type.adb:3324–3346`).

That wrapper is **resolved without Analyze**. It therefore does not invoke
Analyze_Expression_With_Actions and creates no E_Block entity or scope entry.
Resolve_Expression_With_Actions either rewrites its known expression directly,
or the native empty-action case relocates the existing expression and rewrites
the wrapper. Charge at most five nodes/two growing events including wrapper
creation. The short-circuit's own semantic fold or native known-operand rewrite
adds at most two more nodes/one growing event; eight is a conservative envelope
(`sem_res.adb:2567–2581,9483–9512`,
`exp_ch4.adb:5690–5740,13167–13274`, `sem_eval.adb:3906–3998,5150–5222`).
Standard Boolean adjustment is a no-op, the empty action list is not useful,
and purity makes Remove_Side_Effects return. Dead-code handling only removes
existing warnings/scenario records for these scalar trees; it creates no new
syntax or recorded values (`exp_util.adb:10227–10378,12717–12729`,
`errout.adb:3367–3475`, `sem_elab.adb:13667–13689,14258–14269`). The generated
wrapper is a rewrite substitution even if a caller preserves source flags, so
it does not enter Resolve_Declare_Expression's allocating hidden-map path.

### Enabled range-check composition

Take the preceding Get_Range_Checks shape: two already-resolved pure bound
trees with b ordinary nodes and l list headers, no owned itypes/entities/actions,
and exact Integer-base scalar values. Target subtype is Standard Positive.
The scalar graph bound A includes every comparison/conversion query root.
Known values fit their selected types; no static-error diagnostic occurs.
The children are side-effect-free under Variable_Ref, and no pending range
checks remain. Native local-raise optimization is off (default debug flags,
no No_Exception_Propagation restriction). The enclosing declaration is an
ordinary nontransient local declaration with no allocating rewrite callbacks.

The one dynamic check has this fixed generated shape:

```text
raise Constraint_Error when
  high >= low and then
    (low < Positive'First or else high > Positive'Last)
```

Its builder was already bounded by `2*b+28` ordinary nodes and `2*l` lists.
Copies preserve Analyzed flags; Remove_Checks changes check flags without
clearing Analyzed. Its six Convert_To sites can conservatively be charged as
six same-type conversions even where they return only a shallow relocation
(`sem_util.adb:24637–24721`, `checks.adb:9822–9887,10609–10703,11139–11156`).
The two Positive attributes fold existing type bounds for two nodes/one growth
each, with zero numeric appends; their scalar-prefix path selects the Integer
base directly (`sem_attr.adb:1866–1882,8339–8354,9590–9620,9817–9847`).
There are three ordering comparisons and two short-circuits. Finally,
Analyze_Raise_xxx_Error may replace the raise with a null statement, adding
at most two nodes/one growth. Its native expander only adjusts Standard Boolean
and returns from disabled local-raise optimization
(`sem_ch11.adb:674–755`, `exp_ch11.adb:1319–1332,1697–1710`).

Adding all condition-analysis rows gives `120*A+49` ordinary nodes,
21 growing events, two lists and `516*A+360` Uint appends. Insert_Range_Checks
splices the existing conditional raise after the declaration and analyzes it;
it creates no insertion-wrapper list (`checks.adb:8117–8161`). Combining the
builder, the selection comparison and the full condition analysis yields:

```text
complete enabled range check:
  ordinary nodes       2*b + 140*A + 77
  syntax lists         2*l + 2
  growing events       21
  Uint appends         596*A + 420
  entities/names/Elists/String values 0.
```

Consequently the earlier explicit constrained String subtype declaration,
with its already-resolved bounds and all other local premises unchanged, has
the enabled-check envelope `2*b+140*A+81` ordinary nodes, `2*l+2` lists,
23 growing events, `596*A+515` Uint appends, one index entity/name and L+4
name characters. It includes index layout and the at-most-two bound folds.
First bound analysis, any Force_Evaluation capture, the enclosing result object
and subsequent freezing remain separately charged stages. The enabled case
cannot use the earlier zero-list suppression shortcut.

### Executable direct-plus-scalar concat aggregate

For n operands, assume each first generated scalar pass meets the preceding
helper premises and A bounds all of its unfolded query graphs. Charge enabled
arithmetic/conversions even when an actual insertion suppresses their checks.
The collected Integer declarations add only their already-counted syntax.
The lower-bound selection makes at most n direct Compile_Time_Compare queries
(`exp_ch4.adb:3176–3208`); the final Is_Out_Of_Range test only reads known
values or returns Unknown (`sem_eval.adb:5667–5677,7354–7496`).

Summing the direct emitter, initial generated arithmetic, conditionals,
comparisons, attributes, conversions and those selection queries gives:

```text
ordinary nodes       (120*n+80)*A + 52*n + 73
entities/names       2*n + 4
syntax lists         3*n + 13
growing events       12*n + 13
Uint appends         (504*n+344)*A + 385*n + 250
name characters      13*(2*n+4).
```

The aggregate **includes** the n+2 closed scalar-leaf copies, but **excludes**
the remaining direct copies/duplicators, result-subtype/storage/assignment/call
analysis, wrapper placement and repeated invocations. It is a sum of proved
local stages, not a whole-native or source-to-demand bound. A must bound the
actual generated query graphs; neither 4096 source bytes nor the runtime
String-length bound can simply be substituted for it. The executable rows
make these remaining composition obligations visible rather than absorbing
them into an unexplained multiplier.

### Input transient lifetime and later concat placement

The admitted input form has exactly one source call returning unconstrained
String: the first declaration's `First_Or_Default`, with a literal actual.
Later String expressions consist of literals, names, concatenations and
Standard Integer Image; source scalar calls return scalars. The native ordinary
Integer Image path uses its previously described local buffer/procedure/slice,
not Put_Image or wide-image paths. Concat generates no function returning
unconstrained String: the runtime concatenation helpers are procedures.

When the initial input call requests a transient scope, its context search
stops at the input object declaration (`sem_res.adb:7069–7091`,
`exp_ch7.adb:4369–4377`). The expander marks that declaration analyzed and
immediately invokes `Wrap_Transient_Declaration` after its expansion
(`expander.adb:530–550`). The wrapper inserts the pending actions, pops the
transient scope, transfers its entities and can mark the enclosing dynamic
scope `Uses_Sec_Stack` (`exp_ch7.adb:9424–9451`). It cannot leave that transient
scope open while the following declaration or statement is analyzed.

`Scope_Stack.Is_Transient` and an entity's `Uses_Sec_Stack` are separate fields:
`Create_Transient_Scope` sets both only on its new E_Block, while the declaration
wrapper propagates only secondary-stack use after popping it
(`exp_ch7.adb:4226–4247`). Thus subsequent concat initial placement is
nontransient under this grammar, but secondary-stack allocation of the concat
result remains reachable. It would be wrong to exclude that storage branch
from the absence of an active transient scope.

This induction concerns the current Main analysis context. It does not price
the input call's own actions or runtime-library body analysis. Conditional
action attachment and later Boolean EWA wrappers still use their separate
transfers; they are not transient scopes. Copy/reanalysis multiplicity remains
a separate obligation. There is no `Establish_Transient_Scope` call in the
concat emitter or ordinary object expander; the three Image calls belong to
the excluded Put_Image/wide branches (`exp_imgv.adb:1054,1868,1978`).

### Result storage and first subtype freezing

Continue with the earlier pure, already-resolved bound class: b nodes and l
lists, no owned entities/itypes/actions or pending checks, exact Integer-base
values, frozen Standard types, ordinary same current scope, no diagnostics or
allocating callbacks. The result object's directly emitted syntax/entity/name
are already in the direct envelope. These are declaration costs after first
bound analysis and any required capture; they do not establish those incoming
premises for every source expression.

For the plain `Sxx : String (Low .. High)` path, Find_Type's two-node explicit
subtype wrapper, one extra entity/name and one insertion list precede the
enabled subtype transfer. No initializer means no constraint-on-initializer,
actual-subtype, literal-propagation or rename transformation. The generated
object has no aspects, predicates, controlled/task components, return-object,
aliased, imported or statically allocated properties. Native default
initialization adds nothing: Standard String has no base initialization
procedure; `Simple_Initialization_OK` rejects the internal result entity; and
the full initializer builder returns its unchanged `No_List` because it has
neither component nor controlled-object initialization
(`exp_ch3.adb:969–1223,1363–1380,1386–1496,7508–7574,7930–8004`). The Standard
String exception is explicit in its freeze expansion (`5703–5748`);
`Has_Non_Null_Base_Init_Proc` only looks up the existing procedure
(`exp_tss.adb:49–91,222–229`). The no-initializer object skeleton therefore adds
zero core-table allocations beyond the named subtype/placement stages.

The object declaration freezes its subtype (`sem_ch3.adb:4620–4643`). The
explicit array subtype copies Standard String's unknown Esize, and its index
copies Positive's Integer size fields (`14339–14484,15457–15491`). No delayed
freeze is inherited from frozen Standard String
(`sem_util.adb:6326–6331`). Reuse the previously closed String/index pair's
freezing route, except that its first compile-time-size computation may still
be needed: charge at most **four Uint appends**, magnitude `8*(2*H+1)` for
bound magnitude H (`freeze.adb:855–913`). Known size is remembered, while an
unknown nonattribute bound performs no arithmetic. No ordinary freeze node or
list is created on the plain path. Later freezing/layout of the **object** is
a separate stage from this subtype freeze.

The secondary path uses the previously closed suppressed subtype transfer,
one array `Freeze_Itype`, named access declaration/first freeze, allocator and
renaming skeleton. `Freeze_Itype` explicitly sets the delayed flag
(`freeze.adb:10209–10217`), so charge one array freeze node/list in addition to
the named access type's at-most-one freeze node/list. Include the same four
Uint first-size charge, one empty Elist from access-type setup and the
allocator's orphan entity/name. Runtime lookups remain separate. Componentwise
branch charges, beyond direct syntax, are:

| Demand | Plain object | Secondary storage | Common envelope |
| --- | ---: | ---: | ---: |
| Ordinary nodes | `2*b+140*A+83` | `2*b+20*A+34` | `2*b+140*A+83` |
| Lists | `2*l+3` | `2*l+2` | `2*l+3` |
| Growing events | `23` | `2` | `23` |
| Uint appends | `596*A+519` | `80*A+159` | `596*A+519` |
| Entities/names | `2` | `2` | `2` |
| Name characters including NUL | `33` | `29` | `33` |
| Elist headers | `0` | `1` | `1` |

The name bound uses the direct internal-name length at most12: the plain
derived array/index pair uses at most33 characters; secondary storage's index
name and allocator orphan use at most16+13. This is a maximum over the two
branches, not their sum. Neither path adds String values at these closed
stages. Index-layout Uint digits still require the earlier at-least-three-digit
bound, combined with scalar-query and first-size arithmetic magnitudes.

Adding this envelope to the preceding executable direct/scalar aggregate gives
the next partial recurrence:

```text
ordinary nodes       (120*n+220)*A + 52*n + 156 + 2*b
entities/names       2*n + 6
syntax lists         3*n + 2*l + 16
growing events       12*n + 36
Uint appends         (504*n+940)*A + 385*n + 769
name characters      26*n + 85
Elist headers        1.
```

`result_storage` and `direct_scalar_and_storage_concat` regenerate these rows
and assert the polynomial totals. The unresolved boundary still includes
remaining direct copies/duplicators, first bound captures, runtime dependency
loading, later object freezing, final result/call/assignment analysis, wrapper
placement and source-to-invocation multiplicity. The values A, b and l have
not yet been replaced by source-derived summaries. This is still not a native
capacity predicate and does not authorize admission changes.

### Suppressed native slice-assignment length checks

The slice assignments at `exp_ch4.adb:3554–3620` pass `Suppress => All_Checks`.
This does **not** avoid length-check condition construction or analysis.
`Apply_Length_Check_On_Assignment` skips only when its node carries
`Suppress_Assignment_Checks`; the emitter does not set that flag
(`checks.adb:2248–2281`). `Apply_Selected_Length_Checks` calls its selector,
then analyzes the generated conditional raise even when `Checks_On=False`,
before rewriting it to null (`3509–3614`). Both semantic assignment analysis
and native array assignment expansion can call this path
(`sem_ch5.adb:1040–1054`, `exp_ch5.adb:341–900`). Charge **two passes**.

The following transfer covers only checks and the assignment/optional-if
skeleton. Its premises are ordinary nonpacked one-dimensional Standard String
slices in Main; no atomic, controlled, alignment, representation or access-
assignment special case; frozen target/source types; source actual subtype
already cached or constrained (or a literal RHS); no diagnostics, pending
checks or allocating callbacks; and the preceding finite query graph class,
with A bounding every original **and generated** scalar query. Slice and
operand analysis, any actual-subtype construction, type/object freezing,
first bound captures and action placement remain separate.

With those premises the length selector uses type-based Length references,
or an existing literal length. For dimension one it **omits** an explicit
dimension argument, so those attributes own no syntax lists. It builds at
most six ordinary nodes: two two-node attributes, one Ne and one conditional
raise. A statically known pair of lengths costs at most six Uint appends;
the matching/subtype comparisons otherwise only read existing scalar bounds.
There is one check, no OR tree and no access guard
(`checks.adb:9969–10132,10186–10451`, `sem_eval.adb:6702–6835`).

These Length operands initially have **Universal_Integer** type. The earlier
exact-Integer/no-root-Length comparison transfer therefore does not close
their native expansion. `Expand_N_Op_Ne` can first call
`Narrow_Large_Operation`, then `Optimize_Length_Comparison`
(`exp_ch4.adb:10162–10258`). For a comparison, narrowing performs two
Determine_Range calls, two Get_Size_For_Range calls, builds one operator and
two ordinary conversions, then reanalyzes the concrete signed comparison.
The canonical type is an existing 32-, 64- or 128-bit Standard signed type;
the inner comparison cannot narrow again. There are consequently at most
**two** Length-optimizer entries: the narrowed comparison's entry and the
outer caller's entry (`14372–14542`, `exp_util.adb:8852–8890`).

One Get_Size_For_Range tests sizes 32, 63, 64 and 127. Its greatest cached
power is `2^126`, and it performs at most eight negations. Charge a conservative
136 Uint appends per call, including up to 126 cold power-cache extensions;
the `Siz-1` arithmetic stays directly represented
(`exp_ch4.adb:13566–13608`, `uintp.adb:1357–1405`). Two calls cost at most 272.
For the two generated regular conversions, the target is a static Standard
integer type, and the operand is the already analyzed Length or a fitting
literal. A fold costs two nodes/one growth; an unfolder conversion cannot enter
the dynamic-literal or nested-universal conversion simplifiers. Suppression
prevents new checks. The remaining signed-integer native conversion branches
add nothing (`sem_ch4.adb:6419–6458`, `sem_res.adb:12337–12480,13343–13425`,
`sem_eval.adb:4178–4343`, `checks.adb:3805–3919`,
`exp_ch4.adb:12210–12312,12340–12860`).

Each Length optimizer can try both operand orders, hence up to two range
queries and two `2^32` requests. It can construct four First/Last attributes,
four unchecked signed conversions and two arithmetic nodes, and perform two
explicit Compile_Time_Compare queries. The `Maybe_Superflat` early return
occurs **after** speculative construction, so abandoned nodes still count.
Otherwise it rewrites to one concrete comparison whose operands are
First/Last or arithmetic, not root Length; this new comparison cannot enter
another Length optimization (`exp_ch4.adb:14584–15164`).

Unchecked conversions to Long_Long_Integer cost at most three constructor
nodes and two analysis nodes/one growth each. Their children are existing
resolved scalar expressions or the four new First/Last attributes, with no
intermediate conversion to Universal_Integer. They have no unsafe-conversion
capture, biased representation or modular arithmetic route
(`tbuild.adb:912–984`, `sem_ch4.adb:6591–6602`,
`sem_res.adb:12940–12980`, `sem_eval.adb:4442–4500`,
`exp_ch4.adb:12861–12893`, `exp_util.adb:13839–13947`). The preceding scalar
arithmetic/comparison transfers apply to the existing signed Standard types
with checks suppressed: the relevant cases depend on signed Integer kind,
not a 32-bit subtype, and the no-root-Length condition now holds. The
query-magnitude premise must include the wider types; a 32-bit digit bound
cannot be carried across this transfer.

`derive.py` records and sums the following rows. Builder cost includes a
saved original for rewriting and the smaller constant-result alternative.
The four attributes are charged once each even when two are analyzed early
for the explicit comparisons; later Analyze calls retain their Analyzed flag.

| One optimizer entry | Ordinary nodes | Growth | Uint appends |
| --- | ---: | ---: | ---: |
| Constructor nodes, including abandoned alternatives | `27` | `1` | `0` |
| Four First/Last analyses | `8` | `4` | `0` |
| Four unchecked conversion analyses | `8` | `4` | `0` |
| Two signed arithmetic analyses | `4` | `2` | `4` |
| One concrete comparison | `40*A+5` | `2` | `160*A+120` |
| Two explicit comparison queries | `40*A` | `0` | `160*A+120` |
| Range queries and cold power-cache allowance | `0` | `0` | `12*A+64` |
| Total | `80*A+52` | `13` | `332*A+308` |

Two initial Length analyses, the initial and narrowed comparisons, narrowing
construction/conversions/queries, two optimizer entries, the check builder,
static length arithmetic, conditional-raise analysis and final null rewrite
give **`280*A+144` nodes, 39 growing events, `1156*A+1262` Uint appends** per
length-check pass. There are no new lists, entities, names, Elists or String
values in these closed stages. Retained numeric digits must cover both the
query/arithmetic magnitude bound and `2^126` (nine base-32768 digits).

The ordinary String assignment's native overlap handling performs at most
two more Compile_Time_Compare queries when both sides are slices. With no
reason to require an element loop, it returns to the backend even when
overlap is possible (`exp_ch5.adb:341–900,3321–3337`). An optional generated
if around one assignment adds at most two nodes/one growth after condition
and child analysis: known conditions move existing statements or become null;
there is no elsif/else, controlled cleanup or return-statement optimization
(`sem_ch5.adb:1991–2157`, `exp_ch5.adb:4767–5037`,
`exp_util.adb:12192–12378,14018–14140`). Current-value bookkeeping only sets
fields; a generated assignment in Main does not record a library elaboration
scenario (`sem_ch5.adb:1065–1135`, `sem_elab.adb:13995–14009`).

Thus two length passes, overlap queries and the optional guard skeleton add
at most **`600*A+290` nodes, 79 growth events, `2472*A+2644` Uint appends** per
generated slice assignment, under the stated premises. Its direct syntax and
guard comparison are already counted in the direct/scalar aggregate. This
row deliberately excludes the slice's own analysis/copy/capture and incoming
subtype costs; it cannot yet be multiplied by source concat count to obtain
a whole-native bound.

### Source grammar, concat groups and replay boundary

The String grammar includes parentheses, so a nested concat can be a right
operand; it is not sufficient to count one expansion per source expression.
`Resolve_Op_Concat` resolves the first leaf, then each right operand before
processing its enclosing concat. Every operator's result base is Standard
String. A concat folded by Eval_Concatenation becomes a literal; otherwise
native `Expand_N_Op_Concat` defers a left-child concat, gathers its same-type
left spine and expands that group (`sem_res.adb:10570–10839`,
`exp_ch4.adb:8006–8095`). The grouping ignores parenthesis metadata; right
subtrees have already been resolved and expanded.

For one first traversal of a source String-expression forest with c binary
concat nodes, let its actual surviving native groups have arities n_i>=2.
Each group consumes n_i-1 distinct, previously unexpanded concat nodes, and
those sets are disjoint. Thus:

```text
group count g <= c
sum_i (n_i - 1) <= c
sum_i n_i <= c + g <= 2*c.
```

Parser/static folding can only reduce those source groups. This gives a
useful linear multiplier for direct **group** stages. It does not bound
operand-copy size, scalar query unfolding, String literal folding volume or
whole-program reanalysis. In particular, a native group having two retained
operands can still copy a large decorated view produced by a child group.

The grammar-to-current-syntax alternatives at that boundary are:

| Author form | Current native value entering a parent concat |
| --- | --- |
| Literal, including parser/semantic folded concat | String literal; separate literal subtype/value costs |
| Ordinary declared String name | Existing object reference, or a copied/reanalyzed generated renamed view |
| Standard Integer Image | Previously expanded buffer slice; scalar argument and runtime call live in earlier actions |
| Nonfolded child concat | Its new result object/view, optional result slice, or an already-resolved retained operand |
| Parentheses | The enclosed form, with parenthesis metadata |

The only author function returning unconstrained String is the first input
initializer; it is not a String atom in later expressions. The later name
does not cause arbitrary initializer substitution: Expand_Current_Value is
restricted to discrete types, and the late constant-String initializer
propagation copies only a literal. Native declaration rewriting can instead
record an already analyzed renamed object. A renamable captured function
result is an explicit dereference; its call remains in its capture initializer
(`exp_ch2.adb:124–236,372–533`, `sem_ch3.adb:5436–5453`,
`exp_ch3.adb:8603–8643,9485–9487`, `exp_util.adb:8896–8916,13793–13830`).

This narrows concat duplication to resolved values/views. It does **not**
make their later analysis free. `Expand_Renaming` copies Renamed_Object,
explicitly resets analyzed flags, then analyzes/resolves the copy
(`exp_ch2.adb:701–719`). A copied slice consequently may build another slice
subtype, capture a bound or follow a generated pointer renaming. Its syntax
and owned type decorations must use the decorated-copy transfer, followed by
the applicable replay transfer. Source object bounds also have an independent
native declaration path: Expand_Subtype_From_Expr uses an existing slice
index, a literal range, a constrained type or a new actual subtype; it cannot
be replaced by the GNATprove light model's Standard.String shortcut
(`exp_util.adb:5864–6115`, `sem_ch3.adb:5020–5159,5341`).

For the still-open grammar bridge, record per value both its syntax-tree
summary and its owned semantic-type/range summary, and record scalar query
roots through captured initializers and type bounds. A runtime bound such as
String length 4096 is not a bound on any of these graph sizes. The group-count
inequalities above apply to first source traversal only; all caller copying
before resolution, renamed-view replay and library-body/contract processing
must be accounted for before asserting a compilation-wide invocation count.

### Native runtime cache and direct helper seeds

The concat emitter's Str_Concat_2 through Str_Concat_9 and SS_Pool lookups,
plus the generated allocator's SS_Allocate lookup, give **ten entity seeds
in nine runtime units**. The eight concat specs contain only their ordinary
String procedure declaration and depend on parent System; Secondary_Stack
also names Parameters and Storage_Elements. SS_Pool and SS_Allocate map to
the same Secondary_Stack spec (`rtsfind.ads:3493–3498`,
`libgnat/s-conca2.ads` through `s-conca9.ads`, `libgnat/s-secsta.ads:32–111`).
Its private types and generic declaration remain real fixed-dependency
semantic work; this small seed list does not make that work zero.

For an available, correct installation, `RTE` caches a successful entity in
RE_Table. Every distinct seed can therefore enter Load_RTU at most once from
these direct calls; the following RTE_Available/RTE pair does not parse the
same runtime again. Load_RTU also checks the unit cache and only runs
Semantics if the selected compilation unit is not already analyzed. RTE
temporarily disables front-end inlining while loading
(`rtsfind.adb:1102–1215,1530–1635,1642–1672`).

There is a small cost **before** Load_RTU's unit-cache guard: its Priv_Par
initializer always creates an Elist header (`1022–1032`). The direct ten
entity cache misses can therefore allocate ten such headers, although only
nine different units are involved. Main has no private package ancestors,
so its Save_Private_Visibility adds zero elements. Recursive calls made
while analyzing runtime units need their own closure; this direct allowance
does not cover those calls.

`Maybe_Add_With` deduplicates implicit with clauses by both runtime unit and
current semantic unit. Repeated direct lookups in Main add at most nine
clauses, not one per concat. Every seed is a two-level System child;
Make_Unit_Name constructs at most three nodes, and the with clause adds one,
for **36 ordinary nodes** total. It appends to Main's existing Context_Items
list and creates no new header. RTE_Available suppresses this addition in the
selected non-SCIL mode (`rtsfind.adb:1236–1261,1266–1335`). Other semantic
units require a bound on distinct (requesting unit, runtime unit) pairs;
nine is not a compilation-wide with-clause bound.

No new array entry is appended to the fixed RE_Table or RT_Unit_Table.
Name interning, unit loading and semantic processing have separate costs;
the target package's successful parse already interns each selected entity
identifier. Failed availability queries can be retried and do not satisfy
the successful-cache invariant. The frozen tool/runtime identity and full
fixed-dependency parse/semantic/expansion envelope remain prerequisites for
using this cache result in a whole-native capacity predicate.

### Suppressed slice resolution after child analysis

The ordinary slice resolver has a closed suffix once prefix/actual-subtype
lookup and first bound analysis have been charged. Assume one-dimensional,
nonpacked Standard String; an explicit `N_Range`; exact Integer-base bounds;
no overload, implicit dereference, predicate, dimension, diagnostic or pending
check; all preexisting types frozen; and ordinary nonallocating placement.
The prefix is an ordinary aligned object-name view, with no build-in-place
function call. Checks are suppressed throughout. The initial bound trees meet the preceding
scalar-capture class. After any captures, their range has at most **t ordinary
nodes and l syntax lists**, no owned entities/itypes/actions, and no mutable
bound left that fails `Side_Effect_Free(Variable_Ref => True)`. The t/l bounds
must also cover a bound replaced by its one-node captured name.

Under these explicit premises, the suffix adds:

```text
ordinary nodes       t + 16
entities/names       4
syntax lists         l + 4
name characters      52, including NUL
growing events       2
Uint appends         4.
```

`Resolve_Range` resolves the already analyzed children and can fold each
static bound once, adding at most four nodes/two growth events. Its null-range
comparison is source-only and cannot apply to this artificial range
(`sem_res.adb:11161–11289`). The two following forced evaluations add at most
ten nodes/two entities/two lists by the scalar-capture transfer. A second pair
inside `Set_Slice_Subtype` does not recapture. Generalize that subtype transfer
to l input syntax lists: its `New_Copy_Tree` adds t nodes and l lists, followed
by the existing two nodes/two entities/two list headers and four-Uint size
allowance. Pure scalar conditionals may therefore retain their Expressions
lists; those lists are copied, not omitted.

Unlike explicit subtype declaration processing, this resolver calls
`Apply_Range_Check`, whose suppression guard returns **before** check selection
or construction (`checks.adb:3044–3074`). `Resolve_Implicit_Dereference` does
not add a dereference to an already String-typed prefix. `Eval_Slice` leaves
an `N_Range` unchanged, and ordinary nonpacked native slice expansion adds
nothing (`sem_res.adb:11809–12033`, `sem_eval.adb:4007–4046`,
`exp_ch4.adb:11367–11522`). First child analysis, allocating actual-subtype
lookup, enabled range checks, later freezing and action attachment remain
outside this row.

Composing with the preceding two-pass assignment-check/overlap/guard suffix
gives **`600*A+t+306` nodes, `l+4` lists, four entities/names, 52 name
characters, 81 growth events and `2472*A+2648` Uint appends** for one
new left slice plus those assignment suffixes. The RHS view still needs its
own analysis and any actual-subtype creation; this row is not a whole
assignment bound.

### Uncached actual subtype of an input-derived dereference

`Get_Actual_Subtype` first consults an entity's Actual_Subtype or a
dereference's Actual_Designated_Subtype. Its allocating unconstrained branch
does **not** populate either cache: it builds/analyzes/freezes a subtype,
associates it with N and returns it (`sem_util.adb:10270–10374`). Repeated
calls on the same uncached dereference must therefore be charged repeatedly.
The name of the helper is not a memoization guarantee.

A useful closed case is N=`P.all`, with Etype Standard String and no
Actual_Designated_Subtype, where P is an already analyzed, nonvolatile,
nonrenamed internal pointer **constant**, known non-null. Its named access
type, Standard String and scalar types are frozen. Neither N nor its original
node triggers the mutable-renaming exception. Its two-node syntax has no
owned type decoration, actions or pending checks. Assume the ordinary local,
no-diagnostic, nonallocating placement used above. This is a specified shape
of input-result capture, not a proof that every later reference has that
shape. The pointer type's creation and input call remain separate costs.

For this case, `Build_Actual_Subtype` constructs a fresh String subtype with
`P.all'First(1) .. P.all'Last(1)`. The first dimension is not omitted here.
Standard String has no fixed lower-bound index aspect
(`sem_util.adb:1192–1335`). Its direct construction costs thirteen ordinary
nodes: four copied view nodes, two attributes, two dimension literals, a
range, a subtype declaration/indication/mark and an index constraint. It also
creates one entity/internal name and three lists. Both duplication calls
return before side-effect removal: the special internal pointer-constant
exception accepts this dereference even with Variable_Ref=True
(`exp_util.adb:14270–14291`).

The two fresh attribute analyses add at most eight nodes/four growth events:
four nodes/two growth for the existing First/Last transfer, plus four/two for
the dimension literals' mandatory `Fold_Uint`. `Check_Array_Type` resolves
the literal 1, validates it and folds it; these direct small values allocate
no Uint (`sem_attr.adb:1975–2022`). Attribute evaluation consults only
`Get_Actual_Subtype_If_Available` and returns for this unconstrained prefix,
so it does not recursively call the allocating helper
(`sem_attr.adb:8727–8750`).

Each resulting bound has at most four ordinary nodes and one list. It is
pure under Variable_Ref: the pointer's internal-constant exception applies;
the attribute's argument is a literal; and there is no original mutable
renaming. The suppressed explicit String-subtype transfer therefore applies
with **b=8, l=2** after these attribute analyses. Its range check may still
construct an abandoned check, already included in that transfer. The index
layout uses existing Standard Integer fallback bounds. Finally, the explicit
`Freeze_Itype` contributes one node/list and the first array size check's
four-Uint allowance. Internal names use the earlier length-at-most-12 premise.
The complete helper envelope for this specified input is:

```text
ordinary nodes       20*A + 70
entities/names       2
syntax lists         8
name characters      29, including NUL
growing events       6
Uint appends         80*A + 159
Elists/String values 0.
```

`derive.py` composes the rows, including dimension folding and the explicit
freeze. Its A and numeric-magnitude premises are the earlier query/layout
premises. This is per invocation: no one-time cache assumption is used.
It excludes pointer capture for a mutable original renaming, incoming-view
decoration, input-function expansion, action placement, whole-scope/backend
work and the source-to-invocation multiplicity.

### Why a uniform incoming-view constant is not established

The ordinary concat lower-bound conditional spine is captured when its root
remains an if expression (`exp_ch4.adb:3176–3228`). That observation alone
does not establish a constant bound on all later value views or scalar bound
trees. `Side_Effect_Free` has an early case for a non-entity tree whose original
node names a mutable object renaming. When its Renamed_Object is a slice, the
case returns True **without walking that slice's bounds or prefix**
(`exp_util.adb:14479–14514`). Thus forcing a scalar attribute of such a view
need not collapse the whole attribute to a captured scalar constant.

This is relevant to the current grammar even though author renamings are
excluded. A concat marks its result OK_To_Rename and can return a slice;
the source declaration expander expressly permits rewriting an unconstrained
String object's initializer to a renaming of a slice of such a result
(`exp_ch4.adb:3441,3629–3632`, `exp_ch3.adb:8603–8643,9485–9487`). Later name
expansion copies and resets analyzed flags on that recorded view. First/Last
can simplify a compile-time bound or a bound that is already an entity, but
their native expansion does not replace every arbitrary pure bound tree
(`exp_attr.adb:4121–4201`).

No program family growing these bounds is asserted here: full reachability,
folding and subtype-replay induction remain to be proved. The specific
constant-size shortcut based solely on forced evaluation is unsupported.
Keep syntactic and owned-decoration summaries explicit, then establish a
source/declaration recurrence or a stronger simplification invariant. In
particular, the t/l premises in the preceding slice row and b/l premises in
the result-storage row are not discharged by this section.

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
