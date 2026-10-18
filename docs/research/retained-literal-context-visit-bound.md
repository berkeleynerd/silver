# Literal Main fixed context visits

2026-10-18, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
The missing fixed context input in the
[original Main ledger](retained-literal-original-main-storage.md) satisfies
**I <= 114 = 36+39+39**, under its selected source/behavior premises and the
existing fixed unit closure. This is a bound on additional implicit-with
visits in Main's context, not a claim of 114 actual clauses or a complete
frontend allocation bound. It supplies +114 statement-list requests and
+3648 caller/rounded bytes to that ledger, and <=114 additional
stmt_list_cache pushes for its shared backing join. Every such visit has
zero tree-pool insertion, lookup or replacement demand.

No compiler, prover, capture, solver, build or network operation was used.
The Oracle, current admission, tools and invocation remain unchanged.

## Family and fixed domain

Keep exactly one explicit `with Silver_IO;`, the ordinary top-level
Main/SPARK shell, C >= 1 qualified Put/Put_Line calls on direct Character
String literals, N >= 0 source nulls, no declarations/use clauses and each
decoded length <=INT_MAX. Main is nongeneric, nonchild, has no separate
specification or subunit, and acts as its own spec. Preserve successful
selected native semantic processing, no runtime body loading for inlining,
and the accepted fixed library/configuration premises.

The [fixed-input source reduction](retained-native-expansion.md#concrete-fixed-inputs-and-capture-reconciliation)
and its frozen `native-fixed-inputs.json` already supply <=36 runtime
specifications, two Silver specifications and Main: **K_sem<=39** semantic
compilation units. Its broader input/Image/concat family includes the selected
literal family. Fixed generic instances use syntax inside those units;
they do not create additional semantic compilation units. This is the source
closure premise, not an inference from a sampled Units table top.
The earlier runtime-only 288-node residual is not reinterpreted as a bound
on every frontend operation here. This addendum discharges the backend
context-visit input; any complete frontend backing composition must retain
its own construction/capture accounting.

## Three bounded creation mechanisms

### Runtime lookup: at most 36

`rtsfind.adb:1266–1327` walks `U.First_Implicit_With` and returns when a clause's
parent is `Cunit(Current_Sem_Unit)`. A miss creates one with, marks it implicit,
links it into that runtime unit's chain and appends it to the current unit's
context. Thus each of the <=36 possible runtime units contributes at most
one clause to Main, independently of C and repeated RTE lookups.

The reset sites do not reopen a populated selected entry: Initialize resets
before work (`:764`); Load_RTU returns on nonempty U.Entity before its reset
(`:1104–1121`); Set_RTU_Loaded initializes only when U.Entity is empty
(`:1815–1851`). Source-family context transfers described below cannot move
Main's retained clauses to a different parent. No repeated runtime cache
miss after a successful load is assumed.

### New elaboration mechanism: at most 39

`Ensure_Prior_Elaboration_Static` first returns for suppressed/explicit/already
installed elaboration requirements. Otherwise its `Find_With_Clause` scans
Main's actual context for a nonlimited, non-error with whose name Entity is
Unit_Id (`sem_elab.adb:8330–8501`). Only a miss appends a clause; its name is
`New_Occurrence_Of(Unit_Id)`, and the same clause is saved in the elaboration
attributes. Upgrading Elaborate to Elaborate_All only sets flags. Therefore
repeated scenarios add at most one clause per Unit_Id even if one declines
to rely on the auxiliary elaboration-attribute cache: the context search
still finds the earlier successful clause.

All call sites supply a fixed-unit key. The direct Subp_Rep/Gen_Rep calls and
the Unit_Id locals in activation/call/instantiation processing read
`Unit(Target_Rep)` (`:4965–4969,4990–4991,5238–5242,5520–5521,
5681–5685,5799–5803,5928–5929,6088–6092,6145–6149`). The representation's
common initializer sets `Rec.Unit := Find_Top_Unit(Id)` (`:10935`); its getter
only returns that field (`:11508–11512`). The SPARK constituent call also
supplies `Find_Top_Unit` directly (`:15620–15624`). The dispatcher passes
Unit_Id unchanged to the static routine (`:8121–8229`).

`Find_Top_Unit` maps through `Unit(Cunit(Get_Top_Level_Code_Unit(N)))`
and `Find_Unit_Entity` (`:9117–9171`). It selects one entity per such unit,
with fixed instance/subunit normalization. The existing selected closure
excludes new external bodies/compilation-unit instances and concurrent
subunits. Hence the key range has <=39 members. No argument about whether
Main's individual output calls actually trigger an elaboration scenario is
needed for this bound.

### Old elaboration mechanism: at most 39

`Activate_Elaborate_All_Desirable` selects the current code unit's context
and scans it first. It returns when U equals
`Cunit_Entity(Get_Cunit_Unit_Number(Withed_Lib_Unit(Itm)))`
(`sem_elab.adb:16369–16525`). The only append helper copies a clause after
`In_Withs_Of` finds precisely that same U in a specification/ancestor context;
the copy preserves Withed_Lib_Unit. A later call for U therefore finds the
new clause and returns. Even if an arbitrary caller supplied a nonunit U,
it cannot pass that matching test and append a new kind of key. There are
<=39 possible successful Cunit entity keys.

Only calls whose selected code-unit context is Main contribute to I. The
bound deliberately pays 39 without depending on Main's lack of a separate
spec/child ancestor to prove this route zero. It also adds both old and new
mechanisms without taking credit for mode exclusivity or cross-mechanism
deduplication. Their sum with the runtime route is therefore 114.

## Exhaustion and preservation of Main's context

The checked complete Ada source inventory has ten `Set_Is_Implicit_With`
call sites. The three mechanisms above own three; the other seven have these
guards:

| Site | Selected-family disposition |
| --- | --- |
| sem_ch10:3046 self-with | Changes an existing clause; Main explicitly withs Silver_IO, not itself. |
| sem_ch10:3683 ancestor with | Install_Context requires an **explicit** with of a child unit (`:3998–4040`); Silver_IO is a nonchild package. Runtime/elaboration clauses are already implicit and are not expanded here. |
| sem_ch10:3908 child parent | Main is not a child unit; parent recursion remains inside other units' contexts. |
| sem_ch10:4477 limited ancestor | Main has no limited with or limited-view expansion. |
| sem_ch8:4396 use-implies-with | Requires a context use clause and extensions; Main has no use clause. |
| sem_ch8:10182 System_Aux | Requires a source System with (`Find_System`, `:10081–10135`) and System extension. Generated runtime System clauses are not source withs. Main has neither the source with nor a separate-spec/subunit fallback. |
| sem_ch12:11344 generic inheritance | Walks from the instantiation to its enclosing compilation unit; Main contains no instantiation. Fixed runtime instances affect their own units. |

The with-constructor census also includes `lib-load.adb:480`: an explicit
with inserted for a child whose parent is a renaming. Main's sole explicit
nonchild Silver_IO with does not select it. Parser construction
(`par-ch10.adb:920`) creates the one source clause already owned by the Main
source interface. Successful selected parsing excludes error recovery's
additional context clauses. Configuration pragma prepending moves the
existing source list and does not manufacture implicit withs
(`par-ch10.adb:218–246,304–307`); Suppress_All's context insertion is a pragma,
not a with (`sem_prag.adb:35194–35212`).

Copying an already flagged node is covered separately from flag writers.
The context copy/transfer routes are child-spec synthesis
(`sem_ch10.adb:1009–1058`), instantiation spec/body conversion
(`sem_ch12.adb:7642–7687`) and copying a generic subunit
(`:9885–9903`). All are absent for selected Main. Generic inheritance's
explicit `New_Copy` is already excluded in the table. No whole-Main generic
copy is selected. The complete setter/constructor and context-field scan is
retained in the evidence; it is a source review aid, not a replacement for
these control-flow exclusions.

Main's successful generated clauses are nonlimited, nonprivate, non-error
nodes whose keys are unchanged after semantic analysis. The elaboration
creator explicitly runs after analysis/resolution/expansion
(`sem_elab.adb:8470–8478`). The potentially destructive context rewrite at
`sem_ch10.adb:7403–7420` requires a private with and is absent here; the
self-with removal at `:3055–3067` removes use clauses, not withs. Sem_Elab's
scenario deletion operates on scenario sets, not Main's context. No selected
context move, copy, key change or erase/reinsert sequence defeats the guards.

Finally `Compilation_Unit_to_gnu` traverses Main's context once
(`trans.cc:6018–6025`). Main acts as its own spec, and the accepted body
frontier has no separate compilation-unit/inline retranslation. At
`trans.cc:8333–8339`, Is_Implicit_With returns one empty `alloc_stmt_list`
before namespace/name/entity construction. This also establishes zero pool
insertion/lookup/replacement demand independently of clause spelling.

## Integration and checks

The [callable](../evidence/retained-literal-context-visits-20261018/derive.py)
exports I=114 as a sufficient upper input and an optional attachment that
calls the frozen original Main `evaluate(...,implicit_with_visits=114)`.
It does not edit that packet or set complete storage/toolchain flags true.
The total list-header bound becomes
**H <= 2V+5C+4N+119**. For its C=1,N=0,D=1,L=13 projection, the direct
envelope is 1061 GGC events, 420346 caller bytes and 426928 rounded-slot bytes;
the shared backing and excluded intervals remain payable.

The [evidence packet](../evidence/retained-literal-context-visits-20261018/README.md)
checks all 2319 complete retained Ada implementation/specification identities,
the ten setter and eleven with-constructor sites, relevant source excerpts,
the fixed-unit numeric inputs and the frozen Main dependency. Its arithmetic
checks cover every C=1..8,N=0..4,D<=min(2,C) combination and empty/threshold/
INT_MAX lengths. These checks exercise correspondence inputs and composition;
the source argument supplies the universal branch bound.
Independent review is pending. Selected worker: GPT-6 Astra / Extra High;
runtime confirmation and token/cost measurements are unavailable. Round
timestamps and actual check time are retained with the packet.
