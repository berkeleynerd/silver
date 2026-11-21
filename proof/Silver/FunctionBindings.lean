module

public import Silver.IntegerIntervals
public import Silver.NamedIdentifier
public import Silver.ArrayBindings

@[expose] public section

/-! Source-span function signatures and the shared formal pool. Native table
capacities bound active prefixes; unused fixed-array cells carry no lookup meaning.
Integer/Boolean call semantics and body certificates are separate from metadata. -/
namespace Silver.FunctionBindings

def maxFunctions : Nat := 4096 / 32
def maxFormals : Nat := 4096 / 7

inductive ScalarKind | integer | boolean
  deriving DecidableEq, Repr

structure Formal where
  first : Nat
  after : Nat
  kind : ScalarKind
  bounds : Integer.Interval
  typeId : Nat := 0
  deriving DecidableEq, Repr

structure Signature where
  first : Nat
  after : Nat
  formalFirst : Nat
  count : Nat
  resultKind : ScalarKind
  resultBounds : Integer.Interval
  deriving DecidableEq, Repr

structure Metadata where
  items : List Signature := []
  parameters : List Formal := []
  deriving DecidableEq, Repr

def emptyFormal : Formal := ⟨0, 0, .integer, .empty, 0⟩
def emptySignature : Signature := ⟨0, 0, 0, 0, .integer, .empty⟩
def signature (functions : Metadata) (index : Nat) : Signature :=
  functions.items.getD (index - 1) emptySignature
def parameter (functions : Metadata) (index : Nat) : Formal :=
  functions.parameters.getD (index - 1) emptyFormal

def NameSpan (text : Source) (first after : Nat) : Prop :=
  0 < first ∧ first < after ∧ after ≤ text.length + 1

instance (text : Source) (first after : Nat) : Decidable (NameSpan text first after) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _))

def ValidFormal (text : Source) (item : Formal) : Prop :=
  NameSpan text item.first item.after ∧ item.bounds.Bounded ∧ item.bounds.lower ≤ item.bounds.upper ∧
    (item.typeId ≠ 0 → item.kind = .integer) ∧ item.typeId ≤ ArrayBindings.maxTypes

def ValidSignature (text : Source) (functions : Metadata) (item : Signature) : Prop :=
  NameSpan text item.first item.after ∧ 0 < item.count ∧ 0 < item.formalFirst ∧
    item.formalFirst ≤ functions.parameters.length ∧
    item.count ≤ functions.parameters.length - item.formalFirst + 1 ∧
    item.resultBounds.Bounded ∧ item.resultBounds.lower ≤ item.resultBounds.upper

def ValidMetadata (text : Source) (functions : Metadata) : Prop :=
  functions.items.length ≤ maxFunctions ∧ functions.parameters.length ≤ maxFormals ∧
    (∀ item ∈ functions.parameters, ValidFormal text item) ∧
    (∀ item ∈ functions.items, ValidSignature text functions item)

instance (text : Source) (item : Formal) : Decidable (ValidFormal text item) :=
  inferInstanceAs (Decidable ((_ ∧ _ ∧ _) ∧ _ ∧ _ ∧ (_ → _) ∧ _))
instance (text : Source) (functions : Metadata) (item : Signature) :
    Decidable (ValidSignature text functions item) :=
  inferInstanceAs (Decidable ((_ ∧ _ ∧ _) ∧ _ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _))
instance (text : Source) (functions : Metadata) : Decidable (ValidMetadata text functions) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ (∀ item ∈ _, _) ∧ (∀ item ∈ _, _)))

def appendFormal (functions : Metadata) (item : Formal) : Metadata :=
  { functions with parameters := functions.parameters ++ [item] }
def append (functions : Metadata) (item : Signature) : Metadata :=
  { functions with items := functions.items ++ [item] }

def lookupFrom (text : Source) (functions : Metadata) (first after : Nat) : Nat → Nat
  | 0 => 0
  | index + 1 =>
      if first = 0 ∨ after ≤ first then 0
      else if Named.equalName text (signature functions (index + 1)).first
          (signature functions (index + 1)).after first after then index + 1
      else lookupFrom text functions first after index

def lookup (text : Source) (functions : Metadata) (first after : Nat) : Nat :=
  lookupFrom text functions first after functions.items.length

theorem lookupFrom_bound (text : Source) (functions : Metadata) (first after index : Nat) :
    lookupFrom text functions first after index ≤ index := by
  induction index with
  | zero => exact Nat.le_refl _
  | succ index ih => simp only [lookupFrom]; split <;> (first | omega | split <;> omega)

theorem lookup_bound (text : Source) (functions : Metadata) (first after : Nat) :
    lookup text functions first after ≤ functions.items.length :=
  lookupFrom_bound text functions first after functions.items.length

theorem signature_mem {functions : Metadata} {index : Nat}
    (positive : 0 < index) (bound : index ≤ functions.items.length) :
    signature functions index ∈ functions.items := by
  have within : index - 1 < functions.items.length := by omega
  simp only [signature, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
  exact List.getElem_mem within

theorem parameter_mem {functions : Metadata} {index : Nat}
    (positive : 0 < index) (bound : index ≤ functions.parameters.length) :
    parameter functions index ∈ functions.parameters := by
  have within : index - 1 < functions.parameters.length := by omega
  simp only [parameter, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
  exact List.getElem_mem within

@[simp] theorem appendFormal_count (functions : Metadata) (item : Formal) :
    (appendFormal functions item).parameters.length = functions.parameters.length + 1 := by
  simp [appendFormal]
@[simp] theorem append_count (functions : Metadata) (item : Signature) :
    (append functions item).items.length = functions.items.length + 1 := by simp [append]

@[simp] theorem appendFormal_items (functions : Metadata) (item : Formal) :
    (appendFormal functions item).items = functions.items := rfl
@[simp] theorem append_parameters (functions : Metadata) (item : Signature) :
    (append functions item).parameters = functions.parameters := rfl
@[simp] theorem signature_appendFormal (functions : Metadata) (item : Formal) (index : Nat) :
    signature (appendFormal functions item) index = signature functions index := rfl

theorem parameter_prefix (functions : Metadata) (more : List Formal) (index : Nat)
    (positive : 0 < index) (bound : index ≤ functions.parameters.length) :
    parameter {functions with parameters := functions.parameters ++ more} index = parameter functions index := by
  have within : index - 1 < functions.parameters.length := by omega
  simp only [parameter, List.getD_eq_getElem?_getD, List.getElem?_append_left within]

end Silver.FunctionBindings
