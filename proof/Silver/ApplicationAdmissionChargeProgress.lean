module

public import Silver.ApplicationAdmissionChargeImports

@[expose] public section

namespace Silver.ApplicationAdmission.Charge
open Compose Compose.Expressions

def StepContract (text : Source) (position remaining : Nat) : Progress → Prop
  | .returned result => chargeTail text position remaining = result
  | .next after allowance => ValidCursor text after ∧ allowance ≤ remaining ∧
      text.length + 1 - after < text.length + 1 - position ∧
      chargeTail text position remaining = chargeTail text after allowance

/-- The model's defensive progress branches are unreachable on the full native
cursor domain. This covers every returned result, including exhausted allowance. -/
theorem scanStep_contract (text : Source) (valid : ValidText text) (position remaining : Nat)
    (bounded : ValidCursor text position) :
    StepContract text position remaining (scanStep modelCalls text position remaining) := by
  have firstBound := model_skip_valid text position bounded
  unfold scanStep
  dsimp only [modelCalls]
  by_cases firstZero : skipAt text position = 0
  · simp only [firstZero, ↓reduceIte, StepContract]
    rw [chargeTail]
    simp only [firstZero, ↓reduceIte]
  · by_cases finished : skipAt text position > text.length
    · simp only [firstZero, finished, ↓reduceIte, StepContract]
      rw [chargeTail]
      simp only [firstZero, finished, ↓reduceIte]
    · have firstAdvance := skipAt_advances text position bounded firstZero
      have plainBound : ValidCursor text (skipAt text position + 1) := by unfold ValidCursor; omega
      have plainDecrease : text.length + 1 - (skipAt text position + 1) < text.length + 1 - position := by omega
      simp only [firstZero, finished, ↓reduceIte, selected]
      by_cases characterPresent : characterLiteralAfter text (skipAt text position) ≠ 0
      · have advance := characterLiteralAfter_bounds characterPresent
        have decrease : text.length + 1 - characterLiteralAfter text (skipAt text position) <
            text.length + 1 - position := by omega
        simp only [characterPresent, ne_eq, not_false_eq_true, ↓reduceIte, StepContract]
        refine ⟨advance.2, Nat.le_refl _, decrease, ?_⟩
        rw [chargeTail]
        simp only [firstZero, finished, characterPresent, ne_eq, not_false_eq_true, decrease, ↓reduceIte, ↓reduceDIte]
      · by_cases isQuote : Cursor.byteAt text (skipAt text position) = 34
        · by_cases absent : (literalAt text (skipAt text position)).after = 0
          · simp only [characterPresent, isQuote, absent, ↓reduceIte, StepContract]
            rw [chargeTail]
            simp only [firstZero, finished, characterPresent, isQuote, absent, ↓reduceIte]
          · have advance := literalAt_advances text (skipAt text position) absent
            have decrease : text.length + 1 - (literalAt text (skipAt text position)).after <
                text.length + 1 - position := by omega
            simp only [characterPresent, isQuote, absent, ↓reduceIte, StepContract]
            refine ⟨(model_literal_valid text valid _).1, Nat.le_refl _, decrease, ?_⟩
            rw [chargeTail]
            simp only [firstZero, finished, characterPresent, isQuote, absent, decrease, ↓reduceIte, ↓reduceDIte]
        · by_cases namePresent : nameAfter text (skipAt text position) ≠ 0
          · have advance := model_name_advances text (skipAt text position) namePresent
            have decrease : text.length + 1 - nameAfter text (skipAt text position) <
                text.length + 1 - position := by omega
            simp only [characterPresent, isQuote, namePresent, ne_eq, not_false_eq_true, ↓reduceIte, charged]
            split
            · rename_i chargedName
              by_cases empty : remaining = 0
              · simp only [empty, ↓reduceIte, StepContract]
                rw [chargeTail]
                simp only [firstZero, finished, characterPresent, isQuote, namePresent, chargedName, ne_eq, not_false_eq_true, ↓reduceIte]
              · simp only [empty, ↓reduceIte, StepContract]
                refine ⟨model_name_valid text _, Nat.sub_le _ _, decrease, ?_⟩
                rw [chargeTail]
                simp only [firstZero, finished, characterPresent, isQuote, namePresent, chargedName, empty, ne_eq, not_false_eq_true,
                  decrease, ↓reduceIte, ↓reduceDIte]
            · rename_i unchargedName
              dsimp only [StepContract]
              refine ⟨model_name_valid text _, Nat.le_refl _, decrease, ?_⟩
              rw [chargeTail]
              simp only [firstZero, finished, characterPresent, isQuote, namePresent, unchargedName, ne_eq, not_false_eq_true,
                Bool.false_eq_true, decrease, ↓reduceIte, ↓reduceDIte]
          · by_cases numberPresent : (ScalarLiteral.read text (skipAt text position)).after ≠ 0
            · have numberBounds := ScalarLiteral.integer_bounds (ScalarLiteral.read_sound firstBound numberPresent)
              have decrease : text.length + 1 - (ScalarLiteral.read text (skipAt text position)).after <
                  text.length + 1 - position := by omega
              simp only [characterPresent, isQuote, namePresent, numberPresent, ne_eq, not_false_eq_true, ↓reduceIte, StepContract]
              refine ⟨numberBounds.2.1, Nat.le_refl _, decrease, ?_⟩
              rw [chargeTail]
              simp only [firstZero, finished, characterPresent, isQuote, namePresent, numberPresent, ne_eq, not_false_eq_true,
                decrease, ↓reduceIte, ↓reduceDIte]
            · by_cases comparison : Cursor.byteAt text (skipAt text position) = 47 ∧
                  skipAt text position < text.length ∧ Cursor.byteAt text (skipAt text position + 1) = 61
              · have pairBound : ValidCursor text (skipAt text position + 2) := by unfold ValidCursor; omega
                have decrease : text.length + 1 - (skipAt text position + 2) < text.length + 1 - position := by omega
                simp only [characterPresent, isQuote, namePresent, numberPresent, ↓reduceIte]
                rw [ite_eq_left comparison]
                dsimp only [StepContract]
                refine ⟨pairBound, Nat.le_refl _, decrease, ?_⟩
                rw [chargeTail]
                simp only [firstZero, finished, characterPresent, isQuote, namePresent, numberPresent, ↓reduceIte]
                rw [ite_eq_left comparison, dite_eq_left decrease]
              · simp only [characterPresent, isQuote, namePresent, numberPresent, comparison, ↓reduceIte, charged,
                  List.mem_cons, List.not_mem_nil, or_false, decide_eq_true_eq]
                split
                · rename_i operator
                  by_cases empty : remaining = 0
                  · simp only [empty, ↓reduceIte, StepContract]
                    rw [chargeTail]
                    simp only [firstZero, finished, characterPresent, isQuote, namePresent, numberPresent,
                      comparison, operator, ↓reduceIte]
                  · simp only [empty, ↓reduceIte, StepContract]
                    refine ⟨plainBound, Nat.sub_le _ _, plainDecrease, ?_⟩
                    rw [chargeTail]
                    simp only [firstZero, finished, characterPresent, isQuote, namePresent, numberPresent,
                      comparison, operator, empty, plainDecrease, ↓reduceIte, ↓reduceDIte]
                · rename_i other
                  dsimp only [StepContract]
                  refine ⟨plainBound, Nat.le_refl _, plainDecrease, ?_⟩
                  rw [chargeTail]
                  simp only [firstZero, finished, characterPresent, isQuote, namePresent, numberPresent,
                    comparison, other, plainDecrease, ↓reduceIte, ↓reduceDIte]

end Silver.ApplicationAdmission.Charge
