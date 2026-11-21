module

public import Silver.ComposeSourceCandidate
public import Silver.ComposeArrayTypeSourceCandidate
public import Silver.OutputSourceBridge

@[expose] public section

/-! Authoritative source checks for the shared declaration and expression
helpers. The expensive reviewed-shape decisions are independent of source
certification; this adapter binds every source-dependent claim to the complete
freshly certified output specification and implementation shapes. -/

namespace Silver.Compose.SourceBridge

abbrev ExpressionTranslation : Prop :=
  ExpressionTranslationFor Source.outputBodyTokens

abbrev HelperCatalogueTranslation : Prop :=
  HelperCatalogueTranslationFor Source.outputSpecTokens Source.outputBodyTokens

abbrev Declarations : Prop :=
  DeclarationsFor Source.outputSpecTokens Source.outputBodyTokens

abbrev Refinement : Prop :=
  RefinementFor Source.outputBodyTokens

abbrev AdapterTranslation : Prop :=
  AdapterTranslationFor Source.outputBodyTokens

abbrev StringHelperTranslation : Prop :=
  StringHelperTranslationFor Source.outputBodyTokens

abbrev ArrayHelperTranslation : Prop :=
  ArrayHelperTranslationFor Source.outputBodyTokens

abbrev ArrayTypeHelperTranslation : Prop :=
  ArrayTypeHelperTranslationFor Source.outputBodyTokens

theorem actual_array_type_helpers : ArrayTypeHelperTranslation := by
  change ArrayTypeHelperTranslationFor Source.outputBodyTokens
  rw [Output.SourceBridge.actual_complete_shape.2.1]
  exact candidate_array_type_helpers

private theorem actual_checked :
    ExpressionTranslation ∧ HelperCatalogueTranslation ∧ Declarations ∧ Refinement ∧
      AdapterTranslation ∧ ArrayHelperTranslation := by
  have shape := Output.SourceBridge.actual_complete_shape
  change ExpressionTranslationFor Source.outputBodyTokens ∧
    HelperCatalogueTranslationFor Source.outputSpecTokens Source.outputBodyTokens ∧
    DeclarationsFor Source.outputSpecTokens Source.outputBodyTokens ∧
    RefinementFor Source.outputBodyTokens ∧
    AdapterTranslationFor Source.outputBodyTokens ∧
    ArrayHelperTranslationFor Source.outputBodyTokens
  rw [shape.1, shape.2.1]
  exact candidate_checked

theorem actual_expressions : ExpressionTranslation := actual_checked.1

theorem actual_catalogue : HelperCatalogueTranslation := actual_checked.2.1

theorem finite_mapping : TokenMapping := candidate_token_mapping

theorem actual_declarations : Declarations := actual_checked.2.2.1

theorem actual_refinement : Refinement := actual_checked.2.2.2.1

theorem actual_adapters : AdapterTranslation := actual_checked.2.2.2.2.1

theorem actual_array_helpers : ArrayHelperTranslation := actual_checked.2.2.2.2.2

theorem actual_string_helpers : StringHelperTranslation := by
  change StringHelperTranslationFor Source.outputBodyTokens
  rw [Output.SourceBridge.actual_complete_shape.2.1]
  exact candidate_string_helpers

theorem actual_boolean_declaration :
    BooleanDeclarationNative.SourceChecks.Checked Source.outputBodyTokens := by
  rw [Output.SourceBridge.actual_complete_shape.2.1]
  exact candidate_boolean_declaration

theorem actual_boolean_array_helpers :
    BooleanArraySource.Checked Source.outputBodyTokens := by
  rw [Output.SourceBridge.actual_complete_shape.2.1]
  exact candidate_boolean_array_helpers

end Silver.Compose.SourceBridge
