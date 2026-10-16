module

public import Silver.PredicateNativeBodies

@[expose] public section

namespace Silver.Predicate.Native

def Expr.primary : Expr ty → Bool
  | .ite _ _ _ | .elsif _ _ _ | .local _ _ _ _ | .locals _
  | .andThen _ _ | .orElse _ _ | .eq _ _ | .ne _ _ | .le _ _
  | .tokenEq _ _ | .tokenNe _ _ | .comparisonEq _ _ | .notEquality _ | .notChain _ | .not _ => false
  | _ => true

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .le _ _ | .tokenEq _ _ | .tokenNe _ _ | .comparisonEq _ _
  | .notEquality _ | .notChain _ | .not _ => true
  | value => value.primary

def Expr.andHead : Expr ty → Bool
  | .andThen _ _ => true
  | value => value.relation

def Expr.orHead : Expr ty → Bool
  | .orElse _ _ => true
  | value => value.relation

def Expr.conditional (value : Expr .truth) : Bool := value.andHead || value.orHead

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false

def Expr.isLocal : Expr ty → Bool | .local _ _ _ _ => true | _ => false

def Expr.callSpine : Expr ty → Bool
  | .function _ => true | .app fn _ => fn.callSpine | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .operation _ | .number _ | .truth _ | .token _ | .comparison _ | .variable _ | .function _ | .invalid => true
  | .app fn arg => fn.callSpine && fn.wellFormed && arg.primary && arg.wellFormed
  | .field _ value => value.primary && value.wellFormed
  | .bindingAt names index => names.primary && names.wellFormed && index.primary && index.wellFormed
  | .eq left right | .ne left right | .le left right | .tokenEq left right | .tokenNe left right
  | .comparisonEq left right => left.primary && right.primary && left.wellFormed && right.wellFormed
  | .notEquality value | .notChain value | .not value => value.primary && value.wellFormed
  | .andThen left right => left.andHead && right.relation && left.wellFormed && right.wellFormed
  | .orElse left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .group value => value.wellFormed
  | .ite guard yes no | .elsif guard yes no =>
      guard.conditional && yes.primary && (no.primary || no.isElsif) && guard.wellFormed && yes.wellFormed && no.wellFormed
  | .local _ _ value rest => value.primary && value.wellFormed && (rest.primary || rest.isLocal) && rest.wellFormed
  | .locals value => value.isLocal && value.wellFormed
  | .summary low high count empty => low.primary && high.primary && count.primary && empty.primary &&
      low.wellFormed && high.wellFormed && count.wellFormed && empty.wellFormed
  | .bound left right | .compared left right | .length left right =>
      left.primary && right.primary && left.wellFormed && right.wellFormed
  | .condition after yes no => after.primary && yes.primary && no.primary &&
      after.wellFormed && yes.wellFormed && no.wellFormed
  | .updateAfter value after => value.primary && after.primary && value.wellFormed && after.wellFormed

abbrev Scope := List (Ty × String)

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .variable (ty := ty) name => (ty, name) ∈ scope
  | .operation _ | .number _ | .truth _ | .token _ | .comparison _ | .function _ | .invalid => true
  | .app fn arg => fn.scoped scope && arg.scoped scope
  | .field _ value | .notEquality value | .notChain value | .not value | .group value | .locals value => value.scoped scope
  | .bindingAt left right | .eq left right | .ne left right | .le left right | .tokenEq left right
  | .tokenNe left right | .comparisonEq left right | .andThen left right | .orElse left right
  | .bound left right | .compared left right | .length left right
  | .updateAfter left right => left.scoped scope && right.scoped scope
  | .ite guard yes no | .elsif guard yes no => guard.scoped scope && yes.scoped scope && no.scoped scope
  | .summary low high count empty => low.scoped scope && high.scoped scope && count.scoped scope && empty.scoped scope
  | .condition after yes no => after.scoped scope && yes.scoped scope && no.scoped scope
  | .local (a := ty) name _ value rest => value.scoped scope &&
      rest.scoped ((ty, name) :: scope.filter (fun entry => entry.2 != name))

abbrev WellFormedTrees : Prop :=
  summaryBody.wellFormed = true ∧ bindingSummaryBody.wellFormed = true ∧ boundBody.wellFormed = true ∧ comparisonBody.wellFormed = true ∧
  lengthBody.wellFormed = true ∧ primaryBody.wellFormed = true ∧ relationBody.wellFormed = true ∧
  chainTokenBody.wellFormed = true ∧ chainAfterBody.wellFormed = true ∧ tailBody.wellFormed = true ∧
  modelBody.wellFormed = true ∧ conditionBody.wellFormed = true

abbrev WellScopedTrees : Prop :=
  summaryBody.scoped [(.result, "value")] = true ∧ bindingSummaryBody.scoped [(.binding, "value")] = true ∧ boundBody.scoped [(.binding, "value")] = true ∧
  comparisonBody.scoped [(.source, "text"), (.number, "position")] = true ∧
  lengthBody.scoped [(.source, "text"), (.context, "context"), (.number, "position"), (.truth, "literal")] = true ∧
  primaryBody.scoped [(.source, "text"), (.context, "context"), (.number, "position"), (.facts, "facts")] = true ∧
  relationBody.scoped [(.source, "text"), (.context, "context"), (.number, "position"), (.facts, "facts")] = true ∧
  chainTokenBody.scoped [(.source, "text"), (.number, "position")] = true ∧
  chainAfterBody.scoped [(.source, "text"), (.number, "position"), (.token, "operator")] = true ∧
  tailBody.scoped [(.source, "text"), (.context, "context"), (.condition, "result"), (.token, "operator"), (.truth, "chained")] = true ∧
  modelBody.scoped [(.source, "text"), (.context, "context"), (.number, "position"), (.facts, "facts")] = true ∧
  conditionBody.scoped [(.source, "text"), (.context, "context"), (.number, "position"), (.facts, "facts")] = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

theorem checked_scopes : WellScopedTrees := by decide +kernel

end Silver.Predicate.Native
