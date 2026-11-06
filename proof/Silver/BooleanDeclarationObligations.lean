module

public import Silver.BooleanDeclarations
public import Silver.PredicateObligations

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts

def booleanDeclarationObligations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) :
    Boolean.Analysis → List BooleanDeclaration → List Obligation
  | _, [] => []
  | before, declaration :: rest =>
      declaration.value.obligations shape analysis flow before ++
        booleanDeclarationObligations shape analysis flow
          (before.initialize declaration.target declaration.mutable) rest

theorem boolean_declaration_obligations_exact (declarations : List BooleanDeclaration)
    (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) (before : Boolean.Analysis) :
    discharged (booleanDeclarationObligations shape analysis flow before declarations) =
      checkBooleanDeclarations shape analysis flow before declarations := by
  induction declarations generalizing before with
  | nil => rfl
  | cons declaration rest ih =>
      simp only [booleanDeclarationObligations, discharged_append, Condition.obligations_exact,
        ih, checkBooleanDeclarations]

end Silver.Predicate
