module

public import Silver.ApplicationPackageLayoutEffects
public import Silver.ApplicationPackageVisibleStateLayout
public import Silver.PredicateFunctionCallMeaning
public import Silver.PackageEffectSummaries
public import Silver.ApplicationPackageCallsActualOrder
public import Silver.ApplicationPackageRecursiveSyntax

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

/-- Every populated non-output row carries the exact lexical read mask for
its original actual span. Unpopulated rows retain the native zero endpoint. -/
def RowReads (calls : ApplicationPackageCalls.Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (frame : ActualFrame) : Prop :=
  ∀ slot, 0 < slot → (info.parameterAt slot).mode ≠ .output → (frame.actual slot).after ≠ 0 →
    (frame.actual slot).reads = calls.stateReads text context info (frame.actual slot).first (frame.actual slot).after

theorem actual_step_row_reads {calls text context input info item ordinal before after}
    (previous : RowReads calls text context info before)
    (accepted : actualStep calls text context input info item ordinal before = some after) :
    RowReads calls text context info after := by
  obtain ⟨index, named, cursor, _, positive, _, _, _, written, _, _, _⟩ := actual_step_fields accepted
  intro slot slotPositive mode present
  by_cases same : index - 1 = slot - 1
  · have equal : index = slot := by omega
    subst index
    by_cases inside : slot - 1 < before.actuals.length
    · have row : after.actual slot = recordedActual calls text context info (info.parameterAt slot) cursor
          (actualPayload calls text context input (info.parameterAt slot) info cursor
            {before.actual slot with first := cursor}) := by
        simp only [ActualFrame.actual, written, List.getD_eq_getElem?_getD,
          List.getElem?_set_self inside, Option.getD_some]
      rw [row]
      by_cases inputMode : (info.parameterAt slot).mode = .input <;>
        simp [recordedActual, actualPayload, inputMode, mode]
    · have length : after.actuals.length ≤ slot - 1 := by
        rw [written, List.length_set]
        omega
      have absent : after.actual slot = {} := by
        simp only [ActualFrame.actual, List.getD_eq_getElem?_getD,
          List.getElem?_eq_none length, Option.getD_none]
      exact (present (by rw [absent])).elim
  · have unchanged : after.actual slot = before.actual slot := by
      simp only [ActualFrame.actual, written, List.getD_eq_getElem?_getD, List.getElem?_set_ne same]
    rw [unchanged] at present ⊢
    exact previous slot slotPositive mode present

private theorem initial_row_reads (calls : ApplicationPackageCalls.Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (input : ApplicationScan) (item : PackageBindings.Routine) (cursor : Nat) :
    RowReads calls text context info (initialActualFrame input item cursor) := by
  intro slot _ _ present
  have row : (initialActualFrame input item cursor).actual slot = {} := by
    simp only [initialActualFrame, ActualFrame.actual, List.getD_eq_getElem?_getD, List.getElem?_replicate]
    split <;> rfl
  exact (present (by rw [row])).elim

private theorem fold_row_reads {calls text context input info item before after} (indices : List Nat)
    (previous : RowReads calls text context info before)
    (accepted : indices.foldlM (fun frame index => actualStep calls text context input info item (index + 1) frame)
      before = some after) : RowReads calls text context info after := by
  induction indices generalizing before with
  | nil => cases Option.some.inj accepted; exact previous
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at accepted
    obtain ⟨middle, first, remaining⟩ := accepted
    exact ih (actual_step_row_reads previous first) remaining

theorem read_actuals_row_reads {calls text context input info item afterName frame}
    (accepted : readActuals calls text context input info item afterName = some frame) :
    RowReads calls text context info frame := by
  unfold readActuals at accepted
  by_cases zero : item.count = 0
  · simp only [zero, ite_true, Option.some.injEq] at accepted
    subst frame
    exact initial_row_reads calls text context info input item afterName
  · by_cases missing : calls.take text afterName (.symbol "(") = 0
    · simp only [zero, missing, ite_false, ite_true, reduceCtorEq] at accepted
    · simp only [zero, missing, ite_false] at accepted
      exact fold_row_reads _ (initial_row_reads calls text context info input item _) accepted

/-- Original scalar argument syntax, the executed native actual fold and the
state declaration origins derive the argument's complete shared read footprint. -/
theorem actual_read_included {text : Source} {context : ParseContext}
    {input : ApplicationScan} {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {afterName slot bound : Nat} {frame : ActualFrame} {actual : ScalarFunctions.Actual}
    (read : readActuals ApplicationPackageCalls.modelCalls text context input info item afterName = some frame)
    (source : ActualAt text context (frame.actual slot).first input.scan.facts
      (inputFormal (info.parameterAt slot)) actual (frame.actual slot).after)
    (positive : 0 < slot) (mode : (info.parameterAt slot).mode ≠ .output)
    (firstBound : (frame.actual slot).first ≤ text.length + 1)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : context.booleanNames.length ≤ BooleanBindings.maxBindings) :
    ∀ cell ∈ globalCells (layout bound info context) (actualReads actual),
      cell ∈ info.effectCells frame.result.result.reads := by
  have nonzero : (frame.actual slot).first ≠ 0 := by
    intro zero
    have original := source.equation
    rw [zero, actualAfter_zero] at original
    exact source.positive original.symm
  have lexical := actual_global_reads (bound := bound) source rfl nonzero firstBound (Nat.le_refl _)
    declarations capacity scalarCapacity booleanCapacity
  have recorded := read_actuals_row_reads read slot positive mode source.positive
  intro cell member
  apply read_actuals_stored capacity read slot cell
  rw [recorded]
  exact lexical cell member

end NativeReads

namespace NativeMasks
open ApplicationPackageCalls ApplicationPackages ApplicationPackageBodies
open Packages.EffectSummaries

attribute [local irreducible] PackageBindings.stateUnion
attribute [local irreducible] packageCallAt

/-- Raw calls retain incoming effects through actual parsing, alias checks,
summary union and visible-state resets, including rejected calls. -/
theorem call_incoming (calls : ApplicationPackageCalls.Calls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (position : Nat)
    (kind : PackageBindings.RoutineKind) (capacity : info.states.length ≤ PackageBindings.maxStates) :
    Included (scanEffects info input)
      (scanEffects info (packageCallAt calls text context input info position kind).result) := by
  cases stages : callStages calls text context input info position kind with
  | none =>
      simpa only [packageCallAt, stages, ApplicationPackageCalls.failure, invalidApplication, scanEffects] using
        Included.refl (scanEffects info input)
  | some stagesValue =>
      rcases stagesValue with ⟨callee, item, frame, result⟩
      obtain ⟨_, _, _, _, checked, read, aliases, finished, _, _⟩ := callStages_success stages
      have incoming := NativeReads.read_actuals_incoming capacity read
      have same := checkAliases_footprint aliases
      have masks := finishCall_footprint calls text context info kind item frame checked
      rw [← finished] at masks
      have reads := congrArg Prod.fst masks
      have writes := congrArg Prod.snd masks
      have aliasReads := congrArg Prod.fst same
      have aliasWrites := congrArg Prod.snd same
      dsimp only [footprint] at reads writes aliasReads aliasWrites
      simp only [packageCallAt, stages]
      apply mask_included
      · rw [reads, aliasReads]
        exact fun cell member => union_left capacity _ _ cell (incoming.1 cell member)
      · rw [writes, aliasWrites, incoming.2]
        exact union_left capacity _ _

theorem mark_incoming (info : PackageBindings.Metadata) (value : ApplicationScan) (identity : Nat) :
    Included (scanEffects info value)
      (scanEffects info {value with writes := markState value.writes identity}) :=
  ⟨fun _ member => member, marked_mono info value.writes identity⟩

theorem assignment_incoming (calls : BasicCalls) (source : Statement.Input)
    (capacity : source.info.states.length ≤ PackageBindings.maxStates)
    (called : ∀ position kind, Included (scanEffects source.info source.input)
      (scanEffects source.info (calls.packageCallAt source.text source.context source.input source.info position kind).result)) :
    Included (scanEffects source.info source.input)
      (scanEffects source.info (functionAssignment calls source.text source.context source.input source.info
        source.catalog source.procedures)) := by
  let call := calls.packageCallAt source.text source.context source.input source.info
    (assignmentFirst calls source.text source.input) .function
  let result := if call.value.after ≠ 0 then
      let assigned := calls.callAssignmentResult source.context
        {call.result.scan with position := source.input.scan.position}
        (calls.scalarTarget source.text source.context source.input.scan.position)
        (calls.booleanTarget source.text source.context source.input.scan.position) call.value
      {call.result with scan := calls.bodyToken source.text source.context assigned (.symbol ";")}
    else
      let scan := calls.basicBody source.text source.context source.input.scan source.catalog source.procedures
      {source.input with scan, reads := (PackageBindings.stateUnion source.input.reads
        (calls.stateReads source.text source.context source.info
          (assignmentFirst calls source.text source.input) scan.position))}
  have initial : Included (scanEffects source.info source.input) (scanEffects source.info result) := by
    dsimp only [result]
    split
    · exact called _ _
    · exact ⟨union_left capacity _ _, fun _ member => member⟩
  have written := initial.trans
    (mark_incoming source.info result (calls.stateTarget source.text source.context source.info source.input.scan.position))
  change Included _ (scanEffects source.info
    (if calls.stateTarget source.text source.context source.info source.input.scan.position ≠ 0 then
      {result with writes := (result.writes.set
        (calls.stateTarget source.text source.context source.info source.input.scan.position - 1) true)}
    else result))
  by_cases zero : calls.stateTarget source.text source.context source.info source.input.scan.position = 0
  · simpa only [zero, ne_eq, not_true_eq_false, ite_false] using initial
  · simpa only [zero, ne_eq, not_false_eq_true, ite_true, markState, ite_false] using written

/-- The original Basic wrapper never discards an incoming mask bit. The
effect/target callbacks can be arbitrary here; their semantic coverage is
proved separately from source expressions and names. -/
theorem basic_incoming (calls : BasicCalls) (source : Statement.Input)
    (capacity : source.info.states.length ≤ PackageBindings.maxStates)
    (native : calls.packageCallAt = packageCallAt modelCalls) :
    Included (scanEffects source.info source.input)
      (scanEffects source.info (applicationBasic calls source.text source.context source.input source.info
        source.catalog source.procedures)) := by
  have called (position : Nat) (kind : PackageBindings.RoutineKind) :
      Included (scanEffects source.info source.input)
        (scanEffects source.info (calls.packageCallAt source.text source.context source.input source.info position kind).result) := by
    rw [native]
    exact call_incoming _ _ _ _ _ _ _ capacity
  have result : Included (scanEffects source.info source.input)
      (scanEffects source.info (basicResult calls source.text source.context source.input source.info
        source.catalog source.procedures)) := by
    unfold basicResult
    split
    · exact assignment_incoming calls source capacity called
    · split
      · exact called _ _
      · exact Included.refl _
  unfold applicationBasic
  split
  · exact Included.refl _
  · dsimp only
    split
    · exact Included.refl _
    · exact result

theorem then_incoming (calls : Statement.Calls) (source : Statement.Input)
    (state : Statement.Arms) (condition : ConditionResult)
    (capacity : source.info.states.length ≤ PackageBindings.maxStates) :
    Included (scanEffects source.info state.value)
      (scanEffects source.info (Statement.thenInput calls source state condition)) :=
  ⟨union_left capacity _ _, fun _ member => member⟩

theorem arm_masks {calls : Statement.Calls} {source : Statement.Input}
    {read : Statement.ReadArm} {after : Statement.Arms}
    (finished : Statement.armState (Statement.finishArm calls source read) = some after) :
    scanEffects source.info after.value = scanEffects source.info read.branch := by
  unfold Statement.finishArm at finished
  dsimp only at finished
  split at finished
  · simp only [Statement.armState, Option.some.injEq] at finished
    cases finished; rfl
  · split at finished
    · contradiction
    · simp only [Statement.armState, Option.some.injEq] at finished
      cases finished; rfl

theorem header_incoming {calls : Statement.Calls} {source : Statement.Input}
    {afterFor : Nat} {iteration : Statement.Iteration}
    (capacity : source.info.states.length ≤ PackageBindings.maxStates)
    (parsed : Statement.forHeader calls source afterFor = some iteration) :
    Included (scanEffects source.info source.input) (scanEffects source.info iteration.value) := by
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
        · cases parsed; exact Included.refl _
    · cases parsed
      dsimp only [Statement.countedHeader]
      split <;> exact ⟨union_left capacity _ _, fun _ member => member⟩

/-- Every original branch, loop and tail retains the mask accumulated by its
predecessor. This follows from raw native updates alone, independent of any
semantic checker or effect-correspondence premise. -/
theorem tail_incoming {readers : Recursive.Readers} {names source stop required seen result code}
    (original : SourceSyntax.TailCodeAt readers names source stop required seen result code)
    (native : readers.basic.packageCallAt = packageCallAt modelCalls)
    (capacity : source.info.states.length ≤ PackageBindings.maxStates) :
    Included (scanEffects source.info source.input) (scanEffects source.info result) := by
  apply SourceSyntax.TailCodeAt.rec
    (motive_1 := fun source result _ _ => source.info.states.length ≤ PackageBindings.maxStates →
      Included (scanEffects source.info source.input) (scanEffects source.info result))
    (motive_2 := fun source before after _ _ => source.info.states.length ≤ PackageBindings.maxStates →
      Included (scanEffects source.info before.value) (scanEffects source.info after.value))
    (motive_3 := fun source state _ _ => source.info.states.length ≤ PackageBindings.maxStates →
      Included (scanEffects source.info state.value)
        (scanEffects source.info (Statement.elseResult readers.statement source state)))
    (motive_4 := fun source _ _ _ result _ _ => source.info.states.length ≤ PackageBindings.maxStates →
      Included (scanEffects source.info source.input) (scanEffects source.info result))
    ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ original capacity
  · intro source result item _ _ _ _ _ reading capacity
    cases reading with
    | inherited _ returned _ | functionCall _ _ returned _ | procedureCall _ _ returned _ =>
      rw [← returned]
      exact basic_incoming readers.basic source capacity native
  · intro source state result codes alternative _ _ _ _ closing armsIH elseIH capacity
    rw [closing.resultEq]
    exact (armsIH capacity).trans (elseIH capacity)
  · intro source iteration result lower upper body _ _ _ header _ _ _ insideIH capacity
    rw [header.resultEq]
    exact (header_incoming capacity header.header).trans (insideIH capacity)
  · intro source iteration result body _ _ _ header _ _ insideIH capacity
    rw [header.resultEq]
    exact (header_incoming capacity header.header).trans (insideIH capacity)
  · intro source before read after condition body _ _ _ finished insideIH capacity
    have same := arm_masks (show Statement.armState (Statement.finishArm readers.statement source read) = some after by
      rw [finished]; rfl)
    rw [same]
    exact (then_incoming readers.statement source before _ capacity).trans (insideIH capacity)
  · intro source before read after final condition body rest _ _ _ continued _ insideIH restIH capacity
    have same := arm_masks (show Statement.armState (Statement.finishArm readers.statement source read) = some after by
      rw [continued]; rfl)
    have first := (then_incoming readers.statement source before _ capacity).trans (insideIH capacity)
    change Included (scanEffects source.info before.value) (scanEffects source.info read.branch) at first
    rw [← same] at first
    exact first.trans (restIH capacity)
  · intro source state missing capacity
    simp only [Statement.elseResult, missing, ne_eq, not_true_eq_false, ite_false]
    exact Included.refl _
  · intro source state body _ _ insideIH capacity
    exact insideIH capacity
  · intro source stop required seen _ _ _ capacity
    exact Included.refl _
  · intro source stop required seen first result head rest _ _ _ _ _ _ headIH restIH capacity
    exact (headIH capacity).trans (restIH capacity)

end NativeMasks

end Silver.ApplicationPackageSourceEffects
