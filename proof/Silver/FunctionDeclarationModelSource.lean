module

public import Silver.FunctionDeclarationSourceBridge
public import Silver.FunctionDeclarationModelContracts

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

/-- The model satisfies the exact native definition equations. These are the
proved typed-tree denotations, not hypotheses equating a scanner to admission. -/
theorem model_header_equations : HeaderEquations modelCalls where
  functionType text _ state position _ _ := (functionType_model text state position).symm
  formalType text _ state position _ _ := (formalType_model text state position).symm
  parameterStep text _ state arguments _ := (parameterStep_model text state arguments).symm
  parametersModel text _ state arguments _ := (parametersModel_model text state arguments).symm
  parameters _ _ _ _ _ := rfl
  functionLocal text _ state arguments _ := (functionLocal_model text state arguments).symm
  localsModel text _ state arguments _ := (functionLocalsModel_model text state arguments).symm
  locals _ _ _ _ _ := rfl

theorem model_frame_equations : FrameEquations modelCalls where
  appendArrayParameterModel frame first after typeId _ _ _ _ :=
    (appendArrayParameter_model frame first after typeId).symm
  appendArrayParameter _ _ _ _ _ _ _ _ := rfl
  appendParameter frame parameter _ _ := (appendParameter_model frame parameter).symm
  parameterModel frame index _ _ _ := (parameterFrameModel_model frame index).symm
  parameterFrame _ _ _ _ _ _ := rfl

theorem model_ordinary_equations : OrdinaryEquations modelCalls where
  returnAfter text _ context scan resultType _ := (returnAfter_model text context scan resultType).symm
  functionBody text _ outer frame first after resultType arguments _ :=
    (functionBody_model text outer frame first after resultType arguments).symm
  declaration text _ state arguments _ := (functionDeclaration_model text state arguments).symm

def modelVisibility : FunctionVisibilityNative.Implementation where
  calls := FunctionVisibilityNative.modelCalls
  formalHides := Compose.formalHides
  hiddenOuter := Compose.hiddenOuter
  hideName := Compose.hideName

theorem model_visibility_primitives : FunctionVisibilityNative.Primitives modelVisibility.calls := by
  constructor <;> intros <;> rfl

theorem model_visibility_equations : FunctionVisibilityNative.Equations modelVisibility where
  functionHides text _ catalog word _ _ := (FunctionVisibilityNative.functionHides_model text catalog word).symm
  formalHides text _ state first after _ _ _ := (FunctionVisibilityNative.formalHides_model text state first after).symm
  hiddenWord text _ state word _ _ := (FunctionVisibilityNative.hiddenWord_model text state word).symm
  hiddenOuter text _ state _ := (FunctionVisibilityNative.hiddenOuter_model text state).symm
  hideName text _ flags first after _ := (FunctionVisibilityNative.hideName_model text flags first after).symm

theorem model_links : OrdinaryLinks modelCalls Expressions.modelCalls FunctionBindings.Native.modelCalls modelVisibility where
  skip := rfl
  nameAfter := rfl
  take _ _ _ _ := rfl
  newName := rfl
  scalarType := rfl
  strings := rfl
  scalars := rfl
  booleans := rfl
  subtypes := rfl
  arrays := rfl
  arrayTypes := rfl
  arrayType := rfl
  functions := rfl
  procedures := rfl
  appendFormal := rfl
  formalHides := rfl
  hideName := rfl
  equal := rfl
  scalarDeclaration := rfl
  booleanDeclaration := rfl
  scalarAppend := rfl
  hiddenOuter := rfl
  append := rfl
  nameIs := rfl

theorem model_body_links : BodyLinks modelCalls Predicate.BodyNative.modelCalls
    (Predicate.Adapter.Wrappers.modelCalls Predicate.BodyNative.modelCalls) where
  context scan _ := by
    rw [Predicate.Adapter.context_eval]
    rfl
  bodyOf := by
    funext scan
    exact (Predicate.Adapter.body_eval Predicate.BodyNative.modelCalls {scan}).symm
  tail := rfl

/-- A concrete inhabitant built from the independent lower helper model. The
input bundle excludes the function declaration equation being constructed. -/
noncomputable def model_interpreted (domain : Expressions.StateDomain)
    (inherited : InheritedEquations Expressions.modelCalls domain) (exactDomain : ExactDomain domain) :
    InterpretedSource modelCalls where
  domain := domain
  inherited := Expressions.modelCalls
  inheritedSource := inherited
  exactDomain := exactDomain
  metadata := FunctionBindings.Native.modelCalls
  metadataSource := FunctionBindings.SourceBridge.model_interpreted
  visibility := modelVisibility
  visibilityPrimitives := model_visibility_primitives
  visibilityEquations := model_visibility_equations
  links := model_links
  headers := model_header_equations
  headerContracts := model_header_contracts
  frames := model_frame_equations
  arrayLibrary := ArrayBindings.Native.modelCalls
  arrayLibrarySource := ArrayBindings.SourceBridge.model_interpreted
  arrayValidType := rfl
  equations := model_ordinary_equations
  contracts := model_traversal_contracts
  lexical := ⟨Guarded.Expressions.modelCalls, fixedAt, rfl, Lexical.model_interpreted⟩
  bodyLibraries := Predicate.BodyLibraries.modelCalls
  bodyDefinitions := Predicate.BodyLibraries.model_definitions inherited.toRawHelperEquations
    (Lexical.interpreted_primitives Guarded.Expressions.modelCalls fixedAt Lexical.model_interpreted)
  bodyLinks := model_body_links
  actualImports := {Predicate.FunctionCallNative.modelImports with token := Expressions.modelCalls.function .takeToken}
  actualCalls := Predicate.FunctionCallNative.modelCalls
  assignment := fun text context scan catalog => Predicate.callAssignmentBody text context.model scan catalog
  actualLinks := Predicate.FunctionCallNative.model_imports_links inherited.toRawHelperEquations
  actualEquations := Predicate.FunctionCallNative.model_definitions_of_meaning
    (Predicate.FunctionCallNative.imports_meaning inherited.toRawHelperEquations
      (Predicate.BodyLibraries.predicate_helpers Predicate.BodyLibraries.modelCalls
        inherited.toRawHelperEquations (Predicate.BodyLibraries.model_definitions inherited.toRawHelperEquations
          (Lexical.interpreted_primitives Guarded.Expressions.modelCalls fixedAt Lexical.model_interpreted)))
      Predicate.Native.model_definition_equations Predicate.Native.model_contracts
      (Predicate.FunctionCallNative.model_imports_links inherited.toRawHelperEquations))
  actualLink := rfl

theorem model_interpreted_inherited (domain : Expressions.StateDomain)
    (inherited : InheritedEquations Expressions.modelCalls domain) (exactDomain : ExactDomain domain) :
    (model_interpreted domain inherited exactDomain).inherited = Expressions.modelCalls := rfl

end Silver.Compose.FunctionDeclarationNative
