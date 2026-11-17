module

public import Silver.FunctionDeclarationDenotations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 4000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

/-- Individual imported calls at the source's exact arguments. Their native
input domains are discharged by the downstream library bridge; no field
assumes Function_Type_At or a declaration scanner's model equality. -/
structure TypeImports (calls : Calls) (text : Source) (state : ParserState) (position : Nat) : Prop where
  scalarType : calls .scalarType text state position = scalarTypeAt text state position
  skip : calls .skip text position = skipAt text position
  take : calls .take text (skipAt text position) Token.booleanName.shell =
    tokenAfter text (skipAt text position) Token.booleanName.shell
  strings : let first := skipAt text position; let after := fixedAfter text first "boolean" true
    calls .lookupString text state.names first after = lookupName text state.names first after
  scalars : let first := skipAt text position; let after := fixedAfter text first "boolean" true
    calls .lookupScalar text state.scalarNames first after = ScalarExpression.lookup text state.scalarNames first after
  booleans : let first := skipAt text position; let after := fixedAfter text first "boolean" true
    calls .lookupBoolean text state.booleanNames first after = BooleanBindings.lookup text state.booleanNames first after
  subtypes : let first := skipAt text position; let after := fixedAfter text first "boolean" true
    calls .lookupSubtype text state.subtypeNames first after = IntegerSubtypes.lookup text state.subtypeNames first after
  arrays : let first := skipAt text position; let after := fixedAfter text first "boolean" true
    calls .lookupArray text state.arrayNames.names first after = ArrayBindings.lookup text state.arrayNames.names first after
  functions : let first := skipAt text position; let after := fixedAfter text first "boolean" true
    calls .lookupFunction text state.functions first after = FunctionBindings.lookup text state.functions first after
  procedures : let first := skipAt text position; let after := fixedAfter text first "boolean" true
    calls .lookupProcedure text state.procedures first after = ProcedureBindings.lookup text state.procedures first after
  formals : let first := skipAt text position; let after := fixedAfter text first "boolean" true
    calls .formalHides text state first after = formalHides text state first after

theorem functionType_imports (calls : Calls) (text : Source) (state : ParserState) (position : Nat)
    (imports : TypeImports calls text state position) :
    functionTypeBody.eval calls ({text, state, position} : Frame).locals = functionTypeAt text state position := by
  have taken : calls .take text (skipAt text position) (.fixed "boolean" true) =
      fixedAfter text (skipAt text position) "boolean" true := by
    simpa only [Token.shell, tokenAfter, ShellToken.word] using imports.take
  simp [functionTypeBody, Expr.eval, apply2, apply3, apply4, Frame.locals, Locals.set,
    Field.get, imports.scalarType, imports.skip, taken,
    Token.shell, ShellToken.word, imports.strings, imports.scalars, imports.booleans,
    imports.subtypes, imports.arrays, imports.functions, imports.procedures, imports.formals, functionTypeAt,
    Bool.or_eq_true, or_assoc]

/-- Append_Parameter has no Valid_State precondition. Its only imported call
is Append on the scalar branch after the native capacity guard. -/
structure AppendParameterImports (calls : Calls) (frame : ParserState) (parameter : FunctionBindings.Formal) : Prop where
  scalarAppend : parameter.kind = .integer → frame.scalarNames.length ≠ ScalarExpression.maxBindings →
    calls .scalarAppend frame.scalarNames
      ⟨parameter.first, parameter.after, parameter.bounds, false, parameter.bounds, false⟩ =
    frame.scalarNames ++ [⟨parameter.first, parameter.after, parameter.bounds, false, parameter.bounds, false⟩]

theorem appendParameter_imports (calls : Calls) (frame : ParserState) (parameter : FunctionBindings.Formal)
    (imports : AppendParameterImports calls frame parameter) :
    appendParameterBody.eval calls ({frame, parameter} : Frame).locals = appendParameter frame parameter := by
  cases kindEq : parameter.kind with
  | integer =>
      by_cases full : frame.scalarNames.length = ScalarExpression.maxBindings
      · simp [appendParameterBody, Expr.eval, apply2, Frame.locals, Field.get, appendParameter, Capacity.value, kindEq, full]
      · simp [appendParameterBody, Expr.eval, apply2, Frame.locals, Field.get, StateField.set, appendParameter, Capacity.value, kindEq, full, imports.scalarAppend kindEq full]
  | boolean =>
      simp [appendParameterBody, Expr.eval, apply2, Frame.locals, Field.get, appendParameter, Capacity.value, kindEq]

/-- The return wrapper imports just one token reader and one actual reader.
The actual reader receives the original flow and the declared result subtype. -/
structure ReturnImports (calls : Calls) (text : Source) (context : Predicate.Native.Context)
    (scan : Predicate.BodyScan) (resultType : FunctionTypeResult) : Prop where
  take : calls .take text scan.position Token.returnKeyword.shell =
    tokenAfter text scan.position Token.returnKeyword.shell
  actual : calls .actualAfter text context (fixedAfter text scan.position "return" true) scan.facts
      ⟨0, 0, resultType.kind, resultType.bounds⟩ =
    Predicate.actualAfter text context.model (fixedAfter text scan.position "return" true) scan.facts
      ⟨0, 0, resultType.kind, resultType.bounds⟩

theorem returnAfter_imports (calls : Calls) (text : Source) (context : Predicate.Native.Context)
    (scan : Predicate.BodyScan) (resultType : FunctionTypeResult)
    (imports : ReturnImports calls text context scan resultType) :
    returnAfterBody.eval calls ({text, context, scan, resultType} : Frame).locals =
      functionReturnAfter text context.model scan resultType := by
  have taken : calls .take text scan.position (.fixed "return" true) =
      fixedAfter text scan.position "return" true := by
    simpa only [Token.shell, tokenAfter, ShellToken.word] using imports.take
  by_cases zero : fixedAfter text scan.position "return" true = 0 <;>
    simp [returnAfterBody, Command.eval, Expr.eval, apply2, apply3, apply4, apply5,
      Frame.locals, Locals.set, Field.get, taken, Token.shell,
      ShellToken.word, imports.actual, functionReturnAfter, zero, Predicate.actualAfter_zero]

end Silver.Compose.FunctionDeclarationNative
