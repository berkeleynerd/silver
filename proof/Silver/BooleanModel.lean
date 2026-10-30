module

public import Silver.IntegerIntervals

@[expose] public section

/-! Boolean objects have their own namespace and concrete store. Admission
records initialization and mutability, never the condition which produced a
stored value. Consequently a later read cannot restore old path facts. -/
namespace Silver.Boolean

abbrev Store := Nat → Bool

def emptyStore : Store := fun _ => false

def put (store : Store) (index : Nat) (value : Bool) : Store :=
  fun observed => if observed = index then value else store observed

structure Analysis where
  initialized : Nat → Bool := fun _ => false
  mutable : Nat → Bool := fun _ => false

def Analysis.canWrite (analysis : Analysis) (index : Nat) : Bool :=
  analysis.initialized index && analysis.mutable index

inductive Operator
  | and | or | xor
  deriving DecidableEq, Repr

def Operator.evaluate : Operator → Bool → Bool → Bool
  | .and, left, right => left && right
  | .or, left, right => left || right
  | .xor, left, right => left != right

@[simp] theorem put_same (store : Store) (index : Nat) (value : Bool) :
    put store index value index = value := by simp [put]

theorem put_other (store : Store) (index : Nat) (value : Bool) (observed : Nat)
    (different : observed ≠ index) : put store index value observed = store observed := by
  simp [put, different]

theorem canWrite_initialized {analysis : Analysis} {index : Nat}
    (writable : analysis.canWrite index = true) : analysis.initialized index = true :=
  (Bool.and_eq_true_iff.mp writable).1

theorem canWrite_mutable {analysis : Analysis} {index : Nat}
    (writable : analysis.canWrite index = true) : analysis.mutable index = true :=
  (Bool.and_eq_true_iff.mp writable).2

end Silver.Boolean
