module

public import Silver.ScalarArrayGrammarRecognition
public import Silver.ScalarExpressionGrammar
public import Silver.ScalarFunctionArrayShape

@[expose] public section

namespace Silver.ScalarExpression.ArrayGrammar

private def FrameShape (frame : List (Nat × Integer.ArrayDescriptor)) (mode : ArrayReadMode)
    (expression : Integer.Expr) : Prop :=
  ScalarFunctions.frameExpression frame expression = true ∧
    (mode = .noElements → expression.hasArray = false)

private theorem literal_shape (frame : List (Nat × Integer.ArrayDescriptor))
    (mode : ArrayReadMode) (value : Int) : FrameShape frame mode (.literal value) :=
  ⟨rfl, fun _ => rfl⟩

private theorem unary_shape {frame mode value} (good : FrameShape frame mode value.expression)
    (negative : Bool) : FrameShape frame mode (unary value negative).expression := by
  cases negative <;> simpa only [unary, Bool.false_eq_true, ↓reduceIte,
    FrameShape, ScalarFunctions.frameExpression, Integer.Expr.hasArray] using good

private theorem binary_shape {frame mode left right value operator}
    (a : FrameShape frame mode left.expression) (b : FrameShape frame mode right.expression)
    (found : binary left right operator = some value) : FrameShape frame mode value.expression := by
  unfold binary at found
  repeat' first | split at found | cases found
  all_goals
    constructor
    · simp only [ScalarFunctions.frameExpression, a.1, b.1, Bool.and_self]
    · intro disabled
      simp only [Integer.Expr.hasArray, a.2 disabled, b.2 disabled, Bool.or_self]

theorem parseFuel_frameShape {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {allowSign : Bool}
    {arrayReads : ArrayReadMode} {value : Parsed}
    {frame : List (Nat × Integer.ArrayDescriptor)}
    (members : ∀ item ∈ arrays.items, item.isBoolean = false → (item.typeId, item.viewDescriptor) ∈ frame)
    (bound : position ≤ text.length + 1)
    (found : parseFuel fuel text position names arrays maskFirst maskAfter allowSign arrayReads = some value) :
    ScalarFunctions.frameExpression frame value.expression = true ∧
      (arrayReads = .noElements → value.expression.hasArray = false) := by
  change FrameShape frame arrayReads value.expression
  induction fuel generalizing position allowSign arrayReads value with
  | zero => cases found
  | succ fuel ih =>
      have first := skip_bounds text position bound
      rw [parseFuel] at found
      dsimp only at found
      split at found
      · cases found
      · rename_i valid
        split at found
        · split at found
          · have parsed := ScalarExpression.atom_sound first.2 found
            cases parsed <;> exact ⟨rfl, fun _ => rfl⟩
          · split at found
            · unfold attributeAtom at found
              obtain ⟨query, parsed, same⟩ := Option.bind_eq_some_iff.mp found
              cases same
              exact literal_shape ..
            · split at found
              · cases found
              · rename_i allowed
                split at found
                · cases found
                · rename_i opened
                  have namedBounds := ArrayAttributes.nameAfter_bounds
                    (show nameAfter text (skip text position) ≠ 0 by omega)
                  have opening := symbol_bounds namedBounds.2 opened
                  obtain ⟨index, parsed, found⟩ := Option.bind_eq_some_iff.mp found
                  have indexShape := ih opening.2 parsed
                  split at found
                  · cases found
                  · cases found
                    let item := ArrayBindings.binding arrays.items
                      (ArrayBindings.lookup text arrays.items (skip text position) (nameAfter text (skip text position)))
                    have positive : 0 < ArrayBindings.lookup text arrays.items
                        (skip text position) (nameAfter text (skip text position)) := by omega
                    have present : item ∈ arrays.items :=
                      ArrayBindings.binding_mem positive (ArrayBindings.lookup_bound ..)
                    have integerKind : item.isBoolean = false := by
                      apply Bool.eq_false_iff.mpr
                      intro boolean
                      apply allowed
                      simp only [item] at boolean
                      simp only [boolean, true_or, or_true]
                    have member := members item present integerKind
                    have presentFrame : frame.any (fun input => input.2 == item.viewDescriptor) = true :=
                      List.any_eq_true.mpr ⟨(item.typeId, item.viewDescriptor), member, by simp⟩
                    constructor
                    · change (_ && _ && _) = true
                      rw [presentFrame, indexShape.2 rfl, indexShape.1]
                      rfl
                    · intro disabled
                      exact False.elim (allowed (Or.inl disabled))
        · have inner := skip_bounds text (skip text position + 1) (by omega)
          split at found
          · cases found
          · rename_i innerValid
            split at found
            · have next := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
              obtain ⟨original, originalFound, _, rfl⟩ := close_result found
              change FrameShape frame arrayReads original.expression
              split at originalFound
              · obtain ⟨_, rfl⟩ := literal_result originalFound
                exact literal_shape ..
              · simp only [Option.map_eq_some_iff] at originalFound
                obtain ⟨child, childFound, rfl⟩ := originalFound
                exact unary_shape (ih next.2 childFound) _
            · change (Option.bind _ _) = some value at found
              obtain ⟨left, leftFound, found⟩ := Option.bind_eq_some_iff.mp found
              have leftShape := ih inner.2 leftFound
              have leftBounds := parseFuel_bounds inner.2 leftFound
              split at found
              · cases found
              · split at found
                · cases found
                  exact leftShape
                · split at found
                  · cases found
                  · rename_i operator
                    have operatorBounds := binaryAfter_bounds operator
                    obtain ⟨right, rightFound, found⟩ := Option.bind_eq_some_iff.mp found
                    have rightShape := ih operatorBounds.2 rightFound
                    obtain ⟨original, originalFound, _, rfl⟩ := close_result found
                    change FrameShape frame arrayReads original.expression
                    exact binary_shape leftShape rightShape originalFound

theorem At.frameExpression {text names position expression result maskFirst maskAfter allowSign arrays initials elaborating arrayReads}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating arrayReads)
    {frame : List (Nat × Integer.ArrayDescriptor)}
    (members : ∀ item ∈ arrays.items, item.isBoolean = false → (item.typeId, item.viewDescriptor) ∈ frame) :
    ScalarFunctions.frameExpression frame expression = true :=
  (parseFuel_frameShape members parsed.positionBound parsed.grammar).1

theorem At.noElements {text names position expression result maskFirst maskAfter allowSign arrays initials elaborating}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating .noElements) :
    expression.hasArray = false := by
  let frame := arrays.items.map (fun item => (item.typeId, item.viewDescriptor))
  have members : ∀ item ∈ arrays.items, item.isBoolean = false → (item.typeId, item.viewDescriptor) ∈ frame := by
    intro item member _
    exact List.mem_map.mpr ⟨item, member, rfl⟩
  exact (parseFuel_frameShape members parsed.positionBound parsed.grammar).2 rfl

end Silver.ScalarExpression.ArrayGrammar
