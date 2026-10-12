module

public import Silver.ComposeExpressions

@[expose] public section

/-! Interpret the recognizer's checked equations on its verified machine
 domains. Executable loop refinements supply equations for the same terminating
 traversals; no premise identifies the recognizer with language membership. -/

namespace Silver.Compose.Expressions
open Named

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ maxSourceLength

def ValidCursor (text : Source) (position : Nat) : Prop := position ≤ text.length + 1

def ValidName (text : Source) (first after : Nat) : Prop :=
  0 < first ∧ first < after ∧ after ≤ text.length + 1

def ValidInfo (text : Source) (info : BindingInfo) : Prop :=
  ValidName text info.first info.after ∧ info.valueFirst ≤ text.length + 1 ∧
    info.staticLength ≤ maxSourceLength

def ValidNames (text : Source) (names : BindingEnvironment) : Prop :=
  names.length ≤ maxBindings ∧ ∀ info ∈ names, ValidInfo text info

def ValidState (text : Source) (state : ParserState) : Prop :=
  ValidCursor text state.position ∧ ValidNames text state.names ∧
    (⟨state.dynamicFirst,state.dynamicAfter⟩ : NameState).Valid text ∧
    state.target ≤ state.names.length ∧ state.capacity ≤ maxSourceLength

def ValidValue (text : Source) (value : ValueResult) : Prop :=
  value.after ≤ text.length + 1 ∧ value.valueFirst ≤ text.length + 1 ∧
    value.staticLength ≤ maxSourceLength ∧ value.reference ≤ maxBindings

def allTokens : List ShellToken :=
  [.word "with", .word "silver_io", .word "procedure", .word "main", .word "is",
   .word "pragma", .word "spark_mode", .word "on", .word "begin", .word "put_line", .word "end",
   .symbol "(", .symbol ")", .symbol ";", .symbol ".", .literal, .symbol ":", .word "constant",
   .word "string", .symbol ":=", .word "silver_arguments", .word "first_or_default", .word "if",
   .word "input_is_valid", .word "then", .word "else", .word "reject", .symbol "&", .word "and",
   .symbol "'", .word "length", .symbol "<=", .capacity, .symbol "=", .argumentDeclaration,
   .declarations, .assignmentTarget, .targetReference, .dynamicReference, .assignmentValue,
   .outputExpression]

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
  state : ParserState := initialState
  value : ValueResult := invalidValue
  form : Form := .direct
  token : ShellToken := .symbol ";"
  arguments : Bool := false
  mutable : Bool := false
  sameTarget : Bool := false
  dynamicSeen : Bool := false

def Context.locals (ctx : Context) : Locals
  | .source, _ => ctx.text
  | .number, name => match name with
    | "position" => ctx.position | "first" => ctx.first | "after" => ctx.after
    | "index" => ctx.index | "length" => ctx.length | "remaining" => ctx.remaining
    | "following" => ctx.following | "next_token" => ctx.nextToken | _ => 0
  | .truth, name => match name with
    | "arguments" => ctx.arguments | "mutable" => ctx.mutable
    | "same_target" => ctx.sameTarget | "dynamic_seen" => ctx.dynamicSeen | _ => false
  | .names, _ => ctx.names
  | .state, _ => ctx.state
  | .value, _ => ctx.value
  | .form, _ => ctx.form
  | .token, _ => ctx.token
  | ty, _ => ty.default

/-- Consequences of the native subtype declarations and proved routine contracts.
Only result bounds/state preservation occur here, never admission correctness. -/
structure RangeContracts (calls : Calls) : Prop where
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
  value : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ValidNames text names →
    ValidValue text (calls.function .value text position names)
  declaration : ∀ text, ValidText text → ∀ state arguments, ValidState text state →
    ValidState text (calls.function .declaration text state arguments) ∧
      ((calls.function .declaration text state arguments).position = 0 ∨
        state.position < (calls.function .declaration text state arguments).position)
  argument : ∀ text, ValidText text → ∀ state, ValidState text state →
    ValidState text (calls.function .argument text state)
  declarations : ∀ text, ValidText text → ∀ state arguments, ValidState text state →
    ValidState text (calls.function .declarations text state arguments)
  operand : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ValidNames text names →
    ValidCursor text (calls.function .operand text position names).after ∧
      (calls.function .operand text position names).staticLength ≤ maxSourceLength
  expression : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ValidNames text names →
    ValidCursor text (calls.function .expression text position names).after
  step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state →
    ValidState text (calls.function .step text form token state)

/-- Equations of checked expression bodies or exact executable-refinement
postconditions. The evaluator's primitive meanings may be normalized later. -/
structure DefinitionEquations (calls : Calls) (evaluator : Calls := lexical calls) : Prop where
  ranges : RangeContracts calls
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
  value : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ValidNames text names →
    calls.function .value text position names =
      valueBody.eval evaluator (Context.locals {text,position,names})
  newName : ∀ text, ValidText text → ∀ state first after arguments,
    ValidState text state → ValidCursor text first → ValidCursor text after →
    calls.function .newName text state first after arguments =
      newNameBody.eval evaluator (Context.locals {text,state,first,after,arguments})
  addBinding : ∀ text, ValidText text → ∀ state first after value mutable following,
    ValidState text state → ValidCursor text first → ValidCursor text after → ValidValue text value → ValidCursor text following → state.names.length < maxBindings →
    calls.function .addBinding state first after value mutable following =
      addBindingBody.eval evaluator (Context.locals {text,state,first,after,value,mutable,following})
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
  operand : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ValidNames text names →
    calls.function .operand text position names =
      operandBody.eval evaluator (Context.locals {text,position,names})
  tail : ∀ text, ValidText text → ∀ position names length dynamicSeen remaining,
    ValidCursor text position → ValidNames text names → length ≤ maxSourceLength → remaining ≤ maxExpressionOperands →
    calls.function .tail text position names length dynamicSeen remaining =
      tailBody.eval evaluator (Context.locals {text,position,names,length,dynamicSeen,remaining})
  expression : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ValidNames text names →
    calls.function .expression text position names =
      expressionBody.eval evaluator (Context.locals {text,position,names})
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
  step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state →
    calls.function .step text form token state =
      stepBody.eval evaluator (Context.locals {text,form,token,state})
  suffix : ∀ text, ValidText text → ∀ form nextToken state,
    ValidState text state → 1 ≤ nextToken → nextToken ≤ form.tokens.length + 1 →
    calls.function .suffix text form nextToken state =
      suffixBody.eval evaluator (Context.locals {text,form,nextToken,state})
  readDeclarations : ∀ text, ValidText text → ∀ state arguments, ValidState text state →
    calls.function .readDeclarations text state arguments = calls.function .declarations text state arguments
  formMember : ∀ text form, calls.function .formMember text form =
    formBody.eval evaluator (Context.locals {text,form})
  member : ∀ text, calls.function .member text = memberBody.eval evaluator (Context.locals {text})
  arguments : ∀ text, calls.function .arguments text = argumentsBody.eval evaluator (Context.locals {text})
  assignment : ∀ text, calls.function .assignment text = assignmentSelectorBody.eval evaluator (Context.locals {text})

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

@[simp] theorem interpreted_skip (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .skip text position = skipAt text position := by
  rw [equations.skip text valid position bound]
  simp [skipBody, Expr.eval, Context.locals, lexical, modelPrimitives, skipAt]

@[simp] theorem interpreted_name (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .nameAfter text position = nameAfter text position := by
  rw [equations.name text valid position bound]
  simp [nameBody, Expr.eval, Context.locals, lexical, modelPrimitives, nameAfter]

@[simp] theorem interpreted_fixed (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (token : ShellToken)
    (bound : ValidCursor text position) (tokenValid : ValidToken token) :
    calls.function .fixedAfter text position token = fixedAfter text position (spelling token) (isWord token) := by
  rw [equations.fixed text valid position token bound tokenValid]
  simp [fixedBody, Expr.eval, Context.locals, lexical, modelPrimitives, fixedAfter]

@[simp] theorem interpreted_take (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (token : ShellToken)
    (bound : ValidCursor text position) (tokenValid : ValidToken token) :
    calls.function .takeToken text position token = fixedAfter text position (spelling token) (isWord token) := by
  rw [equations.take text valid position token bound tokenValid]
  simp [fixedBody, Expr.eval, Context.locals, lexical, modelPrimitives, fixedAfter]

@[simp] theorem interpreted_literal (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : ValidCursor text position) :
    calls.function .literal text position = literalAt text position := by
  rw [equations.literal text valid position bound]
  simp [literalBody, Expr.eval, Context.locals, lexical, modelPrimitives, literalAt, Bool.and_eq_true,
    and_assoc]

@[simp] theorem interpreted_lookupFrom (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (first after index : Nat)
    (namesValid : ValidNames text names) (nameValid : ValidName text first after)
    (positive : 1 ≤ index) (bounded : index ≤ names.length + 1) :
    calls.function .lookupFrom text names first after index = lookupFrom text names first after index := by
  rw [equations.lookupFrom text valid names first after index namesValid nameValid positive bounded,
    lookupFrom_equation text names first after index (by omega)]
  simp only [lookupFromBody, Expr.eval, Context.locals, lexical, modelPrimitives, Calls.get, Field.get,
    decide_eq_true_eq]
  split
  · rfl
  · rename_i within
    have nextBound : index + 1 ≤ names.length + 1 := Nat.add_le_add_right (Nat.le_of_not_gt within) 1
    split
    · rfl
    · exact interpreted_lookupFrom calls equations text valid names first after (index + 1)
        namesValid nameValid (by omega) nextBound
termination_by names.length + 1 - index
decreasing_by omega

@[simp] theorem interpreted_lookup (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (names : BindingEnvironment) (first after : Nat)
    (namesValid : ValidNames text names) (firstValid : ValidCursor text first) (afterValid : ValidCursor text after) :
    calls.function .lookupName text names first after = lookupName text names first after := by
  rw [equations.lookup text valid names first after namesValid firstValid afterValid]
  simp only [lookupBody, Expr.eval, Context.locals, lexical, Calls.get, lookupName,
    Bool.or_eq_true, decide_eq_true_eq]
  split
  · rfl
  · rename_i outside
    have firstPositive : 0 < first := Nat.pos_of_ne_zero (fun zero => outside (Or.inl zero))
    have afterGreater : first < after := Nat.lt_of_not_ge (fun low => outside (Or.inr low))
    apply interpreted_lookupFrom calls equations text valid names first after 1 namesValid
        (by exact ⟨firstPositive, afterGreater, afterValid⟩) (by omega) (by omega)

@[simp] theorem interpreted_value (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment)
    (bound : ValidCursor text position) (namesValid : ValidNames text names) :
    calls.function .value text position names = valueAt text position names := by
  have skipBound := equations.ranges.skip text valid position bound
  have nameBound := equations.ranges.name text valid _ skipBound
  have skipEq := interpreted_skip calls equations text valid position bound
  have nameEq := interpreted_name calls equations text valid _ skipBound
  have literalEq := interpreted_literal calls equations text valid _ skipBound
  have lookupEq := interpreted_lookup calls equations text valid names _ _ namesValid skipBound nameBound
  rw [equations.value text valid position names bound namesValid]
  simp only [valueBody, Expr.eval, Context.locals, Locals.set, reduceCtorEq, String.reduceEq, lexical, Calls.get,
    Field.get, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq]
  rw [literalEq, lookupEq, nameEq, skipEq]
  rfl

@[simp] theorem interpreted_newName (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (first after : Nat) (arguments : Bool)
    (stateValid : ValidState text state) (firstValid : ValidCursor text first) (afterValid : ValidCursor text after) :
    calls.function .newName text state first after arguments = newNameAllowed text state first after arguments := by
  rw [equations.newName text valid state first after arguments stateValid firstValid afterValid]
  simp [newNameBody, Expr.eval, Context.locals, lexical, modelPrimitives, Calls.get, Field.get,
    interpreted_lookup calls equations text valid state.names first after stateValid.2.1 firstValid afterValid,
    newNameAllowed, Bool.and_assoc]

@[simp] theorem interpreted_addBinding (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (first after : Nat) (value : ValueResult)
    (mutable : Bool) (following : Nat) (stateValid : ValidState text state)
    (firstValid : ValidCursor text first) (afterValid : ValidCursor text after)
    (valueValid : ValidValue text value) (followingValid : ValidCursor text following)
    (room : state.names.length < maxBindings) :
    calls.function .addBinding state first after value mutable following = addBinding state first after value mutable following := by
  rw [equations.addBinding text valid state first after value mutable following stateValid firstValid afterValid valueValid followingValid room]
  rfl

private theorem decideIf {α : Type} (p : Prop) [Decidable p] (yes no : α) :
    (if decide p then yes else no) = (if p then yes else no) := by simp

private theorem declarationGate {α : Type} (a : Bool) (b c : Prop) [Decidable b] [Decidable c]
    (yes no : α) :
    (if (a = false ∨ b) ∨ c then yes else no) =
      (if !a || decide (b ∨ c) then yes else no) := by
  cases a <;> simp

@[simp] theorem interpreted_declaration (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) :
    calls.function .declaration text state arguments = declarationAt text state arguments := by
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  let colon := calls.function .takeToken text after (.symbol ":")
  let constant := calls.function .takeToken text colon (.word "constant")
  let typeAfter := calls.function .takeToken text (if constant ≠ 0 then constant else colon) (.word "string")
  let valuePosition := calls.function .takeToken text typeAfter (.symbol ":=")
  let value := calls.function .value text valuePosition state.names
  let following := calls.function .takeToken text value.after (.symbol ";")
  have bfirst : ValidCursor text first := equations.ranges.skip text valid _ stateValid.1
  have bafter : ValidCursor text after := equations.ranges.name text valid _ bfirst
  have bcolon : ValidCursor text colon := equations.ranges.token text valid _ _ bafter (by unfold ValidToken; decide)
  have bconstant : ValidCursor text constant := equations.ranges.token text valid _ _ bcolon (by unfold ValidToken; decide)
  have btype : ValidCursor text typeAfter := equations.ranges.token text valid _ _
    (by split <;> assumption) (by unfold ValidToken; decide)
  have bposition : ValidCursor text valuePosition := equations.ranges.token text valid _ _ btype (by unfold ValidToken; decide)
  have bvalue : ValidValue text value := equations.ranges.value text valid _ _ bposition stateValid.2.1
  have bfollowing : ValidCursor text following := equations.ranges.token text valid _ _ bvalue.1 (by unfold ValidToken; decide)
  have efirst : first = declarationFirst text state := interpreted_skip calls equations text valid _ stateValid.1
  have eafter : after = nameAfter text first := interpreted_name calls equations text valid _ bfirst
  have ecolon : colon = fixedAfter text after ":" false := interpreted_take calls equations text valid _ _ bafter (by unfold ValidToken; decide)
  have econstant : constant = fixedAfter text colon "constant" true := interpreted_take calls equations text valid _ _ bcolon (by unfold ValidToken; decide)
  have etype : typeAfter = fixedAfter text (if constant ≠ 0 then constant else colon) "string" true :=
    interpreted_take calls equations text valid _ _ (by split <;> assumption) (by unfold ValidToken; decide)
  have eposition : valuePosition = fixedAfter text typeAfter ":=" false :=
    interpreted_take calls equations text valid _ _ btype (by unfold ValidToken; decide)
  have evalue : value = valueAt text valuePosition state.names := interpreted_value calls equations text valid _ _ bposition stateValid.2.1
  have efollowing : following = fixedAfter text value.after ";" false :=
    interpreted_take calls equations text valid _ _ bvalue.1 (by unfold ValidToken; decide)
  have ename := interpreted_newName calls equations text valid state first after arguments stateValid bfirst bafter
  rw [equations.declaration text valid state arguments stateValid]
  simp only [declarationBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get,
    reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq, Bool.or_eq_true, Bool.not_eq_true']
  change (if (calls.function .newName text state first after arguments = false ∨ following = 0) ∨
    state.names.length = maxBindings then invalidState
    else calls.function .addBinding state first after value (decide (constant = 0)) following) = _
  by_cases full : state.names.length = maxBindings
  · simp [full, declarationAt]
  · have room : state.names.length < maxBindings := by have := stateValid.2.1.1; omega
    rw [interpreted_addBinding calls equations text valid state first after value _ following
      stateValid bfirst bafter bvalue bfollowing room, ename]
    have modelFirst : declarationFirst text state = first := efirst.symm
    have modelAfter : declarationAfter text state = after := by
      unfold declarationAfter
      rw [modelFirst]
      exact eafter.symm
    have modelColon : declarationColonAfter text state = colon := by
      unfold declarationColonAfter
      rw [modelAfter]
      exact ecolon.symm
    have modelConstant : declarationConstantAfter text state = constant := by
      unfold declarationConstantAfter
      rw [modelColon]
      exact econstant.symm
    have modelPosition : declarationValuePosition text state = valuePosition := by
      unfold declarationValuePosition
      rw [modelConstant, modelColon, ← etype]
      exact eposition.symm
    have parts : declarationParts text state = ⟨first, after, constant, value, following⟩ := by
      simp only [declarationParts, modelFirst, modelAfter, modelConstant, modelPosition, ← evalue, ← efollowing]
    rw [declarationAt, parts]
    exact declarationGate (newNameAllowed text state first after arguments)
      (following = 0) (state.names.length = maxBindings) invalidState
      (addBinding state first after value (decide (constant = 0)) following)

@[simp] theorem interpreted_argument (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .argument text state = argumentAt text state := by
  let first := calls.function .skip text state.position
  let after := calls.function .nameAfter text first
  have bfirst : ValidCursor text first := equations.ranges.skip text valid _ stateValid.1
  have bafter : ValidCursor text after := equations.ranges.name text valid _ bfirst
  have efirst : first = skipAt text state.position := interpreted_skip calls equations text valid _ stateValid.1
  have eafter : after = nameAfter text first := interpreted_name calls equations text valid _ bfirst
  let p0 := calls.function .takeToken text after (.symbol ":")
  have bp0 : ValidCursor text p0 := equations.ranges.token text valid _ _ bafter (by unfold ValidToken; decide)
  have ep0 : p0 = fixedAfter text after ":" false :=
    interpreted_take calls equations text valid _ _ bafter (by unfold ValidToken; decide)
  let p1 := calls.function .takeToken text p0 (.word "constant")
  have bp1 : ValidCursor text p1 := equations.ranges.token text valid _ _ bp0 (by unfold ValidToken; decide)
  have ep1 : p1 = fixedAfter text p0 "constant" true :=
    interpreted_take calls equations text valid _ _ bp0 (by unfold ValidToken; decide)
  let p2 := calls.function .takeToken text p1 (.word "string")
  have bp2 : ValidCursor text p2 := equations.ranges.token text valid _ _ bp1 (by unfold ValidToken; decide)
  have ep2 : p2 = fixedAfter text p1 "string" true :=
    interpreted_take calls equations text valid _ _ bp1 (by unfold ValidToken; decide)
  let p3 := calls.function .takeToken text p2 (.symbol ":=")
  have bp3 : ValidCursor text p3 := equations.ranges.token text valid _ _ bp2 (by unfold ValidToken; decide)
  have ep3 : p3 = fixedAfter text p2 ":=" false :=
    interpreted_take calls equations text valid _ _ bp2 (by unfold ValidToken; decide)
  let p4 := calls.function .takeToken text p3 (.word "silver_arguments")
  have bp4 : ValidCursor text p4 := equations.ranges.token text valid _ _ bp3 (by unfold ValidToken; decide)
  have ep4 : p4 = fixedAfter text p3 "silver_arguments" true :=
    interpreted_take calls equations text valid _ _ bp3 (by unfold ValidToken; decide)
  let p5 := calls.function .takeToken text p4 (.symbol ".")
  have bp5 : ValidCursor text p5 := equations.ranges.token text valid _ _ bp4 (by unfold ValidToken; decide)
  have ep5 : p5 = fixedAfter text p4 "." false :=
    interpreted_take calls equations text valid _ _ bp4 (by unfold ValidToken; decide)
  let p6 := calls.function .takeToken text p5 (.word "first_or_default")
  have bp6 : ValidCursor text p6 := equations.ranges.token text valid _ _ bp5 (by unfold ValidToken; decide)
  have ep6 : p6 = fixedAfter text p5 "first_or_default" true :=
    interpreted_take calls equations text valid _ _ bp5 (by unfold ValidToken; decide)
  let p7 := calls.function .takeToken text p6 (.symbol "(")
  have bp7 : ValidCursor text p7 := equations.ranges.token text valid _ _ bp6 (by unfold ValidToken; decide)
  have ep7 : p7 = fixedAfter text p6 "(" false :=
    interpreted_take calls equations text valid _ _ bp6 (by unfold ValidToken; decide)
  let defaultPosition := calls.function .skip text p7
  let fallback := calls.function .literal text defaultPosition
  let close := calls.function .takeToken text fallback.after (.symbol ")")
  let following := calls.function .takeToken text close (.symbol ";")
  have bdefault : ValidCursor text defaultPosition := equations.ranges.skip text valid _ bp7
  have bfallback : ValidValue text fallback := equations.ranges.literal text valid _ bdefault
  have bclose : ValidCursor text close := equations.ranges.token text valid _ _ bfallback.1 (by unfold ValidToken; decide)
  have bfollowing : ValidCursor text following := equations.ranges.token text valid _ _ bclose (by unfold ValidToken; decide)
  have edefault : defaultPosition = skipAt text p7 := interpreted_skip calls equations text valid _ bp7
  have efallback : fallback = literalAt text defaultPosition := interpreted_literal calls equations text valid _ bdefault
  have eclose : close = fixedAfter text fallback.after ")" false := interpreted_take calls equations text valid _ _ bfallback.1 (by unfold ValidToken; decide)
  have efollowing : following = fixedAfter text close ";" false := interpreted_take calls equations text valid _ _ bclose (by unfold ValidToken; decide)
  have ename := interpreted_newName calls equations text valid state first after true stateValid bfirst bafter
  rw [equations.argument text valid state stateValid]
  dsimp only [argumentBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get]
  change (if !calls.function .newName text state first after true || decide (following = 0) ||
    decide (state.names.length ≠ 0) then invalidState
    else {calls.function .addBinding state first after ⟨following, 0, 0, true, 0⟩ false following with
      dynamicFirst := first, dynamicAfter := after}) = _
  by_cases empty : state.names.length = 0
  · have room : state.names.length < maxBindings := by simp [empty, maxBindings, maxSourceLength]
    have bvalue : ValidValue text ⟨following, 0, 0, true, 0⟩ := ⟨bfollowing, Nat.zero_le _, Nat.zero_le _, Nat.zero_le _⟩
    rw [interpreted_addBinding calls equations text valid state first after _ false following
      stateValid bfirst bafter bvalue bfollowing room, ename]
    simp only [efollowing, eclose, efallback, edefault, ep7, ep6, ep5, ep4, ep3, ep2, ep1, ep0, eafter, efirst]
    simp [argumentAt, argumentParts, argumentFirst, argumentAfter, argumentDefaultPosition,
      tokenAfter, ShellToken.word, ShellToken.symbol, empty]
  · simp [empty, argumentAt]

@[simp] theorem interpreted_declarations (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) :
    calls.function .declarations text state arguments = declarationsAt text state arguments := by
  have etoken := interpreted_take calls equations text valid state.position (.word "begin") stateValid.1
    (by unfold ValidToken; decide)
  simp only [ShellToken.word, spelling, isWord] at etoken
  have edeclaration := interpreted_declaration calls equations text valid state arguments stateValid
  have nextValid : ValidState text (declarationAt text state arguments) := by
    rw [← edeclaration]
    exact (equations.ranges.declaration text valid state arguments stateValid).1
  rw [equations.declarations text valid state arguments stateValid]
  simp only [declarationsBody, Expr.eval, Context.locals, lexical, Calls.get, Field.get,
    decide_eq_true_eq]
  change (if decide (state.position = 0) then invalidState
    else if decide (calls.function .takeToken text state.position (.word "begin") ≠ 0) then state
    else if (calls.function .declaration text state arguments).position = 0 then invalidState
    else calls.function .declarations text (calls.function .declaration text state arguments) arguments) = _
  rw [decideIf, decideIf]
  simp only [ShellToken.word, etoken, edeclaration]
  rw [declarationsAt_equation text state arguments stateValid.2.1.1]
  split
  · rfl
  · split
    · rfl
    · split
      · rfl
      · exact interpreted_declarations calls equations text valid (declarationAt text state arguments)
          arguments nextValid
termination_by maxBindings + 1 - state.names.length
decreasing_by
  have count := declarationAt_count (text := text) (state := state) (arguments := arguments) (by assumption)
  have _bounded := stateValid.2.1.1
  have nextBound := nextValid.2.1.1
  omega

@[simp] theorem interpreted_operand (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment)
    (bound : ValidCursor text position) (namesValid : ValidNames text names) :
    calls.function .operand text position names = operandAt text position names := by
  rw [equations.operand text valid position names bound namesValid]
  simp [operandBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get,
    interpreted_value calls equations text valid position names bound namesValid, operandAt]

@[simp] theorem interpreted_tail (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment)
    (length : Nat) (dynamicSeen : Bool) (remaining : Nat)
    (bound : ValidCursor text position) (namesValid : ValidNames text names)
    (lengthBound : length ≤ maxSourceLength) (remainingBound : remaining ≤ maxExpressionOperands) :
    calls.function .tail text position names length dynamicSeen remaining =
      expressionTail text names remaining position length dynamicSeen := by
  have batom := (equations.ranges.operand text valid position names bound namesValid).1
  have eoperand := interpreted_operand calls equations text valid position names bound namesValid
  have etoken := interpreted_take calls equations text valid _ (.symbol "&") batom (by unfold ValidToken; decide)
  have followingBound := equations.ranges.token text valid _ (.symbol "&") batom (by unfold ValidToken; decide)
  rw [equations.tail text valid position names length dynamicSeen remaining bound namesValid lengthBound remainingBound]
  simp only [tailBody, Expr.eval, Context.locals, Locals.set, reduceCtorEq, String.reduceEq,
    lexical, Calls.get, Field.get, ↓reduceIte, ↓reduceDIte]
  simp only [ShellToken.symbol, spelling, isWord, eoperand] at etoken followingBound
  simp only [eoperand, etoken, decide_eq_true_eq, Bool.or_eq_true, Bool.and_eq_true] at ⊢ followingBound
  cases remaining with
  | zero => simp [expressionTail]
  | succ remaining =>
      have arithmetic : (operandAt text position names).staticLength > maxSourceLength - length ↔
          ¬length + (operandAt text position names).staticLength ≤ maxSourceLength := by omega
      simp only [expressionTail]
      by_cases present : (operandAt text position names).after = 0
      · simp [present, fitsAccumulator]
      · by_cases fits : length + (operandAt text position names).staticLength ≤ maxSourceLength
        · have overflow : ¬(operandAt text position names).staticLength > maxSourceLength - length := by omega
          by_cases twice : (dynamicSeen && (operandAt text position names).dynamicSeen) = true
          · have components := Bool.and_eq_true_iff.mp twice
            simp [present, overflow, components.1, components.2, fitsAccumulator]
          · have noBoth : ¬ (dynamicSeen = true ∧ (operandAt text position names).dynamicSeen = true) := by
              simpa only [Bool.and_eq_true] using twice
            have allowed : fitsAccumulator (operandAt text position names) length dynamicSeen = true := by
              simp [fitsAccumulator, present, fits, twice]
            simp only [show remaining + 1 ≠ 0 by omega, present, overflow, noBoth, allowed,
              false_or, ↓reduceIte, Nat.add_sub_cancel]
            split
            · exact interpreted_tail calls equations text valid _ names _ _ remaining followingBound
                namesValid fits (by omega)
            · rfl
        · have overflow : (operandAt text position names).staticLength > maxSourceLength - length := by omega
          simp [present, overflow, fits, fitsAccumulator]
termination_by remaining

@[simp] theorem interpreted_expression (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : BindingEnvironment)
    (bound : ValidCursor text position) (namesValid : ValidNames text names) :
    calls.function .expression text position names = expressionAt text position names := by
  rw [equations.expression text valid position names bound namesValid]
  exact interpreted_tail calls equations text valid position names 0 false maxExpressionOperands
    bound namesValid (Nat.zero_le _) (Nat.le_refl _)

@[simp] theorem interpreted_output (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .output text state = outputAt text state := by
  rw [equations.output text valid state stateValid]
  simp [outputBody, Expr.eval, Context.locals, Locals.set, lexical, Calls.get, Field.get,
    interpreted_expression calls equations text valid state.position state.names stateValid.1 stateValid.2.1,
    outputAt, Bool.or_eq_true, Bool.and_eq_true]

@[simp] theorem interpreted_target (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState) (sameTarget : Bool)
    (stateValid : ValidState text state) :
    calls.function .target text state sameTarget = targetAt text state sameTarget := by
  have skipBound := equations.ranges.skip text valid state.position stateValid.1
  have nameBound := equations.ranges.name text valid _ skipBound
  have skipEq := interpreted_skip calls equations text valid state.position stateValid.1
  have nameEq := interpreted_name calls equations text valid _ skipBound
  have lookupEq := interpreted_lookup calls equations text valid state.names _ _ stateValid.2.1 skipBound nameBound
  rw [equations.target text valid state sameTarget stateValid]
  simp only [targetBody, Expr.eval, Context.locals, Locals.set, reduceCtorEq, String.reduceEq,
    lexical, Calls.get, Field.get, ↓reduceIte, ↓reduceDIte]
  rw [lookupEq, nameEq, skipEq]
  simp [targetAt, Bool.or_eq_true, Bool.and_eq_true, or_assoc]

@[simp] theorem interpreted_dynamic (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .dynamic text state = dynamicAt text state := by
  have skipBound := equations.ranges.skip text valid state.position stateValid.1
  have skipEq := interpreted_skip calls equations text valid state.position stateValid.1
  have nameEq := interpreted_name calls equations text valid _ skipBound
  rw [equations.dynamic text valid state stateValid]
  simp only [dynamicBody, Expr.eval, Context.locals, Locals.set, reduceCtorEq, String.reduceEq,
    lexical, modelPrimitives, Calls.get, Field.get, ↓reduceIte, ↓reduceDIte]
  rw [nameEq, skipEq]
  simp [dynamicAt, Bool.or_eq_true, or_assoc]

@[simp] theorem interpreted_assignmentValue (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .assignmentValue text state = assignmentAt text state := by
  rw [equations.assignmentValue text valid state stateValid]
  simp only [assignmentBody, Expr.eval, Context.locals, Locals.set, reduceCtorEq,
    lexical, Calls.get, Field.get, ↓reduceIte, ↓reduceDIte]
  rw [interpreted_value calls equations text valid state.position state.names stateValid.1 stateValid.2.1]
  simp [assignmentAt, Bool.or_eq_true, or_assoc]

@[simp] theorem interpreted_capacity (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) :
    calls.function .capacity text state = capacityAt text state := by
  rw [equations.capacity text valid state stateValid]
  by_cases zero : state.position = 0
  · simp [capacityBody, Expr.eval, Context.locals, lexical, modelPrimitives, Field.get, capacityAt, skipAt, zero]
  · have positive : Cursor.triviaPosition text state.position ≠ 0 := by
      have lower := (Cursor.triviaPosition_bounds text state.position (by omega) stateValid.1).1
      omega
    simp [capacityBody, Expr.eval, Context.locals, lexical, modelPrimitives, Field.get, capacityAt, skipAt, zero, positive]
    change (if decide ((Guarded.decimalAt text (Cursor.triviaPosition text state.position)).after = 0) then invalidState
      else {state with position := (Guarded.decimalAt text (Cursor.triviaPosition text state.position)).after, capacity := (Guarded.decimalAt text (Cursor.triviaPosition text state.position)).value}) = _
    exact decideIf _ _ _

end Silver.Compose.Expressions
