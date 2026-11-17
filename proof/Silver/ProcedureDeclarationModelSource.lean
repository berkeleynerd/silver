module

public import Silver.ProcedureDeclarationSourceBridge
public import Silver.ProcedureDeclarationHelperModelSource

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

theorem model_high_equations : HighEquations modelCalls where
  body text _ outer frame first after arguments _ := by
    rw [body_denotation, body_model_equation]
    rfl
  declaration text _ state arguments _ := by
    rw [declaration_denotation, declaration_model_equation]
    rfl

theorem model_outer_links (domain : Expressions.StateDomain)
    (inherited : FunctionDeclarationNative.InheritedEquations Expressions.modelCalls domain)
    (exactDomain : FunctionDeclarationNative.ExactDomain domain) :
    OuterLinks modelCalls (model_interpreted_helpers domain inherited exactDomain) where
  locals := rfl
  bodyOf := rfl
  tail := rfl
  read := rfl
  append := rfl
  nameIs := rfl
  hiddenOuter := rfl

/-- The witness uses only lower inherited helper equations. The complete
procedure declaration equality is a consequence of the typed trees above. -/
noncomputable def model_interpreted (domain : Expressions.StateDomain)
    (inherited : FunctionDeclarationNative.InheritedEquations Expressions.modelCalls domain)
    (exactDomain : FunctionDeclarationNative.ExactDomain domain) : InterpretedSource modelCalls where
  helpers := model_interpreted_helpers domain inherited exactDomain
  links := model_outer_links domain inherited exactDomain
  equations := model_high_equations

end Silver.Compose.ProcedureDeclarationNative
