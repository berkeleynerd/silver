module

public import Silver.ComposeArrayExpressions
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Interpret the ordinary array-declaration wrapper while retaining the
existing typed initializer and its independent precedence and scope checks.
The checked Static assertion and the explicitly Static equality lemma call
are erased from runtime evaluation under the existing SPARK interpretation;
the complete call tokens and the lemma's Ghost aspect remain source checked. -/
namespace Silver.Compose.ArrayDeclarationNative

/-- This wrapper binds the initializer to Result, checks the fixed Static
assertion, and returns Result. Its initializer remains a typed state expression. -/
structure Body where
  initializer : Expressions.Expr .state

def Body.render (body : Body) : List String :=
  ["result", ":", "constant", "parser_state", ":=", "("] ++ body.initializer.render ++
  [")", ";", "begin", "pragma", "assert", "(", "static", "=>", "same_parser_state", "(",
   "result", ",", "array_declaration_model", "(", "text", ",", "state", ",", "arguments", ")",
   ")", ")", ";", "lemma_parser_state_equality", "(", "result", ",",
   "array_declaration_model", "(", "text", ",", "state", ",", "arguments", ")",
   ")", ";", "return", "result", ";", "end", "array_declaration_at", ";"]

def Body.eval (body : Body) (calls : Expressions.Calls)
    (locals : Expressions.Locals) : ParserState :=
  let result := body.initializer.eval calls locals
  result

def body : Body := ⟨Expressions.arrayDeclarationBody true⟩

def rendered : List String := body.render

/-- The wrapper retains the initializer's value for every callee interpretation
and local environment, including the complete native declaration domain. -/
theorem eval_eq_expression (calls : Expressions.Calls) (locals : Expressions.Locals) :
    body.eval calls locals = (Expressions.arrayDeclarationBody true).eval calls locals := rfl

/-- A source equation for the ordinary wrapper supplies the existing raw
array-declaration equation without any stronger caller or callee premise. -/
theorem equation_of_definition (calls : Expressions.Calls) (locals : Expressions.Locals)
    (value : ParserState) (definition : value = body.eval calls locals) :
    value = (Expressions.arrayDeclarationBody true).eval calls locals :=
  definition.trans (eval_eq_expression calls locals)

namespace SourceChecks

/-- Require one complete ordinary body, including the exact constant binding,
Static assertion and equality call, return statement and function terminator.
The checked procedure header establishes Static erasure of that call; GNATprove
discharges its precondition and postcondition. The surrounding
array-helper requirements retain the exact headers and initializer tree checks. -/
abbrev Checked (tokens : List String) : Prop :=
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "array_declaration_at" tokens =
    some rendered ∧
  Silver.SourceBridge.procedureHeader "lemma_parser_state_equality" "is" tokens =
    some (Silver.SourceBridge.expectedTokens
      "(Left, Right : Parser_State) with Ghost => Static, Global => null, Pre => Same_Parser_State (Left, Right), Post => Left = Right")

end SourceChecks
end Silver.Compose.ArrayDeclarationNative
