module

public import Silver.ComposeArrayExpressions
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Interpret the ordinary array-declaration wrapper while retaining the
existing typed initializer and its independent precedence and scope checks.
The model-result constant, assertion and equality lemma call are explicitly
Static and are erased from runtime evaluation under SPARK's predefined Static
assertion level. The complete model call and Ghost aspect are source checked.
The surrounding array-helper checks retain the model and wrapper headers with
identical preconditions; GNATprove checks the model call over that entire domain,
including zero-position states permitted by Valid_State. -/
namespace Silver.Compose.ArrayDeclarationNative

/-- This wrapper binds the initializer to Result, binds the same model call to
a Static ghost constant, checks the fixed Static assertion, and returns Result.
Its runtime initializer remains a typed state expression. -/
structure Body where
  initializer : Expressions.Expr .state

def Body.render (body : Body) : List String :=
  ["result", ":", "constant", "parser_state", ":=", "("] ++ body.initializer.render ++
  [")", ";", "model_state", ":", "constant", "parser_state", ":=",
   "array_declaration_model", "(", "text", ",", "state", ",", "arguments", ")",
   "with", "ghost", "=>", "static", ";", "begin", "pragma", "assert", "(",
   "static", "=>", "same_parser_state", "(", "result", ",", "model_state", ")",
   ")", ";", "lemma_parser_state_equality", "(", "result", ",", "model_state",
   ")", ";", "return", "result", ";", "end", "array_declaration_at", ";"]

def Body.eval (body : Body) (calls : Expressions.Calls)
    (locals : Expressions.Locals) : ParserState :=
  -- The fixed model call belongs to the explicitly Static constant above.
  -- SPARK RM 11.4.3 always ignores this level, independently of compiler flags.
  -- Its value is used only by the Static assertion and Static equality lemma.
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

/-- Require one complete ordinary body, including the exact runtime binding,
model call and Static ghost declaration, Static assertion and equality call,
return statement and function terminator. The declaration's fixed Ghost aspect
and the checked procedure header establish Static erasure; GNATprove discharges
both call preconditions and the complete wrapper contract. The surrounding
array-helper requirements retain the exact model/wrapper headers and initializer
tree checks, including their unchanged full native input domains. -/
abbrev Checked (tokens : List String) : Prop :=
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "array_declaration_at" tokens =
    some rendered ∧
  Silver.SourceBridge.procedureHeader "lemma_parser_state_equality" "is" tokens =
    some (Silver.SourceBridge.expectedTokens
      "(Left, Right : Parser_State) with Ghost => Static, Global => null, Pre => Same_Parser_State (Left, Right), Post => Left = Right and then Same_Parser_State (Left, Right)")

end SourceChecks
end Silver.Compose.ArrayDeclarationNative
