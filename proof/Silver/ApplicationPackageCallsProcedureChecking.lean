module

public import Silver.ApplicationPackageCallsArgumentAliases

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages ScalarProcedures

private theorem lookup_completed_signature {info : PackageBindings.Metadata} {callee : Nat}
    (positive : 0 < callee)
    (found : Packages.lookupRoutine (completedEnvironment info) callee =
      some ⟨(info.routineAt callee).signature info, (info.routineAt callee).effects info⟩) :
    Packages.lookupRoutine ((completedEnvironment info).map Packages.RoutineEffects.signature) callee =
      some ((info.routineAt callee).signature info) := by
  have mapped := congrArg (Option.map Packages.RoutineEffects.signature) found
  simpa only [Packages.lookupRoutine, Nat.ne_of_gt positive, ↓reduceIte, List.getElem?_map, Option.map_some] using mapped

/-- A native package procedure call resolves in the same completion prefix
and passes the semantic argument, copy-out and alias checks. -/
theorem accepted_procedure_checks {text : Source} {context : Predicate.Native.Context} {input info position}
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (metadataValid : PackageBindings.validMetadata ⟨1, text⟩ info = true)
    (accepted : (packageCallAt modelCalls text context.model input info position .procedure).value.after ≠ 0) :
    ∃ callee frame entries arguments,
      callee = packageCallee modelCalls text context.model info position .procedure ∧
      let item := info.routineAt callee
      ActualListAt modelCalls text context.model input info item (modelCalls.reference text position).after frame entries ∧
      FormalArgumentsAt text context input info frame (formalSlots item) arguments ∧
      (ScalarProcedures.Call.mk callee arguments).Readable context.model.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      Packages.checkProcedure ((completedEnvironment info).map Packages.RoutineEffects.signature) context.names.shape
        context.model.analysis (context.model.flow input.scan.facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        ⟨callee, arguments⟩ = true := by
  obtain ⟨callee, frame, result, entries, arguments, selected, present, source, semantic, aliases, _, meaning⟩ :=
    accepted_formal_arguments textValid valid body storage checked typed accepted
  obtain ⟨positive, prefixBound, procedure, lookup⟩ := callee_completed selected.symm present rfl
  have inTable := Nat.le_trans prefixBound (callee_trace selected.symm present).1
  have routine := PackageBindings.validMetadata_routine metadataValid positive inTable
  let item := info.routineAt callee
  have tableBound : info.parameters.length ≤ PackageBindings.maxFormals := by
    rcases typed with ⟨_, _, _, _, _, _, _, size, _⟩; exact size
  have physical (nonempty : 0 < item.count) : item.formalFirst + item.count - 1 ≤ PackageBindings.maxFormals := by
    have last := (PackageBindings.routine_formal_index routine
      (show item.count - 1 < item.count by omega)).2
    change item.formalFirst + (item.count - 1) ≤ info.parameters.length at last
    omega
  have apart := checked_arguments_apart source semantic physical aliases valid.base.size valid.booleans.1
  obtain ⟨after, checkedArgs⟩ := meaning (context.model.flow input.scan.facts)
  obtain ⟨bound, bind, readable, fits, outputs, _⟩ := checkedArgs.binding
  have sig := lookup_completed_signature positive lookup
  simp only [PackageBindings.Routine.signature, procedure] at sig
  refine ⟨callee, frame, entries, arguments, selected, source, semantic, readable, ?_⟩
  simp only [Packages.checkProcedure, Packages.resolveProcedure, sig, Option.bind_some, bind, Option.map_some,
    apart]
  rw [Bool.and_eq_true, Bool.and_eq_true]
  exact ⟨⟨rfl, fits⟩, outputs⟩

end Silver.ApplicationPackageCalls
