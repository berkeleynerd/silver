module

public import Silver.PackageReindex
public import Silver.ScalarProcedureSyntax

@[expose] public section

/-! The package effect model's explicit read lists are covered by the inherited
syntactic occurrence predicates. Array storage reads may make the latter larger;
no converse is needed for package scalar-state coverage. -/
namespace Silver.Packages

theorem integerReads_integer (expression : Integer.Expr) (identity : Nat)
    (read : .integer identity ∈ integerReads expression) :
    ScalarProcedures.integerMentions identity expression = true := by
  induction expression with
  | literal | snapshot => simp [integerReads] at read
  | name index => simpa [integerReads, ScalarProcedures.integerMentions] using read
  | indexed array index ih =>
      exact Bool.or_eq_true_iff.mpr (Or.inr (ih read))
  | positive value ih | negative value ih | parenthesized value ih => exact ih read
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr
  | divide left right ihl ihr | modulo left right ihl ihr | remainder left right ihl ihr =>
      exact Bool.or_eq_true_iff.mpr ((List.mem_append.mp read).imp ihl ihr)

theorem integerReads_no_boolean (expression : Integer.Expr) (identity : Nat) :
    .boolean identity ∉ integerReads expression := by
  induction expression <;> simp_all [integerReads]

theorem conditionReads_mentioned (expression : Predicate.Condition) (cell : Cell)
    (read : cell ∈ conditionReads expression) :
    ScalarProcedures.conditionMentions cell expression = true := by
  induction expression with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanLiteral | booleanArrayRead =>
      simp [conditionReads] at read
  | booleanName identity => simpa [conditionReads, ScalarProcedures.conditionMentions] using read
  | scalarCompare operator left right =>
      cases cell with
      | integer identity =>
          exact Bool.or_eq_true_iff.mpr ((List.mem_append.mp read).imp
            (integerReads_integer left identity) (integerReads_integer right identity))
      | boolean identity =>
          exact False.elim ((List.mem_append.mp read).elim (integerReads_no_boolean left identity)
            (integerReads_no_boolean right identity))
  | parenthesized inner ih | negated inner ih => exact ih read
  | andThen left right ihl ihr | orElse left right ihl ihr | eager operator left right ihl ihr
  | booleanCompare unequal left right ihl ihr =>
      exact Bool.or_eq_true_iff.mpr ((List.mem_append.mp read).imp ihl ihr)

end Silver.Packages
