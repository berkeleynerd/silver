import Silver.SourceBridge
import Silver.OutputExpressions
import Silver.Current
import Silver.ReviewedOutputShape

/-! Source correspondence for output admission and execution. Existing typed
expression trees bind the copied lexical primitives and membership composition.
The two new recursive expression templates fix operators, grouping and calls;
OutputEquations proves uniqueness on their legal machine domains. The reviewed
Ada frontend interpretation supplies their definition equations, as it does for
the null bridge. Runtime body correspondence is stronger than a token pin: the
complete executable body is rendered from the interpreted statement structure.
Static ghost operations erase only after their checked declarations/contracts
and the GNATprove audit establish their SPARK meaning. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Output.SourceBridge

open Silver.SourceBridge

def literalExpression : List String := Expressions.literalBody.render
def suffixExpression : List String := Expressions.suffixBody.render

abbrev ExpressionTranslation : Prop :=
  Source.expressionBody "comment_end" Source.outputBodyTokens = some Silver.Expressions.commentBody.render ∧
  Source.expressionBody "trivia_end" Source.outputBodyTokens = some Silver.Expressions.triviaBody.render ∧
  Source.expressionBody "token_at" Source.outputBodyTokens = some Silver.Expressions.tokenBody.render ∧
  Source.expressionBody "allowed_source" Source.outputBodyTokens = some Silver.Expressions.allowedBody.render ∧
  Source.expressionBody "is_member" Source.outputBodyTokens = some Silver.Expressions.memberBody.render ∧
  Source.expressionBody "literal_end" Source.outputBodyTokens = some literalExpression ∧
  Source.expressionBody "suffix_matches" Source.outputBodyTokens = some suffixExpression

theorem actual_expressions : ExpressionTranslation := by decide +kernel

def tokenName : Token → String
  | .withKeyword => "with_keyword" | .ioName => "io_name" | .procedureKeyword => "procedure_keyword"
  | .mainName => "main_name" | .isKeyword => "is_keyword" | .pragmaKeyword => "pragma_keyword"
  | .sparkModeName => "spark_mode_name" | .onName => "on_name" | .beginKeyword => "begin_keyword"
  | .putLineName => "put_line_name" | .endKeyword => "end_keyword"
  | .leftParenthesis => "left_parenthesis" | .rightParenthesis => "right_parenthesis"
  | .semicolon => "semicolon" | .dot => "dot" | .stringLiteral => "string_literal"

def allTokens : List Token :=
  [.withKeyword, .ioName, .procedureKeyword, .mainName, .isKeyword, .pragmaKeyword,
   .sparkModeName, .onName, .beginKeyword, .putLineName, .endKeyword,
   .leftParenthesis, .rightParenthesis, .semicolon, .dot, .stringLiteral]

theorem word_token_denotation (token : Token) :
    token.isWord = decide (allTokens.idxOf token ≤ 10) := by
  cases token <;> decide

def names (tokens : List Token) : List String :=
  List.flatten ((tokens.map (fun token => [tokenName token])).intersperse [","])

def quotedSpelling (token : Token) : String :=
  if token = .stringLiteral then "\"\"\"\"" else "\"" ++ token.spellingText ++ "\""

def spellingExpression : List String := ["case", "token", "is"] ++
  List.flatten ((allTokens.map (fun token => ["when", tokenName token, "=>", quotedSpelling token])).intersperse [","])

abbrev CatalogueTranslation : Prop :=
  typeDeclaration "token_kind" Source.outputSpecTokens = some (["("] ++ names allTokens ++ [")"]) ∧
  Source.declaration "required_tokens" Source.outputSpecTokens =
    some (["constant", "token_sequence", ":=", "("] ++ names requiredTokens ++ [")"]) ∧
  Source.expressionBody "spelling" Source.outputBodyTokens = some spellingExpression ∧
  Source.expressionBody "is_word_token" Source.outputBodyTokens =
    some ["token", "in", "with_keyword", "..", "end_keyword"] ∧
  Source.declaration "max_source_length" Source.outputSpecTokens =
    some ["constant", "positive", ":=", "4_096"] ∧
  Source.declaration "comment_introducer" Source.outputSpecTokens =
    some ["constant", "string", "(", "1", "..", "2", ")", ":=", "\"--\""]

theorem actual_catalogue : CatalogueTranslation := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "accepts" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Accepts'Result = Is_Member (Source))") ∧
  functionHeader "normalized" "is" Source.outputBodyTokens = some (expectedTokens
    "(Source : String) return String with Global => null, Pre => Source'Length <= Max_Source_Length, Post => Normalized'Result'First = 1 and then Normalized'Result'Length = Source'Length and then Normalized'Result = Source") ∧
  functionHeader "literal_end" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor) return Literal_Position") ∧
  functionHeader "suffix_matches" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Next_Token : Token_Index) return Boolean")

theorem actual_refinement : Refinement := by decide +kernel

def runtimeFrame : List String := expectedTokens
  "with Interfaces.C; with System; with Silver_Output_Libc; package body Silver_IO with SPARK_Mode => On is use type Interfaces.C.int; procedure Put_Line (Item : String) is Status : Interfaces.C.int; begin"

def renderedRuntime : List String := runtimeFrame ++
  Runtime.program.flatMap Runtime.Instruction.render ++
  expectedTokens "end Put_Line; end Silver_IO;"

/-- Every executable assignment, branch, loop and external call is interpreted
by Runtime.program, and its rendering equals the actual whole body. -/
theorem actual_runtime_translation : Source.ioBodyTokens = renderedRuntime := by decide +kernel

abbrev CompleteShape : Prop :=
  Source.outputSpecTokens = SourceShape.outputSpecification ∧
  Source.outputBodyTokens = SourceShape.outputImplementation ∧
  Source.ioSpecTokens = SourceShape.ioSpecification ∧
  Source.ioBodyTokens = SourceShape.ioImplementation ∧
  Source.outputLibcTokens = SourceShape.libcSpecification

theorem actual_complete_shape : CompleteShape := ⟨rfl, rfl, rfl, rfl, rfl⟩

structure CheckedSource : Prop where
  outputSpecification : Source.lex Source.outputProfileSpec = some Source.outputSpecTokens
  outputImplementation : Source.lex Source.outputProfileBody = some Source.outputBodyTokens
  ioSpecification : Source.lex Source.ioSpec = some Source.ioSpecTokens
  ioImplementation : Source.lex Source.ioBody = some Source.ioBodyTokens
  libcSpecification : Source.lex Source.outputLibcSpec = some Source.outputLibcTokens
  shape : CompleteShape
  expressions : ExpressionTranslation
  catalogue : CatalogueTranslation
  refinement : Refinement
  runtimeTranslation : Source.ioBodyTokens = renderedRuntime

theorem checked_source : CheckedSource where
  outputSpecification := Source.outputSpecTokens_correct
  outputImplementation := Source.outputBodyTokens_correct
  ioSpecification := Source.ioSpecTokens_correct
  ioImplementation := Source.ioBodyTokens_correct
  libcSpecification := Source.outputLibcTokens_correct
  shape := actual_complete_shape
  expressions := actual_expressions
  catalogue := actual_catalogue
  refinement := actual_refinement
  runtimeTranslation := actual_runtime_translation

/-- A checked translation and uniqueness of all new recursive definitions.
Equations carry the same frontend/machine-domain premise as the null bridge;
none assumes the conclusion or automatic proof success. -/
theorem authoritative_output_member_iff (calls : Calls) (primitives : PrimitiveCalls)
    (equations : Expressions.InterpretedSource calls primitives)
    (source : Source) : CheckedSource ∧ (calls.member source = true ↔ Member source) :=
  ⟨checked_source, source_implementation_member_iff calls primitives
    (Expressions.interpreted_equations calls primitives equations) source⟩

theorem authoritative_current_member_iff
    (nullCalls : Silver.Expressions.Calls) (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (outputCalls : Calls) (primitives : PrimitiveCalls)
    (outputEquations : Expressions.InterpretedSource outputCalls primitives) (source : Source) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ((nullCalls.member source || outputCalls.member source) = true ↔ Current.Member source) := by
  refine ⟨Silver.SourceBridge.checked_source, checked_source, ?_⟩
  simp only [Bool.or_eq_true, Current.Member,
    Silver.Expressions.member_implementation_iff nullCalls nullEquations source,
    source_implementation_member_iff outputCalls primitives
      (Expressions.interpreted_equations outputCalls primitives outputEquations) source]

/-- Whole-source runtime correspondence and behavioral refinement together.
An altered guard/call/byte/loop cannot satisfy the same checked translation. -/
theorem authoritative_runtime_correct (environment : Runtime.Environment) (item : Source) :
    CheckedSource ∧ Runtime.execute environment item Runtime.program [] =
      Runtime.specification environment item :=
  ⟨checked_source, Runtime.program_refines environment item⟩

/-- Actual admitted bytes complete the stronger current pipeline under the
explicit tool and fixed-library contracts. No premise identifies membership
with prover success; the language proof supplies the empty user obligations. -/
theorem checked_current_pipeline {Artifact : Type} {tools : Current.Tools Artifact}
    (contract : Current.ToolContract tools)
    (nullCalls : Silver.Expressions.Calls) (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (outputCalls : Calls) (primitives : PrimitiveCalls)
    (outputEquations : Expressions.InterpretedSource outputCalls primitives)
    (source : Source) (accepted : (nullCalls.member source || outputCalls.member source) = true) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ∃ artifact steps, Current.Pipeline tools source artifact steps := by
  have bridge := authoritative_current_member_iff nullCalls nullEquations
    outputCalls primitives outputEquations source
  exact ⟨bridge.1, bridge.2.1, Current.automatic_pipeline contract (bridge.2.2.mp accepted)⟩

end Silver.Output.SourceBridge
