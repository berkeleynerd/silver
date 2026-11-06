module

public import Silver.SourceDeclarations
public import Silver.ComposeArrayDeclarationSource
public import Silver.ComposeContracts
public import Silver.ComposeBooleanDeclarationSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

/-! Kernel source-shape checks for one independent part of the complete
Compose candidate. The facade transports every part to authoritative tokens. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge

abbrev ExpressionTranslationFor (bodyTokens : List String) : Prop :=
  Expressions.WellFormedTrees ∧
  Expressions.WellScopedTrees ∧
  Source.expressionBody "call_after" bodyTokens =
    some Expressions.callAfterBody.render ∧
  Source.expressionBody "fixed_after" bodyTokens =
    some Expressions.fixedBody.render ∧
  Source.expressionBody "lookup_from" bodyTokens =
    some Expressions.lookupFromBody.render ∧
  Source.expressionBody "image_at" bodyTokens =
    some Expressions.imageBody.render ∧
  Source.expressionBody "value_at" bodyTokens =
    some Expressions.valueBody.render ∧
  Source.expressionBody "new_name_allowed" bodyTokens =
    some Expressions.newNameBody.render ∧
  Source.expressionBody "add_binding" bodyTokens =
    some (Expressions.addBindingBody.render.drop 1 |>.dropLast) ∧
  Source.expressionBody "string_declaration_at" bodyTokens =
    some Expressions.stringDeclarationBody.render ∧
  Source.expressionBody "scalar_constraint_at" bodyTokens =
    some Expressions.scalarConstraintBody.render ∧
  Source.expressionBody "scalar_declaration_at" bodyTokens =
    some Expressions.scalarDeclarationBody.render ∧
  Source.expressionBody "declaration_at" bodyTokens =
    some Expressions.declarationBody.render ∧
  Source.expressionBody "argument_at" bodyTokens =
    some Expressions.argumentBody.render ∧
  Source.expressionBody "declarations_at" bodyTokens =
    some Expressions.declarationsBody.render ∧
  Source.expressionBody "expression_step" bodyTokens =
    some Expressions.expressionStepBody.render ∧
  Source.expressionBody "expression_tail" bodyTokens =
    some Expressions.tailBody.render ∧
  Source.expressionBody "target_at" bodyTokens =
    some Expressions.targetBody.render ∧
  Source.expressionBody "dynamic_at" bodyTokens =
    some Expressions.dynamicBody.render ∧
  Source.expressionBody "assignment_at" bodyTokens =
    some Expressions.assignmentBody.render ∧
  Source.expressionBody "output_at" bodyTokens =
    some Expressions.outputBody.render ∧
  Source.expressionBody "step" bodyTokens =
    some Expressions.stepBody.render ∧
  Source.expressionBody "work_tail" bodyTokens = some Expressions.workTailBody.render ∧
  Source.expressionBody "fits" bodyTokens = some Expressions.fitsBody.render ∧
  Source.expressionBody "comparison_at" bodyTokens = some Expressions.comparisonBody.render ∧
  Source.expressionBody "lookup_subtype_model" bodyTokens =
    some Expressions.subtypeLookupModelBody.render ∧
  Source.expressionBody "scalar_type_at" bodyTokens =
    some Expressions.scalarTypeBody.render ∧
  Source.expressionBody "subtype_declaration_at" bodyTokens =
    some Expressions.subtypeDeclarationBody.render

private theorem expression_call_after :
  Source.expressionBody "call_after" Output.SourceShape.outputImplementation =
    some Expressions.callAfterBody.render := by decide +kernel

private theorem expression_fact_03 :
  Source.expressionBody "fixed_after" Output.SourceShape.outputImplementation =
    some Expressions.fixedBody.render := by decide +kernel

private theorem expression_fact_04 :
  Source.expressionBody "lookup_from" Output.SourceShape.outputImplementation =
    some Expressions.lookupFromBody.render := by decide +kernel

private theorem expression_image :
  Source.expressionBody "image_at" Output.SourceShape.outputImplementation =
    some Expressions.imageBody.render := by decide +kernel

private theorem expression_fact_05 :
  Source.expressionBody "value_at" Output.SourceShape.outputImplementation =
    some Expressions.valueBody.render := by decide +kernel

private theorem expression_fact_06 :
  Source.expressionBody "new_name_allowed" Output.SourceShape.outputImplementation =
    some Expressions.newNameBody.render := by decide +kernel

private theorem expression_fact_07 :
  Source.expressionBody "add_binding" Output.SourceShape.outputImplementation =
    some (Expressions.addBindingBody.render.drop 1 |>.dropLast) := by decide +kernel

private theorem expression_string_declaration :
  Source.expressionBody "string_declaration_at" Output.SourceShape.outputImplementation =
    some Expressions.stringDeclarationBody.render := by decide +kernel

private theorem expression_scalar_constraint :
  Source.expressionBody "scalar_constraint_at" Output.SourceShape.outputImplementation =
    some Expressions.scalarConstraintBody.render := by decide +kernel

private theorem expression_scalar_declaration :
  Source.expressionBody "scalar_declaration_at" Output.SourceShape.outputImplementation =
    some Expressions.scalarDeclarationBody.render := by decide +kernel

private theorem expression_fact_08 :
  Source.expressionBody "declaration_at" Output.SourceShape.outputImplementation =
    some Expressions.declarationBody.render := by decide +kernel

private theorem expression_fact_09 :
  Source.expressionBody "argument_at" Output.SourceShape.outputImplementation =
    some Expressions.argumentBody.render := by decide +kernel

private theorem expression_fact_10 :
  Source.expressionBody "declarations_at" Output.SourceShape.outputImplementation =
    some Expressions.declarationsBody.render := by decide +kernel

private theorem expression_fact_11 :
  Source.expressionBody "expression_step" Output.SourceShape.outputImplementation =
    some Expressions.expressionStepBody.render := by decide +kernel

private theorem expression_fact_12 :
  Source.expressionBody "expression_tail" Output.SourceShape.outputImplementation =
    some Expressions.tailBody.render := by decide +kernel

private theorem expression_fact_13 :
  Source.expressionBody "target_at" Output.SourceShape.outputImplementation =
    some Expressions.targetBody.render := by decide +kernel

private theorem expression_fact_14 :
  Source.expressionBody "dynamic_at" Output.SourceShape.outputImplementation =
    some Expressions.dynamicBody.render := by decide +kernel

private theorem expression_fact_15 :
  Source.expressionBody "assignment_at" Output.SourceShape.outputImplementation =
    some Expressions.assignmentBody.render := by decide +kernel

private theorem expression_fact_16 :
  Source.expressionBody "output_at" Output.SourceShape.outputImplementation =
    some Expressions.outputBody.render := by decide +kernel

private theorem expression_fact_17 :
  Source.expressionBody "step" Output.SourceShape.outputImplementation =
    some Expressions.stepBody.render := by decide +kernel

private theorem expression_fact_23 :
  Source.expressionBody "work_tail" Output.SourceShape.outputImplementation = some Expressions.workTailBody.render := by decide +kernel

private theorem expression_fact_24 :
  Source.expressionBody "fits" Output.SourceShape.outputImplementation = some Expressions.fitsBody.render := by decide +kernel

private theorem expression_fact_25 :
  Source.expressionBody "comparison_at" Output.SourceShape.outputImplementation = some Expressions.comparisonBody.render := by decide +kernel

private theorem expression_subtype_lookup :
  Source.expressionBody "lookup_subtype_model" Output.SourceShape.outputImplementation =
    some Expressions.subtypeLookupModelBody.render := by decide +kernel

private theorem expression_scalar_type :
  Source.expressionBody "scalar_type_at" Output.SourceShape.outputImplementation =
    some Expressions.scalarTypeBody.render := by decide +kernel

private theorem expression_subtype_declaration :
  Source.expressionBody "subtype_declaration_at" Output.SourceShape.outputImplementation =
    some Expressions.subtypeDeclarationBody.render := by decide +kernel

theorem candidate_expressions : ExpressionTranslationFor Output.SourceShape.outputImplementation := by
  exact ⟨Expressions.checked_precedence,
    Expressions.checked_scopes,
    expression_call_after,
    expression_fact_03,
    expression_fact_04,
    expression_image,
    expression_fact_05,
    expression_fact_06,
    expression_fact_07,
    expression_string_declaration,
    expression_scalar_constraint,
    expression_scalar_declaration,
    expression_fact_08,
    expression_fact_09,
    expression_fact_10,
    expression_fact_11,
    expression_fact_12,
    expression_fact_13,
    expression_fact_14,
    expression_fact_15,
    expression_fact_16,
    expression_fact_17,
    expression_fact_23,
    expression_fact_24,
    expression_fact_25,
    expression_subtype_lookup,
    expression_scalar_type,
    expression_subtype_declaration⟩
end Silver.Compose.SourceBridge
