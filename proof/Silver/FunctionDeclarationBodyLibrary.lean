module

public import Silver.FunctionDeclarationLibraries
public import Silver.FunctionDeclarationBodyDomains
public import Silver.PredicateAdapterEnvironment
public import Silver.ProcedureMetadataValidity

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 2000000

attribute [local irreducible] Predicate.bodyOf functionReturnAfter
  functionLocals parameterFrame fixedAfter skipAt Compose.nameAfter

/-- Checked Context_Of expression and the exact runtime Body_Of/Body_Tail
callee identities. The wrapper models retain their own static refinements. -/
structure BodyLinks (calls : Calls) (reader : Predicate.BodyNative.Calls)
    (wrappers : Predicate.Adapter.Wrappers.Calls) : Prop where
  context : ∀ scan, StateRecord scan.state →
    calls .contextOf scan = Predicate.Adapter.contextExpr.eval reader {scan}
  bodyOf : calls .bodyOf = wrappers.bodyOf
  tail : calls .bodyTail = reader.tail

theorem model_tail_input (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (context : Predicate.Native.Context) (cv : Predicate.Native.ValidContext text context)
    (scan : Predicate.BodyScan) (sv : BodyScanInput text context scan)
    (catalog : FunctionBindings.Metadata) (fv : FunctionBindings.ValidMetadata text catalog) :
    BodyScanInput text context (Predicate.bodyTail text context.model scan .returnOnly catalog {}) :=
  ⟨Predicate.bodyTail_bound (procedures := {}) text context.model scan .returnOnly tv cv.1 sv.1,
    Predicate.bodyTail_controls (procedures := {}) text context.model scan .returnOnly sv.2.1,
    Predicate.bodyTail_factsBounded (procedures := {}) text context.model scan .returnOnly sv.2.2.1,
    Predicate.bodyTail_flowReady text context.model scan .returnOnly fv (ProcedureBindings.valid_empty text) cv.base sv.2.2.2 cv.2.2.1⟩

theorem body_parts_library_imports {domain calls inherited metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (links : HeaderLinks calls inherited metadata visibility)
    (reader : Predicate.BodyNative.Calls) (readerSource : Predicate.BodyNative.Equations reader)
    (models wrappers : Predicate.Adapter.Wrappers.Calls)
    (modelEquations : Predicate.Adapter.Wrappers.ModelEquations models reader)
    (refinement : Predicate.Adapter.Wrappers.Refinement models wrappers)
    (bodyLinks : BodyLinks calls reader wrappers)
    (equations : OrdinaryEquations calls) (contracts : TraversalContracts calls)
    (returns : ∀ text, FunctionBindings.Native.ValidText text → ∀ context scan resultType,
      ReturnInput text context scan resultType → ReturnImports calls text context scan resultType)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (frame locals bound : ParserState)
    (resultType : FunctionTypeResult) (boundValid : StateInput text bound)
    (count : locals.scalarNames.length ≤ bound.scalarNames.length)
    (metadataValid : FunctionBindings.ValidMetadata text frame.functions) (resultTyped : TypeResultRecord resultType) :
    BodyPartsImports calls text frame locals bound resultType := by
  have lexical := header_lexical source links
  let start := {bound with position := fixedAfter text bound.position "begin" true}
  have startValid : StateInput text start := StateInput.withPosition tv boundValid _
    (fixedAfter_result_bound text _ "begin" true (by decide))
  let context := bodyContext start locals.scalarNames.length
  have contextValid : Predicate.Native.ValidContext text context := body_context_valid text start _ startValid.2 count
  have initialValid := body_initial_valid text start locals.scalarNames.length startValid.2
  have scanValid := model_tail_input text tv context contextValid (Predicate.bodyOf ⟨start, false, false⟩) initialValid frame.functions metadataValid
  let scan := Predicate.bodyTail text context.model (Predicate.bodyOf ⟨start, false, false⟩) .returnOnly frame.functions {}
  have returnValid : ReturnInput text context scan resultType := ⟨contextValid, scanValid, resultTyped⟩
  have returnMeaning := interpreted_returnAfter calls equations text tv context scan resultType returnValid
    (returns text tv context scan resultType returnValid)
  have returnRange := contracts.returnAfter text tv context scan resultType returnValid
  rw [returnMeaning] at returnRange
  have returnBound : functionReturnAfter text context.model scan resultType ≤ text.length + 1 := by
    rcases returnRange with zero | advanced
    · rw [zero]; exact Nat.zero_le _
    · exact advanced.2
  have semicolonBound := fixedAfter_result_bound text (functionReturnAfter text context.model scan resultType) ";" false (by decide)
  let endPosition := fixedAfter text (fixedAfter text (functionReturnAfter text context.model scan resultType) ";" false) "end" true
  have endBound : endPosition ≤ text.length + 1 := fixedAfter_result_bound text _ "end" true (by decide)
  have firstBound := Expressions.model_skip_valid text endPosition endBound
  have afterBound := function_nameAfter_bound text (skipAt text endPosition)
  refine ⟨lexical.take text tv _ _ _ boundValid.2.base.1 (native_token_valid .beginKeyword), ?_, ?_, ?_, returnMeaning,
    lexical.take text tv _ _ _ returnBound (native_token_valid .semicolon), lexical.take text tv _ _ _ semicolonBound (native_token_valid .endKeyword),
    lexical.skip text tv _ endBound, lexical.nameAfter text tv _ firstBound,
    lexical.take text tv _ _ _ afterBound (native_token_valid .semicolon)⟩
  all_goals dsimp only
  · change calls .contextOf ⟨start, false, false⟩ = nativeContextOf ⟨start, false, false⟩
    rw [bodyLinks.context ⟨start, false, false⟩ startValid.1, Predicate.Adapter.context_eval]
    rfl
  · rw [bodyLinks.bodyOf]
    exact Predicate.Adapter.Wrappers.bodyOf_interpreted modelEquations refinement _ startValid.1.scalars.1
  · rw [bodyLinks.tail]
    exact Predicate.BodyNative.tail_executable_unique reader readerSource text tv context contextValid _ .returnOnly initialValid metadataValid
      (ProcedureBindings.valid_empty text)

theorem body_library_imports {domain calls inherited metadata visibility}
    (source : InheritedEquations inherited domain)
    (exactDomain : ExactDomain domain) (functions : FunctionBindings.SourceBridge.ImplementationCorrect metadata)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilityEquations : FunctionVisibilityNative.Equations visibility)
    (links : OrdinaryLinks calls inherited metadata visibility)
    (headers : HeaderEquations calls) (headerContracts : HeaderContracts calls) (frames : FrameEquations calls)
    (arrayImports : ArrayParameterImports calls)
    (equations : OrdinaryEquations calls) (contracts : TraversalContracts calls)
    (reader : Predicate.BodyNative.Calls) (readerSource : Predicate.BodyNative.Equations reader)
    (models wrappers : Predicate.Adapter.Wrappers.Calls)
    (modelEquations : Predicate.Adapter.Wrappers.ModelEquations models reader)
    (refinement : Predicate.Adapter.Wrappers.Refinement models wrappers)
    (bodyLinks : BodyLinks calls reader wrappers)
    (returns : ∀ text, FunctionBindings.Native.ValidText text → ∀ context scan resultType,
      ReturnInput text context scan resultType → ReturnImports calls text context scan resultType)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) (valid : BodyInput text outer frame first after resultType) :
    BodyImports calls text outer frame first after resultType arguments := by
  have imports := header_imports source exactDomain functions visibilityPrimitives visibilityEquations links.toHeaderLinks headers
  have scalar := scalar_append_meaning source.toRawHelperEquations links.toHeaderLinks
  have localsMeaning := interpreted_functionLocals calls headers imports headerContracts text tv frame arguments valid.frame
  have localsInfo := contracts.locals text tv frame arguments valid.frame
  rw [localsMeaning] at localsInfo
  let locals := functionLocals text frame arguments
  have localsValid : StateInput text locals := localsInfo.1
  have positive (accepted : locals.position ≠ 0) : 0 < locals.firstParameter := by
    rw [(localsInfo.2.resolve_left accepted).2.2.1]
    exact valid.firstParameter
  have frameMeaning (accepted : locals.position ≠ 0) :
      calls .parameterFrame text locals = parameterFrame text locals :=
    interpreted_parameterFrame calls frames scalar arrayImports text tv locals localsValid.1 localsValid.2 (positive accepted)
  have frameInfo (accepted : locals.position ≠ 0) := contracts.parameterFrame text tv locals localsValid (positive accepted)
  refine ⟨localsMeaning, frameMeaning, ?_, ?_⟩
  all_goals dsimp only
  · intro localGood boundGood
    have info := frameInfo localGood
    rw [frameMeaning localGood] at info
    have count := (info.2.resolve_left boundGood).2.2.1
    exact body_parts_library_imports source.toRawHelperEquations links.toHeaderLinks reader readerSource
      models wrappers modelEquations refinement bodyLinks equations contracts returns text tv frame locals _ resultType
      info.1 count valid.frame.2.base.2.2.2.2.2.2.2.2.2.1 valid.resultType
  · intro _ _
    exact body_finish_library_imports source.toRawHelperEquations functions visibilityPrimitives visibilityEquations
      links text tv outer frame first after resultType _ valid (function_nameAfter_bound text _)

end Silver.Compose.FunctionDeclarationNative
