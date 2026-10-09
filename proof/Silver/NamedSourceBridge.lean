import Silver.OutputSourceBridge
import Silver.NamedExpressions

/-! Source checks for the one-binding extension. The finite spelling function
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
  typeDeclaration "forbidden_kind" Source.outputBodyTokens = some forbiddenEnum ∧
  ordinaryFunction "forbidden_spelling" Source.outputBodyTokens = some forbiddenSpellingBody ∧
  functionHeader "forbidden_spelling" "is" Source.outputBodyTokens = some (expectedTokens
    "(Word : Forbidden_Kind) return String")

theorem actual_forbidden_translation : ForbiddenTranslation := by decide +kernel

abbrev ExpressionTranslation : Prop :=
  Source.expressionBody "is_letter" Source.outputBodyTokens = some Expressions.letterBody.render ∧
  Source.expressionBody "identifier_tail" Source.outputBodyTokens = some Expressions.tailBody.render ∧
  Source.expressionBody "identifier_end" Source.outputBodyTokens = some Expressions.finishBody.render ∧
  Source.expressionBody "name_is" Source.outputBodyTokens = some Expressions.nameBody.render ∧
  Source.expressionBody "equal_name" Source.outputBodyTokens = some Expressions.equalBody.render ∧
  Source.expressionBody "forbidden_name" Source.outputBodyTokens = some Expressions.forbiddenBody.render ∧
  Source.expressionBody "valid_name_state" Source.outputBodyTokens = some Expressions.stateBody.render ∧
  Source.expressionBody "named_suffix_matches" Source.outputBodyTokens = some Expressions.suffixBody.render ∧
  Source.expressionBody "is_member" Source.outputBodyTokens = some Expressions.memberBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "is_letter" "is" Source.outputBodyTokens = some (expectedTokens
    "(Item : Character) return Boolean") ∧
  functionHeader "identifier_tail" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Previous_Underscore : Boolean) return Literal_Position") ∧
  functionHeader "identifier_end" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor) return Literal_Position") ∧
  functionHeader "name_is" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; First, After : Cursor; Word : String) return Boolean") ∧
  functionHeader "equal_name" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Left_First, Left_After, Right_First, Right_After : Cursor) return Boolean") ∧
  functionHeader "forbidden_name" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; First, After : Cursor) return Boolean") ∧
  functionHeader "valid_name_state" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; First, After : Literal_Position) return Boolean") ∧
  functionHeader "named_suffix_matches" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Next_Token : Named_Token_Index; Declared_First, Declared_After : Literal_Position) return Boolean") ∧
  functionHeader "is_member" "is" Source.outputBodyTokens = some (expectedTokens
    "(Source : String) return Boolean")

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

/-- Equation-level composition after the typed interpretation has closed every
callee. The union is exactly the three current productions. -/
theorem equations_current_member_iff
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (namedCalls : Calls) (namedEquations : DefinitionEquations namedCalls) (source : Source) :
    (nullCalls.member source || namedCalls.member source) = true ↔ Current.Member source := by
  simp only [Bool.or_eq_true, Current.Member,
    Silver.Expressions.member_implementation_iff nullCalls nullEquations source,
    implementation_member_iff namedCalls namedEquations source]

/-- Authoritative source checks and the closed arbitrary-callee interpretation
establish membership for the complete current language. -/
theorem authoritative_current_member_iff
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : Expressions.InterpretedSource calls)
    (source : Source) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ((nullCalls.member source || calls.named.member source) = true ↔ Current.Member source) :=
  ⟨Silver.SourceBridge.checked_source, checked_source,
    equations_current_member_iff nullCalls nullEquations calls.named
      (Expressions.interpreted_equations calls sourceEquations) source⟩

/-- The exact admitted source completes the current pipeline under the explicit
external-tool and fixed-library premises. Application obligation correspondence
continues to use the faithful-generation premise and complete native reports. -/
theorem checked_current_pipeline {Artifact : Type} {tools : Current.Tools Artifact}
    (contract : Current.ToolContract tools)
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : Expressions.InterpretedSource calls)
    (source : Source) (accepted : (nullCalls.member source || calls.named.member source) = true) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ∃ artifact steps, Current.Pipeline tools source artifact steps := by
  have bridge := authoritative_current_member_iff nullCalls nullEquations calls sourceEquations source
  exact ⟨bridge.1, bridge.2.1, Current.automatic_pipeline contract (bridge.2.2.mp accepted)⟩

end Silver.Named.SourceBridge
