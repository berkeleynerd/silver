module

public import Silver.LengthIntervalExpressions

@[expose] public section
namespace Silver.LengthIntervals.Native

def Expr.primary : Expr ty → Bool
  | .add _ _ | .sub _ _ | .div _ _ | .eq _ _ | .ne _ _ | .lt _ _ | .le _ _ | .gt _ _
  | .andThen _ _ | .orElse _ _ | .ite _ _ _ | .elsif _ _ _ | .local _ _ _ _ | .locals _
  | .summary _ _ => false
  | _ => true

def Expr.term : Expr ty → Bool
  | .div _ _ => true | value => value.primary

def Expr.sum : Expr ty → Bool
  | .add _ _ | .sub _ _ => true | value => value.term

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .lt _ _ | .le _ _ | .gt _ _ => true | value => value.sum

def Expr.andHead : Expr ty → Bool
  | .andThen _ _ => true | value => value.relation

def Expr.orHead : Expr ty → Bool
  | .orElse _ _ => true | value => value.relation

def Expr.expression (value : Expr ty) : Bool := value.andHead || value.orHead
def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false
def Expr.isLocal : Expr ty → Bool | .local _ _ _ _ => true | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .variable _ | .number _ | .empty | .maxLength => true
  | .field _ value => value.primary && value.wellFormed
  | .add left right | .sub left right => left.sum && right.term && left.wellFormed && right.wellFormed
  | .div left right => left.term && right.primary && left.wellFormed && right.wellFormed
  | .eq left right | .ne left right | .lt left right | .le left right | .gt left right =>
      left.sum && right.sum && left.wellFormed && right.wellFormed
  | .andThen left right => left.andHead && right.relation && left.wellFormed && right.wellFormed
  | .orElse left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .group value => value.wellFormed
  | .ite guard yes no | .elsif guard yes no =>
      guard.expression && yes.expression && (no.expression || no.isElsif) &&
        guard.wellFormed && yes.wellFormed && no.wellFormed
  | .local _ _ value rest => value.expression && value.wellFormed &&
      (rest.expression || rest.isLocal) && rest.wellFormed
  | .locals value => value.isLocal && value.wellFormed
  | .summary a b => a.expression && a.wellFormed && b.expression && b.wellFormed
  | .isEmpty value | .lower value | .upper value => value.expression && value.wellFormed
  | .pathsFits facts value | .keepIf facts value =>
      facts.expression && facts.wellFormed && value.expression && value.wellFormed
  | .pathsSame facts left right | .intersect facts left right | .increasing facts left right =>
      facts.expression && facts.wellFormed && left.expression && left.wellFormed &&
        right.expression && right.wellFormed

def Expr.scoped (scope : List (Ty × String)) : Expr ty → Bool
  | .variable name => decide ((ty, name) ∈ scope)
  | .number _ | .empty | .maxLength => true
  | .field _ value | .group value | .locals value | .isEmpty value | .lower value | .upper value => value.scoped scope
  | .add a b | .sub a b | .div a b | .eq a b | .ne a b | .lt a b | .le a b | .gt a b
  | .andThen a b | .orElse a b | .summary a b | .pathsFits a b | .keepIf a b =>
      a.scoped scope && b.scoped scope
  | .ite a b c | .elsif a b c | .pathsSame a b c | .intersect a b c | .increasing a b c =>
      a.scoped scope && b.scoped scope && c.scoped scope
  | .local name _ value rest => value.scoped scope && rest.scoped ((.number, name) :: scope)

abbrev WellFormedTrees : Prop :=
  isEmptyBody.wellFormed = true ∧ lowerBody.wellFormed = true ∧ upperBody.wellFormed = true ∧
  fitsBody.wellFormed = true ∧ sameLengthBody.wellFormed = true ∧ increasingBody.wellFormed = true ∧
  refineEqualBody.wellFormed = true

abbrev ScopedTrees : Prop :=
  isEmptyBody.scoped [(.interval, "value")] = true ∧
  lowerBody.scoped [(.interval, "value")] = true ∧ upperBody.scoped [(.interval, "value")] = true ∧
  fitsBody.scoped [(.context, "facts"), (.interval, "value")] = true ∧
  sameLengthBody.scoped [(.context, "facts"), (.interval, "left"), (.interval, "right")] = true ∧
  increasingBody.scoped [(.context, "facts"), (.interval, "left"), (.interval, "right")] = true ∧
  refineEqualBody.scoped [(.context, "facts"), (.interval, "left"), (.interval, "right")] = true

theorem checked_precedence : WellFormedTrees := by decide +kernel
theorem checked_scope : ScopedTrees := by decide +kernel

end Silver.LengthIntervals.Native
