module

public import Silver.ApplicationIterationSafety

@[expose] public section

/-! Whole Main execution safety reuses the existing full Predicate checker,
well-formedness rules and obligations. Each dynamic call sees the current
package state; all recursive branches and both loop forms preserve its schema.
No original Main construct is removed or replaced by a source safety premise. -/
namespace Silver.Applications
open Bindings Compose Predicate PathFacts
open ScalarFunctions (Frame)

mutual
  theorem statement_execution_sound {schema : Packages.StateSchema} {environment : Environment} {globals : Frame}
      {shape : Shape} {before after : Flow} {hasArguments : Bool}
      {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
      {item : Predicate.Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (certified : environment.Valid schema) (globalsFit : schema.Fits globals)
      (wellFormed : item.WellFormed hasArguments shape booleanAnalysis)
      (checked : item.check (signatures := environment.functionSignatures) (procedures := environment.procedureSignatures)
        shape analysis before booleanAnalysis = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers) :
      ExecutionSound schema shape analysis after input valid rejected
        (executeStatement environment globals input valid values item integers booleans)
        (checkedStatement environment globals input valid values item integers booleans) := by
    cases item with
    | simple item | scalarAssign item | callAssign item | procedureCall item | arrayAssign item
    | booleanAssign item | booleanArrayAssign item =>
        simpa only [executeStatement, checkedStatement] using
          atom_execution_sound (booleans := booleans) certified globalsFit wellFormed checked
            state printable allowed declaredState
    | reject =>
        simpa only [executeStatement, checkedStatement] using
          atom_execution_sound (booleans := booleans) certified globalsFit wellFormed checked
            state printable allowed declaredState
    | choice condition yes no =>
        simp only [Predicate.Statement.WellFormed] at wellFormed
        simp only [Predicate.Statement.check] at checked
        split at checked
        · rename_i bounded
          simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, rfl⟩ := checked
          have comparison := condition.checkedEvaluate_of_checkBounds (booleans := booleans) state wellFormed.2.1 allowed bounded
          have refined := condition.refine_sound (analysis := analysis) (booleans := booleans) state wellFormed.2.1 allowed
          cases outcome : condition.evaluate values input valid integers booleans with
          | true =>
              simp only [outcome] at refined
              have selected := statements_execution_sound certified globalsFit (booleans := booleans) wellFormed.2.2.2.1 yesChecked state printable refined declaredState
              refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
              · simpa only [executeStatement, outcome, ↓reduceIte] using selected.state
              · simpa only [executeStatement, outcome, ↓reduceIte] using selected.effects
              · simpa only [executeStatement, outcome, ↓reduceIte] using selected.invalid_no_output
              · simpa only [executeStatement, outcome, ↓reduceIte, Flow.join] using Context.join_left selected.next
              · simpa only [checkedStatement, comparison, Option.bind_some, executeStatement,
                  outcome, ↓reduceIte] using selected.agreement
              · simpa only [executeStatement, outcome, ↓reduceIte, Flow.join] using Integer.Ranges.join_left selected.scalars
              · simpa only [executeStatement, outcome, ↓reduceIte] using selected.declared
              · simpa only [executeStatement, outcome, ↓reduceIte] using selected.globals
          | false =>
              simp only [outcome] at refined
              have selected := statements_execution_sound certified globalsFit (booleans := booleans) wellFormed.2.2.2.2 noChecked state printable refined declaredState
              refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
              · simpa only [executeStatement, outcome, Bool.false_eq_true, ↓reduceIte] using selected.state
              · simpa only [executeStatement, outcome, Bool.false_eq_true, ↓reduceIte] using selected.effects
              · simpa only [executeStatement, outcome, Bool.false_eq_true, ↓reduceIte] using selected.invalid_no_output
              · simpa only [executeStatement, outcome, Bool.false_eq_true, ↓reduceIte, Flow.join] using Context.join_right selected.next
              · simpa only [checkedStatement, comparison, Option.bind_some, executeStatement,
                  outcome, Bool.false_eq_true, ↓reduceIte] using selected.agreement
              · simpa only [executeStatement, outcome, Bool.false_eq_true, ↓reduceIte, Flow.join] using Integer.Ranges.join_right selected.scalars
              · simpa only [executeStatement, outcome, Bool.false_eq_true, ↓reduceIte] using selected.declared
              · simpa only [executeStatement, outcome, Bool.false_eq_true, ↓reduceIte] using selected.globals
        · contradiction
    | forLoop index reverse lower upper body =>
        simp only [Predicate.Statement.WellFormed] at wellFormed
        simp only [Predicate.Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, lowerFound, b, upperFound, bodyAfter, bodyChecked, rfl⟩ := checked
        have lowerSafe := Integer.Expr.inferred_execution lowerFound allowed.2
        have upperSafe := Integer.Expr.inferred_execution upperFound allowed.2
        let indices := Integer.iterationValues reverse (lower.evaluate integers) (upper.evaluate integers)
        let widened := analysis.widen before.scalars
        have lowWithin := (Integer.Expr.infer_sound lowerFound allowed.2).1
        have highWithin := (Integer.Expr.infer_sound upperFound allowed.2).1
        have iterated : ExecutionSound schema shape analysis
            ⟨if indices = [] then before.path else bodyAfter.path, widened⟩ input valid rejected
            (executeIterations (fun shared current scalars flags value =>
              (executeStatements environment shared input valid current body (Integer.put scalars index value) flags).restoreIndex index scalars)
              globals values integers booleans indices)
            (checkedIterations (fun shared current scalars flags value =>
              (checkedStatements environment shared input valid current body (Integer.put scalars index value) flags).map
                fun result => result.restoreIndex index scalars) globals values integers booleans indices) := by
          apply iterations_execution_sound _ globalsFit state allowed.1
            (analysis.widen_fits allowed.2 declaredState) declaredState
          intro value member shared current scalars flags already sharedFit currentState currentAllowed currentScalars currentDeclared
          have within := Integer.loopBounds_contains lowWithin highWithin (Integer.iterationValues_contains member)
          have bodyAllowed : (loopEntry analysis before index (Integer.loopBounds a b)).Allows
              valid input.length already (Integer.put scalars index value) := by
            refine ⟨?_, Integer.put_fits currentScalars within⟩
            simpa only [loopEntry, loopContext, Integer.Interval.contains_nonempty within, Bool.false_eq_true, ↓reduceIte]
              using currentAllowed
          have bodySound := statements_execution_sound certified sharedFit (booleans := flags) wellFormed.2.2 bodyChecked currentState printable bodyAllowed
            (Integer.put_fits currentDeclared within)
          have restoredDeclared := Integer.restore_fits currentDeclared bodySound.declared
          have restoredCurrent : Integer.Fits widened
              (Integer.restore scalars (executeStatements environment shared input valid current body
                (Integer.put scalars index value) flags).integers index) := by
            apply analysis.widen_closed currentScalars restoredDeclared
            intro other readonly
            by_cases same : other = index
            · subst other
              simp only [Integer.restore, Integer.put, ↓reduceIte]
            · have readBody : (analysis.withIndex index (Integer.loopBounds a b)).mutable other = false := by
                simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
              have unchanged := statements_unchanged (environment := environment) (globals := shared) (input := input) (valid := valid)
                (values := current) (booleans := flags) (integers := Integer.put scalars index value) bodyChecked readBody
              simpa only [Integer.restore, Integer.put, same, ↓reduceIte] using unchanged
          exact ⟨bodySound.state, bodySound.effects, bodySound.invalid_no_output, bodySound.next,
            by rw [bodySound.agreement]; rfl, restoredCurrent, restoredDeclared, bodySound.globals⟩
        simp only [executeStatement, checkedStatement, lowerSafe, upperSafe, Option.bind_some]
        refine ⟨iterated.state, iterated.effects, iterated.invalid_no_output, ?_, iterated.agreement, ?_, iterated.declared, iterated.globals⟩
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
            change Integer.Fits before.scalars (executeIterations _ globals values integers booleans indices).integers
            simpa only [noIterations, executeIterations] using allowed.2
          · exact iterated.scalars
    | arrayLoop index reverse array body =>
        simp only [Predicate.Statement.WellFormed] at wellFormed
        simp only [Predicate.Statement.check] at checked
        split at checked
        · rename_i ready
          have properties := (arrayLoopReady_iff analysis before index array).mp (Bool.and_eq_true_iff.mp ready).1
          simp only [Option.map_eq_some_iff] at checked
          obtain ⟨bodyAfter, bodyChecked, rfl⟩ := checked
          let indices := Integer.iterationValues reverse array.bounds.lower array.bounds.upper
          let widened := analysis.widen before.scalars
          have nonempty : indices ≠ [] := Integer.iterationValues_nonempty properties.1.2
          have iterated : ExecutionSound schema shape analysis
              ⟨if indices = [] then before.path else bodyAfter.path, widened⟩ input valid rejected
              (executeIterations (fun shared current scalars flags component =>
                (executeStatements environment shared input valid current body
                  (Integer.put scalars index (array.project scalars component)) flags).restoreIndex index scalars)
                globals values integers booleans indices)
              (checkedIterations (fun shared current scalars flags component =>
                if array.bounds.Contains component then
                  (Integer.checkedValue (array.project scalars component)).bind fun value =>
                    (checkedStatements environment shared input valid current body (Integer.put scalars index value) flags).map
                      fun result => result.restoreIndex index scalars
                else none) globals values integers booleans indices) := by
            apply iterations_execution_sound _ globalsFit state allowed.1
              (analysis.widen_fits allowed.2 declaredState) declaredState
            intro component member shared current scalars flags already sharedFit currentState currentAllowed currentScalars currentDeclared
            have inside : array.bounds.Contains component := Integer.iterationValues_contains member
            have valueWithin : array.componentBounds.Contains (array.project scalars component) :=
              currentDeclared _ _ (properties.2.2.2.1 component inside)
            have valueSafe : Integer.InRange (array.project scalars component) :=
              Integer.Interval.bounded_contains properties.2.2.2.2.2.1 valueWithin
            have bodyAllowed : (arrayLoopEntry analysis before index array.componentBounds).Allows
                valid input.length already (Integer.put scalars index (array.project scalars component)) :=
              ⟨currentAllowed, Integer.put_fits currentScalars valueWithin⟩
            have bodySound := statements_execution_sound certified sharedFit (booleans := flags) wellFormed.2.2 bodyChecked currentState printable bodyAllowed
              (Integer.put_fits currentDeclared valueWithin)
            have restoredDeclared := Integer.restore_fits currentDeclared bodySound.declared
            have restoredCurrent : Integer.Fits widened
                (Integer.restore scalars (executeStatements environment shared input valid current body
                  (Integer.put scalars index (array.project scalars component)) flags).integers index) := by
              apply analysis.widen_closed currentScalars restoredDeclared
              intro other readonly
              by_cases same : other = index
              · subst other
                simp only [Integer.restore, Integer.put, ↓reduceIte]
              · have readBody : (analysis.withIndex index array.componentBounds).mutable other = false := by
                  simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
                have unchanged := statements_unchanged (environment := environment) (globals := shared) (input := input) (valid := valid)
                  (values := current) (booleans := flags) (integers := Integer.put scalars index (array.project scalars component))
                  bodyChecked readBody
                simpa only [Integer.restore, Integer.put, same, ↓reduceIte] using unchanged
            refine ⟨bodySound.state, bodySound.effects, bodySound.invalid_no_output, bodySound.next,
              ?_, restoredCurrent, restoredDeclared, bodySound.globals⟩
            simp only [inside, ↓reduceIte, Integer.checkedValue, valueSafe,
              Option.bind_some, bodySound.agreement, Option.map_some]
          simpa only [executeStatement, checkedStatement, arrayLoopExit, nonempty, ↓reduceIte]
            using iterated
        · contradiction
  termination_by sizeOf item

  theorem statements_execution_sound {schema : Packages.StateSchema} {environment : Environment} {globals : Frame}
      {shape : Shape} {before after : Flow} {hasArguments : Bool}
      {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
      {items : List Predicate.Statement} {input : Source} {values : Values} {valid rejected : Bool}
      (certified : environment.Valid schema) (globalsFit : schema.Fits globals)
      (wellFormed : StatementsWellFormed hasArguments shape items booleanAnalysis)
      (checked : Predicate.checkStatements (signatures := environment.functionSignatures)
        (procedures := environment.procedureSignatures) shape analysis before items booleanAnalysis = some after)
      (state : Fits shape input values) (printable : Bindings.Printable input)
      (allowed : before.Allows valid input.length rejected integers)
      (declaredState : Integer.Fits analysis.declared integers) :
      ExecutionSound schema shape analysis after input valid rejected
        (executeStatements environment globals input valid values items integers booleans)
        (checkedStatements environment globals input valid values items integers booleans) := by
    cases items with
    | nil =>
        simp only [Predicate.checkStatements, Option.some.injEq] at checked
        subst after
        simp only [executeStatements, checkedStatements]
        exact ⟨state, by simp [Sequence.EffectsValid], by simp [NoOutput],
          by simpa [rejectedAfter] using allowed.1, rfl, allowed.2, declaredState, globalsFit⟩
    | cons item rest =>
        simp only [StatementsWellFormed] at wellFormed
        simp only [Predicate.checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have first := statement_execution_sound certified globalsFit (booleans := booleans)
          wellFormed.1 firstChecked state printable allowed declaredState
        have following := statements_execution_sound certified first.globals
          (booleans := (executeStatement environment globals input valid values item integers booleans).booleans)
          wellFormed.2 restChecked first.state printable ⟨first.next, first.scalars⟩ first.declared
        refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
        · simpa only [executeStatements] using following.state
        · simpa only [executeStatements] using Sequence.effects_valid_append first.effects following.effects
        · intro invalid
          simpa only [executeStatements] using noOutput_append (first.invalid_no_output invalid) (following.invalid_no_output invalid)
        · simpa only [executeStatements, rejectedAfter_append] using following.next
        · simp only [checkedStatements, first.agreement, Option.bind_some, following.agreement,
            Option.map_some, executeStatements]
        · simpa only [executeStatements] using following.scalars
        · simpa only [executeStatements] using following.declared
        · simpa only [executeStatements] using following.globals
  termination_by sizeOf items
end

end Silver.Applications
