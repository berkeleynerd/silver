module

public import Silver.ApplicationPackageImportMeaning

@[expose] public section

namespace Silver.ApplicationPackageImport
open Compose Compose.Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem innerLoop_meaning (calls : ApplicationPackageNames.Native.Calls)
    (primitives : ApplicationPackageNames.Native.PrimitiveMeaning calls)
    (normalize : Source → Source) (text : Source) (valid : ValidText text)
    (withClause : Bool) (fuel : Nat) (cursor : Model.Cursor) (cursorValid : cursor.Valid text) :
    Model.innerLoop (fromNames calls normalize) text withClause fuel cursor =
      Model.innerLoop modelCalls text withClause fuel cursor := by
  induction fuel generalizing cursor with
  | zero => rfl
  | succ fuel ih =>
      rw [Model.innerLoop, innerStep_meaning calls primitives normalize text valid withClause cursor cursorValid.2.1]
      have progress := Model.innerStep_advances text withClause cursor cursorValid
      cases step : Model.innerStep modelCalls text withClause cursor with
      | reject => simp only [Model.innerLoop, step]
      | done final => simp only [Model.innerLoop, step]
      | next next =>
          rw [step] at progress
          simp only [Model.innerLoop, step]
          exact ih next progress.2

theorem outerStep_meaning (calls : ApplicationPackageNames.Native.Calls)
    (primitives : ApplicationPackageNames.Native.PrimitiveMeaning calls)
    (normalize : Source → Source) (text : Source) (valid : ValidText text)
    (fuel : Nat) (cursor : Model.Cursor) (cursorValid : cursor.Valid text) :
    Model.outerStep (fromNames calls normalize) text fuel cursor =
      Model.outerStep modelCalls text fuel cursor := by
  unfold Model.outerStep
  dsimp +instances only [fromNames, modelCalls, ApplicationPackageNames.Native.modelCalls]
  rw [primitives.skip text valid _ cursorValid.2.1,
    primitives.nameAfter text valid _ (model_skip_valid text _ cursorValid.2.1)]
  by_cases firstPositive : 0 < skipAt text cursor.position
  · by_cases afterGreater : skipAt text cursor.position < nameAfter text (skipAt text cursor.position)
    · have name : ValidName text (skipAt text cursor.position) (nameAfter text (skipAt text cursor.position)) :=
        ⟨firstPositive, afterGreater, model_name_valid text _⟩
      rw [primitives.nameIs text valid _ _ "with" name (by decide) (by decide),
        primitives.nameIs text valid _ _ "use" name (by decide) (by decide)]
      have innerValid : (⟨nameAfter text (skipAt text cursor.position), cursor.candidate⟩ : Model.Cursor).Valid text :=
        ⟨by change 0 < nameAfter text (skipAt text cursor.position); omega, name.2.2, cursorValid.2.2⟩
      have same (withClause : Bool) := innerLoop_meaning calls primitives normalize text valid withClause fuel _ innerValid
      dsimp +instances only [fromNames, modelCalls, ApplicationPackageNames.Native.modelCalls] at same
      rw [same]
    · simp only [afterGreater, decide_false, Bool.and_false, Bool.false_and, Bool.not_false, Bool.and_self, ↓reduceIte]
  · simp only [firstPositive, decide_false, Bool.false_and, Bool.not_false, Bool.and_self, ↓reduceIte]

namespace Model

def Step.OuterValid (text : Source) (before : Cursor) : Step → Prop
  | .reject => True
  | .done after => after.Valid text
  | .next after => before.position < after.position ∧ after.Valid text

theorem outerStep_total (text : Source) (innerFuel : Nat) (cursor : Cursor)
    (valid : cursor.Valid text) (enough : text.length + 2 ≤ innerFuel) :
    ∃ result, outerStep modelCalls text innerFuel cursor = some result ∧ result.OuterValid text cursor := by
  unfold outerStep
  dsimp +instances only [modelCalls, fromNames, ApplicationPackageNames.Native.modelCalls]
  split
  · exact ⟨.done cursor, rfl, valid⟩
  · rename_i selected
    have positive : 0 < skipAt text cursor.position := by
      by_cases present : 0 < skipAt text cursor.position
      · exact present
      · simp only [present, decide_false, Bool.false_and, Bool.not_false, Bool.and_self] at selected
        contradiction
    have advanced : skipAt text cursor.position < nameAfter text (skipAt text cursor.position) := by
      by_cases present : skipAt text cursor.position < nameAfter text (skipAt text cursor.position)
      · exact present
      · simp only [present, decide_false, Bool.and_false, Bool.false_and, Bool.not_false, Bool.and_self] at selected
        contradiction
    have bound := model_name_valid text (skipAt text cursor.position)
    have first := skipAt_advances text cursor.position valid.2.1 (by omega)
    have innerValid : (⟨nameAfter text (skipAt text cursor.position), cursor.candidate⟩ : Cursor).Valid text :=
      ⟨by change 0 < nameAfter text (skipAt text cursor.position); omega, bound, valid.2.2⟩
    obtain ⟨result, finished, resultValid⟩ := innerLoop_total text _ innerFuel _ innerValid (by omega)
    dsimp +instances only [modelCalls, fromNames, ApplicationPackageNames.Native.modelCalls] at finished
    rw [finished]
    cases result with
    | error _ => exact ⟨.reject, rfl, trivial⟩
    | ok final =>
        have finalValid := resultValid final rfl
        refine ⟨.next final, rfl, ?_, finalValid.2⟩
        have beyond : nameAfter text (skipAt text cursor.position) < final.position := finalValid.1
        omega

theorem outerLoop_total (text : Source) (innerFuel fuel : Nat) (cursor : Cursor)
    (valid : cursor.Valid text) (enoughInner : text.length + 2 ≤ innerFuel)
    (enough : text.length + 2 - cursor.position ≤ fuel) :
    ∃ result, outerLoop modelCalls text innerFuel fuel cursor = some result ∧
      ∀ final, result = .ok final → final.Valid text := by
  induction fuel generalizing cursor with
  | zero =>
      have bound : cursor.position ≤ text.length + 1 := valid.2.1
      omega
  | succ fuel ih =>
      obtain ⟨step, finished, resultValid⟩ := outerStep_total text innerFuel cursor valid enoughInner
      rw [outerLoop, finished]
      cases step with
      | reject => exact ⟨.error (), rfl, by intros; contradiction⟩
      | done final => exact ⟨.ok final, rfl, by intro value same; cases same; exact resultValid⟩
      | next next =>
          have advances : cursor.position < next.position := resultValid.1
          exact ih next resultValid.2 (by omega)

end Model
end Silver.ApplicationPackageImport
