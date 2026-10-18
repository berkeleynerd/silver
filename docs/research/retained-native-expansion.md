# Native Main expansion allocation components

2026-10-17, continued 2026-10-18, #119. This component derives and composes
native Main constructor allocations, including concatenation's generated-action
analysis, scalar operations, declarations and assignments, loops, predicates,
Image and output wrappers. It supplies a source-derived common query envelope
and an executable constructor-vector sum. Common process metadata, physical
representations and later consumers remain separate obligations; this is **not**
a whole-program capacity predicate or a new admission limit. Counting generated
syntax alone misses allocations made while GNAT analyzes that syntax.

The source is GCC Ada commit
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The
[retained evidence](../evidence/unbounded-programs/retained-native-expansion-20261017/local-envelope.json)
records ninety-nine inspected files hash-checked against the complete source
manifest. Adjacent `derive.py` regenerates the arithmetic and lexical inspection
aid from that source directory. Its rows encode the manual control-flow argument
below; it is not an automatic reachability proof or a membership implementation.
No compiler, prover, Lean build or large program probe was run for this source
derivation. Independent reviews cover the frozen
[initial component](../reviews/review-retained-native-cbcd679320.md) and
[first delta](../reviews/review-native-delta-26b438ab5c.md); their scope does not
extend automatically to the later additions here. Whole-Main closure and
review of those later additions remain required.

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

### Main source-to-emitter multiplicity

For the admitted Main grammar under the native options above, the surviving
concat tree can be related to source operators. This does not extend to the
broader fixed runtime sources or to backend transformations.

The source parents that can contain a String constructor are an object
initializer, assignment value, equality operand, output actual or another
String constructor. The first input call takes only a literal. The native
paths resolve the actual child before the parent's expansion:

| Source position | Relevant source path |
| --- | --- |
| Object initializer | `sem_ch3.adb:4701,4748` analyzes/resolves E before initialization expansion |
| Assignment value | `sem_ch5.adb:790` resolves the String RHS; later access-type reanalysis branches do not apply |
| Equality/inequality operand | `sem_res.adb:9143–9144` resolves both String operands before comparison expansion |
| Output actual | `sem_res.adb:4480–4498,4651` resolves A, optionally after establishing a transient scope |
| Concat operand | `sem_res.adb:10570–10618,10625–10764,10804–10834` walks the left spine and resolves each other operand |

No source declaration/default/specification expression contains another
Main declaration or body, and there is no generic instantiation, frontend
inlining, target-name assignment or author conditional String expression.
The admitted ordinary declaration/assignment/equality/call semantic paths
do not make a pre-resolution deep copy of a raw String constructor.
`Resolve_Actuals`' deep default-argument copy is for an omitted library default
(`sem_res.adb:3985–3995`), not a supplied Main String actual; admitted calls
supply all their arguments. Source for-range preanalysis copies only scalar
ranges (`sem_ch5.adb:3207–3255`), which cannot contain String expressions.
The separate Main light-mode inventory independently confirms these shared
semantic source-parent observations; native costs still require the native
expansion argument here.

After child resolution, the current value is a literal, ordinary name or
the normalized Image/concat view described below. `Resolve` calls expansion
before returning (`sem_res.adb:3574–3605`); already analyzed roots return at
2547. `Expand` sets Analyzed before transient wrapping to prevent recursive
expansion of the moved node (`expander.adb:530–534`). Subsequent side-effect
captures and check copies use this current value. They do not traverse the
saved Original_Node as current syntax. The zero-macro-replay result below
excludes restoration through source String renamings. Current-value
replacement is also not such a route: `Expand_Current_Value` requires a
discrete type (`exp_ch2.adb:124–144`) and does not replace String objects.
Semantic folding can replace a constant String read with a literal, which
adds no concat or Image constructor.

Admitted if/for statements do not replicate their raw bodies. Ordinary for
loops analyze their statement list; their native Integer expansion has no
body cloning (`sem_ch5.adb:4227–4300`, `exp_ch5.adb:5841–6129`). Enumeration
representation, iterator-filter, predicate and Loop_Entry rewrites are absent.
If expansion removes or moves already analyzed branch lists and conditions
(`exp_ch5.adb:4767–5017`); it does not unroll them into raw expression copies.
Controlled-object handling does not introduce constructors for ordinary
Integer/String objects. Runtime trip counts therefore do not multiply
frontend concat expansions.

The native concat/Image emitters themselves construct no new `N_Op_Concat`
or Integer Image expression in Main: they return the normalized forms and
generate scalar helpers, runtime calls and assignments. The concat debug
tree-copy branch is disabled (`exp_ch4.adb:8069–8088`). Fixed imported
contracts/defaults and runtime-unit processing are separately charged; they
do not substitute unresolved Main actuals or inline Main source bodies.

Consequently, for **c source `&` operators**, native Main has

```text
g <= c
sum_i (n_i - 1) <= c
sum_i n_i <= 2*c.
```

Parser/semantic folding can only reduce these counts. For any nonnegative
per-invocation linear vector `p*n+q`, the Main aggregate is therefore at most
`(2*p+q)*c`, with zero calls when c=0. This closes the direct emitter's
source multiplicity, including the direct-copy vector below. It does not
bound the number or cost of every generated semantic helper, numeric query,
freeze, contract or runtime-unit action.

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
discriminant, representation, descriptor or Interfaces-array cases. A captured
scalar expression-with-actions may occur as an unrefined leaf, as explained
below. Every compile-time-known expression, including a queried scalar-type
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

This transfer also covers an internal scalar constant whose already analyzed
initializer is an expression-with-actions. `Determine_Range` follows the
initializer, then takes its ordinary unrefined `when others` case
(`checks.adb:5557–5560`); it does not analyze or visit the actions. Such an EWA
is not compile-time-known. `Compile_Time_Compare` returns Unknown immediately
when an exposed EWA fails `Cannot_Raise_Constraint_Error`
(`sem_util.adb:2409–2542`), while the inner `Is_Same_Value` walk has no EWA
recursion branch. Count that EWA as one leaf in the query graph. Its existing
construction/analysis costs remain separate; this extension does not copy or
reanalyze its action list and does not change the allocation formulas.

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

#### Query-specific weighted recurrence

The complete-syntax unfolding definition of A above is sufficient but can
grossly overcharge this native compiler. A sharper compositional recurrence
counts the work its two recursive workers actually perform. It operates on
the **original generated scalar-bound graph**, with initializer and index-bound
links derived from source and the native emitter. Check trees and temporary
literals manufactured by the query itself are outputs, not new inputs to that
graph. This separation is needed to avoid a circular capacity formula.

Define four natural-number summaries for each available scalar node, using
only previously established summaries of its dependencies. Sharing a summary
does not make its later use free: each traversed edge adds its weight again.

| Summary | Recurrence |
| --- | --- |
| D, range-query visits | One plus D of an internal constant's initializer; or of arithmetic/conversion operands; or of Length's two index bounds. All other relevant nodes contribute one. |
| U, range-query Uint appends | Sum of those same dependency U values, plus local weight 2 for unary minus/addition, 4 for subtraction, 6 for multiplication/Length, and 0 otherwise. |
| S, same-value visits | Apply Compare_Fixup **once** at this visit. Add one plus S of the resulting node's unary/binary operands; otherwise add only one. |
| F, same-value allocating fixups | Add one if this visit fixes a String-literal Last, plus the F values of the same recursively visited children used by S. |

Internal constants are followed before the range cache test, so D/U include
their initializer even when it is itself a known literal. Ordinary source
constant-name value lookup is read-only under the existing known-value
premise. First/Last, scalar if and EWA have no range-recursion arm.
In particular, an internal constant initialized by an arbitrarily large
scalar if has **D=2, U=0**. Neither its branches nor its condition are queried
by Determine_Range (`checks.adb:5142–5163,5304–5559`). A generated Length
does follow both index bounds, and an aggregate-length constant does follow
its addition initializer; those dependencies cannot be dropped.

Compare_Fixup is similarly not a transitive expansion. If it returns another
attribute, constant name, conditional or conversion, that result is a leaf
of Is_Same_Value. Only the unary/binary cases recurse into their operands.
For example, fixing Last to `Low + Captured_Length` visits the two scalar
operands, but does not unfold Captured_Length's initializer. Conversely a
range query of that internal name does follow its initializer. The two
walks therefore require distinct summaries
(`sem_eval.adb:995–1067,1078–1218`).

Take maxima over both comparison operands, their possible one-step
Compare_Decompose results, and the scalar-type-bound roots used by the
initial call and its at-most-four Rec=True calls. If Umax/Fmax bound those
summaries, the sharper complete comparison transfer is

```text
ordinary nodes <= 20*Fmax
Uint appends   <= 10*Umax + 20*Fmax + 60.
```

There are at most ten Determine_Range calls and ten Is_Same_Value pair
walks; each pair walk fixes both roots. The remaining arithmetic is the
existing twelve-entry allowance for each of five comparison calls.
Compare_Decompose examines only its root and at most one child
(`sem_eval.adb:940–978`), so no extra recursive allocation term is hidden
there. Independently, U<=6*D and F<=S. Taking
`A=max(1,Dmax,Smax)` therefore preserves every earlier A-based envelope while
avoiding the unrelated conditional/action/constant-initializer expansion
in the same-value walk.

`derive.py` encodes these recurrences on supplied compositional summaries and
checks their arithmetic. A repeated use of a captured length contributes
twice; capturing a conditional terminates the range walk. These examples
neither execute GNAT nor derive a full admitted source's bound graph. The
remaining bridge must build the summaries in source/elaboration order,
cover all generated helper-query roots and propagate numeric magnitudes.
Checked arithmetic may saturate at an established capacity cutoff, since
all these demand recurrences are monotone; that implementation choice does
not supply the missing source-correspondence argument.

#### Main source bridge for original String index bounds

The original String-bound graph has a source-sensitive D envelope without a
generic exponential syntax-unfolding factor. This bridge covers the index
bounds produced by Main's String constructors and declarations. It does not
yet cover every scalar query introduced by a subsequent check or actual-subtype
helper, and therefore is **not** a complete value for A in the combined vector.

The leaf seeds `(D(low), D(high))` are:

| Source form | Bound D seed | Source reason |
| --- | --- | --- |
| String literal, including a folded literal | `(1,1)` | The low bound and length are known values; a literal range has literal endpoints. |
| Standard Integer Image | `(1,2)` | The returned slice is `Snn(1..Pnn)`; forcing the mutable Pnn makes at most one internal constant initialized by that scalar variable. |
| Initial First_Or_Default binding | `(2,2)` | One internal scalar constant captures each of `P.all'First(1)` and `P.all'Last(1)`; neither attribute follows a scalar dependency in Determine_Range. |

The Image source is `exp_imgv.adb:1413–1430`, with range forcing in
`sem_res.adb:11983–12001,13127–13150`. A scalar constant name is already
side-effect-free, so later relaxed Force_Evaluation does not capture it again
(`exp_util.adb:7221–7243,14425–14455`). The scalar argument of Image affects the
runtime Pnn value, but is not an initializer dependency of Pnn's bound capture.
Its own source-scalar analysis remains separate.

For the input seed, object analysis invokes Expand_Subtype_From_Expr before
Find_Type_Of_Object (`sem_ch3.adb:5138–5145`). Its unconstrained-array fallback
calls Make_Subtype_From_Expr, which explicitly creates those two scalar
constants (`exp_util.adb:6102–6104,10943–11003`). The first duplicate captures
the function through one access type and constant pointer, rewrites it to
P.all, and leaves the pointer's designated type Standard String
(`exp_util.adb:12984–13121`). The pointer is known nonnull. Resolving the
ordinary generated dereference does not construct an actual subtype: that
special branch requires a source packed-array dereference
(`sem_res.adb:9351–9368`). Attribute evaluation consults only
Get_Actual_Subtype_If_Available; it returns the existing unconstrained type and
does not call the allocating Get_Actual_Subtype path
(`sem_attr.adb:8723–8744`, `sem_util.adb:10380–10410`). Neither First/Last
expansion nor Compare_Fixup substitutes unconstrained bounds
(`exp_attr.adb:4149–4173`, `sem_eval.adb:1025–1030`). Thus no hidden sequence of
actual-subtype bound captures sits below those seed attributes. Ordinary
String is noncontrolled and has no user-defined indexing; the special result
captures at `exp_ch6.adb:5696–5741` are excluded. The selected options exclude
frontend inlining and build-in-place expansion of this nonlimited result.
This is a bound-shape argument, not an allocation total for the input call.

An ordinary declaration alias **reuses** its initializer's bound descriptor.
For a slice initializer, Expand_Subtype_From_Expr refers to the existing slice
index type; Evaluate_Slice_Bounds only forces its already normalized bounds
(`exp_util.adb:5507–5527,5895–5913`). For a constrained initializer it either
reuses its type or declares an alias of that type, without recalculating the
bounds (`5929–5996`). This applies to immutable and mutable String objects;
later String assignment cannot change the object's subtype. Repeated aliases
therefore do not add D layers. Using the same alias twice in a concat still
adds its descriptor twice to the recurrence.

For a native n-operand concat group, let `L_i,H_i` be these descriptors for
the incoming normalized values. The following conservative envelope covers
the original bound graph through its first normalization:

```text
V_i = L_i + H_i + 2
G   = sum V_i + 2*(n-1)
L   = max(2, 2 + max L_i)
H   = G + L + 5.
```

`V_i` pays for the internal length constant and its Length attribute, whose
range query follows both operand index bounds. Each subsequent aggregate
step adds an internal constant and one addition, giving G
(`exp_ch4.adb:3015–3045,3054–3099`). Fixed lengths and folded aggregates are
smaller. A low bound is a known leaf, an operand First, an existing bound
entity after First expansion, or the captured lower-bound conditional. The
conditional contributes at most two D visits; the additional two in L also
allow one explicit last-operand conversion and one scalar capture. First/Last
expansion can replace an attribute only with an **existing entity occurrence**,
not an arbitrary copied bound expression (`exp_attr.adb:4149–4196`).

The nonnull high expression contributes three visits beyond its low and
aggregate (`low + (aggregate - 1)`). H conservatively adds another conversion
and scalar capture. A null-selector conditional, or its nonempty
expression-with-actions form, stops Determine_Range; capturing it adds one
visit. If a selector folds to its last-operand arm instead, `H_i+2 <= H`
covers that arm and its conversion/capture. Native expression normalization
can fold these roots, replace them by an existing constant, capture a variable
or arithmetic root once, or capture the conditional/EWA root. It does not
repeatedly capture an already constant name. The same stability explains why
subsequent declaration range forcing adds no descriptor layer. The normalized
view argument below supplies the current-bound syntax premise; these D
descriptors separately retain the initializer/Length dependencies hidden behind
small constant-name syntax.

Operand elimination and a completely folded result only reduce this envelope.
A conservative implementation can apply the binary instance at each source
`&`, without predicting GNAT's final retained operand count. Combining two
already summarized subtrees adds their H values, both L values, the new L
and 11; flattening an n-leaf group adds only `sum L_i + L + 4*n + 3` to
`sum H_i`. Each internal combination contributes positive extra low-bound
terms and at least the flattened constant allowance, so the binary source-tree
envelope dominates every grouping. A sharper implementation can preserve the
actual bound-shape summaries and known elimination/folding facts, then use the
previous D/U/S/F recurrences. The envelope does not require compiler queries
to decide language membership.

`derive.py` records the three seeds, zero-growth alias transfer and monotone
concat recurrence. It checks arithmetic examples, repeated incoming edges and
representative flattened/binary compositions. It is not a semantic test or
compiler execution. The next section closes S and generated-query roots for
the combined concat stages. Scalar-source queries, other constructors/helpers,
numeric magnitudes and the allocations needed to build and normalize this
graph remain separate. A bound descriptor is not payment for those allocations.

For the preceding `Get_Range_Checks` shape, `Not_Null_Range` invokes this
comparison at most once. Its other value and conditional-branch tests only
compare existing values. Thus the complete no-static-error selection adds at
most **2*b+28+20*A ordinary nodes, 2*l syntax lists and 80*A+60 Uint appends**,
with the earlier purity/no-owned-decoration premises. If both bounds are known,
the direct value-comparison route still allocates nothing. Enabled insertion
and analysis of the resulting check remain separate from selection.

#### Source-derived query roots for the combined concat stages

For the exact closed stages in the combined Main vector, a usable query-weight
parameter now follows from the preceding source descriptor:

```text
A = 3*H + 7,
```

where H is the conservative high-bound D descriptor of this source concat
group. A binary source-tree descriptor that dominates the group may be used
instead. This supplies the **query weight**, not a whole native capacity rule.
The numeric-magnitude premise and the listed unclosed semantic stages remain.

Here is the complete root inventory for these stages. The bounds include
temporary roots queried during initial analysis, before their final capture
or folding. A row's subexpressions have no greater D weight than its root
except where the querying operation deliberately treats that root as a leaf;
the independently analyzed scalar children of such a leaf are included in the
earlier rows, rather than silently omitted.

| Query-root family | D envelope | Source/transfer |
| --- | ---: | --- |
| Incoming index bounds; saved operand lengths; partial aggregate lengths; selected low, result high and optional null selectors, including first captures | H | Original-bound recurrence; `exp_ch4.adb:2870–3318` |
| Generated assignment low/high, before and after their boundary captures | H | `low + previous aggregate`, `low + (aggregate - 1)`; `exp_ch4.adb:3554–3569` |
| Literal or fixed Standard scalar subtype endpoint | 1 | Integer/Positive and the signed 32/64/128-bit narrowing types |
| First/Last on an incoming/result/assignment view, including an attribute rewritten to an existing bound constant | H | Unrewritten attributes have D=1; existing bound constants use the preceding rows |
| One regular check conversion around a bound | `H+1` | Range-check conversion sites; smaller than the Length-conversion row |
| Length on either side of the generated assignment check | `2*H+1` | One Length plus both source/target index bounds; `checks.adb:9969–10132,10251–10412` |
| A regular narrowing conversion around such a Length | `2*H+2` | At most one layer on each operand; `exp_ch4.adb:14372–14542` |
| Length-optimizer arithmetic and all its intermediate operands | `3*H+7` | At most two arithmetic nodes, with the shapes below; `exp_ch4.adb:14922–15040` |

For the assignment endpoints, the low has D at most L+G+1 before capture,
and the high at most L+G+3. A possible capture adds one; both fit
H=G+L+5. The original-bound row also covers each scalar child of the selected
low conditional spine: each condition compares a saved length with zero,
and each arm is an operand low bound or the next conditional. A scalar if
itself stops Determine_Range. No arbitrarily long initializer walk is hidden
inside its D=1 leaf.

The optimizer's two possible arithmetic shapes are
`Y'Last + (X'First - Y'First)` and `X'First + (Comp - 1)`.
It inserts one unchecked conversion around each relevant operand. In the
actual range worker these unchecked conversions are leaves; even charging
them conservatively as one recursive layer gives at most `3*H+5` in the
first case and `3*H+7` in the second, because Comp is a literal or one of
the preceding Length/conversion roots. The two explicit optimizer comparisons
use only the generated First/Last roots. The initial and narrowed comparisons
have Length roots; the rewritten comparison has these arithmetic/First/Last
roots and cannot trigger another Length optimization. There is no repeated
conversion spine. This is the same two-entry optimizer closure used in the
length-check allocation transfer.

The other query sites add no new root shape. Generated arithmetic overflow
analysis asks about its whole arithmetic root and, when necessary, its two
operands; same-type conversion range analysis asks about its operand
(`checks.adb:3325–3479,6283–6450`). Get_Known_Bound compares one operand low
with another low or a scalar conditional (`exp_ch4.adb:3176–3209`). The range
selector's Not_Null_Range compares the two endpoints, and its generated
condition compares copies/conversions of those endpoints with static Positive
bounds. Native slice-overlap analysis compares the existing slice endpoints
(`exp_ch5.adb:838–846`). No check-created scalar is stored into the original
String bound graph and used to define H.

Compile_Time_Compare also inspects a root after one Compare_Decompose step,
and at most four recursive comparisons against scalar-type bounds
(`sem_eval.adb:940–978,1592–1634`). Decomposition merely selects an existing
arithmetic child (there is no generated Succ/Pred here). The applicable types
are the fixed Standard signed types or generated String index subtypes, whose
endpoints are already in the table. These recursive roots therefore require
no larger D envelope. An early invalid/untyped/cache return only reduces work.

The independent S envelope is small. An original lower bound is a constant,
attribute, conversion or conditional at its root, so its same-value walk has
at most one visit, including one Compare_Fixup. A high or assignment endpoint
can expose the two arithmetic nodes of `low + (aggregate - 1)`; its low
has S<=1 and its aggregate is a captured name. Thus its S is at most five.
An attribute fixed to that high has the same five-visit bound. The fixup is
applied only once per visit: a resulting attribute/constant/conversion does
not unfold again. The optimizer's two-node arithmetic skeleton has at most
three such endpoint leaves, giving **S<=17** even if its conversions are
ignored rather than treated as leaves. Length roots, capture names,
conditionals and conversions themselves have S=1. Decomposition and recursive
scalar-type-bound comparison introduce no larger S shape. F<=S still holds.

Every concat descriptor has n>=2, L_i,H_i>=1 and hence H>=18. Consequently
3*H+7 dominates both D and S for every query in these combined stages.
The previous inequalities U<=6*D and F<=S justify substituting this source
value for A in all their allocation rows. Repeated alias uses are charged
by their repeated contributions to H; alias chains alone do not increase H.

`native_concat_query_roots` in derive.py checks the row arithmetic, the
assignment/capture inequalities and the two optimizer shapes. It does not
execute or simulate GNAT. This closure does **not** price or automatically
cover source scalar expressions, Image's argument analysis, the initial input
call, final runtime-call helpers, source String equality/assignment elsewhere
in Main, wrapper/scope work, fixed dependencies or backend processing.
Those paths need their own allocations and root inventories before reuse of
an A-based row. In particular, no 32-bit magnitude bound is inferred from the
Integer result type: Determine_Range can return a disjoint computed range
outside that type (`checks.adb:5585–5604`).

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
(`exp_ch7.adb:4226–4247`). Thus later constructors do not inherit an *active*
transient scope from the input declaration, but secondary-stack allocation of
their results remains reachable. It would be wrong to exclude that storage
branch from the absence of an active transient scope.

There is a distinct source caller that can create a new transient scope:
`Resolve_Actuals` calls `Establish_Transient_Scope (A, Manage_Sec_Stack => False)`
for a nonstatic concat actual of a procedure call before resolving A
(`sem_res.adb:4480–4498`). An admitted output call can take this path. The
absence of a caller inside the concat emitter therefore does **not** establish
nontransient placement for every admitted concat. Its nested constructor
actions and subsequent call wrapping require that separate placement transfer.

This induction concerns the current Main analysis context. It does not price
the input call's own actions or runtime-library body analysis. Conditional
action attachment and later Boolean EWA wrappers still use their separate
transfers; they are not transient scopes. The direct emitter multiplicity is
source-bounded above, while generated wrapper work remains separate. There is
no `Establish_Transient_Scope` call in the concat emitter or ordinary object
expander itself; the three Image calls belong to the excluded Put_Image/wide
branches (`exp_imgv.adb:1054,1868,1978`). These negative call-site observations
do not exclude the procedure-actual caller just identified.

For this specific output-actual caller, the fresh transient E_Block has
Uses_Sec_Stack=False: Create_Transient_Scope sets it only when the caller's
Manage_Sec_Stack argument is True (`exp_ch7.adb:4226–4247`). Main's earlier
input can set **Main's** Uses_Sec_Stack without setting that field on a newly
created child scope. Ordinary Integer Image and concat introduce no subsequent
unconstrained String-return call, controlled object or explicit request to
promote the new scope. The nested concat groups in that output actual therefore
use ordinary result objects. This does not exclude secondary allocation for
constructors analyzed directly in Main after the input declaration.

There is at most one such fresh output scope per source output call: an
already enclosing transient causes Establish_Transient_Scope to return, and
the generated Image/concat procedure actuals contain resolved values, not
unexpanded String concat roots (`exp_ch7.adb:4559–4585`). Pending action
placement itself adds no nodes or lists. Insert_Actions passes the existing
list to Store_Before_Actions_In_Scope; Store_Actions_In_Scope either stores and
analyzes it, or splices it into the existing list and analyzes only its new
entries (`exp_util.adb:8118–8128`, `exp_ch7.adb:8904–8921`). The actions'
creation and semantic analysis remain separately charged.

The **direct wrapper skeleton** adds at most five
ordinary nodes (one shallow relocation, block, identifier occurrence, handled
sequence and saved old call), two lists, one growing-slot event for rewrite,
one E_Block/internal name, thirteen name characters including NUL, and one new
scope-stack entry (`exp_ch7.adb:8723–8725,8799–8852,9529–9562`,
`atree.adb:2109–2153,2222–2272`). Make_Transient_Block inserts pending actions
with Clean=False and Manage_SS=False, so its insertion stage only splices the
existing lists; it does not generate finalizers or mark/release calls
(`exp_ch7.adb:5340–5440`). Its remaining local helpers now have the following
closure, under the ordinary analyzed-child/type premises of the components
whose actions it encloses:

- The first Push_Scope sets the new block's depth to its parent's depth plus
  one, with at most one Uint append. Make_Transient_Block pops that scope;
  Analyze_Block_Statement later pushes the same entity, whose depth is already
  set. These pushes are sequential, so the extra live scope-stack demand is
  one, not two (`sem_ch8.adb:9814–10008`). Pop_Scope and End_Scope restore
  links and empty action/use fields, without allocation on these paths.
- Insert_Actions_In_Scope_Around moves existing before/after lists without
  adding a wrapper. Freeze_All walks the existing entity chain. First
  freezes are charged once to their entity constructors, including any
  result-object size work; previously frozen entities without aspects add
  nothing. The selected Integer/Boolean/String objects and ordinary types
  have no nested package/task, subprogram/default-expression or finalizable
  access route (`freeze.adb:2539–2798`). Existing freeze-action lists are
  spliced and analyzed under their component's first-freeze charge.
- The rewritten block has the existing bound block identifier and an empty
  declaration list. The moved output call and inserted actions retain
  Analyzed. Analyze_Block_Statement/Analyze_Handled_Statements therefore do
  not replay their analysis (`sem_ch5.adb:1273–1434,4523–4598`,
  `sem_ch11.adb:388–447`). Empty Analyze_Declarations still has a postlude:
  Analyze_Contracts and Build_Assertion_Bodies each walk the empty list;
  Check_State_Refinements examines that same empty block declaration list
  (`sem_ch3.adb:2460–2480,2955–3022`, `contracts.adb:444–539`,
  `sem_util.adb:4786–4971`). None creates an assertion helper here.
- No deferred source constants, source block-local declarations, source
  assignments or source out actuals are introduced. Inspect_Deferred_Constant_Completion
  and Check_References are consequently nonallocating; the latter's Source_E1
  excludes the artificial entities. Last_Assignment is set only for source
  assignments/calls, so Warn_On_Useless_Assignments creates no warning for
  these entities (`sem_util.adb:15910–15942`,
  `sem_warn.adb:1177–1200,1240–1278,4739–4955`,
  `sem_ch5.adb:1229–1247`, `sem_res.adb:7174–7197`). General source diagnostics
  remain a separate component. Conditional statement tracking updates its
  fixed Saved_Checks_Stack; its saturating fallback clears cached checks
  without dynamic allocation (`checks.adb:4918–4975`).
- Requires_Cleanup_Actions finds no controlled, task, protected or finalizable
  access object. The block has no secondary-stack/custom cleanup flag and
  Expand_Cleanup_Actions returns before constructing a finalizer
  (`exp_util.adb:13501–13787`, `exp_ch7.adb:4632–4698`). **Is_RTE is
  nonloading, not necessarily nonallocating:** its Get_Unit_Name/Name_Find
  calls can intern `system.finalization_primitives%s` and `standard%s`.
  Charge those two fixed names once per process: two name entries and
  44 characters including NULs. Later lookups reuse the entries
  (`rtsfind.adb:643–761,778–878`, `uname.adb:181–419`,
  `namet.adb:1185–1275`). Ordinary types scoped in a local block do not
  introduce a third package-unit name on this path.
- Expand_N_Block_Statement appends one Name_Qualify_Units entry. Deferred
  qualification of generated types uses the separate per-type path transfer
  below; qualification of this ordinary block itself adds no name.

For **o source output calls**, charging every call even if no transient is
created, the local wrapper adds `5o` ordinary nodes, `o` growing-slot events,
`o` entities, `2o` lists, `o` Uint appends, `o` qualification-queue entries,
and `115o` dynamic slots. It adds `o+2` name entries and `13o+44` name
characters when o>0 (all zero when o=0). For maximum incoming scope depth d,
the Uint magnitude is at most d+1; require that increment to fit the selected
scope arithmetic and charge `o*digits_32768(d+1)` retained digits. This is a
closed local wrapper transfer, recorded as `output_transient_wrapper`; it
excludes the separately priced child creation/analysis/first freezes,
per-type qualification, original output-call processing and physical stack
bytes. The initial input wrapper and Main's secondary-stack cleanup remain
different paths to close.

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
| Ordinary declared String name | Existing object reference, including backend-handled object renamings |
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

This narrows concat duplication to resolved values/views. The existence of
Renamed_Object alone does not cause frontend replay: Is_Renaming_Of_Object is
a separate flag, excluded for these ordinary String objects as established
below. The earlier macro-renaming helper transfers remain conditional helper
results; they are not reachable Main addends merely because a declaration was
rewritten to a backend renaming. Source object bounds have an independent
native declaration path: Expand_Subtype_From_Expr uses an existing slice
index, a literal range, a constrained type or a new actual subtype; it cannot
be replaced by the GNATprove light model's Standard.String shortcut
(`exp_util.adb:5864–6115`, `sem_ch3.adb:5020–5159,5341`).

For the still-open grammar bridge, record per value both its syntax-tree
summary and its owned semantic-type/range summary, and record scalar query
roots through captured initializers and type bounds. A runtime bound such as
String length 4096 is not a bound on any of these graph sizes. The group-count
inequalities above apply to first source traversal only; all caller copying
before resolution and library-body/contract processing
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

### Ordinary renamings do not cause Main macro replay

The earlier concern about source object renamings rested on conflating two
fields. **Renamed_Object is not Is_Renaming_Of_Object.** The former stores
Renamed_Or_Alias; `Set_Renamed_Object` does not set the latter Boolean flag
(`einfo-utils.adb:98–107`, `gen_il-gen-gen_entities.adb:193`).
`Rewrite_Object_Declaration_As_Renaming` records the already analyzed view
but likewise does not set the macro flag (`exp_util.adb:13793–13830`).

A search of all manifest-pinned Ada source files finds exactly one setter of
Is_Renaming_Of_Object: `exp_ch8.adb:174`. It is guarded by Evaluation_Required.
That function returns False for an ordinary name or explicit dereference;
for a slice it recurses into the prefix unless the prefix is packed or a
full-access object. Its selected-component branch concerns representation
clauses, discriminants and full-access objects, none present in the admitted
String views (`exp_ch8.adb:105–174`). Newly generated ordinary object entities
start with this flag False. The native Main grammar and its String/Image/
concat helper shapes contain no operation that turns it on.

Consequently ordinary source and generated String renamings remain backend
renamings. `Expand_Entity_Reference` does not enter `Expand_Renaming` for them
(`exp_ch2.adb:410–418`). There are **zero frontend macro-renaming replays**
from these objects. An ordinary declared String reference remains an object
name rather than a copy of its initializer view. The original-renaming
exception in Side_Effect_Free also requires the same macro flag and cannot
apply (`exp_util.adb:14479–14514`). This eliminates that proposed obstruction;
it does not declare every possible caller copy/reanalysis free.

The separate eight-node mutable-macro-renaming transfer and uncached
P.all actual-subtype transfer remain valid under their stated general input
premises. They must not be multiplied by source object-read count for Main.
The first input initializer has its own dereference/capture processing, but
later reads of its declared binding are ordinary names.

`derive.py` hashes every searched Ada file against the complete manifest,
records the sole setter site, and verifies the inspected flag/renaming
sources. An independent source check confirmed this flag distinction. No
compiler execution or source-level counterexample was needed to refute the
mistaken reachability inference.

### Uniform normalized view and bound-copy shapes

A small value-copy bound now follows from the actual Main grammar. This is
about **current value syntax and its owned types**, not constant initializers,
Original_Node history, numeric query unfolding or accumulated abandoned trees.

The incoming native String value is a literal, an ordinary object name, or a
direct Image/concat result slice. The first input function is confined to its
own declaration; it cannot appear as a later String atom. Its declaration may
be a backend renaming, but subsequent source reads stay names. Image's scalar
argument and runtime call are preceding actions; its returned value is the
buffer slice. A concat returns a retained operand, a fresh result name, or a
slice of that result name. The secondary-stack result is also an ordinary
backend-renamed name. Parentheses add no node. No author slice, general
String-returning call or String conditional is admitted.

Every directly generated slice base is a mutable Image buffer or concat
result object. Side_Effect_Free with Variable_Ref=True therefore rejects a
slice view, independently of whether its current scalar bounds are pure:
Safe_Prefixed_Reference checks that mutable base. There is no macro-renaming
exception. Thus Force_Evaluation of a scalar bound containing First/Last of
such a slice captures the entire scalar bound, leaving a constant name.
A pure bound that survives can contain First/Last only of an ordinary name
view (a two-node attribute), or the more conservative three-node attribute
of a pure constant-pointer dereference. The latter allowance also covers
the specified input helper, although later String atoms do not need it.

Slice resolution performs this forcing before creating the slice's owned
index range (`sem_res.adb:11983–12001,13127–13150`). Generated scalar if
expressions may acquire arm actions during first child analysis; native
expansion wraps those actions before returning. Such an exposed nonempty
expression-with-actions is not side-effect-free and is captured too
(`exp_ch4.adb:6497–6553`, `exp_util.adb:14561–14566`). The elementary
Remove_Side_Effects branch still has the five-node transfer for an already
analyzed scalar root containing actions: relocation moves the entire
initializer, and later Analyze/Resolve return without processing its children.
Capturing removes those owned declarations from the returned bound-copy
shape; it does not erase their cumulative allocation costs. Empty wrappers
are removed by native expansion. No expression action or owned entity/type
remains within the normalized bound itself.

Known bound copying has another useful source-level simplification:
Compile_Time_Known_Value accepts, for these Integer bounds, only a current
integer literal or constant entity name whose value is recursively known
(`sem_eval.adb:1812–1918`). It does not accept an arbitrary arithmetic or if
tree. Copying a known Type_Low_Bound is consequently one current syntax node,
regardless of the size of its constant's initializer graph.

Standard String uses Ityp=Artyp=Standard Integer, so To_Artyp/To_Ityp do not
add conversions. The two explicit last-bound Convert_To calls can add two
syntax nodes each (`exp_ch4.adb:2727–2761,2821–2824,2994–3007`). The pure
surviving bound grammar therefore has these conservative bounds:

| Current normalized component | Ordinary nodes | Syntax lists |
| --- | ---: | ---: |
| Ordinary operand lower bound | 3 | 0 |
| Last operand First/Last including explicit conversion | 5 | 0 |
| Selected low before null selection | 3 | 0 |
| High before null selection: low + (aggregate - 1) | 7 | 0 |
| Low after optional null-result if | 12 | 1 |
| High after optional null-result if | 16 | 1 |
| Result bound pair | 28 | 2 |
| Assignment low: result low + previous aggregate | 14 | 1 |
| Assignment high: result low + (aggregate - 1) | 16 | 1 |
| Common slice range including range node | 31 | 2 |

The selected-low row does not grow with concat arity: Get_Known_Bound
captures its entire n-deep conditional spine whenever its root remains an
if expression. Otherwise it returns one operand lower bound
(`exp_ch4.adb:3176–3228`). The remaining arithmetic and null selectors add
only their explicit nodes. Any embedded nonpure view causes capture and
reduces these normalized bounds further. Integer Image's leaf-bound range
is smaller. This is a structural induction on direct nested String
expressions; declared String names do not recursively unfold their prior
initializer views.

A common view consequently has at most **34 current ordinary syntax nodes**
(one slice, a conservative two-node base, and a 31-node range), two bound
expression lists and exactly the slice's two owned subtype entities. Its
owned array index adds one occurrence and one list, and its scalar index
range copies at most31 nodes/two lists. The decorated-copy transfer gives:

```text
ordinary nodes       66
entities/names       2
syntax lists         5
pending Elist headers 1
pending elements     2
hash wrappers        3
Uint/String values   0.
```

Copying a First/Last/Length attribute with that view as prefix adds one
ordinary node: **67** without a dimension argument. Source names and
literals, the smaller Image view, and a concat's nonslice result fit the
same envelope. Source names have no owned local type merely because their
external nominal subtype is generated.

These are normalized copy sizes. The emitter can copy a low-bound expression
before first normalization; such a temporary may still contain an incoming
view. The scalar constructor counts above therefore do not alone price
every direct copy site. Nor do they bound the initializer graph A: captured
length/low-bound constants can still form a source-dependent DAG. Caller
copies before first resolution, compilation-wide invocation counts, enabled
slice checks, runtime dependencies and backend costs remain separate.

`derive.py` checks the component additions, the 66/67-node decorated totals,
and the pinned macro-flag setter inventory. This replaces the uncommitted
exponential value recurrence: declaration-name substitution is not the native
behavior for this grammar.

### Remaining direct copies, including raw bounds

The normalized value envelope also closes the remaining direct copy sites,
without prematurely using normalized scalar bounds for the emitter's raw
temporaries. Before first scalar analysis, an operand lower-bound attribute
can still contain a complete incoming view. Its decorated-copy cost is at
most 67 ordinary nodes, two owned entities and five lists. The last operand's
explicit conversion adds two current nodes, giving 69. The selected low bound
is either one operand lower bound or the one-node captured conditional-spine
name. The high bound adds four nodes to that low expression. The two optional
null selectors therefore have these decorated-copy envelopes:

| Raw component | Ordinary nodes | Owned entities | Lists |
| --- | ---: | ---: | ---: |
| Operand/selected low | 67 | 2 | 5 |
| Last operand bound with conversion | 69 | 2 | 5 |
| High before null selection | 71 | 2 | 5 |
| Low after null selection | 140 | 4 | 11 |
| High after null selection | 144 | 4 | 11 |

Each selector adds one conditional, its equality/aggregate/zero condition
(three nodes), one three-element list, and its two bound arms. These are
**decorated-copy** totals, including each embedded view's owned ranges; they
are not counts of current syntax alone. Distinct associated slice nodes give
at most two pending Elist headers, four elements and six hash wrappers.
The known scalar-bound copies at 2905/2976 and the last-literal copies at
2881/2886 are leaves. The `Get_Known_Bound` sites at 3179/3205 copy one
operand bound each; they do not copy the recursively assembled conditional
spine. The high-bound site at 3249 copies the selected low. The error and
assignment sites at 3453/3556/3561 copy the result low. Thus **144 ordinary
nodes, four entities/names and eleven lists** bounds each of the remaining
`4*n+4` direct copies.

No such direct copy occurs midway through action analysis. Before insertion,
the raw grammar above applies. After completed storage/action analysis, bounds
are either retained raw expressions or their smaller normalized/captured
forms; transient scalar arm actions have been normalized as described above.
The `New_Copy_Tree` of an object definition in `Find_Type_Of_Object`
(`sem_ch3.adb:19135`) is specifically inside `In_Spec_Expression`. Main's
native path instead relocates that definition (`19166`); this does not add a
second raw definition-tree copy.

The `2*n+2` direct `Duplicate_Subexpr` calls take incoming normalized String
values. They pass `Name_Req=True` and leave `Variable_Ref=False`
(`exp_util.adb:5323–5333,12527–12536`). Ordinary names and normalized views
are side-effect-free with those arguments; the macro-renaming exception is
unreachable. `Remove_Side_Effects` therefore returns before allocation
(`12718–12723`). Each duplication costs only the **66-node, two-entity,
five-list** decorated copy. Capture work from forcing a scalar *bound* remains
a different event and is not erased by this result.

Together, the remaining direct copies and duplicators contribute:

```text
ordinary nodes        708*n + 708
entities/names         20*n + 20
syntax lists           54*n + 54
pending Elist headers  10*n + 10
pending elements       20*n + 20
hash wrappers          30*n + 30
name characters       260*n + 260, including NUL
growth/Uint/String     0.
```

The earlier direct/scalar/storage aggregate can add this vector; its own
premises still require first raw-bound analysis/captures and exclude final
call/assignment analysis, later freezing, placement and whole-source
multiplicity. This is a closure of the direct copy addend, not of those
semantic costs. The script checks these additions for representative `n`
without running a compiler.

### First raw-bound analysis and capture

The Main normalized-view invariant closes the outstanding first scalar passes
without replaying the resolved String prefix or manufacturing conditional arm
actions. This refinement is specific to these native generated bounds; it is
not a statement that arbitrary copied syntax is already analyzed.

An incoming literal/name/Image/concat value has completed child resolution
before the enclosing emitter runs. A returned slice's final Resolve calls
Freeze_Expression after Set_Slice_Subtype (`sem_res.adb:3574–3605`). Its
generated array/index pair has the no-delayed-freeze properties established
above: Ensure_Defined only inserts an itype reference, and ordinary freezing
sets Is_Frozen without constructing a Freeze_Node. New_Copy_Tree's node worker
uses New_Copy and preserves Analyzed; it never clears that flag
(`sem_util.adb:24637–24721`). Its owned-itype worker clears Is_Frozen **only if
a Freeze_Node exists**, which this pair lacks (`25279–25305`). Therefore a
copy of the normalized String view retains both its completed node analysis
and its frozen ordinary type state. Analyze and Resolve return before
revisiting such a prefix (`sem.adb:104–116`, `sem_res.adb:2545–2551`).

The new scalar syntax outside those prefixes consists only of known
literals/constants, First/Last, exact Integer conversions, `+`/`-`, the
generated Eq/Ne conditions and scalar if expressions. First/Last analysis
does not allocate an actual subtype, and frozen prefixes cannot introduce
freeze actions. The artificial-attribute universal-check guard returns.
Strict Integer arithmetic records any overflow check for the backend; it does
not insert an action into a dependent branch. Exact-type conversions likewise
add no range-check syntax. Thus these first scalar child passes leave the
conditional's Then_Actions/Else_Actions empty. Integer is a definite copy
type, so its initializer conditional does not enter the non-copy-type object
declaration optimization (`exp_ch4.adb:5774–5797`). The earlier no-arm-actions
scalar conditional transfer consequently applies, including in the two
enabled plain-storage bounds.

Actual scalar capture happens after those passes, at the range boundary.
Constrain_Index's explicit N_Range path invokes Process_Range_Expr_In_Decl
without a Subtyp argument (`sem_ch3.adb:15345–15364`); its Force_Evaluation
therefore uses an internal serial name, not a derived `_FIRST`/`_LAST` name
(`22588–22600,22706–22718`). Two result-storage bounds need at most the
existing two scalar-capture transfers: **ten nodes, two entities/names, two
lists and 26 name characters**. Capturing an already analyzed root moves its
initializer and does not analyze its children again. A second force returns
on the new constant name. The assignment-slice transfers already charge their
own captures; the final result slice remains separate.

Each of the `4*n+4` remaining raw copy trees has, outside its already analyzed
String prefixes, at most the following scalar operator occurrences:

| Scalar class in one raw copy | Count | Additional nodes | Uint appends | Growth | Lists |
| --- | ---: | ---: | ---: | ---: | ---: |
| Add/subtract | 3 | 6 | `18*A+6` | 3 | 0 |
| Exact Integer conversion | 2 | 4 | `12*A` | 2 | 0 |
| First/Last | 2 | 4 | 0 | 2 | 0 |
| Equality | 1 | `40*A+5` | `160*A+120` | 2 | 1 |
| Scalar if | 1 | 2 | 0 | 1 | 0 |
| **Total** | | **`40*A+21`** | **`190*A+126`** | **10** | **1** |

The worst raw high has two main arithmetic nodes, the optional last-null-
literal subtraction, the last-bound conversion and two bound attributes, one
null-selector Eq and one if. The table allows a second conversion too. The
lower-bound selector spine itself is captured in its original declaration;
the direct copy sites copy an operand lower bound or the capture name, never
that entire spine. Known-value copies and already analyzed copies are smaller.
Copied owned-range fields belong to the frozen prefix types; they are not
additional first scalar-analysis roots. The `2*n+2` direct value duplications
also retain Analyzed and need no new value analysis. Literal/name leaves add
no further syntax or Uint appends under the existing frozen/known-value
premises.

The node/Uint transfer charges the enabled arithmetic/conversion allowance,
even at suppressed sites. Generated Eq/Ne retains its earlier comparison
transfer with enabled checks too: its children have exact Integer types, no
pending range check and no root Length shape, so comparison resolution and
strict native expansion add no check route. The one equality list is paid
even where no equality survives. The input syntax/copy allocation is already
charged separately. Each original scalar node has the earlier direct first
pass; every copied unanalysed scalar occurrence gets this additional pass.
Later scalar captures and check copies preserve Analyzed. No factor depends
on a source loop's execution count.

An output transient scope does not invalidate these local scalar transfers:
none of the scalar nodes is its Node_To_Be_Wrapped (the output call is), and
the relevant types are frozen. Their only possible new actions are the
separately charged boundary captures, placed through the preceding pending-
action transfer. Input/output wrapper helpers and later whole-scope freezing
remain separate. A still must cover every actual query root, and the numeric
and no-diagnostic premises are unchanged.

`raw_bound_semantics` in derive.py checks these sums and adds the two storage
captures. This closes first raw/copied scalar-bound analysis and capture in
the combined stages below. Their query-root weight is supplied by the scoped
source-derived closure above. Image/input construction, final call/result-slice
processing and their additional queries remain separate.

### Result-object freezing and constrained actual-subtype lookup

The generated concat objects close their own first-freeze cost after the
previously charged subtype/access-type freezes. The plain result object has
no initializer, address/aspect, foreign convention, static-allocation flag or
delayed freeze. It is a local internal ordinary String object. Its declaration
and default-initialization paths, already inspected in the storage transfer,
set none of those properties. The secondary result is a constrained renaming;
its allocator pointer object's separate zero-cost freeze is established above.

`Freeze_Entity` first freezes the object's existing type, then calls
Freeze_Object_Declaration for an ordinary object declaration
(`freeze.adb:6938–6958`). Categorization and address checks have no applicable
local aspect/import case. The abstract/volatile/TLS/foreign-enum branches are
absent. Check_Large_Modular_Array reaches its Is_Modular_Integer_Type guard
and does nothing for the signed Integer index (`4306–4350,4518–4714`). The
static-object branch is false, and Layout_Object is explicitly empty
(`freeze.adb:6992–7008`, `layout.adb:225–229`). There is no initialization
compound statement to explode: that creation route is for a C++ constructor,
not this uninitialized String object (`exp_ch3.adb:8493–8529`,
`freeze.adb:2497–2523`). No delayed freeze means no freeze node/list; the
common debug-information tail only sets existing flags
(`freeze.adb:8265–8286,8363`, `sem_util.adb:28572–28713`).

Thus first freezing of the plain result object adds **zero core-table
allocations**. Repeated freezing returns immediately. The same zero charge
applies to the constrained renaming object itself: it does not invoke the
ordinary object-declaration helper, its type is already frozen, and object
layout is the same no-op. This result does not price Freeze_All's scope walk,
name qualification, backend materialization or input/output wrapper helpers.

Actual-subtype lookup also allocates nothing for the normalized String values
used by this emitter's assignment/result-slice suffixes. A literal or resolved
slice already has a constrained type. A declared String name receives its
initializer's constrained actual type in Set_Etype(Id, Act_T)
(`sem_ch3.adb:5138–5145,5341`), with the declaration/type-reuse bridge above.
The plain concat result is explicitly constrained; the secondary result names
ConstrT. These remain object names, not macro-expanded initializers. Therefore
Get_Actual_Subtype **on that current value** returns an already available Actual_Subtype or the existing
constrained nominal type, before its allocating unconstrained branch
(`sem_util.adb:10270–10374`). This establishes the lookup premise of the
generated length checks and final result slice. It does not make an explicit
Get_Referenced_Object traversal free: that helper follows Renamed_Object even
without the macro-renaming flag (`sem_util.adb:11265–11278`). In particular,
Expand_Assign_Array invokes Get_Actual_Subtype on each referenced object,
rather than on the source name (`exp_ch5.adb:346–355`). A RHS input binding can
therefore expose its uncached unconstrained P.all and requires the earlier
`20A+70` node/two-entity/eight-list/six-growth/`80A+159` Uint actual-subtype
transfer **per assignment**. Charge one such transfer for each of the at most
n generated concat slice assignments. Their left result slice is constrained;
other RHS views are constrained or literals. This extra lookup does not replay
the input call or any source constructor, and its two fixed-view bound
attributes fit the existing query envelope A. Ordinary source assignments
need the same allowance separately.

### Enabled final result slice

The final result at `exp_ch4.adb:3629–3638` is a result-object name or one
slice of that name. It is distinct from the up-to-n suppressed assignment
slices. Slice_Rng is present only when the original low bound is compile-time
known, the original high is not, and the finite known upper length yields a
fitting static buffer high (`3295–3318`). The result object therefore has
known scalar index endpoints in this branch. Checks on the final range can
be enabled, even if construction of an earlier storage helper suppressed them.

The no-slice name has no new core-table cost after its directly charged syntax
and the zero-cost result-object freeze. For the slice, prefix resolution uses
that same object freeze and the nonallocating actual-subtype lookup. The
original range's first scalar nodes were already charged in the direct scalar
transfer. Its possible captures and normalized t/l range copying use the
ordinary slice-resolution suffix. Both target endpoints are static signed
Integer values, so the earlier enabled range-check transfer generalizes from
Positive without changing its allocation vector: the target First/Last
attributes fold known existing endpoints, and their base is the same Integer.
The no-static-error and other existing local premises continue to apply.

Apply_Range_Check calls the same range selector, then inserts its one possible
dynamic conditional raise with Insert_Action (`checks.adb:3044–3158`). Add
**one insertion-wrapper list**, which the prior declaration-specific
Insert_Range_Checks did not need. Its potential diagnostic/error alternatives
are excluded by the same no-static-error premise, not by assuming suppression.
Resolution then creates/freezes the ordinary slice subtype pair as previously
charged; no extra freeze node is requested. The output call's transient wrapper
does not wrap this child slice independently.

For normalized range size t and l syntax lists, composing the existing
suffix with the enabled check for b=t-1 bound nodes gives:

```text
ordinary nodes       140*A + 3*t + 91
syntax lists         3*l + 7
growing events       23
Uint appends         596*A + 424
entities/names       4
name characters      52, including NUL.
```

There are no new Elist/hash/String values in this suffix. Use t=31,l=2 for
**140*A+184 nodes and thirteen lists**. At most one final slice occurs per
native concat invocation; charging it even on no-slice/helper/early-return
paths is conservative. Its query roots are existing result bounds, their
check conversions and static target endpoints. They are included in the
preceding root families, so A=3*H+7 remains sufficient. Numeric magnitudes,
action/wrapper helpers beyond the closed placement paths, runtime-call
processing and later whole-scope/backend costs remain separate.

`enabled_final_slice` in derive.py sums these existing transfers and the
insertion list. The combined vector below now includes this suffix once and
the zero-cost result-object freeze/actual-subtype lookup bridge. No compiler
probe is used to justify the allocation count.

### Ordinary runtime concat procedure call

The helper-call branch passes a result name followed by r<=9 normalized
String operands to System.Concat_r.Str_Concat_r. Its spec has exactly those
unconstrained String formals, the result in OUT mode and all operands in IN
mode. It has no defaults, contracts, access/tagged formals, foreign convention,
renaming, intrinsic status or Inline pragma (`libgnat/s-conca2.ads` through
`s-conca9.ads`). The emitter moves the resolved operand nodes into the actual
list; it does not clone or restore their original source constructors
(`exp_ch4.adb:3492–3544`). The directly emitted call/name/actual-list syntax is
already charged.

Assume the selected runtime spec and its formal types have been loaded and
frozen under the fixed-dependency charge; this does not make runtime loading
or its first spec processing free. Ordinary Main placement, resolved frozen
values, no pending checks/diagnostics, and the selected native defaults remain
premises. In particular, Validity_Check_In_Params, Validity_Check_In_Out_Params
and Check_Aliasing_Of_Parameters are False (`validsw.ads:72–79`,
`opt.ads:268`). There is no frontend inlining or GNAT debug override.

The complete local call route has the following costs and exclusions:

| Stage | Source reason and allocation effect |
| --- | --- |
| Procedure-call analysis | Prebound procedure name and already analyzed operands; Analyze_Call takes its one-interpretation branch. Normalize_Actuals returns on exact positional arity; the first Add_One_Interp sets fields without an interpretation-table entry (`sem_ch6.adb:1610–1725`, `sem_ch4.adb:1329,3918–4333`, `sem_util.adb:25844–25943`, `sem_type.adb:443–460`). |
| Actual resolution | Resolve returns for moved analyzed values. All formals are unconstrained Standard String, so selected length/range checks construct no condition; Standard String has no fixed-lower-bound aspect. No scalar query, actual-subtype allocation or new transient scope results (`sem_res.adb:4240–4310,4480–4652,4856–5040`, `checks.adb:1318–1370,10251–10412,11197–11325`). |
| Extra formals/actuals | String has no discriminants, anonymous-access formals or accessibility/BIP result; the extra-formal set is empty. Rechecking it only sets/reads the known flag, and Create_Extra_Actuals has no extra parameter to construct (`sem_ch6.adb:8797–8831,9287–9400,10227–10231`, `exp_ch6.adb:5210–5227`). |
| Native actual expansion | Expand_Call_Helper allocates an empty Post_Call list, then Expand_Actuals allocates another, replacing the first list identifier. **Both headers count.** Neither list receives an action for these actuals (`exp_ch6.adb:2675–3115,4571–4574,5227`). |
| Copy/contract routes | The OUT actual is an ordinary aligned result name; IN values are ordinary aligned String names/literals/slices. No packed/unaligned/atomic/volatile/storage-model copy, conversion, predicate, invariant, BIP/controlled result, dispatch or remote-call route applies. The result object's first freeze is already closed. |
| Return from expansion | With an empty post-call list, Insert_Post_Call_Actions returns before construction. No intrinsic, inherited, protected, null-procedure or inlined-body rewrite applies (`exp_ch6.adb:5249–5743,8098–8104`). |

Two bookkeeping costs remain even though the actual values are resolved.
Resolve_Actuals examines a source entity-name operand **before** its Resolve
call. For each such mutable source-name operand it can build a fresh
Variable_Reference_Marker and Insert_Action list
(`sem_res.adb:4240–4274`, `sem_util.adb:23907–24032`,
`sem_elab.adb:3782–3851`). The marker analyzer is a no-op and it has no native
expansion; its scenario recorder adds no scenario-set entry at Main's local
declaration/subprogram level (`sem.adb:638`, `expander.adb:519–522`,
`sem_elab.adb:14015–14030`). Charge **one ordinary node and one list per
operand**, regardless of whether a particular operand qualifies. Marker
placement uses the already closed ordinary/pending action path.

The same pass calls Generate_Reference on each source-name operand. For an
ordinary Main String object, charge **one positive Xrefs-table increment per
operand**, without deduplication credit. Add_Entry increments the table before
testing duplicates; its set links live in the Xrefs records with a fixed
65,536-header table, so there is no separate dynamically allocated set wrapper
(`lib-xref.adb:188–206,1160–1198`). The second structural Add_Entry route
requires an end reference to a package/concurrent entity and is excluded.
The generated result-name and runtime-call-name references fail the
source-reference gate; they create no Xrefs entries. An independent source
review confirmed this per-reference primitive bound. The light-mode xref
inventory does not pay for these additional native calls.

The generated call itself needs no Call_Marker. It is not Comes_From_Source,
and Str_Concat_r is none of the Ada-semantic, bridge or SPARK-semantic target
classes (`sem_elab.adb:3563–3700,14397–14474,14663–14668`). This distinction
does not suppress the source-operand variable markers above. Ghost argument
preanalysis likewise requires a source call in a Ghost region and is excluded
(`ghost.adb:2325–2373`).

Fixed runtime unit-name interning must also be in the dependency baseline:
Expand_Call_Helper asks Is_RTE about Raise_Exception even for these ordinary
calls (`exp_ch6.adb:4620–4643`). That helper does not load a unit, but its
Name_Find calls can intern fixed dependency names, as in the output-wrapper
closure. A loaded/frozen concat spec alone does not establish that every such
name already exists. The per-call vector below is for variable Main demand,
with these fixed names charged separately; it does not claim zero first-use
name allocation for the entire process.

The local call envelope is therefore **r ordinary nodes, r+2 lists and
r positive Xrefs increments**, with zero new entities/names, growth events,
Uint/String values or Elists. Use the original n>=r for a linear per-emitter
envelope. No additional scalar query root is introduced; A=3*H+7 is unchanged.
This closes local call processing, not first runtime lookup/spec processing,
wrapper/scope helpers, diagnostics, backend call lowering or physical stack
storage. `native_runtime_concat_call` records the separate table dimensions
and is now included in the combined vector.

## Initial native Integer Image construction

For each source `Integer'Image(E)`, its scalar argument E is analyzed and
resolved before native Image expansion. Its original source semantic/numeric
cost remains a separate source-expression charge. The following closes the
generated constructor after that child has been resolved; it does not replay
E or bound its source processing by a constant.

The prefix is predefined Standard Integer32, without a Put_Image aspect.
Analyze_Image_Attribute resolves E against its base type
(`sem_attr.adb:1541–1618`). Semantic Image folding applies to enumeration
literals, not Integer (`9725–9751`), so the ordinary native path runs even for
a known Integer literal. Image_Should_Call_Put_Image returns False, and the
emitter selects RE_Image_Integer/Standard_Integer
(`exp_put_image.adb:1247–1286`, `exp_imgv.adb:1113–1116`). It emits

```ada
Snn : String (1 .. Integer'Width);
Pnn : Natural;
Image_Integer (Integer (E), Snn, Pnn);
-- expression result: Snn (1 .. Pnn)
```

All inserted actions and the returned slice use Suppress=>All_Checks
(`exp_imgv.adb:1265–1437`). The fixed runtime spec is already loaded/frozen
for this local transfer. System.Img_Int.Image_Integer renames the
System.Image_I instance's procedure with formals Integer, in-out String and
out Natural (`libgnat/s-imgint.ads:36–47`, `libgnat/s-imagei.ads:36–48`).

The direct constructors, including both shallow moves of E, the optional
conversion/mark, and the saved original Image root, cost at most **24 ordinary
nodes, two entities/internal names, three lists and one growth event**. The
names occupy at most26 characters including NULs. No recursive argument copy
is made. Standard Integer'Width folds to11: its absolute endpoint maximum is
2147483648, the divide-by10 loop iterates nine times, and UI_From_Int stores
the resulting11. At most12 Uint appends cover two absolutes, nine divisions
and that conversion (`sem_attr.adb:11038–11337`). Charge the width fold and
four extra static-leaf folds with ten nodes/five growing events; range-stage
fold charges below deliberately overlap those extra allowances.

The scalar conversion is either a relocation of an already exact Integer
operand or a conversion from an ordinary subtype of that same base. In the
latter case the semantic static fold costs at most two nodes/one growth; if
it stays dynamic, the native identical-type branch removes it or the ordinary
discrete-conversion branch returns under suppression. There is no integer
promotion (the base size is already Standard_Integer_Size), universal-integer
operand, predicate, fixed-point or representation conversion
(`sem_res.adb:12440–12480,13343–13412`,
`exp_ch4.adb:11570–11617,12107–12320,12783–12853`). Thus the same two-node,
one-growth envelope covers a constrained source Integer operand too. E
retains Analyzed in every shallow move; any original pending checks belong to
E's already charged processing, not a second scalar-expression traversal.

The buffer declaration uses the previously closed plain String-storage
transfer with b=3,l=0, overcounting the two static bound leaves by one. Its
only incoming scalar endpoints are1 and11. The selected range-check template
has at most the seventeen-visit same-value spine already established above;
its range-query roots are smaller. **A=17 is therefore a derived fixed
template bound here**, rather than a cap on the source scalar argument.
Its plain branch contributes `140A+89` nodes, three lists,23 growths,
`596A+519` Uints, two entities and33 name characters. First subtype and
ordinary object freezing are included. Pnn's existing frozen Natural subtype
adds no itype; internal-object default initialization is skipped, and its
first ordinary object freeze runs the no-op Layout_Object. The same
ordinary scalar capture skeleton applies when the final slice captures Pnn
as a constant of that existing subtype.

The runtime call has no default/access/tagged/controlled formals, predicates,
contracts, foreign convention or frontend Inline requirement. Both source
and ultimate-alias signatures have the same types; alias replacement sets
the existing call-name entity and creates no new actual conversion
(`exp_ch6.adb:5253–5399`). Pnn's Natural formal/actual subtypes match, so the
scalar copy-back check has no copy action. String is unconstrained, the
buffer is aligned, and all range checks are suppressed. The two empty
Post_Call lists still count. Charge three possible variable markers/xref
attempts and one additional call marker/list conservatively: **four nodes,
six lists and three positive Xrefs increments**. Any such marker's recorder
is excluded from library-level scenario allocation by Main's local dynamic
scope, as in the concat-call transfer. Fixed Is_RTE unit-name lookups remain
in the dependency baseline. The final slice has the existing buffer's actual
subtype and range `1..Pnn`; the closed suppressed suffix at t=3,l=0 adds19
nodes, four entities,52 name characters, four lists, two growths and four
Uints, including its possible scalar capture and copied index range.

Adding these stages yields, per source Integer Image:

| Demand | Bound |
| --- | ---: |
| Ordinary nodes / growing events | 2528 / 32 |
| Entities/internal names / name characters including NUL | 8 / 111 |
| Syntax-list headers | 16 |
| Uint appends | 10667 |
| Positive Xrefs increments | 3 |
| Dynamic slots | 23528 |
| Elist/hash/String values | 0 |

The generated numeric computations use only the static endpoints and the
small closed check template; the earlier magnitude derivation with A=17
gives `(16*17+8)*2^127`, at most ten base32768 digits per append. Thus charge
106670 retained Uint digits per Image, without charging source E's numeric
work here. The normalized result descriptor remains `(L,H)=(1,2)` and the
local view has no constructor recursion. The number of native Image
invocations is at most the source Image count by the earlier analyzed-child
multiplicity argument. `native_integer_image` emits this additive vector.
Action placement/output wrapping, deferred qualification of the generated
types, fixed dependency processing and backend/physical stack demands are
separate already identified composition terms; the initial input constructor
and Main cleanup still need closure.

## Deferred name qualification for ordinary Main scopes

The generated output block has a further table dimension beyond the earlier
direct skeleton. Expand_N_Block_Statement calls Qualify_Entity_Names, whose
entire body appends one Node_Id to **Name_Qualify_Units**
(`exp_ch5.adb:3467–3470`, `exp_dbug.adb:53–59,1551–1554`). Charge **one queued
entry per expanded block**, even if another queue entry will eventually visit
some of the same entities. This append is not a Name_Entries append and must
be compared with its own Nat-indexed table's headroom. The whole-program enqueue
count also needs the Main/subprogram/fixed-runtime calls; it cannot be inferred
from the block count alone.

Actual qualification is deferred to Qualify_All_Entity_Names. It visits each
queued scope and its existing First_Entity chain, without allocating a work
list (`exp_dbug.adb:1163–1208`). Under the ordinary Main scope graph, this
processing has a closed name-storage transfer:

- Main is the sole source subprogram. Local scopes are E_Block/E_Loop. Source
  scalar/String objects, loop indexes and generated object/renaming entities
  are local to these dynamic scopes. They take Qualify_Needed=False, set
  Has_Qualified_Name and return **without interning a name**.
- Generated types require full qualification through their scope path to
  Main. Main itself likewise uses the full-qualification branch. Each
  qualifying entity invokes Name_Enter **at most once**; future visits return
  on Has_Qualified_Name (`1214–1545`). Intermediate recursive scope-prefix
  construction does not intern intermediate names.
- These entities have no Debug_Renaming_Link. In particular, the generated
  constrained concat-result renaming's debug helper already returned Empty,
  before creating a debug variable. The special two-name debug-renaming branch
  is therefore excluded, rather than charged as an ordinary local object.
- There is no body-nested package on a Main-local scope path and no same-scope
  overload. The only explicit Has_Homonym setters in the pinned Ada sources
  are Enter_Overloaded_Entity's distinct-profile branch
  (`sem_ch6.adb:9693–9694`); none of these local types, objects, loop/block
  scopes or the sole Main declaration enters that case. Generated internal
  identifiers are fresh. Source shadowing in a different loop scope does
  not create an overloaded declaration. The fixed **256-character**
  Homonym_Numbers buffer therefore remains empty for this transfer, and no
  BNPE/homonym suffix is appended (`exp_dbug.adb:113–117,196–227,1099–1129`).

For an entity e requiring full qualification, let its finite scope path contain
Main, any enclosing generated block/loop scopes, and e itself. Let l(x) bound
each member's original unqualified name length, supplied by the corresponding
constructor. Then

```text
Q(e) = sum l(x) on that path + 2*(number of path members - 1)
```

bounds its qualified name. The two-character separator is `__`. Reusing an
already fully qualified prefix only substitutes that same bounded path prefix;
it does not concatenate its scope a second time. Get_Unqualified_Name_String
uses the unqualified suffix of an already locally qualified name. Thus require
`Q(e)<=32767` (Name_Entry's Short length) and
`Q(e)<=Name_Buffer'Length`, then add **one name entry and Q(e)+1 name characters**
per such entity, including its NUL. Name_Enter's possible reuse is not credited.
All intermediate prefixes fit the same bound. There are no new ordinary/entity
nodes, syntax/Elists, Uint values, Strings or xrefs in these selected routes.

Name_Buffer is the existing global buffer of `4*Max_Line_Length` characters
(`namet.ads:161–163`). Qualify_Entity_Name additionally declares one local
Full_Qualify_Name buffer of that same length (`exp_dbug.adb:1216`). Under the
excluded debug-renaming recursion its recursive Fully_Qualify_Name worker
shares that outer buffer; it does not allocate another full buffer at each
scope level. Control-stack depth still depends on scope depth and is a separate
physical-storage charge.

`local_name_qualification` records this path-sensitive transfer and the
separate enqueue-table dimension. It can use the actual constructor name
lengths instead of multiplying a global maximum by every nesting depth. It
does not close the surrounding block analysis, scope freezing, total enqueue
multiplicity from initial Image/input/finalizer constructors, fixed-runtime
qualification, or later backend external/debug-name production.

## Original scalar arithmetic and loop-bound traversal

The source scalar grammar has only Integer literals/names, unary plus/minus,
and binary addition/subtraction/multiplication. These operations have a
source-structural transfer under the native options above. Scanner/parser
work, enclosing declarations/ranges/assignments, first type freezes and shared
diagnostic/xref/elaboration metadata remain distinct charges.

Let `O_s` count source scalar operators and `O_l` those in loop bounds.
Let `N_s` count source Integer-name occurrences and `N_l` those in loop bounds;
assignment targets may be included conservatively. Let `B_l` sum the raw
loop-range tree sizes, including the range node and both endpoint trees.
Parentheses do not add nodes. Then sufficient visit allowances are

```text
T = O_s + 2*O_l
V = N_s + 2*N_l.
```

Native compilation also makes **two** raw loop-range copies. The preparation
pass copies the range at `sem_ch5.adb:3962–3979`; native `Process_Bounds`
copies/preanalyzes it again at `3207–3255`. The latter replaces the light-mode
`DS_Copy` branch rather than eliminating that copy. Each raw tree contains
only scalar leaves/operators, no owned itypes/entities/actions or syntax lists,
so the two copies add `2*B_l` ordinary nodes. The preanalyses disable expansion
and freezing (`4868–4886`); the original may then be analyzed natively once.
Native Resolve_Range does not perform GNATprove's lower-root replay
(`sem_res.adb:11210–11214`). Loop capture relocates already analyzed syntax,
and its later constant reference does not reanalyze the initializer. No bound
expression contains a nested declaration or a String-returning call.

The shared scalar analyzers find one Standard arithmetic interpretation,
stored directly on the operator, with no All_Interp allocation: Main has no
user operator declaration and scalar operands have Integer/universal-Integer
types (`sem_ch4.adb:930–984,6542–6588,6770–6881,7143–7190`). The
[semantic component's overload derivation](retained-main-semantics.md#overload-records-and-their-index-map)
supplies this mode-independent fact. Source references to ordinary Integer
objects are not overloadable. Known scalar values are read from existing
literal/constant chains; no initializer tree is substituted by Eval_Entity_Name.

One arithmetic evaluation folds at most once: two ordinary nodes, one growing
event and two Uint appends cover Fold_Uint and signed subtraction's negation
plus addition. Multiplication's Num_Bits/UI_From_Int guard uses at most64,
and its comparison constant500000 is also in Uint's direct range
(`sem_eval.adb:1971–2110,4351–4451,6143–6156`, `uintp.ads:475–476`).
The original grammar excludes the unparenthesized unary-product warning;
static intermediates fit Integer, so this family does not enter overflow or
oversized-static-value diagnostics. Type freezing requested by the common
resolver epilogue is charged with the owning subtype, not per operator.

At strict overflow mode, Enable_Overflow_Check performs at most two
Determine_Range queries per unary/binary visit: the root and, for unary minus,
possibly its operand. O0 returns before the saved-check optimizer
(`checks.adb:6283–6455`). Native arithmetic uses the target's backend overflow
checks, so it does not construct widened arithmetic or helper calls.
Apply_Arithmetic_Overflow_Strict's size multiplication precedes that early
return; one extra Uint append per visit is conservative even though the
Integer32 size product is directly represented (`756–966`). Unary minus's
software `0-expr` rewrite is excluded by the same target flag.
Native `X+0`, `0+X`, `X-0`, `X*1`, `1*X`, `X*0` and `0*X` rewrites add at
most another two nodes/one growth event. For multiplication by zero,
Remove_Side_Effects returns: ordinary scalar names and recursively scalar
unary/binary expressions are side-effect-free under its default
`Variable_Ref=False`, even when overflow flags remain
(`exp_util.adb:14425–14662`, `exp_ch4.adb:7918–7976,9935–10164,10678–10728`).
Source exponentiation, modular/fixed/real arithmetic and intrinsic operators
cannot enter their alternative expansions.

For each Integer-name visit, reserve one variable-reference marker with its
one-list Insert_Action wrapper, and one
native Current_Value replacement, the latter two ordinary nodes and one
growing event. The replacement constructs one literal with an existing
Expr_Rep_Value; it never copies an arithmetic initializer tree
(`sem_ch8.adb:7118–7128`, `exp_ch2.adb:124–222,482–522`). Reanalysis of that
literal cannot re-enter identifier expansion. This overcounts readonly names,
lvalues and preanalysis passes. Marker insertion precedes the enclosing
short-circuit's first resolution, so it parks or appends the insertion list
without creating an additional EWA (`exp_util.adb:8143–8191,8290–8417`).
Marker-associated bookkeeping and xref records remain their own common-table
contribution.

For these scalar roots alone, set `A=1+max scalar-expression tree size`, also
including source range-endpoint roots. Captured loop-bound constants contribute
at most one edge to one such initializer; source cannot refer to a generated
capture. Ordinary source constants are leaves for Determine_Range, while
Expr_Value follows their finite declaration-order chain without allocating
numeric values. Source-loop type bounds are either existing static values or
fall back to Standard's bounds, not recursively expanded type definitions
(`checks.adb:5142–5298`). Folding, current-value replacement and identity
rewrites only decrease this tree envelope. The existing query transfer gives
6A Uints per Determine_Range. With target width at most128,
`k=ceil((130*A+2)/15)` is a sufficient base-32768 digit bound for intermediate
query estimates, including multiplication; it does not infer32-bit estimates
from the runtime Integer type.

The resulting original scalar-expression subtotal is

```text
ordinary nodes <= 2*B_l + 4*T + 3*V
growing events <= 2*T + V
Uint appends   <= (12*A+3)*T
Uint digits    <= k*(12*A+3)*T
syntax lists   <= V
entities, new names and String values = 0.
```

`source_scalar_arithmetic` regenerates this transfer. It covers syntax copies,
ordinary arithmetic, scalar-name rewrites and their range queries; it does not
charge the enclosing range's folds/checks, loop-index subtype, bound-capture
declarations, scalar assignment/initializer range checks, Image/Length
attributes, relational operators or whole-program metadata. Those distinct
constructors must be added before claiming Main closure.

## Ordinary native for-loop skeleton

The admitted `for I in [reverse] L .. H loop` adds one loop skeleton after
the original scalar/copy transfer above and its body constructors are charged.
There is no runtime-trip-count multiplier on frontend allocations. Let F be
the source loop count, `G<=2F` the bound-capture allowance, and A the preceding
source scalar-query envelope.

The parser already supplies the implicit loop label/scope and parameter
identities; the missing-identifier fallback in Analyze_Loop_Statement is not
another allocation. Both native range preanalyses are counted above.
`Process_Bounds.One_Bound` either analyzes the original directly or analyzes
and forces evaluation of the whole scalar expression
(`sem_ch5.adb:3113–3167`). The separate secondary-stack assignment route
cannot occur because scalar bounds contain no calls. Its Ensure_Valid adds
nothing for an arithmetic operator or literal; ordinary bound names take the
earlier direct branch. Expr_Known_Valid expressly accepts nonfloating operator
results (`checks.adb:6777–6832,6921–7041`). Subsequent range processing may
capture a mutable name, but a previously captured constant is side-effect-free
and cannot be captured twice. Thus the existing complete scalar-capture
transfer contributes at most `5G` ordinary nodes, G entities/names/lists and
`13G` name characters. The related subtype parameter is empty for these loops,
so `_FIRST`/`_LAST` names are not used. Initializer expression analysis is not
repeated by the capture.

`Make_Index` creates one internal signed Integer index subtype, sharing the
range and copying the base type's layout; it does not add another range tree
(`sem_ch3.adb:20478–20761`). Source pure-universal endpoints are resolved to
Standard Integer. Allow one 95-Uint discrete-size helper call and at most two
first-freeze nodes/lists for the new subtype and parameter, even though their
copied layout and ordinary no-delay path usually avoid them. Previously
declared types' first freezes belong to their declarations. Loops inherit
their enclosing Scope_Depth Uint instead of incrementing it; their live scope
stack entries and deferred qualification remain separate.

The range-processing cost has a useful bound that does not require analyzing
a generated check condition. Force_Evaluation leaves each endpoint as a
literal or stable scalar name, so its copy size is one. Get_Range_Checks may
still build its full conditional range-check tree; the earlier builder gives
`2*2+28=32` ordinary nodes, zero entities/lists. For the source loop's direct
`N_Range`, Process_Range_Expr_In_Decl searches upward for an enclosing
`N_Subtype_Indication` before inserting checks. There is none in the admitted
loop header. Consequently the returned check nodes are discarded without
Analyze (`sem_ch3.adb:22724–22784`). This does **not** erase their allocation.
Dynamic bounds inherited from an enclosing index type can change the check
selection but not that insertion guard or the raw builder shape. Successful
source legality excludes its static out-of-subtype error: two bound names
of the same subtype are already within it, while mixed types/arithmetic choose
the Standard Integer base, within which all admitted endpoint values lie.

Three range resolutions, two null-loop classification tests and the check
selector give at most six Compile_Time_Compare roots per source loop
(`sem_res.adb:11277–11289`, `sem_ch5.adb:3489–3490`,
`checks.adb:10994`). Source subtype-indication-only warnings/checks do not
apply. Their existing generic transfer is `120A` ordinary nodes and
`480A+360` Uints per loop; its syntax allowance is conservative because these
scalar roots have no String-literal Last fixups. Native final range resolution
additionally folds at most two static endpoints, adding four nodes/two growth
events. The preanalyses have expansion disabled and do not perform those
explicit endpoint folds. The only loop-expander rewrite is an optional null
statement for a proven empty loop, at most two nodes/one growth event
(`exp_ch5.adb:5841–6052`). There is no predicate, iterator filter, enumeration
representation or Loop_Entry expansion.

Process_Statements_For_Controlled_Objects scans the body and constructs no
block: ordinary String/Integer temporaries, their access-to-String captures,
and the already handled output wrappers require no controlled-object cleanup
(`exp_util.adb:12192–12342`). This scan does not replay body statements.
Scalar expression conditions may still generate warnings; their text and
deferred records belong to the common diagnostic contribution.

Combining these stages with two optional freeze nodes gives the conservative
loop-skeleton vector

```text
ordinary nodes <= (120A+40)F + 5G
syntax lists   <= 2F + G
growing events <= 3F
entities/names <= F + G
name characters <= 13(F+G)
Uint appends   <= (480A+455)F.
```

Use the scalar-query digit bound (at least three) for this subtotal. The
`source_for_loop_skeleton` evaluator substitutes G=2F. Parser scope identities,
raw range copies, original scalar work, body work, qualification, diagnostics,
xrefs/elaboration records, scope-stack backing and backend lowering must still
be composed separately.

## Ordinary Integer declarations and assignments

This transfer adds the enclosing Integer declaration/assignment work to the
original scalar-expression subtotal. Let D_i count Integer declarations, J_i
Integer assignments, R their explicit static object-range constraints, and
L_R the sum of the constrained objects' identifier lengths. Take the preceding
scalar query envelope A, including initializers and range endpoints. The
generated checks below are scalar only; they cannot contain Image/concat or
source calls, and do not introduce another raw source evaluation.

An explicit Integer subtype has the mode-independent Find_Type_Of_Object
constructor: two ordinary nodes, one entity and one insertion list
(`sem_ch3.adb:19119–19198`). Its name is `T<object>S`, so charge `|object|+3`
characters including NUL, not the internal serial-name bound. Subsequent
qualification is separate. Its static range creates no failing range-check
tree; both endpoints fit Standard Integer, and the declaration range is
nonempty. Allow three Compile_Time_Compare queries, four explicit endpoint
fold nodes/two growth events and two Set_Discrete_RM_Size calls per constraint.
The latter cost at most 190 Uint appends; native first freeze preserves the
same ordinary signed scalar layout as the shared semantic derivation.

Apply_Scalar_Range_Check runs once in semantic object analysis and again
through the native object's Apply_Constraint_Check; an assignment has one
semantic call (`sem_ch3.adb:4851`, `exp_ch3.adb:8439–8459`,
`sem_ch5.adb:1031`, `checks.adb:1318–1334`). Each adds at most one
Determine_Range and two Compile_Time_Compare roots, and otherwise only sets
flags on successful legality (`checks.adb:3155–3503`). O0 excludes the saved
check optimizer. A constant declaration's optional known-valid subtype
refinement adds at most two further comparisons (`sem_ch3.adb:4826`).

The native object/assignment expander can then call Generate_Range_Check once
if the flag survives (`exp_ch3.adb:8456`, `exp_ch5.adb:2523–2524`). This must
be counted even though Silver proves the assignment safe: that does not imply
GNAT's local range estimate clears its flag. Both source and target have the
same Standard Integer base, so only the same-base branch at
`checks.adb:7717–7730` applies. It forces an arithmetic value once, possibly
creating one whole-scalar constant capture, then inserts the artificial
conditional raise `value not in target_subtype`, suppressing recursive checks.
The captured initializer stays analyzed. A plain scalar name needs no strict
capture and Duplicate_Subexpr copies only that one current leaf.

The generated check has the following finite continuation:

| Stage | Ordinary-node allowance | Growth allowance |
| --- | ---: | ---: |
| Whole-scalar capture | 5 | 1 |
| Raise, Not_In, value copy and type occurrence | 4 | 0 |
| First Not_In fold or rewrite to Not(In), plus Not fold | 7 | 3 |
| Subtype mark rewritten to First..Last range | 6 | 1 |
| Two static bound-attribute folds and two endpoint folds | 8 | 4 |
| Two possible In semantic folds | 4 | 2 |
| In-range simplification and generated comparison's local folds/rewrites | 7 | 3 |
| Conditional-raise simplification reserve | 2 | 1 |

Fifty ordinary nodes and sixteen growth events dominate these direct rows.
There are at most two syntax lists: the capture insertion and raise insertion.
The capture adds one entity/name, with at most thirteen name characters.
The subtype bounds are static, so their attributes fold without copying source
bound-expression trees. The scalar membership expander adds two comparison
queries; range resolution adds one; Generate_Range_Check's initial
In_Subrange_Of adds two; and the possible generated ordinary comparison adds
two. Thus seven comparison roots cover the numeric continuation. Each retains
the existing conservative `20A` ordinary-node/`80A+60` Uint query transfer.
The artificial membership has Comes_From_Source=False, excluding its Valid
attribute substitution and additional source-warning query pair
(`exp_ch4.adb:6681–6744,6776–6795,6923–7019,7066–7082,7794–7816`,
`sem_res.adb:10221–10459`, `sem_eval.adb:3062–3128`). Its conditions are
Standard Boolean; local-raise handling returns under the selected switches
(`exp_ch11.adb:1319–1331,1697–1705`).

Ordinary Integer objects have no initializer call, aggregate, special return,
tagged/control/task, representation, anonymous access or unaligned-copy case.
Native assignment's validity-copy option defaults off; its local-variable
case only updates validity flags (`validsw.ads:49`, `exp_ch5.adb:3351–3454`).
Source scalar types have no predicates. First-freeze reserve one node/list
per source object, generated range type and possible capture; ordinary scalar
layout and object freezing add no other syntax or numeric result beyond the
size calls already charged. Common references, warnings and elaboration
records remain outside this local constructor transfer.

With `H=D_i+J_i` possible generated checks and `C=2D_i+J_i` scalar-check calls,
define `Q=2C+2D_i+3R+7H`. A conservative complete local subtotal is

```text
ordinary nodes <= 20A*Q + 7R + 51H + D_i
syntax lists   <= 2R + 3H + D_i
growing events <= 2R + 16H
entities/names <= R + H
name characters <= L_R + 3R + 13H
Uint appends   <= 6A*C + (80A+60)Q + 190R.
```

The scalar digit envelope applies. Parser identities, source arithmetic/name
visits, qualified names, metadata and backend costs are additional.
`source_integer_stores` regenerates this composition without taking credit
for a successful local range-check elimination.

## Source predicates and conditional control flow

Let P count source relational comparisons of all three admitted families:
Integer, String equality/inequality, and Length. Let B count source `and then`
and `or else`, Z source Boolean `not`, I source if statements and E their
elsif parts. All branch bodies count once, regardless of static reachability.
Use a uniform query envelope A covering source scalar roots and every String
bound/length optimizer root, rather than reusing only the scalar A above.
Operand constructors, literal/name processing and library calls are separate.

An Integer source comparison has the existing generated comparison transfer
plus at most two source-warning Test_Comparison queries: one from semantic
evaluation and one from Rewrite_Comparison (`sem_eval.adb:3548–3638`,
`exp_ch4.adb:15251–15306`, `sem_warn.adb:3548–3649`). Thus `80A+5` ordinary
nodes, two growth events, one possible equality Bodies list and `320A+240`
Uint appends suffice. Ordinary ordering takes the same query/rewriting path.
Source-only reference/diagnostic records remain common metadata.

For String equality, native Character components use the target's ordinary
composite comparison; no local equality function/body is generated
(`exp_ch4.adb:8589–8656`). The one empty Bodies list still counts. The values
are aligned, nonpacked String names, literals or normalized slices. String
inequality additionally rewrites to Not(Eq), resolves those two operators,
and leaves the already resolved children alone (`:10217–10256`). Two complete
source-comparison allowances plus five direct rewrite/not-fold nodes therefore
cover either String operator: `160A+15` nodes, six growth events, two lists,
and `640A+492` Uints. The last twelve Uint appends conservatively pay two
Static_Length calls in each of the two relational evaluators. String
Compile_Time_Compare usually returns Unknown without scalar arithmetic; this
bound does not take that credit.

Length predicates initially resolve both operands to Universal_Integer. Their
source attributes therefore return at the result-type guard of
Apply_Universal_Integer_Attribute_Checks (`checks.adb:3985–3993`); they do not
create its narrowing conversion. The subsequent native comparison may use
Narrow_Large_Operation and Optimize_Length_Comparison. The already closed
`280A+144` node/39-growth/`1156A+1262` Uint length-check envelope includes
both initial Length evaluations, initial and narrowed comparisons and two
optimizer entries; its check/raise/discard row is extra safe allowance for a
source predicate. There are two differences from that artificial suppressed
case:

- All four possible comparison stages may retain a source Original_Node.
  Add two warning-query roots for each, or eight Compile_Time_Compare calls.
- Narrow_Large_Operation suppresses overflow checks itself (`exp_ch4.adb:
  14529–14533`), but range checks remain enabled. Its two conversions target
  the existing signed base type selected to contain both operand intervals.
  Their semantic and native Apply_Scalar_Range_Check calls repeat the same
  already bounded Determine_Range and return on containment; they neither
  generate a range-check tree nor narrow again (`checks.adb:3348–3400`,
  `exp_ch4.adb:14454–14533,12333`). Charge four such range-query calls.
  The two optimizer entries each contain two signed arithmetic operations;
  allow two additional range queries per operation under enabled strict
  overflow checks. Their backend-overflow path adds no frontend syntax.

These twelve extra range queries and eight comparison queries give a uniform
bound for **any source comparison**, including the smaller Integer/String
cases:

```text
ordinary nodes <= 440A+144
growing events <= 39
syntax lists   <= 4
Uint appends   <= 1868A+1742.
```

The four lists allow equality's initially empty Bodies list at every
comparison stage. Optimizer-produced roots contain First/Last/arithmetic,
not root Length; no third optimizer layer is possible. The known 32/64/128-bit
Standard signed type frontier and earlier `2^126` cache allowance remain in
force. A source Length literal is scanned separately; it is a single existing
numeric value in this transfer. The scalar-query digit bound with width128
covers both these values and the optimizer's arithmetic.

Short-circuit child resolution and generated actions are not counted a second
time. Resolve_Short_Circuit creates its left EWA with one empty list; useful
right actions can create another Boolean EWA. Charge the complete existing
eight-node/two-entity/two-growth/one-depth-addition wrapper for each side,
even though the resolver-only left wrapper does not normally need both
entities. Add two nodes/one growth for the short-circuit's own fold or
known-operand rewrite. Thus each source short circuit costs at most eighteen
nodes, five growth events, four entities/names, fifty-two name characters,
one list and two Uint depth increments. The moved actions are already analyzed
and have no controlled/finalizable types, so their wrapper does not replay
String constructors or create a cleanup procedure. A source Boolean `not`
adds at most two fold nodes and one growth event; Standard Boolean adjustment
adds nothing (`exp_ch4.adb:10305–10313,13123–13274`,
`sem_res.adb:11668–11700`).

Native if expansion moves existing statements/conditions; it does not clone
them. Each elsif with actions or a known condition can be moved into one new
if node with at most two list headers. It is removed from its old list before
recursive processing, so at most E such moves occur. Existing analyzed body
statements return without reanalysis. Each original/new if can have at most
one terminal rewrite to an existing statement or null. Hence `2I+3E` nodes,
`I+E` growth events and `2E` lists suffice (`exp_ch5.adb:4767–4938`). There
are no source return statements for its return-pair optimization. The
controlled-object scan has the earlier zero-construction result for these
ordinary scalar/String bodies. It creates no case, goto, exit, finally list
or variable family of local procedures.

The resulting predicate/control subtotal is

```text
ordinary nodes <= (440A+144)P + 18B + 2Z + 2I + 3E
syntax lists   <= 4P + B + 2E
growing events <= 39P + 5B + Z + I + E
entities/names <= 4B
name characters <= 52B
Uint appends   <= (1868A+1742)P + 2B.
```

The final `2B` values are scope-depth increments: bound their magnitude by
the enclosing depth plus two per live enclosing short circuit, separately
from scalar-query digits. `source_predicates_and_control` records the two
digit populations. Qualification, diagnostics/xrefs/elaboration, source
calls/operands, action constructors and physical stack/backing remain
separate composition terms.

## Ordinary String declarations and assignments

This component excludes the first input declaration, whose construction is the
fixed scaffold below. Let D_s count all later String declarations, J_s all
String assignments, and L_s the sum of the later declaration identifier lengths.
Initializers/RHS values have already received their source expression and
constructor transfers. All source String declarations use nominal Standard
String without an explicit constraint. Let A cover the original and generated
String-bound query graphs, including the Length optimizer; a scalar-source-only
tree bound is insufficient here.

`Expand_Subtype_From_Expr` partitions these already resolved initializers into
a literal, slice or constrained name (`exp_util.adb:5884–6014`). Source String
names have their actual constrained subtype as Etype after declaration
(`sem_ch3.adb:5138–5145,5341`); Image and concat yield the normalized views
proved earlier. The later declaration cannot enter the first input's general
unconstrained-function branch. The three relevant alternatives are bounded by
the following deliberately overlapping charges:

| Stage | Ordinary nodes | Lists | Growth | Entities/names | Uint appends |
| --- | ---: | ---: | ---: | ---: | ---: |
| Existing plain result-storage transfer, b=6,l=0 | `140A+95` | 3 | 23 | 2 | `596A+519` |
| Literal/slice subtype indication and saved original | 11 | 1 | 1 | 0 | 0 |
| Two literal-range scalar operations and endpoint folds | 8 | 0 | 4 | 0 | `24A+6` |
| Up to two already analyzed whole-bound captures | 10 | 2 | 0 | 2 | 0 |
| Late constant-name initializer literal copy | 2 | 0 | 1 | 0 | 0 |
| Object declaration rewritten as ordinary renaming | 3 | 0 | 1 | 0 | 0 |
| First-freeze reserve for object and four new entities | 5 | 5 | 0 | 0 | 0 |
| Debug-renaming numeric rendering reserve | 0 | 0 | 0 | 0 | 42 |

The literal case's Make_Literal_Range has seven nodes including its range
root; its lower bound is a one-node static literal/constant. Its two operations
are ordinary signed Integer addition/subtraction (`exp_util.adb:10664–10707`).
The b=6 storage row covers those two endpoint trees after their first analysis.
The slice case uses the existing slice index **subtype mark**, without copying
its bound trees or constructing another index subtype: Constrain_Index's
subtype-mark branch analyzes that occurrence and returns
(`sem_ch3.adb:15420–15448`). Evaluate_Slice_Bounds can capture the two current
bounds but does not replay their children (`exp_util.adb:5507–5528`). A
constrained name either reuses its itype or creates one simple subtype alias;
its four-node/one-list/one-entity row is dominated by the table. Thus b=6 is
used for the literal alternative, not asserted for a dynamic slice's index
graph. Both alternatives preserve the normalized bound-shape invariant.

Find_Type names the literal's array/index pair `T<object>S` and
`TT<object>SP1`, requiring `2|object|+9` characters including NUL. Together
with two capture names and a separate alias-name allowance, use
`2|object|+48`; subsequent qualification remains separate. The actual subtype
is marked Is_Constr_Subt_For_U_Nominal. Native initializer expansion therefore
skips its additional constraint check, and Check_Initialization's scalar-only
light-mode test is absent (`sem_ch3.adb:5156–5159,13042–13124`,
`exp_ch3.adb:8420–8439`). Ordinary String excludes controlled, tagged,
special-return and source-defined initialization helpers. The late literal
copy retains its String_Id and analyzed subtype; the renaming rewrite does
not reanalyze its components (`sem_ch3.adb:5436–5453`,
`exp_util.adb:13790–13830`).

Debug_Renaming_Declaration returns no encoding for these unpacked views, but
it can examine subscripts before testing that condition. Its traversal follows
Original_Node and ordinary renaming-name chains. Such a chain has at most one
terminal normalized slice (Image/concat buffer) or pointer dereference; its
buffer/pointer is generated storage, not another source String initializer.
Original_Node may stop the traversal earlier at the constructor. Thus at most
two bounds reach Output_Subscript. Each accepted bound is a known signed
Integer value or a local internal constant name; other bounds stop without
rendering. Decimal output has at most ten digits and one sign. Charge one
negation plus two Uint appends per digit, hence 21 per bound, including the
arithmetic subsequently released by UI_Image. The unreleased sign negation
is also covered (`exp_dbug.adb:350–367,392–530,1148–1157`,
`uintp.adb:386–452,1030–1147`). No name is interned because encoding is disabled.
The temporary Name_Buffer suffix needs at most32 characters (two internal
names or numeric strings plus the fixed selectors/dereference); its backing
storage is separate from retained name characters. Insert_Action with Empty
returns before creating a list (`exp_util.adb:7984–7997`).

For one source String assignment, charge two complete enabled Length-check
comparison envelopes from the predicate section, one uncached referenced-input
actual subtype, and two overlap comparison queries. The first two cover the
semantic/native check passes and their possible raise construction; add their
two insertion-wrapper lists. Get_Referenced_Object on the RHS can reach input
`P.all`, as in the corrected concat assignment transfer. The LHS cannot be
the constant input, and later mutable objects or renamed constructor results
have constrained designated types. In particular OK_To_Rename_Ref only accepts
E_Variable, so the input constant cannot propagate its unconstrained pointer
view into a mutable declaration through that branch
(`exp_ch3.adb:7761–7764`, `sem_util.adb:11265–11278`,
`exp_ch5.adb:346–355`). The aligned, nonpacked Character array route does not
set Loop_Required; the overlap checks add no generated element loop
(`exp_ch5.adb:356–870`). Source operand/literal construction is separate.

The resulting closed local sums are:

| Demand | Per later String declaration | Per String assignment |
| --- | ---: | ---: |
| Ordinary nodes | `140A+134` | `940A+358` |
| Growth events | 30 | 84 |
| Lists | 11 | 18 |
| Entities/names | 4 | 2 |
| Name characters including NUL | `2|object|+48` | 29 |
| Uint appends | `620A+567` | `3976A+3763` |

The assignment's arithmetic is exactly twice `(440A+144,39,4,1868A+1742)`
for nodes/growth/lists/Uints, plus `(20A+70,6,8,80A+159)` for the actual
subtype, `(40A,0,0,160A+120)` for two overlap queries and two insertion lists.
No new retained String value or Elist is introduced in these stages. The
source-derived graph/numeric envelope must also cover their queries. The
executable `source_string_stores` records these rows; parser entities, source
expressions, common metadata, name qualification and backend work remain
additive.

## Standalone String literal resolution

Literal operands of concat were separately resolved in base Standard String.
A standalone literal assignment instead resolves the RHS in the **target
object's subtype** (`sem_ch5.adb:790`). A target initialized from input or a
dynamic constructor can have a nonstatic low bound. Therefore native closure
must include Set_String_Literal_Subtype's dynamic-low branch; the static-low
concat suffix cannot stand in for it.

For a static low, reuse the corrected six-Uint suffix below: one fresh literal
subtype/name, thirteen name characters, at most six Uint appends, and no other
core allocations. The dynamic branch (`sem_res.adb:13249–13335`) creates the
same literal subtype, then an ordinary signed index subtype and String array
subtype. It copies the existing normalized target low twice. That low has at
most12 ordinary nodes and one syntax list, no owned types/actions, under the
earlier bound-shape induction. Source String declarations have no user-written
constraints; aliases preserve this invariant. It builds `low+(length-1)`, one
range and index occurrence, and wraps the literal in an unchecked conversion
to the new String subtype. It does not build a character aggregate.

The direct syntax is at most33 ordinary nodes:24 copied bound nodes, two
upper-expression nodes, the literal subtype's static low1, one range, one
index occurrence, and four conversion/relocation/saved-original nodes.
One generated Integer addition adds at most two fold nodes/one growth and
`6A+2` Uints; the range's two final endpoint folds add at most four nodes/two
growth. The final conversion rewrite adds one growth. Reserve one freeze
node/list for each of the three subtypes. Including the index list and two
copied lists gives **42 ordinary nodes, four growth events, six lists, three
entities/names and39 name characters**. The new signed index copies existing
size fields; there is no new Set_Discrete_RM_Size call. Charge length conversion,
the four-Uint literal evaluation allowance, literal first-size multiplication,
and the ordinary array's four-Uint size allowance: with the addition this is
**6A+12 Uints**. The dynamic lower-bound graph and its one new upper addition
must be included in A.

Resolve_Range does not apply a target-subtype check; it resolves its endpoints,
checks their base-type legality and performs the already charged folds
(`sem_res.adb:11161–11289`). The copied low retains Analyzed. The conversion
does not force another temporary: its enclosing assignment already supplies a
target, and input/output share Standard String's implementation base
(`exp_ch4.adb:12861–12891`, `exp_util.adb:13846–13861,13909–13915`).
The newly nonstatic ordinary subtype makes Eval_String_Literal return before
its static-length branch; charging that branch's four Uint allowance anyway
is conservative. Standard Character's complete range prevents per-character
conversion/aggregate construction. String contents reuse their existing
String_Id throughout.

Let S count original source String literals outside concat and J_l<=J_s the
direct literal assignment RHS occurrences. Charge the static suffix S times
and the entire dynamic branch J_l times, deliberately overlapping the static
part. Counting all source literals for S and all String assignments for J_l
is also conservative if the corresponding literal-resolution counter is
enlarged to contain J_l; precise source counters avoid that unnecessary
overcount. Source literal parser costs and operator-symbol normalization are
separate. `source_string_literal_suffix` records this transfer.

## Source call and leaf bookkeeping

Let C count all source library calls, W all source word tokens, S all original
source String literals and P the parser's raw literal-chain flattenings. The
source argument constructors and the fixed first-input scaffold are separate.
The following conservative residual row deliberately duplicates scalar variable
markers already covered by the scalar-name row:

```text
ordinary nodes <= W+2C
syntax lists   <= W+3C
growing events <= 3C+S+2P.
```

Each eligible source variable occurrence can create one reference marker and
its immediate Insert_Action list (`sem_ch8.adb:7107–7130,7781–7805`,
`sem_res.adb:4247–4276`, `sem_elab.adb:3824–3860`). Calls defer their simple
variable actuals to Resolve_Actuals, so those sites are alternatives.
Needs_Variable_Reference_Marker excludes preanalysis, generated references,
constants and loop indexes (`sem_util.adb:23907–24033`). W conservatively
contains all eligible source occurrences. Scalar loop-bound replay and its
copies remain charged to the scalar row; no copied String constructor is
analyzed afresh. The source analysis and resolution guards leave already
analyzed children alone.

Each original library call contributes at most one call marker and its
Insert_Action list (`sem_res.adb:7341`, `sem_elab.adb:3563–3776`). The one
source function that requires unconstrained-result relocation is the first
First_Or_Default call; its later marker and capture belong to the fixed
scaffold. Native call expansion creates two Post_Call lists, one in
Expand_Call_Helper and one in Expand_Actuals, even when both are empty
(`exp_ch6.adb:4574,5227,2678`). The five selected interfaces have no precondition;
their postconditions belong to the callee. All actuals are supplied, so there
is no default-expression copy. The supplied String actuals are ordinary
nonpacked Character arrays, in mode IN, with the same Standard String
implementation base; the parameter-copy, controlled, atomic, volatile,
dispatching, foreign convention, task/protected and derived-subprogram
conversion branches do not apply. The earlier runtime-call/extra-formal
argument supplies the same no-extra-actual conclusion for these ordinary
source interfaces. No source callee body is inlined with the selected options.
Source child construction and output's transient wrapper have their own rows.

The second node per C allows the parameterless-function relocation. Its
Change_Node leaves Parameter_Associations Empty rather than constructing a
list (`sem_res.adb:1462–1480`). Three growth events per C cover that change,
positional indexed-form to function-call conversion (`sem_ch4.adb:2754–2756`)
and selected-to-expanded-name conversion (`sem_ch8.adb:7659`). These forms
need not all occur for one call. The parser already owns argument lists and
named-association nodes. An operator-looking String literal is changed to an
ordinary String literal in admitted expression positions
(`sem_ch6.adb:1555–1591`, `sem_res.adb:1483–1487`); S+2P covers original and
parser-flattening-created literal nodes. The selected-to-expanded and
operator-to-literal helpers use Mutate_Nkind (`sinfo-cn.adb:140–156`), so
charging a growth event for each is conservative. A literal already normalized
by one route does not repeat that kind change on the other. These bookkeeping steps
create no fresh entity, generated name or Uint; overload, cross-reference,
elaboration and diagnostic records remain common-table terms.

## Source-derived common query envelope

The String descriptor recurrence above supplies a descriptor for every source
String expression and declared String object in source order. Literal, Image
and input seeds are fixed; a source `&` uses the binary recurrence, which
dominates native flattening; an alias reuses its initializer's descriptor.
Later assignments preserve the target object's subtype. Let H_source be the
maximum low or high D descriptor, with a floor of two. This maximum includes
each initializer and each intermediate expression, not just final outputs.

Direct literal assignment creates a transient subtype that is not the target's
declared subtype. Its lower bound copies the target low; its upper bound is
either that low or `low+(length-1)` (`sem_res.adb:13249–13335`). The literal
`length-1` is already one numeric leaf, so the latter adds two D visits.
Consequently use

```text
H = H_source+2
A = max(17, largest_scalar_tree+1, 3H+7).
```

The extra two in H pay this transient subtype before folding. Reusing only
H_source in the global Length-optimizer bound would leave that case unstated.
It creates no new source object descriptor and cannot grow through a sequence
of assignments. The source literal default and static-literal declaration
ranges have leaf bounds; the uncached referenced-input subtype has the input
seed. Aliases and normalized generated bound captures preserve the previously
proved descriptor shapes.

For all String stores, comparisons and concat helpers, an index endpoint has
D<=H, a Length has D<=2H+1, its possible regular conversion has D<=2H+2,
and the two Length-optimizer shapes have D<=3H+7. The earlier query-root table
and its one-layer optimizer argument apply to those same check/compare helpers
outside concat. The dynamic literal high adds only one arithmetic node above
a normalized low; its same-value weight is at most three, below the five used
for the existing endpoint envelope. Thus the existing S<=17 and F<=S remain
valid. Source scalar expressions, including Image arguments, and their loop
range copies use largest_scalar_tree+1 as previously derived; the fixed Image
constructor uses A=17. Source Length occurs in predicates, not in the grammar
for Integer declaration or assignment expressions. No scalar-source edge
silently follows a newly constructed String graph.

This A covers the constructor queries in the next sum, including the dynamic
literal continuation. It does not price scanner construction of numerals,
fixed runtime semantics, backend annotation, diagnostics or other late
consumers. `main_native_query_envelope` records and checks the arithmetic join;
building the source descriptors in the recognizer and proving that computation
remains dependent implementation work.

## Fixed input and Main secondary-stack scaffold

The initial input construction and Main's secondary-stack cleanup reduce to
a fixed native scaffold. This is a source reduction for obtaining a fixed
capture, not a measured baseline in this evidence directory. Use the native
application options above and the actual selected library specs. A suitable
one-character-name, nonempty-literal witness is:

```ada
with Silver_Arguments, Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   D : constant String := Silver_Arguments.First_Or_Default ("x");
begin
   null;
end Main;
```

The default literal's scanner data, resolution, subtype, scalar range queries
and first-size arithmetic remain variable source components. A capture with
this literal does not bound those components for every default length. An
empty-literal companion can isolate the null-literal early-return branch.
After its ordinary source argument is resolved, the input's declared result
is always unconstrained Standard String; its length or contents do not select
different result-storage/cleanup constructors. The function has no precondition,
default actual, private result, build-in-place result or frontend inline body.
Its library contracts and imported declarations remain fixed dependency work.

`Resolve_Call` establishes one transient scope for this nonintrinsic,
non-build-in-place unconstrained String result (`sem_res.adb:7030–7091`).
`Expand_Subtype_From_Expr` selects its final `Make_Subtype_From_Expr` branch
(`exp_util.adb:5864–6107`). Standard String has one dimension, so the latter
creates exactly two captured bounds and one subtype indication
(`10865–11065`). The first `Duplicate_Subexpr_No_Checks` captures the call;
later copies see the normalized reference. Native `Remove_Side_Effects`
creates one access-all String type, one constant initialized by the call's
`Reference`, and a dereference; it does not replay the already analyzed child
call (`12984–13121`). The ordinary object is subsequently rewritten as a
renaming without reanalysis (`13790–13830`). Its debug-renaming inspection
returns before name encoding: the original node is a function call, and even
the normalized pointer path has no packed-component reason to enable an
encoding (`exp_dbug.adb:392–530`).

There are nevertheless two binding-name-dependent generated subtype names.
`Related_Id` is empty in `Expand_Subtype_From_Expr` because D is local
(`sem_ch3.adb:5113–5139`), but the following `Find_Type_Of_Object` creates
`New_External_Name(Chars(D), 'S', 0, 'T')` (`19119–19121`). Its spelling is
`T<D>S`, length `|D|+2`, and its later fully qualified spelling is
`main__T<D>S`, length `|D|+8` (`tbuild.adb:632–666` and the qualification
transfer above). `Constrain_Index` creates its index itype `TT<D>SP1`, length
`|D|+5`, with a qualified name of length `|D|+11`, as in the closed explicit
subtype transfer. Against the one-character D witness, charge
**`4*(|D|-1)` additional name characters**, separately from D's source name.
All four names need their usual NUL allowance in the captured baseline. The
input-related internal temporaries use serial names, independent of D and
the default literal. Normalize each to at most 12 characters (13 including
NUL), subject to the existing serial-counter headroom condition; apply the
same length correction to each retained qualified occurrence. These are
length corrections, not extra entities or extra Name entries.

`Wrap_Transient_Declaration` transfers actions and entities into Main and
sets Main's secondary-stack flag; it creates no enclosing block and does not
mark/release at the input declaration (`exp_ch7.adb:9411–9451`). With
`Manage_SS=False`, the insertion helper only moves existing lists. Its
transient scan finds no finalizable String, scalar or ordinary pointer
(`5101–5440`, `exp_util.adb:9454–9505`). `Transfer_Entities` updates existing
links, scopes and public flags; `Set_Public_Status` performs only tests and
setters (`sem_util.adb:28975–29050,29510–29603`). No input-name-dependent
allocation is hidden in that transfer.

At Main completion only `Needs_Sec_Stack_Mark` requires cleanup
(`exp_ch7.adb:4632–4819`). There are no tasks, controlled/tagged objects,
protected operations, asynchronous statements, custom cleanup or a
build-in-place return. Task activation returns on the absent activation
chain before constructing a call (`exp_ch9.adb:4386–4456`).
`Build_Cleanup_Statements` creates one empty list (`exp_ch7.adb:1392–1523`).
Main receives one mark object and one `_finalizer` specification/body. The
finalizer body contains just `SS_Release(M)`; there is no master, controlled
object list, abort-defer pair, exception object or reraising path
(`1791–2235,2237–2359,2455–2660,3139–3285`). The ordinary declaration and
statement preprocessing is a scan, with zero controlled-object count; it
does not copy Main or create one finalizer per user object. First freezes
of those objects still belong to their constructor charges.
`Expand_At_End_Handler` itself is only an assertion in this pin
(`exp_ch11.adb:83–88`); it does not construct frontend exception handlers.

Thus additions of later ordinary Main declarations, expressions, assignments,
loops and conditionals do not enlarge this fixed scaffold. They retain their
own source/generated costs. Calls to `Is_RTE` during a scan may intern a fixed
unit name even without loading a runtime unit: the fixed baseline must cover
those names, including `system.finalization_primitives%s` and `standard%s`,
or add them explicitly. Capturing immediately before `gigi` directly measures
the frontend scaffold. A complete-process fixed witness is also useful as
conservative fixed overhead, but variable backend callbacks require their
own source-derived addend; a fixed witness cannot establish their absence.

### Native runtime roots and first freezes

The additional native fixed roots are System.Img_Int, System.Concat_2 through
System.Concat_9 and System.Secondary_Stack. They are part of the selected
[fixed support closure](retained-fixed-support.md), together with the existing
Silver context roots. A fixed native capture must exercise every selected RTE
identity or charge its first-lookup residue, not merely load each unit: RTE calls Load_RTU on the first lookup of
each RE_Table entry, and Load_RTU constructs its Priv_Par list before testing
whether the unit is already loaded (`rtsfind.adb:1022–1030,1104–1107,1562–1565`).
Later lookup of that same identity skips Load_RTU. For an already loaded
runtime unit, that early return precedes all parent-chain scanning, so one
extra element-list header per RE identity bounds this residue. The generated
evidence counts the complete RE_Id enumeration, deliberately including
ineligible identities, as a conservative bound. RE_Chars looks up the existing
entity spelling from the parsed runtime source, and successful Check_CRT
constructs no syntax (`rtsfind.adb:269–319,1401–1424`). This residual allowance
does not authorize loading an additional runtime unit.
The per-unit implicit with
clause is created once per current semantic compilation unit; subsequent
lookups return at the matching-clause guard (`:1257–1327`). Fixed queries that
intern a unit name without loading it remain included as described above.

RTE disables frontend inlining while loading a runtime unit. Load_RTU analyzes
that unit only if its compilation unit has not already been analyzed, under
reset Ghost/SPARK and saved instance/private visibility contexts
(`rtsfind.adb:1113–1115,1162–1204,1530–1535,1558–1565`). The unit loader and
semantic unit guards therefore make repeated or reordered Main uses reuse
the completed fixed unit; the dependent scope-save cost remains variable.
The runtime specs cannot name Main's declarations. Their internal source
order, generic instantiation actuals and full-type completions are fixed.
The separate coherent all-miss numeric capture removes cache-hit credit; it
does not remove the need for this source reduction.

The native signature frontier requires a stronger first-freeze argument than
the light-mode Boolean/String interface. At the end of each nongeneric
library package, the private part is analyzed before Freeze_All is called
(`sem_ch3.adb:2782–2867`). Freeze_All recursively enters ordinary nested
packages and instances, installs their private declarations and freezes their
entity lists (`freeze.adb:2586–2611,2649–2652`). Consequently:

- Concat2 through Concat9 expose only ordinary subprogram signatures with
  Standard String actuals; there is no private or generic actual type.
- System.Img_Int's Image_Integer is a renaming of the ordinary
  Image_I(Integer) instance operation. The generic's fixed instantiation and
  its internal generic-freeze triggers occur while the fixed spec is analyzed;
  arbitrary Main Image expressions reference the instance operation, never
  the generic package (`libgnat/s-imgint.ads:42–54`, `s-imagei.ads:37–47`).
- SS_Allocate has Address and Storage_Count formals. SS_Mark and SS_Release
  expose Mark_Id. Its private completion is the non-tagged record containing
  an SS_Stack_Ptr and Stack_Pointer; the stack and chunk access-designated
  types have full completions in the same specification. There is no
  Main-dependent completion, tagged/classwide profile or formal type
  (`libgnat/s-secsta.ads:43–53,70–95,275–341`).

The potentially repeated paths in Freeze_Entity are explicit. Generic-package
freezing occurs before setting Is_Frozen, and incomplete/private/classwide
profile paths can reset it (`freeze.adb:4720–4742,4791,6536–6565,7352,7502,
7643–7653`). Main cannot name the generic packages, introduce an instance, or
remove those already analyzed full views. The exposed ordinary runtime
entities therefore take the already-frozen guard after their fixed unit's
first processing. Order changes cannot make a completed Mark_Id/stack/chunk
completion incomplete again or reinstantiate Image_I. Any finite premature
freeze inside a fixed specification remains part of its captured fixed work.

The retained [native fixed capture](../evidence/retained-native-fixed-capture-20261018/README.md)
uses input, nonstatic Image and each concat arity from two through ten, both
in declarations and output statements. It therefore exercises the selected
unit roots, secondary-pool allocation and Main cleanup. First-lookup cache
entries were not inventoried; the RE_Id residual above avoids assuming that
inventory or repeating the capture just to obtain it. Any unrepresented
Main implicit-with clause needs at most eight ordinary nodes: one with node
and a unit occurrence plus up to three parent qualification pairs (the
selected dependency package depth is at most four). Each selected unit has
at most one such clause in Main; fixed-unit clauses are already captured.

This reduction permits a complete native all-roots witness to supply fixed
frontend overhead, retaining the entire witness Main conservatively. It does
not absorb source constructors, generated Main types' own first freezes,
counter-dependent names, installation paths, saved scopes, common metadata or
variable backend callbacks. Selected unit coverage, the explicit RE_Id/with
residuals, and all-miss coherence are all required when its constants are
composed.

### Concrete fixed inputs and capture reconciliation

The [fixed-input collector](../evidence/unbounded-programs/retained-native-expansion-20261017/reconcile-fixed.py)
now resolves Main's source-selected roots through context clauses and parent
specifications, using hash-verified inputs of the existing native capture. Its
[output](../evidence/unbounded-programs/retained-native-expansion-20261017/native-fixed-inputs.json)
contains every dependency edge and all 120 retained lifetime counters. This
is read-only reconciliation of existing evidence, not another measurement.

Main imports Silver_IO and Silver_Arguments, whose specifications import
Ada.Text_IO. Add the core System/elaboration/exception/stack/Put_Image roots
already justified by the helper-inclusion argument, plus Img_Int, Secondary_Stack
and Concat_2 through Concat_9. The closure contains **36 runtime specifications
and two Silver specifications**. It excludes the six extra roots in the broader
multi-process support union: Ada.Command_Line, Interfaces.C and assertion
packages belong to separate Silver-body compilation, while both array-ordering
helpers are excluded by the native String-equality route. No source or generated
Main operation calls them. The native constructor and type frontier above,
including generated access types, supplies this inclusion argument; observing
a unit's absence from the capture is not the reason for exclusion.

The capture's physical source map equals precisely those 38 specifications
plus Main. Its eight virtual copies reconcile with the seven fixed
Unchecked_Conversion instances and Image_I(Integer). Main's mode neither loads
an external body for inlining nor instantiates a new generic body; the already
closed input/Image/concat calls do not admit a further semantic compilation
unit. Instance analysis uses the fixed generic syntax inside those units.
The existing once-per-unit analyzed guard therefore gives **K_sem <=39**.
This is a source closure, not promotion of the observed Units table top.

Keep the whole witness and use its final process totals, including its fixed
gigi numerical increments. Add 288 ordinary nodes/2592 slots for all 36
possible Main implicit-with clauses and 1336 element-list headers for all
RE_Id first-lookup residues. Context_Items already exists, and Maybe_Add_With
uses Append, without another list header (`rtsfind.adb:1257–1327`). The resulting
fixed inputs to the common table join are:

| Dimension | Fixed contribution before variable Main/scanner/common addends |
| --- | ---: |
| Node identities | 41176 |
| Entity identities, deliberately bounded by all captured nodes | 40888 |
| Dynamic AST slots | 441449 |
| Syntax-list headers | 6526 |
| Elist headers / elements | 2313 / 2096 |
| Uint entries / digit words / Ureal entries | 24324 / 74958 / 60 |
| String descriptors / characters | 203 / 7255 |
| Name entries, including retained reserve | 6222 |
| Xref positive increments | 353 |
| New semantic compilation units | 39 |

The entity overcount uses a captured defining entity's node identity; it does
not require a separate entity measurement. Implicit-with nodes contain no new
entities. The fixed AST count of 41176 also dominates every fixed-scaffold
call marker in the invocation join. Scope saves remain variable: the common
metadata row adds 40 Elist headers and `39*(40888+E_Main+1)` elements,
conservatively retaining the scope saves already present in the witness.

Counter-dependent fixed names need a character correction. Add_Unique_Serial_Number
writes a Nat in decimal and a fixed spec/body letter; New_Internal_Name and
New_External_Name only add their documented fixed prefixes/suffixes
(`tbuild.adb:58–99,638–726`). Subject to serial-counter headroom, a decimal run
has at most ten digits. Replacing every original character by ten characters
therefore bounds *all* serial-run growth in the fixed name table, including
qualified occurrences, without relying on which short serials the witness
happened to use. This is a coarse fixed normalization, not an extra source cap.

Let P bound a **complete pathname** in the controlled invocation. Preserve the
selected search-directory/invocation shape and fixed filenames: variable
installation/workspace path prefixes occupy the slash-bearing pathname roles;
fixed basename and relative-directory tokens remain prescribed. The corrected
retained name inventory has 56 slash-bearing spellings, containing 831 slash
characters in total. All are absolute or `./` paths in this capture, but do not
assume that a generated name contains only one path. Charge one complete path
per original slash. Every variable path occupies a slash-bearing role, so this
overcounts even a name concatenating several paths/options. The 112914 decoded
characters including NUL, plus the 5000-character lock reserve, leave four
characters of positive-growth excess. Treat each of those four characters as
another pathname rather than assuming an unrecorded spelling. Thus 835*(P+1)
characters safely pay replacement path occurrences, retaining all old path
bytes too. The largest decoded spelling has 17 slashes, which also dominates
the four unrepresented characters; use 17 replacement paths in one name for
the buffer bound. It does not assume that this workspace's historical paths will
be used later, or permit extra search directories under the same constant.

For input-binding length d (zero when absent), the sufficient fixed name charge
is

```text
Name characters = 10*117918 + 835*(P+1) + 4*max(0,d-1).
fixed Name_Buffer demand <= 1700 + 17*(P+1) + max(0,d-1).
```

The buffer bound uses the recorded maximum spelling length170 and the same
decimal/path/input-name corrections. These corrections add no Name entry.
The default literal is always charged by its source scanner and standalone
literal transfer, even if the fixed witness already paid for its one-character
default. `native_fixed_frontend` emits the constants and corrections. Its
4096-path example is arithmetic only: integration supplies and enforces P.
The source/root/freezing and all-miss premises remain necessary; this collector
does not turn the retained capture into a universal compiler proof by itself.

## Normalized Main frontier for backend composition

The following finite type/constructor frontier follows from the grammar and
the closed String/input/Image paths. It narrows backend transfer cases; it
is **not** a complete native node count or a claim that source scalar,
assignment, comparison and loop expansion multiplicities are closed.

| Family | Form reaching the backend |
| --- | --- |
| Source scalars | Standard Integer32 and constrained subtypes, Boolean, and Character8 components; no source real/fixed/modular/user-defined scalar type |
| String values | One-dimensional Standard String with Positive32/Integer32 index bounds; literals remain String literals, not per-character frontend aggregates |
| Ordinary result storage | Constrained String objects, scalar bound/length/position temporaries and String slices |
| Input capture | Access-all unconstrained String, reference capture and dereference; source D is a renaming |
| Secondary concat storage | Access-to-constrained String, allocator using `SS_Pool`, and dereference renaming; allocator selects `SS_Allocate` (`exp_ch4.adb:3347–3420,4652–4654`) |
| Integer Image | String(1..11), Natural position, Image_Integer call, and returned String(1..position) slice |
| Concat movement | Str_Concat_2 through Str_Concat_9 calls at O0; ten or more retained operands use slice assignments with optional Boolean guards |
| Main cleanup | One fixed nested `_finalizer` carrying SS_Release; mark object of imported runtime Mark_Id type |

`Mark_Id` contains a stack pointer and a `Stack_Pointer` record containing
Memory_Index and a chunk pointer (`libgnat/s-secsta.ads:295–308,335–341`).
Memory_Index uses the target's System.Parameters.Size_Type
(`s-secsta.ads:251–260`, `s-parame.ads:57`); address/size lowering is therefore
not restricted to Integer32. The recursively declared runtime chunk and stack
types belong to the fixed dependency graph, not a source-dependent family of
record fields. No source construct introduces a record aggregate or a nested
subprogram. The fixed finalizer is the only additional local subprogram
created by these String/input/Image paths.

Direct application calls are the five admitted Silver library operations,
Image_Integer (the System.Img_Int alias of System.Image_I(Integer)), the eight
concat helpers, SS_Allocate, SS_Mark and SS_Release. Runtime/check lowering
may introduce further fixed backend helpers. Bounds/checks leave ordinary
Integer arithmetic, comparisons, Boolean operations, conversions and
conditional expressions; scalar source multiplication is a separate admitted
operator, not part of the additive-only concat-bound graph. Source if/for
control flow and generated blocks remain structural constructs. Backend
GCC modes, fat/thin pointer descriptors, check lowering, GCC aggregate
construction and code-size/identity costs must be derived against this
interface; the Ada frontier does not prescribe their exact representation.

## Numeric magnitudes in the closed concat stages

The query-root bridge can also supply the missing digit bound for the combined
native emitter stages. This result uses the selected Linux target's 32-bit
Integer/Nat and signed Standard/Universal widths no greater than 128. The
target-width/source-correspondence premise is explicit; it is not a deduction
from the checkout path. Require `2<=n` and `n+1<=Nat'Last`, as the emitter's
own arrays and final loop increment already require.

Use the fixed scalar seed **M=2^127**. It covers every signed Standard endpoint,
including Universal_Integer's endpoints. Cstand constructs signed ranges from
their widths and builds Universal_Integer with the largest signed runtime
width (`cstand.adb:237–257,1322–1350,1395–1407`, `ttypes.ads:100–117`). Length
narrowing explicitly selects Integer_Type_For with `Uns=>False`, so the
unsigned 128-bit endpoints do not enter this graph
(`exp_ch4.adb:14488–14501`, `exp_util.adb:8852–8890`).

All incoming String index values fit Integer; take their magnitude as at most
2^31. The earlier direct-emitter formula, including unknown-length sentinel
256, therefore yields

```text
direct metadata magnitude <= n*(2^32+1)+2^31+1 < 2^63 <= M.
```

This covers every literal manufactured for incoming bounds, fixed lengths,
aggregate lengths and the known maximum. The normalized source String-bound
graph contains addition/subtraction, Length, regular conversions, ordinary
signed leaves and internal-constant forwarding. It contains **no source
multiplication**: Integer Image's scalar argument is a separate computation,
and its result-bound descriptor refers to the generated buffer length. Alias
reuse and generated bound captures do not add other arithmetic operators.
Current-condition constants accessible on these generated bound entities are
zero/one or already covered generated lengths; source code cannot name them.

Induct on the Determine_Range visit recurrence D, counting shared dependencies
again at every use. A literal, unrefined leaf or scalar type-bound value has
magnitude at most M. Addition/subtraction endpoints and their intermediate
negations are bounded by the sum of the two child envelopes. Ordinary Length
forms `high-low+1`: the low/high child visits pay for the first two terms and
the current visit pays for 1, since M>=1. Unary operations and conversions
cannot require a larger sum; internal constants follow their initializer.
Static folds produce values already covered by the same arithmetic. It follows
that **M*D(root)** bounds every retained value and arithmetic intermediate in
one range query, hence **M*A** for the closed query roots. This does not assume
clipping to the scalar base range: Determine_Range can return disjoint computed
ranges, which still satisfy this induction (`checks.adb:5155–5167,
5230–5310,5400–5465,5557–5606`).

The other numeric consumers in these stages are bounded as follows:

| Consumer | Magnitude envelope |
| --- | ---: |
| Literal-Last Compare_Fixup | `2^31+(2^31-1) < M` |
| Comparison offsets, differences and unit adjustments | `2*M*A+1` |
| First compile-time size, including multiplication by 8 | `8*(2*M*A+1)` |
| Cold size-selection power cache | `2^126` |
| Explicit Integer index layout | `2^31` |

Compare_Fixup uses the stored low plus length (without assuming Ada's usual
minus-one formula); the bound covers its actual arithmetic
(`sem_eval.adb:1019–1028`). The comparison difference/current-condition
operations are the ones already inventoried at `1321–1759`. First-size
arithmetic uses at most the low/high difference, unit addition and factor 8
from the earlier subtype/storage transfers. Get_Size_For_Range's largest
requested cached power is 2^126 (`exp_ch4.adb:13566–13608`). No unrestricted
power or source scalar multiply has been silently priced as an addition.

A convenient uniform magnitude for **all combined emitter stages** is

```text
V = (16*A+8)*2^127
k = number of base-32768 digits of V.
```

It dominates each row above. Thus the per-group retained Uint digit charge is
`k*((3816*n+2296)*A+3696*n+1697)`; a whole-Main uniform A gives
`k*(9928*A+9089)*c`. The previously derived local arithmetic-vector peak becomes
**5*k+3 digit words**, separate from recursive stack and table-growth storage.
The per-group k can be used instead of a uniform maximum. This magnitude
calculation adds no further Uint appends; no warm-cache assumption is introduced.

`native_concat_numeric_magnitude` checks these arithmetic envelopes, including
the maximal permitted n. Its examples are not language thresholds. This closes
numeric magnitudes **only for the combined vector's already closed stages**.
Original source scalar/Image/input analysis, standalone String operations,
whole-scope and runtime-dependency numeric work still need their own bounds.

## Source concat folding and its literal suffix

The native emitter is preceded by semantic String folding. This is a separate
addend because a folded source concat does not reach that emitter. Charge both
paths for every source `&`; excluding mutually exclusive paths is unnecessary.
The following closes Eval_Concatenation/Fold_Str and the literal-resolution
suffix of concat operands, under the ordinary Main/no-diagnostics premises.
Parsing, source-name/Image/input constructor analysis and standalone literal
resolution in a potentially dynamic assignment subtype remain separate.

Let c be the number of source String concat operators, and let B(e) be a sound
upper bound on the number of characters in source expression e. The value
summary composes as `B(left & right)=B(left)+B(right)`; a source object name
uses its declaration's length bound, and every occurrence counts. Literal,
input and Image seeds are supplied by their existing value/domain analysis.
For this transfer require `0<=B(e)<=Integer'Last` for each concat, rather than
assuming the frontend's String table can represent larger strings. This is an
input-domain premise, not a new admission rule or a table-capacity conclusion.

Resolve_Op_Concat's iterative left-spine walk visits each original operator
once, with recursively disjoint right children (`sem_res.adb:10580–10639`).
Resolve_Op_Concat_First sets the operation type to the base Standard String;
operand resolution also uses that base (`10644–10762,10769–10806`). Thus its
literal suffix has static Positive low bound 1, even when the surrounding
assignment target's own subtype has a dynamic low bound. The latter standalone
literal case must not be charged by this transfer.

Test_Expression_Is_Foldable reads flags/constant values. Its nonstatic-context
helper returns immediately for String; there are no scalar overflow routes
(`sem_eval.adb:478–495,7226–7348`). Compile_Time_Known_Value and Get_String_Val
follow the finite earlier-constant chain without allocation. The latter returns
an existing literal; its allocating character-recovery route requires an error
and is excluded (`1812–1918,5293–5309`). Eval_Entity_Name does not replace String
constant references with their initializer (`2449–2533`). None of this unfolds
runtime loops or allocates a fresh String for a mere alias.

For each actual fold, Eval_Concatenation (`2342–2443`) either reuses the right
String when the left is empty, or invokes Start_String once and appends the
right String. Start_String(S) allocates one descriptor and copies at most the
left length; its end-of-table sharing optimization can only reduce that charge.
Store_String_Chars appends the right length directly to the retained table,
and End_String returns the identifier without allocation
(`stringt.adb:87–90,157–192,221–243`). No separate character work buffer is
created by these helpers. Thus one fold adds at most **one String descriptor
and B(e) retained characters**. Across Main use **c descriptors and sum B(e)**
over all source concats, even nonfolded ones. Charging only the final value, or
only source literal bytes, would miss repeated intermediate retained values.
Parser/scanner String production is an additional charge; parser folding can
reduce the number of semantic operations but supplies no credit here.

Fold_Str creates one String literal and rewrites the original concat. Include
one saved-original node and one possible growing-slot event: **two ordinary
nodes and one growth event**. Analyze_String_Literal sets fields only. Resolve
reuses an existing literal subtype or calls Set_String_Literal_Subtype once
(`sem_eval.adb:5118–5144`, `sem_ch2.adb:304–325`,
`sem_res.adb:12039–12117,13205–13242`). With Standard String's static low bound
the latter creates one E_String_Literal_Subtype/internal name and at most one
Uint for its length, reusing the existing low-bound node. Its dynamic-low
range/unchecked-conversion path cannot run. A fold's empty-left subtype reuse
likewise retains a known String constant's static low bound; neither input nor
mutable String names qualify as a compile-time-known constant value here.

Eval_String_Literal invokes String_Type_Len once. For Standard String this
computes the static Positive range length, costing at most three Uint appends
for subtraction and addition (`sem_eval.adb:4052–4167,6571–6584`). Null with
low 1 is legal; the required B(e) premise excludes the too-long diagnostic.
Character validation either reads existing ASCII characters or is skipped for
a folded concat. Standard Character is the full base component type, so the
per-character Uint/aggregate conversion route is excluded
(`sem_res.adb:12126–12266`). There is no native String-literal expander case.
The general Resolve tail's Mark_Use_Clauses only reads and marks existing
use-clause chains (`sem_ch8.adb:9525–9742`). The outer operation-reference/xref
work is outside this literal/fold suffix.

First freezing of this fresh literal subtype adds at most **one Uint**, and
no ordinary/entity node, list or name. Its base, component and index are the
already frozen Standard types. As with the earlier artificial array subtype,
there are no aspects, packing, predicates, controlled components or delayed
freeze. The only size arithmetic is `8*String_Literal_Length` in
Check_Compile_Time_Size (`freeze.adb:822–834`); Set_Small_Size affects RM_Size
only, leaving Esize unknown (`773–794`). Therefore the alignment helper returns
before arithmetic. Layout_Type explicitly clears both size fields and returns
for a String-literal subtype (`layout.adb:237–246`). The remembered
Size_Known_At_Compile_Time flag and Is_Frozen guard prevent repeated arithmetic.
No freeze node is created, so Freeze_Before/Freeze_And_Append allocate no
placement list (`freeze.adb:2804–2850,6537–6552,8143–8187,8265–8286`). A subtype
registered only after operand resolution may freeze later; its same one-time
cost is charged here, without claiming the entire later scope walk is free.

The mixed comparison `Len > String_Type_Len(Bas)` additionally converts Len
through UI_From_Int; charge one Uint append even if an earlier conversion
of that same length exists (`uintp.adb:1683–1686`). Consequently one
literal-resolution suffix, including potential first subtype creation and
freezing, adds at most **one entity/name, thirteen name characters including
NUL, and six Uint appends**: length conversion, three range-length operations,
the mixed comparison conversion, and one size multiplication. A direct
Set_String_Literal_Subtype plus its first freeze, without Eval_String_Literal,
costs one entity/name, thirteen characters and two Uint appends. Each Uint
magnitude is at most `8*(2^31-1)`, hence at most **three base-32768 digits**.
The existing internal-serial representation premise still applies to names.

For each source operator, conservatively charge two original literal-operand
resolutions, one folded-result resolution and two explicit post-concat literal
subtype registrations (`sem_res.adb:10808–10832`). The registrations and the
folded-result case are mutually exclusive; this deliberate overcount also
allows a replacement subtype whose earlier one remains retained. Normalized
literal operands moved into later native calls retain Analyzed, so that move
does not replay these suffixes. This gives the separate whole-Main addend:

| Demand | Bound |
| --- | ---: |
| Ordinary nodes | `2*c` |
| Growing-slot events | c |
| Entities/internal names | `5*c` |
| Name characters, including NUL | `65*c` |
| Uint appends / retained digit words | `22*c` / `66*c` |
| String descriptors | c |
| Retained String characters | `sum B(e)` over source concats |
| Syntax lists, Elists, hash wrappers, Xrefs | 0 |
| Dynamic slots | `332*c` |

This addend is recorded by `source_concat_folding` in derive.py. It can be
added to the following emitter vector. It does not change that vector's A or
create a new recursive scalar query: the only scalar computations above have
static Standard endpoints, existing lengths and multiplication by 8. Source
operand constructors, outer concat overload/name resolution, standalone
String literals, fixed dependency processing, wrapper/scope helpers and the
backend are still required for the whole native phase.

## Combined Main direct-emitter vector

The closed addends can now be composed without stitching their rows by hand.
For one n-operand invocation, add:

1. The direct/scalar/storage vector, with **b=28, l=2** for the normalized
   result-bound pair.
2. The remaining direct copies and duplicators, including their raw-bound
   decorated-copy allowance.
3. Up to n suppressed slice assignments, using **t=31, l=2** for each
   normalized assignment range. Include both length-check passes, overlap and
   optional-guard skeleton.
4. First passes over each raw copied scalar-bound tree and the two possible
   result-storage captures. Incoming normalized RHS values retain Analyzed.
5. One enabled final result slice at t=31,l=2, including first result-object
   freezing and the nonallocating constrained actual-subtype lookup bridge.
6. One runtime concat procedure call, including the two empty post-call lists,
   possible variable-reference markers and source-operand xref attempts.
7. Up to n uncached input-dereference actual subtypes after the assignment
   expander's explicit Get_Referenced_Object traversal. A constrained source
   name does not justify omitting this separate referenced-object lookup.

These charges deliberately overcount mutually exclusive helper-call and slice
assignment routes. They give the following single vector of closed stages:

| Demand | Per invocation | Whole Main with c source `&` and uniform A |
| --- | ---: | ---: |
| Ordinary nodes | `(900*n+520)*A + 1252*n + 1198` | `(2320*A+3702)*c` |
| Uint appends | `(3816*n+2296)*A + 3696*n + 1697` | `(9928*A+9089)*c` |
| Syntax-list headers | `76*n+95` | `247*c` |
| Growing-slot events | `139*n+99` | `377*c` |
| Entities/internal names | `28*n+32` | `88*c` |
| Name characters, including NUL | `367*n+423` | `1157*c` |
| Elist headers | `10*n+11` | `31*c` |
| Elist elements | `20*n+20` | `60*c` |
| Copy-map hash wrappers | `30*n+30` | `90*c` |
| Positive Xrefs-table increments | n | `2*c` |

The whole-Main column uses `sum n_i <= 2*c` and `g <= c`, and vanishes for
c=0. A better source-sensitive calculation sums the per-invocation vector
with each group's own **n_i and A_i=3*H_i+7** from the source-bound and
query-root recurrences; using one maximum A is optional. This scoped A_i
covers the original and generated query roots in these combined stages;
remaining callees still need their own root inventories. With the pinned slot
maxima, the uniform dynamic-slot addend is
`9*(ordinary+growth)+61*entities = (20880*A+42079)*c`. Node identities/link
tables, physical bytes and temporary stack/workspace remain separate
representations. For these stages the numeric-magnitude closure above supplies
`k=digits_32768((16*A+8)*2^127)`, including cold power-cache extension. Multiply
the Uint row by k to bound retained digit words.

**This is not the whole native construct or a usable admission predicate.**
The next sum adds the separately derived source-concat folding/literal suffix,
Image, source scalar/statement/store/call rows and output wrapper. First input
and Main secondary-stack cleanup use the source-reduced fixed scaffold above;
first runtime lookups/spec processing and all common process/representation
terms must be joined separately. The exact residual list at the end supersedes
earlier intermediate descriptions of those now-derived source constructors.

The previously stated local helper premises remain binding. Normalized b/t
are phase summaries; their raw first-pass/capture costs are now separately
included rather than silently omitted.
`derive.py` sums the existing helper functions, asserts both columns and the
slot arithmetic, and emits the residual list with `whole_construct_closed`
False. No compiler or expensive validation run is needed for this arithmetic
reconciliation.

## Composed Main native constructor vector

`main_native_construct_vector` now sums these rows in one place:

| Addend | Inputs and scope |
| --- | --- |
| Parser/scanner node core | Existing parser transfer's nodes, slots, lists and entities, including scanner nodes, source defining-name promotions and raw literal-chain flattening |
| Original scalar analysis | Source operators/names, the two additional loop-bound passes and raw loop-bound copies |
| For skeleton | Each source loop once, independent of runtime trip count |
| Integer stores | All Integer declarations, constraints and assignments |
| String stores | Later String declarations and all String assignments; first input is fixed scaffold |
| Standalone String literals | Literal resolutions outside concat plus direct literal-assignment dynamic continuation |
| Predicates and control | Every comparison, short circuit, Boolean not, if and elsif |
| Image | Each source Image once; scalar argument already in scalar analysis |
| Output wrappers | Each output call once; supplied value constructors counted separately |
| Source call/leaf bookkeeping | The preceding marker, call-list and kind-change row |
| Native concat emission | Uniform combined envelope, with c the source `&` count |
| Concat folding/literals | Source concat length summaries and semantic literal suffix |

Each branch counts syntactically even if unreachable. Original source argument
or initializer construction is charged once; local generated-action transfers
include their first analysis and freezes. Copies of resolved children do not
multiply source constructors. Known overlaps, including fixed-witness Main
work if retained without subtraction and duplicate marker/static-literal
allowances, are conservative positive addends.

The parser inputs are the existing source formulas in
[retained-table-capacity.md](retained-table-capacity.md), not measured values
from an example. Scanner name, Uint and String pools are additional
representations and are **not** included merely because scanner nodes are
present. The function's two recorded parameter examples check the sum
arithmetic, not parser correctness or program membership.

Let O, G, E and L be the sums of generated ordinary nodes, growing events,
fresh entity identities and syntax-list headers in the rows after the parser.
The resulting accounting is

```text
node identities = parser_nodes + O + E
entity identities = parser_entities + E
dynamic slots = parser_slots + 9*(O+G) + 61*E
syntax-list headers = parser_lists + L.
```

Parser entity identities are already part of parser node identities. Fresh
generated entities need both charges; promotions of parser defining names do
not create another identity. Generated Name entries are E plus the two fixed
output-wrapper names if any output call is present. The character sum already
includes those two names and all individual constructor terminators; deferred
full qualification and backend names remain separate.

The sum also retains Uint appends, folded String descriptors/characters,
pending-copy Elist headers/elements, copy-map wrappers, positive xref increments
and output qualification-queue appends as distinct columns. No byte total is
inferred from node or slot counts. Retained Uint digits use distinct query
families. Let G=largest_scalar_tree+1 and A be the common query envelope:

```text
k_scalar = ceil((130G+2)/15)
k_String = digits_32768((16A+8)*2^127)
k_scope  = digits_32768(incoming_depth+2*short_circuits+output_calls+1).
```

| Constructor Uint population | Digits per append |
| --- | ---: |
| Original scalar analysis, for skeleton, Integer stores | k_scalar |
| String stores, standalone String-literal suffix, native concat emitter | k_String |
| Predicate comparisons and generated query work | max(k_scalar,k_String) |
| Predicate EWA scope-depth work and output wrappers | k_scope |
| Image-local work | 10 |
| Concat folding/literal suffix | 3 |

Multiply each population's already-derived Uint count by its row's digit
bound, then add. The source scalar grammar is the only family with general
multiplication. It has the earlier G bound, including captured loop-bound
initializers. Every String-bound/store query uses the additive descriptor
graphs proved above: bound captures, addition/subtraction and Length; its
only size multiplication is the already-priced factor eight. Image's source
argument is charged in original scalar analysis and does not enter the result
bound descriptor. The returned buffer has the fixed low/high D seed (1,2).
Predicates compare either scalar expressions or String/Length operands; Length
is not admitted inside scalar arithmetic, so a comparison never multiplies
the two query families. Using their maximum covers either branch. The Image
and literal-only suffixes retain their existing local magnitude proofs.

This split avoids applying the multiplicative scalar envelope to potentially
much larger additive String graphs. The mixed arithmetic fixture's complete
logical Uint-digit demand falls from roughly1.96 billion to48,952,135 and
passes the selected Udigits backing checks. Its inputs are still an arithmetic
fixture, not a real program or an admission result. The incoming-depth
parameter must bound the actual enclosing Main/source scope depth; separate
scope-stack backing and temporary arithmetic vectors retain their own joins.

`whole_native_frontend_closed` stays False. This executable sum closes the
constructor accounting join; it does not silently include the common-table,
fixed-process, backend or physical-workspace terms below.

## Native common metadata join

The following native transfers reuse mode-independent primitives from
[retained-main-semantics.md](retained-main-semantics.md), with their native
caller differences checked explicitly. Let W be source word tokens, c source
concat operators, B source short circuits, M source Image occurrences, o output
calls, d the maximum enclosing source-loop depth and L the maximum source
identifier length. Let E_Main be the constructor sum's entity identities;
E_fixed, X_fixed and K_sem are the source-reduced fixed entity/xref and
newly-analyzed-unit bounds supplied by integration. Fixed witness Main work may
overlap E_Main. Define E_X=E_fixed+E_Main.

### Overload tables

The source overload domain is unchanged: at most three Standard String-family
interpretations plus one sentinel per source concat, and at most one direct
operation interpretation plus a sentinel per word-token allowance. Scalar
objects/types and generated bound/capture references are not overloadable.
Source concat children are resolved before native expansion; their copies
retain that resolved state. Generated scalar operators and explicit pointer
dereferences have a single known type. The native copies therefore do not
reconstruct the source concat's alternatives.

Save_Interps allocates one sentinel and one new map key, even though it then
points that key at the old list (`sem_type.adb:3324–3346`). The parameterless-call
allowance is already one per W. Native Resolve_Short_Circuit also calls
Save_Interps when relocating its left child (`sem_res.adb:11684`); add one
sentinel/key per B without relying on that child's usual nonoverloaded Boolean
status. Artificial check short circuits have the already established
nonoverloaded scalar comparisons. Insert_Explicit_Dereference sees the
nonoverloaded generated access name (`sem_util.adb:15830–15865`); other
Save_Interps routes need the excluded operator-call, implicit access-to-function,
mixed Boolean-array or generic forms. Consequently

```text
All_Interp Main entries <= 4c+3W+B
Interp_Map Main bindings <= c+2W+B.
```

These are lifetime append/binding bounds. The fixed dependency interpretations,
initial All_Interp backing and the 3079 Interp_Map hash headers remain separate.

### Full-name qualification and queue

The earlier path-sensitive Q(e) transfer can now use an explicit whole-Main
envelope. A permanent source/generated scope path contains Main, source loops,
at most two EWA scopes per source short circuit, and at most one output
transient block. Output calls are statements and cannot be nested in another
output actual. The generated scalar selectors and artificial check wrappers
have the earlier no-new-scope transfers; concat and Image add no permanent
scope of their own. Include the one fixed Main finalizer as an extra scope
allowance. Temporary freeze-time pushes do not change an entity's Scope chain.

All those internal loop/block names have at most 12 characters under the
serial-counter bound. Generated type names are either such internal names or
the source-object-derived subtype/index forms; the largest source-derived
suffix is five characters (`TT<D>SP1`, documented above). Thus

```text
m = d+2B+[o>0]+1
u = max(12,L+5)
Q_max = 6+14m+u
additional qualification Name entries <= E_Main
additional qualification Name characters <= E_Main*(Q_max+1).
```

The six characters are `main__`; each intermediate scope adds at most 12
characters and `__`; the final entity contributes u. Qualifying all E_Main
entities overcounts ordinary local objects that return without a Name_Enter.
It also includes the Main name, whose actual length is four. This is an
explicit count/length transfer, not an assumption that source identifier
length bounds generated names. Require Q_max to fit the existing Name_Buffer
and corresponding index/length arithmetic. The previous per-entity Q(e) sum
is a sound sharper alternative.

The fixed input's two type names and two qualified names stay in the fixed
capture, with their separate `4*(|D|-1)` correction; they do not disappear
because E_Main excludes fixed scaffold constructors. Internal serial names in
that capture likewise keep their documented normalization correction. Neither
correction creates another entity or name entry.

Qualify_Entity_Names is called once per output block and once for Main and its
possible fixed finalizer (`exp_ch5.adb:3469`, `exp_ch6.adb:6815`). Its ordinary
for-loop caller is inside the **iterator** branch, excluded here
(`exp_ch5.adb:6099–6115`). Analyze/Expand_Expression_With_Actions has no
qualification enqueue. Therefore `Name_Qualify_Units` has at most o+2 Main
appends, independently of how many entities each queue entry eventually walks.
Main/finalizer queue work may already be in the retained capture; paying it
again is conservative. Fixed package/unit queue entries remain fixed terms.

### Native xrefs and unit-boundary Elists

Generate_Reference's source/Force and entity gates remain active in native
mode. Native additionally records **both enclosing-scope fields as Empty**
and uses Original_Location(Sloc), rather than the light mode's two reference
scope alternatives (`lib-xref.adb:1144–1168`). Main creates no instantiation or
virtual source region. The ordinary source binding pairs remain unique through
scalar range copies, normalization and relocation. The native-only named-actual
branch references the formal at the selector token's own location
(`sem_res.adb:5197–5222`); that token is included in W. Native does not follow
String renamings to the generated underlying pointer: Get_Through_Renamings
is in the GNATprove-only branch (`lib-xref.adb:1069–1087`).

The forced ordinary caller family is Main's body/end references. Its closing
label can temporarily advance one location past `Main`, already allowed by
W+1 (`sem_ch6.adb:4198–4202`, `sem_util.adb:27377,27518`). Child-parent labels,
subprogram renamings/completions, derived/record/dispatch references and private
package end references are absent in variable Main work. Its ordinary kinds
are r, m, s, w, b, l, t, with e allowed conservatively. The earlier 16(W+1)
bound remains safe despite native needing only one scope choice. Keep the
already charged explicit concat/Image positive increments as additional
allowances rather than assuming every generated reference is free.

Add_Entry still increments tentatively before duplicate detection and rolls
back duplicate Last values. Hence the **backing demand**, including a tentative
slot, is

```text
X_native = X_fixed+16(W+1)+2E_X+2c+3M+1
ALI xref sorting vector <= X_native+1 Nat words.
```

The two per-entity terms cover definition and orphan keys; fixed and explicit
terms may overlap. This is a bound on live distinct keys plus the tentative
slot, not on all lifetime increment calls. Output_References' sorting vector
and physical table/hash layouts remain representation terms. The native Drefs
addend is zero even with generated pointers: the explicit-dereference and
write callers, and the through-renaming reference route, are guarded by
GNATprove_Mode (`sem_ch4.adb:2225–2230`, `sem_util.adb:26142–26148`,
`lib-xref.adb:1069–1087`). Its initial table storage remains.

Finally the unit-boundary save transfer is mode independent. Each Semantics
entry creates a Save_Scope_Stack Elist even when empty; each currently visible
entity is appended at most once because the append clears its visibility.
Newly analyzed compilation units append once to Comp_Unit_List
(`sem_ch8.adb:10270–10324`, `sem.adb:1431–1491,1650–1673`). Therefore add
K_sem+1 Elist headers and K_sem*(E_X+1) element records. Native pending-copy
lists and first-runtime-lookup lists already have separate positive rows;
this boundary term does not replace them or fixed dependencies' internal lists.

`native_common_metadata` computes all these aggregate terms and uses the
actual constructor sum for its example E_Main input. K_sem and fixed counts
still need source-reduced integration values. Native invocation/elaboration
containers, warning attempts/history/text, stack peaks and table/byte
representations are not silently included in this join.

## Native invocation and elaboration metadata

This transfer assumes the selected modern static elaboration mode:
Legacy_Elaboration_Checks=False, Dynamic_Elaboration_Checks=False and
Relaxed_Elaboration_Checks=False (`opt.ads:488,923,1341`), with invocation-path
debug printing disabled. Native Invocation_Graph_Recording_OK does **not**
return at the GNATprove guard, so its graph and ALI data must be counted
(`sem_elab.adb:12226–12248`). No capture is needed to establish this distinction.

The only variable source callees are the five admitted operations. The
constructor closure additionally identifies Main, its one fixed finalizer,
Image_Integer, the eight Str_Concat_2 through Str_Concat_9 helpers, and
SS_Allocate/SS_Mark/SS_Release. This is a conservative **19-entity target
frontier**, independent of source call count. Most generated runtime calls
do not actually get a marker: Build_Call_Marker requires a source call or an
Ada/bridge/SPARK semantic target (`sem_elab.adb:3671–3707,14399–14469`).
Ordinary runtime helpers fail those generated-target predicates. Keeping them
in the 19-entity frontier avoids taking credit for their absence in the table
bound. The finalizer does pass the bridge predicate; it must not be omitted.

Let A_fixed be the source-reduced fixed native AST bound supplied by the
existing fixed capture and reduction. Every fixed-scaffold marker and the
invocation graph's dummy Main marker is a node in that bound. This deliberately
uses the entire fixed node count rather than making a new measurement or
subtracting witness work. Let C be source library calls, c source concats,
M source Images, and W source word tokens. Use

```text
S_call = C+c+M+A_fixed.
```

The c and M allowances permit one marker per concat/Image helper even where
the filter excludes it. Source original calls occur once; the fixed input's
relocation belongs to A_fixed. There is no body inlining or variable family
of user subprograms. Scenario_Reps and Node_To_Scenario_Map cache by marker;
Target_Reps and Entity_To_Target_Map cache by target, refreshing a record
without appending it (`sem_elab.adb:11300–11324,11429–11472`). Thus their Main
entry bounds are S_call and 19 respectively.

Record_Elaboration_Scenario classifies Main declarations as Declaration_Level
and its statements as No_Level. Calls may enter Declaration_Scenarios; local
variable markers never enter the library-level sets, and a suitable variable
assignment requires assignment to an entity in a package spec from its package
body (`sem_elab.adb:13900–14126,14855–14936`). Main has neither. Dynamic checks
return because Dynamic_Elaboration_Checks is False (`14212–14225`). Source has
no instantiation, derived-type declaration or Refined_State pragma. Therefore
Declaration_Scenarios has at most S_call members; Dynamic_ABE_Check,
Library_Body, Library_Spec and SPARK sets have zero Main members.

Guaranteed-ABE processing does not traverse bodies. The earlier external
up-level target guard still excludes declaration-call ABE diagnostics and
conditional body traversal (`sem_elab.adb:5350–5460,9499–9616`). The fixed
finalizer is already defined before its cleanup call. At invocation processing,
Process_Main_Unit makes the one dummy Main call. Process_Invocation_Call
traverses a target body only inside the extended Main unit; external Silver
operations record an edge and stop, while internal runtime units return
(`12472–12548,12672–12730,12802–12847`). Consequently only Main and its one
finalizer can be traversed, and an active scenario chain has at most three
entries even allowing a leaf runtime call.

Traverse_Body caches one scenario list per body and skips nested encapsulators.
Its full scan collects calls and variable markers as well as the predicate's
selected scenarios. Subsequent visits reuse the list
(`sem_elab.adb:3102–3400`). Therefore allow two Nested_Scenarios_Map bindings,
two list headers and **2*(S_call+W)** list elements; the factor two safely
pays either body's traversal without relying on their disjoint membership.
The traversed-body set peaks at two. Even allowing each of the two bodies as
a separate DFS root gives at most four lifetime insertions. Declaration-level
external calls do not add body traversals. Early_Call_Regions_Map and
Unit_To_Attributes_Map add no Main entries: their derived-type/elaboration-
pragma routes remain absent.

The invocation graph deduplicates constructs by entity and relations by
(invoker,target) **before** appending ALI records
(`sem_elab.adb:12165–12193,13190–13241`). With T=19, allow T Saved_Constructs
members/ALI construct records and T² Saved_Relations members/ALI relation
records. This remains valid for the default endpoint encoding or full-path
encoding: repeated calls do not create new entity pairs. Invocation signatures
deduplicate their complete name/scope/line/column/location tuple
(`ali.adb:735–767`). During this one graph pass those attributes are stable,
so at most T signature records/map bindings are needed.

Signature_Of does not format source-dependent arbitrary object identifiers.
The actual signatures belong to Main, its finalizer and the five fixed Silver
APIs: In_Internal_Unit returns before recording runtime targets. In particular,
Image_Integer's canonical generic-instance alias is not formatted here.
The interface spellings listed in `native_invocation_metadata` include the
excluded runtime targets only to enlarge the allowance; their maximum of 36
characters safely bounds every actual signature name without assuming that
all runtime canonical names have that spelling. Qualified_Scope calls
Get_Qualified_Name (`sem_elab.adb:13309–13399`, `sem_util.adb:11155–11216`).
Allow an already qualified child-package spelling to receive its parent
prefix again: `system__system__secondary_stack` is 31 characters and dominates
the scope spellings here. Repeated identical Name_Find calls reuse names, so
T extra Name entries and 32T characters suffice, with a 31-character name
buffer peak. Main and these selected library declarations are not instance
copies; the 2052-character local instantiation-location buffer is still
reserved, but creates no location Name entry. Line and column are passed as
Nat, with no Uint allocation. The fixed source locations do not bound Main's
line number: all legal Nat values, up to ten decimal digits, are allowed.

Write_Invocation_Signature emits name, scope, line, column and `none` between
brackets (`lib-writ.adb:1770–1807`). Its length is at most
36+31+20+4+6=97 characters. Each graph construct/relation record is bounded by
two such signatures plus 48 characters for its prefix, tags, separators,
optional extra name and newline; an extra-name allowance of 36 already
dominates the parameterless finalizer's empty/ordinary type-name case.
Allow 20 bytes for graph attributes. The invocation-only ALI addend is thus
`20+(T+T²)*(2*97+48)` bytes. Other ALI records and output-buffer backing remain
separate; this does not claim a complete ALI file bound.

`native_invocation_metadata` computes these terms. The three ALI tables each
have initial capacity 2500 and 200-percent growth, and their signature map
starts with a Create(500) request (`ali.adb:129–174`). Existing elaboration
container initial sizes from the shared primitive inventory still apply even
when Main adds zero members. Table/hash/list target layouts and growth peaks
must be joined separately. No extra source constructor, Uint or dependency
body work is hidden in these metadata rows.

## Native scope, check and expander stack peaks

Use the complete Main constructor vector's node and syntax-list counts,
`A_Main` and `L_Main`, including discarded rewrites and list headers. Let
`d_loop` bound simultaneously enclosing source loops, B count source short
circuits and o count output calls. The fixed native source reduction above
permits the retained all-roots lifetime totals to dominate fixed stack peaks;
these are **not observed stack depths**. Keeping the witness's entire Main
work, use 1117 scope pushes, 520 expander-flag pushes and 6526 list headers.
The resulting logical bounds are

```text
Scope_Stack live entries <= 1117 + d_loop + 2B + [o>0] + 2
Expander_Flags live entries <= 520 + A_Main + 1
Saved_Checks_TOS <= 6526 + L_Main + 1.
```

The scope term counts source loops, at most two analyzed EWA scopes per source
short circuit, and at most one output transient/replacement-block scope on an
active path. The output transient is popped before its replacement block is
analyzed, so those pushes are sequential. Main's scope and its fixed finalizer
are already overcounted in the retained fixed total. Conditions, ordinary
scalar/check conditionals, declarations, assignments and native concat helper
calls introduce no additional permanent scope. The type frontier excludes
variable packages, record declarations, task/protected scopes and subprograms.

For native first freezing, Expand_N_Freeze_Entity can push the entity's outer
or currently closed scope, and can separately push the scope of a generated
renaming-as-body (`exp_ch13.adb:470–594,637–649,686–694`). The latter is absent
from the Main constructor frontier, but two entries conservatively pay both
sites. Main's scalar/String/index/access freezes have the closed no-body
transfers above: they create no nested init/assignment/equality or contract
subprogram body. Thus those temporary pushes do not form a source-dependent
recursive chain. Freeze_Before's nested-package push, Freeze_Entity's delayed
record-component-aspect push and Freeze_Expr_Types' expression-function scope
are excluded by their own guards (`freeze.adb:2844–2865,6728–6770,9529–9545`).
Fixed-runtime analysis may occur under the current Main stack; adding its
whole lifetime total pays that ambient join without assuming a favorable load
order. Push_Scope reuses an existing Scope_Depth. The only new block-depth
Uints are already in the output/EWA constructor rows; this peak join adds none.

For expander flags, Analyze_If_Statement can hold at most one save per active
if node. A compile-time-true arm sets Del, so later elsif arms take the Del
branch without another save; false-arm saves are restored before the next
arm (`sem_ch5.adb:2008–2052,2064–2103`). Generated concat assignment guards
are if nodes already counted in A_Main. Every concurrently active variable
if has a distinct node identity; rewritten/copy nodes remain in A_Main even
when the final tree discards them. Each ordinary loop-bound preanalysis can
add one further save, but its scalar expression has no nested statement or
preanalysis construct (`:4868–4886`). The two raw loop preanalyses are sequential.
All other variable saves require target-name assignments, entry/interface/BIP
calls, aggregates, quantified/iterator filters, contracts/aspects, protected
access, generic bodies, errors or legacy elaboration, excluded by the grammar,
constructor frontier and selected mode. Fixed semantic-unit and generic/spec
preanalysis saves stay in the 520 fixed lifetime allowance. This deliberately
uses all Main nodes rather than estimating a maximum source-if depth that
would omit generated guards.

Analyze_Statements is the only caller of Conditional_Statements_Begin/End
(`sem_ch5.adb:4523–4582`). Each active nonempty call processes its own statement
list. Analyzed children are not recursively reanalyzed; an inserted wrapper
gets a distinct list, while branch lists and loop bodies are nested structural
children. Already analyzed statements moved into an output block therefore do
not make a recursively active duplicate of the enclosing list. There are no
body-inlining or contract-copy routes in variable Main. Hence active nonempty
calls inject into the lifetime list identities. An empty/No_List call returns
without another Analyze call, so one extra entry pays that possible leaf.
Adding fixed list identities also covers a first dependency analysis nested
inside Main without needing a separate check-stack capture.

At O0 the selected range/overflow helpers return before saving a redundant
check, so there are no variable Main Saved_Check records. The fixed storage
remains 200 Saved_Check records and 100 Nat stack entries. Begin increments
the Nat counter **before** checking the 100-entry array limit; above that limit
it kills the optimization cache, and End safely resets/decrements it
(`checks.adb:174–201,4921–4973`). The 100-entry array is consequently not a
100-level language limit. Require the derived peak to fit Nat/Int to protect
the increment, independently of physical stack exhaustion.

`native_stack_peaks` regenerates these terms. Scope_Stack uses low bound zero,
initial length10 and 200-percent growth; Expander_Flags uses low bound zero,
initial length32 and 200-percent growth (`sem.ads:499–596`,
`alloc.ads:118–119`, `expander.adb:65–71`). The generic table backing envelope
must still be applied to their live-entry counts and actual target layouts.
These logical bounds do not price recursive Ada call frames, local numeric
vectors or semantic helper stacks, and do not make physical exhaustion a
language-membership test.

## Native frontend diagnostic join

Native compilation retains Warnsw's defaults; it does not receive GNATprove's
warning mask. The selected application argv contains no enabling warning/style
override. Configuration and source-to-installed-tool correspondence remain the
existing process premises. At `warnsw.ads:121–196`, Check_Unreferenced,
Check_Unreferenced_Formals, Check_Withs, Constant_Condition_Warnings,
Warn_On_Constant, Warn_On_Deleted_Code, Warn_On_Hiding, Warn_On_Modified_Unread,
Warn_On_Redundant_Constructs and the other optional source-style warnings used
by the earlier caller partition are False.

Dependency analysis must preserve those values. The read-only
[native warning input inventory](../evidence/unbounded-programs/retained-native-expansion-20261017/native-warning-inputs.json)
hash-reconciles all 42 Ada source inputs in the retained fixed native capture's
input manifest. The sole Warnings/Style_Checks pragma is
`Warnings (Off, Default_Bit_Order)` in System, which affects that entity, not
the global switch set. There is no one-string Warnings pragma that executes
Set_Warning_Switch (the native-only route at `sem_prag.adb:28781–28820`), nor
a style override. Source Main permits only SPARK_Mode(On). This is an inventory
of the already retained input set, not a new compiler capture or a substitute
for proving that set covers the fixed dependency roots.

The additional enabled native defaults have these caller exclusions:

| Enabled family | Main exclusion |
| --- | --- |
| No_Value_Assigned | Every source object is initialized, Main has no formals; generated capture/buffer entities fail Check_References' Source_E1 gate (`sem_warn.adb:1266–1278,1570–1670`). |
| Questionable_Missing_Parens | No Boolean equality operands under and/or/xor, no modular not, and every compound scalar operand of unary minus is parenthesized by the source grammar (`sem_res.adb:9210–9227,10980–11001,12824–12934`). |
| Assumed_Low_Bound | Requires indexing an unconstrained String formal; Main has no formal or source indexing, and generated views are not formals (`sem_warn.adb:4411–4428`). |
| Unchecked_Conversion | Validate_Unchecked_Conversion is called for a generic unchecked-conversion instantiation (`sem_ch12.adb:7103`, `sem_ch13.adb:19744–19836`); generated N_Unchecked_Type_Conversion nodes do not enter it. Fixed dependency instantiations remain fixed work. |
| Compatibility/implementation-unit/pragma warnings | Ada 2022, ASCII and admitted syntax exclude obsolete/extension forms; Main withs only the two ordinary Silver packages and uses its one recognized pragma. Generated runtime with clauses are implicit; no source import/export, layout, size/alignment, biased/modular or bit-order clause is admitted. |
| Assertion/contract/elaboration warnings | Main has no author assertion or contract. Its fixed library callee contracts are fixed work; the preceding ABE guard excludes the variable Main call route. |

The remaining shared caller argument transfers: no static Constraint_Error
under the admitted scalar/range/length conditions; explicit-range for loops
only; source Integer ranges nonempty; generated empty String ranges not source
subtype declarations; no invalid source recovery or undefined-name path.
This does not use successful legality to discard legal warnings. In particular
null/possibly reversed source-loop warnings remain reachable even inside
statically unreachable contexts.

Only the two already bounded families remain: at most two attempts per source
for loop (`sem_ch5.adb:3480–3571`) and one context-license attempt per explicit
with-name (`sem_ch10.adb:3980–4117`). Main's context is installed once, and the
license branch excludes implicit runtime with clauses. With F source loops and
N_with explicit source with-names, define

```text
J_diag = 2F+N_with
M_diag = 1024+2*32767 = 66558.
```

Count attempts before suppression. The shared Errout primitive appends raw
history before Warning_Mode and null-loop suppression; suppressed native data
representation warnings are therefore covered too (`errout.adb:550–697`).
The remaining raw templates have at most 64 characters, their chains at most
two parts, and no diagnostic code, fix, extra span or label. Formatting uses
the pinned Max_Msg_Length buffer (`erroutc.ads:125–135`, `types.ads:181`), not
an assumed bound on arbitrary source names. The resulting Main additions are:

```text
Non_Instance_Msgs, Errors and Locations appends <= J_diag each
raw-history string characters <= 64 J_diag
formatted-text lifetime characters <= (2M_diag+2) J_diag
diagnostic string allocation requests <= 2 J_diag
continuation-join local vector <= 2M_diag+2 characters.
```

Unreferenced_Entities adds zero because its enabling flag/formal alternatives
are absent (`sem_warn.adb:1676–1720`), and In_Out_Warnings has no formal to
record. Edits, Fixes, nonempty labels, source Warnings/Specific_Warnings/
Warnings_As_Errors entries and additional diagnostic Uint arithmetic are zero.
Retain every table's initial backing even at zero additions. The shared
formatted-text transfer counts the old and replacement strings in a joined
continuation, without depending on allocator reuse (`errout.adb:1377–1525`).

`native_diagnostic_metadata` computes the bounds. The large fixed message
maximum is deliberately conservative; no new cap is chosen from it. Rendering,
backend diagnostics and fixed dependency messages are distinct consumers, and
physical table/string allocation layouts remain representation terms.

## Executable native logical-table composition

`native_frontend_logical_join` now composes the Main constructor vector, concrete
fixed inputs, native common metadata, invocation metadata and stack peaks in
one executable arithmetic interface. Its `tables` result supplies AST identities
and slots, syntax/element lists, numeric/String/name pools, overload entries,
qualification queue and xrefs. The node-indexed next/previous link arrays include
the two extra initialized positions. The separate invocation result preserves
its container types; a hash map is not silently counted as a Table array.

The six scanner-pool inputs are mandatory: Name entries/characters, Uint
entries/digits and String descriptors/characters. They must be supplied by the
scanner component including its rescan/lookahead behavior. Parser AST/list
inputs are already in the Main vector and are not added twice. Source with-name
count likewise remains a separately supplied input to the native diagnostic
transfer. The JSON's zero-scanner arithmetic fixtures are **not real-program
capacity results** and cannot be used as admission thresholds.

This closes the previously symbolic fixed entity/xref/unit inputs at these
joins. It leaves the named parser auxiliaries, fixed non-table heap containers,
physical backing/layout/growth/caller arithmetic, local and recursive workspace,
complete ALI/debug/backend/object/linker and independent proof-producer terms.
In particular the retained fixed gigi numbers do not absorb variable Main
callbacks into Uint/Repinfo. No larger source language follows from a sum of
logical table demands until those remaining joins and correspondence are closed.

## Core native table backing and caller checks

`native_core_table_backing` applies the previously derived generic table
capacity envelope to 22 concrete native tables, using the logical join above.
The selected Linux64 representation premise is explicit: Int/IDs/Char_Code
are32 bits, Character/Boolean are bytes, addresses are64 bits, and an access
to an unconstrained String occupies at most the two-address descriptor.
No new compiler/layout measurement was run. Source clauses and the existing
node-layout derivation give the C-facing sizes; ordinary native record sizes
below are upper bounds including target alignment.

| Table family | Bytes per component used by the bound |
| --- | ---: |
| Node_Offsets header | 16 |
| Orig_Nodes, Next_Node, Prev_Node, Slots | 4 |
| Syntax-list header | 12 |
| Elist header, element record, Uint descriptor, String descriptor | 8 |
| Uint digit, String character | 4 |
| Ureal record | 16 |
| Name entry / Name character | 16 / 1 |
| Interpretation record | 16 |
| Name_Qualify_Units | 4 |
| Xref record | 40 |
| Scope_Stack entry | 320, a padded upper bound |
| Expander_Flags | 1 |
| Paren_Counts / Parents_Stack | 8 / 4 |

In particular, Node_Offsets is the **16-byte header**, not one four-byte offset
per node (`atree.ads:725–740`). Slots are separate four-byte words. Uint/String
records each contain two Int fields (`uintp.ads:564–570`,
`stringt.adb:48–51`). Ureal has three four-byte scalars and a Boolean, bounded
by16 bytes (`urealp.adb:36–49`). Interp has four entity IDs
(`sem_type.ads:65–70`). The Xref key has six four-byte fields and one Character;
rounding that to28 bytes and adding its three remaining Int fields gives40
(`lib-xref.adb:68–114`). Scope_Stack has20 immediate components. Each fits a
16-byte slot after alignment: its two potentially wider values are the String
access descriptor and Suppress_Record (30 packed Boolean bits plus two small
enums); its Scope_Actions array is three List_Ids. Hence20*16=320 is sufficient
without claiming an exact packed Scope_Stack layout (`sem.ads:489–583`,
`types.ads:725–726,775–788`). The collector checks the20-field/30-check source
facts on regeneration.

For each table use its actual initial size, increment, low bound, nominal
logical ID domain and the configured Table_Factor. The default factor is1;
configuration must preserve that or supply its actual value. For logical
demand D, initial i, factor f and increment g, all calculations below are
mathematical integers:

```text
p = max(D,i)
C = max(i*f, D+floor(D/1000), floor(p*(100+g)/100), p+10).
```

C bounds backing capacity through growth and release. Check i*f and C+1 in
signed Int, p*(100+g) in signed64, low-1 in signed Int, low+C in signed Int,
and low+D-1 against the actual logical ID upper bound. The zero No_List ID
is excluded from allocated list headers. Other ID domains preserve their own
sentinels and first valid IDs; using one generic positive-count limit would
miss their offsets. The backing sentinel uses the table's actual Base/Int
index conversion, distinct from the logical ID subtype. Include (C+1)*bytes
in the signed64 pointer-difference/address bound, which also implies the
unsigned64 allocation-size bound. These are sufficient checks; a failing
conservative bound does not establish that GNAT would fail at that input.

The 22-table byte subtotal is `2*sum((C+1)*component_bytes)`. This pays old/new
storage during a relocating realloc for every table simultaneously, and thus
overcounts any single growth event. This subtotal is descriptive only: it
is not compared with an aggregate RAM/address-space ceiling and contributes
no admission condition. Per-object allocation-size and pointer-difference
checks remain. It does not guarantee available memory or successful physical
allocation. Hash containers, local temporaries and
unlisted tables are not hidden in this subtotal.

Two auxiliary table demands now close without a new construct inventory:
Set_Paren_Count searches by node before appending, so Paren_Counts has at most
the complete lifetime node count (`atree.adb:2331–2361`). Copies/rewrite nodes
are already in that count. The parent-aware traversal stack holds one root
parent plus one entry per active syntactic node. Its three callbacks only
check/fix parent links; they do not recursively start another parent-aware
traversal (`sem_util.adb:3943–3977`, `sem_ch13.adb:11310–11332`,
`contracts.adb:4750–4782`). Use A_total+1, preserving the traversal's enforced
nonreentrancy (`atree.adb:2747–2765`). Neither result prices recursive Ada frames
or permits cyclic syntactic child edges.

The accompanying non-table subtotal charges3079 eight-byte Interp_Map bucket
pointers and16 bytes per key/element/next wrapper. Fixed bindings are bounded
by all fixed nodes; Main bindings use the native common-metadata transfer.
Xref hash headers are65536 four-byte entry indices with links already inside
the Xrefs records. Its output sort vector is `(Xrefs+1)` Nat words. Saved-check
fixed arrays use200 records of at most20 bytes and100 Nat words. Reaching zero
Main additions does not erase these initial arrays.

There is a distinct name-length conversion beyond Name_Buffer capacity.
Name_Enter and Name_Find cast Buf.Length to **Short**, whose maximum is32767
(`namet.adb:1146,1252`, `types.ads:74`). Therefore **every interned spelling**,
including source identifiers, generated/qualified names and path spellings,
must fit32767 even though Name_Buffer holds4*32766 characters. The checker uses
the maximum of the fixed normalized spelling bound and Main's qualified and
unqualified spelling bounds. It also checks the Saved_Checks_TOS Nat increment.
The path-bound200 fixtures illustrate these calculations only; the earlier
P=4096 fixture fails this conservative fixed-name check because it deliberately
allows17 entire paths in one spelling. Neither fixture is a selected language
threshold. Integration must use the controlled invocation's actual bound or
justify a tighter name-producer shape.

The remaining physical surface is still explicit: other native tables and
heap containers, parser/source/line state, diagnostics and invocation records,
Repinfo/backend callbacks, numeric/local workspace and recursive stack,
serialization/ALI, and the independent proof producer. The selected arithmetic
checker reports this incomplete scope even when every check in its subtotal
passes.

## Real-source composition checks

The [representative inputs](../evidence/unbounded-programs/retained-native-expansion-20261017/representative-inputs.json)
freeze five current sample files by SHA-256 and record manually reviewed syntax
counters. The regenerator reads those exact source bytes, verifies every token
with a deliberately restricted fixture lexer, recomputes lexical counts and
checks the arithmetic/operator/declaration inventories against the manual
counters. This is an evidence harness for these sources, not a second Silver
recognizer. It does not establish a language membership or whole-tool claim.

Unlike the earlier zero-scanner arithmetic fixtures, these inputs include real
scanner and parser contributions. Every identifier/literal/numeral receives
the established two-visit scanner allowance. Source-word names contribute
W entries and B_w+W characters without multiplying interning by rescans. All
numerals here are ordinary decimals no larger than4088, with no exponent or
based-literal route; every prefix operation remains a direct Uint, so their
scanner Uint/digit contribution is zero. String scanning contributes2S
descriptors and2L characters. No sample has1000 plain-literal concatenations,
so there is no parser-flattening suffix. The source-sensitive parser equations
then supply nodes, entity promotions, slots and lists.

| Current source | Bytes | Parser nodes / slots / lists | Common A | Complete joined Uint digits | Selected22-table checks |
| --- | ---: | ---: | ---: | ---: | --- |
| `samples/null.adb` | 69 | 28 / 313 / 4 | 19 | 74,958 | Pass |
| `samples/hello_world.adb` | 118 | 38 / 412 / 5 | 19 | 75,019 | Pass |
| `samples/for_loop_step.adb` | 202 | 79 / 955 / 7 | 19 | 441,119 | Pass |
| `samples/command_line_greeting.adb` | 355 | 99 / 1,031 / 9 | 145 | 33,954,969 | Pass |
| `samples/find_square_difference.adb` | 330 | 127 / 1,387 / 10 | 19 | 11,450,651 | Pass |

“Joined” includes the preserved fixed process vector, source scanner pools and
Main/common/invocation components in the executable join. The selected checks
retain Table_Factor=1 and the **conditional complete-path bound P=200** with
the fixed invocation/search shape. The fixtures do not establish that every
installation satisfies P; integration must supply/enforce its actual bound or
tighten the fixed-name producer bound. No arbitrary source threshold follows.

The guarded greeting exercises input, a short circuit, Length comparison and
two concatenations. Its source guard bounds the intermediate output length by
4095 and the final result by4096. Its low/high descriptor graph yields A=145,
whereas its scalar source-tree maximum remains1. Applying the old common
multiplicative digit bound to all work would produce3,984,705,879 digit words,
failing Udigits backing arithmetic; the constructor-family split produces the
33,954,969 above. This demonstrates a concrete composition benefit without
claiming that either number measures actual compiler memory. The mutable
Integer sample separately exercises a constrained object, assignment, a loop,
two comparisons, Image and a scalar tree with five operators/six leaves.

The output records every source hash, manual counter explanation, derived
scanner/parser input, logical join and selected backing check. Validation was
source/hash inspection and arithmetic regeneration only. No compiler,
GNATprove, Lean, full test suite or application execution was performed.

## Required transitive closure

At optimization level zero, two through nine retained operands use an available
`System.Concat_n.Str_Concat_n` helper; the actuals loop moves operands without
deeply copying them. Ten or more take the slice-assignment loop
(`exp_ch4.adb:3492–3624`). Fewer than two return the retained operand after
setup. The direct envelope overcounts helper and slice paths, so it does not
assume helper availability. The local call analysis is now included above;
runtime first loading/spec processing remains separate.

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
normalized Main operands above: the input function is confined to its first
declaration, and subsequent aliases are ordinary names. The input construction
itself uses the separate fixed-scaffold reduction, with its variable
literal/name and first-lookup corrections.

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
freezing transfers cover the closed local paths above; runtime first loading,
wrapper/scope handling and the diagnostic error path remain separate.

## Exact remaining obligations

The constructor sum supplies a common A and all source construct rows listed
above. The native frontend/process is still incomplete at these explicit joins:

- **Fixed scaffold and dependencies:** the source-root/freezing reduction and
  concrete fixed join now supply the retained constants, first-runtime-lookup
  Elist/implicit-with corrections, input-name normalization and configurable
  pathname charge. Preserve the controlled invocation/search shape and supply
  the actual path bound; charge every variable default literal through its
  scanner/standalone-literal row. These premises still need integration into
  the complete capacity rule.
- **Native common metadata:** the executable logical join now supplies fixed
  entities/xrefs/units to qualification/queue, unit-scope save, overload and
  xrefs. The separate native invocation/elaboration join supplies its scenario,
  target, DFS, graph/signature and invocation-ALI terms using the fixed AST
  input. The native diagnostic join supplies
  warning attempts/history/text under the recorded defaults and fixed-source
  pragma inventory. The native stack join bounds scope/check/expander peaks;
  common auxiliary containers and physical layouts still need their own
  counts even where constructors are zero.
- **Representations and late consumers:** the22 selected backing joins and
  five source-counted examples now compose actual scanner/parser inputs for
  those examples. A general source counter/descriptor implementation and its
  correspondence remain required. Compose the existing physical/virtual
  source, line/column and name-buffer components; finish backing/layout and
  individual allocation/caller checks for the unjoined parser auxiliaries,
  copy maps, diagnostic tables/strings, invocation graph/hash/DFS containers
  and fixed non-table heaps. Temporary numeric vectors, serialization
  (including full ALI), and relevant fixed buffers remain separate. The
  backend's callbacks into Ada Uint/Repinfo allocation are additional to this
  before-gigi constructor sum, even if the AST identity count stays unchanged;
  their phase-unlock/growth state must join the same physical table checks.
- **Caller arithmetic and recursion:** require all table indices and loops to
  fit their actual scalar types. In particular concat's `List_Length`, `NN`
  and terminal `J := J+1` require n+1 to fit Nat; its seven local arrays have
  `1..n` or `0..n` bounds (`exp_ch4.adb:2598–2621`). Bound their byte products,
  lower-bound recursion depth (at most n), semantic/copy/deferred-name stacks
  and native expander stack. Check actual per-object sizes, local indices and
  counted recursion/depth representations; do not turn the sum of independent
  allocations or recursive-frame bytes into an aggregate RAM/address-space
  admission ceiling. Physical resource exhaustion remains a separate condition.
- **Backend and process composition:** close gigi/GCC/object/linker terms and
  phase lifetimes, then compose the independent GNATprove producer. None is
  implied by the native constructor frontier. Every proposed source capacity
  check must then have recognizer/proof correspondence and universal coverage.

Current source/operator/String limits remain unchanged. This component does
not complete #119 or unlock dependent admission changes.
