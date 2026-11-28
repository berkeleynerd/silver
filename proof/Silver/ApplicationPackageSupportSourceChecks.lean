module

public import Silver.ApplicationPackageFramesCandidate
public import Silver.ApplicationPackageEffectsCandidate
public import Silver.ApplicationStateValidityCandidate
public import Silver.ApplicationStateValidityTablesCandidate
public import Silver.ApplicationStateValidityPrimitiveCandidate
public import Silver.OutputLexicalSpecCertificate
public import Silver.ScalarsNativeSourceChecks
public import Silver.OutputBodyCertificate
public import Silver.ScalarExpressionSpecCertificate
import all Init.Data.Repr

@[expose] public section

/-! Authoritative profile binding for the frame transformations, state effects,
and executable state-validity aggregate. Fragment extraction equalities are
kernel checked against the full certified original source, including uniqueness. -/
namespace Silver.ApplicationPackageSupport.SourceChecks
open SourceBridge
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem actual_frames : ApplicationPackageFrames.Native.Source.Checked Silver.Source.outputBodyTokens where
  trees := ApplicationPackageFrames.Native.Source.candidate_checked.trees
  importedHeader := by
    rw [show functionHeader "imported_frame" "is" Silver.Source.outputBodyTokens =
      functionHeader "imported_frame" "is" ApplicationPackageFrames.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageFrames.Native.Source.candidate_checked.importedHeader
  importedBody := by
    rw [show Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "imported_frame" Silver.Source.outputBodyTokens =
      Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "imported_frame" ApplicationPackageFrames.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageFrames.Native.Source.candidate_checked.importedBody
  hideHeader := by
    rw [show functionHeader "hide_outer" "is" Silver.Source.outputBodyTokens =
      functionHeader "hide_outer" "is" ApplicationPackageFrames.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageFrames.Native.Source.candidate_checked.hideHeader
  hideBody := by
    rw [show Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "hide_outer" Silver.Source.outputBodyTokens =
      Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "hide_outer" ApplicationPackageFrames.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageFrames.Native.Source.candidate_checked.hideBody

theorem actual_effects : ApplicationPackageEffects.Native.Source.Checked Silver.Source.outputBodyTokens where
  trees := ApplicationPackageEffects.Native.Source.candidate_checked.trees
  scopes := ApplicationPackageEffects.Native.Source.candidate_checked.scopes
  visibleHeader := by
    rw [show functionHeader "visible_state" "is" Silver.Source.outputBodyTokens =
      functionHeader "visible_state" "is" ApplicationPackageEffects.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageEffects.Native.Source.candidate_checked.visibleHeader
  visibleBody := by
    rw [show Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "visible_state" Silver.Source.outputBodyTokens =
      Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "visible_state" ApplicationPackageEffects.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageEffects.Native.Source.candidate_checked.visibleBody
  targetHeader := by
    rw [show functionHeader "state_target" "is" Silver.Source.outputBodyTokens =
      functionHeader "state_target" "is" ApplicationPackageEffects.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageEffects.Native.Source.candidate_checked.targetHeader
  targetBody := by
    rw [show Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "state_target" Silver.Source.outputBodyTokens =
      Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "state_target" ApplicationPackageEffects.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageEffects.Native.Source.candidate_checked.targetBody
  readsHeader := by
    rw [show functionHeader "state_reads" "is" Silver.Source.outputBodyTokens =
      functionHeader "state_reads" "is" ApplicationPackageEffects.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageEffects.Native.Source.candidate_checked.readsHeader
  readsBody := by
    rw [show Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "state_reads" Silver.Source.outputBodyTokens =
      Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "state_reads" ApplicationPackageEffects.Native.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageEffects.Native.Source.candidate_checked.readsBody

theorem actual_validity : ApplicationPackageFrames.ValidityNative.Source.Checked Silver.Source.outputBodyTokens where
  trees := ApplicationPackageFrames.ValidityNative.Source.candidate_checked.trees
  specification := by
    rw [show functionHeader "valid_state" ";" Silver.Source.outputBodyTokens =
      functionHeader "valid_state" ";" ApplicationPackageFrames.ValidityNative.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageFrames.ValidityNative.Source.candidate_checked.specification
  implementation := by
    rw [show functionHeader "valid_state" "is" Silver.Source.outputBodyTokens =
      functionHeader "valid_state" "is" ApplicationPackageFrames.ValidityNative.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageFrames.ValidityNative.Source.candidate_checked.implementation
  expression := by
    rw [show Silver.Source.expressionBody "valid_state" Silver.Source.outputBodyTokens =
      Silver.Source.expressionBody "valid_state" ApplicationPackageFrames.ValidityNative.Source.candidateTokens by decide +kernel]
    exact ApplicationPackageFrames.ValidityNative.Source.candidate_checked.expression

theorem actual_tables : ApplicationPackageFrames.ValidityTables.Source.Checked
    Silver.Source.outputBodyTokens Silver.Source.scalarExpressionSpecTokens where
  trees := ApplicationPackageFrames.ValidityTables.Source.candidate_checked.trees
  scalar := by
    rw [show Silver.Source.expressionBody "valid_environment" Silver.Source.scalarExpressionSpecTokens =
      Silver.Source.expressionBody "valid_environment" ApplicationPackageFrames.ValidityTables.Source.scalarCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Source.candidate_checked.scalar
  boolean := by
    rw [show Silver.Source.expressionBody "valid_booleans" Silver.Source.outputBodyTokens =
      Silver.Source.expressionBody "valid_booleans" ApplicationPackageFrames.ValidityTables.Source.profileCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Source.candidate_checked.boolean
  subtype := by
    rw [show Silver.Source.expressionBody "valid_subtypes" Silver.Source.outputBodyTokens =
      Silver.Source.expressionBody "valid_subtypes" ApplicationPackageFrames.ValidityTables.Source.profileCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Source.candidate_checked.subtype
  names := by
    rw [show Silver.Source.expressionBody "valid_names" Silver.Source.outputBodyTokens =
      Silver.Source.expressionBody "valid_names" ApplicationPackageFrames.ValidityTables.Source.profileCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Source.candidate_checked.names
  mutable := by
    rw [show Silver.Source.expressionBody "valid_mutable_bounds" Silver.Source.outputBodyTokens =
      Silver.Source.expressionBody "valid_mutable_bounds" ApplicationPackageFrames.ValidityTables.Source.profileCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Source.candidate_checked.mutable
  values := by
    rw [show Silver.Source.expressionBody "valid_declaration_values" Silver.Source.outputBodyTokens =
      Silver.Source.expressionBody "valid_declaration_values" ApplicationPackageFrames.ValidityTables.Source.profileCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Source.candidate_checked.values

theorem actual_primitives : ApplicationPackageFrames.ValidityTables.Primitives.Source.Checked
    Silver.Source.outputLexicalSpecTokens Silver.Source.outputBodyTokens where
  nameTree := ApplicationPackageFrames.ValidityTables.Primitives.Source.candidate_checked.nameTree
  boundsTree := ApplicationPackageFrames.ValidityTables.Primitives.Source.candidate_checked.boundsTree
  nameSpecification := by
    rw [show functionHeader "valid_name_state" ";" Silver.Source.outputLexicalSpecTokens =
      functionHeader "valid_name_state" ";" ApplicationPackageFrames.ValidityTables.Primitives.Source.lexicalCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Primitives.Source.candidate_checked.nameSpecification
  nameImplementation := by
    rw [show functionHeader "valid_name_state" "is" Silver.Source.outputLexicalSpecTokens =
      functionHeader "valid_name_state" "is" ApplicationPackageFrames.ValidityTables.Primitives.Source.lexicalCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Primitives.Source.candidate_checked.nameImplementation
  nameExpression := by
    rw [show Silver.Source.expressionBody "valid_name_state" Silver.Source.outputLexicalSpecTokens =
      Silver.Source.expressionBody "valid_name_state" ApplicationPackageFrames.ValidityTables.Primitives.Source.lexicalCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Primitives.Source.candidate_checked.nameExpression
  boundsHeader := by
    rw [show functionHeader "fixed_bounds_valid" "is" Silver.Source.outputBodyTokens =
      functionHeader "fixed_bounds_valid" "is" ApplicationPackageFrames.ValidityTables.Primitives.Source.profileCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Primitives.Source.candidate_checked.boundsHeader
  boundsExpression := by
    rw [show Silver.Source.expressionBody "fixed_bounds_valid" Silver.Source.outputBodyTokens =
      Silver.Source.expressionBody "fixed_bounds_valid" ApplicationPackageFrames.ValidityTables.Primitives.Source.profileCandidate by decide +kernel]
    exact ApplicationPackageFrames.ValidityTables.Primitives.Source.candidate_checked.boundsExpression

structure CheckedSource : Prop where
  source : Silver.Source.lex Silver.Source.outputProfileBody = some Silver.Source.outputBodyTokens
  scalarSource : Silver.Source.lex Silver.Source.scalarExpressionSpec = some Silver.Source.scalarExpressionSpecTokens
  lexicalSource : Silver.Source.lex Silver.Source.outputLexicalSpec = some Silver.Source.outputLexicalSpecTokens
  primitives : ApplicationPackageFrames.ValidityTables.Primitives.Source.Checked Silver.Source.outputLexicalSpecTokens Silver.Source.outputBodyTokens
  intervals : Integer.NativeSourceChecks.CheckedSource
  tables : ApplicationPackageFrames.ValidityTables.Source.Checked Silver.Source.outputBodyTokens Silver.Source.scalarExpressionSpecTokens
  frames : ApplicationPackageFrames.Native.Source.Checked Silver.Source.outputBodyTokens
  effects : ApplicationPackageEffects.Native.Source.Checked Silver.Source.outputBodyTokens
  validity : ApplicationPackageFrames.ValidityNative.Source.Checked Silver.Source.outputBodyTokens

theorem checked_source : CheckedSource :=
  ⟨Silver.Source.outputBodyTokens_correct, Silver.Source.scalarExpressionSpecTokens_correct,
    Silver.Source.outputLexicalSpecTokens_correct, actual_primitives,
    Integer.NativeSourceChecks.checked_source,
    actual_tables, actual_frames, actual_effects, actual_validity⟩

end Silver.ApplicationPackageSupport.SourceChecks
