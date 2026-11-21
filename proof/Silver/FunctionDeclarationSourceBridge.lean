module

public import Silver.FunctionDeclarationBodyLibrary
public import Silver.FunctionDeclarationReturnLibrary
public import Silver.FunctionDeclarationSource
public import Silver.FunctionDeclarationStateRecords
public import Silver.PredicateBodyLibraries

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
  arrayLibrary : ArrayBindings.Native.Calls
  arrayLibrarySource : ArrayBindings.SourceBridge.InterpretedSource arrayLibrary
  arrayValidType : calls .validArrayType = arrayLibrary.validType
  equations : OrdinaryEquations calls
  contracts : TraversalContracts calls
  lexical : ∃ (helpers : Guarded.Expressions.Calls)
      (token : Source → Nat → String → Bool → Bool),
    inherited.primitive = Lexical.primitives helpers token ∧
      Lexical.InterpretedSource helpers token
  bodyLibraries : Predicate.BodyLibraries.Calls inherited
  bodyDefinitions : Predicate.BodyLibraries.Definitions bodyLibraries
  bodyLinks : BodyLinks calls bodyLibraries.body bodyLibraries.bodyWrappers
  actualImports : Predicate.FunctionCallNative.Imports
  actualCalls : Predicate.FunctionCallNative.Calls
  assignment : Source → Predicate.Native.Context → Predicate.BodyScan → FunctionBindings.Metadata → Predicate.BodyScan
  actualLinks : Predicate.FunctionCallNative.ImportsLinks actualImports inherited bodyLibraries.predicate
  actualEquations : Predicate.FunctionCallNative.DefinitionEquations actualImports actualCalls assignment
  actualLink : calls .actualAfter = actualCalls.actual

theorem source_array_parameter_imports {calls : Calls} (source : InterpretedSource calls) :
    ArrayParameterImports calls :=
  array_parameter_imports source.arrayLibrary source.arrayLibrarySource source.arrayValidType

/-- All normalized reader meanings are conclusions from the raw source
bodies, contracts, and the callees selected by this interpretation. -/
theorem source_lexical {calls : Calls} (source : InterpretedSource calls) :
    Lexical.Meaning source.inherited.primitive := by
  obtain ⟨helpers, token, linked, definitions⟩ := source.lexical
  rw [linked]
  exact Lexical.interpreted_primitives helpers token definitions

theorem source_reader_equations {calls : Calls} (source : InterpretedSource calls) :
    Predicate.BodyNative.Equations source.bodyLibraries.body :=
  Predicate.BodyLibraries.body_equations source.bodyLibraries
    source.inheritedSource.toRawHelperEquations source.bodyDefinitions (source_lexical source)

theorem source_wrapper_models {calls : Calls} (source : InterpretedSource calls) :
    Predicate.Adapter.Wrappers.ModelEquations source.bodyLibraries.bodyWrapperModels source.bodyLibraries.body :=
  Predicate.BodyLibraries.wrapper_models source.bodyLibraries
    source.inheritedSource.toRawHelperEquations source.bodyDefinitions

theorem source_actual_meaning {calls : Calls} (source : InterpretedSource calls) :
    Predicate.FunctionCallNative.ImportsMeaning source.actualImports :=
  Predicate.FunctionCallNative.imports_meaning source.inheritedSource.toRawHelperEquations
    (Predicate.BodyLibraries.predicate_helpers source.bodyLibraries
      source.inheritedSource.toRawHelperEquations source.bodyDefinitions)
    source.bodyDefinitions.predicates source.bodyDefinitions.predicateContracts source.actualLinks

theorem source_return_imports {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (context : Predicate.Native.Context) (scan : Predicate.BodyScan) (resultType : FunctionTypeResult)
    (valid : ReturnInput text context scan resultType) : ReturnImports calls text context scan resultType :=
  return_library_imports source.inheritedSource.toRawHelperEquations source.links.toHeaderLinks
    source.actualImports source.actualCalls source.assignment (source_actual_meaning source) source.actualEquations
    source.actualLink text tv context scan resultType valid

theorem source_body_imports {calls : Calls} (source : InterpretedSource calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) (valid : BodyInput text outer frame first after resultType) :
    BodyImports calls text outer frame first after resultType arguments :=
  body_library_imports source.inheritedSource source.exactDomain
    (FunctionBindings.SourceBridge.interpreted_complete source.metadata source.metadataSource)
    source.visibilityPrimitives source.visibilityEquations source.links source.headers source.headerContracts
    source.frames (source_array_parameter_imports source) source.equations source.contracts source.bodyLibraries.body (source_reader_equations source)
    source.bodyLibraries.bodyWrapperModels source.bodyLibraries.bodyWrappers
    (source_wrapper_models source) source.bodyDefinitions.wrappers source.bodyLinks (source_return_imports source)
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
