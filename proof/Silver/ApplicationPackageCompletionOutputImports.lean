module

public import Silver.ApplicationPackageCompletionLocalImports

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrames ApplicationPackageNames

set_option backward.dsimp.instances true

theorem outputInitializer_congr (actual model : CompletionCalls) (text : Source)
    (info : PackageBindings.Metadata) (formal : PackageBindings.Formal) (state : InitializationFrame)
    (validEq : actual.validName text formal.bodyName = model.validName text formal.bodyName)
    (skipEq : actual.skipAt text state.frame.position = model.skipAt text state.frame.position)
    (nameEq : actual.nameAfter text (model.skipAt text state.frame.position) =
      model.nameAfter text (model.skipAt text state.frame.position))
    (sameEq : actual.sameName text
      ⟨model.skipAt text state.frame.position, model.nameAfter text (model.skipAt text state.frame.position)⟩
      formal.bodyName = model.sameName text
      ⟨model.skipAt text state.frame.position, model.nameAfter text (model.skipAt text state.frame.position)⟩
      formal.bodyName)
    (takeEq : actual.takeToken text (model.nameAfter text (model.skipAt text state.frame.position)) (.symbol ":=") =
      model.takeToken text (model.nameAfter text (model.skipAt text state.frame.position)) (.symbol ":="))
    (contextEq : actual.contextOf ⟨state.frame, false, false⟩ = model.contextOf ⟨state.frame, false, false⟩)
    (flowEq : let context := {model.contextOf ⟨state.frame, false, false⟩ with declarationCount := 0}
      actual.initialFlow context = model.initialFlow context)
    (actualEq : let first := model.takeToken text (model.nameAfter text (model.skipAt text state.frame.position)) (.symbol ":=")
      let context := {model.contextOf ⟨state.frame, false, false⟩ with declarationCount := 0}
      let parameter : FunctionBindings.Formal := ⟨formal.bodyName.first, formal.bodyName.after, formal.kind, formal.bounds, 0⟩
      actual.actualAfter text context first (model.initialFlow context) parameter =
        model.actualAfter text context first (model.initialFlow context) parameter)
    (readsEq : let first := model.takeToken text (model.nameAfter text (model.skipAt text state.frame.position)) (.symbol ":=")
      let context := {model.contextOf ⟨state.frame, false, false⟩ with declarationCount := 0}
      let parameter : FunctionBindings.Formal := ⟨formal.bodyName.first, formal.bodyName.after, formal.kind, formal.bounds, 0⟩
      let after := model.actualAfter text context first (model.initialFlow context) parameter
      actual.stateReads text context info first after = model.stateReads text context info first after)
    (semiEq : let first := model.takeToken text (model.nameAfter text (model.skipAt text state.frame.position)) (.symbol ":=")
      let context := {model.contextOf ⟨state.frame, false, false⟩ with declarationCount := 0}
      let parameter : FunctionBindings.Formal := ⟨formal.bodyName.first, formal.bodyName.after, formal.kind, formal.bounds, 0⟩
      let after := model.actualAfter text context first (model.initialFlow context) parameter
      actual.takeToken text after (.symbol ";") = model.takeToken text after (.symbol ";")) :
    outputInitializer actual text info formal state = outputInitializer model text info formal state := by
  unfold outputInitializer
  split
  · rfl
  · rw [validEq]
    split
    · rfl
    · dsimp only
      rw [skipEq, nameEq, sameEq]
      split
      · rfl
      · rw [takeEq, contextEq, flowEq, actualEq, readsEq, semiEq]

theorem outputInitializers_congr {P : InitializationFrame → Prop}
    (actual model : CompletionCalls) (text : Source) (info : PackageBindings.Metadata)
    (same : ∀ index state, P state → outputInitializer actual text info (info.parameterAt index) state =
      outputInitializer model text info (info.parameterAt index) state)
    (preserved : ∀ index state next, P state →
      outputInitializer model text info (info.parameterAt index) state = some next → P next)
    (indices : List Nat) (state : InitializationFrame) (prior : P state) :
    outputInitializers actual text info indices state = outputInitializers model text info indices state := by
  induction indices generalizing state with
  | nil => rfl
  | cons index rest ih =>
    simp only [outputInitializers, same index state prior]
    cases selected : outputInitializer model text info (info.parameterAt index) state with
    | none => rfl
    | some next => exact ih next (preserved index state next prior selected)

theorem appendOutput_congr (actual model : CompletionCalls) (text : Source)
    (formal : PackageBindings.Formal) (frame : ParserState)
    (validEq : actual.validName text formal.bodyName = model.validName text formal.bodyName)
    (appendEq : model.validName text formal.bodyName = true →
      actual.appendFormal frame formal.bodyName
        ⟨formal.bodyTypeName, formal.bodyTypeName.after, formal.kind, formal.bounds, formal.typeIdentity⟩ formal.mode =
      model.appendFormal frame formal.bodyName
        ⟨formal.bodyTypeName, formal.bodyTypeName.after, formal.kind, formal.bounds, formal.typeIdentity⟩ formal.mode) :
    appendOutput actual text formal frame = appendOutput model text formal frame := by
  unfold appendOutput
  split
  · rfl
  · rw [validEq]
    split
    · rfl
    · rename_i allowed
      have ready : model.validName text formal.bodyName = true :=
        Bool.eq_true_of_ne_false (fun failed => allowed (by rw [failed]; rfl))
      rw [appendEq ready]

theorem appendOutputs_congr {P : ParserState → Prop}
    (actual model : CompletionCalls) (text : Source) (info : PackageBindings.Metadata)
    (same : ∀ index frame, P frame → appendOutput actual text (info.parameterAt index) frame =
      appendOutput model text (info.parameterAt index) frame)
    (preserved : ∀ index frame next, P frame →
      appendOutput model text (info.parameterAt index) frame = some next → P next)
    (indices : List Nat) (frame : ParserState) (prior : P frame) :
    appendOutputs actual text info indices frame = appendOutputs model text info indices frame := by
  induction indices generalizing frame with
  | nil => rfl
  | cons index rest ih =>
    simp only [appendOutputs, same index frame prior]
    cases selected : appendOutput model text (info.parameterAt index) frame with
    | none => rfl
    | some next => exact ih next (preserved index frame next prior selected)

namespace Library

theorem output_initializer (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata)
    (formal : PackageBindings.Formal) (typed : formal.Typed)
    (state : InitializationFrame) (framed : ReaderFrame text state.frame) :
    outputInitializer (library.calls reader) text info formal state =
      outputInitializer (library.model reader) text info formal state := by
  let first := tokenAfter text (Compose.nameAfter text (Compose.skipAt text state.frame.position)) (.symbol ":=")
  let context := nativeContext state
  let facts := ActiveFlow.initial context.scalarNames (initialFacts context.model.hasArguments)
  let parameter : FunctionBindings.Formal := ⟨formal.bodyName.first, formal.bodyName.after, formal.kind, formal.bounds, 0⟩
  have firstBound : ValidCursor text first := fixedAfter_result_bound text _ ":=" false (by decide)
  have actualDomain : FunctionCallNative.ActualDomain text context first facts parameter :=
    ⟨⟨⟨valid, context_valid state framed, firstBound⟩, initial_flow_valid state framed⟩,
      typed.2.1.1, typed.2.1.2, typed.2.2.2.2.1, Nat.zero_le _⟩
  have afterBound := ApplicationPackageActual.actual_model_bound text context first facts parameter
    valid (context_valid state framed) firstBound
  apply outputInitializer_congr
  · exact library.valid_name reader text _
  · exact library.skip reader valid _ framed.cursor
  · exact library.name reader valid _ (model_skip_valid text _ framed.cursor)
  · exact library.same_name reader text _ _
  · exact library.take reader valid _ (function_nameAfter_bound text _) _ (by unfold ValidToken; decide)
  · exact library.context_of reader _
  · apply library.leaves.initial_meaning context.model
    simpa only [context, nativeContext, Adapter.contextOf, Predicate.Native.Context.model,
      ScalarExpression.bodyEnvironment_length] using framed.typed.scalarCount
  · exact library.leaves.returns.actual.projected_meaning text context first facts parameter actualDomain
  · exact library.leaves.state_reads text valid context (context_valid state framed) info first _ firstBound afterBound
  · exact library.take reader valid _ afterBound _ (by unfold ValidToken; decide)

theorem output_initializers (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata) (typed : info.Typed)
    (indices : List Nat) (state : InitializationFrame) (framed : ReaderFrame text state.frame) :
    outputInitializers (library.calls reader) text info indices state =
      outputInitializers (library.model reader) text info indices state := by
  apply outputInitializers_congr (P := fun state => ReaderFrame text state.frame)
    (library.calls reader) (library.model reader) text info
    (fun index state framed => library.output_initializer reader valid info _
      (MetadataTypes.parameter_at typed index) state framed)
    (fun index state next framed selected => output_initializer_frame reader
      (LeafLibraries.model (library.calls reader)) info _ state next framed selected) indices state framed

theorem append_output (library : Library) (reader : BooleanElaboration.Native.Reader)
    (text : Source) (formal : PackageBindings.Formal) (frame : ParserState) (prior : OutputFrame frame) :
    appendOutput (library.calls reader) text formal frame =
      appendOutput (library.model reader) text formal frame := by
  apply appendOutput_congr (library.calls reader) (library.model reader) text formal frame
    (library.valid_name reader text _)
  intro allowed
  have named := (ApplicationPackageNames.Native.validName_domain allowed).2
  exact library.routine.append_meaning frame prior.append_domain _ _ _ named.1 named.2.1

theorem append_outputs (library : Library) (reader : BooleanElaboration.Native.Reader)
    (text : Source) (info : PackageBindings.Metadata) (typed : info.Typed)
    (indices : List Nat) (frame : ParserState) (prior : OutputFrame frame) :
    appendOutputs (library.calls reader) text info indices frame =
      appendOutputs (library.model reader) text info indices frame := by
  exact appendOutputs_congr (P := OutputFrame) (library.calls reader) (library.model reader) text info
    (fun index frame prior => library.append_output reader text _ frame prior)
    (fun index frame next prior selected => append_output_frame reader (LeafLibraries.model (library.calls reader)) text _
      (MetadataTypes.parameter_at typed index).2.2.2.2.1 frame next prior selected) indices frame prior

end Library
end Silver.ApplicationPackageCompletion
