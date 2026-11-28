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

end Silver.ApplicationPackageSourceEffects
