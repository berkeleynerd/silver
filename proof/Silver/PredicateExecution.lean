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
    | .reject => ⟨values, [.reject], integers⟩
    | .choice condition yes no =>
        if condition.evaluate values input inputValid integers
        then executeStatements input inputValid values yes integers
        else executeStatements input inputValid values no integers
    | .forLoop index reverse lower upper body =>
        executeIterations (fun current scalars value =>
          (executeStatements input inputValid current body (Integer.put scalars index value)).restoreIndex index scalars)
          values integers (Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers))
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

structure ExecutionSound (shape : Shape) (ranges : Integer.Ranges) (context : Context) (input : Source)
    (valid beforeRejected : Bool) (result : Execution) (ordinary : Option Execution) : Prop where
  state : Fits shape input result.values
  effects : EffectsValid result.effects
  invalid_no_output : valid = false → NoOutput result.effects
  next : context.Allows valid input.length (rejectedAfter beforeRejected result.effects)
  agreement : ordinary = some result
  scalars : Integer.Fits ranges result.integers

theorem simple_execution_sound {shape : Shape} {context : Context}
    {ranges : Integer.Ranges} {integers : Integer.Store}
    {item : Sequence.SimpleStatement} {input : Source} {values : Values} {valid rejected : Bool}
    (wellFormed : SimpleWellFormed shape item) (checked : checkSimple shape context item ranges = true)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : context.Allows valid input.length rejected) (scalarState : Integer.Fits ranges integers) :
    ExecutionSound shape ranges context input valid rejected
      (executeSimpleStatement input values item integers) (checkedSimpleStatement input values item integers) := by
  cases item with
  | null =>
      exact ⟨state, by simp [executeSimpleStatement, EffectsValid],
        by simp [executeSimpleStatement, NoOutput],
        by simpa [executeSimpleStatement, rejectedAfter] using allowed, rfl, scalarState⟩
  | assign update =>
      have preserved := assignment_preserves_on_path wellFormed.1 state scalarState printable allowed checked
      have length := assignment_checked_length state scalarState allowed checked
      have safe := assignment_checked_safe state scalarState allowed checked
      refine ⟨preserved, by simp [executeSimpleStatement, EffectsValid],
        by simp [executeSimpleStatement, NoOutput], ?_, ?_, scalarState⟩
      · simpa [executeSimpleStatement, rejectedAfter] using allowed
      · simp [checkedSimpleStatement, executeSimpleStatement,
          Expression.checkedEvaluate_agrees safe, length, executeAssignment]
  | output expression | put expression =>
      simp only [checkSimple] at checked
      split at checked
      · rename_i summary known
        simp only [Bool.and_eq_true, Bool.not_eq_true'] at checked
        have safe := expression_safe_on_path known state scalarState allowed checked.1
        have outputValid : (expression.evaluate values input integers).length ≤ maxSourceLength ∧
            Bindings.Printable (expression.evaluate values input integers) :=
          ⟨safe.2, Expression.inferLength_printable known state printable wellFormed.2.1⟩
        refine ⟨state, ?_, ?_, ?_, ?_, scalarState⟩
        · intro effect member
          simp only [executeSimpleStatement, List.mem_singleton] at member
          subst effect
          exact outputValid
        · intro invalid
          have inputValid := Context.output_requires_valid_input allowed checked.2
          simp [invalid] at inputValid
        · simpa [executeSimpleStatement, rejectedAfter, isReject] using allowed
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

theorem ExecutionSound.restoreIndex {shape : Shape} {ranges : Integer.Ranges} {context : Context}
    {input : Source} {valid rejected : Bool} {result : Execution} {ordinary : Option Execution}
    {index : Nat} {bounds : Integer.Interval} {before : Integer.Store}
    (sound : ExecutionSound shape (Integer.put ranges index (some bounds)) context input valid rejected result ordinary)
    (initial : Integer.Fits ranges before) :
    ExecutionSound shape ranges context input valid rejected (result.restoreIndex index before)
      (ordinary.map fun next => next.restoreIndex index before) := by
  exact ⟨sound.state, sound.effects, sound.invalid_no_output, sound.next,
    by rw [sound.agreement]; rfl, Integer.restore_fits initial sound.scalars⟩

theorem iterations_execution_sound {shape : Shape} {ranges : Integer.Ranges} {before after : Context}
    {input : Source} {valid rejected : Bool} {values : Values} {integers : Integer.Store} {indices : List Int}
    {step : Values → Integer.Store → Int → Execution}
    {checkedStep : Values → Integer.Store → Int → Option Execution}
    (bodies : ∀ index ∈ indices, ∀ current scalars already,
      Fits shape input current → before.Allows valid input.length already → Integer.Fits ranges scalars →
      ExecutionSound shape ranges after input valid already (step current scalars index) (checkedStep current scalars index))
    (state : Fits shape input values) (allowed : before.Allows valid input.length rejected)
    (scalarState : Integer.Fits ranges integers) :
    ExecutionSound shape ranges (if indices = [] then before else after) input valid rejected
      (executeIterations step values integers indices) (checkedIterations checkedStep values integers indices) := by
  induction indices generalizing values integers rejected with
  | nil =>
      exact ⟨state, by simp [executeIterations, EffectsValid],
        by simp [executeIterations, NoOutput],
        by simpa only [executeIterations, rejectedAfter, List.any_nil, Bool.or_false, ↓reduceIte] using allowed,
        rfl, scalarState⟩
  | cons index rest ih =>
      have first := bodies index (by simp) values integers rejected state allowed scalarState
      have remaining : ∀ item ∈ rest, ∀ current scalars already,
          Fits shape input current → before.Allows valid input.length already → Integer.Fits ranges scalars →
          ExecutionSound shape ranges after input valid already (step current scalars item) (checkedStep current scalars item) :=
        fun item member => bodies item (List.mem_cons_of_mem index member)
      have following := ih remaining first.state
        (allows_after_effects allowed (step values integers index).effects) first.scalars
      refine ⟨following.state, ?_, ?_, ?_, ?_, following.scalars⟩
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
  theorem statement_execution_sound {shape : Shape} {before after : Context} {hasArguments : Bool}
      {ranges : Integer.Ranges} {integers : Integer.Store} {mutable : Integer.Mutability}
      {item : Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (wellFormed : item.WellFormed hasArguments shape)
      (checked : item.check shape before ranges mutable = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected)
      (scalarState : Integer.Fits ranges integers) :
      ExecutionSound shape ranges after input valid rejected
        (item.execute input valid values integers) (item.checkedExecute input valid values integers) := by
    cases item with
    | simple item =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          simpa only [Statement.execute, Statement.checkedExecute] using
            simple_execution_sound wellFormed good state printable allowed scalarState
        · contradiction
    | scalarAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          have sound := update.check_sound good scalarState
          simp only [Statement.execute, Statement.checkedExecute]
          refine ⟨state, by simp [EffectsValid], by simp [NoOutput], ?_, ?_, sound.2.1⟩
          · simpa [rejectedAfter] using allowed
          · simp only [sound.2.2, Option.map_some]
        · contradiction
    | reject =>
        simp only [Statement.check, Option.some.injEq] at checked
        subst after
        simp only [Statement.execute, Statement.checkedExecute]
        refine ⟨state, ?_, ?_, ?_, rfl, scalarState⟩
        · simp [EffectsValid, Sequence.Effect.Valid]
        · simp [NoOutput]
        · simpa [rejectedAfter, isReject] using Context.reject_sound allowed
    | choice condition yes no =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i bounded
          simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, rfl⟩ := checked
          have comparison := condition.checkedEvaluate_of_checkBounds state wellFormed.2.1 allowed bounded scalarState
          have refined := condition.refine_sound (integers := integers) state wellFormed.2.1 allowed scalarState
          cases outcome : condition.evaluate values input valid integers with
          | true =>
              simp only [outcome] at refined
              have selected := statements_execution_sound wellFormed.2.2.2.1 yesChecked state printable refined scalarState
              refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.state
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.effects
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.invalid_no_output
              · simpa only [Statement.execute, outcome, ↓reduceIte] using Context.join_left selected.next
              · simpa only [Statement.checkedExecute, comparison, Option.bind_some, Statement.execute,
                  outcome, ↓reduceIte] using selected.agreement
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.scalars
          | false =>
              simp only [outcome] at refined
              have selected := statements_execution_sound wellFormed.2.2.2.2 noChecked state printable refined scalarState
              refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.state
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.effects
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.invalid_no_output
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using Context.join_right selected.next
              · simpa only [Statement.checkedExecute, comparison, Option.bind_some, Statement.execute,
                  outcome, Bool.false_eq_true, ↓reduceIte] using selected.agreement
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.scalars
        · contradiction
    | forLoop index reverse lower upper body =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, lowerFound, b, upperFound, bodyAfter, bodyChecked, rfl⟩ := checked
        have lowerSafe := Integer.Expr.inferred_execution lowerFound scalarState
        have upperSafe := Integer.Expr.inferred_execution upperFound scalarState
        let indices := Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers)
        have lowWithin := (Integer.Expr.infer_sound lowerFound scalarState).1
        have highWithin := (Integer.Expr.infer_sound upperFound scalarState).1
        have iterated : ExecutionSound shape ranges (if indices = [] then before else bodyAfter) input valid rejected
            (executeIterations (fun current scalars value =>
              (executeStatements input valid current body (Integer.put scalars index value)).restoreIndex index scalars)
              values integers indices)
            (checkedIterations (fun current scalars value =>
              (checkedStatements input valid current body (Integer.put scalars index value)).map
                fun result => result.restoreIndex index scalars) values integers indices) := by
          apply iterations_execution_sound _ state allowed scalarState
          intro value member current scalars already currentState currentAllowed currentScalars
          have within := Integer.loopBounds_contains lowWithin highWithin (Integer.iterationValues_contains member)
          have bodyAllowed : (loopContext before (Integer.loopBounds a b)).Allows valid input.length already := by
            simpa only [loopContext, Integer.Interval.contains_nonempty within, Bool.false_eq_true, ↓reduceIte]
              using currentAllowed
          have bodySound := statements_execution_sound wellFormed.2.2 bodyChecked currentState printable bodyAllowed
            (Integer.put_fits currentScalars within)
          exact bodySound.restoreIndex currentScalars
        simp only [Statement.execute, Statement.checkedExecute, lowerSafe, upperSafe, Option.bind_some]
        refine ⟨iterated.state, iterated.effects, iterated.invalid_no_output, ?_, iterated.agreement, iterated.scalars⟩
        change (loopAfter before bodyAfter a b).Allows valid input.length _
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
  termination_by sizeOf item

  theorem statements_execution_sound {shape : Shape} {before after : Context} {hasArguments : Bool}
      {ranges : Integer.Ranges} {integers : Integer.Store} {mutable : Integer.Mutability}
      {items : List Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (wellFormed : StatementsWellFormed hasArguments shape items)
      (checked : checkStatements shape before items ranges mutable = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected)
      (scalarState : Integer.Fits ranges integers) :
      ExecutionSound shape ranges after input valid rejected
        (executeStatements input valid values items integers) (checkedStatements input valid values items integers) := by
    cases items with
    | nil =>
        simp only [checkStatements, Option.some.injEq] at checked
        subst after
        simp only [executeStatements, checkedStatements]
        exact ⟨state, by simp [EffectsValid],
          by simp [NoOutput],
          by simpa [rejectedAfter] using allowed, rfl, scalarState⟩
    | cons item rest =>
        simp only [StatementsWellFormed] at wellFormed
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have first := statement_execution_sound wellFormed.1 firstChecked state printable allowed scalarState
        have following := statements_execution_sound wellFormed.2 restChecked first.state printable first.next first.scalars
        refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
        · simpa only [executeStatements] using following.state
        · simpa only [executeStatements] using Sequence.effects_valid_append first.effects following.effects
        · intro invalid
          simpa only [executeStatements] using noOutput_append (first.invalid_no_output invalid) (following.invalid_no_output invalid)
        · simpa only [executeStatements, rejectedAfter_append] using following.next
        · simp only [checkedStatements, first.agreement, Option.bind_some, following.agreement,
            Option.map_some, executeStatements]
        · simpa only [executeStatements] using following.scalars
  termination_by sizeOf items
end

theorem completed_invalid_rejected {shape : Shape} {before after : Context} {hasArguments : Bool}
    {ranges : Integer.Ranges} {integers : Integer.Store} {mutable : Integer.Mutability}
      {items : List Statement} {input : Source} {values : Values}
    (wellFormed : StatementsWellFormed hasArguments shape items)
    (checked : checkStatements shape before items ranges mutable = some after)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : before.Allows false input.length false) (finished : completed after = true)
    (scalarState : Integer.Fits ranges integers) :
    Effect.reject ∈ (executeStatements input false values items integers).effects ∧
      NoOutput (executeStatements input false values items integers).effects := by
  have sound := statements_execution_sound wellFormed checked state printable allowed scalarState
  have reachable := sound.next.2.1
  have guaranteed : after.invalidRejected = true := by
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
