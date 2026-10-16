module

public import Silver.ImageModelTokenScan

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.ScannerNative

theorem structural_root_open (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (depth : state.depth = 0) (phase : state.phase = .beforeRoot) :
    structural helpers state 123 = {state with depth := 1, phase := .rootKey, previousArrayStart := false} := by
  simp [structural, structuralCommands, structuralCases, structuralOpenObject,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, number, Number.eval, NumberField.get, NumberField.set, equal, Comparison.eval,
    Flag.get, Flag.set, Action.eval, notId, depth, phase]

theorem structural_root_colon (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (depth : state.depth = 1) (phase : state.phase = .rootColon) :
    structural helpers state 58 = {state with phase := .rootList, previousArrayStart := false} := by
  simp [structural, structuralCommands, structuralCases, structuralColon,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, Number.eval, NumberField.get, equal, Comparison.eval,
    Flag.get, Flag.set, Action.eval, notId, depth, phase]

theorem structural_root_list (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (depth : state.depth = 1) (phase : state.phase = .rootList) :
    structural helpers state 91 = {state with depth := 2, phase := .firstTheory, previousArrayStart := true} := by
  simp [structural, structuralCommands, structuralCases, structuralOpenArray,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, number, Number.eval, NumberField.get, NumberField.set, equal, Comparison.eval,
    Flag.get, Flag.set, Action.eval, notId, depth, phase]

theorem structural_theory_separator (helpers : Core.Helpers) (state : Core.State)
    (depth : state.depth = 2) (phase : state.phase = .theorySeparator) :
    structural helpers state 44 = {state with phase := .nextTheory, previousArrayStart := false} := by
  simp [structural, structuralCommands, structuralCases, structuralComma,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, Number.eval, NumberField.get, equal, Comparison.eval,
    Flag.set, Action.eval, depth, phase]

theorem structural_root_list_close (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (depth : state.depth = 2)
    (phase : state.phase = .firstTheory ∨ state.phase = .theorySeparator) :
    structural helpers state 93 = {state with depth := 1, phase := .rootEnd, previousArrayStart := false} := by
  rcases phase with phase | phase <;>
    simp [structural, structuralCommands, structuralCases, structuralCloseArray,
      Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
      flag, number, Number.eval, NumberField.get, NumberField.set, equal, Comparison.eval,
      Flag.get, Flag.set, Action.eval, notId, depth, phase]

theorem structural_root_close (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (depth : state.depth = 1) (phase : state.phase = .rootEnd) :
    structural helpers state 125 = {state with depth := 0, phase := .afterRoot, previousArrayStart := false} := by
  simp [structural, structuralCommands, structuralCases, structuralCloseObject,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, number, Number.eval, NumberField.get, NumberField.set, equal, Comparison.eval,
    Flag.get, Flag.set, Action.eval, notId, depth, phase]

theorem structural_nested_comma (helpers : Core.Helpers) (state : Core.State)
    (active : state.matcher.inTheory = true) (depth : 3 < state.depth) :
    structural helpers state 44 = {helpers.matchByte state 44 with previousArrayStart := false} := by
  have two : state.depth ≠ 2 := by omega
  have three : state.depth ≠ 3 := by omega
  simp [structural, structuralCommands, structuralCases, structuralComma,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, Number.eval, NumberField.get, equal, Comparison.eval, Flag.get, Flag.set,
    Action.eval, matchItem, active, two, three]

theorem structural_nested_colon (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true) (depth : 3 ≤ state.depth) :
    structural helpers state 58 = {helpers.matchByte state 58 with previousArrayStart := false} := by
  have one : state.depth ≠ 1 := by omega
  simp [structural, structuralCommands, structuralCases, structuralColon,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, Number.eval, NumberField.get, equal, Comparison.eval, Flag.get, Flag.set,
    Action.eval, matchItem, active, notId, one]

theorem structural_nested_object_open (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (depth : 3 ≤ state.depth) (room : state.depth < 9223372036854775807) :
    structural helpers state 123 =
      {helpers.matchByte {state with depth := state.depth + 1} 123 with previousArrayStart := false} := by
  have zero : state.depth ≠ 0 := by omega
  simp [structural, structuralCommands, structuralCases, structuralOpenObject,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, number, Number.eval, NumberField.get, NumberField.set, equal, increase, Comparison.eval,
    Flag.get, Flag.set, Action.eval, matchItem, active, notId, zero, room]

theorem structural_nested_object_close (helpers : Core.Helpers) (state : Core.State)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true) (depth : 3 < state.depth) :
    structural helpers state 125 =
      {helpers.matchByte {state with depth := state.depth - 1} 125 with previousArrayStart := false} := by
  have one : state.depth ≠ 1 := by omega
  simp [structural, structuralCommands, structuralCases, structuralCloseObject,
    Command.list, Command.eval, Test.eval, Choice.accepts, CharacterValue.eval, whitespace,
    flag, number, Number.eval, NumberField.get, NumberField.set, equal, decrease, Comparison.eval,
    Flag.get, Flag.set, Action.eval, matchItem, active, notId, one, depth]

end Silver.ImageModel.ScannerNative
