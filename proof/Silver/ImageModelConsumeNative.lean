module

public import Silver.ImageModelStructuralNative

@[expose] public section
namespace Silver.ImageModel.ScannerNative

def consumeString : Command :=
  .choose (.itemEquals (.literal 34)) (.action .endString)
    (.choose (.itemEquals (.literal 92)) (.action (.mode .escape))
      (.choose (.number .less (.ordinal .item) (.literal 32)) fail (.action (.decoded (.ordinal .item)))))

def consumeEscapes : Command :=
  .itemBranch [.single (.literal 34), .single (.literal 92), .single (.literal 47)] (.action (.decoded (.ordinal .item))) <|
  .itemBranch [.single (.literal 98)] (.action (.decoded (.literal 8))) <|
  .itemBranch [.single (.literal 116)] (.action (.decoded (.literal 9))) <|
  .itemBranch [.single (.literal 110)] (.action (.decoded (.literal 10))) <|
  .itemBranch [.single (.literal 102)] (.action (.decoded (.literal 12))) <|
  .itemBranch [.single (.literal 114)] (.action (.decoded (.literal 13))) <|
  .itemBranch [.single (.literal 117)]
    (.list [.action (.mode .unicode), number .unicodeLeft (.literal 4), number .unicodeValue (.literal 0)]) <|
  .otherwise fail

def consumeEscape : Command := .list [.action (.mode .string), .switchItem consumeEscapes]

def consumeUnicode : Command := .list [number .digit .hex,
  .choose (.both (.both (.number .less (.field .digit) (.literal 16))
    (.number .greater (.field .unicodeLeft) (.literal 0)))
    (.number .atMost (.field .unicodeValue) (.div (.parens (.sub .unicodeMaximum (.field .digit))) (.literal 16))))
    (.list [number .unicodeValue (.add (.mul (.field .unicodeValue) (.literal 16)) (.field .digit)),
      decrease .unicodeLeft,
      .choose (equal .unicodeLeft 0)
        (.list [.action (.decoded (.field .unicodeValue)), .action (.mode .string)]) .skip]) fail]

def delimiters : List Choice := whitespace ++
  [.single (.literal 44), .single (.literal 93), .single (.literal 125), .single (.literal 58),
   .single (.literal 91), .single (.literal 123), .single (.literal 34)]

def consumeNumberClose : Command := .list [
  .choose (.both (.mode .number) (.flag .numberIsId))
    (.choose (.negated (.flag .numberDigits)) fail
      (number .greatestId (.idMaximumOf (.field .greatestId) (.field .numberValue)))) .skip,
  .action (.mode .between), .action .structural]

def consumeIdDigit : Command :=
  .choose (.itemIn decimal)
    (.list [number .digit (.sub (.ordinal .item) (.ordinal (.literal 48))),
      .choose (.number .atMost (.field .numberValue) (.div (.parens (.sub .idMaximum (.field .digit))) (.literal 10)))
        (.list [number .numberValue (.add (.mul (.field .numberValue) (.literal 10)) (.field .digit)),
          flag .numberDigits (.constant true)]) fail]) fail

def consumeNumber : Command :=
  .choose (.itemIn delimiters) consumeNumberClose
    (.choose (.both (.mode .number) (.flag .numberIsId)) consumeIdDigit matchItem)

def consumeCases : Command :=
  .modeBranch [.string] consumeString <|
  .modeBranch [.escape] consumeEscape <|
  .modeBranch [.unicode] consumeUnicode <|
  .modeBranch [.number, .literal] consumeNumber <|
  .modeBranch [.between] (.action .structural) .skip

def consumeCommands : Command := .list [
  .choose (.flag .failed) .returnNow
    (.choose (.number .equal (.field .bytes) .byteMaximum) (.list [fail, .returnNow]) .skip),
  increase .bytes, .switchMode consumeCases]

def consumeRender : List String :=
  ["procedure", "consume", "(", "current", ":", "in", "out", "state", ";", "item", ":", "character", ")", "is",
   "digit", ":", "natural", ";", "begin"] ++ consumeCommands.render ++ ["end", "consume", ";"]

def consume (helpers : Core.Helpers) (state : Core.State) (item : Nat) : Core.State :=
  (consumeCommands.eval helpers (structural helpers) ⟨state, item, 0⟩).frame.state

/-- Rejected input is absorbing: later bytes cannot restore an accepted state. -/
theorem consume_failed (helpers : Core.Helpers) (state : Core.State) (item : Nat) (failed : state.failed = true) :
    consume helpers state item = state := by
  simp only [consume, consumeCommands, Command.list, List.foldr_cons, List.foldr_nil,
    Command.eval, Test.eval, Flag.get, failed, ↓reduceIte]

/-- The byte counter guard rejects a new byte before increasing a saturated count. -/
theorem consume_saturated (helpers : Core.Helpers) (state : Core.State) (item : Nat)
    (notFailed : state.failed = false) (full : state.bytes = 9223372036854775807) :
    consume helpers state item = {state with failed := true} := by
  simp only [consume, consumeCommands, Command.list, List.foldr_cons, List.foldr_nil,
    Command.eval, Test.eval, Flag.get, notFailed, Bool.false_eq_true, ↓reduceIte,
    Number.eval, NumberField.get, full, Comparison.eval, decide_true, fail, Action.eval, Flag.set]

end Silver.ImageModel.ScannerNative
