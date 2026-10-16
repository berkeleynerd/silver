module

public import Silver.ImageModelCharacter

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- The scanner uses only this finite collection of field accesses, arithmetic,
conditions, assignments, helper calls, and structured control-flow forms. Both
source rendering and evaluation recurse on the same syntax. -/
structure Frame where
  state : Core.State
  item : Nat
  digit : Nat := 0

inductive NumberField
  | bytes | depth | field | candidateDeclarations | candidateIncludes
  | greatestId | numberValue | stringLength | unicodeLeft | unicodeValue | digit
  deriving DecidableEq

def NumberField.name : NumberField → String
  | .bytes => "bytes" | .depth => "depth" | .field => "field"
  | .candidateDeclarations => "candidate_declarations" | .candidateIncludes => "candidate_includes"
  | .greatestId => "greatest_id" | .numberValue => "number_value" | .stringLength => "string_length"
  | .unicodeLeft => "unicode_left" | .unicodeValue => "unicode_value" | .digit => "digit"

def NumberField.render (slot : NumberField) : List String :=
  if slot = .digit then ["digit"] else ["current", ".", slot.name]

def NumberField.get (frame : Frame) : NumberField → Nat
  | .bytes => frame.state.bytes | .depth => frame.state.depth | .field => frame.state.field
  | .candidateDeclarations => frame.state.candidateDeclarations | .candidateIncludes => frame.state.candidateIncludes
  | .greatestId => frame.state.greatestId | .numberValue => frame.state.numberValue
  | .stringLength => frame.state.name.length | .unicodeLeft => frame.state.unicodeLeft
  | .unicodeValue => frame.state.unicodeValue | .digit => frame.digit

def NumberField.set (frame : Frame) (value : Nat) : NumberField → Frame
  | .bytes => {frame with state.bytes := value} | .depth => {frame with state.depth := value}
  | .field => {frame with state.field := value}
  | .candidateDeclarations => {frame with state.candidateDeclarations := value}
  | .candidateIncludes => {frame with state.candidateIncludes := value}
  | .greatestId => {frame with state.greatestId := value}
  | .numberValue => {frame with state.numberValue := value}
  | .stringLength => {frame with state.name.length := value}
  | .unicodeLeft => {frame with state.unicodeLeft := value}
  | .unicodeValue => {frame with state.unicodeValue := value}
  | .digit => {frame with digit := value}

inductive Flag
  | failed | inTheory | previousArrayStart | nodeIdPending | numberIsId | numberDigits
  | isTag | isKey | isName | isTheoryTag
  deriving DecidableEq

def Flag.name : Flag → String
  | .failed => "failed" | .inTheory => "in_theory" | .previousArrayStart => "previous_array_start"
  | .nodeIdPending => "node_id_pending" | .numberIsId => "number_is_id" | .numberDigits => "number_digits"
  | .isTag => "string_is_tag" | .isKey => "string_is_key" | .isName => "string_is_name"
  | .isTheoryTag => "string_is_theory_tag"

def Flag.get (frame : Frame) : Flag → Bool
  | .failed => frame.state.failed | .inTheory => frame.state.matcher.inTheory
  | .previousArrayStart => frame.state.previousArrayStart | .nodeIdPending => frame.state.nodeIdPending
  | .numberIsId => frame.state.numberIsId | .numberDigits => frame.state.numberDigits
  | .isTag => frame.state.isTag | .isKey => frame.state.isKey | .isName => frame.state.isName
  | .isTheoryTag => frame.state.isTheoryTag

def Flag.set (frame : Frame) (value : Bool) : Flag → Frame
  | .failed => {frame with state.failed := value} | .inTheory => {frame with state.matcher.inTheory := value}
  | .previousArrayStart => {frame with state.previousArrayStart := value}
  | .nodeIdPending => {frame with state.nodeIdPending := value}
  | .numberIsId => {frame with state.numberIsId := value} | .numberDigits => {frame with state.numberDigits := value}
  | .isTag => {frame with state.isTag := value} | .isKey => {frame with state.isKey := value}
  | .isName => {frame with state.isName := value} | .isTheoryTag => {frame with state.isTheoryTag := value}

inductive CharacterValue
  | item | literal (code : Nat) | ordinal (code : Nat)
  deriving DecidableEq

def CharacterValue.eval (frame : Frame) : CharacterValue → Nat
  | .item => frame.item | .literal code | .ordinal code => code

def CharacterValue.render : CharacterValue → List String
  | .item => ["item"]
  | .literal code => [String.ofList ['\'', Char.ofNat code, '\'']]
  | .ordinal code => ["character", "'", "val", "(", toString code, ")"]

inductive Choice
  | single (value : CharacterValue) | range (first last : CharacterValue)
  deriving DecidableEq

def Choice.accepts (frame : Frame) : Choice → Bool
  | .single value => decide (frame.item = value.eval frame)
  | .range first last => decide (first.eval frame ≤ frame.item ∧ frame.item ≤ last.eval frame)

def Choice.render : Choice → List String
  | .single value => value.render | .range first last => first.render ++ [".."] ++ last.render

def choicesRender (choices : List Choice) : List String :=
  (choices.map Choice.render).intersperse ["|"] |>.flatten

def modeName : StringNative.Mode → String
  | .between => "between_tokens" | .string => "in_string" | .escape => "after_escape"
  | .unicode => "in_unicode" | .number => "in_number" | .literal => "in_literal"

def phaseName : TheoryNative.Phase → String
  | .beforeRoot => "before_root" | .rootKey => "root_key" | .rootColon => "root_colon"
  | .rootList => "root_list" | .firstTheory => "first_theory" | .nextTheory => "next_theory"
  | .theorySeparator => "theory_separator" | .rootEnd => "root_end" | .afterRoot => "after_root"

inductive Number
  | literal (value : Nat) | unicodeMaximum | byteMaximum | idMaximum
  | field (value : NumberField) | ordinal (value : CharacterValue)
  | add (left right : Number) | sub (left right : Number)
  | mul (left right : Number) | div (left right : Number)
  | parens (value : Number) | idMaximumOf (left right : Number) | hex
  deriving DecidableEq

def Number.eval (helpers : Core.Helpers) (frame : Frame) : Number → Nat
  | .literal value => value | .unicodeMaximum => 65535 | .byteMaximum => 9223372036854775807
  | .idMaximum => originalIdMaximum | .field value => value.get frame
  | .ordinal value => value.eval frame
  | .add left right => left.eval helpers frame + right.eval helpers frame
  | .sub left right => left.eval helpers frame - right.eval helpers frame
  | .mul left right => left.eval helpers frame * right.eval helpers frame
  | .div left right => left.eval helpers frame / right.eval helpers frame
  | .parens value => value.eval helpers frame
  | .idMaximumOf left right => max (left.eval helpers frame) (right.eval helpers frame)
  | .hex => helpers.hex frame.item

def Number.render : Number → List String
  | .literal value => [toString value] | .unicodeMaximum => ["65_535"]
  | .byteMaximum => ["byte_count", "'", "last"] | .idMaximum => ["original_node_id", "'", "last"]
  | .field value => value.render
  | .ordinal value => ["character", "'", "pos", "("] ++ value.render ++ [")"]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .sub left right => left.render ++ ["-"] ++ right.render
  | .mul left right => left.render ++ ["*"] ++ right.render
  | .div left right => left.render ++ ["/"] ++ right.render
  | .parens value => ["("] ++ value.render ++ [")"]
  | .idMaximumOf left right => ["original_node_id", "'", "max", "("] ++ left.render ++ [","] ++ right.render ++ [")"]
  | .hex => ["hex", "(", "item", ")"]

inductive Comparison
  | equal | less | greater | atMost
  deriving DecidableEq

def Comparison.eval (left right : Nat) : Comparison → Bool
  | .equal => decide (left = right) | .less => decide (left < right)
  | .greater => decide (left > right) | .atMost => decide (left ≤ right)

def Comparison.render : Comparison → String
  | .equal => "=" | .less => "<" | .greater => ">" | .atMost => "<="

inductive Test
  | constant (value : Bool) | flag (value : Flag) | negated (value : Test)
  | both (left right : Test) | either (left right : Test) | parens (value : Test)
  | number (comparison : Comparison) (left right : Number)
  | mode (value : StringNative.Mode) | phase (value : TheoryNative.Phase)
  | phaseIn (values : List TheoryNative.Phase)
  | itemEquals (value : CharacterValue) | itemDifferent (value : CharacterValue)
  | itemIn (values : List Choice) | itemNotIn (values : List Choice)
  deriving DecidableEq

def Test.eval (helpers : Core.Helpers) (frame : Frame) : Test → Bool
  | .constant value => value | .flag value => value.get frame | .negated value => !(value.eval helpers frame)
  | .both left right => left.eval helpers frame && right.eval helpers frame
  | .either left right => left.eval helpers frame || right.eval helpers frame
  | .parens value => value.eval helpers frame
  | .number comparison left right => comparison.eval (left.eval helpers frame) (right.eval helpers frame)
  | .mode value => decide (frame.state.mode = value) | .phase value => decide (frame.state.phase = value)
  | .phaseIn values => values.contains frame.state.phase
  | .itemEquals value => decide (frame.item = value.eval frame)
  | .itemDifferent value => decide (frame.item ≠ value.eval frame)
  | .itemIn values => values.any (Choice.accepts frame)
  | .itemNotIn values => !(values.any (Choice.accepts frame))

def Test.render : Test → List String
  | .constant value => [if value then "true" else "false"]
  | .flag value => ["current", ".", value.name] | .negated value => "not" :: value.render
  | .both left right => left.render ++ ["and", "then"] ++ right.render
  | .either left right => left.render ++ ["or", "else"] ++ right.render
  | .parens value => ["("] ++ value.render ++ [")"]
  | .number comparison left right => left.render ++ [comparison.render] ++ right.render
  | .mode value => ["current", ".", "mode", "=", modeName value]
  | .phase value => ["current", ".", "phase", "=", phaseName value]
  | .phaseIn values => ["current", ".", "phase", "in"] ++ ((values.map (fun v => [phaseName v])).intersperse ["|"]).flatten
  | .itemEquals value => ["item", "="] ++ value.render
  | .itemDifferent value => ["item", "/="] ++ value.render
  | .itemIn values => ["item", "in"] ++ choicesRender values
  | .itemNotIn values => ["item", "not", "in"] ++ choicesRender values

inductive Action
  | number (slot : NumberField) (value : Number) | flag (slot : Flag) (value : Test)
  | mode (value : StringNative.Mode) | phase (value : TheoryNative.Phase)
  | otherTheory | zeroMatched | liveAll | spaces
  | matchByte (value : CharacterValue) | decoded (value : Number)
  | endString | endTheory | structural
  deriving DecidableEq

abbrev StructuralCall := Core.State → Nat → Core.State

def Action.eval (helpers : Core.Helpers) (structuralCall : StructuralCall) (frame : Frame) : Action → Frame
  | .number slot value => slot.set frame (value.eval helpers frame)
  | .flag slot value => slot.set frame (value.eval helpers frame)
  | .mode value => {frame with state.mode := value} | .phase value => {frame with state.phase := value}
  | .otherTheory => {frame with state.theory := none}
  | .zeroMatched => {frame with state.matcher.cells := fun kind => {frame.state.matcher.cells kind with position := 0}}
  | .liveAll => {frame with state.matcher.cells := fun kind => {frame.state.matcher.cells kind with live := true}}
  | .spaces => {frame with state.name.buffer := fun _ => 32}
  | .matchByte value => {frame with state := helpers.matchByte frame.state (value.eval frame)}
  | .decoded value => {frame with state := helpers.decoded frame.state (value.eval helpers frame)}
  | .endString => {frame with state := helpers.endString frame.state}
  | .endTheory => {frame with state := helpers.endTheory frame.state}
  | .structural => {frame with state := structuralCall frame.state frame.item}

def Action.render : Action → List String
  | .number slot value => slot.render ++ [":="] ++ value.render ++ [";"]
  | .flag slot value => ["current", ".", slot.name, ":="] ++ value.render ++ [";"]
  | .mode value => ["current", ".", "mode", ":=", modeName value, ";"]
  | .phase value => ["current", ".", "phase", ":=", phaseName value, ";"]
  | .otherTheory => ["current", ".", "theory", ":=", "other_theory", ";"]
  | .zeroMatched => ["current", ".", "matched", ":=", "(", "others", "=>", "0", ")", ";"]
  | .liveAll => ["current", ".", "live", ":=", "(", "others", "=>", "true", ")", ";"]
  | .spaces => ["current", ".", "string_prefix", ":=", "(", "others", "=>", "' '", ")", ";"]
  | .matchByte value => ["match_byte", "(", "current", ","] ++ value.render ++ [")", ";"]
  | .decoded value => ["decoded", "(", "current", ","] ++ value.render ++ [")", ";"]
  | .endString => ["end_string", "(", "current", ")", ";"]
  | .endTheory => ["end_theory", "(", "current", ")", ";"]
  | .structural => ["structural", "(", "current", ",", "item", ")", ";"]

inductive Command
  | skip | returnNow | action (value : Action) | sequence (first second : Command)
  | choose (test : Test) (yes no : Command)
  | switchItem (branches : Command) | switchMode (branches : Command)
  | itemBranch (choices : List Choice) (body rest : Command)
  | modeBranch (modes : List StringNative.Mode) (body rest : Command)
  | otherwise (body : Command)
  deriving DecidableEq

structure Result where
  frame : Frame
  returned : Bool := false

def Command.eval (helpers : Core.Helpers) (structuralCall : StructuralCall) (frame : Frame) : Command → Result
  | .skip => ⟨frame, false⟩ | .returnNow => ⟨frame, true⟩
  | .action value => ⟨value.eval helpers structuralCall frame, false⟩
  | .sequence first second =>
      let result := first.eval helpers structuralCall frame
      if result.returned then result else second.eval helpers structuralCall result.frame
  | .choose test yes no => if test.eval helpers frame then yes.eval helpers structuralCall frame else no.eval helpers structuralCall frame
  | .switchItem branches | .switchMode branches | .otherwise branches => branches.eval helpers structuralCall frame
  | .itemBranch choices body rest => if choices.any (Choice.accepts frame) then body.eval helpers structuralCall frame else rest.eval helpers structuralCall frame
  | .modeBranch modes body rest => if modes.contains frame.state.mode then body.eval helpers structuralCall frame else rest.eval helpers structuralCall frame

mutual
  def Command.render : Command → List String
    | .skip => [] | .returnNow => ["return", ";"] | .action value => value.render
    | .sequence first second => first.render ++ second.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
    | .switchItem branches => ["case", "item", "is"] ++ branches.render ++ ["end", "case", ";"]
    | .switchMode branches => ["case", "current", ".", "mode", "is"] ++ branches.render ++ ["end", "case", ";"]
    | .itemBranch choices body rest => ["when"] ++ choicesRender choices ++ ["=>"] ++ body.render ++ rest.render
    | .modeBranch modes body rest => ["when"] ++ ((modes.map (fun v => [modeName v])).intersperse ["|"]).flatten ++ ["=>"] ++ body.render ++ rest.render
    | .otherwise body => ["when", "others", "=>"] ++ body.render
  def Command.renderElse : Command → List String
    | .skip => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | value => ["else"] ++ value.render
end

def Command.list (items : List Command) : Command := items.foldr .sequence .skip

def fail : Command := .action (.flag .failed (.constant true))
def matchItem : Command := .action (.matchByte .item)
def decimal : List Choice := [.range (.literal 48) (.literal 57)]
def whitespace : List Choice := [.single (.literal 32), .single (.ordinal 9), .single (.ordinal 10), .single (.ordinal 13)]
def number (slot : NumberField) (value : Number) : Command := .action (.number slot value)
def flag (slot : Flag) (value : Test) : Command := .action (.flag slot value)
def equal (slot : NumberField) (value : Nat) : Test := .number .equal (.field slot) (.literal value)
def increase (slot : NumberField) : Command := number slot (.add (.field slot) (.literal 1))
def decrease (slot : NumberField) : Command := number slot (.sub (.field slot) (.literal 1))

end Silver.ImageModel.ScannerNative
