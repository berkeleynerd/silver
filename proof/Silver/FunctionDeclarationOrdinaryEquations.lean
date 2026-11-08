module

public import Silver.FunctionDeclarationComposition

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

/-- Literal_Position and Scalars.Interval component subtypes of the result
record, including typed values whose cursor is zero or whose interval is empty. -/
structure TypeResultRecord (value : FunctionTypeResult) : Prop where
  after : CursorType value.after
  bounds : value.bounds.Bounded

/-- The complete written Function_Body_At precondition and native record types.
No declaration-history or fresh-frame condition is added. -/
structure BodyInput (text : Source) (outerState frameState : ParserState) (first after : Nat)
    (result : FunctionTypeResult) : Prop where
  outer : StateInput text outerState
  frame : StateInput text frameState
  growth : outerState.functions.parameters.length ≤ frameState.functions.parameters.length
  firstParameter : 0 < frameState.firstParameter
  lastParameter : frameState.firstParameter ≤ frameState.functions.parameters.length
  capacity : frameState.functions.items.length < FunctionBindings.maxFunctions
  name : FunctionBindings.NameSpan text first after
  resultType : TypeResultRecord result
  nonempty : result.bounds.isEmpty = false

def BodyScanInput (text : Source) (context : Predicate.Native.Context) (scan : Predicate.BodyScan) : Prop :=
  scan.position ≤ text.length + 1 ∧ (scan.target ≤ context.names.length ∧ scan.capacity ≤ maxSourceLength) ∧ Predicate.Native.ValidFlow context scan.facts

/-- The return helper permits every typed result interval, including Empty.
Only Function_Body_At's caller precondition requires a nonempty result subtype. -/
structure ReturnInput (text : Source) (contextValue : Predicate.Native.Context) (scanValue : Predicate.BodyScan)
    (result : FunctionTypeResult) : Prop where
  context : Predicate.Native.ValidContext text contextValue
  scan : BodyScanInput text contextValue scanValue
  resultType : TypeResultRecord result

structure OrdinaryEquations (calls : Calls) : Prop where
  returnAfter : ∀ text, FunctionBindings.Native.ValidText text → ∀ context scan resultType,
    ReturnInput text context scan resultType →
    calls .returnAfter text context scan resultType = returnAfterBody.eval calls ({text, context, scan, resultType} : Frame).locals
  functionBody : ∀ text, FunctionBindings.Native.ValidText text → ∀ outer frame first after resultType arguments,
    BodyInput text outer frame first after resultType →
    calls .functionBody text outer frame first after resultType arguments =
      functionBodyBody.eval calls ({text, outer, frame, first, after, resultType, arguments} : Frame).locals
  declaration : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state → calls .functionDeclaration text state arguments =
      functionDeclarationBody.eval calls ({text, state, arguments} : Frame).locals

theorem interpreted_returnAfter (calls : Calls) (equations : OrdinaryEquations calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (context : Predicate.Native.Context) (scan : Predicate.BodyScan) (resultType : FunctionTypeResult)
    (valid : ReturnInput text context scan resultType) (imports : ReturnImports calls text context scan resultType) :
    calls .returnAfter text context scan resultType = functionReturnAfter text context.model scan resultType := by
  rw [equations.returnAfter text tv context scan resultType valid]
  exact returnAfter_imports calls text context scan resultType imports

theorem interpreted_functionBody (calls : Calls) (equations : OrdinaryEquations calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) (valid : BodyInput text outer frame first after resultType)
    (imports : BodyImports calls text outer frame first after resultType arguments) :
    calls .functionBody text outer frame first after resultType arguments = functionBodyAt text outer frame first after resultType arguments := by
  rw [equations.functionBody text tv outer frame first after resultType arguments valid]
  exact functionBody_imports calls text outer frame first after resultType arguments imports

theorem interpreted_declaration (calls : Calls) (equations : OrdinaryEquations calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) (imports : DeclarationImports calls text state arguments) :
    calls .functionDeclaration text state arguments = functionDeclarationAt text state arguments := by
  rw [equations.declaration text tv state arguments valid]
  exact declaration_imports calls text state arguments imports

end Silver.Compose.FunctionDeclarationNative
