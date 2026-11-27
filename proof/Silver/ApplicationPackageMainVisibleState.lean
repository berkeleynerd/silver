module

public import Silver.ApplicationPackageProcedureStatement
public import Silver.ApplicationPackageVisibleStateLayout

@[expose] public section

/-! Main retains qualified public imports, while its own scalar names originate
after the package body. These source-position facts exclude private package
state from the native reset pass, even when a Main local has the same spelling. -/
namespace Silver.ApplicationPackageMain
open Compose Predicate ApplicationPackages ApplicationPackageCalls
open ApplicationPackageFrameLayout ApplicationPackageEffects

set_option backward.dsimp.instances true

def ScalarsFrom (first : Nat) (names : ScalarExpression.Environment) : Prop :=
  ∀ row ∈ names, row.qualifierFirst = 0 → first ≤ row.first

theorem ScalarsFrom.retain {first : Nat} {before after : ScalarExpression.Environment}
    (source : ScalarsFrom first before) (kept : after.Sublist before) : ScalarsFrom first after :=
  fun row present bare => source row (kept.subset present) bare

theorem ScalarsFrom.append {first : Nat} {before : ScalarExpression.Environment}
    {row : ScalarExpression.Binding} (source : ScalarsFrom first before)
    (later : first ≤ row.first) : ScalarsFrom first (before ++ [row]) := by
  intro item member bare
  rcases List.mem_append.mp member with old | added
  · exact source item old bare
  · cases List.mem_singleton.mp added
    exact later

theorem ScalarsFrom.bodyEnvironment {first : Nat} {names : ScalarExpression.Environment}
    (source : ScalarsFrom first names) : ScalarsFrom first (ScalarExpression.bodyEnvironment names) := by
  intro row member bare
  obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
  exact source original present bare

theorem imported_scalars (exports : ParserState) (info : PackageBindings.Metadata)
    (position first : Nat) (named : info.nameFirst ≠ 0) :
    ScalarsFrom first (ApplicationPackageFrames.importedFrameRaw exports info position).scalarNames := by
  intro row member bare
  obtain ⟨original, _, rfl⟩ := List.mem_map.mp member
  exact False.elim (named bare)

theorem imported_scalars_checked {text : Source} {exports : ParserState}
    {info : PackageBindings.Metadata} {position first : Nat} (named : info.nameFirst ≠ 0) :
    ScalarsFrom first (ApplicationPackageFrames.importedFrame text exports info position).scalarNames := by
  unfold ApplicationPackageFrames.importedFrame
  dsimp only
  split
  · exact imported_scalars exports info position first named
  · simp [ScalarsFrom, invalidState]

/-- No active Integer private-state row is an unqualified Main binding. The
comparison uses original defining positions, not identifier spelling. -/
theorem private_integer_not_visible {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} {first index : Nat}
    (source : ScalarsFrom first context.scalarNames)
    (earlier : ∀ state ∈ info.states, state.name.first < first)
    (positive : 0 < index) (active : index ≤ info.states.length)
    (integer : (info.stateAt index).kind = .integer) :
    visibleState ApplicationPackageEffects.modelCalls text context info index = false := by
  apply Bool.eq_false_iff.mpr
  intro visible
  simp only [visibleState, ApplicationPackageEffects.modelCalls, integer, ite_true] at visible
  split at visible
  · contradiction
  · simp only [Bool.and_eq_true] at visible
    have positiveSlot := of_decide_eq_true visible.1.1
    have sameFirst := of_decide_eq_true visible.1.2
    have bare := scalarLookupFrom_qualifier rfl positiveSlot
    simp only [QualifiedNames.qualifierMatches, ite_true, beq_iff_eq] at bare
    have within := ScalarExpression.lookup_bound text context.scalarNames
      (info.stateAt index).name.first (info.stateAt index).name.after
    have member : ScalarExpression.binding context.scalarNames
        (ScalarExpression.lookup text context.scalarNames
          (info.stateAt index).name.first (info.stateAt index).name.after) ∈ context.scalarNames := by
      have live : ScalarExpression.lookup text context.scalarNames
          (info.stateAt index).name.first (info.stateAt index).name.after - 1 < context.scalarNames.length := by omega
      simp only [ScalarExpression.binding, List.getD_eq_getElem?_getD,
        List.getElem?_eq_getElem live, Option.getD_some]
      exact List.getElem_mem live
    have later := source _ member bare
    have before := earlier _ (info.stateAt_mem index positive active)
    omega

theorem main_reset_slots_empty {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} {first : Nat} (writes : PackageBindings.StateSet)
    (source : ScalarsFrom first context.scalarNames)
    (earlier : ∀ state ∈ info.states, state.name.first < first) :
    resetSlots ApplicationPackageCalls.modelCalls text context info writes
      ((List.range info.states.length).map (· + 1)) = [] := by
  apply List.eq_nil_iff_forall_not_mem.mpr
  intro slot member
  obtain ⟨index, selected, found⟩ := List.mem_filterMap.mp member
  obtain ⟨offset, bounded, rfl⟩ := List.mem_map.mp selected
  have active := List.mem_range.mp bounded
  dsimp only at found
  split at found
  · rename_i chosen
    have hidden := private_integer_not_visible (text := text) source earlier
      (by omega : 0 < offset + 1) (by omega) chosen.2.2
    exact Bool.noConfusion (chosen.2.1.symm.trans hidden)
  · contradiction

end Silver.ApplicationPackageMain

namespace Silver.ApplicationPackageBodies.Basic
open Compose Predicate ApplicationPackages ApplicationPackageCalls ApplicationPackageMain

/-- Main consumes the original package procedure call using its translated
identity. Empty private-state resets follow from source positions and qualified
imports; no successful semantic call or reset certificate is assumed. -/
theorem main_procedure_source_statement {calls : BasicCalls} {text : Source}
    {context : Predicate.Native.Context} {input : ApplicationScan} {info : PackageBindings.Metadata}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata} {first : Nat}
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (source : ScalarsFrom first context.model.scalarNames)
    (earlier : ∀ state ∈ info.states, state.name.first < first)
    (selected : origin (procedureReaders calls) ⟨text, context.model, input, info, catalog, procedures⟩ = .packageProcedure)
    (accepted : (applicationBasic (procedureReaders calls) text context.model input info catalog procedures).scan.position ≠ 0)
    (environment : Applications.Environment)
    (signatures : environment.packages.signatures = (completedEnvironment info).map Packages.RoutineEffects.signature) :
    let result := applicationBasic (procedureReaders calls) text context.model input info catalog procedures
    let booleans := ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)
    ∃ call : ScalarProcedures.Call,
      ProcedureCallAt text context input info input.scan.position call ∧
      let statement : Predicate.Statement := .procedureCall ⟨environment.packageProcedureId call.callee, call.actuals⟩
      statement.WellFormed context.model.hasArguments context.names.shape booleans ∧
        statement.check context.names.shape context.model.analysis (context.model.flow input.scan.facts) booleans
          environment.functionSignatures environment.procedureSignatures = some (context.model.flow result.scan.facts) ∧
        discharged (statement.obligations context.names.shape context.model.analysis (context.model.flow input.scan.facts)
          booleans environment.functionSignatures environment.procedureSignatures) = true := by
  obtain ⟨callee, frame, arguments, bound, original, _, _, _, _, main⟩ :=
    procedure_statement_reading textValid valid body storage checked typed selected accepted
  exact ⟨⟨callee, arguments⟩, original,
    main (main_reset_slots_empty frame.callWrites source earlier) environment signatures⟩

end Silver.ApplicationPackageBodies.Basic
