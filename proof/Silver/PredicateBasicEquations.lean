module

public import Silver.PredicateBasicExpressions
public import Silver.PredicateBodyProperties

@[expose] public section

namespace Silver.Predicate.BasicNative
open Compose Bindings

/-- Target_At reads no immutable argument-name fields. Its returned position
and target therefore agree after projecting those fields out of parserState. -/
theorem targetAt_expanded (text : Source) (context : Native.Context) (scan : BodyScan) :
    (targetAt text (expandedState context scan) false).position =
      (targetAt text (parserState context.model scan) false).position ∧
    (targetAt text (expandedState context scan) false).target =
      (targetAt text (parserState context.model scan) false).target := by
  dsimp only [targetAt, expandedState, parserState, Native.Context.model]
  constructor <;> split <;> rfl

@[simp] theorem targetAt_expanded_position (text : Source) (context : Native.Context) (scan : BodyScan) :
    (targetAt text (expandedState context scan) false).position =
      (targetAt text (parserState context.model scan) false).position := (targetAt_expanded text context scan).1
@[simp] theorem targetAt_expanded_target (text : Source) (context : Native.Context) (scan : BodyScan) :
    (targetAt text (expandedState context scan) false).target =
      (targetAt text (parserState context.model scan) false).target := (targetAt_expanded text context scan).2

@[simp] theorem bodyToken_invalid (text : Source) (token : ShellToken) :
    bodyToken text invalidBody token = invalidBody := by
  cases token <;> simp [bodyToken, invalidBody, tokenAfter, fixedAfter]

@[simp] theorem model_token (text : Source) (scan : BodyScan) (token : ShellToken) :
    modelPrimitives.bodyToken text scan token = bodyToken text scan token := rfl

/-- Inhabited primitives; no implementation meaning is postulated. -/
theorem model_primitive_equations :
    modelPrimitives.token = tokenAfter ∧ modelPrimitives.expression = (fun text position names scalarNames => expressionAt text position names scalarNames) ∧
    modelPrimitives.target = targetAt ∧ modelPrimitives.fits = fitsLengthSummary ∧
    modelPrimitives.sameLength = equalLengthIntervals ∧ modelPrimitives.reject = PathFacts.Context.reject :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

@[simp] theorem fixedAfter_zero (text : Source) (spelling : String) (word : Bool) :
    fixedAfter text 0 spelling word = 0 := by simp [fixedAfter]

@[simp] theorem invalidBody_position : invalidBody.position = 0 := rfl

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

theorem basicEval_model (text : Source) (context : Native.Context) (scan : BodyScan) :
    basicEval modelPrimitives text context scan = basicBody text context.model scan := by
  dsimp +instances only [basicEval, basicCommands, dispatchCommands, outputCommands, putCommands, rejectCommands,
    assignmentCommands, Command.list, List.foldr_cons, List.foldr_nil, guard,
    Command.eval, Test.eval, Update.eval, modelPrimitives, Primitives.bodyToken,
    basicBody, basicRaw, basicKind, bodyTokens, List.foldl_cons, List.foldl_nil,
    bodyToken, tokenAfter, ShellToken.word, ShellToken.symbol, Native.Context.model,
    bindingSummary, equalLengthIntervals_exact]
  simp +instances only [targetAt_expanded_position, targetAt_expanded_target,
    Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]
  dsimp +instances only [Native.Context.model]
  repeat' first | rfl | (simp_all +instances; done) | split


/-- Calls in the typed block are connected to already checked source primitives.
The model below is an explicit inhabitant, rather than an assumed equation set. -/
structure PrimitiveEquations (primitive : Primitives) : Prop where
  callAfter : primitive.callAfter = (fun text names position operation scalarNames => Compose.callAfter text names position operation scalarNames)
  associationAfter : primitive.associationAfter = Names.associationAfter
  token : primitive.token = tokenAfter
  expression : primitive.expression = (fun text position names scalarNames => expressionAt text position names scalarNames)
  target : primitive.target = targetAt
  fits : primitive.fits = fitsLengthSummary
  sameLength : primitive.sameLength = equalLengthIntervals
  reject : primitive.reject = PathFacts.Context.reject

theorem modelEquations : PrimitiveEquations modelPrimitives := ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem PrimitiveEquations.eq_model {primitive : Primitives} (equations : PrimitiveEquations primitive) :
    primitive = modelPrimitives := by
  cases primitive
  cases equations
  simp_all [modelPrimitives]

theorem basicEval_of_equations {primitive : Primitives} (equations : PrimitiveEquations primitive)
    (text : Source) (context : Native.Context) (scan : BodyScan) :
    basicEval primitive text context scan = basicBody text context.model scan := by
  rw [equations.eq_model]
  exact basicEval_model text context scan

end Silver.Predicate.BasicNative
