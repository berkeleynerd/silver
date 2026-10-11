import Silver.LexicalSourceBridge
import Silver.ComposeEvaluation
import Silver.ComposeExecution
import Silver.Current

/-! Correspondence for the actual shared recognizer, its finite shell tables,
executable refinements and interpreted Main statements. Exact-source certificates
and complete scope pins accompany the interpreted equations; neither replaces
them. The documented Ada frontend and complete SPARK audit supply the equations
and machine-domain contracts of the authoritative source. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge

abbrev ExpressionTranslation : Prop :=
  Expressions.WellFormedTrees ∧
  Source.expressionBody "operand_at" Source.outputBodyTokens = some Expressions.operandBody.render ∧
  Source.expressionBody "expression_tail" Source.outputBodyTokens = some Expressions.tailBody.render ∧
  Source.expressionBody "expression_at" Source.outputBodyTokens = some Expressions.expressionBody.render ∧
  Source.expressionBody "step" Source.outputBodyTokens = some Expressions.stepBody.render ∧
  Source.expressionBody "suffix_matches" Source.outputBodyTokens = some Expressions.suffixBody.render ∧
  Source.expressionBody "form_member" Source.outputBodyTokens = some Expressions.formBody.render ∧
  Source.expressionBody "is_member" Source.outputBodyTokens = some Expressions.memberBody.render ∧
  Source.expressionBody "has_arguments" Source.outputBodyTokens = some Expressions.argumentsBody.render ∧
  Source.expressionBody "has_assignment" Source.outputBodyTokens = some Expressions.assignmentBody.render

theorem actual_expressions : ExpressionTranslation := by decide +kernel

def allTokens : List ShellToken :=
  [.word "with", .word "silver_io", .word "procedure", .word "main", .word "is",
   .word "pragma", .word "spark_mode", .word "on", .word "begin", .word "put_line", .word "end",
   .symbol "(", .symbol ")", .symbol ";", .symbol ".", .literal .ordinary,
   .symbol ":", .word "constant", .word "string", .symbol ":=", .staticDeclaration, .staticReference,
   .word "silver_arguments", .word "first_or_default", .word "if", .word "input_is_valid",
   .word "then", .word "else", .word "reject", .symbol "&", .word "and", .symbol "'",
   .word "length", .symbol "<=", .capacity, .symbol "=", .dynamicDeclaration,
   .dynamicReference, .literal .initial, .literal .assigned, .outputExpression,
   .constantDeclaration false, .constantDeclaration true, .literal .constantOne, .literal .constantTwo]

def commaNames (names : List String) : List String := List.flatten ((names.map fun name => [name]).intersperse [","])

def quoted (text : String) : String :=
  String.ofList (['"'] ++ text.toList.flatMap (fun ch => if ch = '"' then ['"', '"'] else [ch]) ++ ['"'])

def spellingGroups : List (List ShellToken) :=
  (allTokens.take 15).map (fun token => [token]) ++
  [[.literal .ordinary, .literal .initial, .literal .assigned, .literal .constantOne, .literal .constantTwo]] ++
  (allTokens.drop 16 |>.take 4).map (fun token => [token]) ++
  [[.staticDeclaration, .staticReference, .dynamicDeclaration, .dynamicReference, .outputExpression,
    .constantDeclaration false, .constantDeclaration true]] ++
  (allTokens.drop 22 |>.take 14).map (fun token => [token])

def spellingBody : List String := ["case", "token", "is"] ++
  List.flatten ((spellingGroups.map fun group =>
    ["when"] ++ List.flatten ((group.map fun token => [Expressions.tokenName token]).intersperse ["|"]) ++
    ["=>", quoted (Expressions.spelling (group.headD (.symbol ";")))]).intersperse [","])

def tokensBody : List String := ["case", "form", "is"] ++
  List.flatten ((allForms.map fun form =>
    ["when", Expressions.formName form, "=>", "("] ++
    commaNames (form.tokens.map Expressions.tokenName) ++ [")"]).intersperse [","])

abbrev CatalogueTranslation : Prop :=
  typeDeclaration "token_kind" Source.outputSpecTokens =
    some (["("] ++ commaNames (allTokens.map Expressions.tokenName) ++ [")"]) ∧
  typeDeclaration "form_kind" Source.outputSpecTokens =
    some (["("] ++ commaNames (allForms.map Expressions.formName) ++ [")"]) ∧
  Source.expressionBody "spelling" Source.outputBodyTokens = some spellingBody ∧
  Source.expressionBody "tokens" Source.outputBodyTokens = some tokensBody ∧
  Source.expressionBody "is_word_token" Source.outputBodyTokens = some (expectedTokens
    "Token in With_Keyword .. End_Keyword | Constant_Keyword | String_Name | Arguments_Name | First_Or_Default_Name | If_Keyword | Input_Is_Valid_Name | Then_Keyword | Else_Keyword | Reject_Name | And_Keyword | Length_Name") ∧
  Source.expressionBody "is_argument_form" Source.outputSpecTokens =
    some (expectedTokens "Form in Argument_Form .. Guarded_Result_Two_Form") ∧
  Source.expressionBody "is_assignment_form" Source.outputSpecTokens =
    some (expectedTokens "Form in Assignment_Form .. Assignment_Two_Form | Result_Form .. Guarded_Result_Two_Form")

theorem actual_catalogue : CatalogueTranslation := by decide +kernel

/-- The finite mapping covers every token used by every template, including
word/punctuation classification and the source's enum ordinal tests. -/
theorem finite_mapping :
    (∀ form ∈ allForms, ∀ token ∈ form.tokens, token ∈ allTokens) ∧
    (∀ token ∈ allTokens, 1 ≤ (Expressions.spelling token).length ∧ (Expressions.spelling token).length ≤ 16) ∧
    (∀ index : Fin allTokens.length, Expressions.isWord allTokens[index] =
      (decide (index.val ≤ 10) || decide (allTokens[index] ∈
        [.word "constant", .word "string", .word "silver_arguments", .word "first_or_default",
         .word "if", .word "input_is_valid", .word "then", .word "else", .word "reject",
         .word "and", .word "length"]))) := by decide +kernel

abbrev Declarations : Prop :=
  Source.declaration "max_expression_operands" Source.outputSpecTokens =
    some (expectedTokens "constant Positive := 16") ∧ maxExpressionOperands = 16 ∧
  Lexical.SourceBridge.subtypeDeclaration "literal_position" Source.outputLexicalSpecTokens =
    some (expectedTokens "Natural range 0 .. Max_Source_Length + 1") ∧
  Lexical.SourceBridge.subtypeDeclaration "capacity_value" Source.outputLexicalSpecTokens =
    some (expectedTokens "Natural range 0 .. Max_Source_Length") ∧
  Lexical.SourceBridge.subtypeDeclaration "operand_count" Source.outputBodyTokens =
    some (expectedTokens "Natural range 0 .. Max_Expression_Operands") ∧
  Lexical.SourceBridge.subtypeDeclaration "token_index" Source.outputBodyTokens =
    some (expectedTokens "Positive range 1 .. 101") ∧
  Lexical.SourceBridge.recordDeclaration "expression_result" Source.outputBodyTokens = some (expectedTokens
    "record After : Literal_Position; Static_Length : Capacity_Value; Dynamic_Seen : Boolean; Static_Seen : Boolean; end record") ∧
  Lexical.SourceBridge.recordDeclaration "parser_state" Source.outputBodyTokens = some (expectedTokens
    "record Position : Literal_Position; Static_First, Static_After : Literal_Position; Dynamic_First, Dynamic_After : Literal_Position; Constant_One_First, Constant_One_After, Constant_One_Value_First : Literal_Position; Constant_Two_First, Constant_Two_After, Constant_Two_Value_First : Literal_Position; Static_Length : Capacity_Value; Capacity : Capacity_Value; end record") ∧
  Source.declaration "invalid_expression" Source.outputBodyTokens = some (expectedTokens
    "constant Expression_Result := (After => 0, Static_Length => 0, Dynamic_Seen => False, Static_Seen => False)") ∧
  Source.declaration "initial_state" Source.outputBodyTokens = some (expectedTokens
    "constant Parser_State := (Position => 1, Static_First => 0, Static_After => 0, Dynamic_First => 0, Dynamic_After => 0, Constant_One_First => 0, Constant_One_After => 0, Constant_One_Value_First => 0, Constant_Two_First => 0, Constant_Two_After => 0, Constant_Two_Value_First => 0, Static_Length => 0, Capacity => Max_Source_Length)") ∧
  Source.declaration "invalid_state" Source.outputBodyTokens = some (expectedTokens
    "constant Parser_State := (Position => 0, Static_First => 0, Static_After => 0, Dynamic_First => 0, Dynamic_After => 0, Constant_One_First => 0, Constant_One_After => 0, Constant_One_Value_First => 0, Constant_Two_First => 0, Constant_Two_After => 0, Constant_Two_Value_First => 0, Static_Length => 0, Capacity => 0)") ∧
  Source.expressionBody "valid_state" Source.outputBodyTokens = some (expectedTokens
    "State.Position <= Text'Last + 1 and then Valid_Name_State (Text, State.Static_First, State.Static_After) and then Valid_Name_State (Text, State.Dynamic_First, State.Dynamic_After) and then Valid_Name_State (Text, State.Constant_One_First, State.Constant_One_After) and then Valid_Name_State (Text, State.Constant_Two_First, State.Constant_Two_After) and then State.Constant_One_Value_First <= Text'Last + 1 and then State.Constant_Two_Value_First <= Text'Last + 1")

theorem actual_declarations : Declarations := by decide +kernel

abbrev Refinement : Prop :=
  functionHeader "accepts" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Accepts'Result = Is_Member (Source))") ∧
  functionHeader "uses_arguments" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Uses_Arguments'Result = Has_Arguments (Source))") ∧
  functionHeader "uses_assignment" ";" Source.outputSpecTokens = some (expectedTokens
    "(Source : String) return Boolean with Global => null, Post => (Static => Uses_Assignment'Result = Has_Assignment (Source))") ∧
  functionHeader "step" ";" Source.outputBodyTokens = some (expectedTokens
    "(Text : String; Form : Form_Kind; Token : Token_Kind; State : Parser_State) return Parser_State with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then State.Position > 0 and then Valid_State (Text, State), Post => Valid_State (Text, Step'Result)") ∧
  functionHeader "tokens" ";" Source.outputSpecTokens = some (expectedTokens
    "(Form : Form_Kind) return Token_Sequence with Global => null, Post => Tokens'Result'First = 1 and then Tokens'Result'Length in 1 .. 100")

theorem actual_refinement : Refinement := by decide +kernel

structure CheckedSource : Prop where
  inherited : Lexical.SourceBridge.CheckedSource
  expressions : ExpressionTranslation
  catalogue : CatalogueTranslation
  declarations : Declarations
  refinement : Refinement
  mainTranslation : ∀ form, (Main.composition form).render = form.tokens

theorem checked_source : CheckedSource where
  inherited := Lexical.SourceBridge.checked_source
  expressions := actual_expressions
  catalogue := actual_catalogue
  declarations := actual_declarations
  refinement := actual_refinement
  mainTranslation := Main.rendered_tokens

theorem authoritative_main_correct {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) (arguments : Arguments.Runtime.Arguments) :
    CheckedSource ∧ ∃ program, decode form events = some program ∧
      Parsed source form (Main.composition form).render initialState events ∧
      ConstantElaboration source form (Main.composition form).render initialState {} events ∧
      (Main.composition form).execute events arguments = some (program.action arguments) := by
  obtain ⟨program, decoded, valid⟩ := decoded_valid meaning
  exact ⟨checked_source, program, decoded, by simpa [Main.rendered_tokens] using meaning.2.2,
    by simpa [Main.rendered_tokens] using meaning_constant_elaboration meaning,
    Main.execution_refines decoded valid arguments⟩

/-- Interpretation of actual helper/body calls and the existing SPARK domain
contracts. The lexical premises name retained source equations, not equality of
this recognizer with the language model. LegalBodies covers only executed
helper-call preconditions, including short-circuit evaluation. -/
structure InterpretedSource (calls : Expressions.Calls) : Prop where
  lexical : ∃ (helpers : Guarded.Expressions.Calls)
      (token : Source → Nat → String → Bool → Bool),
    calls.primitive = Lexical.primitives helpers token ∧
      Lexical.InterpretedSource helpers token
  definitions : Expressions.DefinitionEquations calls calls
  legal : Expressions.LegalBodies calls

/-- First derive every retained lexical meaning, then transport actual typed
body evaluation to those meanings before applying recursion uniqueness. -/
theorem interpreted_equations (calls : Expressions.Calls)
    (source : InterpretedSource calls) : Expressions.DefinitionEquations calls := by
  obtain ⟨helpers, token, same, interpreted⟩ := source.lexical
  have meaning : Lexical.Meaning calls.primitive := by
    rw [same]
    exact Lexical.interpreted_primitives helpers token interpreted
  exact Expressions.normalized_definitions calls meaning source.definitions source.legal

/-- Executable refinements are the three exact postconditions checked above,
proved by the complete compiler SPARK audit. They neither choose a grammar by
solver success nor assume equivalence to the independent model. -/
structure ExecutableRefinement (calls : Expressions.Calls)
    (accepts usesArguments usesAssignment : Source → Bool) : Prop where
  admission : ∀ source, accepts source = calls.member source
  arguments : ∀ source, usesArguments source = calls.arguments source
  assignment : ∀ source, usesAssignment source = calls.assignment source

theorem authoritative_source_member_iff (calls : Expressions.Calls)
    (sourceEquations : InterpretedSource calls)
    (accepts usesArguments usesAssignment : Source → Bool)
    (proved : ExecutableRefinement calls accepts usesArguments usesAssignment)
    (source : Source) :
    CheckedSource ∧ (accepts source = true ↔ Member source) := by
  refine ⟨checked_source, ?_⟩
  rw [proved.admission, Expressions.interpreted_member calls (interpreted_equations calls sourceEquations)]
  exact accepts_iff_member source

/-- Both report-routing bits select exactly the first accepted form. Together
these distinguish static, argument, assigned and selected-result policies. -/
theorem authoritative_selectors (calls : Expressions.Calls)
    (sourceEquations : InterpretedSource calls)
    (accepts usesArguments usesAssignment : Source → Bool)
    (proved : ExecutableRefinement calls accepts usesArguments usesAssignment)
    {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) :
    CheckedSource ∧ usesArguments source = form.hasArguments ∧
      usesAssignment source = form.hasAssignment := by
  refine ⟨checked_source, ?_, ?_⟩
  · rw [proved.arguments, Expressions.interpreted_arguments calls (interpreted_equations calls sourceEquations)]
    exact meaning_argument_selector meaning
  · rw [proved.assignment, Expressions.interpreted_assignment calls (interpreted_equations calls sourceEquations)]
    exact meaning_assignment_selector meaning

/-- Union the independently interpreted null and output recognizers. No
sample enumeration participates in whole-language membership. -/
theorem authoritative_current_member_iff
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : InterpretedSource calls)
    (source : Source) : CheckedSource ∧
      ((nullCalls.member source || calls.member source) = true ↔ Current.Member source) := by
  refine ⟨checked_source, ?_⟩
  simp only [Bool.or_eq_true, Current.Member]
  rw [Silver.Expressions.member_implementation_iff nullCalls nullEquations source,
    Expressions.interpreted_member calls (interpreted_equations calls sourceEquations), accepts_iff_member]

/-- The actual-source recognizers entail pipeline completion under the explicit
external tool contract, which includes complete generation, pinned-fragment
solver completion and faithful build/runtime semantics. -/
theorem checked_membership_supported_pipeline {Artifact : Type}
    {tools : Current.Tools Artifact} (contract : Current.ToolContract tools)
    (nullCalls : Silver.Expressions.Calls)
    (nullEquations : Silver.Expressions.DefinitionEquations nullCalls)
    (calls : Expressions.Calls) (sourceEquations : InterpretedSource calls)
    (source : Source) (accepted : (nullCalls.member source || calls.member source) = true) :
    CheckedSource ∧ ∃ artifact steps, Current.Pipeline tools source artifact steps := by
  exact ⟨checked_source, Current.automatic_pipeline contract
    ((authoritative_current_member_iff nullCalls nullEquations calls sourceEquations source).2.mp accepted)⟩

end Silver.Compose.SourceBridge
