module

public import Silver.ProcedureDeclarationDenotations

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 4000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

structure StepParts where
  first : Nat
  after : Nat
  start : Nat
  value : FunctionTypeResult
  mode : ProcedureBindings.Mode

def stepParts (calls : Calls) (text : Source) (state : ParserState) : StepParts :=
  let first := calls .skip text state.position
  let after := calls .nameAfter text first
  let colonEnd := calls .take text after (.fixed ":" false)
  let inEnd := calls .take text colonEnd (.fixed "in" true)
  let outEnd := calls .take text (if inEnd = 0 then colonEnd else inEnd) (.fixed "out" true)
  let mode : ProcedureBindings.Mode := if inEnd = 0 then .output else if outEnd = 0 then .input else .inputOutput
  let start := if outEnd ≠ 0 then outEnd else inEnd
  ⟨first, after, start, calls .formalType text state start, mode⟩

def stepPrefix (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) (parts : StepParts) : Bool :=
  !calls .newName text state parts.first parts.after arguments || decide (parts.start = 0) ||
    decide (parts.value.after ≤ state.position) ||
    (decide (parts.value.typeId ≠ 0) && decide (parts.mode ≠ .input)) ||
    decide (state.procedures.parameters.length = ProcedureBindings.maxFormals)

def stepEquation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) (parts : StepParts) : ProcedureParameterStepResult :=
  if stepPrefix calls text state arguments parts ||
      calls .equal text parts.first parts.after (calls .skip text parts.start) parts.value.after then
    ⟨invalidState, false⟩
  else
    let next := {state with
      position := parts.value.after,
      procedures := calls .appendProcedureFormal state.procedures ⟨parts.first, parts.after, parts.value.kind, parts.value.bounds, parts.mode, parts.value.typeId⟩,
      «hiding» := calls .hideName text state.hiding parts.first parts.after}
    let separator := calls .take text parts.value.after (.fixed ";" false)
    let close := calls .take text parts.value.after (.fixed ")" false)
    if close ≠ 0 then ⟨{next with position := close}, true⟩
    else if separator > state.position then ⟨{next with position := separator}, false⟩
    else ⟨invalidState, false⟩

private theorem local_set_here (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) :
    (locals.set ty name value) ty name = value := by
  simp only [Locals.set, ↓reduceDIte, ↓reduceIte]

private theorem local_set_name (locals : Locals) (ty other : Ty) (name actual : String)
    (value : ty.meaning) (different : actual ≠ name) :
    (locals.set ty name value) other actual = locals other actual := by
  simp only [Locals.set, different, ↓reduceIte]
  split <;> rfl

theorem step_denotation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) :
    procedureParameterStepBody.eval calls ({text, state, arguments} : Frame).locals =
      stepEquation calls text state arguments (stepParts calls text state) := by
  simp +instances only [procedureParameterStepBody, stepEquation, stepPrefix, stepParts,
    ↓Expr.eval, apply2, apply3, apply4, apply5, ↓local_set_here, ↓local_set_name,
    Frame.locals, Field.get, StateField.set, Token.shell, ShellToken.word, ShellToken.symbol,
    Capacity.value, String.reduceEq, ne_eq, not_false_eq_true, decide_eq_true_eq, ↓reduceIte]
  rfl

private theorem reorder_rejection (a b c d e f : Prop) :
    (a ∨ b ∨ c ∨ d ∨ e ∨ f) ↔ (a ∨ b ∨ c ∨ f ∨ d ∨ e) := by
  simp only [or_left_comm, or_comm]

theorem step_model_equation (text : Source) (state : ParserState) (arguments : Bool) :
    procedureParameterStep text state arguments = stepEquation modelCalls text state arguments (stepParts modelCalls text state) := by
  dsimp only [procedureParameterStep, stepEquation, stepPrefix, stepParts, modelCalls, tokenAfter]
  simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true',
    or_assoc]
  congr 1
  apply propext
  exact reorder_rejection _ _ _ _ _ _

theorem procedureParameterStep_model (text : Source) (state : ParserState) (arguments : Bool) :
    procedureParameterStepBody.eval modelCalls ({text, state, arguments} : Frame).locals =
      procedureParameterStep text state arguments := by
  rw [step_denotation, step_model_equation]

structure StepLexical (calls : Calls) (text : Source) (state : ParserState) : Prop where
  skip : calls .skip text state.position = skipAt text state.position
  nameAfter : calls .nameAfter text (skipAt text state.position) = Compose.nameAfter text (skipAt text state.position)
  colon : calls .take text (Compose.nameAfter text (skipAt text state.position)) (.fixed ":" false) =
    fixedAfter text (Compose.nameAfter text (skipAt text state.position)) ":" false
  inKeyword : calls .take text (fixedAfter text (Compose.nameAfter text (skipAt text state.position)) ":" false) (.fixed "in" true) =
    fixedAfter text (fixedAfter text (Compose.nameAfter text (skipAt text state.position)) ":" false) "in" true
  outKeyword : let colonEnd := fixedAfter text (Compose.nameAfter text (skipAt text state.position)) ":" false
    let inEnd := fixedAfter text colonEnd "in" true
    calls .take text (if inEnd = 0 then colonEnd else inEnd) (.fixed "out" true) =
      fixedAfter text (if inEnd = 0 then colonEnd else inEnd) "out" true
  formalType : let colonEnd := fixedAfter text (Compose.nameAfter text (skipAt text state.position)) ":" false
    let inEnd := fixedAfter text colonEnd "in" true
    let outEnd := fixedAfter text (if inEnd = 0 then colonEnd else inEnd) "out" true
    let start := if outEnd ≠ 0 then outEnd else inEnd
    calls .formalType text state start = formalTypeAt text state start

theorem step_parts_meaning (calls : Calls) (text : Source) (state : ParserState)
    (imports : StepLexical calls text state) : stepParts calls text state = stepParts modelCalls text state := by
  simp only [stepParts, imports.skip, imports.nameAfter, imports.colon, imports.inKeyword, imports.outKeyword, imports.formalType]
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
    calls .appendProcedureFormal state.procedures ⟨p.first, p.after, p.value.kind, p.value.bounds, p.mode, p.value.typeId⟩ =
      ProcedureBindings.appendFormal state.procedures ⟨p.first, p.after, p.value.kind, p.value.bounds, p.mode, p.value.typeId⟩
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

theorem procedureParameterStep_imports (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    (imports : StepImports calls text state arguments) :
    procedureParameterStepBody.eval calls ({text, state, arguments} : Frame).locals = procedureParameterStep text state arguments := by
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

end Silver.Compose.ProcedureDeclarationNative
