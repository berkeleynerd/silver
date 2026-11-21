module

public import Silver.ProcedureDeclarationHelperLibraries
public import Silver.ProcedureDeclarationTraversalModel
public import Silver.FunctionDeclarationModelSource

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

theorem model_parameter_links : ParameterLinks modelCalls Expressions.modelCalls
    FunctionDeclarationNative.modelCalls ProcedureBindings.Native.modelCalls
    FunctionDeclarationNative.modelVisibility where
  skip := rfl
  nameAfter := rfl
  take _ _ _ _ := rfl
  newName := rfl
  formalType := rfl
  appendArrayParameter := rfl
  appendFormal := rfl
  hideName := rfl
  equal := rfl
  scalarAppend := rfl

theorem model_prefix_links : PrefixLinks modelCalls Predicate.BodyNative.modelCalls
    (Predicate.FlowSourceBridge.initialStorage Predicate.FlowSourceBridge.modelCalls)
    Predicate.FunctionCallNative.modelCalls where
  context scan _ := by
    rw [Predicate.Adapter.context_eval]
    rfl
  initial context bounded := by
    exact (Predicate.Adapter.Environment.initialCall_interpreted
      Predicate.FlowSourceBridge.modelCalls Predicate.FlowSourceBridge.model_calls_meaning
      (Predicate.FlowSourceBridge.initialStorage Predicate.FlowSourceBridge.modelCalls)
      (Predicate.FlowSourceBridge.model_initial_interpreted Predicate.FlowSourceBridge.modelCalls)
      context bounded).symm
  actual := rfl

/-- Concrete simultaneous witness, using only the independent lower ordinary
helper source and the proved procedure helper contracts. No completed procedure
declaration equation occurs in the input bundle. -/
noncomputable def model_interpreted_helpers (domain : Expressions.StateDomain)
    (inherited : FunctionDeclarationNative.InheritedEquations Expressions.modelCalls domain)
    (exactDomain : FunctionDeclarationNative.ExactDomain domain) : InterpretedHelpers modelCalls where
  ordinary := FunctionDeclarationNative.modelCalls
  ordinarySource := FunctionDeclarationNative.model_interpreted domain inherited exactDomain
  metadata := ProcedureBindings.Native.modelCalls
  metadataSource := ProcedureBindings.SourceBridge.model_interpreted
  links := model_parameter_links
  equations := model_equations
  contracts := model_contracts
  traversal := model_traversal_contracts
  prefixLinks := model_prefix_links

end Silver.Compose.ProcedureDeclarationNative
