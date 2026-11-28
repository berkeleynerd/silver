module

public import Silver.ApplicationPackageImportedFrame

@[expose] public section

namespace Silver.ApplicationPackageFrames.Native
open ApplicationNative Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- The native ascending filter writes an active prefix and returns immediately
on a duplicate local. Its loop theorem preserves the exact arbitrary backing
rows; no source-admission premise is used to justify compaction. -/
theorem forValues_compact {α : Type} (selected outer : α → Bool) (item : Nat → α)
    (state : Nat → List α → Locals) (binder : String)
    (body : Locals → (Locals → ParserState) → ParserState) (failure : ParserState)
    (equation : ∀ kept rows index next,
      body ((state kept rows).set .number binder index) next =
        if selected (item index) then
          if outer (item index) then next ((state kept rows).set .number binder index)
          else failure
        else next ((state (kept + 1) (rows.set kept (item index))).set .number binder index))
    (indices : List Nat) (kept : Nat) (rows : List α) (previous : Nat)
    (next : Locals → ParserState)
    (stable : ∀ current index, next (current.set .number binder index) = next current) :
    forValues (resultType := .state) body binder indices ((state kept rows).set .number binder previous) next =
      match compactRows selected outer kept rows (indices.map item) with
      | none => failure
      | some (count, storage) => next (state count storage) := by
  induction indices generalizing kept rows previous with
  | nil => simp only [forValues, List.map_nil, compactRows, stable]
  | cons index rest ih =>
      rw [forValues, Locals.set_shadow, equation]
      simp only [List.map_cons, compactRows]
      by_cases matched : selected (item index) = true
      · by_cases removable : outer (item index) = true
        · simp only [matched, removable, ↓reduceIte]
          exact ih kept rows index
        · simp [matched, removable]
      · simpa [matched] using ih (kept + 1) (rows.set kept (item index)) index

def scalarFilterState (locals : Locals) (kept : Nat)
    (rows : ScalarExpression.Environment) : Locals :=
  (locals.set .state "result" {(locals .state "result") with scalarNames := rows}).set
    .number "scalars_kept" kept

def scalarSelected (calls : Calls Function) (locals : Locals)
    (row : ScalarExpression.Binding) : Bool :=
  decide (row.qualifierFirst = 0) && calls _ .equalName (locals .source "text")
    (locals .nameSpan "name").first (locals .nameSpan "name").after row.first row.after

def scalarOuter (calls : Calls Function) (locals : Locals)
    (row : ScalarExpression.Binding) : Bool :=
  calls _ .outerDeclaration (locals .metadata "info") ⟨row.first, row.after⟩

theorem scalar_filter_body (calls : Calls Function) (locals : Locals) (kept : Nat)
    (rows : ScalarExpression.Environment) (index : Nat) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls
      ((scalarFilterState locals kept rows).set .number "i" index) next
      (filterBody .stateScalarNames .scalar .scalarFirst .scalarAfter .scalarQualifierFirst "scalars_kept") =
      let row := ScalarExpression.binding (locals .state "frame").scalarNames index
      if scalarSelected calls locals row then
        if scalarOuter calls locals row then
          next ((scalarFilterState locals kept rows).set .number "i" index)
        else invalidState
      else next ((scalarFilterState locals (kept + 1) (rows.set kept row)).set .number "i" index) := by
  dsimp only [filterBody, Command.eval, Place.set, Place.expression, Expr.eval, Field.get,
    Field.set, Index.get, Index.set, frame, name, text, info, result,
    scalarSelected, scalarOuter, scalarFilterState]
  cases outerValue : calls _ .outerDeclaration (locals .metadata "info")
    ⟨(ScalarExpression.binding (locals .state "frame").scalarNames index).first,
      (ScalarExpression.binding (locals .state "frame").scalarNames index).after⟩ <;>
    simp [Locals.set, outerValue]
  all_goals simp only [Locals.set_commute_types _ .number .state _ _ _ _ (by decide),
    Locals.set_commute_names _ .number .number "i" "scalars_kept" _ _ (by decide),
    Locals.set_shadow]

theorem enumerateRows {α : Type} (rows : List α) (fallback : α) :
    (((List.range rows.length).map (1 + ·)).map
      (fun index => rows.getD (index - 1) fallback)) = rows := by
  rw [List.map_map]
  apply List.ext_getElem (by simp)
  intro index _ rightBound
  simp only [List.getElem_map, List.getElem_range, Function.comp_def,
    Nat.add_sub_cancel_left]
  exact (List.getElem_eq_getD fallback).symm

theorem scalar_filter_loop (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (filterLoop .stateScalarNames .scalarCount .scalar .scalarFirst .scalarAfter
        .scalarQualifierFirst "scalars_kept") =
      match compactRows (scalarSelected calls locals) (scalarOuter calls locals)
        (locals .number "scalars_kept") (locals .state "result").scalarNames
        (locals .state "frame").scalarNames with
      | none => invalidState
      | some (count, rows) => next (scalarFilterState locals count rows) := by
  have initial :
      (scalarFilterState locals (locals .number "scalars_kept")
        (locals .state "result").scalarNames).set .number "i" (locals .number "i") = locals := by
    change ((locals.set .state "result" (locals .state "result")).set .number "scalars_kept"
      (locals .number "scalars_kept")).set .number "i" (locals .number "i") = locals
    simp only [Locals.set_unchanged]
  have restore (count : Nat) (rows : ScalarExpression.Environment) :
      (scalarFilterState locals count rows).set .number "i" (locals .number "i") =
        scalarFilterState locals count rows := by
    unfold scalarFilterState
    rw [Locals.set_commute_names _ .number .number "scalars_kept" "i" _ _ (by decide),
      Locals.set_commute_types _ .state .number "result" "i" _ _ (by decide),
      Locals.set_unchanged]
  have equation := forValues_compact (scalarSelected calls locals) (scalarOuter calls locals)
    (ScalarExpression.binding (locals .state "frame").scalarNames)
    (scalarFilterState locals) "i"
    (fun current continuation => Command.eval (resultType := .state) calls current continuation
      (filterBody .stateScalarNames .scalar .scalarFirst .scalarAfter .scalarQualifierFirst "scalars_kept"))
    invalidState (scalar_filter_body calls locals)
    ((List.range (locals .state "frame").scalarNames.length).map (1 + ·))
    (locals .number "scalars_kept") (locals .state "result").scalarNames (locals .number "i")
    (fun updated => next (updated.set .number "i" (locals .number "i")))
    (by intros; simp only [Locals.set_shadow])
  rw [initial] at equation
  have enumerated :
      (((List.range (locals .state "frame").scalarNames.length).map (1 + ·)).map
        (ScalarExpression.binding (locals .state "frame").scalarNames)) =
        (locals .state "frame").scalarNames :=
    enumerateRows (locals .state "frame").scalarNames ScalarExpression.emptyBinding
  rw [enumerated] at equation
  simp only [restore] at equation
  change forValues (resultType := .state)
    (fun current continuation => Command.eval calls current continuation
      (filterBody .stateScalarNames .scalar .scalarFirst .scalarAfter .scalarQualifierFirst "scalars_kept"))
    "i" ((List.range ((locals .state "frame").scalarNames.length + 1 - 1)).map (1 + ·)) locals
    (fun updated => next (updated.set .number "i" (locals .number "i"))) = _
  simp only [Nat.add_sub_cancel]
  rw [equation]
  cases compactRows (scalarSelected calls locals) (scalarOuter calls locals)
    (locals .number "scalars_kept") (locals .state "result").scalarNames
    (locals .state "frame").scalarNames with
  | none => rfl
  | some output => cases output; rfl

def booleanFilterState (locals : Locals) (kept : Nat)
    (rows : BooleanBindings.Environment) : Locals :=
  (locals.set .state "result" {(locals .state "result") with booleanNames := rows}).set
    .number "booleans_kept" kept

def booleanSelected (calls : Calls Function) (locals : Locals)
    (row : BooleanBindings.Binding) : Bool :=
  decide (row.qualifierFirst = 0) && calls _ .equalName (locals .source "text")
    (locals .nameSpan "name").first (locals .nameSpan "name").after row.first row.after

def booleanOuter (calls : Calls Function) (locals : Locals)
    (row : BooleanBindings.Binding) : Bool :=
  calls _ .outerDeclaration (locals .metadata "info") ⟨row.first, row.after⟩

theorem boolean_filter_body (calls : Calls Function) (locals : Locals) (kept : Nat)
    (rows : BooleanBindings.Environment) (index : Nat) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls
      ((booleanFilterState locals kept rows).set .number "i" index) next
      (filterBody .stateBooleanNames .boolean .booleanFirst .booleanAfter .booleanQualifierFirst "booleans_kept") =
      let row := BooleanBindings.binding (locals .state "frame").booleanNames index
      if booleanSelected calls locals row then
        if booleanOuter calls locals row then
          next ((booleanFilterState locals kept rows).set .number "i" index)
        else invalidState
      else next ((booleanFilterState locals (kept + 1) (rows.set kept row)).set .number "i" index) := by
  dsimp only [filterBody, Command.eval, Place.set, Place.expression, Expr.eval, Field.get,
    Field.set, Index.get, Index.set, frame, name, text, info, result,
    booleanSelected, booleanOuter, booleanFilterState]
  cases outerValue : calls _ .outerDeclaration (locals .metadata "info")
    ⟨(BooleanBindings.binding (locals .state "frame").booleanNames index).first,
      (BooleanBindings.binding (locals .state "frame").booleanNames index).after⟩ <;>
    simp [Locals.set, outerValue]
  all_goals simp only [Locals.set_commute_types _ .number .state _ _ _ _ (by decide),
    Locals.set_commute_names _ .number .number "i" "booleans_kept" _ _ (by decide),
    Locals.set_shadow]

theorem boolean_filter_loop (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (filterLoop .stateBooleanNames .booleanCount .boolean .booleanFirst .booleanAfter
        .booleanQualifierFirst "booleans_kept") =
      match compactRows (booleanSelected calls locals) (booleanOuter calls locals)
        (locals .number "booleans_kept") (locals .state "result").booleanNames
        (locals .state "frame").booleanNames with
      | none => invalidState
      | some (count, rows) => next (booleanFilterState locals count rows) := by
  have initial :
      (booleanFilterState locals (locals .number "booleans_kept")
        (locals .state "result").booleanNames).set .number "i" (locals .number "i") = locals := by
    change ((locals.set .state "result" (locals .state "result")).set .number "booleans_kept"
      (locals .number "booleans_kept")).set .number "i" (locals .number "i") = locals
    simp only [Locals.set_unchanged]
  have restore (count : Nat) (rows : BooleanBindings.Environment) :
      (booleanFilterState locals count rows).set .number "i" (locals .number "i") =
        booleanFilterState locals count rows := by
    unfold booleanFilterState
    rw [Locals.set_commute_names _ .number .number "booleans_kept" "i" _ _ (by decide),
      Locals.set_commute_types _ .state .number "result" "i" _ _ (by decide),
      Locals.set_unchanged]
  have equation := forValues_compact (booleanSelected calls locals) (booleanOuter calls locals)
    (BooleanBindings.binding (locals .state "frame").booleanNames)
    (booleanFilterState locals) "i"
    (fun current continuation => Command.eval (resultType := .state) calls current continuation
      (filterBody .stateBooleanNames .boolean .booleanFirst .booleanAfter .booleanQualifierFirst "booleans_kept"))
    invalidState (boolean_filter_body calls locals)
    ((List.range (locals .state "frame").booleanNames.length).map (1 + ·))
    (locals .number "booleans_kept") (locals .state "result").booleanNames (locals .number "i")
    (fun updated => next (updated.set .number "i" (locals .number "i")))
    (by intros; simp only [Locals.set_shadow])
  rw [initial] at equation
  have enumerated :
      (((List.range (locals .state "frame").booleanNames.length).map (1 + ·)).map
        (BooleanBindings.binding (locals .state "frame").booleanNames)) =
        (locals .state "frame").booleanNames :=
    enumerateRows (locals .state "frame").booleanNames {}
  rw [enumerated] at equation
  simp only [restore] at equation
  change forValues (resultType := .state)
    (fun current continuation => Command.eval calls current continuation
      (filterBody .stateBooleanNames .boolean .booleanFirst .booleanAfter .booleanQualifierFirst "booleans_kept"))
    "i" ((List.range ((locals .state "frame").booleanNames.length + 1 - 1)).map (1 + ·)) locals
    (fun updated => next (updated.set .number "i" (locals .number "i"))) = _
  simp only [Nat.add_sub_cancel]
  rw [equation]
  cases compactRows (booleanSelected calls locals) (booleanOuter calls locals)
    (locals .number "booleans_kept") (locals .state "result").booleanNames
    (locals .state "frame").booleanNames with
  | none => rfl
  | some output => cases output; rfl

def subtypeFilterState (locals : Locals) (kept : Nat)
    (rows : List IntegerSubtypes.Binding) : Locals :=
  (locals.set .state "result" {(locals .state "result") with subtypeNames := {(locals .state "result").subtypeNames with items := rows}}).set
    .number "subtypes_kept" kept

def subtypeSelected (calls : Calls Function) (locals : Locals)
    (row : IntegerSubtypes.Binding) : Bool :=
  decide (row.qualifierFirst = 0) && calls _ .equalName (locals .source "text")
    (locals .nameSpan "name").first (locals .nameSpan "name").after row.first row.after

def subtypeOuter (calls : Calls Function) (locals : Locals)
    (row : IntegerSubtypes.Binding) : Bool :=
  calls _ .outerDeclaration (locals .metadata "info") ⟨row.first, row.after⟩

theorem subtype_filter_body (calls : Calls Function) (locals : Locals) (kept : Nat)
    (rows : List IntegerSubtypes.Binding) (index : Nat) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls
      ((subtypeFilterState locals kept rows).set .number "i" index) next
      (filterBody .stateSubtypeNames .subtype .subtypeFirst .subtypeAfter .subtypeQualifierFirst "subtypes_kept") =
      let row := IntegerSubtypes.binding (locals .state "frame").subtypeNames index
      if subtypeSelected calls locals row then
        if subtypeOuter calls locals row then
          next ((subtypeFilterState locals kept rows).set .number "i" index)
        else invalidState
      else next ((subtypeFilterState locals (kept + 1) (rows.set kept row)).set .number "i" index) := by
  dsimp only [filterBody, Command.eval, Place.set, Place.expression, Expr.eval, Field.get,
    Field.set, Index.get, Index.set, frame, name, text, info, result,
    subtypeSelected, subtypeOuter, subtypeFilterState]
  cases outerValue : calls _ .outerDeclaration (locals .metadata "info")
    ⟨(IntegerSubtypes.binding (locals .state "frame").subtypeNames index).first,
      (IntegerSubtypes.binding (locals .state "frame").subtypeNames index).after⟩ <;>
    simp only [IntegerSubtypes.binding, List.getD_eq_getElem?_getD] at outerValue
  all_goals simp [Locals.set, IntegerSubtypes.binding, outerValue]
  all_goals simp only [Locals.set_commute_types _ .number .state _ _ _ _ (by decide),
    Locals.set_commute_names _ .number .number "i" "subtypes_kept" _ _ (by decide),
    Locals.set_shadow]

theorem subtype_filter_loop (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (filterLoop .stateSubtypeNames .subtypeCount .subtype .subtypeFirst .subtypeAfter
        .subtypeQualifierFirst "subtypes_kept") =
      match compactRows (subtypeSelected calls locals) (subtypeOuter calls locals)
        (locals .number "subtypes_kept") (locals .state "result").subtypeNames.items
        (locals .state "frame").subtypeNames.items with
      | none => invalidState
      | some (count, rows) => next (subtypeFilterState locals count rows) := by
  have initial :
      (subtypeFilterState locals (locals .number "subtypes_kept")
        (locals .state "result").subtypeNames.items).set .number "i" (locals .number "i") = locals := by
    change ((locals.set .state "result" (locals .state "result")).set .number "subtypes_kept"
      (locals .number "subtypes_kept")).set .number "i" (locals .number "i") = locals
    simp only [Locals.set_unchanged]
  have restore (count : Nat) (rows : List IntegerSubtypes.Binding) :
      (subtypeFilterState locals count rows).set .number "i" (locals .number "i") =
        subtypeFilterState locals count rows := by
    unfold subtypeFilterState
    rw [Locals.set_commute_names _ .number .number "subtypes_kept" "i" _ _ (by decide),
      Locals.set_commute_types _ .state .number "result" "i" _ _ (by decide),
      Locals.set_unchanged]
  have equation := forValues_compact (subtypeSelected calls locals) (subtypeOuter calls locals)
    (IntegerSubtypes.binding (locals .state "frame").subtypeNames)
    (subtypeFilterState locals) "i"
    (fun current continuation => Command.eval (resultType := .state) calls current continuation
      (filterBody .stateSubtypeNames .subtype .subtypeFirst .subtypeAfter .subtypeQualifierFirst "subtypes_kept"))
    invalidState (subtype_filter_body calls locals)
    ((List.range (locals .state "frame").subtypeNames.items.length).map (1 + ·))
    (locals .number "subtypes_kept") (locals .state "result").subtypeNames.items (locals .number "i")
    (fun updated => next (updated.set .number "i" (locals .number "i")))
    (by intros; simp only [Locals.set_shadow])
  rw [initial] at equation
  have enumerated :
      (((List.range (locals .state "frame").subtypeNames.items.length).map (1 + ·)).map
        (IntegerSubtypes.binding (locals .state "frame").subtypeNames)) =
        (locals .state "frame").subtypeNames.items :=
    enumerateRows (locals .state "frame").subtypeNames.items {}
  rw [enumerated] at equation
  simp only [restore] at equation
  change forValues (resultType := .state)
    (fun current continuation => Command.eval calls current continuation
      (filterBody .stateSubtypeNames .subtype .subtypeFirst .subtypeAfter .subtypeQualifierFirst "subtypes_kept"))
    "i" ((List.range ((locals .state "frame").subtypeNames.items.length + 1 - 1)).map (1 + ·)) locals
    (fun updated => next (updated.set .number "i" (locals .number "i"))) = _
  simp only [Nat.add_sub_cancel]
  rw [equation]
  cases compactRows (subtypeSelected calls locals) (subtypeOuter calls locals)
    (locals .number "subtypes_kept") (locals .state "result").subtypeNames.items
    (locals .state "frame").subtypeNames.items with
  | none => rfl
  | some output => cases output; rfl


end Silver.ApplicationPackageFrames.Native
