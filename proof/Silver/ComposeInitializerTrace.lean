module

public import Silver.ComposeDeclarations
public import Silver.ComposeSubtypeChecks
public import Silver.ComposeArrayTypeChecks
public import Silver.ComposeArrayChecks
public import Silver.ComposeBooleanArrayHeaderChecks
public import Silver.StringObligations

@[expose] public section

/-! The raw String initializer projection retains Image arithmetic schemas
alongside the proved frozen execution model. Its source witness fixes all
Image operands, including their actual visibility and arithmetic syntax. -/
namespace Silver.Compose
open Bindings

set_option maxHeartbeats 3000000

inductive DeclarationChecksAt (text : Source) (arguments : Bool) (state : ParserState)
    (declaration : Declaration) : List Integer.Obligation → Prop
  | string {raw result} :
      (characterDeclarationAt text state arguments).position = 0 →
      ExpressionAt text state.names (declarationValuePosition text state) raw result state.scalarNames
        (declarationIntegerHidden text state) state.arrayNames.table state.arrayNames.values true state.contextFirst →
      declaration.initializer = raw.freezeImages
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) →
      DeclarationChecksAt text arguments state declaration
        (raw.imageObligations (ArrayBindings.viewRanges state.arrayNames.names state.arrayNames.values true
          (ScalarExpression.ranges state.scalarNames)) state.names.shape)
  | character {raw result} :
      (characterDeclarationAt text state arguments).position ≠ 0 →
      CharacterAt text state.names state.scalarNames state.arrayNames.table state.arrayNames.values true
        (fixedAfter text (characterDeclarationParts text state).typeAfter ":=" false) raw result →
      declaration.initializer = Expression.freezeImages [Value.character raw]
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) →
      DeclarationChecksAt text arguments state declaration
        (Expression.imageObligations [Value.character raw]
          (ArrayBindings.viewRanges state.arrayNames.names state.arrayNames.values true
            (ScalarExpression.ranges state.scalarNames)) state.names.shape)

theorem declaration_image_trace {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (parsed : DeclarationAt text arguments state declaration next) :
    ∃ checks, DeclarationChecksAt text arguments state declaration checks := by
  cases parsed with
  | string noCharacter source =>
      cases source with
      | declaration _ _ _ _ _ _ _ _ value _ => exact ⟨_, .string noCharacter value rfl⟩
  | character source =>
      have positive : (characterDeclarationAt text state arguments).position ≠ 0 := by
        rw [character_declaration_complete source]
        exact character_declaration_positive source
      cases source with
      | declaration parts _ _ value =>
          exact ⟨_, .character positive (by simpa only [parts] using value) rfl⟩

theorem declaration_image_checks {text : Source} {arguments : Bool} {state : ParserState}
    {declaration : Declaration} {checks : List Integer.Obligation}
    (normal : NamesNormal state.names)
    (trace : DeclarationChecksAt text arguments state declaration checks) : Integer.discharged checks = true := by
  cases trace with
  | string _ parsed _ => exact Expression.image_obligations_discharge (expressionAt_inferLength normal parsed)
  | character _ parsed _ => exact Expression.image_obligations_discharge (characterExpression_inferLength normal parsed)

theorem declaration_image_unique {text : Source} {arguments : Bool} {state : ParserState}
    {declaration : Declaration} {first second : List Integer.Obligation}
    (left : DeclarationChecksAt text arguments state declaration first)
    (right : DeclarationChecksAt text arguments state declaration second) : first = second := by
  cases left with
  | string absent parsed _ =>
      cases right with
      | string _ other _ => rw [(expressionTail_unique parsed other).1]
      | character present _ _ => exact False.elim (present absent)
  | character present parsed _ =>
      cases right with
      | string absent _ _ => exact False.elim (present absent)
      | character _ other _ => rw [(character_unique parsed other).1]

/-- The scalar projection may freeze array reads, but its complete raw
initializer stays in the obligation trace, including arithmetic and indexing. -/
def ScalarDeclarationChecksAt (text : Source) (state : ParserState) (declaration : Integer.Declaration)
    (checks : List Integer.Obligation) : Prop :=
  ∃ raw result,
    ScalarExpression.ArrayGrammar.At text state.scalarNames (scalarDeclarationValuePosition text state) raw result
      (arrays := state.arrayNames.table) (initials := state.arrayNames.values) (elaborating := true) ∧
    declaration.value = raw.freezeArrays
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) ∧
    checks = raw.obligations (ArrayBindings.viewRanges state.arrayNames.names state.arrayNames.values true
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
  rw [(ScalarExpression.ArrayGrammar.at_unique parsed otherParsed).1]

inductive InitializerChecksAt (text : Source) (arguments : Bool) :
    ParserState → List Integer.Obligation → ParserState → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true ≠ 0 → InitializerChecksAt text arguments state [] state
  | callable {state final : ParserState} {rest : List Integer.Obligation}  :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position ≠ 0 →
      InitializerChecksAt text arguments (callableDeclarationAt text state arguments) rest final →
      InitializerChecksAt text arguments state rest final
  | arrayType {state middle final : ParserState} {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      ArrayTypeDeclarationAt text arguments state middle →
      ArrayTypeDeclarationChecksAt text state checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final
  | string {state middle final : ParserState} {declaration : Declaration}
      {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      (booleanDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      DeclarationChecksAt text arguments state declaration checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final
  | scalar {state middle final : ParserState} {declaration : Integer.Declaration}
      {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationChecksAt text state declaration checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final
  | array {state middle final : ParserState} {declaration : Integer.ArrayDeclaration}
      {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationChecksAt text state declaration checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final

  | booleanArray {state middle final : ParserState}
      {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      BooleanArrayDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      BooleanArrayHeaderChecksAt text state checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final

  | subtype {state middle final : ParserState} {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      SubtypeDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      SubtypeDeclarationChecksAt text state checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final

  | boolean {state middle final : ParserState} {rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state rest final

theorem declarations_image_trace {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (parsed : DeclarationsAt text arguments state declarations final) :
    ∃ checks, InitializerChecksAt text arguments state checks final := by
  induction parsed with
  | done positive stop => exact ⟨[], .done positive stop⟩
  | arrayType positive more noCallable first _ ih =>
      obtain ⟨checks, trace⟩ := array_type_declaration_checks_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .arrayType positive more noCallable first trace following⟩
  | next positive more noCallable noSubtype noScalar noArray noBoolean first noArrayType rest ih =>
      obtain ⟨checks, trace⟩ := declaration_image_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .string positive more noCallable noSubtype noScalar noArray noBoolean first noArrayType trace following⟩
  | scalar positive more noCallable noSubtype first noArrayType rest ih =>
      obtain ⟨checks, trace⟩ := scalar_declaration_checks_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .scalar positive more noCallable noSubtype first noArrayType trace following⟩
  | array positive more noCallable noSubtype noScalar first noArrayType rest ih =>
      obtain ⟨checks, trace⟩ := array_declaration_checks_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .array positive more noCallable noSubtype noScalar first noArrayType trace following⟩
  | booleanArray positive more noCallable noSubtype noScalar first noArrayType rest ih =>
      obtain ⟨checks, trace⟩ := boolean_array_header_checks_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .booleanArray positive more noCallable noSubtype noScalar first noArrayType trace following⟩
  | subtype positive more noCallable first noArrayType rest ih =>
      obtain ⟨checks, trace⟩ := subtype_declaration_checks_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .subtype positive more noCallable first noArrayType trace following⟩

  | boolean positive more noCallable noSubtype noScalar noArray first noArrayType rest ih =>
      obtain ⟨remaining, following⟩ := ih
      exact ⟨remaining, .boolean positive more noCallable noSubtype noScalar noArray first noArrayType following⟩

  | callable positive more accepted _ ih =>
      obtain ⟨checks, reading⟩ := ih
      exact ⟨checks, .callable positive more accepted reading⟩

theorem initializer_checks_discharge {text : Source} {arguments : Bool} {state final : ParserState}
    {checks : List Integer.Obligation} (normal : NamesNormal state.names)
    (trace : InitializerChecksAt text arguments state checks final)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types) :
    Integer.discharged checks = true := by
  induction trace with
  | done => rfl
  | arrayType _ _ _ declaration checks _ ih =>
      rw [Integer.discharged_append, array_type_declaration_checks_discharge checks, Bool.true_and]
      have nextTypes := array_type_declaration_types_valid declaration types subtypes
      have nextSubtypes := array_type_declaration_subtypes_valid declaration subtypes
      cases declaration
      exact ih normal nextSubtypes nextTypes
  | string _ _ _ _ _ _ _ declaration _ checks _ ih =>
      rw [Integer.discharged_append, declaration_image_checks normal checks, Bool.true_and]
      apply ih (declaration_normal normal declaration)
      · cases declaration with
        | string _ source => cases source; exact subtypes
        | character source => cases source; exact subtypes
      · cases declaration with
        | string _ source => cases source; exact types
        | character source => cases source; exact types
  | scalar _ _ _ _ declaration _ checks _ ih =>
      rw [Integer.discharged_append, scalar_declaration_checks_discharge checks, Bool.true_and]
      cases declaration
      exact ih normal subtypes types
  | array _ _ _ _ _ declaration _ checks _ ih =>
      rw [Integer.discharged_append, array_declaration_checks_discharge declaration checks types subtypes,
        Bool.true_and]
      rw [(array_declaration_preserves declaration).1, array_declaration_subtypes declaration,
        array_declaration_types declaration] at ih
      exact ih normal subtypes types
  | booleanArray _ _ _ _ _ declaration _ checks _ ih =>
      rw [Integer.discharged_append, boolean_array_header_checks_discharge checks, Bool.true_and]
      rw [(boolean_array_declaration_preserves declaration).1,
        (boolean_array_declaration_preserves declaration).2.2.2,
        boolean_array_declaration_types declaration] at ih
      exact ih normal subtypes types
  | subtype _ _ _ declaration _ checks _ ih =>
      rw [Integer.discharged_append, subtype_declaration_checks_discharge checks, Bool.true_and]
      have nextSubtypes := subtype_declaration_valid declaration subtypes
      cases declaration
      exact ih normal nextSubtypes types
  | boolean _ _ _ _ _ _ declaration _ _ ih =>
      cases declaration
      exact ih normal subtypes types
  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      apply ih (kept.names.symm ▸ normal)
      · simpa only [IntegerSubtypes.ValidEnvironment, kept.subtypeItems] using subtypes
      · simpa only [kept.arrayNames] using types

theorem initializer_checks_valid {text : Source} {arguments : Bool} {state final : ParserState}
    {checks : List Integer.Obligation} (normal : NamesNormal state.names)
    (trace : InitializerChecksAt text arguments state checks final)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ∀ check ∈ checks, check.Valid := by
  have all := List.all_eq_true.mp (initializer_checks_discharge normal trace subtypes types)
  exact fun check member => Integer.Obligation.discharge_sound (all check member)

theorem initializer_trace_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : List Integer.Obligation} (first : InitializerChecksAt text arguments state left leftState)
    (second : InitializerChecksAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  induction first generalizing right rightState with
  | done positive stop =>
      cases second with
      | done _ _ =>
          exact ⟨rfl, rfl⟩
      | callable _ more _ _ =>
          exact False.elim (stop more)
      | arrayType _ more _ _ _ _ =>
          exact False.elim (stop more)
      | subtype _ more _ _ _ _ _ =>
          exact False.elim (stop more)
      | scalar _ more _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | array _ more _ _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | booleanArray _ more _ _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | boolean _ more _ _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | string _ more _ _ _ _ _ _ _ _ _ =>
          exact False.elim (stop more)
  | callable positive more accepted rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ _ remaining =>
          exact ih remaining
      | arrayType _ _ noCallable _ _ _ =>
          exact False.elim (accepted noCallable)
      | subtype _ _ noCallable _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | scalar _ _ noCallable _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | array _ _ noCallable _ _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | booleanArray _ _ noCallable _ _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | boolean _ _ noCallable _ _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | string _ _ noCallable _ _ _ _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
  | arrayType positive more noCallable parsed checks rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other otherChecks remaining =>
          have same := (array_type_declaration_complete parsed).symm.trans (array_type_declaration_complete other)
          cases same
          have sameChecks := array_type_declaration_checks_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) sameChecks, rfl⟩
      | subtype _ _ _ _ noArrayType _ _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | scalar _ _ _ _ _ noArrayType _ _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | array _ _ _ _ _ _ noArrayType _ _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | booleanArray _ _ _ _ _ _ noArrayType _ _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | boolean _ _ _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | string _ _ _ _ _ _ _ _ noArrayType _ _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
  | subtype positive more noCallable parsed noArrayType checks rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ otherChecks remaining =>
          have same := (subtype_declaration_complete parsed).symm.trans (subtype_declaration_complete other)
          cases same
          have sameChecks := subtype_declaration_checks_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) sameChecks, rfl⟩
      | scalar _ _ _ noSubtype _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | array _ _ _ noSubtype _ _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | booleanArray _ _ _ noSubtype _ _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | boolean _ _ _ noSubtype _ _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | string _ _ _ noSubtype _ _ _ _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
  | scalar positive more noCallable noSubtype parsed noArrayType checks rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ otherChecks remaining =>
          obtain ⟨rfl, rfl⟩ := scalar_declaration_unique parsed other
          have sameChecks := scalar_declaration_checks_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) sameChecks, rfl⟩
      | array _ _ _ _ noScalar _ _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | booleanArray _ _ _ _ noScalar _ _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | boolean _ _ _ _ noScalar _ _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | string _ _ _ _ noScalar _ _ _ _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
  | array positive more noCallable noSubtype noScalar parsed noArrayType checks rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ otherChecks remaining =>
          obtain ⟨rfl, rfl⟩ := array_declaration_unique parsed other
          have sameChecks := array_declaration_checks_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) sameChecks, rfl⟩
      | booleanArray _ _ _ _ _ other _ _ _ =>
          exact False.elim (array_declaration_kinds_disjoint parsed other)
      | boolean _ _ _ _ _ noArray _ _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
      | string _ _ _ _ _ noArray _ _ _ _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
  | booleanArray positive more noCallable noSubtype noScalar parsed noArrayType checks rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ _ _ =>
          exact False.elim (array_declaration_kinds_disjoint other parsed)
      | booleanArray _ _ _ _ _ other _ otherChecks remaining =>
          have same := (boolean_array_declaration_complete parsed).symm.trans (boolean_array_declaration_complete other)
          cases same
          have sameChecks := boolean_array_header_checks_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) sameChecks, rfl⟩
      | boolean _ _ _ _ _ noArray _ _ _ =>
          have accepted := boolean_array_declaration_positive parsed
          rw [← boolean_array_declaration_complete parsed, noArray] at accepted
          contradiction
      | string _ _ _ _ _ noArray _ _ _ _ _ =>
          have accepted := boolean_array_declaration_positive parsed
          rw [← boolean_array_declaration_complete parsed, noArray] at accepted
          contradiction
  | boolean positive more noCallable noSubtype noScalar noArray parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ _ _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | booleanArray _ _ _ _ _ other _ _ _ =>
          have accepted := boolean_array_declaration_positive other
          rw [← boolean_array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ _ other _ remaining =>
          have same := (boolean_declaration_complete parsed).symm.trans (boolean_declaration_complete other)
          cases same
          exact ih remaining
      | string _ _ _ _ _ _ noBoolean _ _ _ _ =>
          have accepted := boolean_declaration_positive parsed
          rw [← boolean_declaration_complete parsed, noBoolean] at accepted
          contradiction
  | string positive more noCallable noSubtype noScalar noArray noBoolean parsed noArrayType checks rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ _ _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | booleanArray _ _ _ _ _ other _ _ _ =>
          have accepted := boolean_array_declaration_positive other
          rw [← boolean_array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ _ other _ _ =>
          have accepted := boolean_declaration_positive other
          rw [← boolean_declaration_complete other, noBoolean] at accepted
          contradiction
      | string _ _ _ _ _ _ _ other _ otherChecks remaining =>
          obtain ⟨rfl, rfl⟩ := declaration_unique parsed other
          have sameChecks := declaration_image_unique checks otherChecks
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨congrArg (fun initial => initial ++ _) sameChecks, rfl⟩

end Silver.Compose
