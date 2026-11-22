module

public import Silver.ApplicationPackageCallsSemantics

@[expose] public section

/-! Conditions and effects extracted from successful raw call stages. These
facts quantify over every formal, actual and state bit in the native ranges;
source-helper meaning and actual-expression interpretation remain separate. -/
namespace Silver.ApplicationPackageCalls
open ApplicationPackages

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def AliasSafe (calls : Calls) (text : Source) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (actuals : List PackageActual) (index : Nat) : Prop :=
  let actual := actuals.getD (index - 1) {}
  (List.range info.states.length).any (fun state =>
      PackageBindings.StateSet.get item.mayWrite (state + 1) &&
      PackageBindings.StateSet.get actual.reads (state + 1)) ≠ true ∧
  ((info.parameterAt index).mode ≠ .input →
    ¬(actual.writtenState ≠ 0 ∧
      (PackageBindings.StateSet.get item.mayRead actual.writtenState = true ∨
       PackageBindings.StateSet.get item.mayWrite actual.writtenState = true)) ∧
    (formalSlots item).any (fun other => decide (index ≠ other) &&
      !calls.actualNameFree text (actuals.getD (other - 1) {}).first
        (actuals.getD (other - 1) {}).after actual.target.first actual.target.after) ≠ true)

theorem aliasStep_safe {calls text info item actuals before index after}
    (accepted : aliasStep calls text info item actuals before index = some after) :
    AliasSafe calls text info item actuals index := by
  unfold aliasStep at accepted
  dsimp only at accepted
  split at accepted
  · cases accepted
  · rename_i noImplicit
    split at accepted
    · rename_i inputMode
      exact ⟨noImplicit, fun writable => False.elim (writable inputMode)⟩
    · split at accepted
      · cases accepted
      · rename_i noCapture
        split at accepted
        · cases accepted
        · rename_i noExplicit
          exact ⟨noImplicit, fun _ => ⟨noCapture, noExplicit⟩⟩

private theorem aliasFold_safe {calls text info item actuals} (slots : List Nat)
    {before after : ApplicationCall}
    (accepted : slots.foldlM (aliasStep calls text info item actuals) before = some after) :
    ∀ index ∈ slots, AliasSafe calls text info item actuals index := by
  induction slots generalizing before with
  | nil => simp
  | cons head rest ih =>
      cases first : aliasStep calls text info item actuals before head with
      | none => simp [List.foldlM, first] at accepted
      | some middle =>
          have remaining : rest.foldlM (aliasStep calls text info item actuals) middle = some after := by
            simpa [List.foldlM, first] using accepted
          intro index present
          rcases List.mem_cons.mp present with rfl | present
          · exact aliasStep_safe first
          · exact ih remaining index present

theorem checkAliases_safe {calls text info item frame checked}
    (accepted : checkAliases calls text info item frame = some checked) :
    ∀ index ∈ formalSlots item, AliasSafe calls text info item frame.actuals index :=
  aliasFold_safe (formalSlots item) accepted

abbrev footprint (value : ApplicationCall) : PackageBindings.StateSet × PackageBindings.StateSet :=
  (value.result.reads, value.result.writes)

theorem aliasStep_footprint {calls text info item actuals before index after}
    (accepted : aliasStep calls text info item actuals before index = some after) :
    footprint after = footprint before := by
  unfold aliasStep at accepted
  dsimp only at accepted
  split at accepted
  · cases accepted
  · split at accepted
    · exact congrArg footprint (Option.some.inj accepted).symm
    · split at accepted
      · cases accepted
      · split at accepted
        · cases accepted
        · cases Option.some.inj accepted
          rfl

private theorem aliasFold_footprint {calls text info item actuals} (slots : List Nat)
    {before after : ApplicationCall}
    (accepted : slots.foldlM (aliasStep calls text info item actuals) before = some after) :
    footprint after = footprint before := by
  induction slots generalizing before with
  | nil => exact congrArg footprint (Option.some.inj accepted).symm
  | cons head rest ih =>
      cases first : aliasStep calls text info item actuals before head with
      | none => simp [List.foldlM, first] at accepted
      | some middle =>
          have remaining : rest.foldlM (aliasStep calls text info item actuals) middle = some after := by
            simpa [List.foldlM, first] using accepted
          exact (ih remaining).trans (aliasStep_footprint first)

theorem checkAliases_footprint {calls text info item frame checked}
    (accepted : checkAliases calls text info item frame = some checked) :
    footprint checked = footprint frame.result := aliasFold_footprint (formalSlots item) accepted

theorem resetState_footprint (calls : Calls) (text : Source) (context : Predicate.ParseContext)
    (info : PackageBindings.Metadata) (writes : PackageBindings.StateSet)
    (result : ApplicationCall) (index : Nat) :
    footprint (resetState calls text context info writes result index) = footprint result := by
  unfold resetState
  dsimp only
  split <;> rfl

private theorem resetFold_footprint (calls : Calls) (text : Source) (context : Predicate.ParseContext)
    (info : PackageBindings.Metadata) (writes : PackageBindings.StateSet)
    (indices : List Nat) (result : ApplicationCall) :
    footprint (indices.foldl (fun value index => resetState calls text context info writes value (index + 1)) result) =
      footprint result := by
  induction indices generalizing result with
  | nil => rfl
  | cons head rest ih =>
      exact (ih _).trans (resetState_footprint calls text context info writes result (head + 1))

theorem finishCall_footprint (calls : Calls) (text : Source) (context : Predicate.ParseContext)
    (info : PackageBindings.Metadata) (kind : PackageBindings.RoutineKind)
    (item : PackageBindings.Routine) (frame : ActualFrame) (checked : ApplicationCall) :
    footprint (finishCall calls text context info kind item frame checked) =
      (PackageBindings.stateUnion checked.result.reads item.mayRead,
       PackageBindings.stateUnion checked.result.writes frame.callWrites) := by
  have preserved := resetFold_footprint calls text context info frame.callWrites
    (List.range info.states.length)
    {checked with result := {checked.result with
      reads := PackageBindings.stateUnion checked.result.reads item.mayRead,
      writes := PackageBindings.stateUnion checked.result.writes frame.callWrites}}
  simpa only [finishCall, footprint] using preserved

theorem accepted_aliases {calls text context input info position kind}
    (accepted : (packageCallAt calls text context input info position kind).value.after ≠ 0) :
    ∃ callee item frame checked,
      callee = packageCallee calls text context info position kind ∧ callee ≠ 0 ∧
      item = info.routineAt callee ∧
      readActuals calls text context input info item (calls.reference text position).after = some frame ∧
      (∀ index ∈ formalSlots item, AliasSafe calls text info item frame.actuals index) ∧
      checkAliases calls text info item frame = some checked ∧
      footprint (packageCallAt calls text context input info position kind) =
        (PackageBindings.stateUnion frame.result.result.reads item.mayRead,
         PackageBindings.stateUnion frame.result.result.writes frame.callWrites) := by
  obtain ⟨callee, item, frame, checked, found, present, selected, _, read, aliases, returned, _, _⟩ :=
    accepted_call accepted
  refine ⟨callee, item, frame, checked, found, present, selected, read, checkAliases_safe aliases, aliases, ?_⟩
  rw [returned, finishCall_footprint]
  have same := checkAliases_footprint aliases
  exact congrArg (fun pair =>
    (PackageBindings.stateUnion pair.1 item.mayRead, PackageBindings.stateUnion pair.2 frame.callWrites)) same

end Silver.ApplicationPackageCalls
