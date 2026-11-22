module

public import Silver.ProcedureDeclarationPrefixEquations
public import Silver.ProcedureDeclarationMeaning
public import Silver.FunctionDeclarationStateRecords
public import Silver.FunctionDeclarationInitialDomain

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 7000
set_option maxHeartbeats 2000000

theorem model_equations : HelperEquations modelCalls where
  appendParameter _ _ _ := appendProcedureParameter_model .. |>.symm
  inputFrameModel frame index _ := by
    rw [inputFrame_denotation]
    exact inputFrame_model_equation frame index
  inputFrame _ _ _ := rfl
  parameterStep _ _ _ _ _ := procedureParameterStep_model .. |>.symm
  parametersModel text _ state arguments _ := by
    rw [parameters_denotation]
    exact parameters_model_equation text state arguments
  parameters _ _ _ _ _ := rfl
  prefixStep _ _ _ _ _ _ := procedurePrefixStep_model .. |>.symm
  prefixModel text readFrame frame index declarationCount _ := by
    rw [prefix_denotation]
    exact prefix_model_equation text readFrame frame index declarationCount
  «prefix» _ _ _ _ := rfl

theorem invalid_native (text : Source) : FunctionDeclarationNative.NativeValidState text invalidState :=
  ⟨Expressions.model_invalid_state_valid text, Predicate.ScalarMetadata.headerReady_empty,
    by intro slot info found; simp [invalidState, Bindings.BindingEnvironment.get] at found⟩

theorem parameterStep_native {text state arguments}
    (valid : FunctionDeclarationNative.NativeValidState text state) :
    FunctionDeclarationNative.NativeValidState text (procedureParameterStep text state arguments).state := by
  have base := procedureParameterStep_state_valid (arguments := arguments) valid.base
  rw [step_model_equation] at base ⊢
  generalize stepParts modelCalls text state = parts at base ⊢
  refine ⟨base, ?_, ?_⟩
  · dsimp only [stepEquation]
    split
    · exact Predicate.ScalarMetadata.headerReady_empty
    · split
      · exact valid.ready
      · split
        · exact valid.ready
        · exact Predicate.ScalarMetadata.headerReady_empty
  · dsimp only [stepEquation]
    split
    · exact (invalid_native text).bounds
    · split
      · exact valid.bounds
      · split
        · exact valid.bounds
        · exact (invalid_native text).bounds

/-- Prefix_Step admits any component-typed formal with its written source
name and nonempty interval. Its type/mode guards establish validity without
requiring the stronger declaration-formal predicate. -/
theorem appendParameter_native_raw {text frame parameter}
    (valid : FunctionDeclarationNative.NativeValidState text frame)
    (name : ProcedureBindings.NameSpan text parameter.first parameter.after)
    (bounded : parameter.bounds.Bounded)
    (nonempty : parameter.bounds.lower ≤ parameter.bounds.upper) :
    FunctionDeclarationNative.NativeValidState text (appendProcedureParameter frame parameter) := by
  refine ⟨?_, appendProcedureParameter_headerReady valid.ready nonempty, ?_⟩
  · by_cases named : parameter.typeId ≠ 0
    · rw [appendProcedureParameter, ite_eq_left named]
      split
      · exact Expressions.model_invalid_state_valid text
      · exact appendArrayParameter_valid valid.base name
    · exact appendProcedureParameter_valid valid.base
        ⟨name, bounded, nonempty, (fun present => False.elim (named present)), by
          have zero : parameter.typeId = 0 := Classical.not_not.mp named
          simp [zero]⟩
  · dsimp only [appendProcedureParameter, appendArrayParameter]
    split <;> split <;> (try split) <;>
      first | exact valid.bounds | exact (invalid_native text).bounds

theorem appendParameter_native {text frame parameter}
    (valid : FunctionDeclarationNative.NativeValidState text frame)
    (formal : ProcedureBindings.ValidFormal text parameter) :
    FunctionDeclarationNative.NativeValidState text (appendProcedureParameter frame parameter) :=
  appendParameter_native_raw valid formal.1 formal.2.1 formal.2.2.1

theorem prefixStep_native (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat)
    (valid : PrefixStepDomain text readFrame frame parameter declarationCount) :
    FunctionDeclarationNative.NativeValidState text
      (procedurePrefixStep text readFrame frame parameter declarationCount) := by
  dsimp only [procedurePrefixStep]
  split
  · exact invalid_native text
  · apply appendParameter_native_raw
    · exact (FunctionDeclarationNative.StateInput.withPosition valid.1 valid.2.2.1 _
        (fixedAfter_result_bound text _ ";" false (by decide))).2
    · exact valid.2.2.2.2.2.2.1
    · exact valid.2.2.2.2.1.2.2.1
    · have nonempty := valid.2.2.2.2.2.2.2
      simp only [Bool.not_eq_true', Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty
      omega

theorem model_contracts : HelperContracts modelCalls where
  parameterStep text tv state arguments valid :=
    ⟨FunctionDeclarationNative.StateInput.ofNative tv (parameterStep_native valid.2),
      (parameterStep_position text state arguments).2⟩
  prefixStep text readFrame frame parameter declarationCount valid := by
    refine ⟨FunctionDeclarationNative.StateInput.ofNative valid.1
      (prefixStep_native text readFrame frame parameter declarationCount valid), ?_⟩
    by_cases zero : (procedurePrefixStep text readFrame frame parameter declarationCount).position = 0
    · exact .inl zero
    · exact .inr (prefixStep_procedures text readFrame frame parameter declarationCount zero)

end Silver.Compose.ProcedureDeclarationNative
