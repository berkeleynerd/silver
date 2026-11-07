module

public import Silver.SourceDeclarations
public import Silver.ComposeArrayDeclarationSource
public import Silver.ComposeContracts
public import Silver.ComposeBooleanDeclarationSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

/-! Kernel source-shape checks for one independent part of the complete
Compose candidate. The facade transports every part to authoritative tokens. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge

abbrev allTokens : List ShellToken := Expressions.allTokens

/-- The native membership expression contains one enumeration range followed
by these alternatives. Rendering and classification share this inventory. -/
def wordTokenAlternatives : List ShellToken :=
  [.word "constant", .word "string", .word "silver_arguments", .word "first_or_default",
   .word "if", .word "input_is_valid", .word "then", .word "else", .word "elsif", .word "reject",
   .word "and", .word "length", .word "or", .word "not", .word "null",
   .word "integer", .word "for", .word "in", .word "reverse", .word "loop", .word "range",
   .word "array", .word "of", .word "subtype",
   .word "boolean", .word "true", .word "false", .word "xor", .word "character",
   .word "function", .word "return"]

def wordTokens : List ShellToken := allTokens.take 11 ++ wordTokenAlternatives

def wordTokenBody : List String :=
  ["token", "in", Expressions.tokenName (.word "with"), "..", Expressions.tokenName (.word "end")] ++
    wordTokenAlternatives.flatMap (fun token => ["|", Expressions.tokenName token])

def commaNames (names : List String) : List String := List.flatten ((names.map fun name => [name]).intersperse [","])

def quoted (text : String) : String :=
  String.ofList (['"'] ++ text.toList.flatMap (fun ch => if ch = '"' then ['"', '"'] else [ch]) ++ ['"'])

/-- Statements is a scanner nonterminal; all lexical/helper tokens retain
an exact named representation in the native enumeration. -/
def booleanTokens : List ShellToken := [.word "boolean", .word "true", .word "false", .word "xor", .word "character"]

def functionTokens : List ShellToken := [.word "function", .word "return"]

def earlierTokens : List ShellToken := allTokens.take (allTokens.length - booleanTokens.length - functionTokens.length)

def nativeTokenNames : List String :=
  ((allTokens.take 50).map Expressions.tokenName) ++ ["statements", "context_clauses"] ++
    (((earlierTokens.drop 51).filter (· != ShellToken.word "subtype")).map Expressions.tokenName) ++
    [Expressions.tokenName (.word "subtype")] ++ (booleanTokens ++ functionTokens).map Expressions.tokenName

def spellingBody : List String := ["case", "token", "is"] ++
  List.flatten (((allTokens.take 41 ++ [ShellToken.word "null"] ++
      ((earlierTokens.drop 51).filter (· != ShellToken.word "subtype")).flatMap
        (fun token => if token == ShellToken.word "of" then [ShellToken.word "subtype", ShellToken.word "character"] ++ functionTokens ++
          (booleanTokens.filter (· != ShellToken.word "character")) ++ [token] else [token])).map fun token =>
    ["when", Expressions.tokenName token, "=>", quoted (Expressions.spelling token)]).intersperse [","]) ++
  [",", "when"] ++
  List.flatten ((((allTokens.drop 41).take 8).map Expressions.tokenName ++ ["statements", "context_clauses"]).map
    (fun name => [name]) |>.intersperse ["|"]) ++ ["=>", quoted "_"]

def helperForms : List Form := [.direct, .argument]

abbrev HelperCatalogueTranslationFor (specTokens bodyTokens : List String) : Prop :=
  typeDeclaration "form_kind" specTokens =
    some (["("] ++ commaNames (helperForms.map Expressions.formName) ++ [")"]) ∧
  typeDeclaration "token_kind" specTokens =
    some (["("] ++ commaNames nativeTokenNames ++ [")"]) ∧
  Source.expressionBody "spelling" bodyTokens = some spellingBody ∧
  Source.expressionBody "is_word_token" bodyTokens = some wordTokenBody ∧
  Source.expressionBody "is_argument_form" specTokens =
    some (expectedTokens "Form = Argument_Form")

private theorem catalogue_forms :
  typeDeclaration "form_kind" Output.SourceShape.outputSpecification =
    some (["("] ++ commaNames (helperForms.map Expressions.formName) ++ [")"]) := by decide +kernel

private theorem catalogue_fact_01 :
  typeDeclaration "token_kind" Output.SourceShape.outputSpecification =
    some (["("] ++ commaNames nativeTokenNames ++ [")"]) := by decide +kernel

private theorem catalogue_fact_03 :
  Source.expressionBody "spelling" Output.SourceShape.outputImplementation = some spellingBody := by decide +kernel

private theorem catalogue_fact_05 :
  Source.expressionBody "is_word_token" Output.SourceShape.outputImplementation = some wordTokenBody := by decide +kernel

private theorem catalogue_fact_06 :
  Source.expressionBody "is_argument_form" Output.SourceShape.outputSpecification =
    some (expectedTokens "Form = Argument_Form") := by decide +kernel

theorem candidate_catalogue : HelperCatalogueTranslationFor Output.SourceShape.outputSpecification Output.SourceShape.outputImplementation :=
  ⟨catalogue_forms, catalogue_fact_01, catalogue_fact_03, catalogue_fact_05, catalogue_fact_06⟩

/-- The checked enumeration order gives the exact meaning of With .. End;
every valid model token has the same word classification as that native set. -/
abbrev TokenMapping : Prop :=
  allTokens = Expressions.allTokens ∧
  allTokens.take 11 =
    [.word "with", .word "silver_io", .word "procedure", .word "main", .word "is",
     .word "pragma", .word "spark_mode", .word "on", .word "begin", .word "put_line", .word "end"] ∧
  (∀ token ∈ allTokens, 1 ≤ (Expressions.spelling token).length ∧ (Expressions.spelling token).length ≤ 16) ∧
  (∀ token ∈ allTokens, Expressions.isWord token = decide (token ∈ wordTokens))

theorem candidate_token_mapping : TokenMapping := by decide +kernel
end Silver.Compose.SourceBridge
