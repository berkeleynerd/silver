module

public import Silver.ProcedureNameScanner
public import Silver.ComposeCoreHelperEquations
public import Silver.ComposeModelCalls

@[expose] public section

/-! Actual_Name_Step is an ordinary native function. Its tree keeps local
assignments and early returns explicit, using the inherited checked expression
language for each expression. No finished scanner meaning is an import. -/
namespace Silver.Predicate.ProcedureNameNative
open Compose Expressions

inductive ResultExpr
  | pair : Expr .number → Expr .truth → ResultExpr
  | choice : Expr .truth → ResultExpr → ResultExpr → ResultExpr

def ResultExpr.eval (calls : Expressions.Calls) (locals : Locals) : ResultExpr → NameScanStep
  | .pair next free => ⟨next.eval calls locals, free.eval calls locals⟩
  | .choice test yes no => if test.eval calls locals then yes.eval calls locals else no.eval calls locals

def ResultExpr.render : ResultExpr → List String
  | .pair next free => ["("] ++ next.render ++ [","] ++ free.render ++ [")"]
  | .choice test yes no => ["(", "if"] ++ test.render ++ ["then"] ++ yes.render ++
      ["else"] ++ no.render ++ [")"]

def ResultExpr.checked (scope : Scope) : ResultExpr → Bool
  | .pair next free => next.wellFormed && next.expression && next.scoped scope &&
      free.wellFormed && free.expression && free.scoped scope
  | .choice test yes no => test.wellFormed && test.expression && test.scoped scope &&
      yes.checked scope && no.checked scope

inductive Command
  | result : ResultExpr → Command
  | guard : Expr .truth → ResultExpr → Command → Command
  | branch : Expr .truth → Command → Command → Command
  | assign (name : String) : Expr ty → Command → Command
  | constant (name typeName : String) : Expr ty → Command → Command
  | variable (ty : Ty) (name typeName : String) : Command → Command
  | beginBody : Command → Command

def Command.eval (calls : Expressions.Calls) (locals : Locals) : Command → NameScanStep
  | .result value => value.eval calls locals
  | .guard test value rest => if test.eval calls locals then value.eval calls locals else rest.eval calls locals
  | .branch test yes no => if test.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .assign name value rest | .constant name _ value rest =>
      rest.eval calls (locals.set _ name (value.eval calls locals))
  | .variable _ _ _ rest | .beginBody rest => rest.eval calls locals

def Command.render : Command → List String
  | .result value => ["return"] ++ value.render ++ [";"]
  | .guard test value rest => ["if"] ++ test.render ++ ["then", "return"] ++ value.render ++
      [";", "end", "if", ";"] ++ rest.render
  | .branch test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++
      ["end", "if", ";"] ++ no.render
  | .assign name value rest => [name, ":="] ++ value.render ++ [";"] ++ rest.render
  | .constant name typeName value rest => [name, ":", "constant", typeName, ":="] ++
      value.render ++ [";"] ++ rest.render
  | .variable _ name typeName rest => [name, ":", typeName, ";"] ++ rest.render
  | .beginBody rest => ["begin"] ++ rest.render

/-- Uninitialized native locals enter the declared set only. An expression
cannot read one until an assignment has added it to the readable set. -/
def Command.checked (declared readable : Scope) : Command → Bool
  | .result value => value.checked readable
  | .guard test value rest => test.wellFormed && test.expression && test.scoped readable &&
      value.checked readable && rest.checked declared readable
  | .branch test yes no => test.wellFormed && test.expression && test.scoped readable &&
      yes.checked declared readable && no.checked declared readable
  | @assign ty name value rest => declared.contains name ty && value.wellFormed &&
      value.expression && value.scoped readable && rest.checked declared ((name, ty) :: readable)
  | @constant ty name typeName value rest => localType ty typeName &&
      !(declared.any fun item => item.1 == name) && value.wellFormed && value.expression &&
      value.scoped readable && rest.checked ((name, ty) :: declared) ((name, ty) :: readable)
  | .variable ty name typeName rest => localType ty typeName &&
      !(declared.any fun item => item.1 == name) && rest.checked ((name, ty) :: declared) readable
  | .beginBody rest => rest.checked declared readable

def stepBody : Command :=
  let text : Expr .source := .variable "text"
  let position : Expr .number := .variable "position"
  let after : Expr .number := .variable "after"
  let first : Expr .number := .variable "first"
  let numberAfter : Expr .number := .variable "number_after"
  let wordAfter : Expr .number := .variable "word_after"
  let characterAfter : Expr .number := .variable "character_after"
  let quotedAfter : Expr .number := .field .valueAfter (.variable "quoted")
  let invalid : ResultExpr := .pair (.number 0) (.truth false)
  let next (position : Expr .number) : ResultExpr := .pair position (.truth true)
  let take (position : Expr .number) (token : ShellToken) :=
    Expr.app (.app (.app (.function .takeToken) text) position) (.token token)
  .constant "first" "literal_position" (.app (.app (.function .skip) text) position) <|
  .constant "number_after" "literal_position"
    (.field .scalarLiteralAfter (.app (.app (.function .scalarLiteral) text) first)) <|
  .variable .number "word_after" "literal_position" <|
  .variable .value "quoted" "value_result" <|
  .variable .number "character_after" "literal_position" <|
  .beginBody <|
  .guard (.orElse (.eq position (.number 0)) (.ge position after)) invalid <|
  .guard (.ge first after) (next after) <|
  .assign "character_after" (.app (.app (.function .characterLiteral) text) first) <|
  .guard (.andThen (.ne characterAfter (.number 0)) (.le characterAfter after)) (next characterAfter) <|
  -- The quoted branch assigns its local before reading Quoted.After.
  .branch (.eq (.byteAt text first) (.characterVal (.number 34)))
    (.assign "quoted" (.app (.app (.function .literal) text) first)
      (.result (.choice (.andThen (.gt quotedAfter first) (.le quotedAfter after))
        (next quotedAfter) invalid))) <|
  .guard (.andThen (.ne numberAfter (.number 0)) (.le numberAfter after)) (next numberAfter) <|
  .branch (.eq (.byteAt text first) (.characterVal (.number 39)))
    (.assign "word_after" (.app (.app (.function .nameAfter) text)
      (.app (.app (.function .skip) text) (.add first (.number 1))))
      (.result (.choice (.andThen (.gt wordAfter first) (.le wordAfter after))
        (next wordAfter) (next (.add first (.number 1)))))) <|
  .assign "word_after" (.group (.ite
    (.andThen (.andThen (.eq (.byteAt text first) (.character 46)) (.gt first (.number 1)))
      (.ne (.byteAt text (.sub first (.number 1))) (.character 46)))
    (take (take first (.symbol ".")) (.word "input_is_valid")) (.number 0))) <|
  .guard (.andThen (.gt wordAfter first) (.le wordAfter after)) (next wordAfter) <|
  .assign "word_after" (.app (.app (.function .nameAfter) text) first) <|
  .guard (.andThen (.gt wordAfter first) (.le wordAfter after))
    (.pair wordAfter (.not (.lexEqual text first wordAfter
      (.variable "target_first") (.variable "target_after")))) <|
  .result (next (.add first (.number 1)))

def parameters : Scope :=
  [("text", .source), ("position", .number), ("after", .number),
    ("target_first", .number), ("target_after", .number)]

theorem stepBody_checked : stepBody.checked parameters parameters = true := by
  decide +kernel

def stepLocals (text : Source) (position after targetFirst targetAfter : Nat) : Locals :=
  (Context.locals {text, position, after}).set .number "target_first" targetFirst
    |>.set .number "target_after" targetAfter

theorem stepBody_model (text : Source) (position after targetFirst targetAfter : Nat) :
    stepBody.eval Expressions.modelCalls (stepLocals text position after targetFirst targetAfter) =
      actualNameStep text position after targetFirst targetAfter := by
  dsimp +instances only [stepBody, Command.eval, ResultExpr.eval, Expr.eval, Calls.get,
    Field.get, stepLocals, Context.locals, Locals.set, Expressions.modelCalls,
    modelPrimitives, spelling, isWord, ShellToken.word, ShellToken.symbol, actualNameStep]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte,
    decide_eq_true_eq, Bool.or_eq_true, Bool.and_eq_true, and_assoc]

/-- The same typed AST can be interpreted under any inherited implementation
whose raw source equations have already been connected to the existing models.
The cursor bounds cover every native input, including zero and rejection paths. -/
theorem stepBody_interpreted {domain : StateDomain} (calls : Expressions.Calls)
    (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (textValid : ValidText text) (position after targetFirst targetAfter : Nat)
    (positionBound : ValidCursor text position) (afterBound : ValidCursor text after) :
    stepBody.eval (lexical calls) (stepLocals text position after targetFirst targetAfter) =
      actualNameStep text position after targetFirst targetAfter := by
  have firstEq := interpreted_skip calls equations text textValid position positionBound
  have firstBound := equations.ranges.skip text textValid position positionBound
  rw [firstEq] at firstBound
  have numberEq := equations.scalarLiteral text textValid (skipAt text position) firstBound
  have characterEq := interpreted_characterLiteral calls equations text textValid (skipAt text position) firstBound
  have quotedEq := interpreted_literal calls equations text textValid (skipAt text position) firstBound
  have wordEq := interpreted_name calls equations text textValid (skipAt text position) firstBound
  have dotValid : ValidToken (.symbol ".") := by unfold ValidToken; decide +kernel
  have selectorValid : ValidToken (.word "input_is_valid") := by unfold ValidToken; decide +kernel
  have dotEq := interpreted_take calls equations text textValid (skipAt text position) (.symbol ".") firstBound dotValid
  have dotBound := equations.ranges.token text textValid (skipAt text position) (.symbol ".") firstBound dotValid
  rw [dotEq] at dotBound
  have selectorEq := interpreted_take calls equations text textValid
    (fixedAfter text (skipAt text position) "." false) (.word "input_is_valid") dotBound selectorValid
  simp only [ShellToken.word, ShellToken.symbol, spelling, isWord] at dotEq selectorEq
  dsimp +instances only [stepBody, Command.eval, ResultExpr.eval, Expr.eval, Calls.get,
    Field.get, stepLocals, Context.locals, Locals.set, lexical, modelPrimitives]
  simp only [ShellToken.word, ShellToken.symbol]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, firstEq, numberEq,
    characterEq, quotedEq, wordEq, dotEq, selectorEq, decide_eq_true_eq, Bool.or_eq_true, Bool.and_eq_true, and_assoc]
  unfold actualNameStep
  dsimp only
  by_cases stopped : after ≤ skipAt text position
  · simp only [stopped, ↓reduceIte]
  · have plusBound : ValidCursor text (skipAt text position + 1) := by
      unfold ValidCursor at *
      omega
    have skipped := interpreted_skip calls equations text textValid (skipAt text position + 1) plusBound
    have nextBound := equations.ranges.skip text textValid (skipAt text position + 1) plusBound
    rw [skipped] at nextBound
    have nextName := interpreted_name calls equations text textValid
      (skipAt text (skipAt text position + 1)) nextBound
    simp only [skipped, nextName]

/-- Native Pre, including its complete target span. These conditions do not
require a successful step or a recognized expression. -/
structure StepDomain (text : Source) (position after targetFirst targetAfter : Nat) : Prop where
  textValid : ValidText text
  position : ValidCursor text position
  after : ValidCursor text after
  target : ValidName text targetFirst targetAfter

abbrev Step := Source → Nat → Nat → Nat → Nat → NameScanStep

def DefinitionEquation (calls : Expressions.Calls) (step : Step) : Prop :=
  ∀ text position after targetFirst targetAfter, StepDomain text position after targetFirst targetAfter →
    step text position after targetFirst targetAfter =
      stepBody.eval (lexical calls) (stepLocals text position after targetFirst targetAfter)

theorem interpreted_step {domain : StateDomain} (calls : Expressions.Calls)
    (equations : RawHelperEquations calls (domain := domain)) (step : Step)
    (definition : DefinitionEquation calls step) (text : Source)
    (position after targetFirst targetAfter : Nat) (valid : StepDomain text position after targetFirst targetAfter) :
    step text position after targetFirst targetAfter = actualNameStep text position after targetFirst targetAfter :=
  (definition text position after targetFirst targetAfter valid).trans
    (stepBody_interpreted calls equations text valid.textValid position after targetFirst targetAfter
      valid.position valid.after)

theorem uninitialized_read_rejected :
    (Command.variable .number "word_after" "literal_position"
      (.beginBody (.result (.pair (.variable "word_after") (.truth true))))).checked parameters parameters = false := by
  decide +kernel

end Silver.Predicate.ProcedureNameNative
