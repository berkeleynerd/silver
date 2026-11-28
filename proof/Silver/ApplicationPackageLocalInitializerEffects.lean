module

public import Silver.ApplicationPackageRoutineFooterEffects

@[expose] public section

/-! Local initializer effects retain the RHS scope before the new declaration
is installed, then transport its reads to the native scan of the updated frame. -/
namespace Silver.ApplicationPackageLocalInitializerEffects
open Compose Predicate Packages PackageBindings ApplicationPackages
open ApplicationPackageFrameLayout ApplicationPackageObjectRows ApplicationPackageFrames
open ApplicationPackageDeclarations ApplicationPackageBodies ApplicationPackageInitializers
open ApplicationPackageEffects ApplicationPackageSourceEffects

set_option backward.dsimp.instances true

private theorem scalar_body_lookup (text : Source) (names : ScalarExpression.Environment)
    (first after : Nat) :
    ScalarExpression.lookup text (ScalarExpression.bodyEnvironment names) first after =
      ScalarExpression.lookup text names first after := by
  have loop (count : Nat) :
      ScalarExpression.lookupFrom text (ScalarExpression.bodyEnvironment names) first after count =
        ScalarExpression.lookupFrom text names first after count := by
    induction count with
    | zero => rfl
    | succ count ih =>
        simp only [ScalarExpression.lookupFrom, ScalarExpression.bodyEnvironment_binding,
          ScalarExpression.bodyBinding_first, ScalarExpression.bodyBinding_after,
          ScalarExpression.bodyBinding_qualifierFirst, ScalarExpression.bodyBinding_qualifierAfter, ih]
  simpa only [ScalarExpression.lookup, ScalarExpression.bodyEnvironment_length] using loop names.length

private theorem scalar_append_lookup (text : Source) (names : ScalarExpression.Environment)
    (added : ScalarExpression.Binding) (first after : Nat)
    (apart : Named.equalName text added.first added.after first after = false) :
    ScalarExpression.lookup text (names ++ [added]) first after =
      ScalarExpression.lookup text names first after := by
  have loop (count : Nat) (within : count ≤ names.length) :
      ScalarExpression.lookupFrom text (names ++ [added]) first after count =
        ScalarExpression.lookupFrom text names first after count := by
    induction count with
    | zero => rfl
    | succ count ih =>
        simp only [ScalarExpression.lookupFrom,
          ScalarExpression.binding_append_old names added (count + 1) (by omega) within,
          ih (by omega)]
  by_cases invalid : first = 0 ∨ after ≤ first
  · exact (ScalarExpression.lookup_invalid _ _ _ _ 0 0 invalid).trans
      (ScalarExpression.lookup_invalid _ _ _ _ 0 0 invalid).symm
  · simp only [ScalarExpression.lookup, List.length_append, List.length_singleton,
      ScalarExpression.lookupFrom, invalid, ite_false, ScalarExpression.binding_append_new,
      apart, Bool.false_and, Bool.false_eq_true, loop names.length (Nat.le_refl _)]

private theorem boolean_append_binding (names : BooleanBindings.Environment)
    (added : BooleanBindings.Binding) (index : Nat) (positive : 0 < index)
    (within : index ≤ names.length) :
    BooleanBindings.binding (names ++ [added]) index = BooleanBindings.binding names index := by
  simp only [BooleanBindings.binding, List.getD_eq_getElem?_getD,
    List.getElem?_append_left (show index - 1 < names.length by omega)]

private theorem boolean_append_lookup (text : Source) (names : BooleanBindings.Environment)
    (added : BooleanBindings.Binding) (first after : Nat)
    (apart : Named.equalName text added.first added.after first after = false) :
    BooleanBindings.lookup text (names ++ [added]) first after =
      BooleanBindings.lookup text names first after := by
  have loop (count : Nat) (within : count ≤ names.length) :
      BooleanBindings.lookupFrom text (names ++ [added]) first after count =
        BooleanBindings.lookupFrom text names first after count := by
    induction count with
    | zero => rfl
    | succ count ih =>
        simp only [BooleanBindings.lookupFrom,
          boolean_append_binding names added (count + 1) (by omega) within, ih (by omega)]
  have newest : BooleanBindings.binding (names ++ [added]) (names.length + 1) = added := by
    simp [BooleanBindings.binding, List.getD_eq_getElem?_getD]
  by_cases invalid : first = 0 ∨ after ≤ first
  · simp only [BooleanBindings.lookup, List.length_append, List.length_singleton,
      BooleanBindings.lookupFrom, invalid, ite_true]
    cases names.length <;> simp only [BooleanBindings.lookupFrom, invalid, ite_true]
  · simp only [BooleanBindings.lookup, List.length_append, List.length_singleton,
      BooleanBindings.lookupFrom, invalid, ite_false, newest,
      apart, Bool.false_and, Bool.false_eq_true, loop names.length (Nat.le_refl _)]

private theorem hideOuter_boolean_unselected {text : Source} {frame : ParserState} {info : Metadata}
    {name : NameSpan} (accepted : (hideOuter text frame info name).position ≠ 0) :
    ∀ row ∈ (hideOuter text frame info name).booleanNames, booleanMatches text name row = false := by
  unfold hideOuter at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i allowed
    simp only [allowed]
    cases scalars : hideEntries (scalarMatches text name)
      (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first,item.after⟩) frame.scalarNames with
    | none => simp [scalars, invalidState] at accepted
    | some scalarRows =>
      cases booleans : hideEntries (booleanMatches text name)
        (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first,item.after⟩) frame.booleanNames with
      | none => simp [scalars, booleans, invalidState] at accepted
      | some booleanRows =>
        cases subtypes : hideEntries (subtypeMatches text name)
          (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first,item.after⟩) frame.subtypeNames.items with
        | none => simp [scalars, booleans, subtypes, invalidState] at accepted
        | some subtypeRows =>
          simp only [scalars, booleans, subtypes, Option.bind_some, pure, bind] at accepted ⊢
          split at accepted
          · rename_i checked
            simp only [ite_eq_left checked]
            exact hideEntries_unselected booleans
          · exact False.elim (accepted rfl)

private theorem scalar_binding_mem {names : ScalarExpression.Environment} {index : Nat}
    (positive : index ≠ 0) (within : index ≤ names.length) :
    ScalarExpression.binding names index ∈ names := by
  have live : index - 1 < names.length := by omega
  simp only [ScalarExpression.binding, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem live, Option.getD_some]
  exact List.getElem_mem live

private theorem boolean_binding_mem {names : BooleanBindings.Environment} {index : Nat}
    (positive : index ≠ 0) (within : index ≤ names.length) :
    BooleanBindings.binding names index ∈ names := by
  have live : index - 1 < names.length := by omega
  simp only [BooleanBindings.binding, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem live, Option.getD_some]
  exact List.getElem_mem live

private theorem appended_visible {text : Source} {base : ParserState} {info : Metadata}
    {out : ObjectResult} {index : Nat}
    (storage : Appended base out.name out)
    (apart : Named.equalName text out.name.first out.name.after
      (info.stateAt index).name.first (info.stateAt index).name.after = false)
    (visible : visibleState modelCalls text (booleanInitializerContext base out.name.first out.name.after)
      info index = true) :
    visibleState modelCalls text (contextOf ⟨out.frame, false, false⟩) info index = true := by
  have bounds := visibleState_guard visible
  dsimp only [modelCalls] at bounds
  have scalarBound := ScalarExpression.lookup_bound text base.scalarNames
    (info.stateAt index).name.first (info.stateAt index).name.after
  have flagBound := BooleanBindings.lookup_bound text base.booleanNames
    (info.stateAt index).name.first (info.stateAt index).name.after
  dsimp only [visibleState, modelCalls, booleanInitializerContext] at visible
  simp only [Nat.not_lt.mpr bounds.1, bounds.2, Bool.true_eq_false, or_self, ite_false] at visible
  dsimp only [visibleState, modelCalls, contextOf]
  simp only [Nat.not_lt.mpr bounds.1, bounds.2, Bool.true_eq_false, or_self, ite_false,
    scalar_body_lookup, ScalarExpression.bodyEnvironment_binding,
    ScalarExpression.bodyBinding_first, ScalarExpression.bodyBinding_after]
  cases kind : out.mark.kind with
  | integer =>
      obtain ⟨isStatic, stored, flags⟩ := storage.integerStorage kind
      rw [stored, flags, scalar_append_lookup _ _ _ _ _ apart]
      split at visible
      · rename_i integer
        have positive : ScalarExpression.lookup text base.scalarNames
            (info.stateAt index).name.first (info.stateAt index).name.after ≠ 0 := by
          simpa only [Bool.and_eq_true, decide_eq_true_eq] using (Bool.and_eq_true_iff.mp
            (Bool.and_eq_true_iff.mp visible).1).1
        rw [ScalarExpression.binding_append_old _ _ _ (Nat.pos_of_ne_zero positive) scalarBound]
        simpa only [integer, ite_true] using visible
      · rename_i flag
        simpa only [flag, ite_false] using visible
  | boolean =>
      obtain ⟨known, stored, scalars⟩ := storage.booleanStorage kind
      rw [scalars, stored, boolean_append_lookup _ _ _ _ _ apart]
      split at visible
      · rename_i integer
        simpa only [integer, ite_true] using visible
      · rename_i flag
        split at visible
        · contradiction
        · rename_i scalarZero
          have positive : BooleanBindings.lookup text base.booleanNames
              (info.stateAt index).name.first (info.stateAt index).name.after ≠ 0 := by
            exact of_decide_eq_true (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp visible).1).1
          rw [boolean_append_binding _ _ _ (Nat.pos_of_ne_zero positive) flagBound]
          simpa only [flag, scalarZero, ite_false] using visible

/-- Hiding removes every prior bare row with the new local's spelling. Hence
any global visible during the RHS is still visible after its declaration. -/
theorem object_visible {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : Metadata} {out : ObjectResult} {index : Nat}
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0)
    (visible : visibleState modelCalls text
      (booleanInitializerContext (initializerBase text frame info out.name true) out.name.first out.name.after)
      info index = true) :
    visibleState modelCalls text (contextOf ⟨out.frame, false, false⟩) info index = true := by
  have live := objectStep_hidden_live parsed present
  have storage := (objectStep_storage parsed present).1
  apply appended_visible storage ?_ visible
  have bounds := visibleState_guard visible
  dsimp only [modelCalls] at bounds
  dsimp only [visibleState, modelCalls, booleanInitializerContext, initializerBase] at visible
  simp only [ite_true, Nat.not_lt.mpr bounds.1, bounds.2, Bool.true_eq_false,
    or_self, ite_false] at visible
  split at visible
  · have selected := Bool.and_eq_true_iff.mp visible
    have positive := of_decide_eq_true (Bool.and_eq_true_iff.mp selected.1).1
    have first := of_decide_eq_true (Bool.and_eq_true_iff.mp selected.1).2
    have after := of_decide_eq_true selected.2
    have qualifier := scalarLookupFrom_qualifier (text := text)
      (names := (hideOuter text frame info out.name).scalarNames)
      (first := (info.stateAt index).name.first) (after := (info.stateAt index).name.after)
      (count := (hideOuter text frame info out.name).scalarNames.length)
      (qualifierFirst := 0) (qualifierAfter := 0) rfl positive
    simp only [QualifiedNames.qualifierMatches, ite_true, beq_iff_eq] at qualifier
    change (ScalarExpression.binding (hideOuter text frame info out.name).scalarNames
      (ScalarExpression.lookup text (hideOuter text frame info out.name).scalarNames
        (info.stateAt index).name.first (info.stateAt index).name.after)).qualifierFirst = 0 at qualifier
    have unselected := hideOuter_scalar_unselected live _
      (scalar_binding_mem positive (ScalarExpression.lookup_bound ..))
    simpa only [scalarMatches, qualifier, decide_true, Bool.true_and, first, after] using unselected
  · split at visible
    · contradiction
    · have selected := Bool.and_eq_true_iff.mp visible
      have positive := of_decide_eq_true (Bool.and_eq_true_iff.mp selected.1).1
      have first := of_decide_eq_true (Bool.and_eq_true_iff.mp selected.1).2
      have after := of_decide_eq_true selected.2
      have qualifier := booleanLookupFrom_qualifier (text := text)
        (names := (hideOuter text frame info out.name).booleanNames)
        (first := (info.stateAt index).name.first) (after := (info.stateAt index).name.after)
        (count := (hideOuter text frame info out.name).booleanNames.length)
        (qualifierFirst := 0) (qualifierAfter := 0) rfl positive
      simp only [QualifiedNames.qualifierMatches, ite_true, beq_iff_eq] at qualifier
      change (BooleanBindings.binding (hideOuter text frame info out.name).booleanNames
        (BooleanBindings.lookup text (hideOuter text frame info out.name).booleanNames
          (info.stateAt index).name.first (info.stateAt index).name.after)).qualifierFirst = 0 at qualifier
      have unselected := hideOuter_boolean_unselected live _
        (boolean_binding_mem positive (BooleanBindings.lookup_bound ..))
      simpa only [booleanMatches, qualifier, decide_true, Bool.true_and, first, after] using unselected

theorem object_read_masks {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : Metadata} {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0) (capacity : info.states.length ≤ maxStates) :
    ∀ cell ∈ info.effectCells (stateReads modelCalls text
      (booleanInitializerContext (initializerBase text frame info out.name true) out.name.first out.name.after)
      info out.initFirst out.initAfter),
      cell ∈ info.effectCells (stateReads modelCalls text
        (contextOf ⟨out.frame, false, false⟩) info out.initFirst out.initAfter) := by
  intro cell member
  obtain ⟨offset, inside, selected, same⟩ := (info.mem_effectCells _ _).mp member
  have bounds : offset + 1 ≤ maxStates := by omega
  have read := (stateReads_selected _ _ _ _ _ _ _ (by omega) (by omega) bounds).mp selected
  apply (info.mem_effectCells _ _).mpr
  refine ⟨offset, inside, ?_, same⟩
  exact (stateReads_selected _ _ _ _ _ _ _ (by omega) (by omega) bounds).mpr
    ⟨read.1, object_visible parsed present read.2.1, read.2.2⟩

private theorem scalar_syntax_source {text names maskFirst maskAfter allowSign position value}
    (source : ScalarExpression.SyntaxAt text names maskFirst maskAfter allowSign position value) :
    ScalarExpression.ArrayGrammar.SourceAt text names {} maskFirst maskAfter .allElements
      allowSign position value := by
  induction source with
  | atom positive bound notGroup atom => exact .ordinary positive bound notGroup atom
  | signed opened sign number closing => exact .signed opened sign number closing
  | unary opened sign absent _ closing ih => exact .unary opened sign absent ih closing
  | grouped opened sign _ closing ih => exact .grouped opened sign ih closing
  | binary opened sign _ positive bound operator _ combined closing left right =>
      exact .binary opened sign left positive bound operator right combined closing

private theorem scalar_syntax_reads {text : Source} {context : ParseContext} {info : Metadata}
    {bound position maskFirst maskAfter : Nat} {allowSign : Bool} {value : ScalarExpression.Parsed}
    (source : ScalarExpression.SyntaxAt text context.scalarNames maskFirst maskAfter allowSign position value)
    (positionBound : position ≤ text.length + 1)
    (declarations : StateDeclarations text info.states) (capacity : info.states.length ≤ maxStates) :
    ∀ cell ∈ globalCells (layout bound info context) (integerReads value.expression),
      cell ∈ info.effectCells (stateReads modelCalls text context info position value.after) := by
  intro cell member
  obtain ⟨localCell, read, selected⟩ := globalCells_mem.mp member
  cases localCell with
  | boolean slot => exact (integerReads_no_boolean value.expression slot read).elim
  | integer slot =>
      cases address : (layout bound info context).integers slot with
      | «local» _ => simp only [FrameLayout.place, address] at selected; contradiction
      | global identity =>
          have equal : cell = .integer identity := by
            simpa only [FrameLayout.place, address, Place.global.injEq] using selected.symm
          subst cell
          have live := slotAddress_global address
          have same := stateIndex_some live.2.2
          rw [scalarRows_get] at same
          dsimp only at same
          have name := declarations.name same.1 same.2.1
          have domain := (ApplicationPackageNames.Native.validName_domain name).2
          have found := scalar_source_original_lookup (scalar_syntax_source source) same.2.2.1
            (by rw [← same.2.2.2.2.1]; exact Nat.ne_of_gt domain.1)
            (by rw [← same.2.2.2.2.1, ← same.2.2.2.2.2]; exact domain.2.1) read
          rw [← same.2.2.2.2.1, ← same.2.2.2.2.2] at found
          have visible : visibleState modelCalls text context info identity = true := by
            simp only [visibleState, modelCalls, Nat.not_lt.mpr same.2.1, name, Bool.true_eq_false,
              or_self, ite_false, same.2.2.2.1, ite_true, found,
              decide_true, same.2.2.2.2.1.symm, same.2.2.2.2.2.symm]
            simpa only [Bool.and_true, decide_eq_true_eq] using (Nat.ne_of_gt live.1)
          have occurrence : actualNameFree text position value.after
              (info.stateAt identity).name.first (info.stateAt identity).name.after = false := by
            apply Bool.eq_false_iff.mpr
            intro free
            have absent := ((actualNameFree_sound free).scalarSyntax source positionBound (Nat.le_refl _) found).1
            rw [integerReads_integer value.expression slot read] at absent
            contradiction
          have bounds := ScalarExpression.syntax_bounds positionBound source
          have covered := (stateReads_cell _ _ _ _ _ _ _ same.1 same.2.1
            (Nat.le_trans same.2.1 capacity)).mpr ⟨by omega, visible, occurrence⟩
          simpa only [PackageBindings.StateDeclaration.cell, same.2.2.2.1] using covered

/-- The original Integer or Boolean RHS is included in the exact post-Object
native mask. The source expression keeps its preappend layout throughout. -/
theorem local_value_reads {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : Metadata} {out : ObjectResult} {bound : Nat} {item : LocalInitializer}
    (source : LocalValueAt bound info text frame out item)
    (framed : ReaderFrame text frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0)
    (declarations : StateDeclarations text info.states) (capacity : info.states.length ≤ maxStates) :
    ∀ cell ∈ globalCells item.layout (actualReads item.value),
      cell ∈ info.effectCells (stateReads modelCalls text (contextOf ⟨out.frame, false, false⟩)
        info out.initFirst out.initAfter) := by
  have firstBound := (parsed ▸ objectStep_initializer_bounds reader text frame info true (parsed ▸ present)).1
  have named : out.name = objectName text frame := by
    simpa only [parsed] using (objectStep_rows reader text frame info true (parsed ▸ present)).2.nameEq
  have base := object_initializer_frame reader text frame framed info true (parsed ▸ present)
  rw [← named] at base
  intro cell member
  apply object_read_masks parsed present capacity cell
  cases source with
  | integer kind reading =>
      exact scalar_syntax_reads
        (context := booleanInitializerContext (initializerBase text frame info out.name true)
          out.name.first out.name.after) reading firstBound declarations capacity cell member
  | boolean kind reading after =>
      exact ApplicationPackageSourceEffects.condition_global_reads reading
        (condition_source_input reading) firstBound (Nat.le_of_eq after) declarations capacity
        base.typed.scalarCount base.typed.booleanCount cell member

attribute [local irreducible] stateUnion

/-- Incoming masks and every post-Object read mask survive the complete local
declaration history in their original evaluation order. -/
theorem local_history_masks {calls : CompletionCalls} {text : Source} {info : Metadata}
    {routine : Routine} {before after : InitializationFrame} {rows : List LocalObject}
    (history : LocalObjects calls text info routine before rows after)
    (capacity : info.states.length ≤ maxStates) :
    (∀ cell ∈ info.effectCells before.reads, cell ∈ info.effectCells after.reads) ∧
    (∀ row ∈ rows, ∀ cell ∈ info.effectCells
      (calls.stateReads text (calls.contextOf ⟨row.object.frame, false, false⟩)
        info row.object.initFirst row.object.initAfter), cell ∈ info.effectCells after.reads) := by
  induction history with
  | finished => exact ⟨fun _ member => member, by simp⟩
  | @added row final following _ _ _ _ rest ih =>
    constructor
    · intro cell member
      apply ih.1 cell
      dsimp only [LocalObject.after]
      exact union_left capacity _ _ cell member
    · intro seen member cell selected
      rcases List.mem_cons.mp member with rfl | later
      · apply ih.1 cell
        dsimp only [LocalObject.after]
        exact union_right capacity _ _ cell selected
      · exact ih.2 seen later cell selected

theorem local_values_reads {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {info : Metadata} {rows : List LocalObject} {items : List LocalInitializer}
    {bound : Nat} {finalMask : StateSet}
    (source : LocalValuesAt bound info text rows items)
    (reads : calls.stateReads = stateReads modelCalls) (contexts : calls.contextOf = contextOf)
    (declarations : StateDeclarations text info.states) (capacity : info.states.length ≤ maxStates)
    (frames : ∀ row ∈ rows, ReaderFrame text row.before.frame)
    (objects : ∀ row ∈ rows, objectStep (modelObjectCalls reader) text row.before.frame info true = row.object)
    (present : ∀ row ∈ rows, row.object.frame.position ≠ 0)
    (masks : ∀ row ∈ rows, ∀ cell ∈ info.effectCells
      (calls.stateReads text (calls.contextOf ⟨row.object.frame, false, false⟩)
        info row.object.initFirst row.object.initAfter), cell ∈ info.effectCells finalMask) :
    ∀ cell ∈ initializerReads items, cell ∈ info.effectCells finalMask := by
  induction source with
  | nil => simp [initializerReads]
  | @cons row item rows items original rest ih =>
    intro cell member
    rcases List.mem_append.mp member with first | later
    · apply masks row List.mem_cons_self cell
      rw [reads, contexts]
      exact local_value_reads original (frames row List.mem_cons_self)
        (objects row List.mem_cons_self) (present row List.mem_cons_self) declarations capacity cell first
    · exact ih (fun seen member => frames seen (List.mem_cons_of_mem _ member))
        (fun seen member => objects seen (List.mem_cons_of_mem _ member))
        (fun seen member => present seen (List.mem_cons_of_mem _ member))
        (fun seen member => masks seen (List.mem_cons_of_mem _ member)) cell later

end Silver.ApplicationPackageLocalInitializerEffects
