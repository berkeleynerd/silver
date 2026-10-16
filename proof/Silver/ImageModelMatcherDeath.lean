module

public import Silver.ImageModelWideString

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem endString_dead (tables : Native.Tables) (state : Core.State) (kind : Native.Theory)
    (dead : (state.matcher.cells kind).live = false) :
    (((Core.modelHelpers tables).endString state).matcher.cells kind).live = false :=
  matcher_dead tables state.matcher 34 kind dead

theorem endTheory_dead (tables : Native.Tables) (state : Core.State) (kind : Native.Theory)
    (dead : (state.matcher.cells kind).live = false) :
    (((Core.modelHelpers tables).endTheory state).matcher.cells kind).live = false := by
  simp only [Core.modelHelpers, Core.State.setTheory, TheoryNative.model]
  split <;> exact matcher_dead tables state.matcher 93 kind dead

def Command.noRevive : Command → Bool
  | .action .liveAll => false
  | .sequence first second | .choose _ first second | .itemBranch _ first second | .modeBranch _ first second =>
      first.noRevive && second.noRevive
  | .switchItem body | .switchMode body | .otherwise body => body.noRevive
  | _ => true

theorem Action.dead (action : Action) (noReset : action ≠ .liveAll)
    (tables : Native.Tables) (call : StructuralCall) (kind : Native.Theory)
    (callDead : ∀ state byte, (state.matcher.cells kind).live = false → ((call state byte).matcher.cells kind).live = false)
    (frame : Frame) (dead : (frame.state.matcher.cells kind).live = false) :
    (((action.eval (Core.modelHelpers tables) call frame).state.matcher).cells kind).live = false := by
  cases action with
  | number slot value => cases slot <;> exact dead
  | flag slot value => cases slot <;> exact dead
  | mode | phase | otherTheory | zeroMatched | spaces => exact dead
  | liveAll => exact False.elim (noReset rfl)
  | matchByte value => exact matcher_dead tables frame.state.matcher _ kind dead
  | decoded value =>
      change (((Core.modelHelpers tables).decoded frame.state _).matcher.cells kind).live = false
      rw [decoded_wide]
      exact wide_effect_dead tables frame.state _ kind dead
  | endString => exact endString_dead tables frame.state kind dead
  | endTheory => exact endTheory_dead tables frame.state kind dead
  | structural => exact callDead frame.state frame.item dead

/-- Every checked scanner command except the explicit new-theory reset retains
dead candidates. The only external call premise is the Structural call itself. -/
theorem Command.dead (command : Command) (noReset : command.noRevive = true)
    (tables : Native.Tables) (call : StructuralCall) (kind : Native.Theory)
    (callDead : ∀ state byte, (state.matcher.cells kind).live = false → ((call state byte).matcher.cells kind).live = false)
    (frame : Frame) (dead : (frame.state.matcher.cells kind).live = false) :
    (((command.eval (Core.modelHelpers tables) call frame).frame.state.matcher).cells kind).live = false := by
  induction command generalizing frame with
  | skip | returnNow => exact dead
  | action value =>
      apply Action.dead value _ tables call kind callDead frame dead
      intro eq
      subst value
      contradiction
  | sequence first second ihFirst ihSecond =>
      simp only [Command.noRevive, Bool.and_eq_true] at noReset
      simp only [Command.eval]
      split
      · exact ihFirst noReset.1 frame dead
      · exact ihSecond noReset.2 _ (ihFirst noReset.1 frame dead)
  | choose test yes no ihYes ihNo =>
      simp only [Command.noRevive, Bool.and_eq_true] at noReset
      simp only [Command.eval]
      split
      · exact ihYes noReset.1 frame dead
      · exact ihNo noReset.2 frame dead
  | itemBranch choices yes no ihYes ihNo =>
      simp only [Command.noRevive, Bool.and_eq_true] at noReset
      simp only [Command.eval]
      split
      · exact ihYes noReset.1 frame dead
      · exact ihNo noReset.2 frame dead
  | modeBranch choices yes no ihYes ihNo =>
      simp only [Command.noRevive, Bool.and_eq_true] at noReset
      simp only [Command.eval]
      split
      · exact ihYes noReset.1 frame dead
      · exact ihNo noReset.2 frame dead
  | switchItem body ih | switchMode body ih | otherwise body ih => exact ih noReset frame dead

def nestedArrayCommands : Command :=
  .choose (.both (.flag .inTheory) (.number .less (.field .depth) .byteMaximum))
    (.list [increase .depth, matchItem]) fail

theorem openArray_nested_commands (helpers : Core.Helpers) (call : StructuralCall) (frame : Frame)
    (depth : 3 ≤ frame.state.depth) :
    structuralOpenArray.eval helpers call frame = nestedArrayCommands.eval helpers call frame := by
  have one : frame.state.depth ≠ 1 := by omega
  have two : frame.state.depth ≠ 2 := by omega
  simp only [structuralOpenArray, nestedArrayCommands, Command.eval, Test.eval, equal, Number.eval,
    NumberField.get, Comparison.eval, one, two, decide_false, Bool.and_false, Bool.false_and,
    Bool.false_eq_true, ↓reduceIte]

theorem structural_cases_dead (tables : Native.Tables) (frame : Frame) (kind : Native.Theory)
    (depth : 3 ≤ frame.state.depth) (dead : (frame.state.matcher.cells kind).live = false) :
    ((structuralCases.eval (Core.modelHelpers tables) (fun state _ => state) frame).frame.state.matcher.cells kind).live = false := by
  have preserve (command : Command) (noReset : command.noRevive = true) :=
    Command.dead command noReset tables (fun state _ => state) kind (fun _ _ h => h) frame dead
  simp only [structuralCases, Command.eval]
  split
  · exact preserve structuralOpenObject (by decide +kernel)
  split
  · exact preserve structuralCloseObject (by decide +kernel)
  split
  · rw [openArray_nested_commands _ _ frame depth]
    exact preserve nestedArrayCommands (by decide +kernel)
  split
  · exact preserve structuralCloseArray (by decide +kernel)
  split
  · exact preserve structuralColon (by decide +kernel)
  split
  · exact preserve structuralComma (by decide +kernel)
  split
  · exact preserve structuralQuote (by decide +kernel)
  split
  · exact preserve structuralNumber (by decide +kernel)
  split
  · exact preserve structuralLiteral (by decide +kernel)
  exact preserve fail (by decide +kernel)

/-- At an existing theory's depth, no structural byte can execute the sole
candidate reset, which is confined to opening a new top-level theory at depth2. -/
theorem structural_dead (tables : Native.Tables) (state : Core.State) (byte : Nat) (kind : Native.Theory)
    (depth : 3 ≤ state.depth) (dead : (state.matcher.cells kind).live = false) :
    ((structural (Core.modelHelpers tables) state byte).matcher.cells kind).live = false := by
  have body := structural_cases_dead tables ⟨state, byte, 0⟩ kind depth dead
  simp only [structural, structuralCommands, Command.list, List.foldr_cons, List.foldr_nil,
    Command.eval]
  split
  · exact dead
  simp only [Bool.false_eq_true, ↓reduceIte]
  split
  · exact dead
  simp only [Bool.false_eq_true, ↓reduceIte]
  split
  · exact body
  simp only [flag, Command.eval, Action.eval, Flag.set]
  exact body

theorem nonstructural_dead (tables : Native.Tables) (command : Command)
    (noCall : command.noStructural = true) (noReset : command.noRevive = true)
    (call : StructuralCall) (frame : Frame) (kind : Native.Theory)
    (dead : (frame.state.matcher.cells kind).live = false) :
    ((command.eval (Core.modelHelpers tables) call frame).frame.state.matcher.cells kind).live = false := by
  rw [Command.eval_noStructural command noCall _ call (fun state _ => state)]
  exact Command.dead command noReset tables _ kind (fun _ _ h => h) frame dead

theorem number_close_dead (tables : Native.Tables) (frame : Frame) (kind : Native.Theory)
    (depth : 3 ≤ frame.state.depth) (dead : (frame.state.matcher.cells kind).live = false) :
    ((consumeNumberClose.eval (Core.modelHelpers tables) (structural (Core.modelHelpers tables)) frame).frame.state.matcher.cells kind).live = false := by
  by_cases mode : frame.state.mode = .number <;>
    cases isId : frame.state.numberIsId <;> cases digits : frame.state.numberDigits <;>
    simp only [consumeNumberClose, Command.list, List.foldr_cons, List.foldr_nil,
      Command.eval, Test.eval, Flag.get, mode, isId, digits, decide_true, decide_false,
      Bool.false_and, Bool.true_and, Bool.not_false, Bool.not_true, Bool.false_eq_true,
      ↓reduceIte, fail, number, Action.eval, Flag.set, Number.eval, NumberField.set]
  all_goals exact structural_dead tables _ frame.item kind depth dead

theorem number_dead (tables : Native.Tables) (frame : Frame) (kind : Native.Theory)
    (depth : 3 ≤ frame.state.depth) (dead : (frame.state.matcher.cells kind).live = false) :
    ((consumeNumber.eval (Core.modelHelpers tables) (structural (Core.modelHelpers tables)) frame).frame.state.matcher.cells kind).live = false := by
  simp only [consumeNumber, Command.eval]
  split
  · exact number_close_dead tables frame kind depth dead
  split
  · exact nonstructural_dead tables consumeIdDigit (by decide +kernel) (by decide +kernel) _ frame kind dead
  · exact nonstructural_dead tables matchItem (by decide +kernel) (by decide +kernel) _ frame kind dead

/-- Every actual Consume path retains a dead candidate while reading an existing
theory. This includes errors, escapes, token delimiters and the closing bracket. -/
theorem consume_dead (tables : Native.Tables) (state : Core.State) (byte : Nat) (kind : Native.Theory)
    (depth : 3 ≤ state.depth) (dead : (state.matcher.cells kind).live = false) :
    ((consume (Core.modelHelpers tables) state byte).matcher.cells kind).live = false := by
  cases good : state.failed with
  | true => rw [consume_failed _ state byte good]; exact dead
  | false =>
      by_cases full : state.bytes = 9223372036854775807
      · rw [consume_saturated _ state byte good full]; exact dead
      cases mode : state.mode with
      | between =>
          rw [consume_between _ state byte good full mode]
          exact structural_dead tables _ byte kind depth dead
      | string =>
          rw [consume_in_string _ state byte good full mode]
          exact nonstructural_dead tables consumeString (by decide +kernel) (by decide +kernel) _ _ kind dead
      | escape =>
          rw [consume_in_escape _ state byte good full mode]
          exact nonstructural_dead tables consumeEscape (by decide +kernel) (by decide +kernel) _ _ kind dead
      | unicode =>
          rw [consume_in_unicode _ state byte good full mode]
          exact nonstructural_dead tables consumeUnicode (by decide +kernel) (by decide +kernel) _ _ kind dead
      | number =>
          rw [consume_in_atom _ state byte good full (.inl mode)]
          exact number_dead tables _ kind depth dead
      | literal =>
          rw [consume_in_atom _ state byte good full (.inr mode)]
          exact number_dead tables _ kind depth dead

/-- A finite same-theory input segment: each byte is consumed before leaving
the theory's nesting depth. The closing byte may be the final byte of the run.
This is a structural trace condition, not a matching/schema premise. -/
def WithinTheory (tables : Native.Tables) (state : Core.State) (input : List Nat) : Prop :=
  ∀ before byte after, input = before ++ byte :: after →
    3 ≤ (before.foldl (consume (Core.modelHelpers tables)) state).depth

theorem consume_run_dead (tables : Native.Tables) (state : Core.State) (input : List Nat) (kind : Native.Theory)
    (within : WithinTheory tables state input) (dead : (state.matcher.cells kind).live = false) :
    ((input.foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = false := by
  induction input generalizing state with
  | nil => exact dead
  | cons byte rest ih =>
      have depth := within [] byte rest rfl
      have nextDead := consume_dead tables state byte kind depth dead
      apply ih _ _ nextDead
      intro before next after decomposition
      exact within (byte :: before) next after (by simp [decomposition])

theorem dead_selected_theory_fails (tables : Native.Tables) (state : Core.State) (kind : Native.Theory)
    (selected : state.theory = some kind) (dead : (state.matcher.cells kind).live = false) :
    ((Core.modelHelpers tables).endTheory state).failed = true := by
  cases outcome : ((Core.modelHelpers tables).endTheory state).failed with
  | true => rfl
  | false =>
      have accepted := TheoryNative.successful_selected tables (Core.matcher tables) state.theoryView kind selected outcome
      have remains := matcher_dead tables state.matcher 93 kind dead
      have live := accepted.2.2.1
      change ((Core.matcher tables state.matcher 93).cells kind).live = true at live
      rw [remains] at live
      contradiction

end Silver.ImageModel.ScannerNative
