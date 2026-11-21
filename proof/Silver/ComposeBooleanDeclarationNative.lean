module

public import Silver.ComposeAdmission

@[expose] public section

/-! Typed interpretation of the complete ordinary Boolean declaration function.
This layer uses the concrete context fields without importing the recursive
native condition interpreter, so the outer declaration dispatcher can retain a
raw source equation. The downstream bridge discharges its imported calls. -/
namespace Silver.Compose.BooleanDeclarationNative
open Predicate

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

structure Context where
  names : BindingEnvironment
  dynamicFirst : Nat
  dynamicAfter : Nat
  scalarNames : ScalarExpression.Environment
  declarationCount : Nat
  arrayNames : ArrayBindings.Metadata
  subtypeHiding : IntegerSubtypes.CallHiding
  booleanNames : BooleanBindings.Environment
  trueHidden : Bool
  falseHidden : Bool
  elaborating : Bool
  maskFirst : Nat
  maskAfter : Nat
  pure : Bool := false
  integerHidden : Bool := false
  arrayTypes : ArrayBindings.TypeEnvironment := []
  deriving DecidableEq, Repr

def Context.model (context : Context) : ParseContext :=
  ⟨context.names, decide (context.dynamicFirst ≠ 0), context.scalarNames,
    context.declarationCount, context.arrayNames, context.subtypeHiding, context.booleanNames,
    context.trueHidden, context.falseHidden, context.elaborating, context.maskFirst, context.maskAfter,
    context.pure, context.integerHidden, context.arrayTypes⟩

structure Scan where
  state : ParserState
  assigned : Bool
  output : Bool
  deriving DecidableEq, Repr

def contextOf (scan : Scan) : Context :=
  ⟨scan.state.names, scan.state.dynamicFirst, scan.state.dynamicAfter,
    ScalarExpression.bodyEnvironment scan.state.scalarNames, scan.state.scalarNames.length,
    scan.state.arrayNames.names, scan.state.subtypeNames.hiddenCalls, scan.state.booleanNames,
    scan.state.subtypeNames.trueHidden || scan.state.hiding.trueHidden,
    scan.state.subtypeNames.falseHidden || scan.state.hiding.falseHidden, false, 0, 0,
    scan.state.pure, scan.state.hiding.integerHidden, scan.state.arrayNames.types⟩

def initialFlow (context : Context) : ActiveFlow :=
  ActiveFlow.initial context.scalarNames
    (if context.dynamicFirst ≠ 0 then PathFacts.Context.initial maxSourceLength
      else ⟨some ⟨0, 0⟩, false, false⟩)

inductive Token | colon | constantKeyword | booleanName | assignment | semicolon
  deriving DecidableEq, Repr

def Token.name : Token → String
  | .colon => "colon" | .constantKeyword => "constant_keyword" | .booleanName => "boolean_name"
  | .assignment => "assignment" | .semicolon => "semicolon"

def Token.shell : Token → ShellToken
  | .colon => .symbol ":" | .constantKeyword => .word "constant" | .booleanName => .word "boolean"
  | .assignment => .symbol ":=" | .semicolon => .symbol ";"

inductive Mark | integer | boolean | character
  deriving DecidableEq, Repr

def Mark.word : Mark → String
  | .integer => "integer" | .boolean => "boolean" | .character => "character"

def Mark.hidden (mark : Mark) (state : ParserState) : Bool :=
  match mark with
  | .integer => state.hiding.integerHidden
  | .boolean => state.hiding.booleanHidden
  | .character => state.hiding.characterHidden

inductive Lookup | string | scalar | array | subtype | boolean | function | procedure
  deriving DecidableEq, Repr

def lookup (kind : Lookup) (text : Source) (state : ParserState) (first after : Nat) : Nat :=
  match kind with
  | .string => lookupName text state.names first after
  | .scalar => ScalarExpression.lookup text state.scalarNames first after
  | .array => ArrayBindings.lookup text state.arrayNames.names first after
  | .subtype => IntegerSubtypes.lookup text state.subtypeNames first after
  | .boolean => BooleanBindings.lookup text state.booleanNames first after
  | .function => FunctionBindings.lookup text state.functions first after
  | .procedure => ProcedureBindings.lookup text state.procedures first after

@[ext] structure Imports where
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  take : Source → Nat → Token → Nat
  newName : Source → ParserState → Nat → Nat → Bool → Bool
  nameIsBoolean : Source → Nat → Nat → Bool
  nameIsMark : Mark → Source → Nat → Nat → Bool
  formalHides : Source → ParserState → Nat → Nat → Bool
  lookup : Lookup → Source → ParserState → Nat → Nat → Nat
  contextOf : Scan → Context
  initialFlow : Context → ActiveFlow
  conditionInto : Source → Context → Nat → ActiveFlow → Nat → ArrayBindings.Initials → ConditionResult
  invalid : ParserState

def modelImports : Imports where
  skip := skipAt
  nameAfter := Compose.nameAfter
  take := fun text position token => tokenAfter text position token.shell
  newName := newNameAllowed
  nameIsBoolean := fun text first after => Named.nameIs text first after ("boolean".toList.map Char.toNat)
  nameIsMark := fun mark text first after => Named.nameIs text first after (mark.word.toList.map Char.toNat)
  formalHides := Compose.formalHides
  lookup := lookup
  contextOf := contextOf
  initialFlow := initialFlow
  conditionInto := fun text context position facts _ initials => readCondition text context.model position facts initials
  invalid := invalidState

inductive Local | first | after | colonAfter | constantAfter | typeFirst | typeAfter | valueFirst | following
  deriving DecidableEq, Repr

def Local.name : Local → String
  | .first => "first" | .after => "after" | .colonAfter => "colon_after" | .constantAfter => "constant_after"
  | .typeFirst => "type_first" | .typeAfter => "type_after" | .valueFirst => "value_first" | .following => "following"

structure Frame where
  text : Source
  state : ParserState
  arguments : Bool
  positions : Local → Nat := fun _ => 0
  context : Context := contextOf ⟨initialState, false, false⟩
  value : ConditionResult := invalidCondition ⟨PathFacts.Context.empty, []⟩
  valueCount : Nat := 0

def Frame.withLocal (frame : Frame) (name : Local) (value : Nat) : Frame :=
  {frame with positions := fun other => if other = name then value else frame.positions other}

inductive Expr : Type → Type 1
  | local : Local → Expr Nat
  | statePosition : Expr Nat
  | booleanCount : Expr Nat
  | scalarCount : Expr Nat
  | maxBooleans : Expr Nat
  | number : Nat → Expr Nat
  | truth : Bool → Expr Bool
  | arguments : Expr Bool
  | scalarNames : Expr ScalarExpression.Environment
  | initials : Expr ArrayBindings.Initials
  | context : Expr Context
  | valueAfter : Expr Nat
  | skip : Expr Nat → Expr Nat
  | nameAfter : Expr Nat → Expr Nat
  | take : Expr Nat → Token → Expr Nat
  | newName : Expr Nat → Expr Nat → Expr Bool → Expr Bool
  | nameIsBoolean : Expr Nat → Expr Nat → Expr Bool
  | nameIsMark : Mark → Expr Nat → Expr Nat → Expr Bool
  | formalHides : Expr Nat → Expr Nat → Expr Bool
  | hiddenMark : Mark → Expr Bool
  | lookup : Lookup → Expr Nat → Expr Nat → Expr Nat
  | contextOf : Expr Context
  | initialFlow : Expr Context → Expr ActiveFlow
  | eq : Expr Nat → Expr Nat → Expr Bool
  | ne : Expr Nat → Expr Nat → Expr Bool
  | le : Expr Nat → Expr Nat → Expr Bool
  | not : Expr Bool → Expr Bool
  | orElse : Expr Bool → Expr Bool → Expr Bool
  | andThen : Expr Bool → Expr Bool → Expr Bool
  | choose : Expr Bool → Expr α → Expr α → Expr α
  | group : Expr α → Expr α
  | invalid : Expr ParserState
  | addBoolean : Expr Nat → Expr Nat → Expr Nat → Expr Bool → Expr ParserState

def Expr.eval (imports : Imports) (frame : Frame) : Expr α → α
  | .local name => frame.positions name
  | .statePosition => frame.state.position
  | .booleanCount => frame.state.booleanNames.length
  | .scalarCount => frame.state.scalarNames.length
  | .maxBooleans => BooleanBindings.maxBindings
  | .number value => value | .truth value => value | .arguments => frame.arguments
  | .scalarNames => frame.state.scalarNames | .initials => frame.state.arrayNames.values
  | .context => frame.context | .valueAfter => frame.value.after
  | .skip position => imports.skip frame.text (position.eval imports frame)
  | .nameAfter first => imports.nameAfter frame.text (first.eval imports frame)
  | .take position token => imports.take frame.text (position.eval imports frame) token
  | .newName first after allowArguments => imports.newName frame.text frame.state
      (first.eval imports frame) (after.eval imports frame) (allowArguments.eval imports frame)
  | .nameIsBoolean first after => imports.nameIsBoolean frame.text (first.eval imports frame) (after.eval imports frame)
  | .nameIsMark mark first after => imports.nameIsMark mark frame.text (first.eval imports frame) (after.eval imports frame)
  | .formalHides first after => imports.formalHides frame.text frame.state (first.eval imports frame) (after.eval imports frame)
  | .hiddenMark mark => mark.hidden frame.state
  | .lookup kind first after => imports.lookup kind frame.text frame.state (first.eval imports frame) (after.eval imports frame)
  | .contextOf => imports.contextOf ⟨frame.state, false, false⟩
  | .initialFlow ctx => imports.initialFlow (ctx.eval imports frame)
  | .eq left right => decide (left.eval imports frame = right.eval imports frame)
  | .ne left right => decide (left.eval imports frame ≠ right.eval imports frame)
  | .le left right => decide (left.eval imports frame ≤ right.eval imports frame)
  | .not value => !value.eval imports frame
  | .orElse left right => left.eval imports frame || right.eval imports frame
  | .andThen left right => left.eval imports frame && right.eval imports frame
  | .choose test yes no => if test.eval imports frame then yes.eval imports frame else no.eval imports frame
  | .group value => value.eval imports frame
  | .invalid => imports.invalid
  | .addBoolean position first after mutable =>
      {frame.state with
        position := position.eval imports frame
        booleanNames := frame.state.booleanNames ++ [⟨first.eval imports frame, after.eval imports frame, mutable.eval imports frame⟩]}

def call (name : List String) (arguments : List (List String)) : List String :=
  name ++ ["("] ++ List.flatten (arguments.intersperse [","]) ++ [")"]

def Expr.render : Expr α → List String
  | .local name => [name.name]
  | .statePosition => ["state", ".", "position"]
  | .booleanCount => ["state", ".", "boolean_names", ".", "count"]
  | .scalarCount => ["state", ".", "scalar_names", ".", "count"]
  | .maxBooleans => ["max_boolean_bindings"]
  | .number value => [toString value]
  | .truth value => [if value then "true" else "false"]
  | .arguments => ["arguments"] | .scalarNames => ["state", ".", "scalar_names"]
  | .initials => ["state", ".", "array_names", ".", "values"]
  | .context => ["context"] | .valueAfter => ["value", ".", "after"]
  | .skip position => call ["skip_at"] [["text"], position.render]
  | .nameAfter first => call ["name_after"] [["text"], first.render]
  | .take position token => call ["take_token"] [["text"], position.render, [token.name]]
  | .newName first after allowArguments => call ["new_name_allowed"] [["text"], ["state"], first.render, after.render, allowArguments.render]
  | .nameIsBoolean first after => call ["name_is"] [["text"], first.render, after.render, ["\"boolean\""]]
  | .nameIsMark mark first after => call ["name_is"] [["text"], first.render, after.render, ["\"" ++ mark.word ++ "\""]]
  | .formalHides first after => call ["formal_hides"] [["text"], ["state"], first.render, after.render]
  | .hiddenMark mark => ["state", ".", "hiding", ".", mark.word ++ "_hidden"]
  | .lookup kind first after =>
      let (name, names) := match kind with
        | .string => (["lookup_name"], ["names"])
        | .scalar => (["scalar_expressions", ".", "lookup"], ["scalar_names"])
        | .array => (["array_bindings", ".", "lookup"], ["array_names", ".", "names"])
        | .subtype => (["lookup_subtype"], ["subtype_names"])
        | .boolean => (["lookup_boolean"], ["boolean_names"])
        | .function => (["functions", ".", "lookup"], ["functions"])
        | .procedure => (["procedures", ".", "lookup"], ["procedures"])
      call name [["text"], ["state", "."] ++ names, first.render, after.render]
  | .contextOf => call ["context_of"] [["(", "state", ",", "false", ",", "false", ")"]]
  | .initialFlow ctx => call ["initial_flow"] [ctx.render]
  | .eq left right => left.render ++ ["="] ++ right.render
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .not value => ["not"] ++ value.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .invalid => ["invalid_state"]
  | .addBoolean position first after mutable =>
      ["(", "state", "with", "delta", "position", "=>"] ++ position.render ++
      [",", "boolean_names", "=>", "(", "count", "=>", "state", ".", "boolean_names", ".", "count", "+", "1", ",",
        "items", "=>", "(", "state", ".", "boolean_names", ".", "items", "with", "delta", "state", ".", "boolean_names", ".", "count", "+", "1", "=>", "("] ++
      first.render ++ [","] ++ after.render ++ [","] ++ mutable.render ++ [")", ")", ")", ")"]

def Expr.primary : Expr α → Bool
  | .local _ | .statePosition | .booleanCount | .scalarCount | .maxBooleans |
    .number _ | .truth _ | .arguments | .scalarNames | .initials | .context |
    .valueAfter | .skip _ | .nameAfter _ | .take _ _ | .newName _ _ _ |
    .nameIsBoolean _ _ | .nameIsMark _ _ _ | .formalHides _ _ | .hiddenMark _ |
    .lookup _ _ _ | .contextOf | .initialFlow _ | .group _ | .invalid | .addBoolean _ _ _ _ => true
  | .eq _ _ | .ne _ _ | .le _ _ | .not _ | .orElse _ _ | .andThen _ _ | .choose _ _ _ => false

def Expr.relation : Expr α → Bool
  | .eq _ _ | .ne _ _ | .le _ _ | .not _ => true
  | value => value.primary

def Expr.orHead : Expr α → Bool
  | .orElse _ _ => true
  | value => value.relation

def Expr.andHead : Expr α → Bool
  | .andThen _ _ => true
  | value => value.relation

def Expr.wellFormed : Expr α → Bool
  | .local _ | .statePosition | .booleanCount | .scalarCount | .maxBooleans | .number _ | .truth _ |
      .arguments | .scalarNames | .initials | .context | .valueAfter | .contextOf | .invalid | .hiddenMark _ => true
  | .skip value | .nameAfter value | .take value _ | .initialFlow value | .not value => value.primary && value.wellFormed
  | .nameIsBoolean first after | .nameIsMark _ first after | .formalHides first after | .lookup _ first after | .eq first after | .ne first after | .le first after =>
      first.primary && after.primary && first.wellFormed && after.wellFormed
  | .newName first after allowArguments => first.primary && after.primary && allowArguments.primary &&
      first.wellFormed && after.wellFormed && allowArguments.wellFormed
  | .orElse left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .andThen left right => left.andHead && right.relation && left.wellFormed && right.wellFormed
  | .choose test yes no => test.orHead && yes.primary && no.primary && test.wellFormed && yes.wellFormed && no.wellFormed
  | .group value => value.wellFormed
  | .addBoolean position first after mutable => position.primary && first.primary && after.primary &&
      mutable.orHead && position.wellFormed && first.wellFormed && after.wellFormed && mutable.wellFormed

namespace StructuralControls

theorem not_collision :
    (Expr.not (.orElse (.truth true) (.truth true))).render =
      (Expr.orElse (.not (.truth true)) (.truth true)).render ∧
    (Expr.not (.orElse (.truth true) (.truth true))).wellFormed = false ∧
    (Expr.orElse (.not (.truth true)) (.truth true)).wellFormed = true := by decide +kernel

theorem categories_and_nested_children :
    (Expr.andThen (.orElse (.truth true) (.truth false)) (.truth true)).wellFormed = false ∧
    (Expr.andThen (.group (.orElse (.truth true) (.truth false))) (.truth true)).wellFormed = true ∧
    (Expr.eq (.choose (.truth true) (.number 0) (.number 1)) (.number 0)).wellFormed = false ∧
    (Expr.eq (.group (.choose (.truth true) (.number 0) (.number 1))) (.number 0)).wellFormed = true ∧
    (Expr.skip (.choose (.truth true) (.number 0) (.number 1))).wellFormed = false ∧
    (Expr.skip (.group (.choose (.truth true) (.number 0) (.number 1)))).wellFormed = true := by decide +kernel

end StructuralControls

structure Scope where
  locals : Local → Bool := fun _ => false
  context : Bool := false
  valueDeclared : Bool := false
  value : Bool := false

def Expr.scoped (scope : Scope) : Expr α → Bool
  | .local name => scope.locals name
  | .context => scope.context | .valueAfter => scope.value
  | .statePosition | .booleanCount | .scalarCount | .maxBooleans | .number _ | .truth _ |
      .arguments | .scalarNames | .initials | .contextOf | .invalid | .hiddenMark _ => true
  | .skip value | .nameAfter value | .take value _ | .initialFlow value | .not value | .group value => value.scoped scope
  | .nameIsBoolean first after | .nameIsMark _ first after | .formalHides first after | .lookup _ first after | .eq first after | .ne first after | .le first after |
      .orElse first after | .andThen first after => first.scoped scope && after.scoped scope
  | .newName first after allowArguments | .choose allowArguments first after =>
      first.scoped scope && after.scoped scope && allowArguments.scoped scope
  | .addBoolean position first after mutable =>
      position.scoped scope && first.scoped scope && after.scoped scope && mutable.scoped scope

inductive Command
  | letNat : Local → Expr Nat → Command → Command
  | letContext : Expr Context → Command → Command
  | declareValue : Expr Nat → Command → Command
  | declareFollowing : Command → Command
  | beginBody : Command → Command
  | guard : Expr Bool → Command → Command
  | setScalars : Expr ScalarExpression.Environment → Command → Command
  | setElaborating : Expr Bool → Command → Command
  | setMaskFirst : Expr Nat → Command → Command
  | setMaskAfter : Expr Nat → Command → Command
  | readCondition : Expr Nat → Expr ActiveFlow → Expr ArrayBindings.Initials → Command → Command
  | setFollowing : Expr Nat → Command → Command
  | returned : Expr ParserState → Command

def Command.eval (imports : Imports) (frame : Frame) : Command → ParserState
  | .letNat name value next => next.eval imports (frame.withLocal name (value.eval imports frame))
  | .letContext value next => next.eval imports {frame with context := value.eval imports frame}
  | .declareValue count next => next.eval imports {frame with valueCount := count.eval imports frame}
  | .declareFollowing next | .beginBody next => next.eval imports frame
  | .guard test next => if test.eval imports frame then imports.invalid else next.eval imports frame
  | .setScalars value next => next.eval imports {frame with context := {frame.context with scalarNames := value.eval imports frame}}
  | .setElaborating value next => next.eval imports {frame with context := {frame.context with elaborating := value.eval imports frame}}
  | .setMaskFirst value next => next.eval imports {frame with context := {frame.context with maskFirst := value.eval imports frame}}
  | .setMaskAfter value next => next.eval imports {frame with context := {frame.context with maskAfter := value.eval imports frame}}
  | .readCondition position facts initialValues next =>
      next.eval imports {frame with
        value := imports.conditionInto frame.text frame.context
          (position.eval imports frame) (facts.eval imports frame) frame.valueCount (initialValues.eval imports frame)}
  | .setFollowing value next => next.eval imports (frame.withLocal .following (value.eval imports frame))
  | .returned value => value.eval imports frame

def Command.render : Command → List String
  | .letNat name value next => [name.name, ":", "constant", "literal_position", ":="] ++ value.render ++ [";"] ++ next.render
  | .letContext value next => ["context", ":", "body_context", ":="] ++ value.render ++ [";"] ++ next.render
  | .declareValue count next => ["value", ":", "condition_result", "("] ++ count.render ++ [")", ";"] ++ next.render
  | .declareFollowing next => ["following", ":", "literal_position", ";"] ++ next.render
  | .beginBody next => ["begin"] ++ next.render
  | .guard test next => ["if"] ++ test.render ++ ["then", "return", "invalid_state", ";", "end", "if", ";"] ++ next.render
  | .setScalars value next => ["context", ".", "scalar_names", ":="] ++ value.render ++ [";"] ++ next.render
  | .setElaborating value next => ["context", ".", "elaborating", ":="] ++ value.render ++ [";"] ++ next.render
  | .setMaskFirst value next => ["context", ".", "mask_first", ":="] ++ value.render ++ [";"] ++ next.render
  | .setMaskAfter value next => ["context", ".", "mask_after", ":="] ++ value.render ++ [";"] ++ next.render
  | .readCondition position facts initialValues next => call ["read_condition_into"]
      [["text"], ["context"], position.render, facts.render, ["value"], initialValues.render] ++ [";"] ++ next.render
  | .setFollowing value next => ["following", ":="] ++ value.render ++ [";"] ++ next.render
  | .returned value => ["return"] ++ value.render ++ [";"]

def Command.wellFormed : Command → Bool
  | .letNat _ value next | .letContext value next | .declareValue value next | .setScalars value next |
      .setElaborating value next | .setMaskFirst value next | .setMaskAfter value next | .setFollowing value next =>
      value.primary && value.wellFormed && next.wellFormed
  | .declareFollowing next | .beginBody next => next.wellFormed
  | .guard test next => test.orHead && test.wellFormed && next.wellFormed
  | .readCondition position facts initialValues next => position.primary && facts.primary && initialValues.primary &&
      position.wellFormed && facts.wellFormed && initialValues.wellFormed && next.wellFormed
  | .returned value => value.primary && value.wellFormed

def Command.scoped (scope : Scope) : Command → Bool
  | .letNat name value next => value.scoped scope && next.scoped {scope with locals := fun other => if other = name then true else scope.locals other}
  | .letContext value next => value.scoped scope && next.scoped {scope with context := true}
  | .declareValue count next => count.scoped scope && next.scoped {scope with valueDeclared := true, value := false}
  | .declareFollowing next => next.scoped {scope with locals := fun other => if other = .following then false else scope.locals other}
  | .beginBody next => next.scoped scope
  | .guard test next => test.scoped scope && next.scoped scope
  | .setScalars value next | .setElaborating value next | .setMaskFirst value next | .setMaskAfter value next =>
      scope.context && value.scoped scope && next.scoped scope
  | .readCondition position facts initialValues next => scope.context && scope.valueDeclared && position.scoped scope &&
      facts.scoped scope && initialValues.scoped scope && next.scoped {scope with value := true}
  | .setFollowing value next => value.scoped scope && next.scoped {scope with locals := fun other => if other = .following then true else scope.locals other}
  | .returned value => value.scoped scope

def rejected : Expr Bool :=
  let base := Expr.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse
    (.not (.newName (.local .first) (.local .after) .arguments))
    (.eq (.local .typeAfter) (.number 0)))
    (.eq (.local .valueFirst) (.number 0)))
    (.eq .booleanCount .maxBooleans))
    (.nameIsBoolean (.local .first) (.local .after)))
    (.ne (.lookup .string (.local .typeFirst) (.local .typeAfter)) (.number 0)))
    (.ne (.lookup .scalar (.local .typeFirst) (.local .typeAfter)) (.number 0)))
    (.ne (.lookup .array (.local .typeFirst) (.local .typeAfter)) (.number 0)))
    (.ne (.lookup .subtype (.local .typeFirst) (.local .typeAfter)) (.number 0)))
    (.ne (.lookup .boolean (.local .typeFirst) (.local .typeAfter)) (.number 0))
  let hidden (mark : Mark) := Expr.group (.andThen (.hiddenMark mark)
    (.nameIsMark mark (.local .typeFirst) (.local .typeAfter)))
  .orElse (.orElse (.orElse (.orElse (.orElse (.orElse base
    (.ne (.lookup .function (.local .typeFirst) (.local .typeAfter)) (.number 0)))
    (.ne (.lookup .procedure (.local .typeFirst) (.local .typeAfter)) (.number 0)))
    (.formalHides (.local .typeFirst) (.local .typeAfter)))
    (hidden .integer)) (hidden .boolean)) (hidden .character)

def body : Command :=
  .letNat .first (.skip .statePosition) <|
  .letNat .after (.nameAfter (.local .first)) <|
  .letNat .colonAfter (.take (.local .after) .colon) <|
  .letNat .constantAfter (.take (.local .colonAfter) .constantKeyword) <|
  .letNat .typeFirst (.skip (.group (.choose (.ne (.local .constantAfter) (.number 0))
    (.local .constantAfter) (.local .colonAfter)))) <|
  .letNat .typeAfter (.take (.local .typeFirst) .booleanName) <|
  .letNat .valueFirst (.take (.local .typeAfter) .assignment) <|
  .letContext .contextOf <|
  .declareValue .scalarCount <|
  .declareFollowing <| .beginBody <|
  .guard rejected <|
  .setScalars .scalarNames <|
  .setElaborating (.truth true) <|
  .setMaskFirst (.local .first) <|
  .setMaskAfter (.local .after) <|
  .readCondition (.local .valueFirst) (.initialFlow .context) .initials <|
  .setFollowing (.take .valueAfter .semicolon) <|
  .guard (.le (.local .following) .statePosition) <|
  .returned (.addBoolean (.local .following) (.local .first) (.local .after)
    (.eq (.local .constantAfter) (.number 0)))

def rendered : List String := body.render ++ ["end", "boolean_declaration_at", ";"]

theorem checked_precedence : body.wellFormed = true := by decide +kernel

theorem checked_scope : body.scoped {} = true := by decide +kernel

def parts (imports : Imports) (text : Source) (state : ParserState) : BooleanDeclarationParts :=
  let first := imports.skip text state.position
  let after := imports.nameAfter text first
  let colonAfter := imports.take text after .colon
  let constantAfter := imports.take text colonAfter .constantKeyword
  let typeFirst := imports.skip text (if constantAfter ≠ 0 then constantAfter else colonAfter)
  let typeAfter := imports.take text typeFirst .booleanName
  ⟨first, after, constantAfter, typeFirst, typeAfter, imports.take text typeAfter .assignment⟩

def reject (imports : Imports) (text : Source) (state : ParserState) (arguments : Bool) (p : BooleanDeclarationParts) : Bool :=
  !imports.newName text state p.first p.after arguments || decide (p.typeAfter = 0) || decide (p.valueFirst = 0) ||
    decide (state.booleanNames.length = BooleanBindings.maxBindings) || imports.nameIsBoolean text p.first p.after ||
    decide (imports.lookup .string text state p.typeFirst p.typeAfter ≠ 0) ||
    decide (imports.lookup .scalar text state p.typeFirst p.typeAfter ≠ 0) ||
    decide (imports.lookup .array text state p.typeFirst p.typeAfter ≠ 0) ||
    decide (imports.lookup .subtype text state p.typeFirst p.typeAfter ≠ 0) ||
    decide (imports.lookup .boolean text state p.typeFirst p.typeAfter ≠ 0) ||
    decide (imports.lookup .function text state p.typeFirst p.typeAfter ≠ 0) ||
    decide (imports.lookup .procedure text state p.typeFirst p.typeAfter ≠ 0) ||
    imports.formalHides text state p.typeFirst p.typeAfter ||
    (state.hiding.integerHidden && imports.nameIsMark .integer text p.typeFirst p.typeAfter) ||
    (state.hiding.booleanHidden && imports.nameIsMark .boolean text p.typeFirst p.typeAfter) ||
    (state.hiding.characterHidden && imports.nameIsMark .character text p.typeFirst p.typeAfter)

def elaborationContext (imports : Imports) (state : ParserState) (p : BooleanDeclarationParts) : Context :=
  {imports.contextOf ⟨state, false, false⟩ with
    scalarNames := state.scalarNames
    elaborating := true
    maskFirst := p.first
    maskAfter := p.after}

def equation (imports : Imports) (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  let p := parts imports text state
  if reject imports text state arguments p then imports.invalid else
    let context := elaborationContext imports state p
    let value := imports.conditionInto text context p.valueFirst (imports.initialFlow context)
      state.scalarNames.length state.arrayNames.values
    let following := imports.take text value.after .semicolon
    if following ≤ state.position then imports.invalid else
      {state with position := following, booleanNames := state.booleanNames ++ [⟨p.first, p.after, decide (p.constantAfter = 0)⟩]}

theorem denotation (imports : Imports) (text : Source) (state : ParserState) (arguments : Bool) :
    body.eval imports {text, state, arguments} = equation imports text state arguments := by
  dsimp +instances only [body, Command.eval, Expr.eval, Frame.withLocal,
    rejected, equation, parts, reject, elaborationContext, Mark.hidden]
  simp only [reduceCtorEq, ↓reduceIte, decide_eq_true_eq]

theorem model_parts (text : Source) (state : ParserState) :
    parts modelImports text state = booleanDeclarationParts text state := rfl

theorem model_context (state : ParserState) (p : BooleanDeclarationParts) :
    (elaborationContext modelImports state p).model = booleanDeclarationContext state p := rfl

theorem model_facts (state : ParserState) (p : BooleanDeclarationParts) :
    initialFlow (elaborationContext modelImports state p) = booleanDeclarationFacts state := rfl

theorem model_reject (text : Source) (state : ParserState) (arguments : Bool) (p : BooleanDeclarationParts) :
    reject modelImports text state arguments p = !booleanDeclarationReady text state arguments p := by
  simp [reject, modelImports, lookup, Mark.word, booleanDeclarationReady, Bool.decide_and,
    Bool.not_and, Bool.or_assoc]

theorem model_meaning (text : Source) (state : ParserState) (arguments : Bool) :
    body.eval modelImports {text, state, arguments} = booleanDeclarationAt text state arguments := by
  rw [denotation]
  unfold equation
  simp only [model_parts, model_reject]
  rfl

end Silver.Compose.BooleanDeclarationNative
