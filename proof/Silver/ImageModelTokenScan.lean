module

public import Silver.ImageModelIdNormalization
public import Silver.ImageModelInitialSource

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.ScannerNative

/-- The delimiter closes the previous atom before its own structural effect.
The maximum-ID update occurs only for numbers classified as node IDs. -/
def closedAtom (state : Core.State) : Core.State :=
  {state with
    greatestId := if state.mode = .number ∧ state.numberIsId then max state.greatestId state.numberValue else state.greatestId
    mode := .between}

theorem consume_atom_delimiter (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .number ∨ state.mode = .literal)
    (digits : state.mode = .number → state.numberIsId = true → state.numberDigits = true)
    (delimiter : isDelimiter item = true) :
    consume helpers state item = structural helpers (closedAtom (counted state)) item := by
  rw [consume_in_atom helpers state item good room mode]
  simp only [consumeNumber, Command.eval, delimiter_test, delimiter, ↓reduceIte]
  rcases mode with mode | mode <;> cases isId : state.numberIsId <;>
    simp_all [consumeNumberClose, Command.list, Command.eval, Test.eval, counted,
      Flag.get, number, Action.eval, Number.eval, NumberField.get, NumberField.set, closedAtom]

def atomEffect (tables : Native.Tables) (state : Core.State) (input : List Nat) : Core.State :=
  {state with matcher := input.foldl (Core.matcher tables) state.matcher, bytes := state.bytes + input.length}

/-- Ordinary number/literal token interiors are copied exactly, with original
byte counts. JSON token legality is supplied separately by the typed producer
serialization relation. -/
theorem consume_atom_run (tables : Native.Tables) (state : Core.State) (input : List Nat)
    (good : state.failed = false) (room : state.bytes + input.length ≤ 9223372036854775807)
    (mode : state.mode = .number ∨ state.mode = .literal)
    (ordinary : state.mode = .literal ∨ state.numberIsId = false)
    (token : ∀ byte ∈ input, isDelimiter byte = false) :
    input.foldl (consume (Core.modelHelpers tables)) state = atomEffect tables state input := by
  induction input generalizing state with
  | nil => simp [atomEffect]
  | cons byte rest ih =>
      have next := consume_atom_byte (Core.modelHelpers tables) state byte good
        (by simp only [List.length_cons] at room; omega) mode ordinary (token byte (by simp))
      simp only [List.foldl_cons, next]
      rw [ih ((Core.modelHelpers tables).matchByte (counted state) byte) good
        (by change state.bytes + 1 + rest.length ≤ _; simp only [List.length_cons] at room; omega)
        mode ordinary (fun item member => token item (by simp [member]))]
      simp only [atomEffect, Core.modelHelpers, counted, List.foldl_cons, List.length_cons]
      congr 1 <;> omega

theorem structural_literal (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (active : state.matcher.inTheory = true) (notId : state.nodeIdPending = false)
    (first : item = 116 ∨ item = 102 ∨ item = 110) :
    structural helpers state item =
      {helpers.matchByte {state with mode := .literal} item with previousArrayStart := false} := by
  rcases first with h | h | h <;> subst item <;>
    simp [structural, structuralCommands, structuralCases, structuralLiteral,
      Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
      flag, Flag.get, Flag.set, Action.eval, matchItem, decimal, active, notId]

theorem structural_negative (helpers : Core.Helpers) (state : Core.State)
    (active : state.matcher.inTheory = true) (notId : state.nodeIdPending = false) :
    structural helpers state 45 =
      {helpers.matchByte {state with
          numberIsId := false
          nodeIdPending := false
          numberValue := 0
          numberDigits := false
          mode := .number} 45 with previousArrayStart := false} := by
  simp [structural, structuralCommands, structuralCases, structuralNumber,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, number, Number.eval, NumberField.set,
    Flag.get, Flag.set, Action.eval, matchItem, decimal, active, notId]

def Whitespace (input : List Nat) : Prop := ∀ byte ∈ input, byte = 32 ∨ byte = 9 ∨ byte = 10 ∨ byte = 13

theorem consume_whitespace_run (helpers : Core.Helpers) (state : Core.State) (input : List Nat)
    (good : state.failed = false) (room : state.bytes + input.length ≤ 9223372036854775807)
    (mode : state.mode = .between) (spaces : Whitespace input) :
    input.foldl (consume helpers) state = {state with bytes := state.bytes + input.length} := by
  induction input generalizing state with
  | nil => simp
  | cons byte rest ih =>
      simp only [List.foldl_cons]
      rw [consume_whitespace helpers state byte good
        (by simp only [List.length_cons] at room; omega) mode (spaces byte (by simp))]
      rw [ih (counted state) good
        (by change state.bytes + 1 + rest.length ≤ _; simp only [List.length_cons] at room; omega)
        mode (fun item member => spaces item (by simp [member]))]
      simp only [counted, List.length_cons]
      congr 1 <;> omega

end Silver.ImageModel.ScannerNative
