module

public import Silver.PackageBindingsEquations
public import Silver.PackageBindingsSourceChecks

@[expose] public section

namespace Silver.PackageBindings.SourceBridge
open Native

/-- New native helper meaning is established from exact typed bodies and the
three source-checked loop contracts. No declaration validity, effect locality or
package safety result is supplied as an interpretation premise. -/
theorem actual_source_correspondence : CheckedSource ∧
    ∀ calls, Primitives calls → Equations calls →
      (∀ name, calls.isIdentifier name = isIdentifier name) ∧
      (∀ text name, calls.validName text name = validName text name) ∧
      (∀ name unit, calls.inUnit name unit = inUnit name unit) ∧
      (∀ text left right, calls.sameName text left right = sameName text left right) ∧
      (∀ left right, calls.union left right = stateUnion left right) ∧
      (∀ effect count, calls.within effect count = within effect count) ∧
      (∀ text info, calls.validMetadata text info = validMetadata text info) ∧
      (∀ text info, calls.completeMetadata text info = completeMetadata text info) := by
  refine ⟨checked_source, ?_⟩
  intro calls primitives equations
  exact ⟨interpreted_identifier calls primitives equations, interpreted_validName calls primitives equations,
    interpreted_inUnit calls equations, interpreted_sameName calls primitives equations,
    interpreted_union calls equations, interpreted_within calls equations,
    interpreted_validMetadata calls primitives equations, interpreted_completeMetadata calls primitives equations⟩

theorem executable_lookups (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Text) (info : Metadata) (name : NameSpan) :
    calls.lookupExport text info name = lookupExport text info name ∧
    calls.lookupState text info name = lookupState text info name ∧
    (∀ completedOnly, info.completed ≤ info.routines.length →
      calls.lookupRoutine text info name completedOnly = lookupRoutine text info name completedOnly) := by
  constructor
  · rw [equations.lookupExport, interpreted_exportLookup calls primitives equations text info name _ (by omega)]
    rfl
  constructor
  · rw [equations.lookupState, interpreted_stateLookup calls primitives equations text info name _ (by omega)]
    rfl
  · intro completedOnly bound
    rw [equations.lookupRoutine text info name completedOnly bound,
      interpreted_routineLookup calls primitives equations text info name _ (by split <;> omega)]
    rfl

theorem model_interpreted : Primitives modelCalls ∧ Equations modelCalls :=
  ⟨model_primitives, model_equations⟩

end Silver.PackageBindings.SourceBridge
