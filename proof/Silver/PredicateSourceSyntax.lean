module

public import Silver.PredicateComposition

@[expose] public section

/-! The source tree retains `elsif` and omitted `else` explicitly. Lowering to
the small choice core preserves every returning call, assignment and branch. -/

namespace Silver.Predicate
open Bindings Compose PathFacts

mutual
  inductive SourceStatement
    | simple (item : Sequence.SimpleStatement)
    | scalarAssign (update : Integer.Assignment)
    | arrayAssign (update : Integer.ArrayAssignment)
    | booleanAssign (update : BooleanAssignment)
    | booleanArrayAssign (update : BooleanArrayAssignment)
    | reject
    | choice (condition : Condition) (yes : List SourceStatement) (tail : SourceAlternative)
    | forLoop (index : Nat) (reverse : Bool) (lower upper : Integer.Expr) (body : List SourceStatement)
    | arrayLoop (index : Nat) (reverse : Bool) (array : Integer.ArrayDescriptor) (body : List SourceStatement)
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
    | .scalarAssign update => .scalarAssign update
    | .arrayAssign update => .arrayAssign update
    | .booleanAssign update => .booleanAssign update
    | .booleanArrayAssign update => .booleanArrayAssign update
    | .reject => .reject
    | .choice condition yes tail => .choice condition (lowerStatements yes) tail.lower
    | .forLoop index reverse lower upper body => .forLoop index reverse lower upper (lowerStatements body)
    | .arrayLoop index reverse array body => .arrayLoop index reverse array (lowerStatements body)
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
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore) : Execution :=
    match item with
    | .simple item => executeSimpleStatement input values item integers booleans
    | .scalarAssign update => ⟨values, [], update.execute integers, booleans⟩
    | .arrayAssign update => ⟨values, [], update.execute integers, booleans⟩
    | .booleanAssign update =>
        ⟨values, [], integers, Boolean.put booleans update.target
          (update.value.evaluate values input valid integers booleans)⟩
    | .booleanArrayAssign update =>
        ⟨values, [], integers, update.execute values input valid integers booleans⟩
    | .reject => ⟨values, [.reject], integers, booleans⟩
    | .choice condition yes tail =>
        if condition.evaluate values input valid integers booleans then executeSourceStatements input valid values yes integers booleans
        else tail.execute input valid values integers booleans
    | .forLoop index reverse lower upper body =>
        executeIterations (fun current currentIntegers flags value =>
          let result := executeSourceStatements input valid current body (Integer.put currentIntegers index value) flags
          result.restoreIndex index currentIntegers) values integers booleans
          (Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers))
    | .arrayLoop index reverse array body =>
        executeIterations (fun current currentIntegers flags component =>
          let result := executeSourceStatements input valid current body
            (Integer.put currentIntegers index (array.project currentIntegers component)) flags
          result.restoreIndex index currentIntegers) values integers booleans
          (Integer.iterationValues reverse array.bounds.lower array.bounds.upper)
  termination_by sizeOf item
  def SourceAlternative.execute (input : Source) (valid : Bool) (values : Values) (tail : SourceAlternative)
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore) : Execution :=
    match tail with
    | .absent => ⟨values, [], integers, booleans⟩
    | .otherwise items => executeSourceStatements input valid values items integers booleans
    | .elsif condition yes tail =>
        if condition.evaluate values input valid integers booleans then executeSourceStatements input valid values yes integers booleans
        else tail.execute input valid values integers booleans
  termination_by sizeOf tail
  def executeSourceStatements (input : Source) (valid : Bool) (values : Values) (items : List SourceStatement)
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore) : Execution :=
    match items with
    | [] => ⟨values, [], integers, booleans⟩
    | item :: rest =>
        let first := item.execute input valid values integers booleans
        let following := executeSourceStatements input valid first.values rest first.integers first.booleans
        ⟨following.values, first.effects ++ following.effects, following.integers, following.booleans⟩
  termination_by sizeOf items
end

mutual
  theorem SourceStatement.lower_execute (item : SourceStatement) (input : Source) (valid : Bool) (values : Values)
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore) :
      item.lower.execute input valid values integers booleans = item.execute input valid values integers booleans := by
    cases item with
    | simple item => simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute]
    | scalarAssign update => simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute]
    | arrayAssign update | booleanAssign update | booleanArrayAssign update =>
        simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute]
    | reject => simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute]
    | choice condition yes tail =>
        have yesEq := lowerStatements_execute yes input valid values integers booleans
        have noEq := SourceAlternative.lower_execute tail input valid values integers booleans
        simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute, yesEq, noEq]
    | forLoop index reverse lower upper body =>
        simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute]
        congr 1
        funext current currentIntegers flags value
        rw [lowerStatements_execute body input valid current (Integer.put currentIntegers index value) flags]
    | arrayLoop index reverse array body =>
        simp only [SourceStatement.lower, Statement.execute, SourceStatement.execute]
        congr 1
        funext current currentIntegers flags component
        rw [lowerStatements_execute body input valid current
          (Integer.put currentIntegers index (array.project currentIntegers component)) flags]
  termination_by sizeOf item
  theorem SourceAlternative.lower_execute (tail : SourceAlternative) (input : Source) (valid : Bool) (values : Values)
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore) :
      executeStatements input valid values tail.lower integers booleans = tail.execute input valid values integers booleans := by
    cases tail with
    | absent => simp only [SourceAlternative.lower, executeStatements, SourceAlternative.execute]
    | otherwise items =>
        have equal := lowerStatements_execute items input valid values integers booleans
        simpa only [SourceAlternative.lower, SourceAlternative.execute] using equal
    | elsif condition yes tail =>
        have yesEq := lowerStatements_execute yes input valid values integers booleans
        have noEq := SourceAlternative.lower_execute tail input valid values integers booleans
        simp only [SourceAlternative.lower, executeStatements, Statement.execute, SourceAlternative.execute, List.append_nil,
          yesEq, noEq]
  termination_by sizeOf tail
  theorem lowerStatements_execute (items : List SourceStatement) (input : Source) (valid : Bool) (values : Values)
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore) :
      executeStatements input valid values (lowerStatements items) integers booleans = executeSourceStatements input valid values items integers booleans := by
    cases items with
    | nil => simp only [lowerStatements, executeStatements, executeSourceStatements]
    | cons item rest =>
        have firstEq := SourceStatement.lower_execute item input valid values integers booleans
        have restEq := lowerStatements_execute rest input valid (item.execute input valid values integers booleans).values
          (item.execute input valid values integers booleans).integers
          (item.execute input valid values integers booleans).booleans
        simp only [lowerStatements, executeStatements, executeSourceStatements, firstEq, restEq]
  termination_by sizeOf items
end

theorem lowerStatements_nonempty {items : List SourceStatement} (nonempty : items ≠ []) :
    lowerStatements items ≠ [] := by cases items <;> simp_all [lowerStatements]

mutual
  def SourceStatement.WellFormed (hasArguments : Bool) (shape : Shape) (item : SourceStatement)
      (booleans : Boolean.Analysis := {}) : Prop :=
    match item with
    | .simple item => SimpleWellFormed shape item
    | .scalarAssign update => update.target ≠ 0
    | .arrayAssign _ => True
    | .booleanAssign update => booleans.canWrite update.target = true ∧
        update.value.Grammatical ∧ update.value.Readable hasArguments shape booleans
    | .booleanArrayAssign update => update.array.writable booleans = true ∧
        update.value.Grammatical ∧ update.value.Readable hasArguments shape booleans
    | .reject => hasArguments = true
    | .choice condition yes tail => condition.Grammatical ∧ condition.Readable hasArguments shape booleans ∧
        yes ≠ [] ∧ SourceStatementsWellFormed hasArguments shape yes booleans ∧ tail.WellFormed hasArguments shape booleans
    | .forLoop index _ _ _ body | .arrayLoop index _ _ body =>
        index ≠ 0 ∧ body ≠ [] ∧ SourceStatementsWellFormed hasArguments shape body booleans
  termination_by sizeOf item
  def SourceAlternative.WellFormed (hasArguments : Bool) (shape : Shape) (tail : SourceAlternative)
      (booleans : Boolean.Analysis := {}) : Prop :=
    match tail with
    | .absent => True
    | .otherwise items => items ≠ [] ∧ SourceStatementsWellFormed hasArguments shape items booleans
    | .elsif condition yes tail => condition.Grammatical ∧ condition.Readable hasArguments shape booleans ∧
        yes ≠ [] ∧ SourceStatementsWellFormed hasArguments shape yes booleans ∧ tail.WellFormed hasArguments shape booleans
  termination_by sizeOf tail
  def SourceStatementsWellFormed (hasArguments : Bool) (shape : Shape) (items : List SourceStatement)
      (booleans : Boolean.Analysis := {}) : Prop :=
    match items with
    | [] => True
    | item :: rest => item.WellFormed hasArguments shape booleans ∧ SourceStatementsWellFormed hasArguments shape rest booleans
  termination_by sizeOf items
end

mutual
  theorem SourceStatement.lower_wellFormed {item : SourceStatement} {hasArguments : Bool} {shape : Shape} {booleans : Boolean.Analysis}
      (valid : item.WellFormed hasArguments shape booleans) : item.lower.WellFormed hasArguments shape booleans := by
    cases item with
    | simple item => simpa only [SourceStatement.lower, Statement.WellFormed, SourceStatement.WellFormed] using valid
    | scalarAssign update => simpa only [SourceStatement.lower, Statement.WellFormed, SourceStatement.WellFormed] using valid
    | arrayAssign update => simp only [SourceStatement.lower, Statement.WellFormed]
    | booleanAssign update | booleanArrayAssign update =>
        simpa only [SourceStatement.lower, Statement.WellFormed, SourceStatement.WellFormed] using valid
    | reject => simpa only [SourceStatement.lower, Statement.WellFormed, SourceStatement.WellFormed] using valid
    | choice condition yes tail =>
        simp only [SourceStatement.WellFormed] at valid
        simp only [SourceStatement.lower, Statement.WellFormed]
        exact ⟨valid.1, valid.2.1, lowerStatements_nonempty valid.2.2.1,
          lowerStatements_wellFormed valid.2.2.2.1, SourceAlternative.lower_wellFormed valid.2.2.2.2⟩
    | forLoop index reverse lower upper body | arrayLoop index reverse array body =>
        simp only [SourceStatement.WellFormed] at valid
        simp only [SourceStatement.lower, Statement.WellFormed]
        exact ⟨valid.1, lowerStatements_nonempty valid.2.1, lowerStatements_wellFormed valid.2.2⟩
  termination_by sizeOf item
  theorem SourceAlternative.lower_wellFormed {tail : SourceAlternative} {hasArguments : Bool} {shape : Shape} {booleans : Boolean.Analysis}
      (valid : tail.WellFormed hasArguments shape booleans) : StatementsWellFormed hasArguments shape tail.lower booleans := by
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
  theorem lowerStatements_wellFormed {items : List SourceStatement} {hasArguments : Bool} {shape : Shape} {booleans : Boolean.Analysis}
      (valid : SourceStatementsWellFormed hasArguments shape items booleans) :
      StatementsWellFormed hasArguments shape (lowerStatements items) booleans := by
    cases items with
    | nil => simp only [lowerStatements, StatementsWellFormed]
    | cons item rest =>
        simp only [SourceStatementsWellFormed] at valid
        simp only [lowerStatements, StatementsWellFormed]
        exact ⟨SourceStatement.lower_wellFormed valid.1, lowerStatements_wellFormed valid.2⟩
  termination_by sizeOf items
end

end Silver.Predicate
