module

public import Silver.ComposeAtoms
public import Silver.ComposeBoundTracking

@[expose] public section

namespace Silver.Compose
open Bindings StringObjectBounds

def Operand.objectBounds (names : BindingEnvironment) (input : Source) (integers : Integer.Store) : Operand → Bounds
  | .literal bytes => .canonical bytes.length
  | .reference index | .replace index _ _ _ =>
      let info := (names.get index).getD {}
      if info.dynamic then .canonical input.length else BindingInfo.objectBounds info
  | .argument => .canonical input.length
  | .image scalar => .canonical (Integer.Image.bytes (scalar.evaluate integers)).length
  | .slice _ _ lower upper => ⟨lower.evaluate integers, upper.evaluate integers⟩
  | .character _ => .canonical 1

def namesBoundCeiling (names : BindingEnvironment) : Int := max 1 ((names.length : Int) * maxSourceLength)

theorem namesBoundCeiling_positive (names : BindingEnvironment) : 1 ≤ namesBoundCeiling names := by
  unfold namesBoundCeiling
  omega

theorem selected_binding_bounds {names : BindingEnvironment} {index : Nat} {info : BindingInfo}
    (present : names.get index = some info) : 0 < index ∧ index ≤ names.length := by
  unfold BindingEnvironment.get at present
  split at present
  · cases present
  · have inside := (List.getElem?_eq_some_iff.mp present).1
    omega

theorem value_fixed_bounds {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position : Nat} {value : Operand} {result : ValueResult} {integers : Integer.Store}
    (input : Source) (normal : NamesNormal names)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ScalarExpression.ranges scalarNames)) integers)
    (parsed : ValueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
      (initials := initials) (elaborating := elaborating) text names position value result)
    (fixed : result.dynamicSeen = false) :
    result.ContainsBounds (value.objectBounds names input integers) := by
  cases parsed with
  | literal =>
      constructor <;> simp [Operand.objectBounds, Bounds.canonical, Bounds.length,
        Integer.Interval.Contains, Integer.Interval.singleton]
  | reference positive source selected nonzero unmasked present typed noParen =>
      rename_i after index name info
      change info.dynamic = false at fixed
      have length := (normal.typed _ _ present).2 fixed
      constructor <;> simp [Operand.objectBounds, present, fixed, stringReferenceValue,
        BindingInfo.objectBounds, Bounds.length, Integer.Interval.Contains, Integer.Interval.singleton, length]
  | slice _ _ source =>
      have lower := (Integer.Expr.infer_sound source.lowerSource.inferred scalars).1
      have upper := (Integer.Expr.infer_sound (source.upperSource rfl).inferred scalars).1
      have lengths := StringIndexing.sliceLength_bounds lower upper
      exact ⟨lower, upper, lengths.1, lengths.2⟩
  | image _ _ _ source =>
      have inferred := Integer.Expr.infer_sound source.scalar.inferred scalars
      have nonempty : (imageParts text position scalarNames arrays initials elaborating).scalar.bounds.isEmpty = false := by
        have contains := inferred.1
        simp only [Integer.Interval.isEmpty, Integer.Interval.Contains, decide_eq_false_iff_not] at *
        omega
      have lengths := Integer.Image.length_interval _ _ inferred.1
      constructor <;> simp [Operand.objectBounds, imageValue, LengthSummary.ofImage, nonempty,
        Bounds.canonical, Bounds.length, Integer.Interval.singleton, Integer.Interval.Contains]
      · exact ⟨by omega, by omega⟩
      · exact lengths.1
      · exact lengths.2

theorem value_objectBounds_length {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position : Nat} {value : Operand} {result : ValueResult} {integers : Integer.Store}
    {input : Source} {values : Values} (normal : NamesNormal names)
    (strings : Fits names.shape input values)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ScalarExpression.ranges scalarNames)) integers)
    (parsed : ValueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
      (initials := initials) (elaborating := elaborating) text names position value result) :
    (value.objectBounds names input integers).length = (value.evaluate values input integers).length := by
  cases parsed with
  | literal | image => simp [Operand.objectBounds, Bounds.canonical_length, Value.evaluate]
  | reference positive source selected nonzero unmasked present typed noParen =>
      rename_i after index name info
      have fit := strings index info.cell (by simp [BindingEnvironment.shape, present])
      cases dynamic : info.dynamic with
      | true => simpa [Operand.objectBounds, present, dynamic, Bounds.canonical_length,
          Value.evaluate, BindingInfo.cell, Bindings.BindingInfo.bound, Bound.length] using fit.1.symm
      | false =>
          have length := (normal.typed _ _ present).2 dynamic
          simpa [Operand.objectBounds, present, dynamic, BindingInfo.objectBounds, Bounds.length,
            Value.evaluate, BindingInfo.cell, Bindings.BindingInfo.bound, Bound.length, length] using fit.1.symm
  | slice _ _ source =>
      have lower := (Integer.Expr.infer_sound source.lowerSource.inferred scalars).1
      have upper := (Integer.Expr.infer_sound (source.upperSource rfl).inferred scalars).1
      have checked := StringIndexing.sliceCheck_sound (slice_check normal source) lower upper
      have fit := (fits_fixedLengths strings) _ _ (fixedLengths_of_info source.selected source.fixed)
      rw [← fit.1] at checked
      exact (StringIndexing.slice_length _ checked).symm

theorem canonical_bounds_valid {length : Nat} (bounded : length ≤ maxSourceLength) :
    (Bounds.canonical length).Valid := by
  simp only [Bounds.Valid, Bounds.canonical, Integer.InRange, Integer.minValue, Integer.maxValue, maxSourceLength] at *
  omega

theorem value_objectBounds_valid {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position : Nat} {value : Operand} {result : ValueResult} {integers : Integer.Store}
    {input : Source} (textBound : text.length ≤ maxSourceLength) (inputBound : input.length ≤ maxSourceLength)
    (metadata : NamesBoundsValid names)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ScalarExpression.ranges scalarNames)) integers)
    (parsed : ValueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
      (initials := initials) (elaborating := elaborating) text names position value result) :
    (value.objectBounds names input integers).Valid := by
  cases parsed with
  | literal _ _ _ source =>
      have bounds := Output.literalAt_bounds source
      exact canonical_bounds_valid (by omega)
  | reference positive source selected nonzero unmasked present typed noParen =>
      rename_i after index name info
      cases dynamic : info.dynamic with
      | true => simpa [Operand.objectBounds, present, dynamic] using canonical_bounds_valid inputBound
      | false => simpa [Operand.objectBounds, present, dynamic] using BindingInfo.boundsValid_valid (metadata _ _ present) dynamic
  | image _ _ _ source =>
      have inferred := Integer.Expr.infer_sound source.scalar.inferred scalars
      have bounded := Integer.Image.length_bounded _ (Integer.Expr.safe_value inferred.2)
      exact canonical_bounds_valid (by have := bounded.2; unfold maxSourceLength; omega)
  | slice _ _ source =>
      have lower := Integer.Expr.infer_sound source.lowerSource.inferred scalars
      have upper := Integer.Expr.infer_sound (source.upperSource rfl).inferred scalars
      have valid := BindingInfo.boundsValid_valid (metadata _ _ source.selected) source.fixed
      have contained := (source.sliceBounds rfl).2.2.1
      dsimp only [Operand.objectBounds, Bounds.Valid]
      refine ⟨Integer.Expr.safe_value lower.2, Integer.Expr.safe_value upper.2, ?_⟩
      simp only [Integer.Interval.Contains] at lower upper
      rcases contained with null | inside
      · exact Or.inl (by omega)
      · rcases valid.2.2 with null | positive
        · exact Or.inl (by simp only [BindingInfo.objectBounds] at null; omega)
        · exact Or.inr (by simp only [BindingInfo.objectBounds] at positive; omega)

theorem value_objectBounds_firstBound {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {position : Nat} {value : Operand} {result : ValueResult} {integers : Integer.Store}
    (input : Source) (metadata : NamesBoundsValid names)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ScalarExpression.ranges scalarNames)) integers)
    (parsed : ValueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays)
      (initials := initials) (elaborating := elaborating) text names position value result) :
    (value.objectBounds names input integers).FirstBound (namesBoundCeiling names) := by
  have ceiling := namesBoundCeiling_positive names
  cases parsed with
  | literal | image => exact Or.inr ceiling
  | reference positive source selected nonzero unmasked present typed noParen =>
      rename_i after index name info
      cases dynamic : info.dynamic with
      | true => exact Or.inr (by simpa [Operand.objectBounds, present, dynamic, Bounds.canonical] using ceiling)
      | false =>
          have indices := selected_binding_bounds present
          have bounded := BindingInfo.boundsValid_firstBound (metadata _ _ present) dynamic indices.2 (by omega)
          rcases bounded with null | first
          · exact Or.inl (by simpa [Operand.objectBounds, present, dynamic] using null)
          · apply Or.inr
            simp only [Operand.objectBounds, present, Option.getD_some, dynamic, Bool.false_eq_true, ↓reduceIte]
            unfold namesBoundCeiling
            omega
  | slice noLiteral presentSlice source =>
      rename_i info lowerExpr upperExpr
      have lower := (Integer.Expr.infer_sound source.lowerSource.inferred scalars).1
      have upper := (Integer.Expr.infer_sound (source.upperSource rfl).inferred scalars).1
      have contained := (source.sliceBounds rfl).2.2.1
      by_cases null : upperExpr.evaluate integers < lowerExpr.evaluate integers
      · apply Or.inl
        change decide (upperExpr.evaluate integers < lowerExpr.evaluate integers) = true
        exact decide_eq_true null
      · apply Or.inr
        change lowerExpr.evaluate integers ≤ namesBoundCeiling names
        simp only [Integer.Interval.Contains] at lower upper
        rcases contained with impossible | inside
        · omega
        · have slot := selected_binding_bounds source.selected
          have length := (metadata.normal.typed _ _ source.selected).2 source.fixed
          have nonemptyLength : info.staticLength ≠ 0 := by
            intro zero
            rw [zero] at length
            omega
          have checked := (metadata _ _ source.selected).2.2
          have bounded := fixedBoundsValid_nonempty
            (by simpa [source.fixed, source.stringTyped] using checked) nonemptyLength
          simp only [namesBoundCeiling, maxSourceLength] at *
          omega

end Silver.Compose
