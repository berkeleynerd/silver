module

public import Silver.ComposeBooleanDeclarationNative
public import Silver.SourceDeclarations

@[expose] public section

/-! Exact complete ordinary body and contract requirements. This module does
not import the recursive predicate interpreter or assume declaration meaning.
The final source bridge instantiates Checked on the certified full source. -/
namespace Silver.Compose.BooleanDeclarationNative.SourceChecks
open Silver.SourceBridge

/-- Retain every token through the function's own named terminator. -/
def throughEnd (name : String) : List String → Option (List String)
  | [] => none
  | "end" :: actual :: ";" :: rest =>
      if actual == name then some ["end", actual, ";"]
      else (throughEnd name (actual :: ";" :: rest)).map ("end" :: ·)
  | token :: rest => (throughEnd name rest).map (token :: ·)

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

def implHeader : List String := expectedTokens
  "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State"

def specHeader : List String := implHeader ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Boolean_Declaration_At'Result) and then (Boolean_Declaration_At'Result.Position = 0 or else Boolean_Declaration_At'Result.Position > State.Position)"

structure Checked (tokens : List String) : Prop where
  precedence : body.wellFormed = true
  scope : body.scoped {} = true
  body : ordinaryFunction "boolean_declaration_at" tokens = some rendered
  spec : functionHeader "boolean_declaration_at" ";" tokens = some specHeader
  impl : functionHeader "boolean_declaration_at" "is" tokens = some implHeader

end Silver.Compose.BooleanDeclarationNative.SourceChecks
