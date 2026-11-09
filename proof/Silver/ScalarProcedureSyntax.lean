module

public import Silver.ScalarProcedureTypes
public import Silver.ScalarCallSyntax

@[expose] public section

namespace Silver.ScalarProcedures
open ScalarFunctions (Target)

inductive Cell
  | integer (identity : Nat)
  | boolean (identity : Nat)
  deriving DecidableEq, Repr

def targetCell : Target → Cell
  | .integer identity _ => .integer identity
  | .boolean identity => .boolean identity

def targetRead : Target → ScalarFunctions.Actual
  | .integer identity _ => .integer (.name identity)
  | .boolean identity => .boolean (.booleanName identity)

inductive Actual
  | value (expression : ScalarFunctions.Actual)
  | target (object : Target)
  deriving DecidableEq, Repr

structure Call where
  callee : Nat
  actuals : List Actual
  deriving DecidableEq, Repr

/-- All writable caller objects are already initialized under the selected language.
Only the callee's own `out` formal lacks a readable incoming value. -/
def Actual.Readable (hasArguments : Bool) (shape : Bindings.Shape)
    (booleans : Boolean.Analysis) : Actual → Prop
  | .value expression => expression.Readable hasArguments shape booleans
  | .target object => object.identity ≠ 0 ∧ (targetRead object).Readable hasArguments shape booleans

def Call.Readable (hasArguments : Bool) (shape : Bindings.Shape)
    (booleans : Boolean.Analysis) (call : Call) : Prop :=
  ∀ actual ∈ call.actuals, actual.Readable hasArguments shape booleans

/-- The footprint includes every syntactically possible component, independently
of path feasibility or a particular subscript value. -/
def integerMentions (identity : Nat) : Integer.Expr → Bool
  | .literal _ | .snapshot _ => false
  | .name index => identity == index
  | .indexed array index => decide (array.ContainsCell identity) || integerMentions identity index
  | .positive value | .negative value | .parenthesized value => integerMentions identity value
  | .add left right | .subtract left right | .multiply left right | .divide left right |
    .modulo left right | .remainder left right => integerMentions identity left || integerMentions identity right

def characterMentions (identity : Nat) : Character.Expr → Bool
  | .literal _ | .reference _ => false
  | .indexed _ _ index => integerMentions identity index
  | .parenthesized inner => characterMentions identity inner

def stringMentions (identity : Nat) : Bindings.Value → Bool
  | .literal _ | .reference _ | .argument => false
  | .image expression => integerMentions identity expression
  | .slice _ _ lower upper => integerMentions identity lower || integerMentions identity upper
  | .character expression => characterMentions identity expression
  | .replace _ _ index replacement => integerMentions identity index || characterMentions identity replacement

def conditionMentions (cell : Cell) : Predicate.Condition → Bool
  | .stringCompare _ left right =>
      match cell with
      | .integer identity => left.any (stringMentions identity) || right.any (stringMentions identity)
      | .boolean _ => false
  | .scalarCompare _ left right =>
      match cell with
      | .integer identity => integerMentions identity left || integerMentions identity right
      | .boolean _ => false
  | .characterCompare _ left right =>
      match cell with
      | .integer identity => characterMentions identity left || characterMentions identity right
      | .boolean _ => false
  | .booleanName identity => cell == .boolean identity
  | .booleanArrayRead array index =>
      match cell with
      | .integer identity => integerMentions identity index
      | .boolean identity => decide (array.ContainsCell identity)
  | .parenthesized inner | .negated inner => conditionMentions cell inner
  | .andThen left right | .orElse left right | .eager _ left right | .booleanCompare _ left right =>
      conditionMentions cell left || conditionMentions cell right
  | .lengthCompare _ _ _ | .inputValid | .booleanLiteral _ => false

def valueMentions (cell : Cell) : ScalarFunctions.Actual → Bool
  | .integer expression =>
      match cell with
      | .integer identity => integerMentions identity expression
      | .boolean _ => false
  | .boolean condition => conditionMentions cell condition

def Actual.apart : Actual → Actual → Bool
  | .value _, .value _ => true
  | .target object, .value expression | .value expression, .target object =>
      !valueMentions (targetCell object) expression
  | .target left, .target right => targetCell left != targetCell right

/-- Reject overlap with any other actual, including reads nested inside expressions.
An `in out` actual's own copy-in read is intentionally not compared with itself. -/
def actualsApart : List Actual → Bool
  | [] => true
  | first :: rest => rest.all (Actual.apart first) && actualsApart rest

structure ActualBindings where
  inputs : List ScalarFunctions.Actual
  outputs : List Target
  deriving DecidableEq, Repr

/-- Binding is structural and exact-arity. It never evaluates an actual and
never changes the caller state while collecting the input tuple. -/
def bindActuals : List Formal → List Actual → Option ActualBindings
  | [], [] => some ⟨[], []⟩
  | ⟨.input, _⟩ :: formals, .value expression :: actuals =>
      (bindActuals formals actuals).map fun rest => {rest with inputs := expression :: rest.inputs}
  | ⟨.output, _⟩ :: formals, .target object :: actuals =>
      (bindActuals formals actuals).map fun rest => {rest with outputs := object :: rest.outputs}
  | ⟨.inputOutput, _⟩ :: formals, .target object :: actuals =>
      (bindActuals formals actuals).map fun rest =>
        ⟨targetRead object :: rest.inputs, object :: rest.outputs⟩
  | _, _ => none

structure ResolvedCall where
  signature : Signature
  actuals : ActualBindings
  deriving DecidableEq, Repr

def Call.resolve (signatures : Signatures) (call : Call) : Option ResolvedCall :=
  (lookup signatures call.callee).bind fun signature =>
    (bindActuals signature.formals call.actuals).map fun actuals => ⟨signature, actuals⟩

theorem bindActuals_inputs_readable {formals : List Formal} {actuals : List Actual}
    {bound : ActualBindings} {hasArguments : Bool} {shape : Bindings.Shape} {booleans : Boolean.Analysis}
    (readable : ∀ actual ∈ actuals, actual.Readable hasArguments shape booleans)
    (boundEq : bindActuals formals actuals = some bound) :
    ∀ actual ∈ bound.inputs, actual.Readable hasArguments shape booleans := by
  induction formals generalizing actuals bound with
  | nil =>
      cases actuals with
      | nil => cases Option.some.inj boundEq; simp
      | cons => simp [bindActuals] at boundEq
  | cons formal formals ih =>
      cases actuals with
      | nil => simp [bindActuals] at boundEq
      | cons actual actuals =>
          have first := readable actual (by simp)
          have rest : ∀ other ∈ actuals, other.Readable hasArguments shape booleans :=
            fun other present => readable other (by simp [present])
          rcases formal with ⟨mode, domain⟩
          cases mode <;> cases actual <;> simp only [bindActuals] at boundEq
          all_goals try contradiction
          all_goals
            obtain ⟨following, boundFollowing, rfl⟩ := Option.map_eq_some_iff.mp boundEq
            have next := ih rest boundFollowing
            simp_all [Actual.Readable]

end Silver.ScalarProcedures
