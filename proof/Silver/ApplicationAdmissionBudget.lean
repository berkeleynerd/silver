module

public import Silver.ApplicationAdmissionModel

@[expose] public section

/-! Charge each original source unit independently while preserving the shared
operation allowance. Lexing restarts at each unit boundary, so a trailing comment
or identifier cannot consume bytes of the next unit. These raw equations retain
the remaining allowance on both successful and failed scans. -/
namespace Silver.ApplicationAdmission
open Compose

def chargeTail (text : Source) (position remaining : Nat) : ChargeResult :=
  let first := skipAt text position
  let quoted := literalAt text first
  let afterName := nameAfter text first
  let number := ScalarLiteral.read text first
  if first = 0 then ⟨remaining, false⟩
  else if first > text.length then ⟨remaining, true⟩
  else if characterLiteralAfter text first ≠ 0 then
    if _advancing : text.length + 1 - characterLiteralAfter text first < text.length + 1 - position then
      chargeTail text (characterLiteralAfter text first) remaining
    else ⟨remaining, false⟩
  else if Cursor.byteAt text first = 34 then
    if quoted.after = 0 then ⟨remaining, false⟩
    else if _advancing : text.length + 1 - quoted.after < text.length + 1 - position then
      chargeTail text quoted.after remaining
    else ⟨remaining, false⟩
  else if afterName ≠ 0 then
    if Named.nameIs text first afterName ("mod".toList.map Char.toNat) || Named.nameIs text first afterName ("rem".toList.map Char.toNat) then
      if remaining = 0 then ⟨remaining, false⟩
      else if _advancing : text.length + 1 - afterName < text.length + 1 - position then
        chargeTail text afterName (remaining - 1)
      else ⟨remaining, false⟩
    else if _advancing : text.length + 1 - afterName < text.length + 1 - position then
      chargeTail text afterName remaining
    else ⟨remaining, false⟩
  else if number.after ≠ 0 then
    if _advancing : text.length + 1 - number.after < text.length + 1 - position then
      chargeTail text number.after remaining
    else ⟨remaining, false⟩
  else if Cursor.byteAt text first = 47 ∧ first < text.length ∧ Cursor.byteAt text (first + 1) = 61 then
    if _advancing : text.length + 1 - (first + 2) < text.length + 1 - position then
      chargeTail text (first + 2) remaining
    else ⟨remaining, false⟩
  else if Cursor.byteAt text first = 38 ∨ Cursor.byteAt text first = 43 ∨
      Cursor.byteAt text first = 45 ∨ Cursor.byteAt text first = 42 ∨ Cursor.byteAt text first = 47 then
    if remaining = 0 then ⟨remaining, false⟩
    else if _advancing : text.length + 1 - (first + 1) < text.length + 1 - position then
      chargeTail text (first + 1) (remaining - 1)
    else ⟨remaining, false⟩
  else if _advancing : text.length + 1 - (first + 1) < text.length + 1 - position then
    chargeTail text (first + 1) remaining
  else ⟨remaining, false⟩
termination_by text.length + 1 - position


def chargeUnit (text : Source) (remaining : Nat) : ChargeResult := chargeTail text 1 remaining

theorem chargeTail_accepted (text : Source) (position remaining : Nat) :
    (chargeTail text position remaining).accepted = workTail text position remaining := by
  rw [chargeTail, workTail]
  by_cases test0 : skipAt text position = 0
  · simp only [ite_eq_left test0]
  · by_cases test1 : skipAt text position > text.length
    · simp only [ite_eq_right test0, ite_eq_left test1]
    · by_cases test2 : characterLiteralAfter text (skipAt text position) ≠ 0
      · by_cases test3 : text.length + 1 - (characterLiteralAfter text (skipAt text position)) < text.length + 1 - position
        · simpa only [ite_eq_right test0, ite_eq_right test1, ite_eq_left test2, dite_eq_left test3] using
            chargeTail_accepted text (characterLiteralAfter text (skipAt text position)) (remaining)
        · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_left test2, dite_eq_right test3]
      · by_cases test4 : Cursor.byteAt text (skipAt text position) = 34
        · by_cases test5 : (literalAt text (skipAt text position)).after = 0
          · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_left test4, ite_eq_left test5]
          · by_cases test6 : text.length + 1 - ((literalAt text (skipAt text position)).after) < text.length + 1 - position
            · simpa only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_left test4, ite_eq_right test5, dite_eq_left test6] using
                chargeTail_accepted text ((literalAt text (skipAt text position)).after) (remaining)
            · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_left test4, ite_eq_right test5, dite_eq_right test6]
        · by_cases test7 : nameAfter text (skipAt text position) ≠ 0
          · by_cases test8 : (Named.nameIs text (skipAt text position) (nameAfter text (skipAt text position)) ("mod".toList.map Char.toNat) || Named.nameIs text (skipAt text position) (nameAfter text (skipAt text position)) ("rem".toList.map Char.toNat)) = true
            · by_cases test9 : remaining = 0
              · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_left test7, ite_eq_left test8, ite_eq_left test9]
              · by_cases test10 : text.length + 1 - (nameAfter text (skipAt text position)) < text.length + 1 - position
                · simpa only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_left test7, ite_eq_left test8, ite_eq_right test9, dite_eq_left test10] using
                    chargeTail_accepted text (nameAfter text (skipAt text position)) (remaining - 1)
                · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_left test7, ite_eq_left test8, ite_eq_right test9, dite_eq_right test10]
            · by_cases test11 : text.length + 1 - (nameAfter text (skipAt text position)) < text.length + 1 - position
              · simpa only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_left test7, ite_eq_right test8, dite_eq_left test11] using
                  chargeTail_accepted text (nameAfter text (skipAt text position)) (remaining)
              · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_left test7, ite_eq_right test8, dite_eq_right test11]
          · by_cases test12 : (ScalarLiteral.read text (skipAt text position)).after ≠ 0
            · by_cases test13 : text.length + 1 - ((ScalarLiteral.read text (skipAt text position)).after) < text.length + 1 - position
              · simpa only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_right test7, ite_eq_left test12, dite_eq_left test13] using
                  chargeTail_accepted text ((ScalarLiteral.read text (skipAt text position)).after) (remaining)
              · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_right test7, ite_eq_left test12, dite_eq_right test13]
            · by_cases test14 : Cursor.byteAt text (skipAt text position) = 47 ∧ skipAt text position < text.length ∧ Cursor.byteAt text (skipAt text position + 1) = 61
              · by_cases test15 : text.length + 1 - (skipAt text position + 2) < text.length + 1 - position
                · simpa only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_right test7, ite_eq_right test12, ite_eq_left test14, dite_eq_left test15] using
                    chargeTail_accepted text (skipAt text position + 2) (remaining)
                · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_right test7, ite_eq_right test12, ite_eq_left test14, dite_eq_right test15]
              · by_cases test16 : Cursor.byteAt text (skipAt text position) = 38 ∨ Cursor.byteAt text (skipAt text position) = 43 ∨ Cursor.byteAt text (skipAt text position) = 45 ∨ Cursor.byteAt text (skipAt text position) = 42 ∨ Cursor.byteAt text (skipAt text position) = 47
                · by_cases test17 : remaining = 0
                  · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_right test7, ite_eq_right test12, ite_eq_right test14, ite_eq_left test16, ite_eq_left test17]
                  · by_cases test18 : text.length + 1 - (skipAt text position + 1) < text.length + 1 - position
                    · simpa only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_right test7, ite_eq_right test12, ite_eq_right test14, ite_eq_left test16, ite_eq_right test17, dite_eq_left test18] using
                        chargeTail_accepted text (skipAt text position + 1) (remaining - 1)
                    · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_right test7, ite_eq_right test12, ite_eq_right test14, ite_eq_left test16, ite_eq_right test17, dite_eq_right test18]
                · by_cases test19 : text.length + 1 - (skipAt text position + 1) < text.length + 1 - position
                  · simpa only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_right test7, ite_eq_right test12, ite_eq_right test14, ite_eq_right test16, dite_eq_left test19] using
                      chargeTail_accepted text (skipAt text position + 1) (remaining)
                  · simp only [ite_eq_right test0, ite_eq_right test1, ite_eq_right test2, ite_eq_right test4, ite_eq_right test7, ite_eq_right test12, ite_eq_right test14, ite_eq_right test16, dite_eq_right test19]
termination_by text.length + 1 - position


theorem chargeUnit_accepted (text : Source) (remaining : Nat) :
    (chargeUnit text remaining).accepted = workTail text 1 remaining :=
  chargeTail_accepted text 1 remaining

/-- The whole application's allowance is threaded across all three original
units; there is no reset or pooled lexical interpretation between units. -/
theorem chargeUnits_three (calls : Calls) (sources : ApplicationUnits.Bundle) (remaining : Nat) :
    chargeUnits calls sources originalKinds remaining =
      (let specification := calls.chargeUnit (sources.unitSource .packageSpecification) remaining
       if specification.accepted then
         let body := calls.chargeUnit (sources.unitSource .packageBody) specification.remaining
         if body.accepted then
           let main := calls.chargeUnit (sources.unitSource .mainBody) body.remaining
           if main.accepted then some main.remaining else none
         else none
       else none) := by rfl

end Silver.ApplicationAdmission
