module

public import Silver.ScalarProcedureTypes
public import Silver.ScalarProcedureSyntax
public import Silver.ScalarFunctionFrame

@[expose] public section

/-! Typed persistent scalar cells. Domains are declaration domains, not values
observed during elaboration or at a caller. The same Frame/Value representation
is used by existing callable semantics and by the package capture operations. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value ScalarType)

abbrev Cell := ScalarProcedures.Cell

def cellIndex : Cell → Nat
  | .integer index | .boolean index => index

def readCell (frame : Frame) : Cell → Value
  | .integer index => .integer (frame.integers index)
  | .boolean index => .boolean (frame.booleans index)

def writeCell (frame : Frame) (cell : Cell) (value : Value) : Frame :=
  match cell, value with
  | .integer index, .integer value =>
      {frame with integers := Integer.put frame.integers index value}
  | .boolean index, .boolean value =>
      {frame with booleans := Boolean.put frame.booleans index value}
  | _, _ => frame

def CellDomain : Cell → ScalarType → Prop
  | .integer _, .integer _ | .boolean _, .boolean => True
  | _, _ => False

def CellValue : Cell → Value → Prop
  | .integer _, .integer _ | .boolean _, .boolean _ => True
  | _, _ => False

theorem contains_cell_value {cell : Cell} {domain : ScalarType} {value : Value}
    (kind : CellDomain cell domain) (within : domain.Contains value) : CellValue cell value := by
  cases cell <;> cases domain <;> cases value <;>
    simp_all [CellDomain, CellValue, ScalarType.Contains]

@[simp] theorem readCell_kind (frame : Frame) (cell : Cell) :
    CellValue cell (readCell frame cell) := by
  cases cell <;> trivial

theorem readCell_write_same {cell : Cell} {value : Value} (kind : CellValue cell value)
    (frame : Frame) : readCell (writeCell frame cell value) cell = value := by
  cases cell <;> cases value <;>
    simp_all [CellValue, readCell, writeCell, Integer.put, Boolean.put]

theorem readCell_write_other {cell other : Cell} (different : other ≠ cell)
    (value : Value) (frame : Frame) :
    readCell (writeCell frame cell value) other = readCell frame other := by
  cases cell <;> cases other <;> cases value <;>
    simp_all [readCell, writeCell, Integer.put, Boolean.put]

theorem frame_ext {left right : Frame}
    (equal : ∀ cell, readCell left cell = readCell right cell) : left = right := by
  have integers : left.integers = right.integers := by
    funext index
    exact Value.integer.inj (equal (.integer index))
  have booleans : left.booleans = right.booleans := by
    funext index
    exact Value.boolean.inj (equal (.boolean index))
  cases left
  cases right
  simp_all

theorem writeCell_read (frame : Frame) (cell : Cell) :
    writeCell frame cell (readCell frame cell) = frame := by
  apply frame_ext
  intro other
  by_cases same : other = cell
  · subst other
    exact readCell_write_same (readCell_kind frame cell) frame
  · exact readCell_write_other same _ frame

structure StateDeclaration where
  cell : Cell
  domain : ScalarType
  initial : Value
  deriving DecidableEq, Repr

def StateDeclaration.Valid (declaration : StateDeclaration) : Prop :=
  cellIndex declaration.cell ≠ 0 ∧ CellDomain declaration.cell declaration.domain ∧
    declaration.domain.Valid ∧ declaration.domain.Contains declaration.initial

abbrev StateSchema := List StateDeclaration

def StateSchema.Valid (schema : StateSchema) : Prop :=
  (schema.map StateDeclaration.cell).Nodup ∧ ∀ declaration ∈ schema, declaration.Valid

/-- Every typed store in the entire product of declared domains is covered. -/
def StateSchema.Fits (schema : StateSchema) (frame : Frame) : Prop :=
  ∀ declaration ∈ schema, declaration.domain.Contains (readCell frame declaration.cell)

def initializeFrom : Frame → StateSchema → Frame
  | frame, [] => frame
  | frame, declaration :: rest =>
      initializeFrom (writeCell frame declaration.cell declaration.initial) rest

def initialState (schema : StateSchema) : Frame :=
  initializeFrom ⟨Integer.emptyStore, Boolean.emptyStore⟩ schema

theorem initializeFrom_unchanged {schema : StateSchema} {cell : Cell}
    (absent : ∀ declaration ∈ schema, declaration.cell ≠ cell) (frame : Frame) :
    readCell (initializeFrom frame schema) cell = readCell frame cell := by
  induction schema generalizing frame with
  | nil => rfl
  | cons declaration rest ih =>
      rw [initializeFrom, ih (fun item present => absent item (by simp [present]))]
      exact readCell_write_other (Ne.symm (absent declaration (by simp))) _ frame

theorem initializeFrom_value {schema : StateSchema} (valid : schema.Valid)
    {declaration : StateDeclaration} (present : declaration ∈ schema) (frame : Frame) :
    readCell (initializeFrom frame schema) declaration.cell = declaration.initial := by
  induction schema generalizing frame with
  | nil => simp at present
  | cons first rest ih =>
      have nodup := List.nodup_cons.mp valid.1
      have firstValid := valid.2 first (by simp)
      have restValid : StateSchema.Valid rest :=
        ⟨nodup.2, fun item member => valid.2 item (by simp [member])⟩
      rcases List.mem_cons.mp present with rfl | present
      · rw [initializeFrom, initializeFrom_unchanged]
        · exact readCell_write_same (contains_cell_value firstValid.2.1 firstValid.2.2.2) frame
        · intro item member same
          exact nodup.1 (List.mem_map.mpr ⟨item, member, same⟩)
      · exact ih restValid present _

theorem initialState_fits {schema : StateSchema} (valid : schema.Valid) :
    schema.Fits (initialState schema) := by
  intro declaration present
  rw [initialState, initializeFrom_value valid present]
  exact (valid.2 declaration present).2.2.2

theorem fits_of_agreement {schema : StateSchema} {left right : Frame}
    (fits : schema.Fits left)
    (agree : ∀ declaration ∈ schema,
      readCell right declaration.cell = readCell left declaration.cell) : schema.Fits right := by
  intro declaration present
  rw [agree declaration present]
  exact fits declaration present

end Silver.Packages
