module

public import Silver.ImageModelMatcherNative
public import Silver.ImageModelNames

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.DecodedNative

/-- Fixed native prefix storage, indexed from one. The observation reads only
written characters; padding and stale characters cannot affect Named. -/
structure RawName where
  length : Nat
  buffer : Nat → Nat

def RawName.observe (state : RawName) : NameState :=
  ⟨state.length, (List.range (min state.length 21)).map (fun i => state.buffer (i + 1))⟩

def remember (state : RawName) (code : Nat) : RawName :=
  if state.length < 22 then
    let next := state.length + 1
    ⟨next, if next ≤ 21 then (fun i => if i = next then nameByte code else state.buffer i) else state.buffer⟩
  else state

theorem extended_buffer (length : Nat) (buffer : Nat → Nat) (value : Nat) :
    (List.range (length + 1)).map (fun i => if i = length then value else buffer (i + 1)) =
      (List.range length).map (fun i => buffer (i + 1)) ++ [value] := by
  rw [List.range_succ, List.map_append]
  simp only [List.map_singleton]
  congr 1
  apply List.map_congr_left
  intro i member
  have bound := List.mem_range.mp member
  simp [show i ≠ length by omega]

theorem remember_observe (state : RawName) (code : Nat) :
    (remember state code).observe = rememberName state.observe code := by
  by_cases room : state.length < 22
  · by_cases store : state.length + 1 ≤ 21
    · simp [remember, RawName.observe, rememberName, room, store,
        Nat.min_eq_left (show state.length ≤ 21 by omega), Nat.min_eq_left store,
        extended_buffer]
    · have length : state.length = 21 := by omega
      simp [remember, RawName.observe, rememberName, length]
  · simp [remember, RawName.observe, rememberName, room]

structure Frame where
  name : RawName
  matcher : Native.Matcher
  code : Nat

abbrev MatchCall := Native.Matcher → Nat → Native.Matcher

def hexCharacters : String := "0123456789abcdef"

def hexByte (index : Nat) : Nat :=
  ((hexCharacters.toList.map Char.toNat)[index]?).getD 0

inductive ByteExpression
  | character (value : Char) | code | highHex | lowHex
  deriving DecidableEq

def ByteExpression.eval (frame : Frame) : ByteExpression → Nat
  | .character value => value.toNat
  | .code => frame.code
  | .highHex => hexByte (frame.code / 16)
  | .lowHex => hexByte (frame.code % 16)

def ByteExpression.render : ByteExpression → List String
  | .character value => [String.ofList ['\'', value, '\'']]
  | .code => ["character", "'", "val", "(", "code", ")"]
  | .highHex => ["hex_characters", "(", "code", "/", "16", "+", "1", ")"]
  | .lowHex => ["hex_characters", "(", "code", "mod", "16", "+", "1", ")"]

inductive Test
  | room | store | nonAscii | escaped | control
  deriving DecidableEq

def Test.eval (frame : Frame) : Test → Bool
  | .room => decide (frame.name.length < 22)
  | .store => decide (frame.name.length ≤ 21)
  | .nonAscii => decide (127 ≤ frame.code)
  | .escaped => decide (frame.code = 34 ∨ frame.code = 92)
  | .control => decide (frame.code < 32)

def Test.render : Test → List String
  | .room => ["current", ".", "string_length", "<", "22"]
  | .store => ["current", ".", "string_length", "<=", "21"]
  | .nonAscii => ["code", ">=", "127"]
  | .escaped => ["code", "=", "34", "or", "else", "code", "=", "92"]
  | .control => ["code", "<", "32"]

inductive Action
  | increment | store | invalidate | emit (byte : ByteExpression)
  deriving DecidableEq

def Action.eval (matchCall : MatchCall) (frame : Frame) : Action → Frame
  | .increment => {frame with name := {frame.name with length := frame.name.length + 1}}
  | .store => {frame with name := {frame.name with buffer := (fun i =>
      if i = frame.name.length then nameByte frame.code else frame.name.buffer i)}}
  | .invalidate => {frame with matcher := {frame.matcher with cells := (fun kind =>
      {(frame.matcher.cells kind) with live := false})}}
  | .emit byte => {frame with matcher := matchCall frame.matcher (byte.eval frame)}

def Action.render : Action → List String
  | .increment => ["current", ".", "string_length", ":=", "current", ".", "string_length", "+", "1", ";"]
  | .store => ["current", ".", "string_prefix", "(", "current", ".", "string_length", ")", ":=", "(",
      "if", "code", "<=", "127", "then", "character", "'", "val", "(", "code", ")", "else",
      "character", "'", "val", "(", "127", ")", ")", ";"]
  | .invalidate => ["current", ".", "live", ":=", "(", "others", "=>", "false", ")", ";"]
  | .emit byte => ["match_byte", "(", "current", ","] ++ byte.render ++ [")", ";"]

inductive Command
  | skip | action (value : Action)
  | sequence (first second : Command)
  | choose (test : Test) (yes no : Command)
  | controlCase (eight nine ten twelve thirteen otherwise : Command)
  deriving DecidableEq

def Command.eval (matchCall : MatchCall) (frame : Frame) : Command → Frame
  | .skip => frame
  | .action value => value.eval matchCall frame
  | .sequence first second => second.eval matchCall (first.eval matchCall frame)
  | .choose test yes no => if test.eval frame then yes.eval matchCall frame else no.eval matchCall frame
  | .controlCase eight nine ten twelve thirteen otherwise =>
      match frame.code with
      | 8 => eight.eval matchCall frame | 9 => nine.eval matchCall frame
      | 10 => ten.eval matchCall frame | 12 => twelve.eval matchCall frame
      | 13 => thirteen.eval matchCall frame | _ => otherwise.eval matchCall frame

mutual
  def Command.render : Command → List String
    | .skip => [] | .action value => value.render
    | .sequence first second => first.render ++ second.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
    | .controlCase eight nine ten twelve thirteen otherwise =>
        ["case", "code", "is", "when", "8", "=>"] ++ eight.render ++
        ["when", "9", "=>"] ++ nine.render ++ ["when", "10", "=>"] ++ ten.render ++
        ["when", "12", "=>"] ++ twelve.render ++ ["when", "13", "=>"] ++ thirteen.render ++
        ["when", "others", "=>"] ++ otherwise.render ++ ["end", "case", ";"]
  def Command.renderElse : Command → List String
    | .skip => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | value => ["else"] ++ value.render
end

def Command.list (items : List Command) : Command := items.foldr .sequence .skip

def emit (byte : ByteExpression) : Command := .action (.emit byte)
def emitChar (byte : Char) : Command := emit (.character byte)

def rememberCommands : Command :=
  .choose .room (.sequence (.action .increment) (.choose .store (.action .store) .skip)) .skip

def byteCommands : Command :=
  .choose .nonAscii (.action .invalidate)
    (.choose .escaped (.sequence (emitChar '\\') (emit .code))
      (.choose .control (.sequence (emitChar '\\')
        (.controlCase (emitChar 'b') (emitChar 't') (emitChar 'n') (emitChar 'f') (emitChar 'r')
          (.list [emitChar 'u', emitChar '0', emitChar '0', emit .highHex, emit .lowHex])))
        (emit .code)))

def commands : Command := .sequence rememberCommands byteCommands

def render : List String :=
  ["procedure", "decoded", "(", "current", ":", "in", "out", "state", ";", "code", ":", "natural", ")", "with",
    "pre", "=>", "code", "<=", "65_535", "is", "hex_characters", ":", "constant", "string", ":=",
    "\"0123456789abcdef\"", ";", "begin"] ++ commands.render ++ ["end", "decoded", ";"]

def normalizedCode (code : Nat) : List Nat :=
  if code = 34 ∨ code = 92 then [92, code]
  else if code < 32 then
    92 :: (match code with
      | 8 => [98] | 9 => [116] | 10 => [110] | 12 => [102] | 13 => [114]
      | _ => [117, 48, 48, hexByte (code / 16), hexByte (code % 16)])
  else [code]

def output (matchCall : MatchCall) (frame : Frame) : Frame :=
  if 127 ≤ frame.code then Action.invalidate.eval matchCall frame
  else {frame with matcher := (normalizedCode frame.code).foldl matchCall frame.matcher}

theorem remember_eval (matchCall : MatchCall) (frame : Frame) :
    rememberCommands.eval matchCall frame = {frame with name := remember frame.name frame.code} := by
  by_cases room : frame.name.length < 22
  · by_cases store : frame.name.length + 1 ≤ 21 <;>
      simp [rememberCommands, Command.eval, Test.eval, Action.eval, remember, room, store] <;> rfl
  · simp [rememberCommands, Command.eval, Test.eval, remember, room]

theorem byte_eval (matchCall : MatchCall) (frame : Frame) :
    byteCommands.eval matchCall frame = output matchCall frame := by
  by_cases ascii : 127 ≤ frame.code
  · simp [byteCommands, Command.eval, Test.eval, ascii, output]
  · by_cases escaped : frame.code = 34 ∨ frame.code = 92
    · simp [byteCommands, Command.eval, Test.eval, Action.eval, ByteExpression.eval,
        emitChar, emit, ascii, escaped, output, normalizedCode]
    · by_cases control : frame.code < 32
      · simp only [byteCommands, Command.eval, Test.eval, ascii, decide_false, Bool.false_eq_true,
          ↓reduceIte, escaped, control, decide_true, output, normalizedCode,
          emitChar, emit, Action.eval, ByteExpression.eval]
        split <;> simp [Command.eval, Command.list, Action.eval, ByteExpression.eval,
          List.foldl_cons, List.foldl_nil]
      · simp [byteCommands, Command.eval, Test.eval, Action.eval, ByteExpression.eval,
          emitChar, emit, ascii, escaped, control, output, normalizedCode]

theorem decoded_eval (matchCall : MatchCall) (frame : Frame) :
    commands.eval matchCall frame = output matchCall {frame with name := remember frame.name frame.code} := by
  simp only [commands, Command.eval, remember_eval, byte_eval]

end Silver.ImageModel.DecodedNative
