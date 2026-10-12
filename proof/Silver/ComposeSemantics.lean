module

public import Silver.ComposeAdmission

@[expose] public section

namespace Silver.Compose
open Named Bindings

def NamesNormal (names : BindingEnvironment) : Prop :=
  ∀ index info, names.get index = some info → info.dynamic = true → info.staticLength = 0

theorem value_unique {text : Source} {names : BindingEnvironment} {position : Nat}
    {left right : Operand} {leftResult rightResult : ValueResult}
    (first : ValueAt text names position left leftResult)
    (second : ValueAt text names position right rightResult) :
    left = right ∧ leftResult = rightResult := by
  have results := (value_complete first).symm.trans (value_complete second)
  refine ⟨?_, results⟩
  cases first with
  | literal _ _ quote parsed =>
      cases second with
      | literal _ _ _ other => exact congrArg Bindings.Value.literal (Output.literalAt_unique parsed other).1
      | reference _ name _ _ _ => exact False.elim (identifier_not_quote name quote)
  | reference _ name _ _ _ =>
      cases second with
      | literal _ _ quote _ => exact False.elim (identifier_not_quote name quote)
      | reference => exact congrArg Bindings.Value.reference (congrArg ValueResult.reference results)

theorem value_normal {text : Source} {names : BindingEnvironment} {position : Nat}
    {value : Operand} {result : ValueResult} (normal : NamesNormal names)
    (parsed : ValueAt text names position value result) :
    result.dynamicSeen = true → result.staticLength = 0 := by
  cases parsed with
  | literal => simp
  | reference _ _ _ _ present => exact normal _ _ present

theorem value_summary {text : Source} {names : BindingEnvironment} {position : Nat}
    {value : Operand} {result : ValueResult} (normal : NamesNormal names)
    (parsed : ValueAt text names position value result) :
    value.staticLength names.shape = result.staticLength ∧
      value.dynamicCount names.shape = (if result.dynamicSeen then 1 else 0) := by
  have inferred := value_infer parsed
  have zero := value_normal normal parsed
  simp only [Operand.staticLength, Operand.dynamicCount, Operand.bound, inferred, Option.getD_some,
    ValueResult.bound]
  cases dynamic : result.dynamicSeen
  · simp [Bound.staticPart, Bound.dynamicPart]
  · simp [Bound.staticPart, Bound.dynamicPart, zero dynamic]

def ValueResult.expression (value : ValueResult) : ExpressionResult :=
  ⟨value.after, value.staticLength, value.dynamicSeen⟩

inductive ExpressionTailAt (text : Source) (names : BindingEnvironment) :
    Nat → Nat → Nat → Bool → Expression → ExpressionResult → Prop
  | last {remaining position length : Nat} {dynamicSeen : Bool} {atom : Operand} {value : ValueResult} :
      ValueAt text names position atom value →
      fitsAccumulator value.expression length dynamicSeen = true →
      fixedAfter text value.after "&" false = 0 →
      ExpressionTailAt text names (remaining + 1) position length dynamicSeen [atom]
        (accumulated value.expression length dynamicSeen)
  | next {remaining position length : Nat} {dynamicSeen : Bool} {atom : Operand} {value : ValueResult}
      {rest : Expression} {result : ExpressionResult} :
      ValueAt text names position atom value →
      fitsAccumulator value.expression length dynamicSeen = true →
      fixedAfter text value.after "&" false ≠ 0 →
      ExpressionTailAt text names remaining (fixedAfter text value.after "&" false)
        (length + value.staticLength) (dynamicSeen || value.dynamicSeen) rest result →
      ExpressionTailAt text names (remaining + 1) position length dynamicSeen (atom :: rest) result

def ExpressionAt (text : Source) (names : BindingEnvironment) (position : Nat)
    (expression : Expression) (result : ExpressionResult) : Prop :=
  ExpressionTailAt text names maxExpressionOperands position 0 false expression result

theorem expressionTail_complete {text : Source} {names : BindingEnvironment}
    {remaining position length : Nat} {dynamicSeen : Bool} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text names remaining position length dynamicSeen expression result) :
    expressionTail text names remaining position length dynamicSeen = result := by
  induction parsed with
  | last atom fits stop =>
      simp only [ValueResult.expression] at fits
      simp only [expressionTail, operandAt, value_complete atom, fits, ↓reduceIte, stop, ne_eq, not_true_eq_false, ValueResult.expression]
  | next atom fits more rest ih =>
      simp only [ValueResult.expression] at fits
      simp only [expressionTail, operandAt, value_complete atom, fits, ↓reduceIte]
      split
      · exact ih
      · rename_i absent
        exact False.elim (absent more)

theorem expressionTail_sound (text : Source) (names : BindingEnvironment) (remaining position length : Nat)
    (dynamicSeen : Bool) (accepted : (expressionTail text names remaining position length dynamicSeen).after ≠ 0) :
    ∃ expression, ExpressionTailAt text names remaining position length dynamicSeen expression
      (expressionTail text names remaining position length dynamicSeen) := by
  induction remaining generalizing position length dynamicSeen with
  | zero => simp [expressionTail, invalidExpression] at accepted
  | succ remaining ih =>
      by_cases fits : fitsAccumulator (operandAt text position names) length dynamicSeen = true
      · have valueAccepted : (valueAt text position names).after ≠ 0 := by
          simp only [fitsAccumulator, Bool.and_eq_true, decide_eq_true_eq] at fits
          exact fits.1.1
        obtain ⟨atom, parsed⟩ := value_sound text position names valueAccepted
        by_cases more : fixedAfter text (operandAt text position names).after "&" false ≠ 0
        · have restAccepted : (expressionTail text names remaining
              (fixedAfter text (operandAt text position names).after "&" false)
              (length + (operandAt text position names).staticLength)
              (dynamicSeen || (operandAt text position names).dynamicSeen)).after ≠ 0 := by
            simpa [expressionTail, fits, more] using accepted
          obtain ⟨rest, restParsed⟩ := ih _ _ _ restAccepted
          refine ⟨atom :: rest, ?_⟩
          rw [expressionTail]
          simp only [fits, ↓reduceIte]
          rw [ite_eq_left more]
          exact .next parsed fits more restParsed
        · refine ⟨[atom], ?_⟩
          rw [expressionTail]
          simp only [fits, ↓reduceIte]
          rw [ite_eq_right more]
          have stop : fixedAfter text (operandAt text position names).after "&" false = 0 := by omega
          exact .last parsed fits (by simpa only [operandAt] using stop)
      · simp [expressionTail, fits, invalidExpression] at accepted

theorem expressionTail_readable {text : Source} {names : BindingEnvironment}
    {remaining position length : Nat} {dynamicSeen : Bool} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text names remaining position length dynamicSeen expression result) :
    expression.Readable names.shape ∧ expression.LiteralsPrintable := by
  induction parsed with
  | last atom _ _ =>
      constructor
      · intro item member
        have same := List.mem_singleton.mp member
        subst item
        exact ⟨_, value_infer atom⟩
      · intro item member
        have same := List.mem_singleton.mp member
        subst item
        exact value_literals atom
  | next atom _ _ _ ih =>
      constructor
      · intro item member
        rcases List.mem_cons.mp member with rfl | present
        · exact ⟨_, value_infer atom⟩
        · exact ih.1 item present
      · intro item member
        rcases List.mem_cons.mp member with rfl | present
        · exact value_literals atom
        · exact ih.2 item present


theorem expressionTail_count {text : Source} {names : BindingEnvironment}
    {remaining position length : Nat} {dynamicSeen : Bool} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text names remaining position length dynamicSeen expression result) :
    expression ≠ [] ∧ expression.length ≤ remaining := by
  induction parsed with
  | last => simp
  | next _ _ _ _ ih => simpa using Nat.succ_le_succ ih.2

theorem expressionTail_staticLength {text : Source} {names : BindingEnvironment}
    {remaining position length : Nat} {dynamicSeen : Bool} {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names)
    (parsed : ExpressionTailAt text names remaining position length dynamicSeen expression result) :
    result.staticLength = length + expression.staticLength names.shape := by
  induction parsed with
  | last atom _ _ =>
      simp [accumulated, ValueResult.expression, Expression.staticLength, (value_summary normal atom).1]
  | next atom _ _ _ ih =>
      simpa [Expression.staticLength, (value_summary normal atom).1, Nat.add_assoc] using ih

theorem expressionTail_dynamicCount {text : Source} {names : BindingEnvironment}
    {remaining position length : Nat} {dynamicSeen : Bool} {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names)
    (parsed : ExpressionTailAt text names remaining position length dynamicSeen expression result) :
    (if dynamicSeen then 1 else 0) + expression.dynamicCount names.shape ≤ 1 := by
  induction parsed with
  | @last remaining position length dynamicSeen atom value parsed fits stop =>
      have counted := (value_summary normal parsed).2
      cases dynamicSeen <;> cases seen : value.dynamicSeen <;>
        simp_all [fitsAccumulator, ValueResult.expression, Expression.dynamicCount]
  | @next remaining position length dynamicSeen atom value rest result parsed fits more previous ih =>
      have counted := (value_summary normal parsed).2
      cases dynamicSeen <;> cases seen : value.dynamicSeen <;>
        simp_all [fitsAccumulator, ValueResult.expression, Expression.dynamicCount]

theorem expressionTail_dynamicSeen {text : Source} {names : BindingEnvironment}
    {remaining position length : Nat} {dynamicSeen : Bool} {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names)
    (parsed : ExpressionTailAt text names remaining position length dynamicSeen expression result) :
    result.dynamicSeen = (dynamicSeen || decide (0 < expression.dynamicCount names.shape)) := by
  induction parsed with
  | @last remaining position length dynamicSeen atom value parsed fits stop =>
      have counted := (value_summary normal parsed).2
      cases seen : value.dynamicSeen <;>
        simp [accumulated, ValueResult.expression, Expression.dynamicCount, counted, seen]
  | @next remaining position length dynamicSeen atom value rest result parsed fits more previous ih =>
      have counted := (value_summary normal parsed).2
      rw [ih]
      cases seen : value.dynamicSeen <;>
        simp [Expression.dynamicCount, counted, seen] <;> omega

theorem expressionTail_length_bound {text : Source} {names : BindingEnvironment}
    {remaining position length : Nat} {dynamicSeen : Bool} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text names remaining position length dynamicSeen expression result) :
    result.staticLength ≤ maxSourceLength := by
  induction parsed with
  | last _ fits _ =>
      simp only [fitsAccumulator, Bool.and_eq_true, decide_eq_true_eq] at fits
      exact fits.1.2
  | next _ _ _ _ ih => exact ih

theorem expressionAt_safe {text : Source} {names : BindingEnvironment} {position capacity : Nat}
    {expression : Expression} {result : ExpressionResult} (normal : NamesNormal names)
    (parsed : ExpressionAt text names position expression result)
    (safe : result.staticLength + (if result.dynamicSeen then capacity else 0) ≤ maxSourceLength) :
    SafeExpression expression names.shape capacity := by
  have nonempty := expressionTail_count parsed
  have fixed := expressionTail_staticLength normal parsed
  have counted := expressionTail_dynamicCount normal parsed
  have seen := expressionTail_dynamicSeen normal parsed
  simp only [Bool.false_or, Nat.zero_add, Bool.false_eq_true, ↓reduceIte] at fixed counted seen
  refine ⟨(expressionTail_readable parsed).1, (expressionTail_readable parsed).2,
    nonempty.1, nonempty.2, counted, ?_⟩
  rw [fixed, seen] at safe
  have possibilities : expression.dynamicCount names.shape = 0 ∨ expression.dynamicCount names.shape = 1 := by omega
  rcases possibilities with zero | one
  · simpa [zero] using safe
  · simpa [one] using safe

theorem expressionTail_unique {text : Source} {names : BindingEnvironment}
    {remaining position length : Nat} {dynamicSeen : Bool} {left right : Expression}
    {leftResult rightResult : ExpressionResult}
    (first : ExpressionTailAt text names remaining position length dynamicSeen left leftResult)
    (second : ExpressionTailAt text names remaining position length dynamicSeen right rightResult) :
    left = right ∧ leftResult = rightResult := by
  have results := (expressionTail_complete first).symm.trans (expressionTail_complete second)
  refine ⟨?_, results⟩
  induction first generalizing right rightResult with
  | last atom fits stop =>
      cases second with
      | last other _ _ => exact congrArg (fun x => [x]) (value_unique atom other).1
      | next other _ more _ =>
          obtain ⟨_, same⟩ := value_unique atom other
          exact False.elim (more (same ▸ stop))
  | next atom fits more rest ih =>
      cases second with
      | last other _ stop =>
          obtain ⟨_, same⟩ := value_unique atom other
          exact False.elim (more (same.symm ▸ stop))
      | next other _ _ tail =>
          obtain ⟨rfl, rfl⟩ := value_unique atom other
          exact congrArg (List.cons _) (ih tail (expressionTail_complete rest |>.symm.trans (expressionTail_complete tail)))

end Silver.Compose
