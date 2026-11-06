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

/-- Initialization records only an object's identity and mutability. Its
Boolean value and the predicate which produced it are not analysis facts. -/
def Analysis.initialize (analysis : Analysis) (index : Nat) (mutable : Bool) : Analysis :=
  { initialized := fun observed => if observed = index then true else analysis.initialized observed
    mutable := fun observed => if observed = index then mutable else analysis.mutable observed }

@[simp] theorem Analysis.initialize_initialized (analysis : Analysis) (index : Nat) (mutable : Bool) :
    (analysis.initialize index mutable).initialized index = true := by simp [Analysis.initialize]

@[simp] theorem Analysis.initialize_mutable (analysis : Analysis) (index : Nat) (mutable : Bool) :
    (analysis.initialize index mutable).mutable index = mutable := by simp [Analysis.initialize]

theorem Analysis.initialize_other (analysis : Analysis) (index : Nat) (mutable : Bool)
    (observed : Nat) (different : observed ≠ index) :
    (analysis.initialize index mutable).initialized observed = analysis.initialized observed ∧
      (analysis.initialize index mutable).mutable observed = analysis.mutable observed := by
  simp [Analysis.initialize, different]

theorem Analysis.initialize_preserves (analysis : Analysis) (index : Nat) (mutable : Bool)
    (observed : Nat) (ready : analysis.initialized observed = true) :
    (analysis.initialize index mutable).initialized observed = true := by
  simp [Analysis.initialize, ready]

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
