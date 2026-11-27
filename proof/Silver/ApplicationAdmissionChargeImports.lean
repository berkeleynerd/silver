module

public import Silver.ApplicationAdmissionChargeEquations
public import Silver.ComposeCoreHelperEquations
public import Silver.ComposeModelCalls

@[expose] public section

namespace Silver.ApplicationAdmission.Charge
open Compose Compose.Expressions
variable {domain : StateDomain}

/-- Every leaf receives its complete native precondition, including position
zero on failed scans. Name_Is is reached only after Name_After supplies its span. -/
theorem scanStep_imports (calls : Expressions.Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position remaining : Nat) (bounded : ValidCursor text position) :
    scanStep calls text position remaining = scanStep modelCalls text position remaining := by
  have firstBound := model_skip_valid text position bounded
  have skipEq := interpreted_skip calls equations text valid position bounded
  have characterEq := interpreted_characterLiteral calls equations text valid _ firstBound
  have nameEq := interpreted_name calls equations text valid _ firstBound
  have numberEq := equations.scalarLiteral text valid _ firstBound
  have quotedEq := interpreted_literal calls equations text valid _ firstBound
  unfold scanStep
  rw [skipEq]
  dsimp only [modelCalls]
  split
  · rfl
  · split
    · rfl
    · rw [characterEq, nameEq, numberEq]
      unfold selected
      split
      · rfl
      · split
        · rw [quotedEq]
        · split
          · rename_i present
            have advance := model_name_advances text (skipAt text position) present
            have nameValid : ValidName text (skipAt text position) (nameAfter text (skipAt text position)) :=
              ⟨advance.1, advance.2, model_name_valid text _⟩
            rw [equations.nameIs text valid _ _ "mod" nameValid (by decide) (by decide),
              equations.nameIs text valid _ _ "rem" nameValid (by decide) (by decide)]
          · rfl

end Silver.ApplicationAdmission.Charge
