module

public import Silver.ImageModelQuotedString

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- The opening array of each top-level theory resets all three candidate
matchers and all per-theory observations before its first byte is emitted. -/
def beginTheory (state : Core.State) : Core.State :=
  {state with
    matcher := ⟨true, fun _ => ⟨0, true⟩⟩
    theory := none
    field := 0
    candidateDeclarations := 0
    candidateIncludes := 0
    depth := 3}

theorem structural_begin_theory (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (depth : state.depth = 2)
    (phase : state.phase = .firstTheory ∨ state.phase = .nextTheory) :
    structural helpers state 91 = {helpers.matchByte (beginTheory state) 91 with previousArrayStart := true} := by
  rcases phase with phase | phase <;>
    simp [structural, structuralCommands, structuralCases, structuralOpenArray, beginTheory,
      Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
      flag, number, Number.eval, NumberField.get, NumberField.set, equal, Comparison.eval,
      Flag.get, Flag.set, Action.eval, matchItem, *]

theorem structural_open_nested_array (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (depth : 3 ≤ state.depth) (room : state.depth < 9223372036854775807) :
    structural helpers state 91 =
      {helpers.matchByte {state with depth := state.depth + 1} 91 with previousArrayStart := true} := by
  have one : state.depth ≠ 1 := by omega
  have two : state.depth ≠ 2 := by omega
  simp [structural, structuralCommands, structuralCases, structuralOpenArray,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, number, Number.eval, NumberField.get, NumberField.set, equal, increase, Comparison.eval,
    Flag.get, Flag.set, Action.eval, matchItem, *]

/-- Offset candidates are original zero-based byte positions of the actual
closing bracket, captured before decrementing depth or emitting the bracket. -/
def closeNestedArray (state : Core.State) : Core.State :=
  {state with
    candidateDeclarations := if state.depth = 4 ∧ state.bytes > 0 ∧ state.field = 3 then state.bytes - 1 else state.candidateDeclarations
    candidateIncludes := if state.depth = 4 ∧ state.bytes > 0 ∧ state.field = 6 then state.bytes - 1 else state.candidateIncludes
    depth := state.depth - 1}

theorem structural_close_nested_array (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true) (depth : 3 < state.depth) :
    structural helpers state 93 =
      {helpers.matchByte (closeNestedArray state) 93 with previousArrayStart := false} := by
  have two : state.depth ≠ 2 := by omega
  have three : state.depth ≠ 3 := by omega
  by_cases four : state.depth = 4 <;> by_cases bytes : state.bytes > 0 <;>
    by_cases declarations : state.field = 3 <;> by_cases includes : state.field = 6 <;>
    simp_all [structural, structuralCommands, structuralCases, structuralCloseArray, structuralOffset,
      closeNestedArray, Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval,
      whitespace, flag, number, Number.eval, NumberField.get, NumberField.set, equal, decrease,
      Comparison.eval, Flag.get, Flag.set, Action.eval, matchItem]

theorem structural_close_theory (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true) (depth : state.depth = 3) :
    structural helpers state 93 = {helpers.endTheory state with previousArrayStart := false} := by
  simp [structural, structuralCommands, structuralCases, structuralCloseArray,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, Number.eval, NumberField.get, equal, Comparison.eval, Flag.get, Flag.set, Action.eval, *]

theorem structural_theory_comma (helpers : Core.Helpers) (state : Core.State)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3) (fields : state.field < 7) :
    structural helpers state 44 =
      {helpers.matchByte {state with field := state.field + 1} 44 with previousArrayStart := false} := by
  simp [structural, structuralCommands, structuralCases, structuralComma,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, number, Number.eval, NumberField.get, NumberField.set, equal, increase, Comparison.eval,
    Flag.get, Flag.set, Action.eval, matchItem, *]

/-- Only node-ID numbers are replaced by a single zero byte; every ordinary
number starts by emitting its original first digit unchanged. -/
def beginNumber (state : Core.State) (item : Nat) : Core.State :=
  {state with
    numberIsId := state.nodeIdPending
    nodeIdPending := false
    numberValue := if state.nodeIdPending then item - 48 else 0
    numberDigits := true
    mode := .number}

theorem structural_begin_number (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (active : state.matcher.inTheory = true) (digit : 48 ≤ item ∧ item ≤ 57) :
    structural helpers state item =
      {helpers.matchByte (beginNumber state item) (if state.nodeIdPending then 48 else item) with previousArrayStart := false} := by
  have possibilities : item = 48 ∨ item = 49 ∨ item = 50 ∨ item = 51 ∨ item = 52 ∨
      item = 53 ∨ item = 54 ∨ item = 55 ∨ item = 56 ∨ item = 57 := by omega
  cases pending : state.nodeIdPending <;>
    rcases possibilities with h | h | h | h | h | h | h | h | h | h <;> subst item <;>
    simp [structural, structuralCommands, structuralCases, structuralNumber, beginNumber,
      Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace, decimal,
      flag, number, Number.eval, NumberField.set,
      Flag.get, Flag.set, Action.eval, matchItem, *]

end Silver.ImageModel.ScannerNative
