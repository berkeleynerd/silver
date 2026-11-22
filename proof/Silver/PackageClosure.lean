module

public import Silver.PackageEffects

@[expose] public section

/-! Virtual state captures, with explicit global/local cell maps. These are
semantic frame operations, not generated Ada parameters or a replacement source.
Copy-in reads one frozen incoming store; copyback reads one completed local store.
The subsequent statement/call simulation must connect these operations to the
original shared-state execution and the existing closed callable definitions. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value ScalarType ArgumentsFit)

def SameKind : Cell → Cell → Prop
  | .integer _, .integer _ | .boolean _, .boolean _ => True
  | _, _ => False

theorem sameKind_of_domain {first second : Cell} {domain : ScalarType}
    (left : CellDomain first domain) (right : CellDomain second domain) : SameKind first second := by
  cases first <;> cases second <;> cases domain <;> simp_all [CellDomain, SameKind]

theorem compatible_read {source target : Cell} (kind : SameKind source target) (frame : Frame) :
    CellValue target (readCell frame source) := by
  cases source <;> cases target <;> simp_all [SameKind, CellValue, readCell]

structure Transfer where
  source : Cell
  target : Cell
  deriving DecidableEq, Repr

def Transfer.Valid (transfer : Transfer) : Prop := SameKind transfer.source transfer.target

def TransferPlanValid (plan : List Transfer) : Prop :=
  (plan.map Transfer.target).Nodup ∧ ∀ transfer ∈ plan, transfer.Valid

def copyCells (source : Frame) : Frame → List Transfer → Frame
  | destination, [] => destination
  | destination, transfer :: rest =>
      copyCells source (writeCell destination transfer.target (readCell source transfer.source)) rest

theorem copyCells_unchanged (source destination : Frame) {plan : List Transfer} {cell : Cell}
    (absent : cell ∉ plan.map Transfer.target) :
    readCell (copyCells source destination plan) cell = readCell destination cell := by
  induction plan generalizing destination with
  | nil => rfl
  | cons transfer rest ih =>
      have apart : cell ≠ transfer.target ∧ cell ∉ rest.map Transfer.target := by simpa using absent
      rw [copyCells, ih _ apart.2]
      exact readCell_write_other apart.1 _ destination

theorem copyCells_value (source destination : Frame) {plan : List Transfer}
    (valid : TransferPlanValid plan) {transfer : Transfer} (present : transfer ∈ plan) :
    readCell (copyCells source destination plan) transfer.target = readCell source transfer.source := by
  induction plan generalizing destination with
  | nil => simp at present
  | cons first rest ih =>
      have nodup := List.nodup_cons.mp valid.1
      have restValid : TransferPlanValid rest :=
        ⟨nodup.2, fun item member => valid.2 item (by simp [member])⟩
      rcases List.mem_cons.mp present with rfl | present
      · rw [copyCells, copyCells_unchanged source _ nodup.1]
        exact readCell_write_same (compatible_read (valid.2 transfer (by simp)) source) destination
      · exact ih _ restValid present

theorem copyCells_changesOnly (source destination : Frame) (plan : List Transfer) :
    ChangesOnly (plan.map Transfer.target) destination (copyCells source destination plan) :=
  fun _ absent => copyCells_unchanged source destination absent

private theorem map_filter_nodup {α β : Type} {items : List α} {key : α → β}
    (unique : (items.map key).Nodup) (predicate : α → Bool) :
    ((items.filter predicate).map key).Nodup := by
  induction items with
  | nil => simp
  | cons head rest ih =>
      have parts := List.nodup_cons.mp unique
      simp only [List.filter_cons]
      split
      · apply List.nodup_cons.mpr
        refine ⟨?_, ih parts.2⟩
        intro present
        obtain ⟨item, member, same⟩ := List.mem_map.mp present
        exact parts.1 (List.mem_map.mpr ⟨item, (List.mem_filter.mp member).1, same⟩)
      · exact ih parts.2

private theorem map_nodup_identity {α β : Type} {items : List α} {key : α → β}
    (unique : (items.map key).Nodup) {left right : α}
    (leftMem : left ∈ items) (rightMem : right ∈ items) (same : key left = key right) : left = right := by
  induction items generalizing left right with
  | nil => simp at leftMem
  | cons head rest ih =>
      have parts := List.nodup_cons.mp unique
      rcases List.mem_cons.mp leftMem with leftHead | leftTail
      · rcases List.mem_cons.mp rightMem with rightHead | rightTail
        · exact leftHead.trans rightHead.symm
        · exact False.elim (parts.1
            (List.mem_map.mpr ⟨right, rightTail, same.symm.trans (congrArg key leftHead)⟩))
      · rcases List.mem_cons.mp rightMem with rightHead | rightTail
        · exact False.elim (parts.1
            (List.mem_map.mpr ⟨left, leftTail, same.trans (congrArg key rightHead)⟩))
        · exact ih parts.2 leftTail rightTail same

structure Capture where
  globalCell : Cell
  localCell : Cell
  domain : ScalarType
  writable : Bool
  deriving DecidableEq, Repr

def Capture.Valid (capture : Capture) : Prop :=
  CellDomain capture.globalCell capture.domain ∧
    CellDomain capture.localCell capture.domain ∧ capture.domain.Valid

abbrev CaptureLayout := List Capture

def CaptureLayout.Valid (layout : CaptureLayout) : Prop :=
  (layout.map Capture.globalCell).Nodup ∧ (layout.map Capture.localCell).Nodup ∧
    ∀ capture ∈ layout, capture.Valid

def CaptureLayout.GlobalFits (layout : CaptureLayout) (frame : Frame) : Prop :=
  ∀ capture ∈ layout, capture.domain.Contains (readCell frame capture.globalCell)

def CaptureLayout.LocalFits (layout : CaptureLayout) (frame : Frame) : Prop :=
  ∀ capture ∈ layout, capture.domain.Contains (readCell frame capture.localCell)

def CaptureLayout.inputPlan (layout : CaptureLayout) : List Transfer :=
  layout.map (fun capture => ⟨capture.globalCell, capture.localCell⟩)

def CaptureLayout.outputPlan (layout : CaptureLayout) : List Transfer :=
  (layout.filter Capture.writable).map (fun capture => ⟨capture.localCell, capture.globalCell⟩)

def CaptureLayout.copyIn (layout : CaptureLayout) (globals locals : Frame) : Frame :=
  copyCells globals locals layout.inputPlan

def CaptureLayout.copyOut (layout : CaptureLayout) (locals globals : Frame) : Frame :=
  copyCells locals globals layout.outputPlan

def CaptureLayout.values (layout : CaptureLayout) (globals : Frame) : List Value :=
  layout.map (fun capture => readCell globals capture.globalCell)

def CaptureLayout.domains (layout : CaptureLayout) : List ScalarType :=
  layout.map Capture.domain

/-- A writable capture is an implicit in-out scalar, including when the
original body only writes it. Initialized package state supplies its input. -/
def Capture.formal (capture : Capture) : ScalarProcedures.Formal :=
  ⟨if capture.writable then .inputOutput else .input, capture.domain⟩

theorem CaptureLayout.inputPlan_valid {layout : CaptureLayout} (valid : layout.Valid) :
    TransferPlanValid layout.inputPlan := by
  refine ⟨?_, ?_⟩
  · simpa [inputPlan, List.map_map, Function.comp_def] using valid.2.1
  · intro transfer present
    obtain ⟨capture, member, rfl⟩ := List.mem_map.mp present
    have kinds := valid.2.2 capture member
    exact sameKind_of_domain kinds.1 kinds.2.1

theorem CaptureLayout.outputPlan_valid {layout : CaptureLayout} (valid : layout.Valid) :
    TransferPlanValid layout.outputPlan := by
  refine ⟨?_, ?_⟩
  · simpa [outputPlan, List.map_map, Function.comp_def] using
      map_filter_nodup valid.1 Capture.writable
  · intro transfer present
    obtain ⟨capture, member, rfl⟩ := List.mem_map.mp present
    have kinds := valid.2.2 capture (List.mem_filter.mp member).1
    exact sameKind_of_domain kinds.2.1 kinds.1

theorem CaptureLayout.copyIn_value {layout : CaptureLayout} (valid : layout.Valid)
    {capture : Capture} (present : capture ∈ layout) (globals locals : Frame) :
    readCell (layout.copyIn globals locals) capture.localCell = readCell globals capture.globalCell :=
  copyCells_value globals locals (layout.inputPlan_valid valid) (List.mem_map.mpr ⟨capture, present, rfl⟩)

theorem CaptureLayout.copyIn_fits {layout : CaptureLayout} (valid : layout.Valid)
    {globals : Frame} (fitting : layout.GlobalFits globals) (locals : Frame) :
    layout.LocalFits (layout.copyIn globals locals) := by
  intro capture present
  rw [layout.copyIn_value valid present]
  exact fitting capture present

theorem CaptureLayout.values_fit {layout : CaptureLayout} {globals : Frame}
    (fitting : layout.GlobalFits globals) : ArgumentsFit layout.domains (layout.values globals) := by
  induction layout with
  | nil => trivial
  | cons capture rest ih =>
      exact ⟨fitting capture (by simp), ih (fun item member => fitting item (by simp [member]))⟩

theorem CaptureLayout.copyOut_value {layout : CaptureLayout} (valid : layout.Valid)
    {capture : Capture} (present : capture ∈ layout) (written : capture.writable = true)
    (locals globals : Frame) :
    readCell (layout.copyOut locals globals) capture.globalCell = readCell locals capture.localCell :=
  copyCells_value locals globals (layout.outputPlan_valid valid)
    (List.mem_map.mpr ⟨capture, List.mem_filter.mpr ⟨present, written⟩, rfl⟩)

theorem CaptureLayout.copyOut_readonly {layout : CaptureLayout} (valid : layout.Valid)
    {capture : Capture} (present : capture ∈ layout) (readonly : capture.writable = false)
    (locals globals : Frame) :
    readCell (layout.copyOut locals globals) capture.globalCell = readCell globals capture.globalCell := by
  apply copyCells_unchanged
  simp only [outputPlan, List.map_map, Function.comp_def]
  intro member
  obtain ⟨other, member, same⟩ := List.mem_map.mp member
  have inside := List.mem_filter.mp member
  have equal := map_nodup_identity valid.1 inside.1 present same
  subst other
  simp [readonly] at inside

theorem CaptureLayout.copyOut_fits {layout : CaptureLayout} (valid : layout.Valid)
    {globals locals : Frame} (incoming : layout.GlobalFits globals)
    (returned : layout.LocalFits locals) : layout.GlobalFits (layout.copyOut locals globals) := by
  intro capture present
  cases written : capture.writable with
  | false => rw [layout.copyOut_readonly valid present written]; exact incoming capture present
  | true => rw [layout.copyOut_value valid present written]; exact returned capture present

theorem CaptureLayout.copyOut_changesOnly (layout : CaptureLayout) (locals globals : Frame) :
    ChangesOnly ((layout.filter Capture.writable).map Capture.globalCell)
      globals (layout.copyOut locals globals) := by
  simpa [copyOut, outputPlan, List.map_map, Function.comp_def] using
    copyCells_changesOnly locals globals layout.outputPlan

end Silver.Packages
