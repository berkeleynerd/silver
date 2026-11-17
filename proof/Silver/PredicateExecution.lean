module

public import Silver.PredicateStatements
public import Silver.ScalarCallExecution
public import Silver.ScalarProcedureExecution
public import Silver.SequenceExecution

@[expose] public section

/-! Predicate-control execution keeps the established String store and effect
trace. Reject contributes an effect and returns; later statements still execute.
The static checker separately guarantees no output on any invalid-input path. -/

namespace Silver.Predicate
open Bindings Compose PathFacts
open Sequence (Effect EffectsValid)

variable {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment}

set_option maxRecDepth 10000
set_option maxHeartbeats 500000

structure Execution where
  values : Values
  effects : List Effect
  integers : Integer.Store
  booleans : Boolean.Store

def Execution.restoreIndex (result : Execution) (index : Nat) (before : Integer.Store) : Execution :=
  {result with integers := Integer.restore before result.integers index}

def executeSimpleStatement (input : Source) (values : Values) (item : Sequence.SimpleStatement)
    (integers : Integer.Store) (booleans : Boolean.Store := Boolean.emptyStore) : Execution :=
  match item with
  | .null => ⟨values, [], integers, booleans⟩
  | .assign update => ⟨executeAssignment update values input integers, [], integers, booleans⟩
  | .output expression => ⟨values, [.output (expression.evaluate values input integers)], integers, booleans⟩
  | .put expression => ⟨values, [.put (expression.evaluate values input integers)], integers, booleans⟩

def checkedSimpleStatement (input : Source) (values : Values) (item : Sequence.SimpleStatement)
    (integers : Integer.Store) (booleans : Boolean.Store := Boolean.emptyStore) : Option Execution :=
  match item with
  | .null => some ⟨values, [], integers, booleans⟩
  | .assign update => (update.value.checkedEvaluate values input integers).bind fun value =>
      if value.length = (values update.target).length then
        some ⟨Bindings.put values update.target value, [], integers, booleans⟩ else none
  | .output expression => (expression.checkedEvaluate values input integers).map fun value =>
      ⟨values, [.output value], integers, booleans⟩
  | .put expression => (expression.checkedEvaluate values input integers).map fun value =>
      ⟨values, [.put value], integers, booleans⟩

def executeIterations (step : Values → Integer.Store → Boolean.Store → Int → Execution) :
    Values → Integer.Store → Boolean.Store → List Int → Execution
  | values, integers, booleans, [] => ⟨values, [], integers, booleans⟩
  | values, integers, booleans, index :: rest =>
      let first := step values integers booleans index
      let following := executeIterations step first.values first.integers first.booleans rest
      ⟨following.values, first.effects ++ following.effects, following.integers, following.booleans⟩

def checkedIterations (step : Values → Integer.Store → Boolean.Store → Int → Option Execution) :
    Values → Integer.Store → Boolean.Store → List Int → Option Execution
  | values, integers, booleans, [] => some ⟨values, [], integers, booleans⟩
  | values, integers, booleans, index :: rest => (step values integers booleans index).bind fun first =>
      (checkedIterations step first.values first.integers first.booleans rest).map fun following =>
        ⟨following.values, first.effects ++ following.effects, following.integers, following.booleans⟩

mutual
  def Statement.execute (input : Source) (inputValid : Bool) (values : Values) (item : Statement)
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore)
      (functions : ScalarFunctions.Environment := .empty)
      (procedures : ScalarProcedures.Environment := .empty) : Execution :=
    match item with
    | .simple item => executeSimpleStatement input values item integers booleans
    | .scalarAssign update => ⟨values, [], update.execute integers, booleans⟩
    | .callAssign update =>
        let result := update.execute functions.values ⟨values, input, inputValid, integers, booleans⟩
        ⟨result.values, [], result.integers, result.booleans⟩
    | .procedureCall call =>
        let result := call.execute procedures ⟨values, input, inputValid, integers, booleans⟩
        ⟨result.values, [], result.integers, result.booleans⟩
    | .arrayAssign update => ⟨values, [], update.execute integers, booleans⟩
    | .booleanAssign update =>
        ⟨values, [], integers, Boolean.put booleans update.target
          (update.value.evaluate values input inputValid integers booleans)⟩
    | .booleanArrayAssign update =>
        ⟨values, [], integers, update.execute values input inputValid integers booleans⟩
    | .reject => ⟨values, [.reject], integers, booleans⟩
    | .choice condition yes no =>
        if condition.evaluate values input inputValid integers booleans
        then executeStatements (functions := functions) (procedures := procedures) input inputValid values yes integers booleans
        else executeStatements (functions := functions) (procedures := procedures) input inputValid values no integers booleans
    | .forLoop index reverse lower upper body =>
        executeIterations (fun current scalars flags value =>
          (executeStatements (functions := functions) (procedures := procedures) input inputValid current body (Integer.put scalars index value) flags).restoreIndex index scalars)
          values integers booleans (Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers))
    | .arrayLoop index reverse array body =>
        executeIterations (fun current scalars flags component =>
          (executeStatements (functions := functions) (procedures := procedures) input inputValid current body
            (Integer.put scalars index (array.project scalars component)) flags).restoreIndex index scalars)
          values integers booleans (Integer.iterationValues reverse array.bounds.lower array.bounds.upper)
  termination_by sizeOf item
  def executeStatements (input : Source) (inputValid : Bool) (values : Values) (items : List Statement)
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore)
      (functions : ScalarFunctions.Environment := .empty)
      (procedures : ScalarProcedures.Environment := .empty) : Execution :=
    match items with
    | [] => ⟨values, [], integers, booleans⟩
    | item :: rest =>
        let first := item.execute (functions := functions) (procedures := procedures) input inputValid values integers booleans
        let following := executeStatements (functions := functions) (procedures := procedures) input inputValid first.values rest first.integers first.booleans
        ⟨following.values, first.effects ++ following.effects, following.integers, following.booleans⟩
  termination_by sizeOf items
end

mutual
  def Statement.checkedExecute (input : Source) (inputValid : Bool) (values : Values) (item : Statement)
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore)
      (functions : ScalarFunctions.Environment := .empty)
      (procedures : ScalarProcedures.Environment := .empty) : Option Execution :=
    match item with
    | .simple item => checkedSimpleStatement input values item integers booleans
    | .scalarAssign update => (update.checkedExecute integers).map fun scalars => ⟨values, [], scalars, booleans⟩
    | .callAssign update =>
        (update.checkedExecute functions.signatures functions.values
          ⟨values, input, inputValid, integers, booleans⟩).map fun result =>
            ⟨result.values, [], result.integers, result.booleans⟩
    | .procedureCall call =>
        (call.checkedExecute procedures ⟨values, input, inputValid, integers, booleans⟩).map fun result =>
          ⟨result.values, [], result.integers, result.booleans⟩
    | .arrayAssign update => (update.checkedExecute integers).map fun scalars => ⟨values, [], scalars, booleans⟩
    | .booleanAssign update =>
        (update.value.checkedEvaluate values input inputValid integers booleans).map fun value =>
          ⟨values, [], integers, Boolean.put booleans update.target value⟩
    | .booleanArrayAssign update =>
        (update.checkedExecute values input inputValid integers booleans).map fun flags =>
          ⟨values, [], integers, flags⟩
    | .reject => some ⟨values, [.reject], integers, booleans⟩
    | .choice condition yes no =>
        (condition.checkedEvaluate values input inputValid integers booleans).bind fun outcome =>
          if outcome then checkedStatements (functions := functions) (procedures := procedures) input inputValid values yes integers booleans
          else checkedStatements (functions := functions) (procedures := procedures) input inputValid values no integers booleans
    | .forLoop index reverse lower upper body =>
        (lower.checkedEvaluate integers).bind fun a => (upper.checkedEvaluate integers).bind fun b =>
          checkedIterations (fun current scalars flags value =>
            (checkedStatements (functions := functions) (procedures := procedures) input inputValid current body (Integer.put scalars index value) flags).map
              fun result => result.restoreIndex index scalars)
            values integers booleans (Integer.iterationValues reverse a b)
    | .arrayLoop index reverse array body =>
        checkedIterations (fun current scalars flags component =>
          if array.bounds.Contains component then
            (Integer.checkedValue (array.project scalars component)).bind fun value =>
              (checkedStatements (functions := functions) (procedures := procedures) input inputValid current body (Integer.put scalars index value) flags).map
                fun result => result.restoreIndex index scalars
          else none) values integers booleans (Integer.iterationValues reverse array.bounds.lower array.bounds.upper)
  termination_by sizeOf item
  def checkedStatements (input : Source) (inputValid : Bool) (values : Values) (items : List Statement)
      (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore)
      (functions : ScalarFunctions.Environment := .empty)
      (procedures : ScalarProcedures.Environment := .empty) : Option Execution :=
    match items with
    | [] => some ⟨values, [], integers, booleans⟩
    | item :: rest => (item.checkedExecute (functions := functions) (procedures := procedures) input inputValid values integers booleans).bind fun first =>
        (checkedStatements (functions := functions) (procedures := procedures) input inputValid first.values rest first.integers first.booleans).map fun following =>
          ⟨following.values, first.effects ++ following.effects, following.integers, following.booleans⟩
  termination_by sizeOf items
end

def isReject : Effect → Bool
  | .reject => true
  | .output _ | .put _ => false

def rejectedAfter (before : Bool) (effects : List Effect) : Bool := before || effects.any isReject

def NoOutput (effects : List Effect) : Prop := ∀ effect ∈ effects, effect = .reject

theorem rejectedAfter_append (before : Bool) (first following : List Effect) :
    rejectedAfter before (first ++ following) = rejectedAfter (rejectedAfter before first) following := by
  simp only [rejectedAfter, List.any_append, Bool.or_assoc]

theorem noOutput_append {first following : List Effect} (left : NoOutput first) (right : NoOutput following) :
    NoOutput (first ++ following) := by
  intro effect member
  rcases List.mem_append.mp member with member | member
  · exact left effect member
  · exact right effect member

theorem iterations_unchanged {step : Values → Integer.Store → Boolean.Store → Int → Execution}
    {values : Values} {integers : Integer.Store} {booleans : Boolean.Store} {indices : List Int} {index : Nat}
    (unchanged : ∀ current scalars flags value, (step current scalars flags value).integers index = scalars index) :
    (executeIterations step values integers booleans indices).integers index = integers index := by
  induction indices generalizing values integers booleans with
  | nil => rfl
  | cons value rest ih =>
      exact (ih (values := (step values integers booleans value).values)
        (integers := (step values integers booleans value).integers)
        (booleans := (step values integers booleans value).booleans)).trans (unchanged values integers booleans value)

mutual
  theorem statement_unchanged {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment} {shape : Shape} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {before after : Flow}
      {item : Statement} {input : Source} {valid : Bool} {values : Values} {integers : Integer.Store} {booleans : Boolean.Store}
      {index : Nat} (checked : item.check (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before booleanAnalysis = some after)
      (readonly : analysis.mutable index = false) :
      (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).integers index = integers index := by
    cases item with
    | simple item => cases item <;> simp only [Statement.execute, executeSimpleStatement]
    | scalarAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · simpa only [Statement.execute] using
            update.unchanged (values := integers) (by assumption) readonly
        · contradiction
    | callAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · simpa only [Statement.execute] using
            update.integer_unchanged (calls := functions.values)
              (state := ⟨values, input, valid, integers, booleans⟩) (by assumption) readonly
        · contradiction
    | procedureCall call =>
        simp only [Statement.check] at checked
        split at checked
        · simpa only [Statement.execute] using
            call.integer_unchanged (environment := procedures)
              (state := ⟨values, input, valid, integers, booleans⟩) (by assumption) readonly
        · contradiction
    | arrayAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          have both : update.check before.scalars analysis.mutable = true ∧
              update.array.componentRanges analysis.declared = true := by
            simpa only [checkArrayAssignment, Bool.and_eq_true] using good
          have accepted := both.1
          simpa only [Statement.execute] using
            update.unchanged (values := integers) accepted readonly
        · contradiction
    | booleanAssign _ | booleanArrayAssign _ | reject => simp only [Statement.execute]
    | choice condition yes no =>
        simp only [Statement.check] at checked
        split at checked
        · simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, _⟩ := checked
          simp only [Statement.execute]
          split
          · exact statements_unchanged (functions := functions) (procedures := procedures) yesChecked readonly
          · exact statements_unchanged (functions := functions) (procedures := procedures) noChecked readonly
        · contradiction
    | forLoop binder reverse lower upper body =>
        simp only [Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, _, b, _, bodyAfter, bodyChecked, _⟩ := checked
        simp only [Statement.execute]
        apply iterations_unchanged
        intro current scalars flags value
        by_cases same : index = binder
        · subst index
          simp only [Execution.restoreIndex, Integer.restore, Integer.put, ↓reduceIte]
        · have readonlyBody : (analysis.withIndex binder (Integer.loopBounds a b)).mutable index = false := by
            simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
          have preserved := statements_unchanged (functions := functions) (procedures := procedures) (input := input) (valid := valid)
            (values := current) (booleans := flags) (integers := Integer.put scalars binder value) bodyChecked readonlyBody
          simpa only [Execution.restoreIndex, Integer.restore, Integer.put, same, ↓reduceIte] using preserved
    | arrayLoop binder reverse array body =>
        simp only [Statement.check] at checked
        split at checked
        · simp only [Option.map_eq_some_iff] at checked
          obtain ⟨bodyAfter, bodyChecked, _⟩ := checked
          simp only [Statement.execute]
          apply iterations_unchanged
          intro current scalars flags component
          by_cases same : index = binder
          · subst index
            simp only [Execution.restoreIndex, Integer.restore, Integer.put, ↓reduceIte]
          · have readonlyBody : (analysis.withIndex binder array.componentBounds).mutable index = false := by
              simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
            have preserved := statements_unchanged (functions := functions) (procedures := procedures) (input := input) (valid := valid)
              (values := current) (booleans := flags) (integers := Integer.put scalars binder (array.project scalars component))
              bodyChecked readonlyBody
            simpa only [Execution.restoreIndex, Integer.restore, Integer.put, same, ↓reduceIte] using preserved
        · contradiction
  termination_by sizeOf item

  theorem statements_unchanged {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment} {shape : Shape} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {before after : Flow}
      {items : List Statement} {input : Source} {valid : Bool} {values : Values} {integers : Integer.Store} {booleans : Boolean.Store}
      {index : Nat} (checked : checkStatements (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before items booleanAnalysis = some after)
      (readonly : analysis.mutable index = false) :
      (executeStatements (functions := functions) (procedures := procedures) input valid values items integers booleans).integers index = integers index := by
    cases items with
    | nil => simp only [executeStatements]
    | cons item rest =>
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have first := statement_unchanged (functions := functions) (procedures := procedures) (input := input) (valid := valid)
          (values := values) (integers := integers) (booleans := booleans) firstChecked readonly
        have following := statements_unchanged (functions := functions) (procedures := procedures) (input := input) (valid := valid)
          (values := (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).values)
          (integers := (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).integers)
          (booleans := (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).booleans) restChecked readonly
        simpa only [executeStatements] using following.trans first
  termination_by sizeOf items
end

/-- Boolean cells are independent of lexical Integer loop bindings. -/
theorem iterations_booleans_unchanged {step : Values → Integer.Store → Boolean.Store → Int → Execution}
    {values : Values} {integers : Integer.Store} {booleans : Boolean.Store} {indices : List Int} {index : Nat}
    (unchanged : ∀ current scalars flags value, (step current scalars flags value).booleans index = flags index) :
    (executeIterations step values integers booleans indices).booleans index = booleans index := by
  induction indices generalizing values integers booleans with
  | nil => rfl
  | cons value rest ih =>
      exact (ih (values := (step values integers booleans value).values)
        (integers := (step values integers booleans value).integers)
        (booleans := (step values integers booleans value).booleans)).trans
          (unchanged values integers booleans value)

mutual
  theorem statement_booleans_unchanged {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment} {shape : Shape} {analysis : Integer.Analysis}
      {booleanAnalysis : Boolean.Analysis} {before after : Flow} {item : Statement}
      {input : Source} {valid : Bool} {values : Values} {integers : Integer.Store} {booleans : Boolean.Store}
      {index : Nat} (checked : item.check (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before booleanAnalysis = some after)
      (readonly : booleanAnalysis.mutable index = false) :
      (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).booleans index = booleans index := by
    cases item with
    | simple item => cases item <;> simp only [Statement.execute, executeSimpleStatement]
    | scalarAssign | arrayAssign | reject => simp only [Statement.execute]
    | callAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · simpa only [Statement.execute] using
            update.boolean_unchanged (calls := functions.values)
              (state := ⟨values, input, valid, integers, booleans⟩) (by assumption) readonly
        · contradiction
    | procedureCall call =>
        simp only [Statement.check] at checked
        split at checked
        · simpa only [Statement.execute] using
            call.boolean_unchanged (environment := procedures)
              (state := ⟨values, input, valid, integers, booleans⟩) (by assumption) readonly
        · contradiction
    | booleanAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          have writable := Boolean.canWrite_mutable (Bool.and_eq_true_iff.mp good).1
          have different : index ≠ update.target := by
            intro same
            rw [← same, readonly] at writable
            contradiction
          simpa only [Statement.execute] using Boolean.put_other booleans update.target
            (update.value.evaluate values input valid integers booleans) index different
        · contradiction
    | booleanArrayAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          simpa only [Statement.execute] using update.unchanged
            (values := values) (input := input) (valid := valid) (integers := integers)
            (booleans := booleans) good readonly
        · contradiction
    | choice condition yes no =>
        simp only [Statement.check] at checked
        split at checked
        · simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, _⟩ := checked
          simp only [Statement.execute]
          split
          · exact statements_booleans_unchanged (functions := functions) (procedures := procedures) yesChecked readonly
          · exact statements_booleans_unchanged (functions := functions) (procedures := procedures) noChecked readonly
        · contradiction
    | forLoop binder reverse lower upper body =>
        simp only [Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, _, b, _, bodyAfter, bodyChecked, _⟩ := checked
        simp only [Statement.execute]
        apply iterations_booleans_unchanged
        intro current scalars flags value
        exact statements_booleans_unchanged (functions := functions) (procedures := procedures) bodyChecked readonly
    | arrayLoop binder reverse array body =>
        simp only [Statement.check] at checked
        split at checked
        · simp only [Option.map_eq_some_iff] at checked
          obtain ⟨bodyAfter, bodyChecked, _⟩ := checked
          simp only [Statement.execute]
          apply iterations_booleans_unchanged
          intro current scalars flags value
          exact statements_booleans_unchanged (functions := functions) (procedures := procedures) bodyChecked readonly
        · contradiction
  termination_by sizeOf item

  theorem statements_booleans_unchanged {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment} {shape : Shape} {analysis : Integer.Analysis}
      {booleanAnalysis : Boolean.Analysis} {before after : Flow} {items : List Statement}
      {input : Source} {valid : Bool} {values : Values} {integers : Integer.Store} {booleans : Boolean.Store}
      {index : Nat} (checked : checkStatements (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before items booleanAnalysis = some after)
      (readonly : booleanAnalysis.mutable index = false) :
      (executeStatements (functions := functions) (procedures := procedures) input valid values items integers booleans).booleans index = booleans index := by
    cases items with
    | nil => simp only [executeStatements]
    | cons item rest =>
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have first := statement_booleans_unchanged (functions := functions) (procedures := procedures) (input := input) (valid := valid)
          (values := values) (integers := integers) (booleans := booleans) firstChecked readonly
        have following := statements_booleans_unchanged (functions := functions) (procedures := procedures) (input := input) (valid := valid)
          (values := (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).values)
          (integers := (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).integers)
          (booleans := (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).booleans) restChecked readonly
        simpa only [executeStatements] using following.trans first
  termination_by sizeOf items
end

/-- Constant arrays retain their actual components across every admitted body,
including nested loops, branches, other-array writes and returning Reject. -/
theorem statements_constant_components {shape : Shape} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
    {before after : Flow} {items : List Statement} {input : Source} {valid : Bool}
    {values : Values} {integers : Integer.Store} {booleans : Boolean.Store} {array : Integer.ArrayDescriptor}
    (checked : checkStatements (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before items booleanAnalysis = some after)
    (readonly : ∀ cell, array.ContainsCell cell → analysis.mutable cell = false)
    {component : Int} (inside : array.bounds.Contains component) :
    array.project (executeStatements (functions := functions) (procedures := procedures) input valid values items integers booleans).integers component =
      array.project integers component :=
  statements_unchanged (functions := functions) (procedures := procedures) checked (readonly _ (array.address_within inside))

/-- Installing the lexical element binding cannot replace its actual component.
The premise is a generic core check, independent of native allocation bounds. -/
theorem arrayLoop_binding_component {analysis : Integer.Analysis} {flow : Flow} {index : Nat}
    {array : Integer.ArrayDescriptor} {integers : Integer.Store} {component value : Int}
    (ready : arrayLoopReady analysis flow index array = true)
    (inside : array.bounds.Contains component) :
    array.project (Integer.put integers index value) component = array.project integers component := by
  have separate := ((arrayLoopReady_iff analysis flow index array).mp ready).2.1
  have different : array.address component ≠ index := by
    intro same
    exact separate (same ▸ array.address_within inside)
  simp only [Integer.ArrayDescriptor.project, Integer.put, different, ↓reduceIte]

/- Each nested body is covered independently. An unchanged final loop store
alone would permit a transient binder collision; the loop clauses exclude it. -/
mutual
  def Statement.ComponentsStable (array : Integer.ArrayDescriptor) (item : Statement)
      (functions : ScalarFunctions.Environment := .empty)
      (procedures : ScalarProcedures.Environment := .empty) : Prop :=
    (∀ input valid values integers booleans component, array.bounds.Contains component →
      array.project (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).integers component =
        array.project integers component) ∧
    match item with
    | .simple _ | .scalarAssign _ | .callAssign _ | .procedureCall _ | .arrayAssign _ | .booleanAssign _ | .booleanArrayAssign _ | .reject => True
    | .choice _ yes no => StatementsComponentsStable (functions := functions) (procedures := procedures) array yes ∧ StatementsComponentsStable (functions := functions) (procedures := procedures) array no
    | .forLoop index _ _ _ body | .arrayLoop index _ _ body =>
        ¬array.ContainsCell index ∧ StatementsComponentsStable (functions := functions) (procedures := procedures) array body
  termination_by sizeOf item
  def StatementsComponentsStable (array : Integer.ArrayDescriptor) (items : List Statement)
      (functions : ScalarFunctions.Environment := .empty)
      (procedures : ScalarProcedures.Environment := .empty) : Prop :=
    match items with
    | [] => True
    | item :: rest => item.ComponentsStable (functions := functions) (procedures := procedures) array ∧ StatementsComponentsStable (functions := functions) (procedures := procedures) array rest
  termination_by sizeOf items
end

mutual
  theorem statement_components_stable {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment} {shape : Shape} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
      {before after : Flow} {item : Statement} {array : Integer.ArrayDescriptor}
      (checked : item.check (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before booleanAnalysis = some after)
      (readonly : ∀ cell, array.ContainsCell cell → analysis.mutable cell = false)
      (apart : item.bindersApart array = true) : item.ComponentsStable (functions := functions) (procedures := procedures) array := by
    rw [Statement.ComponentsStable.eq_def]
    refine ⟨fun input valid values integers booleans component inside =>
      statement_unchanged (functions := functions) (procedures := procedures) checked (readonly _ (array.address_within inside)), ?_⟩
    cases item with
    | simple | scalarAssign | callAssign | procedureCall | arrayAssign | booleanAssign | booleanArrayAssign | reject => trivial
    | choice condition yes no =>
        simp only [Statement.check] at checked
        simp only [Statement.bindersApart, Bool.and_eq_true] at apart
        split at checked
        · simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, _⟩ := checked
          exact ⟨statements_components_stable (functions := functions) (procedures := procedures) yesChecked readonly apart.1,
            statements_components_stable (functions := functions) (procedures := procedures) noChecked readonly apart.2⟩
        · contradiction
    | forLoop binder reverse lower upper body =>
        simp only [Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, _, b, _, bodyAfter, bodyChecked, _⟩ := checked
        simp only [Statement.bindersApart, Bool.and_eq_true, decide_eq_true_eq] at apart
        refine ⟨apart.1, statements_components_stable (functions := functions) (procedures := procedures) bodyChecked ?_ apart.2⟩
        intro cell inside
        have different : cell ≠ binder := fun same => apart.1 (same ▸ inside)
        simpa only [Integer.Analysis.withIndex, Integer.put, different, ↓reduceIte]
          using readonly cell inside
    | arrayLoop binder reverse iterable body =>
        simp only [Statement.check] at checked
        simp only [Statement.bindersApart, Bool.and_eq_true, decide_eq_true_eq] at apart
        split at checked
        · simp only [Option.map_eq_some_iff] at checked
          obtain ⟨bodyAfter, bodyChecked, _⟩ := checked
          refine ⟨apart.1, statements_components_stable (functions := functions) (procedures := procedures) bodyChecked ?_ apart.2⟩
          intro cell inside
          have different : cell ≠ binder := fun same => apart.1 (same ▸ inside)
          simpa only [Integer.Analysis.withIndex, Integer.put, different, ↓reduceIte]
            using readonly cell inside
        · contradiction
  termination_by sizeOf item

  theorem statements_components_stable {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment} {shape : Shape} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
      {before after : Flow} {items : List Statement} {array : Integer.ArrayDescriptor}
      (checked : checkStatements (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before items booleanAnalysis = some after)
      (readonly : ∀ cell, array.ContainsCell cell → analysis.mutable cell = false)
      (apart : statementsBindersApart array items = true) : StatementsComponentsStable (functions := functions) (procedures := procedures) array items := by
    cases items with
    | nil => simp only [StatementsComponentsStable]
    | cons item rest =>
        simp only [StatementsComponentsStable]
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        simp only [statementsBindersApart, Bool.and_eq_true] at apart
        exact ⟨statement_components_stable (functions := functions) (procedures := procedures) firstChecked readonly apart.1,
          statements_components_stable (functions := functions) (procedures := procedures) restChecked readonly apart.2⟩
  termination_by sizeOf items
end

/-- Admission establishes component preservation at every nested body, as well
as at the complete iteration boundary. No source identity bound is assumed. -/
theorem arrayLoop_components_stable {shape : Shape} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
    {before after : Flow} {index : Nat} {reverse : Bool} {array : Integer.ArrayDescriptor}
    {body : List Statement}
    (checked : (Statement.arrayLoop index reverse array body).check (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before booleanAnalysis = some after) :
    (Statement.arrayLoop index reverse array body).ComponentsStable (functions := functions) (procedures := procedures) array := by
  have accepted := checked
  simp only [Statement.check] at accepted
  split at accepted
  · rename_i ready
    have both := Bool.and_eq_true_iff.mp ready
    have properties := (arrayLoopReady_iff analysis before index array).mp both.1
    apply statement_components_stable (functions := functions) (procedures := procedures) checked properties.2.2.2.2.1
    simp only [Statement.bindersApart, Bool.and_eq_true, decide_eq_true_eq]
    exact ⟨properties.2.1, both.2⟩
  · contradiction

/-- The immutable scalar binding still denotes the actual component after the
body. Recursive ComponentsStable additionally covers each nested body boundary. -/
theorem arrayLoop_body_actual_component {shape : Shape} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
    {flow after : Flow} {index : Nat} {array : Integer.ArrayDescriptor} {body : List Statement}
    {input : Source} {valid : Bool} {values : Values} {integers : Integer.Store} {booleans : Boolean.Store} {component : Int}
    (ready : arrayLoopReady analysis flow index array = true)
    (checked : checkStatements (signatures := functions.signatures) (procedures := procedures.signatures) shape (analysis.withIndex index array.componentBounds)
      (arrayLoopEntry analysis flow index array.componentBounds) body booleanAnalysis = some after)
    (inside : array.bounds.Contains component) :
    let result := executeStatements (functions := functions) (procedures := procedures) input valid values body
      (Integer.put integers index (array.project integers component)) booleans
    result.integers index = array.project result.integers component := by
  have properties := (arrayLoopReady_iff analysis flow index array).mp ready
  have readonlyBody : ∀ cell, array.ContainsCell cell →
      (analysis.withIndex index array.componentBounds).mutable cell = false := by
    intro cell cellInside
    have different : cell ≠ index := fun same => properties.2.1 (same ▸ cellInside)
    simpa only [Integer.Analysis.withIndex, Integer.put, different, ↓reduceIte]
      using properties.2.2.2.2.1 cell cellInside
  have componentPreserved := statements_constant_components (functions := functions) (procedures := procedures) (input := input) (valid := valid)
    (values := values) (booleans := booleans) (integers := Integer.put integers index (array.project integers component))
    checked readonlyBody inside
  have entry := arrayLoop_binding_component (integers := integers)
    (value := array.project integers component) ready inside
  have bindingPreserved := statements_unchanged (functions := functions) (procedures := procedures) (input := input) (valid := valid) (values := values)
    (integers := Integer.put integers index (array.project integers component)) (booleans := booleans) (index := index)
    checked (by simp only [Integer.Analysis.withIndex, Integer.put, ↓reduceIte])
  calc
    _ = (Integer.put integers index (array.project integers component)) index := bindingPreserved
    _ = array.project integers component := by simp only [Integer.put, ↓reduceIte]
    _ = _ := (componentPreserved.trans entry).symm

structure ExecutionSound (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) (input : Source)
    (valid beforeRejected : Bool) (result : Execution) (ordinary : Option Execution) : Prop where
  state : Fits shape input result.values
  effects : EffectsValid result.effects
  invalid_no_output : valid = false → NoOutput result.effects
  next : flow.path.Allows valid input.length (rejectedAfter beforeRejected result.effects)
  agreement : ordinary = some result
  scalars : Integer.Fits flow.scalars result.integers
  declared : Integer.Fits analysis.declared result.integers

theorem simple_execution_sound {shape : Shape} {analysis : Integer.Analysis} {flow : Flow}
    {integers : Integer.Store} {booleans : Boolean.Store}
    {item : Sequence.SimpleStatement} {input : Source} {values : Values} {valid rejected : Bool}
    (wellFormed : SimpleWellFormed shape item) (checked : checkSimple shape flow.path item flow.scalars = true)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : flow.Allows valid input.length rejected integers)
    (declaredState : Integer.Fits analysis.declared integers) :
    ExecutionSound shape analysis flow input valid rejected
      (executeSimpleStatement input values item integers booleans) (checkedSimpleStatement input values item integers booleans) := by
  cases item with
  | null =>
      exact ⟨state, by simp [executeSimpleStatement, EffectsValid],
        by simp [executeSimpleStatement, NoOutput],
        by simpa [executeSimpleStatement, rejectedAfter] using allowed.1, rfl, allowed.2, declaredState⟩
  | assign update =>
      have preserved := assignment_preserves_on_path wellFormed.1 state allowed.2 printable allowed.1 checked
      have length := assignment_checked_length state allowed.2 allowed.1 checked
      have safe := assignment_checked_safe state allowed.2 allowed.1 checked
      refine ⟨preserved, by simp [executeSimpleStatement, EffectsValid],
        by simp [executeSimpleStatement, NoOutput], ?_, ?_, allowed.2, declaredState⟩
      · simpa [executeSimpleStatement, rejectedAfter] using allowed.1
      · simp [checkedSimpleStatement, executeSimpleStatement,
          Expression.checkedEvaluate_agrees safe, length, executeAssignment]
  | output expression | put expression =>
      simp only [checkSimple] at checked
      split at checked
      · rename_i summary known
        simp only [Bool.and_eq_true, Bool.not_eq_true'] at checked
        have safe := expression_safe_on_path known state allowed.2 allowed.1 checked.1
        have outputValid : (expression.evaluate values input integers).length ≤ maxSourceLength ∧
            Bindings.Printable (expression.evaluate values input integers) :=
          ⟨safe.2, Expression.inferLength_printable known state printable wellFormed.2.1⟩
        refine ⟨state, ?_, ?_, ?_, ?_, allowed.2, declaredState⟩
        · intro effect member
          simp only [executeSimpleStatement, List.mem_singleton] at member
          subst effect
          exact outputValid
        · intro invalid
          have inputValid := Context.output_requires_valid_input allowed.1 checked.2
          simp [invalid] at inputValid
        · simpa [executeSimpleStatement, rejectedAfter, isReject] using allowed.1
        · simp [checkedSimpleStatement, executeSimpleStatement, Expression.checkedEvaluate_agrees safe]
      · contradiction

/-- Input facts are immutable and rejection is sticky across any iteration. -/
theorem allows_after_effects {context : Context} {valid : Bool} {length : Nat} {rejected : Bool}
    (allowed : context.Allows valid length rejected) (effects : List Effect) :
    context.Allows valid length (rejectedAfter rejected effects) := by
  cases valid with
  | true => exact allowed
  | false =>
      exact ⟨allowed.1, allowed.2.1, fun required => by
        simp only [rejectedAfter, allowed.2.2 required, Bool.true_or]⟩

theorem iterations_execution_sound {shape : Shape} {analysis : Integer.Analysis}
    {ranges : Integer.Ranges} {before after : Context}
    {input : Source} {valid rejected : Bool} {values : Values} {integers : Integer.Store} {booleans : Boolean.Store} {indices : List Int}
    {step : Values → Integer.Store → Boolean.Store → Int → Execution}
    {checkedStep : Values → Integer.Store → Boolean.Store → Int → Option Execution}
    (bodies : ∀ index ∈ indices, ∀ current scalars flags already,
      Fits shape input current → before.Allows valid input.length already → Integer.Fits ranges scalars →
      Integer.Fits analysis.declared scalars →
      ExecutionSound shape analysis ⟨after, ranges⟩ input valid already
        (step current scalars flags index) (checkedStep current scalars flags index))
    (state : Fits shape input values) (allowed : before.Allows valid input.length rejected)
    (scalarState : Integer.Fits ranges integers) (declaredState : Integer.Fits analysis.declared integers) :
    ExecutionSound shape analysis ⟨if indices = [] then before else after, ranges⟩ input valid rejected
      (executeIterations step values integers booleans indices) (checkedIterations checkedStep values integers booleans indices) := by
  induction indices generalizing values integers booleans rejected with
  | nil =>
      exact ⟨state, by simp [executeIterations, EffectsValid],
        by simp [executeIterations, NoOutput],
        by simpa only [executeIterations, rejectedAfter, List.any_nil, Bool.or_false, ↓reduceIte] using allowed,
        rfl, scalarState, declaredState⟩
  | cons index rest ih =>
      have first := bodies index (by simp) values integers booleans rejected state allowed scalarState declaredState
      have remaining : ∀ item ∈ rest, ∀ current scalars flags already,
          Fits shape input current → before.Allows valid input.length already → Integer.Fits ranges scalars →
          Integer.Fits analysis.declared scalars →
          ExecutionSound shape analysis ⟨after, ranges⟩ input valid already
            (step current scalars flags item) (checkedStep current scalars flags item) :=
        fun item member => bodies item (List.mem_cons_of_mem index member)
      have following := ih (booleans := (step values integers booleans index).booleans) remaining first.state
        (allows_after_effects allowed (step values integers booleans index).effects) first.scalars first.declared
      refine ⟨following.state, ?_, ?_, ?_, ?_, following.scalars, following.declared⟩
      · exact Sequence.effects_valid_append first.effects following.effects
      · intro invalid
        exact noOutput_append (first.invalid_no_output invalid) (following.invalid_no_output invalid)
      · by_cases empty : rest = []
        · subst rest
          simpa only [executeIterations, List.append_nil, List.cons_ne_nil, ↓reduceIte] using first.next
        · simpa only [executeIterations, rejectedAfter_append, empty, List.cons_ne_nil, ↓reduceIte] using following.next
      · simp only [checkedIterations, first.agreement, Option.bind_some, following.agreement,
          Option.map_some, executeIterations]

mutual
  theorem statement_execution_sound_with_procedures {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment} {shape : Shape} {before after : Flow} {hasArguments : Bool}
      {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
      {item : Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (certified : functions.Valid) (procedureCertified : procedures.Valid)
    (wellFormed : item.WellFormed hasArguments shape booleanAnalysis)
      (checked : item.check (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before booleanAnalysis = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers) :
      ExecutionSound shape analysis after input valid rejected
        (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans) (item.checkedExecute (functions := functions) (procedures := procedures) input valid values integers booleans) := by
    cases item with
    | simple item =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          simpa only [Statement.execute, Statement.checkedExecute] using
            simple_execution_sound wellFormed good state printable allowed declaredState
        · contradiction
    | scalarAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          have sound := update.check_flow_sound good allowed.2 declaredState
          simp only [Statement.execute, Statement.checkedExecute]
          refine ⟨state, by simp [EffectsValid], by simp [NoOutput], ?_, ?_, sound.2.2.1, sound.2.1⟩
          · simpa [rejectedAfter] using allowed.1
          · simp only [sound.2.2.2, Option.map_some]
        · contradiction
    | callAssign update =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          have sound := update.check_execution_sound (state := ⟨values, input, valid, integers, booleans⟩) certified state wellFormed.2
            allowed declaredState good
          have agreement := update.checkedExecute_agrees (state := ⟨values, input, valid, integers, booleans⟩) certified state wellFormed.2 allowed good
          have frame := update.execute_frame functions.values ⟨values, input, valid, integers, booleans⟩
          simp only [Statement.execute, Statement.checkedExecute, agreement, Option.map_some]
          refine ⟨?_, by simp [EffectsValid], by simp [NoOutput], ?_, rfl, sound.2.2.1.2, sound.2.1⟩
          · simpa only [frame.1] using state
          · simpa [rejectedAfter] using sound.2.2.1.1
        · contradiction
    | procedureCall call =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          have sound := call.check_execution_sound (state := ⟨values, input, valid, integers, booleans⟩)
            procedureCertified state wellFormed allowed declaredState good
          have frame := call.execute_frame procedures ⟨values, input, valid, integers, booleans⟩
          simp only [Statement.execute, Statement.checkedExecute, sound.2.2, Option.map_some]
          refine ⟨?_, by simp [EffectsValid], by simp [NoOutput], ?_, rfl, sound.2.1.2, sound.1⟩
          · simpa only [frame.1] using state
          · simpa [rejectedAfter] using sound.2.1.1
        · contradiction
    | arrayAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          have both : update.check before.scalars analysis.mutable = true ∧
              update.array.componentRanges analysis.declared = true := by
            simpa only [checkArrayAssignment, Bool.and_eq_true] using good
          have accepted := both.1
          have full := (Integer.ArrayDescriptor.componentRanges_iff _ _).mp both.2
          have sound := update.check_sound accepted allowed.2
          have declared : Integer.Fits analysis.declared (update.execute integers) := by
            simpa only [Integer.ArrayAssignment.execute, sound.2.2.1, ↓reduceIte] using
              update.array.write_preserves_ranges declaredState full sound.2.2.1
                (update.component_sound accepted allowed.2)
          simp only [Statement.execute, Statement.checkedExecute]
          refine ⟨state, by simp [EffectsValid], by simp [NoOutput], ?_, ?_, sound.2.2.2.1, declared⟩
          · simpa [rejectedAfter] using allowed.1
          · simp only [sound.2.2.2.2, Option.map_some]
        · contradiction
    | booleanAssign update =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          have bounds := (Bool.and_eq_true_iff.mp good).2
          have agreement := update.value.checkedEvaluate_of_checkBounds (booleans := booleans)
            state wellFormed.2.2 allowed bounds
          simp only [Statement.execute, Statement.checkedExecute, agreement, Option.map_some]
          exact ⟨state, by simp [EffectsValid], by simp [NoOutput],
            by simpa [rejectedAfter] using allowed.1, rfl, allowed.2, declaredState⟩
        · contradiction
    | booleanArrayAssign update =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          have sound := update.check_sound (booleans := booleans)
            good wellFormed.2.2 state allowed
          simp only [Statement.execute, Statement.checkedExecute, sound.2.2.2, Option.map_some]
          exact ⟨state, by simp [EffectsValid], by simp [NoOutput],
            by simpa [rejectedAfter] using allowed.1, rfl, allowed.2, declaredState⟩
        · contradiction
    | reject =>
        simp only [Statement.check, Option.some.injEq] at checked
        subst after
        simp only [Statement.execute, Statement.checkedExecute]
        refine ⟨state, ?_, ?_, ?_, rfl, allowed.2, declaredState⟩
        · simp [EffectsValid, Sequence.Effect.Valid]
        · simp [NoOutput]
        · simpa [rejectedAfter, isReject] using Context.reject_sound allowed.1
    | choice condition yes no =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i bounded
          simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, rfl⟩ := checked
          have comparison := condition.checkedEvaluate_of_checkBounds (booleans := booleans) state wellFormed.2.1 allowed bounded
          have refined := condition.refine_sound (analysis := analysis) (booleans := booleans) state wellFormed.2.1 allowed
          cases outcome : condition.evaluate values input valid integers booleans with
          | true =>
              simp only [outcome] at refined
              have selected := statements_execution_sound_with_procedures (functions := functions) (procedures := procedures) certified procedureCertified (booleans := booleans) wellFormed.2.2.2.1 yesChecked state printable refined declaredState
              refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.state
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.effects
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.invalid_no_output
              · simpa only [Statement.execute, outcome, ↓reduceIte, Flow.join] using Context.join_left selected.next
              · simpa only [Statement.checkedExecute, comparison, Option.bind_some, Statement.execute,
                  outcome, ↓reduceIte] using selected.agreement
              · simpa only [Statement.execute, outcome, ↓reduceIte, Flow.join] using Integer.Ranges.join_left selected.scalars
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.declared
          | false =>
              simp only [outcome] at refined
              have selected := statements_execution_sound_with_procedures (functions := functions) (procedures := procedures) certified procedureCertified (booleans := booleans) wellFormed.2.2.2.2 noChecked state printable refined declaredState
              refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.state
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.effects
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.invalid_no_output
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte, Flow.join] using Context.join_right selected.next
              · simpa only [Statement.checkedExecute, comparison, Option.bind_some, Statement.execute,
                  outcome, Bool.false_eq_true, ↓reduceIte] using selected.agreement
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte, Flow.join] using Integer.Ranges.join_right selected.scalars
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.declared
        · contradiction
    | forLoop index reverse lower upper body =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, lowerFound, b, upperFound, bodyAfter, bodyChecked, rfl⟩ := checked
        have lowerSafe := Integer.Expr.inferred_execution lowerFound allowed.2
        have upperSafe := Integer.Expr.inferred_execution upperFound allowed.2
        let indices := Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers)
        let widened := analysis.widen before.scalars
        have lowWithin := (Integer.Expr.infer_sound lowerFound allowed.2).1
        have highWithin := (Integer.Expr.infer_sound upperFound allowed.2).1
        have iterated : ExecutionSound shape analysis
            ⟨if indices = [] then before.path else bodyAfter.path, widened⟩ input valid rejected
            (executeIterations (fun current scalars flags value =>
              (executeStatements (functions := functions) (procedures := procedures) input valid current body (Integer.put scalars index value) flags).restoreIndex index scalars)
              values integers booleans indices)
            (checkedIterations (fun current scalars flags value =>
              (checkedStatements (functions := functions) (procedures := procedures) input valid current body (Integer.put scalars index value) flags).map
                fun result => result.restoreIndex index scalars) values integers booleans indices) := by
          apply iterations_execution_sound _ state allowed.1
            (analysis.widen_fits allowed.2 declaredState) declaredState
          intro value member current scalars flags already currentState currentAllowed currentScalars currentDeclared
          have within := Integer.loopBounds_contains lowWithin highWithin (Integer.iterationValues_contains member)
          have bodyAllowed : (loopEntry analysis before index (Integer.loopBounds a b)).Allows
              valid input.length already (Integer.put scalars index value) := by
            refine ⟨?_, Integer.put_fits currentScalars within⟩
            simpa only [loopEntry, loopContext, Integer.Interval.contains_nonempty within, Bool.false_eq_true, ↓reduceIte]
              using currentAllowed
          have bodySound := statements_execution_sound_with_procedures (functions := functions) (procedures := procedures) certified procedureCertified (booleans := flags) wellFormed.2.2 bodyChecked currentState printable bodyAllowed
            (Integer.put_fits currentDeclared within)
          have restoredDeclared := Integer.restore_fits currentDeclared bodySound.declared
          have restoredCurrent : Integer.Fits widened
              (Integer.restore scalars (executeStatements (functions := functions) (procedures := procedures) input valid current body
                (Integer.put scalars index value) flags).integers index) := by
            apply analysis.widen_closed currentScalars restoredDeclared
            intro other readonly
            by_cases same : other = index
            · subst other
              simp only [Integer.restore, Integer.put, ↓reduceIte]
            · have readBody : (analysis.withIndex index (Integer.loopBounds a b)).mutable other = false := by
                simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
              have unchanged := statements_unchanged (functions := functions) (procedures := procedures) (input := input) (valid := valid)
                (values := current) (booleans := flags) (integers := Integer.put scalars index value) bodyChecked readBody
              simpa only [Integer.restore, Integer.put, same, ↓reduceIte] using unchanged
          exact ⟨bodySound.state, bodySound.effects, bodySound.invalid_no_output, bodySound.next,
            by rw [bodySound.agreement]; rfl, restoredCurrent, restoredDeclared⟩
        simp only [Statement.execute, Statement.checkedExecute, lowerSafe, upperSafe, Option.bind_some]
        refine ⟨iterated.state, iterated.effects, iterated.invalid_no_output, ?_, iterated.agreement, ?_, iterated.declared⟩
        · change (loopAfter before.path bodyAfter.path a b).Allows valid input.length _
          unfold loopAfter
          split
          · rename_i empty
            have noIterations : indices = [] :=
              Integer.iterationValues_empty (Integer.loopBounds_empty lowWithin highWithin empty)
            have next := iterated.next
            rw [ite_eq_left noIterations] at next
            exact next
          · split
            · rename_i definite
              have iterations : indices ≠ [] :=
                Integer.iterationValues_nonempty (Integer.loopDefinite_nonempty lowWithin highWithin definite)
              have next := iterated.next
              rw [ite_eq_right iterations] at next
              exact next
            · by_cases noIterations : indices = []
              · have next := iterated.next
                rw [ite_eq_left noIterations] at next
                exact Context.join_left next
              · have next := iterated.next
                rw [ite_eq_right noIterations] at next
                exact Context.join_right next
        · change Integer.Fits (if (Integer.loopBounds a b).isEmpty then before.scalars else widened) _
          split
          · rename_i empty
            have noIterations : indices = [] :=
              Integer.iterationValues_empty (Integer.loopBounds_empty lowWithin highWithin empty)
            change Integer.Fits before.scalars (executeIterations _ values integers booleans indices).integers
            simpa only [noIterations, executeIterations] using allowed.2
          · exact iterated.scalars
    | arrayLoop index reverse array body =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i ready
          have properties := (arrayLoopReady_iff analysis before index array).mp (Bool.and_eq_true_iff.mp ready).1
          simp only [Option.map_eq_some_iff] at checked
          obtain ⟨bodyAfter, bodyChecked, rfl⟩ := checked
          let indices := Integer.iterationValues reverse array.bounds.lower array.bounds.upper
          let widened := analysis.widen before.scalars
          have nonempty : indices ≠ [] := Integer.iterationValues_nonempty properties.1.2
          have iterated : ExecutionSound shape analysis
              ⟨if indices = [] then before.path else bodyAfter.path, widened⟩ input valid rejected
              (executeIterations (fun current scalars flags component =>
                (executeStatements (functions := functions) (procedures := procedures) input valid current body
                  (Integer.put scalars index (array.project scalars component)) flags).restoreIndex index scalars)
                values integers booleans indices)
              (checkedIterations (fun current scalars flags component =>
                if array.bounds.Contains component then
                  (Integer.checkedValue (array.project scalars component)).bind fun value =>
                    (checkedStatements (functions := functions) (procedures := procedures) input valid current body (Integer.put scalars index value) flags).map
                      fun result => result.restoreIndex index scalars
                else none) values integers booleans indices) := by
            apply iterations_execution_sound _ state allowed.1
              (analysis.widen_fits allowed.2 declaredState) declaredState
            intro component member current scalars flags already currentState currentAllowed currentScalars currentDeclared
            have inside : array.bounds.Contains component := Integer.iterationValues_contains member
            have valueWithin : array.componentBounds.Contains (array.project scalars component) :=
              currentDeclared _ _ (properties.2.2.2.1 component inside)
            have valueSafe : Integer.InRange (array.project scalars component) :=
              Integer.Interval.bounded_contains properties.2.2.2.2.2.1 valueWithin
            have bodyAllowed : (arrayLoopEntry analysis before index array.componentBounds).Allows
                valid input.length already (Integer.put scalars index (array.project scalars component)) :=
              ⟨currentAllowed, Integer.put_fits currentScalars valueWithin⟩
            have bodySound := statements_execution_sound_with_procedures (functions := functions) (procedures := procedures) certified procedureCertified (booleans := flags) wellFormed.2.2 bodyChecked currentState printable bodyAllowed
              (Integer.put_fits currentDeclared valueWithin)
            have restoredDeclared := Integer.restore_fits currentDeclared bodySound.declared
            have restoredCurrent : Integer.Fits widened
                (Integer.restore scalars (executeStatements (functions := functions) (procedures := procedures) input valid current body
                  (Integer.put scalars index (array.project scalars component)) flags).integers index) := by
              apply analysis.widen_closed currentScalars restoredDeclared
              intro other readonly
              by_cases same : other = index
              · subst other
                simp only [Integer.restore, Integer.put, ↓reduceIte]
              · have readBody : (analysis.withIndex index array.componentBounds).mutable other = false := by
                  simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
                have unchanged := statements_unchanged (functions := functions) (procedures := procedures) (input := input) (valid := valid)
                  (values := current) (booleans := flags) (integers := Integer.put scalars index (array.project scalars component))
                  bodyChecked readBody
                simpa only [Integer.restore, Integer.put, same, ↓reduceIte] using unchanged
            refine ⟨bodySound.state, bodySound.effects, bodySound.invalid_no_output, bodySound.next,
              ?_, restoredCurrent, restoredDeclared⟩
            simp only [inside, ↓reduceIte, Integer.checkedValue, valueSafe,
              Option.bind_some, bodySound.agreement, Option.map_some]
          simpa only [Statement.execute, Statement.checkedExecute, arrayLoopExit, nonempty, ↓reduceIte]
            using iterated
        · contradiction
  termination_by sizeOf item

  theorem statements_execution_sound_with_procedures {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment} {shape : Shape} {before after : Flow} {hasArguments : Bool}
      {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
      {items : List Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (certified : functions.Valid) (procedureCertified : procedures.Valid)
    (wellFormed : StatementsWellFormed hasArguments shape items booleanAnalysis)
      (checked : checkStatements (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before items booleanAnalysis = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers) :
      ExecutionSound shape analysis after input valid rejected
        (executeStatements (functions := functions) (procedures := procedures) input valid values items integers booleans) (checkedStatements (functions := functions) (procedures := procedures) input valid values items integers booleans) := by
    cases items with
    | nil =>
        simp only [checkStatements, Option.some.injEq] at checked
        subst after
        simp only [executeStatements, checkedStatements]
        exact ⟨state, by simp [EffectsValid], by simp [NoOutput],
          by simpa [rejectedAfter] using allowed.1, rfl, allowed.2, declaredState⟩
    | cons item rest =>
        simp only [StatementsWellFormed] at wellFormed
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have first := statement_execution_sound_with_procedures (functions := functions) (procedures := procedures) certified procedureCertified (booleans := booleans) wellFormed.1 firstChecked state printable allowed declaredState
        have following := statements_execution_sound_with_procedures (functions := functions) (procedures := procedures) certified procedureCertified
          (booleans := (item.execute (functions := functions) (procedures := procedures) input valid values integers booleans).booleans) wellFormed.2 restChecked first.state printable
          ⟨first.next, first.scalars⟩ first.declared
        refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
        · simpa only [executeStatements] using following.state
        · simpa only [executeStatements] using Sequence.effects_valid_append first.effects following.effects
        · intro invalid
          simpa only [executeStatements] using noOutput_append (first.invalid_no_output invalid) (following.invalid_no_output invalid)
        · simpa only [executeStatements, rejectedAfter_append] using following.next
        · simp only [checkedStatements, first.agreement, Option.bind_some, following.agreement,
            Option.map_some, executeStatements]
        · simpa only [executeStatements] using following.scalars
        · simpa only [executeStatements] using following.declared
  termination_by sizeOf items
end

theorem completed_invalid_rejected_with_procedures {shape : Shape} {before after : Flow} {hasArguments : Bool}
    {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
    {items : List Statement} {input : Source} {values : Values}
    (certified : functions.Valid) (procedureCertified : procedures.Valid)
    (wellFormed : StatementsWellFormed hasArguments shape items booleanAnalysis)
    (checked : checkStatements (signatures := functions.signatures) (procedures := procedures.signatures) shape analysis before items booleanAnalysis = some after)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : before.Allows false input.length false integers) (finished : completed after.path = true)
    (declaredState : Integer.Fits analysis.declared integers) :
    Effect.reject ∈ (executeStatements (functions := functions) (procedures := procedures) input false values items integers booleans).effects ∧
      NoOutput (executeStatements (functions := functions) (procedures := procedures) input false values items integers booleans).effects := by
  have sound := statements_execution_sound_with_procedures (functions := functions) (procedures := procedures) certified procedureCertified (booleans := booleans) wellFormed checked state printable allowed declaredState
  have reachable := sound.next.2.1
  have guaranteed : after.path.invalidRejected = true := by
    simpa only [completed, reachable, Bool.not_true, Bool.false_or] using finished
  have rejected := Context.invalid_rejection_required sound.next guaranteed
  constructor
  · simp only [rejectedAfter, Bool.false_or, List.any_eq_true] at rejected
    obtain ⟨effect, member, isRejection⟩ := rejected
    cases effect with
    | output bytes | put bytes => contradiction
    | reject => exact member
  · exact sound.invalid_no_output rfl

theorem execute_statements_append (input : Source) (valid : Bool) (values : Values)
    (first following : List Statement) (integers : Integer.Store := Integer.emptyStore)
      (booleans : Boolean.Store := Boolean.emptyStore) :
    executeStatements (functions := functions) (procedures := procedures) input valid values (first ++ following) integers booleans =
      let before := executeStatements (functions := functions) (procedures := procedures) input valid values first integers booleans
      let after := executeStatements (functions := functions) (procedures := procedures) input valid before.values following before.integers before.booleans
      ⟨after.values, before.effects ++ after.effects, after.integers, after.booleans⟩ := by
  induction first generalizing values integers booleans with
  | nil => simp [executeStatements]
  | cons item rest ih => simp [executeStatements, ih, List.append_assoc]


/-- Existing function-only endpoints specialize the extended semantics to no procedures. -/
theorem statement_execution_sound {functions : ScalarFunctions.Environment} {shape : Shape} {before after : Flow} {hasArguments : Bool}
      {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
      {item : Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (certified : functions.Valid)
    (wellFormed : item.WellFormed hasArguments shape booleanAnalysis)
      (checked : item.check (signatures := functions.signatures) shape analysis before booleanAnalysis = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers) :
      ExecutionSound shape analysis after input valid rejected
        (item.execute (functions := functions) input valid values integers booleans) (item.checkedExecute (functions := functions) input valid values integers booleans) := by
  exact statement_execution_sound_with_procedures (procedures := .empty) certified ScalarProcedures.Environment.empty_valid wellFormed checked state printable allowed declaredState

theorem statements_execution_sound {functions : ScalarFunctions.Environment} {shape : Shape} {before after : Flow} {hasArguments : Bool}
      {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
      {items : List Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (certified : functions.Valid)
    (wellFormed : StatementsWellFormed hasArguments shape items booleanAnalysis)
      (checked : checkStatements (signatures := functions.signatures) shape analysis before items booleanAnalysis = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers) :
      ExecutionSound shape analysis after input valid rejected
        (executeStatements (functions := functions) input valid values items integers booleans) (checkedStatements (functions := functions) input valid values items integers booleans) := by
  exact statements_execution_sound_with_procedures (procedures := .empty) certified ScalarProcedures.Environment.empty_valid wellFormed checked state printable allowed declaredState

theorem completed_invalid_rejected {shape : Shape} {before after : Flow} {hasArguments : Bool}
    {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
    {items : List Statement} {input : Source} {values : Values}
    (certified : functions.Valid)
    (wellFormed : StatementsWellFormed hasArguments shape items booleanAnalysis)
    (checked : checkStatements (signatures := functions.signatures) shape analysis before items booleanAnalysis = some after)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : before.Allows false input.length false integers) (finished : completed after.path = true)
    (declaredState : Integer.Fits analysis.declared integers) :
    Effect.reject ∈ (executeStatements (functions := functions) input false values items integers booleans).effects ∧
      NoOutput (executeStatements (functions := functions) input false values items integers booleans).effects := by
  exact completed_invalid_rejected_with_procedures (procedures := .empty) certified ScalarProcedures.Environment.empty_valid wellFormed checked state printable allowed finished declaredState

end Silver.Predicate
