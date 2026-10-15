module

public import Silver.PredicateStatements
public import Silver.SequenceExecution

@[expose] public section

/-! Predicate-control execution keeps the established String store and effect
trace. Reject contributes an effect and returns; later statements still execute.
The static checker separately guarantees no output on any invalid-input path. -/

namespace Silver.Predicate
open Bindings Compose PathFacts
open Sequence (Execution Effect EffectsValid)

set_option maxRecDepth 10000
set_option maxHeartbeats 500000

def executeIterations (step : Values → Int → Execution) : Values → List Int → Execution
  | values, [] => ⟨values, []⟩
  | values, index :: rest =>
      let first := step values index
      let following := executeIterations step first.values rest
      ⟨following.values, first.effects ++ following.effects⟩

def checkedIterations (step : Values → Int → Option Execution) : Values → List Int → Option Execution
  | values, [] => some ⟨values, []⟩
  | values, index :: rest => (step values index).bind fun first =>
      (checkedIterations step first.values rest).map fun following =>
        ⟨following.values, first.effects ++ following.effects⟩

mutual
  def Statement.execute (input : Source) (inputValid : Bool) (values : Values) (item : Statement)
      (integers : Integer.Store := Integer.emptyStore) : Execution :=
    match item with
    | .simple item => item.execute input values
    | .reject => ⟨values, [.reject]⟩
    | .choice condition yes no =>
        if condition.evaluate values input inputValid integers
        then executeStatements input inputValid values yes integers
        else executeStatements input inputValid values no integers
    | .forLoop index reverse lower upper body =>
        executeIterations (fun current value =>
          executeStatements input inputValid current body (Integer.put integers index value)) values
          (Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers))
  termination_by sizeOf item
  def executeStatements (input : Source) (inputValid : Bool) (values : Values) (items : List Statement)
      (integers : Integer.Store := Integer.emptyStore) : Execution :=
    match items with
    | [] => ⟨values, []⟩
    | item :: rest =>
        let first := item.execute input inputValid values integers
        let following := executeStatements input inputValid first.values rest integers
        ⟨following.values, first.effects ++ following.effects⟩
  termination_by sizeOf items
end

mutual
  def Statement.checkedExecute (input : Source) (inputValid : Bool) (values : Values) (item : Statement)
      (integers : Integer.Store := Integer.emptyStore) : Option Execution :=
    match item with
    | .simple item => item.checkedExecute input values
    | .reject => some ⟨values, [.reject]⟩
    | .choice condition yes no =>
        (condition.checkedEvaluate values input inputValid integers).bind fun outcome =>
          if outcome then checkedStatements input inputValid values yes integers
          else checkedStatements input inputValid values no integers
    | .forLoop index reverse lower upper body =>
        (lower.checkedEvaluate integers).bind fun a => (upper.checkedEvaluate integers).bind fun b =>
          checkedIterations (fun current value =>
            checkedStatements input inputValid current body (Integer.put integers index value)) values
            (Integer.iterationValues reverse a b)
  termination_by sizeOf item
  def checkedStatements (input : Source) (inputValid : Bool) (values : Values) (items : List Statement)
      (integers : Integer.Store := Integer.emptyStore) : Option Execution :=
    match items with
    | [] => some ⟨values, []⟩
    | item :: rest => (item.checkedExecute input inputValid values integers).bind fun first =>
        (checkedStatements input inputValid first.values rest integers).map fun following =>
          ⟨following.values, first.effects ++ following.effects⟩
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

structure ExecutionSound (shape : Shape) (context : Context) (input : Source)
    (valid beforeRejected : Bool) (result : Execution) (ordinary : Option Execution) : Prop where
  state : Fits shape input result.values
  effects : EffectsValid result.effects
  invalid_no_output : valid = false → NoOutput result.effects
  next : context.Allows valid input.length (rejectedAfter beforeRejected result.effects)
  agreement : ordinary = some result

theorem simple_execution_sound {shape : Shape} {context : Context}
    {item : Sequence.SimpleStatement} {input : Source} {values : Values} {valid rejected : Bool}
    (wellFormed : SimpleWellFormed shape item) (checked : checkSimple shape context item = true)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : context.Allows valid input.length rejected) :
    ExecutionSound shape context input valid rejected
      (item.execute input values) (item.checkedExecute input values) := by
  cases item with
  | null =>
      exact ⟨state, by simp [Sequence.SimpleStatement.execute, EffectsValid],
        by simp [Sequence.SimpleStatement.execute, NoOutput],
        by simpa [Sequence.SimpleStatement.execute, rejectedAfter] using allowed, rfl⟩
  | assign update =>
      have preserved := assignment_preserves_on_path wellFormed.1 state printable allowed checked
      have length := assignment_checked_length wellFormed.1 state allowed checked
      refine ⟨preserved, by simp [Sequence.SimpleStatement.execute, EffectsValid],
        by simp [Sequence.SimpleStatement.execute, NoOutput], ?_, ?_⟩
      · simpa [Sequence.SimpleStatement.execute, rejectedAfter] using allowed
      · simp [Sequence.SimpleStatement.checkedExecute, Sequence.SimpleStatement.execute,
          Expression.left_association, length, Assignment.execute]
  | output expression | put expression =>
      simp only [checkSimple, Bool.and_eq_true, Bool.not_eq_true'] at checked
      have safe := expression_safe_on_path wellFormed allowed checked.1
      have outputValid := expression_domain safe state printable (Nat.le_refl _)
      refine ⟨state, ?_, ?_, ?_, ?_⟩
      · intro effect member
        simp only [Sequence.SimpleStatement.execute, List.mem_singleton] at member
        subst effect
        exact outputValid
      · intro invalid
        have inputValid := Context.output_requires_valid_input allowed checked.2
        simp [invalid] at inputValid
      · simpa [Sequence.SimpleStatement.execute, rejectedAfter, isReject] using allowed
      · simp [Sequence.SimpleStatement.checkedExecute, Sequence.SimpleStatement.execute, Expression.left_association]

/-- Input facts are immutable and rejection is sticky across any iteration. -/
theorem allows_after_effects {context : Context} {valid : Bool} {length : Nat} {rejected : Bool}
    (allowed : context.Allows valid length rejected) (effects : List Effect) :
    context.Allows valid length (rejectedAfter rejected effects) := by
  cases valid with
  | true => exact allowed
  | false =>
      exact ⟨allowed.1, allowed.2.1, fun required => by
        simp only [rejectedAfter, allowed.2.2 required, Bool.true_or]⟩

theorem iterations_execution_sound {shape : Shape} {before after : Context}
    {input : Source} {valid rejected : Bool} {values : Values} {indices : List Int}
    {step : Values → Int → Execution} {checkedStep : Values → Int → Option Execution}
    (bodies : ∀ index ∈ indices, ∀ current already,
      Fits shape input current → before.Allows valid input.length already →
      ExecutionSound shape after input valid already (step current index) (checkedStep current index))
    (state : Fits shape input values) (allowed : before.Allows valid input.length rejected) :
    ExecutionSound shape (if indices = [] then before else after) input valid rejected
      (executeIterations step values indices) (checkedIterations checkedStep values indices) := by
  induction indices generalizing values rejected with
  | nil =>
      exact ⟨state, by simp [executeIterations, EffectsValid],
        by simp [executeIterations, NoOutput],
        by simpa only [executeIterations, rejectedAfter, List.any_nil, Bool.or_false, ↓reduceIte] using allowed, rfl⟩
  | cons index rest ih =>
      have first := bodies index (by simp) values rejected state allowed
      have remaining : ∀ item ∈ rest, ∀ current already,
          Fits shape input current → before.Allows valid input.length already →
          ExecutionSound shape after input valid already (step current item) (checkedStep current item) :=
        fun item member => bodies item (List.mem_cons_of_mem index member)
      have following := ih remaining first.state (allows_after_effects allowed (step values index).effects)
      refine ⟨following.state, ?_, ?_, ?_, ?_⟩
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
      {ranges : Integer.Ranges} {integers : Integer.Store}
      {item : Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (wellFormed : item.WellFormed hasArguments shape)
      (checked : item.check shape before ranges = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected)
      (scalarState : Integer.Fits ranges integers) :
      ExecutionSound shape after input valid rejected
        (item.execute input valid values integers) (item.checkedExecute input valid values integers) := by
    cases item with
    | simple item =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          cases checked
          simpa only [Statement.execute, Statement.checkedExecute] using
            simple_execution_sound wellFormed good state printable allowed
        · contradiction
    | reject =>
        simp only [Statement.check, Option.some.injEq] at checked
        subst after
        simp only [Statement.execute, Statement.checkedExecute]
        refine ⟨state, ?_, ?_, ?_, rfl⟩
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
          have refined := condition.refine_sound (integers := integers) state wellFormed.2.1 allowed
          cases outcome : condition.evaluate values input valid integers with
          | true =>
              simp only [outcome] at refined
              have selected := statements_execution_sound wellFormed.2.2.2.1 yesChecked state printable refined scalarState
              refine ⟨?_, ?_, ?_, ?_, ?_⟩
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.state
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.effects
              · simpa only [Statement.execute, outcome, ↓reduceIte] using selected.invalid_no_output
              · simpa only [Statement.execute, outcome, ↓reduceIte] using Context.join_left selected.next
              · simpa only [Statement.checkedExecute, comparison, Option.bind_some, Statement.execute,
                  outcome, ↓reduceIte] using selected.agreement
          | false =>
              simp only [outcome] at refined
              have selected := statements_execution_sound wellFormed.2.2.2.2 noChecked state printable refined scalarState
              refine ⟨?_, ?_, ?_, ?_, ?_⟩
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.state
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.effects
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using selected.invalid_no_output
              · simpa only [Statement.execute, outcome, Bool.false_eq_true, ↓reduceIte] using Context.join_right selected.next
              · simpa only [Statement.checkedExecute, comparison, Option.bind_some, Statement.execute,
                  outcome, Bool.false_eq_true, ↓reduceIte] using selected.agreement
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
        have iterated : ExecutionSound shape (if indices = [] then before else bodyAfter) input valid rejected
            (executeIterations (fun current value => executeStatements input valid current body
              (Integer.put integers index value)) values indices)
            (checkedIterations (fun current value => checkedStatements input valid current body
              (Integer.put integers index value)) values indices) := by
          apply iterations_execution_sound _ state allowed
          intro value member current already currentState currentAllowed
          have within := Integer.loopBounds_contains lowWithin highWithin (Integer.iterationValues_contains member)
          have bodyAllowed : (loopContext before (Integer.loopBounds a b)).Allows valid input.length already := by
            simpa only [loopContext, Integer.Interval.contains_nonempty within, Bool.false_eq_true, ↓reduceIte]
              using currentAllowed
          exact statements_execution_sound wellFormed.2.2 bodyChecked currentState printable bodyAllowed
            (Integer.put_fits scalarState within)
        simp only [Statement.execute, Statement.checkedExecute, lowerSafe, upperSafe, Option.bind_some]
        refine ⟨iterated.state, iterated.effects, iterated.invalid_no_output, ?_, iterated.agreement⟩
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
      {ranges : Integer.Ranges} {integers : Integer.Store}
      {items : List Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (wellFormed : StatementsWellFormed hasArguments shape items)
      (checked : checkStatements shape before items ranges = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected)
      (scalarState : Integer.Fits ranges integers) :
      ExecutionSound shape after input valid rejected
        (executeStatements input valid values items integers) (checkedStatements input valid values items integers) := by
    cases items with
    | nil =>
        simp only [checkStatements, Option.some.injEq] at checked
        subst after
        simp only [executeStatements, checkedStatements]
        exact ⟨state, by simp [EffectsValid],
          by simp [NoOutput],
          by simpa [rejectedAfter] using allowed, rfl⟩
    | cons item rest =>
        simp only [StatementsWellFormed] at wellFormed
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have first := statement_execution_sound wellFormed.1 firstChecked state printable allowed scalarState
        have following := statements_execution_sound wellFormed.2 restChecked first.state printable first.next scalarState
        refine ⟨?_, ?_, ?_, ?_, ?_⟩
        · simpa only [executeStatements] using following.state
        · simpa only [executeStatements] using Sequence.effects_valid_append first.effects following.effects
        · intro invalid
          simpa only [executeStatements] using noOutput_append (first.invalid_no_output invalid) (following.invalid_no_output invalid)
        · simpa only [executeStatements, rejectedAfter_append] using following.next
        · simp only [checkedStatements, first.agreement, Option.bind_some, following.agreement,
            Option.map_some, executeStatements]
  termination_by sizeOf items
end

theorem completed_invalid_rejected {shape : Shape} {before after : Context} {hasArguments : Bool}
    {ranges : Integer.Ranges} {integers : Integer.Store}
      {items : List Statement} {input : Source} {values : Values}
    (wellFormed : StatementsWellFormed hasArguments shape items)
    (checked : checkStatements shape before items ranges = some after)
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
      let after := executeStatements input valid before.values following integers
      ⟨after.values, before.effects ++ after.effects⟩ := by
  induction first generalizing values with
  | nil => simp [executeStatements]
  | cons item rest ih => simp [executeStatements, ih, List.append_assoc]

end Silver.Predicate
