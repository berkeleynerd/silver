import Silver.ArgumentsSourceBridge
import Silver.GuardedExpressions
import Silver.GuardedMain
import Silver.Current

/-! Source correspondence for the current six-form recognizer and its report
policy selector. Checked typed expressions, arbitrary-callee interpretation,
and applied recursion uniqueness close the new helper chain. The SPARK-proved
imperative contracts and trusted Ada frontend remain explicit premises. Main's
rendered syntax consumes the parser's ordered events before interpretation. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Guarded.SourceBridge
open Silver.SourceBridge

abbrev ExpressionTranslation : Prop :=
  Expressions.WellFormedTrees ∧
  Source.expressionBody "decimal_tail" Source.outputBodyTokens = some Expressions.decimalTailBody.render ∧
  Source.expressionBody "decimal_at" Source.outputBodyTokens = some Expressions.decimalAtBody.render ∧
  Source.expressionBody "literal_length" Source.outputBodyTokens = some Expressions.literalLengthBody.render ∧
  Source.expressionBody "guarded_suffix_matches" Source.outputBodyTokens = some Expressions.suffixBody.render ∧
  Source.expressionBody "is_member" Source.outputBodyTokens = some Expressions.memberBody.render ∧
  Source.expressionBody "is_guarded_member" Source.outputBodyTokens = some Expressions.guardedBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

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

abbrev NumericDeclarations : Prop :=
  subtypeDeclaration "capacity_value" Source.outputBodyTokens =
    some (expectedTokens "Natural range 0 .. Max_Source_Length") ∧
  recordDeclaration "decimal_result" Source.outputBodyTokens =
    some (expectedTokens "record After : Literal_Position; Value : Capacity_Value; end record") ∧
  Source.declaration "invalid_decimal" Source.outputBodyTokens =
    some (expectedTokens "constant Decimal_Result := (After => 0, Value => 0)") ∧
  subtypeDeclaration "guarded_token_index" Source.outputBodyTokens =
    some (expectedTokens "Positive range 1 .. Guarded_Required_Tokens'Last + 1")

theorem actual_numeric_declarations : NumericDeclarations := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "decimal_tail" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Value : Capacity_Value) return Decimal_Result") ∧
  functionHeader "decimal_at" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor) return Decimal_Result") ∧
  functionHeader "literal_length" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor) return Capacity_Value") ∧
  functionHeader "guarded_suffix_matches" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Next_Token : Guarded_Token_Index; Declared_First, Declared_After : Literal_Position; Capacity, Decoration_Length : Capacity_Value) return Boolean") ∧
  functionHeader "is_member" "is" Source.outputBodyTokens = some (expectedTokens
    "(Source : String) return Boolean") ∧
  functionHeader "is_guarded_member" "is" Source.outputBodyTokens = some (expectedTokens
    "(Source : String) return Boolean") ∧
  functionHeader "accepts_guarded" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Accepts_Guarded'Result = Is_Guarded_Member (Source))") ∧
  functionHeader "accepts" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Accepts'Result = Is_Member (Source))")

theorem actual_refinement : Refinement := by decide +kernel

/-- These verified source preconditions are exactly the domains used by the
arbitrary-callee recursive interpretation. Machine arithmetic refinement still
uses the fixed frontend and the complete compiler SPARK proof. -/
abbrev DecimalTailContract : Prop :=
  functionHeader "decimal_tail" ";" Source.outputBodyTokens = some (expectedTokens "(Text : String; Position : Cursor; Value : Capacity_Value) return Decimal_Result with Ghost => Static, Global => null," ++
    expectedTokens "Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1, Post =>" ++
    expectedTokens "Decimal_Tail'Result.After = 0 or else Decimal_Tail'Result.After in Position .. Text'Last + 1, Subprogram_Variant =>" ++
    expectedTokens "(Decreases => (Text'Last + 1) - Position)")

theorem actual_decimal_tail_contract : DecimalTailContract := rfl

abbrev DecimalAtContract : Prop :=
  functionHeader "decimal_at" ";" Source.outputBodyTokens = some (expectedTokens "(Text : String; Position : Cursor) return Decimal_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and" ++
    expectedTokens "then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1, Post => Decimal_At'Result.After = 0 or" ++
    expectedTokens "else Decimal_At'Result.After in Position + 1 .. Text'Last + 1")

theorem actual_decimal_at_contract : DecimalAtContract := rfl

abbrev LiteralLengthContract : Prop :=
  functionHeader "literal_length" ";" Source.outputBodyTokens = some (expectedTokens "(Text : String; Position : Cursor) return Capacity_Value with Ghost => Static, Global => null, Pre => Text'First = 1 and" ++
    expectedTokens "then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1, Post => Literal_Length'Result <=" ++
    expectedTokens "(Text'Last + 1) - Position, Subprogram_Variant => (Decreases => (Text'Last + 1) - Position)")

theorem actual_literal_length_contract : LiteralLengthContract := rfl

abbrev SuffixContract : Prop :=
  functionHeader "guarded_suffix_matches" ";" Source.outputBodyTokens = some (expectedTokens "(Text : String; Position : Cursor; Next_Token : Guarded_Token_Index; Declared_First, Declared_After : Literal_Position;" ++
    expectedTokens "Capacity, Decoration_Length : Capacity_Value) return Boolean with Ghost => Static, Global => null, Pre => Text'First = 1" ++
    expectedTokens "and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Name_State (Text," ++
    expectedTokens "Declared_First, Declared_After), Subprogram_Variant => (Increases => Next_Token)")


theorem actual_suffix_contract : SuffixContract := rfl

abbrev HelperContracts : Prop := DecimalTailContract ∧ DecimalAtContract ∧ LiteralLengthContract ∧ SuffixContract

theorem actual_helper_contracts : HelperContracts :=
  ⟨actual_decimal_tail_contract, actual_decimal_at_contract, actual_literal_length_contract, actual_suffix_contract⟩

structure CheckedSource : Prop where
  inherited : Arguments.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  numeric : NumericDeclarations
  refinement : Refinement
  helperContracts : HelperContracts
  mainTranslation : Main.composition.render = requiredTokens
  mainPrecedence : Main.composition.initializer.wellFormed = true ∧
    Main.guardExpression.wellFormed = true ∧ Main.outputExpression.wellFormed = true

theorem checked_source : CheckedSource where
  inherited := Arguments.SourceBridge.checked_source
  expressions := actual_expressions
  numeric := actual_numeric_declarations
  refinement := actual_refinement
  helperContracts := actual_helper_contracts
  mainTranslation := Main.rendered_tokens
  mainPrecedence := Main.checked_precedence

theorem authoritative_main_correct {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Current.Environment) :
    CheckedSource ∧
    Parsed source Main.composition.render 1 1 {} 0 0 program.events ∧
    Main.composition.execute environment.output environment.arguments program.events =
      some (Current.execute environment (.guardedMain program)) := by
  refine ⟨checked_source, ?_, Current.guarded_execution_refines meaning environment⟩
  simpa only [Main.rendered_tokens] using meaning.2

theorem authoritative_current_member_iff
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : Expressions.InterpretedSource calls)
    (source : Source) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ((nullCalls.member source || calls.member source) = true ↔ Current.Member source) := by
  refine ⟨Silver.SourceBridge.checked_source, checked_source, ?_⟩
  simp only [Bool.or_eq_true, Current.Member,
    Silver.Expressions.member_implementation_iff nullCalls nullEquations source,
    Expressions.interpreted_member_iff calls sourceEquations source]

/-- The report selector is the actual executable Accepts_Guarded function,
related to its ghost equation by the displayed, GNATprove-verified contract. -/
theorem authoritative_guarded_member_iff
    (calls : Expressions.Calls) (sourceEquations : Expressions.InterpretedSource calls)
    (acceptsGuarded : Source → Bool)
    (provedSelector : ∀ source, acceptsGuarded source = calls.guarded source)
    (source : Source) :
    CheckedSource ∧ (acceptsGuarded source = true ↔ Member source) := by
  refine ⟨checked_source, ?_⟩
  rw [provedSelector, Expressions.interpreted_guarded_iff calls sourceEquations]

theorem authoritative_executable_member_iff
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : Expressions.InterpretedSource calls)
    (acceptsNull acceptsOutput : Source → Bool)
    (provedNull : ∀ source, acceptsNull source = nullCalls.member source)
    (provedOutput : ∀ source, acceptsOutput source = calls.member source)
    (source : Source) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ((acceptsNull source || acceptsOutput source) = true ↔ Current.Member source) := by
  rw [provedNull, provedOutput]
  exact authoritative_current_member_iff nullCalls nullEquations calls sourceEquations source

/-- Faithful generation, complete report auditing and completion of the pinned
tools on the bounded range fragment remain explicit ToolContract premises. -/
theorem checked_current_pipeline {Artifact : Type} {tools : Current.Tools Artifact}
    (contract : Current.ToolContract tools)
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : Expressions.InterpretedSource calls)
    (source : Source) (accepted : (nullCalls.member source || calls.member source) = true) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ∃ artifact steps, Current.Pipeline tools source artifact steps := by
  have bridge := authoritative_current_member_iff nullCalls nullEquations calls sourceEquations source
  exact ⟨bridge.1, bridge.2.1, Current.automatic_pipeline contract (bridge.2.2.mp accepted)⟩

/-- Compose the executable recognizer contracts with the same conditional
pipeline theorem; acceptance is never inferred from a successful prover exit. -/
theorem checked_executable_pipeline {Artifact : Type} {tools : Current.Tools Artifact}
    (contract : Current.ToolContract tools)
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : Expressions.InterpretedSource calls)
    (acceptsNull acceptsOutput : Source → Bool)
    (provedNull : ∀ source, acceptsNull source = nullCalls.member source)
    (provedOutput : ∀ source, acceptsOutput source = calls.member source)
    (source : Source) (accepted : (acceptsNull source || acceptsOutput source) = true) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ∃ artifact steps, Current.Pipeline tools source artifact steps := by
  have bridge := authoritative_executable_member_iff nullCalls nullEquations calls sourceEquations
    acceptsNull acceptsOutput provedNull provedOutput source
  exact ⟨bridge.1, bridge.2.1, Current.automatic_pipeline contract (bridge.2.2.mp accepted)⟩

end Silver.Guarded.SourceBridge
