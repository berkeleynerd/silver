module

public import Silver.SourceBridge
public import Silver.OutputSpecCertificate
public import Silver.OutputBodyCertificate
public import Silver.OutputLexicalSpecCertificate
public import Silver.OutputLexicalBodyCertificate
public import Silver.IOSpecCertificate
public import Silver.IOBodyCertificate
public import Silver.OutputLibcCertificate
public import Silver.OutputExpressions
public import Silver.OutputRuntime
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

/-! Source correspondence for shared lexical helpers and the output runtime.
The actual composed recognizer is checked in ComposeSourceBridge. This module
retains the literal/byte lexical translations, shared bounds, complete source
shapes and the whole output-body renderer with its runtime contracts. The
frontend interpretation and native SPARK audit remain explicit premises. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Output.SourceBridge

open Silver.SourceBridge

def literalExpression : List String := Expressions.literalBody.render

abbrev ExpressionTranslation : Prop :=
  Expressions.literalBody.wellFormed = true ∧
  Source.expressionBody "comment_end" Source.outputLexicalSpecTokens = some Silver.Expressions.commentBody.render ∧
  Source.expressionBody "trivia_end" Source.outputLexicalSpecTokens = some Silver.Expressions.triviaBody.render ∧
  Source.expressionBody "token_at" Source.outputLexicalSpecTokens = some Silver.Expressions.tokenBody.render ∧
  Source.expressionBody "allowed_source" Source.outputBodyTokens = some Silver.Expressions.allowedBody.render ∧
  Source.expressionBody "literal_end" Source.outputLexicalSpecTokens = some literalExpression

theorem actual_expressions : ExpressionTranslation := by decide +kernel

/-- The extracted helper uses the null-profile package's shared lexical constants.
Their declarations agree with the output profile's constants at this boundary. -/
abbrev LexicalConstants : Prop :=
  Source.declaration "max_source_length" Source.specTokens =
    Source.declaration "max_source_length" Source.outputSpecTokens ∧
  Source.declaration "comment_introducer" Source.specTokens =
    Source.declaration "comment_introducer" Source.outputSpecTokens

theorem actual_lexical_constants : LexicalConstants := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "accepts" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Accepts'Result = Is_Member (Source))") ∧
  functionHeader "normalized" "is" Source.outputBodyTokens = some (expectedTokens
    "(Source : String) return String with Global => null, Pre => Source'Length <= Max_Source_Length, Post => Normalized'Result'First = 1 and then Normalized'Result'Length = Source'Length and then Normalized'Result = Source") ∧
  functionHeader "literal_end" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; Position : Cursor) return Literal_Position")

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
  procedureHeader "put" Source.ioSpecTokens = some (expectedTokens
    "(Item : String) with Global => (In_Out => Ada.Text_IO.File_System, Output => (Written_Bytes, Written_Count, Flushed, Succeeded)), Always_Terminates => False, Post => (Static => Succeeded = Flushed and then (if Succeeded then Item'Length <= Max_Length and then Written_Count = Item'Length and then Written_Bytes (1 .. Item'Length) = Item))") ∧
  procedureHeader "set_exit_status" Source.outputLibcTokens = some (expectedTokens
    "(Status : Interfaces.C.int) with Import, Convention => C, External_Name => \"__gnat_set_exit_status\", Always_Terminates => True, Global => (In_Out => Ada.Text_IO.File_System)")

theorem actual_runtime_declarations : RuntimeDeclarations :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

def runtimeFrame : List String := expectedTokens
  "with Interfaces.C; with System; with Silver_Output_Libc; package body Silver_IO with SPARK_Mode => On is use type Interfaces.C.int; procedure Put_Line (Item : String) is Status : Interfaces.C.int; begin"

def renderedRuntime : List String := runtimeFrame ++
  Runtime.program.flatMap Runtime.Instruction.render ++
  expectedTokens "end Put_Line; procedure Put (Item : String) is Status : Interfaces.C.int; begin" ++
  Runtime.putProgram.flatMap Runtime.Instruction.render ++
  expectedTokens "end Put; end Silver_IO;"

/-- Every executable assignment, branch, loop and external call is interpreted
by Runtime.program or Runtime.putProgram; their combined rendering equals the
actual whole body. -/
theorem actual_runtime_translation : Source.ioBodyTokens = renderedRuntime := by decide +kernel

abbrev CompleteShape : Prop :=
  Source.outputSpecTokens = SourceShape.outputSpecification ∧
  Source.outputBodyTokens = SourceShape.outputImplementation ∧
  Source.outputLexicalSpecTokens = SourceShape.outputLexicalSpecification ∧
  Source.outputLexicalBodyTokens = SourceShape.outputLexicalImplementation ∧
  Source.ioSpecTokens = SourceShape.ioSpecification ∧
  Source.ioBodyTokens = SourceShape.ioImplementation ∧
  Source.outputLibcTokens = SourceShape.libcSpecification

theorem actual_complete_shape : CompleteShape := ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

structure CheckedSource : Prop where
  outputSpecification : Source.lex Source.outputProfileSpec = some Source.outputSpecTokens
  outputImplementation : Source.lex Source.outputProfileBody = some Source.outputBodyTokens
  lexicalSpecification : Source.lex Source.outputLexicalSpec = some Source.outputLexicalSpecTokens
  lexicalImplementation : Source.lex Source.outputLexicalBody = some Source.outputLexicalBodyTokens
  ioSpecification : Source.lex Source.ioSpec = some Source.ioSpecTokens
  ioImplementation : Source.lex Source.ioBody = some Source.ioBodyTokens
  libcSpecification : Source.lex Source.outputLibcSpec = some Source.outputLibcTokens
  shape : CompleteShape
  expressions : ExpressionTranslation
  lexicalConstants : LexicalConstants
  refinement : Refinement
  runtimeDeclarations : RuntimeDeclarations
  runtimeTranslation : Source.ioBodyTokens = renderedRuntime

theorem checked_source : CheckedSource where
  outputSpecification := Source.outputSpecTokens_correct
  outputImplementation := Source.outputBodyTokens_correct
  lexicalSpecification := Source.outputLexicalSpecTokens_correct
  lexicalImplementation := Source.outputLexicalBodyTokens_correct
  ioSpecification := Source.ioSpecTokens_correct
  ioImplementation := Source.ioBodyTokens_correct
  libcSpecification := Source.outputLibcTokens_correct
  shape := actual_complete_shape
  expressions := actual_expressions
  lexicalConstants := actual_lexical_constants
  refinement := actual_refinement
  runtimeDeclarations := actual_runtime_declarations
  runtimeTranslation := actual_runtime_translation

/-- Whole-source runtime correspondence and behavioral refinement together.
An altered guard/call/byte/loop cannot satisfy the same checked translation. -/
theorem authoritative_runtime_correct (environment : Runtime.Environment) (item : Source) :
    CheckedSource ∧ Runtime.execute environment item Runtime.program [] =
      Runtime.specification environment item :=
  ⟨checked_source, Runtime.program_refines environment item⟩

/-- `Put` is derived from the same checked whole body, with its distinct exact
no-newline byte sequence and the unchanged flush/failure contract. -/
theorem authoritative_put_runtime_correct (environment : Runtime.Environment) (item : Source) :
    CheckedSource ∧ Runtime.execute environment item Runtime.putProgram [] =
      Runtime.putSpecification environment item :=
  ⟨checked_source, Runtime.put_program_refines environment item⟩

end Silver.Output.SourceBridge
