module

public import Silver.ImageModelJsonSpelling
public import Silver.ImageModelByteCount

@[expose] public section
namespace Silver.ImageModel.ScannerNative

def ordinaryNumber (state : Core.State) (digits : Bool) : Core.State :=
  {state with
    mode := .number
    numberIsId := false
    nodeIdPending := false
    numberValue := 0
    numberDigits := digits
    previousArrayStart := false}

theorem positive_number_result (tables : Native.Tables) (state : Core.State) (first : Nat) (rest : List Nat)
    (good : state.failed = false) (mode : state.mode = .between)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (digit : 48 ≤ first ∧ first ≤ 57) (digits : decimalWord rest)
    (room : state.bytes + (first :: rest).length ≤ 9223372036854775807) :
    (first :: rest).foldl (consume (Core.modelHelpers tables)) state =
      atomEffect tables (ordinaryNumber state true) (first :: rest) := by
  have headRoom : state.bytes ≠ 9223372036854775807 := by simp only [List.length_cons] at room; omega
  have head := consume_between (Core.modelHelpers tables) state first good headRoom mode
  rw [structural_begin_number _ (counted state) first active digit] at head
  have initial : consume (Core.modelHelpers tables) state first =
      (Core.modelHelpers tables).matchByte (counted (ordinaryNumber state true)) first := by
    rw [head]
    simp only [beginNumber, counted, notId, Bool.false_eq_true, ↓reduceIte, Core.modelHelpers, ordinaryNumber]
  rw [List.foldl_cons, initial]
  rw [consume_atom_run tables ((Core.modelHelpers tables).matchByte (counted (ordinaryNumber state true)) first) rest good
    (by change state.bytes + 1 + rest.length ≤ _; simp only [List.length_cons] at room; omega)
    (.inl rfl) (.inr rfl) (fun byte member => digit_not_delimiter byte (digits byte member))]
  simp only [atomEffect, Core.modelHelpers, counted, List.foldl_cons, List.length_cons]
  congr 1 <;> omega

theorem negative_number_result (tables : Native.Tables) (state : Core.State) (rest : List Nat)
    (good : state.failed = false) (mode : state.mode = .between)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (digits : decimalWord rest)
    (room : state.bytes + (45 :: rest).length ≤ 9223372036854775807) :
    (45 :: rest).foldl (consume (Core.modelHelpers tables)) state =
      atomEffect tables (ordinaryNumber state false) (45 :: rest) := by
  have headRoom : state.bytes ≠ 9223372036854775807 := by simp only [List.length_cons] at room; omega
  have head := consume_between (Core.modelHelpers tables) state 45 good headRoom mode
  rw [structural_negative _ (counted state) active notId] at head
  have initial : consume (Core.modelHelpers tables) state 45 =
      (Core.modelHelpers tables).matchByte (counted (ordinaryNumber state false)) 45 := by
    rw [head]
    rfl
  rw [List.foldl_cons, initial]
  rw [consume_atom_run tables ((Core.modelHelpers tables).matchByte (counted (ordinaryNumber state false)) 45) rest good
    (by change state.bytes + 1 + rest.length ≤ _; simp only [List.length_cons] at room; omega)
    (.inl rfl) (.inr rfl) (fun byte member => digit_not_delimiter byte (digits byte member))]
  simp only [atomEffect, Core.modelHelpers, counted, List.foldl_cons, List.length_cons]
  congr 1 <;> omega

/-- Every ordinary integer token admitted by the producer grammar is preserved
exactly, including its sign. Only the distinct node-ID path normalizes numbers. -/
theorem ordinary_integer_result (tables : Native.Tables) (state : Core.State) (input : List Nat)
    (token : JSON.IntegerToken input) (good : state.failed = false) (mode : state.mode = .between)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (room : state.bytes + input.length ≤ 9223372036854775807) :
    ∃ digits, input.foldl (consume (Core.modelHelpers tables)) state =
      atomEffect tables (ordinaryNumber state digits) input := by
  cases token with
  | zero => exact ⟨true, positive_number_result tables state 48 [] good mode notId active (by omega) (by simp [decimalWord]) room⟩
  | positive first rest nonzero digits =>
      exact ⟨true, positive_number_result tables state first rest good mode notId active (by omega) digits room⟩
  | negativeZero =>
      exact ⟨false, negative_number_result tables state [48] good mode notId active (by simp [decimalWord]) room⟩
  | negative first rest nonzero digits =>
      refine ⟨false, negative_number_result tables state (first :: rest) good mode notId active ?_ room⟩
      intro byte member
      rcases List.mem_cons.mp member with equal | member
      · omega
      · exact digits byte member

theorem literal_result (tables : Native.Tables) (state : Core.State) (first : Nat) (rest : List Nat)
    (good : state.failed = false) (mode : state.mode = .between)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (start : first = 116 ∨ first = 102 ∨ first = 110)
    (tail : ∀ byte ∈ rest, isDelimiter byte = false)
    (room : state.bytes + (first :: rest).length ≤ 9223372036854775807) :
    (first :: rest).foldl (consume (Core.modelHelpers tables)) state =
      atomEffect tables {state with mode := .literal, previousArrayStart := false} (first :: rest) := by
  have headRoom : state.bytes ≠ 9223372036854775807 := by simp only [List.length_cons] at room; omega
  have head := consume_between (Core.modelHelpers tables) state first good headRoom mode
  rw [structural_literal _ (counted state) first active notId start] at head
  rw [List.foldl_cons, head]
  rw [consume_atom_run tables
    {(Core.modelHelpers tables).matchByte {counted state with mode := .literal} first with previousArrayStart := false} rest good
    (by change state.bytes + 1 + rest.length ≤ _; simp only [List.length_cons] at room; omega)
    (.inr rfl) (.inl rfl) tail]
  simp only [atomEffect, Core.modelHelpers, counted, List.foldl_cons, List.length_cons]
  congr 1 <;> omega

/-- Closing an ordinary token changes only its lexical mode. This permits a
following structural delimiter to be treated uniformly with strings/arrays. -/
theorem closed_ordinary_number (state : Core.State) (digits : Bool) :
    closedAtom (ordinaryNumber state digits) = {ordinaryNumber state digits with mode := .between} := by
  simp [closedAtom, ordinaryNumber]

end Silver.ImageModel.ScannerNative
