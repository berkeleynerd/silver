module

public import Silver.ProcedureDeclarationPrefixLibraries
public import Silver.ProcedureDeclarationTraversalContracts
public import Silver.FunctionDeclarationSourceBridge

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

/-- The low procedure helpers reuse the already interpreted ordinary function
libraries. Every new procedure helper meaning is derived from its individual
source equation and callee identities below. -/
structure InterpretedHelpers (calls : Calls) where
  ordinary : FunctionDeclarationNative.Calls
  ordinarySource : FunctionDeclarationNative.InterpretedSource ordinary
  metadata : ProcedureBindings.Native.Calls
  metadataSource : ProcedureBindings.SourceBridge.InterpretedSource metadata
  links : ParameterLinks calls ordinarySource.inherited ordinary metadata ordinarySource.visibility
  equations : HelperEquations calls
  contracts : HelperContracts calls
  traversal : HelperTraversalContracts calls
  prefixLinks : PrefixLinks calls ordinarySource.bodyLibraries.body
    ordinarySource.bodyLibraries.initial ordinarySource.actualCalls

theorem source_header_imports {calls : Calls} (source : InterpretedHelpers calls) :
    FunctionDeclarationNative.HeaderImports source.ordinary :=
  FunctionDeclarationNative.header_imports source.ordinarySource.inheritedSource
    source.ordinarySource.exactDomain
    (FunctionBindings.SourceBridge.interpreted_complete source.ordinarySource.metadata
      source.ordinarySource.metadataSource)
    source.ordinarySource.visibilityPrimitives source.ordinarySource.visibilityEquations
    source.ordinarySource.links.toHeaderLinks source.ordinarySource.headers

theorem source_parameter_imports {calls : Calls} (source : InterpretedHelpers calls) :
    ParameterImports calls :=
  parameter_imports source.ordinarySource.inheritedSource.toRawHelperEquations
    source.ordinarySource.exactDomain source.ordinarySource.headers (source_header_imports source)
    (ProcedureBindings.SourceBridge.interpreted_complete source.metadata source.metadataSource)
    source.ordinarySource.visibilityPrimitives source.ordinarySource.visibilityEquations source.links

theorem source_scalar_append {calls : Calls} (source : InterpretedHelpers calls) :
    ScalarAppendMeaning calls :=
  scalar_append_meaning source.ordinarySource.inheritedSource.toRawHelperEquations source.links

theorem source_prefix_imports {calls : Calls} (source : InterpretedHelpers calls) :
    PrefixMeaning calls :=
  prefix_imports source.ordinarySource.inheritedSource.toRawHelperEquations source.links
    source.ordinarySource.visibilityPrimitives source.equations source.ordinarySource.bodyLibraries.body
    source.ordinarySource.bodyLibraries.flowLibraries source.ordinarySource.bodyDefinitions.flowLibraries
    source.ordinarySource.bodyLibraries.initial source.ordinarySource.bodyDefinitions.initial
    source.ordinarySource.actualImports source.ordinarySource.actualCalls source.ordinarySource.assignment
    (FunctionDeclarationNative.source_actual_meaning source.ordinarySource)
    source.ordinarySource.actualEquations source.prefixLinks

theorem source_parameters {calls : Calls} (source : InterpretedHelpers calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState)
    (arguments : Bool) (valid : StateInput text state) :
    calls .procedureParameters text state arguments = procedureParametersAt text state arguments :=
  interpreted_parameters calls source.equations (source_parameter_imports source) source.contracts
    text tv state arguments valid

theorem source_inputFrame {calls : Calls} (source : InterpretedHelpers calls)
    (text : Source) (frame : ParserState) (valid : InputFrameDomain text frame) :
    calls .procedureInputFrame text frame = procedureInputFrame text frame :=
  interpreted_inputFrame calls source.equations.toFrameEquations (source_scalar_append source) text frame valid

theorem source_prefix {calls : Calls} (source : InterpretedHelpers calls)
    (text : Source) (frame : ParserState) (declarationCount : Nat)
    (valid : PrefixDomain text frame declarationCount) :
    calls .procedurePrefix text frame declarationCount = procedurePrefix text frame declarationCount :=
  interpreted_prefix calls source.equations (source_prefix_imports source) source.contracts
    text frame declarationCount valid

end Silver.Compose.ProcedureDeclarationNative
