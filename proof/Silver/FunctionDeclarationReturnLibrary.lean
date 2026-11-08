module

public import Silver.FunctionDeclarationLibraries
public import Silver.PredicateFunctionCallHelpers

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 5000
set_option maxHeartbeats 1000000

/-- Actual_After is imported through its checked call-expression interpreter;
the synthesized return formal deliberately has zero source-name components. -/
theorem return_library_imports {domain calls inherited metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (links : HeaderLinks calls inherited metadata visibility)
    (actualImports : Predicate.FunctionCallNative.Imports)
    (actualCalls : Predicate.FunctionCallNative.Calls)
    (assignment : Source → Predicate.Native.Context → Predicate.BodyScan → FunctionBindings.Metadata → Predicate.BodyScan)
    (actualMeaning : Predicate.FunctionCallNative.ImportsMeaning actualImports)
    (actualEquations : Predicate.FunctionCallNative.DefinitionEquations actualImports actualCalls assignment)
    (actualLink : calls .actualAfter = actualCalls.actual)
    (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (context : Predicate.Native.Context) (scan : Predicate.BodyScan) (resultType : FunctionTypeResult)
    (valid : ReturnInput text context scan resultType) : ReturnImports calls text context scan resultType := by
  classical
  refine ⟨(header_lexical source links).take text tv _ _ _ valid.scan.1 (native_token_valid .returnKeyword), ?_⟩
  rw [actualLink]
  have domainValid : Predicate.FunctionCallNative.ActualDomain text context
      (fixedAfter text scan.position "return" true) scan.facts ⟨0, 0, resultType.kind, resultType.bounds⟩ :=
    ⟨⟨⟨tv, valid.context, fixedAfter_result_bound text _ "return" true (by decide)⟩, valid.scan.2.2⟩,
      ⟨Nat.zero_le _, Nat.zero_le _, valid.resultType.bounds⟩⟩
  have interpreted := congrArg (fun fn => fn text context (fixedAfter text scan.position "return" true)
      scan.facts ⟨0, 0, resultType.kind, resultType.bounds⟩)
    (Predicate.FunctionCallNative.normalized_actual actualMeaning actualEquations)
  change (if Predicate.FunctionCallNative.ActualDomain text context
      (fixedAfter text scan.position "return" true) scan.facts ⟨0, 0, resultType.kind, resultType.bounds⟩
      then _ else _) = _ at interpreted
  simpa only [domainValid, ↓reduceIte, Predicate.FunctionCallNative.modelCalls] using interpreted

end Silver.Compose.FunctionDeclarationNative
