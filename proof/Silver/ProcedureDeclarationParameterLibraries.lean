module

public import Silver.ProcedureDeclarationHelperEquations
public import Silver.FunctionDeclarationHeaderLibraries
public import Silver.ProcedureBindingsSourceBridge

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 2000000

/-- Direct identities to previously interpreted callees. The procedure
parameter step and its traversal are conclusions, never fields of this link. -/
structure ParameterLinks (calls : Calls) (inherited : Expressions.Calls)
    (ordinary : FunctionDeclarationNative.Calls) (metadata : ProcedureBindings.Native.Calls)
    (visibility : FunctionVisibilityNative.Implementation) : Prop where
  skip : calls .skip = inherited.function .skip
  nameAfter : calls .nameAfter = inherited.function .nameAfter
  take : ∀ text position word flag,
    calls .take text position (.fixed word flag) = inherited.function .takeToken text position (.fixed word flag)
  newName : calls .newName = inherited.function .newName
  functionType : calls .functionType = ordinary .functionType
  appendFormal : calls .appendProcedureFormal = metadata.appendFormal
  hideName : calls .hideName = visibility.hideName
  equal : calls .equal = visibility.calls.equalName
  scalarAppend : calls .scalarAppend = inherited.function .scalarAppend

structure HeaderLexical (calls : Calls) : Prop where
  skip : ∀ text, FunctionBindings.Native.ValidText text → ∀ position, position ≤ text.length + 1 →
    calls .skip text position = skipAt text position
  nameAfter : ∀ text, FunctionBindings.Native.ValidText text → ∀ position, position ≤ text.length + 1 →
    calls .nameAfter text position = Compose.nameAfter text position
  take : ∀ text, FunctionBindings.Native.ValidText text → ∀ position word flag, position ≤ text.length + 1 →
    Expressions.ValidToken (.fixed word flag) →
    calls .take text position (.fixed word flag) = fixedAfter text position word flag

theorem native_token_valid (token : Token) : Expressions.ValidToken token.shell := by
  cases token <;> simp [Expressions.ValidToken, Expressions.allTokens, Token.shell]

theorem header_lexical {domain calls inherited ordinary metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (links : ParameterLinks calls inherited ordinary metadata visibility) : HeaderLexical calls where
  skip text tv position bound := by
    rw [links.skip]
    exact Expressions.interpreted_skip inherited source text tv position bound
  nameAfter text tv position bound := by
    rw [links.nameAfter]
    exact Expressions.interpreted_name inherited source text tv position bound
  take text tv position word flag bound tokenValid := by
    rw [links.take]
    exact Expressions.interpreted_take inherited source text tv position (.fixed word flag) bound tokenValid

structure StepBounds (text : Source) (state : ParserState) : Prop where
  first : (stepParts modelCalls text state).first ≤ text.length + 1
  after : (stepParts modelCalls text state).after ≤ text.length + 1
  colon : fixedAfter text (stepParts modelCalls text state).after ":" false ≤ text.length + 1
  inKeyword : fixedAfter text (fixedAfter text (stepParts modelCalls text state).after ":" false) "in" true ≤ text.length + 1
  outStart : (let colonEnd := fixedAfter text (stepParts modelCalls text state).after ":" false
    let inEnd := fixedAfter text colonEnd "in" true
    if inEnd = 0 then colonEnd else inEnd) ≤ text.length + 1
  start : (stepParts modelCalls text state).start ≤ text.length + 1
  value : (stepParts modelCalls text state).value.after ≤ text.length + 1

theorem step_bounds (text : Source) (state : ParserState) (bound : state.position ≤ text.length + 1) :
    StepBounds text state := by
  refine ⟨Expressions.model_skip_valid text state.position bound, function_nameAfter_bound text _,
    fixedAfter_result_bound text _ ":" false (by decide),
    fixedAfter_result_bound text _ "in" true (by decide), ?_, ?_, functionTypeAt_position_bound text state _⟩
  · dsimp only
    split
    · exact fixedAfter_result_bound text _ ":" false (by decide)
    · exact fixedAfter_result_bound text _ "in" true (by decide)
  · dsimp +instances only [stepParts, modelCalls, tokenAfter]
    split <;> split
    · exact fixedAfter_result_bound text _ "out" true (by decide)
    · exact fixedAfter_result_bound text _ "in" true (by decide)
    · exact fixedAfter_result_bound text _ "out" true (by decide)
    · exact fixedAfter_result_bound text _ "in" true (by decide)

structure StepAdmitted (text : Source) (state : ParserState) (arguments : Bool) : Prop where
  allowed : newNameAllowed text state (stepParts modelCalls text state).first
    (stepParts modelCalls text state).after arguments = true
  value : (stepParts modelCalls text state).value.after ≠ 0
  space : state.procedures.parameters.length < ProcedureBindings.maxFormals

theorem step_admitted (text : Source) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state)
    (accepted : stepPrefix modelCalls text state arguments (stepParts modelCalls text state) = false) :
    StepAdmitted text state arguments := by
  have capacity := valid.1.procedures.2.1
  simp only [stepPrefix, Bool.or_eq_false_iff, Bool.not_eq_false', decide_eq_false_iff_not] at accepted
  refine ⟨accepted.1.1.1, ?_, ?_⟩ <;> omega

theorem parameter_step_imports {domain calls inherited ordinary metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (exactDomain : FunctionDeclarationNative.ExactDomain domain)
    (ordinaryEquations : FunctionDeclarationNative.HeaderEquations ordinary)
    (ordinaryImports : FunctionDeclarationNative.HeaderImports ordinary)
    (procedures : ProcedureBindings.SourceBridge.ImplementationCorrect metadata)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilityEquations : FunctionVisibilityNative.Equations visibility)
    (links : ParameterLinks calls inherited ordinary metadata visibility)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : StepImports calls text state arguments := by
  have native := valid.2.inherited exactDomain
  have lexical := header_lexical source links
  have bounds := step_bounds text state valid.2.base.1
  have functionType : calls .functionType text state (stepParts modelCalls text state).start =
      functionTypeAt text state (stepParts modelCalls text state).start := by
    rw [links.functionType]
    exact FunctionDeclarationNative.interpreted_functionType ordinary ordinaryEquations ordinaryImports
      text tv state _ valid bounds.start
  refine {
    skip := lexical.skip text tv _ valid.2.base.1,
    nameAfter := lexical.nameAfter text tv _ bounds.first,
    colon := lexical.take text tv _ _ _ bounds.after (native_token_valid .colon),
    inKeyword := lexical.take text tv _ _ _ bounds.colon (native_token_valid .inKeyword),
    outKeyword := lexical.take text tv _ _ _ bounds.outStart (native_token_valid .outKeyword),
    functionType := functionType,
    newName := ?_, skipType := ?_, equal := ?_, append := ?_, hide := ?_, separator := ?_, close := ?_}
  all_goals dsimp only
  · rw [links.newName]
    exact Expressions.interpreted_newName inherited source text tv state _ _ arguments native bounds.first bounds.after
  · intro _
    exact lexical.skip text tv _ bounds.start
  · intro accepted
    have admitted := step_admitted text state arguments valid accepted
    rw [links.equal]
    exact visibilityPrimitives.equalName text tv _ _ _ _
      (Expressions.model_new_name_valid text state _ _ arguments bounds.after admitted.allowed)
      ((functionTypeAt_span text state _ bounds.start).resolve_left admitted.value)
  · intro accepted _
    have admitted := step_admitted text state arguments valid accepted
    have bounded := ((functionTypeAt_good text state _ valid.2.base.2.2.2.2.2.2.2.1).resolve_left admitted.value).1
    rw [links.appendFormal]
    exact procedures.appendFormal state.procedures valid.1.procedures _
      ⟨Nat.le_trans bounds.first (Nat.add_le_add_right tv.2 1),
        Nat.le_trans bounds.after (Nat.add_le_add_right tv.2 1), bounded⟩ admitted.space
  · intro accepted _
    have admitted := step_admitted text state arguments valid accepted
    rw [links.hideName]
    exact FunctionVisibilityNative.hideName_meaning visibility visibilityPrimitives visibilityEquations text tv _ _ _
      (Expressions.model_new_name_valid text state _ _ arguments bounds.after admitted.allowed)
  · intro _ _
    exact lexical.take text tv _ _ _ bounds.value (native_token_valid .semicolon)
  · intro _ _
    exact lexical.take text tv _ _ _ bounds.value (native_token_valid .rightParenthesis)

theorem parameter_imports {domain calls inherited ordinary metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (exactDomain : FunctionDeclarationNative.ExactDomain domain)
    (ordinaryEquations : FunctionDeclarationNative.HeaderEquations ordinary)
    (ordinaryImports : FunctionDeclarationNative.HeaderImports ordinary)
    (procedures : ProcedureBindings.SourceBridge.ImplementationCorrect metadata)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilityEquations : FunctionVisibilityNative.Equations visibility)
    (links : ParameterLinks calls inherited ordinary metadata visibility) : ParameterImports calls where
  step := parameter_step_imports source exactDomain ordinaryEquations ordinaryImports
    procedures visibilityPrimitives visibilityEquations links

theorem scalar_append_meaning {domain calls inherited ordinary metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (links : ParameterLinks calls inherited ordinary metadata visibility) : ScalarAppendMeaning calls where
  append names item space := by
    rw [links.scalarAppend]
    exact source.scalarAppend names item space

end Silver.Compose.ProcedureDeclarationNative
