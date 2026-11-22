module

public import Silver.ApplicationPackageCallsModel
public import Silver.PackageChecking
public import Silver.PackageBindingsEquations

@[expose] public section

/-! Package calls resolve into the actual completion prefix supplied at their
source position. These lemmas expose the native lookup and derive semantic
signature validity from checked metadata; no final completion table or assumed
callee safety is substituted for that prefix. Actual-expression and alias/effect
correspondence remain separate obligations. -/
namespace Silver.ApplicationPackageCalls

open ApplicationPackages

def completedEnvironment (info : PackageBindings.Metadata) : Packages.EffectEnvironment :=
  (info.routines.take info.completed).map fun item => ⟨item.signature info, item.effects info⟩

theorem callee_trace {calls text context info position kind callee}
    (found : packageCallee calls text context info position kind = callee) (accepted : callee ≠ 0) :
    info.completed ≤ info.routines.length ∧ (calls.reference text position).after ≠ 0 ∧
    callee = calls.lookupRoutine text info
      ⟨(calls.reference text position).first, (calls.reference text position).after⟩ true ∧
    (info.routineAt callee).kind = kind := by
  simp only [packageCallee] at found
  split at found
  · exact False.elim (accepted found.symm)
  · rename_i available
    split at found
    · exact False.elim (accepted found.symm)
    · split at found
      · exact False.elim (accepted found.symm)
      · split at found
        · rename_i selected
          exact ⟨Nat.le_of_not_gt (fun h => available (Or.inl h)),
            fun h => available (Or.inr h), found.symm, found ▸ selected.2⟩
        · exact False.elim (accepted found.symm)

theorem completedEnvironment_lookup (info : PackageBindings.Metadata) (identity : Nat)
    (positive : 0 < identity) (prefixBound : identity ≤ info.completed)
    (available : info.completed ≤ info.routines.length) :
    Packages.lookupRoutine (completedEnvironment info) identity =
      some ⟨(info.routineAt identity).signature info, (info.routineAt identity).effects info⟩ := by
  have index : identity - 1 < info.routines.length := by omega
  have inside : identity - 1 < info.completed := by omega
  simp only [Packages.lookupRoutine, completedEnvironment, Nat.ne_of_gt positive, ↓reduceIte,
    List.getElem?_map, List.getElem?_take_of_lt inside,
    Option.map_some, PackageBindings.Metadata.routineAt, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem index, Option.getD_some]

/-- Only the imported routine lookup is identified here. Its complete source
meaning is discharged by the native package-metadata bridge. -/
theorem callee_completed {calls text context info position kind callee}
    (found : packageCallee calls text context info position kind = callee) (accepted : callee ≠ 0)
    (lookup : calls.lookupRoutine text info
        ⟨(calls.reference text position).first, (calls.reference text position).after⟩ true =
      PackageBindings.lookupRoutine ⟨1, text⟩ info
        ⟨(calls.reference text position).first, (calls.reference text position).after⟩ true) :
    0 < callee ∧ callee ≤ info.completed ∧ (info.routineAt callee).kind = kind ∧
    Packages.lookupRoutine (completedEnvironment info) callee =
      some ⟨(info.routineAt callee).signature info, (info.routineAt callee).effects info⟩ := by
  obtain ⟨available, _, selected, kindEq⟩ := callee_trace found accepted
  have prefixBound : callee ≤ info.completed := by
    rw [selected, lookup]
    exact PackageBindings.lookupFrom_bound _ _ _ _
  exact ⟨Nat.pos_of_ne_zero accepted, prefixBound, kindEq,
    completedEnvironment_lookup info callee (Nat.pos_of_ne_zero accepted) prefixBound available⟩

theorem accepted_signature {calls text context input info position kind}
    (typed : info.Typed) (valid : PackageBindings.validMetadata ⟨1, text⟩ info = true)
    (accepted : (packageCallAt calls text context input info position kind).value.after ≠ 0)
    (lookup : calls.lookupRoutine text info
        ⟨(calls.reference text position).first, (calls.reference text position).after⟩ true =
      PackageBindings.lookupRoutine ⟨1, text⟩ info
        ⟨(calls.reference text position).first, (calls.reference text position).after⟩ true) :
    ∃ callee item frame checked,
      0 < callee ∧ callee ≤ info.completed ∧ item = info.routineAt callee ∧ item.kind = kind ∧
      Packages.lookupRoutine (completedEnvironment info) callee =
        some ⟨item.signature info, item.effects info⟩ ∧ (item.signature info).Valid ∧
      readActuals calls text context input info item (calls.reference text position).after = some frame ∧
      checkAliases calls text info item frame = some checked ∧
      packageCallAt calls text context input info position kind =
        finishCall calls text context info kind item frame checked := by
  obtain ⟨callee, item, frame, checked, calleeEq, present, itemEq, _, read, aliases, result, _, _⟩ :=
    accepted_call accepted
  obtain ⟨positive, prefixBound, kindEq, resolved⟩ := callee_completed calleeEq.symm present lookup
  have available := (callee_trace calleeEq.symm present).1
  have signature := PackageBindings.routine_signature_valid typed valid positive (Nat.le_trans prefixBound available)
  subst item
  exact ⟨callee, info.routineAt callee, frame, checked, positive, prefixBound, rfl, kindEq,
    resolved, signature, read, aliases, result⟩

/-- The actual native metadata helper is linked by representation, and its
meaning is derived from its complete typed definition equations. The guard
needed by Lookup_Routine comes from this accepted call's completion prefix;
neither a final environment nor a new entry precondition is substituted. -/
theorem accepted_signature_native_metadata {calls text context input info position kind}
    (metadata : PackageBindings.Native.Calls)
    (primitives : PackageBindings.Native.Primitives metadata)
    (equations : PackageBindings.Native.Equations metadata)
    (linked : ∀ name completedOnly,
      calls.lookupRoutine text info name completedOnly =
        metadata.lookupRoutine ⟨1, text⟩ info name completedOnly)
    (typed : info.Typed) (valid : PackageBindings.validMetadata ⟨1, text⟩ info = true)
    (accepted : (packageCallAt calls text context input info position kind).value.after ≠ 0) :
    ∃ callee item frame checked,
      0 < callee ∧ callee ≤ info.completed ∧ item = info.routineAt callee ∧ item.kind = kind ∧
      Packages.lookupRoutine (completedEnvironment info) callee =
        some ⟨item.signature info, item.effects info⟩ ∧ (item.signature info).Valid ∧
      readActuals calls text context input info item (calls.reference text position).after = some frame ∧
      checkAliases calls text info item frame = some checked ∧
      packageCallAt calls text context input info position kind =
        finishCall calls text context info kind item frame checked := by
  obtain ⟨callee, _, _, _, found, present, _⟩ := accepted_call accepted
  have bound := (callee_trace found.symm present).1
  apply accepted_signature typed valid accepted
  rw [linked, equations.lookupRoutine _ _ _ _ bound,
    PackageBindings.Native.interpreted_routineLookup metadata primitives equations
      ⟨1, text⟩ info _ _ (by simpa using bound)]
  rfl

end Silver.ApplicationPackageCalls
