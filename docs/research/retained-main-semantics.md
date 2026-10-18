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
The auxiliary sections also bound overload storage, deferred-warning tables,
frontend diagnostic attempts and cross-reference keys, and identify element-list
costs at the compilation-unit boundary. Warning suppression differs between
producer phases and does not eliminate diagnostic-history allocation.
Native expansion is a separate process contribution; no production, proof,
language, Oracle or tool-pin file changes here.

The source is GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Its relation to
the embedded frontend in the inspected/installed SPARK producer remains the
explicit premise in the [capacity contract](retained-tool-capacity.md).
The evidence checks the relevant files against the retained complete GCC
manifest, hashes the three archived SPARK mode-selection files and records the
current Silver command/interface inputs. No compiler, prover or Lean run was
performed.

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
| `N_word` | All source identifier/keyword tokens, including context clauses and closing names; used as a conservative name-analysis allowance |
| `N_with` | Package-name occurrences in source `with` clauses; comma-separated names and repetitions each count |

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

## Dynamic node slots, including growing mutations

The [generated slot-layout result](retained-table-capacity.md#exact-slot-sizes-from-the-pinned-generator)
gives at most nine dynamic slots per ordinary allocation and 61 per entity.
The parser transfer already charges defining-name promotion, fresh loop-scope
entities, procedure-call conversion and parser-flattening Rewrite growth.
Semantic entity creation uses defining-entity constructors. Later Mutate_Ekind
does not allocate more slots because every entity already reserves the maximum
entity size (`atree.adb:1131–1151`). Thus there is no additional semantic entity
promotion allowance.

Ordinary growing mutations need their own event count. Let

```text
G_sem = T_fold + D_lit+D_alias+D_copy+G + U+H_len+V0
        + 2C_lib + S+2P.
```

The first terms charge each previously counted Rewrite: an ordinary fold;
the static String subtype-indication/alias replacement; late initializer
literal propagation; captured scalar replacement; String inequality; and
Length conversion. Each calls Copy_Node once, which can allocate a full
new ordinary slot segment even when the identity already exists
(`atree.adb:1301–1333,2222–2276`). Its saved-original copy was already charged
as a node allocation and must not substitute for this growing event.

The remaining in-place kind conversions are:

| Route | Event allowance | Source |
| --- | ---: | --- |
| Parameterless validity name to call | `V0` | `sem_res.adb:1462–1478` |
| Positional function's indexed-component form to call | `C_lib` | `sem_ch4.adb:2720–2780` |
| Qualified library name to expanded name | `C_lib` | `sem_ch8.adb:7656–7668`; `sinfo-cn.adb:151–155` |
| Operator-looking literal to ordinary String literal | `S+2P` | `sem_res.adb:1483–1491`; `sinfo-cn.adb:140–145` |

Each conversion changes the kind away from its input case and is not repeated
by ordinary analyzed-node replay. Qualified names occur only in admitted
library calls; Main/context package names are simple names. The literal count
includes both parser-generated literals, although those ordinarily already
have String_Literal kind. String constant propagation produces an analyzed
literal and does not re-enter this conversion. Calls to an enumeration literal
would also use Copy_Node at `sem_res.adb:7127`, but no such call is admitted.
Source type conversions, private/incomplete views and class-wide entity copies
are excluded. Range-check construction makes fresh unanalysed syntax and has
no additional in-place mutation; its discarded check tree is never expanded.
The previous query, freeze and shell argument excludes other reached syntax
rewrites under these phase/type premises.

Define `A_sem_o = A_struct + E_Main + C_lib + N_ref`, the semantic ordinary
allocation allowance. Combining parser and semantic allocation events gives

```text
slots_Main <= 9*(A_parse+C_proc+P+A_sem_o+G_sem)
              + 61*(D+2F+1+E_generated).
```

Every term counts slots ever appended, including abandoned old slot segments.
It assumes no reclamation or in-place-at-end optimization. Since
`D+2F+1+E_generated <= E_Main`, `C_proc <= C_lib`, and A_Main also includes
the fresh entities, a simpler conservative source form is

```text
G_sem <= O+3P+2O_loop+5F+R+5D_s+3U+4H_len+V0+2C_lib+S.
slots_Main <= 9*(A_Main+C_lib+P+G_sem) + 61E_Main.
```

This deliberately pays an ordinary allocation allowance for some entities as
well as their full entity allowance. The expression supplies **dynamic slot
demand**, not backing-array capacity or total bytes. Node headers, original-node
and list-link tables, parenthesis entries, table-growth rounding and sentinel
indices retain their separate bounds. The parenthesis map receives at most
A_Main distinct Main keys; repeated Rewrite/Change_Node assignments do not
create new keys for the same identity.

## Main semantic scope-stack contribution

Let `d_loop` be the largest number of simultaneously enclosing source loops;
`d_loop <= F` is a simpler alternative. If `s` entries are live immediately
before Main's procedure scope is pushed, ordinary Main analysis needs at most

```text
semantic_scope_peak <= s + 2 + d_loop.
```

Main has no formals/result, so analyzing its specification does not push a
scope. Its body pushes Main once and each loop pushes once around its iteration
scheme and body (`sem_ch6.adb:4217–4219,5477–5481,5555–5567`;
`sem_ch5.adb:4169–4171,4315–4317`). Conditions and branches do not introduce
semantic scopes. The raw bound preanalyses change analysis mode but push no
scope (`sem_ch5.adb:4868–4886`). There are no nested packages, user subprograms,
records, access-type designated scopes or transient native-expansion scopes.

The extra one pays a temporary scope push while analyzing a Main freeze node.
Expand_SPARK_N_Freeze_Entity may install an outer/currently closed scope and
pops it on return (`exp_spark.adb:601–766`). For the admitted ordinary types,
SPARK_Freeze_Type creates no actions and the freeze node's Actions list is
empty, so these local freeze pushes do not nest. Frozen fixed dependencies and
their actions must be accounted in the dependency phase contribution, including
any ambient Main depth if that work is deferred into Main.

Push_Scope initializes list fields to No_List/No_Elist, increments the table
top and copies saved policy values. Pop_Scope decreases the top
(`sem_ch8.adb:9863–9874,9932–9962`). With the selected no-style-check premise,
the Last_Subprogram_Name heap allocation is absent (`sem_ch6.adb:7503–7540`).
Use the generic backing-table envelope at low bound zero, initial length 10
and 200-percent growth, with the target layout of Scope_Stack_Entry supplied
separately (`sem.ads:499–596`; `alloc.ads:118–119`). This is a table bound, not
the compiler's recursive call-stack bound or every operation performed on scope
exit.

## Elaboration recording and processing auxiliaries

This contribution assumes the selected modern elaboration mechanism
(`Legacy_Elaboration_Checks=False`), in addition to GNATprove light mode. It
counts Main's additions, not the constant initialization of the package's
containers or a separate dependency compilation.

Each Main call marker immediately runs Record_Elaboration_Scenario, including
calls in the statement body. Process_Guaranteed_ABE pushes the marker, obtains
its Scenario_Reps record, obtains the target's Target_Reps record, performs
the direct check and pops; this ordinary-call path does not traverse the target
body (`sem_elab.adb:9307–9360,9499–9616`). The constructors fill records with
existing nodes/entities; their optional task list stays Nil. The NTS/ETT maps
cache by marker/entity, so repeated reads or target-record refreshes do not
append again (`:10607–10639,10874–10949,11295–11324,11427–11465`). Therefore:

| Resource | Main additions / peak |
| --- | ---: |
| Scenario_Reps entries and Node_To_Scenario_Map bindings | at most `C_lib` each |
| Target_Reps entries and Entity_To_Target_Map bindings | at most five each: the five admitted library operations |
| Active_Scenario_Stack extra live entries | at most one |
| Declaration_Scenarios set members/inserts | at most `C_lib`; in the current grammar only the input initializer can contribute |
| Dynamic_ABE_Check, Library_Body, Library_Spec and SPARK scenario-set additions | zero |

Find_Enclosing_Level returns Declaration_Level for Main's declarative part,
No_Level for its statement part, and never either library-package level
(`:8943–9112`). Variable markers and assignments are only inserted into the
library-body/spec sets, so Main adds none through those routes. Calls can enter
Declaration_Scenarios; Add_Dynamic_ABE_Check_Scenario returns through
Check_Or_Failure_Generation_OK in GNATprove mode (`:13901–14126,14208–14225`;
`:4084–4102`). There are no source instantiations, derived types or refined-state
pragmas to enter SPARK_Scenarios. Markers are not rewritten by Main's light
transforms; updating some other rewritten source node therefore cannot create
new set members via Replace_Scenario (`:14320–14358`).

The end-of-unit processing does not expand this Main contribution.
Check_Elaboration_Scenarios iterates the declaration set, while all the other
Main sets are empty (`:3913–3982`). For a declaration-level call, the target
is in an external Silver library unit. Is_Up_Level_Target returns True, causing
Process_Conditional_ABE_Call to return before diagnostics, requirement
generation or traversal of its body (`:5350–5460,14969–15005`). The same guard
also applies to that call's earlier guaranteed-ABE check. The conditional
processor only rereads the cached record/target and uses one stack entry.
Reset_Traversed_Bodies resets an empty set; no body is traversed, so there are
no nested-scenario map/list additions or early-call-region map additions.
Invocation-graph recording returns in GNATprove mode (`:12226–12248`), leaving
its saved-construct and saved-relation sets empty. Collect_Elaborated_Units
examines only elaboration pragmas in Main's context; ordinary with/use clauses
do not add entries, and no such pragmas are admitted (`:7811–8061`). Thus Main
also adds zero Unit_To_Attributes_Map/Elaboration_Attributes entries here.

Do not discard initialization cost merely because an entry count is zero.
The source creates these container headers and their initial bucket arrays:

| Container | Create argument |
| --- | ---: |
| Nested_Scenarios_Map, Traversed_Bodies_Set | 250 each |
| Early_Call_Regions_Map | 100 |
| Unit_To_Attributes_Map | 250 |
| Entity_To_Target_Map, Node_To_Scenario_Map | 500 each |
| Saved_Constructs_Set, Saved_Relations_Set | 100, 200 |
| Declaration, Dynamic_ABE_Check, Library_Body, Library_Spec, SPARK sets | 1000, 500, 1000, 1000, 100 |

The initialization sites are `:3035–3039,7651–7654,8586–8589,11216–11220,`
`:12217–12221,14185–14192`. These are requested sizes, **not rounded backing
bucket counts**. Apply the pinned hash/set implementation's constructor and
growth rules, together with actual target component layouts. Scenario_Reps
and Target_Reps have initial length 1000 and 200-percent growth; active-scenario
stack has initial length 50 and 200-percent growth (`:1032–1038,10374–10390`).
Their IDs/counters, array rounding and one-past arithmetic still need the
general representation checks. This closes these elaboration caller counts;
it does not claim that all semantic auxiliary containers have been covered.

## Overload records and their index map

`All_Interp` is lifetime storage: resolving an expression does not reclaim its
records. `New_Interps` appends a sentinel and installs a node-to-index binding;
adding an interpretation fills that sentinel and appends another. `Interp_Map`
is a Simple_HTable with 3079 fixed headers, while All_Interp starts at 1000
entries with 100-percent growth (`sem_type.adb:77–109,197–310,3134–3142`;
`alloc.ads:40–41`). An interpretation has four entity-valued fields
(`sem_type.ads:65–77`). These are separate resources from AST identities.

The current Main grammar has a small overload domain:

- Standard creates one entity per unary/binary operator, except concatenation,
  which has three entities for String, Wide_String and Wide_Wide_String
  (`cstand.adb:306–415`). Main creates no overloadable declaration except its
  parameterless procedure. Its objects and loop indexes hide names rather
  than extending overload sets. The two admitted package interfaces contain
  exactly one declaration of each admitted operation and no explicit operator
  declarations; qualification does not add overload candidates.
- Scalar operands have Integer or universal-integer type. The arithmetic and
  unary analyzers therefore find one interpretation, stored directly on the
  node, without starting an All_Interp list
  (`sem_ch4.adb:930–984,6546–6588,6770–6881,7724–7754`). The generated String
  range arithmetic has the same property. Boolean operations and comparisons
  likewise have one result interpretation; a String comparison may resolve
  an overloaded concatenation operand but does not copy its alternatives into
  a Boolean overload set (`:2073–2115,6268–6300,7505–7571`).
- Before contextual resolution, a String concatenation with literal operands
  can match all three standard String families. Each concat analyzer visits
  each operator entity once and adds at most one interpretation for it
  (`:1917–2064,7580–7612`). Thus one concatenation contributes at most three
  records and one sentinel. The nonrecursive left-spine traversal still
  visits each source concatenation once. Scalar range copies contain no
  String concatenations. The later inequality rewrite reuses resolved
  operands; folding and late constant-name copies create literals, not new
  concatenation analyses.
- A direct operation name can still call Collect_Interps because another,
  invisible declaration occurs on its homonym chain. Do not infer zero
  allocation from the unique legal callee: Collect_Interps first allocates a
  list, then discovers its singleton result (`sem_ch8.adb:6643–6652`;
  `sem_type.adb:613–745`). This costs at most one interpretation plus its
  sentinel per name analysis. The expanded-name path only collects same-scope
  homonyms (`sem_ch8.adb:7705–7748`), absent from these five interfaces.
  Scalar source names, including all three loop-bound passes, denote objects
  or types and are not overloadable.

String literals spelling an operator do not invalidate that domain:
Analyze_Operator_Symbol converts them to ordinary String literals in the
admitted expression positions (`sem_ch6.adb:1555–1591`). No explicit quoted
operator call or operator-valued generic/renaming context is admitted.
Successful resolution clears Is_Overloaded (`sem_res.adb:3572–3576`); the
explicit lower-bound replay calls Resolve, not a fresh bottom-up overload
collection. It therefore does not allocate a second scalar interpretation list.

Copying overload metadata is not free. Save_Interps calls New_Interps and then
replaces its map value with the old index, leaving an abandoned sentinel
(`sem_type.adb:3324–3346`). Among Main's live source shapes, its only possibly
relevant explicit caller is the parameterless-function rewrite
(`sem_res.adb:1462–1480`). Charge one such sentinel and one additional map key
per source name even though the uniquely resolved validity function normally
has no overload flag. Other Save_Interps callers require operator-as-call
syntax, explicit/implicit dereferences, object-operation notation, renamings,
generic actuals or native expansion. Ordinary Atree shallow copies do not
themselves call Save_Interps.

A conservative source-token transfer is consequently:

```text
All_Interp Main entries <= 4A + 3N_word.
Interp_Map Main bindings <= A + 2N_word.
```

These include discarded singleton/sentinel work. Keep the Standard and fixed
dependency interpretations, their map bindings, initial tables and actual
hash-entry layouts as separate process terms. This is a storage count, not a
bound on the number of unsuccessful homonym lookups.

## Warning and cross-reference mode distinction

The inspected SPARK driver has three distinct modes here. Its source snapshot
is `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`; correspondence to the installed
producer remains the existing explicit premise.

| Frontend process | Warning collection | Cross-reference collection |
| --- | --- | --- |
| Native data representation | `-gnatws` suppresses warnings | `-gnatx` disables xrefs |
| gnat2why global-generation/ALI pass | Back_End sets Warning_Mode=Suppress | Remains active |
| gnat2why flow/proof translation | Current `--warnings=continue` maps to Normal; null uses Treat_As_Error | Remains active, although ALI output is disabled |

The native switches are added only in the `not Call_Gnat2Why` arm
(`spark/src/gnatprove/gnatprove.adb:297–310`). The two gnat2why modes are set
in `spark/src/why/back_end.adb:156–187`, and `--warnings` is interpreted by
`spark/src/gnatprove/configuration.adb:2802–2818`. The current Silver command is
`src/silver.adb:116–125`. Xref_Active defaults True (`opt.ads:1725`), and
Disable_ALI_File makes Write_ALI return before Output_References
(`lib-writ.adb:1059–1065,1618–1619`). It does **not** disable the earlier
Generate_Definition/Generate_Reference collection. These are existing mode
differences, not a proposal to suppress any diagnostic or proof obligation.

### Deferred-warning tables

Check_References returns immediately in Suppress mode. Otherwise it walks
the scope's entity chain once and recurses only into packages/blocks, not loop
scopes (`sem_warn.adb:1241–1271,1840–1860`). Main's body invokes it once
(`sem_ch6.adb:4930–4983`). Main has no nested subprogram, block/package,
separate spec, formal or generic declaration. Only source entities pass its
Source_E1 gate, and every append to Unreferenced_Entities is in this one walk
(`sem_warn.adb:1179–1201,1807–1835`). Therefore:

```text
Unreferenced_Entities Main appends <= D.
In_Out_Warnings Main appends = 0.
```

The second table requires an in-out formal (`:1450–1492`), which Main has
none. Their initial capacities are 1000 and 100, both growing by 100 percent,
with Entity_Id elements (`:63–88`; `alloc.ads:61–62,148–149`). Suppress mode gives zero Main additions to
these tables, not permission to omit their package initialization. This closes
these two deferred tables only: diagnostic text, fix edits and other warning
routes still need the separate diagnostic argument.

### Frontend diagnostic attempts and stored text

The driver does more than select Warning_Mode. In GNATprove mode it calls
Reset_Style_Check_Options, then Restore_Warnings with only Elab_Warnings and
Warn_On_Suspicious_Contract enabled; it preserves the documentation-display
switch and sets every other warning flag False (`gnat1drv.adb:517–529`).
Pragma Warnings with a string of compiler warning switches explicitly does
nothing in GNATprove mode (`sem_prag.adb:28781–28801`). Thus a dependency's
such pragma does not undo this mask. Main has no warning/style pragma. Warning
flags and Warning_Mode are different state: the unconditional warnings below
remain reachable even with this mask.

Count attempts to call Error_Msg, not just messages eventually shown. The
non-instance path appends `(new String'(Msg), Flag_Location)` to
Non_Instance_Msgs **before** it asks Warnings_Suppressed or checks an enclosing
null loop (`errout.adb:550–697`). Warnings_Suppressed consults Warning_Mode
only after the warning-location table (`erroutc.adb:2134–2156`). Consequently
the ALI pass's Suppress mode does not make this history free. Maximum_Messages
can suppress later display; it does not bound these earlier appends.

Under the established Main syntax/type closure and successful legality,
the remaining frontend warning attempts are:

| Caller family | Main attempt bound / exclusion |
| --- | --- |
| Analyze_Loop_Parameter_Specification, null or possibly reversed range | At most two per source loop, in mutually exclusive branches (`sem_ch5.adb:3480–3571`) |
| Context-license check | At most one per source with-name, hence `N_with` (`sem_ch10.adb:3980–4117`) |
| Known-condition, redundant assignment/if/comparison/use/with, hiding, unreferenced, could-be-constant and suspicious-parenthesis warnings | Caller warning flags are False; the caller returns or skips the branch before constructing a message or fix (`sem_warn.adb:1333–1376,1570–1590,3596–3647,3789–3815`; `sem_ch5.adb:1066–1096,2113–2152`; `sem_ch8.adb:10490–10513`; `sem_res.adb:9190–9227,10980–11001`) |
| Uninitialized-reference warnings outside that mask | Main has no access objects or formals, and every source object has an initializer (`sem_warn.adb:1272–1331,1383–1410,1570–1670`) |
| Infinite/unreachable loops or unconditional transfers | For-loop warning helper returns on Loop_Parameter_Specification; Main has no while/plain loop, exit, goto, return, raise or No_Return callee (`sem_warn.adb:620–661`; `sem_ch5.adb:2083–2092,4318–4335,4604–4820`) |
| Null subtype range | Source Integer object ranges are nonempty; generated empty String ranges are not Comes_From_Source (`sem_res.adb:11275–11289`) |
| Loop subtype, multidimensional Range, unary-product diagnostics | Main uses explicit N_Range loops, no Range attribute, and parenthesizes compound unary operands (`sem_ch5.adb:3582–3645,4172–4228`; `sem_res.adb:12800–12934`) |
| Constraint/range/divisor/predicate warnings | The earlier no-static-Constraint_Error argument covers Integer/String check callers; no division, user predicates, access, modular/fixed/real or user-defined type is admitted. Successful legality is not being used to discard permissible warnings. |
| Elaboration and suspicious-contract warnings | The elaboration section's up-level target guard returns before diagnostics; Main has no contract, quantified expression, Update attribute or post-state expression (`sem_util.adb:4657–4680`; `sem_warn.adb:4436–4464`) |
| Referenced Unused/Unreferenced entities, representation/foreign/dispatching and other type-specific warnings | No such Main aspect/pragma/type is admitted; the five library operations and two packages have no Unused/Unreferenced annotation (`lib-xref.adb:849–938`; retained Silver interface inputs) |
| Scanner/parser warnings | ASCII excludes bidirectional wide characters; ordinary delimiters exclude obsolete literal spellings; Ada 2022 excludes future-keyword warnings; style flags are reset; the snapshot is `main.adb` and the unit is Main. Valid grammar excludes recovery/no-unit diagnostics (`scng.adb:333–356`; `scn.adb:111–198`; `par-load.adb:169–202`; `src/silver.adb:93–110`) |

Main's context is installed once at Analyze_Compilation_Unit
(`sem_ch10.adb:1108–1116`). The other Install_Context callers reinstall
subunits, child/parent contexts or generic instances; Main has none, and its
body acts as its own spec (`:2615–2635,2794–2806,4148–4157`). The context-license
allowance deliberately does not depend on the current Silver packages'
Unknown license classification. Comments may affect a source's classification;
counting the attempt is simpler than adding a license premise.

Define `J_diag = 2F + N_with` and
`M_diag = 1024 + 2*Int(Column_Number'Last)`, the pinned Max_Msg_Length.
The admitted messages have raw templates of at most 64 characters, no
diagnostic code, no extra spans, no label and no fixes. Each message chain has
at most two parts. Main introduces no generic/inlining location, so Error_Msg
calls Error_Msg_Internal once without instantiation-message expansion.
Set_Msg_Char caps Msglen at M_diag (`erroutc.adb:1359–1367`), and its static
Msg_Buffer has that size (`erroutc.ads:125–135`). The resulting transfer is:

```text
Non_Instance_Msgs Main appends <= J_diag.
Errors Main appends <= J_diag.
Locations Main appends <= J_diag.
Edits / Fixes / nonempty-label allocations from Main = 0.
Main raw-history string characters <= 64 J_diag.
Main formatted-text lifetime string characters <= (2 M_diag + 2) J_diag.
Main diagnostic string allocation requests <= 2 J_diag.
One continuation-join local vector <= 2 M_diag + 2 characters.
```

The formatted-text expression covers both separate messages and a continuation
joined to the preceding text: the old heap text is freed, a local vector of
`old_length+2+Msglen` is used, and one new heap string is allocated
(`errout.adb:1377–1453`). Counting lifetime requested characters is a safe
upper bound for the retained strings, without relying on allocator reuse.
Ordinary appends create one primary location and one formatted-text string;
there are no supplied labels, extra spans or fixes (`:1470–1525`). The only
Change_Error_Text callers require parser recovery or unresolved-name errors,
so they do not add Main replacement strings in this legal fragment.

Non_Instance_Msgs starts at 100 entries with 100-percent growth. Errors,
Locations, Edits and Fixes each start at 200 with 200-percent growth
(`errout.adb:80–93`; `erroutc.ads:184–377`). Empty tables retain these initial
capacities. Apply actual record layouts, table rounding, allocation headers and
index/one-past checks when composing bytes. Main also creates no Warnings,
Specific_Warnings or Warnings_As_Errors entries: their constructors require
excluded warning pragmas (`erroutc.adb:1919–1939,1982–2020`;
`sem_prag.adb:28630–28647`).

This closes **Main frontend diagnostic attempts and their storage transfer**,
not the producer's later diagnostics, output rendering/SARIF containers or
fixed dependency diagnostics. Those share consumers but have different
callers. The active Main messages have no Uint insertion; this diagnostic
family adds no Uint arithmetic beyond the loop comparisons already charged.

### Cross-reference table and deduplication

`lib-xref.adb:67–158` defines an Xref_Key containing entity, source location,
reference-kind Character, two unit numbers and two enclosing-scope entities.
Xref_Set has 65536 fixed headers and links records in Xrefs itself. Add_Entry
first increments Xrefs.Last, then rolls that increment back on a duplicate
(`:188–207`). Thus duplicates do not accumulate records, but the backing
capacity and one-past check must allow **one additional tentative entry**.
Xrefs starts at 5000 with 300-percent growth (`alloc.ads:157–158`).

Here is a deliberately conservative interface bound that avoids treating
each visit or rewrite as a distinct reference. Let `n` be Main's source-byte
length and `E_X = E_fixed + E_Main` bound every entity identity in this process,
including fixed dependencies. A Main reference has a source location in its
unchanged source buffer. In GNATprove mode the location is Sloc(Nod), not a
fresh cursor for each reference; scalar range copies and light rewrites retain
their source locations. Its reference scope is Main or Empty (context items),
because there are no nested subprogram/package scopes. Its entity scope and
entity/source unit numbers are determined by the existing source entity and
the reference location (`lib-xref.adb:956–1162`;
`lib-xref-spark_specific.adb:175–310`). Hence there are at most:

```text
ordinary Main reference keys <= 512(n+1) E_X.
Main definition/orphan keys <= 2E_X.
Xref table backing demand <= X_fixed + 512(n+1) E_X + 2E_X + 1.
```

The factor 512 allows all 256 Character values and both reference scopes.
The extra source position covers the buffer boundary; no fresh virtual source
is introduced by these Main transforms. Two definition forms are allowed:
Generate_Definition uses a blank reference kind, while ALI orphan-type handling
uses Character'First, both with No_Location and empty scopes
(`lib-xref.adb:224–267,1693–1712`). This is an upper bound with intentionally
overlapping fixed terms, not a claim that every combination is reachable or
that all fixed dependency allocations are already closed.

The separate Drefs table has zero Main additions: Generate_Dereference
requires explicit/implicit dereference or a reference through a renaming to
untracked heap storage, none of which the light-mode Main closure creates
(`sem_ch4.adb:2211–2230`; `sem_util.adb:26130–26150`;
`lib-xref.adb:1069–1087`). Its initial five records still count. Its SPARK
iterator traverses existing Drefs/Xrefs entries without creating another
frontend table (`lib-xref-spark_specific.adb:61–169,315–358`). The producer's
callback allocations remain a separate producer obligation.

In the ALI pass, Output_References can add the already-budgeted orphan keys
and allocates a sorting vector of `Xrefs.Last+1` Nat words
(`lib-xref.adb:1678–1840`). No source-defined tagged types exist to enter its
primitive-operation expansion path. Translation disables this output path, so
does not allocate that sorting vector; its collected Xrefs table remains live.
The bound is intentionally loose and may be tightened before selecting a
useful capacity predicate. Its fixed-entity term must be supplied by the
complete dependency component, never silently set to zero.

### Main source-binding refinement

The Cartesian bound above is not a useful final admission rule: it combines
every source byte with thousands of fixed dependency entities, although Main
can name only its objects/indexes and the two packages/five operations. A
caller/source-binding argument removes that product.

Generate_Reference returns for a non-source reference node unless Force is
set (`lib-xref.adb:684–690`), maps an expanded name to its selector, and
requires a source entity (with named exceptions for formals, derived aliases,
child units and discriminants that Main does not create). Standard locations
are rejected in GNATprove mode (`:976–1132`). Thus generated String/Integer
subtypes, scalar captures and folded Standard constants do not introduce
additional Main-to-runtime entity pairs. Standard operator references merely
mark a type's Referenced flag; they do not append xrefs (`:275–316`).

The remaining ordinary caller families preserve a unique source binding:

| Source site | Bound entity and caller |
| --- | --- |
| Ordinary object/index/package/name use | Its unique visible entity, including assignment `m` and read `r` kinds (`sem_ch8.adb:6992–7073,7685–7771`) |
| Qualified call | Its package prefix and unique operation selector, at their separate source tokens; call resolution can add `s` for the same operation (`sem_ch4.adb:1525–1533`; `sem_res.adb:7209–7224`) |
| Actual expression name | The actual's existing entity, not each library formal (`sem_res.adb:4240–4327`). The named-association formal-reference branch is disabled in GNATprove mode (`:5197–5222`). |
| Main declaration and closing name | Main itself, for the `b`, `l` and `t` structural references (`sem_ch6.adb:4198–4202,4745–4748`; `sem_util.adb:27492–27525`) |
| Source with-name | The named Silver package (`sem_ch10.adb:3249–3254`) |
| Modification bookkeeping | The same target object at the target's source site (`sem_util.adb:26235–26306`); renaming/container paths are excluded |

Raw loop-range copies preserve their source locations and lexical bindings;
the lower-bound root replay cannot change an admitted binding. The loop
visibility rule excludes the newly introduced index from its own bounds.
Other light transforms relocate existing children or create references to
generated/Standard entities already excluded above. Forced end references
do require one additional location: Process_End_Label temporarily advances
Main's closing-name Sloc past the name before emitting `t`, then restores it.
Unnamed source loops have no closing identifier, and their generated loop
entities cannot add source-entity references through this route.

Consequently the number of `(entity, source-location)` pairs for ordinary
Main references is at most `N_word+1`. This counts keywords and declaration
names too, conservatively. Entity/source units and entity scope are determined
by the pair; permit both Main and Empty reference scopes to cover temporary
parenting during replay. Without narrowing reference kinds this already gives
`512(N_word+1)`, independently of E_fixed. The Main caller partition above
admits only `r,m,s,w,b,l,t` (allow `e` conservatively for the common end helper);
the `p` to `P` transformation requires tagged primitive operations, and the
other formal, generic, dispatching, completion and representation-reference
families are excluded. Hence the tighter transfer is:

```text
ordinary Main reference keys <= 16 (N_word+1).
Xref backing demand <= X_fixed + 16 (N_word+1) + 2 E_X + 1.
```

The two definition/orphan kinds and single tentative insertion retain their
previous allowances; fixed dependency keys remain in X_fixed. This refinement
does not claim that every generated occurrence is free: its source/Force/entity
gates and the listed transformations establish why it cannot introduce another
pair here. It is specific to Main in GNATprove light mode, not native expansion
or arbitrary source-defined entities.

For scale only, with `n=4096`, `N_word=1024` and `E_X=5000`, the old ordinary
term is 10,488,320,000 entries; this term is 16,400, plus 10,000 definition/orphan
entries, the tentative slot and X_fixed. These are illustrative parameter
values, not a measured program or a selected capacity threshold. Useful-domain
selection still needs the actual source counters, fixed contribution, target
record size and table-growth rule.

## Semantic element-list boundary

Elists are distinct from the Nlists syntax lists already counted. The common
Main helpers do not allocate them merely because an object has String type:

- Check_Function_Writable_Actuals returns unless Check_Actuals is set
  (`sem_util.adb:2920–2954`). Its relevant producer requires an out/in-out
  formal (`sem_ch4.adb:1047–1110`); every admitted actual is String `in`, and
  the other admitted operations have no actuals. This excludes both writable
  and identifier list construction, including the ordinary-read list at
  `sem_util.adb:2851`.
- Ordinary use-package clauses alter entity visibility chains. Their hidden
  element lists require an instance; use-type lists require the excluded
  use-type syntax (`sem_ch8.adb:10772–10784,10861–10875,10906–10918,11128–11174`).
- Create_Itype only creates/decorates an entity (`itypes.adb:38–81`). Private
  dependent lists in subtype construction require private or incomplete
  types, not Integer or ordinary String
  (`sem_ch3.adb:6033–6041,6150–6178,23125–23161`). Pending-itype lists in
  New_Copy_Tree are excluded for raw scalar copies by the earlier copy-shape
  argument; the shallow/static-leaf copies do not enter them.
- Collect_Primitive_Operations really would allocate a list for Standard.String
  (`sem_util.adb:5799–5831`); it is excluded by the **caller**, not the type.
  Its relevant semantic callers require derived/private/record types,
  use-type clauses, generic instances or membership tests. The equality
  resolver's call requires both In_Instance and an untagged record, and
  Resolve_Membership_Equality requires a record
  (`sem_res.adb:9148–9178,10187–10215,10328–10335`). Native expansion callers
  belong to the separate native process. Main's predefined String comparisons
  do not call it.
- Limited-view exchange/deferred-formal lists require incomplete/limited views
  or Expander_Active (`sem_ch6.adb:3154–3195,13380–13513`). Part_Of reference
  lists require that excluded pragma (`sem_util.adb:27745–27783`). Record,
  dispatching, discriminant, controlled-type and contract helper lists are
  likewise outside the established Main type/construct closure.

There is nevertheless a mandatory element-list cost at every new compilation
unit: Semantics.Do_Analyze calls Save_Scope_Stack, which creates an empty list
before checking whether there are visible entities to save. After analysis,
Semantics may append the unit through Append_New_Elmt to Comp_Unit_List
(`sem.adb:1431–1491,1650–1673`; `sem_ch8.adb:10270–10324`). Let `K_sem` count
newly analyzed units in the complete process closure. The Analyzed guard
prevents repeated with clauses from multiplying that count. Each scope-save
visits each currently visible entity at most once, and removes its immediate
visibility before any later encounter. A conservative boundary transfer is:

```text
element-list headers at unit boundaries <= K_sem + 1.
element records at unit boundaries <= K_sem (E_X + 1).
```

This pays even an empty Main scope-save, all dependency saves made while Main
is active, and the one process-wide compilation-unit list. It is an interface
to the full unit/entity closure, not a replacement for fixed dependencies'
own internal element lists or a complete inventory of every semantic package.

Three additional auxiliary paths have zero Main additions under the stated
closure, while their fixed storage remains charged:

| Resource | Why Main adds no entries | Fixed storage |
| --- | --- | --- |
| Urefs | Its only append follows an undefined/not-visible name error; successful legality excludes it (`sem_ch8.adb:6160–6238`) | initial 10 entries, 100-percent growth (`:325–352`) |
| NCT_New_Entities / NCT_Pending_Itypes | Main deep copies contain no defining entities or owned itypes; their Set sites are reached only while copying those objects (`sem_util.adb:24322–24364`) | 511 headers per Simple_HTable (`:24070–24124`) |
| Suppress_Stack_Entry linked records | Main has no Suppress/Unsuppress pragma, aggregate copying or discriminated iterator renaming: these are the only allocating caller families (`sem_prag.adb:11945–12000,12060–12101`; `sem.adb:912–950`; `sem_aggr.adb:747–748`; `sem_ch8.adb:877–900`) | fixed dependency/configuration records still count |

In particular, scalar current-value tracking in the assignment and branch
analyzers stores existing node references in entity fields
(`sem_ch5.adb:1190–1220`); it does not create an independent value-cache table.
The inspected Sem_Eval body likewise has no allocating table/map cache.
Do not add a fictional per-query cache term, or omit actual node/Uint work
already counted in the query and fold sections. The only Uint arithmetic in
Sem_Warn is in Warn_On_Suspicious_Index, an array-index warning route absent
from Main (`sem_warn.adb:4117–4246`); this excludes that particular numeric
route, not general diagnostic buffer allocation.

## Saved checks and dimension analysis

The saved-check optimization has real storage even though Sem_Eval has no
value-cache table. `checks.adb:145–197` declares 200 `Saved_Check` records and
100 `Nat` entries in `Saved_Checks_Stack`. A record contains a Boolean, two
Entity_Ids, a Uint and a Character; byte layout remains a target input. At
optimization level zero both `Enable_Overflow_Check` and `Enable_Range_Check`
return before their only calls to `Find_Check`
(`checks.adb:6432–6454,6599–6620,6695`). Thus Main inserts no saved checks, and
the `UI_Negate` in Find_Check's subtraction case (`:7131`) adds no Main Uint
work. This does not eliminate the two fixed arrays.

The nesting counter is different from the array bound. Every
`Analyze_Statements` calls `Conditional_Statements_Begin` before walking its
list and `Conditional_Statements_End` afterwards
(`sem_ch5.adb:4523–4598`). Begin increments `Saved_Checks_TOS` **before** testing
whether it exceeds 100; overflow of that cache just kills saved checks. End
still decrements the counter (`checks.adb:4921–4973`). Let `d_stmt` be the
maximum number of nested source if/for statements, and `T_fixed` the maximum
number of simultaneously active non-Main statement-list analyses in the
complete process closure. Then:

```text
Main simultaneously active Analyze_Statements calls <= 1 + d_stmt.
Saved_Checks_TOS peak <= T_fixed + 1 + d_stmt.
Saved_Checks Main records = 0.
Saved_Checks fixed arrays = 200 Saved_Check + 100 Nat.
```

The Main handled sequence contributes one call. A loop contributes one body
list, and an if contributes at most one active arm list: arms/elsif lists are
analyzed sequentially (`sem_ch5.adb:2010–2081,4278–4294`;
`sem_ch11.adb:388–445`). Main has no case, handler, finally, block or nested
subprogram; the established light-expansion closure introduces no statement
sequence containing another Main statement sequence. `T_fixed` deliberately
covers dependency analysis while a Main list remains active. The capacity
rule must ensure the peak is representable in `Nat`; **100 is not a language
nesting limit**. Actual recursion frames still need the separate traversal
stack transfer.

Dimension analysis is invoked on ordinary source expressions and declarations;
it is not sound to exclude the package solely because Silver has no dimension
syntax. Its storage can nevertheless be closed by an invariant: every Main
expression/entity and its Integer, String, Boolean or Character type has
`Null_Dimension`, and none has a dimension system. The Standard roots are not
dimension declarations, and the admitted fixed library signatures return/use
these roots. Source has no Dimension/Dimension_System aspect. Generated
Integer ranges and String subtypes preserve those roots.

The invariant is preserved by the actual active branches:

- `Dimensions_Of` is a table lookup; only `Set_Dimensions` inserts
  (`sem_dim.adb:2665–2668,3722–3728`). Identifier/type/attribute propagation
  sets only when the source has a nonempty dimension (`:2086–2164`).
- Arithmetic and comparisons inspect both dimensions. Add/subtract propagates
  only a nonempty dimension; multiply/divide enters rational arithmetic only
  when at least one dimension is nonempty (`:1377–1625`). Unary plus/minus uses
  Move_Dimensions, which uses guarded Copy_Dimensions and Remove_Dimensions
  (`:2461–2480,2507–2521,3623–3633,3677–3683`).
- An object initializer only enters its propagation/warning branch when its
  dimension differs from its type, impossible for two Null_Dimensions
  (`:2202–2278`). Both constrained and unconstrained subtype propagation
  require a nonempty parent dimension (`:2367–2405`). Removal adds nothing.
- The sole System_Table append belongs to the Dimension_System aspect
  (`:1121`). Symbol insertion is either the Dimension aspect (`:856`) or the
  two guarded subtype branches (`:2390,2402`). Dimension I/O is not an admitted
  callee (`:3583–3592`). Thus its Symbol_Of fallback string construction is
  not reached by Main (`:3743–3751`).

Consequently Main adds zero System_Table, Dimension_Table or Symbol_Table
records, zero dimension rational/Uint operations, and zero dimension
messages/symbol strings. The fixed storage remains: System_Table initially
5 records with 5-percent growth, and 511 hash headers in each of the two
Simple_HTable instances (`sem_dim.adb:125–190`). This is a Main transfer;
fixed dependency aspects, initialization and target record layout remain
separate inputs.

## Additional semantic numeric caller exclusions

The following source partition removes concrete residual numeric routes; it
does not yet promote the five-family subtotal to a whole-Main Uint bound.

| Route | Main result and source reason |
| --- | --- |
| Current-value condition inference | `Get_Current_Value_Condition` returns in GNATprove mode before reading the current-value condition (`exp_util.adb:7610–7631`). Its Compile_Time_Compare and null/non-null callers add no second numeric traversal through this helper. Entity current-value references remain real fields, already charged. |
| Saved-check subtraction offsets | Both callers of Find_Check are behind the optimization-level-zero return described above. Its UI_Negate is not another arithmetic charge. |
| Strict/minimized arithmetic check expansion | All actual callers of Apply_Arithmetic_Overflow_Check are in native `exp_ch4.adb`; Exp_SPARK does not call it. This caller exclusion matters because the strict routine computes `2 * Esize` before its own Expander_Active test (`checks.adb:796–867`). Its native cost is not removed. |
| Selected length checks | Selected_Length_Checks returns at `not Expander_Active` before the constrained-array length subtraction/addition (`checks.adb:10215–10222,10304–10387`). Light-mode Apply_Length_Check flag behavior remains charged in the earlier syntax partition. |
| Task counts in object analysis | Count_Tasks really does multiply array lengths (`sem_ch3.adb:4354–4402`), but its only call requires Has_Task and a library-level object (`:5374–5387`); Main Integer/String objects have no tasks. |
| Static array-bound helper | Matching_Static_Array_Bounds has no caller in the pinned Ada source; its arithmetic (`sem_util.adb:23173–23282`) is not part of Main execution. Number_Of_Elements_In_Array's only caller is native exp_ch3 (`exp_ch3.adb:7453`), outside this process closure. |
| Boolean fold literal lookup | Get_Enum_Lit_From_Pos reads/converts the Boolean position (0 or 1) and creates the already-counted occurrence; it performs no table-backed Uint arithmetic (`sem_util.adb:10598–10662`). Character spelling code is a separate branch, not the Boolean fold. |
| Statically_Names_Object | Its only numeric local values are read from an indexed component (`sem_util.adb:29275–29362`); Main names have no indexing. Even those values are read and compared, not arithmetically constructed. |
| Large mutable-discriminant stack test | Needs_Secondary_Stack's Is_Large_Discrete_Type requires a mutable discriminated record (`sem_util.adb:23612–23711`); Main has none. The UI_To_Int there is read-only. |
| Dimension arithmetic | Zero by the invariant above, despite active Analyze_Dimension calls. |

The omitted-type families remain excluded by the established Main closure:
no source scalar/array type definitions, real/fixed/modular arithmetic,
aggregates, predicates, access, records, representation clauses, generic
instances or user-defined literal aspects. In particular, the other
Minimum_Size callers require discriminants, fixed-point/derived types,
aggregates or representation clauses (`sem_res.adb:725–767`;
`freeze.adb:9573–9614,10147–10165`; `sem_ch13.adb:14171–14313`), while the
ordinary discrete subtype calls remain explicitly paid by `U_discrete_size`.
This exclusion does not replace auditing any remaining arithmetic written
using overloaded operators or any newly reached helper.

## Additional semantic auxiliary zero routes

The only source pragma is SPARK_Mode (On), and Main has no aspect, contract,
representation clause, package, generic, concurrent declaration or unchecked
conversion. The compiler-generated light-mode closure above introduces none
of those caller prerequisites. This closes the following **Main additions**,
not their fixed initial/dependency storage:

| Resource | Allocating route excluded from Main | Initial records / growth percent, or fixed headers |
| --- | --- | --- |
| Obsolescent_Warnings | pragma Obsolescent (`sem_prag.adb:22898`; `sem_aux.ads:56–62`) | 50 / 200 (`alloc.ads:106–107`) |
| Assertion_Levels | Insert_Assertion_Level requires an E_Assertion_Level (`sem_prag.adb:34516–34583`) | 30 / 200 (`:142–148`) |
| Externals | duplicate Export external-name tracking (`sem_prag.adb:6866–6874`) | 100 / 100, low bound 0 (`:282–288`) |
| Compile_Time_Warnings_Errors | Defer_Compile_Time_Warning_Error_To_BE takes the excluded pragma's argument (`sem_prag.adb:36002–36008`) | 50 / 200 (`:509–515`) |
| Check_Names, beyond predefined names | pragma Check_Name append (`sem_prag.adb:15732–15738`); fixed initialization still appends Predefined_Check_Id names (`checks.adb:8106–8110`) | 30 / 200 (`checks.ads:977–983`) |
| Warnings_Off_Pragmas | pragma Warnings entity form (`sem_prag.adb:28936`; `sem_warn.ads:56–62`) | 500 / 100 (`alloc.ads:151–152`) |
| Unchecked_Conversions | unchecked-conversion validation and enabled Warn_On_Unchecked_Conversion (`sem_ch13.adb:19821–19831`), neither a Main route | 50 / 200 (`:403–409`) |
| Address_Clause_Checks | Register_Address_Clause_Check is called only by address-clause analysis (`sem_ch13.adb:6993,7037,16638–16647`) | 20 / 200 (`:445–451`) |
| Alignment_Warnings | Apply_Address_Clause_Check native expansion (`checks.adb:579–750`; `exp_ch13.adb:439`) | 10 / 200, low bound 0 (`checks.ads:131–137`) |
| Subprogram_Table / Traversed_Table | both writers are local helpers of Analyze_Package_Body_Helper; Main is a procedure body (`sem_ch7.adb:244–686`) | 4093 headers each (`:198–223`) |

These tables' Init calls and fixed library/configuration producers cannot be
removed merely because Main contributes zero. Contract input/output element
lists are similarly absent for Main: all calls of
Collect_Subprogram_Inputs_Outputs are within Sem_Prag contract analysis
(`sem_prag.adb:2195,2226,3511,29410,30473,30480,33452–33780`). The admitted
SPARK_Mode handler changes fields and context and does not invoke that helper
(`:26430–26530`). This further narrows the element-list inventory without
claiming that every remaining semantic container has now been closed.

## Remaining resource obligations

Remaining whole-frontend obligations are:

1. **Other semantic numeric helpers and mutations.** Close the remaining
   numeric caller inventory beyond the five named families and the explicit
   Main diagnostic exclusions. The query envelope does not make other callers
   free. Keep value caches distinct from node identities. Serialized Uint values
   must also meet the exact Image_Out decimal-image bound; large scanner
   scratch powers are a different value population.
2. **Other semantic auxiliary storage.** Finish element lists, other auxiliary
   resources and traversal stacks, including semantic packages outside the
   explicit inventory above. Main frontend diagnostic attempts/text now have
   a transfer; producer-origin diagnostics, fixed dependency diagnostics and
   output rendering remain distinct consumer/caller work. The named
   overload/warning/xref tables and unit-boundary element lists have separate
   counts; they still require fixed-process inputs and actual
   representation/growth checks.
3. **Complete table/resource connection.** Add all remaining ordinary/entity
   slot demand, name spelling/qualification, auxiliary table events,
   remaining Uint work and peak/growth arithmetic to the existing table and
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
