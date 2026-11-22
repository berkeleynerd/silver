module

public import Silver.NamedIdentifier
public import Silver.Names
public import Silver.IntegerIntervals
public import Silver.QualifiedNames

@[expose] public section

/-! Static Integer subtype names are declaration metadata, separate from
runtime scalar identities. Only operation-hiding flags enter a body context. -/
namespace Silver.IntegerSubtypes

def maxBindings : Nat := 4096 / 32

structure Binding where
  first : Nat := 0
  after : Nat := 0
  bounds : Integer.Interval := .empty
  qualifierFirst : Nat := 0
  qualifierAfter : Nat := 0
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
  trueHidden : Bool := false
  falseHidden : Bool := false
  deriving DecidableEq, Repr

def binding (environment : Environment) (index : Nat) : Binding :=
  environment.items.getD (index - 1) {}

def lookupFrom (text : Source) (environment : Environment) (first after index : Nat)
    (qualifierFirst qualifierAfter : Nat := 0) : Nat :=
  match index with
  | 0 => 0
  | index + 1 =>
      if first = 0 ∨ after ≤ first then 0
      else if Named.equalName text (binding environment (index + 1)).first
          (binding environment (index + 1)).after first after &&
          QualifiedNames.qualifierMatches text (binding environment (index + 1)).qualifierFirst
            (binding environment (index + 1)).qualifierAfter qualifierFirst qualifierAfter
      then index + 1 else lookupFrom text environment first after index qualifierFirst qualifierAfter

def lookup (text : Source) (environment : Environment) (first after : Nat)
    (qualifierFirst qualifierAfter : Nat := 0) : Nat :=
  lookupFrom text environment first after environment.items.length qualifierFirst qualifierAfter

def append (text : Source) (environment : Environment) (item : Binding) : Environment :=
  { items := environment.items ++ [item]
    hiddenCalls := if item.qualifierFirst = 0 then environment.hiddenCalls.add text item.first item.after
      else environment.hiddenCalls
    trueHidden := environment.trueHidden || (decide (item.qualifierFirst = 0) &&
      Named.nameIs text item.first item.after ("true".toList.map Char.toNat))
    falseHidden := environment.falseHidden || (decide (item.qualifierFirst = 0) &&
      Named.nameIs text item.first item.after ("false".toList.map Char.toNat)) }

def ValidEnvironment (text : Source) (environment : Environment) : Prop :=
  environment.items.length ≤ maxBindings ∧ ∀ item ∈ environment.items,
    0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧
    item.bounds.Bounded ∧ item.bounds.lower ≤ item.bounds.upper ∧
      QualifiedNames.ValidSpan text item.qualifierFirst item.qualifierAfter

/-- The same native call-hiding table contains subtype names and completed
function names. Extra spans are supplied by the declaration proof; the default
retains the subtype-only initialization statement. -/
def HidingCorrect (text : Source) (environment : Environment)
    (otherNames : List (Nat × Nat) := []) : Prop :=
  ∀ operation, environment.hiddenCalls.get operation =
    (environment.items.any (fun item => decide (item.qualifierFirst = 0) &&
      Named.nameIs text item.first item.after (operation.name.toList.map Char.toNat)) ||
     otherNames.any (fun item => Named.nameIs text item.1 item.2
      (operation.name.toList.map Char.toNat)))

theorem lookupFrom_bound (text : Source) (environment : Environment)
    (first after index : Nat) (qualifierFirst qualifierAfter : Nat := 0) :
    lookupFrom text environment first after index qualifierFirst qualifierAfter ≤ index := by
  induction index with
  | zero => exact Nat.le_refl _
  | succ index ih =>
      simp only [lookupFrom]
      split
      · omega
      · split <;> omega

theorem lookup_bound (text : Source) (environment : Environment) (first after : Nat)
    (qualifierFirst qualifierAfter : Nat := 0) :
    lookup text environment first after qualifierFirst qualifierAfter ≤ environment.items.length :=
  lookupFrom_bound text environment first after environment.items.length qualifierFirst qualifierAfter

theorem valid_empty (text : Source) : ValidEnvironment text {} := by
  simp [ValidEnvironment, maxBindings]

theorem valid_append {text : Source} {environment : Environment} {item : Binding}
    (valid : ValidEnvironment text environment)
    (space : environment.items.length < maxBindings)
    (itemValid : 0 < item.first ∧ item.first < item.after ∧ item.after ≤ text.length + 1 ∧
      item.bounds.Bounded ∧ item.bounds.lower ≤ item.bounds.upper ∧
        QualifiedNames.ValidSpan text item.qualifierFirst item.qualifierAfter) :
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

theorem hiding_append {text : Source} {environment : Environment} {otherNames : List (Nat × Nat)}
    (correct : HidingCorrect text environment otherNames) (item : Binding) :
    HidingCorrect text (append text environment item) otherNames := by
  intro operation
  by_cases localName : item.qualifierFirst = 0
  · have appended := congrArg (fun flag => flag || Named.nameIs text item.first item.after
      (operation.name.toList.map Char.toNat)) (correct operation)
    cases operation <;>
      simpa [append, localName, CallHiding.add, CallHiding.get, List.any_append,
        Bool.or_assoc, Bool.or_left_comm, Bool.or_comm] using appended
  · have unchanged := correct operation
    cases operation <;> simpa [append, localName, CallHiding.get, List.any_append] using unchanged


theorem hiding_add_other {text : Source} {environment : Environment} {otherNames : List (Nat × Nat)}
    (correct : HidingCorrect text environment otherNames) (first after : Nat) :
    HidingCorrect text
      {environment with hiddenCalls := environment.hiddenCalls.add text first after}
      (otherNames ++ [(first, after)]) := by
  intro operation
  have appended := congrArg (fun flag => flag || Named.nameIs text first after
    (operation.name.toList.map Char.toNat)) (correct operation)
  cases operation <;>
    simpa [CallHiding.add, CallHiding.get, List.any_append, Bool.or_assoc] using appended


def LiteralHidingCorrect (text : Source) (environment : Environment) : Prop :=
  environment.trueHidden = environment.items.any
      (fun item => decide (item.qualifierFirst = 0) &&
        Named.nameIs text item.first item.after ("true".toList.map Char.toNat)) ∧
    environment.falseHidden = environment.items.any
      (fun item => decide (item.qualifierFirst = 0) &&
        Named.nameIs text item.first item.after ("false".toList.map Char.toNat))

theorem literal_hiding_empty (text : Source) : LiteralHidingCorrect text {} := ⟨rfl, rfl⟩

theorem literal_hiding_append {text : Source} {environment : Environment}
    (correct : LiteralHidingCorrect text environment) (item : Binding) :
    LiteralHidingCorrect text (append text environment item) := by
  simp only [LiteralHidingCorrect, append, List.any_append, List.any_cons, List.any_nil,
    Bool.or_false, correct.1, correct.2, and_self]

/-- Imported subtype names are all selected by package qualification. They do
not introduce unqualified operation or Boolean-literal hiding. -/
def qualify (environment : Environment) (first after : Nat) : Environment :=
  { items := environment.items.map fun item => { item with qualifierFirst := first, qualifierAfter := after }
    hiddenCalls := {}, trueHidden := false, falseHidden := false }

theorem qualify_valid {text : Source} {environment : Environment} {first after : Nat}
    (valid : ValidEnvironment text environment) (span : QualifiedNames.ValidSpan text first after) :
    ValidEnvironment text (qualify environment first after) := by
  refine ⟨by simpa [qualify] using valid.1, ?_⟩
  intro item present
  obtain ⟨original, member, rfl⟩ := List.mem_map.mp present
  have old := valid.2 original member
  exact ⟨old.1, old.2.1, old.2.2.1, old.2.2.2.1, old.2.2.2.2.1, span⟩

theorem qualify_hiding (text : Source) (environment : Environment) (first after : Nat)
    (positive : first ≠ 0) : HidingCorrect text (qualify environment first after) := by
  intro operation
  cases operation <;> simp [qualify, CallHiding.get, List.any_map, positive]

theorem qualify_literal_hiding (text : Source) (environment : Environment) (first after : Nat)
    (positive : first ≠ 0) : LiteralHidingCorrect text (qualify environment first after) := by
  simp [LiteralHidingCorrect, qualify, List.any_map, positive]

end Silver.IntegerSubtypes
