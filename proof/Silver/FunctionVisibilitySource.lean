module

public import Silver.FunctionVisibilityNative

@[expose] public section

namespace Silver.Compose.FunctionVisibilityNative.SourceChecks
open Silver.SourceBridge

abbrev CheckedTrees : Prop :=
  functionHidesBody.wellFormed = true ∧ functionHidesBody.scoped {catalog := true, word := true} = true ∧
  formalHidesBody.wellFormed = true ∧ formalHidesBody.scoped {state := true, positions := true} = true ∧
  hiddenWordBody.wellFormed = true ∧ hiddenWordBody.scoped {state := true, word := true} = true ∧
  (∀ mark ∈ marks, (hiddenOuterField mark).wellFormed = true ∧ (hiddenOuterField mark).scoped {state := true} = true) ∧
  (∀ mark ∈ marks, (hideNameField mark).wellFormed = true ∧
    (hideNameField mark).scoped {flags := true, positions := true} = true)

theorem checked_trees : CheckedTrees := by decide +kernel

namespace StructuralControls

private def atom : Expr := .functionHides

/-- This language's controls cover mixed logical chains and fixed quantified
operands, including rejection of a malformed child inside an explicit group. -/
private theorem logical_and_quantified_categories :
    (Expr.andThen (.orElse atom atom) atom).wellFormed = false ∧
    (Expr.andThen (.group (.orElse atom atom)) atom).wellFormed = true ∧
    (Expr.or (.orElse atom atom) atom).wellFormed = false ∧
    (Expr.or (.group (.orElse atom atom)) atom).wellFormed = true ∧
    (Expr.orElse atom (.or atom atom)).wellFormed = false ∧
    (Expr.orElse atom (.group (.or atom atom))).wellFormed = true ∧
    (Expr.orElse .catalogNames atom).wellFormed = false ∧
    (Expr.orElse (.group .catalogNames) atom).wellFormed = true ∧
    (Expr.andThen (.group (.orElse atom (.andThen atom atom))) atom).wellFormed = false ∧
    (Expr.orElse (.orElse atom atom) atom).wellFormed = true := by decide +kernel

end StructuralControls

structure Checked (tokens : List String) : Prop where
  trees : CheckedTrees
  functionHides : expressionDeclaration "function_hides" tokens =
    some (functionHidesBody.render, expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Functions.Valid_Metadata (Text, Catalog) and then Word'First = 1 and then Word'Length in 1 .. Max_Source_Length")
  functionHidesHeader : functionHeader "function_hides" "is" tokens =
    some (expectedTokens "(Text : String; Catalog : Functions.Metadata; Word : String) return Boolean")
  formalHides : expressionDeclaration "formal_hides" tokens =
    some (formalHidesBody.render, expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State) and then First <= Text'Last + 1 and then After <= Text'Last + 1")
  formalHidesHeader : functionHeader "formal_hides" "is" tokens =
    some (expectedTokens "(Text : String; State : Parser_State; First, After : Literal_Position) return Boolean")
  hiddenWord : expressionDeclaration "hidden_word" tokens =
    some (hiddenWordBody.render, expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State) and then Word'First = 1 and then Word'Length in 1 .. Max_Source_Length")
  hiddenWordHeader : functionHeader "hidden_word" "is" tokens =
    some (expectedTokens "(Text : String; State : Parser_State; Word : String) return Boolean")
  hiddenOuter : expressionDeclaration "hidden_outer" tokens =
    some (renderMarks hiddenOuterField, expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State)")
  hiddenOuterHeader : functionHeader "hidden_outer" "is" tokens =
    some (expectedTokens "(Text : String; State : Parser_State) return Hidden_Marks")
  hideName : expressionDeclaration "hide_name" tokens =
    some (renderMarks hideNameField, expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then First > 0 and then After > First and then After <= Text'Last + 1")
  hideNameHeader : functionHeader "hide_name" "is" tokens =
    some (expectedTokens "(Text : String; Hiding : Hidden_Marks; First, After : Literal_Position) return Hidden_Marks")

end Silver.Compose.FunctionVisibilityNative.SourceChecks
