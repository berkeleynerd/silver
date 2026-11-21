module

public import Silver.ComposeSubtypeDeclarations
public import Silver.ArrayBindingsEnvironment

@[expose] public section

/-! Named constrained array types retain their source bounds and component
subtype. Object type names resolve through the independent Ada identifier
relation and the complete namespace, before inheriting the stored shape. -/
namespace Silver.Compose
open Expressions

attribute [local irreducible] ScalarExpression.ArrayGrammar.read

def ArrayTypeNameVisible (text : Source) (state : ParserState) (first after : Nat) : Prop :=
  lookupName text state.names first after = 0 ∧
    ScalarExpression.lookup text state.scalarNames first after = 0 ∧
    ArrayBindings.lookup text state.arrayNames.names first after = 0 ∧
    BooleanBindings.lookup text state.booleanNames first after = 0 ∧
    FunctionBindings.lookup text state.functions first after = 0 ∧
    ProcedureBindings.lookup text state.procedures first after = 0 ∧
    formalHides text state first after = false

inductive ArrayTypeNameAt (text : Source) (state : ParserState) (position : Nat) : Nat → Nat → Prop
  | named {name : Source} {typeId after : Nat} :
      skipAt text position ≠ 0 → Named.IdentifierAt text (skipAt text position) name after →
      ArrayTypeNameVisible text state (skipAt text position) after →
      ArrayBindings.lookupType text state.arrayNames.types (skipAt text position) after = typeId →
      typeId ≠ 0 → ArrayTypeNameAt text state position typeId after

theorem ArrayTypeNameAt.complete {text state position typeId after}
    (reading : ArrayTypeNameAt text state position typeId after) :
    arrayTypeAt text state position = typeId ∧ nameAfter text (skipAt text position) = after := by
  cases reading with
  | named positive identifier visible selected present =>
      have parsed : nameAfter text (skipAt text position) = after := by
        simp only [nameAfter, positive, ↓reduceIte, Named.identifierEnd_complete identifier]
      refine ⟨?_, parsed⟩
      have span := Named.identifier_bounds identifier
      rcases visible with ⟨strings, scalars, arrays, booleans, functions, procedures, formals⟩
      simp only [arrayTypeAt, parsed, positive, Nat.not_le.mpr span.2.2.1,
        strings, scalars, arrays, booleans, functions, procedures, formals,
        Bool.false_eq_true, ne_eq, not_true_eq_false, false_or, ↓reduceIte, selected]

theorem arrayTypeAt_sound {text : Source} {state : ParserState} {position : Nat}
    (present : arrayTypeAt text state position ≠ 0) :
    ArrayTypeNameAt text state position (arrayTypeAt text state position)
      (nameAfter text (skipAt text position)) := by
  unfold arrayTypeAt at present ⊢
  dsimp only at present ⊢
  split at present
  · contradiction
  · rename_i good
    simp only [good, ↓reduceIte]
    have facts := good
    simp only [not_or, Decidable.not_not, Bool.not_eq_true] at facts
    have named : Named.identifierEnd text (skipAt text position) ≠ 0 := by
      have after : nameAfter text (skipAt text position) ≠ 0 := by omega
      simpa only [nameAfter, facts.1, ↓reduceIte] using after
    obtain ⟨name, parsed⟩ := Named.identifierEnd_sound text _ named
    apply ArrayTypeNameAt.named facts.1
    · simpa only [nameAfter, facts.1, ↓reduceIte] using parsed
    · exact facts.2.2
    · rfl
    · exact present

theorem ArrayTypeNameAt.bounds {text state position typeId after}
    (reading : ArrayTypeNameAt text state position typeId after) :
    0 < typeId ∧ typeId ≤ state.arrayNames.types.length ∧
      0 < after ∧ after ≤ text.length + 1 := by
  cases reading with
  | named positive identifier visible selected present =>
      have limit := ArrayBindings.lookupType_bound text state.arrayNames.types (skipAt text position) after
      have span := Named.identifier_bounds identifier
      rw [selected] at limit
      exact ⟨by omega, limit, by omega, span.2.2.2⟩

theorem ArrayTypeNameAt.valid {text state position typeId after}
    (reading : ArrayTypeNameAt text state position typeId after)
    (valid : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ArrayBindings.ValidType (ArrayBindings.arrayType state.arrayNames.types typeId) :=
  (valid.type_valid reading.bounds.1 reading.bounds.2.1).2

structure ArrayTypeDeclarationParts where
  first : Nat
  after : Nat
  start : Nat
  lower : ScalarExpression.Result
  upper : ScalarExpression.Result
  component : ScalarConstraintResult
  following : Nat

def arrayTypeDeclarationParts (text : Source) (state : ParserState) : ArrayTypeDeclarationParts :=
  let first := skipAt text (fixedAfter text state.position "type" true)
  let after := nameAfter text first
  let start := fixedAfter text (fixedAfter text (fixedAfter text after "is" true) "array" true) "(" false
  let lower := ScalarExpression.ArrayGrammar.read text start state.scalarNames state.arrayNames.table
  let upper := ScalarExpression.ArrayGrammar.read text (fixedAfter text lower.after ".." false)
    state.scalarNames state.arrayNames.table
  let component := scalarTypeAt text state
    (fixedAfter text (fixedAfter text upper.after ")" false) "of" true)
  ⟨first, after, start, lower, upper, component, fixedAfter text component.after ";" false⟩

def ArrayTypeDeclarationParts.item (parts : ArrayTypeDeclarationParts) : ArrayBindings.ArrayType :=
  ⟨parts.first, parts.after, ⟨parts.lower.bounds.lower, parts.upper.bounds.lower⟩, parts.component.bounds⟩

def ArrayTypeDeclarationParts.next (parts : ArrayTypeDeclarationParts) (text : Source)
    (state : ParserState) : ParserState :=
  {state with
    position := parts.following,
    arrayNames := {state.arrayNames with types := state.arrayNames.types ++ [parts.item]},
    subtypeNames := {state.subtypeNames with
      trueHidden := state.subtypeNames.trueHidden || Named.nameIs text parts.first parts.after ("true".toList.map Char.toNat),
      falseHidden := state.subtypeNames.falseHidden || Named.nameIs text parts.first parts.after ("false".toList.map Char.toNat),
      hiddenCalls := state.subtypeNames.hiddenCalls.add text parts.first parts.after}}

def ArrayTypeDeclarationReady (text : Source) (state : ParserState) (arguments : Bool)
    (parts : ArrayTypeDeclarationParts) : Prop :=
  parts.start ≠ 0 ∧ state.position < parts.following ∧ state.pure = false ∧
    newNameAllowed text state parts.first parts.after arguments = true ∧
    Named.nameIs text parts.first parts.after ("integer".toList.map Char.toNat) = false ∧
    state.arrayNames.types.length ≠ ArrayBindings.maxTypes ∧
    parts.lower.after ≠ 0 ∧ parts.upper.after ≠ 0 ∧ parts.component.after ≠ 0 ∧
    parts.lower.isStatic = true ∧ parts.upper.isStatic = true ∧
    parts.lower.bounds.isEmpty = false ∧ parts.upper.bounds.isEmpty = false ∧
    parts.lower.bounds.lower = parts.lower.bounds.upper ∧
    parts.upper.bounds.lower = parts.upper.bounds.upper ∧
    parts.lower.bounds.lower ≤ parts.upper.bounds.lower ∧
    parts.upper.bounds.lower - parts.lower.bounds.lower < (ArrayBindings.maxElements : Int)

def arrayTypeDeclarationRejected (text : Source) (state : ParserState) (arguments : Bool)
    (parts : ArrayTypeDeclarationParts) : Prop :=
  parts.start = 0 ∨ parts.following ≤ state.position ∨ state.pure ∨
    !newNameAllowed text state parts.first parts.after arguments ∨
    Named.nameIs text parts.first parts.after ("integer".toList.map Char.toNat) ∨
    state.arrayNames.types.length = ArrayBindings.maxTypes ∨
    parts.lower.after = 0 ∨ parts.upper.after = 0 ∨ parts.component.after = 0 ∨
    !parts.lower.isStatic ∨ !parts.upper.isStatic ∨ parts.lower.bounds.isEmpty ∨ parts.upper.bounds.isEmpty ∨
    parts.lower.bounds.lower ≠ parts.lower.bounds.upper ∨
    parts.upper.bounds.lower ≠ parts.upper.bounds.upper ∨
    parts.lower.bounds.lower > parts.upper.bounds.lower ∨
    parts.upper.bounds.lower - parts.lower.bounds.lower ≥ (ArrayBindings.maxElements : Int)

instance (text : Source) (state : ParserState) (arguments : Bool) (parts : ArrayTypeDeclarationParts) :
    Decidable (arrayTypeDeclarationRejected text state arguments parts) := inferInstanceAs (Decidable (_ ∨ _))

theorem arrayTypeDeclarationReady_iff {text state arguments parts} :
    ArrayTypeDeclarationReady text state arguments parts ↔
      ¬ arrayTypeDeclarationRejected text state arguments parts := by
  simp [ArrayTypeDeclarationReady, arrayTypeDeclarationRejected, not_or, Bool.not_eq_true,
    Bool.not_eq_false, Int.not_lt, Int.not_le, Nat.not_le]

theorem arrayTypeDeclarationAt_equation (text : Source) (state : ParserState) (arguments : Bool) :
    arrayTypeDeclarationAt text state arguments =
      let parts := arrayTypeDeclarationParts text state
      if arrayTypeDeclarationRejected text state arguments parts then invalidState else parts.next text state := rfl

/-- The source declaration retains both static bound expressions and the exact
component subtype reading; it introduces a type and allocates no object cells. -/
inductive ArrayTypeDeclarationAt (text : Source) (arguments : Bool) : ParserState → ParserState → Prop
  | declaration {state : ParserState} {parts : ArrayTypeDeclarationParts} {lower upper : Integer.Expr} :
      arrayTypeDeclarationParts text state = parts → ArrayTypeDeclarationReady text state arguments parts →
      ScalarExpression.ArrayGrammar.At text state.scalarNames parts.start lower parts.lower
        (arrays := state.arrayNames.table) →
      ScalarExpression.ArrayGrammar.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
        (arrays := state.arrayNames.table) →
      ScalarTypeAt text state (fixedAfter text (fixedAfter text parts.upper.after ")" false) "of" true) parts.component →
      ArrayTypeDeclarationAt text arguments state (parts.next text state)

theorem array_type_declaration_complete {text arguments state final}
    (reading : ArrayTypeDeclarationAt text arguments state final) :
    arrayTypeDeclarationAt text state arguments = final := by
  cases reading with
  | declaration parts ready _ _ _ =>
      rw [arrayTypeDeclarationAt_equation, parts]
      exact ite_eq_right (arrayTypeDeclarationReady_iff.mp ready)

theorem array_type_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (arrayTypeDeclarationAt text state arguments).position ≠ 0) :
    ArrayTypeDeclarationAt text arguments state (arrayTypeDeclarationAt text state arguments) := by
  rw [arrayTypeDeclarationAt_equation] at accepted ⊢
  generalize partsEq : arrayTypeDeclarationParts text state = parts at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i good
    rw [ite_eq_right good]
    have ready := arrayTypeDeclarationReady_iff.mpr good
    rcases ready with ⟨start, advances, pure, fresh, reserved, room, low, high, component, rest⟩
    have lowEq : ScalarExpression.ArrayGrammar.read text parts.start state.scalarNames state.arrayNames.table = parts.lower := by
      rw [← partsEq]; rfl
    have highEq : ScalarExpression.ArrayGrammar.read text (fixedAfter text parts.lower.after ".." false)
        state.scalarNames state.arrayNames.table = parts.upper := by rw [← partsEq]; rfl
    have componentEq : scalarTypeAt text state
        (fixedAfter text (fixedAfter text parts.upper.after ")" false) "of" true) = parts.component := by
      rw [← partsEq]; rfl
    have startBound : parts.start ≤ text.length + 1 := by
      rw [← partsEq]
      exact fixedAfter_result_bound text _ "(" false (by decide)
    obtain ⟨lower, lowerRead⟩ := ScalarExpression.ArrayGrammar.read_sound startBound (lowEq.symm ▸ low)
    obtain ⟨upper, upperRead⟩ := ScalarExpression.ArrayGrammar.read_sound
      (fixedAfter_result_bound text _ ".." false (by decide)) (highEq.symm ▸ high)
    exact .declaration partsEq (arrayTypeDeclarationReady_iff.mpr good)
      (lowEq ▸ lowerRead) (highEq ▸ upperRead)
      (componentEq ▸ scalarTypeAt_sound text state _ (componentEq.symm ▸ component))

theorem array_type_declaration_positive {text arguments state final}
    (reading : ArrayTypeDeclarationAt text arguments state final) : final.position ≠ 0 := by
  cases reading with
  | declaration _ ready _ _ _ =>
      have advance := ready.2.1
      dsimp only [ArrayTypeDeclarationParts.next]
      omega

theorem array_type_declaration_advances {text arguments state final}
    (reading : ArrayTypeDeclarationAt text arguments state final) : state.position < final.position := by
  cases reading with
  | declaration _ ready _ _ _ => exact ready.2.1

theorem array_type_declaration_fields {text arguments state final}
    (reading : ArrayTypeDeclarationAt text arguments state final) :
    final = {state with
      position := final.position
      arrayNames := {state.arrayNames with types := final.arrayNames.types}
      subtypeNames := final.subtypeNames} := by
  cases reading <;> rfl

theorem array_type_declaration_item_valid {text arguments state parts lower upper}
    (ready : ArrayTypeDeclarationReady text state arguments parts)
    (low : ScalarExpression.ArrayGrammar.At text state.scalarNames parts.start lower parts.lower
      (arrays := state.arrayNames.table))
    (high : ScalarExpression.ArrayGrammar.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
      (arrays := state.arrayNames.table))
    (component : ScalarTypeAt text state (fixedAfter text (fixedAfter text parts.upper.after ")" false) "of" true) parts.component)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidType parts.item := by
  rcases ready with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, ordered, capacity⟩
  exact ⟨⟨(Integer.Expr.infer_bounded low.inferred).1, (Integer.Expr.infer_bounded high.inferred).1⟩,
    ordered, component.bounded subtypes, component.nonempty subtypes, capacity⟩

theorem array_type_declaration_types_valid {text arguments state final}
    (reading : ArrayTypeDeclarationAt text arguments state final)
    (valid : ArrayBindings.ValidTypes text state.arrayNames.types)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidTypes text final.arrayNames.types := by
  cases reading with
  | declaration partsEq ready low high component =>
      have shape := array_type_declaration_item_valid ready low high component subtypes
      have fresh := ready.2.2.2.1
      simp only [newNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at fresh
      have room := ready.2.2.2.2.2.1
      refine ⟨by dsimp only [ArrayTypeDeclarationParts.next]; simp only [List.length_append, List.length_singleton]; have cap := valid.1; omega, ?_⟩
      intro item member
      simp only [ArrayTypeDeclarationParts.next, List.mem_append, List.mem_singleton] at member
      rcases member with prior | rfl
      · exact valid.2 item prior
      · refine ⟨⟨?_, ?_, ?_⟩, shape⟩
        · dsimp only [ArrayTypeDeclarationParts.item]; omega
        · dsimp only [ArrayTypeDeclarationParts.item]; omega
        · dsimp only [ArrayTypeDeclarationParts.item]
          rw [← partsEq]
          exact model_name_valid text _

theorem array_type_declaration_source_ready {text arguments state final}
    (reading : ArrayTypeDeclarationAt text arguments state final)
    (ready : ArrayBindings.SourceReady text state.arrayNames) :
    ArrayBindings.SourceReady text final.arrayNames := by
  cases reading with
  | declaration => exact ready

theorem array_type_declaration_unique {text arguments state first second}
    (left : ArrayTypeDeclarationAt text arguments state first)
    (right : ArrayTypeDeclarationAt text arguments state second) : first = second :=
  (array_type_declaration_complete left).symm.trans (array_type_declaration_complete right)

end Silver.Compose
