module

public import Silver.ApplicationPackageDeclarationsObjectSourceCandidate
public import Silver.ApplicationPackageDeclarationsSignatureSourceCandidate
public import Silver.ApplicationPackageDeclarationsSpecificationSourceCandidate
public import Silver.OutputBodyCertificate
public import Silver.PackageBindingsSpecCertificate
public import Silver.ScalarExpressionSpecCertificate
import all Init.Data.Repr

@[expose] public section

/-! Bind the complete typed Object, Signature and Specification readers and
their native contract/record interfaces to the certified original source.
Semantic imported-call composition is proved separately over the full domains. -/
namespace Silver.ApplicationPackageDeclarations

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace ObjectSourceChecks

theorem actual_checked : Checked Source.outputBodyTokens Source.scalarExpressionSpecTokens where
  wellFormed := candidate_checked.wellFormed
  bodyScopes := candidate_checked.bodyScopes
  named := candidate_checked.named
  bodySource := by
    refine Eq.trans ?_ candidate_checked.bodySource
    decide +kernel
  headerSource := by
    refine Eq.trans ?_ candidate_checked.headerSource
    decide +kernel
  objectType := by
    refine Eq.trans ?_ candidate_checked.objectType
    decide +kernel
  invalidObject := by
    refine Eq.trans ?_ candidate_checked.invalidObject
    decide +kernel
  constraintType := by
    refine Eq.trans ?_ candidate_checked.constraintType
    decide +kernel
  staticType := by
    refine Eq.trans ?_ candidate_checked.staticType
    decide +kernel
  scalarType := by
    refine Eq.trans ?_ candidate_checked.scalarType
    decide +kernel
  scalarSpecialization := by
    refine Eq.trans ?_ candidate_checked.scalarSpecialization
    decide +kernel

end ObjectSourceChecks

namespace ReaderSourceChecks

theorem signature_actual_checked : SignatureChecked Source.outputBodyTokens Source.packageBindingsSpecTokens where
  tree := signature_candidate_checked.tree
  bodySource := by
    refine Eq.trans ?_ signature_candidate_checked.bodySource
    decide +kernel
  headerSource := by
    refine Eq.trans ?_ signature_candidate_checked.headerSource
    decide +kernel
  routineType := by
    refine Eq.trans ?_ signature_candidate_checked.routineType
    decide +kernel
  formalType := by
    refine Eq.trans ?_ signature_candidate_checked.formalType
    decide +kernel
  appendSource := by
    refine Eq.trans ?_ signature_candidate_checked.appendSource
    decide +kernel

theorem append_actual_checked : AppendChecked Source.outputBodyTokens Source.scalarExpressionSpecTokens where
  headerSource := by
    refine Eq.trans ?_ append_candidate_checked.headerSource
    decide +kernel
  scalarHeader := by
    refine Eq.trans ?_ append_candidate_checked.scalarHeader
    decide +kernel
  scalarBody := by
    refine Eq.trans ?_ append_candidate_checked.scalarBody
    decide +kernel

theorem specification_actual_checked : SpecificationChecked Source.outputBodyTokens Source.packageBindingsSpecTokens where
  tree := specification_candidate_checked.tree
  bodySource := by
    refine Eq.trans ?_ specification_candidate_checked.bodySource
    decide +kernel
  headerSource := by
    refine Eq.trans ?_ specification_candidate_checked.headerSource
    decide +kernel
  exportType := by
    refine Eq.trans ?_ specification_candidate_checked.exportType
    decide +kernel
  objectDefault := by
    refine Eq.trans ?_ specification_candidate_checked.objectDefault
    decide +kernel

structure CheckedSource : Prop where
  implementation : Source.lex Source.outputProfileBody = some Source.outputBodyTokens
  packages : Source.lex Source.packageBindingsSpec = some Source.packageBindingsSpecTokens
  scalars : Source.lex Source.scalarExpressionSpec = some Source.scalarExpressionSpecTokens
  object : ObjectSourceChecks.Checked Source.outputBodyTokens Source.scalarExpressionSpecTokens
  signature : SignatureChecked Source.outputBodyTokens Source.packageBindingsSpecTokens
  append : AppendChecked Source.outputBodyTokens Source.scalarExpressionSpecTokens
  specification : SpecificationChecked Source.outputBodyTokens Source.packageBindingsSpecTokens

theorem checked_source : CheckedSource :=
  ⟨Source.outputBodyTokens_correct, Source.packageBindingsSpecTokens_correct,
    Source.scalarExpressionSpecTokens_correct, ObjectSourceChecks.actual_checked,
    signature_actual_checked, append_actual_checked, specification_actual_checked⟩

end ReaderSourceChecks
end Silver.ApplicationPackageDeclarations
