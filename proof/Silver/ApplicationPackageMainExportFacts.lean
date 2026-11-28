module

public import Silver.ApplicationPackageMainInitialization
public import Silver.ApplicationPackageRoutineInitialization
public import Silver.ApplicationPackageRoutineClosedFrames
public import Silver.ApplicationPackageMainDomains

@[expose] public section

/-! Original specification and import histories establish the declaration
entry facts consumed by Main. No initializer-check certificate is an input. -/
namespace Silver.ApplicationPackageMain.ExportFacts
open Compose Compose.Expressions Predicate ApplicationPackageDeclarations
open ApplicationPackageInitializers ApplicationPackageFrames

private def CallableRetains (before after : ParserState) : Prop :=
  after.functions = before.functions ∧ after.procedures = before.procedures

private theorem finish_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {result : ObjectResult}
    (present : (finishObject calls text original result).frame.position ≠ 0) :
    CallableRetains result.frame (finishObject calls text original result).frame := by
  dsimp only [finishObject] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i advanced
    rw [ite_eq_right advanced]
    exact ⟨rfl, rfl⟩

private theorem booleanFinish_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd after : Nat} {localObject : Bool} {result : ObjectResult}
    (present : (objectBooleanFinish calls text original first last constantEnd after localObject result).frame.position ≠ 0) :
    CallableRetains result.frame
      (objectBooleanFinish calls text original first last constantEnd after localObject result).frame :=
  finish_retains present

private theorem boolean_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd : Nat} {localObject : Bool} {result : ObjectResult}
    (present : (objectBoolean calls text original first last constantEnd localObject result).frame.position ≠ 0) :
    CallableRetains result.frame (objectBoolean calls text original first last constantEnd localObject result).frame := by
  dsimp only [objectBoolean] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i checked
    rw [ite_eq_right checked]
    split at present
    · rename_i global
      rw [ite_eq_left global]
      split at present
      · exact False.elim (present rfl)
      · rename_i same
        rw [ite_eq_right same]
        exact booleanFinish_retains present
    · rename_i localBranch
      rw [ite_eq_right localBranch]
      exact booleanFinish_retains present

private theorem scalar_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd : Nat} {localObject : Bool} {result : ObjectResult} {constraint : ScalarConstraintResult}
    (present : (objectScalar calls text original first last constantEnd localObject result constraint).frame.position ≠ 0) :
    CallableRetains result.frame (objectScalar calls text original first last constantEnd localObject result constraint).frame := by
  dsimp only [objectScalar] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i checked
    rw [ite_eq_right checked]
    exact finish_retains present

private theorem initialized_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd : Nat} {localObject : Bool} {result : ObjectResult} {constraint : ScalarConstraintResult}
    (present : (objectInitialized calls text original first last constantEnd localObject result constraint).frame.position ≠ 0) :
    CallableRetains result.frame (objectInitialized calls text original first last constantEnd localObject result constraint).frame := by
  dsimp only [objectInitialized] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i checked
    rw [ite_eq_right checked]
    split at present
    · rename_i integer
      rw [ite_eq_left integer]
      exact scalar_retains present
    · rename_i boolean
      rw [ite_eq_right boolean]
      exact boolean_retains present

private theorem typed_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {info : PackageBindings.Metadata} {first last colonEnd constantEnd : Nat} {localObject : Bool}
    {result : ObjectResult}
    (present : (objectTyped calls text original info first last colonEnd constantEnd localObject result).frame.position ≠ 0) :
    result.frame.position ≠ 0 ∧ CallableRetains result.frame
      (objectTyped calls text original info first last colonEnd constantEnd localObject result).frame := by
  dsimp only [objectTyped] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i live
    rw [ite_eq_right live]
    refine ⟨by simpa only [decide_eq_true_eq] using live, ?_⟩
    by_cases constant : constantEnd = 0 <;>
      simp only [constant, decide_true, decide_false, Bool.false_eq_true, ↓reduceIte] at present ⊢
    all_goals
      split at present
      · exact False.elim (present rfl)
      · rename_i typed
        rw [ite_eq_right typed]
        split at present
        · rename_i integer
          rw [ite_eq_left integer]
          exact initialized_retains present
        · rename_i boolean
          rw [ite_eq_right boolean]
          exact initialized_retains present


private theorem object_callables {calls : ObjectCalls} {text : Source} {frame : ParserState}
    {info : PackageBindings.Metadata}
    (present : (objectStep calls text frame info false).frame.position ≠ 0) :
    CallableRetains frame (objectStep calls text frame info false).frame := by
  dsimp only [objectStep, objectNameStep] at present ⊢
  simp only [Bool.false_eq_true, ite_false] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i named
    rw [ite_eq_right named]
    split at present
    · rename_i fresh
      rw [ite_eq_left fresh]
      exact (typed_retains present).2
    · exact False.elim (present rfl)

structure Values (frame : ParserState) : Prop where
  static : ScalarExpression.ElaboratedEnvironment frame.scalarNames
  functions : frame.functions = {}
  procedures : frame.procedures = {}

private theorem initial_values : Values initialState := ⟨ScalarExpression.static_empty, rfl, rfl⟩
private theorem invalid_values : Values invalidState := ⟨ScalarExpression.static_empty, rfl, rfl⟩

private def Start : SpecificationStart → Prop
  | .returned result => Values result.exports
  | .loop state => Values state.exports

private def Step : SpecificationStep → Prop
  | .returned result => Values result.exports
  | .ready state | .next state => Values state.exports

private def Exit : SpecificationExit → Prop
  | .returned result => Values result.exports
  | .ready state => Values state.exports

private theorem start (calls : SpecificationCalls) (text : Source) (info : PackageBindings.Metadata) :
    Start (specificationStart calls text info) := by
  dsimp only [specificationStart]
  split
  · exact invalid_values
  · split <;> exact ⟨initial_values.static, initial_values.functions, initial_values.procedures⟩

private theorem continue_state (calls : SpecificationCalls) (text : Source) (before : Nat)
    (state : SpecificationState) (known : Values state.exports) :
    Step (continueSpecification calls text before state) := by
  dsimp only [continueSpecification]
  split
  · exact invalid_values
  · exact known

private theorem routine (calls : SpecificationCalls) (text : Source) (state : SpecificationState)
    (known : Values state.exports) : Step (specificationRoutine calls text state) := by
  dsimp only [specificationRoutine]
  split
  · exact invalid_values
  · exact continue_state _ _ _ _ ⟨known.static, known.functions, known.procedures⟩

private theorem subtype (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state : SpecificationState) (known : Values state.exports) :
    Step (specificationSubtype (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationSubtype, modelSpecificationCalls]
  split
  · exact invalid_values
  · rename_i present
    split
    · exact invalid_values
    · unfold appendExport
      apply continue_state
      have preserved {next : ParserState} (parsed : SubtypeDeclarationAt text false state.exports next) :
          Values next := by
        cases parsed
        exact ⟨known.static, known.functions, known.procedures⟩
      exact preserved (subtype_declaration_sound text state.exports false present)

private theorem object (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state : SpecificationState) (known : Values state.exports) :
    Step (specificationObject (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationObject, modelSpecificationCalls]
  split
  · exact invalid_values
  · rename_i accepted
    have present : (objectStep (modelObjectCalls reader) text state.exports state.info false).frame.position ≠ 0 :=
      fun zero => accepted (by simp only [zero, decide_true, Bool.true_or])
    unfold appendExport
    apply continue_state
    have retained := object_callables present
    exact ⟨object_global_elaborated reader text state.exports state.info known.static rfl present,
      retained.1.trans known.functions, retained.2.trans known.procedures⟩

private theorem step (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state : SpecificationState) (known : Values state.exports) :
    Step (specificationStep (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationStep]
  split
  · exact known
  · split
    · exact routine _ _ _ known
    · split
      · exact invalid_values
      · split
        · exact subtype _ _ _ known
        · exact object _ _ _ known

private theorem loop {reader text state result}
    (run : SpecificationLoop (modelSpecificationCalls reader) text state result)
    (known : Values state.exports) : Exit result := by
  induction run with
  | returned parsed =>
    have retained := step reader text _ known
    rwa [parsed] at retained
  | ready parsed =>
    have retained := step reader text _ known
    rwa [parsed] at retained
  | next parsed _ ih =>
    have retained := step reader text _ known
    rw [parsed] at retained
    exact ih retained

private theorem finish (calls : SpecificationCalls) (text : Source) (state : SpecificationState)
    (known : Values state.exports) : Values (finishSpecification calls text state).exports := by
  dsimp only [finishSpecification]
  split
  · exact invalid_values
  · exact ⟨known.static, known.functions, known.procedures⟩

/-- Every original Specification result, including early rejection, has exact
scalar initial values and empty local callable catalogs. Package signatures
live in the separate package metadata table. -/
theorem specification_values {reader text info result}
    (exec : SpecificationExec (modelSpecificationCalls reader) text info result) : Values result.exports := by
  have started := start (modelSpecificationCalls reader) text info
  unfold SpecificationExec at exec
  cases entry : specificationStart (modelSpecificationCalls reader) text info with
  | returned failed =>
    simp only [entry] at started exec
    subst result
    exact started
  | loop state =>
    simp only [entry] at started exec
    obtain ⟨exit, ran, resultEq⟩ := exec
    have retained := loop ran started
    cases exit with
    | returned failed => subst result; exact retained
    | ready finalState => subst result; exact finish _ _ _ retained

theorem readSpecification_values (reader : BooleanElaboration.Native.Reader) (text : Source)
    (info : PackageBindings.Metadata) : Values (readSpecification reader text info).exports :=
  specification_values (readSpecification_exec reader text info)

end Silver.ApplicationPackageMain.ExportFacts
