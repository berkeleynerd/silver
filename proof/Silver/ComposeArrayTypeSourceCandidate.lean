module

public import Silver.ComposeArrayTypeNative
public import Silver.SourceDeclarations
public import Silver.ReviewedOutputShape
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge

/-- The new native helpers are bound by complete headers, exact typed bodies,
and independent scope/precedence decisions. No parser-model equality is a pin. -/
abbrev ArrayTypeHelperTranslationFor (tokens : List String) : Prop :=
  Expressions.arrayTypeAtBody.wellFormed = true ∧
  Expressions.arrayTypeDeclarationBody.wellFormed = true ∧
  Expressions.arrayTypeAtBody.scoped [("text", .source), ("state", .state), ("position", .number)] = true ∧
  Expressions.arrayTypeDeclarationBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  functionHeader "array_type_at" ";" tokens = some (expectedTokens
    "(Text : String; State : Parser_State; Position : Literal_Position) return Array_Bindings.Type_Count with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State) and then Position <= Text'Last + 1, Post => Array_Type_At'Result <= State.Array_Names.Names.Types.Count") ∧
  functionHeader "array_type_at" "is" tokens = some (expectedTokens
    "(Text : String; State : Parser_State; Position : Literal_Position) return Array_Bindings.Type_Count") ∧
  expressionDeclaration "array_type_at" tokens =
    some (Expressions.arrayTypeAtBody.render, []) ∧
  functionHeader "array_type_declaration_at" ";" tokens = some (expectedTokens
    "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Array_Type_Declaration_At'Result) and then (Array_Type_Declaration_At'Result.Position = 0 or else Array_Type_Declaration_At'Result.Position > State.Position)") ∧
  functionHeader "array_type_declaration_at" "is" tokens = some (expectedTokens
    "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State") ∧
  BooleanDeclarationNative.SourceChecks.ordinaryFunction "array_type_declaration_at" tokens =
    some Expressions.arrayTypeDeclarationBody.render

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

private theorem checked_type_headers :
    functionHeader "array_type_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens
      "(Text : String; State : Parser_State; Position : Literal_Position) return Array_Bindings.Type_Count with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State) and then Position <= Text'Last + 1, Post => Array_Type_At'Result <= State.Array_Names.Names.Types.Count") ∧
    functionHeader "array_type_at" "is" Output.SourceShape.outputImplementation = some (expectedTokens
      "(Text : String; State : Parser_State; Position : Literal_Position) return Array_Bindings.Type_Count") := by
  constructor <;> decide +kernel

private theorem checked_type_body :
    expressionDeclaration "array_type_at" Output.SourceShape.outputImplementation =
      some (Expressions.arrayTypeAtBody.render, []) := by
  decide +kernel

private theorem checked_type_declaration_headers :
    functionHeader "array_type_declaration_at" ";" Output.SourceShape.outputImplementation = some (expectedTokens
      "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Array_Type_Declaration_At'Result) and then (Array_Type_Declaration_At'Result.Position = 0 or else Array_Type_Declaration_At'Result.Position > State.Position)") ∧
    functionHeader "array_type_declaration_at" "is" Output.SourceShape.outputImplementation = some (expectedTokens
      "(Text : String; State : Parser_State; Arguments : Boolean) return Parser_State") := by
  constructor <;> decide +kernel

private theorem checked_type_declaration_body :
    BooleanDeclarationNative.SourceChecks.ordinaryFunction "array_type_declaration_at" Output.SourceShape.outputImplementation =
      some Expressions.arrayTypeDeclarationBody.render := by
  simp only [Expressions.arrayTypeDeclarationBody, StringNative.Body.render,
    StringNative.Command.list, List.foldr, StringNative.guard,
    StringNative.Command.render, StringNative.Command.renderElse]
  decide +kernel

theorem candidate_array_type_helpers :
    ArrayTypeHelperTranslationFor Output.SourceShape.outputImplementation :=
  ⟨Expressions.checked_array_type_precedence.1, Expressions.checked_array_type_precedence.2,
    Expressions.checked_array_type_scope.1, Expressions.checked_array_type_scope.2,
    checked_type_headers.1, checked_type_headers.2, checked_type_body,
    checked_type_declaration_headers.1, checked_type_declaration_headers.2, checked_type_declaration_body⟩

end Silver.Compose.SourceBridge
