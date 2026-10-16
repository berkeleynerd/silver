module

public import Silver.ComposeModelCalls
public import Silver.ComposeStateBounds

@[expose] public section

/-! Bounds and progress for the concrete composed recognizer. These are model
proofs of the existing interpretation contracts, independent of that interface's
assumed equations. -/

namespace Silver.Compose.Expressions
open Named

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem model_ranges : RangeContracts modelCalls where
  skip := by
    intro text _ position bound
    exact model_skip_valid text position bound
  name := by
    intro text _ position _
    exact model_name_valid text position
  token := by
    intro text _ position token bound _
    exact model_fixed_valid text position (spelling token) (isWord token) bound
  lookup := by
    intro text _ names first after _ _ _
    exact model_lookup_valid text names first after
  literal := by
    intro text valid position _
    exact model_literal_valid text valid position
  value := by
    intro text valid position names scalarNames _ namesValid _
    exact model_value_valid (scalarNames := scalarNames) text valid position names namesValid
  stringDeclaration := by
    intro text valid state arguments stateValid
    refine ⟨model_string_declaration_valid text valid state arguments stateValid, ?_⟩
    by_cases zero : (stringDeclarationAt text state arguments).position = 0
    · exact Or.inl zero
    · exact Or.inr (model_string_declaration_advances text valid state arguments stateValid zero)
  scalarDeclaration := by
    intro text _ state arguments stateValid
    refine ⟨model_scalar_declaration_valid text state arguments stateValid, ?_⟩
    by_cases zero : (scalarDeclarationAt text state arguments).position = 0
    · exact Or.inl zero
    · exact Or.inr (model_scalar_declaration_advances text state arguments zero)
  declaration := by
    intro text valid state arguments stateValid
    refine ⟨model_declaration_valid text valid state arguments stateValid, ?_⟩
    by_cases zero : (declarationAt text state arguments).position = 0
    · exact Or.inl zero
    · exact Or.inr (model_declaration_advances text valid state arguments stateValid zero)
  argument := by
    intro text valid state stateValid
    exact model_argument_valid text valid state stateValid
  declarations := by
    intro text valid state arguments stateValid
    exact model_declarations_valid text valid state arguments stateValid
  expressionStep := by
    intro text valid names scan scalarNames namesValid _ scanValid
    exact model_scan_valid (scalarNames := scalarNames) text valid names scan namesValid scanValid
  expression := by
    intro text valid position names scalarNames bound namesValid _
    exact model_expression_valid (scalarNames := scalarNames) text valid position names bound namesValid
  step := by
    intro text valid form token state _ stateValid
    exact model_step_valid text valid form token state stateValid

end Silver.Compose.Expressions
