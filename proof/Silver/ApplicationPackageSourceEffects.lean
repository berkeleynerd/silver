module

public import Silver.ApplicationPackageLayoutEffects
public import Silver.ApplicationPackageVisibleStateLayout
public import Silver.PredicateFunctionCallMeaning
public import Silver.PackageEffectSummaries
public import Silver.ApplicationPackageCallsActualOrder

@[expose] public section

/-! Source expression effects are included in the native mask. Lexical
scanning may conservatively include more cells, and list order is immaterial. -/
namespace Silver.ApplicationPackageSourceEffects
open Compose Predicate Packages ApplicationPackageFrameLayout ApplicationPackageEffects

theorem union_cells {info : PackageBindings.Metadata}
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (left right : PackageBindings.StateSet) (cell : Cell) :
    cell ∈ info.effectCells (PackageBindings.stateUnion left right) ↔
      cell ∈ info.effectCells left ∨ cell ∈ info.effectCells right := by
  constructor
  · intro member
    obtain ⟨offset, inside, selected, same⟩ := (info.mem_effectCells _ _).mp member
    rw [PackageBindings.stateUnion_get left right (offset + 1) (by omega) (by omega),
      Bool.or_eq_true] at selected
    exact selected.elim
      (fun included => Or.inl ((info.mem_effectCells _ _).mpr ⟨offset, inside, included, same⟩))
      (fun included => Or.inr ((info.mem_effectCells _ _).mpr ⟨offset, inside, included, same⟩))
  · intro member
    rcases member with leftMember | rightMember
    · obtain ⟨offset, inside, selected, same⟩ := (info.mem_effectCells _ _).mp leftMember
      apply (info.mem_effectCells _ _).mpr
      refine ⟨offset, inside, ?_, same⟩
      rw [PackageBindings.stateUnion_get left right (offset + 1) (by omega) (by omega), selected]
      rfl
    · obtain ⟨offset, inside, selected, same⟩ := (info.mem_effectCells _ _).mp rightMember
      apply (info.mem_effectCells _ _).mpr
      refine ⟨offset, inside, ?_, same⟩
      rw [PackageBindings.stateUnion_get left right (offset + 1) (by omega) (by omega), selected]
      exact Bool.or_true _

theorem empty_cells (info : PackageBindings.Metadata) :
    info.effectCells PackageBindings.emptyStateSet = [] := by
  apply List.eq_nil_iff_forall_not_mem.mpr
  intro cell member
  obtain ⟨offset, _, selected, _⟩ := (info.mem_effectCells _ _).mp member
  rw [emptyStateSet_get] at selected
  contradiction

/-- Exact native bitmasks interpreted through the original state table. -/
def maskEffects (info : PackageBindings.Metadata) (reads writes : PackageBindings.StateSet) : Effects :=
  ⟨info.effectCells reads, info.effectCells writes⟩

def scanEffects (info : PackageBindings.Metadata) (scan : ApplicationPackages.ApplicationScan) : Effects :=
  maskEffects info scan.reads scan.writes

theorem mask_included {info : PackageBindings.Metadata} {reads writes laterReads laterWrites}
    (read : ∀ cell ∈ info.effectCells reads, cell ∈ info.effectCells laterReads)
    (write : ∀ cell ∈ info.effectCells writes, cell ∈ info.effectCells laterWrites) :
    EffectSummaries.Included (maskEffects info reads writes) (maskEffects info laterReads laterWrites) :=
  ⟨read, write⟩

theorem union_left {info : PackageBindings.Metadata}
    (capacity : info.states.length ≤ PackageBindings.maxStates) (first second : PackageBindings.StateSet) :
    ∀ cell ∈ info.effectCells first, cell ∈ info.effectCells (PackageBindings.stateUnion first second) :=
  fun cell member => (union_cells capacity first second cell).mpr (Or.inl member)

theorem union_right {info : PackageBindings.Metadata}
    (capacity : info.states.length ≤ PackageBindings.maxStates) (first second : PackageBindings.StateSet) :
    ∀ cell ∈ info.effectCells second, cell ∈ info.effectCells (PackageBindings.stateUnion first second) :=
  fun cell member => (union_cells capacity first second cell).mpr (Or.inr member)

theorem marked_mono (info : PackageBindings.Metadata) (mask : PackageBindings.StateSet) (identity : Nat) :
    ∀ cell ∈ info.effectCells mask, cell ∈ info.effectCells (ApplicationPackageCalls.markState mask identity) := by
  intro cell member
  obtain ⟨offset, inside, selected, same⟩ := (info.mem_effectCells _ _).mp member
  apply (info.mem_effectCells _ _).mpr
  refine ⟨offset, inside, ?_, same⟩
  by_cases zero : identity = 0
  · simpa only [ApplicationPackageCalls.markState, zero, ite_true] using selected
  · simp only [ApplicationPackageCalls.markState, zero, ite_false, PackageBindings.StateSet.get,
      Nat.add_one_sub_one, List.getD_eq_getElem?_getD]
    by_cases atSlot : identity - 1 = offset
    · have inMask : offset < mask.length := by
        by_cases active : offset < mask.length
        · exact active
        · simp only [PackageBindings.StateSet.get, Nat.add_one_sub_one, List.getD_eq_getElem?_getD,
            List.getElem?_eq_none (by omega : mask.length ≤ offset), Option.getD_none] at selected
          contradiction
      rw [atSlot, List.getElem?_set_self inMask]
      rfl
    · simpa only [List.getElem?_set_ne atSlot, PackageBindings.StateSet.get,
        Nat.add_one_sub_one, List.getD_eq_getElem?_getD] using selected

theorem marked_cell {info : PackageBindings.Metadata} {mask : PackageBindings.StateSet} {identity : Nat}
    (positive : 0 < identity) (active : identity ≤ info.states.length) (space : identity ≤ mask.length) :
    (info.stateAt identity).cell identity ∈
      info.effectCells (ApplicationPackageCalls.markState mask identity) := by
  rw [info.effectCells_index positive active]
  simp only [ApplicationPackageCalls.markState, Nat.ne_of_gt positive, ite_false,
    PackageBindings.StateSet.get, List.getD_eq_getElem?_getD,
    List.getElem?_set_self (by omega : identity - 1 < mask.length), Option.getD_some]

theorem condition_integer_global_read {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {bound position limit slot identity : Nat}
    {condition : Condition} {result : ConditionResult} {facts : ActiveFlow} {initials : ArrayBindings.Initials}
    (source : ConditionAt text context position facts condition result initials)
    (positionPositive : position ≠ 0) (positionBound : position ≤ text.length + 1)
    (finishBound : result.after ≤ limit)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (selected : (layout bound info context).integers slot = .global identity)
    (read : .integer slot ∈ conditionReads condition) :
    .integer identity ∈ info.effectCells (stateReads modelCalls text context info position limit) := by
  have live := slotAddress_global selected
  have same := stateIndex_some live.2.2
  rw [scalarRows_get] at same
  dsimp only at same
  have name := declarations.name same.1 same.2.1
  have domain := (ApplicationPackageNames.Native.validName_domain name).2
  have row : OriginalRow context (.integer slot) :=
    ⟨Nat.ne_of_gt live.1, by simpa only [scalarRows, List.length_map] using live.2.1,
      same.2.2.1, by rw [← same.2.2.2.2.1]; exact Nat.ne_of_gt domain.1,
      by rw [← same.2.2.2.2.1, ← same.2.2.2.2.2]; exact domain.2.1⟩
  have found := condition_source_original_lookup source row read
  change ScalarExpression.lookup text context.scalarNames _ _ = slot at found
  rw [← same.2.2.2.2.1, ← same.2.2.2.2.2] at found
  have covered := condition_integer_read_cell source positionPositive positionBound finishBound
    same.1 same.2.1 (Nat.le_trans same.2.1 capacity) name same.2.2.2.1 found row.1
    (Nat.le_trans row.2.1 scalarCapacity) same.2.2.2.2.1.symm same.2.2.2.2.2.symm
    (conditionReads_mentioned condition (.integer slot) read)
  simpa only [PackageBindings.StateDeclaration.cell, same.2.2.2.1] using covered

theorem condition_boolean_global_read {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {bound position limit slot identity : Nat}
    {condition : Condition} {result : ConditionResult} {facts : ActiveFlow} {initials : ArrayBindings.Initials}
    (source : ConditionAt text context position facts condition result initials)
    (positionPositive : position ≠ 0) (positionBound : position ≤ text.length + 1)
    (finishBound : result.after ≤ limit)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (booleanCapacity : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (selected : (layout bound info context).booleans slot = .global identity)
    (read : .boolean slot ∈ conditionReads condition) :
    .boolean identity ∈ info.effectCells (stateReads modelCalls text context info position limit) := by
  have live := slotAddress_global selected
  have same := stateIndex_some live.2.2
  rw [booleanRows_get] at same
  dsimp only at same
  have name := declarations.name same.1 same.2.1
  have domain := (ApplicationPackageNames.Native.validName_domain name).2
  have row : OriginalRow context (.boolean slot) :=
    ⟨Nat.ne_of_gt live.1, by simpa only [booleanRows, List.length_map] using live.2.1,
      same.2.2.1, by rw [← same.2.2.2.2.1]; exact Nat.ne_of_gt domain.1,
      by rw [← same.2.2.2.2.1, ← same.2.2.2.2.2]; exact domain.2.1⟩
  have found := condition_source_original_lookup source row read
  change ScalarExpression.lookup text context.scalarNames _ _ = 0 ∧
    BooleanBindings.lookup text context.booleanNames _ _ = slot at found
  rw [← same.2.2.2.2.1, ← same.2.2.2.2.2] at found
  have covered := condition_boolean_read_cell source positionPositive positionBound finishBound
    same.1 same.2.1 (Nat.le_trans same.2.1 capacity) name same.2.2.2.1 found.1 found.2 row.1
    (Nat.le_trans row.2.1 booleanCapacity) same.2.2.2.2.1.symm same.2.2.2.2.2.symm
    (conditionReads_mentioned condition (.boolean slot) read)
  simpa only [PackageBindings.StateDeclaration.cell, same.2.2.2.1] using covered

theorem scalar_global_read {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {bound position limit slot identity maskFirst maskAfter : Nat}
    {expression : Integer.Expr} {result : ScalarExpression.Result} {facts : ActiveFlow}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials}
    {elaborating allowSign : Bool} {mode : ScalarExpression.ArrayReadMode}
    (source : ScalarExpression.ArrayGrammar.At text (context.readingNames facts) position expression result
      maskFirst maskAfter allowSign arrays initials elaborating mode)
    (finishBound : result.after ≤ limit)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (selected : (layout bound info context).integers slot = .global identity)
    (read : .integer slot ∈ integerReads expression) :
    .integer identity ∈ info.effectCells (stateReads modelCalls text context info position limit) := by
  have live := slotAddress_global selected
  have same := stateIndex_some live.2.2
  rw [scalarRows_get] at same
  dsimp only at same
  have name := declarations.name same.1 same.2.1
  have domain := (ApplicationPackageNames.Native.validName_domain name).2
  have row : OriginalRow context (.integer slot) :=
    ⟨Nat.ne_of_gt live.1, by simpa only [scalarRows, List.length_map] using live.2.1,
      same.2.2.1, by rw [← same.2.2.2.2.1]; exact Nat.ne_of_gt domain.1,
      by rw [← same.2.2.2.2.1, ← same.2.2.2.2.2]; exact domain.2.1⟩
  have found := scalar_original_in_flow source.source row read
  change ScalarExpression.lookup text context.scalarNames _ _ = slot at found
  rw [← same.2.2.2.2.1, ← same.2.2.2.2.2] at found
  have visible : visibleState modelCalls text context info identity = true := by
    simp [visibleState, modelCalls, Nat.not_lt.mpr same.2.1, name, same.2.2.2.1,
      found, row.1, same.2.2.2.2.1.symm, same.2.2.2.2.2.symm]
  have occurrence : actualNameFree text position limit
      (info.stateAt identity).name.first (info.stateAt identity).name.after = false := by
    apply Bool.eq_false_iff.mpr
    intro free
    have overlayLookup : ScalarExpression.lookup text (context.readingNames facts)
        (info.stateAt identity).name.first (info.stateAt identity).name.after = slot := by
      simpa only [ParseContext.readingNames, ScalarMetadata.readingNames_lookup] using found
    have absent := ((actualNameFree_sound free).scalar source finishBound overlayLookup
      (Nat.le_trans row.2.1 scalarCapacity)).1
    rw [integerReads_integer expression slot read] at absent
    contradiction
  have covered := (stateReads_cell modelCalls text context info position limit identity
    same.1 same.2.1 (Nat.le_trans same.2.1 capacity)).mpr
      ⟨by have bounds := source.cursorBounds; omega, visible, occurrence⟩
  simpa only [PackageBindings.StateDeclaration.cell, same.2.2.2.1] using covered

theorem condition_global_reads {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {bound position limit : Nat}
    {condition : Condition} {result : ConditionResult} {facts : ActiveFlow} {initials : ArrayBindings.Initials}
    (source : ConditionAt text context position facts condition result initials)
    (positionPositive : position ≠ 0) (positionBound : position ≤ text.length + 1)
    (finishBound : result.after ≤ limit)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : context.booleanNames.length ≤ BooleanBindings.maxBindings) :
    ∀ cell ∈ globalCells (layout bound info context) (conditionReads condition),
      cell ∈ info.effectCells (stateReads modelCalls text context info position limit) := by
  intro cell present
  obtain ⟨localCell, read, selected⟩ := globalCells_mem.mp present
  cases localCell with
  | integer slot =>
      cases address : (layout bound info context).integers slot with
      | «local» _ => simp only [FrameLayout.place, address] at selected; contradiction
      | global identity =>
          have equal : cell = .integer identity := by
            simpa only [FrameLayout.place, address, Place.global.injEq] using selected.symm
          subst cell
          exact condition_integer_global_read source positionPositive positionBound finishBound
            declarations capacity scalarCapacity address read
  | boolean slot =>
      cases address : (layout bound info context).booleans slot with
      | «local» _ => simp only [FrameLayout.place, address] at selected; contradiction
      | global identity =>
          have equal : cell = .boolean identity := by
            simpa only [FrameLayout.place, address, Place.global.injEq] using selected.symm
          subst cell
          exact condition_boolean_global_read source positionPositive positionBound finishBound
            declarations capacity booleanCapacity address read

theorem scalar_global_reads {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {bound position limit maskFirst maskAfter : Nat}
    {expression : Integer.Expr} {result : ScalarExpression.Result} {facts : ActiveFlow}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials}
    {elaborating allowSign : Bool} {mode : ScalarExpression.ArrayReadMode}
    (source : ScalarExpression.ArrayGrammar.At text (context.readingNames facts) position expression result
      maskFirst maskAfter allowSign arrays initials elaborating mode)
    (finishBound : result.after ≤ limit)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit) :
    ∀ cell ∈ globalCells (layout bound info context) (integerReads expression),
      cell ∈ info.effectCells (stateReads modelCalls text context info position limit) := by
  intro cell present
  obtain ⟨localCell, used, selected⟩ := globalCells_mem.mp present
  cases localCell with
  | integer slot =>
      cases address : (layout bound info context).integers slot with
      | «local» _ => simp only [FrameLayout.place, address] at selected; contradiction
      | global identity =>
          have equal : cell = .integer identity := by
            simpa only [FrameLayout.place, address, Place.global.injEq] using selected.symm
          subst cell
          exact scalar_global_read source finishBound declarations capacity scalarCapacity address used
  | boolean slot =>
      exact (integerReads_no_boolean expression slot used).elim

/-- Scalar actuals include both the original Integer/Boolean expression and
the native reader's exact finishing position. The subsequent native lexical
mask may contain extra reads, but it cannot omit an interpreted global read. -/
theorem actual_global_reads {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {bound position after limit : Nat}
    {formal : FunctionBindings.Formal} {actual : ScalarFunctions.Actual} {facts : ActiveFlow}
    (source : ActualAt text context position facts formal actual after)
    (scalar : formal.typeId = 0)
    (positionPositive : position ≠ 0) (positionBound : position ≤ text.length + 1)
    (finishBound : after ≤ limit)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : context.booleanNames.length ≤ BooleanBindings.maxBindings) :
    ∀ cell ∈ globalCells (layout bound info context) (actualReads actual),
      cell ∈ info.effectCells (stateReads modelCalls text context info position limit) := by
  cases source.payload with
  | integer scalar kind reading nonempty included =>
      have bounds := reading.cursorBounds
      have positive : (readScalarInFlow text context position facts).after ≠ 0 := by omega
      have finish := source.equation
      simp only [actualAfter, scalar, ne_eq, not_true_eq_false, kind, reduceCtorEq, ↓reduceIte,
        positive, nonempty, included, Bool.not_true, Bool.false_eq_true, or_self] at finish
      exact scalar_global_reads reading (finish ▸ finishBound) declarations capacity scalarCapacity
  | boolean scalar kind reading =>
      have finish : (readCondition text context position facts).after = after := by
        simpa only [actualAfter, scalar, ne_eq, not_true_eq_false, kind, ↓reduceIte] using source.equation
      exact condition_global_reads reading positionPositive positionBound (finish ▸ finishBound)
        declarations capacity scalarCapacity booleanCapacity
  | array reading =>
      have positive := reading.nominal
      omega

namespace NativeReads
open ApplicationPackageCalls ApplicationPackages

attribute [local irreducible] PackageBindings.stateUnion

private theorem getD_set_either {α : Type} (values : List α) (index position : Nat) (value fallback : α) :
    (values.set index value).getD position fallback = value ∨
      (values.set index value).getD position fallback = values.getD position fallback := by
  induction values generalizing index position with
  | nil => exact Or.inr rfl
  | cons head tail ih =>
    cases index with
    | zero => cases position with
      | zero => exact Or.inl rfl
      | succ position => exact Or.inr rfl
    | succ index => cases position with
      | zero => exact Or.inr rfl
      | succ position => exact ih index position

/-- Every physical actual row's mask is contained in the native accumulator.
The invariant includes arbitrary backing indices and does not assume source
association order or an already completed semantic checker. -/
def StoredReads (info : PackageBindings.Metadata) (frame : ActualFrame) : Prop :=
  ∀ slot cell, cell ∈ info.effectCells (frame.actual slot).reads →
    cell ∈ info.effectCells frame.result.result.reads

theorem actual_step_masks {calls text context input info item ordinal before after}
    (accepted : actualStep calls text context input info item ordinal before = some after) :
    ∃ slot row, after.actuals = before.actuals.set (slot - 1) row ∧
      after.result.result.reads = PackageBindings.stateUnion before.result.result.reads row.reads ∧
      after.result.result.writes = before.result.result.writes := by
  unfold actualStep at accepted
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff] at accepted
  obtain ⟨⟨slot, named, cursor⟩, _, accepted⟩ := accepted
  dsimp only at accepted
  by_cases unavailable : slot = 0 ∨ before.seen.getD (slot - 1) false = true
  · simp only [unavailable, ite_true, reduceCtorEq] at accepted
  · simp only [unavailable, ite_false] at accepted
    cases read : actualPayload calls text context input (info.parameterAt slot) info cursor
        {before.actual slot with first := cursor} with
    | mk following value =>
      simp only [read] at accepted
      by_cases stopped : following ≤ cursor
      · simp only [stopped, ite_true, reduceCtorEq] at accepted
      · by_cases absent : calls.take text following (if ordinal = item.count then .symbol ")" else .symbol ",") = 0
        · simp only [stopped, absent, ite_true, ite_false, reduceCtorEq] at accepted
        · simp only [stopped, absent, ite_false, Option.some.injEq] at accepted
          subst after
          refine ⟨slot, _, rfl, rfl, rfl⟩

theorem actual_step_stored {calls text context input info item ordinal before after}
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (stored : StoredReads info before)
    (accepted : actualStep calls text context input info item ordinal before = some after) :
    StoredReads info after := by
  obtain ⟨index, row, cells, reads, _⟩ := actual_step_masks accepted
  intro slot cell member
  have selected : after.actual slot = row ∨ after.actual slot = before.actual slot := by
    simp only [ActualFrame.actual, cells]
    exact getD_set_either before.actuals (index - 1) (slot - 1) row {}
  rw [reads]
  rcases selected with current | earlier
  · rw [current] at member
    exact union_right capacity _ _ cell member
  · rw [earlier] at member
    exact union_left capacity _ _ cell (stored slot cell member)

theorem actual_step_incoming {calls text context input info item ordinal before after}
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (accepted : actualStep calls text context input info item ordinal before = some after) :
    (∀ cell ∈ info.effectCells before.result.result.reads, cell ∈ info.effectCells after.result.result.reads) ∧
      after.result.result.writes = before.result.result.writes := by
  obtain ⟨_, row, _, reads, writes⟩ := actual_step_masks accepted
  rw [reads]
  exact ⟨union_left capacity _ row.reads, writes⟩

private theorem initial_stored (info : PackageBindings.Metadata) (input : ApplicationScan)
    (item : PackageBindings.Routine) (cursor : Nat) : StoredReads info (initialActualFrame input item cursor) := by
  intro slot cell member
  have row : (initialActualFrame input item cursor).actual slot = {} := by
    simp only [initialActualFrame, ActualFrame.actual, List.getD_eq_getElem?_getD, List.getElem?_replicate]
    split <;> rfl
  rw [row] at member
  change cell ∈ info.effectCells PackageBindings.emptyStateSet at member
  rw [empty_cells] at member
  contradiction

private theorem fold_stored {calls text context input info item before after} (indices : List Nat)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (stored : StoredReads info before)
    (accepted : indices.foldlM (fun frame index => actualStep calls text context input info item (index + 1) frame)
      before = some after) : StoredReads info after := by
  induction indices generalizing before with
  | nil => cases Option.some.inj accepted; exact stored
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at accepted
    obtain ⟨middle, first, remaining⟩ := accepted
    exact ih (actual_step_stored capacity stored first) remaining

/-- The actual reader starts with empty row masks and accumulates every
stored actual mask through the original successful native fold. -/
theorem read_actuals_stored {calls text context input info item afterName frame}
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (accepted : readActuals calls text context input info item afterName = some frame) :
    StoredReads info frame := by
  unfold readActuals at accepted
  by_cases zero : item.count = 0
  · simp only [zero, ite_true, Option.some.injEq] at accepted
    subst frame
    exact initial_stored info input item afterName
  · by_cases missing : calls.take text afterName (.symbol "(") = 0
    · simp only [zero, missing, ite_false, ite_true, reduceCtorEq] at accepted
    · simp only [zero, missing, ite_false] at accepted
      exact fold_stored _ capacity (initial_stored info input item _) accepted

private theorem fold_incoming {calls text context input info item before after} (indices : List Nat)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (accepted : indices.foldlM (fun frame index => actualStep calls text context input info item (index + 1) frame)
      before = some after) :
    (∀ cell ∈ info.effectCells before.result.result.reads, cell ∈ info.effectCells after.result.result.reads) ∧
      after.result.result.writes = before.result.result.writes := by
  induction indices generalizing before with
  | nil => cases Option.some.inj accepted; exact ⟨fun _ member => member, rfl⟩
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at accepted
    obtain ⟨middle, first, remaining⟩ := accepted
    have head := actual_step_incoming capacity first
    have tail := ih remaining
    exact ⟨fun cell member => tail.1 cell (head.1 cell member), tail.2.trans head.2⟩

theorem read_actuals_incoming {calls text context input info item afterName frame}
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (accepted : readActuals calls text context input info item afterName = some frame) :
    (∀ cell ∈ info.effectCells input.reads, cell ∈ info.effectCells frame.result.result.reads) ∧
      frame.result.result.writes = input.writes := by
  unfold readActuals at accepted
  by_cases zero : item.count = 0
  · simp only [zero, ite_true, Option.some.injEq] at accepted
    subst frame
    exact ⟨fun _ member => member, rfl⟩
  · by_cases missing : calls.take text afterName (.symbol "(") = 0
    · simp only [zero, missing, ite_false, ite_true, reduceCtorEq] at accepted
    · simp only [zero, missing, ite_false] at accepted
      exact fold_incoming _ capacity accepted

end NativeReads

end Silver.ApplicationPackageSourceEffects
