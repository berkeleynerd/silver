module

public import Silver.ApplicationPackageDeclarationsSpecificationObjectDomains

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

theorem object_state_position {text : Source} {frame : ParserState}
    (valid : stateValid text frame = true) (position : Nat) (bounded : ValidCursor text position) :
    stateValid text {frame with position} = true := by
  simp only [stateValid, Bool.and_eq_true, decide_eq_true_eq, and_assoc] at valid ⊢
  exact ⟨bounded, valid.2⟩

theorem object_state_scalar {text : Source} {frame : ParserState}
    (valid : stateValid text frame = true) (first last : Nat) (span : ValidName text first last)
    (value declared : Integer.Interval) (nonempty : value.isEmpty = false)
    (lower : declared.lower ≤ value.lower) (upper : value.upper ≤ declared.upper)
    (static mutable : Bool) :
    stateValid text {frame with scalarNames := frame.scalarNames ++
      [⟨first, last, value, static, declared, mutable, 0, 0⟩]} = true := by
  let item : ScalarExpression.Binding := ⟨first, last, value, static, declared, mutable, 0, 0⟩
  have name : nameStateValid text first last = true := (nameStateValid_meaning ..).mpr (.inr span)
  have names : scalarNamesValid text (frame.scalarNames ++ [item]) = scalarNamesValid text frame.scalarNames := by
    simp only [scalarNamesValid, List.all_append, List.all_cons, List.all_nil, item, name]
    simp [nameStateValid, span.1]
  have writable : mutableBoundsValid (frame.scalarNames ++ [item]) = mutableBoundsValid frame.scalarNames := by
    cases mutable <;> simp [mutableBoundsValid, item, nonempty, lower, upper]
  have values : declarationValuesValid (frame.scalarNames ++ [item]) (frame.scalarNames ++ [item]).length =
      declarationValuesValid frame.scalarNames frame.scalarNames.length := by
    simp only [declarationValuesValid, Nat.le_refl, decide_true, Bool.true_and, List.take_length,
      List.all_append, List.all_cons, List.all_nil, item, nonempty, Bool.not_false, Bool.and_true]
  change stateValid text {frame with scalarNames := frame.scalarNames ++ [item]} = true
  simpa only [stateValid, names, writable, values] using valid

theorem object_state_boolean {text : Source} {frame : ParserState}
    (valid : stateValid text frame = true) (first last : Nat) (span : ValidName text first last)
    (mutable known value : Bool) :
    stateValid text {frame with booleanNames := frame.booleanNames ++
      [⟨first, last, mutable, 0, 0, known, value⟩]} = true := by
  let item : BooleanBindings.Binding := ⟨first, last, mutable, 0, 0, known, value⟩
  have name : nameStateValid text first last = true := (nameStateValid_meaning ..).mpr (.inr span)
  have names : booleanNamesValid text (frame.booleanNames ++ [item]) = booleanNamesValid text frame.booleanNames := by
    simp only [booleanNamesValid, List.all_append, List.all_cons, List.all_nil, item, name]
    simp [nameStateValid, span.1]
  change stateValid text {frame with booleanNames := frame.booleanNames ++ [item]} = true
  simpa only [stateValid, names] using valid

end Silver.ApplicationPackageDeclarations
