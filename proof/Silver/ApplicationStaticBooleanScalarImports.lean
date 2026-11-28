module

public import Silver.ApplicationStaticBooleanBodyImports

@[expose] public section

/-! `Scalars.Is_Empty` is a library call in the original relation body. The
typed relation expression uses its interval meaning; this file justifies that
primitive on both actual operands after the original declarations and right
assignment, including failed reads and arbitrary initially unassigned locals. -/
namespace Silver.BooleanElaboration.Native.SourceImports
open Compose Compose.Expressions ApplicationPackageDeclarations

set_option backward.dsimp.instances true

theorem scalar_result_bounds (library : ObjectLibraries) {text : Source} (valid : ValidText text)
    {position : Nat} (bounded : ValidCursor text position) {names : ScalarExpression.Environment}
    (environment : ScalarExpression.ValidEnvironment text names) :
    ((ofObjects library).scalar text position names).after ≤ text.length + 1 ∧
      ((ofObjects library).scalar text position names).bounds.Bounded := by
  rw [(ofObjects_meaning library).scalar text valid position names bounded environment]
  refine ⟨?_, (ScalarExpression.Native.read_type valid bounded).2.1⟩
  by_cases failed : (modelImports.scalar text position names).after = 0
  · rw [failed]; exact Nat.zero_le _
  · exact (ScalarExpression.read_arrays_bounds bounded failed).2.1

/-- The precise frame at the two original Is_Empty calls: execute all original
declarations, then the scalar branch's assignment to Right. No initial scalar,
comparison or Boolean local is assumed initialized. -/
def scalarOperandsFrame (library : ObjectLibraries) (factor : Reader) (initial : Relation.Frame) : Relation.Frame :=
  let declared := Relation.declarations.foldl (Relation.Declaration.eval (ofObjects library) factor) initial
  declared.setScalar .right
    ((Relation.Expr.readScalar (.afterComparison (.comparison .scalar))).eval (ofObjects library) factor declared)

theorem scalarOperandsFrame_left (library : ObjectLibraries) (factor : Reader) (initial : Relation.Frame) :
    ((scalarOperandsFrame library factor initial).scalars .left) =
      (ofObjects library).scalar initial.text initial.position initial.state.scalarNames := rfl

theorem scalarOperandsFrame_right (library : ObjectLibraries) (factor : Reader) (initial : Relation.Frame) :
    ((scalarOperandsFrame library factor initial).scalars .right) =
      (ofObjects library).scalar initial.text
        ((ofObjects library).comparison initial.text
          ((ofObjects library).scalar initial.text initial.position initial.state.scalarNames).after).after
        initial.state.scalarNames := rfl

theorem scalarOperandsFrame_bounded (library : ObjectLibraries) (factor : Reader) (initial : Relation.Frame)
    (domain : SourceChecks.Domain initial.text initial.state initial.position) (which : Relation.ScalarLocal) :
    ((scalarOperandsFrame library factor initial).scalars which).bounds.Bounded := by
  have names := domain.frameDomain.base.2.2.2.2.2.1
  have left := scalar_result_bounds library domain.textValid domain.cursor names
  have compared : ((ofObjects library).comparison initial.text
      ((ofObjects library).scalar initial.text initial.position initial.state.scalarNames).after).after ≤
      initial.text.length + 1 := by
    rw [(ofObjects_meaning library).comparison initial.text domain.textValid _ left.1]
    exact Predicate.comparison_bound _ _ left.1
  have right := scalar_result_bounds library domain.textValid compared names
  cases which with
  | left => rw [scalarOperandsFrame_left]; exact left.2
  | right => rw [scalarOperandsFrame_right]; exact right.2

/-- The actual imported Is_Empty call and the primitive interpretation in the
same typed source tree agree on each original operand. The source-library law
is applied only after deriving its interval domain from the actual scalar and
comparison calls; no operand bound or Is_Empty equality is a caller premise. -/
theorem scalar_empty_source (library : ObjectLibraries) (factor : Reader) (initial : Relation.Frame)
    (domain : SourceChecks.Domain initial.text initial.state initial.position) (which : Relation.ScalarLocal) :
    library.names.shared.composed.function .scalarEmpty
      ((scalarOperandsFrame library factor initial).scalars which).bounds =
      (Relation.Expr.empty (.bounds (.scalar which))).eval (ofObjects library) factor
        (scalarOperandsFrame library factor initial) :=
  library.names.shared.inherited.scalarEmpty _ (scalarOperandsFrame_bounded library factor initial domain which)

end Silver.BooleanElaboration.Native.SourceImports
