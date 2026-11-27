module

public import Silver.ApplicationPackageRecursiveOutcomes

@[expose] public section

namespace Silver.ApplicationPackages

/-- Exact native fixed-array widths, independent of whether any bit is set and
of whether the source reader succeeds. -/
def ApplicationScan.MaskWidth (value : ApplicationScan) : Prop :=
  value.reads.length = PackageBindings.maxStates ∧ value.writes.length = PackageBindings.maxStates

theorem ApplicationScan.MaskWidth.invalid {value : ApplicationScan} (width : value.MaskWidth) :
    (invalidApplication value).MaskWidth := width

end Silver.ApplicationPackages

namespace Silver.ApplicationPackageCalls
open ApplicationPackages Compose Predicate

private theorem reset_mask_width (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (writes : PackageBindings.StateSet)
    (result : ApplicationCall) (index : Nat) (width : result.result.MaskWidth) :
    (resetState calls text context info writes result index).result.MaskWidth := by
  unfold resetState
  dsimp only
  split <;> exact width

private theorem resets_mask_width (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (writes : PackageBindings.StateSet) (indices : List Nat)
    (result : ApplicationCall) (width : result.result.MaskWidth) :
    (indices.foldl (fun result state => resetState calls text context info writes result (state + 1)) result).result.MaskWidth := by
  induction indices generalizing result with
  | nil => exact width
  | cons index rest ih => exact ih _ (reset_mask_width calls text context info writes result _ width)

/-- The original finishing unions allocate all effect cells; reset/copy-back
steps change only the body scan. No semantic metadata premise is needed. -/
theorem finishCall_mask_width (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (kind : PackageBindings.RoutineKind)
    (item : PackageBindings.Routine) (frame : ActualFrame) (checked : ApplicationCall) :
    (finishCall calls text context info kind item frame checked).result.MaskWidth := by
  apply resets_mask_width
  constructor <;> simp only [PackageBindings.stateUnion, List.length_map, List.length_range]

theorem packageCall_mask_width (calls : Calls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (position : Nat)
    (kind : PackageBindings.RoutineKind) (width : input.MaskWidth) :
    (packageCallAt calls text context input info position kind).result.MaskWidth := by
  unfold packageCallAt
  cases stages : callStages calls text context input info position kind with
  | none => exact width
  | some stagesValue =>
    rcases stagesValue with ⟨callee, item, frame, result⟩
    obtain ⟨_, _, _, _, checked, _, _, same, _, _⟩ := callStages_success stages
    dsimp only
    rw [same]
    exact finishCall_mask_width calls text context info kind item frame checked

end Silver.ApplicationPackageCalls

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

theorem native_function_mask_width (calls : BasicCalls) (source : Statement.Input)
    (width : source.input.MaskWidth) :
    (functionAssignment (nativeBasicReaders calls) source.text source.context source.input source.info
      source.catalog source.procedures).MaskWidth := by
  have called := ApplicationPackageCalls.packageCall_mask_width ApplicationPackageCalls.modelCalls
    source.text source.context source.input source.info
    (assignmentFirst (nativeBasicReaders calls) source.text source.input) .function width
  unfold functionAssignment
  dsimp only
  split
  · split
    · exact ⟨called.1, (List.length_set ..).trans called.2⟩
    · exact ⟨by simp only [PackageBindings.stateUnion, List.length_map, List.length_range],
        (List.length_set ..).trans width.2⟩
  · split
    · exact called
    · exact ⟨by simp only [PackageBindings.stateUnion, List.length_map, List.length_range], width.2⟩

theorem native_basic_mask_width (calls : BasicCalls) (source : Statement.Input)
    (width : source.input.MaskWidth) :
    (applicationBasic (nativeBasicReaders calls) source.text source.context source.input source.info
      source.catalog source.procedures).MaskWidth := by
  have result : (basicResult (nativeBasicReaders calls) source.text source.context source.input source.info
      source.catalog source.procedures).MaskWidth := by
    unfold basicResult
    split
    · exact native_function_mask_width calls source width
    · split
      · exact ApplicationPackageCalls.packageCall_mask_width ApplicationPackageCalls.modelCalls
          source.text source.context source.input source.info source.input.scan.position .procedure width
      · exact width
  unfold applicationBasic
  split
  · exact width
  · dsimp only
    split <;> first | exact width | exact result

theorem thenInput_mask_width (calls : Statement.Calls) (source : Statement.Input)
    (state : Statement.Arms) (condition : ConditionResult) (width : state.value.MaskWidth) :
    (Statement.thenInput calls source state condition).MaskWidth :=
  ⟨by simp only [Statement.thenInput, Statement.withFacts, Statement.atPosition,
      PackageBindings.stateUnion, List.length_map, List.length_range], width.2⟩

theorem forHeader_mask_width {calls : Statement.Calls} {source : Statement.Input}
    {afterFor : Nat} {iteration : Statement.Iteration} (width : source.input.MaskWidth)
    (parsed : Statement.forHeader calls source afterFor = some iteration) :
    iteration.value.MaskWidth := by
  unfold Statement.forHeader at parsed
  dsimp only at parsed
  split at parsed
  · contradiction
  · split at parsed
    · unfold Statement.arrayHeader at parsed
      dsimp only at parsed
      split at parsed
      · contradiction
      · split at parsed
        · contradiction
        · cases parsed; exact width
    · cases parsed
      dsimp only [Statement.countedHeader]
      split <;> exact ⟨by simp only [Statement.atPosition, PackageBindings.stateUnion,
        List.length_map, List.length_range], width.2⟩

theorem finishArm_mask_width {calls : Statement.Calls} {source : Statement.Input}
    {read : Statement.ReadArm} {after : Statement.Arms}
    (width : read.branch.MaskWidth)
    (finished : Statement.armState (Statement.finishArm calls source read) = some after) :
    after.value.MaskWidth := by
  unfold Statement.finishArm at finished
  dsimp only at finished
  split at finished
  · simp only [Statement.armState, Option.some.injEq] at finished
    cases finished; exact width
  · split at finished
    · contradiction
    · simp only [Statement.armState, Option.some.injEq] at finished
      cases finished; exact width

private theorem readArm_mask_width {readers : Readers} {source : Statement.Input}
    {before : Statement.Arms} {read : Statement.ReadArm}
    (decode : ∀ value, NativeDomain (atInput source value) →
      source.input.scan.position < value.scan.position → ∀ stop required,
      value.MaskWidth → ((nativeReaders readers).tailResult (atInput source value) stop required).MaskWidth)
    (legal : ArmsDomain source before) (lower : source.input.scan.position ≤ before.value.scan.position)
    (width : before.value.MaskWidth)
    (parsed : Statement.readArm (nativeStatementReaders readers.statement) source before = some read) :
    read.branch.MaskWidth := by
  have observed := Statement.readArm_evaluation parsed
  have entryLegal := legal.value.thenInput (calls := nativeStatementReaders readers.statement) rfl rfl
  have branchEq : (nativeReaders readers).tailResult
      (atInput source (Statement.thenInput (nativeStatementReaders readers.statement) source before
        (Statement.conditionFor (nativeStatementReaders readers.statement) source before))) .arm true =
      read.branch := observed.branchRead
  rw [← branchEq]
  exact decode _ entryLegal (Nat.lt_of_le_of_lt lower observed.thenAdvanced) .arm true
    (thenInput_mask_width _ _ _ _ width)

private theorem armsReading_mask_width {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} {before after : Statement.Arms} {entries}
    (typed : source.info.Typed)
    (decode : ∀ value, NativeDomain (atInput source value) →
      source.input.scan.position < value.scan.position → ∀ stop required,
      value.MaskWidth → ((nativeReaders readers).tailResult (atInput source value) stop required).MaskWidth)
    (reading : Statement.ArmsReading (nativeStatementReaders readers.statement) source before entries after) :
    ArmsDomain source before → source.input.scan.position ≤ before.value.scan.position →
    before.value.MaskWidth → after.value.MaskWidth := by
  induction reading with
  | @last before read after parsed finished =>
    intro legal lower width
    have step : Statement.armState
        (Statement.finishArm (nativeStatementReaders readers.statement) source read) = some after := by
      rw [finished]; rfl
    exact finishArm_mask_width (readArm_mask_width decode legal lower width parsed) step
  | @next before read after entries final parsed finished _ ih =>
    intro legal lower width
    have step : Statement.armState
        (Statement.finishArm (nativeStatementReaders readers.statement) source read) = some after := by
      rw [finished]; rfl
    obtain ⟨scan, _, advanced, _⟩ := readArm_outcome equations
      (fun value child _ stop required => ((equations.outcomes child typed).2 stop required)) legal lower parsed
    exact ih (legal.finish parsed scan step)
      (Nat.le_of_lt (Nat.lt_of_le_of_lt lower (finishArm_position parsed advanced step)))
      (finishArm_mask_width (readArm_mask_width decode legal lower width parsed) step)

private theorem else_mask_width {readers : Readers} {source : Statement.Input} {state : Statement.Arms}
    (decode : ∀ value, NativeDomain (atInput source value) →
      source.input.scan.position < value.scan.position → ∀ stop required,
      value.MaskWidth → ((nativeReaders readers).tailResult (atInput source value) stop required).MaskWidth)
    (legal : ArmsDomain source state) (lower : source.input.scan.position < state.value.scan.position)
    (width : state.value.MaskWidth) :
    (Statement.elseResult (nativeStatementReaders readers.statement) source state).MaskWidth := by
  by_cases missing : Statement.elsePosition (nativeStatementReaders readers.statement) source state = 0
  · simpa only [Statement.elseResult, missing, ne_self_iff_false, ite_false] using width
  · have advance := Expressions.model_fixed_advances source.text state.value.scan.position "else" true
      legal.value.scan.position (by decide) missing
    have childLegal := legal.value.atPosition
      (fixedAfter_result_bound source.text state.value.scan.position "else" true (by decide))
    have child := decode _ childLegal (Nat.lt_trans lower advance) .endOnly true width
    rw [Statement.elseResult, ite_eq_left missing]
    exact child

private theorem statement_mask_width {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} (legal : NativeDomain source) (typed : source.info.Typed)
    (width : source.input.MaskWidth)
    (decode : ∀ context value, NativeDomain (atContext source context value) →
      source.input.scan.position < value.scan.position → ∀ stop required,
      value.MaskWidth → ((nativeReaders readers).tailResult (atContext source context value) stop required).MaskWidth) :
    ((nativeReaders readers).statementResult source).MaskWidth := by
  by_cases present : ((nativeReaders readers).statementResult source).scan.position ≠ 0
  · have reading := equations.statement_reading legal present
    generalize resultEq : (nativeReaders readers).statementResult source = result at reading ⊢
    cases reading with
    | basic _ _ _ =>
      rw [equations.basic_model legal]
      exact native_basic_mask_width readers.basic source width
    | @conditional entries state result inputPresent keyword arms closing =>
      have first := Expressions.model_fixed_advances source.text source.input.scan.position "if" true
        legal.scan.position (by decide) keyword
      have stateWidth := armsReading_mask_width equations typed (decode source.context) arms
        (ArmsDomain.initial legal) (Nat.le_of_lt first) width
      obtain ⟨stateLegal, _, stateLower, _⟩ := armsReading_outcome equations
        (fun value child _ stop required => ((equations.outcomes child typed).2 stop required)) arms
        (ArmsDomain.initial legal) (Nat.le_of_lt first)
      have branchWidth := else_mask_width (decode source.context) stateLegal stateLower stateWidth
      rw [closing.resultEq]
      exact branchWidth
    | @iteration iteration result _ _ _ loop =>
      have childLegal := legal.loopInput loop.header loop.advances
      have childWidth := forHeader_mask_width width loop.header
      have inside := decode _ _ childLegal loop.advances .endOnly true childWidth
      rw [loop.resultEq]
      exact inside
  · have rejected : ((nativeReaders readers).statementResult source).scan.position = 0 := by simpa using present
    obtain ⟨_, evaluated⟩ := equations.statement_model legal
    rcases Statement.statementFuel_rejected evaluated rejected with invalid | basic
    · rw [invalid]; exact width
    · rw [basic, equations.basic_model legal]
      exact native_basic_mask_width readers.basic source width

private theorem tailExecution_mask_width {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} {stop : BodyStop} {required : Bool}
    {state : TailState} {result : ApplicationScan} (typed : source.info.Typed)
    (decode : ∀ value, NativeDomain (atInput source value) →
      source.input.scan.position ≤ value.scan.position → value.MaskWidth →
      ((nativeReaders readers).statementResult (atInput source value)).MaskWidth)
    (execution : TailExecution (Tail.reader readers.tail (tailContext source stop required)) state result) :
    NativeDomain (atInput source state.value) → source.input.scan.position ≤ state.value.scan.position →
    state.value.MaskWidth → result.MaskWidth := by
  induction execution with
  | @returned state result step =>
    intro legal lower width
    unfold Tail.reader tailStep at step
    split at step
    · have first := decode state.value legal lower width
      dsimp only at step
      split at step
      · cases step; exact first
      · contradiction
    · split at step <;> cases step <;> exact width
  | @continued state next result step _ ih =>
    intro legal lower width
    obtain ⟨advanced, _, nextEq⟩ := tailStep_progress step
    change next.value = (nativeReaders readers).statementResult (atInput source state.value) at nextEq
    have first := (equations.outcomes legal typed).1
    have nextScan : ScanDomain source.text source.context next.value.scan := by
      rw [nextEq]; exact first.scan
    apply ih (legal.replaceInput nextScan) (Nat.le_trans lower (Nat.le_of_lt advanced))
    rw [nextEq]
    exact decode state.value legal lower width

/-- Exact effect-array capacities throughout the original mutually recursive
reader. All accepted and rejected paths are included, over the native call
domain and field subtypes only. Child calls are at their original contexts. -/
theorem Equations.mask_widths {readers : Readers}
    (equations : Equations (nativeReaders readers) NativeDomain)
    {source : Statement.Input} (legal : NativeDomain source) (typed : source.info.Typed)
    (width : source.input.MaskWidth) :
    ((nativeReaders readers).statementResult source).MaskWidth ∧
      ∀ stop required, ((nativeReaders readers).tailResult source stop required).MaskWidth := by
  have all : ∀ remaining, ∀ input : Statement.Input, NativeDomain input → input.info.Typed →
      input.text.length + 1 - input.input.scan.position = remaining → input.input.MaskWidth →
      ((nativeReaders readers).statementResult input).MaskWidth ∧
        ∀ stop required, ((nativeReaders readers).tailResult input stop required).MaskWidth := by
    intro remaining
    induction remaining using Nat.strongRecOn with
    | ind remaining ih =>
      have statement : ∀ input : Statement.Input, NativeDomain input → input.info.Typed →
          input.text.length + 1 - input.input.scan.position = remaining → input.input.MaskWidth →
          ((nativeReaders readers).statementResult input).MaskWidth := by
        intro input inputLegal inputTyped size inputWidth
        apply statement_mask_width equations inputLegal inputTyped inputWidth
        intro context value childLegal advanced stop required childWidth
        have childBound : value.scan.position ≤ input.text.length + 1 := childLegal.scan.position
        have smaller : input.text.length + 1 - value.scan.position < remaining := by omega
        exact (ih _ smaller (atContext input context value) childLegal inputTyped rfl childWidth).2 stop required
      intro input inputLegal inputTyped size inputWidth
      refine ⟨statement input inputLegal inputTyped size inputWidth, ?_⟩
      intro stop required
      obtain ⟨_, evaluated⟩ := equations.tail_model inputLegal stop required
      apply tailExecution_mask_width equations inputTyped ?_ (tailFuel_sound evaluated) inputLegal (Nat.le_refl _) inputWidth
      intro value nextLegal advanced nextWidth
      have nextBound : value.scan.position ≤ input.text.length + 1 := nextLegal.scan.position
      have inputBound := inputLegal.scan.position
      have smallerOrSame : input.text.length + 1 - value.scan.position ≤ remaining := by omega
      by_cases same : input.text.length + 1 - value.scan.position = remaining
      · exact statement (atInput input value) nextLegal inputTyped same nextWidth
      · have smaller : input.text.length + 1 - value.scan.position < remaining := by omega
        exact (ih _ smaller (atInput input value) nextLegal inputTyped rfl nextWidth).1
  exact all _ source legal typed rfl width

end Silver.ApplicationPackageBodies.Recursive
