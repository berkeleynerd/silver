module

public import Silver.ProcedureDeclarationHelperLibraries
public import Silver.ProcedureDeclarationHighEquations
public import Silver.FunctionDeclarationMeaning

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 7000
set_option maxHeartbeats 3000000

/-- Direct native callee identities supplement the shared parameter/prefix
links. Each callee's meaning is derived from its own source and contract. -/
structure BodyLinks (calls : Calls) (source : InterpretedHelpers calls) : Prop where
  locals : calls .functionLocals = source.ordinary .functionLocals
  bodyOf : calls .bodyOf = source.ordinarySource.bodyLibraries.bodyWrappers.bodyOf
  tail : calls .bodyTail = source.ordinarySource.bodyLibraries.body.tail
  read : calls .readBody = source.ordinarySource.bodyLibraries.body.read
  append : calls .appendProcedure = source.metadata.append
  nameIs : calls .nameIs = source.ordinarySource.inherited.function .nameIs

/-- Assignment/output bits do not change the native scan input predicates.
The frame and every stored flow component retain the complete domain. -/
theorem body_initial_valid_flags (text : Source) (state : ParserState) (declarations : Nat)
    (valid : FunctionDeclarationNative.NativeValidState text state) (assigned output : Bool) :
    FunctionDeclarationNative.BodyScanInput text
      (FunctionDeclarationNative.bodyContext state declarations)
      (Predicate.bodyOf ⟨state, assigned, output⟩) := by
  exact FunctionDeclarationNative.body_initial_valid text state declarations valid

theorem body_parts_library_imports {calls : Calls} (source : InterpretedHelpers calls)
    (links : BodyLinks calls source) (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (frame locals start ready : ParserState)
    (readyValid : StateInput text ready) (count : locals.scalarNames.length ≤ ready.scalarNames.length)
    (functions : FunctionBindings.ValidMetadata text frame.functions)
    (procedures : ProcedureBindings.ValidMetadata text frame.procedures) :
    BodyPartsImports calls text frame locals start ready := by
  let parts := bodyParts modelCalls text frame locals start ready
  have contextValid : Predicate.Native.ValidContext text parts.context :=
    FunctionDeclarationNative.body_context_valid text ready _ readyValid.2 count
  have scanValid : FunctionDeclarationNative.BodyScanInput text parts.context parts.scan :=
    body_initial_valid_flags text ready _ readyValid.2 parts.initialized false
  have equations := FunctionDeclarationNative.source_reader_equations source.ordinarySource
  have tailMeaning := Predicate.BodyNative.tail_executable_unique
    source.ordinarySource.bodyLibraries.body equations text tv parts.context contextValid
    parts.scan .endOnly scanValid functions procedures
  have readMeaning := Predicate.BodyNative.read_unique
    source.ordinarySource.bodyLibraries.body equations text tv parts.context contextValid
    parts.scan .endOnly scanValid functions procedures
  have resultBound : parts.result.position ≤ text.length + 1 := by
    dsimp only [parts, bodyParts, modelCalls]
    split
    · exact Predicate.bodyTail_bound text _ _ .endOnly tv contextValid.1 scanValid.1
    · exact Predicate.readBody_bound text _ _ .endOnly tv contextValid.1 scanValid.1
  have endBound : fixedAfter text parts.result.position "end" true ≤ text.length + 1 :=
    fixedAfter_result_bound text _ "end" true (by decide)
  have firstBound : parts.endFirst ≤ text.length + 1 :=
    Expressions.model_skip_valid text _ endBound
  have afterBound : parts.endAfter ≤ text.length + 1 := function_nameAfter_bound text _
  have lexical := header_lexical source.ordinarySource.inheritedSource.toRawHelperEquations source.links
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [source.prefixLinks.context ⟨ready, false, false⟩ readyValid.1,
      Predicate.Adapter.context_eval]
    rfl
  · rw [links.bodyOf]
    exact Predicate.Adapter.Wrappers.bodyOf_interpreted
      (FunctionDeclarationNative.source_wrapper_models source.ordinarySource)
      source.ordinarySource.bodyDefinitions.wrappers _ readyValid.1.scalars.1
  · intro initialized
    rw [links.tail]
    simpa only [parts, bodyParts, modelCalls, initialized, ↓reduceIte] using tailMeaning
  · intro initialized
    rw [links.read]
    simpa only [parts, bodyParts, modelCalls, initialized, Bool.false_eq_true, ↓reduceIte] using readMeaning
  · exact lexical.take text tv _ _ _ resultBound (native_token_valid .endKeyword)
  · exact lexical.skip text tv _ endBound
  · exact lexical.nameAfter text tv _ firstBound
  · exact lexical.take text tv _ _ _ afterBound (native_token_valid .semicolon)

theorem body_finish_library_imports {calls : Calls} (source : InterpretedHelpers calls)
    (links : BodyLinks calls source) (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (outer frame : ParserState) (first after : Nat) (parts : BodyParts)
    (valid : BodyDomain text outer frame first after)
    (endBound : parts.endAfter ≤ text.length + 1) :
    BodyFinishImports calls text outer frame first after parts := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro accepted
    simp only [bodyPrefix, Bool.or_eq_false_iff, decide_eq_false_iff_not] at accepted
    rw [source.links.equal]
    exact source.ordinarySource.visibilityPrimitives.equalName text tv first after
      parts.endFirst parts.endAfter valid.name ⟨by omega, by omega, endBound⟩
  · intro _
    have size := tv.2
    have nameBound := valid.name.2.2
    have nameOrder := valid.name.2.1
    have firstParameter := valid.frameValid.1.firstProcedureParameter
    have parameterCount := valid.frameValid.1.procedures.2.1
    have positive := valid.firstParameter
    rw [links.append]
    exact (ProcedureBindings.SourceBridge.interpreted_complete source.metadata source.metadataSource).append
      frame.procedures valid.frameValid.1.procedures _
      ⟨by dsimp only; omega, by dsimp only; omega, firstParameter, by dsimp only; omega⟩ valid.capacity
  · intro _
    rw [source.links.hideName]
    exact FunctionVisibilityNative.hideName_meaning source.ordinarySource.visibility
      source.ordinarySource.visibilityPrimitives source.ordinarySource.visibilityEquations text tv _ _ _ valid.name
  · intro _ operation
    rw [links.nameIs]
    exact source.ordinarySource.inheritedSource.toRawHelperEquations.nameIs text tv
      first after operation.name valid.name (by cases operation <;> decide) (by cases operation <;> decide)

theorem body_library_imports {calls : Calls} (source : InterpretedHelpers calls)
    (links : BodyLinks calls source) (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (outer frame : ParserState) (first after : Nat) (arguments : Bool)
    (valid : BodyDomain text outer frame first after) :
    BodyImports calls text outer frame first after arguments := by
  have ordinaryLocals := FunctionDeclarationNative.interpreted_functionLocals source.ordinary
    source.ordinarySource.headers (source_header_imports source) source.ordinarySource.headerContracts
    text tv frame arguments valid.frameValid
  have localsMeaning : calls .functionLocals text frame arguments = functionLocals text frame arguments :=
    (congrFun (congrFun (congrFun links.locals text) frame) arguments).trans ordinaryLocals
  have localsInfo := source.ordinarySource.contracts.locals text tv frame arguments valid.frameValid
  rw [ordinaryLocals] at localsInfo
  let locals := functionLocals text frame arguments
  have localsValid : StateInput text locals := localsInfo.1
  have firstPositive (accepted : locals.position ≠ 0) : 0 < locals.firstProcedureParameter := by
    obtain ⟨_, _, _, _, parsed⟩ := functionLocals_reading tv valid.frameValid.2.base accepted
    rw [parsed.preserves.firstProcedureParameter]
    exact valid.firstParameter
  have frameDomain (accepted : locals.position ≠ 0) : InputFrameDomain text locals :=
    ⟨tv, localsValid, firstPositive accepted⟩
  have frameMeaning (accepted : locals.position ≠ 0) := source_inputFrame source text locals (frameDomain accepted)
  have frameInfo (accepted : locals.position ≠ 0) :
      StateInput text (procedureInputFrame text locals) ∧
      ((procedureInputFrame text locals).position = 0 ∨ InputFramePost locals (procedureInputFrame text locals)) := by
    have info := source.traversal.inputFrame text locals (frameDomain accepted)
    rw [frameMeaning accepted] at info
    exact info
  let bound := procedureInputFrame text locals
  let start := bodyStart text bound
  have startValid (accepted : locals.position ≠ 0) : StateInput text start :=
    FunctionDeclarationNative.StateInput.withPosition tv (frameInfo accepted).1 _
      (fixedAfter_result_bound text _ "begin" true (by decide))
  have prefixDomain (localGood : locals.position ≠ 0) (boundGood : bound.position ≠ 0) :
      PrefixDomain text start locals.scalarNames.length := by
    have fields := (frameInfo localGood).2.resolve_left boundGood
    exact ⟨⟨tv, startValid localGood, by
      change 0 < bound.firstProcedureParameter
      rw [fields.firstParameter]
      exact firstPositive localGood⟩, fields.scalars⟩
  have prefixMeaning (localGood : locals.position ≠ 0) (boundGood : bound.position ≠ 0) :=
    source_prefix source text start locals.scalarNames.length (prefixDomain localGood boundGood)
  refine ⟨localsMeaning, frameMeaning, ?_, prefixMeaning, ?_, ?_⟩
  · intro localGood _
    exact (header_lexical source.ordinarySource.inheritedSource.toRawHelperEquations source.links).take
      text tv _ _ _ (frameInfo localGood).1.2.base.1 (native_token_valid .beginKeyword)
  · intro localGood boundGood readyGood
    have info := source.traversal.prefix text start locals.scalarNames.length (prefixDomain localGood boundGood)
    rw [prefixMeaning localGood boundGood] at info
    have grows := (info.2.resolve_left readyGood).scalars
    exact body_parts_library_imports source links text tv frame locals start _ info.1
      (Nat.le_trans (prefixDomain localGood boundGood).2 grows)
      valid.frameValid.2.base.functions valid.frameValid.2.base.procedures
  · intro _ _ _
    exact body_finish_library_imports source links text tv outer frame first after _ valid
      (function_nameAfter_bound text _)

end Silver.Compose.ProcedureDeclarationNative
