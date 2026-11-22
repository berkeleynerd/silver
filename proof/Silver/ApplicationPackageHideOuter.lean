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

end Silver.ApplicationPackageFrames.Native
