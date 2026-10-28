module

public import Silver.PredicateStatements
public import Silver.SequenceExecution

@[expose] public section

/-! Predicate-control execution keeps the established String store and effect
trace. Reject contributes an effect and returns; later statements still execute.
The static checker separately guarantees no output on any invalid-input path. -/

namespace Silver.Predicate
open Bindings Compose PathFacts
open Sequence (Effect EffectsValid)

set_option maxRecDepth 10000
set_option maxHeartbeats 500000

structure Execution where
  values : Values
  effects : List Effect
  integers : Integer.Store

def Execution.restoreIndex (result : Execution) (index : Nat) (before : Integer.Store) : Execution :=
  {result with integers := Integer.restore before result.integers index}

def executeSimpleStatement (input : Source) (values : Values) (item : Sequence.SimpleStatement)
    (integers : Integer.Store) : Execution :=
  match item with
  | .null => ⟨values, [], integers⟩
  | .assign update => ⟨executeAssignment update values input integers, [], integers⟩
  | .output expression => ⟨values, [.output (expression.evaluate values input integers)], integers⟩
  | .put expression => ⟨values, [.put (expression.evaluate values input integers)], integers⟩

def checkedSimpleStatement (input : Source) (values : Values) (item : Sequence.SimpleStatement)
    (integers : Integer.Store) : Option Execution :=
  match item with
  | .null => some ⟨values, [], integers⟩
  | .assign update => (update.value.checkedEvaluate values input integers).bind fun value =>
      if value.length = (values update.target).length then
        some ⟨Bindings.put values update.target value, [], integers⟩ else none
  | .output expression => (expression.checkedEvaluate values input integers).map fun value =>
      ⟨values, [.output value], integers⟩
  | .put expression => (expression.checkedEvaluate values input integers).map fun value =>
      ⟨values, [.put value], integers⟩

def executeIterations (step : Values → Integer.Store → Int → Execution) :
    Values → Integer.Store → List Int → Execution
  | values, integers, [] => ⟨values, [], integers⟩
  | values, integers, index :: rest =>
      let first := step values integers index
      let following := executeIterations step first.values first.integers rest
      ⟨following.values, first.effects ++ following.effects, following.integers⟩

def checkedIterations (step : Values → Integer.Store → Int → Option Execution) :
    Values → Integer.Store → List Int → Option Execution
  | values, integers, [] => some ⟨values, [], integers⟩
  | values, integers, index :: rest => (step values integers index).bind fun first =>
      (checkedIterations step first.values first.integers rest).map fun following =>
        ⟨following.values, first.effects ++ following.effects, following.integers⟩

mutual
  def Statement.execute (input : Source) (inputValid : Bool) (values : Values) (item : Statement)
      (integers : Integer.Store := Integer.emptyStore) : Execution :=
    match item with
    | .simple item => executeSimpleStatement input values item integers
    | .scalarAssign update => ⟨values, [], update.execute integers⟩
    | .arrayAssign update => ⟨values, [], update.execute integers⟩
    | .reject => ⟨values, [.reject], integers⟩
    | .choice condition yes no =>
        if condition.evaluate values input inputValid integers
        then executeStatements input inputValid values yes integers
        else executeStatements input inputValid values no integers
    | .forLoop index reverse lower upper body =>
        executeIterations (fun current scalars value =>
          (executeStatements input inputValid current body (Integer.put scalars index value)).restoreIndex index scalars)
          values integers (Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers))
    | .arrayLoop index reverse array body =>
        executeIterations (fun current scalars component =>
          (executeStatements input inputValid current body
            (Integer.put scalars index (array.project scalars component))).restoreIndex index scalars)
          values integers (Integer.iterationValues reverse array.bounds.lower array.bounds.upper)
  termination_by sizeOf item
  def executeStatements (input : Source) (inputValid : Bool) (values : Values) (items : List Statement)
      (integers : Integer.Store := Integer.emptyStore) : Execution :=
    match items with
    | [] => ⟨values, [], integers⟩
    | item :: rest =>
        let first := item.execute input inputValid values integers
        let following := executeStatements input inputValid first.values rest first.integers
        ⟨following.values, first.effects ++ following.effects, following.integers⟩
  termination_by sizeOf items
end

mutual
  def Statement.checkedExecute (input : Source) (inputValid : Bool) (values : Values) (item : Statement)
      (integers : Integer.Store := Integer.emptyStore) : Option Execution :=
    match item with
    | .simple item => checkedSimpleStatement input values item integers
    | .scalarAssign update => (update.checkedExecute integers).map fun scalars => ⟨values, [], scalars⟩
    | .arrayAssign update => (update.checkedExecute integers).map fun scalars => ⟨values, [], scalars⟩
    | .reject => some ⟨values, [.reject], integers⟩
    | .choice condition yes no =>
        (condition.checkedEvaluate values input inputValid integers).bind fun outcome =>
          if outcome then checkedStatements input inputValid values yes integers
          else checkedStatements input inputValid values no integers
    | .forLoop index reverse lower upper body =>
        (lower.checkedEvaluate integers).bind fun a => (upper.checkedEvaluate integers).bind fun b =>
          checkedIterations (fun current scalars value =>
            (checkedStatements input inputValid current body (Integer.put scalars index value)).map
              fun result => result.restoreIndex index scalars)
            values integers (Integer.iterationValues reverse a b)
    | .arrayLoop index reverse array body =>
        checkedIterations (fun current scalars component =>
          if array.bounds.Contains component then
            (Integer.checkedValue (array.project scalars component)).bind fun value =>
              (checkedStatements input inputValid current body (Integer.put scalars index value)).map
                fun result => result.restoreIndex index scalars
          else none) values integers (Integer.iterationValues reverse array.bounds.lower array.bounds.upper)
  termination_by sizeOf item
  def checkedStatements (input : Source) (inputValid : Bool) (values : Values) (items : List Statement)
      (integers : Integer.Store := Integer.emptyStore) : Option Execution :=
    match items with
    | [] => some ⟨values, [], integers⟩
    | item :: rest => (item.checkedExecute input inputValid values integers).bind fun first =>
        (checkedStatements input inputValid first.values rest first.integers).map fun following =>
          ⟨following.values, first.effects ++ following.effects, following.integers⟩
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

theorem iterations_unchanged {step : Values → Integer.Store → Int → Execution}
    {values : Values} {integers : Integer.Store} {indices : List Int} {index : Nat}
    (unchanged : ∀ current scalars value, (step current scalars value).integers index = scalars index) :
    (executeIterations step values integers indices).integers index = integers index := by
  induction indices generalizing values integers with
  | nil => rfl
  | cons value rest ih =>
      exact (ih (values := (step values integers value).values)
        (integers := (step values integers value).integers)).trans (unchanged values integers value)

mutual
  theorem statement_unchanged {shape : Shape} {analysis : Integer.Analysis} {before after : Flow}
      {item : Statement} {input : Source} {valid : Bool} {values : Values} {integers : Integer.Store}
      {index : Nat} (checked : item.check shape analysis before = some after)
      (readonly : analysis.mutable index = false) :
      (item.execute input valid values integers).integers index = integers index := by
    cases item with
    | simple item => cases item <;> simp only [Statement.execute, executeSimpleStatement]
    | scalarAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · simpa only [Statement.execute] using
            update.unchanged (values := integers) (by assumption) readonly
        · contradiction
    | arrayAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          have both : update.check before.scalars analysis.mutable = true ∧
              update.array.fullRanges analysis.declared = true := by
            simpa only [checkArrayAssignment, Bool.and_eq_true] using good
          have accepted := both.1
          simpa only [Statement.execute] using
            update.unchanged (values := integers) accepted readonly
        · contradiction
    | reject => simp only [Statement.execute]
    | choice condition yes no =>
        simp only [Statement.check] at checked
        split at checked
        · simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, _⟩ := checked
          simp only [Statement.execute]
          split
          · exact statements_unchanged yesChecked readonly
          · exact statements_unchanged noChecked readonly
        · contradiction
    | forLoop binder reverse lower upper body =>
        simp only [Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, _, b, _, bodyAfter, bodyChecked, _⟩ := checked
        simp only [Statement.execute]
        apply iterations_unchanged
        intro current scalars value
        by_cases same : index = binder
        · subst index
          simp only [Execution.restoreIndex, Integer.restore, Integer.put, ↓reduceIte]
        · have readonlyBody : (analysis.withIndex binder (Integer.loopBounds a b)).mutable index = false := by
            simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
          have preserved := statements_unchanged (input := input) (valid := valid)
            (values := current) (integers := Integer.put scalars binder value) bodyChecked readonlyBody
          simpa only [Execution.restoreIndex, Integer.restore, Integer.put, same, ↓reduceIte] using preserved
    | arrayLoop binder reverse array body =>
        simp only [Statement.check] at checked
        split at checked
        · simp only [Option.map_eq_some_iff] at checked
          obtain ⟨bodyAfter, bodyChecked, _⟩ := checked
          simp only [Statement.execute]
          apply iterations_unchanged
          intro current scalars component
          by_cases same : index = binder
          · subst index
            simp only [Execution.restoreIndex, Integer.restore, Integer.put, ↓reduceIte]
          · have readonlyBody : (analysis.withIndex binder Integer.Interval.full).mutable index = false := by
              simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
            have preserved := statements_unchanged (input := input) (valid := valid)
              (values := current) (integers := Integer.put scalars binder (array.project scalars component))
              bodyChecked readonlyBody
            simpa only [Execution.restoreIndex, Integer.restore, Integer.put, same, ↓reduceIte] using preserved
        · contradiction
  termination_by sizeOf item

  theorem statements_unchanged {shape : Shape} {analysis : Integer.Analysis} {before after : Flow}
      {items : List Statement} {input : Source} {valid : Bool} {values : Values} {integers : Integer.Store}
      {index : Nat} (checked : checkStatements shape analysis before items = some after)
      (readonly : analysis.mutable index = false) :
      (executeStatements input valid values items integers).integers index = integers index := by
    cases items with
    | nil => simp only [executeStatements]
    | cons item rest =>
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have first := statement_unchanged (input := input) (valid := valid)
          (values := values) (integers := integers) firstChecked readonly
        have following := statements_unchanged (input := input) (valid := valid)
          (values := (item.execute input valid values integers).values)
          (integers := (item.execute input valid values integers).integers) restChecked readonly
        simpa only [executeStatements] using following.trans first
  termination_by sizeOf items
end

/-- Constant arrays retain their actual components across every admitted body,
including nested loops, branches, other-array writes and returning Reject. -/
theorem statements_constant_components {shape : Shape} {analysis : Integer.Analysis}
    {before after : Flow} {items : List Statement} {input : Source} {valid : Bool}
    {values : Values} {integers : Integer.Store} {array : Integer.ArrayDescriptor}
    (checked : checkStatements shape analysis before items = some after)
    (readonly : ∀ cell, array.ContainsCell cell → analysis.mutable cell = false)
    {component : Int} (inside : array.bounds.Contains component) :
    array.project (executeStatements input valid values items integers).integers component =
      array.project integers component :=
  statements_unchanged checked (readonly _ (array.address_within inside))

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
    {integers : Integer.Store}
    {item : Sequence.SimpleStatement} {input : Source} {values : Values} {valid rejected : Bool}
    (wellFormed : SimpleWellFormed shape item) (checked : checkSimple shape flow.path item flow.scalars = true)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : flow.Allows valid input.length rejected integers)
    (declaredState : Integer.Fits analysis.declared integers) :
    ExecutionSound shape analysis flow input valid rejected
      (executeSimpleStatement input values item integers) (checkedSimpleStatement input values item integers) := by
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
    {input : Source} {valid rejected : Bool} {values : Values} {integers : Integer.Store} {indices : List Int}
    {step : Values → Integer.Store → Int → Execution}
    {checkedStep : Values → Integer.Store → Int → Option Execution}
    (bodies : ∀ index ∈ indices, ∀ current scalars already,
      Fits shape input current → before.Allows valid input.length already → Integer.Fits ranges scalars →
      Integer.Fits analysis.declared scalars →
      ExecutionSound shape analysis ⟨after, ranges⟩ input valid already
        (step current scalars index) (checkedStep current scalars index))
    (state : Fits shape input values) (allowed : before.Allows valid input.length rejected)
    (scalarState : Integer.Fits ranges integers) (declaredState : Integer.Fits analysis.declared integers) :
    ExecutionSound shape analysis ⟨if indices = [] then before else after, ranges⟩ input valid rejected
      (executeIterations step values integers indices) (checkedIterations checkedStep values integers indices) := by
  induction indices generalizing values integers rejected with
  | nil =>
      exact ⟨state, by simp [executeIterations, EffectsValid],
        by simp [executeIterations, NoOutput],
        by simpa only [executeIterations, rejectedAfter, List.any_nil, Bool.or_false, ↓reduceIte] using allowed,
        rfl, scalarState, declaredState⟩
  | cons index rest ih =>
      have first := bodies index (by simp) values integers rejected state allowed scalarState declaredState
      have remaining : ∀ item ∈ rest, ∀ current scalars already,
          Fits shape input current → before.Allows valid input.length already → Integer.Fits ranges scalars →
          Integer.Fits analysis.declared scalars →
          ExecutionSound shape analysis ⟨after, ranges⟩ input valid already
            (step current scalars item) (checkedStep current scalars item) :=
        fun item member => bodies item (List.mem_cons_of_mem index member)
      have following := ih remaining first.state
        (allows_after_effects allowed (step values integers index).effects) first.scalars first.declared
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
  theorem statement_execution_sound {shape : Shape} {before after : Flow} {hasArguments : Bool}
      {analysis : Integer.Analysis} {integers : Integer.Store}
      {item : Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (wellFormed : item.WellFormed hasArguments shape)
      (checked : item.check shape analysis before = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers) :
      ExecutionSound shape analysis after input valid rejected
        (item.execute input valid values integers) (item.checkedExecute input valid values integers) := by
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
    | arrayAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          have both : update.check before.scalars analysis.mutable = true ∧
              update.array.fullRanges analysis.declared = true := by
            simpa only [checkArrayAssignment, Bool.and_eq_true] using good
          have accepted := both.1
          have full := (Integer.ArrayDescriptor.fullRanges_iff _ _).mp both.2
          have sound := update.check_sound accepted allowed.2
          have declared : Integer.Fits analysis.declared (update.execute integers) := by
            simpa only [Integer.ArrayAssignment.execute, sound.2.2.1, ↓reduceIte] using
              update.array.write_preserves_ranges declaredState full sound.2.2.1
                (Integer.Expr.safe_value sound.2.1)
          simp only [Statement.execute, Statement.checkedExecute]
          refine ⟨state, by simp [EffectsValid], by simp [NoOutput], ?_, ?_, sound.2.2.2.1, declared⟩
          · simpa [rejectedAfter] using allowed.1
          · simp only [sound.2.2.2.2, Option.map_some]
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
          have comparison := condition.checkedEvaluate_of_checkBounds state wellFormed.2.1 allowed bounded
          have refined := condition.refine_sound (analysis := analysis) state wellFormed.2.1 allowed
          cases outcome : condition.evaluate values input valid integers with
          | true =>
              simp only [outcome] at refined
              have selected := statements_execution_sound wellFormed.2.2.2.1 yesChecked state printable refined declaredState
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
              have selected := statements_execution_sound wellFormed.2.2.2.2 noChecked state printable refined declaredState
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
            (executeIterations (fun current scalars value =>
              (executeStatements input valid current body (Integer.put scalars index value)).restoreIndex index scalars)
              values integers indices)
            (checkedIterations (fun current scalars value =>
              (checkedStatements input valid current body (Integer.put scalars index value)).map
                fun result => result.restoreIndex index scalars) values integers indices) := by
          apply iterations_execution_sound _ state allowed.1
            (analysis.widen_fits allowed.2 declaredState) declaredState
          intro value member current scalars already currentState currentAllowed currentScalars currentDeclared
          have within := Integer.loopBounds_contains lowWithin highWithin (Integer.iterationValues_contains member)
          have bodyAllowed : (loopEntry analysis before index (Integer.loopBounds a b)).Allows
              valid input.length already (Integer.put scalars index value) := by
            refine ⟨?_, Integer.put_fits currentScalars within⟩
            simpa only [loopEntry, loopContext, Integer.Interval.contains_nonempty within, Bool.false_eq_true, ↓reduceIte]
              using currentAllowed
          have bodySound := statements_execution_sound wellFormed.2.2 bodyChecked currentState printable bodyAllowed
            (Integer.put_fits currentDeclared within)
          have restoredDeclared := Integer.restore_fits currentDeclared bodySound.declared
          have restoredCurrent : Integer.Fits widened
              (Integer.restore scalars (executeStatements input valid current body
                (Integer.put scalars index value)).integers index) := by
            apply analysis.widen_closed currentScalars restoredDeclared
            intro other readonly
            by_cases same : other = index
            · subst other
              simp only [Integer.restore, Integer.put, ↓reduceIte]
            · have readBody : (analysis.withIndex index (Integer.loopBounds a b)).mutable other = false := by
                simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
              have unchanged := statements_unchanged (input := input) (valid := valid)
                (values := current) (integers := Integer.put scalars index value) bodyChecked readBody
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
            change Integer.Fits before.scalars (executeIterations _ values integers indices).integers
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
              (executeIterations (fun current scalars component =>
                (executeStatements input valid current body
                  (Integer.put scalars index (array.project scalars component))).restoreIndex index scalars)
                values integers indices)
              (checkedIterations (fun current scalars component =>
                if array.bounds.Contains component then
                  (Integer.checkedValue (array.project scalars component)).bind fun value =>
                    (checkedStatements input valid current body (Integer.put scalars index value)).map
                      fun result => result.restoreIndex index scalars
                else none) values integers indices) := by
            apply iterations_execution_sound _ state allowed.1
              (analysis.widen_fits allowed.2 declaredState) declaredState
            intro component member current scalars already currentState currentAllowed currentScalars currentDeclared
            have inside : array.bounds.Contains component := Integer.iterationValues_contains member
            have valueWithin : Integer.Interval.full.Contains (array.project scalars component) :=
              currentDeclared _ _ (properties.2.2.2.1 component inside)
            have valueSafe : Integer.InRange (array.project scalars component) :=
              by simpa only [Integer.Interval.full_contains] using valueWithin
            have bodyAllowed : (arrayLoopEntry analysis before index).Allows
                valid input.length already (Integer.put scalars index (array.project scalars component)) :=
              ⟨currentAllowed, Integer.put_fits currentScalars valueWithin⟩
            have bodySound := statements_execution_sound wellFormed.2.2 bodyChecked currentState printable bodyAllowed
              (Integer.put_fits currentDeclared valueWithin)
            have restoredDeclared := Integer.restore_fits currentDeclared bodySound.declared
            have restoredCurrent : Integer.Fits widened
                (Integer.restore scalars (executeStatements input valid current body
                  (Integer.put scalars index (array.project scalars component))).integers index) := by
              apply analysis.widen_closed currentScalars restoredDeclared
              intro other readonly
              by_cases same : other = index
              · subst other
                simp only [Integer.restore, Integer.put, ↓reduceIte]
              · have readBody : (analysis.withIndex index Integer.Interval.full).mutable other = false := by
                  simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
                have unchanged := statements_unchanged (input := input) (valid := valid)
                  (values := current) (integers := Integer.put scalars index (array.project scalars component))
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

  theorem statements_execution_sound {shape : Shape} {before after : Flow} {hasArguments : Bool}
      {analysis : Integer.Analysis} {integers : Integer.Store}
      {items : List Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (wellFormed : StatementsWellFormed hasArguments shape items)
      (checked : checkStatements shape analysis before items = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers) :
      ExecutionSound shape analysis after input valid rejected
        (executeStatements input valid values items integers) (checkedStatements input valid values items integers) := by
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
        have first := statement_execution_sound wellFormed.1 firstChecked state printable allowed declaredState
        have following := statements_execution_sound wellFormed.2 restChecked first.state printable
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

theorem completed_invalid_rejected {shape : Shape} {before after : Flow} {hasArguments : Bool}
    {analysis : Integer.Analysis} {integers : Integer.Store}
    {items : List Statement} {input : Source} {values : Values}
    (wellFormed : StatementsWellFormed hasArguments shape items)
    (checked : checkStatements shape analysis before items = some after)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : before.Allows false input.length false integers) (finished : completed after.path = true)
    (declaredState : Integer.Fits analysis.declared integers) :
    Effect.reject ∈ (executeStatements input false values items integers).effects ∧
      NoOutput (executeStatements input false values items integers).effects := by
  have sound := statements_execution_sound wellFormed checked state printable allowed declaredState
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
    (first following : List Statement) (integers : Integer.Store := Integer.emptyStore) :
    executeStatements input valid values (first ++ following) integers =
      let before := executeStatements input valid values first integers
      let after := executeStatements input valid before.values following before.integers
      ⟨after.values, before.effects ++ after.effects, after.integers⟩ := by
  induction first generalizing values integers with
  | nil => simp [executeStatements]
  | cons item rest ih => simp [executeStatements, ih, List.append_assoc]

end Silver.Predicate
