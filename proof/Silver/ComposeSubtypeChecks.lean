module

public import Silver.ComposeSubtypeDeclarations

@[expose] public section

namespace Silver.Compose

/-- Every subtype range retains both raw arithmetic endpoint schemas.
The declaration does not allocate an Integer value cell. -/
def SubtypeDeclarationChecksAt (text : Source) (state : ParserState)
    (checks : List Integer.Obligation) : Prop :=
  ∃ (low high : Integer.Expr) (lower upper : ScalarExpression.Result),
    ScalarExpression.At text state.scalarNames
      (fixedAfter text (subtypeDeclarationParts text state).typeAfter "range" true) low lower ∧
    ScalarExpression.At text state.scalarNames (fixedAfter text lower.after ".." false) high upper ∧
    checks = low.obligations (ScalarExpression.ranges state.scalarNames) ++
      high.obligations (ScalarExpression.ranges state.scalarNames)

theorem subtype_declaration_checks_trace {text arguments state next}
    (reading : SubtypeDeclarationAt text arguments state next) :
    ∃ checks, SubtypeDeclarationChecksAt text state checks := by
  cases reading with
  | @declaration parts partsEq ready constraint =>
      generalize resultEq : parts.constraint = result at constraint
      cases constraint with
      | absent missing => exact False.elim (ready.2.2.2.2.1 missing)
      | @present low high lower upper _ lowRead _ highRead _ _ _ _ _ _ _ =>
          refine ⟨_, low, high, lower, upper, ?_, highRead, rfl⟩
          simpa only [partsEq] using lowRead

theorem subtype_declaration_checks_discharge {text state checks}
    (trace : SubtypeDeclarationChecksAt text state checks) : Integer.discharged checks = true := by
  obtain ⟨low, high, lower, upper, lowRead, highRead, rfl⟩ := trace
  have lowChecks := Integer.Expr.obligations_discharge lowRead.inferred
  have highChecks := Integer.Expr.obligations_discharge highRead.inferred
  change Integer.discharged (low.obligations (ScalarExpression.ranges state.scalarNames)) = true at lowChecks
  change Integer.discharged (high.obligations (ScalarExpression.ranges state.scalarNames)) = true at highChecks
  rw [Integer.discharged_append, lowChecks, highChecks]
  rfl

theorem subtype_declaration_checks_unique {text state first second}
    (left : SubtypeDeclarationChecksAt text state first)
    (right : SubtypeDeclarationChecksAt text state second) : first = second := by
  obtain ⟨low, high, lower, upper, lowRead, highRead, rfl⟩ := left
  obtain ⟨otherLow, otherHigh, otherLower, otherUpper, otherLowRead, otherHighRead, rfl⟩ := right
  obtain ⟨rfl, rfl⟩ := ScalarExpression.at_unique lowRead otherLowRead
  rw [(ScalarExpression.at_unique highRead otherHighRead).1]

end Silver.Compose
