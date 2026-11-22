module

public import Silver.BooleanModel
public import Silver.NamedIdentifier
public import Silver.QualifiedNames

@[expose] public section

/-! Boolean metadata retains exact package-elaboration values separately from
body analysis. A known value never stores or recreates predicate refinements. -/
namespace Silver.BooleanBindings

def maxBindings : Nat := 4096 / 13

structure Binding where
  first : Nat := 0
  after : Nat := 0
  mutable : Bool := false
  qualifierFirst : Nat := 0
  qualifierAfter : Nat := 0
  known : Bool := false
  value : Bool := false
  deriving DecidableEq, Repr

abbrev Environment := List Binding

def binding (names : Environment) (index : Nat) : Binding := names.getD (index - 1) {}

def lookupFrom (text : Source) (names : Environment) (first after index : Nat)
    (qualifierFirst qualifierAfter : Nat := 0) : Nat :=
  match index with
  | 0 => 0
  | index + 1 =>
      if first = 0 ∨ after ≤ first then 0
      else if Named.equalName text (binding names (index + 1)).first
          (binding names (index + 1)).after first after &&
          QualifiedNames.qualifierMatches text (binding names (index + 1)).qualifierFirst
            (binding names (index + 1)).qualifierAfter qualifierFirst qualifierAfter
      then index + 1 else lookupFrom text names first after index qualifierFirst qualifierAfter

def lookup (text : Source) (names : Environment) (first after : Nat)
    (qualifierFirst qualifierAfter : Nat := 0) : Nat :=
  lookupFrom text names first after names.length qualifierFirst qualifierAfter

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
  names.any fun item => decide (item.qualifierFirst = 0) &&
    Named.nameIs text item.first item.after ("integer".toList.map Char.toNat)

def ValidEnvironment (text : Source) (names : Environment) : Prop :=
  names.length ≤ maxBindings ∧ ∀ item ∈ names,
    0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧
      QualifiedNames.ValidSpan text item.qualifierFirst item.qualifierAfter

theorem lookupFrom_bound (text : Source) (names : Environment)
    (first after index : Nat) (qualifierFirst qualifierAfter : Nat := 0) :
    lookupFrom text names first after index qualifierFirst qualifierAfter ≤ index := by
  induction index with
  | zero => exact Nat.le_refl _
  | succ index ih =>
      simp only [lookupFrom]
      split
      · omega
      · split <;> omega

theorem lookup_bound (text : Source) (names : Environment) (first after : Nat)
    (qualifierFirst qualifierAfter : Nat := 0) :
    lookup text names first after qualifierFirst qualifierAfter ≤ names.length :=
  lookupFrom_bound text names first after names.length qualifierFirst qualifierAfter

theorem lookup_initialized {text : Source} {names : Environment} {first after : Nat}
    {qualifierFirst qualifierAfter : Nat}
    (found : lookup text names first after qualifierFirst qualifierAfter ≠ 0) :
    (analysis names).initialized (lookup text names first after qualifierFirst qualifierAfter) = true := by
  simp only [analysis, decide_eq_true_eq]
  exact ⟨Nat.pos_of_ne_zero found, lookup_bound text names first after qualifierFirst qualifierAfter⟩

theorem valid_empty (text : Source) : ValidEnvironment text [] := by
  simp [ValidEnvironment, maxBindings]

theorem valid_append {text : Source} {names : Environment} {item : Binding}
    (valid : ValidEnvironment text names) (space : names.length < maxBindings)
    (itemValid : 0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧
      QualifiedNames.ValidSpan text item.qualifierFirst item.qualifierAfter) :
    ValidEnvironment text (names ++ [item]) := by
  refine ⟨by simp only [List.length_append, List.length_singleton]; omega, ?_⟩
  intro other present
  rcases List.mem_append.mp present with old | fresh
  · exact valid.2 other old
  · simpa only [List.mem_singleton.mp fresh] using itemValid

/-- Only initialized, explicitly known entries constrain elaboration values. -/
def KnownFits (names : Environment) (values : Boolean.Store) : Prop :=
  ∀ index, 0 < index → index ≤ names.length → (binding names index).known = true →
    values index = (binding names index).value

def initialValues (names : Environment) : Boolean.Store := fun index => (binding names index).value

theorem initialValues_fits (names : Environment) : KnownFits names (initialValues names) := by
  intro index positive bounded known
  rfl

def bodyBinding (item : Binding) : Binding :=
  {item with known := if item.mutable then false else item.known}

def bodyEnvironment (names : Environment) : Environment := names.map bodyBinding

theorem bodyEnvironment_length (names : Environment) :
    (bodyEnvironment names).length = names.length := by simp [bodyEnvironment]

theorem bodyEnvironment_binding (names : Environment) (index : Nat) :
    binding (bodyEnvironment names) index = bodyBinding (binding names index) := by
  simp only [bodyEnvironment, binding, List.getD_eq_getElem?_getD, List.getElem?_map]
  cases names[index - 1]? <;> simp [bodyBinding]

theorem bodyEnvironment_analysis (names : Environment) :
    analysis (bodyEnvironment names) = analysis names := by
  simp only [analysis, bodyEnvironment_length, bodyEnvironment_binding, bodyBinding]

theorem bodyEnvironment_valid {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) : ValidEnvironment text (bodyEnvironment names) := by
  refine ⟨by simpa only [bodyEnvironment_length] using valid.1, ?_⟩
  intro item present
  obtain ⟨original, member, rfl⟩ := List.mem_map.mp present
  exact valid.2 original member

theorem bodyBinding_mutable_unknown (item : Binding) (mutable : item.mutable = true) :
    (bodyBinding item).known = false := by simp [bodyBinding, mutable]

theorem bodyEnvironment_known_fits {names : Environment} {values : Boolean.Store}
    (fits : KnownFits names values) : KnownFits (bodyEnvironment names) values := by
  intro index positive bounded known
  rw [bodyEnvironment_binding] at known ⊢
  simp only [bodyBinding] at known ⊢
  have old : (binding names index).known = true := by
    split at known
    · contradiction
    · exact known
  exact fits index positive (by simpa only [bodyEnvironment_length] using bounded) old

end Silver.BooleanBindings
