module

public import Silver.ApplicationPackageLayoutEffects
public import Silver.ApplicationPackageVisibleStateLayout
public import Silver.PredicateFunctionCallMeaning

@[expose] public section

/-! Source expression effects are included in the native mask. Lexical
scanning may conservatively include more cells, and list order is immaterial. -/
namespace Silver.ApplicationPackageSourceEffects
open Compose Predicate Packages ApplicationPackageFrameLayout ApplicationPackageEffects

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

end Silver.ApplicationPackageSourceEffects
