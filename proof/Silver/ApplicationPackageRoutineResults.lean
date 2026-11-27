module

public import Silver.ApplicationPackageReturnReading
public import Silver.ApplicationPackageRoutineEntryScope

@[expose] public section

/-! Routine results retain the original terminal expression or the original
writable formal rows. The result checker is derived from the native reader
domain and final flow, never supplied as an admission premise. -/
namespace Silver.ApplicationPackageRoutineResults
open Compose Predicate Packages ApplicationPackages ApplicationPackageBodies
open ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax
open PackageBindings (Metadata Routine)

set_option backward.dsimp.instances true

/-- The original function return is checked in the completed body's incoming
flow. Its original expression and all intermediate obligations remain visible. -/
theorem function_results {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : Metadata} {index : Nat} {item : Routine} {state : InitializationFrame}
    {result : CompletionResult}
    (read : CompletionBodyRead calls text globals info index item state result)
    (take : calls.takeToken = tokenAfter)
    (returnAfter : calls.functionReturnAfter = functionReturnAfter)
    (legal : NativeDomain
      ⟨text, completionContextOf calls state, completionDispatch calls text info item state, info, {}, {}⟩)
    (closed : ClosedFunctionContext (completionContextOf calls state))
    (kind : item.kind = .function) :
    ∃ value,
      ActualAt text (completionContextOf calls state)
        (fixedAfter text (completionDispatch calls text info item state).scan.position "return" true)
        (completionDispatch calls text info item state).scan.facts (resultFormal item) value
        (functionReturnAfter text (completionContextOf calls state)
          (completionDispatch calls text info item state).scan ⟨0, item.resultKind, item.resultBounds, 0⟩) ∧
      value.Readable false Bindings.emptyShape
        (ArrayBindings.booleanAnalysis (completionContextOf calls state).arrayNames
          (BooleanBindings.analysis (completionContextOf calls state).booleanNames)) ∧
      ScalarFunctions.scalarActual value = true ∧
      ScalarFunctions.checkActuals Bindings.emptyShape (completionContextOf calls state).analysis
        ((completionContextOf calls state).flow (completionDispatch calls text info item state).scan.facts)
        (ArrayBindings.booleanAnalysis (completionContextOf calls state).arrayNames
          (BooleanBindings.analysis (completionContextOf calls state).booleanNames))
        (item.signature info).outputTypes [value] = true ∧
      discharged (actualObligations Bindings.emptyShape (completionContextOf calls state).analysis
        ((completionContextOf calls state).flow (completionDispatch calls text info item state).scan.facts)
        (ArrayBindings.booleanAnalysis (completionContextOf calls state).arrayNames
          (BooleanBindings.analysis (completionContextOf calls state).booleanNames)) item.resultDomain value) = true ∧
      read.returned.writes = PackageBindings.emptyStateSet := by
  obtain ⟨native, same, valid⟩ := legal.context
  change native.model = completionContextOf calls state at same
  have names : Expressions.ValidNames text (completionContextOf calls state).names := by
    rw [← same]
    exact valid.1
  have normal : NamesNormal (completionContextOf calls state).names := by
    rw [closed.noNames]
    exact namesBoundsValid_empty.normal
  obtain ⟨value, original, _, unwritten⟩ := read.function_source take returnAfter legal.text names kind
  have checked := result_reading_checks normal names legal.base legal.arrays
    legal.scan.flow.1 legal.scan.path original
  have shape : (completionContextOf calls state).names.shape = Bindings.emptyShape := by
    rw [closed.noNames]
    exact empty_names_shape
  rw [closed.noArguments, shape] at checked
  refine ⟨value, original, checked.1, actual_source_scalar closed original, ?_, checked.2.2, unwritten⟩
  simpa only [PackageBindings.Routine.signature, kind, RoutineSignature.outputTypes,
    ScalarFunctions.checkActuals, Bool.and_true] using checked.2.1

end Silver.ApplicationPackageRoutineResults
