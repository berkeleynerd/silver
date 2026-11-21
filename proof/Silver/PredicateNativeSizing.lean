module

public import Silver.PredicateNativeEquations
public import Silver.PredicateConditionFlow

@[expose] public section

namespace Silver.Predicate.Native

/-- Discriminants are retained in the source tree and checked against both
active vectors before projecting a native condition record. A constrained
local also checks the complete result of its initializing call. This is an
additional interpretation obligation, separate from precedence and scope. -/
def Expr.Sized (calls : Calls) (locals : Locals) : Expr ty → Prop
  | .operation _ | .number _ | .noElements | .maxScalarOperands | .truth _ | .word _ | .emptyPath | .validityCallWord | .token _ | .chain _ | .comparison _ | .variable _ | .function _ => True
  | .app fn arg | .appNamed fn _ arg => fn.Sized calls locals ∧ arg.Sized calls locals
  | .field _ value | .notEquality value | .notChain value | .not value | .group value | .old value | .locals value =>
      value.Sized calls locals
  | .subtypeHidden left right | .bindingAt left right | .arrayBindingAt left right | .eq left right | .ne left right | .le left right | .tokenEq left right
  | .chainEq left right | .chainNe left right | .tokenNe left right | .comparisonEq left right | .andThen left right | .orElse left right
  | .bound left right | .compared left right | .length left right
  | .updateAfter left right | .updatePath left right => left.Sized calls locals ∧ right.Sized calls locals
  | .chainCase value no shortAnd shortOr eagerAnd eagerOr eagerXor =>
      value.Sized calls locals ∧
        match value.eval calls locals with
        | .noChain => no.Sized calls locals
        | .shortAnd => shortAnd.Sized calls locals
        | .shortOr => shortOr.Sized calls locals
        | .eagerAnd => eagerAnd.Sized calls locals
        | .eagerOr => eagerOr.Sized calls locals
        | .eagerXor => eagerXor.Sized calls locals
  | .ite guard yes no | .elsif guard yes no =>
      guard.Sized calls locals ∧
        (if guard.eval calls locals then yes.Sized calls locals else no.Sized calls locals)
  | .summary low high count empty =>
      low.Sized calls locals ∧ high.Sized calls locals ∧ count.Sized calls locals ∧ empty.Sized calls locals
  | .condition _ count after yes no =>
      count.Sized calls locals ∧ after.Sized calls locals ∧ yes.Sized calls locals ∧ no.Sized calls locals ∧
        (yes.eval calls locals).count = count.eval calls locals ∧
        (no.eval calls locals).count = count.eval calls locals
  | .invalid facts => facts.Sized calls locals ∧
      (calls.invalidCondition (facts.eval calls locals)).Counts (facts.eval calls locals).count
  | .local (a := ty) name _ value rest => value.Sized calls locals ∧
      rest.Sized calls (locals.set ty name (value.eval calls locals))
  | .localCondition name count value rest =>
      count.Sized calls locals ∧ value.Sized calls locals ∧
        (value.eval calls locals).Counts (count.eval calls locals) ∧
        rest.Sized calls (locals.set .condition name (value.eval calls locals))

theorem sized_condition_counts {calls locals named count after yes no}
    (sized : (Expr.condition named count after yes no).Sized calls locals) :
    ((Expr.condition named count after yes no).eval calls locals).Counts (count.eval calls locals) :=
  sized.2.2.2.2

end Silver.Predicate.Native
