module

public import Silver.ApplicationPackageProcedureEffects

@[expose] public section

/-! Original Basic statements retain their complete direct and earlier-callee
effects in the native application scan. -/
namespace Silver.ApplicationPackageSourceEffects
open Compose Predicate Packages ApplicationPackages ApplicationPackageCalls
open ApplicationPackageFrameLayout ApplicationPackageBodies ApplicationPackageBodies.SourceSyntax

namespace SourceFrames

theorem function_call_effects {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : PackageBindings.Metadata} {position bound : Nat}
    {call : ScalarFunctions.Call}
    (original : Basic.FunctionCallAt text context input info position call)
    (accepted : (packageCallAt modelCalls text context.model input info position .function).value.after ≠ 0)
    (typed : info.Typed) (declared : ApplicationPackageDeclarations.DeclaredFormalModes info)
    (declarations : StateDeclarations text info.states)
    (scalarCapacity : context.model.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : context.model.booleanNames.length ≤ BooleanBindings.maxBindings) :
    EffectSummaries.Included
      ((directEffects (layout bound info context.model) (actualsReads call.actuals) []).merge
        ((info.routineAt call.callee).effects info))
      (scanEffects info (packageCallAt modelCalls text context.model input info position .function).result) := by
  have dimensions := accepted_call_dimensions typed accepted
  rw [← original.1] at dimensions
  obtain ⟨callee, item, frame, checked, selected, present, itemEq, read, _, _, masks⟩ := accepted_aliases accepted
  have same : callee = call.callee := selected.trans original.1.symm
  rw [same] at present
  rw [itemEq, same] at read masks
  obtain ⟨positive, completed, kind, _⟩ := callee_completed original.1.symm present rfl
  have available := (callee_trace original.1.symm present).1
  have member : info.routineAt call.callee ∈ info.routines := by
    have inside : call.callee - 1 < info.routines.length := by omega
    simp only [PackageBindings.Metadata.routineAt, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem inside, Option.getD_some]
    exact List.getElem_mem inside
  have capacity : info.states.length ≤ PackageBindings.maxStates := typed.2.2.2.2.1
  have direct := function_call_reads original read declared member kind dimensions.2.1
    declarations capacity scalarCapacity booleanCapacity (bound := bound)
  have implicit := callee_writes_included read dimensions.2.1 dimensions.2.2
  have reads := congrArg Prod.fst masks
  have writes := congrArg Prod.snd masks
  dsimp only [footprint] at reads writes
  apply EffectSummaries.Included.merge_bound
  · constructor
    · intro cell used
      change cell ∈ info.effectCells _
      rw [reads]
      exact union_left capacity _ _ cell (direct cell used)
    · intro cell used
      simp only [directEffects, globalCells, List.filterMap_nil, List.not_mem_nil] at used
  · constructor
    · intro cell used
      change cell ∈ info.effectCells _
      rw [reads]
      exact union_right capacity _ _ cell used
    · intro cell used
      change cell ∈ info.effectCells _
      rw [writes]
      exact union_right capacity _ _ cell (implicit cell used)

end SourceFrames

namespace BasicMasks

attribute [local irreducible] PackageBindings.stateUnion
attribute [local irreducible] packageCallAt

theorem function_masks {calls : BasicCalls} {source : Statement.Input}
    (selected : Basic.origin calls source = .packageFunction)
    (accepted : (applicationBasic calls source.text source.context source.input source.info
      source.catalog source.procedures).scan.position ≠ 0) :
    let called := Basic.functionCall calls source
    let result := applicationBasic calls source.text source.context source.input source.info
      source.catalog source.procedures
    result.reads = called.result.reads ∧
      result.writes = markState called.result.writes
        (calls.stateTarget source.text source.context source.info source.input.scan.position) := by
  have guards := Basic.function_origin selected
  dsimp only [Basic.selectedAssignment, Basic.functionCall] at guards
  rw [(applicationBasic_accepted accepted).2.2]
  dsimp only
  unfold basicResult
  rw [ite_eq_left guards.1]
  dsimp only [functionAssignment]
  rw [ite_eq_left guards.2]
  by_cases zero : calls.stateTarget source.text source.context source.info source.input.scan.position = 0
  · simp only [zero, ne_eq, not_true_eq_false, ite_false, markState, ite_true]
    exact ⟨rfl, rfl⟩
  · simp only [zero, ne_eq, not_false_eq_true, ite_true, markState, ite_false]
    exact ⟨rfl, rfl⟩

theorem call_write_length {text : Source} {context : ParseContext} {input : ApplicationScan}
    {info : PackageBindings.Metadata} {position : Nat} {kind : PackageBindings.RoutineKind}
    (accepted : (packageCallAt modelCalls text context input info position kind).value.after ≠ 0) :
    (packageCallAt modelCalls text context input info position kind).result.writes.length =
      PackageBindings.maxStates := by
  obtain ⟨_, _, _, _, _, _, _, _, _, _, masks⟩ := accepted_aliases accepted
  have writes := congrArg Prod.snd masks
  dsimp only [footprint] at writes
  rw [writes]
  simp only [PackageBindings.stateUnion, List.length_map, List.length_range]

/-- The target write added by the original assignment wrapper is combined
with the original function's direct and transitive effects. -/
theorem function_assignment_effects {calls : BasicCalls} {source : Statement.Input}
    {context : Predicate.Native.Context} {call : ScalarFunctions.Call} {bound : Nat} {effects : Effects}
    (same : context.model = source.context)
    (original : Basic.FunctionCallAt source.text context source.input source.info
      (assignmentFirst (basicReaders calls) source.text source.input) call)
    (selected : Basic.origin (basicReaders calls) source = .packageFunction)
    (accepted : (applicationBasic (basicReaders calls) source.text source.context source.input source.info
      source.catalog source.procedures).scan.position ≠ 0)
    (inferred : inferStatementEffects (completedEnvironment source.info) (layout bound source.info source.context)
      (.callAssign ⟨functionAssignmentTarget source.text source.context source.input.scan, call⟩) = some effects)
    (typed : source.info.Typed) (declared : ApplicationPackageDeclarations.DeclaredFormalModes source.info)
    (valid : 0 < source.text.length ∧ source.text.length ≤ maxSourceLength)
    (declarations : StateDeclarations source.text source.info.states)
    (scalarCapacity : source.context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : source.context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (target : calls.stateTarget source.text source.context source.info source.input.scan.position =
      ApplicationPackageEffects.stateTarget ApplicationPackageEffects.modelCalls
        source.text source.context source.info source.input.scan.position) :
    EffectSummaries.Included effects
      (scanEffects source.info (applicationBasic (basicReaders calls) source.text source.context source.input
        source.info source.catalog source.procedures)) := by
  have guards := Basic.function_origin selected
  have called : (packageCallAt modelCalls source.text context.model source.input source.info
      (assignmentFirst (basicReaders calls) source.text source.input) .function).value.after ≠ 0 := by
    simpa only [same, Basic.functionCall, basicReaders, Basic.withInheritedBody,
      Basic.functionReaders, Basic.procedureReaders] using guards.2
  have raw := SourceFrames.function_call_effects original called typed declared declarations
    (same.symm ▸ scalarCapacity) (same.symm ▸ booleanCapacity) (bound := bound)
  have positive : call.callee ≠ 0 := by
    obtain ⟨callee, _, _, _, selected, present, _⟩ := accepted_call called
    rw [original.1, ← selected]
    exact present
  obtain ⟨_, _, kind, found⟩ := callee_completed original.1.symm positive rfl
  simp only [inferStatementEffects, found, Option.bind_some, PackageBindings.Routine.signature,
    kind, Option.some.injEq] at inferred
  subst effects
  have masks := function_masks selected accepted
  have named := assignment_name guards.1.1 guards.1.2
  have space : source.info.states.length ≤
      (packageCallAt modelCalls source.text source.context source.input source.info
        (assignmentFirst (basicReaders calls) source.text source.input) .function).result.writes.length := by
    rw [call_write_length (same ▸ called)]
    exact typed.2.2.2.2.1
  have marked := named_write named valid declarations space (bound := bound)
  rw [same] at raw
  constructor
  · intro cell member
    change cell ∈ source.info.effectCells _
    rw [masks.1]
    exact raw.reads cell member
  · intro cell member
    change cell ∈ source.info.effectCells _
    rw [masks.2]
    change cell ∈ source.info.effectCells (markState _ (calls.stateTarget _ _ _ _))
    rw [target]
    change cell ∈ globalCells _ [ScalarProcedures.targetCell _] ++
      ((source.info.routineAt call.callee).effects source.info).writes at member
    rcases List.mem_append.mp member with direct | indirect
    · exact marked cell direct
    · apply marked_mono _ _ _ cell
      apply raw.writes cell
      change cell ∈ [] ++ ((source.info.routineAt call.callee).effects source.info).writes
      exact indirect

end BasicMasks
end Silver.ApplicationPackageSourceEffects
