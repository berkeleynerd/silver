module

public import Silver.PackageSharedCallSafety

@[expose] public section

/-! Primitive steps for the shared-state body induction. Persistent state is
preserved at its entire declared schema after every step; lexical loop binders
remain invocation-local even when they hide a persistent declaration. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value Target)
open Predicate (Flow Statement)

mutual
  def statementLocalBinders (layout : FrameLayout) : Statement → Prop
    | .choice _ yes no => StatementsLocalBinders layout yes ∧ StatementsLocalBinders layout no
    | .forLoop index _ _ _ body =>
        (∃ identity, layout.integers index = .local identity) ∧ StatementsLocalBinders layout body
    | _ => True
  termination_by statement => sizeOf statement
  def StatementsLocalBinders (layout : FrameLayout) : List Statement → Prop
    | [] => True
    | statement :: rest => statementLocalBinders layout statement ∧ StatementsLocalBinders layout rest
  termination_by statements => sizeOf statements
end

theorem scalar_assignment_sound {schema : StateSchema} {layout : FrameLayout}
    {analysis : Integer.Analysis} {before : Flow} {state : SharedState}
    {update : Integer.Assignment}
    (valid : schema.Valid) (context : layout.Context schema analysis)
    (globalsFit : schema.Fits state.globals)
    (declared : Integer.Fits analysis.declared (state.view layout).integers)
    (allowed : before.Allows true 0 false (state.view layout).integers)
    (checked : update.check before.scalars analysis.mutable analysis.declared = true) :
    SharedStepSound schema layout analysis {before with scalars := update.after before.scalars} state
      (state.write (layout.place (.integer update.target))
        (.integer (update.value.evaluate (state.view layout).integers)))
      ((update.value.checkedEvaluate (state.view layout).integers).bind fun value =>
        checkedSharedWrite layout state (.integer update.target update.bounds) (.integer value)) := by
  have sound := update.check_flow_sound checked allowed.2 declared
  have integers := state.write_integer_view context.unique update.target
    (update.value.evaluate (state.view layout).integers)
  have full : Integer.Fits analysis.declared
      ((state.write (layout.place (.integer update.target))
        (.integer (update.value.evaluate (state.view layout).integers))).view layout).integers := by
    rw [integers]
    exact sound.2.1
  have within : update.bounds.Contains (update.value.evaluate (state.view layout).integers) := by
    have agreement := sound.2.2.2
    simp only [Integer.Assignment.checkedExecute, Integer.Expr.checkedEvaluate_agrees sound.1,
      Option.bind_some] at agreement
    split at agreement
    · assumption
    · contradiction
  refine ⟨state.write_schema_from_declared context valid globalsFit full, full,
    ⟨allowed.1, ?_⟩, ?_, ?_⟩
  · rw [integers]
    exact sound.2.2.1
  · simp only [Integer.Expr.checkedEvaluate_agrees sound.1, Option.bind_some,
      checkedSharedWrite, Target.checkedWrite, within, ↓reduceIte, Option.map_some,
      ScalarProcedures.targetCell]
  · intro index readonly
    rw [integers]
    exact update.unchanged checked readonly

theorem boolean_assignment_sound {schema : StateSchema} {layout : FrameLayout}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {before : Flow}
    {state : SharedState} {update : Predicate.BooleanAssignment}
    (valid : schema.Valid) (context : layout.Context schema analysis)
    (globalsFit : schema.Fits state.globals)
    (declared : Integer.Fits analysis.declared (state.view layout).integers)
    (allowed : before.Allows true 0 false (state.view layout).integers)
    (readable : update.value.Readable false Bindings.emptyShape booleans)
    (checked : update.value.checkBounds Bindings.emptyShape analysis before booleans = true) :
    SharedStepSound schema layout analysis before state
      (state.write (layout.place (.boolean update.target))
        (.boolean (update.value.evaluate Bindings.emptyValues [] true
          (state.view layout).integers (state.view layout).booleans)))
      ((update.value.checkedEvaluate Bindings.emptyValues [] true
        (state.view layout).integers (state.view layout).booleans).map fun value =>
          state.write (layout.place (.boolean update.target)) (.boolean value)) := by
  have comparison := update.value.checkedEvaluate_of_checkBounds (booleans := (state.view layout).booleans)
    (Bindings.empty_fits []) readable allowed checked
  have integers := state.write_boolean_view context.unique update.target
    (update.value.evaluate Bindings.emptyValues [] true (state.view layout).integers (state.view layout).booleans)
  have full : Integer.Fits analysis.declared
      ((state.write (layout.place (.boolean update.target))
        (.boolean (update.value.evaluate Bindings.emptyValues [] true
          (state.view layout).integers (state.view layout).booleans))).view layout).integers := by
    rw [integers]
    exact declared
  refine ⟨state.write_schema_from_declared context valid globalsFit full, full, ?_, ?_, ?_⟩
  · rw [integers]
    exact allowed
  · simp only [comparison, Option.map_some]
  · intro index _
    exact congrFun integers index

theorem SharedState.restore_integer_view {layout : FrameLayout} (unique : layout.Injective)
    (before after : SharedState) (index : Nat) :
    ((after.write (layout.place (.integer index)) (before.read (layout.place (.integer index)))).view layout).integers =
      Integer.restore (before.view layout).integers (after.view layout).integers index := by
  rw [← before.view_read layout (.integer index)]
  exact after.write_integer_view unique index ((before.view layout).integers index)

theorem SharedState.local_integer_globals (state : SharedState) {layout : FrameLayout}
    {index identity : Nat} (located : layout.integers index = .local identity) (value : Value) :
    (state.write (layout.place (.integer index)) value).globals = state.globals := by
  simp only [FrameLayout.place, located, SharedState.write]

end Silver.Packages
