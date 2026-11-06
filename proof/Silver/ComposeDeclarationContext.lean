module

public import Silver.ComposeObjectDeclarations

@[expose] public section

namespace Silver.Compose

/-- Both initialized byte-store object kinds preserve every other declaration
environment and the retained header context. -/
theorem declaration_context_fields {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) :
    next.scalarNames = state.scalarNames ∧ next.arrayNames = state.arrayNames ∧
      next.subtypeNames = state.subtypeNames ∧ next.booleanNames = state.booleanNames ∧
      next.capacity = state.capacity ∧ next.target = state.target ∧
      next.dynamicFirst = state.dynamicFirst ∧ next.dynamicAfter = state.dynamicAfter := by
  cases parsed with
  | string _ source => cases source; exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  | character source => cases source; exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem declaration_arrayNames {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) : next.arrayNames = state.arrayNames :=
  (declaration_context_fields parsed).2.1

theorem declaration_subtypeNames {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) : next.subtypeNames = state.subtypeNames :=
  (declaration_context_fields parsed).2.2.1

theorem declaration_booleanNames {text arguments state next declaration}
    (parsed : DeclarationAt text arguments state declaration next) : next.booleanNames = state.booleanNames :=
  (declaration_context_fields parsed).2.2.2.1

end Silver.Compose
