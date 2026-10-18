# Retained Main semantic allocation bridge

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
2026-10-18, Linux x86_64. This connects the source-counted parser to ordinary
GNATprove semantic/light-expansion work. It supplies a structural subtotal and
explicit remaining obligations for the producer's `A_Main` input. **It does not
yet supply a complete `A_Main`, whole-process bound or admission predicate.**
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
| `D_copy <= D_s` | String declarations whose constant-name initializer is replaced by a literal copy; `D_s` is the conservative syntactic bound |

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
copies cannot silently share the prior literal's module. The producer lane is
updating its `K` and aggregate length allowances; ordinary expression visit
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
T_fold = O + P + 2O_loop + 3F + R + 3D_lit + 2U + 2H_len.
```

The terms charge source operators/artificial parser concatenations, the two
range-copy operator passes, lower-root replay, two generated literal-range
arithmetic operators per `D_lit`, the two inequality operators, and Length
plus its conversion. Leaf names retain their values without copying their
initializers during Eval_Entity_Name (`sem_eval.adb:2454–2532`); the late
declaration copy above is a distinct route. This allowance covers the listed
ordinary evaluators, not all transitive semantic helpers or diagnostics.
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

## Aggregate checkpoint and exact gaps

The preceding **covered structural subtotal**, excluding parser entities and
the following residuals, is

```text
A_struct = 4B_loop + 28F + 2R + 13D_lit + 4D_alias + 5G
           + 2D_copy + 3U + 4H_len + V0 + 2T_fold.
L_struct = R + 2D_lit + D_alias + G.
E_generated <= R + 2D_s + 3F + K_literal.
```

`E_generated` is the prior entity bound minus the parser's `1+D+2F` source
and implicit-loop entities. It includes index types and captured constants;
do not add the fresh-entity column again. The intended complete decomposition is

```text
A_Main <= A_parse + F + E_generated + A_struct + A_residual.
```

The `F` beside A_parse is its fresh loop-scope entity allocation, which the
parser's ordinary-node counter excludes. `A_residual` is **unfinished work, not
a free coefficient or a chosen safety margin**. The current exact gaps are:

1. **Semantic query/mutation closure.** Establish complete invocation counts
   for scalar range/constant comparisons, type layout and source folds from
   all reached declaration/assignment/resolution helpers. Their Uint work
   remains necessary even where syntax allocation is zero. In the reviewed
   Compile_Time_Compare helper the sole syntax constructor is Compare_Fixup
   for a constrained literal String's Last (`sem_eval.adb:995–1067`). The
   ordinary source graph has no First/Last, and generated check attributes are
   discarded; completing that graph invariant can set this helper's ordinary
   node charge to zero instead of importing its native `20A` envelope.
   Eval_Relational_Op has another conditional New_Occurrence_Of for a captured
   constant (`:3489–3505`); close its caller exclusion or multiplicity separately.
   Keep overload tables, value caches and per-kind growing mutations distinct
   from node identities. One identity bound is not a slot-event bound.
2. **Freeze/marker and enclosing Main closure.** Freeze_Entity marks entities
   frozen and reuses/creates at most one freeze node per ordinary entity
   (`freeze.adb:6536–6550,6809,8265–8283`). Verify all reached layout/freezing
   helpers and the enclosing procedure/context/SPARK_Mode path before replacing
   this residual by that simple count. Main's types exclude packed, modular,
   invariant/DIC and tagged cases; light SPARK freezing builds none of their
   support. Build_Call_Marker directly adds at most one marker/action list per
   ordinary call resolution (`sem_elab.adb:3563–3776`), but complete marker
   placement/elaboration bookkeeping remains part of this closure. C_lib is
   the source count to connect; Image is not another source library call here.
3. **Complete table/resource connection.** Add all remaining ordinary/entity
   slot mutations, name spelling/qualification, auxiliary table events,
   Uint layout/query work and peak/growth arithmetic to the existing table and
   value components. Fixed dependency work remains outside Main. The producer
   may use A_Main only after the residual is closed; this subtotal does not
   silently satisfy that prerequisite.

The meaningful new connection is source-derived ordinary semantic shape work,
including discarded work and explicit replay. The late String-copy path also
requires a concrete producer correction. These results do not establish the
complete capacity rule, source-to-installed-producer identity or permission to
remove any current language limit.

## Reproduction

Run the adjacent [source/equation check](../evidence/retained-main-semantics-20261018/derive.py)
with `--source` pointing to the pinned `gcc/ada` directory. Its
[result](../evidence/retained-main-semantics-20261018/result.json) records source
hashes, cited ranges and the aggregate equation expansion. It checks source
identity and arithmetic, not reachability, soundness or installed-tool behavior.
