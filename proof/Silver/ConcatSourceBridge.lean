import Silver.NamedSourceBridge
import Silver.ConcatExpressions

/-! The new recognizer's actual source expression has a checked typed rendering
and arbitrary-callee interpretation. The Main expression consumes the parser's
ordered event values, rather than selecting values through unverified labels.
The fixed frontend's interpretation of Ada concatenation remains explicit. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Concat.SourceBridge

open Silver.SourceBridge

abbrev ExpressionTranslation : Prop :=
  Expressions.WellFormedTrees ∧
  Source.expressionBody "concatenation_suffix_matches" Source.outputBodyTokens =
    some Expressions.suffixBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "concatenation_suffix_matches" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Next_Token : Concatenation_Token_Index; Declared_First, Declared_After : Literal_Position) return Boolean")

theorem actual_refinement : Refinement := by decide +kernel

structure CheckedSource : Prop where
  named : Named.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  refinement : Refinement
  mainTranslation : Main.composition.render = requiredTokens
  mainPrecedence : Main.composition.initializer.wellFormed = true ∧ Main.composition.output.wellFormed = true

theorem checked_source : CheckedSource where
  named := Named.SourceBridge.checked_source
  expressions := actual_expressions
  refinement := actual_refinement
  mainTranslation := Main.rendered_tokens
  mainPrecedence := Main.checked_precedence

/-- The complete parse supplies the ordered declaration/literal/reference
trace interpreted by this same rendered syntax. Name lookup and all literal
positions are resolved mechanically. Operands are pure: this trace order is a
source decoder, not a claim that Ada mandates operand evaluation order. -/
theorem authoritative_main_correct {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Current.Environment) :
    CheckedSource ∧
    Named.Parsed source Main.composition.render 1 {} program.events ∧
    Main.composition.evaluateEvents program.events = some program.bytes ∧
    Main.composition.execute environment.output program =
      some (Current.execute environment (.outputMain program.bytes)) := by
  refine ⟨checked_source, ?_, evaluation_refines meaning, Current.concat_execution_refines meaning environment⟩
  simpa only [Main.rendered_tokens] using meaning.2

end Silver.Concat.SourceBridge
