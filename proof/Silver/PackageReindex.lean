module

public import Silver.PackageClosure
public import Silver.ScalarFunctionDefinition

@[expose] public section

/-! Package source frames and closed capture frames need not have the same
identities. Renaming is explicit, preserves cell kind, and need be injective
only on the finite live domain. Expressions retain the existing scalar
semantics; these theorems cover both ordinary and checked evaluation. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value Actual)

structure Renaming where
  integers : Nat → Nat
  booleans : Nat → Nat

def Renaming.identity : Renaming := ⟨id, id⟩

def Renaming.cell (mapping : Renaming) : Cell → Cell
  | .integer identity => .integer (mapping.integers identity)
  | .boolean identity => .boolean (mapping.booleans identity)

def Renaming.InjectiveOn (mapping : Renaming) (domain : List Cell) : Prop :=
  ∀ left ∈ domain, ∀ right ∈ domain,
    mapping.cell left = mapping.cell right → left = right

def Renaming.AgreesOn (mapping : Renaming) (domain : List Cell)
    (original renamed : Frame) : Prop :=
  ∀ cell ∈ domain, readCell renamed (mapping.cell cell) = readCell original cell

theorem Renaming.AgreesOn.mono {mapping : Renaming} {domain smaller : List Cell}
    {original renamed : Frame} (same : mapping.AgreesOn domain original renamed)
    (included : ∀ cell ∈ smaller, cell ∈ domain) :
    mapping.AgreesOn smaller original renamed :=
  fun cell member => same cell (included cell member)

theorem Renaming.AgreesOn.left {mapping : Renaming} {left right : List Cell}
    {original renamed : Frame} (same : mapping.AgreesOn (left ++ right) original renamed) :
    mapping.AgreesOn left original renamed :=
  same.mono (fun _ member => List.mem_append_left _ member)

theorem Renaming.AgreesOn.right {mapping : Renaming} {left right : List Cell}
    {original renamed : Frame} (same : mapping.AgreesOn (left ++ right) original renamed) :
    mapping.AgreesOn right original renamed :=
  same.mono (fun _ member => List.mem_append_right _ member)

theorem Renaming.cell_kind (mapping : Renaming) (cell : Cell) :
    SameKind cell (mapping.cell cell) := by cases cell <;> trivial

theorem Renaming.cell_value {mapping : Renaming} {cell : Cell} {value : Value}
    (typed : CellValue cell value) : CellValue (mapping.cell cell) value := by
  cases cell <;> cases value <;> simp_all [CellValue, Renaming.cell]

theorem Renaming.AgreesOn.write {mapping : Renaming} {domain : List Cell}
    {original renamed : Frame} (same : mapping.AgreesOn domain original renamed)
    (unique : mapping.InjectiveOn domain) {target : Cell} (inside : target ∈ domain)
    {value : Value} (typed : CellValue target value) :
    mapping.AgreesOn domain (writeCell original target value)
      (writeCell renamed (mapping.cell target) value) := by
  intro cell member
  by_cases equal : cell = target
  · subst cell
    rw [readCell_write_same (Renaming.cell_value typed), readCell_write_same typed]
  · have apart : mapping.cell cell ≠ mapping.cell target :=
      fun bad => equal (unique cell member target inside bad)
    rw [readCell_write_other apart, readCell_write_other equal]
    exact same cell member

def integerReads : Integer.Expr → List Cell
  | .literal _ | .snapshot _ => []
  | .name identity => [.integer identity]
  | .indexed _ index => integerReads index
  | .positive value | .negative value | .parenthesized value => integerReads value
  | .add left right | .subtract left right | .multiply left right | .divide left right |
    .modulo left right | .remainder left right => integerReads left ++ integerReads right

def Renaming.integerExpr (mapping : Renaming) : Integer.Expr → Integer.Expr
  | .literal value => .literal value
  | .snapshot value => .snapshot value
  | .name identity => .name (mapping.integers identity)
  | .indexed array index => .indexed array (mapping.integerExpr index)
  | .positive value => .positive (mapping.integerExpr value)
  | .negative value => .negative (mapping.integerExpr value)
  | .parenthesized value => .parenthesized (mapping.integerExpr value)
  | .add left right => .add (mapping.integerExpr left) (mapping.integerExpr right)
  | .subtract left right => .subtract (mapping.integerExpr left) (mapping.integerExpr right)
  | .multiply left right => .multiply (mapping.integerExpr left) (mapping.integerExpr right)
  | .divide left right => .divide (mapping.integerExpr left) (mapping.integerExpr right)
  | .modulo left right => .modulo (mapping.integerExpr left) (mapping.integerExpr right)
  | .remainder left right => .remainder (mapping.integerExpr left) (mapping.integerExpr right)

theorem Renaming.integer_evaluate (mapping : Renaming) (expression : Integer.Expr)
    {original renamed : Frame} (scalar : ScalarFunctions.scalarExpression expression = true)
    (same : mapping.AgreesOn (integerReads expression) original renamed) :
    (mapping.integerExpr expression).evaluate renamed.integers = expression.evaluate original.integers := by
  induction expression with
  | literal | snapshot => rfl
  | name identity => exact Value.integer.inj (same (.integer identity) (by simp [integerReads]))
  | indexed => simp [ScalarFunctions.scalarExpression, ScalarFunctions.frameExpression] at scalar
  | positive value ih | negative value ih | parenthesized value ih =>
      simp only [integerExpr, Integer.Expr.evaluate, ih scalar same]
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr
  | divide left right ihl ihr | modulo left right ihl ihr | remainder left right ihl ihr =>
      have parts : ScalarFunctions.scalarExpression left = true ∧
          ScalarFunctions.scalarExpression right = true := Bool.and_eq_true_iff.mp scalar
      simp only [integerExpr, Integer.Expr.evaluate, ihl parts.1 same.left, ihr parts.2 same.right]

theorem Renaming.integer_checkedEvaluate (mapping : Renaming) (expression : Integer.Expr)
    {original renamed : Frame} (scalar : ScalarFunctions.scalarExpression expression = true)
    (same : mapping.AgreesOn (integerReads expression) original renamed) :
    (mapping.integerExpr expression).checkedEvaluate renamed.integers =
      expression.checkedEvaluate original.integers := by
  induction expression with
  | literal | snapshot => rfl
  | name identity =>
      have value := Value.integer.inj (same (.integer identity) (by simp [integerReads]))
      simp only [integerExpr, Integer.Expr.checkedEvaluate, value]
  | indexed => simp [ScalarFunctions.scalarExpression, ScalarFunctions.frameExpression] at scalar
  | positive value ih | negative value ih | parenthesized value ih =>
      simp only [integerExpr, Integer.Expr.checkedEvaluate, ih scalar same]
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr
  | divide left right ihl ihr | modulo left right ihl ihr | remainder left right ihl ihr =>
      have parts : ScalarFunctions.scalarExpression left = true ∧
          ScalarFunctions.scalarExpression right = true := Bool.and_eq_true_iff.mp scalar
      simp only [integerExpr, Integer.Expr.checkedEvaluate, ihl parts.1 same.left, ihr parts.2 same.right]

def conditionReads : Predicate.Condition → List Cell
  | .scalarCompare _ left right => integerReads left ++ integerReads right
  | .booleanName identity => [.boolean identity]
  | .parenthesized inner | .negated inner => conditionReads inner
  | .andThen left right | .orElse left right | .eager _ left right | .booleanCompare _ left right =>
      conditionReads left ++ conditionReads right
  | _ => []

def Renaming.condition (mapping : Renaming) : Predicate.Condition → Predicate.Condition
  | .scalarCompare operator left right =>
      .scalarCompare operator (mapping.integerExpr left) (mapping.integerExpr right)
  | .booleanName identity => .booleanName (mapping.booleans identity)
  | .parenthesized inner => .parenthesized (mapping.condition inner)
  | .negated inner => .negated (mapping.condition inner)
  | .andThen left right => .andThen (mapping.condition left) (mapping.condition right)
  | .orElse left right => .orElse (mapping.condition left) (mapping.condition right)
  | .eager operator left right => .eager operator (mapping.condition left) (mapping.condition right)
  | .booleanCompare unequal left right =>
      .booleanCompare unequal (mapping.condition left) (mapping.condition right)
  | other => other

theorem Renaming.condition_evaluate (mapping : Renaming) (expression : Predicate.Condition)
    {original renamed : Frame} (scalar : ScalarFunctions.scalarCondition expression = true)
    (same : mapping.AgreesOn (conditionReads expression) original renamed)
    (values : Bindings.Values) (input : Source) (inputValid : Bool) :
    (mapping.condition expression).evaluate values input inputValid renamed.integers renamed.booleans =
      expression.evaluate values input inputValid original.integers original.booleans := by
  induction expression with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanArrayRead =>
      simp [ScalarFunctions.scalarCondition, ScalarFunctions.frameCondition] at scalar
  | booleanLiteral => rfl
  | booleanName identity =>
      exact Value.boolean.inj (same (.boolean identity) (by simp [conditionReads]))
  | scalarCompare operator left right =>
      have parts : ScalarFunctions.scalarExpression left = true ∧
          ScalarFunctions.scalarExpression right = true := Bool.and_eq_true_iff.mp scalar
      simp only [condition, Predicate.Condition.evaluate,
        mapping.integer_evaluate left parts.1 same.left, mapping.integer_evaluate right parts.2 same.right]
  | parenthesized inner ih | negated inner ih =>
      simp only [condition, Predicate.Condition.evaluate, ih scalar same]
  | andThen left right ihl ihr | orElse left right ihl ihr | eager operator left right ihl ihr
  | booleanCompare unequal left right ihl ihr =>
      have parts : ScalarFunctions.scalarCondition left = true ∧
          ScalarFunctions.scalarCondition right = true := Bool.and_eq_true_iff.mp scalar
      simp only [condition, Predicate.Condition.evaluate, ihl parts.1 same.left, ihr parts.2 same.right]

theorem Renaming.condition_checkedEvaluate (mapping : Renaming) (expression : Predicate.Condition)
    {original renamed : Frame} (scalar : ScalarFunctions.scalarCondition expression = true)
    (same : mapping.AgreesOn (conditionReads expression) original renamed)
    (values : Bindings.Values) (input : Source) (inputValid : Bool) :
    (mapping.condition expression).checkedEvaluate values input inputValid renamed.integers renamed.booleans =
      expression.checkedEvaluate values input inputValid original.integers original.booleans := by
  induction expression with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanArrayRead =>
      simp [ScalarFunctions.scalarCondition, ScalarFunctions.frameCondition] at scalar
  | booleanLiteral => rfl
  | booleanName identity =>
      have value := Value.boolean.inj (same (.boolean identity) (by simp [conditionReads]))
      simp only [condition, Predicate.Condition.checkedEvaluate, value]
  | scalarCompare operator left right =>
      have parts : ScalarFunctions.scalarExpression left = true ∧
          ScalarFunctions.scalarExpression right = true := Bool.and_eq_true_iff.mp scalar
      simp only [condition, Predicate.Condition.checkedEvaluate,
        mapping.integer_checkedEvaluate left parts.1 same.left,
        mapping.integer_checkedEvaluate right parts.2 same.right]
  | parenthesized inner ih | negated inner ih =>
      simp only [condition, Predicate.Condition.checkedEvaluate, ih scalar same]
  | andThen left right ihl ihr | orElse left right ihl ihr | eager operator left right ihl ihr
  | booleanCompare unequal left right ihl ihr =>
      have parts : ScalarFunctions.scalarCondition left = true ∧
          ScalarFunctions.scalarCondition right = true := Bool.and_eq_true_iff.mp scalar
      simp only [condition, Predicate.Condition.checkedEvaluate, ihl parts.1 same.left, ihr parts.2 same.right]

def actualReads : Actual → List Cell
  | .integer expression => integerReads expression
  | .boolean expression => conditionReads expression
  | .array _ _ => []

def Renaming.actual (mapping : Renaming) : Actual → Actual
  | .integer expression => .integer (mapping.integerExpr expression)
  | .boolean expression => .boolean (mapping.condition expression)
  | .array identity source => .array identity source

@[simp] theorem Renaming.identity_cell (cell : Cell) : Renaming.identity.cell cell = cell := by
  cases cell <;> rfl

@[simp] theorem Renaming.identity_integerExpr (expression : Integer.Expr) :
    Renaming.identity.integerExpr expression = expression := by
  induction expression <;> simp_all [integerExpr, identity]

@[simp] theorem Renaming.identity_condition (expression : Predicate.Condition) :
    Renaming.identity.condition expression = expression := by
  induction expression <;> simp_all only [condition, identity_integerExpr] <;> rfl

@[simp] theorem Renaming.identity_actual (actual : Actual) : Renaming.identity.actual actual = actual := by
  cases actual <;> simp [Renaming.actual]

def scalarState (frame : Frame) : ScalarFunctions.State :=
  ⟨Bindings.emptyValues, [], true, frame.integers, frame.booleans⟩

theorem Renaming.actual_evaluate (mapping : Renaming) (actual : Actual)
    {original renamed : Frame} (scalar : ScalarFunctions.scalarActual actual = true)
    (same : mapping.AgreesOn (actualReads actual) original renamed) :
    (mapping.actual actual).evaluate (scalarState renamed) = actual.evaluate (scalarState original) := by
  cases actual with
  | integer expression => exact congrArg Value.integer (mapping.integer_evaluate expression scalar same)
  | boolean expression => exact congrArg Value.boolean (mapping.condition_evaluate expression scalar same _ _ _)
  | array => simp [ScalarFunctions.scalarActual, ScalarFunctions.frameActual] at scalar

theorem Renaming.actual_checkedEvaluate (mapping : Renaming) (actual : Actual)
    {original renamed : Frame} (scalar : ScalarFunctions.scalarActual actual = true)
    (same : mapping.AgreesOn (actualReads actual) original renamed) :
    (mapping.actual actual).checkedEvaluate (scalarState renamed) = actual.checkedEvaluate (scalarState original) := by
  cases actual with
  | integer expression =>
      exact congrArg (Option.map Value.integer) (mapping.integer_checkedEvaluate expression scalar same)
  | boolean expression =>
      exact congrArg (Option.map Value.boolean) (mapping.condition_checkedEvaluate expression scalar same _ _ _)
  | array => simp [ScalarFunctions.scalarActual, ScalarFunctions.frameActual] at scalar

end Silver.Packages
