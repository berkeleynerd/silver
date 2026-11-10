module

public import Silver.ProcedureDeclarationNative
public import Silver.FunctionDeclarationHeaderEquations
public import Silver.ProcedureFrameRecordTypes

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

/-- Parser-state component types remain part of the domain, including when
the native validity predicate permits the zero-position failure state. -/
abbrev StateInput := FunctionDeclarationNative.StateInput
abbrev StateRecord := FunctionDeclarationNative.StateRecord

def AppendDomain (frame : ParserState) (parameter : ProcedureBindings.Formal) : Prop :=
  StateRecord frame ∧ ProcedureBindings.Native.FormalType parameter

/-- The recursive frame model has no source or Valid_State precondition.
Its cursor subtype and written index bound are retained exactly. -/
def InputFrameModelDomain (frame : ParserState) (index : Nat) : Prop :=
  StateRecord frame ∧ 0 < index ∧ index ≤ frame.procedures.parameters.length + 1

def InputFrameDomain (text : Source) (frame : ParserState) : Prop :=
  FunctionBindings.Native.ValidText text ∧ StateInput text frame ∧ 0 < frame.firstProcedureParameter

/-- Prefix_Step permits any typed formal with a valid nonempty source name
and nonempty bounds. The stronger declaration-formal predicate is not imposed. -/
def PrefixStepDomain (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat) : Prop :=
  FunctionBindings.Native.ValidText text ∧ StateInput text readFrame ∧ StateInput text frame ∧
    declarationCount ≤ readFrame.scalarNames.length ∧ ProcedureBindings.Native.FormalType parameter ∧
    0 < parameter.first ∧ FunctionBindings.NameSpan text parameter.first parameter.after ∧
    !parameter.bounds.isEmpty

def PrefixModelDomain (text : Source) (readFrame frame : ParserState)
    (index declarationCount : Nat) : Prop :=
  FunctionBindings.Native.ValidText text ∧ StateInput text readFrame ∧ StateInput text frame ∧
    declarationCount ≤ readFrame.scalarNames.length ∧ 0 < index ∧
    index ≤ frame.procedures.parameters.length + 1

def PrefixDomain (text : Source) (frame : ParserState) (declarationCount : Nat) : Prop :=
  InputFrameDomain text frame ∧ declarationCount ≤ frame.scalarNames.length

end Silver.Compose.ProcedureDeclarationNative
