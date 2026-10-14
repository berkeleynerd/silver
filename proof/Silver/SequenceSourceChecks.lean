module

public import Silver.LexicalSourceBridge
public import Silver.SequenceExpressions
public import Silver.SequenceNativeExpressions
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
  Named.SourceBridge.ordinaryFunction "conditional_body" Source.outputBodyTokens =
    some (Native.conditionalBody.render "conditional_body") ∧
  Source.expressionBody "statement_body" Source.outputBodyTokens = some Native.statementBody.render ∧
  Named.SourceBridge.ordinaryFunction "body_tail" Source.outputBodyTokens = some (Native.tailImplementation.render "body_tail") ∧
  Source.expressionBody "scan_step" Source.outputBodyTokens = some scanStepBody.render ∧
  Source.expressionBody "scan_suffix" Source.outputBodyTokens = some suffixBody.render ∧
  Source.expressionBody "form_result" Source.outputBodyTokens = some formBody.render ∧
  Source.expressionBody "is_member" Source.outputBodyTokens = some memberBody.render ∧
  Source.expressionBody "has_arguments" Source.outputBodyTokens = some argumentsBody.render ∧
  Source.expressionBody "has_assignment" Source.outputBodyTokens = some assignmentBody.render ∧
  Source.expressionBody "has_output" Source.outputBodyTokens = some outputBody.render ∧
  Named.SourceBridge.ordinaryFunction "body_token" Source.outputBodyTokens =
    some (Native.tokenBody.render "body_token") ∧
  Source.expressionBody "basic_body" Source.outputBodyTokens = some Native.basicBody.render ∧
  Named.SourceBridge.ordinaryFunction "alternative_body" Source.outputBodyTokens =
    some (Native.alternativeBody.render "alternative_body") ∧
  Source.expressionBody "context_of" Source.outputBodyTokens = some (Native.Conversion.render .contextOf) ∧
  Source.expressionBody "body_of" Source.outputBodyTokens = some (Native.Conversion.render .bodyOf) ∧
  Source.expressionBody "expand_body" Source.outputBodyTokens = some (Native.Conversion.render .expand) ∧
  Source.expressionBody "compact_body" Source.outputBodyTokens = some (Native.Conversion.render .compact) ∧
  Source.expressionBody "at_body_stop" Source.outputBodyTokens = some Native.stopRender ∧
  Named.SourceBridge.ordinaryFunction "read_statements" Source.outputBodyTokens = some (Native.Adapter.render .statements) ∧
  Named.SourceBridge.ordinaryFunction "read_body" Source.outputBodyTokens = some (Native.readImplementation.render "read_body")

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
private theorem body_05 : Named.SourceBridge.ordinaryFunction "conditional_body" Source.outputBodyTokens = some (Native.conditionalBody.render "conditional_body") := by
  simp only [Native.Function.render, Native.conditionalBody, Native.finish, Native.guard,
    Native.Command.steps, Native.Command.list, Compose.endIfTokens,
    List.map_cons, List.map_nil, List.foldr_cons, List.foldr_nil]
  simp only [Native.Command.render, Native.Command.renderElse, Native.Expr.render, Native.Condition.render]
  decide +kernel
private theorem body_06 : Source.expressionBody "statement_body" Source.outputBodyTokens = some Native.statementBody.render := by
  simp only [Native.statementBody, Native.Expr.render, Native.Expr.renderElse, Native.Condition.render]
  decide +kernel
private theorem body_07 : Named.SourceBridge.ordinaryFunction "body_tail" Source.outputBodyTokens = some (Native.tailImplementation.render "body_tail") := by
  simp only [Native.Function.render, Native.tailImplementation, Native.Command.list,
    List.foldr_cons, List.foldr_nil]
  simp only [Native.guard, Native.Command.render, Native.Command.renderElse, Native.Expr.render, Native.Condition.render]
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

private theorem body_15 : Named.SourceBridge.ordinaryFunction "body_token" Source.outputBodyTokens = some (Native.tokenBody.render "body_token") := by
  simp only [Native.Function.render, Native.tokenBody, Native.finish, Native.guard]
  simp only [Native.Command.render, Native.Command.renderElse, Native.Expr.render, Native.Condition.render]
  decide +kernel
private theorem body_16 : Source.expressionBody "basic_body" Source.outputBodyTokens = some Native.basicBody.render := by
  simp only [Native.basicBody, Native.Expr.render]
  decide +kernel
private theorem body_17 : Named.SourceBridge.ordinaryFunction "alternative_body" Source.outputBodyTokens = some (Native.alternativeBody.render "alternative_body") := by
  simp only [Native.Function.render, Native.alternativeBody, Native.guard,
    Native.Command.steps, Native.Command.list, elsifTokens,
    List.map_cons, List.map_nil, List.foldr_cons, List.foldr_nil]
  simp only [Native.Command.render, Native.Command.renderElse, Native.Expr.render, Native.Condition.render]
  decide +kernel

private theorem body_18 : Source.expressionBody "context_of" Source.outputBodyTokens = some (Native.Conversion.render .contextOf) := by
  simp only [Native.Conversion.render, Native.words]
  decide +kernel
private theorem body_19 : Source.expressionBody "body_of" Source.outputBodyTokens = some (Native.Conversion.render .bodyOf) := by
  simp only [Native.Conversion.render, Native.words]
  decide +kernel
private theorem body_20 : Source.expressionBody "expand_body" Source.outputBodyTokens = some (Native.Conversion.render .expand) := by
  simp only [Native.Conversion.render, Native.words]
  decide +kernel
private theorem body_21 : Source.expressionBody "compact_body" Source.outputBodyTokens = some (Native.Conversion.render .compact) := by
  simp only [Native.Conversion.render, Native.words]
  decide +kernel
private theorem body_22 : Source.expressionBody "at_body_stop" Source.outputBodyTokens = some Native.stopRender := by
  simp only [Native.stopRender, Native.words]
  decide +kernel
private theorem body_23 : Named.SourceBridge.ordinaryFunction "read_statements" Source.outputBodyTokens = some (Native.Adapter.render .statements) := by
  simp only [Native.Adapter.render, Native.words]
  decide +kernel

private theorem body_24 : Named.SourceBridge.ordinaryFunction "read_body" Source.outputBodyTokens = some (Native.readImplementation.render "read_body") := by
  simp only [Native.Function.render, Native.readImplementation, Native.guard]
  simp only [Native.Command.render, Native.Command.renderElse, Native.Expr.render, Native.Condition.render]
  decide +kernel

theorem actual_bodies : Bodies :=
  ⟨body_01, body_02, body_03, body_04, body_05, body_06, body_07,
    body_08, body_09, body_10, body_11, body_12, body_13, body_14,
    body_15, body_16, body_17, body_18, body_19, body_20, body_21, body_22, body_23, body_24⟩

def listRefinement (name : String) (body : Expr) : List String :=
  expectedTokens "( text : string ; scan : scan_result ; stop : token_kind ) return scan_result with global => null , pre => text ' first = 1 and then text ' length in 1 .. max_source_length and then valid_state ( text , scan . state ) , post => ( static => valid_state ( text ," ++
  [name, "'", "result", ".", "state", ")", "and", "then", name, "'", "result", "="] ++ body.render ++ [")"]

def bodyRefinement : List String :=
  expectedTokens "(Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop) return Body_Scan with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => (Runtime => Valid_Body (Text, Context, Read_Body'Result) and then (Read_Body'Result.Position = 0 or else Read_Body'Result.Position > Scan.Position), Static => Read_Body'Result =" ++
  Native.readBody.render ++ expectedTokens "), Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 3)"

abbrev Refinements : Prop :=
  functionHeader "read_basic_statements" ";" Source.outputBodyTokens = some (listRefinement "read_basic_statements" readBasicBody) ∧
  functionHeader "read_body" ";" Source.outputBodyTokens = some bodyRefinement ∧
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
private theorem refinement_02 : functionHeader "read_body" ";" Source.outputBodyTokens = some bodyRefinement := by
  simp only [bodyRefinement, Native.readBody, Native.Expr.render, Native.Expr.renderElse, Native.Condition.render]
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
    "constant Scan_Result := (State => Invalid_State, Assigned => False, Output => False)") ∧
  Lexical.SourceBridge.recordDeclaration "body_context" Source.outputBodyTokens = some (expectedTokens
    "record Names : Binding_Environment; Dynamic_First, Dynamic_After : Literal_Position; end record") ∧
  Lexical.SourceBridge.recordDeclaration "body_scan" Source.outputBodyTokens = some (expectedTokens
    "record Position : Literal_Position; Target : Binding_Count; Capacity : Capacity_Value; Assigned, Output : Boolean; end record") ∧
  typeDeclaration "body_stop" Source.outputBodyTokens = some (expectedTokens
    "(End_Only, Else_Only, Arm_Boundary)") ∧
  Source.declaration "invalid_body" Source.outputBodyTokens = some (expectedTokens
    "constant Body_Scan := (Position => 0, Target => 0, Capacity => 0, Assigned => False, Output => False)") ∧
  Source.expressionBody "valid_context" Source.outputBodyTokens = some (expectedTokens
    "Valid_Names (Text, Context.Names) and then Valid_Name_State (Text, Context.Dynamic_First, Context.Dynamic_After)") ∧
  Source.expressionBody "valid_body" Source.outputBodyTokens = some (expectedTokens
    "Scan.Position <= Text'Last + 1 and then Scan.Target <= Context.Names.Count")

theorem actual_declarations : Declarations := by decide +kernel

/-- Native pre/postcondition shapes that supply all range and progress facts
used by the recursive source interpretation. No semantic denotation is a range
premise. The recursive-body adapter carries its exact result equation above. -/
def rangeHeader (name parameters : String) (ghost progress tail : Bool) : List String :=
  expectedTokens parameters ++ expectedTokens "return Scan_Result with" ++
    (if ghost then expectedTokens "Ghost => Static," else []) ++
    expectedTokens "Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Scan.State), Post => Valid_State (Text," ++
    [name, "'", "result", ".", "state", ")"] ++
    (if progress then expectedTokens "and then (" ++ [name, "'", "result", ".", "state", ".", "position"] ++
      expectedTokens "= 0 or else" ++ [name, "'", "result", ".", "state", ".", "position"] ++
      expectedTokens "> Scan.State.Position)" else []) ++
    (if tail then expectedTokens ", Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.State.Position)" else [])

/-- Scalar scanner headers expose only cursor, context, and progress facts;
recursive ranks agree with the native mutual traversal. -/
def scalarRangeHeader (name parameters : String) (ghost strict : Bool) (rank : Option Nat) : List String :=
  expectedTokens parameters ++ expectedTokens "return Body_Scan with" ++
    (if ghost then expectedTokens "Ghost => Static," else []) ++
    expectedTokens "Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => Valid_Body (Text, Context," ++
    [name, "'", "result", ")"] ++ expectedTokens "and then (" ++ [name, "'", "result", ".", "position"] ++
    expectedTokens "= 0 or else" ++ [name, "'", "result", ".", "position", if strict then ">" else ">="] ++
    expectedTokens "Scan.Position)" ++
    (match rank with
      | none => []
      | some n => expectedTokens ", Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases =>" ++
          [toString n, ")"])

abbrev Ranges : Prop :=
  functionHeader "scan_token" ";" Source.outputBodyTokens = some (rangeHeader "scan_token"
    "(Text : String; Scan : Scan_Result; Token : Token_Kind)" false false false) ∧
  functionHeader "basic_statement_at" ";" Source.outputBodyTokens = some (rangeHeader "basic_statement_at"
    "(Text : String; Scan : Scan_Result)" false true false) ∧
  functionHeader "body_token" ";" Source.outputBodyTokens = some (scalarRangeHeader "body_token"
    "(Text : String; Context : Body_Context; Scan : Body_Scan; Token : Token_Kind)" false true none) ∧
  functionHeader "basic_body" ";" Source.outputBodyTokens = some (scalarRangeHeader "basic_body"
    "(Text : String; Context : Body_Context; Scan : Body_Scan)" false true none) ∧
  functionHeader "statement_body" ";" Source.outputBodyTokens = some (scalarRangeHeader "statement_body"
    "(Text : String; Context : Body_Context; Scan : Body_Scan)" false true (some 2)) ∧
  functionHeader "conditional_body" ";" Source.outputBodyTokens = some (scalarRangeHeader "conditional_body"
    "(Text : String; Context : Body_Context; Scan : Body_Scan)" false true (some 1)) ∧
  functionHeader "alternative_body" ";" Source.outputBodyTokens = some (scalarRangeHeader "alternative_body"
    "(Text : String; Context : Body_Context; Scan : Body_Scan)" false false (some 1)) ∧
  functionHeader "body_tail" ";" Source.outputBodyTokens = some (scalarRangeHeader "body_tail"
    "(Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop)" false false (some 3)) ∧
  functionHeader "basic_tail" ";" Source.outputBodyTokens = some (rangeHeader "basic_tail"
    "(Text : String; Scan : Scan_Result; Stop : Token_Kind)" true false true) ∧
  functionHeader "read_statements" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Scan.State) and then Stop in Else_Keyword | End_Keyword, Post => Valid_State (Text, Read_Statements'Result.State)") ∧
  functionHeader "scan_step" ";" Source.outputBodyTokens = some (rangeHeader "scan_step"
    "(Text : String; Form : Form_Kind; Token : Token_Kind; Scan : Scan_Result)" false false false) ∧
  functionHeader "scan_suffix" ";" Source.outputBodyTokens = some
    (rangeHeader "scan_suffix" "(Text : String; Form : Form_Kind; Next_Token : Token_Index; Scan : Scan_Result)" true false false ++
      expectedTokens ", Subprogram_Variant => (Increases => Next_Token)") ∧
  Lexical.SourceBridge.subtypeDeclaration "token_index" Source.outputBodyTokens = some (expectedTokens "Positive range 1 .. 101") ∧
  (∀ form : Form, 1 ≤ form.tokens.length ∧ form.tokens.length ≤ 100) ∧
  functionHeader "valid_context" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Context : Body_Context) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length") ∧
  functionHeader "valid_body" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Context : Body_Context; Scan : Body_Scan) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length") ∧
  functionHeader "at_body_stop" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Literal_Position; Stop : Body_Stop) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1")

private theorem range_01 : functionHeader "scan_token" ";" Source.outputBodyTokens = some (rangeHeader "scan_token"
    "(Text : String; Scan : Scan_Result; Token : Token_Kind)" false false false) := by decide +kernel
private theorem range_02 : functionHeader "basic_statement_at" ";" Source.outputBodyTokens = some (rangeHeader "basic_statement_at"
    "(Text : String; Scan : Scan_Result)" false true false) := by decide +kernel
private theorem range_03 : functionHeader "body_token" ";" Source.outputBodyTokens = some (scalarRangeHeader "body_token"
    "(Text : String; Context : Body_Context; Scan : Body_Scan; Token : Token_Kind)" false true none) := by decide +kernel
private theorem range_04 : functionHeader "basic_body" ";" Source.outputBodyTokens = some (scalarRangeHeader "basic_body"
    "(Text : String; Context : Body_Context; Scan : Body_Scan)" false true none) := by decide +kernel
private theorem range_05 : functionHeader "statement_body" ";" Source.outputBodyTokens = some (scalarRangeHeader "statement_body"
    "(Text : String; Context : Body_Context; Scan : Body_Scan)" false true (some 2)) := by decide +kernel
private theorem range_06 : functionHeader "conditional_body" ";" Source.outputBodyTokens = some (scalarRangeHeader "conditional_body"
    "(Text : String; Context : Body_Context; Scan : Body_Scan)" false true (some 1)) := by decide +kernel
private theorem range_07 : functionHeader "alternative_body" ";" Source.outputBodyTokens = some (scalarRangeHeader "alternative_body"
    "(Text : String; Context : Body_Context; Scan : Body_Scan)" false false (some 1)) := by decide +kernel
private theorem range_08 : functionHeader "body_tail" ";" Source.outputBodyTokens = some (scalarRangeHeader "body_tail"
    "(Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop)" false false (some 3)) := by decide +kernel
private theorem range_09 : functionHeader "basic_tail" ";" Source.outputBodyTokens = some (rangeHeader "basic_tail"
    "(Text : String; Scan : Scan_Result; Stop : Token_Kind)" true false true) := by decide +kernel
private theorem range_10 : functionHeader "read_statements" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, Scan.State) and then Stop in Else_Keyword | End_Keyword, Post => Valid_State (Text, Read_Statements'Result.State)") := by decide +kernel
private theorem range_11 : functionHeader "scan_step" ";" Source.outputBodyTokens = some (rangeHeader "scan_step"
    "(Text : String; Form : Form_Kind; Token : Token_Kind; Scan : Scan_Result)" false false false) := by decide +kernel
private theorem range_12 : functionHeader "scan_suffix" ";" Source.outputBodyTokens = some
    (rangeHeader "scan_suffix" "(Text : String; Form : Form_Kind; Next_Token : Token_Index; Scan : Scan_Result)" true false false ++
      expectedTokens ", Subprogram_Variant => (Increases => Next_Token)") := by decide +kernel
private theorem range_13 : Lexical.SourceBridge.subtypeDeclaration "token_index" Source.outputBodyTokens = some (expectedTokens "Positive range 1 .. 101") := by decide +kernel
private theorem range_14 : ∀ form : Form, 1 ≤ form.tokens.length ∧ form.tokens.length ≤ 100 := by
  intro form; cases form <;> decide +kernel

private theorem range_15 : functionHeader "valid_context" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Context : Body_Context) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length") := by decide +kernel
private theorem range_16 : functionHeader "valid_body" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Context : Body_Context; Scan : Body_Scan) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length") := by decide +kernel
private theorem range_17 : functionHeader "at_body_stop" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Position : Literal_Position; Stop : Body_Stop) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1") := by decide +kernel

theorem actual_ranges : Ranges :=
  ⟨range_01, range_02, range_03, range_04, range_05, range_06, range_07,
    range_08, range_09, range_10, range_11, range_12, range_13, range_14,
    range_15, range_16, range_17⟩

end Silver.Sequence.SourceBridge
