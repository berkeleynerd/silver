module

public import Silver.FunctionDeclarationBodyEquations
public import Silver.FunctionDeclarationDenotations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

theorem body_model_equation (text : Source) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (arguments : Bool) :
    functionBodyAt text outer frame first after resultType arguments =
      bodyEquation modelCalls text outer frame first after resultType arguments := by
  exact (functionBody_model text outer frame first after resultType arguments).symm.trans
    (body_denotation modelCalls text outer frame first after resultType arguments)

end Silver.Compose.FunctionDeclarationNative
