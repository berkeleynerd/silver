module

public import Silver.FunctionDeclarationBodyLibrary
public import Silver.FunctionDeclarationReturnLibrary
public import Silver.FunctionDeclarationSource
public import Silver.FunctionDeclarationStateRecords

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

/-- A source interpretation consists of checked definition/contract equations
and direct links to separately interpreted libraries. No field identifies the
whole function declaration scanner with its mathematical model. -/
structure InterpretedSource (calls : Calls) where
  domain : Expressions.StateDomain
  inherited : Expressions.Calls
  inheritedSource : InheritedEquations inherited domain
  exactDomain : ExactDomain domain
  metadata : FunctionBindings.Native.Calls
  metadataSource : FunctionBindings.SourceBridge.InterpretedSource metadata
  visibility : FunctionVisibilityNative.Implementation
  visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls
  visibilityEquations : FunctionVisibilityNative.Equations visibility
  links : OrdinaryLinks calls inherited metadata visibility
  headers : HeaderEquations calls
  headerContracts : HeaderContracts calls
  frames : FrameEquations calls
  equations : OrdinaryEquations calls
  contracts : TraversalContracts calls
  reader : Predicate.BodyNative.Calls
  readerSource : Predicate.BodyNative.Equations reader
  models : Predicate.Adapter.Wrappers.Calls
  wrappers : Predicate.Adapter.Wrappers.Calls
  modelEquations : Predicate.Adapter.Wrappers.ModelEquations models reader
  refinement : Predicate.Adapter.Wrappers.Refinement models wrappers
  bodyLinks : BodyLinks calls reader wrappers
  actualImports : Predicate.FunctionCallNative.Imports
  actualCalls : Predicate.FunctionCallNative.Calls
  assignment : Source → Predicate.Native.Context → Predicate.BodyScan → FunctionBindings.Metadata → Predicate.BodyScan
  actualMeaning : Predicate.FunctionCallNative.ImportsMeaning actualImports
  actualEquations : Predicate.FunctionCallNative.DefinitionEquations actualImports actualCalls assignment
  actualLink : calls .actualAfter = actualCalls.actual

theorem source_return_imports {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (context : Predicate.Native.Context) (scan : Predicate.BodyScan) (resultType : FunctionTypeResult)
    (valid : ReturnInput text context scan resultType) : ReturnImports calls text context scan resultType :=
  return_library_imports source.inheritedSource.toRawHelperEquations source.links.toHeaderLinks
    source.actualImports source.actualCalls source.assignment source.actualMeaning source.actualEquations
    source.actualLink text tv context scan resultType valid

theorem source_body_imports {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) (valid : BodyInput text outer frame first after resultType) :
    BodyImports calls text outer frame first after resultType arguments :=
  body_library_imports source.inheritedSource source.exactDomain
    (FunctionBindings.SourceBridge.interpreted_complete source.metadata source.metadataSource)
    source.visibilityPrimitives source.visibilityEquations source.links source.headers source.headerContracts
    source.frames source.equations source.contracts source.reader source.readerSource source.models source.wrappers
    source.modelEquations source.refinement source.bodyLinks (source_return_imports source)
    text tv outer frame first after resultType arguments valid

theorem source_declaration_imports {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : DeclarationImports calls text state arguments :=
  declaration_library_imports source.inheritedSource source.exactDomain
    (FunctionBindings.SourceBridge.interpreted_complete source.metadata source.metadataSource)
    source.visibilityPrimitives source.visibilityEquations source.links source.headers source.headerContracts
    source.contracts source.equations (source_body_imports source) text tv state arguments valid

theorem interpreted_source_declaration {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) :
    calls .functionDeclaration text state arguments = functionDeclarationAt text state arguments :=
  interpreted_declaration calls source.equations text tv state arguments valid
    (source_declaration_imports source text tv state arguments valid)

/-- Native callers already supply the complete state predicate. Its record
bounds are derived here rather than required as an additional premise. -/
theorem interpreted_native_declaration {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : NativeValidState text state) :
    calls .functionDeclaration text state arguments = functionDeclarationAt text state arguments :=
  interpreted_source_declaration source text tv state arguments (StateInput.ofNative tv valid)

/-- Adapter for the inherited source-helper domain used by the outer bridge. -/
theorem interpreted_inherited_declaration {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : Expressions.NativeState source.domain text state) :
    calls .functionDeclaration text state arguments = functionDeclarationAt text state arguments :=
  interpreted_native_declaration source text tv state arguments
    ((source.exactDomain.state text state).mp valid.base)

/-- The full source-token witness must be instantiated for the authoritative
native file by the root source candidate. Native contract discharge remains an
independent requirement, represented by the interpretation above. -/
theorem checked_source_declaration (tokens : List String) (checked : SourceChecks.Checked tokens) :
    SourceChecks.Checked tokens ∧ ∀ calls, InterpretedSource calls →
      ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments, StateInput text state →
        calls .functionDeclaration text state arguments = functionDeclarationAt text state arguments :=
  ⟨checked, fun _ source => interpreted_source_declaration source⟩

end Silver.Compose.FunctionDeclarationNative
