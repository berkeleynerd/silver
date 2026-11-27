module

public import Silver.ApplicationPackageVisibleStateLayout

@[expose] public section

/-! Retained global rows cannot be shadowed by later bare rows. This narrow
history invariant allows arbitrary duplicates among unrelated local rows. -/
namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages ApplicationPackageEffects ApplicationPackageObjectRows
open ApplicationPackageDeclarations ApplicationPackageBodies ApplicationPackageFrames
open ApplicationPackageFormalStorage ApplicationPackageRoutineFrame

set_option backward.dsimp.instances true

def GlobalRow (states : List PackageBindings.StateDeclaration) (row : Row) : Prop :=
  ∃ state ∈ states, row.first = state.name.first

def GlobalRowsClear (text : Source) (states : List PackageBindings.StateDeclaration)
    (rows : List Row) : Prop :=
  rows.Pairwise fun older newer => GlobalRow states older → older.qualifierFirst = 0 →
    newer.qualifierFirst = 0 →
    Named.equalName text older.first older.after newer.first newer.after = false

def GlobalRowsApart (text : Source) (states : List PackageBindings.StateDeclaration)
    (rows : List Row) (names : List PackageBindings.NameSpan) : Prop :=
  ∀ row ∈ rows, GlobalRow states row → row.qualifierFirst = 0 → ∀ name ∈ names,
    Named.equalName text row.first row.after name.first name.after = false

theorem GlobalRowsClear.emptyStates (text : Source) (rows : List Row) : GlobalRowsClear text [] rows := by
  apply List.pairwise_iff_getElem.mpr
  intro i j _ _ _ global
  obtain ⟨state, member, _⟩ := global
  contradiction

theorem GlobalRowsClear.retain {text states before after}
    (prior : GlobalRowsClear text states before) (kept : after.Sublist before) :
    GlobalRowsClear text states after := prior.sublist kept

theorem GlobalRowsApart.retain {text states before after names}
    (prior : GlobalRowsApart text states before names) (kept : after.Sublist before) :
    GlobalRowsApart text states after names :=
  fun row member => prior row (kept.subset member)

theorem GlobalRowsClear.append {text states before added}
    (prior : GlobalRowsClear text states before)
    (localRows : ∀ row ∈ added, ¬GlobalRow states row)
    (apart : ∀ old ∈ before, GlobalRow states old → old.qualifierFirst = 0 →
      ∀ new ∈ added, new.qualifierFirst = 0 →
      Named.equalName text old.first old.after new.first new.after = false) :
    GlobalRowsClear text states (before ++ added) := by
  apply List.pairwise_append.mpr
  refine ⟨prior, ?_, ?_⟩
  · apply List.pairwise_iff_getElem.mpr
    intro i j hi _ _ global
    exact False.elim (localRows _ (List.getElem_mem hi) global)
  · intro old previous new installed global bare bareNew
    exact apart old previous global bare new installed bareNew

theorem GlobalRowsApart.append {text states before added names}
    (prior : GlobalRowsApart text states before names)
    (localRows : ∀ row ∈ added, ¬GlobalRow states row) :
    GlobalRowsApart text states (before ++ added) names := by
  intro row member global bare name selected
  rcases List.mem_append.mp member with old | new
  · exact prior row old global bare name selected
  · exact False.elim (localRows row new global)

theorem hideEntries_unselected {α : Type} {selected outer : α → Bool} {before after : List α}
    (checked : hideEntries selected outer before = some after) :
    ∀ row ∈ after, selected row = false := by
  induction before generalizing after with
  | nil => cases Option.some.inj checked; simp
  | cons item rest ih =>
    simp only [hideEntries] at checked
    split at checked
    · split at checked
      · exact ih checked
      · contradiction
    · rename_i absent
      obtain ⟨kept, next, rfl⟩ := Option.map_eq_some_iff.mp checked
      intro row member
      rcases List.mem_cons.mp member with same | later
      · subst row
        exact Bool.eq_false_iff.mpr absent
      · exact ih next row later

theorem hideOuter_scalar_unselected {text : Source} {frame : ParserState} {info : PackageBindings.Metadata}
    {name : PackageBindings.NameSpan} (accepted : (hideOuter text frame info name).position ≠ 0) :
    ∀ row ∈ (hideOuter text frame info name).scalarNames, scalarMatches text name row = false := by
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
            exact hideEntries_unselected scalars
          · exact False.elim (accepted rfl)

theorem equalName_false_symm {text : Source} {a b c d : Nat}
    (different : Named.equalName text a b c d = false) : Named.equalName text c d a b = false := by
  apply Bool.eq_false_iff.mpr
  intro same
  have symmetric := equalName_symm same
  rw [different] at symmetric
  contradiction

theorem hideOuter_scalar_apart {text : Source} {frame : ParserState} {info : PackageBindings.Metadata}
    {name : PackageBindings.NameSpan} (accepted : (hideOuter text frame info name).position ≠ 0)
    {row : Row} (member : row ∈ integerRows (hideOuter text frame info name)) (bare : row.qualifierFirst = 0) :
    Named.equalName text row.first row.after name.first name.after = false := by
  obtain ⟨original, stored, rfl⟩ := List.mem_map.mp member
  change original.qualifierFirst = 0 at bare
  have apart := hideOuter_scalar_unselected accepted original stored
  simp only [scalarMatches, bare, decide_true, Bool.true_and] at apart
  exact equalName_false_symm apart

theorem scalarLookupFrom_zero_apart {text : Source} {names : ScalarExpression.Environment}
    {first after count index : Nat}
    (missing : ScalarExpression.lookupFrom text names first after count = 0)
    (positive : first ≠ 0) (ordered : first < after) (indexPositive : 0 < index) (active : index ≤ count)
    (bare : (ScalarExpression.binding names index).qualifierFirst = 0) :
    Named.equalName text (ScalarExpression.binding names index).first
      (ScalarExpression.binding names index).after first after = false := by
  induction count with
  | zero => omega
  | succ count ih =>
    simp only [ScalarExpression.lookupFrom, positive, Nat.not_le.mpr ordered, or_self, ite_false] at missing
    split at missing
    · omega
    · rename_i absent
      by_cases last : index = count + 1
      · subst index
        simpa only [QualifiedNames.qualifierMatches, ite_true, bare, beq_self_eq_true, Bool.and_true] using
          Bool.eq_false_iff.mpr absent
      · exact ih missing (by omega)

theorem scalarLookup_zero_row {text : Source} {names : ScalarExpression.Environment}
    {first after : Nat} {row : ScalarExpression.Binding}
    (missing : ScalarExpression.lookup text names first after = 0)
    (positive : first ≠ 0) (ordered : first < after) (member : row ∈ names)
    (bare : row.qualifierFirst = 0) : Named.equalName text row.first row.after first after = false := by
  obtain ⟨offset, within, atOffset⟩ := List.getElem_of_mem member
  have installedBinding : ScalarExpression.binding names (offset + 1) = row := by
    simp only [ScalarExpression.binding, Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem within, Option.getD_some, atOffset]
  have apart := scalarLookupFrom_zero_apart missing positive ordered
    (by omega : 0 < offset + 1) (by omega) (installedBinding ▸ bare)
  simpa only [installedBinding] using apart

theorem GlobalRowsClear.after_state {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    (prior : GlobalRowsClear text info.states (integerRows frame))
    (source : StateFrame info.states frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info false = out)
    (present : out.frame.position ≠ 0) :
    GlobalRowsClear text (info.states ++ [stateDeclaration out]) (integerRows out.frame) := by
  have positions := parsed ▸ objectStep_positions reader text frame info false (parsed ▸ present)
  obtain ⟨storage, _, _⟩ := objectStep_storage parsed present
  have guards := objectStep_name_guards (parsed ▸ present)
  have nameEq := parsed ▸ (objectStep_rows reader text frame info false (parsed ▸ present)).2.nameEq
  rw [← nameEq] at guards
  have span := newNameAllowed_span text frame out.name.first out.name.after false guards.2
  have missing : ScalarExpression.lookup text frame.scalarNames out.name.first out.name.after = 0 := by
    have allowed := guards.2
    simp only [newNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
    exact allowed.1.1.2.2.1
  have extended : GlobalRowsClear text (info.states ++ [stateDeclaration out]) (integerRows frame) := by
    apply prior.imp_of_mem
    intro old new member _ apart global bare bareNew
    obtain ⟨state, declared, same⟩ := global
    rcases List.mem_append.mp declared with priorState | newState
    · exact apart ⟨state, priorState, same⟩ bare bareNew
    · cases List.mem_singleton.mp newState
      have earlier := Nat.lt_of_lt_of_le (source.order.1.before old member) positions.1
      exact False.elim (Nat.ne_of_lt earlier same)
  rw [storage.integers]
  change GlobalRowsClear text (info.states ++ [stateDeclaration out])
    (integerRows frame ++ (if out.mark.kind = .integer then [reference out.name] else []))
  split
  · apply List.pairwise_append.mpr
    refine ⟨extended, by simp, ?_⟩
    intro old member new installed _ bare _
    cases List.mem_singleton.mp installed
    obtain ⟨original, stored, rfl⟩ := List.mem_map.mp member
    exact scalarLookup_zero_row missing (Nat.ne_of_gt span.1) span.2 stored bare
  · simpa only [List.append_nil] using extended

theorem stateHistory_clear {reader : BooleanElaboration.Native.Reader} {calls : UnitCalls}
    {text : Source} {before after : UnitState} {rows : List StateObject}
    (history : StateObjects calls text before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.globals row.before.info false =
      objectStep (modelObjectCalls reader) text row.before.globals row.before.info false)
    (source : StateFrame before.info.states before.globals)
    (clear : GlobalRowsClear text before.info.states (integerRows before.globals)) :
    GlobalRowsClear text after.info.states (integerRows after.globals) := by
  induction history with
  | finished => exact clear
  | @added row following final phase chosen capacity parsed advances writable rest ih =>
    have object := ((original row List.mem_cons_self).symm.trans parsed)
    have present : row.object.frame.position ≠ 0 := by omega
    exact ih (fun seen member => original seen (List.mem_cons_of_mem _ member))
      (source.after_state object present writable) (clear.after_state source object present)

private theorem objectTyped_live {calls : ObjectCalls} {text : Source} {original : ParserState}
    {info : PackageBindings.Metadata} {first last colonEnd constantEnd : Nat} {localObject : Bool}
    {seed : ObjectResult}
    (accepted : (objectTyped calls text original info first last colonEnd constantEnd localObject seed).frame.position ≠ 0) :
    seed.frame.position ≠ 0 := by
  intro missing
  apply accepted
  unfold objectTyped
  rw [ite_eq_left (by simp only [missing, decide_true])]
  rfl

theorem objectStep_hidden_live {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0) : (hideOuter text frame info out.name).position ≠ 0 := by
  subst out
  have named := (objectStep_rows reader text frame info true present).2.nameEq
  rw [named]
  dsimp only [objectStep, objectNameStep] at present
  split at present
  · exact False.elim (present rfl)
  · exact objectTyped_live present

theorem object_reference_local {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    (source : StateFrame info.states frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0) : ¬GlobalRow info.states (reference out.name) := by
  obtain positions := parsed ▸ objectStep_positions reader text frame info true (parsed ▸ present)
  rintro ⟨state, member, same⟩
  have before := Nat.lt_of_lt_of_le (source.statesBefore state member) positions.1
  exact Nat.ne_of_gt before same

theorem GlobalRowsClear.after_local {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    (prior : GlobalRowsClear text info.states (integerRows frame))
    (source : StateFrame info.states frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0) : GlobalRowsClear text info.states (integerRows out.frame) := by
  obtain ⟨storage, kept, _⟩ := objectStep_storage parsed present
  rw [storage.integers]
  split
  · apply (prior.retain (kept.map _)).append
    · intro row member
      cases List.mem_singleton.mp member
      exact object_reference_local source parsed present
    · intro row member _ bare new installed _
      cases List.mem_singleton.mp installed
      exact hideOuter_scalar_apart (objectStep_hidden_live parsed present) member bare
  · simpa only [List.append_nil, integerRows] using prior.retain (kept.map _)

theorem GlobalRowsApart.after_local {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    {names : List PackageBindings.NameSpan}
    (prior : GlobalRowsApart text info.states (integerRows frame) names)
    (source : StateFrame info.states frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0) : GlobalRowsApart text info.states (integerRows out.frame) names := by
  obtain ⟨storage, kept, _⟩ := objectStep_storage parsed present
  rw [storage.integers]
  split
  · apply (prior.retain (kept.map _)).append
    intro row member
    cases List.mem_singleton.mp member
    exact object_reference_local source parsed present
  · simpa only [List.append_nil, integerRows] using prior.retain (kept.map _)

theorem localHistory_clear {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {before after : InitializationFrame} {rows : List LocalObject} {names : List PackageBindings.NameSpan}
    (history : LocalObjects calls text info item before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true)
    (source : StateFrame info.states before.frame)
    (clear : GlobalRowsClear text info.states (integerRows before.frame))
    (apart : GlobalRowsApart text info.states (integerRows before.frame) names) :
    GlobalRowsClear text info.states (integerRows after.frame) ∧
      GlobalRowsApart text info.states (integerRows after.frame) names := by
  induction history with
  | finished => exact ⟨clear, apart⟩
  | @added row final following atBegin separate parsed advances rest ih =>
    have object := ((original row List.mem_cons_self).symm.trans parsed)
    have present : row.object.frame.position ≠ 0 := by omega
    exact ih (fun seen member => original seen (List.mem_cons_of_mem _ member))
      (source.after_object object present) (clear.after_local source object present)
      (apart.after_local source object present)

theorem GlobalRowsApart.select {text states rows all kept}
    (prior : GlobalRowsApart text states rows all) (subset : ∀ name ∈ kept, name ∈ all) :
    GlobalRowsApart text states rows kept :=
  fun row member global bare name selected => prior row member global bare name (subset name selected)

private theorem formal_rows_local {states : List PackageBindings.StateDeclaration}
    {formals : List PackageBindings.Formal} {rows : List Row}
    (references : rows.Sublist (ApplicationPackageFormalStorage.references formals))
    (distinct : ∀ formal ∈ formals, ∀ state ∈ states, formal.bodyName.first ≠ state.name.first) :
    ∀ row ∈ rows, ¬GlobalRow states row := by
  intro row member global
  obtain ⟨formal, declared, rfl⟩ := List.mem_map.mp (references.subset member)
  obtain ⟨state, active, same⟩ := global
  exact distinct formal declared state active same

theorem stored_global_clear {text : Source} {states : List PackageBindings.StateDeclaration}
    {before after : ParserState} {formals : List PackageBindings.Formal}
    (stored : Stored before after formals)
    (prior : GlobalRowsClear text states (integerRows before))
    (apart : GlobalRowsApart text states (integerRows before) (formals.map (·.bodyName)))
    (distinct : ∀ formal ∈ formals, ∀ state ∈ states, formal.bodyName.first ≠ state.name.first) :
    GlobalRowsClear text states (integerRows after) := by
  obtain ⟨integers, _, refs, _, table, _⟩ := stored.references
  rw [table]
  apply prior.append (formal_rows_local refs distinct)
  intro old member global bare new installed _
  obtain ⟨formal, declared, rfl⟩ := List.mem_map.mp (refs.subset installed)
  exact apart old member global bare formal.bodyName (List.mem_map_of_mem declared)

theorem stored_global_apart {text : Source} {states : List PackageBindings.StateDeclaration}
    {before after : ParserState} {formals : List PackageBindings.Formal} {names : List PackageBindings.NameSpan}
    (stored : Stored before after formals)
    (prior : GlobalRowsApart text states (integerRows before) names)
    (distinct : ∀ formal ∈ formals, ∀ state ∈ states, formal.bodyName.first ≠ state.name.first) :
    GlobalRowsApart text states (integerRows after) names := by
  obtain ⟨integers, _, refs, _, table, _⟩ := stored.references
  rw [table]
  exact prior.append (formal_rows_local refs distinct)

private theorem hideParameter_scalar {calls : ApplicationPackageRoutineFrame.Calls}
    (native : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    {text : Source} {info : PackageBindings.Metadata} {frame after : ParserState} {index : Nat}
    (run : hideParameter calls text info frame index = some after) :
    after.scalarNames.Sublist frame.scalarNames ∧
      ∀ row ∈ integerRows after, row.qualifierFirst = 0 →
        Named.equalName text row.first row.after
          (info.parameterAt index).bodyName.first (info.parameterAt index).bodyName.after = false := by
  dsimp only [hideParameter] at run
  split at run
  · contradiction
  · split at run
    · contradiction
    · rename_i present
      cases run
      rw [native] at present ⊢
      exact ⟨(ApplicationPackageFrames.Native.hideOuter_frame present).2.1,
        fun _ member bare => hideOuter_scalar_apart present member bare⟩

theorem hideParameters_scalar {calls : ApplicationPackageRoutineFrame.Calls}
    (native : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    {text : Source} {info : PackageBindings.Metadata} (indices : List Nat) {frame after : ParserState}
    (run : parameters (hideParameter calls text info) indices frame = some after) :
    after.scalarNames.Sublist frame.scalarNames ∧
      ∀ index ∈ indices, ∀ row ∈ integerRows after, row.qualifierFirst = 0 →
        Named.equalName text row.first row.after
          (info.parameterAt index).bodyName.first (info.parameterAt index).bodyName.after = false := by
  induction indices generalizing frame with
  | nil => cases run; exact ⟨.refl _, by simp⟩
  | cons index rest ih =>
    simp only [parameters] at run
    obtain ⟨middle, step, finish⟩ := Option.bind_eq_some_iff.mp run
    have first := hideParameter_scalar native step
    have remaining := ih finish
    refine ⟨remaining.1.trans first.1, ?_⟩
    intro current chosen row member bare
    rcases List.mem_cons.mp chosen with same | later
    · subst current
      exact first.2 row ((remaining.1.map _).subset member) bare
    · exact remaining.2 current later row member bare

theorem routineFrame_hidden {calls : ApplicationPackageRoutineFrame.Calls}
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {text : Source} {globals after : ParserState} {info : PackageBindings.Metadata} {routine position : Nat}
    (parsed : routineFrame calls text globals info routine position = after) (present : after.position ≠ 0) :
    ∃ hidden, parameters (hideParameter calls text info) (formalIndices (info.routineAt routine))
      (entryFrame calls globals position) = some hidden ∧
      Stored hidden after (chosen false info (formalIndices (info.routineAt routine))) := by
  unfold routineFrame withItem at parsed
  split at parsed
  · cases parsed; exact False.elim (present rfl)
  · split at parsed
    · cases parsed; exact False.elim (present rfl)
    · dsimp only at parsed
      split at parsed
      · cases parsed; exact False.elim (present rfl)
      · rename_i hidden hiddenRun
        split at parsed
        · cases parsed; exact False.elim (present rfl)
        · rename_i result stored
          split at parsed
          · cases parsed
            exact ⟨hidden, hiddenRun, parameters_stored append info _ stored⟩
          · cases parsed; exact False.elim (present rfl)

theorem routineFrame_clear {calls : ApplicationPackageRoutineFrame.Calls}
    (body : calls.bodyEnvironment = ScalarExpression.bodyEnvironment)
    (hide : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {text : Source} {globals after : ParserState} {info : PackageBindings.Metadata} {routine position : Nat}
    (source : StateFrame info.states globals)
    (window : HeaderWindow globals.position position ((formalIndices (info.routineAt routine)).map info.parameterAt))
    (prior : GlobalRowsClear text info.states (integerRows globals))
    (parsed : routineFrame calls text globals info routine position = after) (present : after.position ≠ 0) :
    GlobalRowsClear text info.states (integerRows after) ∧
      GlobalRowsApart text info.states (integerRows after)
        ((formalIndices (info.routineAt routine)).map (fun index => (info.parameterAt index).bodyName)) := by
  obtain ⟨hidden, read, stored⟩ := routineFrame_hidden append parsed present
  have retained := hideParameters_scalar hide _ read
  have entry : integerRows (entryFrame calls globals position) = integerRows globals := by
    simp only [integerRows, entryFrame, body, ScalarExpression.bodyEnvironment, List.map_map,
      Function.comp_def, ScalarExpression.bodyBinding]
  have kept : (integerRows hidden).Sublist (integerRows globals) := by
    rw [← entry]
    exact retained.1.map _
  have apart : GlobalRowsApart text info.states (integerRows hidden)
      ((formalIndices (info.routineAt routine)).map (fun index => (info.parameterAt index).bodyName)) := by
    intro row member _ bare name declared
    obtain ⟨index, selected, rfl⟩ := List.mem_map.mp declared
    exact retained.2 index selected row member bare
  have distinct : ∀ formal ∈ chosen false info (formalIndices (info.routineAt routine)),
      ∀ state ∈ info.states, formal.bodyName.first ≠ state.name.first := by
    intro formal member state declared
    exact Nat.ne_of_gt (Nat.lt_of_lt_of_le (source.statesBefore state declared)
      (window.entries formal ((chosen_sublist false info _).subset member)).1)
  refine ⟨stored_global_clear stored (prior.retain kept) ?_ distinct,
    stored_global_apart stored apart distinct⟩
  apply apart.select
  intro name member
  obtain ⟨formal, chosen, rfl⟩ := List.mem_map.mp member
  obtain ⟨index, selected, rfl⟩ := List.mem_map.mp ((chosen_sublist false info _).subset chosen)
  exact List.mem_map_of_mem selected

theorem scalarLookup_selected {text : Source} {names : ScalarExpression.Environment}
    {first after slot : Nat} (positive : first ≠ 0) (ordered : first < after)
    (slotPositive : 0 < slot) (active : slot ≤ names.length)
    (matching : (Named.equalName text (ScalarExpression.binding names slot).first
      (ScalarExpression.binding names slot).after first after &&
      QualifiedNames.qualifierMatches text (ScalarExpression.binding names slot).qualifierFirst
        (ScalarExpression.binding names slot).qualifierAfter 0 0) = true)
    (later : ∀ index, slot < index → index ≤ names.length →
      (Named.equalName text (ScalarExpression.binding names index).first
        (ScalarExpression.binding names index).after first after &&
        QualifiedNames.qualifierMatches text (ScalarExpression.binding names index).qualifierFirst
          (ScalarExpression.binding names index).qualifierAfter 0 0) = false) :
    ScalarExpression.lookup text names first after = slot := by
  have scan (count : Nat) (inside : slot ≤ count) (bounded : count ≤ names.length) :
      ScalarExpression.lookupFrom text names first after count = slot := by
    induction count with
    | zero => omega
    | succ count ih =>
      simp only [ScalarExpression.lookupFrom, positive, Nat.not_le.mpr ordered, or_self, ite_false]
      by_cases same : slot = count + 1
      · rw [← same, matching]
        rfl
      · rw [later (count + 1) (by omega) bounded]
        exact ih (by omega) (by omega)
  exact scan names.length active (Nat.le_refl _)

theorem GlobalRowsClear.integer_lookup {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {slot identity bound : Nat}
    (clear : GlobalRowsClear text info.states (scalarRows context))
    (source : StateDeclarations text info.states)
    (selected : (layout bound info context).integers slot = .global identity) :
    ScalarExpression.lookup text context.scalarNames
      (info.stateAt identity).name.first (info.stateAt identity).name.after = slot := by
  have live := slotAddress_global selected
  have state := stateIndex_some live.2.2
  rw [scalarRows_get] at state
  dsimp only at state
  have bounded : slot ≤ context.scalarNames.length := by
    simpa only [scalarRows, List.length_map] using live.2.1
  have domain := (ApplicationPackageNames.Native.validName_domain (source.name state.1 state.2.1)).2
  apply scalarLookup_selected (Nat.ne_of_gt domain.1) domain.2.1 live.1 bounded
  · simp [state.2.2.1, state.2.2.2.2.1.symm, state.2.2.2.2.2.symm,
      Named.equalName, QualifiedNames.qualifierMatches]
  · intro index newer within
    by_cases bare : (ScalarExpression.binding context.scalarNames index).qualifierFirst = 0
    · have oldIndex : slot - 1 < context.scalarNames.length := by omega
      have newIndex : index - 1 < context.scalarNames.length := by omega
      have pairwise := (List.pairwise_map.mp clear)
      have apart := pairwise.rel_getElem_of_lt oldIndex newIndex (by omega : slot - 1 < index - 1)
      have names : Named.equalName text (ScalarExpression.binding context.scalarNames slot).first
          (ScalarExpression.binding context.scalarNames slot).after
          (ScalarExpression.binding context.scalarNames index).first
          (ScalarExpression.binding context.scalarNames index).after = false := by
        apply (show GlobalRow info.states
            ⟨(ScalarExpression.binding context.scalarNames slot).first,
              (ScalarExpression.binding context.scalarNames slot).after,
              (ScalarExpression.binding context.scalarNames slot).qualifierFirst,
              (ScalarExpression.binding context.scalarNames slot).qualifierAfter⟩ →
            (ScalarExpression.binding context.scalarNames slot).qualifierFirst = 0 →
            (ScalarExpression.binding context.scalarNames index).qualifierFirst = 0 → _ from by
          simpa only [ScalarExpression.binding, List.getD_eq_getElem?_getD,
            List.getElem?_eq_getElem oldIndex, List.getElem?_eq_getElem newIndex, Option.getD_some] using apart)
        · exact ⟨info.stateAt identity, info.stateAt_mem identity state.1 state.2.1,
            state.2.2.2.2.1.symm⟩
        · exact state.2.2.1
        · exact bare
      rw [← state.2.2.2.2.1, ← state.2.2.2.2.2] at names
      simp only [equalName_false_symm names, Bool.false_and]
    · simp only [QualifiedNames.qualifierMatches, ite_true, beq_eq_false_iff_ne.mpr bare,
        Bool.and_false]

theorem GlobalRowsClear.integer_visible {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {slot identity bound : Nat}
    (clear : GlobalRowsClear text info.states (scalarRows context))
    (source : StateDeclarations text info.states)
    (selected : (layout bound info context).integers slot = .global identity) :
    visibleState ApplicationPackageEffects.modelCalls text context info identity = true := by
  have live := slotAddress_global selected
  have state := stateIndex_some live.2.2
  rw [scalarRows_get] at state
  dsimp only at state
  have found := clear.integer_lookup source selected
  simp [visibleState, ApplicationPackageEffects.modelCalls, Nat.not_lt.mpr state.2.1,
    source.name state.1 state.2.1, state.2.2.2.1, found, Nat.ne_of_gt live.1,
    state.2.2.2.2.1.symm, state.2.2.2.2.2.symm]

theorem resetSlots_global_iff {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet} {bound slot : Nat}
    (source : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (scalarRows context)) :
    slot ∈ ApplicationPackageCalls.resetSlots ApplicationPackageCalls.modelCalls text context info writes
      ((List.range info.states.length).map (· + 1)) ↔
    ∃ identity, (layout bound info context).integers slot = .global identity ∧
      ScalarProcedures.Cell.integer identity ∈ info.effectCells writes := by
  unfold ApplicationPackageCalls.resetSlots
  constructor
  · intro member
    obtain ⟨index, present, found⟩ := List.mem_filterMap.mp member
    obtain ⟨offset, active, rfl⟩ := List.mem_map.mp present
    have bounded := List.mem_range.mp active
    dsimp only at found
    split at found
    · rename_i chosen
      cases found
      have global := visible_integer_global source (by omega : 0 < offset + 1) chosen.2.1 chosen.2.2 (bound := bound)
      refine ⟨offset + 1, global, ?_⟩
      have written := (PackageBindings.Metadata.effectCells_index
        (by omega : 0 < offset + 1) (by omega : offset + 1 ≤ info.states.length)).mpr chosen.1
      simpa only [PackageBindings.StateDeclaration.cell, chosen.2.2] using written
    · contradiction
  · rintro ⟨identity, global, written⟩
    have state := stateIndex_some (slotAddress_global global).2.2
    have selected : PackageBindings.StateSet.get writes identity = true :=
      (PackageBindings.Metadata.effectCells_index state.1 state.2.1).mp
        (by simpa only [PackageBindings.StateDeclaration.cell, state.2.2.2.1] using written)
    have visible := clear.integer_visible source global
    have lookup := clear.integer_lookup source global
    apply List.mem_filterMap.mpr
    refine ⟨identity, ?_, ?_⟩
    · exact List.mem_map.mpr ⟨identity - 1, List.mem_range.mpr (by omega), Nat.sub_add_cancel state.1⟩
    · simp only [ApplicationPackageCalls.modelCalls, selected, visible, state.2.2.2.1,
        and_self, ite_true, lookup]

theorem resetSlots_declared {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet} {bound slot : Nat}
    (source : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (scalarRows context))
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (fields : ScalarStateFields info.states context.scalarNames)
    (selected : slot ∈ ApplicationPackageCalls.resetSlots ApplicationPackageCalls.modelCalls text context info writes
      ((List.range info.states.length).map (· + 1))) :
    context.analysis.declared slot = some (ScalarExpression.binding context.scalarNames slot).declaredBounds := by
  obtain ⟨identity, global, _⟩ := (resetSlots_global_iff source clear (bound := bound)).mp selected
  have rows := fields.globalRows (bound := bound)
  have declared := (scalar_global_analysis capacity ready rows global).1
  rw [← (rows slot identity global).1] at declared
  exact declared

theorem resetSlotsFlow_source {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet} (bound : Nat)
    (source : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (scalarRows context))
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (fields : ScalarStateFields info.states context.scalarNames) (flow : Flow) :
    ApplicationPackageCalls.resetSlotsFlow context.scalarNames
      (ApplicationPackageCalls.resetSlots ApplicationPackageCalls.modelCalls text context info writes
        ((List.range info.states.length).map (· + 1))) flow =
      resetGlobalFlow context.analysis.declared (layout bound info context) (info.effectCells writes) flow :=
  ApplicationPackageCalls.resetSlotsFlow_global
    (fun _ => resetSlots_global_iff source clear)
    (fun _ selected => resetSlots_declared source clear capacity ready fields selected (bound := bound)) flow

end Silver.ApplicationPackageFrameLayout
