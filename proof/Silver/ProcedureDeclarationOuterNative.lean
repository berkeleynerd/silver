module

public import Silver.ProcedureDeclarationSyntax

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 3000000
set_option backward.dsimp.instances true

def procedureDeclarationBody : Command .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let start : Expr .number := .variable "start"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let opening : Expr .number := .variable "open"
  let initialInput : Expr .state := .variable "initial"
  let header : Expr .state := .variable "header"
  let bodyStart : Expr .number := .variable "body_start"
  .letValue "start" (apply3 (.function .take) text (.field .position state) (.token .procedureKeyword)) <|
    .letValue "first" (apply2 (.function .skip) text start) <|
    .letValue "after" (apply2 (.function .nameAfter) text first) <|
    .letValue "open" (apply3 (.function .take) text after (.token .leftParenthesis)) <|
    .beginBody <| .guard
      (.orElse (.orElse (.orElse (.orElse (.orElse
        (.eq start (.number 0)) (.eq opening (.number 0))) (.field .pure state))
        (.not (apply5 (.function .newName) text state first after arguments)))
        (.eq (.field .procedureCount (.field .procedures state)) (.capacity .procedures)))
        (.eq (.field .procedureParameterCount (.field .procedures state)) (.capacity .procedureFormals))) .invalid <|
    .block <| .letValue "initial"
      (.update .firstProcedureParameter
        (.update .hiding
          (.update .procedures
            (.update .functions (.update .subtypes
              (.update .arrayEnvironment (.update .pure (.update .position .initial opening) (.truth true))
                (.emptyArrayFrame state)) (.field .subtypes state))
              (.field .functions state))
            (.field .procedures state))
          (apply4 (.function .hideName) text (apply2 (.function .hiddenOuter) text state) first after))
        (.add (.field .procedureParameterCount (.field .procedures state)) (.number 1))) <|
    .letValue "header" (apply3 (.function .procedureParameters) text initialInput arguments) <|
    .beginBody <| .guard (.eq (.field .position header) (.number 0)) .invalid <|
    .block <| .letValue "body_start" (apply3 (.function .take) text (.field .position header) (.token .isKeyword)) <|
    .beginBody <| .guard (.orElse (.eq bodyStart (.number 0))
      (.not (.anyWritable (.field .procedures header) (.field .firstProcedureParameter header)))) .invalid <|
    .returned <| apply6 (.function .procedureBody) text state (.update .position header bodyStart) first after arguments

structure DeclarationInput where
  text : Source
  state : ParserState
  arguments : Bool

def DeclarationInput.locals (input : DeclarationInput) : Locals
  | .source, "text" => input.text
  | .state, "state" => input.state
  | .truth, "arguments" => input.arguments
  | ty, _ => ty.default

structure DeclarationParts where
  start : Nat
  first : Nat
  after : Nat
  opening : Nat

def declarationParts (calls : Calls) (text : Source) (state : ParserState) : DeclarationParts :=
  let start := calls .take text state.position (.fixed "procedure" true)
  let first := calls .skip text start
  let after := calls .nameAfter text first
  ⟨start, first, after, calls .take text after (.fixed "(" false)⟩

def declarationRejected (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool)
    (parts : DeclarationParts) : Bool :=
  decide (parts.start = 0) || decide (parts.opening = 0) || state.pure ||
    !calls .newName text state parts.first parts.after arguments ||
    decide (state.procedures.items.length = ProcedureBindings.maxProcedures) ||
    decide (state.procedures.parameters.length = ProcedureBindings.maxFormals)

def declarationInitial (calls : Calls) (text : Source) (state : ParserState)
    (parts : DeclarationParts) : ParserState :=
  {initialState with
    position := parts.opening, pure := true,
    arrayNames := {types := state.arrayNames.types},
    subtypeNames := state.subtypeNames, functions := state.functions, procedures := state.procedures,
    «hiding» := calls .hideName text (calls .hiddenOuter text state) parts.first parts.after,
    firstProcedureParameter := state.procedures.parameters.length + 1}

def declarationEquation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let parts := declarationParts calls text state
  if declarationRejected calls text state arguments parts then invalidState else
  let initial := declarationInitial calls text state parts
  let header := calls .procedureParameters text initial arguments
  if decide (header.position = 0) then invalidState else
  let bodyStart := calls .take text header.position (.fixed "is" true)
  let writable := (header.procedures.parameters.drop (header.firstProcedureParameter - 1)).any
    (fun parameter => parameter.mode != .input)
  if decide (bodyStart = 0) || !writable then invalidState else
    calls .procedureBody text state {header with position := bodyStart} parts.first parts.after arguments

private theorem local_set_here (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) :
    (locals.set ty name value) ty name = value := by
  simp only [Locals.set, ↓reduceDIte, ↓reduceIte]

private theorem local_set_name (locals : Locals) (ty other : Ty) (name actual : String)
    (value : ty.meaning) (different : actual ≠ name) :
    (locals.set ty name value) other actual = locals other actual := by
  simp only [Locals.set, different, ↓reduceIte]
  split <;> rfl

theorem declaration_denotation (calls : Calls) (text : Source) (state : ParserState) (arguments : Bool) :
    procedureDeclarationBody.eval calls (DeclarationInput.locals ⟨text, state, arguments⟩) =
      declarationEquation calls text state arguments := by
  simp +instances only [procedureDeclarationBody, declarationEquation, declarationParts,
    declarationInitial, declarationRejected, ↓Command.eval, ↓Expr.eval,
    apply2, apply3, apply4, apply5, apply6, ↓local_set_here, ↓local_set_name,
    DeclarationInput.locals, Field.get, StateField.set, Token.shell,
    ShellToken.word, ShellToken.symbol, Capacity.value,
    String.reduceEq, ne_eq, not_false_eq_true] <;> rfl

theorem declaration_model_equation (text : Source) (state : ParserState) (arguments : Bool) :
    declarationEquation modelCalls text state arguments = procedureDeclarationAt text state arguments := by
  dsimp +instances only [declarationEquation, declarationParts, declarationInitial, declarationRejected,
    procedureDeclarationAt, modelCalls, tokenAfter]
  simp only [decide_eq_true_eq, Bool.or_eq_true, Bool.not_eq_true', or_assoc]

end Silver.Compose.ProcedureDeclarationNative
