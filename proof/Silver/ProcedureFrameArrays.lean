module

public import Silver.ProcedureFrameMeaning
public import Silver.FunctionParameterArrays

@[expose] public section

namespace Silver.Compose
open Predicate Silver.Compose.Expressions

/-- A scalar formal occupies the next low Integer cell. Its mode controls
mutability independently of the symbolic cells installed for array inputs. -/
def procedureScalarCell (base : Integer.Analysis) (index : Nat) (bounds : Integer.Interval)
    (writable : Bool) : Integer.Analysis :=
  ⟨Integer.put base.declared index (some bounds), Integer.put base.mutable index writable,
    Integer.put base.static index false, Integer.put base.refinable index true⟩

theorem viewAnalysis_procedureScalarCell (names : ArrayBindings.Metadata) (base : Integer.Analysis)
    (index : Nat) (bounds : Integer.Interval) (writable : Bool) (low : index ≤ ArrayBindings.scalarLimit) :
    ArrayViews.analysis names (procedureScalarCell base index bounds writable) =
      procedureScalarCell (ArrayViews.analysis names base) index bounds writable := by
  simp only [ArrayViews.analysis, ArrayFlow.analysis, procedureScalarCell,
    ArrayBindings.integerMutability, ArrayBindings.integerRefinability]
  rw [ArrayFlow.ranges_put _ _ low, ArrayBindings.mutability_put _ _ low,
    ArrayBindings.refinability_put _ _ low]

theorem arrayAnalysis_procedureScalarCell (formals : List ScalarFunctions.ScalarType) (slot : Nat)
    (base : Integer.Analysis) (index : Nat) (bounds : Integer.Interval) (writable : Bool)
    (low : index ≤ ArrayBindings.scalarLimit) :
    ScalarFunctions.arrayAnalysis slot formals (procedureScalarCell base index bounds writable) =
      procedureScalarCell (ScalarFunctions.arrayAnalysis slot formals base) index bounds writable := by
  induction formals generalizing slot base with
  | nil => rfl
  | cons formal rest ih =>
      cases formal with
      | integer | boolean => exact ih slot base
      | array domain =>
          have outside : ¬(domain.formal slot).ContainsCell index := by
            intro inside
            have above := NamedArrayParameters.formal_above_scalars domain slot
            change index ≤ NamedArrayParameters.scalarLimit at low
            simp only [Integer.ArrayDescriptor.ContainsCell] at inside
            omega
          have commute : parameterArrayAnalysis (domain.formal slot) (procedureScalarCell base index bounds writable) =
              procedureScalarCell (parameterArrayAnalysis (domain.formal slot) base) index bounds writable := by
            unfold parameterArrayAnalysis procedureScalarCell
            dsimp only
            congr 1 <;> funext cell <;> by_cases same : cell = index
            all_goals simp_all [Integer.ArrayDescriptor.bodyRanges, Integer.put]
          change ScalarFunctions.arrayAnalysis (slot + 1) rest
            (parameterArrayAnalysis _ (procedureScalarCell base index bounds writable)) = _
          rw [commute, ih]
          rfl

theorem ProcedureInputFramesAt.arrayAnalysis {text frame index final}
    (source : ProcedureInputFramesAt frame index final) (valid : ValidState text frame)
    (positive : 0 < index) (declarations : Nat) (count : declarations ≤ frame.scalarNames.length) :
    ArrayViews.analysis final.arrayNames.names (functionScalarAnalysis final declarations) =
      ScalarProcedures.parameterAnalysis frame.scalarNames.length
        (ScalarProcedures.inputFormals (ProcedureBindings.formalModels frame.procedures index
          (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types))
        (ScalarFunctions.arrayAnalysis (frame.arrayNames.names.length + 1)
          (ScalarProcedures.inputTypes (ProcedureBindings.formalModels frame.procedures index
            (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types))
          (ArrayViews.analysis frame.arrayNames.names (functionScalarAnalysis frame declarations))) := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.procedures.parameters.length + 1 - index = 0 := by omega
      simp [empty, ProcedureBindings.formalModels, ScalarProcedures.inputFormals,
        ScalarProcedures.inputTypes, ScalarProcedures.parameterAnalysis, ScalarFunctions.arrayAnalysis]
  | @skip before final index _ more output _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      simpa only [ProcedureBindings.formalModel, output, ProcedureBindings.modeModel,
        ScalarProcedures.inputFormals, ScalarProcedures.inputTypes] using ih valid (by omega) count
  | @next before final index _ more input accepted _ _ ih =>
      have typed : ProcedureBindings.ValidFormal text (ProcedureBindings.parameter before.procedures index) :=
        valid.procedures.2.2.1 _ (ProcedureBindings.parameter_mem positive more)
      have grows := appendProcedureParameter_grows before (ProcedureBindings.parameter before.procedures index) accepted
      have tail := ih (appendProcedureParameter_valid valid typed) (by omega) (Nat.le_trans count grows.1)
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      by_cases named : (ProcedureBindings.parameter before.procedures index).typeId ≠ 0
      · have mode := appendProcedureParameter_named_input named accepted
        have same := appendProcedureParameter_named named accepted
        have typedInput : FunctionBindings.ValidFormal text (procedureInputFormal (ProcedureBindings.parameter before.procedures index)) :=
          ⟨typed.1, typed.2.1, typed.2.2.1, fun id => (typed.2.2.2 id).2⟩
        have installed : ArrayViews.analysis (appendProcedureParameter before (ProcedureBindings.parameter before.procedures index)).arrayNames.names
            (functionScalarAnalysis (appendProcedureParameter before (ProcedureBindings.parameter before.procedures index)) declarations) =
              parameterArrayAnalysis
                (((ArrayBindings.arrayType before.arrayNames.types (ProcedureBindings.parameter before.procedures index).typeId).domain
                  (ProcedureBindings.parameter before.procedures index).typeId).formal (before.arrayNames.names.length + 1))
                (ArrayViews.analysis before.arrayNames.names (functionScalarAnalysis before declarations)) := by
          rw [same]
          exact appendParameter_arrayAnalysis valid typedInput named (same ▸ accepted) declarations
        rw [installed, appendProcedureParameter_array named accepted] at tail
        rw [procedureFormalModel_named _ named mode]
        simpa +instances only [ScalarProcedures.inputFormals, ScalarProcedures.inputTypes, ScalarProcedures.parameterAnalysis,
          ScalarFunctions.arrayAnalysis, List.length_append, List.length_singleton, Nat.add_assoc,
          parameterArrayAnalysis, procedureInputFormal] using tail
      · cases kind : (ProcedureBindings.parameter before.procedures index).kind with
        | integer =>
            have space : before.scalarNames.length ≠ ScalarExpression.maxBindings := by
              intro full
              simp [appendProcedureParameter, named, kind, full, invalidState] at accepted
            have low : before.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit := by
              have capacity := valid.2.2.2.2.2.1.1
              change before.scalarNames.length ≤ ArrayBindings.scalarLimit at capacity
              change before.scalarNames.length ≠ ArrayBindings.scalarLimit at space
              omega
            have step : appendProcedureParameter before (ProcedureBindings.parameter before.procedures index) =
                {before with scalarNames := before.scalarNames ++ [procedureIntegerBinding (ProcedureBindings.parameter before.procedures index)]} := by
              simp [appendProcedureParameter, named, kind, space, procedureIntegerBinding]
            have updated : functionScalarAnalysis {before with scalarNames := before.scalarNames ++
                [procedureIntegerBinding (ProcedureBindings.parameter before.procedures index)]} declarations = procedureScalarCell
                (functionScalarAnalysis before declarations) (before.scalarNames.length + 1)
                (ProcedureBindings.parameter before.procedures index).bounds (decide ((ProcedureBindings.parameter before.procedures index).mode ≠ .input)) :=
              functionScalarAnalysis_procedureInteger before (ProcedureBindings.parameter before.procedures index) declarations count
            rw [step, updated] at tail
            rw [viewAnalysis_procedureScalarCell _ _ _ _ _ low,
              arrayAnalysis_procedureScalarCell _ _ _ _ _ _ low] at tail
            cases mode : (ProcedureBindings.parameter before.procedures index).mode <;> try exact False.elim (input mode)
            all_goals simpa [ProcedureBindings.formalModel, formalType, procedureInputFormal, named, kind, mode,
              ProcedureBindings.modeModel, ScalarProcedures.inputFormals, ScalarProcedures.inputTypes,
              ScalarProcedures.parameterAnalysis, ScalarFunctions.arrayAnalysis, procedureScalarCell,
              show (ScalarProcedures.Mode.inputOutput != .input) = true from rfl] using tail
        | boolean =>
            have space : before.booleanNames.length ≠ BooleanBindings.maxBindings := by
              intro full
              simp [appendProcedureParameter, named, kind, full, invalidState] at accepted
            have step : appendProcedureParameter before (ProcedureBindings.parameter before.procedures index) =
                {before with booleanNames := before.booleanNames ++
                  [⟨(ProcedureBindings.parameter before.procedures index).first, (ProcedureBindings.parameter before.procedures index).after, decide ((ProcedureBindings.parameter before.procedures index).mode ≠ .input)⟩]} := by
              simp [appendProcedureParameter, named, kind, space]
            rw [step] at tail
            cases mode : (ProcedureBindings.parameter before.procedures index).mode <;> try exact False.elim (input mode)
            all_goals simpa [ProcedureBindings.formalModel, formalType, procedureInputFormal, named, kind, mode,
              ProcedureBindings.modeModel, ScalarProcedures.inputFormals, ScalarProcedures.inputTypes,
              ScalarProcedures.parameterAnalysis, ScalarFunctions.arrayAnalysis, functionScalarAnalysis] using tail

/-- The pooled mixed signature installs exactly the source-order array input
descriptors. Reading a scalar or skipping an output allocates no array slot. -/
theorem ProcedureInputFramesAt.arrayDescriptors {frame index final}
    (source : ProcedureInputFramesAt frame index final) :
    final.arrayNames.names.map (fun item => (item.typeId, item.viewDescriptor)) =
      frame.arrayNames.names.map (fun item => (item.typeId, item.viewDescriptor)) ++
        ScalarFunctions.formalArrays (frame.arrayNames.names.length + 1)
          (ScalarProcedures.inputTypes (ProcedureBindings.formalModels frame.procedures index
            (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types)) := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.procedures.parameters.length + 1 - index = 0 := by omega
      simp [empty, ProcedureBindings.formalModels, ScalarProcedures.inputTypes, ScalarFunctions.formalArrays]
  | @skip before final index _ more output _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      simpa only [ProcedureBindings.formalModel, output, ProcedureBindings.modeModel, ScalarProcedures.inputTypes]
        using ih
  | @next before final index _ more input accepted _ _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      by_cases named : (ProcedureBindings.parameter before.procedures index).typeId ≠ 0
      · have mode := appendProcedureParameter_named_input named accepted
        rw [appendProcedureParameter_array named accepted] at ih
        simp only [List.map_append, List.map_singleton] at ih
        rw [arrayParameterBinding_viewDescriptor] at ih
        rw [procedureFormalModel_named _ named mode]
        simpa only [ScalarProcedures.inputTypes, ScalarFunctions.formalArrays, List.length_append,
          List.length_singleton, ArrayBindings.ArrayType.domain, List.append_assoc, List.singleton_append,
          arrayParameterBinding, Nat.add_assoc] using ih
      · have arrays := appendProcedureParameter_scalar_arrays (by omega) accepted
        have procs : (appendProcedureParameter before (ProcedureBindings.parameter before.procedures index)).procedures = before.procedures :=
          by rw [appendProcedureParameter_fields before (ProcedureBindings.parameter before.procedures index) accepted]
        rw [arrays, procs] at ih
        cases kind : (ProcedureBindings.parameter before.procedures index).kind <;> cases mode : (ProcedureBindings.parameter before.procedures index).mode <;> try exact False.elim (input mode)
        all_goals simpa [ProcedureBindings.formalModel, formalType, procedureInputFormal, named, kind, mode,
          ProcedureBindings.modeModel, ScalarProcedures.inputTypes, ScalarFunctions.formalArrays] using ih

theorem ProcedureInputFramesAt.arrayViewKinds {frame index final}
    (source : ProcedureInputFramesAt frame index final)
    (initial : ∀ item ∈ frame.arrayNames.names, item.isBoolean = false ∧ item.viewSlot ≠ 0) :
    ∀ item ∈ final.arrayNames.names, item.isBoolean = false ∧ item.viewSlot ≠ 0 := by
  induction source with
  | done => exact initial
  | skip _ _ _ _ ih => exact ih initial
  | @next before final index _ _ _ accepted _ _ ih =>
      apply ih
      by_cases named : (ProcedureBindings.parameter before.procedures index).typeId ≠ 0
      · rw [appendProcedureParameter_array named accepted]
        intro item member
        rcases List.mem_append.mp member with old | fresh
        · exact initial item old
        · have same := List.mem_singleton.mp fresh
          subst item
          simp [arrayParameterBinding]
      · rw [appendProcedureParameter_scalar_arrays (by omega) accepted]
        exact initial

end Silver.Compose
