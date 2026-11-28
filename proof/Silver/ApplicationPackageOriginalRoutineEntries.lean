module

public import Silver.ApplicationPackageOriginalRoutineFrames

@[expose] public section

namespace Silver.ApplicationPackageRoutineSources
open Compose Compose.Expressions Predicate Packages ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageInitializers ApplicationPackageObjectRows
open ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax

/-- Construct every original routine entry, using only the original
specification inventory and native domains. The final package's state schema
is the same schema present before the first completion. -/
theorem original_package_entries {reader : BooleanElaboration.Native.Reader} {completion : CompletionCalls}
    {calls : ApplicationAdmission.Calls} {sources : ApplicationUnits.Bundle} {result : ApplicationAdmission.AnalysisResult}
    (parsed : ApplicationAdmission.ParsedPackage reader completion calls sources result)
    (valid : sources.Valid)
    (framed : ReaderFrame (sources.prefix .packageBody) parsed.history.routinesStart.globals)
    (typed : parsed.history.routinesStart.info.Typed) (finalTyped : parsed.body.info.Typed)
    {specStart specEnd : SpecificationState} {specRows : List SpecificationItem}
    (specified : SpecificationInventories reader (sources.prefix .packageSpecification) specStart specRows (.ready specEnd))
    (specValid : ValidText (sources.prefix .packageSpecification))
    (specFrame : ReaderFrame (sources.prefix .packageSpecification) specStart.exports)
    (specOrder : FrameOrder specStart.exports) (specEmpty : specStart.exports.scalarNames = [])
    (specScalars : specEnd.exports.scalarNames = parsed.specification.exports.scalarNames)
    (bodyValid : ValidText (sources.prefix .packageBody))
    (typing : ∀ (globals : ParserState) (info : PackageBindings.Metadata),
      ReaderFrame (sources.prefix .packageBody) globals → info.Typed →
      (readCompletion reader completion (sources.prefix .packageBody) globals info).info.Typed)
    {readers : Readers} (equations : Equations (sourceReaders readers) NativeDomain)
    (tail : completion.applicationTail = (sourceReaders readers).statement.applicationTail)
    (actual : completion.actualAfter = Predicate.actualAfter)
    (flow : completion.initialFlow = fun context => ActiveFlow.initial context.scalarNames (initialFacts context.hasArguments))
    (returned : completion.functionReturnAfter = functionReturnAfter) :
    ∃ entries, RoutineEntriesAt reader completion (sources.prefix .packageBody) readers specRows
        parsed.history.rows entries ∧
      EntriesRelated (EntryCheckedAt parsed.body.info.stateSchema) parsed.history.rows entries := by
  have initial := original_frame_facts parsed valid framed typed finalTyped
  have states := (parsed.history.completions.source_layouts initial.initial framed.typed.scalarCount).1
  have schema := state_schema_equal states.symm
  rw [← specScalars] at initial
  obtain ⟨entries, originals, checked⟩ := original_entries specified specValid specFrame specOrder specEmpty
    parsed.history.completions bodyValid initial typing parsed.complete equations tail actual flow returned
  rw [schema] at checked
  exact ⟨entries, originals, checked⟩

end Silver.ApplicationPackageRoutineSources
