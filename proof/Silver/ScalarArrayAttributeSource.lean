module

public import Silver.ScalarArrayAttributeNative
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.ScalarExpression.SourceChecks

/-- Retain the complete declaration and statement sequence through the first
matching named terminator. An absent terminator fails extraction. The checked
render contains all intermediate `end if` tokens and no nested declarations. -/
def namedBodyEnd (name : String) : List String → Option (List String)
  | [] => none
  | "end" :: actual :: ";" :: rest =>
      if actual == name then some ["end", actual, ";"]
      else (namedBodyEnd name (actual :: ";" :: rest)).map ("end" :: ·)
  | token :: rest => (namedBodyEnd name rest).map (token :: ·)

/-- Select executable implementations by the complete function header, never
by a matching body substring. A malformed implementation remains in the list
as `none`, so it cannot be silently discarded by the uniqueness check. -/
def imperativeFunctionBodies (name : String) : List String → List (Option (List String))
  | [] => []
  | "function" :: actual :: tokens =>
      let later := imperativeFunctionBodies name (actual :: tokens)
      if actual == name then
        match Silver.SourceBridge.headerEnd 0 tokens with
        | some (header, "is") =>
            let body := tokens.drop (header.length + 1)
            (if body.head? == some "(" then none else namedBodyEnd name body) :: later
        | some (_, ";") => later
        | _ => none :: later
      else later
  | _ :: rest => imperativeFunctionBodies name rest

def imperativeFunctionBody (name : String) (tokens : List String) : Option (List String) :=
  match imperativeFunctionBodies name tokens with
  | [some body] => some body
  | _ => none

end Silver.ScalarExpression.SourceChecks
