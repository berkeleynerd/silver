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

theorem metadataLookup_zero_apart {text : PackageBindings.Text} {name : PackageBindings.NameSpan}
    {itemName : Nat → PackageBindings.NameSpan} {count index : Nat}
    (missing : PackageBindings.lookupFrom text name itemName count = 0)
    (positive : 0 < index) (active : index ≤ count) :
    PackageBindings.sameName text (itemName index) name = false := by
  induction count with
  | zero => omega
  | succ count ih =>
    rw [PackageBindings.lookupFrom] at missing
    split at missing
    · omega
    · rename_i apart
      by_cases last : index = count + 1
      · subst index
        exact Bool.eq_false_iff.mpr apart
      · exact ih missing (by omega)

theorem objectStep_name_guards {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : PackageBindings.Metadata}
    (present : (objectStep (modelObjectCalls reader) text frame info false).frame.position ≠ 0) :
    ApplicationPackageNames.packageNameFresh text info (objectName text frame) = true ∧
      newNameAllowed text frame (objectName text frame).first (objectName text frame).after false = true := by
  dsimp only [objectStep, objectNameStep] at present
  simp only [Bool.false_eq_true, ite_false] at present
  split at present
  · contradiction
  · split at present
    · rename_i accepted
      simpa only [Bool.and_eq_true, modelObjectCalls, objectName] using accepted
    · contradiction

structure StateDeclarations (text : Source) (states : List PackageBindings.StateDeclaration) : Prop where
  ordered : states.Pairwise (fun left right => left.name.first < right.name.first)
  names : ∀ state ∈ states,
    PackageBindings.validName (ApplicationPackageNames.metadataText text) state.name = true
  spelling : states.Pairwise (fun left right =>
    Named.equalName text left.name.first left.name.after right.name.first right.name.after = false)

theorem StateDeclarations.empty (text : Source) : StateDeclarations text [] :=
  ⟨.nil, by simp, .nil⟩

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
  · apply List.pairwise_append.mpr
    refine ⟨prior.spelling, by simp, ?_⟩
    intro old member added fresh
    cases List.mem_singleton.mp fresh
    obtain ⟨offset, offsetBound, atOffset⟩ := List.mem_iff_getElem.mp member
    have guards := (objectStep_name_guards (parsed ▸ present)).1
    simp only [ApplicationPackageNames.packageNameFresh, Bool.and_eq_true,
      decide_eq_true_eq] at guards
    have noName := metadataLookup_zero_apart guards.1.2
      (by omega : 0 < offset + 1) (by omega)
    have oldAt : info.stateAt (offset + 1) = old := by
      simp only [PackageBindings.Metadata.stateAt, Nat.add_sub_cancel,
        List.getD_eq_getElem?_getD, List.getElem?_eq_getElem offsetBound, Option.getD_some, atOffset]
    have current : (objectName text frame) = out.name := by
      exact (parsed ▸ valid.2.nameEq).symm
    change PackageBindings.sameName _ (info.stateAt (offset + 1)).name _ = false at noName
    rw [oldAt, current] at noName
    simp only [PackageBindings.sameName, prior.names old member, named, Bool.true_and] at noName
    simpa only [ApplicationPackageNames.metadataText, stateDeclaration] using noName

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

theorem StateDeclarations.spelling_identity {text : Source} {info : PackageBindings.Metadata}
    (source : StateDeclarations text info.states) {left right : Nat}
    (leftPositive : 0 < left) (leftActive : left ≤ info.states.length)
    (rightPositive : 0 < right) (rightActive : right ≤ info.states.length)
    (same : Named.equalName text (info.stateAt left).name.first (info.stateAt left).name.after
      (info.stateAt right).name.first (info.stateAt right).name.after = true) : left = right := by
  have l : left - 1 < info.states.length := by omega
  have r : right - 1 < info.states.length := by omega
  simp only [PackageBindings.Metadata.stateAt, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem l, List.getElem?_eq_getElem r, Option.getD_some] at same
  by_cases equal : left = right
  · exact equal
  · rcases Nat.lt_or_gt_of_ne equal with before | after
    · have apart := source.spelling.rel_getElem_of_lt l r (by omega : left - 1 < right - 1)
      rw [same] at apart
      contradiction
    · have apart := source.spelling.rel_getElem_of_lt r l (by omega : right - 1 < left - 1)
      rw [equalName_symm same] at apart
      contradiction

theorem StateDeclarations.lookupState {text : Source} {info : PackageBindings.Metadata}
    (source : StateDeclarations text info.states) {name : PackageBindings.NameSpan} {identity : Nat}
    (positive : 0 < identity) (active : identity ≤ info.states.length)
    (valid : PackageBindings.validName (ApplicationPackageNames.metadataText text) name = true)
    (same : Named.equalName text (info.stateAt identity).name.first (info.stateAt identity).name.after
      name.first name.after = true) :
    PackageBindings.lookupState (ApplicationPackageNames.metadataText text) info name = identity := by
  have matching : PackageBindings.sameName (ApplicationPackageNames.metadataText text)
      (info.stateAt identity).name name = true := by
    simp only [PackageBindings.sameName, source.name positive active, valid, Bool.true_and]
    exact same
  have present : PackageBindings.lookupState (ApplicationPackageNames.metadataText text) info name ≠ 0 := by
    intro missing
    have absent := metadataLookup_zero_apart missing positive active
    rw [matching] at absent
    contradiction
  have found := PackageBindings.lookupFrom_found present
  have bounded := PackageBindings.lookupFrom_bound (ApplicationPackageNames.metadataText text) name
    (fun index => (info.stateAt index).name) info.states.length
  simp only [PackageBindings.sameName, Bool.and_eq_true] at found
  exact source.spelling_identity (Nat.pos_of_ne_zero present) bounded positive active
    (equalName_trans found.2 (equalName_symm same))

theorem stateTarget_selected {calls : ApplicationPackageEffects.Calls} {text : Source}
    {context : ParseContext} {info : PackageBindings.Metadata} {position identity : Nat}
    (found : stateTarget calls text context info position = identity) (positive : identity ≠ 0) :
    calls.lookupState text info ⟨calls.skip text position, calls.nameAfter text (calls.skip text position)⟩ = identity ∧
      visibleState calls text context info identity = true := by
  dsimp only [stateTarget] at found
  split at found
  · rename_i selected
    exact ⟨found, found ▸ selected.2⟩
  · exact False.elim (positive found.symm)

theorem stateTarget_of_visible {calls : ApplicationPackageEffects.Calls} {text : Source}
    {context : ParseContext} {info : PackageBindings.Metadata} {position identity : Nat}
    (found : calls.lookupState text info
      ⟨calls.skip text position, calls.nameAfter text (calls.skip text position)⟩ = identity)
    (positive : identity ≠ 0) (visible : visibleState calls text context info identity = true) :
    stateTarget calls text context info position = identity := by
  dsimp only [stateTarget]
  rw [found]
  exact ite_eq_left ⟨positive, visible⟩

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

/-- State_Target records exactly the global identity of an original bare
Integer actual. The spelling and lookup premises are supplied by the actual
target's source derivation; no visibility or effect endpoint is assumed. -/
theorem stateTarget_integer_iff {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} (source : StateDeclarations text info.states)
    {position first after slot identity bound : Nat}
    (positive : 0 < identity) (slotPositive : slot ≠ 0)
    (skipped : skipAt text position = first) (ended : Compose.nameAfter text first = after)
    (valid : PackageBindings.validName (ApplicationPackageNames.metadataText text) ⟨first, after⟩ = true)
    (actual : ScalarExpression.lookup text context.scalarNames first after = slot) :
    stateTarget ApplicationPackageEffects.modelCalls text context info position = identity ↔
      (layout bound info context).integers slot = .global identity := by
  have actualDomain := (ApplicationPackageNames.Native.validName_domain valid).2
  constructor
  · intro target
    obtain ⟨selected, visible⟩ := stateTarget_selected target (Nat.ne_of_gt positive)
    change PackageBindings.lookupState _ info _ = identity at selected
    simp only [ApplicationPackageEffects.modelCalls, skipped, ended] at selected
    have nonzero : PackageBindings.lookupState (ApplicationPackageNames.metadataText text)
        info ⟨first, after⟩ ≠ 0 := selected ▸ Nat.ne_of_gt positive
    have spelling := PackageBindings.lookupFrom_found nonzero
    change PackageBindings.sameName _ (info.stateAt
      (PackageBindings.lookupState _ info ⟨first,after⟩)).name ⟨first,after⟩ = true at spelling
    rw [selected] at spelling
    simp only [PackageBindings.sameName, Bool.and_eq_true] at spelling
    have domain := (ApplicationPackageNames.Native.validName_domain spelling.1.1).2
    have original : ScalarExpression.lookup text context.scalarNames
        (info.stateAt identity).name.first (info.stateAt identity).name.after = slot :=
      (scalarLookup_retarget (Nat.ne_of_gt domain.1) domain.2.1
        (Nat.ne_of_gt actualDomain.1) actualDomain.2.1 spelling.2).trans actual
    have kind : (info.stateAt identity).kind = .integer := by
      cases choice : (info.stateAt identity).kind with
      | integer => rfl
      | boolean =>
        simp only [visibleState, ApplicationPackageEffects.modelCalls, choice, reduceCtorEq,
          original, ite_false] at visible
        split at visible <;> contradiction
    simpa only [original] using visible_integer_global source positive visible kind (bound := bound)
  · intro selected
    have live := slotAddress_global selected
    have state := stateIndex_some live.2.2
    rw [scalarRows_get] at state
    dsimp only at state
    have named := source.name state.1 state.2.1
    have domain := (ApplicationPackageNames.Native.validName_domain named).2
    have spelling := scalarLookupFrom_spelling actual slotPositive
    rw [← state.2.2.2.2.1, ← state.2.2.2.2.2] at spelling
    have found := source.lookupState state.1 state.2.1 valid spelling
    have original : ScalarExpression.lookup text context.scalarNames
        (info.stateAt identity).name.first (info.stateAt identity).name.after = slot :=
      (scalarLookup_retarget (Nat.ne_of_gt domain.1) domain.2.1
        (Nat.ne_of_gt actualDomain.1) actualDomain.2.1 spelling).trans actual
    have visible : visibleState ApplicationPackageEffects.modelCalls text context info identity = true := by
      simp [visibleState, ApplicationPackageEffects.modelCalls, Nat.not_lt.mpr state.2.1, named,
        state.2.2.2.1, original, slotPositive, state.2.2.2.2.1.symm, state.2.2.2.2.2.symm]
    apply stateTarget_of_visible (positive := Nat.ne_of_gt positive) (visible := visible)
    simpa only [ApplicationPackageEffects.modelCalls, skipped, ended] using found

theorem stateTarget_boolean_iff {text : Source} {info : PackageBindings.Metadata}
    {context : ParseContext} (source : StateDeclarations text info.states)
    {position first after slot identity bound : Nat}
    (positive : 0 < identity) (slotPositive : slot ≠ 0)
    (skipped : skipAt text position = first) (ended : Compose.nameAfter text first = after)
    (valid : PackageBindings.validName (ApplicationPackageNames.metadataText text) ⟨first, after⟩ = true)
    (noInteger : ScalarExpression.lookup text context.scalarNames first after = 0)
    (actual : BooleanBindings.lookup text context.booleanNames first after = slot) :
    stateTarget ApplicationPackageEffects.modelCalls text context info position = identity ↔
      (layout bound info context).booleans slot = .global identity := by
  have actualDomain := (ApplicationPackageNames.Native.validName_domain valid).2
  constructor
  · intro target
    obtain ⟨selected, visible⟩ := stateTarget_selected target (Nat.ne_of_gt positive)
    change PackageBindings.lookupState _ info _ = identity at selected
    simp only [ApplicationPackageEffects.modelCalls, skipped, ended] at selected
    have nonzero : PackageBindings.lookupState (ApplicationPackageNames.metadataText text)
        info ⟨first, after⟩ ≠ 0 := selected ▸ Nat.ne_of_gt positive
    have spelling := PackageBindings.lookupFrom_found nonzero
    change PackageBindings.sameName _ (info.stateAt
      (PackageBindings.lookupState _ info ⟨first,after⟩)).name ⟨first,after⟩ = true at spelling
    rw [selected] at spelling
    simp only [PackageBindings.sameName, Bool.and_eq_true] at spelling
    have domain := (ApplicationPackageNames.Native.validName_domain spelling.1.1).2
    have original : BooleanBindings.lookup text context.booleanNames
        (info.stateAt identity).name.first (info.stateAt identity).name.after = slot :=
      (booleanLookup_retarget (Nat.ne_of_gt domain.1) domain.2.1
        (Nat.ne_of_gt actualDomain.1) actualDomain.2.1 spelling.2).trans actual
    have scalarAbsent : ScalarExpression.lookup text context.scalarNames
        (info.stateAt identity).name.first (info.stateAt identity).name.after = 0 :=
      (scalarLookup_retarget (Nat.ne_of_gt domain.1) domain.2.1
        (Nat.ne_of_gt actualDomain.1) actualDomain.2.1 spelling.2).trans noInteger
    have kind : (info.stateAt identity).kind = .boolean := by
      cases choice : (info.stateAt identity).kind with
      | boolean => rfl
      | integer =>
        simp only [visibleState, ApplicationPackageEffects.modelCalls, choice, scalarAbsent,
          ne_eq, not_true_eq_false, decide_false, Bool.false_and, ite_true] at visible
        split at visible <;> contradiction
    simpa only [original] using visible_boolean_global source positive visible kind (bound := bound)
  · intro selected
    have live := slotAddress_global selected
    have state := stateIndex_some live.2.2
    rw [booleanRows_get] at state
    dsimp only at state
    have named := source.name state.1 state.2.1
    have domain := (ApplicationPackageNames.Native.validName_domain named).2
    have spelling := booleanLookupFrom_spelling actual slotPositive
    rw [← state.2.2.2.2.1, ← state.2.2.2.2.2] at spelling
    have found := source.lookupState state.1 state.2.1 valid spelling
    have original : BooleanBindings.lookup text context.booleanNames
        (info.stateAt identity).name.first (info.stateAt identity).name.after = slot :=
      (booleanLookup_retarget (Nat.ne_of_gt domain.1) domain.2.1
        (Nat.ne_of_gt actualDomain.1) actualDomain.2.1 spelling).trans actual
    have scalarAbsent : ScalarExpression.lookup text context.scalarNames
        (info.stateAt identity).name.first (info.stateAt identity).name.after = 0 :=
      (scalarLookup_retarget (Nat.ne_of_gt domain.1) domain.2.1
        (Nat.ne_of_gt actualDomain.1) actualDomain.2.1 spelling).trans noInteger
    have visible : visibleState ApplicationPackageEffects.modelCalls text context info identity = true := by
      simp [visibleState, ApplicationPackageEffects.modelCalls, Nat.not_lt.mpr state.2.1, named,
        state.2.2.2.1, scalarAbsent, original, slotPositive,
        state.2.2.2.2.1.symm, state.2.2.2.2.2.symm]
    apply stateTarget_of_visible (positive := Nat.ne_of_gt positive) (visible := visible)
    simpa only [ApplicationPackageEffects.modelCalls, skipped, ended] using found

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
