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

end Silver.ApplicationPackageFrameLayout
