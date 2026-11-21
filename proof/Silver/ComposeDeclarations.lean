module

public import Silver.ComposeObjectDeclarations
public import Silver.ComposeArrayTypeDeclarations
public import Silver.ComposeScalarDeclarations
public import Silver.ComposeArrayElaboration
public import Silver.ComposeBooleanArrayElaboration
public import Silver.ComposeBooleanDeclarations
public import Silver.CallableDeclarationPreservation

@[expose] public section

/-! Source derivations and value-preservation for the finite initialized
String declaration region. Later body guards supply no declaration-time facts. -/

namespace Silver.Compose
open Named Bindings

inductive DeclarationsAt (text : Source) (arguments : Bool) :
    ParserState → List Declaration → ParserState → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true ≠ 0 → DeclarationsAt text arguments state [] state
  | callable {state final : ParserState} {rest : List Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position ≠ 0 →
      DeclarationsAt text arguments (callableDeclarationAt text state arguments) rest final →
      DeclarationsAt text arguments state rest final
  | arrayType {state middle final : ParserState} {rest : List Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      ArrayTypeDeclarationAt text arguments state middle →
      DeclarationsAt text arguments middle rest final →
      DeclarationsAt text arguments state rest final
  | next {state middle final : ParserState} {declaration : Declaration} {rest : List Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      (booleanDeclarationAt text state arguments).position = 0 →
      DeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      DeclarationsAt text arguments middle rest final →
      DeclarationsAt text arguments state (declaration :: rest) final
  | scalar {state middle final : ParserState} {declaration : Integer.Declaration} {rest : List Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      ScalarDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      DeclarationsAt text arguments middle rest final →
      DeclarationsAt text arguments state rest final
  | array {state middle final : ParserState} {declaration : Integer.ArrayDeclaration} {rest : List Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      ArrayDeclarationAt text arguments state declaration middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      DeclarationsAt text arguments middle rest final →
      DeclarationsAt text arguments state rest final

  | booleanArray {state middle final : ParserState} {rest : List Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      BooleanArrayDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      DeclarationsAt text arguments middle rest final →
      DeclarationsAt text arguments state rest final

  | subtype {state middle final : ParserState} {rest : List Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      SubtypeDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      DeclarationsAt text arguments middle rest final →
      DeclarationsAt text arguments state rest final

  | boolean {state middle final : ParserState} {rest : List Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      (callableDeclarationAt text state arguments).position = 0 →
      (subtypeDeclarationAt text state arguments).position = 0 →
      (scalarDeclarationAt text state arguments).position = 0 →
      (arrayDeclarationAt text state arguments).position = 0 →
      BooleanDeclarationAt text arguments state middle →
      (arrayTypeDeclarationAt text state arguments).position = 0 →
      DeclarationsAt text arguments middle rest final →
      DeclarationsAt text arguments state rest final

theorem declarationsLoop_sound (text : Source) (arguments : Bool) (fuel : Nat) (state : ParserState)
    (accepted : (declarationsLoop text arguments fuel state).position ≠ 0) :
    ∃ declarations, DeclarationsAt text arguments state declarations (declarationsLoop text arguments fuel state) := by
  induction fuel generalizing state with
  | zero => simp [declarationsLoop, invalidState] at accepted
  | succ fuel ih =>
      by_cases positive : state.position = 0
      · simp [declarationsLoop, positive, invalidState] at accepted
      · by_cases stop : fixedAfter text state.position "begin" true ≠ 0
        · refine ⟨[], ?_⟩
          simpa [declarationsLoop, positive, stop] using DeclarationsAt.done positive stop
        · by_cases failed : (declarationAt text state arguments).position = 0
          · simp [declarationsLoop, positive, stop, failed, invalidState] at accepted
          · by_cases callable : (callableDeclarationAt text state arguments).position ≠ 0
            · have selected : declarationAt text state arguments = callableDeclarationAt text state arguments := by
                simp only [declarationAt_callable_equation]
                rw [ite_eq_left callable]
              have remaining : (declarationsLoop text arguments fuel (callableDeclarationAt text state arguments)).position ≠ 0 := by
                simpa [declarationsLoop, positive, stop, selected, callable] using accepted
              obtain ⟨rest, parsedRest⟩ := ih _ remaining
              refine ⟨rest, ?_⟩
              simpa [declarationsLoop, positive, stop, selected, callable] using
                DeclarationsAt.callable positive (by omega) callable parsedRest
            · by_cases namedType : (arrayTypeDeclarationAt text state arguments).position ≠ 0
              · have selected : declarationAt text state arguments = arrayTypeDeclarationAt text state arguments := by
                  rw [declarationAt_callable_equation, ite_eq_right callable, ite_eq_left namedType]
                have parsed := array_type_declaration_sound text state arguments namedType
                have remaining : (declarationsLoop text arguments fuel (arrayTypeDeclarationAt text state arguments)).position ≠ 0 := by
                  simpa [declarationsLoop, positive, stop, selected, namedType] using accepted
                obtain ⟨rest, parsedRest⟩ := ih _ remaining
                refine ⟨rest, ?_⟩
                simpa [declarationsLoop, positive, stop, selected, namedType] using
                  DeclarationsAt.arrayType positive (by omega) (by omega) parsed parsedRest
              · by_cases subtype : (subtypeDeclarationAt text state arguments).position ≠ 0
                · have selected : declarationAt text state arguments = subtypeDeclarationAt text state arguments := by
                    simp only [declarationAt_callable_equation, callable, namedType, ↓reduceIte]; split <;> simp_all
                  have parsed := subtype_declaration_sound text state arguments subtype
                  have remaining : (declarationsLoop text arguments fuel (subtypeDeclarationAt text state arguments)).position ≠ 0 := by
                    simpa [declarationsLoop, positive, stop, selected, subtype] using accepted
                  obtain ⟨rest, parsedRest⟩ := ih _ remaining
                  refine ⟨rest, ?_⟩
                  simpa [declarationsLoop, positive, stop, selected, subtype] using
                    DeclarationsAt.subtype positive (by omega) (by omega) parsed (by omega) parsedRest
                · by_cases scalar : (scalarDeclarationAt text state arguments).position ≠ 0
                  · have selected : declarationAt text state arguments = scalarDeclarationAt text state arguments := by
                      simp only [declarationAt_callable_equation, callable, namedType, ↓reduceIte]; split <;> simp_all
                    obtain ⟨declaration, parsed⟩ := scalar_declaration_sound text state arguments scalar
                    have remaining : (declarationsLoop text arguments fuel (scalarDeclarationAt text state arguments)).position ≠ 0 := by
                      simpa [declarationsLoop, positive, stop, selected, scalar] using accepted
                    obtain ⟨rest, parsedRest⟩ := ih _ remaining
                    refine ⟨rest, ?_⟩
                    simpa [declarationsLoop, positive, stop, selected, scalar] using
                      DeclarationsAt.scalar positive (by omega) (by omega) (by omega) parsed (by omega) parsedRest
                  · by_cases array : (arrayDeclarationAt text state arguments).position ≠ 0
                    · have selected : declarationAt text state arguments = arrayDeclarationAt text state arguments := by
                        simp only [declarationAt_callable_equation]
                        rw [ite_eq_right callable, ite_eq_right namedType]
                        rw [ite_eq_right subtype, ite_eq_right scalar, ite_eq_left array]
                      have remaining : (declarationsLoop text arguments fuel (arrayDeclarationAt text state arguments)).position ≠ 0 := by
                        simpa [declarationsLoop, positive, stop, selected, array] using accepted
                      obtain ⟨rest, parsedRest⟩ := ih _ remaining
                      by_cases kind : (arrayDeclarationParts text state).isBoolean = true
                      · have parsed := boolean_array_declaration_sound text state arguments kind array
                        refine ⟨rest, ?_⟩
                        simpa [declarationsLoop, positive, stop, selected, array] using
                          DeclarationsAt.booleanArray positive (by omega) (by omega) (by omega) (by omega) parsed (by omega) parsedRest
                      · obtain ⟨declaration, parsed⟩ := array_declaration_sound text state arguments
                          (Bool.eq_false_iff.mpr kind) array
                        refine ⟨rest, ?_⟩
                        simpa [declarationsLoop, positive, stop, selected, array] using
                          DeclarationsAt.array positive (by omega) (by omega) (by omega) (by omega) parsed (by omega) parsedRest
                    · by_cases boolean : (booleanDeclarationAt text state arguments).position ≠ 0
                      · have selected : declarationAt text state arguments = booleanDeclarationAt text state arguments := by
                          simp only [declarationAt_callable_equation, callable, namedType, ↓reduceIte]; split <;> simp_all
                        have parsed := boolean_declaration_sound text state arguments boolean
                        have remaining : (declarationsLoop text arguments fuel (booleanDeclarationAt text state arguments)).position ≠ 0 := by
                          simpa [declarationsLoop, positive, stop, selected, boolean] using accepted
                        obtain ⟨rest, parsedRest⟩ := ih _ remaining
                        refine ⟨rest, ?_⟩
                        simpa [declarationsLoop, positive, stop, selected, boolean] using
                          DeclarationsAt.boolean positive (by omega) (by omega) (by omega) (by omega) (by omega) parsed (by omega) parsedRest
                      · have selected : declarationAt text state arguments = objectDeclarationAt text state arguments := by
                          simp only [declarationAt_callable_equation]
                          rw [ite_eq_right callable, ite_eq_right namedType]
                          rw [ite_eq_right subtype, ite_eq_right scalar, ite_eq_right array, ite_eq_right boolean]
                          rfl
                        have stringPositive : (objectDeclarationAt text state arguments).position ≠ 0 := selected ▸ failed
                        obtain ⟨declaration, parsed⟩ := declaration_sound text state arguments stringPositive
                        have remaining : (declarationsLoop text arguments fuel (objectDeclarationAt text state arguments)).position ≠ 0 := by
                          simpa [declarationsLoop, positive, stop, selected, stringPositive] using accepted
                        obtain ⟨rest, parsedRest⟩ := ih _ remaining
                        refine ⟨declaration :: rest, ?_⟩
                        simpa [declarationsLoop, positive, stop, selected, stringPositive] using
                          DeclarationsAt.next positive (by omega) (by omega) (by omega) (by omega) (by omega) (by omega) parsed (by omega) parsedRest


theorem declarations_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (declarationsAt text state arguments).position ≠ 0) :
    ∃ declarations, DeclarationsAt text arguments state declarations (declarationsAt text state arguments) :=
  declarationsLoop_sound text arguments _ state accepted

theorem declarations_count {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (parsed : DeclarationsAt text arguments state declarations final) :
    final.names.length = state.names.length + declarations.length := by
  induction parsed with
  | done => simp
  | next _ _ _ _ _ _ _ first _ _ ih =>
      have count := declaration_count first
      simpa only [List.length_cons, count, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using ih
  | scalar _ _ _ _ first _ _ ih =>
      cases first
      exact ih
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).1] at ih
      exact ih
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).1] at ih
      exact ih

  | subtype _ _ _ first _ _ ih => cases first; exact ih
  | arrayType _ _ _ first _ ih => cases first; exact ih
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih

  | callable _ _ accepted _ ih =>
      rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).names] at ih
      exact ih

theorem array_declaration_stored {text arguments state final declaration}
    (stored : state.StoredArrays)
    (parsed : ArrayDeclarationAt text arguments state declaration final) : final.StoredArrays := by
  have kept := arrayDeclarationAt_stored text state arguments stored
  rwa [array_declaration_complete parsed] at kept

theorem boolean_array_declaration_stored {text arguments state final}
    (stored : state.StoredArrays)
    (parsed : BooleanArrayDeclarationAt text arguments state final) : final.StoredArrays := by
  have kept := arrayDeclarationAt_stored text state arguments stored
  rwa [boolean_array_declaration_complete parsed] at kept

theorem declarations_stored {text arguments state final declarations}
    (parsed : DeclarationsAt text arguments state declarations final)
    (stored : state.StoredArrays) : final.StoredArrays := by
  induction parsed with
  | done => exact stored
  | next _ _ _ _ _ _ _ first _ _ ih => exact ih (declaration_stored stored first)
  | scalar _ _ _ _ first _ _ ih => exact ih (scalar_declaration_stored stored first)
  | array _ _ _ _ _ first _ _ ih => exact ih (array_declaration_stored stored first)
  | booleanArray _ _ _ _ _ first _ _ ih => exact ih (boolean_array_declaration_stored stored first)
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih stored
  | subtype _ _ _ first _ _ ih => cases first; exact ih stored
  | arrayType _ _ _ first _ ih => cases first; exact ih stored
  | callable _ _ accepted _ ih =>
      apply ih
      simpa only [ParserState.StoredArrays,
        (callableDeclarationAt_preserves_outer _ _ _ accepted).arrayNames] using stored

theorem declarations_shape {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (normal : NamesNormal state.names)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (stored : state.StoredArrays)
    (parsed : DeclarationsAt text arguments state declarations final) :
    Bindings.DeclarationsValid state.names.shape declarations final.names.shape := by
  induction parsed with
  | done => exact .nil _
  | next _ _ _ _ _ _ _ first _ _ ih =>
      obtain ⟨bound, valid, same⟩ := declaration_shape normal static stored first
      exact .cons valid (same ▸ ih (declaration_normal normal first)
        ((declaration_scalarNames first).symm ▸ static) (declaration_stored stored first))
  | scalar _ _ _ _ first _ _ ih =>
      have nextStatic := scalar_declaration_static static first
      have nextStored := scalar_declaration_stored stored first
      cases first
      exact ih normal nextStatic nextStored
  | array _ _ _ _ _ first _ _ ih =>
      have nextStored := array_declaration_stored stored first
      rw [(array_declaration_preserves first).1, (array_declaration_preserves first).2] at ih
      exact ih normal static nextStored
  | booleanArray _ _ _ _ _ first _ _ ih =>
      have nextStored := boolean_array_declaration_stored stored first
      rw [(boolean_array_declaration_preserves first).1, (boolean_array_declaration_preserves first).2.1] at ih
      exact ih normal static nextStored

  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih normal static stored
  | subtype _ _ _ first _ _ ih => cases first; exact ih normal static stored
  | arrayType _ _ _ first _ ih => cases first; exact ih normal static stored

  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      rw [kept.names, kept.scalarNames] at ih
      exact ih normal static (by simpa only [ParserState.StoredArrays, kept.arrayNames] using stored)

theorem declarations_normal {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (parsed : DeclarationsAt text arguments state declarations final)
    (normal : NamesNormal state.names) : NamesNormal final.names := by
  induction parsed with
  | done => exact normal
  | next _ _ _ _ _ _ _ first _ _ ih => exact ih (declaration_normal normal first)
  | scalar _ _ _ _ first _ _ ih =>
      cases first
      exact ih normal
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).1] at ih
      exact ih normal
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).1] at ih
      exact ih normal

  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih normal
  | subtype _ _ _ first _ _ ih => cases first; exact ih normal
  | arrayType _ _ _ first _ ih => cases first; exact ih normal

  | callable _ _ accepted _ ih =>
      rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).names] at ih
      exact ih normal

theorem declarations_static {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (parsed : DeclarationsAt text arguments state declarations final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    ScalarExpression.StaticEnvironment final.scalarNames := by
  induction parsed with
  | done => exact static
  | next _ _ _ _ _ _ _ first _ _ ih => exact ih ((declaration_scalarNames first).symm ▸ static)
  | scalar _ _ _ _ first _ _ ih => exact ih (scalar_declaration_static static first)
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).2] at ih
      exact ih static
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.1] at ih
      exact ih static

  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih static
  | subtype _ _ _ first _ _ ih => cases first; exact ih static
  | arrayType _ _ _ first _ ih => cases first; exact ih static

  | callable _ _ accepted _ ih =>
      rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).scalarNames] at ih
      exact ih static

inductive LiteralReading (text : Source) : Nat → Source → ValueResult → Prop
  | literal {position after : Nat} {bytes : Source} :
      position ≠ 0 → position ≤ text.length → Cursor.byteAt text position = 34 →
      Output.LiteralAt text (position + 1) bytes after →
      LiteralReading text position bytes ⟨after, position + 1, bytes.length, bytes.length, false, false, false, 0, 1, .singleton 1, .singleton bytes.length⟩

theorem literalReading_complete {text bytes : Source} {position : Nat} {result : ValueResult}
    (parsed : LiteralReading text position bytes result) : literalAt text position = result := by
  cases parsed with
  | literal positive bound quote value =>
      rename_i after
      have nonzero : after ≠ 0 := by have := Output.literalAt_bounds value; omega
      simp [literalAt, positive, bound, quote, Output.literalAt_complete value,
        Guarded.literalLength_decodes value, nonzero]

theorem literalReading_sound (text : Source) (position : Nat)
    (accepted : (literalAt text position).after ≠ 0) :
    ∃ bytes, LiteralReading text position bytes (literalAt text position) := by
  by_cases conditions : position ≠ 0 ∧ position ≤ text.length ∧ Cursor.byteAt text position = 34 ∧
      Output.literalEnd text (position + 1) ≠ 0
  · obtain ⟨bytes, parsed⟩ := Output.literalAt_sound text _ conditions.2.2.2
    refine ⟨bytes, ?_⟩
    have observed : literalAt text position =
        ⟨Output.literalEnd text (position + 1), position + 1, bytes.length, bytes.length, false, false, false, 0, 1, .singleton 1, .singleton bytes.length⟩ := by
      simp [literalAt, conditions, Guarded.literalLength_decodes parsed]
    rw [observed]
    exact .literal conditions.1 conditions.2.1 conditions.2.2.1 parsed
  · simp [literalAt, conditions, invalidValue] at accepted

theorem literalReading_domain {text bytes : Source} {position : Nat} {result : ValueResult}
    (parsed : LiteralReading text position bytes result) :
    bytes.length ≤ text.length ∧ Bindings.Printable bytes := by
  cases parsed with
  | literal _ _ _ value =>
      have facts := Output.literalAt_bounds value
      exact ⟨by omega, facts.2.2⟩

theorem argumentParts_fallback (text : Source) (state : ParserState) :
    (argumentParts text state).fallback = literalAt text (argumentDefaultPosition text state) := by
  simp only [argumentParts]

theorem argumentParts_following (text : Source) (state : ParserState) :
    (argumentParts text state).following =
      fixedAfter text (fixedAfter text (argumentParts text state).fallback.after ")" false) ";" false := by
  simp only [argumentParts]

inductive ArgumentAt (text : Source) : ParserState → Source → ParserState → Prop
  | argument {state : ParserState} {parts : ArgumentParts} {fallback : Source} :
      argumentParts text state = parts →
      newNameAllowed text state parts.first parts.after true = true →
      parts.following ≠ 0 → state.names = [] →
      LiteralReading text (argumentDefaultPosition text state) fallback parts.fallback →
      ArgumentAt text state fallback
        {addBinding state parts.first parts.after
          ⟨parts.following, 0, 0, 0, true, true, false, 0, 1, .singleton 1, ⟨0, maxSourceLength⟩⟩ false parts.following with
          dynamicFirst := parts.first, dynamicAfter := parts.after}

theorem argument_complete {text fallback : Source} {state next : ParserState}
    (parsed : ArgumentAt text state fallback next) : argumentAt text state = next := by
  cases parsed with
  | argument parts allowed following empty _ => simp [argumentAt, parts, allowed, following, empty]

theorem argument_sound (text : Source) (state : ParserState)
    (accepted : (argumentAt text state).position ≠ 0) :
    ∃ fallback, ArgumentAt text state fallback (argumentAt text state) := by
  generalize partsEq : argumentParts text state = parts
  have observed : argumentAt text state =
      if !newNameAllowed text state parts.first parts.after true ||
          decide (parts.following = 0 ∨ state.names.length ≠ 0) then invalidState
      else {addBinding state parts.first parts.after ⟨parts.following, 0, 0, 0, true, true, false, 0, 1, .singleton 1, ⟨0, maxSourceLength⟩⟩ false parts.following with
        dynamicFirst := parts.first, dynamicAfter := parts.after} := by
    simp only [argumentAt, partsEq]
  by_cases allowed : newNameAllowed text state parts.first parts.after true = true
  · by_cases following : parts.following = 0
    · simp [observed, following, invalidState] at accepted
    · by_cases empty : state.names.length = 0
      · have source : state.names = [] := List.length_eq_zero_iff.mp empty
        have nextEq := argumentParts_following text state
        rw [partsEq] at nextEq
        have valueEq := argumentParts_fallback text state
        rw [partsEq] at valueEq
        have literalNonzero : parts.fallback.after ≠ 0 :=
          fixedAfter_nonzero (fixedAfter_nonzero (nextEq ▸ following))
        rw [valueEq] at literalNonzero
        obtain ⟨fallback, parsed⟩ := literalReading_sound text (argumentDefaultPosition text state) literalNonzero
        refine ⟨fallback, ?_⟩
        rw [observed]
        simp only [allowed, Bool.not_true, Bool.false_or, following, empty, ne_eq,
          not_true_eq_false, or_self, decide_false, Bool.false_eq_true, ↓reduceIte]
        exact .argument partsEq allowed following source (valueEq.symm ▸ parsed)
      · simp [observed, empty, invalidState] at accepted
  · simp [observed, allowed, invalidState] at accepted

def argumentDeclaration : Bindings.Declaration := ⟨1, false, [.argument]⟩
def argumentShape : Bindings.Shape := put emptyShape 1 (some ⟨.argument, false⟩)

theorem empty_names_shape : BindingEnvironment.shape [] = emptyShape := by
  funext index
  simp [BindingEnvironment.shape, BindingEnvironment.get, emptyShape]

theorem argument_shape {text fallback : Source} {state next : ParserState}
    (parsed : ArgumentAt text state fallback next) :
    state.names.shape = emptyShape ∧ next.names.shape = argumentShape ∧
      argumentDeclaration.Valid emptyShape .argument := by
  cases parsed with
  | argument _ _ _ empty _ =>
      refine ⟨by simp [empty, empty_names_shape], ?_, ?_⟩
      · simp only [addBinding, empty, environment_append, empty_names_shape,
          List.length_nil, Nat.zero_add, BindingInfo.cell, BindingInfo.bound,
          ↓reduceIte, argumentShape]
      · simp [Declaration.Valid, argumentDeclaration, emptyShape, Expression.infer,
          Expression.summary, Expression.staticLength, Expression.dynamicCount,
          Expression.PrintableLiterals, Expression.LiteralsPrintable,
          Operand.staticLength, Operand.dynamicCount, Operand.bound, Bindings.Value.infer,
          Bindings.Value.PrintableLiterals, Bound.staticPart, Bound.dynamicPart,
          Bindings.Bound.summary, Bindings.Bound.length, maxExpressionOperands]

theorem argument_normal {text fallback : Source} {state next : ParserState}
    (parsed : ArgumentAt text state fallback next) : NamesNormal next.names := by
  cases parsed with
  | argument _ _ _ empty _ =>
      apply namesNormal_append (slot := 1)
      · rw [empty]
        constructor
        · intro index info present
          simp [BindingEnvironment.get] at present
        · intro index info present
          simp [BindingEnvironment.get] at present
      · simp [fixedBoundsValid]

theorem literalReading_unique {text : Source} {position : Nat} {left right : Source}
    {firstResult secondResult : ValueResult}
    (first : LiteralReading text position left firstResult)
    (second : LiteralReading text position right secondResult) : left = right := by
  cases first with
  | literal _ _ _ parsed =>
      cases second with
      | literal _ _ _ other => exact (Output.literalAt_unique parsed other).1

set_option maxHeartbeats 2000000 in
theorem declarations_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : List Declaration} (first : DeclarationsAt text arguments state left leftState)
    (second : DeclarationsAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  induction first generalizing right rightState with
  | done positive stop =>
      cases second with
      | done _ _ =>
          exact ⟨rfl, rfl⟩
      | callable _ more _ _ =>
          exact False.elim (stop more)
      | arrayType _ more _ _ _ =>
          exact False.elim (stop more)
      | subtype _ more _ _ _ _ =>
          exact False.elim (stop more)
      | scalar _ more _ _ _ _ _ =>
          exact False.elim (stop more)
      | array _ more _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | booleanArray _ more _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | boolean _ more _ _ _ _ _ _ _ =>
          exact False.elim (stop more)
      | next _ more _ _ _ _ _ _ _ _ =>
          exact False.elim (stop more)
  | callable positive more accepted rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ _ remaining =>
          exact ih remaining
      | arrayType _ _ noCallable _ _ =>
          exact False.elim (accepted noCallable)
      | subtype _ _ noCallable _ _ _ =>
          exact False.elim (accepted noCallable)
      | scalar _ _ noCallable _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | array _ _ noCallable _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | booleanArray _ _ noCallable _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | boolean _ _ noCallable _ _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
      | next _ _ noCallable _ _ _ _ _ _ _ =>
          exact False.elim (accepted noCallable)
  | arrayType positive more noCallable parsed rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other remaining =>
          have same := (array_type_declaration_complete parsed).symm.trans (array_type_declaration_complete other)
          cases same
          exact ih remaining
      | subtype _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | scalar _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | array _ _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | booleanArray _ _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | boolean _ _ _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
      | next _ _ _ _ _ _ _ _ noArrayType _ =>
          have accepted := array_type_declaration_positive parsed
          rw [← array_type_declaration_complete parsed, noArrayType] at accepted
          contradiction
  | subtype positive more noCallable parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ remaining =>
          have same := (subtype_declaration_complete parsed).symm.trans (subtype_declaration_complete other)
          cases same
          exact ih remaining
      | scalar _ _ _ noSubtype _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | array _ _ _ noSubtype _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | booleanArray _ _ _ noSubtype _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | boolean _ _ _ noSubtype _ _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
      | next _ _ _ noSubtype _ _ _ _ _ _ =>
          have accepted := subtype_declaration_positive parsed
          rw [← subtype_declaration_complete parsed, noSubtype] at accepted
          contradiction
  | scalar positive more noCallable noSubtype parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ remaining =>
          obtain ⟨rfl, rfl⟩ := scalar_declaration_unique parsed other
          exact ih remaining
      | array _ _ _ _ noScalar _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | booleanArray _ _ _ _ noScalar _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | boolean _ _ _ _ noScalar _ _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
      | next _ _ _ _ noScalar _ _ _ _ _ =>
          have accepted := scalar_declaration_positive parsed
          rw [← scalar_declaration_complete parsed, noScalar] at accepted
          contradiction
  | array positive more noCallable noSubtype noScalar parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ remaining =>
          have same := (array_declaration_complete parsed).symm.trans (array_declaration_complete other)
          cases same
          exact ih remaining
      | booleanArray _ _ _ _ _ other _ _ =>
          exact False.elim (array_declaration_kinds_disjoint parsed other)
      | boolean _ _ _ _ _ noArray _ _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
      | next _ _ _ _ _ noArray _ _ _ _ =>
          have accepted := array_declaration_positive parsed
          rw [← array_declaration_complete parsed, noArray] at accepted
          contradiction
  | booleanArray positive more noCallable noSubtype noScalar parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ _ =>
          exact False.elim (array_declaration_kinds_disjoint other parsed)
      | booleanArray _ _ _ _ _ other _ remaining =>
          have same := (boolean_array_declaration_complete parsed).symm.trans (boolean_array_declaration_complete other)
          cases same
          exact ih remaining
      | boolean _ _ _ _ _ noArray _ _ _ =>
          have accepted := boolean_array_declaration_positive parsed
          rw [← boolean_array_declaration_complete parsed, noArray] at accepted
          contradiction
      | next _ _ _ _ _ noArray _ _ _ _ =>
          have accepted := boolean_array_declaration_positive parsed
          rw [← boolean_array_declaration_complete parsed, noArray] at accepted
          contradiction
  | boolean positive more noCallable noSubtype noScalar noArray parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | booleanArray _ _ _ _ _ other _ _ =>
          have accepted := boolean_array_declaration_positive other
          rw [← boolean_array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ _ other _ remaining =>
          have same := (boolean_declaration_complete parsed).symm.trans (boolean_declaration_complete other)
          cases same
          exact ih remaining
      | next _ _ _ _ _ _ noBoolean _ _ _ =>
          have accepted := boolean_declaration_positive parsed
          rw [← boolean_declaration_complete parsed, noBoolean] at accepted
          contradiction
  | next positive more noCallable noSubtype noScalar noArray noBoolean parsed noArrayType rest ih =>
      cases second with
      | done _ stop =>
          exact False.elim (stop more)
      | callable _ _ accepted _ =>
          exact False.elim (accepted noCallable)
      | arrayType _ _ _ other _ =>
          have accepted := array_type_declaration_positive other
          rw [← array_type_declaration_complete other, noArrayType] at accepted
          contradiction
      | subtype _ _ _ other _ _ =>
          have accepted := subtype_declaration_positive other
          rw [← subtype_declaration_complete other, noSubtype] at accepted
          contradiction
      | scalar _ _ _ _ other _ _ =>
          have accepted := scalar_declaration_positive other
          rw [← scalar_declaration_complete other, noScalar] at accepted
          contradiction
      | array _ _ _ _ _ other _ _ =>
          have accepted := array_declaration_positive other
          rw [← array_declaration_complete other, noArray] at accepted
          contradiction
      | booleanArray _ _ _ _ _ other _ _ =>
          have accepted := boolean_array_declaration_positive other
          rw [← boolean_array_declaration_complete other, noArray] at accepted
          contradiction
      | boolean _ _ _ _ _ _ other _ _ =>
          have accepted := boolean_declaration_positive other
          rw [← boolean_declaration_complete other, noBoolean] at accepted
          contradiction
      | next _ _ _ _ _ _ _ other _ remaining =>
          obtain ⟨rfl, rfl⟩ := declaration_unique parsed other
          obtain ⟨rfl, rfl⟩ := ih remaining
          exact ⟨rfl, rfl⟩

theorem argument_unique {text : Source} {state leftState rightState : ParserState}
    {left right : Source} (first : ArgumentAt text state left leftState)
    (second : ArgumentAt text state right rightState) : left = right ∧ leftState = rightState := by
  refine ⟨?_, (argument_complete first).symm.trans (argument_complete second)⟩
  cases first with
  | argument _ _ _ _ value =>
      cases second with
      | argument _ _ _ _ other => exact literalReading_unique value other

theorem declarations_fields {text : Source} {arguments : Bool} {state final : ParserState}
    {values : List Declaration} (parsed : DeclarationsAt text arguments state values final) :
    final.capacity = state.capacity ∧ final.target = state.target ∧
      final.dynamicFirst = state.dynamicFirst ∧ final.dynamicAfter = state.dynamicAfter := by
  induction parsed with
  | done => exact ⟨rfl, rfl, rfl, rfl⟩
  | next _ _ _ _ _ _ _ first _ _ ih =>
      cases first with
      | string _ source => cases source; exact ih
      | character source => cases source; exact ih
  | scalar _ _ _ _ first _ _ ih =>
      cases first
      exact ih
  | array _ _ _ _ _ first _ _ ih =>
      have fields := array_declaration_fields first
      exact ⟨ih.1.trans fields.1, ih.2.1.trans fields.2.1,
        ih.2.2.1.trans fields.2.2.1, ih.2.2.2.trans fields.2.2.2⟩

  | booleanArray _ _ _ _ _ first _ _ ih =>
      have same := boolean_array_declaration_fields first
      have capacity := congrArg ParserState.capacity same
      have target := congrArg ParserState.target same
      have dynamicFirst := congrArg ParserState.dynamicFirst same
      have dynamicAfter := congrArg ParserState.dynamicAfter same
      exact ⟨ih.1.trans capacity, ih.2.1.trans target,
        ih.2.2.1.trans dynamicFirst, ih.2.2.2.trans dynamicAfter⟩
  | subtype _ _ _ first _ _ ih => cases first; exact ih
  | arrayType _ _ _ first _ ih => cases first; exact ih
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih

  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      exact ⟨ih.1.trans kept.capacity, ih.2.1.trans kept.target,
        ih.2.2.1.trans kept.dynamicFirst, ih.2.2.2.trans kept.dynamicAfter⟩

theorem argument_fields {text fallback : Source} {state final : ParserState}
    (parsed : ArgumentAt text state fallback final) :
    final.capacity = state.capacity ∧ final.target = state.target := by
  cases parsed
  exact ⟨rfl, rfl⟩

theorem declarations_subtypes_valid {text arguments state final declarations}
    (parsed : DeclarationsAt text arguments state declarations final)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    IntegerSubtypes.ValidEnvironment text final.subtypeNames := by
  induction parsed with
  | done => exact valid
  | next _ _ _ _ _ _ _ first _ _ ih =>
      cases first with
      | string _ source => cases source; exact ih valid
      | character source => cases source; exact ih valid
  | scalar _ _ _ _ first _ _ ih => cases first; exact ih valid
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih valid
  | subtype _ _ _ first _ _ ih => exact ih (subtype_declaration_valid first valid)
  | arrayType _ _ _ first _ ih => cases first; exact ih valid
  | array _ _ _ _ _ first _ _ ih =>
      rw [array_declaration_subtypes first] at ih
      exact ih valid
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.2.2] at ih
      exact ih valid

  | callable _ _ accepted _ ih =>
      apply ih
      simpa only [IntegerSubtypes.ValidEnvironment,
        (callableDeclarationAt_preserves_outer _ _ _ accepted).subtypeItems] using valid

theorem array_declaration_functions {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    final.functions = state.functions := by
  cases reading with
  | declaration _ _ _ _ values _ _ =>
      simpa only [] using congrArg ParserState.functions (arrayValues_fields values)

theorem array_declaration_procedures {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    final.procedures = state.procedures := by
  cases reading with
  | declaration _ _ _ _ values _ _ =>
      simpa only [] using congrArg ParserState.procedures (arrayValues_fields values)

theorem array_declaration_types {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    final.arrayNames.types = state.arrayNames.types := by
  cases reading with
  | declaration _ _ _ _ values _ _ =>
      simpa only [] using congrArg (fun s => s.arrayNames.types) (arrayValues_fields values)

theorem boolean_array_declaration_types {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final) :
    final.arrayNames.types = state.arrayNames.types := by
  cases reading with
  | @declaration values parts lower upper position following _ _ _ _ _ valuesEq positive _ _ =>
      have fields := booleanArrayValuesModel_fields text state state position parts.length 0 parts.first parts.after
        (valuesEq.symm ▸ positive)
      rw [valuesEq] at fields
      exact congrArg (fun s => s.arrayNames.types) fields

theorem declarations_types_valid {text arguments state final declarations}
    (parsed : DeclarationsAt text arguments state declarations final)
    (valid : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidTypes text final.arrayNames.types := by
  induction parsed with
  | done => exact valid
  | next _ _ _ _ _ _ _ first _ _ ih =>
      cases first with
      | string _ source => cases source; exact ih valid subtypes
      | character source => cases source; exact ih valid subtypes
  | scalar _ _ _ _ first _ _ ih => cases first; exact ih valid subtypes
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih valid subtypes
  | subtype _ _ _ first _ _ ih =>
      have nextSubtypes := subtype_declaration_valid first subtypes
      cases first
      exact ih valid nextSubtypes
  | arrayType _ _ _ first _ ih =>
      exact ih (array_type_declaration_types_valid first valid subtypes)
        (array_type_declaration_subtypes_valid first subtypes)
  | array _ _ _ _ _ first _ _ ih =>
      rw [array_declaration_types first, array_declaration_subtypes first] at ih
      exact ih valid subtypes
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [boolean_array_declaration_types first, (boolean_array_declaration_preserves first).2.2.2] at ih
      exact ih valid subtypes
  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      rw [kept.arrayNames] at ih
      apply ih valid
      simpa only [IntegerSubtypes.ValidEnvironment, kept.subtypeItems] using subtypes

theorem declarations_subtypes_hiding {text arguments state final declarations}
    (parsed : DeclarationsAt text arguments state declarations final)
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames
      (declarationHidingNames state)) :
    IntegerSubtypes.HidingCorrect text final.subtypeNames
      (declarationHidingNames final) := by
  induction parsed with
  | done => exact correct
  | next _ _ _ _ _ _ _ first _ _ ih =>
      cases first with
      | string _ source => cases source; exact ih correct
      | character source => cases source; exact ih correct
  | scalar _ _ _ _ first _ _ ih => cases first; exact ih correct
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih correct
  | subtype _ _ _ first _ _ ih =>
      have nextCorrect := subtype_declaration_hiding first correct
      cases first
      exact ih nextCorrect
  | array _ _ _ _ _ first _ _ ih =>
      rw [array_declaration_subtypes first, declarationHidingNames, array_declaration_types first, array_declaration_functions first,
        array_declaration_procedures first] at ih
      exact ih correct
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.2.2, declarationHidingNames, boolean_array_declaration_types first,
        congrArg ParserState.functions (boolean_array_declaration_fields first),
        congrArg ParserState.procedures (boolean_array_declaration_fields first)] at ih
      exact ih correct

  | arrayType _ _ _ first _ ih =>
      apply ih
      intro operation
      have extended := array_type_declaration_hiding first correct operation
      have fields := array_type_declaration_fields first
      simpa [declarationHidingNames, array_type_declaration_types first,
        congrArg ParserState.functions fields, congrArg ParserState.procedures fields,
        ArrayTypeDeclarationParts.item, List.any_append, Bool.or_assoc, Bool.or_left_comm, Bool.or_comm]
        using extended

  | callable _ _ accepted _ ih => exact ih (callableDeclarationAt_hiding correct accepted)

theorem declarations_array_ready {text arguments state final declarations}
    (parsed : DeclarationsAt text arguments state declarations final)
    (ready : ArrayBindings.SourceReady text state.arrayNames)
    (types : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.SourceReady text final.arrayNames := by
  induction parsed with
  | done => exact ready
  | arrayType _ _ _ first _ ih =>
      have nextReady := array_type_declaration_source_ready first ready
      exact ih nextReady (array_type_declaration_types_valid first types subtypes)
        (array_type_declaration_subtypes_valid first subtypes)
  | next _ _ _ _ _ _ _ first _ _ ih =>
      cases first with
      | string _ source => cases source; exact ih ready types subtypes
      | character source => cases source; exact ih ready types subtypes
  | scalar _ _ _ _ first _ _ ih => cases first; exact ih ready types subtypes
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih ready types subtypes
  | subtype _ _ _ first _ _ ih =>
      have nextSubtypes := subtype_declaration_valid first subtypes
      cases first
      exact ih ready types nextSubtypes
  | array _ _ _ _ _ first _ _ ih =>
      exact ih (array_declaration_source_ready first ready types subtypes)
        ((array_declaration_types first).symm ▸ types)
        ((array_declaration_subtypes first).symm ▸ subtypes)
  | booleanArray _ _ _ _ _ first _ _ ih =>
      exact ih (boolean_array_declaration_source_ready first ready)
        ((boolean_array_declaration_types first).symm ▸ types)
        ((boolean_array_declaration_preserves first).2.2.2.symm ▸ subtypes)

  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      apply ih (kept.arrayNames.symm ▸ ready) (by simpa only [kept.arrayNames] using types)
      simpa only [IntegerSubtypes.ValidEnvironment, kept.subtypeItems] using subtypes

end Silver.Compose
