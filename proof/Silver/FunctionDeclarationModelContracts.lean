module

public import Silver.FunctionDeclarationTraversalContracts
public import Silver.FunctionDeclarationStateRecords
public import Silver.FunctionBodyFrameReadiness
public import Silver.PredicateNativeRanges

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 3000000

attribute [local irreducible] ScalarExpression.ArrayGrammar.read

private theorem parameters_progress (text : Source) (state : ParserState) (arguments : Bool) :
    (parametersModel text state arguments).position = 0 ∨
      state.position < (parametersModel text state arguments).position := by
  rw [parametersModel]
  split
  · exact .inl rfl
  · rename_i nonzero
    have step := (parameterStep_position text state arguments).2.resolve_left nonzero
    split
    · exact .inr step
    · split
      · rcases parameters_progress text (parameterStep text state arguments).state arguments with zero | rest
        · exact .inl zero
        · exact .inr (Nat.lt_trans step rest)
      · exact .inl rfl
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

private def LocalFields (before after : ParserState) : Prop :=
  after.functions = before.functions ∧ after.firstParameter = before.firstParameter ∧ after.pure = before.pure

private theorem local_fields (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (functionLocalAt text state arguments).position ≠ 0) :
    LocalFields state (functionLocalAt text state arguments) := by
  have scalar : (scalarDeclarationAt text state arguments).position = 0 ∨
      LocalFields state (scalarDeclarationAt text state arguments) := by
    dsimp only [scalarDeclarationAt]
    split
    · exact .inl rfl
    · exact .inr ⟨rfl, rfl, rfl⟩
  have boolean : (booleanDeclarationAt text state arguments).position = 0 ∨
      LocalFields state (booleanDeclarationAt text state arguments) := by
    dsimp only [booleanDeclarationAt]
    split
    · exact .inl rfl
    · split
      · exact .inl rfl
      · exact .inr ⟨rfl, rfl, rfl⟩
  dsimp only [functionLocalAt] at accepted ⊢
  split
  · rename_i selected
    exact scalar.resolve_left selected
  · rename_i selected
    simp only [selected, ↓reduceIte] at accepted
    exact boolean.resolve_left accepted

private theorem locals_post (text : Source) (state : ParserState) (arguments : Bool) :
    (functionLocalsModel text state arguments).position = 0 ∨
      state.position ≤ (functionLocalsModel text state arguments).position ∧
      LocalFields state (functionLocalsModel text state arguments) := by
  rw [functionLocalsModel]
  split
  · exact .inl rfl
  · split
    · exact .inr ⟨Nat.le_refl _, rfl, rfl, rfl⟩
    · dsimp only
      split
      · exact .inl rfl
      · rename_i nonzero
        have progress := (functionLocalAt_position text state arguments).2.resolve_left nonzero
        have fields := local_fields text state arguments nonzero
        split
        · rcases locals_post text (functionLocalAt text state arguments) arguments with zero | rest
          · exact .inl zero
          · exact .inr ⟨Nat.le_trans (Nat.le_of_lt progress) rest.1,
              rest.2.1.trans fields.1, rest.2.2.1.trans fields.2.1, rest.2.2.2.trans fields.2.2⟩
        · exact .inl rfl
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

private def FramePost (before after : ParserState) : Prop :=
  after.position = before.position ∧ after.functions = before.functions ∧
    before.scalarNames.length ≤ after.scalarNames.length ∧ before.booleanNames.length ≤ after.booleanNames.length

private theorem append_post (frame : ParserState) (parameter : FunctionBindings.Formal) :
    (appendParameter frame parameter).position = 0 ∨ FramePost frame (appendParameter frame parameter) := by
  dsimp only [appendParameter]
  split
  · unfold appendArrayParameter
    split
    · exact .inl rfl
    · exact .inr ⟨rfl, rfl, Nat.le_refl _, Nat.le_refl _⟩
  · split
    · split
      · exact .inl rfl
      · exact .inr ⟨rfl, rfl, by simp, Nat.le_refl _⟩
    · split
      · exact .inl rfl
      · exact .inr ⟨rfl, rfl, Nat.le_refl _, by simp⟩

private theorem frame_post (frame : ParserState) (index : Nat) :
    (parameterFrameModel frame index).position = 0 ∨ FramePost frame (parameterFrameModel frame index) := by
  rw [parameterFrameModel]
  split
  · exact .inl rfl
  · split
    · exact .inr ⟨rfl, rfl, Nat.le_refl _, Nat.le_refl _⟩
    · dsimp only
      split
      · exact .inl rfl
      · rename_i nonzero
        have first := (append_post frame (FunctionBindings.parameter frame.functions index)).resolve_left nonzero
        split
        · rcases frame_post (appendParameter frame (FunctionBindings.parameter frame.functions index)) (index + 1) with zero | rest
          · exact .inl zero
          · exact .inr ⟨rest.1.trans first.1, rest.2.1.trans first.2.1,
              Nat.le_trans first.2.2.1 rest.2.2.1, Nat.le_trans first.2.2.2 rest.2.2.2⟩
        · exact .inl rfl
termination_by frame.functions.parameters.length + 1 - index
decreasing_by assumption

private theorem type_bounded (text : Source) (state : ParserState) (position : Nat)
    (valid : NativeValidState text state) : (functionTypeAt text state position).bounds.Bounded := by
  dsimp only [functionTypeAt]
  split
  · exact scalarTypeAt_bounded text state position valid.base.2.2.2.2.2.2.2.1
  · split
    · exact Integer.Interval.empty_bounded
    · exact Integer.Interval.full_bounded

private theorem type_id_bounded (text : Source) (state : ParserState) (position : Nat) :
    (functionTypeAt text state position).typeId ≤ ArrayBindings.maxTypes := by
  dsimp only [functionTypeAt]
  split
  · exact Nat.zero_le _
  · split <;> exact Nat.zero_le _

private theorem actual_post (text : Source) (context : Predicate.Native.Context) (position : Nat)
    (facts : Predicate.ActiveFlow) (formal : FunctionBindings.Formal) (scalar : formal.typeId = 0)
    (tv : FunctionBindings.Native.ValidText text) (cv : Predicate.Native.ValidContext text context)
    (bounded : position ≤ text.length + 1) (accepted : Predicate.actualAfter text context.model position facts formal ≠ 0) :
    0 < position ∧ position < Predicate.actualAfter text context.model position facts formal ∧
      Predicate.actualAfter text context.model position facts formal ≤ text.length + 1 := by
  simp only [Predicate.actualAfter, scalar, ne_eq, not_true_eq_false, ↓reduceIte] at accepted ⊢
  split
  · rename_i boolean
    simp only [boolean, ↓reduceIte] at accepted
    have positive : position ≠ 0 := by
      intro zero
      rw [zero, Predicate.readCondition, Predicate.readRelation] at accepted
      exact accepted rfl
    exact ⟨by omega, Predicate.Native.condition_progress text context.model position facts accepted,
      Predicate.Native.condition_bound text context.model position facts tv cv.1 bounded⟩
  · rename_i integer
    simp only [integer, ↓reduceIte] at accepted
    split at accepted
    · exact False.elim (accepted rfl)
    · rename_i allowed
      have nonzero : (Predicate.readScalarInFlow text context.model position facts).after ≠ 0 :=
        fun zero => allowed (.inl zero)
      obtain ⟨expression, parsed⟩ := ScalarExpression.ArrayGrammar.read_sound bounded nonzero
      simp only [allowed, ↓reduceIte]
      exact parsed.cursorBounds

private theorem return_post (text : Source) (context : Predicate.Native.Context)
    (scan : Predicate.BodyScan) (resultType : FunctionTypeResult)
    (tv : FunctionBindings.Native.ValidText text) (valid : ReturnInput text context scan resultType) :
    functionReturnAfter text context.model scan resultType = 0 ∨
      scan.position < functionReturnAfter text context.model scan resultType ∧
      functionReturnAfter text context.model scan resultType ≤ text.length + 1 := by
  by_cases zero : functionReturnAfter text context.model scan resultType = 0
  · exact .inl zero
  · have startBound := fixedAfter_result_bound text scan.position "return" true (by decide)
    have after := actual_post text context (fixedAfter text scan.position "return" true) scan.facts
      ⟨0, 0, resultType.kind, resultType.bounds, 0⟩ rfl tv valid.context startBound zero
    have start := Expressions.model_fixed_advances text scan.position "return" true valid.scan.1 (by decide)
      (Nat.ne_of_gt after.1)
    exact .inr ⟨Nat.lt_trans start after.2.1, after.2.2⟩

theorem model_header_contracts : HeaderContracts modelCalls where
  parameterStep text tv state arguments valid := by
    refine ⟨StateInput.ofNative tv ⟨parameterStep_state_valid valid.2.base,
      parameterStep_headerReady valid.2.ready, parameterStep_nameBounds valid.2.bounds⟩,
      (parameterStep_position text state arguments).2⟩
  localStep text tv state arguments valid :=
    ⟨StateInput.ofNative tv ⟨functionLocalAt_valid valid.2.base,
      functionLocalAt_headerReady valid.2.ready, functionLocalAt_nameBounds valid.2.bounds⟩,
      (functionLocalAt_position text state arguments).2⟩

theorem model_traversal_contracts : TraversalContracts modelCalls where
  parameters text tv state arguments valid := by
    refine ⟨StateInput.ofNative tv ⟨parametersModel_state_valid valid.2.base,
      parametersModel_headerReady valid.2.ready, parametersModel_nameBounds valid.2.bounds⟩, ?_⟩
    by_cases zero : (parametersAt text state arguments).position = 0
    · exact .inl zero
    · have extension := (parametersAt_valid text state arguments valid.2.base.functions
        valid.2.base.2.2.2.2.2.2.2.1 valid.2.base.arrayTypes).resolve_left zero
      have fields := parametersAt_fields zero
      unfold ParameterFieldsPreserved at fields
      have purity := congrArg ParserState.pure fields
      exact .inr ⟨(parameters_progress text state arguments).resolve_left zero,
        congrArg List.length extension.items, extension.grows, extension.firstParameter,
        purity⟩
  locals text tv state arguments valid :=
    ⟨StateInput.ofNative tv ⟨functionLocalsModel_valid valid.2.base,
      functionLocalsModel_headerReady valid.2.ready, functionLocalsModel_nameBounds valid.2.bounds⟩,
      locals_post text state arguments⟩
  parameterFrame text tv state valid positive :=
    ⟨StateInput.ofNative tv ⟨parameterFrameModel_valid state.firstParameter valid.2.base positive,
      parameterFrameModel_headerReady state.firstParameter valid.2.base positive valid.2.ready,
      parameterFrameModel_nameBounds state.firstParameter valid.2.bounds⟩,
      frame_post state state.firstParameter⟩
  functionType text tv state position valid bound := by
    change TypeResultRecord (functionTypeAt text state position) ∧
      ((functionTypeAt text state position).after = 0 ∨
      position < (functionTypeAt text state position).after ∧
      (functionTypeAt text state position).after ≤ text.length + 1 ∧
      (functionTypeAt text state position).bounds.isEmpty = false)
    have afterBound := functionTypeAt_position_bound text state position
    refine ⟨⟨by change (functionTypeAt text state position).after ≤ 4097; have size := tv.2; omega, type_bounded text state position valid.2, type_id_bounded text state position⟩, ?_⟩
    by_cases zero : (functionTypeAt text state position).after = 0
    · exact .inl zero
    · have span := (functionTypeAt_span text state position bound).resolve_left zero
      have skipped := skipAt_advances text position bound (Nat.ne_of_gt span.1)
      have good := (functionTypeAt_good text state position valid.2.base.2.2.2.2.2.2.2.1).resolve_left zero
      exact .inr ⟨by have ordered := span.2.1; omega, afterBound,
        by simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not]; omega⟩
  returnAfter text tv context scan resultType valid := return_post text context scan resultType tv valid

end Silver.Compose.FunctionDeclarationNative
