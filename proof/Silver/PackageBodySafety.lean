module

public import Silver.PackageIterationSafety

@[expose] public section

/-! Safety and checked execution for every scalar package-body path. The
callee hypothesis is discharged by the completion-prefix library induction.
Neither package elaboration values nor a caller-specific state refinement
restricts the persistent-state/input product quantified by this theorem. -/
namespace Silver.Packages
open Predicate (Flow Statement)

mutual
  theorem package_statement_sound {schema : StateSchema} {environment : SharedEnvironment}
      {earlier : EffectEnvironment} {layout : FrameLayout} {analysis : Integer.Analysis}
      {before after : Flow} {booleans : Boolean.Analysis} {state : SharedState} {statement : Statement}
      (effects : environment.RespectsEffects earlier) (library : environment.Typed schema)
      (valid : schema.Valid) (context : layout.Context schema analysis)
      (binders : statementLocalBinders layout statement)
      (wellFormed : statement.WellFormed false Bindings.emptyShape booleans)
      (checked : checkPackageStatement earlier layout analysis before booleans statement = some after)
      (globalsFit : schema.Fits state.globals)
      (declared : Integer.Fits analysis.declared (state.view layout).integers)
      (allowed : before.Allows true 0 false (state.view layout).integers) :
      SharedStepSound schema layout analysis after state
        (executeSharedStatement environment layout state statement)
        (checkedSharedStatement environment layout state statement) := by
    cases statement with
    | simple item =>
        cases item with
        | null =>
            simp only [checkPackageStatement] at checked
            cases Option.some.inj checked
            simp only [executeSharedStatement, checkedSharedStatement]
            exact ⟨globalsFit, declared, allowed, rfl, fun _ _ => rfl⟩
        | assign | output | put =>
            simp only [checkPackageStatement] at checked
            contradiction
    | scalarAssign update =>
        simp only [checkPackageStatement] at checked
        split at checked
        · rename_i good
          cases Option.some.inj checked
          simpa only [executeSharedStatement, checkedSharedStatement] using
            scalar_assignment_sound valid context globalsFit declared allowed good
        · contradiction
    | booleanAssign update =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [checkPackageStatement] at checked
        split at checked
        · rename_i good
          cases Option.some.inj checked
          have readable := wellFormed.2.2
          simpa only [executeSharedStatement, checkedSharedStatement] using
            boolean_assignment_sound valid context globalsFit declared allowed readable (Bool.and_eq_true_iff.mp good).2
        · contradiction
    | callAssign update =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [checkPackageStatement] at checked
        simpa only [executeSharedStatement, checkedSharedStatement] using
          shared_function_assignment_sound effects.1 library valid context globalsFit declared wellFormed.2 allowed checked
    | procedureCall call =>
        simp only [Statement.WellFormed] at wellFormed
        simp only [checkPackageStatement] at checked
        simpa only [executeSharedStatement, checkedSharedStatement] using
          shared_procedure_call_sound effects library valid context globalsFit declared wellFormed allowed checked
    | arrayAssign | booleanArrayAssign | reject | arrayLoop =>
        simp only [checkPackageStatement] at checked
        contradiction
    | choice condition yes no =>
        simp only [checkPackageStatement] at checked
        split at checked
        · rename_i bounded
          simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, rfl⟩ := checked
          simp only [Statement.WellFormed] at wellFormed
          simp only [statementLocalBinders] at binders
          have comparison := condition.checkedEvaluate_of_checkBounds
            (booleans := (state.view layout).booleans) (Bindings.empty_fits []) wellFormed.2.1 allowed bounded
          have refined := condition.refine_sound (analysis := analysis)
            (booleans := (state.view layout).booleans) (Bindings.empty_fits []) wellFormed.2.1 allowed
          cases outcome : condition.evaluate Bindings.emptyValues [] true
              (state.view layout).integers (state.view layout).booleans with
          | true =>
              simp only [outcome] at refined
              have selected := package_statements_sound effects library valid context binders.1
                wellFormed.2.2.2.1 yesChecked globalsFit declared refined
              simp only [executeSharedStatement, checkedSharedStatement, comparison, Option.bind_some,
                outcome, ↓reduceIte]
              exact ⟨selected.globals, selected.declared, Flow.join_left selected.allowed,
                selected.agreement, selected.readonly⟩
          | false =>
              simp only [outcome] at refined
              have selected := package_statements_sound effects library valid context binders.2
                wellFormed.2.2.2.2 noChecked globalsFit declared refined
              simp only [executeSharedStatement, checkedSharedStatement, comparison, Option.bind_some,
                outcome, Bool.false_eq_true, ↓reduceIte]
              exact ⟨selected.globals, selected.declared, Flow.join_right selected.allowed,
                selected.agreement, selected.readonly⟩
        · contradiction
    | forLoop index reverse lower upper body =>
        simp only [checkPackageStatement, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, lowerFound, b, upperFound, bodyAfter, bodyChecked, rfl⟩ := checked
        simp only [Statement.WellFormed] at wellFormed
        simp only [statementLocalBinders] at binders
        obtain ⟨localIdentity, localIndex⟩ := binders.1
        have lowerSafe := Integer.Expr.inferred_execution lowerFound allowed.2
        have upperSafe := Integer.Expr.inferred_execution upperFound allowed.2
        have lowWithin := (Integer.Expr.infer_sound lowerFound allowed.2).1
        have highWithin := (Integer.Expr.infer_sound upperFound allowed.2).1
        let indices := Integer.iterationValues reverse (lower.evaluate (state.view layout).integers)
          (upper.evaluate (state.view layout).integers)
        let widened := analysis.widen before.scalars
        let step := fun (current : SharedState) (value : Int) =>
          (executeSharedStatements environment layout
            (current.write (layout.place (.integer index)) (.integer value)) body).write
              (layout.place (.integer index)) (current.read (layout.place (.integer index)))
        let checkedStep := fun (current : SharedState) (value : Int) =>
          (checkedSharedStatements environment layout
            (current.write (layout.place (.integer index)) (.integer value)) body).map fun result =>
              result.write (layout.place (.integer index)) (current.read (layout.place (.integer index)))
        have bodies : ∀ value ∈ indices, ∀ current,
            schema.Fits current.globals → Integer.Fits analysis.declared (current.view layout).integers →
            Integer.Fits widened (current.view layout).integers →
            SharedStepSound schema layout analysis ⟨bodyAfter.path, widened⟩ current
              (step current value) (checkedStep current value) := by
          intro value member current currentGlobals currentDeclared currentRanges
          have within := Integer.loopBounds_contains lowWithin highWithin (Integer.iterationValues_contains member)
          exact shared_loop_iteration context localIndex
            (fun entered goodGlobals goodDeclared goodFlow =>
              package_statements_sound effects library valid (context.withIndex localIndex (Integer.loopBounds a b))
                binders.2 wellFormed.2.2 bodyChecked goodGlobals goodDeclared goodFlow)
            currentGlobals currentDeclared currentRanges allowed.1 within
        have iterated := shared_iterations_sound bodies globalsFit declared
          (analysis.widen_fits allowed.2 declared) allowed.1
        simp only [executeSharedStatement, checkedSharedStatement, lowerSafe, upperSafe, Option.bind_some]
        change SharedStepSound schema layout analysis (Predicate.loopExit analysis before bodyAfter a b)
          state (indices.foldl step state) (checkedSharedIterations checkedStep state indices)
        refine ⟨iterated.globals, iterated.declared, ⟨?_, ?_⟩, iterated.agreement, iterated.readonly⟩
        · change (Predicate.loopAfter before.path bodyAfter.path a b).Allows true 0 false
          unfold Predicate.loopAfter
          split
          · rename_i empty
            have noIterations : indices = [] :=
              Integer.iterationValues_empty (Integer.loopBounds_empty lowWithin highWithin empty)
            simpa only [noIterations, ↓reduceIte] using iterated.allowed.1
          · split
            · rename_i definite
              have nonempty : indices ≠ [] :=
                Integer.iterationValues_nonempty (Integer.loopDefinite_nonempty lowWithin highWithin definite)
              simpa only [nonempty, ↓reduceIte] using iterated.allowed.1
            · by_cases noIterations : indices = []
              · exact PathFacts.Context.join_left (by simpa only [noIterations, ↓reduceIte] using iterated.allowed.1)
              · exact PathFacts.Context.join_right (by simpa only [noIterations, ↓reduceIte] using iterated.allowed.1)
        · change Integer.Fits (if (Integer.loopBounds a b).isEmpty then before.scalars else widened)
            ((indices.foldl step state).view layout).integers
          split
          · rename_i empty
            have noIterations : indices = [] :=
              Integer.iterationValues_empty (Integer.loopBounds_empty lowWithin highWithin empty)
            simpa only [noIterations, List.foldl_nil] using allowed.2
          · exact iterated.allowed.2
  termination_by sizeOf statement

  theorem package_statements_sound {schema : StateSchema} {environment : SharedEnvironment}
      {earlier : EffectEnvironment} {layout : FrameLayout} {analysis : Integer.Analysis}
      {before after : Flow} {booleans : Boolean.Analysis} {state : SharedState} {statements : List Statement}
      (effects : environment.RespectsEffects earlier) (library : environment.Typed schema)
      (valid : schema.Valid) (context : layout.Context schema analysis)
      (binders : StatementsLocalBinders layout statements)
      (wellFormed : Predicate.StatementsWellFormed false Bindings.emptyShape statements booleans)
      (checked : checkPackageStatements earlier layout analysis before booleans statements = some after)
      (globalsFit : schema.Fits state.globals)
      (declared : Integer.Fits analysis.declared (state.view layout).integers)
      (allowed : before.Allows true 0 false (state.view layout).integers) :
      SharedStepSound schema layout analysis after state
        (executeSharedStatements environment layout state statements)
        (checkedSharedStatements environment layout state statements) := by
    cases statements with
    | nil =>
        simp only [checkPackageStatements] at checked
        cases Option.some.inj checked
        simp only [executeSharedStatements, checkedSharedStatements]
        exact ⟨globalsFit, declared, allowed, rfl, fun _ _ => rfl⟩
    | cons statement rest =>
        simp only [checkPackageStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨next, head, tail⟩ := checked
        simp only [StatementsLocalBinders] at binders
        simp only [Predicate.StatementsWellFormed] at wellFormed
        have first := package_statement_sound effects library valid context binders.1 wellFormed.1
          head globalsFit declared allowed
        have following := package_statements_sound effects library valid context binders.2 wellFormed.2
          tail first.globals first.declared first.allowed
        simp only [executeSharedStatements, checkedSharedStatements, first.agreement, Option.bind_some]
        refine ⟨following.globals, following.declared, following.allowed, following.agreement, ?_⟩
        intro index readonly
        exact (following.readonly index readonly).trans (first.readonly index readonly)
  termination_by sizeOf statements
end

end Silver.Packages
