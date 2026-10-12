module

public import Silver.Source
public import Silver.Precedence
public import Silver.Uniqueness
public import Silver.SupportedTools
public import Silver.ReviewedSourceShape
public import Silver.RecursiveBridge
import all Init.Data.Repr

@[expose] public section

/-!
Checked translation of the actual SPARK recognizer specification. The source
reader embeds the authoritative files and supplies kernel-checked token
certificates. Here the uniquely named expression bodies are matched to typed,
precedence-checked trees; their denotations were proved in Expressions.lean.

This bridge relies on the approved GNAT/GNATprove front end for the enclosing
Ada declarations, machine bounds, and the proved imperative `Accepts` contract.
It is not a verified parser for arbitrary Ada, nor a proof of compiler I/O or
GNATprove subprocess completion.
-/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.SourceBridge

open Silver.Expressions

def allTokens : List Token :=
  [.procedureKeyword, .mainName, .isKeyword, .pragmaKeyword, .sparkModeName,
   .onName, .beginKeyword, .nullKeyword, .endKeyword,
   .leftParenthesis, .rightParenthesis, .semicolon]

def tokenName : Token → String
  | .procedureKeyword => "procedure_keyword"
  | .mainName => "main_name"
  | .isKeyword => "is_keyword"
  | .pragmaKeyword => "pragma_keyword"
  | .sparkModeName => "spark_mode_name"
  | .onName => "on_name"
  | .beginKeyword => "begin_keyword"
  | .nullKeyword => "null_keyword"
  | .endKeyword => "end_keyword"
  | .leftParenthesis => "left_parenthesis"
  | .rightParenthesis => "right_parenthesis"
  | .semicolon => "semicolon"

def tokenOrdinal : Token → Nat
  | .procedureKeyword => 0 | .mainName => 1 | .isKeyword => 2
  | .pragmaKeyword => 3 | .sparkModeName => 4 | .onName => 5
  | .beginKeyword => 6 | .nullKeyword => 7 | .endKeyword => 8
  | .leftParenthesis => 9 | .rightParenthesis => 10 | .semicolon => 11

theorem token_ordinals (token : Token) : allTokens[tokenOrdinal token]? = some token := by
  cases token <;> decide

theorem word_token_denotation (token : Token) :
    token.isWord = decide (0 ≤ tokenOrdinal token ∧ tokenOrdinal token ≤ 8) := by
  cases token <;> decide

def separatedNames (tokens : List Token) : List String :=
  List.flatten ((tokens.map (fun token => [tokenName token])).intersperse [","])

def enumDeclaration : List String := ["("] ++ separatedNames allTokens ++ [")"]
def requiredDeclaration : List String :=
  ["constant", "token_sequence", ":=", "("] ++ separatedNames requiredTokens ++ [")"]

def quotedSpelling (token : Token) : String :=
  String.ofList ('"' :: (token.spelling.map Char.ofNat) ++ ['"'])

def spellingExpression : List String := ["case", "token", "is"] ++
  List.flatten ((allTokens.map (fun token => ["when", tokenName token, "=>", quotedSpelling token])).intersperse [","])

def typeDeclarations (name : String) : List String → List (List String)
  | [] => []
  | "type" :: actual :: "is" :: tokens =>
    let later := typeDeclarations name (actual :: "is" :: tokens)
    if actual == name then
      match Source.declarationEnd 0 tokens with
      | some body => body :: later
      | none => later
    else later
  | _ :: tokens => typeDeclarations name tokens

def typeDeclaration (name : String) (tokens : List String) : Option (List String) :=
  match typeDeclarations name tokens with
  | [body] => some body
  | _ => none

/-- The complete header ends at a top-level `is` or semicolon. -/
def headerEnd : Nat → List String → Option (List String × String)
  | _, [] => none
  | depth, token :: tokens =>
    if depth == 0 && (token == "is" || token == ";") then some ([], token)
    else do
      let next := if token == "(" then depth + 1 else if token == ")" then depth - 1 else depth
      let (header, stop) ← headerEnd next tokens
      pure (token :: header, stop)

def functionHeaders (name stop : String) : List String → List (List String)
  | [] => []
  | "function" :: actual :: tokens =>
    let later := functionHeaders name stop (actual :: tokens)
    if actual == name then
      match headerEnd 0 tokens with
      | some (header, terminator) => if terminator == stop then header :: later else later
      | none => later
    else later
  | _ :: tokens => functionHeaders name stop tokens

def functionHeader (name stop : String) (tokens : List String) : Option (List String) :=
  match functionHeaders name stop tokens with
  | [header] => some header
  | _ => none

/-- All expected headers below are single physical lines. -/
def expectedTokens (text : String) : List String := (Source.lexLine text).getD []

abbrev NumericTranslation (name : String) (expression : Number) : Prop :=
  expression.wellFormed = true ∧
    Source.expressionBody name Source.bodyTokens = some expression.render

abbrev BooleanTranslation (name : String) (expression : Condition) : Prop :=
  expression.wellFormed = true ∧
    Source.expressionBody name Source.bodyTokens = some expression.render

theorem actual_comment : NumericTranslation "comment_end" commentBody := by decide +kernel
theorem actual_trivia : NumericTranslation "trivia_end" triviaBody := by decide +kernel
theorem actual_token : BooleanTranslation "token_at" tokenBody := by decide +kernel
theorem actual_suffix : BooleanTranslation "suffix_matches" suffixBody := by decide +kernel
theorem actual_member : BooleanTranslation "is_member" memberBody := by decide +kernel
theorem actual_allowed : BooleanTranslation "allowed_source" allowedBody := by decide +kernel
theorem actual_whitespace : BooleanTranslation "is_whitespace" whitespaceBody := by decide +kernel
theorem actual_allowedCharacter : BooleanTranslation "is_allowed_character" allowedCharacterBody := by decide +kernel
theorem actual_lineEnd : BooleanTranslation "is_comment_end" lineEndBody := by decide +kernel
theorem actual_identifier : BooleanTranslation "is_identifier_character" identifierBody := by decide +kernel
theorem actual_lowercase : NumericTranslation "lowercase" lowercaseBody := by decide +kernel

abbrev CatalogueTranslation : Prop :=
    typeDeclaration "token_kind" Source.specTokens = some enumDeclaration ∧
    Source.declaration "required_tokens" Source.specTokens = some requiredDeclaration ∧
    Source.expressionBody "spelling" Source.bodyTokens = some spellingExpression ∧
    Source.expressionBody "is_word_token" Source.bodyTokens =
      some ["token", "in", "procedure_keyword", "..", "end_keyword"] ∧
    Source.declaration "max_source_length" Source.specTokens =
      some ["constant", "positive", ":=", "4_096"] ∧
    Source.declaration "comment_introducer" Source.specTokens =
      some ["constant", "string", "(", "1", "..", "2", ")", ":=", "\"--\""]

theorem actual_catalogue : CatalogueTranslation := by decide +kernel

abbrev GhostHeaders : Prop :=
    functionHeader "comment_end" "is" Source.bodyTokens =
      some (expectedTokens "(Text : String; Position : Cursor) return Cursor") ∧
    functionHeader "trivia_end" "is" Source.bodyTokens =
      some (expectedTokens "(Text : String; Position : Cursor) return Cursor") ∧
    functionHeader "token_at" "is" Source.bodyTokens =
      some (expectedTokens "(Text : String; Position : Cursor; Word : String; Is_Word : Boolean) return Boolean") ∧
    functionHeader "suffix_matches" "is" Source.bodyTokens =
      some (expectedTokens "(Text : String; Position : Cursor; Next_Token : Token_Index) return Boolean") ∧
    functionHeader "is_member" "is" Source.bodyTokens =
      some (expectedTokens "(Source : String) return Boolean")

theorem actual_ghost_headers : GhostHeaders := by decide +kernel

abbrev PrimitiveHeaders : Prop :=
    functionHeader "is_whitespace" "is" Source.bodyTokens =
      some (expectedTokens "(Item : Character) return Boolean") ∧
    functionHeader "is_allowed_character" "is" Source.bodyTokens =
      some (expectedTokens "(Item : Character) return Boolean") ∧
    functionHeader "is_comment_end" "is" Source.bodyTokens =
      some (expectedTokens "(Item : Character) return Boolean") ∧
    functionHeader "is_identifier_character" "is" Source.bodyTokens =
      some (expectedTokens "(Item : Character) return Boolean") ∧
    functionHeader "lowercase" "is" Source.bodyTokens =
      some (expectedTokens "(Item : Character) return Character") ∧
    functionHeader "is_word_token" "is" Source.bodyTokens =
      some (expectedTokens "(Token : Token_Kind) return Boolean") ∧
    functionHeader "spelling" "is" Source.bodyTokens =
      some (expectedTokens "(Token : Token_Kind) return String") ∧
    functionHeader "allowed_source" "is" Source.bodyTokens =
      some (expectedTokens "(Text : String) return Boolean")

theorem actual_primitive_headers : PrimitiveHeaders := by decide +kernel

abbrev RefinementContract : Prop :=
    functionHeader "accepts" ";" Source.specTokens = some (expectedTokens
      "(Source : String) return Boolean with Global => null, Post => Accepts'Result = Is_Member (Source)") ∧
    functionHeader "normalized" "is" Source.bodyTokens = some (expectedTokens
      "(Source : String) return String with Global => null, Pre => Source'Length <= Max_Source_Length, Post => Normalized'Result'First = 1 and then Normalized'Result'Length = Source'Length and then Normalized'Result = Source")

theorem actual_refinement_contract : RefinementContract := by decide +kernel

/-- The source-checked membership expression denotes exactly the independent language. -/
theorem source_member_iff (context : Context) :
    BooleanTranslation "is_member" memberBody ∧
      (memberBody.eval context = true ↔ Member context.text) := by
  refine ⟨actual_member, ?_⟩
  rw [memberBody_denotation]
  exact Cursor.isMember_iff context.text

/-- Every compiler byte is covered, including comment and literal contents. -/
theorem actual_source_alphabet :
    Source.compilerSource Source.profileSpec = true ∧
    Source.compilerSource Source.profileBody = true := by
  constructor
  · rw [← Source.specTokens_source]
    exact Source.certified_source_supported _
  · rw [← Source.bodyTokens_source]
    exact Source.certified_source_supported _

/-- Complete scopes and declarations, not just selected expression lookups.
Any extra operator, helper, rename, context clause, aspect, or syntax form changes
this checked shape and is rejected even if all selected expression text agrees. -/
theorem actual_source_shape :
    Source.specTokens = SourceShape.specification ∧
    Source.bodyTokens = SourceShape.implementation := ⟨rfl, rfl⟩

structure CheckedSource : Prop where
  specification : Source.lex Source.profileSpec = some Source.specTokens
  implementation : Source.lex Source.profileBody = some Source.bodyTokens
  alphabet : Source.compilerSource Source.profileSpec = true ∧
    Source.compilerSource Source.profileBody = true
  shape : Source.specTokens = SourceShape.specification ∧
    Source.bodyTokens = SourceShape.implementation
  catalogue : CatalogueTranslation
  ghostHeaders : GhostHeaders
  primitiveHeaders : PrimitiveHeaders
  refinement : RefinementContract
  comment : NumericTranslation "comment_end" commentBody
  trivia : NumericTranslation "trivia_end" triviaBody
  token : BooleanTranslation "token_at" tokenBody
  suffix : BooleanTranslation "suffix_matches" suffixBody
  member : BooleanTranslation "is_member" memberBody
  allowed : BooleanTranslation "allowed_source" allowedBody
  whitespace : BooleanTranslation "is_whitespace" whitespaceBody
  allowedCharacter : BooleanTranslation "is_allowed_character" allowedCharacterBody
  lineEnd : BooleanTranslation "is_comment_end" lineEndBody
  identifier : BooleanTranslation "is_identifier_character" identifierBody
  lowercase : NumericTranslation "lowercase" lowercaseBody

theorem checked_source : CheckedSource where
  specification := Source.specTokens_correct
  implementation := Source.bodyTokens_correct
  alphabet := actual_source_alphabet
  shape := actual_source_shape
  catalogue := actual_catalogue
  ghostHeaders := actual_ghost_headers
  primitiveHeaders := actual_primitive_headers
  refinement := actual_refinement_contract
  comment := actual_comment
  trivia := actual_trivia
  token := actual_token
  suffix := actual_suffix
  member := actual_member
  allowed := actual_allowed
  whitespace := actual_whitespace
  allowedCharacter := actual_allowedCharacter
  lineEnd := actual_lineEnd
  identifier := actual_identifier
  lowercase := actual_lowercase

/-- The complete authoritative source is checked, and EVERY interpretation of
its checked definition equations recognizes exactly the independent language.
The recursive equality follows from uniqueness, not from hard-wiring callees.
The equations use the documented approved-front-end meaning of the fixed source
fragment and GNATprove's machine-bound and normalization contracts. -/
theorem authoritative_source_member_iff (calls : Calls)
    (equations : DefinitionEquations calls) (context : Context) :
    CheckedSource ∧ (calls.member context.text = true ↔ Member context.text) :=
  ⟨checked_source, member_implementation_iff calls equations context.text⟩

/-- Actual-source membership implies completion under the explicit external
contracts; source and recursive-interpretation checks are retained. -/
theorem checked_membership_supported_pipeline {Artifact : Type}
    {tools : SupportedTools.Operations Artifact} (contract : SupportedTools.Contract tools)
    (calls : Calls) (equations : DefinitionEquations calls)
    (context : Context) (accepted : calls.member context.text = true) :
    CheckedSource ∧
    ∃ artifact steps, SupportedTools.Pipeline tools context.text artifact steps := by
  refine ⟨checked_source, ?_⟩
  exact SupportedTools.admitted_pipeline_completes contract
    ((authoritative_source_member_iff calls equations context).2.mp accepted)

end Silver.SourceBridge
