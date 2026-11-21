module

public import Silver.FunctionDeclarationFrameEquations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 4000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

structure StepParts where
  first : Nat
  after : Nat
  start : Nat
  value : FunctionTypeResult

def stepParts (calls : Calls) (text : Source) (state : ParserState) : StepParts :=
  let first := calls .skip text state.position
  let after := calls .nameAfter text first
  let start := calls .take text (calls .take text after (.fixed ":" false)) (.fixed "in" true)
  ⟨first, after, start, calls .formalType text state start⟩

def stepPrefix (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) (parts : StepParts) : Bool :=
  !calls .newName text state parts.first parts.after arguments || decide (parts.start = 0) ||
    decide (parts.value.after ≤ state.position) || decide (state.functions.parameters.length = FunctionBindings.maxFormals)

def stepEquation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) (parts : StepParts) : ParameterStepResult :=
  if stepPrefix calls text state arguments parts ||
      calls .equal text parts.first parts.after (calls .skip text parts.start) parts.value.after then
    ⟨invalidState, false⟩
  else
    let next := {state with
      position := parts.value.after,
      functions := calls .appendFormal state.functions ⟨parts.first, parts.after, parts.value.kind, parts.value.bounds, parts.value.typeId⟩,
      «hiding» := calls .hideName text state.hiding parts.first parts.after}
    let separator := calls .take text parts.value.after (.fixed ";" false)
    let close := calls .take text parts.value.after (.fixed ")" false)
    if close ≠ 0 then ⟨{next with position := close}, true⟩
    else if separator > state.position then ⟨{next with position := separator}, false⟩
    else ⟨invalidState, false⟩

theorem step_denotation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) :
    parameterStepBody.eval calls ({text, state, arguments} : Frame).locals =
      stepEquation calls text state arguments (stepParts calls text state) := by
  dsimp +instances only [parameterStepBody, Expr.eval, apply2, apply3, apply4, apply5, Frame.locals,
    Locals.set, Field.get, StateField.set, Token.shell, ShellToken.word, ShellToken.symbol,
    Capacity.value, stepEquation, stepPrefix, stepParts]
  simp [Bool.or_eq_true, or_assoc]

theorem step_model_equation (text : Source) (state : ParserState) (arguments : Bool) :
    parameterStep text state arguments = stepEquation modelCalls text state arguments (stepParts modelCalls text state) := by
  rw [← parameterStep_model, step_denotation]

structure StepLexical (calls : Calls) (text : Source) (state : ParserState) : Prop where
  skip : calls .skip text state.position = skipAt text state.position
  nameAfter : calls .nameAfter text (skipAt text state.position) = Compose.nameAfter text (skipAt text state.position)
  colon : calls .take text (Compose.nameAfter text (skipAt text state.position)) (.fixed ":" false) =
    fixedAfter text (Compose.nameAfter text (skipAt text state.position)) ":" false
  inKeyword : calls .take text (fixedAfter text (Compose.nameAfter text (skipAt text state.position)) ":" false) (.fixed "in" true) =
    fixedAfter text (fixedAfter text (Compose.nameAfter text (skipAt text state.position)) ":" false) "in" true
  formalType : let start := fixedAfter text (fixedAfter text (Compose.nameAfter text (skipAt text state.position)) ":" false) "in" true
    calls .formalType text state start = formalTypeAt text state start

theorem step_parts_meaning (calls : Calls) (text : Source) (state : ParserState)
    (imports : StepLexical calls text state) : stepParts calls text state = stepParts modelCalls text state := by
  simp only [stepParts, imports.skip, imports.nameAfter, imports.colon, imports.inKeyword, imports.formalType]
  rfl

/-- Later imports are required only after the exact source prefix and name
comparison guards. In particular Equal_Name never needs an invalid name span. -/
structure StepImports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    : Prop extends StepLexical calls text state where
  newName : let p := stepParts modelCalls text state
    calls .newName text state p.first p.after arguments = newNameAllowed text state p.first p.after arguments
  skipType : let p := stepParts modelCalls text state
    stepPrefix modelCalls text state arguments p = false → calls .skip text p.start = skipAt text p.start
  equal : let p := stepParts modelCalls text state
    stepPrefix modelCalls text state arguments p = false →
    calls .equal text p.first p.after (skipAt text p.start) p.value.after =
      Named.equalName text p.first p.after (skipAt text p.start) p.value.after
  append : let p := stepParts modelCalls text state
    stepPrefix modelCalls text state arguments p = false →
    Named.equalName text p.first p.after (skipAt text p.start) p.value.after = false →
    calls .appendFormal state.functions ⟨p.first, p.after, p.value.kind, p.value.bounds, p.value.typeId⟩ =
      FunctionBindings.appendFormal state.functions ⟨p.first, p.after, p.value.kind, p.value.bounds, p.value.typeId⟩
  hide : let p := stepParts modelCalls text state
    stepPrefix modelCalls text state arguments p = false →
    Named.equalName text p.first p.after (skipAt text p.start) p.value.after = false →
    calls .hideName text state.hiding p.first p.after = hideName text state.hiding p.first p.after
  separator : let p := stepParts modelCalls text state
    stepPrefix modelCalls text state arguments p = false →
    Named.equalName text p.first p.after (skipAt text p.start) p.value.after = false →
    calls .take text p.value.after (.fixed ";" false) = fixedAfter text p.value.after ";" false
  close : let p := stepParts modelCalls text state
    stepPrefix modelCalls text state arguments p = false →
    Named.equalName text p.first p.after (skipAt text p.start) p.value.after = false →
    calls .take text p.value.after (.fixed ")" false) = fixedAfter text p.value.after ")" false

theorem parameterStep_imports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    (imports : StepImports calls text state arguments) :
    parameterStepBody.eval calls ({text, state, arguments} : Frame).locals = parameterStep text state arguments := by
  rw [step_denotation, step_parts_meaning calls text state imports.toStepLexical, step_model_equation]
  have prefixSame : stepPrefix calls text state arguments (stepParts modelCalls text state) =
      stepPrefix modelCalls text state arguments (stepParts modelCalls text state) := by
    simp only [stepPrefix, imports.newName, modelCalls]
  unfold stepEquation
  rw [prefixSame]
  cases rejected : stepPrefix modelCalls text state arguments (stepParts modelCalls text state) with
  | true => simp only [Bool.true_or, ↓reduceIte]
  | false =>
      simp only [Bool.false_or]
      rw [imports.skipType rejected, imports.equal rejected]
      dsimp only [modelCalls, tokenAfter]
      cases equalNames : Named.equalName text (stepParts modelCalls text state).first
          (stepParts modelCalls text state).after (skipAt text (stepParts modelCalls text state).start)
          (stepParts modelCalls text state).value.after with
      | true => simp only [↓reduceIte]
      | false =>
          simp only [Bool.false_eq_true, ↓reduceIte]
          rw [imports.append rejected equalNames, imports.hide rejected equalNames,
            imports.separator rejected equalNames, imports.close rejected equalNames]

end Silver.Compose.FunctionDeclarationNative
