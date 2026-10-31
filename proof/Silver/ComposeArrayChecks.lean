module

public import Silver.ComposeArrayElaboration

@[expose] public section

/-! Raw array bounds, singleton association choices and all component
expressions remain in the initializer obligation trace. -/
namespace Silver.Compose

def ArrayAggregateChecksAt (text : Source) (state : ParserState) (parts : ArrayDeclarationParts)
    (checks : List Integer.Obligation) : Prop :=
  if parts.length = 1 then
    ∃ expression result,
      ScalarExpression.At text state.scalarNames parts.position expression result
        (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) ∧
      checks = expression.obligations (declarationRanges state)
  else checks = []

theorem arrayAggregate_checks_trace {text state parts position}
    (reading : ArrayAggregateAt text state parts position) :
    ∃ checks, ArrayAggregateChecksAt text state parts checks := by
  cases reading with
  | positional multiple => exact ⟨[], by simp only [ArrayAggregateChecksAt, multiple, ↓reduceIte]⟩
  | @singleton expression result single reading _ _ _ _ _ =>
      refine ⟨expression.obligations (declarationRanges state), ?_⟩
      simp only [ArrayAggregateChecksAt, single, ↓reduceIte]
      exact ⟨_, _, reading, rfl⟩

theorem arrayAggregate_checks_discharge {text state parts checks}
    (trace : ArrayAggregateChecksAt text state parts checks) : Integer.discharged checks = true := by
  unfold ArrayAggregateChecksAt at trace
  split at trace
  · obtain ⟨expression, result, reading, rfl⟩ := trace
    exact Integer.Expr.obligations_discharge reading.inferred
  · rw [trace]; rfl

theorem arrayAggregate_checks_unique {text state parts left right}
    (first : ArrayAggregateChecksAt text state parts left)
    (second : ArrayAggregateChecksAt text state parts right) : left = right := by
  unfold ArrayAggregateChecksAt at first second
  split at first
  · rename_i single
    rw [ite_eq_left single] at second
    obtain ⟨expression, result, reading, rfl⟩ := first
    obtain ⟨other, otherResult, otherReading, rfl⟩ := second
    rw [(ScalarExpression.at_unique reading otherReading).1]
  · rename_i multiple
    rw [ite_eq_right multiple] at second
    exact first.trans second.symm

def ArrayDeclarationChecksAt (text : Source) (state : ParserState)
    (declaration : Integer.ArrayDeclaration) (checks : List Integer.Obligation) : Prop :=
  ∃ parts lower upper association,
    arrayDeclarationParts text state = parts ∧
    ScalarExpression.At text state.scalarNames (fixedAfter text parts.arrayAfter "(" false) lower parts.lower
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) ∧
    ScalarExpression.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) ∧
    ArrayAggregateChecksAt text state parts association ∧
    checks = lower.obligations (declarationRanges state) ++ upper.obligations (declarationRanges state) ++
      association ++ declaration.obligations (declarationRanges state)

theorem array_declaration_checks_trace {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    ∃ checks, ArrayDeclarationChecksAt text state declaration checks := by
  cases reading with
  | declaration parts _ _ low high aggregate _ _ _ =>
      obtain ⟨association, trace⟩ := arrayAggregate_checks_trace aggregate
      exact ⟨_, _, _, _, association, parts, low, high, trace, rfl⟩

theorem array_declaration_checks_discharge {text arguments state declaration final checks}
    (reading : ArrayDeclarationAt text arguments state declaration final)
    (trace : ArrayDeclarationChecksAt text state declaration checks)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) : Integer.discharged checks = true := by
  obtain ⟨parts, lower, upper, association, _, low, high, aggregate, rfl⟩ := trace
  obtain ⟨items, checked⟩ := array_declaration_checked reading subtypes
  have lowChecks : Integer.discharged (lower.obligations (declarationRanges state)) = true :=
    Integer.Expr.obligations_discharge low.inferred
  have highChecks : Integer.discharged (upper.obligations (declarationRanges state)) = true :=
    Integer.Expr.obligations_discharge high.inferred
  simp only [Integer.discharged_append, lowChecks, highChecks, arrayAggregate_checks_discharge aggregate,
    Integer.ArrayDeclaration.obligations_discharge checked, Bool.and_self]

theorem array_declaration_checks_unique {text state declaration left right}
    (first : ArrayDeclarationChecksAt text state declaration left)
    (second : ArrayDeclarationChecksAt text state declaration right) : left = right := by
  obtain ⟨parts, lower, upper, association, partsEq, low, high, aggregate, rfl⟩ := first
  obtain ⟨otherParts, otherLower, otherUpper, otherAssociation, otherPartsEq, otherLow, otherHigh, otherAggregate, rfl⟩ := second
  have sameParts := partsEq.symm.trans otherPartsEq
  cases sameParts
  rw [(ScalarExpression.at_unique low otherLow).1, (ScalarExpression.at_unique high otherHigh).1,
    arrayAggregate_checks_unique aggregate otherAggregate]

end Silver.Compose
