module

public import Silver.ApplicationPackageBodyEntry
public import Silver.ApplicationPackageCompletionTotal

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose ApplicationAdmission ApplicationPackageDeclarations ApplicationPackageObjectRows
open ApplicationPackageExportRows ApplicationPackageFrameLayout

structure RoutineRead where
  before : UnitState
  result : CompletionResult

def RoutineRead.after (row : RoutineRead) : UnitState := ⟨row.result.globals, row.result.info, .routines⟩

/-- Every completion selected by the package body's original bounded loop,
in execution order, followed by the footer that returned the result. -/
inductive RoutineHistory (calls : UnitCalls) (text : Source) : UnitState → List RoutineRead → BodyResult → Prop where
  | finished {before : UnitState} {result : BodyResult} (phase : before.phase = .routines)
      (allRead : before.info.routines.length ≤ before.info.completed)
      (footer : unitStep calls text {before with phase := .footer} = .returned result) :
      RoutineHistory calls text before [] result
  | added {row : RoutineRead} {later : List RoutineRead} {result : BodyResult}
      (phase : row.before.phase = .routines) (pending : row.before.info.completed < row.before.info.routines.length)
      (read : calls.completionAt text row.before.globals row.before.info = row.result)
      (advances : row.before.globals.position < row.result.globals.position)
      (rest : RoutineHistory calls text row.after later result) :
      RoutineHistory calls text row.before (row :: later) result

private theorem footer_returns {calls : UnitCalls} {text : Source} {state : UnitState} {result : BodyResult}
    (run : UnitExecution (unitStep calls text) {state with phase := .footer} result) :
    unitStep calls text {state with phase := .footer} = .returned result := by
  cases run with
  | returned read => exact read
  | continued step _ => simp only [unitStep, reduceCtorEq] at step

theorem unitExecution_routines {calls : UnitCalls} {text : Source} {state : UnitState} {result : BodyResult}
    (run : UnitExecution (unitStep calls text) state result) (accepted : result.accepted = true)
    (phase : state.phase = .routines) : ∃ rows, RoutineHistory calls text state rows result := by
  induction run with
  | returned step =>
    simp only [unitStep, phase] at step
    split at step
    · split at step
      · cases step
        contradiction
      · contradiction
    · contradiction
  | @continued before after result step tail ih =>
    simp only [unitStep, phase] at step
    split at step
    · rename_i pending
      split at step
      · contradiction
      · rename_i moved
        cases step
        obtain ⟨rows, rest⟩ := ih accepted rfl
        let row : RoutineRead := ⟨before, calls.completionAt text before.globals before.info⟩
        exact ⟨row :: rows, .added (row := row) phase pending rfl (Nat.lt_of_not_ge moved) rest⟩
    · rename_i allRead
      cases step
      exact ⟨[], .finished phase (Nat.le_of_not_gt allRead) (footer_returns tail)⟩

def bodyReaders (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls) : UnitCalls :=
  unitReaders reader (readCompletion reader calls)

def RoutineRead.SourceLayout (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (row : RoutineRead) : Prop :=
  ∃ frames : CompletionFrames (declarationReaders reader calls) text row.before.globals row.before.info row.result,
    let context := completionContextOf (declarationReaders reader calls) frames.outputs.body
    (layout text.length frames.signature.info context).Context frames.signature.info.stateSchema context.analysis

private theorem frame_at_cursor {states : List PackageBindings.StateDeclaration} {before after : ParserState}
    (frame : StateFrame states before) (kept : after = {before with position := after.position})
    (progress : before.position < after.position) : StateFrame states after := by
  have integers := congrArg ParserState.scalarNames kept
  have booleans := congrArg ParserState.booleanNames kept
  refine ⟨reframe frame.order integers booleans (Nat.le_of_lt progress), ?_, ?_⟩
  · exact fun row member => Nat.lt_trans (frame.statesBefore row member) progress
  · rw [integers]
    exact frame.scalarFields

private theorem routine_layout {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {row : RoutineRead}
    (read : (bodyReaders reader calls).completionAt text row.before.globals row.before.info = row.result)
    (advanced : row.before.globals.position < row.result.globals.position)
    (initial : StateFrame row.before.info.states row.before.globals)
    (capacity : row.before.globals.scalarNames.length ≤ ScalarExpression.maxBindings) :
    row.SourceLayout reader calls text ∧ row.result.info.states = row.before.info.states ∧
      StateFrame row.after.info.states row.after.globals ∧
      row.after.globals.scalarNames.length ≤ ScalarExpression.maxBindings := by
  have actual : readCompletion reader calls text row.before.globals row.before.info = row.result := read
  have evaluated := (readCompletion_eq reader calls text row.before.globals row.before.info).trans (congrArg some actual)
  have present : row.result.globals.position ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advanced)
  obtain ⟨frames⟩ := packageCompletionFuel_frames evaluated present
  have signed : readSignature text row.before.globals row.before.info true = frames.signature := frames.signed
  have states : frames.signature.info.states = row.before.info.states := signed ▸ readSignature_states ..
  obtain ⟨kept, progress, same⟩ := completionBody_globals frames.executed present
  have table := same.trans states
  refine ⟨⟨frames, frames.source_layout present initial capacity⟩, table, ?_, ?_⟩
  · change StateFrame row.result.info.states row.result.globals
    rw [table]
    exact frame_at_cursor initial kept progress
  · change row.result.globals.scalarNames.length ≤ _
    have integers := congrArg ParserState.scalarNames kept
    rw [integers]
    exact capacity

/-- Each original routine receives its own actual declaration frame and the
persistent state table from entry to the routine segment. -/
theorem RoutineHistory.source_layouts {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {before : UnitState} {rows : List RoutineRead} {result : BodyResult}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (initial : StateFrame before.info.states before.globals)
    (capacity : before.globals.scalarNames.length ≤ ScalarExpression.maxBindings) :
    result.info.states = before.info.states ∧ ∀ row ∈ rows,
      row.before.info.states = before.info.states ∧ row.SourceLayout reader calls text := by
  induction history with
  | finished phase allRead footer =>
    dsimp only [unitStep] at footer
    cases footer
    exact ⟨rfl, by simp⟩
  | @added row later result phase pending read advanced rest ih =>
    obtain ⟨layout, same, frame, size⟩ := routine_layout read advanced initial capacity
    obtain ⟨final, following⟩ := ih frame size
    refine ⟨final.trans same, ?_⟩
    intro seen member
    rcases List.mem_cons.mp member with rfl | tail
    · exact ⟨rfl, layout⟩
    · obtain ⟨states, checked⟩ := following seen tail
      exact ⟨states.trans same, checked⟩

end Silver.ApplicationPackageBodies
