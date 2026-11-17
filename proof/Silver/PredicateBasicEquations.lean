module

public import Silver.PredicateBasicExpressions

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

theorem basicEval_model (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata := {})
    (procedures : ProcedureBindings.Metadata := {}) :
    basicEval modelPrimitives text context scan catalog procedures = basicBody text context.model scan catalog procedures := by
  have target := ScalarBodyNative.stringTargetEval_model text context scan
  dsimp +instances only [Native.Context.model] at target
  by_cases zero : scan.position = 0
  case' neg =>
    by_cases nullToken : fixedAfter text scan.position "null" true ≠ 0
    case' neg =>
      by_cases outputCall : !context.pure && decide (callAfter text context.names scan.position .output context.scalarNames context.arrayNames (context.subtypeHiding.get .output) context.booleanNames ≠ 0) = true
      case' neg =>
        by_cases putCall : !context.pure && decide (callAfter text context.names scan.position .partialOutput context.scalarNames context.arrayNames (context.subtypeHiding.get .partialOutput) context.booleanNames ≠ 0) = true
        case' neg =>
          by_cases rejectCall : context.dynamicFirst ≠ 0 ∧ callAfter text context.names scan.position .reject context.scalarNames context.arrayNames (context.subtypeHiding.get .reject) context.booleanNames ≠ 0
          case' neg =>
            by_cases scalar : scalarTarget text context.model scan.position ≠ 0
            case' neg =>
              by_cases array : !context.pure && decide (arrayTarget text context.model scan.position ≠ 0) = true
              case' neg =>
                by_cases boolean : booleanTarget text context.model scan.position ≠ 0
                case' neg =>
                  by_cases absentTarget : (stringAssignmentTarget text context.model scan).target = 0
                  case' neg =>
                    by_cases characterTarget :
                        ((context.names.get (stringAssignmentTarget text context.model scan).target).getD {}).isCharacter = true
                    case' neg =>
                      by_cases elementTarget :
                        fixedAfter text (stringAssignmentTarget text context.model scan).position "(" false ≠ 0
  all_goals by_cases procedure : procedureCalleeAt text context.model scan.position procedures ≠ 0
  all_goals by_cases pure : context.pure = true
  all_goals
    by_cases booleanArray : (ArrayBindings.binding context.arrayNames
      (arrayTarget text context.model scan.position)).isBoolean = true
  all_goals
    dsimp +instances only [Native.Context.model, stringAssignmentTarget] at *
    dsimp +instances only [basicEval, basicCommands, dispatchCommands, outputCommands, putCommands, rejectCommands,
      assignmentCommands, Command.list, List.foldr_cons, List.foldr_nil, guard,
      characterCommands, elementCommands, wholeCommands,
      Command.eval, Test.eval, Update.eval, modelPrimitives,
      basicBody, basicRaw, basicKind, stringAssignmentBody, stringAssignmentStart,
      stringAssignmentKind, stringAssignmentTarget, characterAssignmentPosition, elementTargetRead,
      bodyTokens, List.foldl_cons, List.foldl_nil,
      bodyToken, tokenAfter, ShellToken.word, ShellToken.symbol, Native.Context.model, bindingSummary]
    simp +instances only [equalLengthIntervals_exact, Bool.or_eq_true, Bool.and_eq_true,
      ↓reduceIte,
      Bool.not_eq_true', decide_eq_true_eq, or_assoc, *]
    try simp_all +instances
    repeat' first | rfl | (split <;> simp_all +instances)


/-- Calls in the typed block are connected to already checked source primitives.
The model below is an explicit inhabitant, rather than an assumed equation set. -/
structure PrimitiveEquations (primitive : Primitives) : Prop where
  callAfter : primitive.callAfter = (fun text names position operation scalarNames arrays hidden booleans => Compose.callAfter text names position operation scalarNames arrays hidden booleans)
  associationAfter : primitive.associationAfter = Names.associationAfter
  token : primitive.token = tokenAfter
  expression : primitive.expression = (fun text context position facts => readStringInFlow text context.model position facts)
  readingNames : primitive.readingNames = (fun context facts => context.model.readingNames facts)
  character : primitive.character = (fun text position names scalarNames arrays => characterAt text position names scalarNames arrays)
  indexed : primitive.indexed = indexedAt
  target : primitive.target = ScalarBodyNative.stringTargetEval ScalarBodyNative.modelImports
  bodyToken : primitive.bodyToken = fun text _ scan token => Predicate.bodyToken text scan token
  invalid : primitive.invalid = invalidBody
  scalarTarget : primitive.scalarTarget = fun text context position => Predicate.scalarTarget text context.model position
  scalarAssignment : primitive.scalarAssignment = fun text context scan => scalarAssignmentBody text context.model scan
  callAssignment : primitive.callAssignment = fun text context scan catalog => callAssignmentBody text context.model scan catalog
  procedureCallee : primitive.procedureCallee = fun text context position procedures => procedureCalleeAt text context.model position procedures
  procedureCall : primitive.procedureCall = fun text context scan procedures => procedureCallBody text context.model scan procedures
  booleanTarget : primitive.booleanTarget = fun text context position => Predicate.booleanTarget text context.model position
  booleanAssignment : primitive.booleanAssignment = fun text context scan => booleanAssignmentBody text context.model scan
  arrayTarget : primitive.arrayTarget = fun text context position => Predicate.arrayTarget text context.model position
  arrayAssignment : primitive.arrayAssignment = fun text context scan => arrayAssignmentBody text context.model scan
  booleanArrayAssignment : primitive.booleanArrayAssignment = fun text context scan => booleanArrayAssignmentBody text context.model scan
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
    (text : Source) (context : Native.Context) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata := {})
    (procedures : ProcedureBindings.Metadata := {}) :
    basicEval primitive text context scan catalog procedures = basicBody text context.model scan catalog procedures := by
  rw [equations.eq_model]
  exact basicEval_model text context scan catalog procedures

end Silver.Predicate.BasicNative
