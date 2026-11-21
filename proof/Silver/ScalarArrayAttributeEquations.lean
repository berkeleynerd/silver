module

public import Silver.ScalarExpressionNativeDefinitions

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option linter.unusedSimpArgs false

theorem arrayAttribute_model_equation (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat) (rangeQuery : Bool) :
    arrayAttributeEquation modelCalls text position names arrays maskFirst maskAfter rangeQuery =
      ArrayAttributes.read text position names arrays maskFirst maskAfter rangeQuery := by
  dsimp +instances only [arrayAttributeEquation, modelCalls, ArrayBindings.Native.modelCalls,
    ArrayAttributes.read, ArrayAttributes.parse, ArrayAttributes.selectedShape]
  split
  · rfl
  · split
    · split
      · rfl
      · simp only [arrayAttributeResultEquation, modelCalls, ArrayBindings.Native.modelCalls,
          ArrayAttributes.selectedQuery, Bind.bind, Option.bind,
          show "range".toList.map Char.toNat = ArrayAttributes.Query.range.word from rfl,
          show "first".toList.map Char.toNat = ArrayAttributes.Query.first.word from rfl,
          show "last".toList.map Char.toNat = ArrayAttributes.Query.last.word from rfl,
          show "length".toList.map Char.toNat = ArrayAttributes.Query.length.word from rfl]
        repeat' first | rfl | split
    · split
      · simp only [arrayAttributeResultEquation, modelCalls, ArrayBindings.Native.modelCalls,
          ArrayAttributes.selectedQuery, Bind.bind, Option.bind,
          show "range".toList.map Char.toNat = ArrayAttributes.Query.range.word from rfl,
          show "first".toList.map Char.toNat = ArrayAttributes.Query.first.word from rfl,
          show "last".toList.map Char.toNat = ArrayAttributes.Query.last.word from rfl,
          show "length".toList.map Char.toNat = ArrayAttributes.Query.length.word from rfl]
        repeat' first | rfl | split
      · rfl

theorem interpreted_arrayAttributeResult (calls : Calls) (primitives : Primitives calls)
    (text : Source) (valid : ValidText text) (first after : Nat)
    (named : Span text first after) (shape : Integer.Interval) (shapeValid : ArrayAttributes.ShapeValid shape)
    (rangeQuery : Bool) :
    arrayAttributeResultEquation calls text first after shape rangeQuery =
      arrayAttributeResultEquation modelCalls text first after shape rangeQuery := by
  unfold arrayAttributeResultEquation
  rw [primitives.nameIs text valid first after _ named (by decide) (by decide),
    primitives.nameIs text valid first after _ named (by decide) (by decide),
    primitives.nameIs text valid first after _ named (by decide) (by decide),
    primitives.nameIs text valid first after _ named (by decide) (by decide),
    primitives.arrayPrimitives.singleton _ shapeValid.1.1,
    primitives.arrayPrimitives.singleton _ shapeValid.1.2,
    primitives.arrayPrimitives.singleton _
      (show Integer.InRange (shape.upper - shape.lower + 1) from
        (ArrayAttributes.Query.bounds_bounded .length shapeValid).1)]
  rfl

theorem interpreted_arrayAttribute (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat) (rangeQuery : Bool)
    (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) (metadata : ArrayBindings.ValidTable text arrays) :
    calls.readArrayAttribute text position names arrays maskFirst maskAfter rangeQuery =
      ArrayAttributes.read text position names arrays maskFirst maskAfter rangeQuery := by
  rw [equations.arrayAttribute text valid position names arrays maskFirst maskAfter rangeQuery bound environment mask metadata,
    arrayAttribute_denotation, ← arrayAttribute_model_equation]
  have firstBounds := skip_bounds text position bound
  have afterBound := nameAfter_bounds text (skip text position)
  have tickBound : symbol text (nameAfter text (skip text position)) 39 ≤ text.length + 1 := by
    by_cases zero : symbol text (nameAfter text (skip text position)) 39 = 0
    · omega
    · exact (symbol_bounds afterBound zero).2
  have attrBounds := skip_bounds text (symbol text (nameAfter text (skip text position)) 39) tickBound
  have attrAfterBound := nameAfter_bounds text (skip text (symbol text (nameAfter text (skip text position)) 39))
  unfold arrayAttributeEquation
  rw [interpreted_skip calls primitives equations text valid position bound]
  dsimp only
  rw [interpreted_nameAfter calls primitives equations text valid _ firstBounds.2,
    interpreted_symbol calls primitives equations text valid _ 39 afterBound (by decide),
    interpreted_skip calls primitives equations text valid _ tickBound,
    interpreted_nameAfter calls primitives equations text valid _ attrBounds.2,
    interpreted_lookup calls primitives equations text valid names environment _ _ firstBounds.2 afterBound,
    ArrayBindings.Native.interpreted_lookup calls.arrays primitives.arrayPrimitives primitives.arrayEquations
      text valid arrays metadata _ _ firstBounds.2 afterBound,
    ArrayBindings.Native.interpreted_lookupType calls.arrays primitives.arrayPrimitives primitives.arrayEquations
      text valid arrays.types metadata.1 _ _ firstBounds.2 afterBound]
  dsimp +instances only [modelCalls, ArrayBindings.Native.modelCalls]
  by_cases malformed : skip text position = 0 ∨ nameAfter text (skip text position) ≤ skip text position ∨
      skip text (symbol text (nameAfter text (skip text position)) 39) = 0 ∨
      nameAfter text (skip text (symbol text (nameAfter text (skip text position)) 39)) ≤
        skip text (symbol text (nameAfter text (skip text position)) 39)
  · rcases malformed with bad | bad | bad | bad <;> simp only [bad, true_or, or_true, ↓reduceIte]
  · have named : Span text (skip text position) (nameAfter text (skip text position)) := by
      exact ⟨by omega, by omega, afterBound⟩
    have attrNamed : Span text (skip text (symbol text (nameAfter text (skip text position)) 39))
        (nameAfter text (skip text (symbol text (nameAfter text (skip text position)) 39))) := by
      exact ⟨by omega, by omega, attrAfterBound⟩
    have compared : (maskFirst ≠ 0 ∧ calls.equalName text maskFirst maskAfter
        (skip text position) (nameAfter text (skip text position)) = true) =
        (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter
        (skip text position) (nameAfter text (skip text position)) = true) := by
      by_cases noMask : maskFirst = 0
      · simp [noMask]
      · have maskSpan : Span text maskFirst maskAfter := by
          rcases mask with absent | active
          · exact False.elim (noMask absent.1)
          · exact active
        rw [primitives.equalName text valid maskFirst maskAfter _ _ maskSpan named]
    simp only [compared]
    split
    · rfl
    · split
      · rename_i objectFound
        split
        · rfl
        · have item := metadata.binding_valid
            (index := ArrayBindings.lookup text arrays.items (skip text position) (nameAfter text (skip text position)))
            (by omega)
            (ArrayBindings.lookup_bound text arrays.items _ _)
          exact interpreted_arrayAttributeResult calls primitives text valid _ _ attrNamed _
            ⟨item.2.1.1.1, item.2.1.1.2.1, item.2.1.length_bound⟩ rangeQuery
      · split
        · rename_i typeFound
          have item := metadata.1.type_valid
            (index := ArrayBindings.lookupType text arrays.types (skip text position) (nameAfter text (skip text position)))
            (by omega)
            (ArrayBindings.lookupType_bound text arrays.types _ _)
          exact interpreted_arrayAttributeResult calls primitives text valid _ _ attrNamed _
            ⟨item.2.1, item.2.2.1, item.2.length_bound⟩ rangeQuery
        · rfl

end Silver.ScalarExpression.Native
