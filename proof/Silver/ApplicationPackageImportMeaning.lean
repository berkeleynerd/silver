module

public import Silver.ApplicationPackageImportInterpretation
public import Silver.ApplicationPackageNamesMeaning

@[expose] public section

namespace Silver.ApplicationPackageImport
open Compose Compose.Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- The scanner uses the already interpreted lexical/package callees. The
normalizer has the native identity postcondition on its bounded input. -/
def fromNames (calls : ApplicationPackageNames.Native.Calls)
    (normalize : Source → Source) : Native.Calls where
  normalize := normalize
  skip := calls.skip
  nameAfter := calls.nameAfter
  take := calls.takeToken
  nameIs := calls.nameIs
  validName := calls.validName
  sameName := calls.sameName

def modelCalls : Native.Calls where
  normalize := id
  skip := skipAt
  nameAfter := nameAfter
  take := tokenAfter
  nameIs text first after word := Named.nameIs text first after (word.toList.map Char.toNat)
  validName text name := PackageBindings.validName (ApplicationPackageNames.metadataText text) name
  sameName text left right := PackageBindings.sameName (ApplicationPackageNames.metadataText text) left right

theorem innerStep_meaning (calls : ApplicationPackageNames.Native.Calls)
    (primitives : ApplicationPackageNames.Native.PrimitiveMeaning calls)
    (normalize : Source → Source) (text : Source) (valid : ValidText text)
    (withClause : Bool) (cursor : Model.Cursor) (bound : ValidCursor text cursor.position) :
    Model.innerStep (fromNames calls normalize) text withClause cursor =
      Model.innerStep modelCalls text withClause cursor := by
  unfold Model.innerStep
  dsimp +instances only [fromNames, modelCalls, ApplicationPackageNames.Native.modelCalls]
  rw [primitives.skip text valid _ bound,
    primitives.nameAfter text valid _ (model_skip_valid text _ bound)]
  have afterBound := model_name_valid text (skipAt text cursor.position)
  rw [primitives.takeToken text valid _ (.symbol ",") afterBound (by unfold ValidToken allTokens; decide +kernel),
    primitives.takeToken text valid _ (.symbol ";") afterBound (by unfold ValidToken allTokens; decide +kernel),
    primitives.validName]
  by_cases accepted : PackageBindings.validName (ApplicationPackageNames.metadataText text)
      ⟨skipAt text cursor.position, nameAfter text (skipAt text cursor.position)⟩ = true
  · have name := (ApplicationPackageNames.Native.validName_domain accepted).2
    rw [primitives.nameIs text valid _ _ "silver_io" name (by decide) (by decide),
      primitives.nameIs text valid _ _ "silver_arguments" name (by decide) (by decide)]
    simp only [primitives.sameName, spelling, isWord, ShellToken.symbol, tokenAfter]
    rfl
  · simp only [Bool.eq_false_iff.mpr accepted, Bool.not_false, Bool.true_or, ↓reduceIte]

namespace Model

/-- Exactly the native loop invariant: bounded cursor and an absent or valid
candidate span. It does not assume that scanning eventually succeeds. -/
def Cursor.Valid (text : Source) (cursor : Cursor) : Prop :=
  0 < cursor.position ∧ ValidCursor text cursor.position ∧
    (cursor.candidate.first = 0 ∨
      PackageBindings.validName (ApplicationPackageNames.metadataText text) cursor.candidate = true)

def Step.Advances (text : Source) (before : Cursor) : Step → Prop
  | .reject => True
  | .next after | .done after => before.position < after.position ∧ after.Valid text

theorem innerStep_advances (text : Source) (withClause : Bool) (cursor : Cursor)
    (valid : cursor.Valid text) :
    Step.Advances text cursor (innerStep modelCalls text withClause cursor) := by
  dsimp +instances only [innerStep, modelCalls]
  split
  · trivial
  · rename_i accepted
    have nameOk : PackageBindings.validName (ApplicationPackageNames.metadataText text)
        ⟨skipAt text cursor.position, nameAfter text (skipAt text cursor.position)⟩ = true := by
      cases nameEq : PackageBindings.validName (ApplicationPackageNames.metadataText text)
        ⟨skipAt text cursor.position, nameAfter text (skipAt text cursor.position)⟩ <;> simp_all
    have name := (ApplicationPackageNames.Native.validName_domain nameOk).2
    have firstPositive : 0 < skipAt text cursor.position := name.1
    have afterGreater : skipAt text cursor.position < nameAfter text (skipAt text cursor.position) := name.2.1
    have cursorPositive := valid.1
    have skipped := skipAt_advances text cursor.position valid.2.1 (by omega)
    have selected : ∀ choose : Bool,
        (if choose then (⟨skipAt text cursor.position, nameAfter text (skipAt text cursor.position)⟩ : PackageBindings.NameSpan)
          else cursor.candidate).first = 0 ∨
        PackageBindings.validName (ApplicationPackageNames.metadataText text)
          (if choose then ⟨skipAt text cursor.position, nameAfter text (skipAt text cursor.position)⟩
            else cursor.candidate) = true := by
      intro choose
      cases choose
      · exact valid.2.2
      · exact Or.inr nameOk
    split
    · trivial
    · split
      · rename_i semicolon
        have bound := model_fixed_valid text (nameAfter text (skipAt text cursor.position)) ";" false name.2.2
        have advances := model_fixed_advances text (nameAfter text (skipAt text cursor.position)) ";" false
          name.2.2 (by decide) semicolon
        refine ⟨?_, ?_, bound, selected _⟩ <;> dsimp only [tokenAfter, ShellToken.symbol] at * <;> omega
      · rename_i semicolon
        have comma : tokenAfter text (nameAfter text (skipAt text cursor.position)) (.symbol ",") ≠ 0 := by
          intro zero
          have endZero : tokenAfter text (nameAfter text (skipAt text cursor.position)) (.symbol ";") = 0 := by omega
          simp [zero, endZero] at accepted
        have bound := model_fixed_valid text (nameAfter text (skipAt text cursor.position)) "," false name.2.2
        have advances := model_fixed_advances text (nameAfter text (skipAt text cursor.position)) "," false
          name.2.2 (by decide) comma
        refine ⟨?_, ?_, bound, selected _⟩ <;> dsimp only [tokenAfter, ShellToken.symbol] at * <;> omega

/-- At most one iteration per remaining source position, plus the final
terminating inspection, is enough. Rejection is a completed result. -/
theorem innerLoop_total (text : Source) (withClause : Bool) (fuel : Nat)
    (cursor : Cursor) (valid : cursor.Valid text)
    (enough : text.length + 2 - cursor.position ≤ fuel) :
    ∃ result, innerLoop modelCalls text withClause fuel cursor = some result ∧
      ∀ final, result = .ok final → cursor.position < final.position ∧ final.Valid text := by
  induction fuel generalizing cursor with
  | zero =>
      have bound : cursor.position ≤ text.length + 1 := valid.2.1
      omega
  | succ fuel ih =>
      have progress := innerStep_advances text withClause cursor valid
      cases step : innerStep modelCalls text withClause cursor with
      | reject =>
          exact ⟨.error (), by simp only [innerLoop, step], by intros; contradiction⟩
      | done final =>
          rw [step] at progress
          exact ⟨.ok final, by simp only [innerLoop, step], by intro value same; cases same; exact progress⟩
      | next next =>
          rw [step] at progress
          have advance := progress.1
          have bounded : cursor.position ≤ text.length + 1 := valid.2.1
          obtain ⟨result, finished, resultValid⟩ := ih next progress.2 (by omega)
          refine ⟨result, by simp only [innerLoop, step, finished], ?_⟩
          intro final same
          have finalValid := resultValid final same
          exact ⟨Nat.lt_trans advance finalValid.1, finalValid.2⟩

end Model
end Silver.ApplicationPackageImport
