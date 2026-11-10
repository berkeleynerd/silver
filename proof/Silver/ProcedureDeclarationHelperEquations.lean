module

public import Silver.ProcedureDeclarationStepImports
public import Silver.ProcedureDeclarationFrameEquations

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 5000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

/-- These equations expose the checked source trees and three native Static
refinements. None is a completed declaration or helper-result model law. -/
structure HelperEquations (calls : Calls) : Prop extends FrameEquations calls where
  parameterStep : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state → calls .procedureParameterStep text state arguments =
      procedureParameterStepBody.eval calls ({text, state, arguments} : Frame).locals
  parametersModel : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state → calls .procedureParametersModel text state arguments =
      procedureParametersModelBody.eval calls ({text, state, arguments} : Frame).locals
  parameters : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    calls .procedureParameters text state arguments = calls .procedureParametersModel text state arguments
  prefixStep : ∀ text readFrame frame parameter declarationCount,
    PrefixStepDomain text readFrame frame parameter declarationCount →
    calls .procedurePrefixStep text readFrame frame parameter declarationCount =
      procedurePrefixStepBody.eval calls
        ({text, readFrame, frame, procedureParameter := parameter, declarationCount} : Frame).locals
  prefixModel : ∀ text readFrame frame index declarationCount,
    PrefixModelDomain text readFrame frame index declarationCount →
    calls .procedurePrefixModel text readFrame frame index declarationCount =
      procedurePrefixModelBody.eval calls ({text, readFrame, frame, index, declarationCount} : Frame).locals
  «prefix» : ∀ text frame declarationCount, PrefixDomain text frame declarationCount →
    calls .procedurePrefix text frame declarationCount =
      calls .procedurePrefixModel text frame frame frame.firstProcedureParameter declarationCount

/-- Only projections of native runtime postconditions are imported here;
the source checks retain each complete precondition, postcondition and body. -/
structure HelperContracts (calls : Calls) : Prop where
  parameterStep : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    StateInput text (calls .procedureParameterStep text state arguments).state ∧
      ((calls .procedureParameterStep text state arguments).state.position = 0 ∨
        state.position < (calls .procedureParameterStep text state arguments).state.position)
  prefixStep : ∀ text readFrame frame parameter declarationCount,
    PrefixStepDomain text readFrame frame parameter declarationCount →
    StateInput text (calls .procedurePrefixStep text readFrame frame parameter declarationCount) ∧
      ((calls .procedurePrefixStep text readFrame frame parameter declarationCount).position = 0 ∨
        (calls .procedurePrefixStep text readFrame frame parameter declarationCount).procedures = frame.procedures)

structure ParameterImports (calls : Calls) : Prop where
  step : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state → StepImports calls text state arguments

theorem interpreted_parameterStep (calls : Calls) (equations : HelperEquations calls)
    (imports : ParameterImports calls) (text : Source) (textValid : FunctionBindings.Native.ValidText text)
    (state : ParserState) (arguments : Bool) (valid : StateInput text state) :
    calls .procedureParameterStep text state arguments = procedureParameterStep text state arguments := by
  rw [equations.parameterStep text textValid state arguments valid]
  exact procedureParameterStep_imports calls text state arguments (imports.step text textValid state arguments valid)

theorem interpreted_parametersModel (calls : Calls) (equations : HelperEquations calls)
    (imports : ParameterImports calls) (contracts : HelperContracts calls)
    (text : Source) (textValid : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) :
    calls .procedureParametersModel text state arguments = procedureParametersModel text state arguments := by
  rw [equations.parametersModel text textValid state arguments valid, parameters_denotation, parameters_model_equation]
  have step := interpreted_parameterStep calls equations imports text textValid state arguments valid
  have next := contracts.parameterStep text textValid state arguments valid
  rw [step] at next
  dsimp only [parametersEquation, modelCalls]
  rw [step]
  by_cases rejected : (procedureParameterStep text state arguments).state.position = 0
  · simp only [rejected, ↓reduceIte]
  · simp only [rejected, ↓reduceIte]
    split
    · rfl
    · exact interpreted_parametersModel calls equations imports contracts text textValid
        (procedureParameterStep text state arguments).state arguments next.1
termination_by Predicate.remainingAt text state.position
decreasing_by
  rw [step] at next
  have advanced := next.2.resolve_left rejected
  have bound := next.1.2.base.1
  change _ ≤ text.length + 1 at bound
  unfold Predicate.remainingAt
  omega

theorem interpreted_parameters (calls : Calls) (equations : HelperEquations calls)
    (imports : ParameterImports calls) (contracts : HelperContracts calls)
    (text : Source) (textValid : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) :
    calls .procedureParameters text state arguments = procedureParametersAt text state arguments := by
  rw [equations.parameters text textValid state arguments valid]
  exact interpreted_parametersModel calls equations imports contracts text textValid state arguments valid

end Silver.Compose.ProcedureDeclarationNative
