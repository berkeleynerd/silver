module

public import Silver.PredicateStringActualBounds

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts

def Condition.ActualBoundsSafe (bounds : BoundsStore) (names : Compose.BindingEnvironment) (values : Values)
    (input : Source) (valid : Bool) (integers : Integer.Store) (booleans : Boolean.Store) : Condition → Prop
  | .stringCompare _ left right => left.ActualBoundsSafe bounds names values input integers ∧
      right.ActualBoundsSafe bounds names values input integers
  | .parenthesized inner | .negated inner => inner.ActualBoundsSafe bounds names values input valid integers booleans
  | .andThen left right => left.ActualBoundsSafe bounds names values input valid integers booleans ∧
      (left.evaluate values input valid integers booleans = true → right.ActualBoundsSafe bounds names values input valid integers booleans)
  | .orElse left right => left.ActualBoundsSafe bounds names values input valid integers booleans ∧
      (left.evaluate values input valid integers booleans = false → right.ActualBoundsSafe bounds names values input valid integers booleans)
  | .eager _ left right | .booleanCompare _ left right =>
      left.ActualBoundsSafe bounds names values input valid integers booleans ∧
        right.ActualBoundsSafe bounds names values input valid integers booleans
  | _ => True

theorem Condition.actualBoundsSafe {bounds : BoundsStore} {names : Compose.BindingEnvironment}
    {values : Values} {input : Source} {valid : Bool} {integers : Integer.Store} {booleans : Boolean.Store}
    {condition : Condition} (compatible : bounds.Compatible names input)
    (origin : condition.BoundsOrigin names) (safe : condition.ObjectBoundsSafe names values input valid integers booleans) :
    condition.ActualBoundsSafe bounds names values input valid integers booleans := by
  induction condition with
  | stringCompare => exact ⟨Expression.actualBoundsSafe compatible origin.1 safe.1,
      Expression.actualBoundsSafe compatible origin.2 safe.2⟩
  | parenthesized inner ih | negated inner ih => exact ih origin safe
  | andThen left right ihl ihr | orElse left right ihl ihr =>
      exact ⟨ihl origin.1 safe.1, fun reached => ihr origin.2 (safe.2 reached)⟩
  | eager operator left right ihl ihr | booleanCompare unequal left right ihl ihr =>
      exact ⟨ihl origin.1 safe.1, ihr origin.2 safe.2⟩
  | lengthCompare | scalarCompare | characterCompare | inputValid | booleanLiteral | booleanName | booleanArrayRead => trivial

def SimpleActualBoundsSafe (bounds : BoundsStore) (names : Compose.BindingEnvironment) (values : Values)
    (input : Source) (integers : Integer.Store) : Sequence.SimpleStatement → Prop
  | .null => True
  | .assign update => update.value.ActualBoundsSafe bounds names values input integers
  | .output expression | .put expression => expression.ActualBoundsSafe bounds names values input integers

mutual
  def Statement.ActualBoundsSafe (bounds : BoundsStore) (names : Compose.BindingEnvironment) (input : Source) (valid : Bool)
      (values : Values) (item : Statement) (integers : Integer.Store) (booleans : Boolean.Store) : Prop :=
    match item with
    | .simple item => SimpleActualBoundsSafe bounds names values input integers item
    | .booleanAssign update => update.value.ActualBoundsSafe bounds names values input valid integers booleans
    | .scalarAssign _ | .arrayAssign _ | .reject => True
    | .choice condition yes no =>
        condition.ActualBoundsSafe bounds names values input valid integers booleans ∧
          if condition.evaluate values input valid integers booleans
          then StatementsActualBoundsSafe bounds names input valid values yes integers booleans
          else StatementsActualBoundsSafe bounds names input valid values no integers booleans
    | .forLoop index reverse lower upper body =>
        IterationsObjectBoundsSafe
          (fun current scalars flags value =>
            (executeStatements input valid current body (Integer.put scalars index value) flags).restoreIndex index scalars)
          (fun current scalars flags value =>
            StatementsActualBoundsSafe bounds names input valid current body (Integer.put scalars index value) flags)
          values integers booleans (Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers))
    | .arrayLoop index reverse array body =>
        IterationsObjectBoundsSafe
          (fun current scalars flags component =>
            (executeStatements input valid current body
              (Integer.put scalars index (array.project scalars component)) flags).restoreIndex index scalars)
          (fun current scalars flags component =>
            StatementsActualBoundsSafe bounds names input valid current body
              (Integer.put scalars index (array.project scalars component)) flags)
          values integers booleans (Integer.iterationValues reverse array.bounds.lower array.bounds.upper)
  termination_by sizeOf item

  def StatementsActualBoundsSafe (bounds : BoundsStore) (names : Compose.BindingEnvironment) (input : Source) (valid : Bool)
      (values : Values) (items : List Statement) (integers : Integer.Store) (booleans : Boolean.Store) : Prop :=
    match items with
    | [] => True
    | item :: rest => item.ActualBoundsSafe bounds names input valid values integers booleans ∧
        StatementsActualBoundsSafe bounds names input valid (item.execute input valid values integers booleans).values rest
          (item.execute input valid values integers booleans).integers
          (item.execute input valid values integers booleans).booleans
  termination_by sizeOf items
end

theorem IterationsObjectBoundsSafe.mono
    {step : Values → Integer.Store → Boolean.Store → Int → Execution}
    {first second : Values → Integer.Store → Boolean.Store → Int → Prop}
    {values : Values} {integers : Integer.Store} {booleans : Boolean.Store} {indices : List Int}
    (transfer : ∀ values integers booleans index, first values integers booleans index → second values integers booleans index)
    (safe : IterationsObjectBoundsSafe step first values integers booleans indices) :
    IterationsObjectBoundsSafe step second values integers booleans indices := by
  induction indices generalizing values integers booleans with
  | nil => trivial
  | cons index rest ih => exact ⟨transfer _ _ _ _ safe.1, ih safe.2⟩

/- String assignment, including sliding, keeps the target's initialized bounds.
Thus one source-produced compatible bounds store covers all later byte stores. -/
mutual
  theorem statement_actualBoundsSafe {bounds : BoundsStore} {names : Compose.BindingEnvironment}
      {values : Values} {input : Source} {valid : Bool} {integers : Integer.Store} {booleans : Boolean.Store}
      {item : Statement} (compatible : bounds.Compatible names input)
      (origin : item.BoundsOrigin names) (safe : item.ObjectBoundsSafe names input valid values integers booleans) :
      item.ActualBoundsSafe bounds names input valid values integers booleans := by
    cases item with
    | simple item =>
        simp only [Statement.BoundsOrigin, Statement.ObjectBoundsSafe, Statement.ActualBoundsSafe] at origin safe ⊢
        cases item with
        | null => trivial
        | assign update | output update | put update =>
            exact Expression.actualBoundsSafe compatible origin safe
    | scalarAssign | arrayAssign | reject => simp only [Statement.ActualBoundsSafe]
    | booleanAssign update =>
        simp only [Statement.BoundsOrigin, Statement.ObjectBoundsSafe, Statement.ActualBoundsSafe] at origin safe ⊢
        exact Condition.actualBoundsSafe compatible origin safe
    | choice condition yes no =>
        simp only [Statement.BoundsOrigin, Statement.ObjectBoundsSafe, Statement.ActualBoundsSafe] at origin safe ⊢
        change condition.ObjectBoundsSafe names values input valid integers booleans ∧ _ at safe
        change condition.ActualBoundsSafe bounds names values input valid integers booleans ∧ _
        refine ⟨Condition.actualBoundsSafe compatible origin.1 safe.1, ?_⟩
        split <;> rename_i reached
        · exact statements_actualBoundsSafe compatible origin.2.1 (by simpa only [reached, Bool.false_eq_true, ↓reduceIte] using safe.2)
        · exact statements_actualBoundsSafe compatible origin.2.2 (by simpa only [reached, Bool.false_eq_true, ↓reduceIte] using safe.2)
    | forLoop index reverse lower upper body =>
        simp only [Statement.BoundsOrigin, Statement.ObjectBoundsSafe, Statement.ActualBoundsSafe] at origin safe ⊢
        exact IterationsObjectBoundsSafe.mono
          (fun _ _ _ _ inner => statements_actualBoundsSafe compatible origin inner) safe
    | arrayLoop index reverse array body =>
        simp only [Statement.BoundsOrigin, Statement.ObjectBoundsSafe, Statement.ActualBoundsSafe] at origin safe ⊢
        exact IterationsObjectBoundsSafe.mono
          (fun _ _ _ _ inner => statements_actualBoundsSafe compatible origin inner) safe
  termination_by sizeOf item

  theorem statements_actualBoundsSafe {bounds : BoundsStore} {names : Compose.BindingEnvironment}
      {values : Values} {input : Source} {valid : Bool} {integers : Integer.Store} {booleans : Boolean.Store}
      {items : List Statement} (compatible : bounds.Compatible names input)
      (origin : StatementsBoundsOrigin names items)
      (safe : StatementsObjectBoundsSafe names input valid values items integers booleans) :
      StatementsActualBoundsSafe bounds names input valid values items integers booleans := by
    cases items with
    | nil => simp only [StatementsActualBoundsSafe]
    | cons item rest =>
        simp only [StatementsBoundsOrigin, StatementsObjectBoundsSafe, StatementsActualBoundsSafe] at origin safe ⊢
        exact ⟨statement_actualBoundsSafe compatible origin.1 safe.1,
          statements_actualBoundsSafe compatible origin.2 safe.2⟩
  termination_by sizeOf items
end

end Silver.Predicate
