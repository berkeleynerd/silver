module

public import Silver.BooleanDeclarations
public import Silver.PredicateObligations

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts

def booleanDeclarationObligations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) :
    Nat → List BooleanDeclaration → List Obligation
  | _, [] => []
  | count, declaration :: rest =>
      declaration.value.obligations shape analysis flow (booleanInitialAnalysis count) ++
        booleanDeclarationObligations shape analysis flow (count + 1) rest

theorem boolean_declaration_obligations_exact (declarations : List BooleanDeclaration)
    (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) (count : Nat) :
    discharged (booleanDeclarationObligations shape analysis flow count declarations) =
      checkBooleanDeclarations shape analysis flow count declarations := by
  induction declarations generalizing count with
  | nil => rfl
  | cons declaration rest ih =>
      simp only [booleanDeclarationObligations, discharged_append, Condition.obligations_exact,
        ih, checkBooleanDeclarations]

end Silver.Predicate
