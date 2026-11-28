module

public import Silver.ApplicationPackageBasicEffects
public import Silver.ApplicationPackageRecursiveScope

@[expose] public section

namespace Silver.ApplicationPackageSourceEffects.BasicMasks
open Compose Predicate Packages ApplicationPackages ApplicationPackageCalls
open ApplicationPackageFrameLayout ApplicationPackageBodies ApplicationPackageBodies.SourceSyntax

attribute [local irreducible] PackageBindings.stateUnion
attribute [local irreducible] packageCallAt

theorem inherited_assignment_masks {calls : BasicCalls} {source : Statement.Input}
    (assignment : Basic.selectedAssignment calls source)
    (selected : Basic.origin calls source = .inherited)
    (accepted : (applicationBasic calls source.text source.context source.input source.info
      source.catalog source.procedures).scan.position ≠ 0) :
    let result := applicationBasic calls source.text source.context source.input source.info
      source.catalog source.procedures
    result.reads = PackageBindings.stateUnion source.input.reads
      (calls.stateReads source.text source.context source.info
        (assignmentFirst calls source.text source.input) result.scan.position) ∧
      result.writes = markState source.input.writes
        (calls.stateTarget source.text source.context source.info source.input.scan.position) := by
  have absent : (Basic.functionCall calls source).value.after = 0 := by
    unfold Basic.origin at selected
    rw [ite_eq_left assignment] at selected
    split at selected
    · contradiction
    · omega
  have scan := Basic.basicResult_source_scan calls source
  rw [selected] at scan
  dsimp only [Basic.selectedAssignment] at assignment
  rw [(applicationBasic_accepted accepted).2.2]
  dsimp only
  rw [scan]
  unfold basicResult
  rw [ite_eq_left assignment]
  dsimp only [functionAssignment]
  dsimp only [Basic.functionCall] at absent
  rw [absent]
  simp only [ne_eq, not_true_eq_false, ite_false]
  by_cases zero : calls.stateTarget source.text source.context source.info source.input.scan.position = 0
  · simp only [zero, not_true_eq_false, ite_false, markState, ite_true]
    exact ⟨trivial, trivial⟩
  · simp only [zero, not_false_eq_true, ite_true, markState, ite_false]
    exact ⟨trivial, trivial⟩

private theorem assignment_recorded {calls : BasicCalls} {source : Statement.Input}
    {bound after : Nat} {targetCell : Cell} {reads : List Cell}
    (assignment : Basic.selectedAssignment (basicReaders calls) source)
    (selected : Basic.origin (basicReaders calls) source = .inherited)
    (accepted : (applicationBasic (basicReaders calls) source.text source.context source.input source.info
      source.catalog source.procedures).scan.position ≠ 0)
    (named : WritableNameAt source.text source.context source.input.scan.position after targetCell)
    (valid : 0 < source.text.length ∧ source.text.length ≤ maxSourceLength)
    (declarations : StateDeclarations source.text source.info.states)
    (capacity : source.info.states.length ≤ PackageBindings.maxStates)
    (space : source.info.states.length ≤ source.input.writes.length)
    (target : calls.stateTarget source.text source.context source.info source.input.scan.position =
      ApplicationPackageEffects.stateTarget ApplicationPackageEffects.modelCalls
        source.text source.context source.info source.input.scan.position)
    (recorded : ∀ cell ∈ globalCells (layout bound source.info source.context) reads,
      cell ∈ source.info.effectCells (calls.stateReads source.text source.context source.info
        (assignmentFirst (basicReaders calls) source.text source.input)
        (applicationBasic (basicReaders calls) source.text source.context source.input source.info
          source.catalog source.procedures).scan.position)) :
    EffectSummaries.Included (directEffects (layout bound source.info source.context) reads [targetCell])
      (scanEffects source.info (applicationBasic (basicReaders calls) source.text source.context source.input
        source.info source.catalog source.procedures)) := by
  have masks := inherited_assignment_masks assignment selected accepted
  constructor
  · intro cell member
    change cell ∈ source.info.effectCells _
    rw [masks.1]
    exact union_right capacity _ _ cell (recorded cell member)
  · intro cell member
    change cell ∈ source.info.effectCells _
    rw [masks.2]
    change cell ∈ source.info.effectCells (markState _ (calls.stateTarget _ _ _ _))
    rw [target]
    exact named_write named valid declarations space cell member

private theorem condition_start {text context position facts condition result initials}
    (reading : ConditionAt text context position facts condition result initials) : position ≠ 0 := by
  cases reading with
  | condition _ relation _ _ _ => cases relation <;> assumption

/-- The inherited original scalar statement adds precisely the shared reads
and target write justified by its source expression and native wrapper. -/
theorem inherited_effects {calls : BasicCalls} {source : Statement.Input}
    {item : SourceStatement} {result : ApplicationScan} {bound : Nat} {effects : Effects}
    (original : BasicStepAt source.text source.context source.input.scan item result.scan {} {})
    (returned : applicationBasic (basicReaders calls) source.text source.context source.input source.info
      source.catalog source.procedures = result)
    (selected : Basic.origin (basicReaders calls) source = .inherited)
    (inferred : inferStatementEffects (completedEnvironment source.info) (layout bound source.info source.context)
      item.lower = some effects)
    (valid : 0 < source.text.length ∧ source.text.length ≤ maxSourceLength)
    (names : Expressions.ValidNames source.text source.context.names)
    (declarations : StateDeclarations source.text source.info.states)
    (capacity : source.info.states.length ≤ PackageBindings.maxStates)
    (space : source.info.states.length ≤ source.input.writes.length)
    (scalarCapacity : source.context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : source.context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (target : calls.stateTarget source.text source.context source.info source.input.scan.position =
      ApplicationPackageEffects.stateTarget ApplicationPackageEffects.modelCalls
        source.text source.context source.info source.input.scan.position)
    (reads : calls.stateReads source.text source.context source.info
      (scalarAssignmentStart source.text source.input.scan) result.scan.position =
      ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls source.text source.context source.info
        (scalarAssignmentStart source.text source.input.scan) result.scan.position) :
    EffectSummaries.Included effects (scanEffects source.info result) := by
  have primitive := original.empty_primitive
  have accepted := returned.symm ▸ original.positive
  have present := primitive.equation.symm ▸ primitive.positive
  have raw := basic_raw_positive present
  have resultEq := primitive.equation.symm.trans (basic_after_raw present)
  cases primitive.payload with
  | null =>
      simp only [SourceStatement.lower, inferStatementEffects, Option.some.injEq] at inferred
      subst effects
      exact ⟨fun _ member => False.elim (List.not_mem_nil member),
        fun _ member => False.elim (List.not_mem_nil member)⟩
  | output | put | reject | arrayAssignment | booleanArrayAssignment | assignment =>
      simp only [SourceStatement.lower, inferStatementEffects, reduceCtorEq] at inferred
  | scalarCallAssignment _ reading | booleanCallAssignment _ reading =>
      have bounded := calleeAt_bound source.text source.context
        (scalarAssignmentStart source.text source.input.scan) {}
      have positive := reading.call.positive
      rw [reading.call.callee] at positive
      exact False.elim (positive (Nat.eq_zero_of_le_zero bounded))
  | scalarAssignment kind noCall expression =>
      simp only [SourceStatement.lower, inferStatementEffects, Option.some.injEq] at inferred
      subst effects
      simp only [basicRaw, kind, noCall, ne_eq, not_true_eq_false, ite_false, scalarAssignmentBody] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i allowed
        rw [ite_eq_right allowed] at resultEq
        have nonzero : scalarTarget source.text source.context source.input.scan.position ≠ 0 :=
          fun zero => allowed (Or.inl zero)
        have start := expression.cursorBounds
        have assignment : Basic.selectedAssignment (basicReaders calls) source :=
          ⟨Nat.ne_of_gt start.1, Or.inl nonzero⟩
        have named := assignment_name (Nat.ne_of_gt start.1) (Or.inl nonzero)
        rw [functionAssignmentTarget, ite_eq_left nonzero] at named
        change WritableNameAt _ _ _ _ (.integer _) at named
        have following : result.scan.position = fixedAfter source.text
            (readScalarInFlow source.text source.context (scalarAssignmentStart source.text source.input.scan)
              source.input.scan.facts).after ";" false := congrArg BodyScan.position resultEq
        have next : (readScalarInFlow source.text source.context
            (scalarAssignmentStart source.text source.input.scan) source.input.scan.facts).after ≤ result.scan.position := by
          rw [following]
          exact Nat.le_of_lt (Expressions.model_fixed_advances _ _ ";" false start.2.2 (by decide)
            (following ▸ original.positive))
        rw [← returned]
        apply assignment_recorded assignment selected accepted named valid declarations capacity space target
        intro cell member
        change cell ∈ source.info.effectCells (calls.stateReads _ _ _
          (scalarAssignmentStart source.text source.input.scan) _)
        rw [returned, reads]
        exact scalar_global_reads expression next declarations capacity scalarCapacity cell member
  | booleanAssignment kind noCall condition =>
      simp only [SourceStatement.lower, inferStatementEffects, Option.some.injEq] at inferred
      subst effects
      simp only [basicRaw, kind, noCall, ne_eq, not_true_eq_false, ite_false, booleanAssignmentBody] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i allowed
        rw [ite_eq_right allowed] at resultEq
        have nonzero : booleanTarget source.text source.context source.input.scan.position ≠ 0 :=
          fun zero => allowed (Or.inl zero)
        have start := condition_start condition
        have assignment : Basic.selectedAssignment (basicReaders calls) source := ⟨start, Or.inr nonzero⟩
        have absent : scalarTarget source.text source.context source.input.scan.position = 0 := by
          apply Classical.byContradiction
          intro scalar
          change ScalarExpression.lookup source.text source.context.scalarNames
            (skipAt source.text source.input.scan.position)
            (nameAfter source.text (skipAt source.text source.input.scan.position)) ≠ 0 at scalar
          rw [booleanTarget, ite_eq_left scalar] at nonzero
          exact nonzero rfl
        have named := assignment_name start (Or.inr nonzero)
        rw [functionAssignmentTarget, ite_eq_right (by omega : ¬scalarTarget source.text source.context
          source.input.scan.position ≠ 0)] at named
        change WritableNameAt _ _ _ _ (.boolean _) at named
        have following : result.scan.position = fixedAfter source.text
            (readCondition source.text source.context (scalarAssignmentStart source.text source.input.scan)
              source.input.scan.facts).after ";" false := congrArg BodyScan.position resultEq
        have startBound := fixedAfter_result_bound source.text
          (nameAfter source.text (skipAt source.text source.input.scan.position)) ":=" false (by decide)
        have endBound := condition_bound source.text source.context
          (scalarAssignmentStart source.text source.input.scan) source.input.scan.facts valid names startBound
        have next : (readCondition source.text source.context
            (scalarAssignmentStart source.text source.input.scan) source.input.scan.facts).after ≤ result.scan.position := by
          rw [following]
          exact Nat.le_of_lt (Expressions.model_fixed_advances _ _ ";" false endBound (by decide)
            (following ▸ original.positive))
        rw [← returned]
        apply assignment_recorded assignment selected accepted named valid declarations capacity space target
        intro cell member
        change cell ∈ source.info.effectCells (calls.stateReads _ _ _
          (scalarAssignmentStart source.text source.input.scan) _)
        rw [returned, reads]
        exact condition_global_reads condition start startBound next declarations capacity
          scalarCapacity booleanCapacity cell member

theorem procedure_masks {calls : BasicCalls} {source : Statement.Input}
    (selected : Basic.origin calls source = .packageProcedure)
    (accepted : (applicationBasic calls source.text source.context source.input source.info
      source.catalog source.procedures).scan.position ≠ 0) :
    scanEffects source.info (applicationBasic calls source.text source.context source.input source.info
      source.catalog source.procedures) =
      scanEffects source.info (Basic.procedureCall calls source).result := by
  have guards : ¬Basic.selectedAssignment calls source ∧
      (source.input.allowProcedureCalls && decide
        (calls.packageCallee source.text source.context source.info source.input.scan.position .procedure ≠ 0)) = true := by
    unfold Basic.origin at selected
    split at selected
    · split at selected <;> contradiction
    · rename_i absent
      split at selected
      · exact ⟨absent, by assumption⟩
      · contradiction
  dsimp only [Basic.selectedAssignment] at guards
  rw [(applicationBasic_accepted accepted).2.2]
  unfold basicResult
  rw [ite_eq_right guards.1, ite_eq_left guards.2]
  rfl

/-- Complete original Basic-source effect inclusion. Native representation and
declaration-history facts supply the whole-domain capacities; exact imported
state-reader equations remain separate from semantic coverage. -/
theorem basic_effects {calls : BasicCalls} {source : Statement.Input} {result : ApplicationScan}
    {item : Predicate.Statement} {bound : Nat} {effects : Effects}
    (original : BasicCodeAt (basicReaders calls) packageNames source result item)
    (accepted : result.scan.position ≠ 0)
    (legal : Recursive.NativeDomain source) (scope : PackageScope source)
    (space : source.info.states.length ≤ source.input.writes.length)
    (inferred : inferStatementEffects (completedEnvironment source.info) (layout bound source.info source.context)
      item = some effects)
    (target : calls.stateTarget source.text source.context source.info source.input.scan.position =
      ApplicationPackageEffects.stateTarget ApplicationPackageEffects.modelCalls
        source.text source.context source.info source.input.scan.position)
    (reads : calls.stateReads source.text source.context source.info
      (scalarAssignmentStart source.text source.input.scan) result.scan.position =
      ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls source.text source.context source.info
        (scalarAssignmentStart source.text source.input.scan) result.scan.position) :
    EffectSummaries.Included effects (scanEffects source.info result) := by
  obtain ⟨native, nativeEq, valid⟩ := legal.context
  have names : Expressions.ValidNames source.text source.context.names := nativeEq ▸ valid.1
  have booleans : source.context.booleanNames.length ≤ BooleanBindings.maxBindings := nativeEq ▸ valid.booleans.1
  have scalars := legal.base.size
  have capacity : source.info.states.length ≤ PackageBindings.maxStates := legal.typed.2.2.2.2.1
  cases original with
  | inherited selected returned reading =>
      rw [scope.functions, scope.procedures] at reading
      exact inherited_effects reading returned selected inferred legal.text names scope.declarations capacity space
        scalars booleans target reads
  | functionCall same selected returned reading =>
      rw [← returned]
      exact function_assignment_effects same reading selected (returned.symm ▸ accepted) inferred legal.typed
        scope.declared legal.text scope.declarations scalars booleans target
  | @procedureCall context call same selected returned reading =>
      have acceptedCall := Basic.procedure_call_accepted (calls := basicReaders calls) selected (returned.symm ▸ accepted)
      have called : (packageCallAt modelCalls source.text context.model source.input source.info
          source.input.scan.position .procedure).value.after ≠ 0 := by simpa only [same] using acceptedCall
      have read : inferStatementEffects (completedEnvironment source.info) (layout bound source.info context.model)
          (.procedureCall call) = some effects := by simpa only [same, packageNames, id_eq] using inferred
      have effects := SourceFrames.procedure_call_effects reading called read legal.typed legal.text scope.declarations
        (same.symm ▸ scalars) (same.symm ▸ booleans)
      rw [← returned, procedure_masks selected (returned.symm ▸ accepted)]
      simpa only [Basic.procedureCall, basicReaders, Basic.withInheritedBody,
        Basic.functionReaders, Basic.procedureReaders, same] using effects

end Silver.ApplicationPackageSourceEffects.BasicMasks
