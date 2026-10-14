module

public import Silver.SourceLexer

@[expose] public section

/-! The existing unique-declaration extractors, separated from their source
checks so each helper bridge can import only its own source certificates. -/
namespace Silver.SourceBridge

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

/-- The existing expression-body reader expects an unqualified return type.
This narrowly handles the qualified path-library record results used here. -/
def qualifiedExpressionBodies (name : String) : List String → List (List String)
  | [] => []
  | "function" :: actual :: tokens =>
    let later := qualifiedExpressionBodies name (actual :: tokens)
    if actual == name then
      match tokens.dropWhile (· != "return") with
      | "return" :: _package :: "." :: _resultType :: "is" :: "(" :: expr =>
        match Source.balanced 1 expr with
        | some (body, ";" :: _) => body :: later
        | _ => later
      | _ => later
    else later
  | _ :: tokens => qualifiedExpressionBodies name tokens

def qualifiedExpressionBody (name : String) (tokens : List String) : Option (List String) :=
  match qualifiedExpressionBodies name tokens with
  | [body] => some body
  | _ => none

end Silver.SourceBridge

namespace Silver.Lexical.SourceBridge

/-- Unique subtype declaration lookup, retaining its entire range expression. -/
def subtypeDeclarations (name : String) : List String → List (List String)
  | [] => []
  | "subtype" :: actual :: "is" :: tokens =>
      let later := subtypeDeclarations name (actual :: "is" :: tokens)
      if actual == name then
        match Source.declarationEnd 0 tokens with
        | some body => body :: later
        | none => later
      else later
  | _ :: tokens => subtypeDeclarations name tokens

def subtypeDeclaration (name : String) (tokens : List String) : Option (List String) :=
  match subtypeDeclarations name tokens with
  | [body] => some body
  | _ => none

/-- Record fields cannot contain a nested record declaration in this subset.
Retain every token through the matching fixed record terminator. -/
def recordEnd : List String → Option (List String)
  | [] => none
  | "end" :: "record" :: ";" :: _ => some ["end", "record"]
  | token :: rest => (recordEnd rest).map (token :: ·)

def recordDeclarations (name : String) : List String → List (List String)
  | [] => []
  | "type" :: actual :: "is" :: "record" :: tokens =>
      let later := recordDeclarations name (actual :: "is" :: "record" :: tokens)
      if actual == name then
        match recordEnd tokens with
        | some body => ("record" :: body) :: later
        | none => later
      else later
  | _ :: tokens => recordDeclarations name tokens

def recordDeclaration (name : String) (tokens : List String) : Option (List String) :=
  match recordDeclarations name tokens with
  | [body] => some body
  | _ => none

end Silver.Lexical.SourceBridge
