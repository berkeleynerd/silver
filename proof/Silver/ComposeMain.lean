module

public import Silver.ComposeAdmission
public import Silver.GuardedObligations

@[expose] public section

/-! Decoded payloads of the finite shells. Admission resolves result and argument
names to their distinct slots and immutable names to their declared bytes;
the values here retain every literal and operand.
An explicit capacity remains distinguishable from an absent capacity. -/

namespace Silver.Compose

inductive Program
  | direct (expression : Expression)
  | static (initial : Source) (expression : Expression)
  | assignment (initial replacement : Source) (expression : Expression)
  | argument (fallback : Source) (capacity : Option Nat) (expression : Expression)
  | branching (fallback : Source) (capacity : Option Nat) (comparison : Source)
      (yes no : Expression)
  | result (fallback initial : Source) (capacity : Option Nat)
      (comparison yes no : Source) (expression : Expression)
  deriving DecidableEq, Repr

def decode : Form → List Event → Option Program
  | .direct, [.output expression] => some (.direct expression)
  | .static, [.declaration false _, .literal .initial initial, .output expression] =>
      some (.static initial expression)
  | .assignment, [.declaration false _, .literal .initial initial, .reference false,
      .literal .assigned replacement, .output expression] =>
      some (.assignment initial replacement expression)
  | .argument, [.declaration true _, .literal .ordinary fallback, .output expression] =>
      some (.argument fallback none expression)
  | .guardedArgument, [.declaration true _, .literal .ordinary fallback,
      .reference true, .capacity capacity, .output expression] =>
      some (.argument fallback (some capacity) expression)
  | .branching, [.declaration true _, .literal .ordinary fallback, .reference true,
      .literal .ordinary comparison, .output yes, .output no] =>
      some (.branching fallback none comparison yes no)
  | .guardedBranching, [.declaration true _, .literal .ordinary fallback,
      .reference true, .capacity capacity, .reference true,
      .literal .ordinary comparison, .output yes, .output no] =>
      some (.branching fallback (some capacity) comparison yes no)
  | .result, [.declaration true _, .literal .ordinary fallback,
      .declaration false _, .literal .initial initial, .reference true,
      .literal .ordinary comparison, .reference false, .literal .assigned yes,
      .reference false, .literal .assigned no, .output expression] =>
      some (.result fallback initial none comparison yes no expression)
  | .guardedResult, [.declaration true _, .literal .ordinary fallback,
      .declaration false _, .literal .initial initial, .reference true, .capacity capacity,
      .reference true, .literal .ordinary comparison, .reference false,
      .literal .assigned yes, .reference false, .literal .assigned no, .output expression] =>
      some (.result fallback initial (some capacity) comparison yes no expression)
  | .assignmentOne, [.constantDeclaration false _, .literal .constantOne _, .declaration false _, .literal .initial initial, .reference false,
      .literal .assigned replacement, .output expression] =>
      some (.assignment initial replacement expression)
  | .assignmentTwo, [.constantDeclaration false _, .literal .constantOne _, .constantDeclaration true _, .literal .constantTwo _, .declaration false _, .literal .initial initial, .reference false,
      .literal .assigned replacement, .output expression] =>
      some (.assignment initial replacement expression)
  | .resultOne, [.declaration true _, .literal .ordinary fallback,
      .constantDeclaration false _, .literal .constantOne _, .declaration false _, .literal .initial initial, .reference true,
      .literal .ordinary comparison, .reference false, .literal .assigned yes,
      .reference false, .literal .assigned no, .output expression] =>
      some (.result fallback initial none comparison yes no expression)
  | .resultTwo, [.declaration true _, .literal .ordinary fallback,
      .constantDeclaration false _, .literal .constantOne _, .constantDeclaration true _, .literal .constantTwo _, .declaration false _, .literal .initial initial, .reference true,
      .literal .ordinary comparison, .reference false, .literal .assigned yes,
      .reference false, .literal .assigned no, .output expression] =>
      some (.result fallback initial none comparison yes no expression)
  | .guardedResultOne, [.declaration true _, .literal .ordinary fallback,
      .constantDeclaration false _, .literal .constantOne _, .declaration false _, .literal .initial initial, .reference true, .capacity capacity,
      .reference true, .literal .ordinary comparison, .reference false,
      .literal .assigned yes, .reference false, .literal .assigned no, .output expression] =>
      some (.result fallback initial (some capacity) comparison yes no expression)
  | .guardedResultTwo, [.declaration true _, .literal .ordinary fallback,
      .constantDeclaration false _, .literal .constantOne _, .constantDeclaration true _, .literal .constantTwo _, .declaration false _, .literal .initial initial, .reference true, .capacity capacity,
      .reference true, .literal .ordinary comparison, .reference false,
      .literal .assigned yes, .reference false, .literal .assigned no, .output expression] =>
      some (.result fallback initial (some capacity) comparison yes no expression)
  | _, _ => none

def effectiveCapacity (capacity : Option Nat) : Nat := capacity.getD maxSourceLength

def Printable (bytes : Source) : Prop := ∀ byte ∈ bytes, Output.printable byte = true

def SafeExpression (expression : Expression) (length capacity : Nat) : Prop :=
  expression.Bounded length capacity ∧ expression.LiteralsPrintable ∧
    expression.length ≤ maxExpressionOperands

def Program.Valid : Program → Prop
  | .direct expression => SafeExpression expression 0 maxSourceLength
  | .static initial expression => Printable initial ∧
      SafeExpression expression initial.length maxSourceLength
  | .assignment initial replacement expression => Printable initial ∧ Printable replacement ∧
      replacement.length = initial.length ∧ SafeExpression expression initial.length maxSourceLength
  | .argument fallback capacity expression => Printable fallback ∧ fallback.length ≤ maxSourceLength ∧
      effectiveCapacity capacity ≤ maxSourceLength ∧ SafeExpression expression 0 (effectiveCapacity capacity)
  | .branching fallback capacity comparison yes no =>
      Printable fallback ∧ fallback.length ≤ maxSourceLength ∧ Printable comparison ∧
      effectiveCapacity capacity ≤ maxSourceLength ∧
      SafeExpression yes 0 (effectiveCapacity capacity) ∧ SafeExpression no 0 (effectiveCapacity capacity)
  | .result fallback initial capacity comparison yes no expression =>
      Printable fallback ∧ fallback.length ≤ maxSourceLength ∧ Printable initial ∧ Printable comparison ∧
      Printable yes ∧ Printable no ∧ yes.length = initial.length ∧ no.length = initial.length ∧
      effectiveCapacity capacity ≤ maxSourceLength ∧ SafeExpression expression initial.length (effectiveCapacity capacity)

inductive Action
  | reject
  | output (bytes : Source)
  deriving DecidableEq, Repr

def selected (fallback : Source) (arguments : Arguments.Runtime.Arguments) : Source :=
  Arguments.Runtime.firstOrDefault fallback arguments

def guard (fallback : Source) (capacity : Option Nat) (arguments : Arguments.Runtime.Arguments) : Bool :=
  Arguments.Runtime.inputIsValid arguments &&
    match capacity with
    | none => true
    | some bound => decide ((selected fallback arguments).length ≤ bound)

def Program.action (arguments : Arguments.Runtime.Arguments) : Program → Action
  | .direct expression => .output (expression.evaluate [] [])
  | .static initial expression => .output (expression.evaluate initial [])
  | .assignment _ replacement expression => .output (expression.evaluate replacement [])
  | .argument fallback capacity expression =>
      if guard fallback capacity arguments then .output (expression.evaluate [] (selected fallback arguments))
      else .reject
  | .branching fallback capacity comparison yes no =>
      if guard fallback capacity arguments then
        .output ((if selected fallback arguments = comparison then yes else no).evaluate [] (selected fallback arguments))
      else .reject
  | .result fallback _ capacity comparison yes no expression =>
      if guard fallback capacity arguments then
        .output (expression.evaluate (if selected fallback arguments = comparison then yes else no)
          (selected fallback arguments))
      else .reject

theorem selected_domain (fallback : Source) (arguments : Arguments.Runtime.Arguments) :
    (selected fallback arguments).length ≤ maxSourceLength ∧ Printable (selected fallback arguments) := by
  have domain := (Arguments.Runtime.message_iff _).mp
    (Arguments.Runtime.initializer_domain arguments fallback)
  exact ⟨domain.1, fun byte member => decide_eq_true (domain.2 byte member)⟩

theorem guarded_length {fallback : Source} {capacity : Option Nat} {arguments : Arguments.Runtime.Arguments}
    (accepted : guard fallback capacity arguments = true) :
    (selected fallback arguments).length ≤ effectiveCapacity capacity := by
  cases capacity with
  | none => exact (selected_domain fallback arguments).1
  | some capacity =>
      simp only [guard, Bool.and_eq_true, decide_eq_true_eq] at accepted
      exact accepted.2

theorem expression_domain {expression : Expression} {staticValue dynamicValue : Source} {capacity : Nat}
    (safe : SafeExpression expression staticValue.length capacity)
    (staticBytes : Printable staticValue) (dynamicBytes : Printable dynamicValue)
    (fits : dynamicValue.length ≤ capacity) :
    (expression.evaluate staticValue dynamicValue).length ≤ maxSourceLength ∧
      Printable (expression.evaluate staticValue dynamicValue) :=
  ⟨Expression.output_bound safe.1 fits,
    Expression.evaluate_printable safe.2.1 staticBytes dynamicBytes⟩

theorem action_domain {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) {bytes : Source}
    (output : program.action arguments = .output bytes) :
    bytes.length ≤ maxSourceLength ∧ Printable bytes := by
  cases program with
  | direct expression =>
      cases output
      exact expression_domain valid (by simp [Printable]) (by simp [Printable]) (by simp)
  | static initial expression =>
      cases output
      exact expression_domain valid.2 valid.1 (by simp [Printable]) (by simp)
  | assignment initial replacement expression =>
      cases output
      exact expression_domain (by simpa [valid.2.2.1] using valid.2.2.2)
        valid.2.1 (by simp [Printable]) (by simp)
  | argument fallback capacity expression =>
      simp only [Program.action] at output
      split at output
      · rename_i accepted
        cases output
        exact expression_domain valid.2.2.2 (by simp [Printable])
          (selected_domain fallback arguments).2 (guarded_length accepted)
      · cases output
  | branching fallback capacity comparison yes no =>
      simp only [Program.action] at output
      split at output
      · rename_i accepted
        cases output
        apply expression_domain
        · split <;> first | exact valid.2.2.2.2.1 | exact valid.2.2.2.2.2
        · simp [Printable]
        · exact (selected_domain fallback arguments).2
        · exact guarded_length accepted
      · cases output
  | result fallback initial capacity comparison yes no expression =>
      simp only [Program.action] at output
      split at output
      · rename_i accepted
        cases output
        apply expression_domain
        · split <;> simpa only [valid.2.2.2.2.2.2.1, valid.2.2.2.2.2.2.2.1] using valid.2.2.2.2.2.2.2.2.2
        · split <;> first | exact valid.2.2.2.2.1 | exact valid.2.2.2.2.2.1
        · exact (selected_domain fallback arguments).2
        · exact guarded_length accepted
      · cases output

end Silver.Compose
