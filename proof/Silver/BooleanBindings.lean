module

public import Silver.BooleanModel
public import Silver.NamedIdentifier

@[expose] public section

/-! Active Boolean declaration metadata. Values and former predicate facts
are absent: only source name spans and object mutability enter admission. -/
namespace Silver.BooleanBindings

def maxBindings : Nat := 4096 / 13

structure Binding where
  first : Nat := 0
  after : Nat := 0
  mutable : Bool := false
  deriving DecidableEq, Repr

abbrev Environment := List Binding

def binding (names : Environment) (index : Nat) : Binding := names.getD (index - 1) {}

def lookupFrom (text : Source) (names : Environment) (first after : Nat) : Nat → Nat
  | 0 => 0
  | index + 1 =>
      if first = 0 ∨ after ≤ first then 0
      else if Named.equalName text (binding names (index + 1)).first
          (binding names (index + 1)).after first after
      then index + 1 else lookupFrom text names first after index

def lookup (text : Source) (names : Environment) (first after : Nat) : Nat :=
  lookupFrom text names first after names.length

def analysis (names : Environment) : Boolean.Analysis :=
  { initialized := fun index => decide (0 < index ∧ index ≤ names.length)
    mutable := fun index => decide (0 < index ∧ index ≤ names.length) && (binding names index).mutable }

theorem analysis_append (names : Environment) (item : Binding) :
    analysis (names ++ [item]) = (analysis names).initialize (names.length + 1) item.mutable := by
  unfold analysis Boolean.Analysis.initialize
  congr 1
  · funext index
    simp only [List.length_append, List.length_singleton]
    by_cases same : index = names.length + 1
    · simp [same]
    · simp only [same, ↓reduceIte]
      apply Bool.eq_iff_iff.mpr
      simp only [decide_eq_true_eq]
      omega
  · funext index
    simp only [List.length_append, List.length_singleton]
    by_cases same : index = names.length + 1
    · simp [same, binding, List.getD_eq_getElem?_getD]
    · simp only [same, ↓reduceIte]
      by_cases old : 0 < index ∧ index ≤ names.length
      · have remains : 0 < index ∧ index ≤ names.length + 1 := by omega
        have inside : index - 1 < names.length := by omega
        simp only [old, remains, binding,
          List.getD_eq_getElem?_getD, List.getElem?_append_left inside]
      · have outside : ¬ (0 < index ∧ index ≤ names.length + 1) := by omega
        simp only [old, outside, decide_false, Bool.false_and]

def hidesInteger (text : Source) (names : Environment) : Bool :=
  names.any fun item => Named.nameIs text item.first item.after ("integer".toList.map Char.toNat)

def ValidEnvironment (text : Source) (names : Environment) : Prop :=
  names.length ≤ maxBindings ∧ ∀ item ∈ names,
    0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1

theorem lookupFrom_bound (text : Source) (names : Environment)
    (first after index : Nat) : lookupFrom text names first after index ≤ index := by
  induction index with
  | zero => exact Nat.le_refl _
  | succ index ih =>
      simp only [lookupFrom]
      split
      · omega
      · split <;> omega

theorem lookup_bound (text : Source) (names : Environment) (first after : Nat) :
    lookup text names first after ≤ names.length := lookupFrom_bound text names first after names.length

theorem lookup_initialized {text : Source} {names : Environment} {first after : Nat}
    (found : lookup text names first after ≠ 0) :
    (analysis names).initialized (lookup text names first after) = true := by
  simp only [analysis, decide_eq_true_eq]
  exact ⟨Nat.pos_of_ne_zero found, lookup_bound text names first after⟩

theorem valid_empty (text : Source) : ValidEnvironment text [] := by
  simp [ValidEnvironment, maxBindings]

theorem valid_append {text : Source} {names : Environment} {item : Binding}
    (valid : ValidEnvironment text names) (space : names.length < maxBindings)
    (itemValid : 0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1) :
    ValidEnvironment text (names ++ [item]) := by
  refine ⟨by simp only [List.length_append, List.length_singleton]; omega, ?_⟩
  intro other present
  rcases List.mem_append.mp present with old | fresh
  · exact valid.2 other old
  · simpa only [List.mem_singleton.mp fresh] using itemValid

end Silver.BooleanBindings
