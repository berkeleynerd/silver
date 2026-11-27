module

public import Silver.ApplicationPackageCompletionDomains

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrames ApplicationPackageRoutineFrame

/-- Between output appends the original code need not have a valid state:
malformed metadata may contribute an empty interval. Native field types and
the complete imported Valid_State domain are nevertheless preserved. -/
structure OutputFrame (frame : ParserState) : Prop where
  typed : StateType frame
  imported : ValidityNative.ImportedTypes frame

theorem OutputFrame.of_reader {text : Source} {frame : ParserState}
    (valid : ValidText text) (framed : ReaderFrame text frame) : OutputFrame frame :=
  ⟨framed.typed, framed.imported_types valid⟩

theorem OutputFrame.append_domain {frame : ParserState} (prior : OutputFrame frame) : AppendFrame frame :=
  ⟨prior.typed.scalarCount, prior.typed.booleanCount, prior.imported⟩

theorem append_output_frame (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (formal : PackageBindings.Formal) (bounds : formal.bounds.Bounded)
    (frame result : ParserState) (prior : OutputFrame frame)
    (read : appendOutput (declarationReaders reader calls) text formal frame = some result) :
    OutputFrame result := by
  unfold appendOutput at read
  dsimp only at read
  split at read
  · cases read; exact prior
  · split at read
    · contradiction
    · split at read
      · contradiction
      · cases read
        exact ⟨append_formal_typed prior.typed _ _ bounds _,
          (append_formal_frame prior.append_domain _ _ _).imported⟩

theorem append_outputs_frame (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (info : PackageBindings.Metadata) (bounds : ParameterBounds info)
    (indices : List Nat) (frame result : ParserState) (prior : OutputFrame frame)
    (read : appendOutputs (declarationReaders reader calls) text info indices frame = some result) :
    OutputFrame result := by
  induction indices generalizing frame with
  | nil => cases read; exact prior
  | cons index rest ih =>
    simp only [appendOutputs, Option.bind_eq_some_iff] at read
    obtain ⟨next, first, remaining⟩ := read
    exact ih next (append_output_frame reader calls text _ (parameter_bounds bounds index)
      frame next prior first) remaining

theorem OutputFrame.checked {text : Source} {frame : ParserState} (prior : OutputFrame frame)
    (checked : stateValid text frame = true) : ReaderFrame text frame := ⟨prior.typed, checked⟩

end Silver.ApplicationPackageCompletion
