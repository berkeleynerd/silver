module

public import Silver.ImageModelConsumeNative

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- Syntactic frame check: this command never assigns the byte counter.
Helper calls are handled by their independently stated frame equations. -/
def Action.keepsBytes : Action → Bool
  | .number slot _ => slot != .bytes
  | _ => true

def Command.keepsBytes : Command → Bool
  | .action value => value.keepsBytes
  | .sequence first second | .choose _ first second
  | .itemBranch _ first second | .modeBranch _ first second =>
      first.keepsBytes && second.keepsBytes
  | .switchItem body | .switchMode body | .otherwise body => body.keepsBytes
  | _ => true

theorem Action.eval_bytes (tables : Native.Tables) (call : StructuralCall)
    (callBytes : ∀ state item, (call state item).bytes = state.bytes)
    (action : Action) (keeps : action.keepsBytes = true) (frame : Frame) :
    (action.eval (Core.modelHelpers tables) call frame).state.bytes = frame.state.bytes := by
  cases action with
  | number slot value => cases slot <;> simp_all [Action.keepsBytes, Action.eval, NumberField.set]
  | flag slot value => cases slot <;> rfl
  | structural => exact callBytes _ _
  | endString => rfl
  | endTheory => rfl
  | matchByte value => rfl
  | decoded value => rfl
  | mode value | phase value => rfl
  | otherTheory | zeroMatched | liveAll | spaces => rfl

theorem Command.eval_bytes (tables : Native.Tables) (call : StructuralCall)
    (callBytes : ∀ state item, (call state item).bytes = state.bytes)
    (command : Command) (keeps : command.keepsBytes = true) (frame : Frame) :
    (command.eval (Core.modelHelpers tables) call frame).frame.state.bytes = frame.state.bytes := by
  induction command generalizing frame with
  | skip | returnNow => rfl
  | action value => exact Action.eval_bytes tables call callBytes value keeps frame
  | sequence a b ia ib =>
      simp only [Command.keepsBytes, Bool.and_eq_true] at keeps
      simp only [Command.eval]
      split
      · exact ia keeps.1 frame
      · exact (ib keeps.2 _).trans (ia keeps.1 frame)
  | choose test yes no iy ino =>
      simp only [Command.keepsBytes, Bool.and_eq_true] at keeps
      simp only [Command.eval]
      split
      · exact iy keeps.1 frame
      · exact ino keeps.2 frame
  | itemBranch choices yes no iy ino =>
      simp only [Command.keepsBytes, Bool.and_eq_true] at keeps
      simp only [Command.eval]
      split
      · exact iy keeps.1 frame
      · exact ino keeps.2 frame
  | modeBranch modes yes no iy ino =>
      simp only [Command.keepsBytes, Bool.and_eq_true] at keeps
      simp only [Command.eval]
      split
      · exact iy keeps.1 frame
      · exact ino keeps.2 frame
  | switchItem body ih | switchMode body ih | otherwise body ih => exact ih keeps frame

theorem structural_keeps_bytes : structuralCommands.keepsBytes = true := by decide +kernel

theorem structural_bytes (tables : Native.Tables) (state : Core.State) (item : Nat) :
    (structural (Core.modelHelpers tables) state item).bytes = state.bytes :=
  Command.eval_bytes tables (fun state _ => state) (by intros; rfl)
    structuralCommands structural_keeps_bytes ⟨state, item, 0⟩

theorem consume_cases_keep_bytes : consumeCases.keepsBytes = true := by decide +kernel

theorem consume_progress (tables : Native.Tables) (state : Core.State) (item : Nat)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807) :
    (consume (Core.modelHelpers tables) state item).bytes = state.bytes + 1 := by
  have tail := Command.eval_bytes tables (structural (Core.modelHelpers tables))
    (structural_bytes tables) (.sequence (.switchMode consumeCases) .skip)
    (by simpa [Command.keepsBytes] using consume_cases_keep_bytes)
    ⟨{state with bytes := state.bytes + 1}, item, 0⟩
  simpa only [consume, consumeCommands, Command.list, List.foldr_cons, List.foldr_nil,
    Command.eval, Test.eval, Flag.get, good, Bool.false_eq_true, ↓reduceIte,
    Number.eval, NumberField.get, Comparison.eval, room, decide_false,
    increase, number, Action.eval, NumberField.set] using tail

theorem consume_fold_failed (helpers : Core.Helpers) (state : Core.State) (input : List Nat)
    (failed : state.failed = true) : input.foldl (consume helpers) state = state := by
  induction input with
  | nil => rfl
  | cons item rest ih =>
      rw [List.foldl_cons, consume_failed helpers state item failed]
      exact ih

/-- A successful final state entails that every consumed prefix was successful. -/
theorem consume_prefix_good (helpers : Core.Helpers) (state : Core.State)
    (initial rest : List Nat)
    (good : ((initial ++ rest).foldl (consume helpers) state).failed = false) :
    (initial.foldl (consume helpers) state).failed = false := by
  rw [List.foldl_append] at good
  cases failed : (initial.foldl (consume helpers) state).failed with
  | false => rfl
  | true =>
      rw [consume_fold_failed helpers _ rest failed, failed] at good
      contradiction

theorem consume_success_start (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (good : (consume helpers state item).failed = false) :
    state.failed = false ∧ state.bytes ≠ 9223372036854775807 := by
  have before : state.failed = false := by
    cases failed : state.failed with
    | false => rfl
    | true =>
        rw [consume_failed helpers state item failed, failed] at good
        contradiction
  refine ⟨before, ?_⟩
  intro full
  rw [consume_saturated helpers state item before full] at good
  contradiction

/-- This connects Finish's byte count to the complete successful consumed list;
no equality between a scanner count and input length is assumed. -/
theorem consume_fold_bytes (tables : Native.Tables) (state : Core.State) (input : List Nat)
    (good : (input.foldl (consume (Core.modelHelpers tables)) state).failed = false) :
    (input.foldl (consume (Core.modelHelpers tables)) state).bytes = state.bytes + input.length := by
  induction input generalizing state with
  | nil => simp
  | cons item rest ih =>
      have firstGood : (consume (Core.modelHelpers tables) state item).failed = false :=
        consume_prefix_good (Core.modelHelpers tables) state [item] rest good
      have before := consume_success_start (Core.modelHelpers tables) state item firstGood
      rw [List.foldl_cons, ih _ good, consume_progress tables state item before.1 before.2]
      simp [Nat.add_comm, Nat.add_left_comm]

theorem finish_bytes (state : Core.State) :
    (FinishNative.model state.finishView).bytes = state.bytes := by
  simp only [FinishNative.model]
  split <;> try rfl
  split <;> try rfl
  split <;> rfl

theorem finish_success_good (state : Core.State)
    (accepted : (FinishNative.model state.finishView).kind ≠ .invalid) :
    state.failed = false := by
  cases failed : state.failed with
  | false => rfl
  | true =>
      simp [FinishNative.model, FinishNative.Test.eval, Core.State.finishView, failed,
        FinishNative.initial] at accepted

theorem successful_plan_bytes (tables : Native.Tables) (input : List Nat)
    (accepted : (FinishNative.model
      (input.foldl (consume (Core.modelHelpers tables)) {}).finishView).kind ≠ .invalid) :
    (FinishNative.model
      (input.foldl (consume (Core.modelHelpers tables)) {}).finishView).bytes = input.length := by
  rw [finish_bytes, consume_fold_bytes tables {} input (finish_success_good _ accepted)]
  exact Nat.zero_add input.length

end Silver.ImageModel.ScannerNative
