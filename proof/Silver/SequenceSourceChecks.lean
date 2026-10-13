module

public import Silver.LexicalSourceBridge
public import Silver.SequenceExpressions
import all Init.Data.Repr

@[expose] public section

namespace Silver.Sequence.SourceBridge
open Silver.SourceBridge
open Silver.Sequence.Expressions

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

def tokenName : Token → String
  | .helper token => Compose.Expressions.tokenName token
  | .statements => "statements"

def formName (form : Form) : String := Compose.Expressions.formName form.helper

def tokensBody : List String := ["case", "form", "is"] ++
  List.flatten ((allForms.map fun form => ["when", formName form, "=>", "("] ++
    List.flatten ((form.tokens.map (fun token => [tokenName token])).intersperse [","]) ++ [")"]).intersperse [","])

abbrev Bodies : Prop :=
  Source.expressionBody "tokens" Source.outputBodyTokens = some tokensBody ∧
  Source.expressionBody "scan_token" Source.outputBodyTokens = some (scanTokenBody.render.drop 1 |>.dropLast) ∧
  Named.SourceBridge.ordinaryFunction "basic_statement_at" Source.outputBodyTokens =
    some (basicBody.functionTokens "basic_statement_at") ∧
  Source.expressionBody "basic_tail" Source.outputBodyTokens = some basicTailBody.render ∧
  Named.SourceBridge.ordinaryFunction "conditional_at" Source.outputBodyTokens =
    some (conditionalBody.functionTokens "conditional_at") ∧
  Source.expressionBody "statement_at" Source.outputBodyTokens = some statementBody.render ∧
  Source.expressionBody "statements_tail" Source.outputBodyTokens = some statementsTailBody.render ∧
  Source.expressionBody "scan_step" Source.outputBodyTokens = some scanStepBody.render ∧
  Source.expressionBody "scan_suffix" Source.outputBodyTokens = some suffixBody.render ∧
  Source.expressionBody "form_result" Source.outputBodyTokens = some formBody.render ∧
  Source.expressionBody "is_member" Source.outputBodyTokens = some memberBody.render ∧
  Source.expressionBody "has_arguments" Source.outputBodyTokens = some argumentsBody.render ∧
  Source.expressionBody "has_assignment" Source.outputBodyTokens = some assignmentBody.render ∧
  Source.expressionBody "has_output" Source.outputBodyTokens = some outputBody.render

private theorem body_01 : Source.expressionBody "tokens" Source.outputBodyTokens = some tokensBody := by decide +kernel
private theorem body_02 : Source.expressionBody "scan_token" Source.outputBodyTokens = some (scanTokenBody.render.drop 1 |>.dropLast) := by
  simp only [scanTokenBody, Expr.render]
  decide +kernel
private theorem body_03 : Named.SourceBridge.ordinaryFunction "basic_statement_at" Source.outputBodyTokens = some (basicBody.functionTokens "basic_statement_at") := by
  simp only [Command.functionTokens, basicBody, guardReturn, finish, Command.steps, BasicKind.tokens, Compose.outputTokens, Compose.assignmentTokens, List.foldr_cons, List.foldr_nil]
  simp only [Command.render, Command.renderElse, Condition.render, Expr.render]
  decide +kernel
private theorem body_04 : Source.expressionBody "basic_tail" Source.outputBodyTokens = some basicTailBody.render := by
  simp only [basicTailBody, Expr.render, Expr.renderElse, Condition.render]
  decide +kernel
private theorem body_05 : Named.SourceBridge.ordinaryFunction "conditional_at" Source.outputBodyTokens = some (conditionalBody.functionTokens "conditional_at") := by
  simp only [Command.functionTokens, conditionalBody, finish, guardReturn, Command.steps, Compose.equalityTokens, Compose.endIfTokens, List.foldr_cons, List.foldr_nil]
  simp only [Command.render, Command.renderElse, Condition.render, Expr.render]
  decide +kernel
private theorem body_06 : Source.expressionBody "statement_at" Source.outputBodyTokens = some statementBody.render := by
  simp only [statementBody, Expr.render, Expr.renderElse, Condition.render]
  decide +kernel
private theorem body_07 : Source.expressionBody "statements_tail" Source.outputBodyTokens = some statementsTailBody.render := by
  simp only [statementsTailBody, Expr.render, Expr.renderElse, Condition.render]
  decide +kernel
private theorem body_08 : Source.expressionBody "scan_step" Source.outputBodyTokens = some scanStepBody.render := by
  simp only [scanStepBody, Expr.render, Expr.renderElse, Condition.render]
  decide +kernel
private theorem body_09 : Source.expressionBody "scan_suffix" Source.outputBodyTokens = some suffixBody.render := by
  simp only [suffixBody, Expr.render, Expr.renderElse, Condition.render]
  decide +kernel
private theorem body_10 : Source.expressionBody "form_result" Source.outputBodyTokens = some formBody.render := by
  simp only [formBody, Expr.render, Expr.renderElse, Condition.render]
  decide +kernel
private theorem body_11 : Source.expressionBody "is_member" Source.outputBodyTokens = some memberBody.render := by decide +kernel
private theorem body_12 : Source.expressionBody "has_arguments" Source.outputBodyTokens = some argumentsBody.render := by decide +kernel
private theorem body_13 : Source.expressionBody "has_assignment" Source.outputBodyTokens = some assignmentBody.render := by decide +kernel
private theorem body_14 : Source.expressionBody "has_output" Source.outputBodyTokens = some outputBody.render := by decide +kernel

theorem actual_bodies : Bodies :=
  ⟨body_01, body_02, body_03, body_04, body_05, body_06, body_07,
    body_08, body_09, body_10, body_11, body_12, body_13, body_14⟩

def listRefinement (name : String) (body : Expr) : List String :=
  expectedTokens "( text : string ; scan : scan_result ; stop : token_kind ) return scan_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , scan . state ) , post => ( static => valid_state ( text ," ++
  [name, "'", "result", ".", "state", ")", "and", "then", name, "'", "result", "="] ++ body.render ++ [")"]

abbrev Refinements : Prop :=
  functionHeader "read_basic_statements" ";" Source.outputBodyTokens = some (listRefinement "read_basic_statements" readBasicBody) ∧
  functionHeader "read_statements" ";" Source.outputBodyTokens = some (listRefinement "read_statements" readStatementsBody) ∧
  functionHeader "read_form" ";" Source.outputBodyTokens = some (expectedTokens
    "( Source : String; Form : Form_Kind) return Scan_Result with Global => null, Post => (Static => Read_Form'Result = Form_Result (Source, Form))") ∧
  functionHeader "accepts" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Accepts'Result = Is_Member (Source))") ∧
  functionHeader "uses_arguments" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Uses_Arguments'Result = Has_Arguments (Source))") ∧
  functionHeader "uses_assignment" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Uses_Assignment'Result = Has_Assignment (Source))") ∧
  functionHeader "uses_output" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Uses_Output'Result = Has_Output (Source))")

private theorem refinement_01 : functionHeader "read_basic_statements" ";" Source.outputBodyTokens = some (listRefinement "read_basic_statements" readBasicBody) := by
  simp only [listRefinement, readBasicBody, Expr.render]
  decide +kernel
private theorem refinement_02 : functionHeader "read_statements" ";" Source.outputBodyTokens = some (listRefinement "read_statements" readStatementsBody) := by
  simp only [listRefinement, readStatementsBody, Expr.render]
  decide +kernel
private theorem refinement_03 : functionHeader "read_form" ";" Source.outputBodyTokens = some (expectedTokens "( Source : String; Form : Form_Kind) return Scan_Result with Global => null, Post => (Static => Read_Form'Result = Form_Result (Source, Form))") := by decide +kernel
private theorem refinement_04 : functionHeader "accepts" ";" Source.outputSpecTokens = some (expectedTokens "(Source : String) return Boolean with Global => null, Post => (Static => Accepts'Result = Is_Member (Source))") := by decide +kernel
private theorem refinement_05 : functionHeader "uses_arguments" ";" Source.outputSpecTokens = some (expectedTokens "(Source : String) return Boolean with Global => null, Post => (Static => Uses_Arguments'Result = Has_Arguments (Source))") := by decide +kernel
private theorem refinement_06 : functionHeader "uses_assignment" ";" Source.outputSpecTokens = some (expectedTokens "(Source : String) return Boolean with Global => null, Post => (Static => Uses_Assignment'Result = Has_Assignment (Source))") := by decide +kernel
private theorem refinement_07 : functionHeader "uses_output" ";" Source.outputSpecTokens = some (expectedTokens "(Source : String) return Boolean with Global => null, Post => (Static => Uses_Output'Result = Has_Output (Source))") := by decide +kernel

theorem actual_refinements : Refinements :=
  ⟨refinement_01, refinement_02, refinement_03, refinement_04, refinement_05, refinement_06, refinement_07⟩

abbrev Declarations : Prop :=
  Lexical.SourceBridge.recordDeclaration "scan_result" Source.outputBodyTokens = some (expectedTokens
    "record State : Parser_State; Assigned, Output : Boolean; end record") ∧
  Source.declaration "initial_scan" Source.outputBodyTokens = some (expectedTokens
    "constant Scan_Result := (State => Initial_State, Assigned => False, Output => False)") ∧
  Source.declaration "invalid_scan" Source.outputBodyTokens = some (expectedTokens
    "constant Scan_Result := (State => Invalid_State, Assigned => False, Output => False)")

theorem actual_declarations : Declarations := by decide +kernel

/-- Native pre/postcondition shapes that supply all range and progress facts
used by the recursive source interpretation. No semantic denotation is a range
premise. List adapters additionally carry their exact result equations above. -/
def rangeHeader (name parameters : String) (ghost progress tail : Bool) : List String :=
  expectedTokens parameters ++ expectedTokens "return Scan_Result with" ++
    (if ghost then expectedTokens "Ghost => Static," else []) ++
    expectedTokens "Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Scan.State), Post => Valid_State (Text," ++
    [name, "'", "result", ".", "state", ")"] ++
    (if progress then expectedTokens "and then (" ++ [name, "'", "result", ".", "state", ".", "position"] ++
      expectedTokens "= 0 or else" ++ [name, "'", "result", ".", "state", ".", "position"] ++
      expectedTokens "> Scan.State.Position)" else []) ++
    (if tail then expectedTokens ", Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.State.Position)" else [])

abbrev Ranges : Prop :=
  functionHeader "scan_token" ";" Source.outputBodyTokens = some (rangeHeader "scan_token"
    "(Text : String; Scan : Scan_Result; Token : Token_Kind)" false false false) ∧
  functionHeader "basic_statement_at" ";" Source.outputBodyTokens = some (rangeHeader "basic_statement_at"
    "(Text : String; Scan : Scan_Result)" false true false) ∧
  functionHeader "conditional_at" ";" Source.outputBodyTokens = some (rangeHeader "conditional_at"
    "(Text : String; Scan : Scan_Result)" false true false) ∧
  functionHeader "statement_at" ";" Source.outputBodyTokens = some (rangeHeader "statement_at"
    "(Text : String; Scan : Scan_Result)" false true false) ∧
  functionHeader "basic_tail" ";" Source.outputBodyTokens = some (rangeHeader "basic_tail"
    "(Text : String; Scan : Scan_Result; Stop : Token_Kind)" true false true) ∧
  functionHeader "statements_tail" ";" Source.outputBodyTokens = some (rangeHeader "statements_tail"
    "(Text : String; Scan : Scan_Result; Stop : Token_Kind)" true false true) ∧
  functionHeader "scan_step" ";" Source.outputBodyTokens = some (rangeHeader "scan_step"
    "(Text : String; Form : Form_Kind; Token : Token_Kind; Scan : Scan_Result)" false false false) ∧
  functionHeader "scan_suffix" ";" Source.outputBodyTokens = some
    (rangeHeader "scan_suffix" "(Text : String; Form : Form_Kind; Next_Token : Token_Index; Scan : Scan_Result)" true false false ++
      expectedTokens ", Subprogram_Variant => (Increases => Next_Token)") ∧
  Lexical.SourceBridge.subtypeDeclaration "token_index" Source.outputBodyTokens = some (expectedTokens "Positive range 1 .. 101") ∧
  (∀ form : Form, 1 ≤ form.tokens.length ∧ form.tokens.length ≤ 100)

private theorem range_01 : functionHeader "scan_token" ";" Source.outputBodyTokens = some (rangeHeader "scan_token"
    "(Text : String; Scan : Scan_Result; Token : Token_Kind)" false false false) := by decide +kernel
private theorem range_02 : functionHeader "basic_statement_at" ";" Source.outputBodyTokens = some (rangeHeader "basic_statement_at"
    "(Text : String; Scan : Scan_Result)" false true false) := by decide +kernel
private theorem range_03 : functionHeader "conditional_at" ";" Source.outputBodyTokens = some (rangeHeader "conditional_at"
    "(Text : String; Scan : Scan_Result)" false true false) := by decide +kernel
private theorem range_04 : functionHeader "statement_at" ";" Source.outputBodyTokens = some (rangeHeader "statement_at"
    "(Text : String; Scan : Scan_Result)" false true false) := by decide +kernel
private theorem range_05 : functionHeader "basic_tail" ";" Source.outputBodyTokens = some (rangeHeader "basic_tail"
    "(Text : String; Scan : Scan_Result; Stop : Token_Kind)" true false true) := by decide +kernel
private theorem range_06 : functionHeader "statements_tail" ";" Source.outputBodyTokens = some (rangeHeader "statements_tail"
    "(Text : String; Scan : Scan_Result; Stop : Token_Kind)" true false true) := by decide +kernel
private theorem range_07 : functionHeader "scan_step" ";" Source.outputBodyTokens = some (rangeHeader "scan_step"
    "(Text : String; Form : Form_Kind; Token : Token_Kind; Scan : Scan_Result)" false false false) := by decide +kernel
private theorem range_08 : functionHeader "scan_suffix" ";" Source.outputBodyTokens = some
    (rangeHeader "scan_suffix" "(Text : String; Form : Form_Kind; Next_Token : Token_Index; Scan : Scan_Result)" true false false ++
      expectedTokens ", Subprogram_Variant => (Increases => Next_Token)") := by decide +kernel
private theorem range_09 : Lexical.SourceBridge.subtypeDeclaration "token_index" Source.outputBodyTokens = some (expectedTokens "Positive range 1 .. 101") := by decide +kernel
private theorem range_10 : ∀ form : Form, 1 ≤ form.tokens.length ∧ form.tokens.length ≤ 100 := by
  intro form; cases form <;> decide +kernel

theorem actual_ranges : Ranges :=
  ⟨range_01, range_02, range_03, range_04, range_05, range_06, range_07, range_08, range_09, range_10⟩

end Silver.Sequence.SourceBridge
