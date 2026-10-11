import Silver.NamedSourceBridge
import Silver.ArgumentsRuntime
import Silver.ArgumentsExpressions

/-! Shared argument-name helpers and complete argument-wrapper correspondence.
The composed Main syntax and interpretation are checked separately. This module
retains the authoritative lexical expressions, runtime declarations, GNAT imports
and whole argument-body renderer. Ada frontend interpretation, immutable argv
and the GNAT ABI remain explicit premises. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Arguments.SourceBridge

open Silver.SourceBridge

abbrev ExpressionTranslation : Prop :=
  Expressions.argumentForbiddenBody.wellFormed = true ∧
  Source.expressionBody "is_letter" Source.outputLexicalSpecTokens = some Expressions.letterBody.render ∧
  Source.expressionBody "identifier_tail" Source.outputLexicalSpecTokens = some Expressions.tailBody.render ∧
  Source.expressionBody "identifier_end" Source.outputLexicalSpecTokens = some Expressions.finishBody.render ∧
  Source.expressionBody "name_is" Source.outputLexicalSpecTokens = some Expressions.nameBody.render ∧
  Source.expressionBody "equal_name" Source.outputLexicalSpecTokens = some Expressions.equalBody.render ∧
  Source.expressionBody "forbidden_name" Source.outputLexicalSpecTokens = some Expressions.forbiddenBody.render ∧
  Source.expressionBody "valid_name_state" Source.outputLexicalSpecTokens = some Expressions.stateBody.render ∧
  Source.expressionBody "forbidden_argument_name" Source.outputLexicalSpecTokens = some Expressions.argumentForbiddenBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "forbidden_argument_name" "is" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; First, After : Cursor) return Boolean") ∧
  functionHeader "token_at" ";" Source.outputLexicalSpecTokens = some (expectedTokens
    "(Text : String; Position : Cursor; Word : String; Is_Word : Boolean) return Boolean with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Word'First = 1 and then Word'Length in 1 .. 16")

theorem actual_refinement : Refinement := by decide +kernel

abbrev RuntimeDeclarations : Prop :=
  functionHeader "input_is_valid" ";" Source.argumentsSpecTokens = some (expectedTokens
    "return Boolean with Global => null") ∧
  functionHeader "first_or_default" ";" Source.argumentsSpecTokens = some (expectedTokens
    "(Default : String) return String with Global => null, Post => First_Or_Default'Result'First = 1 and then First_Or_Default'Result'Length <= Silver_IO.Max_Length and then (for all Ch of First_Or_Default'Result => Character'Pos (Ch) in 32 .. 126)") ∧
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

end Silver.Arguments.SourceBridge
