module

public import Silver.ComposeSemantics

@[expose] public section

/-! Source derivations and value-preservation for the finite initialized
String declaration region. Later body guards supply no declaration-time facts. -/

namespace Silver.Compose
open Named Bindings

theorem declarationParts_value (text : Source) (state : ParserState) :
    (declarationParts text state).value = valueAt text (declarationValuePosition text state) state.names := by
  simp only [declarationParts]

theorem fixedAfter_nonzero {text : Source} {position : Nat} {spelling : String} {word : Bool}
    (accepted : fixedAfter text position spelling word ≠ 0) : position ≠ 0 := by
  intro zero
  simp [fixedAfter, zero] at accepted

theorem declarationParts_following (text : Source) (state : ParserState) :
    (declarationParts text state).following = fixedAfter text (declarationParts text state).value.after ";" false := by
  simp only [declarationParts]

inductive DeclarationAt (text : Source) (arguments : Bool) : ParserState → Declaration → ParserState → Prop
  | declaration {state : ParserState} {parts : DeclarationParts} {value : Operand} :
      declarationParts text state = parts →
      newNameAllowed text state parts.first parts.after arguments = true →
      parts.following ≠ 0 → state.names.length ≠ maxBindings →
      ValueAt text state.names (declarationValuePosition text state) value parts.value →
      DeclarationAt text arguments state
        ⟨state.names.length + 1, decide (parts.constantAfter = 0), value⟩
        (addBinding state parts.first parts.after parts.value (decide (parts.constantAfter = 0)) parts.following)

theorem declaration_complete {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (parsed : DeclarationAt text arguments state declaration next) :
    declarationAt text state arguments = next := by
  cases parsed with
  | declaration parts allowed following count _ => simp [declarationAt, parts, allowed, following, count]

theorem declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (declarationAt text state arguments).position ≠ 0) :
    ∃ declaration, DeclarationAt text arguments state declaration (declarationAt text state arguments) := by
  generalize partsEq : declarationParts text state = parts
  have observed : declarationAt text state arguments =
      if !newNameAllowed text state parts.first parts.after arguments ||
          decide (parts.following = 0 ∨ state.names.length = maxBindings) then invalidState
      else addBinding state parts.first parts.after parts.value (decide (parts.constantAfter = 0)) parts.following := by
    simp only [declarationAt, partsEq]
  by_cases allowed : newNameAllowed text state parts.first parts.after arguments = true
  · by_cases following : parts.following = 0
    · simp [observed, following, invalidState] at accepted
    · by_cases count : state.names.length = maxBindings
      · simp [observed, count, invalidState] at accepted
      · have nextEq := declarationParts_following text state
        rw [partsEq] at nextEq
        have valueEq := declarationParts_value text state
        rw [partsEq] at valueEq
        have valueNonzero : parts.value.after ≠ 0 := fixedAfter_nonzero (nextEq ▸ following)
        rw [valueEq] at valueNonzero
        obtain ⟨value, parsed⟩ := value_sound text (declarationValuePosition text state) state.names valueNonzero
        refine ⟨⟨state.names.length + 1, decide (parts.constantAfter = 0), value⟩, ?_⟩
        rw [observed]
        simp only [allowed, Bool.not_true, Bool.false_or, following, count, or_self,
          decide_false, Bool.false_eq_true, ↓reduceIte]
        exact .declaration partsEq allowed following count (valueEq.symm ▸ parsed)
  · simp [observed, allowed, invalidState] at accepted

theorem declaration_positive {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (parsed : DeclarationAt text arguments state declaration next) :
    next.position ≠ 0 := by
  cases parsed with
  | declaration _ _ following _ _ => simpa only [addBinding] using following

theorem declaration_shape {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (parsed : DeclarationAt text arguments state declaration next) :
    ∃ bound, declaration.Valid state.names.shape bound ∧
      next.names.shape = declaration.extend state.names.shape bound := by
  cases parsed with
  | declaration parts allowed following count value =>
      refine ⟨_, ⟨environment_fresh _, value_infer value, value_literals value⟩, ?_⟩
      simp only [addBinding, environment_append, Declaration.extend, BindingInfo.cell,
        BindingInfo.bound, ValueResult.bound]

theorem get_append_new {names : BindingEnvironment} {info : BindingInfo} {index : Nat}
    {found : BindingInfo} (present : (names ++ [info]).get index = some found) :
    names.get index = some found ∨ (index = names.length + 1 ∧ found = info) := by
  by_cases zero : index = 0
  · simp [BindingEnvironment.get, zero] at present
  · by_cases before : index - 1 < names.length
    · left
      simpa [BindingEnvironment.get, zero, List.getElem?_append_left before] using present
    · right
      have after : names.length ≤ index - 1 := by omega
      simp only [BindingEnvironment.get, zero, ↓reduceIte, List.getElem?_append_right after] at present
      have within := (List.getElem?_eq_some_iff.mp present).1
      have same : index = names.length + 1 := by simp only [List.length_singleton] at within; omega
      subst index
      have reversed : info = found := by simpa using present
      exact ⟨rfl, reversed.symm⟩

theorem declaration_normal {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Declaration} (normal : NamesNormal state.names)
    (parsed : DeclarationAt text arguments state declaration next) : NamesNormal next.names := by
  cases parsed with
  | declaration _ _ _ _ value =>
      intro index info present dynamic
      obtain prior | ⟨_, same⟩ := get_append_new present
      · exact normal index info prior dynamic
      · subst info
        exact value_normal normal value dynamic

inductive DeclarationsAt (text : Source) (arguments : Bool) :
    ParserState → List Declaration → ParserState → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      fixedAfter text state.position "begin" true ≠ 0 → DeclarationsAt text arguments state [] state
  | next {state middle final : ParserState} {declaration : Declaration} {rest : List Declaration} :
      state.position ≠ 0 → fixedAfter text state.position "begin" true = 0 →
      DeclarationAt text arguments state declaration middle →
      DeclarationsAt text arguments middle rest final →
      DeclarationsAt text arguments state (declaration :: rest) final

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
          · obtain ⟨declaration, parsed⟩ := declaration_sound text state arguments failed
            have remaining : (declarationsLoop text arguments fuel (declarationAt text state arguments)).position ≠ 0 := by
              simpa [declarationsLoop, positive, stop, failed] using accepted
            obtain ⟨rest, parsedRest⟩ := ih _ remaining
            refine ⟨declaration :: rest, ?_⟩
            simpa [declarationsLoop, positive, stop, failed] using
              DeclarationsAt.next positive (by omega) parsed parsedRest

theorem declarations_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (declarationsAt text state arguments).position ≠ 0) :
    ∃ declarations, DeclarationsAt text arguments state declarations (declarationsAt text state arguments) :=
  declarationsLoop_sound text arguments _ state accepted

theorem declarations_count {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (parsed : DeclarationsAt text arguments state declarations final) :
    final.names.length = state.names.length + declarations.length := by
  induction parsed with
  | done => simp
  | next _ _ first _ ih =>
      have count := declarationAt_count ((declaration_complete first).symm ▸ declaration_positive first)
      rw [declaration_complete first] at count
      simpa only [List.length_cons, count, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using ih

theorem declarations_shape {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (parsed : DeclarationsAt text arguments state declarations final) :
    Bindings.DeclarationsValid state.names.shape declarations final.names.shape := by
  induction parsed with
  | done => exact .nil _
  | next _ _ first _ ih =>
      obtain ⟨bound, valid, same⟩ := declaration_shape first
      exact .cons valid (same ▸ ih)

theorem declarations_normal {text : Source} {arguments : Bool} {state final : ParserState}
    {declarations : List Declaration} (parsed : DeclarationsAt text arguments state declarations final)
    (normal : NamesNormal state.names) : NamesNormal final.names := by
  induction parsed with
  | done => exact normal
  | next _ _ first _ ih => exact ih (declaration_normal normal first)


inductive LiteralReading (text : Source) : Nat → Source → ValueResult → Prop
  | literal {position after : Nat} {bytes : Source} :
      position ≠ 0 → position ≤ text.length → Cursor.byteAt text position = 34 →
      Output.LiteralAt text (position + 1) bytes after →
      LiteralReading text position bytes ⟨after, position + 1, bytes.length, false, 0⟩

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
        ⟨Output.literalEnd text (position + 1), position + 1, bytes.length, false, 0⟩ := by
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
          ⟨parts.following, 0, 0, true, 0⟩ false parts.following with
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
      else {addBinding state parts.first parts.after ⟨parts.following, 0, 0, true, 0⟩ false parts.following with
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

def argumentDeclaration : Bindings.Declaration := ⟨1, false, .argument⟩
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
      · simp [Declaration.Valid, argumentDeclaration, emptyShape, Bindings.Value.infer,
          Bindings.Value.PrintableLiterals]

theorem argument_normal {text fallback : Source} {state next : ParserState}
    (parsed : ArgumentAt text state fallback next) : NamesNormal next.names := by
  cases parsed with
  | argument _ _ _ empty _ =>
      intro index info present dynamic
      simp only [addBinding, empty, List.nil_append] at present
      by_cases zero : index = 0
      · simp [BindingEnvironment.get, zero] at present
      · have inside := (List.getElem?_eq_some_iff.mp (by simpa [BindingEnvironment.get, zero] using present)).1
        have same : index = 1 := by simp only [List.length_singleton] at inside; omega
        subst index
        simp [BindingEnvironment.get] at present
        subst info
        rfl

theorem literalReading_unique {text : Source} {position : Nat} {left right : Source}
    {firstResult secondResult : ValueResult}
    (first : LiteralReading text position left firstResult)
    (second : LiteralReading text position right secondResult) : left = right := by
  cases first with
  | literal _ _ _ parsed =>
      cases second with
      | literal _ _ _ other => exact (Output.literalAt_unique parsed other).1

theorem declaration_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : Declaration} (first : DeclarationAt text arguments state left leftState)
    (second : DeclarationAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  have states := (declaration_complete first).symm.trans (declaration_complete second)
  refine ⟨?_, states⟩
  cases first with
  | declaration partsEq _ _ _ value =>
      cases second with
      | declaration otherEq _ _ _ other =>
          have same := partsEq.symm.trans otherEq
          cases same
          obtain ⟨rfl, _⟩ := value_unique value other
          rfl

theorem declarations_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : List Declaration} (first : DeclarationsAt text arguments state left leftState)
    (second : DeclarationsAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  induction first generalizing right rightState with
  | done positive stop =>
      cases second with
      | done => exact ⟨rfl, rfl⟩
      | next _ more _ _ => exact False.elim (stop more)
  | next positive more parsed rest ih =>
      cases second with
      | done _ stop => exact False.elim (stop more)
      | next _ _ other remaining =>
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
  | next _ _ first _ ih =>
      cases first
      exact ih

theorem argument_fields {text fallback : Source} {state final : ParserState}
    (parsed : ArgumentAt text state fallback final) :
    final.capacity = state.capacity ∧ final.target = state.target := by
  cases parsed
  exact ⟨rfl, rfl⟩

end Silver.Compose
