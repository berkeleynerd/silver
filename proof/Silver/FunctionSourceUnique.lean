module

public import Silver.FunctionHeaderSource
public import Silver.PredicateBodyUnique

@[expose] public section

namespace Silver.Compose
open Predicate ScalarFunctions

theorem FunctionLocalsAt.unique {text arguments state leftState rightState
    leftIntegers rightIntegers leftBooleans rightBooleans leftChecks rightChecks leftBooleanChecks rightBooleanChecks}
    (first : FunctionLocalsAt text arguments state leftIntegers leftBooleans leftChecks leftBooleanChecks leftState)
    (second : FunctionLocalsAt text arguments state rightIntegers rightBooleans rightChecks rightBooleanChecks rightState) :
    leftIntegers = rightIntegers ∧ leftBooleans = rightBooleans ∧ leftChecks = rightChecks ∧
      leftBooleanChecks = rightBooleanChecks ∧ leftState = rightState := by
  induction first generalizing rightState rightIntegers rightBooleans rightChecks rightBooleanChecks with
  | done positive stop =>
    cases second with
    | done => exact ⟨rfl, rfl, rfl, rfl, rfl⟩
    | integer _ more | boolean _ more => exact False.elim (stop more)
  | integer positive more parsed raw advanced rest ih =>
    cases second with
    | done _ stop => exact False.elim (stop more)
    | integer _ _ other otherRaw _ remaining =>
      obtain ⟨rfl, rfl⟩ := scalar_declaration_unique parsed other
      have checks := scalar_declaration_checks_unique raw otherRaw
      obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := ih remaining
      rw [checks]
      exact ⟨rfl, rfl, rfl, rfl, rfl⟩
    | boolean _ _ noScalar =>
      have accepted := scalar_declaration_positive parsed
      rw [← scalar_declaration_complete parsed, noScalar] at accepted
      contradiction
  | boolean positive more noScalar parsed raw advanced rest ih =>
    cases second with
    | done _ stop => exact False.elim (stop more)
    | integer _ _ other =>
      have accepted := scalar_declaration_positive other
      rw [← scalar_declaration_complete other, noScalar] at accepted
      contradiction
    | boolean _ _ _ other otherRaw _ remaining =>
      have same := boolean_declaration_unique parsed other
      cases same
      obtain ⟨rfl, rfl⟩ := boolean_declaration_checks_unique raw otherRaw
      obtain ⟨rfl, rfl, rfl, rfl, rfl⟩ := ih remaining
      exact ⟨rfl, rfl, rfl, rfl, rfl⟩

theorem FunctionBodySource.unique {text frame first after resultType arguments left right}
    (a : FunctionBodySource text frame first after resultType arguments left)
    (b : FunctionBodySource text frame first after resultType arguments right) : left = right := by
  cases a with
  | parsed locals _ _ body result =>
    cases b with
    | parsed otherLocals _ _ otherBody otherResult =>
      obtain ⟨rfl, rfl, rfl, rfl, _⟩ := locals.unique otherLocals
      have items := bodyTail_unique body otherBody
      have returned := (actual_unique result otherResult).1
      cases items
      cases returned
      rfl

theorem FunctionDeclarationSource.unique {text state arguments left right}
    (a : FunctionDeclarationSource text state arguments left)
    (b : FunctionDeclarationSource text state arguments right) : left = right := by
  cases a with
  | parsed _ body => cases b with
    | parsed _ other => exact body.unique other

end Silver.Compose
