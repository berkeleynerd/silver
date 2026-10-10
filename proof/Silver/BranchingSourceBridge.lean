import Silver.ArgumentsSourceBridge
import Silver.BranchingExpressions
import Silver.GuardedExpressions
import Silver.BranchingMain
import Silver.Current

/-! Source correspondence for the eighth production. Its private executable
recognizer refines the displayed normalized suffix expression directly; there
is no separate Is_Branching_Member function. The shared wrapper interpretation,
SPARK refinement proof and Ada frontend/tool premises remain distinct from
the exact source-shape checks. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Branching.SourceBridge
open Silver.SourceBridge

abbrev ExpressionTranslation : Prop :=
  Expressions.WellFormedTrees ∧
  Source.expressionBody "branching_suffix_matches" Source.outputBodyTokens = some Expressions.suffixBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

/-- Retain the complete declared index range, including its terminal sentinel. -/
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

abbrev IndexDeclaration : Prop :=
  subtypeDeclaration "branching_token_index" Source.outputBodyTokens =
    some (expectedTokens "Positive range 1 .. Branching_Required_Tokens'Last + 1")

theorem actual_index_declaration : IndexDeclaration := by decide +kernel

/-- The right-hand side of the actual executable postcondition is the same
typed membership expression interpreted by the whole-language bridge. -/
def acceptanceHeader : List String :=
  expectedTokens "(Source : String) return Boolean with Global => null, Post => (Static => Accepts_Branching'Result =" ++
  ["("] ++ Guarded.Expressions.branchingBody.render ++ [")", ")"]

abbrev Refinement : Prop :=
  functionHeader "branching_suffix_matches" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Next_Token : Branching_Token_Index; Declared_First, Declared_After : Literal_Position) return Boolean") ∧
  functionHeader "branching_suffix_matches" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Next_Token : Branching_Token_Index; Declared_First, Declared_After : Literal_Position) return Boolean with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Declared_First, Declared_After), Subprogram_Variant => (Increases => Next_Token)") ∧
  functionHeader "accepts_branching" ";" Source.outputBodyTokens = some acceptanceHeader ∧
  functionHeader "accepts_branching" "is" Source.outputBodyTokens = some (expectedTokens
    "(Source : String) return Boolean")

theorem actual_refinement : Refinement := by decide +kernel

structure CheckedSource : Prop where
  inherited : Arguments.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  index : IndexDeclaration
  refinement : Refinement
  mainTranslation : Main.composition.render = requiredTokens
  mainPrecedence : Main.composition.initializer.wellFormed = true ∧
    Main.comparisonExpression.wellFormed = true

theorem checked_source : CheckedSource where
  inherited := Arguments.SourceBridge.checked_source
  expressions := actual_expressions
  index := actual_index_declaration
  refinement := actual_refinement
  mainTranslation := Main.rendered_tokens
  mainPrecedence := Main.checked_precedence

/-- This is the actual private recognizer's verified postcondition, not an
extra ghost membership routine or a new report-policy selector. -/
theorem authoritative_branching_member_iff
    (calls : Guarded.Expressions.Calls)
    (sourceEquations : Guarded.Expressions.InterpretedSource calls)
    (acceptsBranching : Source → Bool)
    (provedRecognizer : ∀ source,
      acceptsBranching source = Guarded.Expressions.branchingBody.eval calls {text := source})
    (source : Source) :
    CheckedSource ∧ (acceptsBranching source = true ↔ Member source) := by
  refine ⟨checked_source, ?_⟩
  rw [provedRecognizer, ← sourceEquations.branchingMember]
  exact Guarded.Expressions.interpreted_branching_iff calls sourceEquations source

/-- One typed composition consumes the declaration and all literal/reference
events in source order, then executes the validity guard and selected equality
branch. The unselected branch contributes no output effect. -/
theorem authoritative_main_correct {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Current.Environment) :
    CheckedSource ∧
    Parsed source Main.composition.render 1 {} program.events ∧
    Main.composition.execute environment.output environment.arguments program.events =
      some (Current.execute environment (.branchingMain program)) := by
  refine ⟨checked_source, ?_, Current.branching_execution_refines meaning environment⟩
  simpa only [Main.rendered_tokens] using meaning.2

end Silver.Branching.SourceBridge
