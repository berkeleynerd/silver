module

public import Silver.ComposeArrayTypeDeclarations

@[expose] public section

namespace Silver.Compose

/-- Type declarations observe declared component domains; they do not allocate
or read an initializer snapshot for an object. -/
def arrayTypeDeclarationRanges (state : ParserState) : Integer.Ranges :=
  ArrayBindings.viewRanges state.arrayNames.names [] false (ScalarExpression.ranges state.scalarNames)

/-- Both written bounds remain as raw arithmetic obligation schemas. -/
def ArrayTypeDeclarationChecksAt (text : Source) (state : ParserState)
    (checks : List Integer.Obligation) : Prop :=
  ∃ (parts : ArrayTypeDeclarationParts) (lower upper : Integer.Expr),
    arrayTypeDeclarationParts text state = parts ∧
    ScalarExpression.ArrayGrammar.At text state.scalarNames parts.start lower parts.lower
      (arrays := state.arrayNames.table) ∧
    ScalarExpression.ArrayGrammar.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
      (arrays := state.arrayNames.table) ∧
    checks = lower.obligations (arrayTypeDeclarationRanges state) ++
      upper.obligations (arrayTypeDeclarationRanges state)

theorem array_type_declaration_checks_trace {text arguments state final}
    (reading : ArrayTypeDeclarationAt text arguments state final) :
    ∃ checks, ArrayTypeDeclarationChecksAt text state checks := by
  cases reading with
  | declaration parts _ lower upper _ => exact ⟨_, _, _, _, parts, lower, upper, rfl⟩

theorem array_type_declaration_checks_discharge {text state checks}
    (trace : ArrayTypeDeclarationChecksAt text state checks) : Integer.discharged checks = true := by
  obtain ⟨parts, lower, upper, _, lowRead, highRead, rfl⟩ := trace
  have lowChecks : Integer.discharged (lower.obligations (arrayTypeDeclarationRanges state)) = true :=
    Integer.Expr.obligations_discharge lowRead.inferred
  have highChecks : Integer.discharged (upper.obligations (arrayTypeDeclarationRanges state)) = true :=
    Integer.Expr.obligations_discharge highRead.inferred
  rw [Integer.discharged_append, lowChecks, highChecks]
  rfl

theorem array_type_declaration_checks_unique {text state first second}
    (left : ArrayTypeDeclarationChecksAt text state first)
    (right : ArrayTypeDeclarationChecksAt text state second) : first = second := by
  obtain ⟨parts, lower, upper, partsEq, lowRead, highRead, rfl⟩ := left
  obtain ⟨otherParts, otherLower, otherUpper, otherPartsEq, otherLow, otherHigh, rfl⟩ := right
  have same := partsEq.symm.trans otherPartsEq
  cases same
  rw [(ScalarExpression.ArrayGrammar.at_unique lowRead otherLow).1,
    (ScalarExpression.ArrayGrammar.at_unique highRead otherHigh).1]

end Silver.Compose
