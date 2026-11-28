module

public import Silver.ApplicationPackageRoutinePhaseSource
public import Silver.ApplicationPackageCompletionBodyDomains
public import Silver.ApplicationPackageRoutineValidity

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Compose.Expressions Predicate Packages ApplicationPackages ApplicationPackageDeclarations
open ApplicationPackageRoutineClosedFrames ApplicationPackageInitializers
open Recursive SourceSyntax

theorem CompletionFrames.signature_typed {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (valid : ValidText text) (framed : ReaderFrame text globals) (typed : info.Typed) :
    frames.signature.info.Typed := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  exact signed ▸ readSignature_completion_typed valid globals framed info typed

theorem CompletionFrames.entry_reader {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (valid : ValidText text) (framed : ReaderFrame text globals) (typed : info.Typed) :
    ReaderFrame text frames.entry := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have entered := ApplicationPackageCompletion.entry_reader reader calls valid globals framed info typed
  dsimp only at entered
  rw [signed, frames.entered] at entered
  exact entered

/-- Every original declaration/output pass preserves the native field
domains. The actual accepted Valid_State branch establishes the final body
reader frame, including malformed-input failure behavior before that branch. -/
theorem CompletionFrames.body_reader {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (valid : ValidText text) (framed : ReaderFrame text globals) (typed : info.Typed)
    (present : result.globals.position ≠ 0) : ReaderFrame text frames.outputs.body.frame := by
  have locals := Silver.ApplicationPackageInitializers.LocalObjects.reader_frame frames.declarations
    valid (fun _ _ => rfl) (frames.entry_reader valid framed typed)
  have started : ReaderFrame text (beginOutputs (declarationReaders reader calls) text frames.locals).frame :=
    locals.at_position (fixedAfter_result_bound text _ "begin" true (by decide))
  have initialized := ApplicationPackageCompletion.output_initializers_frame reader calls
    frames.signature.info _ _ _ started frames.outputs.read
  have output := ApplicationPackageCompletion.append_outputs_frame reader calls text frames.signature.info
    (ApplicationPackageRoutineFrame.parameterBounds_of_typed (frames.signature_typed valid framed typed))
    _ _ _ (ApplicationPackageCompletion.OutputFrame.of_reader valid initialized) frames.outputs.installed
  obtain ⟨read⟩ := completion_body_read frames.executed present
  exact output.checked read.valid

theorem CompletionFrames.body_domain {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (valid : ValidText text) (framed : ReaderFrame text globals) (typed : info.Typed)
    (present : result.globals.position ≠ 0) : NativeDomain frames.bodySource :=
  ApplicationPackageCompletion.body_source_domain reader calls valid frames.signature.info
    (frames.signature_typed valid framed typed) _ _ (frames.body_reader valid framed typed present)

theorem CompletionFrames.closed_context {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (tables : Tables globals) : ClosedFunctionContext frames.bodySource.context := by
  have closed := frames.body_closed tables
  apply ClosedFunctionContext.ofEmpty closed.pure _ closed.names closed.arrayNames
  simp only [CompletionFrames.bodySource, completionContextOf, declarationReaders, contextOf,
    OutputFrames.body, closed.dynamicFirst, ne_eq, not_true_eq_false, decide_false]

def CompletionFrames.stop {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result) : BodyStop :=
  if (frames.signature.info.routineAt (info.completed + 1)).kind = .function then .returnOnly else .endOnly

def CompletionFrames.required {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result) : Bool :=
  decide ((frames.signature.info.routineAt (info.completed + 1)).kind = .procedure) && !frames.outputs.body.initialized

def CompletionFrames.dispatched {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result) : ApplicationScan :=
  completionDispatch (declarationReaders reader calls) text frames.signature.info
    (frames.signature.info.routineAt (info.completed + 1)) frames.outputs.body

theorem CompletionFrames.tail_result {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (readers : Readers) (tail : calls.applicationTail = (sourceReaders readers).statement.applicationTail) :
    (sourceReaders readers).tailResult frames.bodySource frames.stop frames.required = frames.dispatched := by
  change (sourceReaders readers).statement.applicationTail _ _ _ _ _ _ _ _ = calls.applicationTail _ _ _ _ _ _ _ _
  rw [tail]
  rfl

/-- Original cursor recursion constructs every routine body tree and derives
its complete package checker. The native result domain comes from the same
recursive equations, so the terminal result reads receive the actual flow. -/
theorem CompletionFrames.original_body {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    {readers : Readers} (equations : Equations (sourceReaders readers) NativeDomain)
    (tail : calls.applicationTail = (sourceReaders readers).statement.applicationTail)
    (legal : NativeDomain frames.bodySource) (scope : PackageScope frames.bodySource)
    (present : result.globals.position ≠ 0) :
    ∃ code,
      TailCodeAt (sourceReaders readers) packageNames frames.bodySource frames.stop frames.required false
        frames.dispatched code ∧
      PackageChecked text.length frames.bodySource frames.dispatched code ∧
      NativeDomain (atInput frames.bodySource frames.dispatched) := by
  obtain ⟨read⟩ := completion_body_read frames.executed present
  have dispatchPresent : frames.dispatched.scan.position ≠ 0 := read.dispatchPresent
  have linked := frames.tail_result readers tail
  rw [← linked] at dispatchPresent
  obtain ⟨code, original, checked⟩ :=
    (package_recursive_meaning equations scope legal (frames.body_hidden text.length)).2
      frames.stop frames.required dispatchPresent
  have returned := ((Equations.outcomes (readers := sourceReaders readers) equations legal legal.typed).2
    frames.stop frames.required).scan
  rw [sourceReaders_native] at returned
  rw [linked] at original checked returned
  exact ⟨code, original, checked, legal.replaceInput returned⟩

theorem CompletionFrames.initial_flow {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (tables : Tables globals) :
    frames.bodySource.context.flow frames.bodySource.input.scan.facts =
      ⟨ScalarFunctions.entryContext, frames.bodySource.context.analysis.declared⟩ := by
  have closed := frames.closed_context tables
  have original := bodyOf_model ⟨frames.outputs.completed, frames.outputs.initialized.initialized, false⟩
  change frames.bodySource.context.flow frames.bodySource.input.scan.facts =
    Flow.initial frames.bodySource.context.analysis (initialFacts frames.bodySource.context.hasArguments) at original
  rw [closed.noArguments] at original
  exact original

end Silver.ApplicationPackageBodies
