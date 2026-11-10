module

public import Silver.ScalarProcedureExecution

@[expose] public section

/-! A footprint excludes a write only on a safe evaluation: checked array
indexes must remain inside the descriptor whose cells the footprint records.
Safety and value equality are preserved together for sequential prefix writes. -/
namespace Silver.ScalarProcedures
open ScalarFunctions (Target Value State)

theorem integer_write_noninterference {expression : Integer.Expr} {store : Integer.Store}
    {identity : Nat} (value : Int) (safe : expression.Safe store)
    (absent : integerMentions identity expression = false) :
    expression.Safe (Integer.put store identity value) ∧
      expression.evaluate (Integer.put store identity value) = expression.evaluate store := by
  induction expression with
  | literal | snapshot => exact ⟨safe, by trivial⟩
  | name index =>
      have different : index ≠ identity := by intro same; subst index; simp [integerMentions] at absent
      simp only [Integer.Expr.Safe, Integer.Expr.evaluate, Integer.put, different, ↓reduceIte]
      exact ⟨safe, by trivial⟩
  | indexed array index ih =>
      have parts := Bool.or_eq_false_iff.mp absent
      have outside : ¬array.ContainsCell identity := of_decide_eq_false parts.1
      have next := ih safe.1 parts.2
      have other : array.address (index.evaluate store) ≠ identity := by
        intro same
        have within := Integer.ArrayDescriptor.address_within safe.2.1
        rw [same] at within
        exact outside within
      have unchanged : array.project (Integer.put store identity value) (index.evaluate store) =
          array.project store (index.evaluate store) := by simp [Integer.ArrayDescriptor.project, Integer.put, other]
      simp only [Integer.Expr.Safe, Integer.Expr.evaluate, next.2, unchanged]
      exact ⟨⟨next.1, safe.2⟩, by trivial⟩
  | positive inner ih | parenthesized inner ih => exact ih safe absent
  | negative inner ih =>
      have next := ih safe.1 absent
      simp only [Integer.Expr.Safe, Integer.Expr.evaluate, next.2]
      exact ⟨⟨next.1, safe.2⟩, by trivial⟩
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr | divide left right ihl ihr | modulo left right ihl ihr | remainder left right ihl ihr =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := ihl safe.1 parts.1
      have second := ihr safe.2.1 parts.2
      simp only [Integer.Expr.Safe, Integer.Expr.evaluate, first.2, second.2]
      exact ⟨⟨first.1, second.1, safe.2.2⟩, by trivial⟩

theorem character_write_noninterference {expression : Character.Expr} {store : Integer.Store}
    {values : Bindings.Values} {identity : Nat} (value : Int) (safe : expression.Safe values store)
    (absent : characterMentions identity expression = false) :
    expression.Safe values (Integer.put store identity value) ∧
      expression.evaluate values (Integer.put store identity value) = expression.evaluate values store := by
  induction expression with
  | literal | reference => exact ⟨safe, by trivial⟩
  | indexed target base index =>
      have next := integer_write_noninterference value safe.1 absent
      simp only [Character.Expr.Safe, Character.Expr.evaluate, next.2]
      exact ⟨⟨next.1, safe.2⟩, by trivial⟩
  | parenthesized inner ih => exact ih safe absent

theorem string_write_noninterference {atom : Bindings.Value} {store : Integer.Store}
    {values : Bindings.Values} {input : Source} {identity : Nat} (value : Int)
    (safe : atom.ChecksSafe values store) (absent : stringMentions identity atom = false) :
    atom.ChecksSafe values (Integer.put store identity value) ∧
      atom.evaluate values input (Integer.put store identity value) = atom.evaluate values input store := by
  cases atom with
  | literal | reference | argument => exact ⟨safe, by trivial⟩
  | image expression =>
      have next := integer_write_noninterference value safe absent
      exact ⟨next.1, congrArg Integer.Image.bytes next.2⟩
  | slice target base lower upper =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := integer_write_noninterference value safe.1 parts.1
      have second := integer_write_noninterference value safe.2.1 parts.2
      simp only [Bindings.Value.ChecksSafe, Bindings.Value.evaluate, first.2, second.2]
      exact ⟨⟨first.1, second.1, safe.2.2⟩, by trivial⟩
  | character expression =>
      have next := character_write_noninterference value safe absent
      exact ⟨next.1, congrArg (fun byte => [byte]) next.2⟩
  | replace target base index replacement =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := integer_write_noninterference value safe.1 parts.1
      have second := character_write_noninterference value safe.2.2 parts.2
      simp only [Bindings.Value.ChecksSafe, Bindings.Value.evaluate, first.2, second.2]
      exact ⟨⟨first.1, safe.2.1, second.1⟩, by trivial⟩

theorem expression_write_noninterference {expression : Compose.Expression} {store : Integer.Store}
    {values : Bindings.Values} {input : Source} {identity : Nat} (value : Int)
    (safe : expression.ImagesSafe store values) (absent : expression.any (stringMentions identity) = false) :
    expression.ImagesSafe (Integer.put store identity value) values ∧
      expression.evaluate values input (Integer.put store identity value) = expression.evaluate values input store := by
  induction expression with
  | nil => exact ⟨by simp [Compose.Expression.ImagesSafe], by trivial⟩
  | cons atom rest ih =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := string_write_noninterference (input := input) value (safe atom (by simp)) parts.1
      have second := ih (fun other present => safe other (by simp [present])) parts.2
      refine ⟨?_, ?_⟩
      · intro other present
        rcases List.mem_cons.mp present with rfl | present
        · exact first.1
        · exact second.1 other present
      · simp only [Compose.Expression.evaluate, first.2, second.2]

theorem condition_integer_write_noninterference {condition : Predicate.Condition} {shape : Bindings.Shape}
    {values : Bindings.Values} {input : Source} {valid : Bool}
    {store : Integer.Store} {booleans : Boolean.Store} {identity : Nat} (value : Int)
    (safe : condition.Safe shape values input valid store booleans)
    (absent : conditionMentions (.integer identity) condition = false) :
    condition.Safe shape values input valid (Integer.put store identity value) booleans ∧
      condition.evaluate values input valid (Integer.put store identity value) booleans =
        condition.evaluate values input valid store booleans := by
  induction condition with
  | lengthCompare | inputValid | booleanLiteral | booleanName => exact ⟨safe, by trivial⟩
  | stringCompare unequal left right =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := expression_write_noninterference (input := input) value safe.1.1 parts.1
      have second := expression_write_noninterference (input := input) value safe.2.1 parts.2
      simp only [Predicate.Condition.Safe, Compose.Expression.RuntimeSafe, Predicate.Condition.evaluate, first.2, second.2]
      exact ⟨⟨⟨first.1, safe.1.2⟩, ⟨second.1, safe.2.2⟩⟩, by trivial⟩
  | scalarCompare operator left right =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := integer_write_noninterference value safe.1 parts.1
      have second := integer_write_noninterference value safe.2 parts.2
      simp only [Predicate.Condition.Safe, Predicate.Condition.evaluate, first.2, second.2]
      exact ⟨⟨first.1, second.1⟩, by trivial⟩
  | characterCompare operator left right =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := character_write_noninterference value safe.1 parts.1
      have second := character_write_noninterference value safe.2 parts.2
      simp only [Predicate.Condition.Safe, Predicate.Condition.evaluate, first.2, second.2]
      exact ⟨⟨first.1, second.1⟩, by trivial⟩
  | booleanArrayRead array index =>
      have next := integer_write_noninterference value safe.1 absent
      simp only [Predicate.Condition.Safe, Predicate.Condition.evaluate, next.2]
      exact ⟨⟨next.1, safe.2⟩, by trivial⟩
  | parenthesized inner ih => exact ih safe absent
  | negated inner ih =>
      have next := ih safe absent
      exact ⟨next.1, congrArg Bool.not next.2⟩
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := ihl safe.1 parts.1
      simp only [Predicate.Condition.Safe, Predicate.Condition.evaluate, first.2]
      refine ⟨⟨first.1, fun reached => (ihr (safe.2 reached) parts.2).1⟩, ?_⟩
      split
      · first | exact (ihr (safe.2 (by assumption)) parts.2).2 | rfl
      · first | exact (ihr (safe.2 (by simp_all)) parts.2).2 | rfl
  | eager operator left right ihl ihr | booleanCompare unequal left right ihl ihr =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := ihl safe.1 parts.1
      have second := ihr safe.2 parts.2
      simp only [Predicate.Condition.Safe, Predicate.Condition.evaluate, first.2, second.2]
      exact ⟨⟨first.1, second.1⟩, by trivial⟩

theorem condition_boolean_write_noninterference {condition : Predicate.Condition} {shape : Bindings.Shape}
    {values : Bindings.Values} {input : Source} {valid : Bool}
    {store : Integer.Store} {booleans : Boolean.Store} {identity : Nat} (value : Bool)
    (safe : condition.Safe shape values input valid store booleans)
    (absent : conditionMentions (.boolean identity) condition = false) :
    condition.Safe shape values input valid store (Boolean.put booleans identity value) ∧
      condition.evaluate values input valid store (Boolean.put booleans identity value) =
        condition.evaluate values input valid store booleans := by
  induction condition with
  | stringCompare | lengthCompare | scalarCompare | characterCompare | inputValid | booleanLiteral => exact ⟨safe, by trivial⟩
  | booleanName index =>
      have different : index ≠ identity := by intro same; subst index; simp [conditionMentions] at absent
      exact ⟨trivial, Boolean.put_other booleans identity value index different⟩
  | booleanArrayRead array index =>
      have outside : ¬array.ContainsCell identity := of_decide_eq_false absent
      have other : array.address (index.evaluate store) ≠ identity := by
        intro same
        have within := Boolean.ArrayDescriptor.address_within safe.2
        rw [same] at within
        exact outside within
      exact ⟨safe, by simp [Predicate.Condition.evaluate, Boolean.ArrayDescriptor.project, Boolean.put, other]⟩
  | parenthesized inner ih => exact ih safe absent
  | negated inner ih =>
      have next := ih safe absent
      exact ⟨next.1, congrArg Bool.not next.2⟩
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := ihl safe.1 parts.1
      simp only [Predicate.Condition.Safe, Predicate.Condition.evaluate, first.2]
      refine ⟨⟨first.1, fun reached => (ihr (safe.2 reached) parts.2).1⟩, ?_⟩
      split
      · first | exact (ihr (safe.2 (by assumption)) parts.2).2 | rfl
      · first | exact (ihr (safe.2 (by simp_all)) parts.2).2 | rfl
  | eager operator left right ihl ihr | booleanCompare unequal left right ihl ihr =>
      have parts := Bool.or_eq_false_iff.mp absent
      have first := ihl safe.1 parts.1
      have second := ihr safe.2 parts.2
      simp only [Predicate.Condition.Safe, Predicate.Condition.evaluate, first.2, second.2]
      exact ⟨⟨first.1, second.1⟩, by trivial⟩

theorem actual_write_noninterference {actual : ScalarFunctions.Actual} {shape : Bindings.Shape}
    {state : State} {target : Target} (value : Value) (safe : actual.Safe shape state)
    (absent : valueMentions (targetCell target) actual = false) :
    actual.Safe shape (target.write value state) ∧ actual.evaluate (target.write value state) = actual.evaluate state := by
  cases target <;> cases value
  all_goals try exact ⟨safe, by trivial⟩
  · rename_i identity bounds value
    cases actual with
    | integer expression =>
        have next := integer_write_noninterference value safe absent
        exact ⟨next.1, congrArg Value.integer next.2⟩
    | boolean condition =>
        have next := condition_integer_write_noninterference value safe absent
        exact ⟨next.1, congrArg Value.boolean next.2⟩
  · rename_i identity value
    cases actual with
    | integer expression => exact ⟨safe, by trivial⟩
    | boolean condition =>
        have next := condition_boolean_write_noninterference value safe absent
        exact ⟨next.1, congrArg Value.boolean next.2⟩

theorem actual_copyBack_noninterference {actual : ScalarFunctions.Actual} {shape : Bindings.Shape}
    {state : State} {targets : List Target} (values : List Value) (safe : actual.Safe shape state)
    (absent : ∀ target ∈ targets, valueMentions (targetCell target) actual = false) :
    actual.Safe shape (copyBack targets values state) ∧
      actual.evaluate (copyBack targets values state) = actual.evaluate state := by
  induction targets generalizing values state with
  | nil => exact ⟨safe, by trivial⟩
  | cons target targets ih =>
      cases values with
      | nil => exact ⟨safe, by trivial⟩
      | cons value values =>
          have first := actual_write_noninterference value safe (absent target (by simp))
          have rest := ih values first.1 (fun other present => absent other (by simp [present]))
          exact ⟨rest.1, rest.2.trans first.2⟩

end Silver.ScalarProcedures
