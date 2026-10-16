module

public import Silver.IntegerImageLength

@[expose] public section

/-! A concrete refinement of the producer's weak String Image abstraction.
The generated size parameter is a bound, not a claim of exact length for every
possible parameter. In particular, size zero still produces an empty string.
The exact Integer theorem is instantiated only at the producer's size 12.
Connecting this interpretation to the actual typed producer input remains a
separate source-correspondence obligation. -/
namespace Silver.Integer.Image.Refinement

structure StringValue where
  data : List Nat
  deriving DecidableEq

def StringValue.first (_value : StringValue) : Int := 1
def StringValue.last (value : StringValue) : Int := value.data.length
def StringValue.length (value : StringValue) : Int := value.data.length
def StringValue.wellFormed (value : StringValue) : Prop :=
  value.data.length ≤ 2147483647

def toString (image : List Nat) (size : Int) : StringValue :=
  ⟨image.take (min size.toNat 2147483647)⟩

theorem first_axiom (image : List Nat) (size : Int) :
    (toString image size).first = 1 := rfl

theorem upper_bound_axiom (image : List Nat) (size : Int) (nonnegative : 0 ≤ size) :
    (toString image size).length ≤ size := by
  have cast := Int.toNat_of_nonneg nonnegative
  simp only [toString, StringValue.length, List.length_take]
  omega

theorem well_formed_axiom (image : List Nat) (size : Int) :
    (toString image size).wellFormed := by
  simp only [toString, StringValue.wellFormed, List.length_take]
  omega

theorem zero_size (image : List Nat) : (toString image 0).data = [] := by
  simp [toString]

theorem integer_image_preserved (value : Int) (bounded : InRange value) :
    (toString (bytes value) 12).data = bytes value := by
  have length := (length_bounded value bounded).2
  simp only [toString]
  apply List.take_of_length_le
  change (bytes value).length ≤ 12
  omega

theorem integer_length_refinement (value : Int) (bounded : InRange value) :
    (toString (bytes value) 12).length = nativeLength value := by
  unfold StringValue.length
  rw [integer_image_preserved value bounded]
  exact (nativeLength_exact value bounded).symm

/-- The weak producer axioms and exact fixed-size theorem have a common model.
The additional fact is justified by the predefined operation's semantics;
it is not a consequence of the weak axioms alone. -/
theorem consistent_refinement :
    (∀ image size, (toString image size).first = 1) ∧
    (∀ image size, 0 ≤ size → (toString image size).length ≤ size) ∧
    (∀ image size, (toString image size).wellFormed) ∧
    (∀ value, InRange value → (toString (bytes value) 12).length = nativeLength value) :=
  ⟨first_axiom, upper_bound_axiom, well_formed_axiom, integer_length_refinement⟩

end Silver.Integer.Image.Refinement
