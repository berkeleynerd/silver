module

public import Silver.ImageModelNameSource
public import Silver.ImageModelTheoryNative

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.StringNative

inductive Mode
  | between | string | escape | unicode | number | literal
  deriving DecidableEq

structure Frame where
  failed : Bool
  matcher : Native.Matcher
  name : DecodedNative.RawName
  mode : Mode
  phase : TheoryNative.Phase
  theory : Option Native.Theory
  isKey : Bool
  isTheoryTag : Bool
  isName : Bool
  isTag : Bool
  nodeIdPending : Bool

abbrev NameCall := DecodedNative.RawName → List Nat → Bool

inductive Name
  | key | theoryTag | integer | string | image
  deriving DecidableEq

def Name.text : Name → String
  | .key => "theory_declarations" | .theoryTag => "W_THEORY_DECLARATION"
  | .integer => "Standard__integer" | .string => "Standard__string" | .image => "Standard_String__Img"

def Name.bytes (name : Name) : List Nat := name.text.toList.map Char.toNat

def Name.render (name : Name) : List String :=
  ["named", "(", "current", ",", String.ofList ('"' :: (name.text.toList ++ ['"'])), ")"]

inductive Test
  | isKey | isTheoryTag | isName | named (name : Name) | notNamed (name : Name)
  deriving DecidableEq

def Test.eval (namedCall : NameCall) (frame : Frame) : Test → Bool
  | .isKey => frame.isKey | .isTheoryTag => frame.isTheoryTag | .isName => frame.isName
  | .named name => namedCall frame.name name.bytes | .notNamed name => !(namedCall frame.name name.bytes)

def Test.render : Test → List String
  | .isKey => ["current", ".", "string_is_key"]
  | .isTheoryTag => ["current", ".", "string_is_theory_tag"]
  | .isName => ["current", ".", "string_is_name"]
  | .named name => name.render | .notNamed name => "not" :: name.render

inductive Action
  | quote | between | colon | fail | select (theory : Native.Theory) | pending
  deriving DecidableEq

def pending (frame : Frame) : Bool := frame.isTag && decide (2 ≤ frame.name.length) &&
  decide (frame.name.buffer 1 = 87 ∧ frame.name.buffer 2 = 95)

def Action.eval (matchCall : DecodedNative.MatchCall) (frame : Frame) : Action → Frame
  | .quote => {frame with matcher := matchCall frame.matcher 34}
  | .between => {frame with mode := .between}
  | .colon => {frame with phase := .rootColon}
  | .fail => {frame with failed := true}
  | .select theory => {frame with theory := some theory}
  | .pending => {frame with nodeIdPending := StringNative.pending frame}

def theoryName : Native.Theory → String
  | .integer => "integer_theory" | .string => "string_theory" | .image => "image_theory"

def Action.render : Action → List String
  | .quote => ["match_byte", "(", "current", ",", "'\"'", ")", ";"]
  | .between => ["current", ".", "mode", ":=", "between_tokens", ";"]
  | .colon => ["current", ".", "phase", ":=", "root_colon", ";"]
  | .fail => ["current", ".", "failed", ":=", "true", ";"]
  | .select theory => ["current", ".", "theory", ":=", theoryName theory, ";"]
  | .pending => ["current", ".", "node_id_pending", ":=", "current", ".", "string_is_tag", "and", "then",
      "current", ".", "string_length", ">=", "2", "and", "then", "current", ".", "string_prefix", "(",
      "1", "..", "2", ")", "=", "\"W_\"", ";"]

inductive Command
  | skip | action (value : Action) | sequence (first second : Command)
  | choose (test : Test) (yes no : Command)
  deriving DecidableEq

def Command.eval (matchCall : DecodedNative.MatchCall) (namedCall : NameCall) (frame : Frame) : Command → Frame
  | .skip => frame | .action value => value.eval matchCall frame
  | .sequence first second => second.eval matchCall namedCall (first.eval matchCall namedCall frame)
  | .choose test yes no => if test.eval namedCall frame then yes.eval matchCall namedCall frame else no.eval matchCall namedCall frame

mutual
  def Command.render : Command → List String
    | .skip => [] | .action value => value.render
    | .sequence first second => first.render ++ second.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
  def Command.renderElse : Command → List String
    | .skip => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | value => ["else"] ++ value.render
end

def Command.list (items : List Command) : Command := items.foldr .sequence .skip

def selectCommands : Command := .choose (.named .integer) (.action (.select .integer))
  (.choose (.named .string) (.action (.select .string)) (.choose (.named .image) (.action (.select .image)) .skip))

def classifyCommands : Command :=
  .choose .isKey (.choose (.named .key) (.action .colon) (.action .fail))
    (.choose .isTheoryTag (.choose (.notNamed .theoryTag) (.action .fail) .skip)
      (.choose .isName selectCommands .skip))

def commands : Command := .list [.action .quote, .action .between, classifyCommands, .action .pending]

def render : List String := ["procedure", "end_string", "(", "current", ":", "in", "out", "state", ")", "is", "begin"] ++
  commands.render ++ ["end", "end_string", ";"]

def classification (namedCall : NameCall) (state : DecodedNative.RawName) (old : Option Native.Theory) : Option Native.Theory :=
  if namedCall state Name.integer.bytes then some .integer
  else if namedCall state Name.string.bytes then some .string
  else if namedCall state Name.image.bytes then some .image
  else old

def model (matchCall : DecodedNative.MatchCall) (namedCall : NameCall) (frame : Frame) : Frame :=
  {frame with
    matcher := matchCall frame.matcher 34
    mode := .between
    phase := (if frame.isKey && namedCall frame.name Name.key.bytes then .rootColon else frame.phase)
    failed := (if frame.isKey then if namedCall frame.name Name.key.bytes then frame.failed else true
      else if frame.isTheoryTag && !(namedCall frame.name Name.theoryTag.bytes) then true else frame.failed)
    theory := (if !frame.isKey && !frame.isTheoryTag && frame.isName then classification namedCall frame.name frame.theory else frame.theory)
    nodeIdPending := pending frame}

theorem eval_model (matchCall : DecodedNative.MatchCall) (namedCall : NameCall) (frame : Frame) :
    commands.eval matchCall namedCall frame = model matchCall namedCall frame := by
  cases key : frame.isKey <;> cases tag : frame.isTheoryTag <;> cases name : frame.isName <;>
    simp only [commands, Command.list, List.foldr_cons, List.foldr_nil, Command.eval,
      classifyCommands, selectCommands, Test.eval, Action.eval, key, tag, name, model,
      classification, pending, Bool.false_eq_true, Bool.not_false, Bool.not_true,
      Bool.true_and, Bool.false_and, Bool.and_true, Bool.and_false, ↓reduceIte]
  all_goals split <;> simp_all
  all_goals split <;> simp_all
  all_goals split <;> simp_all

/-- Static targets all fit the bounded name recognizer and contain only ASCII. -/
theorem names_legal (name : Name) : name.bytes.length ≤ 21 ∧ ∀ byte ∈ name.bytes, byte < 127 := by
  cases name <;> decide +kernel

end Silver.ImageModel.StringNative
