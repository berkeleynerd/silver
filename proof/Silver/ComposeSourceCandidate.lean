module

public import Silver.ComposeExpressionSourceCandidate
public import Silver.ComposeCatalogueSourceCandidate
public import Silver.ComposeDeclarationSourceCandidate
public import Silver.ComposeContractSourceCandidate
public import Silver.ComposeHelperSourceCandidate

@[expose] public section

/-! Complete shared declaration and expression source checks. Independent parts
retain checked objects when another source section needs repair. -/

namespace Silver.Compose.SourceBridge

/-- All source-dependent helper checks, before binding the reviewed shape to
actual output specification and implementation tokens. -/
theorem candidate_checked :
    ExpressionTranslationFor Output.SourceShape.outputImplementation ∧
    HelperCatalogueTranslationFor Output.SourceShape.outputSpecification Output.SourceShape.outputImplementation ∧
    DeclarationsFor Output.SourceShape.outputSpecification Output.SourceShape.outputImplementation ∧
    RefinementFor Output.SourceShape.outputImplementation ∧
    AdapterTranslationFor Output.SourceShape.outputImplementation ∧
    ArrayHelperTranslationFor Output.SourceShape.outputImplementation :=
  ⟨candidate_expressions, candidate_catalogue, candidate_declarations,
    candidate_refinement, candidate_adapters, candidate_array_helpers⟩
end Silver.Compose.SourceBridge
