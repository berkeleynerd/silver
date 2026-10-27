module

public import Silver.ComposeAdmission
public import Silver.StringExecution

@[expose] public section

namespace Silver.Compose
open Named Bindings

theorem value_unique {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {left right : Operand} {leftResult rightResult : ValueResult}
    (first : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position left leftResult)
    (second : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position right rightResult) :
    left = right ∧ leftResult = rightResult := by
  have results := (value_complete first).symm.trans (value_complete second)
  refine ⟨?_, results⟩
  cases first with
  | literal _ _ quote parsed =>
      cases second with
      | literal _ _ _ other => exact congrArg Bindings.Value.literal (Output.literalAt_unique parsed other).1
      | reference _ name _ _ _ _ => exact False.elim (identifier_not_quote name quote)
      | image =>
          have different := congrArg ValueResult.nonliteralSeen results
          simp [imageValue] at different
  | reference _ name _ positive _ _ =>
      cases second with
      | literal _ _ quote _ => exact False.elim (identifier_not_quote name quote)
      | reference => exact congrArg Bindings.Value.reference (congrArg ValueResult.reference results)
      | image =>
          have different := congrArg ValueResult.reference results
          simp only [imageValue] at different
          exact False.elim (positive different)
  | image _ _ parsed =>
      cases second with
      | literal =>
          have different := congrArg ValueResult.nonliteralSeen results
          simp [imageValue] at different
      | reference _ _ _ positive _ _ =>
          have different := congrArg ValueResult.reference results
          simp only [imageValue] at different
          exact False.elim (positive different.symm)
      | image _ _ other =>
          exact congrArg Bindings.Value.image (ScalarExpression.at_unique parsed.scalar other.scalar).1

/-- The source scanner emits an atom only at an operand position. Parentheses
and separators preserve its order; the grouping theorem covers all trees over
that ordered list, including every bounded intermediate. -/
def EmissionAt (text : Source) (names : BindingEnvironment) (state : ExpressionState)
    (emitted : Expression) (scalarNames : ScalarExpression.Environment := []) (integerHidden : Bool := false) (arrays : ArrayBindings.Metadata := [])
    (initials : ArrayBindings.Initials := []) (elaborating : Bool := false) : Prop :=
  if state.needOperand = true ∧ fixedAfter text state.position "(" false = 0 then
    ∃ atom, ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state.position atom (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names) ∧ emitted = [atom]
  else emitted = []

theorem emission_sound {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {state : ExpressionState}
    (positive : state.position ≠ 0) (unfinished : state.complete = false)
    (accepted : (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).position ≠ 0) :
    ∃ emitted, EmissionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state emitted := by
  by_cases reading : state.needOperand = true ∧ fixedAfter text state.position "(" false = 0
  · have success : (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names).after ≠ 0 := by
      by_cases failed : (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names).after = 0
      · simp [expressionStep, positive, unfinished, reading.1, reading.2, failed, invalidExpressionState] at accepted
      · exact failed
    obtain ⟨atom, parsed⟩ := value_sound text state.position names success
    exact ⟨[atom], by rw [EmissionAt, ite_eq_left reading]; exact ⟨atom, parsed, rfl⟩⟩
  · exact ⟨[], by rw [EmissionAt, ite_eq_right reading]⟩

theorem emission_unique {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {state : ExpressionState}
    {left right : Expression} (first : EmissionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state left)
    (second : EmissionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state right) : left = right := by
  unfold EmissionAt at first second
  split at first
  · rename_i reading
    rw [ite_eq_left reading] at second
    obtain ⟨a, parsed, rfl⟩ := first
    obtain ⟨b, other, rfl⟩ := second
    exact congrArg (fun x => [x]) (value_unique parsed other).1
  · rename_i notReading
    rw [ite_eq_right notReading] at second
    exact first.trans second.symm

theorem value_readable {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult}
    (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    value.StringReadable names.shape := by
  cases parsed with
  | literal | image => trivial
  | reference positive identifier selected nonzero unmasked present =>
      rename_i after index name info
      exact ⟨info.cell, by simp [BindingEnvironment.shape, present]⟩

theorem emission_readable {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {state : ExpressionState}
    {emitted : Expression} (parsed : EmissionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state emitted) :
    emitted.StringReadable names.shape ∧ emitted.LiteralsPrintable := by
  unfold EmissionAt at parsed
  split at parsed
  · obtain ⟨atom, source, rfl⟩ := parsed
    constructor
    · intro item member
      have same := List.mem_singleton.mp member
      subst item
      exact value_readable source
    · intro item member
      have same := List.mem_singleton.mp member
      subst item
      exact value_literals source
  · subst emitted
    simp [Expression.StringReadable, Expression.LiteralsPrintable]

theorem emission_accounting {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {state : ExpressionState}
    {emitted : Expression} (normal : NamesNormal names)
    (positive : state.position ≠ 0) (unfinished : state.complete = false)
    (accepted : (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).position ≠ 0)
    (bounded : state.operands ≤ maxExpressionOperands)
    (parsed : EmissionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state emitted) :
    ∃ summary, emitted.inferLength names.shape (ArrayBindings.ranges arrays initials elaborating (ScalarExpression.ranges scalarNames)) = some summary ∧
      (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).lengthSummary =
        state.lengthSummary.add summary ∧
      (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).operands = state.operands + emitted.length ∧
      (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).operands ≤ maxExpressionOperands ∧
      (state.needOperand = true → emitted = [] →
        (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).needOperand = true ∧
          (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).complete = false) := by
  by_cases reading : state.needOperand = true ∧ fixedAfter text state.position "(" false = 0
  · rw [EmissionAt, ite_eq_left reading] at parsed
    obtain ⟨atom, source, rfl⟩ := parsed
    have allowed : ¬(state.operands = maxExpressionOperands ∨
        (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names).after = 0 ∨
        (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names).staticLength > maxSourceLength - state.staticLength ∨
        (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names).minimumLength > maxSourceLength - state.minimumLength) := by
      intro failed
      simp [expressionStep, positive, unfinished, reading.1, reading.2, failed, invalidExpressionState] at accepted
    have inferred := value_inferLength normal source
    refine ⟨(valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names).lengthSummary, ?_, ?_⟩
    · simp only [Expression.inferLength, inferred, Option.bind_some, Option.map_some, LengthSummary.add_zero]
    · simp only [expressionStep, positive, unfinished, Bool.false_eq_true, ↓reduceIte, reading.1,
        reading.2, ne_eq, not_true_eq_false, allowed, List.length_singleton]
      exact ⟨rfl, True.intro, by omega, by simp⟩
  · rw [EmissionAt, ite_eq_right reading] at parsed
    subst emitted
    refine ⟨{}, rfl, ?_⟩
    simp only [LengthSummary.add_zero, List.length_nil, Nat.add_zero]
    by_cases need : state.needOperand = true
    · have opening : fixedAfter text state.position "(" false ≠ 0 := fun absent => reading ⟨need, absent⟩
      simp [expressionStep, positive, unfinished, need, opening, ExpressionState.lengthSummary, bounded]
    · simp only [expressionStep, positive, unfinished, Bool.false_eq_true, ↓reduceIte, need]
      split
      · exact ⟨rfl, rfl, bounded, fun contradiction => False.elim contradiction⟩
      · rename_i noJoin
        split
        · exact ⟨rfl, rfl, bounded, fun contradiction => False.elim contradiction⟩
        · rename_i noClose
          split
          · exact ⟨rfl, rfl, bounded, fun contradiction => False.elim contradiction⟩
          · rename_i noEnd
            have closeZero : fixedAfter text state.position ")" false = 0 := by
              by_cases zero : fixedAfter text state.position ")" false = 0
              · exact zero
              · exact False.elim (noClose ⟨zero, noEnd⟩)
            simp [expressionStep, positive, unfinished, need, noJoin, closeZero, noEnd, invalidExpressionState] at accepted

inductive ExpressionTailAtCore (text : Source) (names : BindingEnvironment)
    (scalarNames : ScalarExpression.Environment) (integerHidden : Bool)
    (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    ExpressionState → Expression → ExpressionResult → Prop
  | done {state} : state.position ≠ 0 → state.complete = true →
      ExpressionTailAtCore text names scalarNames integerHidden arrays initials elaborating state [] state.result
  | last {state emitted} : state.position ≠ 0 → state.complete = false →
      (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).position ≠ 0 →
      (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).complete = true →
      EmissionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state emitted →
      ExpressionTailAtCore text names scalarNames integerHidden arrays initials elaborating state emitted (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).result
  | next {state emitted rest result} : state.position ≠ 0 → state.complete = false →
      (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).position ≠ 0 →
      (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).complete = false →
      text.length + 1 - (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).position < text.length + 1 - state.position →
      EmissionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state emitted →
      ExpressionTailAtCore text names scalarNames integerHidden arrays initials elaborating (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state) rest result →
      ExpressionTailAtCore text names scalarNames integerHidden arrays initials elaborating state (emitted ++ rest) result

abbrev ExpressionTailAt (text : Source) (names : BindingEnvironment) (state : ExpressionState)
    (expression : Expression) (result : ExpressionResult) (scalarNames : ScalarExpression.Environment := []) (integerHidden : Bool := false) (arrays : ArrayBindings.Metadata := [])
    (initials : ArrayBindings.Initials := []) (elaborating : Bool := false) : Prop :=
  ExpressionTailAtCore text names scalarNames integerHidden arrays initials elaborating state expression result

def ExpressionAt (text : Source) (names : BindingEnvironment) (position : Nat)
    (expression : Expression) (result : ExpressionResult)
    (scalarNames : ScalarExpression.Environment := []) (integerHidden : Bool := false) (arrays : ArrayBindings.Metadata := [])
    (initials : ArrayBindings.Initials := []) (elaborating : Bool := false) : Prop :=
  ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names {position := position} expression result

theorem expressionTail_complete {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression result) :
    expressionTail (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state = result := by
  induction parsed with
  | done positive finished => rw [expressionTail]; simp only [positive, finished, ↓reduceIte]
  | last positive unfinished nextPositive finished _ =>
      rw [expressionTail]
      simp only [positive, unfinished, Bool.false_eq_true, ↓reduceIte, nextPositive, finished]
  | next positive unfinished nextPositive nextUnfinished advancing _ _ ih =>
      rw [expressionTail]
      simp only [positive, unfinished, Bool.false_eq_true, ↓reduceIte, nextPositive, nextUnfinished,
        advancing, ↓reduceDIte, ih]

theorem expressionTail_sound (text : Source) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} (state : ExpressionState)
    (accepted : (expressionTail (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).after ≠ 0) :
    ∃ expression, ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression (expressionTail (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state) := by
  by_cases positive : state.position = 0
  · rw [expressionTail] at accepted
    simp only [positive, ↓reduceIte, invalidExpression, ne_eq, not_true_eq_false] at accepted
  · by_cases finished : state.complete = true
    · refine ⟨[], ?_⟩
      rw [expressionTail]
      simpa only [positive, finished, ↓reduceIte] using ExpressionTailAtCore.done positive finished
    · have unfinished : state.complete = false := Bool.eq_false_iff.mpr finished
      by_cases nextPositive : (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).position = 0
      · rw [expressionTail] at accepted
        simp only [positive, unfinished, Bool.false_eq_true, ↓reduceIte, nextPositive, invalidExpression,
          ne_eq, not_true_eq_false] at accepted
      · obtain ⟨emitted, emission⟩ := emission_sound positive unfinished nextPositive
        by_cases nextFinished : (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).complete = true
        · refine ⟨emitted, ?_⟩
          rw [expressionTail]
          simpa only [positive, unfinished, Bool.false_eq_true, ↓reduceIte, nextPositive, nextFinished]
            using ExpressionTailAtCore.last positive unfinished nextPositive nextFinished emission
        · have nextUnfinished : (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).complete = false := Bool.eq_false_iff.mpr nextFinished
          by_cases advancing : text.length + 1 - (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).position < text.length + 1 - state.position
          · have reduced : expressionTail (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state = expressionTail (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state) := by
              rw [expressionTail]
              simp only [positive, unfinished, Bool.false_eq_true, ↓reduceIte, nextPositive, nextUnfinished, advancing, ↓reduceDIte]
            obtain ⟨rest, parsed⟩ := expressionTail_sound text names (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state) (reduced ▸ accepted)
            refine ⟨emitted ++ rest, ?_⟩
            rw [reduced]
            exact .next positive unfinished nextPositive nextUnfinished advancing emission parsed
          · rw [expressionTail] at accepted
            simp only [positive, unfinished, Bool.false_eq_true, ↓reduceIte, nextPositive, nextUnfinished,
              advancing, ↓reduceDIte, invalidExpression, ne_eq, not_true_eq_false] at accepted
termination_by text.length + 1 - state.position

theorem expressionAt_sound (text : Source) (names : BindingEnvironment) {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} (position : Nat)
    (accepted : (expressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names).after ≠ 0) :
    ∃ expression, ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position expression (expressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text position names) :=
  expressionTail_sound text names _ accepted

theorem expressionTail_readable {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression result) :
    expression.StringReadable names.shape ∧ expression.LiteralsPrintable := by
  induction parsed with
  | done => simp [Expression.StringReadable, Expression.LiteralsPrintable]
  | last _ _ _ _ emitted => exact emission_readable emitted
  | next _ _ _ _ _ emitted _ ih =>
      have first := emission_readable emitted
      constructor
      · intro atom present
        rcases List.mem_append.mp present with before | after
        · exact first.1 atom before
        · exact ih.1 atom after
      · intro atom present
        rcases List.mem_append.mp present with before | after
        · exact first.2 atom before
        · exact ih.2 atom after

theorem expressionTail_count {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names) (bounded : state.operands ≤ maxExpressionOperands)
    (parsed : ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression result) :
    state.operands + expression.length ≤ maxExpressionOperands := by
  induction parsed with
  | done => simpa using bounded
  | last positive unfinished accepted _ emitted =>
      obtain ⟨summary, inferred, facts⟩ := emission_accounting normal positive unfinished accepted bounded emitted
      omega
  | next positive unfinished accepted _ _ emitted _ ih =>
      obtain ⟨summary, inferred, facts⟩ := emission_accounting normal positive unfinished accepted bounded emitted
      have remaining := ih facts.2.2.1
      simp only [List.length_append]
      omega

theorem expressionTail_nonempty {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names) (bounded : state.operands ≤ maxExpressionOperands)
    (need : state.needOperand = true) (unfinished : state.complete = false)
    (parsed : ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression result) : expression ≠ [] := by
  intro empty
  induction parsed with
  | done _ finished => simp [unfinished] at finished
  | last positive incomplete accepted finished emitted =>
      obtain ⟨summary, inferred, facts⟩ := emission_accounting normal positive incomplete accepted bounded emitted
      have impossible := facts.2.2.2 need empty
      simp [impossible.2] at finished
  | next positive incomplete accepted _ _ emitted _ ih =>
      obtain ⟨firstEmpty, restEmpty⟩ := List.append_eq_nil_iff.mp empty
      obtain ⟨summary, inferred, facts⟩ := emission_accounting normal positive incomplete accepted bounded emitted
      have next := facts.2.2.2 need firstEmpty
      exact ih facts.2.2.1 next.1 next.2 restEmpty

theorem expressionTail_summary {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names) (bounded : state.operands ≤ maxExpressionOperands)
    (parsed : ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression result) :
    ∃ summary, expression.inferLength names.shape (ArrayBindings.ranges arrays initials elaborating (ScalarExpression.ranges scalarNames)) = some summary ∧
      result.lengthSummary = state.lengthSummary.add summary := by
  induction parsed with
  | done => exact ⟨{}, rfl, by simp [ExpressionState.result, ExpressionResult.lengthSummary, ExpressionState.lengthSummary]⟩
  | last positive unfinished accepted _ emitted =>
      obtain ⟨summary, inferred, facts⟩ := emission_accounting normal positive unfinished accepted bounded emitted
      exact ⟨summary, inferred, facts.1⟩
  | next positive unfinished accepted _ _ emitted _ ih =>
      obtain ⟨first, inferred, facts⟩ := emission_accounting normal positive unfinished accepted bounded emitted
      obtain ⟨remaining, restInferred, resultSummary⟩ := ih facts.2.2.1
      refine ⟨first.add remaining, ?_, ?_⟩
      · simp only [Expression.inferLength_append, inferred, restInferred, Option.bind_some, Option.map_some]
      · rw [resultSummary, facts.1, LengthSummary.add_assoc]

theorem expressionAt_inferLength {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {expression : Expression} {result : ExpressionResult} (normal : NamesNormal names)
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position expression result) :
    expression.inferLength names.shape (ArrayBindings.ranges arrays initials elaborating (ScalarExpression.ranges scalarNames)) = some result.lengthSummary := by
  obtain ⟨summary, inferred, same⟩ := expressionTail_summary normal (by simp) parsed
  have initial : (ExpressionState.lengthSummary {position := position}) = ({} : LengthSummary) := rfl
  rw [initial, LengthSummary.zero_add] at same
  rwa [same]

theorem expressionTail_unique {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {left right : Expression} {leftResult rightResult : ExpressionResult}
    (first : ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state left leftResult)
    (second : ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state right rightResult) :
    left = right ∧ leftResult = rightResult := by
  have results := (expressionTail_complete first).symm.trans (expressionTail_complete second)
  refine ⟨?_, results⟩
  induction first generalizing right rightResult with
  | done _ finished =>
      cases second with
      | done => rfl
      | last _ unfinished => simp [finished] at unfinished
      | next _ unfinished => simp [finished] at unfinished
  | last _ unfinished _ finished emitted =>
      cases second with
      | done _ other => simp [other] at unfinished
      | last _ _ _ _ other => exact emission_unique emitted other
      | next _ _ _ notFinished => simp [finished] at notFinished
  | next _ unfinished _ nextUnfinished _ emitted previous ih =>
      cases second with
      | done _ other => simp [other] at unfinished
      | last _ _ _ finished => simp [finished] at nextUnfinished
      | next _ _ _ _ _ other tail =>
          rw [emission_unique emitted other]
          exact congrArg (List.append _) (ih tail ((expressionTail_complete previous).symm.trans (expressionTail_complete tail)))

/-- Completion can be produced only after an operand and outside every pair
of parentheses. The source trace therefore cannot finish a malformed grouping. -/
theorem expressionStep_finished {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {state : ExpressionState}
    (positive : state.position ≠ 0) (unfinished : state.complete = false)
    (finished : (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).complete = true) :
    (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).needOperand = false ∧
      (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).depth = 0 := by
  dsimp only [expressionStep] at finished ⊢
  simp only [positive, unfinished, Bool.false_eq_true, ↓reduceIte] at finished ⊢
  by_cases need : state.needOperand = true
  · simp only [need, ↓reduceIte] at finished
    split at finished
    · simp at finished
    · split at finished <;> simp_all [invalidExpressionState]
  · simp only [need, Bool.false_eq_true, ↓reduceIte] at finished ⊢
    split at finished
    · simp at finished
    · rename_i noJoin
      rw [ite_eq_right noJoin]
      split at finished
      · simp at finished
      · rename_i noClose
        rw [ite_eq_right noClose]
        split at finished
        · rename_i empty
          rw [ite_eq_left empty]
          exact ⟨rfl, empty⟩
        · simp [invalidExpressionState] at finished

theorem expressionTail_balanced {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {expression : Expression} {result : ExpressionResult}
    (initial : state.complete = true → state.needOperand = false ∧ state.depth = 0)
    (parsed : ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression result) :
    ∃ final : ExpressionState, result = final.result ∧ final.complete = true ∧
      final.needOperand = false ∧ final.depth = 0 := by
  induction parsed with
  | done positive finished => exact ⟨_, rfl, finished, initial finished⟩
  | last positive unfinished _ finished _ =>
      exact ⟨_, rfl, finished, expressionStep_finished positive unfinished finished⟩
  | next _ _ _ unfinished _ _ _ ih =>
      exact ih (by intro finished; simp [unfinished] at finished)

theorem expressionAt_balanced {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position : Nat} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position expression result) :
    ∃ final : ExpressionState, result = final.result ∧ final.complete = true ∧
      final.needOperand = false ∧ final.depth = 0 :=
  expressionTail_balanced (by simp) parsed

def Operand.isNamed : Operand → Bool
  | .reference _ | .image _ => true
  | _ => false

def Expression.hasName (expression : Expression) : Bool := expression.any Operand.isNamed

theorem value_named {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {position : Nat}
    {value : Operand} {result : ValueResult} (parsed : ValueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position value result) :
    value.isNamed = result.nonliteralSeen := by
  cases parsed with
  | literal => rfl
  | reference | image => rfl

theorem emission_named {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {state : ExpressionState}
    {emitted : Expression} (positive : state.position ≠ 0) (unfinished : state.complete = false)
    (accepted : (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).position ≠ 0)
    (parsed : EmissionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state emitted) :
    (expressionStep (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state).namedSeen = (state.namedSeen || emitted.hasName) := by
  by_cases reading : state.needOperand = true ∧ fixedAfter text state.position "(" false = 0
  · rw [EmissionAt, ite_eq_left reading] at parsed
    obtain ⟨atom, source, rfl⟩ := parsed
    have allowed : ¬(state.operands = maxExpressionOperands ∨ (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names).after = 0 ∨
        (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names).staticLength > maxSourceLength - state.staticLength ∨
        (valueAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text state.position names).minimumLength > maxSourceLength - state.minimumLength) := by
      intro failed
      simp [expressionStep, positive, unfinished, reading.1, reading.2, failed, invalidExpressionState] at accepted
    simp [expressionStep, positive, unfinished, reading.1, reading.2, allowed, Expression.hasName, value_named source]
  · rw [EmissionAt, ite_eq_right reading] at parsed
    subst emitted
    by_cases need : state.needOperand = true
    · have opening : fixedAfter text state.position "(" false ≠ 0 := fun absent => reading ⟨need, absent⟩
      simp [expressionStep, positive, unfinished, need, opening, Expression.hasName]
    · simp only [expressionStep, positive, unfinished, Bool.false_eq_true, ↓reduceIte, need,
        Expression.hasName, List.any_nil, Bool.or_false]
      split
      · rfl
      · rename_i noJoin
        split
        · rfl
        · rename_i noClose
          split
          · rfl
          · rename_i noEnd
            have closeZero : fixedAfter text state.position ")" false = 0 := by
              by_cases zero : fixedAfter text state.position ")" false = 0
              · exact zero
              · exact False.elim (noClose ⟨zero, noEnd⟩)
            simp [expressionStep, positive, unfinished, need, noJoin, closeZero, noEnd, invalidExpressionState] at accepted

theorem expressionTail_named {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {state : ExpressionState} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names state expression result) :
    result.namedSeen = (state.namedSeen || expression.hasName) := by
  induction parsed with
  | done => simp [ExpressionState.result, Expression.hasName]
  | last positive unfinished accepted _ emitted => exact emission_named positive unfinished accepted emitted
  | next positive unfinished accepted _ _ emitted _ ih =>
      rw [ih, emission_named positive unfinished accepted emitted]
      simp [Expression.hasName, List.any_append, Bool.or_assoc]

theorem expressionAt_named {text : Source} {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position : Nat} {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position expression result) : result.namedSeen = expression.hasName := by
  simpa using expressionTail_named parsed


/-- A source derivation fixes atom order and verifies every bracket/operand
transition. Every association of those atoms has the same value; all of its
subexpressions satisfy the same source-position capacity bound. -/
theorem expressionAt_grouped_semantics {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool} {integers : Integer.Store}
    {position capacity : Nat} {expression : Expression} {result : ExpressionResult}
    {whole part : GroupedExpression} {values : Values} {input : Source}
    (normal : NamesNormal names)
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := elaborating) text names position expression result)
    (fitsResult : fits result capacity = true) (state : Fits names.shape input values)
    (scalarState : Integer.Fits (ArrayBindings.ranges arrays initials elaborating (ScalarExpression.ranges scalarNames)) integers)
    (inputBound : input.length ≤ capacity) (ordered : whole.flatten = expression)
    (subexpression : GroupedExpression.Subexpression part whole) :
    whole.evaluate values input integers = expression.evaluate values input integers ∧
      (part.evaluate values input integers).length ≤ maxSourceLength := by
  have known := expressionAt_inferLength normal parsed
  have nonempty := (Expression.inferLength_sound known state scalarState).1.1
  change result.emptyValue = false at nonempty
  have fitsBound : result.lengthSummary.upper.length capacity ≤ maxSourceLength := by
    have checked := (decide_eq_true_eq.mp fitsResult).2
    simpa only [ExpressionResult.lengthSummary, nonempty, Bool.false_eq_true, false_or,
      LengthSummary.upper, Summary.length] using checked
  have bound := Expression.inferLength_bound known state scalarState fitsBound inputBound
  have same : whole.evaluate values input integers = expression.evaluate values input integers := by
    rw [← GroupedExpression.flatten_evaluate whole values input integers, ordered]
  refine ⟨same, ?_⟩
  rw [← same] at bound
  exact Nat.le_trans (GroupedExpression.subexpression_length subexpression values input integers) bound

end Silver.Compose
