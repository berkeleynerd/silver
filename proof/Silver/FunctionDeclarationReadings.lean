module

public import Silver.ComposeBooleanRegionTrace
public import Silver.ComposeInitializerTrace
public import Silver.ScalarFunctionDefinition

@[expose] public section

namespace Silver.Compose
open Predicate _root_.Silver.Compose.Expressions

/-- Function locals use the source-order Integer/Boolean declaration grammar.
The two semantic initializer lists are separate, while every raw check stays
attached to its declaration-time source frame. -/
inductive FunctionLocalsAt (text : Source) (arguments : Bool) :
    ParserState → List Integer.Declaration → List BooleanDeclaration →
      List Integer.Obligation → List Predicate.Obligation → ParserState → Prop
  | done {state} : state.position ≠ 0 → fixedAfter text state.position "begin" true ≠ 0 →
      FunctionLocalsAt text arguments state [] [] [] [] state
  | integer {state middle final declaration integers booleans firstChecks checks booleanChecks} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      ScalarDeclarationChecksAt text state declaration firstChecks →
      remainingAt text middle.position < remainingAt text state.position →
      FunctionLocalsAt text arguments middle integers booleans checks booleanChecks final →
      FunctionLocalsAt text arguments state (declaration :: integers) booleans
        (firstChecks ++ checks) booleanChecks final
  | boolean {state middle final declaration integers booleans checks firstChecks booleanChecks} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      BooleanDeclarationChecksAt text state declaration firstChecks →
      remainingAt text middle.position < remainingAt text state.position →
      FunctionLocalsAt text arguments middle integers booleans checks booleanChecks final →
      FunctionLocalsAt text arguments state integers (declaration :: booleans)
        checks (firstChecks ++ booleanChecks) final

theorem functionLocals_reading_or_rejected (text : Source) (arguments : Bool) (state : ParserState)
    (textValid : ValidText text) (valid : ValidState text state) :
    (functionLocalsModel text state arguments).position = 0 ∨
      ∃ integers booleans checks booleanChecks,
        FunctionLocalsAt text arguments state integers booleans checks booleanChecks
          (functionLocalsModel text state arguments) := by
  rw [functionLocalsModel]
  split
  · exact .inl rfl
  · rename_i positive
    split
    · rename_i stop
      exact .inr ⟨[], [], [], [], .done positive stop⟩
    · rename_i more
      dsimp only
      split
      · exact .inl rfl
      · rename_i nonzero
        split
        · rename_i advanced
          by_cases scalar : (scalarDeclarationAt text state arguments).position ≠ 0
          · have selected : functionLocalAt text state arguments = scalarDeclarationAt text state arguments := by
              dsimp only [functionLocalAt]
              rw [ite_eq_left scalar]
            obtain ⟨declaration, source⟩ := scalar_declaration_sound text state arguments scalar
            obtain ⟨firstChecks, raw⟩ := scalar_declaration_checks_trace source
            have nextValid := model_scalar_reading_valid valid source
            rcases functionLocals_reading_or_rejected text arguments (scalarDeclarationAt text state arguments)
                textValid nextValid with rejected | ⟨integers, booleans, checks, booleanChecks, rest⟩
            · exact .inl (by simpa only [selected] using rejected)
            · apply Or.inr
              refine ⟨declaration :: integers, booleans, firstChecks ++ checks, booleanChecks, ?_⟩
              rw [selected]
              exact .integer positive (by omega) source raw (by simpa only [selected] using advanced) rest
          · have selected : functionLocalAt text state arguments = booleanDeclarationAt text state arguments := by
              dsimp only [functionLocalAt]
              rw [ite_eq_right scalar]
            have accepted : (booleanDeclarationAt text state arguments).position ≠ 0 := by
              simpa only [selected] using nonzero
            have source := boolean_declaration_sound text state arguments accepted
            obtain ⟨declaration, firstChecks, raw⟩ := boolean_declaration_trace textValid valid.2.1 source
            have nextValid := model_boolean_reading_valid valid source
            rcases functionLocals_reading_or_rejected text arguments (booleanDeclarationAt text state arguments)
                textValid nextValid with rejected | ⟨integers, booleans, checks, booleanChecks, rest⟩
            · exact .inl (by simpa only [selected] using rejected)
            · apply Or.inr
              refine ⟨integers, declaration :: booleans, checks, firstChecks ++ booleanChecks, ?_⟩
              rw [selected]
              exact .boolean positive (by omega) (by omega) source raw
                (by simpa only [selected] using advanced) rest
        · exact .inl rfl
termination_by remainingAt text state.position
decreasing_by all_goals simp_all only

theorem functionLocals_reading {text : Source} {arguments : Bool} {state : ParserState}
    (textValid : ValidText text) (valid : ValidState text state)
    (accepted : (functionLocals text state arguments).position ≠ 0) :
    ∃ integers booleans checks booleanChecks,
      FunctionLocalsAt text arguments state integers booleans checks booleanChecks
        (functionLocals text state arguments) :=
  (functionLocals_reading_or_rejected text arguments state textValid valid).resolve_left accepted

theorem functionLocals_complete {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final) :
    functionLocals text state arguments = final := by
  change functionLocalsModel text state arguments = final
  induction source with
  | done positive stop =>
      rw [functionLocalsModel, ite_eq_right positive, ite_eq_left stop]
  | @integer before middle final declaration integers booleans firstChecks checks booleanChecks positive more first _ advanced _ ih =>
      have scanned := scalar_declaration_complete first
      have nonzero := scalar_declaration_positive first
      have selected : functionLocalAt text before arguments = middle := by
        dsimp only [functionLocalAt]
        rw [scanned, ite_eq_left nonzero]
      rw [functionLocalsModel, ite_eq_right positive, ite_eq_right (not_not_intro more)]
      dsimp only
      rw [selected, ite_eq_right nonzero, dite_eq_left advanced]
      exact ih
  | @boolean before middle final declaration integers booleans checks firstChecks booleanChecks positive more noScalar first _ advanced _ ih =>
      have scanned := boolean_declaration_complete first
      have nonzero := boolean_declaration_positive first
      have selected : functionLocalAt text before arguments = middle := by
        dsimp only [functionLocalAt]
        rw [ite_eq_right (not_not_intro noScalar), scanned]
      rw [functionLocalsModel, ite_eq_right positive, ite_eq_right (not_not_intro more)]
      dsimp only
      rw [selected, ite_eq_right nonzero, dite_eq_left advanced]
      exact ih

end Silver.Compose
