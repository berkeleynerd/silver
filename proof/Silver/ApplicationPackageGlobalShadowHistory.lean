module

public import Silver.ApplicationPackageVisibleStateLayout

@[expose] public section

/-! Retained global rows cannot be shadowed by later bare rows. This narrow
history invariant allows arbitrary duplicates among unrelated local rows. -/
namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages ApplicationPackageEffects ApplicationPackageObjectRows
open ApplicationPackageDeclarations ApplicationPackageBodies ApplicationPackageFrames

set_option backward.dsimp.instances true

def GlobalRow (states : List PackageBindings.StateDeclaration) (row : Row) : Prop :=
  ∃ state ∈ states, row.first = state.name.first

def GlobalRowsClear (text : Source) (states : List PackageBindings.StateDeclaration)
    (rows : List Row) : Prop :=
  rows.Pairwise fun older newer => GlobalRow states older → older.qualifierFirst = 0 →
    newer.qualifierFirst = 0 →
    Named.equalName text older.first older.after newer.first newer.after = false

def GlobalRowsApart (text : Source) (states : List PackageBindings.StateDeclaration)
    (rows : List Row) (names : List PackageBindings.NameSpan) : Prop :=
  ∀ row ∈ rows, GlobalRow states row → row.qualifierFirst = 0 → ∀ name ∈ names,
    Named.equalName text row.first row.after name.first name.after = false

theorem GlobalRowsClear.emptyStates (text : Source) (rows : List Row) : GlobalRowsClear text [] rows := by
  apply List.pairwise_iff_getElem.mpr
  intro i j _ _ _ global
  obtain ⟨state, member, _⟩ := global
  contradiction

theorem GlobalRowsClear.retain {text states before after}
    (prior : GlobalRowsClear text states before) (kept : after.Sublist before) :
    GlobalRowsClear text states after := prior.sublist kept

theorem GlobalRowsApart.retain {text states before after names}
    (prior : GlobalRowsApart text states before names) (kept : after.Sublist before) :
    GlobalRowsApart text states after names :=
  fun row member => prior row (kept.subset member)

theorem GlobalRowsClear.append {text states before added}
    (prior : GlobalRowsClear text states before)
    (localRows : ∀ row ∈ added, ¬GlobalRow states row)
    (apart : ∀ old ∈ before, GlobalRow states old → old.qualifierFirst = 0 →
      ∀ new ∈ added, new.qualifierFirst = 0 →
      Named.equalName text old.first old.after new.first new.after = false) :
    GlobalRowsClear text states (before ++ added) := by
  apply List.pairwise_append.mpr
  refine ⟨prior, ?_, ?_⟩
  · apply List.pairwise_iff_getElem.mpr
    intro i j hi _ _ global
    exact False.elim (localRows _ (List.getElem_mem hi) global)
  · intro old previous new installed global bare bareNew
    exact apart old previous global bare new installed bareNew

theorem GlobalRowsApart.append {text states before added names}
    (prior : GlobalRowsApart text states before names)
    (localRows : ∀ row ∈ added, ¬GlobalRow states row) :
    GlobalRowsApart text states (before ++ added) names := by
  intro row member global bare name selected
  rcases List.mem_append.mp member with old | new
  · exact prior row old global bare name selected
  · exact False.elim (localRows row new global)

theorem hideEntries_unselected {α : Type} {selected outer : α → Bool} {before after : List α}
    (checked : hideEntries selected outer before = some after) :
    ∀ row ∈ after, selected row = false := by
  induction before generalizing after with
  | nil => cases Option.some.inj checked; simp
  | cons item rest ih =>
    simp only [hideEntries] at checked
    split at checked
    · split at checked
      · exact ih checked
      · contradiction
    · rename_i absent
      obtain ⟨kept, next, rfl⟩ := Option.map_eq_some_iff.mp checked
      intro row member
      rcases List.mem_cons.mp member with same | later
      · subst row
        exact Bool.eq_false_iff.mpr absent
      · exact ih next row later

theorem hideOuter_scalar_unselected {text : Source} {frame : ParserState} {info : PackageBindings.Metadata}
    {name : PackageBindings.NameSpan} (accepted : (hideOuter text frame info name).position ≠ 0) :
    ∀ row ∈ (hideOuter text frame info name).scalarNames, scalarMatches text name row = false := by
  unfold hideOuter at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i allowed
    simp only [allowed]
    cases scalars : hideEntries (scalarMatches text name)
      (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first,item.after⟩) frame.scalarNames with
    | none => simp [scalars, invalidState] at accepted
    | some scalarRows =>
      cases booleans : hideEntries (booleanMatches text name)
        (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first,item.after⟩) frame.booleanNames with
      | none => simp [scalars, booleans, invalidState] at accepted
      | some booleanRows =>
        cases subtypes : hideEntries (subtypeMatches text name)
          (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first,item.after⟩) frame.subtypeNames.items with
        | none => simp [scalars, booleans, subtypes, invalidState] at accepted
        | some subtypeRows =>
          simp only [scalars, booleans, subtypes, Option.bind_some, pure, bind] at accepted ⊢
          split at accepted
          · rename_i checked
            simp only [ite_eq_left checked]
            exact hideEntries_unselected scalars
          · exact False.elim (accepted rfl)

theorem equalName_false_symm {text : Source} {a b c d : Nat}
    (different : Named.equalName text a b c d = false) : Named.equalName text c d a b = false := by
  apply Bool.eq_false_iff.mpr
  intro same
  have symmetric := equalName_symm same
  rw [different] at symmetric
  contradiction

theorem hideOuter_scalar_apart {text : Source} {frame : ParserState} {info : PackageBindings.Metadata}
    {name : PackageBindings.NameSpan} (accepted : (hideOuter text frame info name).position ≠ 0)
    {row : Row} (member : row ∈ integerRows (hideOuter text frame info name)) (bare : row.qualifierFirst = 0) :
    Named.equalName text row.first row.after name.first name.after = false := by
  obtain ⟨original, stored, rfl⟩ := List.mem_map.mp member
  change original.qualifierFirst = 0 at bare
  have apart := hideOuter_scalar_unselected accepted original stored
  simp only [scalarMatches, bare, decide_true, Bool.true_and] at apart
  exact equalName_false_symm apart

theorem scalarLookupFrom_zero_apart {text : Source} {names : ScalarExpression.Environment}
    {first after count index : Nat}
    (missing : ScalarExpression.lookupFrom text names first after count = 0)
    (positive : first ≠ 0) (ordered : first < after) (indexPositive : 0 < index) (active : index ≤ count)
    (bare : (ScalarExpression.binding names index).qualifierFirst = 0) :
    Named.equalName text (ScalarExpression.binding names index).first
      (ScalarExpression.binding names index).after first after = false := by
  induction count with
  | zero => omega
  | succ count ih =>
    simp only [ScalarExpression.lookupFrom, positive, Nat.not_le.mpr ordered, or_self, ite_false] at missing
    split at missing
    · omega
    · rename_i absent
      by_cases last : index = count + 1
      · subst index
        simpa only [QualifiedNames.qualifierMatches, ite_true, bare, beq_self_eq_true, Bool.and_true] using
          Bool.eq_false_iff.mpr absent
      · exact ih missing (by omega)

theorem scalarLookup_selected {text : Source} {names : ScalarExpression.Environment}
    {first after slot : Nat} (positive : first ≠ 0) (ordered : first < after)
    (slotPositive : 0 < slot) (active : slot ≤ names.length)
    (matching : (Named.equalName text (ScalarExpression.binding names slot).first
      (ScalarExpression.binding names slot).after first after &&
      QualifiedNames.qualifierMatches text (ScalarExpression.binding names slot).qualifierFirst
        (ScalarExpression.binding names slot).qualifierAfter 0 0) = true)
    (later : ∀ index, slot < index → index ≤ names.length →
      (Named.equalName text (ScalarExpression.binding names index).first
        (ScalarExpression.binding names index).after first after &&
        QualifiedNames.qualifierMatches text (ScalarExpression.binding names index).qualifierFirst
          (ScalarExpression.binding names index).qualifierAfter 0 0) = false) :
    ScalarExpression.lookup text names first after = slot := by
  have scan (count : Nat) (inside : slot ≤ count) (bounded : count ≤ names.length) :
      ScalarExpression.lookupFrom text names first after count = slot := by
    induction count with
    | zero => omega
    | succ count ih =>
      simp only [ScalarExpression.lookupFrom, positive, Nat.not_le.mpr ordered, or_self, ite_false]
      by_cases same : slot = count + 1
      · rw [← same, matching]
        rfl
      · rw [later (count + 1) (by omega) bounded]
        exact ih (by omega) (by omega)
  exact scan names.length active (Nat.le_refl _)

theorem GlobalRowsClear.integer_lookup {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {slot identity bound : Nat}
    (clear : GlobalRowsClear text info.states (scalarRows context))
    (source : StateDeclarations text info.states)
    (selected : (layout bound info context).integers slot = .global identity) :
    ScalarExpression.lookup text context.scalarNames
      (info.stateAt identity).name.first (info.stateAt identity).name.after = slot := by
  have live := slotAddress_global selected
  have state := stateIndex_some live.2.2
  rw [scalarRows_get] at state
  dsimp only at state
  have bounded : slot ≤ context.scalarNames.length := by
    simpa only [scalarRows, List.length_map] using live.2.1
  have domain := (ApplicationPackageNames.Native.validName_domain (source.name state.1 state.2.1)).2
  apply scalarLookup_selected (Nat.ne_of_gt domain.1) domain.2.1 live.1 bounded
  · simp [state.2.2.1, state.2.2.2.2.1.symm, state.2.2.2.2.2.symm,
      Named.equalName, QualifiedNames.qualifierMatches]
  · intro index newer within
    by_cases bare : (ScalarExpression.binding context.scalarNames index).qualifierFirst = 0
    · have oldIndex : slot - 1 < context.scalarNames.length := by omega
      have newIndex : index - 1 < context.scalarNames.length := by omega
      have pairwise := (List.pairwise_map.mp clear)
      have apart := pairwise.rel_getElem_of_lt oldIndex newIndex (by omega : slot - 1 < index - 1)
      have names : Named.equalName text (ScalarExpression.binding context.scalarNames slot).first
          (ScalarExpression.binding context.scalarNames slot).after
          (ScalarExpression.binding context.scalarNames index).first
          (ScalarExpression.binding context.scalarNames index).after = false := by
        apply (show GlobalRow info.states
            ⟨(ScalarExpression.binding context.scalarNames slot).first,
              (ScalarExpression.binding context.scalarNames slot).after,
              (ScalarExpression.binding context.scalarNames slot).qualifierFirst,
              (ScalarExpression.binding context.scalarNames slot).qualifierAfter⟩ →
            (ScalarExpression.binding context.scalarNames slot).qualifierFirst = 0 →
            (ScalarExpression.binding context.scalarNames index).qualifierFirst = 0 → _ from by
          simpa only [ScalarExpression.binding, List.getD_eq_getElem?_getD,
            List.getElem?_eq_getElem oldIndex, List.getElem?_eq_getElem newIndex, Option.getD_some] using apart)
        · exact ⟨info.stateAt identity, info.stateAt_mem identity state.1 state.2.1,
            state.2.2.2.2.1.symm⟩
        · exact state.2.2.1
        · exact bare
      rw [← state.2.2.2.2.1, ← state.2.2.2.2.2] at names
      simp only [equalName_false_symm names, Bool.false_and]
    · simp only [QualifiedNames.qualifierMatches, ite_true, beq_eq_false_iff_ne.mpr bare,
        Bool.and_false]

theorem GlobalRowsClear.integer_visible {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {slot identity bound : Nat}
    (clear : GlobalRowsClear text info.states (scalarRows context))
    (source : StateDeclarations text info.states)
    (selected : (layout bound info context).integers slot = .global identity) :
    visibleState ApplicationPackageEffects.modelCalls text context info identity = true := by
  have live := slotAddress_global selected
  have state := stateIndex_some live.2.2
  rw [scalarRows_get] at state
  dsimp only at state
  have found := clear.integer_lookup source selected
  simp [visibleState, ApplicationPackageEffects.modelCalls, Nat.not_lt.mpr state.2.1,
    source.name state.1 state.2.1, state.2.2.2.1, found, Nat.ne_of_gt live.1,
    state.2.2.2.2.1.symm, state.2.2.2.2.2.symm]

theorem resetSlots_global_iff {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet} {bound slot : Nat}
    (source : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (scalarRows context)) :
    slot ∈ ApplicationPackageCalls.resetSlots ApplicationPackageCalls.modelCalls text context info writes
      ((List.range info.states.length).map (· + 1)) ↔
    ∃ identity, (layout bound info context).integers slot = .global identity ∧
      ScalarProcedures.Cell.integer identity ∈ info.effectCells writes := by
  unfold ApplicationPackageCalls.resetSlots
  constructor
  · intro member
    obtain ⟨index, present, found⟩ := List.mem_filterMap.mp member
    obtain ⟨offset, active, rfl⟩ := List.mem_map.mp present
    have bounded := List.mem_range.mp active
    dsimp only at found
    split at found
    · rename_i chosen
      cases found
      have global := visible_integer_global source (by omega : 0 < offset + 1) chosen.2.1 chosen.2.2 (bound := bound)
      refine ⟨offset + 1, global, ?_⟩
      have written := (PackageBindings.Metadata.effectCells_index
        (by omega : 0 < offset + 1) (by omega : offset + 1 ≤ info.states.length)).mpr chosen.1
      simpa only [PackageBindings.StateDeclaration.cell, chosen.2.2] using written
    · contradiction
  · rintro ⟨identity, global, written⟩
    have state := stateIndex_some (slotAddress_global global).2.2
    have selected : PackageBindings.StateSet.get writes identity = true :=
      (PackageBindings.Metadata.effectCells_index state.1 state.2.1).mp
        (by simpa only [PackageBindings.StateDeclaration.cell, state.2.2.2.1] using written)
    have visible := clear.integer_visible source global
    have lookup := clear.integer_lookup source global
    apply List.mem_filterMap.mpr
    refine ⟨identity, ?_, ?_⟩
    · exact List.mem_map.mpr ⟨identity - 1, List.mem_range.mpr (by omega), Nat.sub_add_cancel state.1⟩
    · simp only [ApplicationPackageCalls.modelCalls, selected, visible, state.2.2.2.1,
        and_self, ite_true, lookup]

theorem resetSlots_declared {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet} {bound slot : Nat}
    (source : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (scalarRows context))
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (fields : ScalarStateFields info.states context.scalarNames)
    (selected : slot ∈ ApplicationPackageCalls.resetSlots ApplicationPackageCalls.modelCalls text context info writes
      ((List.range info.states.length).map (· + 1))) :
    context.analysis.declared slot = some (ScalarExpression.binding context.scalarNames slot).declaredBounds := by
  obtain ⟨identity, global, _⟩ := (resetSlots_global_iff source clear (bound := bound)).mp selected
  have rows := fields.globalRows (bound := bound)
  have declared := (scalar_global_analysis capacity ready rows global).1
  rw [← (rows slot identity global).1] at declared
  exact declared

theorem resetSlotsFlow_source {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet} (bound : Nat)
    (source : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (scalarRows context))
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (fields : ScalarStateFields info.states context.scalarNames) (flow : Flow) :
    ApplicationPackageCalls.resetSlotsFlow context.scalarNames
      (ApplicationPackageCalls.resetSlots ApplicationPackageCalls.modelCalls text context info writes
        ((List.range info.states.length).map (· + 1))) flow =
      resetGlobalFlow context.analysis.declared (layout bound info context) (info.effectCells writes) flow :=
  ApplicationPackageCalls.resetSlotsFlow_global
    (fun _ => resetSlots_global_iff source clear)
    (fun _ selected => resetSlots_declared source clear capacity ready fields selected (bound := bound)) flow

end Silver.ApplicationPackageFrameLayout
