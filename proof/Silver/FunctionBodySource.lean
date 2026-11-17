module

public import Silver.FunctionBodyMeaning

@[expose] public section

namespace Silver.Compose
open Predicate ScalarFunctions Bindings Silver.Compose.Expressions

def functionSourceEntry (frame : ParserState) (first after : Nat) (result : FunctionTypeResult) :
    FunctionBindings.Signature :=
  ⟨first, after, frame.firstParameter, frame.functions.parameters.length - frame.firstParameter + 1,
    result.kind, result.bounds⟩

def functionSourceStart (text : Source) (frame : ParserState) (arguments : Bool) : ParserState :=
  let bound := parameterFrame text (functionLocals text frame arguments)
  {bound with position := fixedAfter text bound.position "begin" true}

def functionSourceContext (text : Source) (frame : ParserState) (arguments : Bool) : ParseContext :=
  {contextOf ⟨functionSourceStart text frame arguments, false, false⟩ with
    declarationCount := (functionLocals text frame arguments).scalarNames.length}

def functionSourceScan (text : Source) (frame : ParserState) (arguments : Bool) : BodyScan :=
  bodyOf ⟨functionSourceStart text frame arguments, false, false⟩

def functionSourceFinal (text : Source) (frame : ParserState) (arguments : Bool) : BodyScan :=
  bodyTail text (functionSourceContext text frame arguments) (functionSourceScan text frame arguments)
    .returnOnly frame.functions

/-- Exact source-order locals, installed formal suffix, scalar body and typed
terminal return retained from one function's source frame. -/
inductive FunctionBodySource (text : Source) (frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) : Definition → Prop
  | parsed {integers booleans checks booleanChecks items returned} :
      FunctionLocalsAt text arguments frame integers booleans checks booleanChecks
        (functionLocals text frame arguments) →
      (parameterFrame text (functionLocals text frame arguments)).position ≠ 0 →
      ParameterFramesAt (functionLocals text frame arguments)
        (functionLocals text frame arguments).firstParameter
        (parameterFrame text (functionLocals text frame arguments)) →
      BodyTailAt (catalog := frame.functions) (procedures := {}) text (functionSourceContext text frame arguments) .returnOnly
        (functionSourceScan text frame arguments) items (functionSourceFinal text frame arguments) →
      ActualAt text (functionSourceContext text frame arguments)
        (fixedAfter text (functionSourceFinal text frame arguments).position "return" true)
        (functionSourceFinal text frame arguments).facts ⟨0, 0, resultType.kind, resultType.bounds⟩
        returned (functionReturnAfter text (functionSourceContext text frame arguments)
          (functionSourceFinal text frame arguments) resultType) →
      FunctionBodySource text frame first after resultType arguments
        (sourceFunctionDefinition (signatureModel frame.functions (functionSourceEntry frame first after resultType))
          integers booleans checks booleanChecks items returned)

theorem FunctionBodySource.signature {text frame first after resultType arguments definition}
    (source : FunctionBodySource text frame first after resultType arguments definition) :
    definition.signature = signatureModel frame.functions (functionSourceEntry frame first after resultType) := by
  cases source
  rfl

theorem FunctionBodySource.checked {text frame first after resultType arguments definition}
    (source : FunctionBodySource text frame first after resultType arguments definition)
    (valid : ValidState text frame) (closed : ClosedFunctionState frame)
    (emptyIntegers : frame.scalarNames = []) (emptyBooleans : frame.booleanNames = [])
    (positive : 0 < frame.firstParameter)
    (signatureValid : FunctionBindings.ValidSignature text frame.functions (functionSourceEntry frame first after resultType)) :
    definition.Checked (catalogSignatures frame.functions) := by
  cases source with
  | @parsed integers booleans checks booleanChecks items returned locals accepted parameters body result =>
    let localFrame := functionLocals text frame arguments
    let bound := parameterFrame text localFrame
    let context := functionSourceContext text frame arguments
    let scan := functionSourceScan text frame arguments
    have localValid : ValidState text localFrame := locals.valid valid
    have localClosed : ClosedFunctionState localFrame := locals.closed closed
    have localReady : ScalarMetadata.HeaderReady localFrame.scalarNames := locals.headerReady (by
      rw [emptyIntegers]; exact ScalarMetadata.headerReady_empty)
    have firstPositive : 0 < localFrame.firstParameter := by rw [locals.preserves.firstParameter]; exact positive
    have boundValid : ValidState text bound := parameterFrameModel_valid localFrame.firstParameter localValid firstPositive
    have boundFields : ParameterFrameFieldsPreserved localFrame bound := parameters.fields
    have boundClosed : ClosedFunctionState bound := by
      rw [boundFields]
      exact ⟨localClosed.pure, localClosed.noArguments, localClosed.noNames, localClosed.noArrays⟩
    have contextClosed : ClosedFunctionContext context := by
      refine ⟨boundClosed.pure, ?_, boundClosed.noNames, boundClosed.noArrays⟩
      change decide (bound.dynamicFirst ≠ 0) = false
      simp only [boundClosed.noArguments, ne_eq, not_true_eq_false, decide_false]
    have contextReady : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating :=
      parameterFrame_contextReady localValid localReady firstPositive accepted
    have flowReady : scan.FlowReady context :=
      parameterFrame_flowReady localValid localReady firstPositive _
    have environment : ScalarExpression.ValidEnvironment text context.scalarNames :=
      ScalarExpression.bodyEnvironment_valid boundValid.2.2.2.2.2.1
    have count : context.booleanNames.length ≤ BooleanBindings.maxBindings := boundValid.booleans.1
    have path : scan.facts.path = entryContext := by
      change initialFacts (decide (bound.dynamicFirst ≠ 0)) = entryContext
      simp only [boundClosed.noArguments, ne_eq, not_true_eq_false, decide_false, initialFacts, Bool.false_eq_true, ↓reduceIte]
      rfl
    have bounded : scan.facts.path.Bounded := by
      rw [path]
      simp [entryContext, PathFacts.Context.Bounded, PathFacts.Region.Bounded]
    have scalarCount : localFrame.scalarNames.length = integers.length := by
      simpa only [emptyIntegers, List.length_nil, Nat.zero_add] using locals.scalar_length
    have booleanCount : localFrame.booleanNames.length = booleans.length := by
      simpa only [emptyBooleans, List.length_nil, Nat.zero_add] using locals.boolean_length
    have analyses := parameters.analyses localFrame.scalarNames.length (Nat.le_refl _)
    have formalCount : localFrame.functions.parameters.length + 1 - localFrame.firstParameter =
        frame.functions.parameters.length - frame.firstParameter + 1 := by
      rw [locals.preserves.functions, locals.preserves.firstParameter]
      have firstBound : frame.firstParameter ≤ frame.functions.parameters.length := signatureValid.2.2.2.1
      omega
    rw [formalCount, locals.preserves.functions, locals.preserves.firstParameter,
      locals.local_analysis valid emptyIntegers, locals.local_boolean_analysis valid emptyBooleans closed.noArrays,
      scalarCount, booleanCount] at analyses
    have analysis : context.analysis = parameterAnalysis integers.length
        (signatureModel frame.functions (functionSourceEntry frame first after resultType)).formals
        (Integer.Analysis.ofDeclarations integers) := by
      change ArrayFlow.analysis bound.arrayNames.names (functionScalarAnalysis bound localFrame.scalarNames.length) = _
      rw [boundClosed.noArrays, scalarCount]
      exact analyses.1
    have booleanAnalysis : BooleanBindings.analysis context.booleanNames = parameterBooleans booleans.length
        (signatureModel frame.functions (functionSourceEntry frame first after resultType)).formals
        (booleanBodyAnalysis booleans) := analyses.2
    have entry : context.flow scan.facts = ⟨entryContext, context.analysis.declared⟩ := by
      have emptyArrays : context.arrayNames = [] := contextClosed.noArrays
      simp only [ParseContext.flow, ParseContext.analysis, emptyArrays, ArrayBindings.integerRanges,
        ArrayBindings.integerNames, List.filter_nil, ArrayBindings.ranges_nil, ArrayFlow.analysis,
        ArrayFlow.ranges, ScalarMetadata.analysis]
      change (⟨scan.facts.path, scan.facts.model.scalars⟩ : Flow) = _
      rw [path]
      change (⟨entryContext, (ActiveFlow.initial context.scalarNames _).model.scalars⟩ : Flow) = _
      rw [ActiveFlow.initial_model]
    exact sourceFunctionDefinition_checked (locals.initializers_checked valid closed emptyIntegers emptyBooleans)
      (signatureModel_valid valid.functions signatureValid) contextClosed valid.functions rfl contextReady flowReady environment count bounded analysis
      booleanAnalysis entry rfl body result


theorem functionBodyAt_stages {text outer frame first after resultType arguments}
    (accepted : (functionBodyAt text outer frame first after resultType arguments).position ≠ 0) :
    (functionLocals text frame arguments).position ≠ 0 ∧
    (parameterFrame text (functionLocals text frame arguments)).position ≠ 0 ∧
    (functionSourceFinal text frame arguments).position ≠ 0 ∧
    functionReturnAfter text (functionSourceContext text frame arguments)
      (functionSourceFinal text frame arguments) resultType ≠ 0 ∧
    (functionBodyAt text outer frame first after resultType arguments).functions =
      FunctionBindings.append frame.functions (functionSourceEntry frame first after resultType) := by
  dsimp only [functionBodyAt] at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i localsAccepted
    split at accepted
    · exact False.elim (accepted rfl)
    · rename_i parametersAccepted
      split at accepted
      · exact False.elim (accepted rfl)
      · rename_i checked
        refine ⟨localsAccepted, parametersAccepted, ?_, ?_, ?_⟩
        · exact fun zero => checked (Or.inl zero)
        · exact fun zero => checked (Or.inr (Or.inl zero))
        · rw [ite_eq_right localsAccepted, ite_eq_right parametersAccepted, ite_eq_right checked]
          rfl

theorem functionBodyAt_source {text outer frame first after resultType arguments}
    (textValid : ValidText text) (valid : ValidState text frame) (positive : 0 < frame.firstParameter)
    (accepted : (functionBodyAt text outer frame first after resultType arguments).position ≠ 0) :
    ∃ definition, FunctionBodySource text frame first after resultType arguments definition := by
  have stages := functionBodyAt_stages accepted
  obtain ⟨integers, booleans, checks, booleanChecks, locals⟩ :=
    functionLocals_reading textValid valid stages.1
  have parameters := parameterFrames_reading stages.2.1
  have localValid := locals.valid valid
  have firstPositive : 0 < (functionLocals text frame arguments).firstParameter := by
    rw [locals.preserves.firstParameter]
    exact positive
  have boundValid := parameterFrameModel_valid
    (functionLocals text frame arguments).firstParameter localValid firstPositive
  have namesValid : ValidNames text (functionSourceContext text frame arguments).names := boundValid.2.1
  obtain ⟨items, body⟩ := bodyTail_sound (catalog := frame.functions) (procedures := {}) text (functionSourceContext text frame arguments)
    (functionSourceScan text frame arguments) .returnOnly textValid namesValid
    (fixedAfter_result_bound text _ "begin" true (by decide)) stages.2.2.1
  obtain ⟨returned, result⟩ := actual_sound textValid namesValid
    (fixedAfter_result_bound text _ "return" true (by decide)) stages.2.2.2.1
  exact ⟨_, .parsed locals stages.2.1 parameters body result⟩

end Silver.Compose
