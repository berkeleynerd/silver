module

public import Silver.ImageModelTheorySpelling
public import Silver.ImageModelWideNormalization

@[expose] public section
namespace Silver.ImageModel.JSON

inductive WideField (index : Nat) (previous pending : Bool) (span : FieldSpan) (normalized : Value) (outgoing : Bool) : Prop
  | mk (before : ScannerNative.Whitespace span.leading)
      (value : WideValue previous pending span.value span.body normalized outgoing)
      (legal : ScannerNative.FieldLegal index span.value)
      (after : ScannerNative.Whitespace span.trailing)

/-- Exactly the eight top-level theory positions are represented when starting
at index zero. These constructors contain only syntax/domain subderivations. -/
inductive WideFields : Nat → Bool → Bool → List FieldSpan → List Value → Prop
  | last (previous pending : Bool) (span : FieldSpan) (normalized : Value)
      (field : WideField 7 previous pending span normalized false) :
      WideFields 7 previous pending [span] [normalized]
  | more (index : Nat) (previous pending outgoing : Bool) (span : FieldSpan) (normalized : Value)
      (spans : List FieldSpan) (restNormalized : List Value) (bounded : index < 7)
      (field : WideField index previous pending span normalized outgoing)
      (tail : WideFields (index + 1) false outgoing spans restNormalized) :
      WideFields index previous pending (span :: spans) (normalized :: restNormalized)

theorem WideFields.nonempty {index : Nat} {previous pending : Bool} {spans : List FieldSpan} {normalized : List Value}
    (normal : WideFields index previous pending spans normalized) : spans ≠ [] ∧ normalized ≠ [] := by
  cases normal <;> simp

theorem WideFields.length {index : Nat} {previous pending : Bool} {spans : List FieldSpan} {normalized : List Value}
    (normal : WideFields index previous pending spans normalized) : spans.length + index = 8 ∧ normalized.length = spans.length := by
  induction normal with
  | last => simp
  | more _ _ _ _ _ _ _ _ bounded field tail ih => simp only [List.length_cons]; omega

end Silver.ImageModel.JSON
