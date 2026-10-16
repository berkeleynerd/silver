module

public import Silver.ComposeDeclarations
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
      (declarationIntegerHidden text state) ∧
    declaration.initializer = raw.freezeImages (frozenIntegers state.scalarNames) ∧
    checks = raw.imageObligations (ScalarExpression.ranges state.scalarNames)

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

inductive InitializerChecksAt (text : Source) (arguments : Bool) :
    ParserState → List Integer.Obligation → ParserState → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true ≠ 0 → InitializerChecksAt text arguments state [] state
  | string {state middle final : ParserState} {declaration : Declaration}
      {checks rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      DeclarationChecksAt text state declaration checks →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state (checks ++ rest) final
  | scalar {state middle final : ParserState} {declaration : Integer.Declaration}
      {rest : List Integer.Obligation} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      InitializerChecksAt text arguments middle rest final →
      InitializerChecksAt text arguments state rest final

theorem declarations_image_trace {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (parsed : DeclarationsAt text arguments state declarations final) :
    ∃ checks, InitializerChecksAt text arguments state checks final := by
  induction parsed with
  | done positive stop => exact ⟨[], .done positive stop⟩
  | next positive more noScalar first rest ih =>
      obtain ⟨checks, trace⟩ := declaration_image_trace first
      obtain ⟨remaining, following⟩ := ih
      exact ⟨checks ++ remaining, .string positive more noScalar first trace following⟩
  | scalar positive more first rest ih =>
      obtain ⟨remaining, following⟩ := ih
      exact ⟨remaining, .scalar positive more first following⟩

theorem initializer_checks_discharge {text : Source} {arguments : Bool} {state final : ParserState}
    {checks : List Integer.Obligation} (normal : NamesNormal state.names)
    (trace : InitializerChecksAt text arguments state checks final) :
    Integer.discharged checks = true := by
  induction trace with
  | done => rfl
  | string _ _ _ declaration checks _ ih =>
      rw [Integer.discharged_append, declaration_image_checks normal checks,
        ih (declaration_normal normal declaration)]
      rfl
  | scalar _ _ declaration _ ih =>
      cases declaration
      exact ih normal

theorem initializer_checks_valid {text : Source} {arguments : Bool} {state final : ParserState}
    {checks : List Integer.Obligation} (normal : NamesNormal state.names)
    (trace : InitializerChecksAt text arguments state checks final) :
    ∀ check ∈ checks, check.Valid := by
  have all := List.all_eq_true.mp (initializer_checks_discharge normal trace)
  exact fun check member => Integer.Obligation.discharge_sound (all check member)

end Silver.Compose
