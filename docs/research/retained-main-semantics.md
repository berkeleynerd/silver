# Retained Main semantic allocation bridge

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-18, Linux x86_64. This connects the source-counted parser to ordinary
GNATprove semantic/light-expansion work. It supplies a source-counted bound on
Main's allocated node identities, including entities and discarded syntax,
for the producer's `A_Main` input. **It does not supply a complete frontend
table/byte bound, whole-process bound or admission predicate.**
The subsequent aggregates also close Main's scalar range/comparison query
invocations, literal/subtype and ordinary freeze-layout Uint contributions,
and semantic syntax-list headers under the stated source shapes.
Native expansion is a separate process contribution; no production, proof,
language, Oracle or tool-pin file changes here.

The source is GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Its relation to
the embedded frontend in the inspected/installed SPARK producer remains the
explicit premise in the [capacity contract](retained-tool-capacity.md).
The evidence checks the relevant files against the retained complete GCC
manifest. No compiler, prover or Lean run was performed.

## Source counters and boundary

Use the current grammar with its numerical budgets allowed to vary, successful
semantic legality, `GNATprove_Mode=True`, `Expander_Active=False`, and disabled
validity checks. Keep Standard and the selected library entities outside the
Main-local contribution. Their setup, semantic analysis and freezing need their
own process terms. No user-defined operators, types, contracts, conversions,
renamings, generic units or object aspects are introduced by this domain.

Reuse `A_parse`, `F`, `D`, `R`, `O`, `P` and the parser's other counters from
[the table component](retained-table-capacity.md#main-parser-constructor-transfer),
and `D_s`, `D_lit`, `D_alias`, `K_literal` from
[the entity component](retained-frontend-entities.md). Additionally:

| Counter | Source-derived meaning |
| --- | --- |
| `B_loop` | Sum of syntax-node sizes of the raw loop ranges: one range node plus the two scalar expression trees per loop; grouping adds no node |
| `O_loop` | Scalar operators in those loop-bound trees; each belongs to one source loop |
| `G <= 2F` | Captured loop bounds; using `2F` avoids reproducing the capture decision |
| `U` | String `/=` occurrences |
| `H_len` | Length attributes |
| `V0` | Parameterless Input_Is_Valid calls |
| `C_lib` | All admitted library calls: argument-bearing calls, Reject and Input_Is_Valid |
| `N_ref` | Source occurrences of mutable object names, including assignment targets; all source identifier-token occurrences are a conservative alternative |
| `D_copy <= D_s` | String declarations whose constant-name initializer is replaced by a literal copy; `D_s` is the conservative syntactic bound |
| `N_assign` | Source assignments of either type; counting String assignments too conservatively covers every scalar assignment |

`B_loop` is computed from recognized source, not a measured decorated tree.
The static declaration classes can conservatively use `D_lit + D_alias <= D_s`.
All arms, unused declarations and empty loops count. Runtime iteration counts
do not multiply these semantic traversals.

## Raw range copies and scalar replay

`Prepare_Param_Spec_Loop` copies the raw range for preanalysis, and
`Analyze_Loop_Parameter_Specification` makes another copy when native expansion
is disabled (`sem_ch5.adb:3962–3979,3295–3311`). Neither original range has been
semantically decorated at its respective copy point. The source range contains
only scalar names, integer literals and operators, with no owned itypes,
defining entities, syntax lists or expression actions. The ordinary tree-copy
case therefore contributes exactly `2*B_loop` new ordinary nodes, no entities
and no syntax lists. Referenced entities are shared, not copied.

`Preanalyze_Range` disables full analysis/freezing; side-effect removal excludes
that preanalysis (`sem_ch5.adb:4868–4886`; `exp_util.adb:12619–12630`). Each
bound expression has three ordinary semantic passes: its two copies and its
original. A later capture relocates an already analyzed whole bound; it does
not recursively analyze one new copy per operator.

There is an additional **root replay**: `Resolve_Range` explicitly clears the
lower endpoint's Analyzed flag and resolves it again in GNATprove mode
(`sem_res.adb:11200–11214`). Its already analyzed descendants return from
Resolve. Charge one additional root visit per range resolution: `3F` for
source loops and one each for the `R` explicit Integer ranges and the
`D_lit` generated String ranges. This replay is absent from the native-mode
argument and must not be inferred away from the usual Analyzed guard.

The explicit final endpoint `Fold_Uint` calls at `sem_res.adb:11260–11268`
require `Expander_Active`; they add no further light-mode folding events.

## Declaration and capture construction

These rows count **direct syntax constructors, shallow relocations and saved
originals**, before the separate expression folding, check-query, freezing and
layout terms. Generated entities are counted separately below.

| Route | Ordinary nodes | Syntax lists | Fresh entities |
| --- | ---: | ---: | ---: |
| Explicit Integer object-range subtype skeleton | `2R` | `R` | `R` |
| Static literal String subtype skeleton | `13D_lit` | `2D_lit` | `2D_lit` |
| Static constrained String-name alias skeleton | `4D_alias` | `D_alias` | `D_alias` |
| Scalar bound capture | `5G` | `G` | `G` |
| Late String initializer literal copy | `2D_copy` | `0` | `0` |

`Find_Type_Of_Object` creates a defining identifier, a subtype declaration and
one relocation of the existing indication, then wraps its single Insert_Action
in a list (`sem_ch3.adb:19121–19198`). This gives two ordinary nodes per
explicit subtype. The inherited standard base freezes separately.

For the literal String case, `Make_Literal_Range` constructs seven nodes:
two copies of the existing static lower literal, two integer literals,
subtraction, addition and range (`exp_util.adb:10664–10711`).
`Expand_Subtype_From_Expr` adds a subtype indication, String occurrence and
index constraint, one syntax list and at most one saved original. Adding
Find_Type's two nodes gives `7+3+1+2=13`, before analyzing the two arithmetic
operators. `Constrain_Array` reuses its existing one-element constraint list;
`Constrain_Index` creates the scalar index entity and shares that range
(`sem_ch3.adb:14339–14484,15317–15492`). No additional syntactic range is
created for Standard.String's ordinary, non-fixed-lower-bound index.

The static-name alias route creates a subtype declaration and existing-type
occurrence, then a replacement type occurrence and possibly its saved original:
four nodes, one entity and one action list (`exp_util.adb:5989–6011`). It aliases
the prior index. The nonstatic-initializer guard at `:5897–5899` returns before
either String subtype route, including mutable-name, Image and input results.

A captured scalar bound gets an entity, declaration, type occurrence, new
reference, relocation and possible saved original: five ordinary nodes plus
one entity/list (`exp_util.adb:12761–12824,13102–13111`). This is the whole
elementary expression, with its analyzed children retained. Assignment_OK and
the local check suppression prevent new scalar checks in the generated
declaration; the new constant reference needs no second capture. The existing
entity argument establishes `G<=2F`; this row does not count captures again.

### Late constant-name propagation needs a separate charge

`Analyze_Object_Declaration` finally tests whether its initializer is the name
of a String constant whose `Constant_Value` is a literal. It then executes
`Rewrite (E, New_Copy (Val))` (`sem_ch3.adb:5436–5453`). This is reachable for
ordinary `B : constant String := A;` and mutable declarations initialized from
such constants. It adds a shallow copied literal and at most one saved original.
The copy retains its analyzed flag, String_Id and subtype; there is no additional
Stringt character/descriptor allocation or literal-subtype entity.

Consequently the existing `K_literal` entity and String-pool formulas survive,
but a count of **literal node identities** must add `D_copy`, and a total of
their decoded lengths must add the initializer's length at each such declaration.
The producer keys a static literal theory by actual node identity, so these
copies cannot silently share the prior literal's module. The producer component
adds them to its `K` and aggregate length allowances; ordinary expression visit
count stays unchanged because a source name is replaced by one leaf.

## Expression skeleton and folding

The following additional direct light-expansion charges are separate from
semantic folding:

| Route | Ordinary nodes | Growing-node events | Syntax lists |
| --- | ---: | ---: | ---: |
| String `/=` to `not (=)` | `3U` | `U` | `0` |
| Surviving Length to universal-Integer conversion | `4H_len` | `H_len` | `0` |
| Parameterless validity name to function call | `V0` | `V0` | `0` |

String inequality constructs Not and Eq, preserving its existing children,
and Rewrite may preserve the old root (`exp_spark.adb:1008–1023`;
`exp_ch4.adb:10217–10256`). Their possible two folds are charged separately.
Scalar `/=` uses the standard elementary operator without this rewrite.

`Apply_Universal_Integer_Attribute_Checks` creates a type occurrence,
relocation, conversion and possible saved original (`checks.adb:4028–4044`).
The inner Length is marked analyzed first, preventing repeated wrapping.
The source attribute may fold before that route; charging both attribute and
conversion folding is conservative. Image has no corresponding light expansion.

`Check_Parameterless_Call` makes one shallow relocation, then changes the old
root's kind to Function_Call; it allocates no argument list
(`sem_res.adb:1462–1478`). It excludes an existing function-call name to avoid
repeating this conversion. Conversion of operator-looking String literals and
qualified names can grow existing nodes without creating identities; their
mutations need their separate slot charges.

One successful ordinary `Fold_Str` or signed Integer/Boolean `Fold_Uint` adds
at most two ordinary nodes: its replacement literal/name and a saved original,
plus at most one growing Copy_Node event (`sem_eval.adb:5118–5222`;
`atree.adb:1301–1333,2222–2276`). The replacement uses an existing scalar value
or String_Id; computing that value has a separate Uint/String cost.
Define the **ordinary fold-call allowance**

```text
T_fold = O + P + 2O_loop + 3F + R + 3D_lit + 2U + 3H_len.
```

The terms charge source operators/artificial parser concatenations, the two
range-copy operator passes, lower-root replay, two generated literal-range
arithmetic operators per `D_lit`, the two inequality operators, and two Length
fold calls plus its conversion. `Eval_Attribute.Length` can first fold from
known bounds and then fold again from `Compile_Time_Compare`; there is no
return between those branches (`sem_attr.adb:9898–9970`). The third charge
allows a conversion fold without relying on branch exclusivity. Leaf names
retain their values without copying their
initializers during Eval_Entity_Name (`sem_eval.adb:2454–2532`); the late
declaration copy above is a distinct route. This allowance covers the listed
ordinary evaluators. The query closure below excludes additional ordinary-node
construction in their reached semantic helpers.
Their syntax-fold subtotal is `2T_fold` nodes and `T_fold` growing events.

## Range-check construction is live allocation, even when discarded

Each ordinary loop invokes `Process_Range_Expr_In_Decl` once after its original
range is analyzed. This captures its bounds and invokes Get_Range_Checks
without checking Expander_Active (`sem_ch3.adb:22588–22734`). After capture,
each bound is either its no-larger pure scalar tree or a single constant name.
The [native helper's structural transfer](retained-native-expansion.md#range-check-trees-are-constructed-before-suppression)
is applicable to this constructor: it uses no native expansion itself.
For the ordinary Main range trees this gives the source-counted upper charge

```text
A_range_build <= 2B_loop + 28F,    syntax lists = 0.
```

The `B_loop` expression intentionally still includes each original range root.
Static Integer object ranges and static String index bounds are known in their
target range and create no check tree through this selection route. Numeric
comparisons still have to be charged.

`Insert_Range_Checks` returns immediately when native expansion is disabled
(`checks.adb:8139–8141`). Thus these discarded trees receive neither recursive
analysis nor a producer visit. In particular their generated First/Last
attributes do not enter the ordinary semantic query graph. The source
short-circuit handler's empty expression-with-actions wrapper also requires
Expander_Active (`sem_res.adb:11680–11698`) and is absent here.

## Query graph: no additional ordinary-node identities

The zero-syntax result here is specific to this grammar and light expansion;
it does not make numeric queries allocation-free. Consider the graph reached
from source scalar expressions by operand, constant-initializer, captured-bound,
current-value and scalar-type-bound edges. Its leaves are existing integer or
Boolean values and existing entity references. Explicit Integer bounds contain
only scalar arithmetic and earlier Ada-static constants. Captured loop bounds
preserve that shape; their declarations do not manufacture an attribute.
Generated String indexes are static literal arithmetic, and aliases share a
previous static index. Nonstatic String initializers retain Standard.String.
Source attributes are only Integer Image and a declared String name's Length.

The reviewed `Determine_Range` closure constructs Uint values but no syntax.
The sole syntax allocation in `Compile_Time_Compare` is `Compare_Fixup`'s
materialized Last of an `E_String_Literal_Subtype`
(`sem_eval.adb:995–1067`). Neither the graph above nor current-value expressions
introduce First/Last. Discarded loop checks may contain such attributes, but
the checks are not analyzed, and their constructor's comparison queries use
the existing scalar operands and bounds. Static range checks on generated
declaration subtypes have static operands and return without building checks.

`Eval_Relational_Op.Decompose_Expr` can allocate an occurrence when unfolding
a captured bound (`sem_eval.adb:3489–3505`). Its only caller is the final,
dynamic-index branch of the nested `Static_Length` helper. Main Strings are
literal subtypes, static ordinary subtypes or unconstrained Standard.String;
each returns in an earlier branch (`:3645–3718`). Thus that constructor is
unreachable here, including comparisons of Image/input expressions. String
length-check insertion also exits before constructing anything when
`Expander_Active=False` (`checks.adb:2234–2286,3509–3534`). Successful scalar
assignment checks set flags or issue the numeric queries, with no syntax
constructor on the admitted non-error path (`:3155–3503`).

`Eval_Attribute.Set_Bounds` materializes a high-bound literal only for a
literal-subtype prefix (`sem_attr.adb:8308–8405`). The grammar requires a
declared String name before Length; its declared type is an ordinary String
subtype or Standard.String, not the initializer's literal subtype. Its bounds
therefore already exist. Integer Image does not fold: the only Image folding
branch requires an enumeration literal (`:9717–9751`). The remaining reached
evaluators fold at most as charged above; array indexing, slices, aggregates,
predicates, real/fixed arithmetic, user-defined/intrinsic calls and error-tree
recovery are outside this source shape. `sem_warn.adb` contains no syntax
constructor or rewrite; its additional scalar comparisons use the same graph.

Consequently these query paths add **zero ordinary-node identities**. They
receive source-derived invocation, unfolded-expression and Uint charges below.
Those charges do not follow from the old 32-bit result premise: intermediate
range estimates need a separate magnitude bound.

## Freeze, markers and the enclosing Main

### At most one freeze node per Main entity

`Freeze_Entity` returns for an already frozen entity, marks the first ordinary
visit frozen, and reuses an existing freeze node or allocates one
(`freeze.adb:6536–6550,6809,8265–8283`). The cases that clear the flag require
incomplete/private/class-wide types or an incomplete formal profile, absent
from Main. Its type helpers do not create another type or support subprogram:

| Helper | Reached Main case and syntax result |
| --- | --- |
| `Layout_Object`, `layout.adb:225–231` | Null procedure. |
| `Layout_Type`, `:235–664` | Literal String subtype clears size fields; signed Integer and ordinary String subtypes set/inherit size and alignment. No syntax constructors. |
| `Check_Compile_Time_Size`, `freeze.adb:750–912` | Elementary types are immediate; one-dimensional String size uses existing bounds and Uint arithmetic. |
| `Freeze_Array_Type`, `:3641–4276` | Ordinary subtype of Standard.String; bit-packed implementation, full-access and record/invariant branches are excluded. |
| `Freeze_Object_Declaration`, `:4282–4605` | Modular-array size check and delayed-aspect/address rewriting require native expansion; no user aspects/imports apply. |
| `Freeze_Static_Object`, `:10223–10390` | Existing types/bounds/flags only. |
| `Freeze_Profile`, `:4748–5094` | Main is a procedure with no formals; no profile traversal or return type. |
| `Freeze_Subprogram`, `:10402–10771` | Ordinary nonimported procedure; `Create_Extra_Formals` returns when expansion is disabled (`sem_ch6.adb:8934–8946`), and `Set_Mechanisms` has no Main formal or result. |
| `SPARK_Freeze_Type`, `exp_spark.adb:1138–1254` | No invariant, DIC or tagged-type support for these types. |

The bound is `A_freeze <= E_Main`, with `E_Main` supplied by the entity
component. It deliberately includes object and scope entities that may never
need a freeze node. It does not include dependency entities; their allocations
belong to the fixed contribution. `Add_To_Result` uses `Append_New_To`
(`freeze.adb:2974–2977`). The independent list-constructor argument below
charges headers and recursive concatenation; the node count alone would not
justify their bound.

### Call and variable-reference markers are live in light mode

Elaboration recording is initialized active (`sem_elab.adb:10196–10208`),
including GNATprove. `Build_Call_Marker` allocates at most one node per ordinary
library call resolution (`:3563–3776`). Image remains an attribute; it does not
add a call. The admitted call resolution reaches the terminal marker site
(`sem_res.adb:7341`); earlier entry, indexed-call and Character-result ambiguity
routes are absent.

`Find_Direct_Name` and `Find_Expanded_Name` also create variable-reference
markers, including assignment targets (`sem_ch8.adb:7107–7130,7781–7805`).
Calls defer their simple-variable actual to `Resolve_Actuals`
(`sem_res.adb:4247–4276`). These alternatives do not duplicate the marker.
`Needs_Variable_Reference_Marker` requires a source reference to a source
SPARK variable and excludes preanalysis (`sem_util.adb:23907–24033`). Constants,
loop indexes and generated captures fail its entity-kind/source guards.
Each eligible name is analyzed once: both Analyze and Resolve return for
analyzed children (`sem.adb:113`; `sem_res.adb:2547`), lower-root replay is
Resolve rather than name analysis, and the two range copies are preanalyzed.
Hence `M_marker <= C_lib + N_ref` nodes and the same number of immediate
Insert_Action list wrappers.

Marker insertion does not add expression-with-actions wrappers here. Before
the enclosing short-circuit's first resolution finishes, its Analyzed flag is
false, so insertion stores/appends the marker in its existing Actions field
(`exp_util.adb:8143–8191`). No admitted replay contains a call or short-circuit
expression. Other insertions reach the enclosing declaration/statement or an
elsif condition action list (`:8290–8417`). Marker analysis is null
(`sem.adb:634–640`) and cannot recursively generate more markers. Later ABE
check generation and invocation-graph recording are disabled in GNATprove
(`sem_elab.adb:4084–4102,12226–12248`). Scenario maps/sets/stacks still need
their independent resource bounds.

### No additional ordinary syntax for Main's shell

Main's specification mutates its parsed defining entity; it has no parameters,
result, contracts, aspects or separate specification (`sem_ch6.adb:5440–5623`).
The GNATprove synthetic-spec route requires a body that is a list member;
library Main is a compilation unit (`:3738–3764`). Extra formals are disabled
as above; tagged, access-result, dispatching and inlined-body paths are absent.
The compilation-unit synthetic-spec route requires a child unit
(`sem_ch10.adb:989–1042`), which Main is not. The with clauses name only the
selected fixed library units. The use-implies-with constructor requires
`All_Extensions_Allowed`, absent the selected options
(`sem_ch8.adb:4362–4400`). SPARK_Mode(On) sets the current pragma/context; its
instance-only null rewrite is inapplicable (`sem_prag.adb:26242–26325,26507`).
Main has no exception handlers; handled-sequence and statement traversal reuse
the parsed nodes (`sem_ch11.adb:388–465`; `sem_ch5.adb:4523–4595`). The parser
already supplied the implicit loop identifier/declaration, so the semantic
missing-identifier fallback at `sem_ch5.adb:4110` is not another allocation.

## Node-identity aggregate and remaining resource obligations

The direct structural subtotal is

```text
A_struct = 4B_loop + 28F + 2R + 13D_lit + 4D_alias + 5G
           + 2D_copy + 3U + 4H_len + V0 + 2T_fold.
L_struct = R + 2D_lit + D_alias + G.
E_generated <= R + 2D_s + 3F + K_literal.
```

`E_generated` is the prior entity bound minus the parser's `1+D+2F` source
and implicit-loop entities. It includes index types and captured constants;
do not add the fresh-entity column again.

Adding the closed query, freeze, marker and shell cases gives the source-derived
node-identity bound

```text
M_marker <= C_lib + N_ref.
E_Main <= 1 + D + R + 2D_s + 5F + K_literal.
A_Main <= A_parse + F + E_generated + A_struct + E_Main + C_lib + N_ref.
```

`A_parse` includes the scanner identities later promoted to Main, object and
index entities. The separate `F` is the parser's fresh implicit-loop entities;
the semantic phase reuses them. `E_generated` adds only later generated entity
identities; `E_Main` in this expression charges their possible **ordinary
freeze nodes**, not a second entity allocation. The query/shell syntax residual
is zero under the stated grammar, type and phase premises. This is the
`A_Main` input for the producer's ignored-entry/list traversal transfer. It
does not establish bytes or any other frontend representation bound.

Using `G <= 2F`, `D_lit + D_alias <= D_s`, `D_copy <= D_s` and
`K_literal <= S + 3A + 5P` gives a fully syntactic, less precise form:

```text
A_Main <= A_parse + 4B_loop + 53F + 6R + 25D_s + D + 2S + 6A
          + 7U + 10H_len + V0 + 2O + 12P + 4O_loop + C_lib + N_ref + 1.
```

Here `A` counts String concatenations, whereas `O` counts all source operators;
the two terms intentionally overlap because they pay different allocations.
Every counter can be obtained from recognized source. No measured tree size,
runtime iteration count or selected safety margin enters this expression.

## Scalar-query aggregate

Keep `Optimization_Level=0` in addition to the phase premises above. This is
the selected producer analysis configuration; it matters because the saved
check optimizer in `Enable_Overflow_Check` and `Enable_Range_Check` is otherwise
another query source (`checks.adb:6430–6455,6595–6620`). Counts below are
**outermost helper invocations**: recursive calls inside Determine_Range or
Compile_Time_Compare are already paid by their helper transfers and are not
multiplied into the root count again. Warnings are allowed, so their query
paths are charged even when disabled by a selected warning setting.

Define these source-derived visit allowances:

```text
T_ar    = O + 2O_loop + 3F + R + 3D_lit.
T_check = D + G + N_assign + H_len.
Q_range = 6F + 3R + 3D_lit.
```

`T_ar` is the scalar arithmetic part of the earlier expression traversal:
source operators, the two raw range copies, lower-root replay, and the two
generated static String-range operators. Counting every source operator
overcounts non-arithmetic operations. `T_check` covers source and captured
object initializers, all assignments and a possible Length conversion. The
capture declaration's local suppression can only reduce this allowance.

| Reached source route | Range-query roots | Comparison-query roots |
| --- | ---: | ---: |
| Arithmetic/unary resolution | `2T_ar` | 0 |
| Relational evaluation, including generated String equality and its warning | 0 | `2(O+U)` |
| Range resolution, loop classification and range-check selection | 0 | `Q_range` |
| Scalar initializer/assignment/conversion check | `T_check` | `2T_check` |
| Constant declaration's optional subtype refinement | 0 | `2(D+G)` |
| Length evaluation and conversion's overflow subtype test | 0 | `3H_len` |

The source coverage for these rows is:

- `Resolve_Arithmetic_Op`/`Resolve_Unary_Op` invoke Enable_Overflow_Check once
  for a surviving operator (`sem_res.adb:6290–6448,12729–12934`). That helper
  queries the root and may additionally query the operand of unary minus
  (`checks.adb:6353–6414`). Division, abs, mod/rem restrictions and the
  unparenthesized unary-product warning do not occur in the admitted grammar.
- Eval_Relational_Op calls Compile_Time_Compare once through Fold_General_Op
  and at most once through Warn_On_Constant_Valid_Condition/Test_Comparison
  (`sem_eval.adb:3550,3622,7118`; `sem_warn.adb:3548–3647`). The native
  exp_ch4 warning/optimizer is not active. String comparisons either compare
  existing literal bytes or return Unknown before discrete range analysis
  (`sem_eval.adb:1321–1420`); charging the scalar-query envelope for them is
  conservative. Static_Length's direct arithmetic is separate below.
- Resolve_Range makes at most `3F+R+D_lit` comparisons. Its final condition
  evaluates the comparison **before** testing whether the parent is a subtype
  declaration (`sem_res.adb:11277–11289`). Loop classification adds `2F`
  (`sem_ch5.adb:3489–3490`). Process_Range_Expr_In_Decl adds at most
  `F+R+D_lit` through Get_Range_Checks/Not_Null_Range; the final subtype
  declaration compatibility checks add at most `R+D_lit`
  (`sem_ch3.adb:6363–6378,15474–15497,20478–20761,22588–22734,23676–23707`;
  `checks.adb:10994`). Their sum is Q_range. Source loops use N_Range, so
  the five extra subtype-indication comparisons at `sem_ch5.adb:3598–3621`
  are excluded. Static in-range declarations normally take the direct
  value-comparison route, but that optimization is not required by the bound.
- Apply_Scalar_Range_Check has at most one Determine_Range_To_Discrete and
  one In_Subrange_Of (`checks.adb:3155–3503`). The former delegates once to
  Determine_Range for these discrete expressions (`:6112–6127`); the latter
  makes at most two comparisons (`sem_eval.adb:5323–5428`). Is_In_Range and
  Is_Out_Of_Range use Test_In_Range, which does not recursively call these
  allocating query helpers on the admitted signed-Integer types
  (`:7354–7496`). Initializer and assignment callers are `sem_ch3.adb:4851`
  and `sem_ch5.adb:1031`. The separate known-valid constant refinement is
  the In_Subrange_Of call at `sem_ch3.adb:4826`.
- Eval_Attribute.Length makes one comparison (`sem_attr.adb:9949`). A
  surviving generated conversion has one overflow In_Subrange_Of and one
  Apply_Scalar_Range_Check (`checks.adb:3810–3920`); the latter is already
  in T_check. Resolve_Type_Conversion invokes that check once
  (`sem_res.adb:12337–12476`); integer-to-integer Eval_Type_Conversion reads
  its existing value, and its final range test uses Test_In_Range
  (`sem_eval.adb:4178–4343`). The attribute range-check caller at
  `sem_attr.adb:13613` is Val, not Length or Image.

All admitted library actuals are String `in` parameters. Resolve_Actuals takes
the array length-check branch, which returns before checking in light mode;
its scalar and out/in-out branches are inapplicable (`sem_res.adb:4861–4911`).
The other inspected direct query sites require a source indexing/slice,
aggregate, power, qualified expression, real/fixed/modular type, address clause,
Val/Range_Length attribute, discriminator or native expansion. The array-bound
inspection in `sem_util.adb:8488` calls Is_Null_Range only after proving both
bounds static, so it uses existing value comparisons rather than the query
fallback. Main's freeze cases have no address clauses or array packing.

Thus the root allowances are

```text
Q_R <= 2T_ar + T_check.
Q_C <= 2(O+U) + Q_range + 2T_check + 2(D+G) + 3H_len.
```

Using only syntactic upper counts gives

```text
Q_R <= 2O + 4O_loop + 8F + 2R + 6D_s + D + N_assign + H_len.
Q_C <= 2O + 2U + 14F + 3R + 3D_s + 4D + 2N_assign + 5H_len.
```

### Query graph and numeric magnitude from source

The [range/comparison helper transfer](retained-native-expansion.md#scalar-range-analysis-and-comparison-transfer)
requires a bound on each fully unfolded input tree, including the four
type-bound roots which a comparison may query. Here that input is source
derived; it is not an observed decorated-tree measurement. A sufficient bound
is

```text
A_q = 3(A_Main+1).
```

To establish it, consider the extra edges followed by the helper:

1. Ordinary scalar operands form syntax trees. The two raw loop copies and
   relocations are already included in A_Main. Parenthesis metadata creates no
   extra operand edge. Is_Same_Value recurses only through the existing
   operand/prefix trees; Original_Node is inspected without recursively walking
   an original tree (`sem_eval.adb:1078–1218`).
2. Determine_Range follows an internally named constant's initializer before
   consulting its cache (`checks.adb:5142–5163`). Main has only the captured
   loop-bound constants in this class. A captured initializer is one source
   scalar expression; source cannot name any captured constant. A source
   reference to an outer loop index is an ordinary name, not a capture
   initializer edge. Thus expansion of a capture root adds its already charged
   initializer tree once; it cannot recursively unfold a chain of generated
   captures or duplicate that initializer inside one expression tree.
3. A Length query may revisit both index bounds (`checks.adb:5390–5440`).
   Main's String types are static ordinary subtypes, literal subtypes or
   Standard.String. Each index bound is already compile-time known and returns
   before recursive range refinement. Charge two additional leaf visits for
   every Length occurrence, including repeated visits to shared bound nodes.
   Loop-bound syntax contains no Length, and captured bounds cannot introduce
   one. This is at most two extra visits per Main syntax identity.
4. Ordinary scalar names do not recursively range-analyze dynamic type bounds.
   Determine_Range reads a known bound or the known Standard base bound
   (`checks.adb:5215–5298`). A comparison can separately choose a type bound as
   a new root, but the helper's at-most-four recursive comparisons already
   account for those roots. A root from Standard is a known leaf. Source
   constants are backward references; Expr_Value follows their finite
   constant/literal chain without allocating numeric values
   (`sem_eval.adb:4589–4684`).

For any one rooted range tree, its ordinary/captured syntax therefore uses at
most A_Main distinct identities, with at most two additional known leaves per
Length. Standard roots add only a leaf. The deliberately looser `3(A_Main+1)`
covers all those cases. There is no cache-hit premise and no multiplication by
runtime loop iteration count. String comparisons do not enter the scalar
graph. Type-bound/current-condition values are included in the scalar leaf
magnitude below, even when they were not source literals.

Let `b=max(32, Standard_Long_Long_Long_Integer_Size)` for the fixed target and
`H=2^b`. Universal_Integer is built from that longest signed target type
(`cstand.adb:1396–1407`). With the separate String representation conditions
`length <= Int'Last` and the admitted 32-bit scalar rules, H covers every
existing literal, static index bound, current-condition value and Standard
scalar bound reachable by these queries. This includes universal-Integer
Length contexts; using only 32-bit type bounds would be unjustified.

Range refinement can still calculate values outside the runtime base range:
it returns a disjoint computed interval without clipping it back
(`checks.adb:5582–5605`). For an unfolded tree of n nodes, the helper's
add/subtract, multiply, unary/conversion and Length magnitude recurrences are
all bounded by `(2H+1)^n`. Each recursive edge decreases that tree size;
the Length step `2*max(B1,B2)+1` and binary products satisfy the same bound.
The comparison's offset/difference/unit-adjustment arithmetic is bounded by
`2*(2H+1)^A_q+1`. Consequently this digit count is sufficient without
constructing that large integer:

```text
k = ceil(((b+2)*A_q+2)/15).
```

The denominator is Uint's radix-32768 digit width. Since
`2H+1 < 2^(b+2)`, the displayed exponent bounds the bit length of all query
results and intermediates. It is intentionally conservative; a source-local
range recurrence can be tighter without changing the caller coverage.

### Closed query contribution and discrete subtype size calls

Combine the root counts with the independently derived helper transfer:

```text
U_query <= 6A_q Q_R + (80A_q+60) Q_C.
digit_words_query <= k U_query.
maximum local arithmetic-vector words <= 5k+3.
UI_Ints insertion events <= U_query.
```

The 80A_q term retains the generic helper's comparison-fixup allowance even
though Main's shape proves those syntax/numeric fixups absent. It is harmless
overcounting, and the separate **syntax contribution remains zero**. Local
vector words are not whole-process stack bytes: recursive expression/value
walks and surrounding compiler frames remain separate resource obligations.

One further non-query family now has a source multiplicity. The only new
signed scalar types are the `R` Integer object subtypes, `D_lit` static String
index subtypes and `F` loop-index subtypes. Constrain_Integer/Constrain_Index
each call Set_Discrete_RM_Size once (`sem_ch3.adb:15474–15497`); Make_Index
copies its base layout (`:20729–20734`). Layout_Type can call the size helper
once more on first freeze if RM_Size is not known (`layout.adb:370–378`).
The earlier once-per-entity freeze argument therefore gives

```text
T_size <= 2R + 2D_lit + F.
U_discrete_size <= 95T_size.
digit_words_discrete_size <= 285T_size.
```

The [32-bit discrete-size helper transfer](retained-native-expansion.md#constrained-subtype-declaration-with-resolved-pure-bounds)
uses at most 95 Uint appends/285 digit words per call, including cold power
memo entries, and at most eight local digit words. All these subtypes have
Integer bounds or use its base fallback, so its magnitude premise holds.
String alias subtypes reuse their existing index; literal String subtype
entities are not additional scalar index types. This closes this helper's
contribution, not every layout operation.

There is also a closed direct-evaluator subtotal. Each arithmetic visit adds
at most two Uint entries: subtraction may negate and add, while addition,
multiplication and unary minus need at most one result entry. Multiplication's
`UI_From_Int(Num_Bits(left)+Num_Bits(right))` guard is included: both operands
are already folded, admitted 32-bit values, so this value is at most 64 and
uses Uint's direct representation (`sem_eval.adb:1971–2110,4351–4451`).
The two static String-range arithmetic operators also have 32-bit bounds
under the separate String representation conditions. Unknown expressions do
not compute a scalar folding result. Integer-to-integer conversion folding,
Boolean folds and Check_Non_Static_Context_For_Overflow only read existing
values on the successful legality path (`:660–682,4178–4343`).

One Eval_Relational_Op makes at most two Static_Length calls, each adding at
most three Uint entries under Main's static/unconstrained String types
(`sem_eval.adb:3654–3718,3753–3754`). One Length evaluation adds at most four
direct arithmetic entries in addition to its comparison
(`sem_attr.adb:9936–9966`). Thus

```text
U_eval <= 2T_ar + 6(O+U) + 4H_len.
digit_words_eval <= 3U_eval.
```

### Literal/subtype bookkeeping and ordinary freeze layout

Let `L_res <= S+A+3P` be the literal-resolution allowance established by the
[entity derivation](retained-frontend-entities.md#literal-allocation-and-re-entry).
Each Set_String_Literal_Subtype converts its Nat length once with UI_From_Int;
its lower bound is the already static Standard.String value 1, so its dynamic
lower-bound branch is absent (`sem_res.adb:13205–13337`). There are at most
`K_literal <= S+3A+5P` such calls, including direct concat-operand setters.

Resolve_String_Literal invokes Eval_String_Literal at most once per resolution
(`sem_res.adb:12039–12322`). Eval_String_Literal calls String_Type_Len on its
**base** type, Standard.String, which computes `High-Low+1`: at most three
Uint appends. Its subsequent `Len > String_Type_Len(Bas)` is a mixed Int/Uint
comparison; UI_Gt converts Len with UI_From_Int and may allocate one more entry
(`sem_eval.adb:4052–4167,6571–6584`; `uintp.adb:1683–1696`). Treating every
numeric comparison as allocation-free would miss this cost. Character checks
either return for Standard.Character's complete range or convert printable
ASCII codes, which fit Uint's direct representation. Late initializer copies
retain the analyzed literal and subtype and do not re-enter these helpers.
Consequently

```text
U_literal <= K_literal + 4L_res <= 5S+7A+17P.
digit_words_literal <= 3U_literal.
```

The magnitude allowance is three base-32768 digits: literal lengths and the
Standard.String index computation fit the signed-Int/Integer domain under the
separate String representation conditions. Check_String_Literal_Length's
other call site requires a qualified expression, excluded here
(`sem_eval.adb:688–700,3374`).

On first freeze, Check_Compile_Time_Size performs at most one multiplication
for a literal subtype and at most `high-low+1` plus one multiplication for a
one-dimensional static ordinary String subtype. Its elementary-type and
unconstrained-array branches return without numeric allocation; recursive
component visits reach Standard.Character. Its alternate pre-freeze caller
requires generic scope (`freeze.adb:750–912,7064,8143`). Thus

```text
U_freeze_size <= 4(D_lit+D_alias)+K_literal <= 4D_s+K_literal.
digit_words_freeze_size <= 3U_freeze_size.
```

The bit-size product is at most `8*Integer'Last`, still below 2^35 and hence
within three digits. The mixed comparison with System_Max_Integer_Size converts
only that small fixed target size, not the potentially large product.

The rest of the ordinary Main layout paths add no table-backed Uint values
on the selected byte-storage targets (`System_Storage_Unit=8`):

- Scalar subtypes inherit Integer's 32-bit Esize; their RM_Size is at most 32.
  Layout_Type's size/alignment values, divisions and conversions are therefore
  small direct Uints. The separate Set_Discrete_RM_Size cost remains charged
  above (`layout.adb:358–445,601–664,939–1050`).
- Standard.String starts with unknown Esize, component size 8 and alignment 1
  (`cstand.adb:916–937`). Constrain_Array and Copy_Array_Subtype_Attributes copy
  that Esize; Set_Size_Info copies Esize and alignment, not a newly computed
  size (`sem_ch3.adb:14440–14484,15790–15807`; `sem_util.adb:29103–29119`).
  Check_Compile_Time_Size may set RM_Size, never Esize. No packing, full-access
  or representation clause enters Main, so ordinary String subtype layout
  leaves Esize unknown. Adjust_Esize_Alignment consequently returns before its
  allocating mod/division arithmetic (`layout.adb:72–82,445–664`;
  `freeze.adb:4090–4103`). Literal-subtype Layout_Type clears size and returns.
- Layout_Object is null. Check_Unsigned_Type reads existing static bounds or
  their ancestor/base bounds and compares with the small direct value zero;
  Freeze_Static_Object traverses existing bounds/types and sets flags
  (`layout.adb:225–231`; `freeze.adb:2418–2491,10223–10390`).

Scope_Depth is also a Uint, but nested E_Loop scopes copy the enclosing depth;
they do not add one. Main's ordinary library-procedure depth is 1, and all
admitted nested loops inherit it (`sem_ch8.adb:9890–9930`). This removes a
potential numeric contribution, **not the scope-stack entry demand**.

The five disjoint numeric families can be added:

```text
U_closed = U_query + U_discrete_size + U_eval + U_literal + U_freeze_size.
digit_words_closed <= k U_query
  + 285T_size + 3(U_eval+U_literal+U_freeze_size).
```

Their ordinary Uint primitive result costs include discarded temporaries; no
release/cache credit is required. Scanner integer-token Uints are a separate
existing component. Other semantic bookkeeping and diagnostic/value-cache
routes still require a complete numeric caller inventory, so this is explicitly
**not the complete Main Uint bound**.

## Semantic syntax-list headers

Freeze_Entity initializes Result to No_List. On Main's ordinary entities, the
only reached Add_To_Result call appends its own freeze node; the other sites
require record/access components, a class-wide type, or an imported subprogram
wrapper (`freeze.adb:2893,2974–2977,5202,6496,7389,8285`). The first successful
freeze marks the entity frozen before recursively freezing dependencies. Each
Main entity can therefore cause at most one lazy result-header allocation.
Already-frozen calls return No_List, except a subtype's forwarding to its still
unfrozen base, whose allocation is charged to that base's first visit.

Freeze_And_Append adopts a nonempty child's header when its result is empty,
otherwise Append_List relinks existing nodes and empties the child's header;
neither operation creates another header (`freeze.adb:2803–2825`;
`nlists.adb:189–275`). Freeze_Before/Freeze_All insert those lists directly,
without creating singleton wrappers. Insert_Actions likewise adopts or splices
the supplied list on the reached declaration, statement, short-circuit and
elsif routes (`exp_util.adb:8000–8450`). Its singleton Insert_Action entry does
allocate one list, already counted for structural actions and each marker.
The generic-entity empty-list constructor and generic wrappers are excluded.

Hence the additional Main semantic syntax-list header count is

```text
L_sem <= L_struct + E_Main + C_lib + N_ref
      <= R+2D_lit+D_alias+G + E_Main + C_lib+N_ref
      <= 1+D+2R+4D_s+7F+K_literal+C_lib+N_ref.
```

This counts abandoned headers after splicing as well as live headers. Add the
parser's syntax-list allocation count separately. Nlists' Next_Node/Prev_Node
arrays have one entry per allocated node identity, already connected through
A_Main; they are not one extra allocation per append or splice
(`nlists.adb:125–132`). Element lists, scope stacks and elaboration maps are
different resources and do not follow from L_sem. Main-triggered first freezing
of fixed external entities belongs to the separate dependency contribution.

## Remaining resource obligations

Remaining whole-frontend obligations are:

1. **Other semantic numeric helpers and mutations.** Close the remaining
   numeric caller inventory beyond the five named families, including any
   diagnostic/value-cache routes. The query envelope does not make them free.
   Keep overload tables, value caches and per-kind growing mutations distinct
   from node identities. One identity bound is not a slot-event bound.
2. **Freeze/marker auxiliary storage.** Charge scope-stack
   operations, elaboration maps/sets and traversal stacks. Their ordinary syntax
   nodes are covered above; it would be incorrect to infer their complete
   storage cost from that node-identity count.
3. **Complete table/resource connection.** Add all remaining ordinary/entity
   slot mutations, name spelling/qualification, auxiliary table events,
   Uint layout/query work and peak/growth arithmetic to the existing table and
   value components. Fixed dependency work remains outside Main. The producer
   can use this A_Main for the stated frontend-node input, while the separate
   frontend capacities still need every listed resource bound.

The connection includes discarded work, explicit replay and markers. The late
String-copy path requires the producer's separate copied-literal correction.
These results do not establish the complete capacity rule,
source-to-installed-producer identity or permission to
remove any current language limit.

## Reproduction

Run the adjacent [source/equation check](../evidence/retained-main-semantics-20261018/derive.py)
with `--source` pointing to the pinned `gcc/ada` directory. Its
[result](../evidence/retained-main-semantics-20261018/result.json) records source
hashes, cited ranges and the aggregate equation expansion. It checks source
identity and arithmetic, not reachability, soundness or installed-tool behavior.
