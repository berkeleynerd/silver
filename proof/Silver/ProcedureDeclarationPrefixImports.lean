module

public import Silver.ProcedureDeclarationHelperEquations
public import Silver.FunctionDeclarationBodyDomains

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

structure PrefixParts where
  first : Nat
  after : Nat
  valueAfter : Nat
  following : Nat

abbrev prefixContext := FunctionDeclarationNative.bodyContext

def prefixParts (calls : Calls) (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat) : PrefixParts :=
  let first := calls .skip text frame.position
  let after := calls .nameAfter text first
  let context := {calls .contextOf ⟨readFrame, false, false⟩ with declarationCount}
  let valueAfter := calls .actualAfter text context (calls .take text after (.fixed ":=" false))
    (calls .initialFlow context) ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds, parameter.typeId⟩
  ⟨first, after, valueAfter, calls .take text valueAfter (.fixed ";" false)⟩

def prefixRejected (calls : Calls) (text : Source) (frame : ParserState)
    (parameter : ProcedureBindings.Formal) (parts : PrefixParts) : Bool :=
  decide (parts.first = 0) || decide (parts.after ≤ parts.first) ||
    !calls .equal text parts.first parts.after parameter.first parameter.after ||
    decide (parts.valueAfter = 0) || decide (parts.following ≤ frame.position)

def prefixStepEquation (calls : Calls) (text : Source) (frame : ParserState)
    (parameter : ProcedureBindings.Formal) (parts : PrefixParts) : ParserState :=
  if prefixRejected calls text frame parameter parts then invalidState
  else calls .appendProcedureParameter {frame with position := parts.following} parameter

theorem prefixStep_denotation (calls : Calls) (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat) :
    procedurePrefixStepBody.eval calls
      ({text, readFrame, frame, procedureParameter := parameter, declarationCount} : Frame).locals =
      prefixStepEquation calls text frame parameter (prefixParts calls text readFrame frame parameter declarationCount) := by
  dsimp +instances only [procedurePrefixStepBody, Command.eval, Expr.eval, apply2, apply3, apply4, apply5,
    Frame.locals, Locals.set, Field.get, StateField.set, Token.shell, ShellToken.symbol,
    prefixStepEquation, prefixRejected, prefixParts]
  simp

theorem prefixStep_model_equation (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat) :
    procedurePrefixStep text readFrame frame parameter declarationCount =
      prefixStepEquation modelCalls text frame parameter (prefixParts modelCalls text readFrame frame parameter declarationCount) := by
  rw [← procedurePrefixStep_model, prefixStep_denotation]

/-- Eager declaration initializers are linked individually at the exact
source arguments; only Equal_Name and Append follow the executable guard. -/
structure PrefixLexical (calls : Calls) (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat) : Prop where
  skip : calls .skip text frame.position = skipAt text frame.position
  nameAfter : calls .nameAfter text (skipAt text frame.position) = Compose.nameAfter text (skipAt text frame.position)
  context : calls .contextOf ⟨readFrame, false, false⟩ = nativeContextOf ⟨readFrame, false, false⟩
  assignment : calls .take text (Compose.nameAfter text (skipAt text frame.position)) (.fixed ":=" false) =
    fixedAfter text (Compose.nameAfter text (skipAt text frame.position)) ":=" false
  initial : let context := prefixContext readFrame declarationCount
    calls .initialFlow context = Predicate.ActiveFlow.initial context.scalarNames
      (Predicate.initialFacts context.model.hasArguments)
  actual : let context := prefixContext readFrame declarationCount
    calls .actualAfter text context (fixedAfter text (Compose.nameAfter text (skipAt text frame.position)) ":=" false)
      (Predicate.ActiveFlow.initial context.scalarNames (Predicate.initialFacts context.model.hasArguments))
      ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds, parameter.typeId⟩ =
    Predicate.actualAfter text context.model
      (fixedAfter text (Compose.nameAfter text (skipAt text frame.position)) ":=" false)
      (Predicate.ActiveFlow.initial context.scalarNames (Predicate.initialFacts context.model.hasArguments))
      ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds, parameter.typeId⟩
  following : let p := prefixParts modelCalls text readFrame frame parameter declarationCount
    calls .take text p.valueAfter (.fixed ";" false) = fixedAfter text p.valueAfter ";" false

theorem prefix_parts_meaning (calls : Calls) (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat)
    (imports : PrefixLexical calls text readFrame frame parameter declarationCount) :
    prefixParts calls text readFrame frame parameter declarationCount =
      prefixParts modelCalls text readFrame frame parameter declarationCount := by
  simp only [prefixParts, imports.skip, imports.nameAfter, imports.context, imports.assignment]
  rw (transparency := .default) [imports.initial, imports.actual, imports.following]
  rfl

structure PrefixImports (calls : Calls) (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat)
    : Prop extends PrefixLexical calls text readFrame frame parameter declarationCount where
  equal : let p := prefixParts modelCalls text readFrame frame parameter declarationCount
    p.first ≠ 0 → p.first < p.after →
    calls .equal text p.first p.after parameter.first parameter.after =
      Named.equalName text p.first p.after parameter.first parameter.after
  append : let p := prefixParts modelCalls text readFrame frame parameter declarationCount
    prefixRejected modelCalls text frame parameter p = false →
    calls .appendProcedureParameter {frame with position := p.following} parameter =
      appendProcedureParameter {frame with position := p.following} parameter

theorem prefixStep_imports (calls : Calls) (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat)
    (imports : PrefixImports calls text readFrame frame parameter declarationCount) :
    procedurePrefixStepBody.eval calls
      ({text, readFrame, frame, procedureParameter := parameter, declarationCount} : Frame).locals =
      procedurePrefixStep text readFrame frame parameter declarationCount := by
  rw [prefixStep_denotation, prefix_parts_meaning calls text readFrame frame parameter declarationCount imports.toPrefixLexical,
    prefixStep_model_equation]
  let p := prefixParts modelCalls text readFrame frame parameter declarationCount
  change prefixStepEquation calls text frame parameter p = prefixStepEquation modelCalls text frame parameter p
  by_cases zero : p.first = 0
  · simp [prefixStepEquation, prefixRejected, zero]
  · by_cases invalid : p.after ≤ p.first
    · simp [prefixStepEquation, prefixRejected, invalid]
    · have equalNames : calls .equal text p.first p.after parameter.first parameter.after =
          Named.equalName text p.first p.after parameter.first parameter.after :=
        imports.equal zero (Nat.lt_of_not_ge invalid)
      have rejected : prefixRejected calls text frame parameter p = prefixRejected modelCalls text frame parameter p := by
        simp only [prefixRejected, equalNames, modelCalls]
      unfold prefixStepEquation
      rw [rejected]
      cases accepted : prefixRejected modelCalls text frame parameter p with
      | true => simp only [↓reduceIte]
      | false =>
          simp only [Bool.false_eq_true, ↓reduceIte]
          exact imports.append accepted

end Silver.Compose.ProcedureDeclarationNative
