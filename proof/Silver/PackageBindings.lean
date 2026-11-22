module

public import Silver.ApplicationUnitsExpressions
public import Silver.ProcedureBindings
public import Silver.PackageEffects

@[expose] public section

/-! Native metadata values retain original spans, nominal subtype identities,
completion order and packed effects. Active table prefixes are represented by
lists; unused native cells have no lookup meaning. Effect arrays retain every
fixed-capacity bit because Within inspects their inactive suffix as well. -/
namespace Silver.PackageBindings

abbrev Text := ApplicationUnits.Native.SourceValue
abbrev ScalarKind := FunctionBindings.ScalarKind
abbrev Mode := ProcedureBindings.Mode
abbrev UnitKind := ApplicationUnits.UnitKind
abbrev UnitSpan := ApplicationUnits.Span

def maxStates : Nat := maxSourceLength / 7
def maxExports : Nat := maxSourceLength / 12
def maxRoutines : Nat := maxSourceLength / 32
def maxFormals : Nat := maxSourceLength / 7

structure NameSpan where
  first : Nat := 0
  after : Nat := 0
  deriving DecidableEq, Repr

inductive ExportKind | integerSubtype | integerConstant | booleanConstant
  deriving DecidableEq, Repr

structure ExportDeclaration where
  name : NameSpan := {}
  kind : ExportKind := .integerSubtype
  bounds : Integer.Interval := .empty
  typeName : NameSpan := {}
  typeIdentity : Nat := 1
  initializerFirst : Nat := 0
  initializerAfter : Nat := 0
  booleanValue : Bool := false
  deriving DecidableEq, Repr

structure StateDeclaration where
  name : NameSpan := {}
  kind : ScalarKind := .integer
  typeName : NameSpan := {}
  typeIdentity : Nat := 1
  declaredBounds : Integer.Interval := .empty
  initialBounds : Integer.Interval := .empty
  initializerFirst : Nat := 0
  initializerAfter : Nat := 0
  booleanInitial : Bool := false
  deriving DecidableEq, Repr

abbrev StateSet := List Bool

def emptyStateSet : StateSet := List.replicate maxStates false

def StateSet.get (set : StateSet) (identity : Nat) : Bool := set.getD (identity - 1) false

def stateUnion (left right : StateSet) : StateSet :=
  (List.range maxStates).map fun index => StateSet.get left (index + 1) || StateSet.get right (index + 1)

def within (effect : StateSet) (count : Nat) : Bool :=
  (List.range maxStates).all fun index => if index + 1 > count then !(StateSet.get effect (index + 1)) else true

structure Formal where
  specName : NameSpan := {}
  bodyName : NameSpan := {}
  specTypeName : NameSpan := {}
  bodyTypeName : NameSpan := {}
  kind : ScalarKind := .integer
  bounds : Integer.Interval := .empty
  typeIdentity : Nat := 1
  mode : Mode := .input
  deriving DecidableEq, Repr

inductive RoutineKind | function | procedure
  deriving DecidableEq, Repr

structure Routine where
  kind : RoutineKind := .procedure
  specName : NameSpan := {}
  bodyName : NameSpan := {}
  specFirst : Nat := 0
  specAfter : Nat := 0
  bodyFirst : Nat := 0
  bodyAfter : Nat := 0
  formalFirst : Nat := 0
  count : Nat := 0
  resultKind : ScalarKind := .integer
  resultBounds : Integer.Interval := .empty
  resultTypeIdentity : Nat := 1
  specResultName : NameSpan := {}
  bodyResultName : NameSpan := {}
  mayRead : StateSet := emptyStateSet
  mayWrite : StateSet := emptyStateSet
  assigned : Bool := false
  deriving DecidableEq, Repr

structure Metadata where
  nameFirst : Nat := 0
  nameAfter : Nat := 0
  bodyNameFirst : Nat := 0
  bodyNameAfter : Nat := 0
  units : UnitKind → UnitSpan := fun _ => ⟨1, 1⟩
  exports : List ExportDeclaration := []
  states : List StateDeclaration := []
  routines : List Routine := []
  completed : Nat := 0
  parameters : List Formal := []
  assigned : Bool := false

def Metadata.exportAt (info : Metadata) (index : Nat) : ExportDeclaration := info.exports.getD (index - 1) {}
def Metadata.stateAt (info : Metadata) (index : Nat) : StateDeclaration := info.states.getD (index - 1) {}
def Metadata.routineAt (info : Metadata) (index : Nat) : Routine := info.routines.getD (index - 1) {}
def Metadata.parameterAt (info : Metadata) (index : Nat) : Formal := info.parameters.getD (index - 1) {}

def isIdentifier (name : Text) : Bool :=
  decide (0 < name.bytes.length ∧ name.bytes.length ≤ maxSourceLength) &&
  Named.letter (name.bytes.getD 0 0) && decide (name.bytes.getD (name.bytes.length - 1) 0 ≠ 95) &&
  (List.range name.bytes.length).all fun index =>
    identifierCharacter (name.bytes.getD index 0) &&
    (if name.bytes.getD index 0 = 95 then
      decide (0 < index) && decide (name.bytes.getD (index - 1) 0 ≠ 95) else true)

def validName (text : Text) (name : NameSpan) : Bool :=
  decide (text.first = 1 ∧ 0 < text.bytes.length ∧ text.bytes.length ≤ maxSourceLength ∧
    0 < name.first ∧ name.first < name.after ∧ name.after ≤ text.bytes.length + 1) &&
  isIdentifier (text.slice name.first (name.after - 1))

def inUnit (name : NameSpan) (unit : UnitSpan) : Bool :=
  decide (unit.first ≤ name.first ∧ name.first < name.after ∧ name.after ≤ unit.after)

def sameName (text : Text) (left right : NameSpan) : Bool :=
  validName text left && validName text right &&
    Named.equalName text.bytes left.first left.after right.first right.after

def Metadata.unitLayout (info : Metadata) (length : Nat) : Prop :=
  (info.units .packageSpecification).first = 1 ∧
  (info.units .packageSpecification).first < (info.units .packageSpecification).after ∧
  (info.units .packageBody).first = (info.units .packageSpecification).after ∧
  (info.units .packageBody).first < (info.units .packageBody).after ∧
  (info.units .mainBody).first = (info.units .packageBody).after ∧
  (info.units .mainBody).first < (info.units .mainBody).after ∧
  (info.units .mainBody).after = length + 1

instance (info : Metadata) (length : Nat) : Decidable (info.unitLayout length) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _ ∧ _))

def exportValid (text : Text) (info : Metadata) (index : Nat) : Bool :=
  let item := info.exportAt index
  validName text item.name && inUnit item.name (info.units .packageSpecification) && !item.bounds.isEmpty &&
    (if item.kind = .integerSubtype then decide (item.typeIdentity = index + 1) else true)

def stateValid (text : Text) (info : Metadata) (index : Nat) : Bool :=
  let item := info.stateAt index
  validName text item.name && inUnit item.name (info.units .packageBody) &&
    !item.declaredBounds.isEmpty && !item.initialBounds.isEmpty &&
    decide (item.initialBounds.lower = item.initialBounds.upper ∧
      item.declaredBounds.lower ≤ item.initialBounds.lower ∧
      item.initialBounds.upper ≤ item.declaredBounds.upper ∧
      (info.units .packageBody).first ≤ item.initializerFirst ∧
      item.initializerFirst < item.initializerAfter ∧ item.initializerAfter ≤ (info.units .packageBody).after)

def parameterValid (text : Text) (info : Metadata) (index : Nat) : Bool :=
  let item := info.parameterAt index
  validName text item.specName && inUnit item.specName (info.units .packageSpecification) && !item.bounds.isEmpty

def routineValid (text : Text) (info : Metadata) (index : Nat) : Bool :=
  let item := info.routineAt index
  validName text item.specName && inUnit item.specName (info.units .packageSpecification) &&
    decide ((info.units .packageSpecification).first ≤ item.specFirst ∧ item.specFirst ≤ item.specName.first ∧
      item.specName.after < item.specAfter ∧ item.specAfter ≤ (info.units .packageSpecification).after) &&
    (if item.count = 0 then decide (item.formalFirst = 0) else
      decide (0 < item.formalFirst ∧ item.formalFirst ≤ info.parameters.length ∧
        item.count ≤ info.parameters.length - item.formalFirst + 1)) &&
    within item.mayRead info.states.length && within item.mayWrite info.states.length &&
    (if item.kind = .function then !item.resultBounds.isEmpty && decide (item.mayWrite = emptyStateSet) else true) &&
    (if index ≤ info.completed then
      inUnit item.bodyName (info.units .packageBody) && sameName text item.specName item.bodyName &&
      decide ((info.units .packageBody).first ≤ item.bodyFirst ∧ item.bodyFirst ≤ item.bodyName.first ∧
        item.bodyName.after < item.bodyAfter ∧ item.bodyAfter ≤ (info.units .packageBody).after) &&
      (if 0 < item.count then (List.range item.count).all fun offset =>
        let formal := info.parameterAt (item.formalFirst + offset)
        inUnit formal.bodyName (info.units .packageBody) && sameName text formal.specName formal.bodyName
      else true)
    else true)

def validMetadata (text : Text) (info : Metadata) : Bool :=
  decide (text.first = 1 ∧ 0 < text.bytes.length ∧ text.bytes.length ≤ maxSourceLength ∧
    info.unitLayout text.bytes.length) &&
  validName text ⟨info.nameFirst, info.nameAfter⟩ &&
  inUnit ⟨info.nameFirst, info.nameAfter⟩ (info.units .packageSpecification) &&
  (if info.bodyNameFirst = 0 then decide (info.bodyNameAfter = 0 ∧ info.states.length = 0 ∧ info.completed = 0)
   else inUnit ⟨info.bodyNameFirst, info.bodyNameAfter⟩ (info.units .packageBody) &&
     sameName text ⟨info.nameFirst, info.nameAfter⟩ ⟨info.bodyNameFirst, info.bodyNameAfter⟩) &&
  decide (info.completed ≤ info.routines.length) &&
  (List.range info.exports.length).all (fun index => exportValid text info (index + 1)) &&
  (List.range info.states.length).all (fun index => stateValid text info (index + 1)) &&
  (List.range info.parameters.length).all (fun index => parameterValid text info (index + 1)) &&
  (List.range info.routines.length).all (fun index => routineValid text info (index + 1))

def completeMetadata (text : Text) (info : Metadata) : Bool :=
  validMetadata text info && decide (0 < info.bodyNameFirst ∧ info.completed = info.routines.length)

def lookupFrom (text : Text) (name : NameSpan) (itemName : Nat → NameSpan) : Nat → Nat
  | 0 => 0
  | index + 1 => if sameName text (itemName (index + 1)) name then index + 1
      else lookupFrom text name itemName index

def exportLookupModel (text : Text) (info : Metadata) (name : NameSpan) (limit : Nat) : Nat :=
  lookupFrom text name (fun index => (info.exportAt index).name) limit

def stateLookupModel (text : Text) (info : Metadata) (name : NameSpan) (limit : Nat) : Nat :=
  lookupFrom text name (fun index => (info.stateAt index).name) limit

def routineLookupModel (text : Text) (info : Metadata) (name : NameSpan) (limit : Nat) : Nat :=
  lookupFrom text name (fun index => (info.routineAt index).specName) limit

def lookupExport (text : Text) (info : Metadata) (name : NameSpan) : Nat :=
  exportLookupModel text info name info.exports.length

def lookupState (text : Text) (info : Metadata) (name : NameSpan) : Nat :=
  stateLookupModel text info name info.states.length

def lookupRoutine (text : Text) (info : Metadata) (name : NameSpan) (completedOnly : Bool) : Nat :=
  routineLookupModel text info name (if completedOnly then info.completed else info.routines.length)

theorem lookupFrom_bound (text : Text) (name : NameSpan) (itemName : Nat → NameSpan) (limit : Nat) :
    lookupFrom text name itemName limit ≤ limit := by
  induction limit with
  | zero => exact Nat.le_refl 0
  | succ limit ih => simp only [lookupFrom]; split <;> omega

theorem lookupFrom_found {text : Text} {name : NameSpan} {itemName : Nat → NameSpan}
    {limit : Nat} (found : lookupFrom text name itemName limit ≠ 0) :
    sameName text (itemName (lookupFrom text name itemName limit)) name = true := by
  induction limit with
  | zero => exact False.elim (found rfl)
  | succ limit ih =>
      simp only [lookupFrom] at found ⊢
      split <;> simp_all

/-- Native subtype facts, without any declaration or grammar validity premise. -/
def NameSpan.Typed (name : NameSpan) : Prop := name.first ≤ maxSourceLength + 1 ∧ name.after ≤ maxSourceLength + 1

def ExportDeclaration.Typed (item : ExportDeclaration) : Prop :=
  item.name.Typed ∧ item.typeName.Typed ∧ item.bounds.Bounded ∧ item.typeIdentity ≤ maxExports + 1 ∧
    item.initializerFirst ≤ maxSourceLength + 1 ∧ item.initializerAfter ≤ maxSourceLength + 1

def StateDeclaration.Typed (item : StateDeclaration) : Prop :=
  item.name.Typed ∧ item.typeName.Typed ∧ item.declaredBounds.Bounded ∧ item.initialBounds.Bounded ∧
    item.typeIdentity ≤ maxExports + 1 ∧ item.initializerFirst ≤ maxSourceLength + 1 ∧
    item.initializerAfter ≤ maxSourceLength + 1

def Formal.Typed (item : Formal) : Prop :=
  item.specName.Typed ∧ item.bodyName.Typed ∧ item.specTypeName.Typed ∧ item.bodyTypeName.Typed ∧
    item.bounds.Bounded ∧ item.typeIdentity ≤ maxExports + 1

def Routine.Typed (item : Routine) : Prop :=
  item.specName.Typed ∧ item.bodyName.Typed ∧ item.specResultName.Typed ∧ item.bodyResultName.Typed ∧
    item.specFirst ≤ maxSourceLength + 1 ∧ item.specAfter ≤ maxSourceLength + 1 ∧
    item.bodyFirst ≤ maxSourceLength + 1 ∧ item.bodyAfter ≤ maxSourceLength + 1 ∧
    item.formalFirst ≤ maxFormals ∧ item.count ≤ maxFormals ∧ item.resultBounds.Bounded ∧
    item.resultTypeIdentity ≤ maxExports + 1 ∧ item.mayRead.length = maxStates ∧ item.mayWrite.length = maxStates

def Metadata.Typed (info : Metadata) : Prop :=
  (NameSpan.mk info.nameFirst info.nameAfter).Typed ∧
    (NameSpan.mk info.bodyNameFirst info.bodyNameAfter).Typed ∧
    (∀ kind, 1 ≤ (info.units kind).first ∧ (info.units kind).first ≤ maxSourceLength + 1 ∧
      1 ≤ (info.units kind).after ∧ (info.units kind).after ≤ maxSourceLength + 1) ∧
    info.exports.length ≤ maxExports ∧ info.states.length ≤ maxStates ∧ info.routines.length ≤ maxRoutines ∧
    info.completed ≤ maxRoutines ∧ info.parameters.length ≤ maxFormals ∧
    (∀ item ∈ info.exports, item.Typed) ∧ (∀ item ∈ info.states, item.Typed) ∧
    (∀ item ∈ info.routines, item.Typed) ∧ (∀ item ∈ info.parameters, item.Typed)

/-- Declaration identity uses its original state-order index, independent of
where a visible native frame happens to store the declaration at a given phase. -/
def StateDeclaration.cell (item : StateDeclaration) (identity : Nat) : Packages.Cell :=
  match item.kind with | .integer => .integer identity | .boolean => .boolean identity

def StateDeclaration.semantic (item : StateDeclaration) (identity : Nat) : Packages.StateDeclaration :=
  match item.kind with
  | .integer => ⟨.integer identity, .integer item.declaredBounds, .integer item.initialBounds.lower⟩
  | .boolean => ⟨.boolean identity, .boolean, .boolean item.booleanInitial⟩

def Metadata.stateSchema (info : Metadata) : Packages.StateSchema :=
  (List.range info.states.length).map fun index => (info.stateAt (index + 1)).semantic (index + 1)

def Metadata.effectCells (info : Metadata) (set : StateSet) : List Packages.Cell :=
  ((List.range info.states.length).filter fun index => StateSet.get set (index + 1)).map fun index =>
    (info.stateAt (index + 1)).cell (index + 1)

def Routine.effects (info : Metadata) (routine : Routine) : Packages.Effects :=
  ⟨info.effectCells routine.mayRead, info.effectCells routine.mayWrite⟩

end Silver.PackageBindings
