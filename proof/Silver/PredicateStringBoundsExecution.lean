module

public import Silver.PredicateStringBoundsSources

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts

def SimpleObjectBoundsSafe (names : Compose.BindingEnvironment) (values : Values)
    (input : Source) (integers : Integer.Store) : Sequence.SimpleStatement → Prop
  | .null => True
  | .assign update => update.value.ObjectBoundsSafe names values input integers
  | .output expression | .put expression => expression.ObjectBoundsSafe names values input integers

def IterationsObjectBoundsSafe (step : Values → Integer.Store → Boolean.Store → Int → Execution)
    (safeStep : Values → Integer.Store → Boolean.Store → Int → Prop) :
    Values → Integer.Store → Boolean.Store → List Int → Prop
  | _, _, _, [] => True
  | values, integers, booleans, index :: rest =>
      safeStep values integers booleans index ∧
        IterationsObjectBoundsSafe step safeStep (step values integers booleans index).values
          (step values integers booleans index).integers (step values integers booleans index).booleans rest

mutual
  def Statement.ObjectBoundsSafe (names : Compose.BindingEnvironment) (input : Source) (valid : Bool)
      (values : Values) (item : Statement) (integers : Integer.Store) (booleans : Boolean.Store) : Prop :=
    match item with
    | .simple item => SimpleObjectBoundsSafe names values input integers item
    | .booleanAssign update | .booleanArrayAssign update =>
        update.value.ObjectBoundsSafe names values input valid integers booleans
    | .scalarAssign _ | .arrayAssign _ | .reject => True
    | .choice condition yes no =>
        condition.ObjectBoundsSafe names values input valid integers booleans ∧
          if condition.evaluate values input valid integers booleans
          then StatementsObjectBoundsSafe names input valid values yes integers booleans
          else StatementsObjectBoundsSafe names input valid values no integers booleans
    | .forLoop index reverse lower upper body =>
        IterationsObjectBoundsSafe
          (fun current scalars flags value =>
            (executeStatements input valid current body (Integer.put scalars index value) flags).restoreIndex index scalars)
          (fun current scalars flags value =>
            StatementsObjectBoundsSafe names input valid current body (Integer.put scalars index value) flags)
          values integers booleans (Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers))
    | .arrayLoop index reverse array body =>
        IterationsObjectBoundsSafe
          (fun current scalars flags component =>
            (executeStatements input valid current body
              (Integer.put scalars index (array.project scalars component)) flags).restoreIndex index scalars)
          (fun current scalars flags component =>
            StatementsObjectBoundsSafe names input valid current body
              (Integer.put scalars index (array.project scalars component)) flags)
          values integers booleans (Integer.iterationValues reverse array.bounds.lower array.bounds.upper)
  termination_by sizeOf item

  def StatementsObjectBoundsSafe (names : Compose.BindingEnvironment) (input : Source) (valid : Bool)
      (values : Values) (items : List Statement) (integers : Integer.Store) (booleans : Boolean.Store) : Prop :=
    match items with
    | [] => True
    | item :: rest => item.ObjectBoundsSafe names input valid values integers booleans ∧
        StatementsObjectBoundsSafe names input valid (item.execute input valid values integers booleans).values rest
          (item.execute input valid values integers booleans).integers
          (item.execute input valid values integers booleans).booleans
  termination_by sizeOf items
end

theorem simple_objectBoundsSafe {program : Program} {names : Compose.BindingEnvironment} {flow : Flow}
    {item : Sequence.SimpleStatement} {values : Values} {input : Source}
    {integers : Integer.Store} {valid rejected : Bool}
    (_count : names.length ≤ maxBindings) (metadata : NamesBoundsValid names)
    (origin : SimpleBoundsOrigin names item)
    (checked : checkSimple names.shape flow.path item flow.scalars = true)
    (state : Fits names.shape input values) (allowed : flow.Allows valid input.length rejected integers)
    (certificates : RawBooleanBoundsCertificates program names (simpleObligations names.shape flow.path item flow.scalars)) :
    SimpleObjectBoundsSafe names values input integers item := by
  cases item with
  | null => trivial
  | assign update =>
      have safe := assignment_checked_safe state allowed.2 allowed.1 checked
      simp only [checkSimple, checkAssignment] at checked
      split at checked
      · rename_i bound summary target known
        obtain ⟨certificate, countEq, lengthEq, _, _, endpoint⟩ := certificates flow.path summary
          (by simp [simpleObligations, target, known])
        apply StringBoundsObligation.expression_safe endpoint (Nat.le_of_eq countEq.symm)
          metadata state origin safe
        rw [lengthEq]
        exact ⟨allowed.1, _, (Expression.inferLength_sound known state allowed.2).1, Nat.le_refl _⟩
      · contradiction
  | output expression | put expression =>
      simp only [checkSimple] at checked
      split at checked
      · rename_i summary known
        simp only [Bool.and_eq_true] at checked
        obtain ⟨certificate, countEq, lengthEq, _, _, endpoint⟩ := certificates flow.path summary
          (by simp [simpleObligations, known])
        apply StringBoundsObligation.expression_safe endpoint (Nat.le_of_eq countEq.symm)
          metadata state origin (expression_safe_on_path known state allowed.2 allowed.1 checked.1)
        rw [lengthEq]
        exact ⟨allowed.1, _, (Expression.inferLength_sound known state allowed.2).1, Nat.le_refl _⟩
      · contradiction

private theorem iterations_objectBoundsSafe {shape : Shape} {ranges declared : Integer.Ranges}
    {context : Context} {input : Source} {valid rejected : Bool}
    {values : Values} {integers : Integer.Store} {booleans : Boolean.Store} {indices : List Int}
    {step : Values → Integer.Store → Boolean.Store → Int → Execution}
    {safeStep : Values → Integer.Store → Boolean.Store → Int → Prop}
    (steps : ∀ index ∈ indices, ∀ current scalars flags already,
      Fits shape input current → context.Allows valid input.length already → Integer.Fits ranges scalars →
      Integer.Fits declared scalars → safeStep current scalars flags index ∧
        Fits shape input (step current scalars flags index).values ∧
        Integer.Fits ranges (step current scalars flags index).integers ∧
        Integer.Fits declared (step current scalars flags index).integers)
    (state : Fits shape input values) (allowed : context.Allows valid input.length rejected)
    (scalarState : Integer.Fits ranges integers) (declaredState : Integer.Fits declared integers) :
    IterationsObjectBoundsSafe step safeStep values integers booleans indices := by
  induction indices generalizing values integers booleans rejected with
  | nil => trivial
  | cons index rest ih =>
      have first := steps index (by simp) values integers booleans rejected state allowed scalarState declaredState
      refine ⟨first.1, ?_⟩
      exact ih (fun item member => steps item (List.mem_cons_of_mem index member)) first.2.1
        (allows_after_effects allowed (step values integers booleans index).effects) first.2.2.1 first.2.2.2


mutual
  theorem statement_objectBoundsSafe {program : Program} {names : Compose.BindingEnvironment} {before after : Flow}
      {hasArguments : Bool} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
      {integers : Integer.Store} {booleans : Boolean.Store} {item : Statement}
      {input : Source} {values : Values} {valid rejected : Bool}
      (count : names.length ≤ maxBindings) (metadata : NamesBoundsValid names)
      (origin : item.BoundsOrigin names)
      (wellFormed : item.WellFormed hasArguments names.shape booleanAnalysis)
      (checked : item.check names.shape analysis before booleanAnalysis = some after)
      (state : Fits names.shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers)
      (certificates : RawBooleanBoundsCertificates program names (item.obligations names.shape analysis before booleanAnalysis)) :
      item.ObjectBoundsSafe names input valid values integers booleans := by
    cases item with
    | simple item =>
        simp only [Statement.obligations] at certificates
        simp only [Statement.BoundsOrigin] at origin
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          simp only [Statement.ObjectBoundsSafe]
          exact simple_objectBoundsSafe count metadata origin good state allowed certificates
        · contradiction
    | scalarAssign | arrayAssign | reject => simp only [Statement.ObjectBoundsSafe]
    | booleanAssign update =>
        simp only [Statement.obligations] at certificates
        simp only [Statement.BoundsOrigin] at origin
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          simp only [Statement.ObjectBoundsSafe]
          apply condition_objectBounds_from_raw_certificates metadata state origin wellFormed.2.2 allowed
            (Bool.and_eq_true_iff.mp good).2
          intro context summary member
          exact certificates context summary (List.mem_append_right _ member)
        · contradiction
    | booleanArrayAssign update =>
        simp only [Statement.obligations] at certificates
        simp only [Statement.BoundsOrigin] at origin
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          simp only [Statement.ObjectBoundsSafe]
          have checkedValue : update.value.checkBounds names.shape analysis before booleanAnalysis = true :=
            (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp good).2).2
          apply condition_objectBounds_from_raw_certificates metadata state origin wellFormed.2.2 allowed
            checkedValue
          intro context summary member
          exact certificates context summary (List.mem_append_right _ member)
        · contradiction
    | choice condition yes no =>
        simp only [Statement.obligations] at certificates
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.BoundsOrigin] at origin
        simp only [Statement.check] at checked
        split at checked
        · rename_i bounded
          simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, rfl⟩ := checked
          simp only [Statement.ObjectBoundsSafe]
          refine ⟨condition_objectBounds_from_raw_certificates metadata state origin.1 wellFormed.2.1 allowed bounded
            (fun context summary member => certificates context summary
              (List.mem_append_left _ (List.mem_append_left _ member))), ?_⟩
          have refined := condition.refine_sound (analysis := analysis) (booleans := booleans)
            state wellFormed.2.1 allowed
          cases outcome : condition.evaluate values input valid integers booleans with
          | true =>
              simp only [outcome] at refined
              simp only [↓reduceIte]
              exact statements_objectBoundsSafe count metadata origin.2.1 wellFormed.2.2.2.1 yesChecked
                state printable refined declaredState
                (fun context summary member => certificates context summary
                  (List.mem_append_left _ (List.mem_append_right _ member)))
          | false =>
              simp only [outcome] at refined
              simp only [Bool.false_eq_true, ↓reduceIte]
              exact statements_objectBoundsSafe count metadata origin.2.2 wellFormed.2.2.2.2 noChecked
                state printable refined declaredState
                (fun context summary member => certificates context summary (List.mem_append_right _ member))
        · contradiction
    | forLoop index reverse lower upper body =>
        simp only [Statement.obligations] at certificates
        simp only [Statement.BoundsOrigin] at origin
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, lowerFound, b, upperFound, bodyAfter, bodyChecked, rfl⟩ := checked
        have lowWithin := (Integer.Expr.infer_sound lowerFound allowed.2).1
        have highWithin := (Integer.Expr.infer_sound upperFound allowed.2).1
        simp only [Statement.ObjectBoundsSafe]
        apply iterations_objectBoundsSafe (ranges := analysis.widen before.scalars) (declared := analysis.declared)
          (context := before.path) _ state allowed.1 (analysis.widen_fits allowed.2 declaredState) declaredState
        intro value member current scalars flags already currentState currentAllowed currentScalars currentDeclared
        have within := Integer.loopBounds_contains lowWithin highWithin (Integer.iterationValues_contains member)
        have bodyAllowed : (loopEntry analysis before index (Integer.loopBounds a b)).Allows
            valid input.length already (Integer.put scalars index value) := by
          refine ⟨?_, Integer.put_fits currentScalars within⟩
          simpa only [loopEntry, loopContext, Integer.Interval.contains_nonempty within, Bool.false_eq_true, ↓reduceIte]
            using currentAllowed
        have sound := statements_execution_sound (booleans := flags) wellFormed.2.2 bodyChecked currentState
          printable bodyAllowed (Integer.put_fits currentDeclared within)
        have bodyCertificates : RawBooleanBoundsCertificates program names
            (statementsObligations names.shape (analysis.withIndex index (Integer.loopBounds a b))
              (loopEntry analysis before index (Integer.loopBounds a b)) body booleanAnalysis) := by
          intro context summary member
          apply certificates context summary
          simpa only [Statement.obligations, lowerFound, upperFound] using List.mem_append_right
            ((lower.obligations before.scalars ++ upper.obligations before.scalars).map Obligation.scalar) member
        have safe := statements_objectBoundsSafe (booleans := flags) count metadata origin wellFormed.2.2 bodyChecked currentState
          printable bodyAllowed (Integer.put_fits currentDeclared within) bodyCertificates
        have restoredDeclared := Integer.restore_fits currentDeclared sound.declared
        have restoredCurrent : Integer.Fits (analysis.widen before.scalars)
            (Integer.restore scalars (executeStatements input valid current body
              (Integer.put scalars index value) flags).integers index) := by
          apply analysis.widen_closed currentScalars restoredDeclared
          intro other readonly
          by_cases same : other = index
          · subst other
            simp only [Integer.restore, Integer.put, ↓reduceIte]
          · have readBody : (analysis.withIndex index (Integer.loopBounds a b)).mutable other = false := by
              simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
            have unchanged := statements_unchanged (input := input) (valid := valid)
              (values := current) (booleans := flags) (integers := Integer.put scalars index value) bodyChecked readBody
            simpa only [Integer.restore, Integer.put, same, ↓reduceIte] using unchanged
        exact ⟨safe, sound.state, restoredCurrent, restoredDeclared⟩
    | arrayLoop index reverse array body =>
        simp only [Statement.obligations] at certificates
        simp only [Statement.BoundsOrigin] at origin
        simp only [Statement.WellFormed] at wellFormed
        simp only [Statement.check] at checked
        split at checked
        · rename_i ready
          have properties := (arrayLoopReady_iff analysis before index array).mp (Bool.and_eq_true_iff.mp ready).1
          simp only [Option.map_eq_some_iff] at checked
          obtain ⟨bodyAfter, bodyChecked, rfl⟩ := checked
          simp only [Statement.ObjectBoundsSafe]
          apply iterations_objectBoundsSafe (ranges := analysis.widen before.scalars) (declared := analysis.declared)
            (context := before.path) _ state allowed.1 (analysis.widen_fits allowed.2 declaredState) declaredState
          intro component member current scalars flags already currentState currentAllowed currentScalars currentDeclared
          have inside : array.bounds.Contains component := Integer.iterationValues_contains member
          have valueWithin : array.componentBounds.Contains (array.project scalars component) :=
            currentDeclared _ _ (properties.2.2.2.1 component inside)
          have bodyAllowed : (arrayLoopEntry analysis before index array.componentBounds).Allows
              valid input.length already (Integer.put scalars index (array.project scalars component)) :=
            ⟨currentAllowed, Integer.put_fits currentScalars valueWithin⟩
          have sound := statements_execution_sound (booleans := flags) wellFormed.2.2 bodyChecked currentState
            printable bodyAllowed (Integer.put_fits currentDeclared valueWithin)
          have safe := statements_objectBoundsSafe (booleans := flags) count metadata origin wellFormed.2.2 bodyChecked currentState
            printable bodyAllowed (Integer.put_fits currentDeclared valueWithin)
            (fun context summary member => certificates context summary (List.mem_append_right _ member))
          have restoredDeclared := Integer.restore_fits currentDeclared sound.declared
          have restoredCurrent : Integer.Fits (analysis.widen before.scalars)
              (Integer.restore scalars (executeStatements input valid current body
                (Integer.put scalars index (array.project scalars component)) flags).integers index) := by
            apply analysis.widen_closed currentScalars restoredDeclared
            intro other readonly
            by_cases same : other = index
            · subst other
              simp only [Integer.restore, Integer.put, ↓reduceIte]
            · have readBody : (analysis.withIndex index array.componentBounds).mutable other = false := by
                simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
              have unchanged := statements_unchanged (input := input) (valid := valid)
                (values := current) (booleans := flags) (integers := Integer.put scalars index (array.project scalars component))
                bodyChecked readBody
              simpa only [Integer.restore, Integer.put, same, ↓reduceIte] using unchanged
          exact ⟨safe, sound.state, restoredCurrent, restoredDeclared⟩
        · contradiction
  termination_by sizeOf item

  theorem statements_objectBoundsSafe {program : Program} {names : Compose.BindingEnvironment} {before after : Flow}
      {hasArguments : Bool} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
      {integers : Integer.Store} {booleans : Boolean.Store} {items : List Statement}
      {input : Source} {values : Values} {valid rejected : Bool}
      (count : names.length ≤ maxBindings) (metadata : NamesBoundsValid names)
      (origin : StatementsBoundsOrigin names items)
      (wellFormed : StatementsWellFormed hasArguments names.shape items booleanAnalysis)
      (checked : checkStatements names.shape analysis before items booleanAnalysis = some after)
      (state : Fits names.shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers)
      (certificates : RawBooleanBoundsCertificates program names (statementsObligations names.shape analysis before items booleanAnalysis)) :
      StatementsObjectBoundsSafe names input valid values items integers booleans := by
    cases items with
    | nil => simp only [StatementsObjectBoundsSafe]
    | cons item rest =>
        simp only [StatementsBoundsOrigin] at origin
        simp only [StatementsWellFormed] at wellFormed
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have sound := statement_execution_sound (booleans := booleans) wellFormed.1 firstChecked state printable allowed declaredState
        simp only [StatementsObjectBoundsSafe]
        simp only [statementsObligations, firstChecked] at certificates
        have firstCertificates : RawBooleanBoundsCertificates program names
            (item.obligations names.shape analysis before booleanAnalysis) :=
          fun context summary member => certificates context summary (List.mem_append_left _ member)
        have restCertificates : RawBooleanBoundsCertificates program names
            (statementsObligations names.shape analysis middle rest booleanAnalysis) := by
          intro context summary member
          apply certificates context summary
          simpa only [statementsObligations, firstChecked] using List.mem_append_right
            (item.obligations names.shape analysis before booleanAnalysis) member
        exact ⟨statement_objectBoundsSafe count metadata origin.1 wellFormed.1 firstChecked state printable allowed declaredState firstCertificates,
          statements_objectBoundsSafe count metadata origin.2 wellFormed.2 restChecked sound.state printable
            ⟨sound.next, sound.scalars⟩ sound.declared restCertificates⟩
  termination_by sizeOf items
end

end Silver.Predicate
