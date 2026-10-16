module

public import Silver.PredicateComposition

@[expose] public section

/-! The source tree retains `elsif` and omitted `else` explicitly. Lowering to
the small choice core preserves every returning call, assignment and branch. -/

namespace Silver.Predicate
open Bindings Compose PathFacts
open Sequence (Execution)

mutual
  inductive SourceStatement
    | simple (item : Sequence.SimpleStatement)
    | reject
    | choice (condition : Condition) (yes : List SourceStatement) (tail : SourceAlternative)
    | forLoop (index : Nat) (reverse : Bool) (lower upper : Integer.Expr) (body : List SourceStatement)
    deriving Repr
  inductive SourceAlternative
    | absent
    | otherwise (items : List SourceStatement)
    | elsif (condition : Condition) (yes : List SourceStatement) (tail : SourceAlternative)
    deriving Repr
end

mutual
  def SourceStatement.lower : SourceStatement → Statement
    | .simple item => .simple item
    | .reject => .reject
    | .choice condition yes tail => .choice condition (lowerStatements yes) tail.lower
    | .forLoop index reverse lower upper body => .forLoop index reverse lower upper (lowerStatements body)
  termination_by item => sizeOf item
  def SourceAlternative.lower : SourceAlternative → List Statement
    | .absent => []
    | .otherwise items => lowerStatements items
    | .elsif condition yes tail => [.choice condition (lowerStatements yes) tail.lower]
  termination_by tail => sizeOf tail
  def lowerStatements : List SourceStatement → List Statement
    | [] => []
    | item :: rest => item.lower :: lowerStatements rest
  termination_by items => sizeOf items
end

mutual
  def SourceStatement.execute (input : Source) (valid : Bool) (values : Values) (item : SourceStatement)
      (integers : Integer.Store := Integer.emptyStore) : Execution :=
    match item with
    | .simple item => executeSimpleStatement input values item integers
    | .reject => ⟨values, [.reject]⟩
    | .choice condition yes tail =>
        if condition.evaluate values input valid integers then executeSourceStatements input valid values yes integers
        else tail.execute input valid values integers
    | .forLoop index reverse lower upper body =>
        executeIterations (fun current value =>
          executeSourceStatements input valid current body (Integer.put integers index value)) values
          (Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers))
  termination_by sizeOf item
  def SourceAlternative.execute (input : Source) (valid : Bool) (values : Values) (tail : SourceAlternative)
      (integers : Integer.Store := Integer.emptyStore) : Execution :=
    match tail with
    | .absent => ⟨values, []⟩
    | .otherwise items => executeSourceStatements input valid values items integers
    | .elsif condition yes tail =>
        if condition.evaluate values input valid integers then executeSourceStatements input valid values yes integers
        else tail.execute input valid values integers
  termination_by sizeOf tail
  def executeSourceStatements (input : Source) (valid : Bool) (values : Values) (items : List SourceStatement)
      (integers : Integer.Store := Integer.emptyStore) : Execution :=
    match items with
    | [] => ⟨values, []⟩
    | item :: rest =>
        let first := item.execute input valid values integers
        let following := executeSourceStatements input valid first.values rest integers
        ⟨following.values, first.effects ++ following.effects⟩
  termination_by sizeOf items
end

mutual
  theorem SourceStatement.lower_execute (item : SourceStatement) (input : Source) (valid : Bool) (values : Values)
      (integers : Integer.Store := Integer.emptyStore) :
      item.lower.execute input valid values integers = item.execute input valid values integers := by
    cases item with
    | simple item => simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute]
    | reject => simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute]
    | choice condition yes tail =>
        have yesEq := lowerStatements_execute yes input valid values integers
        have noEq := SourceAlternative.lower_execute tail input valid values integers
        simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute, yesEq, noEq]
    | forLoop index reverse lower upper body =>
        simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute]
        congr 1
        funext current value
        exact lowerStatements_execute body input valid current (Integer.put integers index value)
  termination_by sizeOf item
  theorem SourceAlternative.lower_execute (tail : SourceAlternative) (input : Source) (valid : Bool) (values : Values)
      (integers : Integer.Store := Integer.emptyStore) :
      executeStatements input valid values tail.lower integers = tail.execute input valid values integers := by
    cases tail with
    | absent => simp only [SourceAlternative.lower, executeStatements, SourceAlternative.execute]
    | otherwise items =>
        have equal := lowerStatements_execute items input valid values integers
        simpa only [SourceAlternative.lower, SourceAlternative.execute] using equal
    | elsif condition yes tail =>
        have yesEq := lowerStatements_execute yes input valid values integers
        have noEq := SourceAlternative.lower_execute tail input valid values integers
        simp only [SourceAlternative.lower, executeStatements, Statement.execute, SourceAlternative.execute, List.append_nil,
          yesEq, noEq]
  termination_by sizeOf tail
  theorem lowerStatements_execute (items : List SourceStatement) (input : Source) (valid : Bool) (values : Values)
      (integers : Integer.Store := Integer.emptyStore) :
      executeStatements input valid values (lowerStatements items) integers = executeSourceStatements input valid values items integers := by
    cases items with
    | nil => simp only [lowerStatements, executeStatements, executeSourceStatements]
    | cons item rest =>
        have firstEq := SourceStatement.lower_execute item input valid values integers
        have restEq := lowerStatements_execute rest input valid (item.execute input valid values integers).values integers
        simp only [lowerStatements, executeStatements, executeSourceStatements, firstEq, restEq]
  termination_by sizeOf items
end

theorem lowerStatements_nonempty {items : List SourceStatement} (nonempty : items ≠ []) :
    lowerStatements items ≠ [] := by cases items <;> simp_all [lowerStatements]

mutual
  def SourceStatement.WellFormed (hasArguments : Bool) (shape : Shape) : SourceStatement → Prop
    | .simple item => SimpleWellFormed shape item
    | .reject => hasArguments = true
    | .choice condition yes tail => condition.Grammatical ∧ condition.Readable hasArguments shape ∧
        yes ≠ [] ∧ SourceStatementsWellFormed hasArguments shape yes ∧ tail.WellFormed hasArguments shape
    | .forLoop index _ _ _ body => index ≠ 0 ∧ body ≠ [] ∧ SourceStatementsWellFormed hasArguments shape body
  termination_by item => sizeOf item
  def SourceAlternative.WellFormed (hasArguments : Bool) (shape : Shape) : SourceAlternative → Prop
    | .absent => True
    | .otherwise items => items ≠ [] ∧ SourceStatementsWellFormed hasArguments shape items
    | .elsif condition yes tail => condition.Grammatical ∧ condition.Readable hasArguments shape ∧
        yes ≠ [] ∧ SourceStatementsWellFormed hasArguments shape yes ∧ tail.WellFormed hasArguments shape
  termination_by tail => sizeOf tail
  def SourceStatementsWellFormed (hasArguments : Bool) (shape : Shape) : List SourceStatement → Prop
    | [] => True
    | item :: rest => item.WellFormed hasArguments shape ∧ SourceStatementsWellFormed hasArguments shape rest
  termination_by items => sizeOf items
end

mutual
  theorem SourceStatement.lower_wellFormed {item : SourceStatement} {hasArguments : Bool} {shape : Shape}
      (valid : item.WellFormed hasArguments shape) : item.lower.WellFormed hasArguments shape := by
    cases item with
    | simple item => simpa only [SourceStatement.lower, Statement.WellFormed, SourceStatement.WellFormed] using valid
    | reject => simpa only [SourceStatement.lower, Statement.WellFormed, SourceStatement.WellFormed] using valid
    | choice condition yes tail =>
        simp only [SourceStatement.WellFormed] at valid
        simp only [SourceStatement.lower, Statement.WellFormed]
        exact ⟨valid.1, valid.2.1, lowerStatements_nonempty valid.2.2.1,
          lowerStatements_wellFormed valid.2.2.2.1, SourceAlternative.lower_wellFormed valid.2.2.2.2⟩
    | forLoop index reverse lower upper body =>
        simp only [SourceStatement.WellFormed] at valid
        simp only [SourceStatement.lower, Statement.WellFormed]
        exact ⟨valid.1, lowerStatements_nonempty valid.2.1, lowerStatements_wellFormed valid.2.2⟩
  termination_by sizeOf item
  theorem SourceAlternative.lower_wellFormed {tail : SourceAlternative} {hasArguments : Bool} {shape : Shape}
      (valid : tail.WellFormed hasArguments shape) : StatementsWellFormed hasArguments shape tail.lower := by
    cases tail with
    | absent => simp only [SourceAlternative.lower, StatementsWellFormed]
    | otherwise items =>
        simp only [SourceAlternative.WellFormed] at valid
        simpa only [SourceAlternative.lower] using lowerStatements_wellFormed valid.2
    | elsif condition yes tail =>
        simp only [SourceAlternative.WellFormed] at valid
        simp only [SourceAlternative.lower, StatementsWellFormed, Statement.WellFormed]
        exact ⟨⟨valid.1, valid.2.1, lowerStatements_nonempty valid.2.2.1,
          lowerStatements_wellFormed valid.2.2.2.1, SourceAlternative.lower_wellFormed valid.2.2.2.2⟩, trivial⟩
  termination_by sizeOf tail
  theorem lowerStatements_wellFormed {items : List SourceStatement} {hasArguments : Bool} {shape : Shape}
      (valid : SourceStatementsWellFormed hasArguments shape items) :
      StatementsWellFormed hasArguments shape (lowerStatements items) := by
    cases items with
    | nil => simp only [lowerStatements, StatementsWellFormed]
    | cons item rest =>
        simp only [SourceStatementsWellFormed] at valid
        simp only [lowerStatements, StatementsWellFormed]
        exact ⟨SourceStatement.lower_wellFormed valid.1, lowerStatements_wellFormed valid.2⟩
  termination_by sizeOf items
end

end Silver.Predicate
