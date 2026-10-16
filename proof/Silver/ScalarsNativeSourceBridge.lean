module

public import Silver.ScalarsNativeSourceChecks

@[expose] public section

/-! The exact Ada helper bodies determine all interval operations. Source
interpretation is the documented frontend premise; mathematical safety follows
from the checked equations, not from an assumed operation-correctness premise.
Native GNATprove separately establishes the signed-wide implementation checks. -/
namespace Silver.Integer.NativeSourceBridge

structure InterpretedSource (calls : Native.Calls) : Prop where
  definitions : Native.Equations calls

theorem interpreted_functions (calls : Native.Calls) (source : InterpretedSource calls)
    (fn : Native.Function) : calls fn = fn.eval :=
  Native.interpreted_functions calls source.definitions fn

theorem add_sound (calls : Native.Calls) (source : InterpretedSource calls)
    {left right : Interval} {a b : Int}
    (accepted : (calls .add left right).safe = true)
    (ha : left.Contains a) (hb : right.Contains b) :
    (calls .add left right).bounds.Contains (a + b) ∧ InRange (a + b) := by
  rw [interpreted_functions calls source .add] at accepted ⊢
  exact checkedAdd_sound accepted ha hb

theorem subtract_sound (calls : Native.Calls) (source : InterpretedSource calls)
    {left right : Interval} {a b : Int}
    (accepted : (calls .subtract left right).safe = true)
    (ha : left.Contains a) (hb : right.Contains b) :
    (calls .subtract left right).bounds.Contains (a - b) ∧ InRange (a - b) := by
  rw [interpreted_functions calls source .subtract] at accepted ⊢
  exact checkedSubtract_sound accepted ha hb

theorem multiply_sound (calls : Native.Calls) (source : InterpretedSource calls)
    {left right : Interval} {a b : Int}
    (accepted : (calls .multiply left right).safe = true)
    (ha : left.Contains a) (hb : right.Contains b) :
    (calls .multiply left right).bounds.Contains (a * b) ∧ InRange (a * b) := by
  rw [interpreted_functions calls source .multiply] at accepted ⊢
  exact checkedMultiply_sound accepted ha hb

theorem negate_sound (calls : Native.Calls) (source : InterpretedSource calls)
    {bounds : Interval} {a : Int}
    (accepted : (calls .negate bounds).safe = true) (ha : bounds.Contains a) :
    (calls .negate bounds).bounds.Contains (-a) ∧ InRange (-a) := by
  rw [interpreted_functions calls source .negate] at accepted ⊢
  exact checkedNegate_sound accepted ha

theorem actual_source_correspondence : NativeSourceChecks.CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ fn, calls fn = fn.eval :=
  ⟨NativeSourceChecks.checked_source, interpreted_functions⟩

theorem model_interpreted : InterpretedSource Native.Function.eval := ⟨Native.model_equations⟩

end Silver.Integer.NativeSourceBridge
