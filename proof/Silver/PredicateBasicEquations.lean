module

public import Silver.PredicateBasicExpressions
public import Silver.PredicateBodyProperties

@[expose] public section

namespace Silver.Predicate.BasicNative
open Compose Bindings

@[simp] theorem model_token (text : Source) (context : Native.Context) (scan : BodyScan) (token : ShellToken) :
    modelPrimitives.bodyToken text context scan token = bodyToken text scan token := rfl

@[simp] theorem fixedAfter_zero (text : Source) (spelling : String) (word : Bool) :
    fixedAfter text 0 spelling word = 0 := by simp [fixedAfter]

@[simp] theorem invalidBody_position (scan : BodyScan) : (invalidBody scan).position = 0 := rfl

@[simp] theorem bodyToken_invalid (text : Source) (scan : BodyScan) (token : ShellToken) :
    bodyToken text (invalidBody scan) token = invalidBody scan := by
  cases token <;> simp [bodyToken, invalidBody, tokenAfter, fixedAfter]

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

theorem basicEval_model (text : Source) (context : Native.Context) (scan : BodyScan) :
    basicEval modelPrimitives text context scan = basicBody text context.model scan := by
  have target := ScalarBodyNative.stringTargetEval_model text context scan
  dsimp +instances only [Native.Context.model] at target
  by_cases zero : scan.position = 0
  case' neg =>
    by_cases nullToken : fixedAfter text scan.position "null" true ≠ 0
    case' neg =>
      by_cases outputCall : callAfter text context.names scan.position .output context.scalarNames context.arrayNames ≠ 0
      case' neg =>
        by_cases putCall : callAfter text context.names scan.position .partialOutput context.scalarNames context.arrayNames ≠ 0
        case' neg =>
          by_cases rejectCall : context.dynamicFirst ≠ 0 ∧ callAfter text context.names scan.position .reject context.scalarNames context.arrayNames ≠ 0
          case' neg =>
            by_cases scalar : scalarTarget text context.model scan.position ≠ 0
            case' neg =>
              by_cases array : arrayTarget text context.model scan.position ≠ 0
  all_goals
    dsimp +instances only [basicEval, basicCommands, dispatchCommands, outputCommands, putCommands, rejectCommands,
      assignmentCommands, Command.list, List.foldr_cons, List.foldr_nil, guard,
      Command.eval, Test.eval, Update.eval, modelPrimitives,
      basicBody, basicRaw, basicKind, bodyTokens, List.foldl_cons, List.foldl_nil,
      bodyToken, tokenAfter, ShellToken.word, ShellToken.symbol, Native.Context.model, bindingSummary]
    simp +instances only [equalLengthIntervals_exact, Bool.or_eq_true, Bool.and_eq_true,
      Bool.not_eq_true', decide_eq_true_eq, or_assoc, *]
    repeat' first | rfl | (simp_all +instances; done) | split


/-- Calls in the typed block are connected to already checked source primitives.
The model below is an explicit inhabitant, rather than an assumed equation set. -/
structure PrimitiveEquations (primitive : Primitives) : Prop where
  callAfter : primitive.callAfter = (fun text names position operation scalarNames arrays => Compose.callAfter text names position operation scalarNames arrays)
  associationAfter : primitive.associationAfter = Names.associationAfter
  token : primitive.token = tokenAfter
  expression : primitive.expression = (fun text context position facts => expressionAt text position context.names (context.model.readingNames facts) (arrays := context.arrayNames))
  target : primitive.target = ScalarBodyNative.stringTargetEval ScalarBodyNative.modelImports
  bodyToken : primitive.bodyToken = fun text _ scan token => Predicate.bodyToken text scan token
  invalid : primitive.invalid = invalidBody
  scalarTarget : primitive.scalarTarget = fun text context position => Predicate.scalarTarget text context.model position
  scalarAssignment : primitive.scalarAssignment = fun text context scan => scalarAssignmentBody text context.model scan
  arrayTarget : primitive.arrayTarget = fun text context position => Predicate.arrayTarget text context.model position
  arrayAssignment : primitive.arrayAssignment = fun text context scan => arrayAssignmentBody text context.model scan
  fits : primitive.fits = fitsLengthSummary
  sameLength : primitive.sameLength = equalLengthIntervals
  reject : primitive.reject = PathFacts.Context.reject

theorem modelEquations : PrimitiveEquations modelPrimitives := by constructor <;> rfl

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
