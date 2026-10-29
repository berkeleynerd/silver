module

public import Silver.NamedIdentifier
public import Silver.Names
public import Silver.IntegerIntervals

@[expose] public section

/-! Static Integer subtype names are declaration metadata, separate from
runtime scalar identities. Only operation-hiding flags enter a body context. -/
namespace Silver.IntegerSubtypes

def maxBindings : Nat := 4096 / 32

structure Binding where
  first : Nat := 0
  after : Nat := 0
  bounds : Integer.Interval := .empty
  deriving DecidableEq, Repr

structure CallHiding where
  output : Bool := false
  partialOutput : Bool := false
  argument : Bool := false
  validity : Bool := false
  reject : Bool := false
  deriving DecidableEq, Repr

def CallHiding.get (flags : CallHiding) : Names.Operation → Bool
  | .output => flags.output | .partialOutput => flags.partialOutput
  | .argument => flags.argument | .validity => flags.validity | .reject => flags.reject

def CallHiding.add (flags : CallHiding) (text : Source) (first after : Nat) : CallHiding :=
  let matchesOperation (operation : Names.Operation) :=
    Named.nameIs text first after (operation.name.toList.map Char.toNat)
  { output := flags.output || matchesOperation .output
    partialOutput := flags.partialOutput || matchesOperation .partialOutput
    argument := flags.argument || matchesOperation .argument
    validity := flags.validity || matchesOperation .validity
    reject := flags.reject || matchesOperation .reject }

structure Environment where
  items : List Binding := []
  hiddenCalls : CallHiding := {}
  deriving DecidableEq, Repr

def binding (environment : Environment) (index : Nat) : Binding :=
  environment.items.getD (index - 1) {}

def lookupFrom (text : Source) (environment : Environment) (first after : Nat) : Nat → Nat
  | 0 => 0
  | index + 1 =>
      if first = 0 ∨ after ≤ first then 0
      else if Named.equalName text (binding environment (index + 1)).first
          (binding environment (index + 1)).after first after
      then index + 1 else lookupFrom text environment first after index

def lookup (text : Source) (environment : Environment) (first after : Nat) : Nat :=
  lookupFrom text environment first after environment.items.length

def append (text : Source) (environment : Environment) (item : Binding) : Environment :=
  { items := environment.items ++ [item]
    hiddenCalls := environment.hiddenCalls.add text item.first item.after }

def ValidEnvironment (text : Source) (environment : Environment) : Prop :=
  environment.items.length ≤ maxBindings ∧ ∀ item ∈ environment.items,
    0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧
    item.bounds.Bounded ∧ item.bounds.lower ≤ item.bounds.upper

def HidingCorrect (text : Source) (environment : Environment) : Prop :=
  ∀ operation, environment.hiddenCalls.get operation =
    environment.items.any (fun item => Named.nameIs text item.first item.after
      (operation.name.toList.map Char.toNat))

theorem lookupFrom_bound (text : Source) (environment : Environment)
    (first after index : Nat) : lookupFrom text environment first after index ≤ index := by
  induction index with
  | zero => exact Nat.le_refl _
  | succ index ih =>
      simp only [lookupFrom]
      split
      · omega
      · split <;> omega

theorem lookup_bound (text : Source) (environment : Environment) (first after : Nat) :
    lookup text environment first after ≤ environment.items.length :=
  lookupFrom_bound text environment first after environment.items.length

theorem valid_empty (text : Source) : ValidEnvironment text {} := by
  simp [ValidEnvironment, maxBindings]

theorem valid_append {text : Source} {environment : Environment} {item : Binding}
    (valid : ValidEnvironment text environment)
    (space : environment.items.length < maxBindings)
    (itemValid : 0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧
      item.bounds.Bounded ∧ item.bounds.lower ≤ item.bounds.upper) :
    ValidEnvironment text (append text environment item) := by
  refine ⟨by dsimp only [append]; simp only [List.length_append, List.length_singleton]; omega, ?_⟩
  intro other present
  rcases List.mem_append.mp present with old | fresh
  · exact valid.2 other old
  · have equal : other = item := List.mem_singleton.mp fresh
    simpa only [equal] using itemValid

theorem hiding_empty (text : Source) : HidingCorrect text {} := by
  intro operation
  cases operation <;> rfl

theorem hiding_append {text : Source} {environment : Environment}
    (correct : HidingCorrect text environment) (item : Binding) :
    HidingCorrect text (append text environment item) := by
  intro operation
  have appended := congrArg (fun flag => flag || Named.nameIs text item.first item.after
    (operation.name.toList.map Char.toNat)) (correct operation)
  cases operation <;>
    simpa [append, CallHiding.add, CallHiding.get, List.any_append] using appended


end Silver.IntegerSubtypes
