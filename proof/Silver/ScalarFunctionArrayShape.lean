module

public import Silver.ScalarFunctionFrame

@[expose] public section

namespace Silver.ScalarFunctions

/-- The source frame contains only array input formals, in their own
one-based slot order. Stored objects from Main are outside this scope. -/
def formalArrays : Nat → List ScalarType → List (Nat × Integer.ArrayDescriptor)
  | _, [] => []
  | slot, .array domain :: rest =>
      (domain.identity, domain.formal slot) :: formalArrays (slot + 1) rest
  | slot, _ :: rest => formalArrays slot rest

def frameExpression (arrays : List (Nat × Integer.ArrayDescriptor)) : Integer.Expr → Bool
  | .literal _ | .snapshot _ | .name _ => true
  | .indexed array index =>
      arrays.any (fun input => input.2 == array) && !index.hasArray && frameExpression arrays index
  | .positive value | .negative value | .parenthesized value => frameExpression arrays value
  | .add left right | .subtract left right | .multiply left right | .divide left right |
    .modulo left right | .remainder left right => frameExpression arrays left && frameExpression arrays right

end Silver.ScalarFunctions
