module

public import Silver.ImageModelNativeHelpers

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.ScannerNative

/-- One raw input byte is counted before the mode-specific transition. -/
def counted (state : Core.State) : Core.State := {state with bytes := state.bytes + 1}

theorem consume_dispatch (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807) :
    consume helpers state item =
      (consumeCases.eval helpers (structural helpers) ⟨counted state, item, 0⟩).frame.state := by
  simp only [consume, consumeCommands, Command.list, List.foldr_cons, List.foldr_nil,
    Command.eval, Test.eval, Flag.get, good, Bool.false_eq_true, ↓reduceIte,
    Comparison.eval, Number.eval, NumberField.get, room, decide_false,
    increase, number, Action.eval, NumberField.set, counted]
  split <;> rfl

theorem consume_in_string (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .string) :
    consume helpers state item =
      (consumeString.eval helpers (structural helpers) ⟨counted state, item, 0⟩).frame.state := by
  rw [consume_dispatch helpers state item good room]
  simp only [consumeCases, Command.eval, counted, mode, List.contains_cons, List.contains_nil,
    beq_self_eq_true, Bool.or_false, ↓reduceIte]

theorem consume_in_escape (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .escape) :
    consume helpers state item =
      (consumeEscape.eval helpers (structural helpers) ⟨counted state, item, 0⟩).frame.state := by
  rw [consume_dispatch helpers state item good room]
  simp only [consumeCases, Command.eval, counted, mode, List.contains_cons, List.contains_nil,
    beq_self_eq_true, Bool.or_false, ↓reduceIte, show (StringNative.Mode.escape == .string) = false by decide,
    Bool.false_eq_true]

theorem consume_in_unicode (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .unicode) :
    consume helpers state item =
      (consumeUnicode.eval helpers (structural helpers) ⟨counted state, item, 0⟩).frame.state := by
  rw [consume_dispatch helpers state item good room]
  simp only [consumeCases, Command.eval, counted, mode, List.contains_cons, List.contains_nil,
    beq_self_eq_true, Bool.or_false, ↓reduceIte, show (StringNative.Mode.unicode == .string) = false by decide,
    show (StringNative.Mode.unicode == .escape) = false by decide, Bool.false_eq_true]

/-- Printable unescaped string characters call Decoded exactly once. This is a
universal transition theorem for arbitrary scanner states and input characters. -/
theorem consume_plain (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .string) (quote : item ≠ 34) (escape : item ≠ 92) (printable : 32 ≤ item) :
    consume helpers state item = helpers.decoded (counted state) item := by
  rw [consume_in_string helpers state item good room mode]
  simp only [consumeString, Command.eval, Test.eval, CharacterValue.eval, quote, escape,
    decide_false, Bool.false_eq_true, ↓reduceIte, Comparison.eval, Number.eval,
    show ¬item < 32 by omega, Action.eval]

theorem consume_quote (helpers : Core.Helpers) (state : Core.State)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807) (mode : state.mode = .string) :
    consume helpers state 34 = helpers.endString (counted state) := by
  rw [consume_in_string helpers state 34 good room mode]
  simp only [consumeString, Command.eval, Test.eval, CharacterValue.eval, decide_true, ↓reduceIte, Action.eval]

theorem consume_escape_start (helpers : Core.Helpers) (state : Core.State)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807) (mode : state.mode = .string) :
    consume helpers state 92 = {counted state with mode := .escape} := by
  rw [consume_in_string helpers state 92 good room mode]
  simp only [consumeString, Command.eval, Test.eval, CharacterValue.eval,
    show (92 = 34) = False by decide, decide_false, Bool.false_eq_true, ↓reduceIte,
    decide_true, Action.eval]

/-- JSON's eight short escapes have exactly their standard character values. -/
def shortEscape : Nat → Option Nat
  | 34 => some 34 | 92 => some 92 | 47 => some 47 | 98 => some 8
  | 116 => some 9 | 110 => some 10 | 102 => some 12 | 114 => some 13
  | _ => none

theorem consume_short_escape (helpers : Core.Helpers) (state : Core.State) (item code : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .escape) (escaped : shortEscape item = some code) :
    consume helpers state item = helpers.decoded {counted state with mode := .string} code := by
  rw [consume_in_escape helpers state item good room mode]
  unfold shortEscape at escaped
  split at escaped <;> (try contradiction)
  all_goals cases escaped
  all_goals simp [consumeEscape, consumeEscapes, Command.list, Command.eval, Action.eval,
    Choice.accepts, CharacterValue.eval, Number.eval]

theorem consume_unicode_start (helpers : Core.Helpers) (state : Core.State)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807) (mode : state.mode = .escape) :
    consume helpers state 117 = {counted state with
      mode := .unicode, unicodeLeft := 4, unicodeValue := 0} := by
  rw [consume_in_escape helpers state 117 good room mode]
  simp [consumeEscape, consumeEscapes, Command.list, Command.eval, Action.eval,
    Choice.accepts, CharacterValue.eval, Number.eval, number, NumberField.set]

/-- A Unicode digit performs the guarded base-16 accumulation; only its final
fourth digit emits a decoded character. -/
theorem consume_unicode_digit (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .unicode) (digit : helpers.hex item < 16)
    (left : 0 < state.unicodeLeft) (space : state.unicodeValue ≤ (65535 - helpers.hex item) / 16) :
    consume helpers state item =
      let next := {counted state with
        unicodeValue := state.unicodeValue * 16 + helpers.hex item
        unicodeLeft := state.unicodeLeft - 1}
      if state.unicodeLeft = 1 then {helpers.decoded next next.unicodeValue with mode := .string} else next := by
  rw [consume_in_unicode helpers state item good room mode]
  simp only [consumeUnicode, Command.list, List.foldr_cons, List.foldr_nil,
    Command.eval, number, Action.eval, Number.eval, NumberField.get, NumberField.set,
    Test.eval, Comparison.eval, digit, left, space, decide_true, Bool.true_and, ↓reduceIte,
    decrease, equal, counted]
  by_cases last : state.unicodeLeft = 1
  · simp [last]
  · have more : state.unicodeLeft - 1 ≠ 0 := by omega
    simp [last, more]

end Silver.ImageModel.ScannerNative
