module

public import Silver.PredicateProcedureTargetMeaning
public import Silver.ProcedureNameActualsApart

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

/-- Source-derived checks of a procedure actual list. Every input uses the
same incoming flow; output ranges accumulate only in the before/after indices. -/
inductive ProcedureActualsMeaning (context : ParseContext) (incoming : Flow) :
    List ScalarProcedures.Formal → List ScalarProcedures.Actual → Flow → Flow → Prop
  | nil {flow} : ProcedureActualsMeaning context incoming [] [] flow flow
  | input {domain : ScalarFunctions.ScalarType} {expression : ScalarFunctions.Actual}
      {formals actuals before after} :
      expression.Readable context.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) →
      expression.check context.names.shape context.analysis incoming
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) domain = true →
      ProcedureActualsMeaning context incoming formals actuals before after →
      ProcedureActualsMeaning context incoming (⟨.input, domain⟩ :: formals) (.value expression :: actuals) before after
  | output {domain : ScalarFunctions.ScalarType} {object : ScalarFunctions.Target}
      {formals actuals before after} :
      (Actual.target object).Readable context.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) →
      object.check context.analysis
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) domain = true →
      ProcedureActualsMeaning context incoming formals actuals (object.after domain before) after →
      ProcedureActualsMeaning context incoming (⟨.output, domain⟩ :: formals) (.target object :: actuals) before after
  | inputOutput {domain : ScalarFunctions.ScalarType} {object : ScalarFunctions.Target}
      {formals actuals before after} :
      (Actual.target object).Readable context.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) →
      (targetRead object).check context.names.shape context.analysis incoming
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) domain = true →
      object.check context.analysis
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) domain = true →
      ProcedureActualsMeaning context incoming formals actuals (object.after domain before) after →
      ProcedureActualsMeaning context incoming (⟨.inputOutput, domain⟩ :: formals) (.target object :: actuals) before after

theorem ProcedureActualsMeaning.binding {context incoming formals actuals before after}
    (source : ProcedureActualsMeaning context incoming formals actuals before after) :
    ∃ bound, bindActuals formals actuals = some bound ∧
      (∀ actual ∈ actuals, actual.Readable context.hasArguments context.names.shape
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))) ∧
      ScalarFunctions.checkActuals context.names.shape context.analysis incoming
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        (inputTypes formals) bound.inputs = true ∧
      checkTargets context.analysis
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        (outputTypes formals) bound.outputs = true ∧
      afterTargets (outputTypes formals) bound.outputs before = after := by
  induction source with
  | nil => exact ⟨⟨[], []⟩, rfl, by simp, rfl, rfl, rfl⟩
  | @input domain expression formals actuals before after readable checked rest ih =>
      obtain ⟨bound, found, restReadable, inputs, outputs, changed⟩ := ih
      refine ⟨⟨expression :: bound.inputs, bound.outputs⟩, ?_, ?_, ?_, outputs, changed⟩
      · simp only [bindActuals, found, Option.map_some]
      · intro actual member
        rcases List.mem_cons.mp member with same | later
        · cases same; exact readable
        · exact restReadable actual later
      · simp only [inputTypes, ScalarFunctions.checkActuals, checked, inputs, Bool.and_self]
  | @output domain object formals actuals before after readable checked rest ih =>
      obtain ⟨bound, found, restReadable, inputs, outputs, changed⟩ := ih
      refine ⟨⟨bound.inputs, object :: bound.outputs⟩, ?_, ?_, inputs, ?_, changed⟩
      · simp only [bindActuals, found, Option.map_some]
      · intro actual member
        rcases List.mem_cons.mp member with same | later
        · cases same; exact readable
        · exact restReadable actual later
      · simp only [outputTypes, checkTargets, checked, outputs, Bool.and_self]
  | @inputOutput domain object formals actuals before after readable inputChecked outputChecked rest ih =>
      obtain ⟨bound, found, restReadable, inputs, outputs, changed⟩ := ih
      refine ⟨⟨targetRead object :: bound.inputs, object :: bound.outputs⟩, ?_, ?_, ?_, ?_, changed⟩
      · simp only [bindActuals, found, Option.map_some]
      · intro actual member
        rcases List.mem_cons.mp member with same | later
        · cases same; exact readable
        · exact restReadable actual later
      · simp only [inputTypes, ScalarFunctions.checkActuals, inputChecked, inputs, Bool.and_self]
      · simp only [outputTypes, checkTargets, outputChecked, outputs, Bool.and_self]

theorem ProcedureUpdateAt.extendMeaning
    {text context incoming parameter callFirst callAfter scan actual next formals actuals after}
    (normal : NamesNormal context.names)
    (nv : Compose.Expressions.ValidNames text context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (arraysReady : context.ArraysReady text)
    (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount incoming)
    (bounded : incoming.path.Bounded) (bodyMode : context.elaborating = false)
    (count : scan.count = context.scalarNames.length)
    (formalBounds : parameter.bounds.Bounded)
    (source : ProcedureUpdateAt text context incoming parameter callFirst callAfter scan actual next)
    (rest : ProcedureActualsMeaning context (context.flow incoming) formals actuals (context.flow next.facts) after) :
    ProcedureActualsMeaning context (context.flow incoming)
      (ProcedureBindings.formalModel parameter :: formals) (actual :: actuals) (context.flow scan.facts) after := by
  cases source with
  | input mode value _ =>
      have checked := actual_meaning normal nv (by rw [bodyMode]; exact base.toContextReady)
        arraysReady compatible bounded value
      have formal : ProcedureBindings.formalModel parameter =
          ⟨.input, formalType (procedureInputFormal parameter)⟩ := by
        cases kind : parameter.kind <;>
          simp only [ProcedureBindings.formalModel, mode, ProcedureBindings.modeModel,
            formalType, procedureInputFormal, kind]
      rw [formal]
      exact ProcedureActualsMeaning.input checked.1 checked.2 rest
  | writable notInput accepted _ _ _ _ =>
      have meaning := procedureTargetActual_meaning base booleansBound compatible.count bodyMode formalBounds accepted
      rw [meaning.changed scan count] at rest
      cases mode : parameter.mode with
      | input => exact False.elim (notInput mode)
      | output =>
          simpa only [ProcedureBindings.formalModel, mode, ProcedureBindings.modeModel] using
            ProcedureActualsMeaning.output meaning.readable meaning.checked rest
      | inputOutput =>
          simpa only [ProcedureBindings.formalModel, mode, ProcedureBindings.modeModel] using
            ProcedureActualsMeaning.inputOutput meaning.readable (meaning.copyIn mode) meaning.checked rest

theorem ProcedureUpdateAt.count {text context incoming parameter callFirst callAfter scan actual next}
    (source : ProcedureUpdateAt text context incoming parameter callFirst callAfter scan actual next) :
    next.count = scan.count := by
  cases source with
  | input => rfl
  | writable =>
      unfold procedureWritableUpdate
      split
      · rfl
      · exact ActiveFlow.replace_count ..

theorem ProcedureUpdatesAt.meaning
    {text context incoming catalog callFirst callAfter scan first last actuals result}
    (normal : NamesNormal context.names)
    (nv : Compose.Expressions.ValidNames text context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (arraysReady : context.ArraysReady text)
    (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount incoming)
    (bounded : incoming.path.Bounded) (bodyMode : context.elaborating = false)
    (count : scan.count = context.scalarNames.length)
    (valid : ProcedureBindings.ValidMetadata text catalog)
    (source : ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last actuals result) :
    ProcedureActualsMeaning context (context.flow incoming)
      (ProcedureBindings.formalModels catalog first (last - first + 1)) actuals
      (context.flow scan.facts) (context.flow result.facts) := by
  induction source with
  | last step _ =>
      simp only [Nat.sub_self, ProcedureBindings.formalModels, bodyToken]
      exact step.extendMeaning normal nv base arraysReady booleansBound compatible bounded bodyMode count (ProcedureBindings.parameter_bounds valid _) .nil
  | @next scan first last actual next rest result within step comma following ih =>
      have remaining : last - first = last - (first + 1) + 1 := by omega
      have nextCount : (bodyToken text next (.symbol ",")).count = context.scalarNames.length :=
        step.count.trans count
      have tail := ih nextCount
      dsimp only [bodyToken] at tail
      simpa only [ProcedureBindings.formalModels, remaining] using
        step.extendMeaning normal nv base arraysReady booleansBound compatible bounded bodyMode count (ProcedureBindings.parameter_bounds valid _) tail

end Silver.Predicate
