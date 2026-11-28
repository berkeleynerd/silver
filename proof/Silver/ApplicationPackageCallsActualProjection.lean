module

public import Silver.ApplicationPackageCallsActualInterpretation

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

/-- The source checks the active parameter table window before it enters
nonempty actual and alias loops. Its fixed array allocation bounds that window. -/
structure ActualWindow (item : PackageBindings.Routine) (capacity : Nat) : Prop where
  first : 0 < item.formalFirst
  last : item.formalFirst + item.count - 1 ≤ capacity

theorem actualWindow_of_guard {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    (positive : 0 < item.count) (parameters : info.parameters.length ≤ PackageBindings.maxFormals)
    (guard : ¬(item.count > 0 ∧ (item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
      item.count > info.parameters.length - item.formalFirst + 1))) :
    ActualWindow item PackageBindings.maxFormals := by
  constructor <;> omega

private theorem namedFold_origin (calls : ApplicationPackageCalls.Calls)
    (args : Source × PackageBindings.Metadata × Nat × Nat) (slots : List Nat) (start : Nat) :
    let selected := slots.foldl (fun previous index => namedStep calls args index previous) start
    selected = start ∨ selected ∈ slots := by
  induction slots generalizing start with
  | nil => exact Or.inl rfl
  | cons head rest ih =>
      dsimp only [List.foldl_cons]
      rcases ih (namedStep calls args head start) with selected | member
      · rw [selected]
        unfold namedStep
        split
        · exact Or.inr (List.mem_cons_self ..)
        · exact Or.inl rfl
      · exact Or.inr (List.mem_cons_of_mem _ member)

theorem namedSlot_bound (calls : ApplicationPackageCalls.Calls) (text : Source)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (first after capacity : Nat)
    (window : ActualWindow item capacity) : namedSlot calls text info item first after ≤ capacity := by
  have origin := namedFold_origin calls (text, info, first, after) (formalSlots item) 0
  change namedSlot calls text info item first after = 0 ∨
    namedSlot calls text info item first after ∈ formalSlots item at origin
  rcases origin with zero | member
  · omega
  · obtain ⟨offset, inside, selected⟩ := List.mem_map.mp member
    have bounded := List.mem_range.mp inside
    have := window.last
    omega

def frameOf (locals : Locals) : ActualFrame :=
  {cursor := locals .number "cursor_at", named := locals .truth "named",
   actuals := locals .packageActuals "actuals", seen := locals .packageSeen "seen",
   result := locals .appCall "result", callWrites := locals .stateSet "call_writes"}

def selectedAssociation (calls : ApplicationPackageCalls.Calls) (text : Source)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (ordinal : Nat)
    (frame : ActualFrame) : Option (Nat × Bool × Nat) :=
  actualAssociation calls text info item ordinal frame

def selectedFields (locals : Locals) : Nat × Bool × Nat :=
  (locals .number "slot", locals .truth "named", locals .number "cursor_at")

theorem association_projection (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (positive : 0 < (locals .routine "item").count) :
    (associationLocals calls locals).map selectedFields =
      selectedAssociation calls (locals .source "text") (locals .metadata "info")
        (locals .routine "item") (locals .number "ordinal") (frameOf locals) := by
  unfold associationLocals selectedAssociation actualAssociation frameOf
  simp only [namedRange_of_positive _ positive]
  split
  · simp (disch := decide) [selectedFields, namedSlot, namedStep]
  · split <;> simp (disch := decide) [selectedFields]


structure PayloadView where
  frame : ActualFrame
  slot : Nat
  parameter : PackageBindings.Formal
  following : Nat

def payloadView (locals : Locals) : PayloadView :=
  ⟨frameOf locals, locals .number "slot", locals .formal "parameter", locals .number "following"⟩

def payloadModel (calls : ApplicationPackageCalls.Calls) (text : Source) (context : Predicate.ParseContext)
    (input : ApplicationPackages.ApplicationScan) (info : PackageBindings.Metadata) (slot : Nat)
    (frame : ActualFrame) : Option PayloadView :=
  if slot = 0 ∨ frame.seen.getD (slot - 1) false = true then none else
    let parameter := info.parameterAt slot
    let original := {frame.actual slot with first := frame.cursor}
    let (following, actual) := actualPayload calls text context input parameter info frame.cursor original
    if following ≤ frame.cursor then none else
      let stored := {frame with
        actuals := frame.actuals.set (slot - 1) actual
        seen := frame.seen.set (slot - 1) true}
      some ⟨stored, slot, parameter, following⟩

theorem actual_offset_lt_length {slot length : Nat} (positive : slot ≠ 0) (bounded : slot ≤ length) :
    slot - 1 < length := by omega

theorem payload_projection (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (bounded : locals .number "slot" ≤ (locals .packageActuals "actuals").length) :
    (payloadLocals calls locals).map payloadView =
      payloadModel calls (locals .source "text") (locals .parseContext "context") (locals .appScan "input")
        (locals .metadata "info") (locals .number "slot") (frameOf locals) := by
  by_cases unavailable : locals .number "slot" = 0 ∨
      (locals .packageSeen "seen").getD (locals .number "slot" - 1) false = true
  · simp only [payloadModel, payloadLocals, frameOf, unavailable, ↓reduceIte, Option.map_none]
  · have positive : locals .number "slot" ≠ 0 := fun zero => unavailable (Or.inl zero)
    have inside := actual_offset_lt_length positive bounded
    by_cases input : ((locals .metadata "info").parameterAt (locals .number "slot")).mode = .input <;>
      by_cases stop : (actualPayload calls (locals .source "text") (locals .parseContext "context")
        (locals .appScan "input") ((locals .metadata "info").parameterAt (locals .number "slot"))
        (locals .metadata "info") (locals .number "cursor_at")
        {((frameOf locals).actual (locals .number "slot")) with first := locals .number "cursor_at"}).1 ≤
        locals .number "cursor_at" <;>
      simp only [actualPayload, input, ↓reduceIte] at stop <;>
      simp (disch := first | decide | assumption)
        [payloadModel, payloadLocals, frameOf, ActualFrame.actual, actualPayload, input,
         writeActual, List.set_set, List.getD_eq_getElem?_getD, stop] at unavailable ⊢ <;>
      simp_all [payloadView, frameOf]
    all_goals simp (disch := first | decide | assumption) [Locals.set]

def finishModel (calls : ApplicationPackageCalls.Calls) (text : Source) (context : Predicate.ParseContext)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (ordinal : Nat)
    (view : PayloadView) : Option ActualFrame :=
  let frame := view.frame
  let actual := {frame.actual view.slot with after := view.following}
  let actual := if view.parameter.mode ≠ .output then {actual with
      reads := calls.stateReads text context info frame.cursor view.following} else actual
  let result := {frame.result with result := {frame.result.result with
    reads := PackageBindings.stateUnion frame.result.result.reads actual.reads}}
  let endToken := if ordinal = item.count then Compose.ShellToken.symbol ")" else .symbol ","
  let finish := calls.take text view.following endToken
  if finish = 0 then none else
    some {frame with
      cursor := finish
      actuals := frame.actuals.set (view.slot - 1) actual
      result := result
      callWrites := markState frame.callWrites actual.writtenState}

theorem finish_projection (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (inside : locals .number "slot" - 1 < (locals .packageActuals "actuals").length) :
    (finishActualLocals calls locals).map frameOf =
      finishModel calls (locals .source "text") (locals .parseContext "context") (locals .metadata "info")
        (locals .routine "item") (locals .number "ordinal") (payloadView locals) := by
  dsimp only [finishActualLocals, finishModel, payloadView, frameOf, ActualFrame.actual, markState]
  repeat' (split <;> try simp (disch := first | decide | assumption | omega)
    [*, writeActual, frameOf, List.set_set])
  all_goals rfl

end Silver.ApplicationPackageCalls.Native.Call
