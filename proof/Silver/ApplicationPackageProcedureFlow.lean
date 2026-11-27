module

public import Silver.ApplicationPackageProcedureReset

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages

set_option backward.dsimp.instances true

/-- Effect-union bookkeeping and the final cursor/assignment updates leave
exactly the flow produced by the native visible-state reset. -/
theorem finishCall_reset_flow {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {kind : PackageBindings.RoutineKind}
    {item : PackageBindings.Routine} {frame : ActualFrame} {checked : ApplicationCall}
    (body : context.elaborating = false)
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (count : checked.result.scan.count = context.scalarNames.length) :
    let after := finishCall modelCalls text context info kind item frame checked
    after.result.scan.count = checked.result.scan.count ∧
      context.flow after.result.scan.facts =
        resetSlotsFlow context.scalarNames
          (resetSlots modelCalls text context info frame.callWrites
            ((List.range info.states.length).map (· + 1)))
          (context.flow checked.result.scan.facts) := by
  let initial : ApplicationCall := {checked with result := {checked.result with
    reads := PackageBindings.stateUnion checked.result.reads item.mayRead,
    writes := PackageBindings.stateUnion checked.result.writes frame.callWrites}}
  let indices := (List.range info.states.length).map (· + 1)
  have reset := reset_fold_flow (text := text) (info := info) (writes := frame.callWrites)
    indices initial body capacity count
  let after := indices.foldl (resetState modelCalls text context info frame.callWrites) initial
  have same : (finishCall modelCalls text context info kind item frame checked).result.scan.facts =
      after.result.scan.facts := by
    dsimp only [finishCall, after, indices, initial]
    rw [List.foldl_map]
    split <;> rfl
  constructor
  · change (finishCall modelCalls text context info kind item frame checked).result.scan.facts.count = _
    rw [same]
    exact reset.1
  · rw [same]
    exact reset.2

/-- The complete raw procedure call is decoded at its original completion
prefix. Actuals are read and checked in the incoming flow, explicit targets
are updated in formal order, then precisely the native visible-global slots
receive declared ranges. Nothing assumes a completed semantic call or safety
certificate. The source-layout connection remains an explicit later join. -/
theorem accepted_procedure_flow {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : PackageBindings.Metadata} {position : Nat}
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (accepted : (packageCallAt modelCalls text context.model input info position .procedure).value.after ≠ 0) :
    ∃ callee frame entries arguments bound,
      callee = packageCallee modelCalls text context.model info position .procedure ∧
      let item := info.routineAt callee
      readActuals modelCalls text context.model input info item
        (modelCalls.reference text position).after = some frame ∧
      ActualListAt modelCalls text context.model input info item
        (modelCalls.reference text position).after frame entries ∧
      FormalArgumentsAt text context input info frame (formalSlots item) arguments ∧
      ScalarProcedures.bindActuals ((item.formals info).map PackageBindings.Formal.semantic) arguments = some bound ∧
      (ScalarProcedures.Call.mk callee arguments).Readable context.model.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      Packages.checkProcedure ((completedEnvironment info).map Packages.RoutineEffects.signature)
        context.names.shape context.model.analysis (context.model.flow input.scan.facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        ⟨callee, arguments⟩ = true ∧
      context.model.flow
        (packageCallAt modelCalls text context.model input info position .procedure).result.scan.facts =
        resetSlotsFlow context.scalarNames
          (resetSlots modelCalls text context.model info frame.callWrites
            ((List.range info.states.length).map (· + 1)))
          (ScalarProcedures.afterTargets
            (ScalarProcedures.outputTypes ((item.formals info).map PackageBindings.Formal.semantic))
            bound.outputs (context.model.flow input.scan.facts)) := by
  obtain ⟨callee, item, frame, aliasResult, selected, present, itemEq, window, read, aliases, returned, _, _⟩ :=
    accepted_call accepted
  have capacity (nonempty : 0 < item.count) : item.formalFirst + item.count - 1 ≤ info.parameters.length := by
    have bounds : ¬(item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
        item.count > info.parameters.length - item.formalFirst + 1) := fun failed => window ⟨nonempty, failed⟩
    omega
  obtain ⟨entries, source⟩ := readActuals_source read
  obtain ⟨arguments, semantic⟩ := source.formal_arguments textValid valid body storage checked typed capacity
  have count : input.scan.count = context.scalarNames.length :=
    ((flowValidCheck_meaning _ _).mp ((bodyValidCheck_meaning _ _ _).mp checked).2.2).1
  obtain ⟨bound, binding, updated, afterCount⟩ := checkAliases_output_flow semantic count read aliases
  obtain ⟨someFlow, meaning⟩ := semantic.procedure_meaning (context.model.flow input.scan.facts)
  obtain ⟨otherBound, otherBinding, readable, fits, targets, _⟩ := meaning.binding
  have normalized : ScalarProcedures.bindActuals
      ((item.formals info).map PackageBindings.Formal.semantic) arguments = some otherBound := by
    simpa only [formalSlots, PackageBindings.Routine.formals, List.map_map, Function.comp_def] using otherBinding
  have boundEq := Option.some.inj (normalized.symm.trans binding)
  cases boundEq
  have tableBound : info.parameters.length ≤ PackageBindings.maxFormals := by
    rcases typed with ⟨_, _, _, _, _, _, _, size, _⟩; exact size
  have apart := checked_arguments_apart source semantic
    (fun nonempty => Nat.le_trans (capacity nonempty) tableBound) aliases valid.base.size valid.booleans.1
  subst item
  obtain ⟨positive, _, procedure, lookup⟩ := callee_completed selected.symm present rfl
  have signature := congrArg (Option.map Packages.RoutineEffects.signature) lookup
  have sig : Packages.lookupRoutine ((completedEnvironment info).map Packages.RoutineEffects.signature) callee =
      some ((info.routineAt callee).signature info) := by
    simpa only [Packages.lookupRoutine, Nat.ne_of_gt positive, ↓reduceIte,
      List.getElem?_map, Option.map_some] using signature
  simp only [PackageBindings.Routine.signature, procedure] at sig
  refine ⟨callee, frame, entries, arguments, bound, selected, read, source, semantic, binding, readable, ?_, ?_⟩
  · simp only [Packages.checkProcedure, Packages.resolveProcedure, sig, Option.bind_some,
      binding, Option.map_some, apart]
    rw [Bool.and_eq_true, Bool.and_eq_true]
    refine ⟨⟨rfl, ?_⟩, ?_⟩
    · simpa only [formalSlots, PackageBindings.Routine.formals, List.map_map, Function.comp_def,
        Predicate.Native.Context.model] using fits
    · simpa only [formalSlots, PackageBindings.Routine.formals, List.map_map, Function.comp_def,
        Predicate.Native.Context.model] using targets
  · have finalFlow := (finishCall_reset_flow (text := text) (context := context.model) (info := info) (kind := .procedure)
      (item := info.routineAt callee) (frame := frame) body valid.base.size (afterCount.trans count)).2
    rw [← returned, ← updated] at finalFlow
    exact finalFlow

end Silver.ApplicationPackageCalls
