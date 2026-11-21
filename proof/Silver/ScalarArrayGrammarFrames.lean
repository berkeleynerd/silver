module

public import Silver.ScalarArrayGrammarSyntax
public import Silver.ScalarArrayExpressionRecognition
public import Silver.ScalarFunctionArrayShape

@[expose] public section

namespace Silver.ScalarExpression.ArrayGrammar

private theorem noArray_of_readsOnly {allowed : Nat → Prop} {expression : Integer.Expr}
    (reads : expression.ReadsOnly allowed) : expression.hasArray = false := by
  induction expression <;> simp_all [Integer.Expr.ReadsOnly, Integer.Expr.hasArray]

private def FrameShape (names : Environment) (frame : List (Nat × Integer.ArrayDescriptor)) (mode : ArrayReadMode)
    (expression : Integer.Expr) : Prop :=
  ScalarFunctions.frameExpression frame expression = true ∧
    (mode = .noElements → expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length))

private theorem literal_shape (names : Environment) (frame : List (Nat × Integer.ArrayDescriptor))
    (mode : ArrayReadMode) (value : Int) : FrameShape names frame mode (.literal value) :=
  ⟨rfl, fun _ => trivial⟩

private theorem unary_shape {names frame mode value} (good : FrameShape names frame mode value.expression)
    (negative : Bool) : FrameShape names frame mode (unary value negative).expression := by
  cases negative <;> simpa only [unary, Bool.false_eq_true, ↓reduceIte,
    FrameShape, ScalarFunctions.frameExpression, Integer.Expr.ReadsOnly] using good

private theorem binary_shape {names frame mode left right value operator}
    (a : FrameShape names frame mode left.expression) (b : FrameShape names frame mode right.expression)
    (found : binary left right operator = some value) : FrameShape names frame mode value.expression := by
  unfold binary at found
  repeat' first | split at found | cases found
  all_goals
    constructor
    · simp only [ScalarFunctions.frameExpression, a.1, b.1, Bool.and_self]
    · intro disabled
      exact ⟨a.2 disabled, b.2 disabled⟩

private theorem parseFuel_frameShapeWithReads {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {allowSign : Bool}
    {arrayReads : ArrayReadMode} {value : Parsed}
    {frame : List (Nat × Integer.ArrayDescriptor)}
    (members : ∀ item ∈ arrays.items, item.isBoolean = false → (item.typeId, item.viewDescriptor) ∈ frame)
    (bound : position ≤ text.length + 1)
    (found : parseFuel fuel text position names arrays maskFirst maskAfter allowSign arrayReads = some value) :
    ScalarFunctions.frameExpression frame value.expression = true ∧
      (arrayReads = .noElements → value.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length)) := by
  change FrameShape names frame arrayReads value.expression
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
            exact ⟨by cases parsed <;> rfl, fun _ => atom_readsOnly parsed⟩
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
                      rw [presentFrame, noArray_of_readsOnly (indexShape.2 rfl), indexShape.1]
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
              change FrameShape names frame arrayReads original.expression
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
                    change FrameShape names frame arrayReads original.expression
                    exact binary_shape leftShape rightShape originalFound

theorem parseFuel_frameShape {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {allowSign : Bool}
    {arrayReads : ArrayReadMode} {value : Parsed}
    {frame : List (Nat × Integer.ArrayDescriptor)}
    (members : ∀ item ∈ arrays.items, item.isBoolean = false → (item.typeId, item.viewDescriptor) ∈ frame)
    (bound : position ≤ text.length + 1)
    (found : parseFuel fuel text position names arrays maskFirst maskAfter allowSign arrayReads = some value) :
    ScalarFunctions.frameExpression frame value.expression = true ∧
      (arrayReads = .noElements → value.expression.hasArray = false) := by
  have shape := parseFuel_frameShapeWithReads members bound found
  exact ⟨shape.1, fun disabled => noArray_of_readsOnly (shape.2 disabled)⟩

theorem At.frameExpression {text names position expression result maskFirst maskAfter allowSign arrays initials elaborating arrayReads}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating arrayReads)
    {frame : List (Nat × Integer.ArrayDescriptor)}
    (members : ∀ item ∈ arrays.items, item.isBoolean = false → (item.typeId, item.viewDescriptor) ∈ frame) :
    ScalarFunctions.frameExpression frame expression = true :=
  (parseFuel_frameShape members parsed.positionBound parsed.grammar).1

theorem parseFuel_noElements_readsOnly {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : parseFuel fuel text position names arrays maskFirst maskAfter allowSign .noElements = some value) :
    value.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length) := by
  let frame := arrays.items.map (fun item => (item.typeId, item.viewDescriptor))
  have members : ∀ item ∈ arrays.items, item.isBoolean = false → (item.typeId, item.viewDescriptor) ∈ frame := by
    intro item member _
    exact List.mem_map.mpr ⟨item, member, rfl⟩
  exact (parseFuel_frameShapeWithReads members bound found).2 rfl

theorem At.noElements_readsOnly {text names position expression result maskFirst maskAfter allowSign arrays initials elaborating}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating .noElements) :
    expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length) :=
  parseFuel_noElements_readsOnly parsed.positionBound parsed.grammar

theorem At.noElements {text names position expression result maskFirst maskAfter allowSign arrays initials elaborating}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating .noElements) :
    expression.hasArray = false :=
  noArray_of_readsOnly parsed.noElements_readsOnly

theorem SourceAt.noArray_readsOnly {text names arrays maskFirst maskAfter mode allowSign position value}
    (source : SourceAt text names arrays maskFirst maskAfter mode allowSign position value)
    (absent : value.expression.hasArray = false) :
    value.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length) := by
  induction source with
  | ordinary _ _ _ atom => exact atom_readsOnly atom
  | shape | signed => trivial
  | indexed => contradiction
  | unary _ _ _ _ _ ih =>
      simp only [ScalarExpression.unary] at absent ⊢
      split at absent <;> rename_i negative <;>
        simpa only [negative, Bool.false_eq_true, ↓reduceIte, Integer.Expr.ReadsOnly] using ih absent
  | grouped _ _ _ _ ih => exact ih absent
  | binary _ _ _ _ _ _ _ combined _ ihl ihr =>
      rw [binary_hasArray combined] at absent
      have parts := Bool.or_eq_false_iff.mp absent
      have reads := binary_readsOnly (ihl parts.1) (ihr parts.2) combined
      exact reads

theorem At.noArray_readsOnly {text names position expression result maskFirst maskAfter allowSign arrays initials elaborating mode}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating mode)
    (absent : expression.hasArray = false) :
    expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length) :=
  parsed.source.noArray_readsOnly absent

theorem At.static_noArray {text names position expression result maskFirst maskAfter allowSign arrays initials elaborating mode}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating mode)
    (fixed : result.isStatic = true) : expression.hasArray = false := by
  have staticExpr := parsed.staticValue.symm.trans fixed
  clear parsed fixed
  induction expression <;> simp_all [isStatic, Integer.Expr.hasArray]

end Silver.ScalarExpression.ArrayGrammar
