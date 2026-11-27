module

public import Silver.ApplicationPackageCompletionSourceLayout
public import Silver.ApplicationPackageDeclarationsSignatureCursor
public import Silver.ApplicationPackageDeclarationsSignatureMetadataTypes
public import Silver.ApplicationPackageDeclarationsObjectFrameDomains
public import Silver.ApplicationPackageDeclarationsObjectInitializerBounds
public import Silver.ApplicationPackageRoutineFrameContract
public import Silver.FunctionDeclarationBodyDomains
public import Silver.PredicateAdapterEnvironment
public import Silver.ApplicationPackageRecursiveDomain

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrames

set_option backward.dsimp.instances true

/-- The original Context_Of record, with Completion's original declaration
prefix reset. Its dynamic-name fields are retained rather than reconstructed. -/
def nativeContext (state : InitializationFrame) : Predicate.Native.Context :=
  {Adapter.contextOf ⟨state.frame, state.initialized, false⟩ with declarationCount := 0}

theorem context_model (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (state : InitializationFrame) :
    (nativeContext state).model = completionContextOf (declarationReaders reader calls) state := rfl

theorem context_valid {text : Source} (state : InitializationFrame)
    (framed : ReaderFrame text state.frame) : Predicate.Native.ValidContext text (nativeContext state) :=
  FunctionDeclarationNative.body_context_valid text state.frame 0 framed.native (Nat.zero_le _)

theorem body_domain {text : Source} (state : InitializationFrame)
    (framed : ReaderFrame text state.frame) :
    Recursive.ScanDomain text (nativeContext state).model
      (Predicate.bodyOf ⟨state.frame, state.initialized, false⟩) := by
  have initial := FunctionDeclarationNative.body_initial_valid text state.frame 0 framed.native
  exact ⟨initial.1, initial.2.1, initial.2.2.1, initial.2.2.2⟩

theorem initial_flow_valid {text : Source} (state : InitializationFrame)
    (framed : ReaderFrame text state.frame) :
    Predicate.Native.ValidFlow (nativeContext state)
      (ActiveFlow.initial (nativeContext state).scalarNames
        (initialFacts (nativeContext state).model.hasArguments)) :=
  (FunctionDeclarationNative.body_initial_valid text state.frame 0 framed.native).2.2

/-- The Signature output metadata is typed even on partial failure. The
subsequent Routine_Frame invocation uses the original globals and the bounded
header position, without any semantic metadata invariant. -/
theorem entry_reader (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (valid : ValidText text) (globals : ParserState)
    (framed : ReaderFrame text globals) (info : PackageBindings.Metadata) (typed : info.Typed) :
    let signature := readSignature text globals info true
    ReaderFrame text ((declarationReaders reader calls).routineFrame text globals signature.info
      (info.completed + 1) signature.header.position) := by
  exact ApplicationPackageRoutineFrame.routine_frame_reader globals framed _
    (ApplicationPackageRoutineFrame.parameterBounds_of_typed
      (readSignature_completion_typed valid globals framed info typed)) _ _
    (readSignature_header_cursor text globals info true)

theorem local_step_frame (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (state result : InitializationFrame)
    (framed : ReaderFrame text state.frame)
    (read : localStep (declarationReaders reader calls) text info item state = .continued result) :
    ReaderFrame text result.frame := by
  unfold localStep at read
  dsimp only at read
  split at read
  · contradiction
  · split at read
    · contradiction
    · split at read
      · contradiction
      · rename_i advanced
        cases read
        apply objectStep_reader_frame reader valid state.frame framed info true
        change ¬ ((objectStep (modelObjectCalls reader) text state.frame info true).frame.position ≤
          state.frame.position) at advanced
        omega

theorem local_finish_frame (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (state result : InitializationFrame) (framed : ReaderFrame text state.frame)
    (read : localStep (declarationReaders reader calls) text info item state = .finished result) :
    ReaderFrame text result.frame := by
  unfold localStep at read
  dsimp only at read
  split at read
  · cases read; exact framed
  · split at read
    · contradiction
    · split at read <;> contradiction

theorem locals_frame (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (fuel : Nat) (state result : InitializationFrame)
    (framed : ReaderFrame text state.frame)
    (read : localsFuel (localStep (declarationReaders reader calls) text info item) fuel state = some (some result)) :
    ReaderFrame text result.frame := by
  induction fuel generalizing state with
  | zero => contradiction
  | succ fuel ih =>
    simp only [localsFuel] at read
    cases chosen : localStep (declarationReaders reader calls) text info item state with
    | failed => simp only [chosen, Option.some.injEq] at read; cases read
    | finished finalState =>
      simp only [chosen, Option.some.injEq] at read
      cases read
      exact local_finish_frame reader calls info item state _ framed chosen
    | continued next =>
      simp only [chosen] at read
      exact ih next (local_step_frame reader calls valid info item state next framed chosen) read

theorem output_initializer_frame (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (info : PackageBindings.Metadata) (formal : PackageBindings.Formal)
    (state result : InitializationFrame) (framed : ReaderFrame text state.frame)
    (read : outputInitializer (declarationReaders reader calls) text info formal state = some result) :
    ReaderFrame text result.frame := by
  unfold outputInitializer at read
  dsimp only at read
  split at read
  · cases read; exact framed
  · split at read
    · contradiction
    · split at read
      · contradiction
      · split at read
        · contradiction
        · cases read
          exact framed.at_position (fixedAfter_result_bound text _ ";" false (by decide))

theorem output_initializers_frame (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (info : PackageBindings.Metadata) (indices : List Nat)
    (state result : InitializationFrame) (framed : ReaderFrame text state.frame)
    (read : outputInitializers (declarationReaders reader calls) text info indices state = some result) :
    ReaderFrame text result.frame := by
  induction indices generalizing state with
  | nil => cases read; exact framed
  | cons index rest ih =>
    simp only [outputInitializers, Option.bind_eq_some_iff] at read
    obtain ⟨next, first, remaining⟩ := read
    exact ih next (output_initializer_frame reader calls info _ state next framed first) remaining

end Silver.ApplicationPackageCompletion
