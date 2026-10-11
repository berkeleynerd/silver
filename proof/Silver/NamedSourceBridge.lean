import Silver.OutputSourceBridge
import Silver.NamedExpressions

/-! Source checks for shared identifier and name-binding helpers. The finite spelling function
is an ordinary case/return body, so its complete body and enum are checked
separately from expression bodies. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Named.SourceBridge

open Silver.SourceBridge

/-- Read through the named terminator, retaining every intervening token. -/
def throughEnd (name : String) : List String → Option (List String)
  | [] => none
  | "end" :: actual :: ";" :: rest =>
      if actual == name then some ["end", actual, ";"]
      else (throughEnd name (actual :: ";" :: rest)).map ("end" :: ·)
  | token :: rest => (throughEnd name rest).map (token :: ·)

/-- Select complete ordinary function implementations, excluding forward
specifications and rejecting duplicate implementations. -/
def ordinaryFunctions (name : String) : List String → List (List String)
  | [] => []
  | "function" :: actual :: tokens =>
      let later := ordinaryFunctions name (actual :: tokens)
      if actual == name then
        match headerEnd 0 tokens with
        | some (header, "is") =>
            match throughEnd name (tokens.drop (header.length + 1)) with
            | some body => body :: later
            | none => later
        | _ => later
      else later
  | _ :: tokens => ordinaryFunctions name tokens

def ordinaryFunction (name : String) (tokens : List String) : Option (List String) :=
  match ordinaryFunctions name tokens with
  | [body] => some body
  | _ => none

def forbiddenEnum : List String := ["("] ++
  List.flatten ((forbiddenSpellings.map (fun word => ["forbidden_" ++ word])).intersperse [","]) ++ [")"]

def forbiddenSpellingBody : List String := ["begin", "case", "word", "is"] ++
  forbiddenSpellings.flatMap (fun word =>
    ["when", "forbidden_" ++ word, "=>", "return", "\"" ++ word ++ "\"", ";"]) ++
  ["end", "case", ";", "end", "forbidden_spelling", ";"]

abbrev ForbiddenTranslation : Prop :=
  typeDeclaration "forbidden_kind" Source.outputLexicalSpecTokens = some forbiddenEnum ∧
  ordinaryFunction "forbidden_spelling" Source.outputLexicalBodyTokens = some forbiddenSpellingBody ∧
  functionHeader "forbidden_spelling" "is" Source.outputLexicalBodyTokens = some (expectedTokens
    "(Word : Forbidden_Kind) return String")

theorem actual_forbidden_translation : ForbiddenTranslation := by decide +kernel

abbrev ExpressionTranslation : Prop :=
  Expressions.letterBody.wellFormed = true ∧
  Expressions.tailBody.wellFormed = true ∧
  Expressions.finishBody.wellFormed = true ∧
  Expressions.nameBody.wellFormed = true ∧
  Expressions.equalBody.wellFormed = true ∧
  Expressions.forbiddenBody.wellFormed = true ∧
  Expressions.stateBody.wellFormed = true ∧
  Source.expressionBody "is_letter" Source.outputLexicalSpecTokens = some Expressions.letterBody.render ∧
  Source.expressionBody "identifier_tail" Source.outputLexicalSpecTokens = some Expressions.tailBody.render ∧
  Source.expressionBody "identifier_end" Source.outputLexicalSpecTokens = some Expressions.finishBody.render ∧
  Source.expressionBody "name_is" Source.outputLexicalSpecTokens = some Expressions.nameBody.render ∧
  Source.expressionBody "equal_name" Source.outputLexicalSpecTokens = some Expressions.equalBody.render ∧
  Source.expressionBody "forbidden_name" Source.outputLexicalSpecTokens = some Expressions.forbiddenBody.render ∧
  Source.expressionBody "valid_name_state" Source.outputLexicalSpecTokens = some Expressions.stateBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "is_letter" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Item : Character) return Boolean") ∧
  functionHeader "identifier_tail" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Previous_Underscore : Boolean) return Literal_Position") ∧
  functionHeader "identifier_end" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; Position : Cursor) return Literal_Position") ∧
  functionHeader "name_is" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; First, After : Cursor; Word : String) return Boolean") ∧
  functionHeader "equal_name" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; Left_First, Left_After, Right_First, Right_After : Cursor) return Boolean") ∧
  functionHeader "forbidden_name" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; First, After : Cursor) return Boolean") ∧
  functionHeader "valid_name_state" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; First, After : Literal_Position) return Boolean")

theorem actual_refinement : Refinement := by decide +kernel

structure CheckedSource : Prop where
  output : Output.SourceBridge.CheckedSource
  forbidden : ForbiddenTranslation
  expressions : ExpressionTranslation
  refinement : Refinement

theorem checked_source : CheckedSource where
  output := Output.SourceBridge.checked_source
  forbidden := actual_forbidden_translation
  expressions := actual_expressions
  refinement := actual_refinement

end Silver.Named.SourceBridge
