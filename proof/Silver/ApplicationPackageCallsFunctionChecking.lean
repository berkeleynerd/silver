module

public import Silver.ApplicationPackageCallsFormalArguments
public import Silver.ApplicationPackageDeclarationsFormalModes

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages

/-- A source Signature that permits only input formals yields an ordinary
function argument list with every expression checked in the same entry flow. -/
theorem FormalArgumentsAt.function_inputs {text context input info frame slots arguments}
    (source : FormalArgumentsAt text context input info frame slots arguments)
    (modes : ∀ slot ∈ slots, (info.parameterAt slot).mode = .input) :
    ∃ values, arguments = values.map ScalarProcedures.Actual.value ∧
      (∀ value ∈ values, value.Readable context.model.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))) ∧
      ScalarFunctions.checkActuals context.names.shape context.model.analysis (context.model.flow input.scan.facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        (slots.map fun slot => (info.parameterAt slot).domain) values = true := by
  induction source with
  | nil => exact ⟨[], rfl, by simp, rfl⟩
  | @cons slot slots argument arguments head _ ih =>
    have inputMode := modes slot (List.mem_cons_self ..)
    obtain ⟨values, same, followingReadable, followingChecked⟩ := ih (fun i h => modes i (List.mem_cons_of_mem _ h))
    cases head with
    | @value expression _ _ readable fits =>
      refine ⟨expression :: values, by simp only [same, List.map_cons], ?_, ?_⟩
      · intro value member
        rcases List.mem_cons.mp member with ident | later
        · exact ident ▸ readable
        · exact followingReadable value later
      · have checkedHead : expression.check context.names.shape context.model.analysis (context.model.flow input.scan.facts)
            (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
            (info.parameterAt slot).domain = true := fits
        simp only [List.map_cons, ScalarFunctions.checkActuals, checkedHead, followingChecked, Bool.and_self]
    | target writable _ _ _ => exact False.elim (writable inputMode)

/-- Resolves a source-accepted function in the actual completed prefix. Its
input modes follow from the Signature reader's invariant for this declaration. -/
theorem accepted_function_checks {text : Source} {context : Predicate.Native.Context} {input info position}
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (accepted : (packageCallAt modelCalls text context.model input info position .function).value.after ≠ 0)
    (declared : ApplicationPackageDeclarations.DeclaredFormalModes info) :
    ∃ callee frame entries values,
      callee = packageCallee modelCalls text context.model info position .function ∧
      let item := info.routineAt callee
      ActualListAt modelCalls text context.model input info item (modelCalls.reference text position).after frame entries ∧
      FormalArgumentsAt text context input info frame (formalSlots item) (values.map ScalarProcedures.Actual.value) ∧
      (∀ value ∈ values, value.Readable context.model.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))) ∧
      Packages.checkFunction ((completedEnvironment info).map Packages.RoutineEffects.signature) context.names.shape
        context.model.analysis (context.model.flow input.scan.facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        ⟨callee, values⟩ = some item.resultDomain ∧
      (packageCallAt modelCalls text context.model input info position .function).value =
        ⟨frame.cursor, item.resultKind, item.resultBounds⟩ := by
  obtain ⟨callee, frame, result, entries, arguments, selected, present, source, semantic, _, returned, _⟩ :=
    accepted_formal_arguments textValid valid body storage checked typed accepted
  obtain ⟨positive, completed, functionKind, lookup⟩ := callee_completed selected.symm present rfl
  let item := info.routineAt callee
  have inTable := Nat.le_trans completed (callee_trace selected.symm present).1
  have routine : item ∈ info.routines := by
    have inside : callee - 1 < info.routines.length := by omega
    simp only [item, PackageBindings.Metadata.routineAt, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem inside, Option.getD_some]
    exact List.getElem_mem inside
  have inputModes : ∀ slot ∈ formalSlots item, (info.parameterAt slot).mode = .input := by
    intro slot member
    obtain ⟨offset, inside, same⟩ := List.mem_map.mp member
    apply declared.function_inputs routine functionKind
    exact List.mem_map.mpr ⟨offset, inside, congrArg info.parameterAt same⟩
  obtain ⟨values, same, readable, fits⟩ := semantic.function_inputs inputModes
  have formals : ScalarFunctions.checkActuals context.names.shape context.model.analysis (context.model.flow input.scan.facts)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      ((item.formals info).map PackageBindings.Formal.domain) values = true := by
    simpa only [formalSlots, PackageBindings.Routine.formals, List.map_map, Function.comp_def] using fits
  have lookupMapped := congrArg (Option.map Packages.RoutineEffects.signature) lookup
  have sig : Packages.lookupRoutine ((completedEnvironment info).map Packages.RoutineEffects.signature) callee =
      some (.function ⟨(item.formals info).map PackageBindings.Formal.domain, item.resultDomain⟩) := by
    simpa only [Packages.lookupRoutine, Nat.ne_of_gt positive, ↓reduceIte, List.getElem?_map, Option.map_some,
      PackageBindings.Routine.signature, functionKind] using lookupMapped
  subst arguments
  refine ⟨callee, frame, entries, values, selected, source, semantic, readable, ?_, ?_⟩
  · simp only [Packages.checkFunction, sig, Option.bind_some, formals, ↓reduceIte]
    rfl
  · rw [returned]; rfl

end Silver.ApplicationPackageCalls
