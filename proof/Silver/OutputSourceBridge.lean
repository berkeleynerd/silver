import Silver.SourceBridge
import Silver.OutputExpressions
import Silver.Current
import Silver.NamedEquations
import Silver.ArgumentsExpressions
import Silver.GuardedExpressions
import Silver.ReviewedOutputShape

/-! Source correspondence for literal-output admission and execution. `Calls.member`
interprets the internal Is_Literal_Member helper; the public Is_Member union is
closed by GuardedSourceBridge. Existing typed
expression trees bind the copied lexical primitives and membership composition.
The two new recursive expression templates fix operators, grouping and calls;
OutputEquations proves uniqueness on their legal machine domains. The reviewed
Ada frontend interpretation supplies their definition equations, as it does for
the null bridge. The runtime renderer covers the whole body with interpreted
executable instructions and a finite set of fixed static observations. Separate
checks bind every erased target to its Static declaration and Max_Length to the
shared model bound. Ada statement/ghost interpretation and the GNATprove audit
remain explicit premises; the complete-shape pin alone establishes no semantics. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Output.SourceBridge

open Silver.SourceBridge

def literalExpression : List String := Expressions.literalBody.render
def suffixExpression : List String := Expressions.suffixBody.render

abbrev ExpressionTranslation : Prop :=
  Expressions.WellFormedTrees ∧
  Source.expressionBody "comment_end" Source.outputBodyTokens = some Silver.Expressions.commentBody.render ∧
  Source.expressionBody "trivia_end" Source.outputBodyTokens = some Silver.Expressions.triviaBody.render ∧
  Source.expressionBody "token_at" Source.outputBodyTokens = some Silver.Expressions.tokenBody.render ∧
  Source.expressionBody "allowed_source" Source.outputBodyTokens = some Silver.Expressions.allowedBody.render ∧
  Source.expressionBody "is_literal_member" Source.outputBodyTokens = some Silver.Expressions.memberBody.render ∧
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

def namedTokenName : Named.Token → String
  | .base token => tokenName token
  | .colon => "colon" | .constantKeyword => "constant_keyword" | .stringName => "string_name"
  | .assignment => "assignment" | .declarationName => "declaration_name" | .referenceName => "reference_name"
  | .ampersand => "ampersand"

def argumentTokens : List Arguments.Token := allTokens.map Arguments.Token.base ++
  [.colon, .constantKeyword, .stringName, .assignment, .declarationName, .referenceName,
   .argumentsName, .firstOrDefaultName, .ifKeyword, .inputIsValidName, .thenKeyword, .elseKeyword, .rejectName, .ampersand]

def argumentNames (tokens : List Arguments.Token) : List String :=
  List.flatten ((tokens.map (fun token => [Arguments.Expressions.tokenName token])).intersperse [","])

def namedNames (tokens : List Named.Token) : List String :=
  List.flatten ((tokens.map (fun token => [namedTokenName token])).intersperse [","])

def fullSpellingExpression : List String := spellingExpression ++
  [.colon, .constantKeyword, .stringName, .assignment].flatMap (fun (token : Named.Token) =>
    [",", "when", namedTokenName token, "=>", "\"" ++ token.spellingText ++ "\""]) ++
  [",", "when", "declaration_name", "|", "reference_name", "=>",
    "\"" ++ Named.Token.declarationName.spellingText ++ "\""] ++
  [.argumentsName, .firstOrDefaultName, .ifKeyword, .inputIsValidName, .thenKeyword, .elseKeyword, .rejectName, .ampersand].flatMap
    (fun (token : Arguments.Token) =>
      [",", "when", Arguments.Expressions.tokenName token, "=>", "\"" ++ token.spellingText ++ "\""])

def guardedTokens : List Guarded.Token := allTokens.map Guarded.Token.base ++
  [.colon, .constantKeyword, .stringName, .assignment, .declarationName, .referenceName,
   .argumentsName, .firstOrDefaultName, .ifKeyword, .inputIsValidName, .thenKeyword,
   .elseKeyword, .rejectName, .ampersand, .andKeyword, .apostrophe, .lengthName,
   .lessEqual, .capacityLiteral]

def guardedNames (tokens : List Guarded.Token) : List String :=
  List.flatten ((tokens.map (fun token => [Guarded.Expressions.tokenName token])).intersperse [","])

def guardedSpellingExpression : List String := fullSpellingExpression ++
  [.andKeyword, .apostrophe, .lengthName, .lessEqual, .capacityLiteral].flatMap
    (fun (token : Guarded.Token) =>
      [",", "when", Guarded.Expressions.tokenName token, "=>", "\"" ++ token.spellingText ++ "\""])

theorem guarded_word_token_denotation (token : Guarded.Token) :
    token.isWord = decide (guardedTokens.idxOf token ≤ 10 ∨
      token = .constantKeyword ∨ token = .stringName ∨
      (22 ≤ guardedTokens.idxOf token ∧ guardedTokens.idxOf token ≤ 28) ∨
      token = .andKeyword ∨ token = .lengthName) := by
  cases token with
  | base token => cases token <;> decide
  | _ => decide

theorem guarded_fixed_token_bounds (token : Guarded.Token) :
    0 < token.spelling.length ∧ token.spelling.length ≤ 16 := by
  cases token with
  | base token => cases token <;> decide
  | _ => decide

theorem variable_token_same_spelling :
    Named.Token.declarationName.spelling = Named.Token.referenceName.spelling := rfl

theorem full_word_token_denotation (token : Arguments.Token) :
    token.isWord = decide (argumentTokens.idxOf token ≤ 10 ∨
      token = .constantKeyword ∨ token = .stringName ∨ (22 ≤ argumentTokens.idxOf token ∧ argumentTokens.idxOf token ≤ 28)) := by
  cases token with
  | base token => cases token <;> decide
  | _ => decide

abbrev CatalogueTranslation : Prop :=
  typeDeclaration "token_kind" Source.outputSpecTokens = some (["("] ++ guardedNames guardedTokens ++ [")"]) ∧
  Source.declaration "required_tokens" Source.outputSpecTokens =
    some (["constant", "token_sequence", ":=", "("] ++ names requiredTokens ++ [")"]) ∧
  Source.declaration "named_required_tokens" Source.outputSpecTokens =
    some (["constant", "token_sequence", ":=", "("] ++ namedNames Named.requiredTokens ++ [")"]) ∧
  Source.declaration "argument_required_tokens" Source.outputSpecTokens =
    some (["constant", "token_sequence", ":=", "("] ++ argumentNames Arguments.requiredTokens ++ [")"]) ∧
  Source.declaration "concatenation_required_tokens" Source.outputSpecTokens =
    some (["constant", "token_sequence", ":=", "("] ++ namedNames Concat.requiredTokens ++ [")"]) ∧
  Source.declaration "guarded_required_tokens" Source.outputSpecTokens =
    some (["constant", "token_sequence", ":=", "("] ++ guardedNames Guarded.requiredTokens ++ [")"]) ∧
  Source.declaration "assignment_required_tokens" Source.outputSpecTokens =
    some (["constant", "token_sequence", ":=", "("] ++ namedNames Assignment.requiredTokens ++ [")"]) ∧
  Source.expressionBody "spelling" Source.outputBodyTokens = some guardedSpellingExpression ∧
  Source.expressionBody "is_word_token" Source.outputBodyTokens =
    some ["token", "in", "with_keyword", "..", "end_keyword", "|", "constant_keyword", "|", "string_name", "|", "arguments_name", "|", "first_or_default_name", "|", "if_keyword", "|", "input_is_valid_name", "|", "then_keyword", "|", "else_keyword", "|", "reject_name", "|", "and_keyword", "|", "length_name"] ∧
  Source.declaration "max_source_length" Source.outputSpecTokens =
    some ["constant", "positive", ":=", "4_096"] ∧
  Source.declaration "comment_introducer" Source.outputSpecTokens =
    some ["constant", "string", "(", "1", "..", "2", ")", ":=", "\"--\""]

theorem actual_catalogue : CatalogueTranslation := by decide +kernel

theorem fixed_token_bounds (token : Arguments.Token) :
    0 < token.spelling.length ∧ token.spelling.length ≤ 16 := by
  cases token with
  | base token => cases token <;> decide
  | _ => decide

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

/-- Extract unique procedure declarations without accepting a second overload. -/
def procedureHeaders (name : String) : List String → List (List String)
  | [] => []
  | "procedure" :: actual :: tokens =>
    let later := procedureHeaders name (actual :: tokens)
    if actual == name then
      match Source.declarationEnd 0 tokens with
      | some header => header :: later
      | none => later
    else later
  | _ :: tokens => procedureHeaders name tokens

def procedureHeader (name : String) (tokens : List String) : Option (List String) :=
  match procedureHeaders name tokens with
  | [header] => some header
  | _ => none

/-- Fixed declarations classify all targets in GhostAction.render as Static.
The numeric spelling check ties the extracted Ada bound to Runtime.maxLength. -/
abbrev RuntimeDeclarations : Prop :=
  Source.declaration "max_length" Source.ioSpecTokens =
    some ["constant", "positive", ":=", "4_096"] ∧
  ("4_096".toList.filter (· != '_')).foldl
    (fun value digit => value * 10 + (digit.toNat - 48)) 0 = Runtime.maxLength ∧
  Source.declaration "written_bytes" Source.ioSpecTokens = some (expectedTokens
    "String (1 .. Max_Length + 1) := (others => Character'Val (0)) with Ghost => Static") ∧
  Source.declaration "written_count" Source.ioSpecTokens = some (expectedTokens
    "Natural range 0 .. Max_Length + 1 := 0 with Ghost => Static") ∧
  Source.declaration "flushed" Source.ioSpecTokens = some (expectedTokens
    "Boolean := False with Ghost => Static") ∧
  Source.declaration "succeeded" Source.ioSpecTokens = some (expectedTokens
    "Boolean := False with Ghost => Static") ∧
  procedureHeader "put_line" Source.ioSpecTokens = some (expectedTokens
    "(Item : String) with Global => (In_Out => Ada.Text_IO.File_System, Output => (Written_Bytes, Written_Count, Flushed, Succeeded)), Always_Terminates => False, Post => (Static => Succeeded = Flushed and then (if Succeeded then Item'Length <= Max_Length and then Written_Count = Item'Length + 1 and then Written_Bytes (1 .. Item'Length) = Item and then Written_Bytes (Written_Count) = Character'Val (10)))") ∧
  procedureHeader "set_exit_status" Source.outputLibcTokens = some (expectedTokens
    "(Status : Interfaces.C.int) with Import, Convention => C, External_Name => \"__gnat_set_exit_status\", Always_Terminates => True, Global => (In_Out => Ada.Text_IO.File_System)")

theorem actual_runtime_declarations : RuntimeDeclarations :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

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
  runtimeDeclarations : RuntimeDeclarations
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
  runtimeDeclarations := actual_runtime_declarations
  runtimeTranslation := actual_runtime_translation

/-- A checked translation and uniqueness of all new recursive definitions.
Equations carry the same frontend/machine-domain premise as the null bridge;
none assumes the conclusion or automatic proof success. This theorem covers
the retained literal-only helper; GuardedSourceBridge covers the public union. -/
theorem authoritative_output_member_iff (calls : Calls) (primitives : PrimitiveCalls)
    (equations : Expressions.InterpretedSource calls primitives)
    (source : Source) : CheckedSource ∧ (calls.member source = true ↔ Member source) :=
  ⟨checked_source, source_implementation_member_iff calls primitives
    (Expressions.interpreted_equations calls primitives equations) source⟩

/-- Whole-source runtime correspondence and behavioral refinement together.
An altered guard/call/byte/loop cannot satisfy the same checked translation. -/
theorem authoritative_runtime_correct (environment : Runtime.Environment) (item : Source) :
    CheckedSource ∧ Runtime.execute environment item Runtime.program [] =
      Runtime.specification environment item :=
  ⟨checked_source, Runtime.program_refines environment item⟩

end Silver.Output.SourceBridge
