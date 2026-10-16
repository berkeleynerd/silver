module

public import Silver.ImageModelStringObservations

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.ScannerNative

def isDelimiter (item : Nat) : Bool := [32, 9, 10, 13, 44, 93, 125, 58, 91, 123, 34].contains item

theorem delimiter_test (helpers : Core.Helpers) (frame : Frame) :
    (Test.itemIn delimiters).eval helpers frame = isDelimiter frame.item := by
  change ([32, 9, 10, 13, 44, 93, 125, 58, 91, 123, 34].any (fun byte => decide (frame.item = byte))) = _
  simp [isDelimiter]

theorem decimal_test (helpers : Core.Helpers) (frame : Frame) :
    (Test.itemIn decimal).eval helpers frame = decide (48 ≤ frame.item ∧ frame.item ≤ 57) := by
  change (decide (48 ≤ frame.item ∧ frame.item ≤ 57) || false) = _
  exact Bool.or_false _

theorem digit_not_delimiter (item : Nat) (digit : 48 ≤ item ∧ item ≤ 57) : isDelimiter item = false := by
  apply Bool.eq_false_iff.mpr
  intro member
  simp only [isDelimiter, List.contains_iff_mem, List.mem_cons, List.not_mem_nil, or_false] at member
  omega

theorem consume_in_atom (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .number ∨ state.mode = .literal) :
    consume helpers state item =
      (consumeNumber.eval helpers (structural helpers) ⟨counted state, item, 0⟩).frame.state := by
  rw [consume_dispatch helpers state item good room]
  rcases mode with mode | mode <;> simp [consumeCases, Command.eval, counted, mode]

/-- Non-ID number and literal bytes are forwarded unchanged to the template
matcher. Validity of their complete JSON token remains the parser's obligation. -/
theorem consume_atom_byte (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .number ∨ state.mode = .literal)
    (ordinary : state.mode = .literal ∨ state.numberIsId = false) (token : isDelimiter item = false) :
    consume helpers state item = helpers.matchByte (counted state) item := by
  rw [consume_in_atom helpers state item good room mode]
  simp only [consumeNumber, Command.eval, delimiter_test, token, Bool.false_eq_true, ↓reduceIte]
  rcases ordinary with literal | notId
  · simp [Command.eval, Test.eval, counted, literal, Flag.get, matchItem, Action.eval, CharacterValue.eval]
  · simp [Command.eval, Test.eval, counted, notId, Flag.get, matchItem, Action.eval, CharacterValue.eval]

/-- The remainder of a W-node ID is consumed without emitting any further
number bytes. The first digit's normalization to zero occurs in Structural. -/
theorem consume_id_digit (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .number) (nodeId : state.numberIsId = true)
    (digit : 48 ≤ item ∧ item ≤ 57)
    (bounded : state.numberValue ≤ (originalIdMaximum - (item - 48)) / 10) :
    consume helpers state item = {counted state with
      numberValue := state.numberValue * 10 + (item - 48)
      numberDigits := true} := by
  rw [consume_in_atom helpers state item good room (.inl mode)]
  simp only [consumeNumber, Command.eval, delimiter_test, digit_not_delimiter item digit, Bool.false_eq_true, ↓reduceIte]
  simp only [Test.eval, counted, mode, Flag.get, nodeId, decide_true, Bool.true_and, ↓reduceIte]
  simp only [consumeIdDigit, Command.eval, decimal_test]
  have digitBool : decide (48 ≤ item ∧ item ≤ 57) = true := by exact decide_eq_true digit
  simp only [digitBool, ↓reduceIte]
  simp [Command.list, Command.eval, number, flag, Action.eval, Number.eval,
    CharacterValue.eval, NumberField.set, NumberField.get, Flag.set, Test.eval, Comparison.eval, bounded]

/-- A delimiter commits an accumulated node ID and then undergoes the same
structural processing as a delimiter encountered between tokens. -/
theorem consume_id_delimiter (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .number) (nodeId : state.numberIsId = true)
    (digits : state.numberDigits = true) (delimiter : isDelimiter item = true) :
    consume helpers state item = structural helpers
      {counted state with greatestId := max state.greatestId state.numberValue, mode := .between} item := by
  rw [consume_in_atom helpers state item good room (.inl mode)]
  simp only [consumeNumber, Command.eval, delimiter_test, delimiter, ↓reduceIte]
  simp only [
    consumeNumberClose, Command.eval, Command.list, List.foldr_cons, List.foldr_nil, ↓reduceIte,
    Test.eval, counted, mode, Flag.get, nodeId, digits, decide_true, Bool.true_and,
    Bool.not_true, Bool.false_eq_true, number, Action.eval, Number.eval,
    NumberField.get, NumberField.set]

end Silver.ImageModel.ScannerNative
