module

public import Silver.ProcedureDeclarationBodyImports
public import Silver.ProcedureDeclarationOuterImports
public import Silver.FunctionDeclarationHeaderEquations

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

/-- All written Procedure_Body_At preconditions and the native Parser_State
component types. No successful-declaration or fresh-frame premise is added. -/
structure BodyDomain (text : Source) (outer frame : ParserState) (first after : Nat) : Prop where
  outerValid : FunctionDeclarationNative.StateInput text outer
  frameValid : FunctionDeclarationNative.StateInput text frame
  growth : outer.procedures.parameters.length ≤ frame.procedures.parameters.length
  firstParameter : 0 < frame.firstProcedureParameter
  lastParameter : frame.firstProcedureParameter ≤ frame.procedures.parameters.length
  capacity : frame.procedures.items.length < ProcedureBindings.maxProcedures
  name : FunctionBindings.NameSpan text first after

/-- Raw equations preserve the complete native precondition domain, including
rejected states. Source checks bind the trees; imported helper equations are
interpreted separately before a declaration meaning is concluded. -/
structure HighEquations (calls : Calls) : Prop where
  body : ∀ text, FunctionBindings.Native.ValidText text → ∀ outer frame first after arguments,
    BodyDomain text outer frame first after →
    calls .procedureBody text outer frame first after arguments =
      procedureBodyBody.eval calls (BodyInput.locals ⟨text, outer, frame, first, after, arguments⟩)
  declaration : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    FunctionDeclarationNative.StateInput text state →
    calls .procedureDeclaration text state arguments =
      procedureDeclarationBody.eval calls (DeclarationInput.locals ⟨text, state, arguments⟩)

theorem interpreted_body (calls : Calls) (equations : HighEquations calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (outer frame : ParserState)
    (first after : Nat) (arguments : Bool) (valid : BodyDomain text outer frame first after)
    (imports : BodyImports calls text outer frame first after arguments) :
    calls .procedureBody text outer frame first after arguments = procedureBodyAt text outer frame first after arguments := by
  rw [equations.body text tv outer frame first after arguments valid]
  exact procedureBody_imports calls text outer frame first after arguments imports

theorem interpreted_declaration (calls : Calls) (equations : HighEquations calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState)
    (arguments : Bool) (valid : FunctionDeclarationNative.StateInput text state)
    (imports : DeclarationImports calls text state arguments) :
    calls .procedureDeclaration text state arguments = procedureDeclarationAt text state arguments := by
  rw [equations.declaration text tv state arguments valid]
  exact declaration_imports calls text state arguments imports

end Silver.Compose.ProcedureDeclarationNative
