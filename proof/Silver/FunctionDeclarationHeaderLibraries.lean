module

public import Silver.FunctionDeclarationHeaderEquations
public import Silver.FunctionVisibilityEquations
public import Silver.FunctionBindingsSourceBridge
public import Silver.ComposeHelperEquations
public import Silver.ComposeArrayTypeEquations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 5000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

/-- The lower inherited helpers needed by function locals. This deliberately
contains no function-declaration equation: the outer helper bundle is assembled
only after the function source bridge has been interpreted. -/
structure InheritedEquations (calls : Expressions.Calls) (domain : Expressions.StateDomain)
    : Prop extends Expressions.RawHelperEquations calls (domain := domain) where
  booleanDeclaration : ∀ text, Expressions.ValidText text → ∀ state arguments,
    Expressions.NativeState domain text state →
    calls.function .booleanDeclaration text state arguments = booleanDeclarationAt text state arguments

/-- Direct source-callee identities. The inherited Boolean declaration law is
already derived from its separately checked body and condition reader. -/
structure HeaderLinks (calls : Calls) (inherited : Expressions.Calls)
    (metadata : FunctionBindings.Native.Calls) (visibility : FunctionVisibilityNative.Implementation) : Prop where
  skip : calls .skip = inherited.function .skip
  nameAfter : calls .nameAfter = inherited.function .nameAfter
  take : ∀ text position word flag,
    calls .take text position (.fixed word flag) = inherited.function .takeToken text position (.fixed word flag)
  newName : calls .newName = inherited.function .newName
  scalarType : calls .scalarType = inherited.function .scalarType
  strings : calls .lookupString = inherited.function .lookupName
  scalars : calls .lookupScalar = inherited.function .scalarLookup
  booleans : calls .lookupBoolean = inherited.function .booleanLookup
  subtypes : calls .lookupSubtype = inherited.function .subtypeLookup
  arrays : calls .lookupArray = inherited.function .arrayLookup
  arrayTypes : calls .lookupArrayType = inherited.function .arrayTypeLookup
  arrayType : calls .arrayTypeAt = inherited.function .arrayTypeAt
  functions : calls .lookupFunction = metadata.lookup
  procedures : calls .lookupProcedure = inherited.function .procedureLookup
  appendFormal : calls .appendFormal = metadata.appendFormal
  formalHides : calls .formalHides = visibility.formalHides
  hideName : calls .hideName = visibility.hideName
  equal : calls .equal = visibility.calls.equalName
  scalarDeclaration : calls .scalarDeclaration = inherited.function .scalarDeclaration
  booleanDeclaration : calls .booleanDeclaration = inherited.function .booleanDeclaration
  scalarAppend : calls .scalarAppend = inherited.function .scalarAppend

theorem NativeValidState.inherited {domain : Expressions.StateDomain} (exactDomain : ExactDomain domain)
    {text state} (valid : NativeValidState text state) : Expressions.NativeState domain text state :=
  ⟨(exactDomain.state text state).mpr valid, valid.bounds⟩

/-- Position-only lexical helpers have no additional state requirements. -/
structure HeaderLexical (calls : Calls) : Prop where
  skip : ∀ text, FunctionBindings.Native.ValidText text → ∀ position, position ≤ text.length + 1 →
    calls .skip text position = skipAt text position
  nameAfter : ∀ text, FunctionBindings.Native.ValidText text → ∀ position, position ≤ text.length + 1 →
    calls .nameAfter text position = Compose.nameAfter text position
  take : ∀ text, FunctionBindings.Native.ValidText text → ∀ position word flag, position ≤ text.length + 1 →
    Expressions.ValidToken (.fixed word flag) → calls .take text position (.fixed word flag) = fixedAfter text position word flag

theorem native_token_valid (token : Token) : Expressions.ValidToken token.shell := by
  cases token <;> simp [Expressions.ValidToken, Expressions.allTokens, Token.shell]

theorem header_lexical {domain calls inherited metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (links : HeaderLinks calls inherited metadata visibility) : HeaderLexical calls where
  skip text tv position bound := by
    rw [links.skip]
    exact Expressions.interpreted_skip inherited source text tv position bound
  nameAfter text tv position bound := by
    rw [links.nameAfter]
    exact Expressions.interpreted_name inherited source text tv position bound
  take text tv position word flag bound tokenValid := by
    rw [links.take]
    exact Expressions.interpreted_take inherited source text tv position (.fixed word flag) bound tokenValid

theorem header_type_imports {domain calls inherited metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (exactDomain : ExactDomain domain) (functions : FunctionBindings.SourceBridge.ImplementationCorrect metadata)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilityEquations : FunctionVisibilityNative.Equations visibility)
    (links : HeaderLinks calls inherited metadata visibility)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (position : Nat)
    (valid : StateInput text state) (bound : position ≤ text.length + 1) : TypeImports calls text state position := by
  have native := valid.2.inherited exactDomain
  have lexical := header_lexical source links
  have firstBound := Expressions.model_skip_valid text position bound
  have afterBound := fixedAfter_result_bound text (skipAt text position) "boolean" true (by decide)
  refine ⟨?_, lexical.skip text tv position bound, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [links.scalarType]
    exact Expressions.interpreted_scalarType inherited source text tv state position native bound
  · exact lexical.take text tv _ _ _ firstBound (native_token_valid .booleanName)
  · dsimp only
    rw [links.strings]
    exact Expressions.interpreted_lookup inherited source text tv state.names _ _ native.nativeNames firstBound afterBound
  · dsimp only
    rw [links.scalars]
    exact source.scalarLookup text tv state.scalarNames _ _ native.valid.2.2.2.2.2.1 firstBound afterBound
  · dsimp only
    rw [links.booleans]
    exact source.booleanLookup text tv state.booleanNames _ _ native.valid.2.2.2.2.2.2.2.2.1 firstBound afterBound
  · dsimp only
    rw [links.subtypes]
    exact Expressions.interpreted_subtypeLookup inherited source text tv state.subtypeNames _ _
      native.valid.2.2.2.2.2.2.2.1 firstBound afterBound
  · dsimp only
    rw [links.arrays]
    exact source.arrayLookup text tv state.arrayNames.table _ _ native.valid.arrays.1 firstBound afterBound
  · dsimp only
    rw [links.arrayTypes]
    exact source.arrayTypeLookup text tv state.arrayNames.types _ _ native.valid.arrayTypes firstBound afterBound
  · dsimp only
    rw [links.functions]
    exact functions.lookup text tv state.functions native.valid.2.2.2.2.2.2.2.2.2.1 _ _ firstBound afterBound
  · dsimp only
    rw [links.procedures]
    exact source.procedureLookup text tv state.procedures _ _ native.valid.procedures firstBound afterBound
  · dsimp only
    rw [links.formalHides]
    exact FunctionVisibilityNative.formalHides_meaning visibility visibilityPrimitives visibilityEquations
      text tv state valid.2 _ _ firstBound afterBound

theorem header_formalType_imports {domain calls inherited metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (exactDomain : ExactDomain domain) (functions : FunctionBindings.SourceBridge.ImplementationCorrect metadata)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilityEquations : FunctionVisibilityNative.Equations visibility)
    (links : HeaderLinks calls inherited metadata visibility) (equations : HeaderEquations calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (position : Nat)
    (valid : StateInput text state) (bound : position ≤ text.length + 1) :
    FormalTypeImports calls text state position := by
  have lexical := header_lexical source links
  refine ⟨?_, ?_, lexical.skip text tv position bound,
    lexical.nameAfter text tv _ (Expressions.model_skip_valid text position bound)⟩
  · rw [links.arrayType]
    exact Expressions.interpreted_arrayTypeAt inherited source text tv state position
      (valid.2.inherited exactDomain) bound
  · rw [equations.functionType text tv state position valid bound]
    exact functionType_imports calls text state position
      (header_type_imports source exactDomain functions visibilityPrimitives visibilityEquations links
        text tv state position valid bound)

structure StepBounds (text : Source) (state : ParserState) : Prop where
  first : (stepParts modelCalls text state).first ≤ text.length + 1
  after : (stepParts modelCalls text state).after ≤ text.length + 1
  colon : fixedAfter text (stepParts modelCalls text state).after ":" false ≤ text.length + 1
  start : (stepParts modelCalls text state).start ≤ text.length + 1
  value : (stepParts modelCalls text state).value.after ≤ text.length + 1

theorem step_bounds (text : Source) (state : ParserState) (bound : state.position ≤ text.length + 1) :
    StepBounds text state := by
  refine ⟨Expressions.model_skip_valid text state.position bound, function_nameAfter_bound text _,
    fixedAfter_result_bound text _ ":" false (by decide),
    fixedAfter_result_bound text _ "in" true (by decide), formalTypeAt_position_bound text state _⟩

structure StepAdmitted (text : Source) (state : ParserState) (arguments : Bool) : Prop where
  allowed : newNameAllowed text state (stepParts modelCalls text state).first
    (stepParts modelCalls text state).after arguments = true
  value : (stepParts modelCalls text state).value.after ≠ 0
  space : state.functions.parameters.length < FunctionBindings.maxFormals

theorem step_admitted (text : Source) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state)
    (accepted : stepPrefix modelCalls text state arguments (stepParts modelCalls text state) = false) :
    StepAdmitted text state arguments := by
  have capacity := valid.1.functions.2.1
  simp only [stepPrefix, Bool.or_eq_false_iff, Bool.not_eq_false', decide_eq_false_iff_not] at accepted
  refine ⟨accepted.1.1.1, ?_, ?_⟩ <;> omega

theorem header_step_imports {domain calls inherited metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (exactDomain : ExactDomain domain) (functions : FunctionBindings.SourceBridge.ImplementationCorrect metadata)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilityEquations : FunctionVisibilityNative.Equations visibility)
    (links : HeaderLinks calls inherited metadata visibility) (equations : HeaderEquations calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : StepImports calls text state arguments := by
  have native := valid.2.inherited exactDomain
  have lexical := header_lexical source links
  have bounds := step_bounds text state valid.2.base.1
  have formalType : calls .formalType text state (stepParts modelCalls text state).start =
      formalTypeAt text state (stepParts modelCalls text state).start := by
    rw [equations.formalType text tv state _ valid bounds.start]
    exact formalType_imports calls text state _
      (header_formalType_imports source exactDomain functions visibilityPrimitives visibilityEquations links equations
        text tv state _ valid bounds.start)
  refine {
    skip := lexical.skip text tv _ valid.2.base.1,
    nameAfter := lexical.nameAfter text tv _ bounds.first,
    colon := lexical.take text tv _ _ _ bounds.after (native_token_valid .colon),
    inKeyword := lexical.take text tv _ _ _ bounds.colon (native_token_valid .inKeyword), formalType := formalType,
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
      ((formalTypeAt_span text state _ bounds.start).resolve_left admitted.value)
  · intro accepted _
    have admitted := step_admitted text state arguments valid accepted
    have bounded := ((formalTypeAt_good text state _ valid.2.base.2.2.2.2.2.2.2.1 valid.2.base.arrayTypes).resolve_left admitted.value).1
    rw [links.appendFormal]
    exact functions.appendFormal state.functions valid.1.functions _
      ⟨Nat.le_trans bounds.first (Nat.add_le_add_right tv.2 1),
        Nat.le_trans bounds.after (Nat.add_le_add_right tv.2 1), bounded,
        Nat.le_trans (formalTypeAt_typeId_bound text state _) valid.2.base.arrayTypes.1⟩ admitted.space
  · intro accepted _
    have admitted := step_admitted text state arguments valid accepted
    rw [links.hideName]
    exact FunctionVisibilityNative.hideName_meaning visibility visibilityPrimitives visibilityEquations text tv _ _ _
      (Expressions.model_new_name_valid text state _ _ arguments bounds.after admitted.allowed)
  · intro _ _
    exact lexical.take text tv _ _ _ bounds.value (native_token_valid .semicolon)
  · intro _ _
    exact lexical.take text tv _ _ _ bounds.value (native_token_valid .rightParenthesis)

theorem header_imports {domain calls inherited metadata visibility}
    (source : InheritedEquations inherited domain)
    (exactDomain : ExactDomain domain) (functions : FunctionBindings.SourceBridge.ImplementationCorrect metadata)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilityEquations : FunctionVisibilityNative.Equations visibility)
    (links : HeaderLinks calls inherited metadata visibility) (equations : HeaderEquations calls) : HeaderImports calls where
  functionType := header_type_imports source.toRawHelperEquations exactDomain functions visibilityPrimitives visibilityEquations links
  formalType := header_formalType_imports source.toRawHelperEquations exactDomain functions visibilityPrimitives visibilityEquations links equations
  step := header_step_imports source.toRawHelperEquations exactDomain functions visibilityPrimitives visibilityEquations links equations
  localStep text tv state arguments valid := by
    have native := valid.2.inherited exactDomain
    constructor
    · rw [links.scalarDeclaration]
      exact Expressions.interpreted_scalarDeclaration inherited source.toRawHelperEquations text tv state arguments native
    · rw [links.booleanDeclaration]
      exact source.booleanDeclaration text tv state arguments native
  beginToken text tv state valid :=
    (header_lexical source.toRawHelperEquations links).take text tv _ _ _ valid.2.base.1 (native_token_valid .beginKeyword)

theorem scalar_append_meaning {domain calls inherited metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (links : HeaderLinks calls inherited metadata visibility) : ScalarAppendMeaning calls where
  append names item space := by
    rw [links.scalarAppend]
    exact source.scalarAppend names item space

end Silver.Compose.FunctionDeclarationNative
