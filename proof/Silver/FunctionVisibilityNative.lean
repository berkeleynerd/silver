module

public import Silver.FunctionDeclarationAdmission
public import Silver.FunctionBindingsNativeEquations
public import Silver.SourceDeclarations

@[expose] public section

/-! Typed interpretations of the five function-visibility helpers. Quantified
name tests are explicit syntax constructors for the written active-prefix or
formal-suffix traversal, including the array, binder, and primitive call. -/
namespace Silver.Compose.FunctionVisibilityNative

inductive Mark | integer | boolean | character | trueLiteral | falseLiteral
  deriving DecidableEq, Repr

def Mark.word : Mark → String
  | .integer => "integer" | .boolean => "boolean" | .character => "character"
  | .trueLiteral => "true" | .falseLiteral => "false"
def Mark.field (mark : Mark) : String := mark.word ++ "_hidden"
def Mark.get (mark : Mark) (flags : HiddenMarks) : Bool :=
  match mark with
  | .integer => flags.integerHidden | .boolean => flags.booleanHidden
  | .character => flags.characterHidden | .trueLiteral => flags.trueHidden | .falseLiteral => flags.falseHidden

inductive Table | strings | scalars | booleans | arrays | arrayTypes | subtypes
  deriving DecidableEq, Repr

def Table.path : Table → List String
  | .strings => ["names"] | .scalars => ["scalar_names"] | .booleans => ["boolean_names"]
  | .arrays => ["array_names", ".", "names"]
  | .arrayTypes => ["array_names", ".", "names", ".", "types"] | .subtypes => ["subtype_names"]
def Table.spans (table : Table) (state : ParserState) : List (Nat × Nat) :=
  match table with
  | .strings => state.names.map fun item => (item.first, item.after)
  | .scalars => state.scalarNames.map fun item => (item.first, item.after)
  | .booleans => state.booleanNames.map fun item => (item.first, item.after)
  | .arrays => state.arrayNames.names.map fun item => (item.first, item.after)
  | .arrayTypes => state.arrayNames.types.map fun item => (item.first, item.after)
  | .subtypes => state.subtypeNames.items.map fun item => (item.first, item.after)

structure Calls where
  nameIs : Source → Nat → Nat → Source → Bool
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  functionHides : Source → FunctionBindings.Metadata → String → Bool
  hiddenWord : Source → ParserState → String → Bool

structure Frame where
  text : Source := []
  state : ParserState := initialState
  catalog : FunctionBindings.Metadata := {}
  flags : HiddenMarks := {}
  first : Nat := 0
  after : Nat := 0
  word : String := ""

inductive Expr
  | firstPositive | afterGreater | firstParameterNonzero | firstProcedureParameterNonzero
  | catalogNames | formalNames | procedureNames | procedureFormalNames
  | tableNames : Table → Expr
  | functionHides | hiddenWord : Mark → Expr
  | outerMark : Mark → Expr | inputMark : Mark → Expr | inputName : Mark → Expr
  | andThen : Expr → Expr → Expr | orElse : Expr → Expr → Expr | or : Expr → Expr → Expr
  | group : Expr → Expr

/-- One-based native parameter indices select exactly this list suffix whenever
First_Parameter is positive. The enclosing checked conjunction provides that
guard, so the index-zero native array access is never interpreted. -/
def Expr.eval (calls : Calls) (frame : Frame) : Expr → Bool
  | .firstPositive => decide (frame.first > 0)
  | .afterGreater => decide (frame.after > frame.first)
  | .firstParameterNonzero => decide (frame.state.firstParameter ≠ 0)
  | .firstProcedureParameterNonzero => decide (frame.state.firstProcedureParameter ≠ 0)
  | .catalogNames => frame.catalog.items.any fun item =>
      calls.nameIs frame.text item.first item.after (frame.word.toList.map Char.toNat)
  | .formalNames => (frame.state.functions.parameters.drop (frame.state.firstParameter - 1)).any fun item =>
      calls.equalName frame.text item.first item.after frame.first frame.after
  | .procedureNames => frame.state.procedures.items.any fun item =>
      calls.nameIs frame.text item.first item.after (frame.word.toList.map Char.toNat)
  | .procedureFormalNames =>
      (frame.state.procedures.parameters.drop (frame.state.firstProcedureParameter - 1)).any fun item =>
        calls.equalName frame.text item.first item.after frame.first frame.after
  | .tableNames table => (table.spans frame.state).any fun span =>
      calls.nameIs frame.text span.1 span.2 (frame.word.toList.map Char.toNat)
  | .functionHides => calls.functionHides frame.text frame.state.functions frame.word
  | .hiddenWord mark => calls.hiddenWord frame.text frame.state mark.word
  | .outerMark mark => mark.get frame.state.hiding
  | .inputMark mark => mark.get frame.flags
  | .inputName mark => calls.nameIs frame.text frame.first frame.after (mark.word.toList.map Char.toNat)
  | .andThen left right => left.eval calls frame && right.eval calls frame
  | .orElse left right | .or left right => left.eval calls frame || right.eval calls frame
  | .group value => value.eval calls frame

def call (name : String) (arguments : List (List String)) : List String :=
  [name, "("] ++ (arguments.intersperse [","]).flatten ++ [")"]

def Expr.render : Expr → List String
  | .firstPositive => ["first", ">", "0"]
  | .afterGreater => ["after", ">", "first"]
  | .firstParameterNonzero => ["state", ".", "first_parameter", "/=", "0"]
  | .firstProcedureParameterNonzero => ["state", ".", "first_procedure_parameter", "/=", "0"]
  | .catalogNames => ["for", "some", "index", "in", "1", "..", "catalog", ".", "count", "=>"] ++
      call "name_is" [["text"], ["catalog", ".", "items", "(", "index", ")", ".", "first"],
        ["catalog", ".", "items", "(", "index", ")", ".", "after"], ["word"]]
  | .formalNames => ["for", "some", "index", "in", "state", ".", "first_parameter", "..",
      "state", ".", "functions", ".", "parameter_count", "=>"] ++
      call "equal_name" [["text"], ["state", ".", "functions", ".", "parameters", "(", "index", ")", ".", "first"],
        ["state", ".", "functions", ".", "parameters", "(", "index", ")", ".", "after"], ["first"], ["after"]]
  | .procedureNames => ["for", "some", "index", "in", "1", "..", "state", ".", "procedures", ".", "count", "=>"] ++
      call "name_is" [["text"], ["state", ".", "procedures", ".", "items", "(", "index", ")", ".", "first"],
        ["state", ".", "procedures", ".", "items", "(", "index", ")", ".", "after"], ["word"]]
  | .procedureFormalNames => ["for", "some", "index", "in", "state", ".", "first_procedure_parameter", "..",
      "state", ".", "procedures", ".", "parameter_count", "=>"] ++
      call "equal_name" [["text"], ["state", ".", "procedures", ".", "parameters", "(", "index", ")", ".", "first"],
        ["state", ".", "procedures", ".", "parameters", "(", "index", ")", ".", "after"], ["first"], ["after"]]
  | .tableNames table =>
      let base := ["state", "."] ++ table.path
      ["for", "some", "i", "in", "1", ".."] ++ base ++ [".", "count", "=>"] ++
        call "name_is" [["text"], base ++ [".", "items", "(", "i", ")", ".", "first"],
          base ++ [".", "items", "(", "i", ")", ".", "after"], ["word"]]
  | .functionHides => call "function_hides" [["text"], ["state", ".", "functions"], ["word"]]
  | .hiddenWord mark => call "hidden_word" [["text"], ["state"], ["\"" ++ mark.word ++ "\""]]
  | .outerMark mark => ["state", ".", "hiding", ".", mark.field]
  | .inputMark mark => ["hiding", ".", mark.field]
  | .inputName mark => call "name_is" [["text"], ["first"], ["after"], ["\"" ++ mark.word ++ "\""]]
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .or left right => left.render ++ ["or"] ++ right.render
  | .group value => ["("] ++ value.render ++ [")"]

def Expr.primary : Expr → Bool
  | .functionHides | .hiddenWord _ | .outerMark _ | .inputMark _ | .inputName _ | .group _ => true
  | _ => false
def Expr.relation : Expr → Bool
  | .firstPositive | .afterGreater | .firstParameterNonzero | .firstProcedureParameterNonzero => true
  | value => value.primary
def Expr.andHead : Expr → Bool | .andThen _ _ => true | value => value.relation
def Expr.orElseHead : Expr → Bool | .orElse _ _ => true | value => value.relation
def Expr.orHead : Expr → Bool | .or _ _ => true | value => value.relation
def Expr.wellFormed : Expr → Bool
  | .firstPositive | .afterGreater | .firstParameterNonzero | .firstProcedureParameterNonzero |
      .catalogNames | .formalNames | .procedureNames | .procedureFormalNames | .tableNames _ |
      .functionHides | .hiddenWord _ | .outerMark _ | .inputMark _ | .inputName _ => true
  | .andThen left right => left.andHead && right.relation && left.wellFormed && right.wellFormed
  | .orElse left right => left.orElseHead && right.relation && left.wellFormed && right.wellFormed
  | .or left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .group value => value.wellFormed

structure Scope where
  state : Bool := false
  catalog : Bool := false
  flags : Bool := false
  positions : Bool := false
  word : Bool := false

def Expr.scoped (scope : Scope) : Expr → Bool
  | .firstPositive | .afterGreater => scope.positions
  | .firstParameterNonzero | .firstProcedureParameterNonzero => scope.state
  | .catalogNames => scope.catalog && scope.word
  | .formalNames | .procedureFormalNames => scope.state && scope.positions
  | .tableNames _ | .functionHides | .procedureNames => scope.state && scope.word
  | .hiddenWord _ | .outerMark _ => scope.state
  | .inputMark _ => scope.flags
  | .inputName _ => scope.positions
  | .andThen left right | .orElse left right | .or left right => left.scoped scope && right.scoped scope
  | .group value => value.scoped scope

def functionHidesBody : Expr := .catalogNames
def formalHidesBody : Expr := .andThen (.andThen .firstPositive .afterGreater)
  (.group (.orElse (.group (.andThen .firstParameterNonzero (.group .formalNames)))
    (.group (.andThen .firstProcedureParameterNonzero (.group .procedureFormalNames)))))
def hiddenWordBody : Expr := .orElse (.orElse (.orElse (.orElse (.orElse (.orElse
  (.orElse .functionHides (.group .procedureNames))
  (.group (.tableNames .strings))) (.group (.tableNames .scalars))) (.group (.tableNames .booleans)))
  (.group (.tableNames .arrays))) (.group (.tableNames .arrayTypes))) (.group (.tableNames .subtypes))

def marks : List Mark := [.integer, .boolean, .character, .trueLiteral, .falseLiteral]
def hiddenOuterField (mark : Mark) : Expr := .or (.outerMark mark) (.hiddenWord mark)
def hideNameField (mark : Mark) : Expr := .or (.inputMark mark) (.inputName mark)

def renderMarks (field : Mark → Expr) : List String :=
  ((marks.map fun mark => [mark.field, "=>"] ++ (field mark).render).intersperse [","]).flatten

def evalMarks (calls : Calls) (frame : Frame) (field : Mark → Expr) : HiddenMarks :=
  ⟨(field .integer).eval calls frame, (field .boolean).eval calls frame,
   (field .character).eval calls frame, (field .trueLiteral).eval calls frame, (field .falseLiteral).eval calls frame⟩

def modelCalls : Calls := ⟨Named.nameIs, Named.equalName, Compose.functionHides, Compose.hiddenWord⟩

theorem functionHides_model (text : Source) (catalog : FunctionBindings.Metadata) (word : String) :
    functionHidesBody.eval modelCalls {text, catalog, word} = functionHides text catalog word := rfl

theorem formalHides_model (text : Source) (state : ParserState) (first after : Nat) :
    formalHidesBody.eval modelCalls {text, state, first, after} = formalHides text state first after := by
  simp only [formalHidesBody, Expr.eval, modelCalls, formalHides, Bool.decide_and, Bool.and_assoc]

theorem hiddenWord_model (text : Source) (state : ParserState) (word : String) :
    hiddenWordBody.eval modelCalls {text, state, word} = hiddenWord text state word := by
  simp only [hiddenWordBody, Expr.eval, Table.spans, List.any_map, Function.comp_def, modelCalls, hiddenWord]

theorem hiddenOuter_model (text : Source) (state : ParserState) :
    evalMarks modelCalls {text, state} hiddenOuterField = hiddenOuter text state := rfl

theorem hideName_model (text : Source) (flags : HiddenMarks) (first after : Nat) :
    evalMarks modelCalls {text, flags, first, after} hideNameField = hideName text flags first after := rfl

end Silver.Compose.FunctionVisibilityNative
