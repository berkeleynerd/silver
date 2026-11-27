module

public import Silver.ApplicationPackageRecursiveDomain
public import Silver.ApplicationPackageProcedureOutputs
public import Silver.ApplicationPackageCallsValidityMeaning

@[expose] public section

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

theorem ScanDomain.storage {text : Source} {context : ParseContext} {scan : BodyScan}
    (valid : ScanDomain text context scan) : ApplicationPackageCalls.ValidityNative.FlowStorage scan.facts := by
  refine ⟨valid.path, ?_⟩
  intro bounds member
  obtain ⟨index, inside, same⟩ := List.mem_iff_getElem.mp member
  apply valid.flow.bounded (index + 1) bounds
  change ActiveFlow.ranges scan.facts.values (index + 1) = some bounds
  rw [ActiveFlow.ranges_inside _ _ (by omega) (by omega)]
  simpa only [Nat.add_sub_cancel, List.getElem?_eq_getElem inside] using congrArg some same

theorem ScanDomain.invalid {text : Source} {context : ParseContext} {scan : BodyScan}
    (valid : ScanDomain text context scan) : ScanDomain text context (invalidBody scan) :=
  ⟨Nat.zero_le _, ⟨Nat.zero_le _, Nat.zero_le _⟩, PathFacts.Context.empty_bounded, valid.flow.withPath _⟩

end Silver.ApplicationPackageBodies.Recursive

namespace Silver.ApplicationPackageCalls
open ApplicationPackages Compose Predicate PackageBindings ApplicationPackageBodies.Recursive

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

private theorem getD_property {α : Type} (property : α → Prop) (items : List α) (fallback : α)
    (default : property fallback) (all : ∀ item ∈ items, property item) (index : Nat) :
    property (items.getD index fallback) := by
  cases found : items[index]? with
  | none => simpa only [List.getD_eq_getElem?_getD, found, Option.getD_none] using default
  | some item =>
    simpa only [List.getD_eq_getElem?_getD, found, Option.getD_some] using all item (List.mem_of_getElem? found)

theorem formal_bounds_typed {info : Metadata} (typed : info.Typed) (index : Nat) :
    (info.parameterAt index).bounds.Bounded := by
  rcases typed with ⟨_, _, _, _, _, _, _, _, _, _, _, parameters⟩
  exact getD_property (fun item : Formal => item.bounds.Bounded) info.parameters {}
    Integer.Interval.empty_bounded (fun item member => (parameters item member).2.2.2.2.1) (index - 1)

theorem routine_bounds_typed {info : Metadata} (typed : info.Typed) (index : Nat) :
    (info.routineAt index).resultBounds.Bounded := by
  rcases typed with ⟨_, _, _, _, _, _, _, _, _, _, routines, _⟩
  apply getD_property (fun item : Routine => item.resultBounds.Bounded) info.routines {}
    Integer.Interval.empty_bounded _ (index - 1)
  intro item member
  rcases routines item member with ⟨_, _, _, _, _, _, _, _, _, _, bounds, _⟩
  exact bounds

theorem scalar_declared_bounded {text : Source} {names : ScalarExpression.Environment}
    (valid : ScalarExpression.ValidEnvironment text names) (index : Nat) :
    (ScalarExpression.binding names index).declaredBounds.Bounded :=
  getD_property (fun item : ScalarExpression.Binding => item.declaredBounds.Bounded)
    names ScalarExpression.emptyBinding Integer.Interval.empty_bounded
    (fun item member => (valid.2 item member).2.2.2.2.1) (index - 1)

theorem ValidityNative.FlowStorage.replace {facts : ActiveFlow} (valid : ValidityNative.FlowStorage facts)
    (index : Nat) (bounds : Integer.Interval) (typed : bounds.Bounded) :
    ValidityNative.FlowStorage (facts.replace index bounds) := by
  refine ⟨by simpa only [ActiveFlow.replace_path] using valid.path, ?_⟩
  intro value member
  unfold ActiveFlow.replace at member
  split at member
  · exact valid.intervals value member
  · rcases List.mem_or_eq_of_mem_set member with old | rfl
    · exact valid.intervals value old
    · exact typed

/-- Type storage and the scalar-independent native return fields. This is
preserved through arbitrary metadata; no declaration validity is assumed. -/
structure CallStorage (input : ApplicationScan) (value : ApplicationCall) : Prop where
  count : value.result.count = input.count
  calls : value.result.allowProcedureCalls = input.allowProcedureCalls
  capacity : value.result.scan.capacity = input.scan.capacity
  flow : ValidityNative.FlowStorage value.result.scan.facts

theorem CallStorage.replace {input : ApplicationScan} {value : ApplicationCall}
    (valid : CallStorage input value) (index : Nat) (bounds : Integer.Interval) (typed : bounds.Bounded) :
    CallStorage input (replaceScalar value index bounds) := by
  refine ⟨?_, valid.calls, valid.capacity, valid.flow.replace index bounds typed⟩
  exact (ActiveFlow.replace_count ..).trans valid.count

theorem aliasStep_storage {calls : Calls} {text : Source} {info : Metadata} {item : Routine}
    {actuals : List PackageActual} {input : ApplicationScan} {before after : ApplicationCall} {index : Nat}
    (typed : info.Typed) (valid : CallStorage input before)
    (selected : aliasStep calls text info item actuals before index = some after) :
    CallStorage input after := by
  unfold aliasStep at selected
  dsimp only at selected
  split at selected
  · contradiction
  · split at selected
    · cases selected; exact valid
    · split at selected
      · contradiction
      · split at selected
        · contradiction
        · split at selected
          · contradiction
          · cases selected
            have replaced := valid.replace (actuals.getD (index - 1) {}).target.scalar
              (info.parameterAt index).bounds (formal_bounds_typed typed index)
            exact ⟨replaced.count, replaced.calls, replaced.capacity, replaced.flow⟩

theorem aliases_storage {calls : Calls} {text : Source} {info : Metadata} {item : Routine}
    {frame : ActualFrame} {input : ApplicationScan} {after : ApplicationCall}
    (typed : info.Typed) (valid : CallStorage input frame.result)
    (selected : checkAliases calls text info item frame = some after) :
    CallStorage input after := by
  change (formalSlots item).foldlM (aliasStep calls text info item frame.actuals) frame.result = some after at selected
  generalize slotsEq : formalSlots item = slots at selected
  clear slotsEq
  generalize beforeEq : frame.result = before at selected valid
  clear beforeEq
  induction slots generalizing before with
  | nil => cases selected; exact valid
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at selected
    obtain ⟨middle, first, remaining⟩ := selected
    exact ih middle remaining (aliasStep_storage typed valid first)

theorem resetState_storage {calls : Calls} {text : Source} {context : ParseContext}
    {info : Metadata} {writes : StateSet} {input : ApplicationScan} {value : ApplicationCall}
    (valid : CallStorage input value) (names : ScalarExpression.ValidEnvironment text context.scalarNames)
    (index : Nat) : CallStorage input (resetState calls text context info writes value index) := by
  unfold resetState
  dsimp only
  split
  · exact valid.replace _ _ (scalar_declared_bounded names _)
  · exact valid

theorem reset_fold_storage {calls : Calls} {text : Source} {context : ParseContext}
    {info : Metadata} {writes : StateSet} {input : ApplicationScan} {value : ApplicationCall}
    (valid : CallStorage input value) (names : ScalarExpression.ValidEnvironment text context.scalarNames)
    (slots : List Nat) : CallStorage input (slots.foldl
      (fun result state => resetState calls text context info writes result (state + 1)) value) := by
  induction slots generalizing value with
  | nil => exact valid
  | cons index rest ih => exact ih (resetState_storage valid names (index + 1))

theorem finishCall_storage {calls : Calls} {text : Source} {context : ParseContext}
    {info : Metadata} {kind : RoutineKind} {item : Routine} {frame : ActualFrame}
    {input : ApplicationScan} {value : ApplicationCall}
    (valid : CallStorage input value) (names : ScalarExpression.ValidEnvironment text context.scalarNames) :
    CallStorage input (finishCall calls text context info kind item frame value) := by
  let seeded := {value with result := {value.result with
    reads := stateUnion value.result.reads item.mayRead,
    writes := stateUnion value.result.writes frame.callWrites}}
  have initial : CallStorage input seeded := ⟨valid.count, valid.calls, valid.capacity, valid.flow⟩
  have folded : CallStorage input ((List.range info.states.length).foldl
      (fun result state => resetState calls text context info frame.callWrites result (state + 1)) seeded) := by
    exact reset_fold_storage initial names _
  unfold finishCall
  dsimp only
  split <;> exact ⟨folded.count, folded.calls, folded.capacity, folded.flow⟩

theorem readActuals_storage {calls text context input info item position frame}
    (storage : ValidityNative.FlowStorage input.scan.facts)
    (parsed : readActuals calls text context input info item position = some frame) :
    CallStorage input frame.result := by
  obtain ⟨scan, calls, _⟩ := readActuals_frame parsed
  refine ⟨?_, calls, ?_, ?_⟩
  · change frame.result.result.scan.count = input.scan.count
    rw [scan]
  · rw [scan]
  · rw [scan]
    exact storage

/-- The guarded raw package call returns a valid native body on its full
declared input domain. `Typed` contains only native field/subtype bounds. It
does not assert valid declarations, completed routines or admitted code. -/
theorem packageCall_native_contract {source : ApplicationPackageBodies.Statement.Input}
    (legal : NativeDomain source) (typed : source.info.Typed) (position : Nat) (kind : RoutineKind) :
    let result := packageCallAt modelCalls source.text source.context source.input source.info position kind
    ScanDomain source.text source.context result.result.scan ∧
      result.result.count = source.input.count ∧
      result.result.allowProcedureCalls = source.input.allowProcedureCalls ∧ result.value.bounds.Bounded := by
  cases selected : callStages modelCalls source.text source.context source.input source.info position kind with
  | none =>
    simp only [packageCallAt, selected]
    exact ⟨legal.scan.invalid, rfl, rfl, Integer.Interval.empty_bounded⟩
  | some tuple =>
    rcases tuple with ⟨callee, item, frame, result⟩
    obtain ⟨_, _, itemEq, _, aliased, read, aliases, resultEq, _, checked⟩ := callStages_success selected
    have storage : CallStorage source.input
        (finishCall modelCalls source.text source.context source.info kind item frame aliased) := finishCall_storage
      (aliases_storage typed (readActuals_storage legal.scan.storage read) aliases) legal.scalarNames
    rw [← resultEq] at storage
    obtain ⟨native, same, valid⟩ := legal.context
    have guarded : bodyValidCheck source.text native.model result.result.scan = true := by
      rw [same]
      exact checked
    obtain ⟨bound, target, path, flow⟩ := ValidityNative.body_import_domain _ _ _ storage.flow guarded
    simp only [packageCallAt, selected]
    refine ⟨⟨bound, ⟨?_, ?_⟩, path, ?_⟩, storage.count, storage.calls, ?_⟩
    · rw [← same]
      change result.result.scan.target ≤ native.names.length
      exact target
    · rw [storage.capacity]
      exact legal.scan.controls.2
    · rw [← same]
      change ScalarMetadata.FlowReady native.scalarNames native.declarationCount result.result.scan.facts
      exact flow
    · rw [resultEq]
      change item.resultBounds.Bounded
      rw [itemEq]
      exact routine_bounds_typed typed _

end Silver.ApplicationPackageCalls
