module

public import Silver.PathNativeExpressions

@[expose] public section

namespace Silver.PathFacts.Native

/-! Local checks that the path-library expression trees preserve Ada operator
precedence and left association when rendered without implicit parentheses.
Only the typed expression constructors used by this library are covered. -/

def Expr.primary : Expr ty → Bool
  | .add _ _ | .sub _ _ | .mul _ _ | .div _ _ | .eq _ _ | .ne _ _
  | .lt _ _ | .le _ _ | .gt _ _ | .ge _ _ | .boolEq _ _
  | .andThen _ _ | .orElse _ _ | .not _ | .ite _ _ _ | .elsif _ _ _
  | .cases _ _ _ _ _ _ _ | .local _ _ _ _ | .locals _
  | .assumeValid _ | .assumeInvalid _ | .rejected _ => false
  | _ => true

def Expr.factor : Expr ty → Bool
  | .not _ => true
  | value => value.primary

def Expr.term : Expr ty → Bool
  | .mul _ _ | .div _ _ => true
  | value => value.factor

def Expr.sum : Expr ty → Bool
  | .add _ _ | .sub _ _ => true
  | value => value.term

def Expr.relation : Expr ty → Bool
  | .eq _ _ | .ne _ _ | .lt _ _ | .le _ _ | .gt _ _ | .ge _ _ | .boolEq _ _ => true
  | value => value.sum

def Expr.andHead : Expr ty → Bool
  | .andThen _ _ => true
  | value => value.relation

def Expr.orHead : Expr ty → Bool
  | .orElse _ _ => true
  | value => value.relation

def Expr.expression (value : Expr ty) : Bool := value.andHead || value.orHead
def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false
def Expr.isLocal : Expr ty → Bool | .local _ _ _ _ => true | _ => false
def Expr.callSpine : Expr ty → Bool
  | .function _ => true | .app fn _ => fn.callSpine | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .number _ | .truth _ | .comparison _ | .variable _ | .function _ | .maxLength | .empty => true
  | .app fn arg => fn.callSpine && fn.wellFormed && arg.expression && arg.wellFormed
  | .field _ value => value.primary && value.wellFormed
  | .add left right | .sub left right => left.sum && right.term && left.wellFormed && right.wellFormed
  | .mul left right | .div left right => left.term && right.factor && left.wellFormed && right.wellFormed
  | .min _ left right | .max _ left right => left.expression && right.expression && left.wellFormed && right.wellFormed
  | .eq left right | .ne left right | .lt left right | .le left right | .gt left right | .ge left right
  | .boolEq left right => left.sum && right.sum && left.wellFormed && right.wellFormed
  | .not value => value.primary && value.wellFormed
  | .andThen left right => left.andHead && right.relation && left.wellFormed && right.wellFormed
  | .orElse left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .group value => value.wellFormed
  | .ite guard yes no | .elsif guard yes no =>
      guard.expression && yes.expression && (no.expression || no.isElsif) &&
        guard.wellFormed && yes.wellFormed && no.wellFormed
  | .cases operator eqCase neCase ltCase leCase gtCase geCase =>
      operator.expression && operator.wellFormed &&
        eqCase.expression && eqCase.wellFormed && neCase.expression && neCase.wellFormed &&
        ltCase.expression && ltCase.wellFormed && leCase.expression && leCase.wellFormed &&
        gtCase.expression && gtCase.wellFormed && geCase.expression && geCase.wellFormed
  | .local _ _ value rest => value.expression && value.wellFormed &&
      (rest.expression || rest.isLocal) && rest.wellFormed
  | .locals value => value.isLocal && value.wellFormed
  | .context _ lower upper valid invalid rejectedFlag =>
      lower.expression && lower.wellFormed && upper.expression && upper.wellFormed &&
        valid.expression && valid.wellFormed && invalid.expression && invalid.wellFormed &&
        rejectedFlag.expression && rejectedFlag.wellFormed
  | .assumeValid value | .assumeInvalid value | .rejected value => value.primary && value.wellFormed

abbrev WellFormedTrees : Prop :=
  compareBody.wellFormed = true ∧ complementBody.wellFormed = true ∧ swapBody.wellFormed = true ∧
  initialBody.wellFormed = true ∧ ceilingBody.wellFormed = true ∧ assumeValidBody.wellFormed = true ∧
  assumeInvalidBody.wellFormed = true ∧ rejectedBody.wellFormed = true ∧ completedBody.wellFormed = true ∧
  keepIfBody.wellFormed = true ∧ intersectBody.wellFormed = true ∧ joinBody.wellFormed = true ∧
  belowBody.wellFormed = true ∧ aboveBody.wellFormed = true ∧ refineInputTrueBody.wellFormed = true ∧
  refineInputBody.wellFormed = true ∧ refineBoundsBody.wellFormed = true ∧ lengthAtBody.wellFormed = true ∧
  fitsBody.wellFormed = true ∧ sameLengthBody.wellFormed = true ∧ equalIncreasingBody.wellFormed = true ∧
  refineEqualBody.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

end Silver.PathFacts.Native
