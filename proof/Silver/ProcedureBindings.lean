module

public import Silver.FunctionBindings

@[expose] public section

/-! Source-span procedure signatures and the shared formal pool. Native table
capacities bound active prefixes; unused fixed-array cells carry no lookup meaning.
Mode-aware Integer/Boolean call semantics and body certificates are separate from metadata. -/
namespace Silver.ProcedureBindings

def maxProcedures : Nat := 4096 / 32
def maxFormals : Nat := 4096 / 7

abbrev ScalarKind := FunctionBindings.ScalarKind

inductive Mode | input | output | inputOutput
  deriving DecidableEq, Repr

structure Formal where
  first : Nat
  after : Nat
  kind : ScalarKind
  bounds : Integer.Interval
  mode : Mode
  deriving DecidableEq, Repr

structure Signature where
  first : Nat
  after : Nat
  formalFirst : Nat
  count : Nat
  deriving DecidableEq, Repr

structure Metadata where
  items : List Signature := []
  parameters : List Formal := []
  deriving DecidableEq, Repr

def emptyFormal : Formal := ⟨0, 0, .integer, .empty, .input⟩
def emptySignature : Signature := ⟨0, 0, 0, 0⟩
def signature (procedures : Metadata) (index : Nat) : Signature :=
  procedures.items.getD (index - 1) emptySignature
def parameter (procedures : Metadata) (index : Nat) : Formal :=
  procedures.parameters.getD (index - 1) emptyFormal

def NameSpan (text : Source) (first after : Nat) : Prop :=
  0 < first ∧ first < after ∧ after ≤ text.length + 1

instance (text : Source) (first after : Nat) : Decidable (NameSpan text first after) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _))

def ValidFormal (text : Source) (item : Formal) : Prop :=
  NameSpan text item.first item.after ∧ item.bounds.Bounded ∧ item.bounds.lower ≤ item.bounds.upper

def ValidSignature (text : Source) (procedures : Metadata) (item : Signature) : Prop :=
  NameSpan text item.first item.after ∧ 0 < item.count ∧ 0 < item.formalFirst ∧
    item.formalFirst ≤ procedures.parameters.length ∧
    item.count ≤ procedures.parameters.length - item.formalFirst + 1

def ValidMetadata (text : Source) (procedures : Metadata) : Prop :=
  procedures.items.length ≤ maxProcedures ∧ procedures.parameters.length ≤ maxFormals ∧
    (∀ item ∈ procedures.parameters, ValidFormal text item) ∧
    (∀ item ∈ procedures.items, ValidSignature text procedures item)

instance (text : Source) (item : Formal) : Decidable (ValidFormal text item) :=
  inferInstanceAs (Decidable ((_ ∧ _ ∧ _) ∧ _ ∧ _))
instance (text : Source) (procedures : Metadata) (item : Signature) :
    Decidable (ValidSignature text procedures item) :=
  inferInstanceAs (Decidable ((_ ∧ _ ∧ _) ∧ _ ∧ _ ∧ _ ∧ _))
instance (text : Source) (procedures : Metadata) : Decidable (ValidMetadata text procedures) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ (∀ item ∈ _, _) ∧ (∀ item ∈ _, _)))

def appendFormal (procedures : Metadata) (item : Formal) : Metadata :=
  { procedures with parameters := procedures.parameters ++ [item] }
def append (procedures : Metadata) (item : Signature) : Metadata :=
  { procedures with items := procedures.items ++ [item] }

def lookupFrom (text : Source) (procedures : Metadata) (first after : Nat) : Nat → Nat
  | 0 => 0
  | index + 1 =>
      if first = 0 ∨ after ≤ first then 0
      else if Named.equalName text (signature procedures (index + 1)).first
          (signature procedures (index + 1)).after first after then index + 1
      else lookupFrom text procedures first after index

def lookup (text : Source) (procedures : Metadata) (first after : Nat) : Nat :=
  lookupFrom text procedures first after procedures.items.length

theorem lookupFrom_bound (text : Source) (procedures : Metadata) (first after index : Nat) :
    lookupFrom text procedures first after index ≤ index := by
  induction index with
  | zero => exact Nat.le_refl _
  | succ index ih => simp only [lookupFrom]; split <;> (first | omega | split <;> omega)

theorem lookup_bound (text : Source) (procedures : Metadata) (first after : Nat) :
    lookup text procedures first after ≤ procedures.items.length :=
  lookupFrom_bound text procedures first after procedures.items.length

theorem signature_mem {procedures : Metadata} {index : Nat}
    (positive : 0 < index) (bound : index ≤ procedures.items.length) :
    signature procedures index ∈ procedures.items := by
  have within : index - 1 < procedures.items.length := by omega
  simp only [signature, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
  exact List.getElem_mem within

theorem parameter_mem {procedures : Metadata} {index : Nat}
    (positive : 0 < index) (bound : index ≤ procedures.parameters.length) :
    parameter procedures index ∈ procedures.parameters := by
  have within : index - 1 < procedures.parameters.length := by omega
  simp only [parameter, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
  exact List.getElem_mem within

@[simp] theorem appendFormal_count (procedures : Metadata) (item : Formal) :
    (appendFormal procedures item).parameters.length = procedures.parameters.length + 1 := by
  simp [appendFormal]
@[simp] theorem append_count (procedures : Metadata) (item : Signature) :
    (append procedures item).items.length = procedures.items.length + 1 := by simp [append]

@[simp] theorem appendFormal_items (procedures : Metadata) (item : Formal) :
    (appendFormal procedures item).items = procedures.items := rfl
@[simp] theorem append_parameters (procedures : Metadata) (item : Signature) :
    (append procedures item).parameters = procedures.parameters := rfl
@[simp] theorem signature_appendFormal (procedures : Metadata) (item : Formal) (index : Nat) :
    signature (appendFormal procedures item) index = signature procedures index := rfl

theorem parameter_prefix (procedures : Metadata) (more : List Formal) (index : Nat)
    (positive : 0 < index) (bound : index ≤ procedures.parameters.length) :
    parameter {procedures with parameters := procedures.parameters ++ more} index = parameter procedures index := by
  have within : index - 1 < procedures.parameters.length := by omega
  simp only [parameter, List.getD_eq_getElem?_getD, List.getElem?_append_left within]

end Silver.ProcedureBindings
