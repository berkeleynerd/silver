module

public import Silver.ComposeExpressions
public import Silver.ComposeBounds

@[expose] public section

/-! Interpret the recognizer's checked equations on its verified machine
 domains. Executable loop refinements supply equations for the same terminating
 traversals; no premise identifies the recognizer with language membership. -/

namespace Silver.Compose.Expressions
open Named

def ValidState (text : Source) (state : ParserState) : Prop :=
  ValidCursor text state.position ∧ ValidNames text state.names ∧
    (⟨state.dynamicFirst,state.dynamicAfter⟩ : NameState).Valid text ∧
    state.target ≤ state.names.length ∧ state.capacity ≤ maxSourceLength ∧
    ScalarExpression.ValidEnvironment text state.scalarNames

def allTokens : List ShellToken :=
  [.word "with", .word "silver_io", .word "procedure", .word "main", .word "is",
   .word "pragma", .word "spark_mode", .word "on", .word "begin", .word "put_line", .word "end",
   .symbol "(", .symbol ")", .symbol ";", .symbol ".", .literal, .symbol ":", .word "constant",
   .word "string", .symbol ":=", .word "silver_arguments", .word "first_or_default", .word "if",
   .word "input_is_valid", .word "then", .word "else", .word "elsif", .word "reject", .symbol "&", .word "and",
   .word "or", .word "not", .symbol "/=", .symbol "<", .symbol ">", .symbol ">=",
   .symbol "'", .word "length", .symbol "<=", .capacity, .symbol "=", .argumentDeclaration,
   .declarations, .assignmentTarget, .targetReference, .dynamicReference, .assignmentValue,
   .outputExpression, .comparisonExpression, .word "null", .contextClauses,
   .word "integer", .word "for", .word "in", .word "reverse", .word "loop", .symbol "..", .word "range"]

def ValidToken (token : ShellToken) : Prop := token ∈ allTokens

def tokenAtIndex (form : Form) (index : Nat) : ShellToken :=
  form.tokens.getD (index - 1) (.symbol ";")

def suffixAtIndex (text : Source) (form : Form) (index : Nat) (state : ParserState) : Bool :=
  suffixMatches text form (form.tokens.drop (index - 1)) state

structure Context where
  text : Source := []
  position : Nat := 0
  first : Nat := 0
  after : Nat := 0
  index : Nat := 1
  length : Nat := 0
  remaining : Nat := maxExpressionOperands
  following : Nat := 0
  nextToken : Nat := 1
  names : BindingEnvironment := []
  scalarNames : ScalarExpression.Environment := []
  state : ParserState := initialState
  value : ValueResult := invalidValue
  result : ExpressionResult := invalidExpression
  scan : ExpressionState := invalidExpressionState
  capacity : Nat := 0
  form : Form := .direct
  token : ShellToken := .symbol ";"
  operation : Names.Operation := .output
  arguments : Bool := false
  mutable : Bool := false
  sameTarget : Bool := false
  dynamicSeen : Bool := false
  integerHidden : Bool := false

def Context.locals (ctx : Context) : Locals
  | .source, _ => ctx.text
  | .number, name => match name with
    | "position" => ctx.position | "first" => ctx.first | "after" => ctx.after
    | "index" => ctx.index | "length" => ctx.length | "remaining" => ctx.remaining
    | "following" => ctx.following | "next_token" => ctx.nextToken | "capacity" => ctx.capacity | _ => 0
  | .truth, name => match name with
    | "arguments" => ctx.arguments | "mutable" => ctx.mutable
    | "same_target" => ctx.sameTarget | "dynamic_seen" => ctx.dynamicSeen
    | "integer_hidden" => ctx.integerHidden | _ => false
  | .names, _ => ctx.names
  | .scalarNames, _ => ctx.scalarNames
  | .state, _ => ctx.state
  | .value, _ => ctx.value
  | .result, _ => ctx.result
  | .scan, _ => ctx.scan
  | .form, _ => ctx.form
  | .token, _ => ctx.token
  | .operation, _ => ctx.operation
  | ty, _ => ty.default

/-- Consequences of the native subtype declarations and proved routine contracts.
Only result bounds/state preservation occur here, never admission correctness. -/
structure HelperRanges (calls : Calls) : Prop where
  skip : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    ValidCursor text (calls.function .skip text position)
  name : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    ValidCursor text (calls.function .nameAfter text position)
  token : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    ValidCursor text (calls.function .takeToken text position token)
  lookup : ∀ text, ValidText text → ∀ names first after,
    ValidNames text names → ValidCursor text first → ValidCursor text after →
    calls.function .lookupName text names first after ≤ names.length
  literal : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    ValidValue text (calls.function .literal text position)
  image : ∀ text, ValidText text → ∀ position names scalarNames integerHidden,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ValidValue text (calls.function .image text position names scalarNames integerHidden)
  value : ∀ text, ValidText text → ∀ position names scalarNames integerHidden,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ValidValue text (calls.function .value text position names scalarNames integerHidden)
  stringDeclaration : ∀ text, ValidText text → ∀ state arguments, ValidState text state →
    ValidState text (calls.function .stringDeclaration text state arguments) ∧
      ((calls.function .stringDeclaration text state arguments).position = 0 ∨
        state.position < (calls.function .stringDeclaration text state arguments).position)
  scalarDeclaration : ∀ text, ValidText text → ∀ state arguments, ValidState text state →
    ValidState text (calls.function .scalarDeclaration text state arguments) ∧
      ((calls.function .scalarDeclaration text state arguments).position = 0 ∨
        state.position < (calls.function .scalarDeclaration text state arguments).position)
  declaration : ∀ text, ValidText text → ∀ state arguments, ValidState text state →
    ValidState text (calls.function .declaration text state arguments) ∧
      ((calls.function .declaration text state arguments).position = 0 ∨
        state.position < (calls.function .declaration text state arguments).position)
  argument : ∀ text, ValidText text → ∀ state, ValidState text state →
    ValidState text (calls.function .argument text state)
  declarations : ∀ text, ValidText text → ∀ state arguments, ValidState text state →
    ValidState text (calls.function .declarations text state arguments)
  expressionStep : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames → ValidScan text scan →
    ValidScan text (calls.function .expressionStep text names scan scalarNames integerHidden) ∧
      ((calls.function .expressionStep text names scan scalarNames integerHidden).position = 0 ∨
       (calls.function .expressionStep text names scan scalarNames integerHidden).complete = true ∨
       scan.position < (calls.function .expressionStep text names scan scalarNames integerHidden).position)
  expression : ∀ text, ValidText text → ∀ position names scalarNames integerHidden,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ValidResult text (calls.function .expression text position names scalarNames integerHidden)

structure RangeContracts (calls : Calls) : Prop extends HelperRanges calls where
  step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state →
    ValidState text (calls.function .step text form token state)

/-- Equations of checked expression bodies or exact executable-refinement
postconditions. The evaluator's primitive meanings may be normalized later. -/
structure HelperEquations (calls : Calls) (evaluator : Calls := lexical calls) : Prop where
  ranges : HelperRanges calls
  names : Names.InterpretedSource calls.names
  scalarLookup : ∀ text, ValidText text → ∀ names first after,
    ScalarExpression.ValidEnvironment text names → ValidCursor text first → ValidCursor text after →
    calls.function .scalarLookup text names first after = ScalarExpression.lookup text names first after
  scalarRead : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ScalarExpression.ValidEnvironment text names →
    calls.function .scalarRead text position names = ScalarExpression.read text position names
  scalarLiteral : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    calls.function .scalarLiteral text position = ScalarLiteral.read text position
  scalarAppend : ∀ names item, names.length < ScalarExpression.maxBindings →
    calls.function .scalarAppend names item = names ++ [item]
  scalarEmpty : ∀ value, value.Bounded →
    calls.function .scalarEmpty value = value.isEmpty
  imageMinimum : ∀ value, value.Bounded →
    calls.function .imageMinimum value = (LengthSummary.ofImage value).minimumLength
  imageMaximum : ∀ value, value.Bounded →
    calls.function .imageMaximum value = (LengthSummary.ofImage value).staticLength
  nameIs : ∀ text, ValidText text → ∀ first after word,
    ValidName text first after → 0 < word.toList.length → word.toList.length ≤ 16 →
    calls.function .nameIs text first after word = Named.nameIs text first after (word.toList.map Char.toNat)
  callAfter : ∀ text, ValidText text → ∀ names position operation scalarNames,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames → ValidCursor text position →
    calls.function .callAfter text names position operation scalarNames =
      callAfterBody.eval evaluator (Context.locals {text,scalarNames,names,position,operation})
  skip : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    calls.function .skip text position =
      skipBody.eval evaluator (Context.locals {text,position})
  name : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    calls.function .nameAfter text position =
      nameBody.eval evaluator (Context.locals {text,position})
  fixed : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    calls.function .fixedAfter text position token =
      fixedBody.eval evaluator (Context.locals {text,position,token})
  take : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    calls.function .takeToken text position token =
      fixedBody.eval evaluator (Context.locals {text,position,token})
  lookupFrom : ∀ text, ValidText text → ∀ names first after index,
    ValidNames text names → ValidName text first after → 1 ≤ index → index ≤ names.length + 1 →
    calls.function .lookupFrom text names first after index =
      lookupFromBody.eval evaluator (Context.locals {text,names,first,after,index})
  lookup : ∀ text, ValidText text → ∀ names first after,
    ValidNames text names → ValidCursor text first → ValidCursor text after →
    calls.function .lookupName text names first after =
      lookupBody.eval evaluator (Context.locals {text,names,first,after})
  literal : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    calls.function .literal text position =
      literalBody.eval evaluator (Context.locals {text,position})
  workTail : ∀ text, ValidText text → ∀ position remaining,
    ValidCursor text position → remaining ≤ maxConcatenations →
    calls.function .workTail text position remaining =
      workTailBody.eval evaluator (Context.locals {text,position,remaining})
  workBudget : ∀ text, ValidText text →
    calls.function .workBudget text = workBudgetBody.eval evaluator (Context.locals {text})
  image : ∀ text, ValidText text → ∀ position names scalarNames integerHidden,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    calls.function .image text position names scalarNames integerHidden =
      imageBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,position,names})
  value : ∀ text, ValidText text → ∀ position names scalarNames integerHidden,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    calls.function .value text position names scalarNames integerHidden =
      valueBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,position,names})
  newName : ∀ text, ValidText text → ∀ state first after arguments,
    ValidState text state → ValidCursor text first → ValidCursor text after →
    calls.function .newName text state first after arguments =
      newNameBody.eval evaluator (Context.locals {text,state,first,after,arguments})
  addBinding : ∀ text, ValidText text → ∀ state first after value mutable following,
    ValidState text state → ValidCursor text first → ValidCursor text after → ValidValue text value → ValidCursor text following → state.names.length < maxBindings →
    calls.function .addBinding state first after value mutable following =
      addBindingBody.eval evaluator (Context.locals {text,state,first,after,value,mutable,following})
  stringDeclaration : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state → calls.function .stringDeclaration text state arguments =
      stringDeclarationBody.eval evaluator (Context.locals {text,state,arguments})
  scalarConstraint : ∀ text, ValidText text → ∀ position scalarNames,
    ValidCursor text position → ScalarExpression.ValidEnvironment text scalarNames →
    calls.function .scalarConstraint text position scalarNames =
      scalarConstraintBody.eval evaluator (Context.locals {text,position,scalarNames})
  scalarDeclaration : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state → calls.function .scalarDeclaration text state arguments =
      scalarDeclarationBody.eval evaluator (Context.locals {text,state,arguments})
  declaration : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state →
    calls.function .declaration text state arguments =
      declarationBody.eval evaluator (Context.locals {text,state,arguments})
  argument : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    calls.function .argument text state =
      argumentBody.eval evaluator (Context.locals {text,state})
  declarations : ∀ text, ValidText text → ∀ state arguments,
    ValidState text state →
    calls.function .declarations text state arguments =
      declarationsBody.eval evaluator (Context.locals {text,state,arguments})
  expressionStep : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames → ValidScan text scan →
    calls.function .expressionStep text names scan scalarNames integerHidden =
      expressionStepBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,names,scan})
  tail : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames → ValidScan text scan →
    calls.function .tail text names scan scalarNames integerHidden =
      tailBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,names,scan})
  fits : ∀ text, ValidText text → ∀ result capacity,
    ValidResult text result → capacity ≤ maxSourceLength →
    calls.function .fits result capacity =
      fitsBody.eval evaluator (Context.locals {text,result,capacity})
  comparison : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    calls.function .comparison text state =
      comparisonBody.eval evaluator (Context.locals {text,state})
  expression : ∀ text, ValidText text → ∀ position names scalarNames integerHidden,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    calls.function .expression text position names scalarNames integerHidden =
      expressionBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,position,names})
  target : ∀ text, ValidText text → ∀ state sameTarget,
    ValidState text state →
    calls.function .target text state sameTarget =
      targetBody.eval evaluator (Context.locals {text,state,sameTarget})
  dynamic : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    calls.function .dynamic text state =
      dynamicBody.eval evaluator (Context.locals {text,state})
  assignmentValue : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    calls.function .assignmentValue text state =
      assignmentBody.eval evaluator (Context.locals {text,state})
  output : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    calls.function .output text state =
      outputBody.eval evaluator (Context.locals {text,state})
  capacity : ∀ text, ValidText text → ∀ state,
    ValidState text state →
    calls.function .capacity text state =
      capacityBody.eval evaluator (Context.locals {text,state})
  readDeclarations : ∀ text, ValidText text → ∀ state arguments, ValidState text state →
    calls.function .readDeclarations text state arguments = calls.function .declarations text state arguments

/-- The previous fixed-form model retains its own abstract equations. These
are not assertions about the current statement scanner. -/
structure DefinitionEquations (calls : Calls) (evaluator : Calls := lexical calls)
    : Prop extends HelperEquations calls evaluator where
  stepRange : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state →
    ValidState text (calls.function .step text form token state)
  step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state →
    calls.function .step text form token state =
      stepBody.eval evaluator (Context.locals {text,form,token,state})
  suffix : ∀ text, ValidText text → ∀ form nextToken state,
    ValidState text state → 1 ≤ nextToken → nextToken ≤ form.tokens.length + 1 →
    calls.function .suffix text form nextToken state =
      suffixBody.eval evaluator (Context.locals {text,form,nextToken,state})
  formMember : ∀ text form, calls.function .formMember text form =
    formBody.eval evaluator (Context.locals {text,form})
  member : ∀ text, calls.function .member text = memberBody.eval evaluator (Context.locals {text})
  arguments : ∀ text, calls.function .arguments text = argumentsBody.eval evaluator (Context.locals {text})
  assignment : ∀ text, calls.function .assignment text = assignmentSelectorBody.eval evaluator (Context.locals {text})

end Silver.Compose.Expressions
