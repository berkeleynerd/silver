module

public import Silver.ApplicationPackageProcedureReset
public import Silver.ApplicationPackageObjectLayout
public import Silver.ApplicationPackageFormalLayout

@[expose] public section

/-! Source-derived state identities and visible scalar slots. These facts are
obtained from the original declaration history; they do not strengthen the
domain of Visible_State, State_Target, or the raw reset pass. -/
namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages ApplicationPackageEffects ApplicationPackageObjectRows
open ApplicationPackageDeclarations ApplicationPackageBodies

set_option backward.dsimp.instances true

structure StateDeclarations (text : Source) (states : List PackageBindings.StateDeclaration) : Prop where
  ordered : states.Pairwise (fun left right => left.name.first < right.name.first)
  names : ∀ state ∈ states,
    PackageBindings.validName (ApplicationPackageNames.metadataText text) state.name = true

theorem StateDeclarations.empty (text : Source) : StateDeclarations text [] :=
  ⟨.nil, by simp⟩

theorem StateDeclarations.after_state {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    (prior : StateDeclarations text info.states) (source : StateFrame info.states frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info false = out)
    (present : out.frame.position ≠ 0) :
    StateDeclarations text (info.states ++ [stateDeclaration out]) := by
  have positions := parsed ▸ objectStep_positions reader text frame info false (parsed ▸ present)
  have valid := objectStep_rows reader text frame info false (parsed ▸ present)
  have named : PackageBindings.validName (ApplicationPackageNames.metadataText text) out.name = true := by
    rw [← parsed, valid.2.nameEq]
    exact valid.1
  constructor
  · apply List.pairwise_append.mpr
    refine ⟨prior.ordered, by simp, ?_⟩
    intro old member added fresh
    cases List.mem_singleton.mp fresh
    exact Nat.lt_of_lt_of_le (source.statesBefore old member) positions.1
  · intro state member
    rcases List.mem_append.mp member with old | fresh
    · exact prior.names state old
    · cases List.mem_singleton.mp fresh
      exact named

/-- Strict source progression and each successful Object name guard supply
state identity uniqueness and name validity at the actual declaration prefix. -/
theorem stateHistory_declarations {reader : BooleanElaboration.Native.Reader} {calls : UnitCalls}
    {text : Source} {before after : UnitState} {rows : List StateObject}
    (history : StateObjects calls text before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.globals row.before.info false =
      objectStep (modelObjectCalls reader) text row.before.globals row.before.info false)
    (initial : StateFrame before.info.states before.globals)
    (declarations : StateDeclarations text before.info.states) :
    StateDeclarations text after.info.states := by
  induction history with
  | finished => exact declarations
  | @added row following final phase chosen capacity parsed advances writable rest ih =>
    have object := ((original row List.mem_cons_self).symm.trans parsed)
    have present : row.object.frame.position ≠ 0 := by omega
    exact ih (fun seen member => original seen (List.mem_cons_of_mem _ member))
      (initial.after_state object present writable) (declarations.after_state initial object present)

theorem StateDeclarations.identity {text : Source} {info : PackageBindings.Metadata}
    (source : StateDeclarations text info.states) {left right : Nat}
    (leftPositive : 0 < left) (leftActive : left ≤ info.states.length)
    (rightPositive : 0 < right) (rightActive : right ≤ info.states.length)
    (same : (info.stateAt left).name.first = (info.stateAt right).name.first) : left = right := by
  have l : left - 1 < info.states.length := by omega
  have r : right - 1 < info.states.length := by omega
  simp only [PackageBindings.Metadata.stateAt, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem l, List.getElem?_eq_getElem r, Option.getD_some] at same
  by_cases equal : left = right
  · exact equal
  · rcases Nat.lt_or_gt_of_ne equal with before | after
    · have less := source.ordered.rel_getElem_of_lt l r (by omega : left - 1 < right - 1)
      omega
    · have less := source.ordered.rel_getElem_of_lt r l (by omega : right - 1 < left - 1)
      omega

theorem stateIndex_of_matching {text : Source} {info : PackageBindings.Metadata}
    {kind : FunctionBindings.ScalarKind} {row : Row} {identity : Nat}
    (source : StateDeclarations text info.states)
    (positive : 0 < identity) (active : identity ≤ info.states.length)
    (bare : row.qualifierFirst = 0) (sameKind : (info.stateAt identity).kind = kind)
    (first : (info.stateAt identity).name.first = row.first)
    (after : (info.stateAt identity).name.after = row.after) :
    stateIndex info kind row = some identity := by
  have matching : stateMatches info kind row (identity - 1) = true := by
    simp only [stateMatches, Nat.sub_add_cancel positive, bare, sameKind, first, after,
      and_self, decide_true]
  cases found : (List.range info.states.length).find? (stateMatches info kind row) with
  | none =>
    have absent := List.find?_eq_none.mp found (identity - 1) (List.mem_range.mpr (by omega))
    exact False.elim (absent matching)
  | some offset =>
    have bound := List.mem_range.mp (List.mem_of_find?_eq_some found)
    have matchingFields := List.find?_some found
    simp only [stateMatches, decide_eq_true_eq] at matchingFields
    have equal := source.identity (by omega : 0 < offset + 1) (by omega) positive active
      (matchingFields.2.2.1.trans first.symm)
    simp only [stateIndex, found, Option.map_some, equal]

theorem StateDeclarations.name {text : Source} {info : PackageBindings.Metadata}
    (source : StateDeclarations text info.states) {identity : Nat}
    (positive : 0 < identity) (active : identity ≤ info.states.length) :
    PackageBindings.validName (ApplicationPackageNames.metadataText text) (info.stateAt identity).name = true := by
  apply source.names
  have bound : identity - 1 < info.states.length := by omega
  simp only [PackageBindings.Metadata.stateAt, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem bound, Option.getD_some]
  exact List.getElem_mem bound

/-- A visible integer denotes the same positive state ordinal in the concrete
layout. Original declaration progression rules out duplicate defining spans. -/
theorem visible_integer_global {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} (source : StateDeclarations text info.states)
    {identity bound : Nat} (positive : 0 < identity)
    (visible : visibleState ApplicationPackageEffects.modelCalls text context info identity = true)
    (integer : (info.stateAt identity).kind = .integer) :
    (layout bound info context).integers
      (ScalarExpression.lookup text context.scalarNames
        (info.stateAt identity).name.first (info.stateAt identity).name.after) = .global identity := by
  have active := (visibleState_guard visible).1
  dsimp only [visibleState, ApplicationPackageEffects.modelCalls] at visible
  split at visible
  · contradiction
  · simp only [Bool.and_eq_true, decide_eq_true_eq] at visible
    have bare := scalarLookupFrom_qualifier rfl visible.1.1
    simp only [QualifiedNames.qualifierMatches, ite_true, beq_iff_eq] at bare
    have live := ScalarExpression.lookup_bound text context.scalarNames
      (info.stateAt identity).name.first (info.stateAt identity).name.after
    have selected := stateIndex_of_matching source positive active
      (row := (scalarRows context).getD
        (ScalarExpression.lookup text context.scalarNames
          (info.stateAt identity).name.first (info.stateAt identity).name.after - 1) {})
      (by simpa only [scalarRows_get, ScalarExpression.lookup] using bare) integer
      (by simpa only [scalarRows_get] using visible.1.2.symm)
      (by simpa only [scalarRows_get] using visible.2.symm)
    simp only [layout, slotAddress, scalarRows, List.length_map,
      Nat.pos_of_ne_zero visible.1.1, live, and_self, ite_true, rowAddress] at *
    rw [selected]

theorem visible_boolean_global {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} (source : StateDeclarations text info.states)
    {identity bound : Nat} (positive : 0 < identity)
    (visible : visibleState ApplicationPackageEffects.modelCalls text context info identity = true)
    (boolean : (info.stateAt identity).kind = .boolean) :
    (layout bound info context).booleans
      (BooleanBindings.lookup text context.booleanNames
        (info.stateAt identity).name.first (info.stateAt identity).name.after) = .global identity := by
  have active := (visibleState_guard visible).1
  dsimp only [visibleState, ApplicationPackageEffects.modelCalls] at visible
  split at visible
  · contradiction
  · simp only [boolean, reduceCtorEq, ite_false] at visible
    split at visible
    · contradiction
    · simp only [Bool.and_eq_true, decide_eq_true_eq] at visible
      have bare := booleanLookupFrom_qualifier rfl visible.1.1
      simp only [QualifiedNames.qualifierMatches, ite_true, beq_iff_eq] at bare
      have live := BooleanBindings.lookup_bound text context.booleanNames
        (info.stateAt identity).name.first (info.stateAt identity).name.after
      have selected := stateIndex_of_matching source positive active
        (row := (booleanRows context).getD
          (BooleanBindings.lookup text context.booleanNames
            (info.stateAt identity).name.first (info.stateAt identity).name.after - 1) {})
        (by simpa only [booleanRows_get, BooleanBindings.lookup] using bare) boolean
        (by simpa only [booleanRows_get] using visible.1.2.symm)
        (by simpa only [booleanRows_get] using visible.2.symm)
      simp only [layout, slotAddress, booleanRows, List.length_map,
        Nat.pos_of_ne_zero visible.1.1, live, and_self, ite_true, rowAddress] at *
      rw [selected]

theorem stateTarget_zero (text : Source) (context : ParseContext) (info : PackageBindings.Metadata) :
    stateTarget ApplicationPackageEffects.modelCalls text context info 0 = 0 := by
  have missing (count : Nat) : PackageBindings.lookupFrom
      (ApplicationPackageNames.metadataText text) ⟨0, 0⟩
      (fun index => (info.stateAt index).name) count = 0 := by
    induction count with
    | zero => rfl
    | succ count ih =>
      simp only [PackageBindings.lookupFrom, PackageBindings.sameName, PackageBindings.validName,
        Nat.lt_irrefl, false_and, and_false, decide_false, Bool.and_false, Bool.false_and,
        Bool.false_eq_true, ite_false, ih]
  simp only [stateTarget, ApplicationPackageEffects.modelCalls, skipAt, ite_true, nameAfter,
    PackageBindings.lookupState, PackageBindings.stateLookupModel, missing, ne_eq,
    not_true_eq_false, false_and, ite_false]

end Silver.ApplicationPackageFrameLayout
