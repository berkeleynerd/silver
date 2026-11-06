module

public import Silver.ComposeArrayChecks
public import Silver.ComposeBooleanArrayElaboration

@[expose] public section

/-! Boolean-array declarations retain the Integer checks in both bounds and
in the singleton association. Aggregate Boolean conditions have a separate raw
obligation trace. -/
namespace Silver.Compose

def BooleanArrayHeaderChecksAt (text : Source) (state : ParserState)
    (checks : List Integer.Obligation) : Prop :=
  ∃ parts lower upper association,
    arrayDeclarationParts text state = parts ∧
    ScalarExpression.At text state.scalarNames (fixedAfter text parts.arrayAfter "(" false) lower parts.lower
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) ∧
    ScalarExpression.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) ∧
    ArrayAggregateChecksAt text state parts association ∧
    checks = lower.obligations (declarationRanges state) ++ upper.obligations (declarationRanges state) ++
      association

theorem boolean_array_header_checks_trace {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final) :
    ∃ checks, BooleanArrayHeaderChecksAt text state checks := by
  cases reading with
  | declaration parts _ low high aggregate _ _ _ _ =>
      obtain ⟨association, trace⟩ := arrayAggregate_checks_trace aggregate
      exact ⟨_, _, _, _, association, parts, low, high, trace, rfl⟩

theorem boolean_array_header_checks_discharge {text state checks}
    (trace : BooleanArrayHeaderChecksAt text state checks) : Integer.discharged checks = true := by
  obtain ⟨parts, lower, upper, association, _, low, high, aggregate, rfl⟩ := trace
  have lowChecks : Integer.discharged (lower.obligations (declarationRanges state)) = true :=
    Integer.Expr.obligations_discharge low.inferred
  have highChecks : Integer.discharged (upper.obligations (declarationRanges state)) = true :=
    Integer.Expr.obligations_discharge high.inferred
  simp only [Integer.discharged_append, lowChecks, highChecks, arrayAggregate_checks_discharge aggregate,
    Bool.and_self]

theorem boolean_array_header_checks_unique {text state left right}
    (first : BooleanArrayHeaderChecksAt text state left)
    (second : BooleanArrayHeaderChecksAt text state right) : left = right := by
  obtain ⟨parts, lower, upper, association, partsEq, low, high, aggregate, rfl⟩ := first
  obtain ⟨otherParts, otherLower, otherUpper, otherAssociation, otherPartsEq, otherLow, otherHigh, otherAggregate, rfl⟩ := second
  have sameParts := partsEq.symm.trans otherPartsEq
  cases sameParts
  rw [(ScalarExpression.at_unique low otherLow).1, (ScalarExpression.at_unique high otherHigh).1,
    arrayAggregate_checks_unique aggregate otherAggregate]

end Silver.Compose
