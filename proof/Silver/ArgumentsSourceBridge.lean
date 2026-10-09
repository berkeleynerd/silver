import Silver.NamedSourceBridge
import Silver.ArgumentsExpressions

/-! The typed Main composition renders to the admitted token sequence and is
interpreted by Arguments.execute. Recognizer expressions, owned argument-wrapper
statements and GNAT imports are checked against their authoritative sources.
Current composes the model refinements; this bridge retains their source facts
alongside them. Ada frontend interpretation, immutable argv and the GNAT ABI
remain explicit premises; token-shape equality alone proves no implementation. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Arguments.SourceBridge

open Silver.SourceBridge

abbrev ExpressionTranslation : Prop :=
  Expressions.WellFormedTrees ∧
  Source.expressionBody "is_letter" Source.outputBodyTokens = some Expressions.letterBody.render ∧
  Source.expressionBody "identifier_tail" Source.outputBodyTokens = some Expressions.tailBody.render ∧
  Source.expressionBody "identifier_end" Source.outputBodyTokens = some Expressions.finishBody.render ∧
  Source.expressionBody "name_is" Source.outputBodyTokens = some Expressions.nameBody.render ∧
  Source.expressionBody "equal_name" Source.outputBodyTokens = some Expressions.equalBody.render ∧
  Source.expressionBody "forbidden_name" Source.outputBodyTokens = some Expressions.forbiddenBody.render ∧
  Source.expressionBody "valid_name_state" Source.outputBodyTokens = some Expressions.stateBody.render ∧
  Source.expressionBody "forbidden_argument_name" Source.outputBodyTokens = some Expressions.argumentForbiddenBody.render ∧
  Source.expressionBody "argument_suffix_matches" Source.outputBodyTokens = some Expressions.suffixBody.render ∧
  Source.expressionBody "is_member" Source.outputBodyTokens = some Expressions.memberBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "forbidden_argument_name" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; First, After : Cursor) return Boolean") ∧
  functionHeader "argument_suffix_matches" "is" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Next_Token : Argument_Token_Index; Declared_First, Declared_After : Literal_Position) return Boolean") ∧
  functionHeader "token_at" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Word : String; Is_Word : Boolean) return Boolean with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Word'First = 1 and then Word'Length in 1 .. 16")

theorem actual_refinement : Refinement := by decide +kernel

abbrev RuntimeDeclarations : Prop :=
  functionHeader "input_is_valid" ";" Source.argumentsSpecTokens = some (expectedTokens
    "return Boolean with Global => null") ∧
  functionHeader "first_or_default" ";" Source.argumentsSpecTokens = some (expectedTokens
    "(Default : String) return String with Global => null, Post => First_Or_Default'Result'Length <= Silver_IO.Max_Length and then (for all Ch of First_Or_Default'Result => Character'Pos (Ch) in 32 .. 126)") ∧
  Output.SourceBridge.procedureHeader "reject" Source.argumentsSpecTokens = some (expectedTokens
    "with Global => (In_Out => Ada.Text_IO.File_System), Always_Terminates") ∧
  functionHeader "argument_count" ";" Source.runtimeSpecTokens = some (expectedTokens
    "return Natural with Import, Convention => Ada, External_Name => \"ada__command_line__argument_count\", Global => null") ∧
  functionHeader "argument" ";" Source.runtimeSpecTokens = some (expectedTokens
    "(Number : Positive) return String with Import, Convention => Ada, External_Name => \"ada__command_line__argument\", Global => null, Pre => Number <= Argument_Count") ∧
  Output.SourceBridge.procedureHeader "set_exit_status" Source.runtimeSpecTokens = some (expectedTokens
    "(Code : Ada.Command_Line.Exit_Status) with Import, Convention => C, External_Name => \"__gnat_set_exit_status\", Global => (Output => Exit_State), Always_Terminates")

theorem actual_runtime_declarations : RuntimeDeclarations := by decide +kernel

theorem actual_runtime_translation : Source.argumentsBodyTokens = Runtime.renderedBody := by decide +kernel

abbrev CompleteShape : Prop :=
  Source.argumentsSpecTokens = Output.SourceShape.argumentsSpecification ∧
  Source.argumentsBodyTokens = Output.SourceShape.argumentsImplementation ∧
  Source.runtimeSpecTokens = Output.SourceShape.runtimeSpecification

theorem actual_complete_shape : CompleteShape := ⟨rfl, rfl, rfl⟩

structure CheckedSource : Prop where
  named : Named.SourceBridge.CheckedSource
  argumentsSpecification : Source.lex Source.argumentsSpec = some Source.argumentsSpecTokens
  argumentsImplementation : Source.lex Source.argumentsBody = some Source.argumentsBodyTokens
  runtimeSpecification : Source.lex Source.runtimeSpec = some Source.runtimeSpecTokens
  shape : CompleteShape
  expressions : ExpressionTranslation
  refinement : Refinement
  runtimeDeclarations : RuntimeDeclarations
  runtimeTranslation : Source.argumentsBodyTokens = Runtime.renderedBody
  mainTranslation : Main.composition.render = requiredTokens

theorem checked_source : CheckedSource where
  named := Named.SourceBridge.checked_source
  argumentsSpecification := Source.argumentsSpecTokens_correct
  argumentsImplementation := Source.argumentsBodyTokens_correct
  runtimeSpecification := Source.runtimeSpecTokens_correct
  shape := actual_complete_shape
  expressions := actual_expressions
  refinement := actual_refinement
  runtimeDeclarations := actual_runtime_declarations
  runtimeTranslation := actual_runtime_translation
  mainTranslation := Main.rendered_tokens

/-- The same typed composition supplies the tokens parsed from every admitted
Main and the interpreter refined to Current. No independently handwritten branch
reading is substituted between membership and execution. The wrapper refinement
and trusted frontend/tool premises remain separate explicit parts of the claim. -/
theorem authoritative_main_correct {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Current.Environment) :
    CheckedSource ∧
    Parsed source Main.composition.render 1 {}
      [.declaration program.declared, .literal program.defaultValue, .reference program.reference] ∧
    Main.composition.execute environment.output environment.arguments program =
      some (Current.execute environment (.argumentMain program.defaultValue)) := by
  refine ⟨checked_source, ?_, Current.argument_execution_refines meaning environment⟩
  simpa only [Main.rendered_tokens] using meaning.2

/-- Whole-body statement interpretation refines the independent argument cases
and ordinary Main completion for every immutable argument vector and default. -/
theorem authoritative_argument_runtime_correct (environment : Output.Runtime.Environment)
    (arguments : Runtime.Arguments) (defaultValue : Source) :
    CheckedSource ∧
    Runtime.validityProgram.execute ⟨arguments, defaultValue, none⟩ = .returned (Runtime.inputIsValid arguments) ∧
    Runtime.initializerProgram.execute ⟨arguments, defaultValue, none⟩ = .returned (Runtime.firstOrDefault defaultValue arguments) ∧
    Runtime.executeMain environment arguments defaultValue =
      some (if Runtime.inputIsValid arguments then
        Runtime.outputMain environment (Runtime.firstOrDefault defaultValue arguments) else ⟨1, []⟩) :=
  ⟨checked_source, Runtime.validity_refines arguments defaultValue,
    Runtime.initializer_refines arguments defaultValue, Runtime.main_refines environment arguments defaultValue⟩

theorem authoritative_current_member_iff
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : Expressions.InterpretedSource calls)
    (source : Source) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ((nullCalls.member source || calls.arguments.member source) = true ↔ Current.Member source) := by
  refine ⟨Silver.SourceBridge.checked_source, checked_source, ?_⟩
  simp only [Bool.or_eq_true, Current.Member,
    Silver.Expressions.member_implementation_iff nullCalls nullEquations source,
    implementation_member_iff calls.arguments (Expressions.interpreted_equations calls sourceEquations) source]

/-- Faithful generation and verification of the fixed six-file library set
remain explicit tool premises, with source identity checked by the driver. -/
theorem checked_current_pipeline {Artifact : Type} {tools : Current.Tools Artifact}
    (contract : Current.ToolContract tools)
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : Expressions.InterpretedSource calls)
    (source : Source) (accepted : (nullCalls.member source || calls.arguments.member source) = true) :
    Silver.SourceBridge.CheckedSource ∧ CheckedSource ∧
      ∃ artifact steps, Current.Pipeline tools source artifact steps := by
  have bridge := authoritative_current_member_iff nullCalls nullEquations calls sourceEquations source
  exact ⟨bridge.1, bridge.2.1, Current.automatic_pipeline contract (bridge.2.2.mp accepted)⟩

end Silver.Arguments.SourceBridge
