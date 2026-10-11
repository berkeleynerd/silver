import Silver.ConcatSourceBridge
import Silver.AssignmentExpressions

/-! The checked recognizer equations and the typed application composition share
source tokens with their interpretations. The fixed-bound assignment meaning
uses the documented Ada frontend premise; all callee/recursive interpretations
are closed on the SPARK-proved domains rather than inferred from a source pin. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.Assignment.SourceBridge
open Silver.SourceBridge

abbrev ExpressionTranslation : Prop :=
  Expressions.WellFormedTrees ∧
  Source.expressionBody "literal_length" Source.outputLexicalSpecTokens = some Expressions.literalLengthBody.render ∧
  Source.expressionBody "assignment_suffix_matches" Source.outputBodyTokens = some Expressions.suffixBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "assignment_suffix_matches" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Next_Token : Assignment_Token_Index; Declared_First, Declared_After : Literal_Position; Initial_Length : Capacity_Value) return Boolean") ∧
  functionHeader "assignment_suffix_matches" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Next_Token : Assignment_Token_Index; Declared_First, Declared_After : Literal_Position; Initial_Length : Capacity_Value) return Boolean with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Declared_First, Declared_After), Subprogram_Variant => (Increases => Next_Token)") ∧
  functionHeader "is_assignment_member" "is" Source.outputBodyTokens = some (expectedTokens
    "(Source : String) return Boolean") ∧
  functionHeader "is_assignment_member" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Ghost => Static, Global => null") ∧
  functionHeader "accepts_assignment" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Accepts_Assignment'Result = Is_Assignment_Member (Source))")

theorem actual_refinement : Refinement := by decide +kernel

structure CheckedSource : Prop where
  inherited : Concat.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  refinement : Refinement
  mainTranslation : Main.composition.render = requiredTokens

theorem checked_source : CheckedSource where
  inherited := Concat.SourceBridge.checked_source
  expressions := actual_expressions
  refinement := actual_refinement
  mainTranslation := Main.rendered_tokens

/-- The application syntax consumes its ordered declaration, initializer,
assignment target, replacement literal and output reference events. It mutates
one initialized cell without changing the constraint established by its length. -/
theorem authoritative_main_correct {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Current.Environment) :
    CheckedSource ∧
    Parsed source Main.composition.render 1 1 {} 0 program.events ∧
    Main.composition.evaluate program = some program.replacement ∧
    Main.composition.execute environment.output program =
      some (Current.execute environment (.outputMain program.replacement)) := by
  refine ⟨checked_source, ?_, evaluation_refines meaning, Current.assignment_execution_refines meaning environment⟩
  simpa only [Main.rendered_tokens] using meaning.2

end Silver.Assignment.SourceBridge
