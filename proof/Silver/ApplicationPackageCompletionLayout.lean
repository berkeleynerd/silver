module

public import Silver.ApplicationPackageFormalLayout

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Predicate ApplicationPackageObjectRows ApplicationPackageFormalStorage ApplicationPackageFrameLayout

def beginOutputs (calls : CompletionCalls) (text : Source) (locals : InitializationFrame) : InitializationFrame :=
  {locals with frame := {locals.frame with position := calls.takeToken text locals.frame.position (.word "begin")}}

structure OutputFrames (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (locals : InitializationFrame) where
  initialized : InitializationFrame
  completed : ParserState
  read : outputInitializers calls text info (formalIndices item) (beginOutputs calls text locals) = some initialized
  installed : appendOutputs calls text info (formalIndices item) initialized.frame = some completed

def OutputFrames.body {calls text info item locals} (frames : OutputFrames calls text info item locals) : InitializationFrame :=
  {frames.initialized with frame := frames.completed}

/-- Positive completion exposes the actual result of each output pass and the
exact declaration frame supplied to the native body. -/
theorem completionOutputs_frames {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : PackageBindings.Metadata} {index : Nat} {item : PackageBindings.Routine} {locals : InitializationFrame}
    {returned : CompletionResult} (actual : completionOutputs calls text globals info index item locals = returned)
    (accepted : returned.globals.position ≠ 0) :
    ∃ frames : OutputFrames calls text info item locals,
      completionBody calls text globals info index item frames.body = returned := by
  dsimp only [completionOutputs] at actual
  split at actual
  · cases actual; exact False.elim (accepted rfl)
  · rename_i initialized read
    split at actual
    · cases actual; exact False.elim (accepted rfl)
    · rename_i completed stored
      exact ⟨⟨initialized, completed, read, stored⟩, actual⟩

theorem LocalObjects.at_begin {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {before after : InitializationFrame} {rows : List LocalObject}
    (history : LocalObjects calls text info item before rows after) :
    calls.takeToken text after.frame.position (.word "begin") ≠ 0 := by
  induction history with
  | finished atBegin => exact atBegin
  | added _ _ _ _ _ ih => exact ih

private theorem completionBody_cursor {calls : CompletionCalls}
    (validState : calls.validState = ApplicationPackageFrames.stateValid) {text : Source} {globals : ParserState}
    {info : PackageBindings.Metadata} {index : Nat} {item : PackageBindings.Routine} {state : InitializationFrame}
    (accepted : (completionBody calls text globals info index item state).globals.position ≠ 0) :
    state.frame.position ≤ text.length + 1 := by
  have checked : calls.validState text state.frame = true := by
    dsimp only [completionBody] at accepted
    split at accepted
    · assumption
    · exact False.elim (accepted rfl)
  rw [validState] at checked
  simp only [ApplicationPackageFrames.stateValid, Bool.and_eq_true, decide_eq_true_eq, and_assoc] at checked
  exact checked.1

theorem OutputFrames.layout {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {locals : InitializationFrame} (frames : OutputFrames calls text info item locals)
    (prior : LocalFrame info.states (chosen true info (formalIndices item)) locals.frame)
    (atBegin : calls.takeToken text locals.frame.position (.word "begin") ≠ 0)
    (sourceBegin : calls.takeToken text locals.frame.position (.word "begin") =
      tokenAfter text locals.frame.position (.word "begin"))
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    (sourceContext : calls.contextOf ⟨frames.completed, frames.initialized.initialized, false⟩ =
      contextOf ⟨frames.completed, frames.initialized.initialized, false⟩)
    (bounded : frames.completed.position ≤ text.length + 1)
    (capacity : frames.completed.scalarNames.length ≤ ArrayBindings.scalarLimit) :
    let context := completionContextOf calls frames.body
    (layout text.length info context).Context info.stateSchema context.analysis := by
  have beginPresent : fixedAfter text locals.frame.position "begin" true ≠ 0 := by
    rw [sourceBegin] at atBegin
    exact atBegin
  have later : locals.frame.position ≤ (beginOutputs calls text locals).frame.position := by
    change _ ≤ calls.takeToken text locals.frame.position (.word "begin")
    rw [sourceBegin]
    exact Nat.le_of_lt (fixed_window (by decide) beginPresent).1
  have atStart : LocalFrame info.states (chosen true info (formalIndices item)) (beginOutputs calls text locals).frame :=
    prior.reposition later
  have initialized := atStart.initializers frames.read
  have stored := outputs_stored append text info _ frames.installed
  have grounded : completionContextOf calls frames.body =
      {contextOf ⟨frames.completed, frames.initialized.initialized, false⟩ with declarationCount := 0} :=
    congrArg (fun value : ParseContext => {value with declarationCount := 0}) sourceContext
  dsimp only
  rw [grounded]
  exact initialized.outputs_context ⟨frames.completed, frames.initialized.initialized, false⟩ text.length 0 stored bounded capacity

/-- Take the frame from the original accepted completion, including a possibly
empty output pass. Its source bound is proved by the actual Valid_State branch.
The remaining scalar capacity is the native table's representation bound. -/
theorem completionOutputs_layout {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : PackageBindings.Metadata} {index : Nat} {item : PackageBindings.Routine} {locals : InitializationFrame}
    {returned : CompletionResult} (actual : completionOutputs calls text globals info index item locals = returned)
    (accepted : returned.globals.position ≠ 0)
    (prior : LocalFrame info.states (chosen true info (formalIndices item)) locals.frame)
    (atBegin : calls.takeToken text locals.frame.position (.word "begin") ≠ 0)
    (take : calls.takeToken = tokenAfter) (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    (validState : calls.validState = ApplicationPackageFrames.stateValid) (context : calls.contextOf = Predicate.contextOf) :
    ∃ frames : OutputFrames calls text info item locals,
      completionBody calls text globals info index item frames.body = returned ∧
      (frames.completed.scalarNames.length ≤ ArrayBindings.scalarLimit →
        let body := completionContextOf calls frames.body
        (layout text.length info body).Context info.stateSchema body.analysis) := by
  obtain ⟨frames, executed⟩ := completionOutputs_frames actual accepted
  refine ⟨frames, executed, fun capacity => ?_⟩
  have bounded := completionBody_cursor validState (executed ▸ accepted)
  exact frames.layout prior atBegin (by rw [take]) append (by rw [context]) bounded capacity

end Silver.ApplicationPackageBodies
