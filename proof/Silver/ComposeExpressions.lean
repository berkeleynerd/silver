module

public import Silver.ComposeAdmission

@[expose] public section

/-! Typed expression trees for the shared SPARK expression and shell recognizer.
All newly introduced callees remain arbitrary. Shared lexical callees have a
separate interface so their established source interpretation can be reused. -/

set_option linter.constructorNameAsVariable false
namespace Silver.Compose.Expressions

structure Primitives where
  trivia : Source → Nat → Nat
  literal : Source → Nat → Nat
  length : Source → Nat → Nat
  identifier : Source → Nat → Nat
  forbidden : Source → Nat → Nat → Bool
  forbiddenArgument : Source → Nat → Nat → Bool
  equal : Source → Nat → Nat → Nat → Nat → Bool
  decimal : Source → Nat → Guarded.DecimalResult
  token : Source → Nat → String → Bool → Bool
  normalize : Source → Source
  allowed : Source → Bool

structure Calls where
  primitive : Primitives
  operand : Source → Nat → NameContext → ExpressionResult
  tail : Source → NameContext → Nat → Nat → Nat → Bool → Bool → ExpressionResult
  expression : Source → Nat → NameContext → ExpressionResult
  step : Source → Form → ShellToken → ParserState → ParserState
  suffix : Source → Form → Nat → ParserState → Bool
  formMember : Source → Form → Bool
  member : Source → Bool
  arguments : Source → Bool
  assignment : Source → Bool

structure Context where
  text : Source
  position : Nat := 1
  names : NameContext := {}
  length : Nat := 0
  dynamicSeen : Bool := false
  staticSeen : Bool := false
  remaining : Nat := 16
  form : Form := .direct
  token : ShellToken := .symbol ";"
  state : ParserState := {}
  nextToken : Nat := 1

mutual
inductive Number
  | constant (value : Nat) | character (value : Nat) | characterVal (value : Number)
  | position | last | sourceLength | maxLength | maxOperands | length | remaining | nextToken | tokensLast
  | staticFirst | staticAfter | staticLength | dynamicFirst | dynamicAfter
  | constantOneFirst | constantOneAfter | constantOneValueFirst | constantTwoFirst | constantTwoAfter | constantTwoValueFirst
  | stateConstantOneFirst | stateConstantOneAfter | stateConstantOneValueFirst | stateConstantTwoFirst | stateConstantTwoAfter | stateConstantTwoValueFirst
  | statePosition | stateStaticFirst | stateStaticAfter | stateStaticLength
  | stateDynamicFirst | stateDynamicAfter | stateCapacity
  | add (left right : Number) | sub (left right : Number) | group (value : Number)
  | byteAt (position : Number) | trivia (position : Number) | identifier (position : Number)
  | literal (position : Number) | literalLength (position : Number)
  | decimalAfter (position : Number) | decimalValue (position : Number)
  | after (value : Result) | resultLength (value : Result) | spellingLength
  | ite (condition : Condition) (yes no : Number) | elsif (condition : Condition) (yes no : Number)
  deriving DecidableEq, Repr
inductive Condition
  | value (value : Bool) | dynamicSeen | staticSeen
  | eq (left right : Number) | ne (left right : Number)
  | lt (left right : Number) | le (left right : Number) | gt (left right : Number)
  | range (value first last : Number)
  | andThen (left right : Condition) | orElse (left right : Condition)
  | not (value : Condition) | group (value : Condition)
  | forbidden (first after : Number) | forbiddenArgument (first after : Number)
  | equalName (leftFirst leftAfter rightFirst rightAfter : Number)
  | tokenEq (token : ShellToken) | tokenNe (token : ShellToken) | literalToken | copyToken | declarationToken
  | fixedAt (position : Number) | assignmentForm
  | resultDynamic (value : Result) | resultStatic (value : Result)
  | suffix (index : Number) (state : State) | suffixNormalized
  | allowedNormalized | formMember (form : Form) | currentFormMember
  | someForm (argumentsOnly : Bool)
  | firstForm (arguments : Bool)
  | ite (condition yes no : Condition) | elsif (condition yes no : Condition)
  deriving DecidableEq, Repr
inductive Result
  | invalid
  | record (after length : Number) (dynamicSeen staticSeen : Condition)
  | operand (position first after length dynamicFirst dynamicAfter c1f c1a c1v c2f c2a c2v : Number)
  | tail (position first after length dynamicFirst dynamicAfter c1f c1a c1v c2f c2a c2v accumulated : Number)
      (dynamicSeen staticSeen : Condition) (remaining : Number)
  | expression (position first after length dynamicFirst dynamicAfter c1f c1a c1v c2f c2a c2v : Number)
  | group (value : Result)
  | ite (condition : Condition) (yes no : Result) | elsif (condition : Condition) (yes no : Result)
  deriving DecidableEq, Repr
inductive State
  | current | initial | invalid
  | position (position : Number)
  | staticBinding (position first after : Number)
  | dynamicBinding (position first after : Number)
  | constantOneBinding (position first after : Number)
  | constantTwoBinding (position first after : Number)
  | constantValues (position one two : Number)
  | declarations (position sf sa c1f c1a c2f c2a : Number)
  | length (position length : Number)
  | capacity (position capacity : Number)
  | step (index : Number)
  | group (value : State)
  | ite (condition : Condition) (yes no : State) | elsif (condition : Condition) (yes no : State)
  deriving DecidableEq, Repr
end

def call (name : String) (arguments : List (List String)) : List String :=
  [name, "("] ++ List.flatten (List.intersperse [","] arguments) ++ [")"]

def formName : Form → String
  | .direct => "direct_form" | .static => "static_form" | .assignment => "assignment_form"
  | .argument => "argument_form" | .guardedArgument => "guarded_argument_form"
  | .branching => "branching_form" | .guardedBranching => "guarded_branching_form"
  | .result => "result_form" | .guardedResult => "guarded_result_form"
  | .assignmentOne => "assignment_one_form" | .assignmentTwo => "assignment_two_form"
  | .resultOne => "result_one_form" | .resultTwo => "result_two_form"
  | .guardedResultOne => "guarded_result_one_form" | .guardedResultTwo => "guarded_result_two_form"

def tokenName : ShellToken → String
  | .staticDeclaration => "declaration_name" | .dynamicDeclaration => "dynamic_declaration"
  | .staticReference => "reference_name" | .dynamicReference => "dynamic_reference"
  | .literal .ordinary => "string_literal" | .literal .initial => "static_initializer"
  | .literal .assigned => "static_assignment" | .capacity => "capacity_literal"
  | .outputExpression => "output_expression"
  | .constantDeclaration false => "constant_one_declaration"
  | .constantDeclaration true => "constant_two_declaration"
  | .literal .constantOne => "constant_one_initializer"
  | .literal .constantTwo => "constant_two_initializer"
  | .fixed spelling _ => match spelling with
    | "with" => "with_keyword" | "silver_io" => "io_name" | "procedure" => "procedure_keyword"
    | "main" => "main_name" | "is" => "is_keyword" | "pragma" => "pragma_keyword"
    | "spark_mode" => "spark_mode_name" | "on" => "on_name" | "begin" => "begin_keyword"
    | "put_line" => "put_line_name" | "end" => "end_keyword" | "(" => "left_parenthesis"
    | ")" => "right_parenthesis" | ";" => "semicolon" | "." => "dot" | ":" => "colon"
    | "constant" => "constant_keyword" | "string" => "string_name" | ":=" => "assignment"
    | "silver_arguments" => "arguments_name" | "first_or_default" => "first_or_default_name"
    | "if" => "if_keyword" | "input_is_valid" => "input_is_valid_name" | "then" => "then_keyword"
    | "else" => "else_keyword" | "reject" => "reject_name" | "&" => "ampersand"
    | "and" => "and_keyword" | "'" => "apostrophe" | "length" => "length_name"
    | "<=" => "less_equal" | _ => "equal"

def tokenAtIndex (form : Form) (index : Nat) : ShellToken :=
  form.tokens.getD (index - 1) (.symbol ";")
def spelling : ShellToken → String
  | .fixed word _ => word
  | .literal _ => "\"" | .capacity => "0" | _ => "_"
def isWord : ShellToken → Bool | .fixed _ word => word | _ => false

def indexedToken (index : List String) : List String := call "tokens" [["form"]] ++ ["("] ++ index ++ [")"]
def updated (fields : List (String × List String)) : List String :=
  ["(", "state", "with", "delta"] ++
    List.flatten (List.intersperse [","] (fields.map fun (field,value) => [field,"=>"] ++ value)) ++ [")"]

mutual
def Number.render : Number → List String
  | .constant n => [toString n] | .character n => [String.ofList ['\'',Char.ofNat n,'\'']]
  | .characterVal a => ["character","'","val","("] ++ a.render ++ [")"]
  | .position => ["position"] | .last => ["text","'","last"]
  | .sourceLength => ["source","'","length"] | .maxLength => ["max_source_length"]
  | .maxOperands => ["max_expression_operands"] | .length => ["length"] | .remaining => ["remaining"]
  | .nextToken => ["next_token"] | .tokensLast => call "tokens" [["form"]] ++ ["'","last"]
  | .staticFirst => ["static_first"] | .staticAfter => ["static_after"]
  | .staticLength => ["static_length"] | .dynamicFirst => ["dynamic_first"] | .dynamicAfter => ["dynamic_after"]
  | .statePosition => ["state",".","position"] | .stateStaticFirst => ["state",".","static_first"]
  | .stateStaticAfter => ["state",".","static_after"] | .stateStaticLength => ["state",".","static_length"]
  | .stateDynamicFirst => ["state",".","dynamic_first"] | .stateDynamicAfter => ["state",".","dynamic_after"]
  | .stateCapacity => ["state",".","capacity"]
  | .constantOneFirst => ["constant_one_first"]
  | .constantOneAfter => ["constant_one_after"]
  | .constantOneValueFirst => ["constant_one_value_first"]
  | .constantTwoFirst => ["constant_two_first"]
  | .constantTwoAfter => ["constant_two_after"]
  | .constantTwoValueFirst => ["constant_two_value_first"]
  | .stateConstantOneFirst => ["state",".","constant_one_first"]
  | .stateConstantOneAfter => ["state",".","constant_one_after"]
  | .stateConstantOneValueFirst => ["state",".","constant_one_value_first"]
  | .stateConstantTwoFirst => ["state",".","constant_two_first"]
  | .stateConstantTwoAfter => ["state",".","constant_two_after"]
  | .stateConstantTwoValueFirst => ["state",".","constant_two_value_first"]
  | .add a b => a.render ++ ["+"] ++ b.render | .sub a b => a.render ++ ["-"] ++ b.render
  | .group a => ["("] ++ a.render ++ [")"]
  | .byteAt a => call "text" [a.render] | .trivia a => call "trivia_end" [["text"],a.render]
  | .identifier a => call "identifier_end" [["text"],a.render]
  | .literal a => call "literal_end" [["text"],a.render]
  | .literalLength a => call "literal_length" [["text"],a.render]
  | .decimalAfter a => call "decimal_at" [["text"],a.render] ++ [".","after"]
  | .decimalValue a => call "decimal_at" [["text"],a.render] ++ [".","value"]
  | .after a => a.render ++ [".","after"] | .resultLength a => a.render ++ [".","static_length"]
  | .spellingLength => call "spelling" [["token"]] ++ ["'","length"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
def Condition.render : Condition → List String
  | .value true => ["true"] | .value false => ["false"]
  | .dynamicSeen => ["dynamic_seen"] | .staticSeen => ["static_seen"]
  | .eq a b => a.render ++ ["="] ++ b.render | .ne a b => a.render ++ ["/="] ++ b.render
  | .lt a b => a.render ++ ["<"] ++ b.render | .le a b => a.render ++ ["<="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render
  | .range a b c => a.render ++ ["in"] ++ b.render ++ [".."] ++ c.render
  | .andThen a b => a.render ++ ["and","then"] ++ b.render
  | .orElse a b => a.render ++ ["or","else"] ++ b.render
  | .not a => ["not"] ++ a.render | .group a => ["("] ++ a.render ++ [")"]
  | .forbidden a b => call "forbidden_name" [["text"],a.render,b.render]
  | .forbiddenArgument a b => call "forbidden_argument_name" [["text"],a.render,b.render]
  | .equalName a b c d => call "equal_name" [["text"],a.render,b.render,c.render,d.render]
  | .tokenEq token => ["token","=",tokenName token] | .tokenNe token => ["token","/=",tokenName token]
  | .literalToken => ["token","in","string_literal","|","constant_one_initializer","|","constant_two_initializer"]
  | .copyToken => ["token","in","static_initializer","|","static_assignment"]
  | .declarationToken => ["token","in","declaration_name","|","constant_one_declaration","|","constant_two_declaration"]
  | .fixedAt a => call "token_at" [["text"],a.render,call "spelling" [["token"]],call "is_word_token" [["token"]]]
  | .assignmentForm => call "is_assignment_form" [["form"]]
  | .resultDynamic a => a.render ++ [".","dynamic_seen"] | .resultStatic a => a.render ++ [".","static_seen"]
  | .suffix a state => call "suffix_matches" [["text"],["form"],a.render,state.render]
  | .suffixNormalized => call "suffix_matches" [call "normalized" [["source"]],["form"],["1"],["initial_state"]]
  | .allowedNormalized => call "allowed_source" [call "normalized" [["source"]]]
  | .formMember form => call "form_member" [["source"],[formName form]]
  | .currentFormMember => call "form_member" [["source"],["form"]]
  | .firstForm arguments => ["for","some","form","in","form_kind","=>"] ++
      call "form_member" [["source"],["form"]] ++ ["and","then"] ++
      call (if arguments then "is_argument_form" else "is_assignment_form") [["form"]] ++
      ["and","then","(","for","all","previous","in","form_kind","\'","first","..","form","=>","(","if","previous","/=","form","then","not"] ++
      call "form_member" [["source"],["previous"]] ++ [")",")"]
  | .someForm argumentsOnly => ["for","some","form","in"] ++
      (if argumentsOnly then ["argument_form","..","guarded_result_form"] else ["form_kind"]) ++
      ["=>"] ++ call "form_member" [["source"],["form"]]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
def Result.render : Result → List String
  | .invalid => ["invalid_expression"]
  | .record a l d s => ["(","after","=>"] ++ a.render ++ [",","static_length","=>"] ++ l.render ++
      [",","dynamic_seen","=>"] ++ d.render ++ [",","static_seen","=>"] ++ s.render ++ [")"]
  | .operand p a b l c d e f g h i j => call "operand_at" [["text"],p.render,a.render,b.render,l.render,c.render,d.render,e.render,f.render,g.render,h.render,i.render,j.render]
  | .expression p a b l c d e f g h i j => call "expression_at" [["text"],p.render,a.render,b.render,l.render,c.render,d.render,e.render,f.render,g.render,h.render,i.render,j.render]
  | .tail p a b l c d e f g h i j total dyn seen fuel => call "expression_tail"
      [["text"],p.render,a.render,b.render,l.render,c.render,d.render,e.render,f.render,g.render,h.render,i.render,j.render,total.render,dyn.render,seen.render,fuel.render]
  | .group a => ["("] ++ a.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
def State.render : State → List String
  | .current => ["state"] | .initial => ["initial_state"] | .invalid => ["invalid_state"]
  | .position p => updated [("position",p.render)]
  | .staticBinding p a b => updated [("position",p.render),("static_first",a.render),("static_after",b.render)]
  | .dynamicBinding p a b => updated [("position",p.render),("dynamic_first",a.render),("dynamic_after",b.render)]
  | .constantOneBinding p a b => updated [("position",p.render),("constant_one_first",a.render),("constant_one_after",b.render)]
  | .constantTwoBinding p a b => updated [("position",p.render),("constant_two_first",a.render),("constant_two_after",b.render)]
  | .declarations p a b c d e f => updated [("position",p.render),("static_first",a.render),("static_after",b.render),("constant_one_first",c.render),("constant_one_after",d.render),("constant_two_first",e.render),("constant_two_after",f.render)]
  | .constantValues p a b => updated [("position",p.render),("constant_one_value_first",a.render),("constant_two_value_first",b.render)]
  | .length p l => updated [("position",p.render),("static_length",l.render)]
  | .capacity p c => updated [("position",p.render),("capacity",c.render)]
  | .step index => call "step" [["text"],["form"],indexedToken index.render,["state"]]
  | .group a => ["("] ++ a.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
end

mutual
def Number.eval (calls : Calls) (ctx : Context) : Number → Nat
  | .constant n | .character n => n | .characterVal a | .group a => a.eval calls ctx
  | .position => ctx.position | .last | .sourceLength => ctx.text.length
  | .maxLength => maxSourceLength | .maxOperands => maxExpressionOperands
  | .length => ctx.length | .remaining => ctx.remaining | .nextToken => ctx.nextToken
  | .tokensLast => ctx.form.tokens.length
  | .staticFirst => ctx.names.staticFirst | .staticAfter => ctx.names.staticAfter
  | .staticLength => ctx.names.staticLength | .dynamicFirst => ctx.names.dynamicFirst | .dynamicAfter => ctx.names.dynamicAfter
  | .statePosition => ctx.state.position | .stateStaticFirst => ctx.state.context.staticFirst
  | .stateStaticAfter => ctx.state.context.staticAfter | .stateStaticLength => ctx.state.context.staticLength
  | .stateDynamicFirst => ctx.state.context.dynamicFirst | .stateDynamicAfter => ctx.state.context.dynamicAfter
  | .stateCapacity => ctx.state.capacity
  | .constantOneFirst => ctx.names.constantOneFirst
  | .constantOneAfter => ctx.names.constantOneAfter
  | .constantOneValueFirst => ctx.names.constantOneValueFirst
  | .constantTwoFirst => ctx.names.constantTwoFirst
  | .constantTwoAfter => ctx.names.constantTwoAfter
  | .constantTwoValueFirst => ctx.names.constantTwoValueFirst
  | .stateConstantOneFirst => ctx.state.context.constantOneFirst
  | .stateConstantOneAfter => ctx.state.context.constantOneAfter
  | .stateConstantOneValueFirst => ctx.state.context.constantOneValueFirst
  | .stateConstantTwoFirst => ctx.state.context.constantTwoFirst
  | .stateConstantTwoAfter => ctx.state.context.constantTwoAfter
  | .stateConstantTwoValueFirst => ctx.state.context.constantTwoValueFirst
  | .add a b => a.eval calls ctx + b.eval calls ctx | .sub a b => a.eval calls ctx - b.eval calls ctx
  | .byteAt a => Cursor.byteAt ctx.text (a.eval calls ctx)
  | .trivia a => calls.primitive.trivia ctx.text (a.eval calls ctx)
  | .identifier a => calls.primitive.identifier ctx.text (a.eval calls ctx)
  | .literal a => calls.primitive.literal ctx.text (a.eval calls ctx)
  | .literalLength a => calls.primitive.length ctx.text (a.eval calls ctx)
  | .decimalAfter a => (calls.primitive.decimal ctx.text (a.eval calls ctx)).after
  | .decimalValue a => (calls.primitive.decimal ctx.text (a.eval calls ctx)).value
  | .after a => (a.eval calls ctx).after | .resultLength a => (a.eval calls ctx).staticLength
  | .spellingLength => (spelling ctx.token).length
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx
def Condition.eval (calls : Calls) (ctx : Context) : Condition → Bool
  | .value v => v | .dynamicSeen => ctx.dynamicSeen | .staticSeen => ctx.staticSeen
  | .eq a b => decide (a.eval calls ctx = b.eval calls ctx)
  | .ne a b => decide (a.eval calls ctx ≠ b.eval calls ctx)
  | .lt a b => decide (a.eval calls ctx < b.eval calls ctx)
  | .le a b => decide (a.eval calls ctx ≤ b.eval calls ctx)
  | .gt a b => decide (a.eval calls ctx > b.eval calls ctx)
  | .range a b c => decide (b.eval calls ctx ≤ a.eval calls ctx ∧ a.eval calls ctx ≤ c.eval calls ctx)
  | .andThen a b => a.eval calls ctx && b.eval calls ctx
  | .orElse a b => a.eval calls ctx || b.eval calls ctx
  | .not a => !a.eval calls ctx | .group a => a.eval calls ctx
  | .forbidden a b => calls.primitive.forbidden ctx.text (a.eval calls ctx) (b.eval calls ctx)
  | .forbiddenArgument a b => calls.primitive.forbiddenArgument ctx.text (a.eval calls ctx) (b.eval calls ctx)
  | .equalName a b c d => calls.primitive.equal ctx.text (a.eval calls ctx) (b.eval calls ctx) (c.eval calls ctx) (d.eval calls ctx)
  | .tokenEq token => decide (ctx.token = token) | .tokenNe token => decide (ctx.token ≠ token)
  | .literalToken => match ctx.token with | .literal .ordinary | .literal .constantOne | .literal .constantTwo => true | _ => false
  | .copyToken => match ctx.token with | .literal .initial | .literal .assigned => true | _ => false
  | .declarationToken => match ctx.token with | .staticDeclaration | .constantDeclaration _ => true | _ => false
  | .fixedAt a => calls.primitive.token ctx.text (a.eval calls ctx) (spelling ctx.token) (isWord ctx.token)
  | .assignmentForm => ctx.form.hasAssignment
  | .resultDynamic a => (a.eval calls ctx).dynamicSeen | .resultStatic a => (a.eval calls ctx).staticSeen
  | .suffix a state => calls.suffix ctx.text ctx.form (a.eval calls ctx) (state.eval calls ctx)
  | .suffixNormalized => calls.suffix (calls.primitive.normalize ctx.text) ctx.form 1 initialState
  | .allowedNormalized => calls.primitive.allowed (calls.primitive.normalize ctx.text)
  | .formMember form => calls.formMember ctx.text form
  | .currentFormMember => calls.formMember ctx.text ctx.form
  | .firstForm arguments => allForms.any (fun form =>
      calls.formMember ctx.text form && (if arguments then form.hasArguments else form.hasAssignment) &&
      (allForms.takeWhile (fun previous => previous != form)).all (fun previous => !calls.formMember ctx.text previous))
  | .someForm argumentsOnly => (allForms.filter fun form => !argumentsOnly || form.hasArguments).any (calls.formMember ctx.text)
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx
def Result.eval (calls : Calls) (ctx : Context) : Result → ExpressionResult
  | .invalid => invalidExpression
  | .record a l d s => ⟨a.eval calls ctx,l.eval calls ctx,d.eval calls ctx,s.eval calls ctx⟩
  | .operand p a b l c d e f g h i j => calls.operand ctx.text (p.eval calls ctx)
      ⟨a.eval calls ctx,b.eval calls ctx,l.eval calls ctx,c.eval calls ctx,d.eval calls ctx,e.eval calls ctx,f.eval calls ctx,g.eval calls ctx,h.eval calls ctx,i.eval calls ctx,j.eval calls ctx⟩
  | .expression p a b l c d e f g h i j => calls.expression ctx.text (p.eval calls ctx)
      ⟨a.eval calls ctx,b.eval calls ctx,l.eval calls ctx,c.eval calls ctx,d.eval calls ctx,e.eval calls ctx,f.eval calls ctx,g.eval calls ctx,h.eval calls ctx,i.eval calls ctx,j.eval calls ctx⟩
  | .tail p a b l c d e f g h i j total dyn seen fuel => calls.tail ctx.text
      ⟨a.eval calls ctx,b.eval calls ctx,l.eval calls ctx,c.eval calls ctx,d.eval calls ctx,e.eval calls ctx,f.eval calls ctx,g.eval calls ctx,h.eval calls ctx,i.eval calls ctx,j.eval calls ctx⟩
      (fuel.eval calls ctx) (p.eval calls ctx) (total.eval calls ctx) (dyn.eval calls ctx) (seen.eval calls ctx)
  | .group a => a.eval calls ctx
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx
def State.eval (calls : Calls) (ctx : Context) : State → ParserState
  | .current => ctx.state | .initial => initialState | .invalid => invalidState
  | .position p => {ctx.state with position := p.eval calls ctx}
  | .staticBinding p a b => {ctx.state with position := p.eval calls ctx, context := {ctx.state.context with staticFirst := a.eval calls ctx, staticAfter := b.eval calls ctx}}
  | .dynamicBinding p a b => {ctx.state with position := p.eval calls ctx, context := {ctx.state.context with dynamicFirst := a.eval calls ctx, dynamicAfter := b.eval calls ctx}}
  | .constantOneBinding p a b => {ctx.state with position := p.eval calls ctx, context := {ctx.state.context with constantOneFirst := a.eval calls ctx, constantOneAfter := b.eval calls ctx}}
  | .constantTwoBinding p a b => {ctx.state with position := p.eval calls ctx, context := {ctx.state.context with constantTwoFirst := a.eval calls ctx, constantTwoAfter := b.eval calls ctx}}
  | .declarations p a b c d e f => {ctx.state with position := p.eval calls ctx, context := {ctx.state.context with staticFirst := a.eval calls ctx, staticAfter := b.eval calls ctx, constantOneFirst := c.eval calls ctx, constantOneAfter := d.eval calls ctx, constantTwoFirst := e.eval calls ctx, constantTwoAfter := f.eval calls ctx}}
  | .constantValues p a b => {ctx.state with position := p.eval calls ctx, context := {ctx.state.context with constantOneValueFirst := a.eval calls ctx, constantTwoValueFirst := b.eval calls ctx}}
  | .length p l => {ctx.state with position := p.eval calls ctx, context := {ctx.state.context with staticLength := l.eval calls ctx}}
  | .capacity p c => {ctx.state with position := p.eval calls ctx, capacity := c.eval calls ctx}
  | .step index => calls.step ctx.text ctx.form (tokenAtIndex ctx.form (index.eval calls ctx)) ctx.state
  | .group a => a.eval calls ctx
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx
end

/-! The precedence checks use Ada's expression categories. Mixed Boolean
operators require an explicit group; relational operands cannot contain an
unparenthesized conditional, and arithmetic keeps its left association. -/
def Number.primary : Number → Bool
  | .add _ _ | .sub _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Number.simple : Number → Bool | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Number.isElsif : Number → Bool | .elsif _ _ _ => true | _ => false
def Condition.primary : Condition → Bool
  | .value _ | .dynamicSeen | .staticSeen | .group _ | .forbidden _ _ | .forbiddenArgument _ _
  | .equalName _ _ _ _ | .fixedAt _ | .assignmentForm | .resultDynamic _ | .resultStatic _
  | .suffix _ _ | .suffixNormalized | .allowedNormalized | .formMember _ | .currentFormMember => true
  | _ => false
def Condition.relation : Condition → Bool
  | .andThen _ _ | .orElse _ _ | .ite _ _ _ | .elsif _ _ _ | .someForm _ | .firstForm _ => false | _ => true
def Condition.logical : Condition → Bool | .ite _ _ _ | .elsif _ _ _ | .someForm _ | .firstForm _ => false | _ => true
def Condition.andLeft : Condition → Bool | .andThen _ _ => true | c => c.relation
def Condition.orLeft : Condition → Bool | .orElse _ _ => true | c => c.relation
def Condition.isElsif : Condition → Bool | .elsif _ _ _ => true | _ => false
def Result.primary : Result → Bool | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Result.isElsif : Result → Bool | .elsif _ _ _ => true | _ => false
def State.primary : State → Bool | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def State.isElsif : State → Bool | .elsif _ _ _ => true | _ => false
mutual
def Number.wellFormed : Number → Bool
  | .add a b | .sub a b => a.wellFormed && b.wellFormed && a.simple && b.primary
  | .group a => a.wellFormed && !a.isElsif
  | .characterVal a | .byteAt a | .trivia a | .identifier a | .literal a | .literalLength a
  | .decimalAfter a | .decimalValue a => a.wellFormed && a.simple
  | .after a | .resultLength a => a.wellFormed && a.primary
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.simple && b.wellFormed && (b.simple || b.isElsif)
  | _ => true
def Condition.wellFormed : Condition → Bool
  | .eq a b | .ne a b | .lt a b | .le a b | .gt a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .range a b c => a.wellFormed && b.wellFormed && c.wellFormed && a.simple && b.simple && c.simple
  | .andThen a b => a.wellFormed && b.wellFormed && a.andLeft && b.relation
  | .orElse a b => a.wellFormed && b.wellFormed && a.orLeft && b.relation
  | .not a => a.wellFormed && a.primary | .group a => a.wellFormed && !a.isElsif
  | .forbidden a b | .forbiddenArgument a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .equalName a b c d => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && a.simple && b.simple && c.simple && d.simple
  | .fixedAt a => a.wellFormed && a.simple
  | .resultDynamic a | .resultStatic a => a.wellFormed && a.primary
  | .suffix a b => a.wellFormed && a.simple && b.wellFormed && b.primary
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.logical && b.wellFormed && (b.logical || b.isElsif)
  | _ => true
def Result.wellFormed : Result → Bool
  | .invalid => true
  | .record a l d s => a.wellFormed && l.wellFormed && d.wellFormed && s.wellFormed && a.simple && l.simple && d.logical && s.logical
  | .operand p a b l c d e f g h i j | .expression p a b l c d e f g h i j => p.wellFormed && a.wellFormed && b.wellFormed && l.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && f.wellFormed && g.wellFormed && h.wellFormed && i.wellFormed && j.wellFormed && p.simple && a.simple && b.simple && l.simple && c.simple && d.simple && e.simple && f.simple && g.simple && h.simple && i.simple && j.simple
  | .tail p a b l c d e f g h i j total dyn seen fuel => p.wellFormed && a.wellFormed && b.wellFormed && l.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && f.wellFormed && g.wellFormed && h.wellFormed && i.wellFormed && j.wellFormed && total.wellFormed && dyn.wellFormed && seen.wellFormed && fuel.wellFormed && p.simple && a.simple && b.simple && l.simple && c.simple && d.simple && e.simple && f.simple && g.simple && h.simple && i.simple && j.simple && total.simple && dyn.logical && seen.logical && fuel.simple
  | .group a => a.wellFormed && !a.isElsif
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.primary && b.wellFormed && (b.primary || b.isElsif)
def State.wellFormed : State → Bool
  | .current | .initial | .invalid => true
  | .position p | .step p => p.wellFormed && p.simple
  | .staticBinding p a b | .dynamicBinding p a b | .constantOneBinding p a b | .constantTwoBinding p a b | .constantValues p a b => p.wellFormed && a.wellFormed && b.wellFormed && p.simple && a.simple && b.simple
  | .declarations p a b c d e f => p.wellFormed && a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && f.wellFormed && p.simple && a.simple && b.simple && c.simple && d.simple && e.simple && f.simple
  | .length p l | .capacity p l => p.wellFormed && l.wellFormed && p.simple && l.simple
  | .group a => a.wellFormed && !a.isElsif
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.primary && b.wellFormed && (b.primary || b.isElsif)
end

def both (a b : Condition) : Condition := .andThen a b
def either (a b : Condition) : Condition := .orElse a b
def quoteAt (position : Number) : Condition := .eq (.byteAt position) (.characterVal (.constant 34))
def plusOne (value : Number) : Number := .add value (.constant 1)

def operandBody : Result :=
  let finish := Number.identifier .position
  let literal := Number.literal (plusOne .position)
  let constantCase (first after value : Number) (rest : Result) : Result :=
    .elsif (both (both (both (both (both (.ne finish (.constant 0)) (.gt first (.constant 0)))
      (.equalName first after .position finish)) (.gt value (.constant 1)))
      (quoteAt (.sub value (.constant 1)))) (.ne (.literal value) (.constant 0)))
      (.record finish (.literalLength value) (.value false) (.value false)) rest
  .ite (both (both (.le .position .last) (quoteAt .position)) (.ne literal (.constant 0)))
    (.record literal (.literalLength (plusOne .position)) (.value false) (.value false))
    (.elsif (both (both (.ne finish (.constant 0)) (.gt .staticFirst (.constant 0)))
      (.equalName .staticFirst .staticAfter .position finish))
      (.record finish .staticLength (.value false) (.value true))
      (.elsif (both (both (.ne finish (.constant 0)) (.gt .dynamicFirst (.constant 0)))
        (.equalName .dynamicFirst .dynamicAfter .position finish))
        (.record finish (.constant 0) (.value true) (.value false))
        (constantCase .constantOneFirst .constantOneAfter .constantOneValueFirst
          (constantCase .constantTwoFirst .constantTwoAfter .constantTwoValueFirst .invalid))))

def tailBody : Result :=
  let atom := Result.operand (.trivia .position) .staticFirst .staticAfter .staticLength .dynamicFirst .dynamicAfter
    .constantOneFirst .constantOneAfter .constantOneValueFirst .constantTwoFirst .constantTwoAfter .constantTwoValueFirst
  let after := Number.after atom
  let length := Number.resultLength atom
  let following := Number.trivia after
  let dynamic := Condition.resultDynamic atom
  let seen := Condition.resultStatic atom
  .ite (.eq .remaining (.constant 0)) .invalid
    (.elsif (either (either (.eq after (.constant 0)) (.gt length (.sub .maxLength .length)))
      (.group (both .dynamicSeen dynamic))) .invalid
      (.elsif (both (.le following .last) (.eq (.byteAt following) (.character 38)))
        (.tail (plusOne following) .staticFirst .staticAfter .staticLength .dynamicFirst .dynamicAfter
    .constantOneFirst .constantOneAfter .constantOneValueFirst .constantTwoFirst .constantTwoAfter .constantTwoValueFirst
          (.add .length length) (either .dynamicSeen dynamic) (either .staticSeen seen)
          (.sub .remaining (.constant 1)))
        (.record after (.add .length length) (either .dynamicSeen dynamic) (either .staticSeen seen))))

def expressionBody : Result :=
  .tail .position .staticFirst .staticAfter .staticLength .dynamicFirst .dynamicAfter
    .constantOneFirst .constantOneAfter .constantOneValueFirst .constantTwoFirst .constantTwoAfter .constantTwoValueFirst
    (.constant 0) (.value false) (.value false) .maxOperands

def stepBody : State :=
  let start := Number.trivia .statePosition
  let finish := Number.identifier start
  let literal := Number.literal (plusOne start)
  let expression := Result.expression .statePosition .stateStaticFirst .stateStaticAfter
    .stateStaticLength .stateDynamicFirst .stateDynamicAfter
    .stateConstantOneFirst .stateConstantOneAfter .stateConstantOneValueFirst
    .stateConstantTwoFirst .stateConstantTwoAfter .stateConstantTwoValueFirst
  let value := Result.operand start (.constant 0) (.constant 0) (.constant 0) (.constant 0) (.constant 0)
    .stateConstantOneFirst .stateConstantOneAfter .stateConstantOneValueFirst
    .stateConstantTwoFirst .stateConstantTwoAfter .stateConstantTwoValueFirst
  let different (first after : Number) : Condition :=
    .group (either (.eq first (.constant 0)) (.not (.equalName first after start finish)))
  let selected (token : ShellToken) (value old : Number) : Number :=
    .group (.ite (.tokenEq token) value old)
  .ite .declarationToken
    (.group (.ite (both (both (both (both (.ne finish (.constant 0)) (.not (.forbidden start finish)))
      (.group (either (.eq .stateDynamicFirst (.constant 0))
        (.group (both (.not (.forbiddenArgument start finish))
          (.not (.equalName .stateDynamicFirst .stateDynamicAfter start finish)))))))
      (different .stateConstantOneFirst .stateConstantOneAfter))
      (different .stateConstantTwoFirst .stateConstantTwoAfter))
      (.declarations finish
        (selected .staticDeclaration start .stateStaticFirst)
        (selected .staticDeclaration finish .stateStaticAfter)
        (selected (.constantDeclaration false) start .stateConstantOneFirst)
        (selected (.constantDeclaration false) finish .stateConstantOneAfter)
        (selected (.constantDeclaration true) start .stateConstantTwoFirst)
        (selected (.constantDeclaration true) finish .stateConstantTwoAfter)) .invalid))
    (.elsif (.tokenEq .dynamicDeclaration)
      (.group (.ite (both (.ne finish (.constant 0)) (.not (.forbiddenArgument start finish)))
        (.dynamicBinding finish start finish) .invalid))
      (.elsif (.tokenEq .staticReference)
        (.group (.ite (both (both (.ne finish (.constant 0)) (.gt .stateStaticFirst (.constant 0)))
          (.equalName .stateStaticFirst .stateStaticAfter start finish)) (.position finish) .invalid))
        (.elsif (.tokenEq .dynamicReference)
          (.group (.ite (both (both (.ne finish (.constant 0)) (.gt .stateDynamicFirst (.constant 0)))
            (.equalName .stateDynamicFirst .stateDynamicAfter start finish)) (.position finish) .invalid))
          (.elsif .literalToken
            (.group (.ite (both (both (.le start .last) (quoteAt start)) (.ne literal (.constant 0)))
              (.constantValues literal
                (selected (.literal .constantOne) (plusOne start) .stateConstantOneValueFirst)
                (selected (.literal .constantTwo) (plusOne start) .stateConstantTwoValueFirst)) .invalid))
            (.elsif .copyToken
              (.group (.ite (both (.ne (.after value) (.constant 0))
                (.group (either (.tokenNe (.literal .assigned)) (.eq (.resultLength value) .stateStaticLength))))
                (.length (.after value) (selected (.literal .initial) (.resultLength value) .stateStaticLength)) .invalid))
              (.elsif (.tokenEq .capacity)
                (.group (.ite (.ne (.decimalAfter start) (.constant 0))
                  (.capacity (.decimalAfter start) (.decimalValue start)) .invalid))
                (.elsif (.tokenEq .outputExpression)
                  (.group (.ite (both (both (.ne (.after expression) (.constant 0))
                    (.group (either (.not (.resultDynamic expression))
                      (.le (.resultLength expression) (.sub .maxLength .stateCapacity)))))
                    (.group (either (.not .assignmentForm) (.resultStatic expression))))
                    (.position (.after expression)) .invalid))
                  (.elsif (.fixedAt start) (.position (.add start .spellingLength)) .invalid))))))))

def suffixBody : Condition :=
  .ite (.eq .statePosition (.constant 0)) (.value false)
    (.elsif (.gt .nextToken .tokensLast)
      (.eq (.trivia .statePosition) (plusOne .last))
      (.suffix (plusOne .nextToken) (.step .nextToken)))

def formBody : Condition :=
  both (both (.range .sourceLength (.constant 1) .maxLength) .allowedNormalized) .suffixNormalized

def memberBody : Condition := .someForm false

def argumentsBody : Condition := .firstForm true

def assignmentBody : Condition := .firstForm false

abbrev WellFormedTrees : Prop :=
  operandBody.wellFormed = true ∧ tailBody.wellFormed = true ∧ expressionBody.wellFormed = true ∧
  stepBody.wellFormed = true ∧ suffixBody.wellFormed = true ∧ formBody.wellFormed = true ∧
  memberBody.wellFormed = true ∧ argumentsBody.wellFormed = true ∧ assignmentBody.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

end Silver.Compose.Expressions
