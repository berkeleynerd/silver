module

public import Silver.FunctionDeclarationStepImports
public import Silver.FunctionDeclarationTypeSpan

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 4000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

abbrev StateInput (text : Source) (state : ParserState) : Prop := StateRecord state ∧ NativeValidState text state

structure LocalImports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) : Prop where
  scalar : calls .scalarDeclaration text state arguments = scalarDeclarationAt text state arguments
  boolean : calls .booleanDeclaration text state arguments = booleanDeclarationAt text state arguments

theorem functionLocal_imports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    (imports : LocalImports calls text state arguments) :
    functionLocalBody.eval calls ({text, state, arguments} : Frame).locals = functionLocalAt text state arguments := by
  simp [functionLocalBody, Expr.eval, apply2, apply3, Frame.locals, Locals.set,
    Field.get, imports.scalar, imports.boolean, functionLocalAt]

/-- Typed source equations, with the three executable traversals interpreted
through their checked Static postconditions. -/
structure HeaderEquations (calls : Calls) : Prop where
  functionType : ∀ text, FunctionBindings.Native.ValidText text → ∀ state position,
    StateInput text state → position ≤ text.length + 1 →
    calls .functionType text state position = functionTypeBody.eval calls ({text, state, position} : Frame).locals
  parameterStep : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    calls .parameterStep text state arguments = parameterStepBody.eval calls ({text, state, arguments} : Frame).locals
  parametersModel : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    calls .parametersModel text state arguments = parametersModelBody.eval calls ({text, state, arguments} : Frame).locals
  parameters : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state → calls .parameters text state arguments = calls .parametersModel text state arguments
  functionLocal : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    calls .functionLocal text state arguments = functionLocalBody.eval calls ({text, state, arguments} : Frame).locals
  localsModel : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    calls .functionLocalsModel text state arguments = functionLocalsModelBody.eval calls ({text, state, arguments} : Frame).locals
  locals : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state → calls .functionLocals text state arguments = calls .functionLocalsModel text state arguments

/-- Exactly the required projections of the checked runtime postconditions
and Parser_State result type. Additional written preservation clauses remain
retained by SourceChecks.Checked and are not assumptions of these proofs. -/
structure HeaderContracts (calls : Calls) : Prop where
  parameterStep : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    StateInput text (calls .parameterStep text state arguments).state ∧
      ((calls .parameterStep text state arguments).state.position = 0 ∨
        state.position < (calls .parameterStep text state arguments).state.position)
  localStep : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    StateInput text (calls .functionLocal text state arguments) ∧
      ((calls .functionLocal text state arguments).position = 0 ∨
        state.position < (calls .functionLocal text state arguments).position)

structure HeaderImports (calls : Calls) : Prop where
  functionType : ∀ text, FunctionBindings.Native.ValidText text → ∀ state position,
    StateInput text state → position ≤ text.length + 1 → TypeImports calls text state position
  step : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state → StepImports calls text state arguments
  localStep : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state → LocalImports calls text state arguments
  beginToken : ∀ text, FunctionBindings.Native.ValidText text → ∀ state,
    StateInput text state → calls .take text state.position (.fixed "begin" true) = fixedAfter text state.position "begin" true

theorem interpreted_functionType (calls : Calls) (equations : HeaderEquations calls) (imports : HeaderImports calls)
    (text : Source) (textValid : FunctionBindings.Native.ValidText text) (state : ParserState) (position : Nat)
    (valid : StateInput text state) (bound : position ≤ text.length + 1) :
    calls .functionType text state position = functionTypeAt text state position := by
  rw [equations.functionType text textValid state position valid bound]
  exact functionType_imports calls text state position (imports.functionType text textValid state position valid bound)

theorem interpreted_parameterStep (calls : Calls) (equations : HeaderEquations calls) (imports : HeaderImports calls)
    (text : Source) (textValid : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : calls .parameterStep text state arguments = parameterStep text state arguments := by
  rw [equations.parameterStep text textValid state arguments valid]
  exact parameterStep_imports calls text state arguments (imports.step text textValid state arguments valid)

def parametersEquation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let next := calls .parameterStep text state arguments
  if next.state.position = 0 then invalidState
  else if next.closed then next.state else calls .parametersModel text next.state arguments

theorem parameters_denotation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) :
    parametersModelBody.eval calls ({text, state, arguments} : Frame).locals = parametersEquation calls text state arguments := by
  dsimp +instances only [parametersModelBody, Expr.eval, apply2, apply3, Frame.locals, Locals.set, Field.get, parametersEquation]
  simp

theorem parameters_model_equation (text : Source) (state : ParserState) (arguments : Bool) :
    parametersModel text state arguments = parametersEquation modelCalls text state arguments := by
  rw [← parametersModel_model, parameters_denotation]

theorem interpreted_parametersModel (calls : Calls) (equations : HeaderEquations calls)
    (imports : HeaderImports calls) (contracts : HeaderContracts calls)
    (text : Source) (textValid : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : calls .parametersModel text state arguments = parametersModel text state arguments := by
  rw [equations.parametersModel text textValid state arguments valid, parameters_denotation, parameters_model_equation]
  have step := interpreted_parameterStep calls equations imports text textValid state arguments valid
  have next := contracts.parameterStep text textValid state arguments valid
  rw [step] at next
  dsimp only [parametersEquation, modelCalls]
  rw [step]
  by_cases rejected : (parameterStep text state arguments).state.position = 0
  · simp only [rejected, ↓reduceIte]
  · simp only [rejected, ↓reduceIte]
    split
    · rfl
    · exact interpreted_parametersModel calls equations imports contracts text textValid
        (parameterStep text state arguments).state arguments next.1
termination_by Predicate.remainingAt text state.position
decreasing_by
  rw [step] at next
  have advanced := next.2.resolve_left rejected
  have bound := next.1.2.base.1
  change _ ≤ text.length + 1 at bound
  unfold Predicate.remainingAt
  omega

theorem interpreted_parameters (calls : Calls) (equations : HeaderEquations calls)
    (imports : HeaderImports calls) (contracts : HeaderContracts calls)
    (text : Source) (textValid : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : calls .parameters text state arguments = parametersAt text state arguments := by
  rw [equations.parameters text textValid state arguments valid]
  exact interpreted_parametersModel calls equations imports contracts text textValid state arguments valid

theorem interpreted_functionLocal (calls : Calls) (equations : HeaderEquations calls) (imports : HeaderImports calls)
    (text : Source) (textValid : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : calls .functionLocal text state arguments = functionLocalAt text state arguments := by
  rw [equations.functionLocal text textValid state arguments valid]
  exact functionLocal_imports calls text state arguments (imports.localStep text textValid state arguments valid)

def localsEquation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  if state.position = 0 then invalidState
  else if calls .take text state.position (.fixed "begin" true) ≠ 0 then state
  else let next := calls .functionLocal text state arguments
    if next.position = 0 then invalidState else calls .functionLocalsModel text next arguments

theorem locals_denotation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) :
    functionLocalsModelBody.eval calls ({text, state, arguments} : Frame).locals = localsEquation calls text state arguments := by
  dsimp +instances only [functionLocalsModelBody, Expr.eval, apply2, apply3, Frame.locals, Locals.set,
    Field.get, Token.shell, ShellToken.word, localsEquation]
  simp

theorem locals_model_equation (text : Source) (state : ParserState) (arguments : Bool) :
    functionLocalsModel text state arguments = localsEquation modelCalls text state arguments := by
  rw [← functionLocalsModel_model, locals_denotation]

theorem interpreted_functionLocalsModel (calls : Calls) (equations : HeaderEquations calls)
    (imports : HeaderImports calls) (contracts : HeaderContracts calls)
    (text : Source) (textValid : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : calls .functionLocalsModel text state arguments = functionLocalsModel text state arguments := by
  rw [equations.localsModel text textValid state arguments valid, locals_denotation, locals_model_equation]
  have step := interpreted_functionLocal calls equations imports text textValid state arguments valid
  have next := contracts.localStep text textValid state arguments valid
  rw [step] at next
  dsimp only [localsEquation, modelCalls, tokenAfter]
  rw [imports.beginToken text textValid state valid, step]
  by_cases rejected : (functionLocalAt text state arguments).position = 0
  · simp only [rejected, ↓reduceIte]
  · simp only [rejected, ↓reduceIte]
    by_cases zero : state.position = 0
    · simp only [zero, ↓reduceIte]
    · simp only [zero, ↓reduceIte]
      split
      · rfl
      · exact interpreted_functionLocalsModel calls equations imports contracts text textValid
          (functionLocalAt text state arguments) arguments next.1
termination_by Predicate.remainingAt text state.position
decreasing_by
  rw [step] at next
  have advanced := next.2.resolve_left rejected
  have bound := next.1.2.base.1
  change _ ≤ text.length + 1 at bound
  unfold Predicate.remainingAt
  omega

theorem interpreted_functionLocals (calls : Calls) (equations : HeaderEquations calls)
    (imports : HeaderImports calls) (contracts : HeaderContracts calls)
    (text : Source) (textValid : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : calls .functionLocals text state arguments = functionLocals text state arguments := by
  rw [equations.locals text textValid state arguments valid]
  exact interpreted_functionLocalsModel calls equations imports contracts text textValid state arguments valid

end Silver.Compose.FunctionDeclarationNative
