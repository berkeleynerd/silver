module

public import Silver.ApplicationPackageSpecificationSeedRows
public import Silver.ApplicationPackageObjectLayout

@[expose] public section

namespace Silver.ApplicationPackageInitializers
open Compose Predicate Packages ApplicationPackageDeclarations ApplicationPackageBodies
open ApplicationPackageObjectRows ApplicationPackageFrameLayout

/-- Every global-frame scalar is either an original public constant or one of
the original private state declarations. This relation records syntax/storage
origin only; it carries no range-map or checking conclusion. -/
def GlobalScalarOrigins (constants : ScalarExpression.Environment)
    (states : List PackageBindings.StateDeclaration) (names : ScalarExpression.Environment) : Prop :=
  ∀ row ∈ names, row ∈ constants ∨ ∃ state ∈ states,
    state.kind = .integer ∧ state.name.first = row.first ∧ state.name.after = row.after ∧
      row.qualifierFirst = 0

theorem GlobalScalarOrigins.initial (constants : ScalarExpression.Environment) :
    GlobalScalarOrigins constants [] constants := fun _ member => Or.inl member

theorem GlobalScalarOrigins.after_state {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    {constants : ScalarExpression.Environment}
    (origin : GlobalScalarOrigins constants info.states frame.scalarNames)
    (parsed : objectStep (modelObjectCalls reader) text frame info false = out)
    (present : out.frame.position ≠ 0) :
    GlobalScalarOrigins constants (info.states ++ [stateDeclaration out]) out.frame.scalarNames := by
  have prior : GlobalScalarOrigins constants (info.states ++ [stateDeclaration out]) frame.scalarNames := by
    intro row member
    rcases origin row member with constant | ⟨state, declared, kind, first, after, bare⟩
    · exact Or.inl constant
    · exact Or.inr ⟨state, List.mem_append_left _ declared, kind, first, after, bare⟩
  obtain ⟨storage, _, _⟩ := objectStep_storage parsed present
  cases kind : out.mark.kind with
  | integer =>
    obtain ⟨_, stored, _⟩ := storage.integerStorage kind
    intro row member
    rw [stored] at member
    rcases List.mem_append.mp member with old | new
    · exact prior row old
    · cases List.mem_singleton.mp new
      exact Or.inr ⟨stateDeclaration out, List.mem_append_right _ List.mem_cons_self, kind, rfl, rfl, rfl⟩
  | boolean =>
    obtain ⟨_, _, stored⟩ := storage.booleanStorage kind
    simpa only [stored, initializerBase, Bool.false_eq_true, ite_false] using prior

theorem StateObjects.scalar_origins {reader : BooleanElaboration.Native.Reader} {calls : UnitCalls} {text : Source}
    {before after : UnitState} {objects : List StateObject} {constants : ScalarExpression.Environment}
    (history : StateObjects calls text before objects after)
    (original : ∀ row ∈ objects, calls.objectAt text row.before.globals row.before.info false =
      objectStep (modelObjectCalls reader) text row.before.globals row.before.info false)
    (initial : GlobalScalarOrigins constants before.info.states before.globals.scalarNames) :
    GlobalScalarOrigins constants after.info.states after.globals.scalarNames := by
  induction history with
  | finished => exact initial
  | @added row following final phase selected capacity parsed advanced writable rest ih =>
    apply ih (fun next member => original next (List.mem_cons_of_mem _ member))
    exact initial.after_state ((original row List.mem_cons_self).symm.trans parsed) (by omega)

theorem stateIndex_of_member {info : PackageBindings.Metadata} {row : Row}
    {state : PackageBindings.StateDeclaration} (member : state ∈ info.states)
    (kind : state.kind = .integer) (first : state.name.first = row.first)
    (after : state.name.after = row.after) (bare : row.qualifierFirst = 0) :
    ∃ identity, stateIndex info .integer row = some identity := by
  obtain ⟨offset, inside, same⟩ := List.mem_iff_getElem.mp member
  have atOffset : info.stateAt (offset + 1) = state := by
    simpa only [PackageBindings.Metadata.stateAt, Nat.add_one_sub_one,
      List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside, Option.getD_some] using same
  have matching : stateMatches info .integer row offset = true := by
    simp only [stateMatches, atOffset, bare, kind, first, after, and_self, decide_true]
  cases found : (List.range info.states.length).find? (stateMatches info .integer row) with
  | none => exact False.elim (List.find?_eq_none.mp found offset (List.mem_range.mpr inside) matching)
  | some index => exact ⟨index + 1, by simp only [stateIndex, found, Option.map_some]⟩

/-- Widening a native global frame uses full state domains and leaves its
source-selected immutable constants exact. Metadata slots select globals;
original defining bytes select constant locals. -/
theorem global_seed_rows {info : PackageBindings.Metadata} {frame : ParserState}
    {constants : ScalarExpression.Environment} {ranges : SharedRanges}
    (origin : GlobalScalarOrigins constants info.states frame.scalarNames)
    (fields : ScalarStateFields info.states frame.scalarNames)
    (seeded : ConstantRangeRows ranges constants)
    (globals : ranges.globals = info.stateSchema.integerRanges) :
    ScalarRangeRows info ranges (ScalarExpression.bodyEnvironment frame.scalarNames) := by
  intro row member
  obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
  let reference : Row := ⟨original.first, original.after, original.qualifierFirst, original.qualifierAfter⟩
  cases found : stateIndex info .integer reference with
  | some identity =>
    have selected := stateIndex_some found
    have declared := fields original present (info.stateAt identity)
      (info.stateAt_mem identity selected.1 selected.2.1) selected.2.2.2.2.1.symm
    change integerRangeAt ranges (rowAddress info .integer reference) = _
    simp only [rowAddress, found, integerRangeAt, ScalarExpression.bodyBinding, declared.2, ite_true, globals]
    exact (metadata_global_range info selected.1 selected.2.1 selected.2.2.2.1).trans
      (congrArg some declared.1.symm)
  | none =>
    rcases origin original present with constant | ⟨state, included, kind, first, after, bare⟩
    · have loaded := seeded original constant
      change integerRangeAt ranges (rowAddress info .integer reference) = _
      simp only [rowAddress, found, integerRangeAt, ScalarExpression.bodyBinding, loaded.2]
      exact loaded.1
    · obtain ⟨identity, selected⟩ := stateIndex_of_member (row := reference) included kind first after bare
      rw [found] at selected
      contradiction

end Silver.ApplicationPackageInitializers
