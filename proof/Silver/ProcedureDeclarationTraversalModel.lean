module

public import Silver.ProcedureDeclarationHelperModel
public import Silver.ProcedureDeclarationTraversalContracts

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 7000
set_option maxHeartbeats 2000000

theorem parameters_native {text state arguments}
    (valid : FunctionDeclarationNative.NativeValidState text state) :
    FunctionDeclarationNative.NativeValidState text (procedureParametersModel text state arguments) := by
  rw [procedureParametersModel]
  split
  · exact invalid_native text
  · split
    · exact parameterStep_native valid
    · split
      · exact parameters_native (parameterStep_native valid)
      · exact invalid_native text
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem parameters_forward (text : Source) (state : ParserState) (arguments : Bool) :
    (procedureParametersModel text state arguments).position = 0 ∨
      state.position < (procedureParametersModel text state arguments).position := by
  rw [procedureParametersModel]
  split
  · exact .inl rfl
  · rename_i nonzero
    have first := (parameterStep_position text state arguments).2.resolve_left nonzero
    split
    · exact .inr first
    · split
      · rcases parameters_forward text (procedureParameterStep text state arguments).state arguments with
          failed | advanced
        · exact .inl failed
        · exact .inr (Nat.lt_trans first advanced)
      · exact .inl rfl
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem parameters_post {text state arguments}
    (valid : FunctionDeclarationNative.NativeValidState text state)
    (accepted : (procedureParametersModel text state arguments).position ≠ 0) :
    ParametersPost state (procedureParametersModel text state arguments) := by
  have extension := (procedureParametersModel_valid text state arguments valid.base.procedures
    valid.base.2.2.2.2.2.2.2.1 valid.base.arrayTypes).resolve_left accepted
  have fields := (procedureParametersModel_fields_or_rejected text state arguments).resolve_left accepted
  unfold ProcedureParameterFields at fields
  have pure := congrArg ParserState.pure fields
  exact ⟨(parameters_forward text state arguments).resolve_left accepted,
    congrArg List.length extension.items, extension.functions, extension.grows,
    extension.firstParameter, pure⟩

theorem inputFrame_native {text frame} (index : Nat)
    (valid : FunctionDeclarationNative.NativeValidState text frame) (positive : 0 < index) :
    FunctionDeclarationNative.NativeValidState text (procedureInputFrameModel frame index) := by
  rw [procedureInputFrameModel]
  split
  · exact invalid_native text
  · split
    · exact valid
    · rename_i inside
      split
      · exact inputFrame_native (index + 1) valid (by omega)
      · have typed := valid.base.procedures.2.2.1 _ (ProcedureBindings.parameter_mem positive (by omega))
        dsimp only
        split
        · exact invalid_native text
        · split
          · exact inputFrame_native (index + 1) (appendParameter_native valid typed) (by omega)
          · exact invalid_native text
termination_by frame.procedures.parameters.length + 1 - index
decreasing_by all_goals first | omega | assumption

theorem inputFrame_post (frame : ParserState) (index : Nat)
    (accepted : (procedureInputFrameModel frame index).position ≠ 0) :
    InputFramePost frame (procedureInputFrameModel frame index) := by
  have fields := procedureInputFrameModel_fields frame index accepted
  have grows := procedureInputFrameModel_grows frame index accepted
  unfold ProcedureFrameFields at fields
  have position := congrArg ParserState.position fields
  have functions := congrArg ParserState.functions fields
  have procedures := congrArg ParserState.procedures fields
  have firstParameter := congrArg ParserState.firstProcedureParameter fields
  exact ⟨position, functions, procedures, firstParameter, grows.1, grows.2⟩

theorem prefixStep_post (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat)
    (accepted : (procedurePrefixStep text readFrame frame parameter declarationCount).position ≠ 0) :
    PrefixPost frame (procedurePrefixStep text readFrame frame parameter declarationCount) := by
  dsimp only [procedurePrefixStep] at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i permitted
    simp only [ite_eq_right permitted]
    have fields := appendProcedureParameter_fields _ parameter accepted
    have grows := appendProcedureParameter_grows _ parameter accepted
    unfold ProcedureFrameFields at fields
    have functions := congrArg ParserState.functions fields
    have procedures := congrArg ParserState.procedures fields
    have position := congrArg ParserState.position fields
    refine ⟨?_, functions, procedures, grows.1⟩
    rw [position]
    dsimp only
    simp only [not_or] at permitted
    omega

theorem prefix_native (text : Source) (readFrame frame : ParserState) (index declarationCount : Nat)
    (valid : PrefixModelDomain text readFrame frame index declarationCount) :
    FunctionDeclarationNative.NativeValidState text
      (procedurePrefixModel text readFrame frame index declarationCount) := by
  rw [procedurePrefixModel]
  split
  · exact invalid_native text
  · split
    · exact valid.2.2.1.2
    · rename_i inside
      have member := ProcedureBindings.parameter_mem valid.2.2.2.2.1 (Nat.le_of_not_gt inside)
      have typed := valid.2.2.1.1.procedures.2.2.1 _ member
      have formal := valid.2.2.1.2.base.procedures.2.2.1 _ member
      have stepDomain : PrefixStepDomain text readFrame frame
          (ProcedureBindings.parameter frame.procedures index) declarationCount :=
        ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1, typed, formal.1.1, formal.1, by
          simp only [Integer.Interval.isEmpty, Bool.not_eq_true', decide_eq_false_iff_not]
          have nonempty := formal.2.2.1
          omega⟩
      split
      · exact prefix_native text readFrame frame (index + 1) declarationCount
          ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1, by omega, by omega⟩
      · dsimp only
        split
        · exact invalid_native text
        · rename_i accepted
          have same := prefixStep_procedures text readFrame frame
            (ProcedureBindings.parameter frame.procedures index) declarationCount accepted
          split
          · exact prefix_native text readFrame
              (procedurePrefixStep text readFrame frame (ProcedureBindings.parameter frame.procedures index) declarationCount)
              (index + 1) declarationCount
              ⟨valid.1, valid.2.1, FunctionDeclarationNative.StateInput.ofNative valid.1
                (prefixStep_native text readFrame frame _ declarationCount stepDomain),
                valid.2.2.2.1, by omega, by rw [same]; omega⟩
          · exact invalid_native text
termination_by frame.procedures.parameters.length + 1 - index
decreasing_by all_goals first | omega | assumption

theorem prefix_post (text : Source) (readFrame frame : ParserState) (index declarationCount : Nat) :
    (procedurePrefixModel text readFrame frame index declarationCount).position = 0 ∨
      PrefixPost frame (procedurePrefixModel text readFrame frame index declarationCount) := by
  rw [procedurePrefixModel]
  split
  · exact .inl rfl
  · split
    · exact .inr ⟨Nat.le_refl _, rfl, rfl, Nat.le_refl _⟩
    · split
      · exact prefix_post text readFrame frame (index + 1) declarationCount
      · dsimp only
        split
        · exact .inl rfl
        · rename_i accepted
          have first := prefixStep_post text readFrame frame _ declarationCount accepted
          split
          · rcases prefix_post text readFrame
                (procedurePrefixStep text readFrame frame (ProcedureBindings.parameter frame.procedures index) declarationCount)
                (index + 1) declarationCount with failed | rest
            · exact .inl failed
            · exact .inr ⟨Nat.le_trans first.position rest.position, rest.functions.trans first.functions,
                rest.procedures.trans first.procedures, Nat.le_trans first.scalars rest.scalars⟩
          · exact .inl rfl
termination_by frame.procedures.parameters.length + 1 - index
decreasing_by all_goals first | omega | assumption

theorem model_traversal_contracts : HelperTraversalContracts modelCalls where
  parameters text tv state arguments valid := by
    refine ⟨FunctionDeclarationNative.StateInput.ofNative tv (parameters_native valid.2), ?_⟩
    by_cases rejected : (procedureParametersAt text state arguments).position = 0
    · exact .inl rejected
    · exact .inr (parameters_post valid.2 rejected)
  inputFrame text frame valid := by
    refine ⟨FunctionDeclarationNative.StateInput.ofNative valid.1
      (inputFrame_native frame.firstProcedureParameter valid.2.1.2 valid.2.2), ?_⟩
    by_cases rejected : (procedureInputFrame text frame).position = 0
    · exact .inl rejected
    · exact .inr (inputFrame_post frame frame.firstProcedureParameter rejected)
  prefixModel text readFrame frame index declarationCount valid :=
    ⟨FunctionDeclarationNative.StateInput.ofNative valid.1
      (prefix_native text readFrame frame index declarationCount valid),
      prefix_post text readFrame frame index declarationCount⟩
  «prefix» text frame declarationCount valid := by
    have modelDomain : PrefixModelDomain text frame frame frame.firstProcedureParameter declarationCount :=
      ⟨valid.1.1, valid.1.2.1, valid.1.2.1, valid.2, valid.1.2.2, ((FunctionDeclarationNative.nativeValidState_iff text frame).mp valid.1.2.1.2).2.firstProcedureParameter⟩
    exact ⟨FunctionDeclarationNative.StateInput.ofNative valid.1.1
      (prefix_native text frame frame frame.firstProcedureParameter declarationCount modelDomain),
      prefix_post text frame frame frame.firstProcedureParameter declarationCount⟩

end Silver.Compose.ProcedureDeclarationNative
