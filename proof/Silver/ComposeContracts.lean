module

public import Silver.ComposeExpressions
public import Silver.ComposeArrayExpressions
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
    ScalarExpression.ValidEnvironment text state.scalarNames ∧
    ArrayBindings.ValidEnvironment text state.arrayNames ∧
    IntegerSubtypes.ValidEnvironment text state.subtypeNames ∧
    BooleanBindings.ValidEnvironment text state.booleanNames

/-- The state precondition actually provided by an interpreted native caller.
The base domain remains available for the independent mathematical model. -/
structure StateDomain where
  holds : Source → ParserState → Prop
  valid : ∀ text state, holds text state → ValidState text state
  /-- Array updates preserve the scalar declarations and String binding table.
  Additional native caller invariants may depend on either immutable table. -/
  transportScalar : ∀ text before after, holds text before → ValidState text after →
    after.scalarNames = before.scalarNames → after.names = before.names → holds text after

def StateDomain.basic : StateDomain where
  holds := ValidState
  valid := fun _ _ valid => valid
  transportScalar := fun _ _ _ _ valid _ _ => valid

/-- Native Valid_Names includes the exact String/Character metadata predicate.
The independent mathematical table-validity predicate remains unchanged. -/
structure NativeNames (text : Source) (names : BindingEnvironment) : Prop where
  base : ValidNames text names
  bounds : NamesBoundsValid names

/-- A native source state call carries the caller's chosen mathematical
domain and the exact String-table subtype invariant independently. -/
structure NativeState (domain : StateDomain) (text : Source) (state : ParserState) : Prop where
  base : domain.holds text state
  bounds : NamesBoundsValid state.names

theorem NativeState.valid {domain : StateDomain} {text state}
    (context : NativeState domain text state) : ValidState text state :=
  domain.valid text state context.base

theorem NativeState.nativeNames {domain : StateDomain} {text state}
    (context : NativeState domain text state) : NativeNames text state.names :=
  ⟨context.valid.2.1, context.bounds⟩

theorem NativeState.transportScalar {domain : StateDomain} {text before after}
    (context : NativeState domain text before) (valid : ValidState text after)
    (scalars : after.scalarNames = before.scalarNames) (names : after.names = before.names) :
    NativeState domain text after :=
  ⟨domain.transportScalar text before after context.base valid scalars names,
    names ▸ context.bounds⟩

/-- The complete Value_Result record domain, including the newly represented
operand subtype and both machine Integer interval fields. -/
structure NativeValue (text : Source) (value : ValueResult) : Prop where
  base : ValidValue text value
  operands : value.operands ≤ maxExpressionOperands
  firstIndex : value.firstIndex.Bounded
  lastIndex : value.lastIndex.Bounded

structure NativeResult (text : Source) (result : ExpressionResult) : Prop where
  base : ValidResult text result
  firstIndex : result.firstIndex.Bounded
  lastIndex : result.lastIndex.Bounded

structure NativeScan (text : Source) (scan : ExpressionState) : Prop where
  base : ValidScan text scan
  firstIndex : scan.firstIndex.Bounded
  lastIndex : scan.lastIndex.Bounded

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
   .word "integer", .word "for", .word "in", .word "reverse", .word "loop", .symbol "..", .word "range", .word "subtype", .word "array", .word "of", .symbol ",", .symbol "=>",
   .word "boolean", .word "true", .word "false", .word "xor"]

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
  booleans : BooleanBindings.Environment := []
  arrays : ArrayBindings.Metadata := []
  initials : ArrayBindings.Initials := []
  elaborating : Bool := false
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
  subtypeHidden : Bool := false
  subtypeNames : IntegerSubtypes.Environment := {}
  baseBounds : Integer.Interval := Integer.Interval.full

def Context.locals (ctx : Context) : Locals
  | .source, _ => ctx.text
  | .number, name => match name with
    | "position" => ctx.position | "first" => ctx.first | "after" => ctx.after
    | "index" => ctx.index | "length" => ctx.length | "remaining" => ctx.remaining
    | "following" => ctx.following | "next_token" => ctx.nextToken | "capacity" => ctx.capacity | _ => 0
  | .truth, name => match name with
    | "arguments" => ctx.arguments | "mutable" => ctx.mutable
    | "same_target" => ctx.sameTarget | "dynamic_seen" => ctx.dynamicSeen
    | "subtype_hidden" => ctx.subtypeHidden
    | "integer_hidden" => ctx.integerHidden | "elaborating" => ctx.elaborating | _ => false
  | .names, _ => ctx.names
  | .scalarNames, _ => ctx.scalarNames
  | .booleanNames, _ => ctx.booleans
  | .arrayMetadata, _ => ctx.arrays
  | .subtypeNames, _ => ctx.subtypeNames
  | .interval, "base_bounds" => ctx.baseBounds
  | .arrayInitials, _ => ctx.initials
  | .state, _ => ctx.state
  | .value, _ => ctx.value
  | .result, _ => ctx.result
  | .scan, _ => ctx.scan
  | .form, _ => ctx.form
  | .token, _ => ctx.token
  | .operation, _ => ctx.operation
  | ty, _ => ty.default

/-- The aggregate precondition retains the caller's complete state domain.
This requires native table validity, not the stronger source allocation layout. -/
structure ArrayValuesDomain (text : Source) (source result : ParserState)
    (position length parsed : Nat) (domain : StateDomain := .basic) : Prop where
  sourceContext : NativeState domain text source
  resultContext : NativeState domain text result
  positionValid : ValidCursor text position
  parsedBound : parsed ≤ length
  capacity : length ≤ ArrayBindings.maxElements - source.arrayNames.used
  used : result.arrayNames.used = source.arrayNames.used + parsed

theorem ArrayValuesDomain.sourceValid {domain : StateDomain}
    {text source result position length parsed}
    (context : ArrayValuesDomain text source result position length parsed domain) :
    ValidState text source := context.sourceContext.valid

theorem ArrayValuesDomain.resultValid {domain : StateDomain}
    {text source result position length parsed}
    (context : ArrayValuesDomain text source result position length parsed domain) :
    ValidState text result := context.resultContext.valid

/-- The native append precondition compares the new segment with the last
allocated descriptor; valid metadata already orders all earlier segments. -/
def ArrayAddDomain (names : ArrayBindings.Metadata) (offset : Nat) : Prop :=
  ∀ last, names.getLast? = some last → last.offset + last.length ≤ offset

def arrayPutLocals (state : ParserState) (value : Int) : Locals :=
  (Context.locals {state}).set .integer "value" value

def arrayAddLocals (text : Source) (state : ParserState) (first after : Nat)
    (bounds : Integer.Interval) (offset length : Nat) (mutable : Bool) (following : Nat)
    (componentBounds : Integer.Interval) : Locals :=
  ((Context.locals {text,state,first,after,length,mutable,following}).set .interval "bounds" bounds)
    |>.set .number "offset" offset
    |>.set .interval "component_bounds" componentBounds

/-- Source state and result accumulator are separate native arguments. -/
def arrayValuesLocals (text : Source) (source result : ParserState)
    (position length parsed : Nat) (componentBounds : Integer.Interval) : Locals :=
  ((Context.locals {text,position,length}).set .state "source_state" source).set .state "result_state" result
    |>.set .number "parsed" parsed
    |>.set .interval "component_bounds" componentBounds

/-- Consequences of the native subtype declarations and proved routine contracts.
Only result bounds/state preservation occur here, never admission correctness. -/
structure HelperRanges (calls : Calls) (domain : StateDomain := .basic) : Prop where
  skip : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    ValidCursor text (calls.function .skip text position)
  name : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    ValidCursor text (calls.function .nameAfter text position)
  token : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    ValidCursor text (calls.function .takeToken text position token)
  lookup : ∀ text, ValidText text → ∀ names first after,
    NativeNames text names → ValidCursor text first → ValidCursor text after →
    calls.function .lookupName text names first after ≤ names.length
  literal : ∀ text, ValidText text → ∀ position, ValidCursor text position →
    NativeValue text (calls.function .literal text position)
  image : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    NativeValue text (calls.function .image text position names scalarNames integerHidden arrays initials elaborating)
  value : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    NativeValue text (calls.function .value text position names scalarNames integerHidden arrays initials elaborating)
  stringDeclaration : ∀ text, ValidText text → ∀ state arguments, NativeState domain text state →
    NativeState domain text (calls.function .stringDeclaration text state arguments) ∧
      ((calls.function .stringDeclaration text state arguments).position = 0 ∨
        state.position < (calls.function .stringDeclaration text state arguments).position)
  subtypeDeclaration : ∀ text, ValidText text → ∀ state arguments, NativeState domain text state →
    NativeState domain text (calls.function .subtypeDeclaration text state arguments) ∧
      ((calls.function .subtypeDeclaration text state arguments).position = 0 ∨
        state.position < (calls.function .subtypeDeclaration text state arguments).position)
  scalarType : ∀ text, ValidText text → ∀ state position, NativeState domain text state →
    ValidCursor text position →
    ValidCursor text (calls.function .scalarType text state position).after ∧
      (calls.function .scalarType text state position).bounds.Bounded ∧
      ((calls.function .scalarType text state position).after ≠ 0 →
        (calls.function .scalarType text state position).bounds.lower ≤
          (calls.function .scalarType text state position).bounds.upper)
  scalarDeclaration : ∀ text, ValidText text → ∀ state arguments, NativeState domain text state →
    NativeState domain text (calls.function .scalarDeclaration text state arguments) ∧
      ((calls.function .scalarDeclaration text state arguments).position = 0 ∨
        state.position < (calls.function .scalarDeclaration text state arguments).position)
  arrayDeclaration : ∀ text, ValidText text → ∀ state arguments, NativeState domain text state →
    NativeState domain text (calls.function .arrayDeclaration text state arguments) ∧
      ((calls.function .arrayDeclaration text state arguments).position = 0 ∨
        state.position < (calls.function .arrayDeclaration text state arguments).position)
  declaration : ∀ text, ValidText text → ∀ state arguments, NativeState domain text state →
    NativeState domain text (calls.function .declaration text state arguments) ∧
      ((calls.function .declaration text state arguments).position = 0 ∨
        state.position < (calls.function .declaration text state arguments).position)
  argument : ∀ text, ValidText text → ∀ state, NativeState domain text state →
    NativeState domain text (calls.function .argument text state)
  declarations : ∀ text, ValidText text → ∀ state arguments, NativeState domain text state →
    NativeState domain text (calls.function .declarations text state arguments)
  expressionStep : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden arrays initials elaborating,
    NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → NativeScan text scan →
    NativeScan text (calls.function .expressionStep text names scan scalarNames integerHidden arrays initials elaborating) ∧
      ((calls.function .expressionStep text names scan scalarNames integerHidden arrays initials elaborating).position = 0 ∨
       (calls.function .expressionStep text names scan scalarNames integerHidden arrays initials elaborating).complete = true ∨
       scan.position < (calls.function .expressionStep text names scan scalarNames integerHidden arrays initials elaborating).position)
  expression : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    NativeResult text (calls.function .expression text position names scalarNames integerHidden arrays initials elaborating)

structure RangeContracts (calls : Calls) : Prop extends HelperRanges calls where
  step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → NativeState .basic text state →
    NativeState .basic text (calls.function .step text form token state)

/-- Equations of checked expression bodies or exact executable-refinement
postconditions. The evaluator's primitive meanings may be normalized later. -/
structure RawHelperEquations (calls : Calls) (evaluator : Calls := lexical calls)
    (domain : StateDomain := .basic) : Prop where
  ranges : HelperRanges calls domain
  names : Names.InterpretedSource calls.names
  scalarLookup : ∀ text, ValidText text → ∀ names first after,
    ScalarExpression.ValidEnvironment text names → ValidCursor text first → ValidCursor text after →
    calls.function .scalarLookup text names first after = ScalarExpression.lookup text names first after
  scalarRead : ∀ text, ValidText text → ∀ position names arrays initials elaborating,
    ValidCursor text position → ScalarExpression.ValidEnvironment text names →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    calls.function .scalarRead text position names arrays initials elaborating =
      ScalarExpression.read text position names 0 0 true arrays initials elaborating
  booleanHidesInteger : ∀ text, ValidText text → ∀ booleans,
    BooleanBindings.ValidEnvironment text booleans →
    calls.function .booleanHidesInteger text booleans = BooleanBindings.hidesInteger text booleans
  booleanLookup : ∀ text, ValidText text → ∀ booleans first after,
    BooleanBindings.ValidEnvironment text booleans → ValidCursor text first → ValidCursor text after →
    calls.function .booleanLookup text booleans first after = BooleanBindings.lookup text booleans first after
  arrayLookup : ∀ text, ValidText text → ∀ arrays first after,
    ArrayBindings.ValidMetadata text arrays → ValidCursor text first → ValidCursor text after →
    calls.function .arrayLookup text arrays first after = ArrayBindings.lookup text arrays first after
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
  callAfter : ∀ text, ValidText text → ∀ names position operation scalarNames arrays subtypeHidden booleans,
    NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → BooleanBindings.ValidEnvironment text booleans → ValidCursor text position →
    calls.function .callAfter text names position operation scalarNames arrays subtypeHidden booleans =
      callAfterBody.eval evaluator (Context.locals {text,scalarNames,arrays,names,position,operation,subtypeHidden,booleans})
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
    NativeNames text names → ValidName text first after → 1 ≤ index → index ≤ names.length + 1 →
    calls.function .lookupFrom text names first after index =
      lookupFromBody.eval evaluator (Context.locals {text,names,first,after,index})
  lookup : ∀ text, ValidText text → ∀ names first after,
    NativeNames text names → ValidCursor text first → ValidCursor text after →
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
  image : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    calls.function .image text position names scalarNames integerHidden arrays initials elaborating =
      imageBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names})
  value : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    calls.function .value text position names scalarNames integerHidden arrays initials elaborating =
      valueBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names})
  newName : ∀ text, ValidText text → ∀ state first after arguments,
    NativeState domain text state → ValidCursor text first → ValidCursor text after →
    calls.function .newName text state first after arguments =
      newNameBody.eval evaluator (Context.locals {text,state,first,after,arguments})
  addBinding : ∀ text, ValidText text → ∀ state first after value mutable following,
    NativeState domain text state → ValidCursor text first → ValidCursor text after → NativeValue text value → ValidCursor text following → state.names.length < maxBindings →
    calls.function .addBinding state first after value mutable following =
      addBindingBody.eval evaluator (Context.locals {text,state,first,after,value,mutable,following})
  stringDeclaration : ∀ text, ValidText text → ∀ state arguments,
    NativeState domain text state → calls.function .stringDeclaration text state arguments =
      stringDeclarationBody.eval evaluator (Context.locals {text,state,arguments})
  scalarConstraint : ∀ text, ValidText text → ∀ position scalarNames baseBounds,
    ValidCursor text position → ScalarExpression.ValidEnvironment text scalarNames → baseBounds.Bounded →
    calls.function .scalarConstraint text position scalarNames baseBounds =
      scalarConstraintBody.eval evaluator (Context.locals {text,position,scalarNames,baseBounds})
  subtypeLookupModel : ∀ text, ValidText text → ∀ subtypeNames first after index,
    IntegerSubtypes.ValidEnvironment text subtypeNames → ValidCursor text first → ValidCursor text after →
    index ≤ subtypeNames.items.length →
    calls.function .subtypeLookupModel text subtypeNames first after index =
      subtypeLookupModelBody.eval evaluator (Context.locals {text,subtypeNames,first,after,index})
  subtypeLookup : ∀ text, ValidText text → ∀ subtypeNames first after,
    IntegerSubtypes.ValidEnvironment text subtypeNames → ValidCursor text first → ValidCursor text after →
    calls.function .subtypeLookup text subtypeNames first after =
      calls.function .subtypeLookupModel text subtypeNames first after subtypeNames.items.length
  scalarType : ∀ text, ValidText text → ∀ state position,
    NativeState domain text state → ValidCursor text position →
    calls.function .scalarType text state position =
      scalarTypeBody.eval evaluator (Context.locals {text,state,position})
  subtypeDeclaration : ∀ text, ValidText text → ∀ state arguments,
    NativeState domain text state → calls.function .subtypeDeclaration text state arguments =
      subtypeDeclarationBody.eval evaluator (Context.locals {text,state,arguments})
  scalarDeclaration : ∀ text, ValidText text → ∀ state arguments,
    NativeState domain text state → calls.function .scalarDeclaration text state arguments =
      scalarDeclarationBody.eval evaluator (Context.locals {text,state,arguments})
  arrayAdd : ∀ text, ValidText text → ∀ state first after bounds offset length mutable following componentBounds,
    NativeState domain text state → ValidName text first after →
    ArrayBindings.ValidBinding ⟨first, after, bounds, offset, length, mutable, componentBounds⟩ →
    state.arrayNames.names.length < ArrayBindings.maxBindings →
    offset + length ≤ state.arrayNames.used → ArrayAddDomain state.arrayNames.names offset →
    ValidCursor text following →
    calls.function .arrayAdd text state first after bounds offset length mutable following componentBounds =
      arrayAddBody.eval evaluator (arrayAddLocals text state first after bounds offset length mutable following componentBounds)
  arrayPut : ∀ state value, state.arrayNames.used < ArrayBindings.maxElements →
    Integer.InRange value →
    calls.function .arrayPut state value = arrayPutBody.eval evaluator (arrayPutLocals state value)
  arrayValuesModel : ∀ text, ValidText text → ∀ source result position length parsed componentBounds,
    componentBounds.Bounded → ArrayValuesDomain text source result position length parsed domain →
    calls.function .arrayValuesModel text source result position length parsed componentBounds =
      arrayValuesModelBody.eval evaluator (arrayValuesLocals text source result position length parsed componentBounds)
  arrayValues : ∀ text, ValidText text → ∀ source result position length parsed componentBounds,
    componentBounds.Bounded → ArrayValuesDomain text source result position length parsed domain →
    calls.function .arrayValues text source result position length parsed componentBounds =
      calls.function .arrayValuesModel text source result position length parsed componentBounds
  arrayDeclaration : ∀ text, ValidText text → ∀ state arguments,
    NativeState domain text state →
    calls.function .arrayDeclaration text state arguments =
      (arrayDeclarationBody true).eval evaluator (Context.locals {text,state,arguments})
  declaration : ∀ text, ValidText text → ∀ state arguments,
    NativeState domain text state →
    calls.function .declaration text state arguments =
      declarationBody.eval evaluator (Context.locals {text,state,arguments})
  argument : ∀ text, ValidText text → ∀ state,
    NativeState domain text state →
    calls.function .argument text state =
      argumentBody.eval evaluator (Context.locals {text,state})
  declarations : ∀ text, ValidText text → ∀ state arguments,
    NativeState domain text state →
    calls.function .declarations text state arguments =
      declarationsBody.eval evaluator (Context.locals {text,state,arguments})
  expressionStep : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden arrays initials elaborating,
    NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → NativeScan text scan →
    calls.function .expressionStep text names scan scalarNames integerHidden arrays initials elaborating =
      expressionStepBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,names,scan})
  tail : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden arrays initials elaborating,
    NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → NativeScan text scan →
    calls.function .tail text names scan scalarNames integerHidden arrays initials elaborating =
      tailBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,names,scan})
  fits : ∀ text, ValidText text → ∀ result capacity,
    NativeResult text result → capacity ≤ maxSourceLength →
    calls.function .fits result capacity =
      fitsBody.eval evaluator (Context.locals {text,result,capacity})
  comparison : ∀ text, ValidText text → ∀ state,
    NativeState domain text state →
    calls.function .comparison text state =
      comparisonBody.eval evaluator (Context.locals {text,state})
  expression : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    calls.function .expression text position names scalarNames integerHidden arrays initials elaborating =
      expressionBody.eval evaluator (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names})
  target : ∀ text, ValidText text → ∀ state sameTarget,
    NativeState domain text state →
    calls.function .target text state sameTarget =
      targetBody.eval evaluator (Context.locals {text,state,sameTarget})
  dynamic : ∀ text, ValidText text → ∀ state,
    NativeState domain text state →
    calls.function .dynamic text state =
      dynamicBody.eval evaluator (Context.locals {text,state})
  assignmentValue : ∀ text, ValidText text → ∀ state,
    NativeState domain text state →
    calls.function .assignmentValue text state =
      assignmentBody.eval evaluator (Context.locals {text,state})
  output : ∀ text, ValidText text → ∀ state,
    NativeState domain text state →
    calls.function .output text state =
      outputBody.eval evaluator (Context.locals {text,state})
  capacity : ∀ text, ValidText text → ∀ state,
    NativeState domain text state →
    calls.function .capacity text state =
      capacityBody.eval evaluator (Context.locals {text,state})
  readDeclarations : ∀ text, ValidText text → ∀ state arguments, NativeState domain text state →
    calls.function .readDeclarations text state arguments = calls.function .declarations text state arguments

/-- Complete helper laws. The Boolean declaration law is derived separately
from its typed native body and the interpreted condition reader; it is not a
primitive assumption of the actual-source bridge. -/
structure HelperEquations (calls : Calls) (evaluator : Calls := lexical calls)
    (domain : StateDomain := .basic) : Prop extends RawHelperEquations calls evaluator domain where
  /-- Discharged by the downstream Boolean-declaration source bridge, which
  interprets the native condition reader on the full initializer domain. -/
  booleanDeclaration : ∀ text, ValidText text → ∀ state arguments,
    NativeState domain text state → calls.function .booleanDeclaration text state arguments = booleanDeclarationAt text state arguments

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
