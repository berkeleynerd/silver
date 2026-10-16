module

public import Silver.ImageModelNumberScan

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.ScannerNative

theorem consume_between (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .between) :
    consume helpers state item = structural helpers (counted state) item := by
  rw [consume_dispatch helpers state item good room]
  simp [consumeCases, Command.eval, counted, mode, Action.eval]

/-- The context captured at a string's opening quote depends on its actual
array position and enclosing theory field, before later bytes are decoded. -/
def quoteContext (state : Core.State) : Core.State :=
  {state with
    isTag := state.previousArrayStart
    isKey := decide (state.depth = 1)
    isName := decide (state.depth = 3) && decide (state.field = 4)
    isTheoryTag := decide (state.depth = 3) && decide (state.field = 0)
    name := ⟨0, fun _ => 32⟩
    mode := .string}

theorem structural_quote (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false)
    (allowed : state.matcher.inTheory = true ∨ (state.depth = 1 ∧ state.phase = .rootKey)) :
    structural helpers state 34 = {helpers.matchByte (quoteContext state) 34 with previousArrayStart := false} := by
  rcases allowed with active | ⟨depth, phase⟩ <;>
    simp [structural, structuralCommands, structuralCases, structuralQuote, Command.list, Command.eval,
      Test.eval, Choice.accepts, CharacterValue.eval, whitespace, flag, number,
      Number.eval, NumberField.get, NumberField.set, equal, Comparison.eval, Flag.get, Flag.set,
      Action.eval, matchItem, quoteContext, *]

/-- Whitespace is semantically absent between tokens; it still contributes one
original byte through Consume before Structural returns. -/
theorem structural_whitespace (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (space : item = 32 ∨ item = 9 ∨ item = 10 ∨ item = 13) : structural helpers state item = state := by
  rcases space with h | h | h | h <;> subst item <;>
    simp [structural, structuralCommands, Command.list, Command.eval, Test.eval,
      whitespace, Choice.accepts, CharacterValue.eval]

theorem consume_whitespace (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (mode : state.mode = .between) (space : item = 32 ∨ item = 9 ∨ item = 10 ∨ item = 13) :
    consume helpers state item = counted state := by
  rw [consume_between helpers state item good room mode, structural_whitespace helpers _ item space]

end Silver.ImageModel.ScannerNative
