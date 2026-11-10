module

public import Silver.FunctionLocalAnalysis
public import Silver.PredicateBodyMeaning
public import Silver.PredicateBodySound
public import Silver.PredicateBodyFlowPreservation

@[expose] public section

namespace Silver.Compose
open Predicate ScalarFunctions Bindings Silver.Compose.Expressions

def sourceFunctionDefinition (signature : Signature) (integers : List Integer.Declaration)
    (booleans : List BooleanDeclaration) (checks : List Integer.Obligation)
    (booleanChecks : List Predicate.Obligation) (items : List SourceStatement) (result : Actual) : Definition :=
  ⟨signature, integers, booleans, checks, booleanChecks, lowerStatements items, result⟩

/-- Source body and return readings establish every semantic body condition.
The analysis equations connect the installed frame to its local/formal lists;
no semantic safety or checked-definition premise is assumed. -/
theorem sourceFunctionDefinition_checked
    {text context catalog scan items resultScan returnPosition formal returned returnAfter}
    {signature : Signature} {integers booleans checks booleanChecks}
    (initialized : FunctionInitializersChecked integers booleans checks booleanChecks)
    (signatureValid : signature.Valid)
    (closed : ClosedFunctionContext context)
    (metadata : FunctionBindings.ValidMetadata text catalog)
    (bodyMode : context.elaborating = false)
    (ready : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (initial : scan.FlowReady context)
    (environment : ScalarExpression.ValidEnvironment text context.scalarNames)
    (booleanCount : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (bounded : scan.facts.path.Bounded)
    (analysis : context.analysis = parameterAnalysis integers.length signature.formals
      (Integer.Analysis.ofDeclarations integers))
    (booleanAnalysis : BooleanBindings.analysis context.booleanNames =
      parameterBooleans booleans.length signature.formals (booleanBodyAnalysis booleans))
    (entry : context.flow scan.facts = ⟨entryContext, context.analysis.declared⟩)
    (resultType : formalType formal = signature.result)
    (body : BodyTailAt (catalog := catalog) (procedures := {}) text context .returnOnly scan items resultScan)
    (result : ActualAt text context returnPosition resultScan.facts formal returned returnAfter) :
    (sourceFunctionDefinition signature integers booleans checks booleanChecks items returned).Checked
      (catalogSignatures catalog) := by
  let definition := sourceFunctionDefinition signature integers booleans checks booleanChecks items returned
  have normal : NamesNormal context.names := by
    rw [closed.noNames]
    constructor <;> simp [NamesWellTyped, BindingEnvironment.get]
  have namesValid : ValidNames text context.names := by
    rw [closed.noNames]
    simp [ValidNames]
  have arraysReady : context.ArraysReady text := by
    simp [ParseContext.ArraysReady, closed.noArrays, ArrayBindings.ValidMetadata]
  have base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount :=
    (bodyMode ▸ ready).toBaseReady
  have meaning := bodyTail_meaning metadata bodyMode normal base arraysReady booleanCount
    namesValid initial.compatible bounded body
  have finalReady := bodyTail_flowReady text context scan .returnOnly metadata (ProcedureBindings.valid_empty text) ready initial environment
  rw [bodyTail_complete body] at finalReady
  have returnedMeaning := actual_meaning normal namesValid ready arraysReady finalReady.compatible meaning.2.2 result
  have bodyShape := bodyTail_source_scalar closed body
  have returnShape := actual_source_scalar closed result
  have shape : context.names.shape = emptyShape := by rw [closed.noNames, empty_names_shape]
  have scalarAnalysis : context.analysis = definition.analysis := analysis
  have boolAnalysis : ArrayBindings.booleanAnalysis context.arrayNames
      (BooleanBindings.analysis context.booleanNames) = definition.booleanAnalysis := by
    rw [closed.noArrays]
    exact booleanAnalysis
  have entryFlow : context.flow scan.facts = definition.initialFlow := by
    rw [entry, scalarAnalysis]
    rfl
  have formed : definition.WellFormed := by
    refine ⟨signatureValid, initialized.booleanDeclarations, ?_, ?_, ?_⟩
    · have translated := lowerStatements_wellFormed meaning.1
      simpa only [closed.noArguments, shape, boolAnalysis, definition, sourceFunctionDefinition] using translated
    · simpa only [closed.noArguments, shape, boolAnalysis, definition, sourceFunctionDefinition] using returnedMeaning.1
    · change (integers.all (fun item => scalarExpression item.value) &&
        booleans.all (fun item => ScalarFunctions.scalarCondition item.value) &&
        scalarStatements (lowerStatements items) && scalarActual returned) = true
      rw [initialized.scalarIntegers, initialized.scalarBooleans, bodyShape.2, returnShape]
      rfl
  refine ⟨formed, context.flow resultScan.facts, (definition.check_iff _ _).mpr ?_⟩
  refine ⟨initialized.integerDeclarations, initialized.integerChecks, initialized.booleanChecks,
    initialized.booleanCheck, bodyShape.1, ?_, ?_⟩
  · simpa only [shape, scalarAnalysis, entryFlow, boolAnalysis, definition, sourceFunctionDefinition] using meaning.2.1
  · simpa only [shape, scalarAnalysis, boolAnalysis, resultType, definition, sourceFunctionDefinition] using returnedMeaning.2

end Silver.Compose
