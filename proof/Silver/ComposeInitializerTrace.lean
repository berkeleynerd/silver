module

public import Silver.ComposeDeclarations
public import Silver.ComposeSubtypeChecks
public import Silver.ComposeArrayChecks
public import Silver.StringObligations

@[expose] public section

/-! The raw String initializer projection retains Image arithmetic schemas
alongside the proved frozen execution model. Its source witness fixes all
Image operands, including their actual visibility and arithmetic syntax. -/
namespace Silver.Compose
open Bindings

def DeclarationChecksAt (text : Source) (state : ParserState) (declaration : Declaration)
    (checks : List Integer.Obligation) : Prop :=
  ∃ raw result,
    ExpressionAt text state.names (declarationValuePosition text state) raw result state.scalarNames
      (declarationIntegerHidden text state)
      state.arrayNames.names state.arrayNames.values true ∧
    declaration.initializer = raw.freezeImages (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    checks = raw.imageObligations (ArrayBindings.ranges state.arrayNames.names state.arrayNames.values true
      (ScalarExpression.ranges state.scalarNames))

theorem declaration_image_trace {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (parsed : DeclarationAt text arguments state declaration next) :
    ∃ checks, DeclarationChecksAt text state declaration checks := by
  cases parsed with
  | declaration parts allowed following count bounded nonempty exact value =>
      exact ⟨_, _, _, value, rfl, rfl⟩

theorem declaration_image_checks {text : Source} {state : ParserState}
    {declaration : Declaration} {checks : List Integer.Obligation}
    (normal : NamesNormal state.names) (trace : DeclarationChecksAt text state declaration checks) :
    Integer.discharged checks = true := by
  obtain ⟨raw, result, parsed, _, rfl⟩ := trace
  exact Expression.image_obligations_discharge (expressionAt_inferLength normal parsed)

theorem declaration_image_unique {text : Source} {state : ParserState} {declaration : Declaration}
    {first second : List Integer.Obligation}
    (left : DeclarationChecksAt text state declaration first)
    (right : DeclarationChecksAt text state declaration second) : first = second := by
  obtain ⟨raw, result, parsed, _, rfl⟩ := left
  obtain ⟨other, otherResult, otherParsed, _, rfl⟩ := right
  rw [(expressionTail_unique parsed otherParsed).1]

/-- The scalar projection may freeze array reads, but its complete raw
initializer stays in the obligation trace, including arithmetic and indexing. -/
def ScalarDeclarationChecksAt (text : Source) (state : ParserState) (declaration : Integer.Declaration)
    (checks : List Integer.Obligation) : Prop :=
  ∃ raw result,
    ScalarExpression.At text state.scalarNames (scalarDeclarationValuePosition text state) raw result
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) ∧
    declaration.value = raw.freezeArrays
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    checks = raw.obligations (ArrayBindings.ranges state.arrayNames.names state.arrayNames.values true
      (ScalarExpression.ranges state.scalarNames))

theorem scalar_declaration_checks_trace {text arguments state next declaration}
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ∃ checks, ScalarDeclarationChecksAt text state declaration checks := by
  cases parsed with
  | declaration _ _ _ reading => exact ⟨_, _, _, reading, rfl, rfl⟩

theorem scalar_declaration_checks_discharge {text state declaration checks}
    (trace : ScalarDeclarationChecksAt text state declaration checks) : Integer.discharged checks = true := by
  obtain ⟨raw, result, parsed, _, rfl⟩ := trace
  exact Integer.Expr.obligations_discharge parsed.inferred

theorem scalar_declaration_checks_unique {text state declaration first second}
    (left : ScalarDeclarationChecksAt text state declaration first)
    (right : ScalarDeclarationChecksAt text state declaration second) : first = second := by
  obtain ⟨raw, result, parsed, _, rfl⟩ := left
  obtain ⟨other, otherResult, otherParsed, _, rfl⟩ := right
  rw [(ScalarExpression.at_unique parsed otherParsed).1]

inductive InitializerChecksAt (text : Source) (arguments : Bool) :
    ParserState → List Integer.Obligation → ParserState → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true ≠ 0 → InitializerChecksAt text arguments state [] state
  | string {state middle final : ParserState} {declaration : Declaration}
      {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      (booleanDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      DeclarationChecksAt text state declaration checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final
  | scalar {state middle final : ParserState} {declaration : Integer.Declaration}
      {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      ScalarDeclarationChecksAt text state declaration checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final
  | array {state middle final : ParserState} {declaration : Integer.ArrayDeclaration}
      {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationAt text arguments state declaration middle →
      ArrayDeclarationChecksAt text state declaration checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final

  | subtype {state middle final : ParserState} {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      SubtypeDeclarationAt text arguments state middle →
      SubtypeDeclarationChecksAt text state checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final

  | boolean {state middle final : ParserState} {rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state rest final

theorem declarations_image_trace {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (parsed : DeclarationsAt text arguments state declarations final) :
    ∃ checks, InitializerChecksAt text arguments state checks final := by
  induction parsed with
  | done positive stop => exact ⟨[], .done positive stop⟩
  | next positive more noSubtype noScalar noArray noBoolean first rest ih =>
      obtain ⟨checks, trace⟩ := declaration_image_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .string positive more noSubtype noScalar noArray noBoolean first trace following⟩
  | scalar positive more noSubtype first rest ih =>
      obtain ⟨checks, trace⟩ := scalar_declaration_checks_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .scalar positive more noSubtype first trace following⟩
  | array positive more noSubtype noScalar first rest ih =>
      obtain ⟨checks, trace⟩ := array_declaration_checks_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .array positive more noSubtype noScalar first trace following⟩
  | subtype positive more first rest ih =>
      obtain ⟨checks, trace⟩ := subtype_declaration_checks_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .subtype positive more first trace following⟩

  | boolean positive more noSubtype noScalar noArray first rest ih =>
      obtain ⟨remaining, following⟩ := ih
      exact ⟨remaining, .boolean positive more noSubtype noScalar noArray first following⟩

theorem initializer_checks_discharge {text : Source} {arguments : Bool} {state final : ParserState}
    {checks : List Integer.Obligation} (normal : NamesNormal state.names)
    (trace : InitializerChecksAt text arguments state checks final)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    Integer.discharged checks = true := by
  induction trace with
  | done => rfl
  | string _ _ _ _ _ _ declaration checks _ ih =>
      rw [Integer.discharged_append, declaration_image_checks normal checks,
        ih (declaration_normal normal declaration) (by cases declaration; exact subtypes)]
      rfl
  | scalar _ _ _ declaration checks _ ih =>
      rw [Integer.discharged_append, scalar_declaration_checks_discharge checks]
      cases declaration
      simpa only [Bool.true_and] using ih normal subtypes
  | array _ _ _ _ declaration checks _ ih =>
      rw [Integer.discharged_append, array_declaration_checks_discharge declaration checks subtypes]
      rw [(array_declaration_preserves declaration).1, array_declaration_subtypes declaration] at ih
      simpa only [Bool.true_and] using ih normal subtypes
  | subtype _ _ declaration checks _ ih =>
      rw [Integer.discharged_append, subtype_declaration_checks_discharge checks]
      have nextSubtypes := subtype_declaration_valid declaration subtypes
      cases declaration
      simpa only [Bool.true_and] using ih normal nextSubtypes

  | boolean _ _ _ _ _ declaration _ ih =>
      cases declaration
      exact ih normal subtypes

theorem initializer_checks_valid {text : Source} {arguments : Bool} {state final : ParserState}
    {checks : List Integer.Obligation} (normal : NamesNormal state.names)
    (trace : InitializerChecksAt text arguments state checks final)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ∀ check ∈ checks, check.Valid := by
  have all := List.all_eq_true.mp (initializer_checks_discharge normal trace subtypes)
  exact fun check member => Integer.Obligation.discharge_sound (all check member)

theorem initializer_trace_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : List Integer.Obligation} (first : InitializerChecksAt text arguments state left leftState)
    (second : InitializerChecksAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  induction first generalizing right rightState with
  | done positive stop =>
      cases second with
      | done => exact ⟨rfl, rfl⟩
      | string _ more _ _ _ _ _ _ _ | scalar _ more _ _ _ _ | array _ more _ _ _ _ _ | subtype _ more _ _ _ | boolean _ more _ _ _ _ _ => exact False.elim (stop more)
  | string positive more noSubtype noScalar noArray noBoolean parsed checks rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ _ _ _ _ other otherChecks remaining =>
          obtain ⟨rfl, rfl⟩ := declaration_unique parsed other
          have same := declaration_image_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) same, rfl⟩
      | scalar _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ other _ _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ other _ =>
          have accepted := boolean_declaration_positive other
          rw [← boolean_declaration_complete other, noBoolean] at accepted
          contradiction
      | subtype _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction

  | scalar positive more noSubtype parsed checks rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ _ noScalar _ _ _ _ _ | array _ _ _ noScalar _ _ _ | boolean _ _ _ noScalar _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | scalar _ _ _ other otherChecks remaining =>
          obtain ⟨rfl, rfl⟩ := scalar_declaration_unique parsed other
          have same := scalar_declaration_checks_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) same, rfl⟩
      | subtype _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction

  | array positive more noSubtype noScalar parsed checks rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ _ _ noArray _ _ _ _ | boolean _ _ _ _ noArray _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
      | scalar _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ other otherChecks remaining =>
          obtain ⟨rfl, rfl⟩ := array_declaration_unique parsed other
          have same := array_declaration_checks_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) same, rfl⟩

      | subtype _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction

  | subtype positive more parsed checks rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ noSubtype _ _ _ _ _ _ | scalar _ _ noSubtype _ _ _ | array _ _ noSubtype _ _ _ _ | boolean _ _ noSubtype _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | subtype _ _ other otherChecks remaining =>
          have same := subtype_declaration_unique parsed other
          cases same
          have sameChecks := subtype_declaration_checks_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) sameChecks, rfl⟩

  | boolean positive more noSubtype noScalar noArray parsed rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | string _ _ _ _ _ noBoolean _ _ _ =>
          have accepted := boolean_declaration_positive parsed
          rw [← boolean_declaration_complete parsed, noBoolean] at accepted
          contradiction
      | scalar _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ other _ _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | subtype _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | boolean _ _ _ _ _ other remaining =>
          have same := boolean_declaration_unique parsed other
          cases same
          exact ih remaining

end Silver.Compose
