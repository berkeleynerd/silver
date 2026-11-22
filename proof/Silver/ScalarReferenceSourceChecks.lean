module

public import Silver.ScalarReferenceNative
public import Silver.ScalarArrayAttributeNative
public import Silver.SourceDeclarations
public import Silver.ScalarExpressionSpecCertificate
public import Silver.ScalarExpressionBodyCertificate
import all Init.Data.Repr

@[expose] public section

namespace Silver.ScalarExpression.ReferenceSourceChecks
open Silver.SourceBridge Silver.Lexical.SourceBridge

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

def tokens (text : String) : List String := (Source.lexLine text).getD []

def header : List String := tokens
  "(Text : String; Position : Literal_Position) return Name_Reference"

def contract : List String := header ++ tokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1, Post => Valid_Name_State (Text, Read_Reference'Result.First, Read_Reference'Result.After) and then Valid_Name_State (Text, Read_Reference'Result.Qualifier_First, Read_Reference'Result.Qualifier_After) and then (Read_Reference'Result.After = 0 or else (Read_Reference'Result.First > 0 and then Read_Reference'Result.First < Read_Reference'Result.After and then Read_Reference'Result.After in Position + 1 .. Text'Last + 1))"

structure Checked (spec body : List String) : Prop where
  recordShape : recordDeclaration "name_reference" spec = some (tokens
    "record First, After, Qualifier_First, Qualifier_After : Literal_Position := 0; end record")
  invalid : Source.declaration "invalid_reference" spec = some (tokens
    "constant Name_Reference := (others => 0)")
  specification : functionHeader "read_reference" ";" spec = some contract
  implementation : functionHeader "read_reference" "is" body = some header
  bodyShape : Source.expressionBody "read_reference" body = some Native.referenceBody.render
  precedence : Native.referenceBody.wellFormed = true
  scope : Native.referenceBody.scoped [("text", .source), ("position", .number)] = true

theorem actual_reference : Checked Source.scalarExpressionSpecTokens Source.scalarExpressionBodyTokens := by
  constructor <;> decide +kernel

end Silver.ScalarExpression.ReferenceSourceChecks
