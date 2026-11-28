module

public import Silver.ApplicationPackageMainDeclarationOrigins
public import Silver.ApplicationPackageMainDeclarationComposition

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageObjectRows

private theorem context_tail_after (text : Source) (state : Names.State) (first last : Nat)
    (present : (Names.contextTail text state first last).after ≠ 0) :
    state.context.after ≤ (Names.contextTail text state first last).after := by
  rw [Names.contextTail] at present ⊢
  split at present
  · rename_i bounded
    rw [dite_eq_left bounded]
    split at present
    · exact False.elim (present rfl)
    · rename_i nonzero
      rw [ite_eq_right nonzero]
      split at present
      · rename_i complete
        rw [ite_eq_left complete]
        exact Nat.le_refl _
      · rename_i active
        rw [ite_eq_right active]
        dsimp only at present ⊢
        split at present
        · exact False.elim (present rfl)
        · rename_i live
          rw [ite_eq_right live]
          exact Nat.le_trans ((Names.contextStep_progress text state first last bounded).2.resolve_left live).1
            (context_tail_after text _ first last present)
  · exact False.elim (present rfl)
termination_by 2 * (text.length + 1 - state.context.after) + (if state.complete then 0 else 1)
decreasing_by
  have progress := Names.contextStep_progress text state first last (by assumption)
  rcases progress.2 with zero | ⟨monotone, complete | advancing⟩
  all_goals cases finished : (Names.contextStep text state first last).complete <;> simp_all +zetaDelta <;> omega

theorem context_after {text : Source} {position first last : Nat}
    (present : (Names.readContext text position first last).after ≠ 0) :
    position ≤ (Names.readContext text position first last).after :=
  context_tail_after text _ first last present

private theorem pragma_after {text : Source} {position : Nat}
    (present : sparkPragmaAfter text position ≠ 0) : position < sparkPragmaAfter text position := by
  unfold sparkPragmaAfter at present ⊢
  have last := fixed_window (by decide) present
  have five := fixed_window (by decide) (fixedAfter_nonzero present)
  have four := fixed_window (by decide) (fixedAfter_nonzero (fixedAfter_nonzero present))
  have three := fixed_window (by decide) (fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero present)))
  have two := fixed_window (by decide) (fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero present))))
  have one := fixed_window (by decide) (fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero present)))))
  omega

attribute [local irreducible] Names.readContext fixedAfter sparkPragmaAfter

/-- Every original context clause and fixed Main header token advances from
the packed Main unit's first byte. No semantic body check supplies this bound. -/
theorem main_start_after (other : Calls) (sources : ApplicationUnits.Bundle) (info : PackageBindings.Metadata)
    (present : mainStart (DeclarationLibraries.model other) sources info ≠ 0) :
    (sources.units .mainBody).first < mainStart (DeclarationLibraries.model other) sources info := by
  let text := textOf sources
  let context := Names.readContext text (sources.units .mainBody).first info.nameFirst info.nameAfter
  let header := fixedAfter text (fixedAfter text (fixedAfter text context.after "procedure" true) "main" true) "is" true
  change sparkPragmaAfter text header ≠ 0 at present
  have headerPresent : header ≠ 0 := by
    intro zero
    simp only [zero, sparkPragmaAfter, fixedAfter] at present
    contradiction
  have last := fixed_window (by decide) headerPresent
  have second := fixed_window (by decide) (fixedAfter_nonzero headerPresent)
  have first := fixed_window (by decide) (fixedAfter_nonzero (fixedAfter_nonzero headerPresent))
  have contextPresent := fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero headerPresent))
  have contextAfter := context_after contextPresent
  have pragma := pragma_after present
  change (sources.units .mainBody).first < sparkPragmaAfter text header
  exact Nat.lt_trans (Nat.lt_of_le_of_lt contextAfter
    (Nat.lt_trans first.1 (Nat.lt_trans second.1 last.1))) pragma

private theorem argument_default_after {text : Source} {state : ParserState}
    (bounded : state.position ≤ text.length + 1)
    (present : argumentDefaultPosition text state ≠ 0) :
    state.position < argumentDefaultPosition text state := by
  let named := argumentAfter text state
  let start := fixedAfter text (fixedAfter text (fixedAfter text (fixedAfter text named ":" false)
    "constant" true) "string" true) ":=" false
  let hidden := (decide (argumentFirst text state ≠ 0) && decide (argumentAfter text state > argumentFirst text state)) &&
    decide (fixedAfter text (argumentFirst text state) "first_or_default" true = argumentAfter text state)
  let operation := Names.operationAfter text start .argument hidden state.contextFirst state.packageFirst state.packageAfter
  let opening := fixedAfter text operation "(" false
  change skipAt text (Names.associationAfter text opening true) ≠ 0 at present
  have openingPresent : opening ≠ 0 := by
    intro zero
    simp only [zero, Names.associationAfter_zero, skipAt, ite_true, ne_eq, not_true_eq_false] at present
  have operationPresent : operation ≠ 0 := fixedAfter_nonzero openingPresent
  have startPresent : start ≠ 0 := by
    intro zero
    change Names.operationAfter text start .argument hidden state.contextFirst state.packageFirst state.packageAfter ≠ 0 at operationPresent
    simp only [zero, Names.operationAfter_zero, ne_eq, not_true_eq_false] at operationPresent
  have startBound : start ≤ text.length + 1 := fixedAfter_result_bound text _ ":=" false (by decide)
  have operationAfter := Names.operationAfter_progress text start .argument hidden
    state.contextFirst state.packageFirst state.packageAfter startBound operationPresent
  have opened := fixed_window (by decide) openingPresent
  have associated := Names.associationAfter_range text opening true opened.2
  have skipped := skipAt_advances text _ associated.2 present
  have four := fixed_window (by decide) startPresent
  have three := fixed_window (by decide) (fixedAfter_nonzero startPresent)
  have two := fixed_window (by decide) (fixedAfter_nonzero (fixedAfter_nonzero startPresent))
  have one := fixed_window (by decide) (fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero startPresent)))
  have namedPresent : named ≠ 0 := fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero (fixedAfter_nonzero startPresent)))
  have namedAfter := model_name_advances text (argumentFirst text state) namedPresent
  have firstAfter := skipAt_advances text state.position bounded (Nat.ne_of_gt namedAfter.1)
  change state.position < skipAt text (Names.associationAfter text opening true)
  change state.position ≤ argumentFirst text state at firstAfter
  have namedAdvance : argumentFirst text state < named := namedAfter.2
  omega

private theorem literal_start {text fallback : Source} {position : Nat} {result : ValueResult}
    (read : LiteralReading text position fallback result) : position ≠ 0 := by
  cases read
  assumption

theorem argument_after {text fallback : Source} {before after : ParserState}
    (bounded : before.position ≤ text.length + 1) (read : ArgumentAt text before fallback after) :
    before.position < after.position := by
  cases read with
  | @argument parts _ partsEq allowed following empty reading =>
    have initial : argumentDefaultPosition text before ≠ 0 := literal_start reading
    have initialAfter := argument_default_after bounded initial
    have followingEq := argumentParts_following text before
    rw [partsEq] at followingEq
    have finished := followingEq ▸ following
    have close := fixed_window (by decide) (fixedAfter_nonzero finished)
    have final := fixed_window (by decide) finished
    have literalPresent : (literalAt text (argumentDefaultPosition text before)).after ≠ 0 := by
      rw [literalReading_complete reading]
      exact fixedAfter_nonzero (fixedAfter_nonzero finished)
    have literalAfter := literalAt_advances text _ literalPresent
    rw [literalReading_complete reading] at literalAfter
    change before.position < parts.following
    omega

private theorem declarations_loop_after (text : Source) (textValid : ValidText text) (arguments : Bool)
    (fuel : Nat) (state : ParserState) (valid : ValidState text state)
    (present : (declarationsLoop text arguments fuel state).position ≠ 0) :
    state.position ≤ (declarationsLoop text arguments fuel state).position := by
  induction fuel generalizing state with
  | zero => exact False.elim (present rfl)
  | succ fuel ih =>
    rw [declarationsLoop] at present ⊢
    split at present
    · exact False.elim (present rfl)
    · rename_i nonzero
      rw [ite_eq_right nonzero]
      split at present
      · rename_i endSeen
        rw [ite_eq_left endSeen]
        exact Nat.le_refl _
      · rename_i pending
        rw [ite_eq_right pending]
        split at present
        · exact False.elim (present rfl)
        · rename_i declared
          rw [ite_eq_right declared]
          exact Nat.le_trans (Nat.le_of_lt (model_declaration_advances text textValid state arguments valid declared))
            (ih _ (model_declaration_valid text textValid state arguments valid) present)

theorem declarations_after {text : Source} {arguments : Bool} {state : ParserState}
    (textValid : ValidText text) (valid : ValidState text state)
    (present : (declarationsAt text state arguments).position ≠ 0) :
    state.position ≤ (declarationsAt text state arguments).position :=
  declarations_loop_after text textValid arguments _ state valid present

end Silver.ApplicationPackageMain
