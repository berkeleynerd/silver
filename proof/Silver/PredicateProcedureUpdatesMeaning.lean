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

/-- Flow updates for distinct writable cells commute just as concrete copy-back
writes do. Boolean domains do not refine the caller's numeric flow. -/
theorem target_after_commute {left right : ScalarFunctions.Target}
    (apart : targetCell left ≠ targetCell right)
    (leftDomain rightDomain : ScalarFunctions.ScalarType) (flow : Flow) :
    right.after rightDomain (left.after leftDomain flow) =
      left.after leftDomain (right.after rightDomain flow) := by
  cases left with
  | boolean => cases right <;> cases leftDomain <;> cases rightDomain <;> rfl
  | integer left leftBounds =>
      cases right with
      | boolean => cases leftDomain <;> cases rightDomain <;> rfl
      | integer right rightBounds =>
          cases leftDomain with
          | boolean => rfl
          | integer leftDomain =>
              cases rightDomain with
              | boolean => rfl
              | integer rightDomain =>
                  have distinct : left ≠ right := by
                    intro same
                    apply apart
                    cases same
                    rfl
                  change {flow with scalars := Integer.put (Integer.put flow.scalars left (some leftDomain)) right (some rightDomain)} =
                    {flow with scalars := Integer.put (Integer.put flow.scalars right (some rightDomain)) left (some leftDomain)}
                  apply congrArg (fun ranges : Nat → Option Integer.Interval => ({flow with scalars := ranges} : Flow))
                  funext index
                  by_cases first : index = left <;> by_cases second : index = right <;>
                    simp_all [Integer.put]

private theorem actualsApart_head {first second : ScalarProcedures.Actual} {rest}
    (apart : actualsApart (first :: second :: rest) = true) : Actual.apart first second = true :=
  (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp apart).1).1

/-- Reordering associations reorders paired domains and actuals together. Inputs
keep the same incoming flow; disjoint outputs commute. This is the bridge from
written association order to the existing formal-order procedure semantics. -/
theorem ProcedureActualsMeaning.permutation {context incoming before after}
    {written ordered : List (ScalarProcedures.Formal × ScalarProcedures.Actual)}
    (permuted : written.Perm ordered)
    (apart : actualsApart (written.map Prod.snd) = true)
    (meaning : ProcedureActualsMeaning context incoming (written.map Prod.fst)
      (written.map Prod.snd) before after) :
    ProcedureActualsMeaning context incoming (ordered.map Prod.fst)
      (ordered.map Prod.snd) before after := by
  induction permuted generalizing before after with
  | nil => exact meaning
  | @cons entry written ordered permuted ih =>
      rcases entry with ⟨formal, actual⟩
      have restApart := (Bool.and_eq_true_iff.mp apart).2
      cases meaning with
      | input readable checked rest => exact .input readable checked (ih restApart rest)
      | output readable checked rest => exact .output readable checked (ih restApart rest)
      | inputOutput readable inputChecked checked rest =>
          exact .inputOutput readable inputChecked checked (ih restApart rest)
  | @swap first second rest =>
      rcases first with ⟨firstFormal, firstActual⟩
      rcases second with ⟨secondFormal, secondActual⟩
      have separate := actualsApart_head apart
      cases meaning with
      | input readable checked following =>
          cases following with
          | input otherReadable otherChecked tail =>
              exact .input otherReadable otherChecked (.input readable checked tail)
          | output otherReadable otherChecked tail =>
              exact .output otherReadable otherChecked (.input readable checked tail)
          | inputOutput otherReadable otherInput otherChecked tail =>
              exact .inputOutput otherReadable otherInput otherChecked (.input readable checked tail)
      | @output domain object _ _ _ _ readable checked following =>
          cases following with
          | input otherReadable otherChecked tail =>
              exact .input otherReadable otherChecked (.output readable checked tail)
          | @output otherDomain other _ _ _ _ otherReadable otherChecked tail =>
              have distinct : targetCell object ≠ targetCell other := by
                simpa only [Actual.apart, bne_iff_ne] using separate
              rw [target_after_commute distinct domain otherDomain before] at tail
              exact .output otherReadable otherChecked (.output readable checked tail)
          | @inputOutput otherDomain other _ _ _ _ otherReadable otherInput otherChecked tail =>
              have distinct : targetCell object ≠ targetCell other := by
                simpa only [Actual.apart, bne_iff_ne] using separate
              rw [target_after_commute distinct domain otherDomain before] at tail
              exact .inputOutput otherReadable otherInput otherChecked (.output readable checked tail)
      | @inputOutput domain object _ _ _ _ readable inputChecked checked following =>
          cases following with
          | input otherReadable otherChecked tail =>
              exact .input otherReadable otherChecked (.inputOutput readable inputChecked checked tail)
          | @output otherDomain other _ _ _ _ otherReadable otherChecked tail =>
              have distinct : targetCell object ≠ targetCell other := by
                simpa only [Actual.apart, bne_iff_ne] using separate
              rw [target_after_commute distinct domain otherDomain before] at tail
              exact .output otherReadable otherChecked (.inputOutput readable inputChecked checked tail)
          | @inputOutput otherDomain other _ _ _ _ otherReadable otherInput otherChecked tail =>
              have distinct : targetCell object ≠ targetCell other := by
                simpa only [Actual.apart, bne_iff_ne] using separate
              rw [target_after_commute distinct domain otherDomain before] at tail
              exact .inputOutput otherReadable otherInput otherChecked (.inputOutput readable inputChecked checked tail)
  | trans first second ihFirst ihSecond =>
      exact ihSecond (actualsApart_permutation (first.map Prod.snd) apart) (ihFirst apart meaning)

theorem ProcedureUpdateAt.extendMeaning
    {text context incoming parameter catalog first last callFirst callAfter scan actual next formals actuals after}
    (normal : NamesNormal context.names)
    (nv : Compose.Expressions.ValidNames text context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (arraysReady : context.ArraysReady text)
    (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount incoming)
    (bounded : incoming.path.Bounded) (bodyMode : context.elaborating = false)
    (count : scan.count = context.scalarNames.length)
    (formalBounds : parameter.bounds.Bounded)
    (source : ProcedureUpdateAt text context incoming parameter catalog first last callFirst callAfter scan actual next)
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
  | writable notInput accepted _ _ _ =>
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

theorem ProcedureUpdateAt.count {text context incoming parameter catalog first last callFirst callAfter scan actual next}
    (source : ProcedureUpdateAt text context incoming parameter catalog first last callFirst callAfter scan actual next) :
    next.count = scan.count := by
  cases source with
  | input => rfl
  | writable =>
      unfold procedureWritableUpdate
      split
      · rfl
      · exact ActiveFlow.replace_count ..

theorem ProcedureUpdatesTailAt.meaning
    {text context incoming catalog first last callFirst callAfter scan ordinal named seen entries result}
    (normal : NamesNormal context.names)
    (nv : Compose.Expressions.ValidNames text context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (arraysReady : context.ArraysReady text)
    (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount incoming)
    (bounded : incoming.path.Bounded) (bodyMode : context.elaborating = false)
    (count : scan.count = context.scalarNames.length)
    (valid : ProcedureBindings.ValidMetadata text catalog)
    (source : ProcedureUpdatesTailAt text context incoming catalog first last callFirst callAfter scan ordinal named seen entries result) :
    ProcedureActualsMeaning context (context.flow incoming)
      (entries.map (fun entry => ProcedureBindings.formalModel (ProcedureBindings.parameter catalog entry.1)))
      (entries.map (fun entry => entry.2.actual)) (context.flow scan.facts) (context.flow result.facts) := by
  induction source with
  | @last scan named seen actual next _ _ step _ =>
      have meaning := step.extendMeaning
        (scan := {scan with position := (procedureAssociation text scan.position catalog first last last named).payloadFirst})
        (next := next) normal nv base arraysReady booleansBound compatible bounded bodyMode count
        (ProcedureBindings.parameter_bounds valid _) .nil
      simpa only [List.map_cons, List.map_nil, bodyToken] using meaning
  | @next scan ordinal named seen actual next entries result _ _ _ step _ _ ih =>
      have nextCount : _ = context.scalarNames.length := step.count.trans count
      have tail := ih nextCount
      have meaning := step.extendMeaning
        (scan := {scan with position := (procedureAssociation text scan.position catalog first last ordinal named).payloadFirst})
        (next := next) normal nv base arraysReady booleansBound compatible bounded bodyMode count
        (ProcedureBindings.parameter_bounds valid _) tail
      simpa only [List.map_cons, bodyToken] using meaning

private theorem formalModels_of_keys {catalog : ProcedureBindings.Metadata}
    {entries : List (ScalarAssociations.Entry ProcedureActualSource)} {first count : Nat}
    (keys : entries.map Prod.fst = List.range' first count) :
    entries.map (fun entry => ProcedureBindings.formalModel (ProcedureBindings.parameter catalog entry.1)) =
      ProcedureBindings.formalModels catalog first count := by
  induction count generalizing entries first with
  | zero =>
      have empty : entries = [] := List.map_eq_nil_iff.mp keys
      subst entries
      rfl
  | succ count ih =>
      cases entries with
      | nil => simp at keys
      | cons entry entries =>
          have parts : entry.1 = first ∧ entries.map Prod.fst = List.range' (first + 1) count := by
            simpa only [List.map_cons, List.range'_succ, List.cons.injEq] using keys
          simp only [List.map_cons, ProcedureBindings.formalModels, parts.1, ih parts.2]

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
    (start : scan.position = callFirst) (positionBound : scan.position ≤ text.length + 1)
    (source : ProcedureUpdatesAt text context incoming catalog callFirst callAfter scan first last actuals result) :
    ProcedureActualsMeaning context (context.flow incoming)
      (ProcedureBindings.formalModels catalog first (last - first + 1)) actuals
      (context.flow scan.facts) (context.flow result.facts) := by
  cases source with
  | updates source =>
      have written := source.meaning normal nv base arraysReady booleansBound compatible bounded bodyMode count valid
      have apart := source.actualsApart start positionBound base.size booleansBound
      let pairing := fun entry : ScalarAssociations.Entry ProcedureActualSource =>
        (ProcedureBindings.formalModel (ProcedureBindings.parameter catalog entry.1), entry.2.actual)
      have permutation := (ScalarAssociations.arrange_permutation defaultProcedureActual
        source.actuals.fresh.nodup source.actuals.complete).map pairing
      have ordered := ProcedureActualsMeaning.permutation permutation
        (by simpa only [List.map_map, pairing, Function.comp_def] using apart)
        (by simpa only [List.map_map, pairing, Function.comp_def] using written)
      simpa only [List.map_map, pairing, Function.comp_def, formalModels_of_keys (ScalarAssociations.arrange_keys ..),
        arrangeProcedureActuals] using ordered

end Silver.Predicate
