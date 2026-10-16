module

public import Silver.ImageModelScannerSyntax

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- The complete executable body of Structural, including the two early exits.
Every leaf has source tokens and a state interpretation in ScannerSyntax. -/
def structuralOpenObject : Command :=
  .choose (.both (.phase .beforeRoot) (equal .depth 0))
    (.list [number .depth (.literal 1), .action (.phase .rootKey)])
    (.choose (.both (.flag .inTheory) (.number .less (.field .depth) .byteMaximum))
      (.list [increase .depth, matchItem]) fail)

def structuralCloseObject : Command :=
  .choose (.both (.phase .rootEnd) (equal .depth 1))
    (.list [number .depth (.literal 0), .action (.phase .afterRoot)])
    (.choose (.both (.flag .inTheory) (.number .greater (.field .depth) (.literal 3)))
      (.list [decrease .depth, matchItem]) fail)

def structuralOpenArray : Command :=
  .choose (.both (.phase .rootList) (equal .depth 1))
    (.list [number .depth (.literal 2), .action (.phase .firstTheory)])
    (.choose (.both (equal .depth 2) (.phaseIn [.firstTheory, .nextTheory]))
      (.list [flag .inTheory (.constant true), .action .otherTheory, number .field (.literal 0),
        number .candidateDeclarations (.literal 0), number .candidateIncludes (.literal 0),
        .action .zeroMatched, .action .liveAll, number .depth (.literal 3), matchItem])
      (.choose (.both (.flag .inTheory) (.number .less (.field .depth) .byteMaximum))
        (.list [increase .depth, matchItem]) fail))

def structuralOffset : Command :=
  .choose (.both (equal .depth 4) (.number .greater (.field .bytes) (.literal 0)))
    (.choose (equal .field 3) (number .candidateDeclarations (.sub (.field .bytes) (.literal 1)))
      (.choose (equal .field 6) (number .candidateIncludes (.sub (.field .bytes) (.literal 1))) .skip)) .skip

def structuralCloseArray : Command :=
  .choose (.both (equal .depth 2) (.phaseIn [.firstTheory, .theorySeparator]))
    (.list [number .depth (.literal 1), .action (.phase .rootEnd)])
    (.choose (.both (.flag .inTheory) (equal .depth 3)) (.action .endTheory)
      (.choose (.both (.flag .inTheory) (.number .greater (.field .depth) (.literal 3)))
        (.list [structuralOffset, decrease .depth, matchItem]) fail))

def structuralColon : Command :=
  .choose (.both (.phase .rootColon) (equal .depth 1)) (.action (.phase .rootList))
    (.choose (.flag .inTheory) matchItem fail)

def structuralComma : Command :=
  .choose (.both (equal .depth 2) (.phase .theorySeparator)) (.action (.phase .nextTheory))
    (.choose (.flag .inTheory)
      (.list [.choose (equal .depth 3)
        (.choose (.number .less (.field .field) (.literal 7)) (increase .field) fail) .skip, matchItem]) fail)

def structuralQuote : Command :=
  .choose (.either (.flag .inTheory) (.parens (.both (equal .depth 1) (.phase .rootKey))))
    (.list [flag .isTag (.flag .previousArrayStart), flag .isKey (equal .depth 1),
      flag .isName (.both (equal .depth 3) (equal .field 4)),
      flag .isTheoryTag (.both (equal .depth 3) (equal .field 0)),
      number .stringLength (.literal 0), .action .spaces, .action (.mode .string), matchItem]) fail

def structuralNumber : Command :=
  .choose (.flag .inTheory)
    (.list [flag .numberIsId (.flag .nodeIdPending), flag .nodeIdPending (.constant false),
      number .numberValue (.literal 0), flag .numberDigits (.itemIn decimal), .action (.mode .number),
      .choose (.flag .numberIsId)
        (.choose (.itemIn decimal)
          (.list [number .numberValue (.sub (.ordinal .item) (.ordinal (.literal 48))),
            .action (.matchByte (.literal 48))]) fail) matchItem]) fail

def structuralLiteral : Command :=
  .choose (.flag .inTheory) (.list [.action (.mode .literal), matchItem]) fail

def structuralCases : Command :=
  .itemBranch [.single (.literal 123)] structuralOpenObject <|
  .itemBranch [.single (.literal 125)] structuralCloseObject <|
  .itemBranch [.single (.literal 91)] structuralOpenArray <|
  .itemBranch [.single (.literal 93)] structuralCloseArray <|
  .itemBranch [.single (.literal 58)] structuralColon <|
  .itemBranch [.single (.literal 44)] structuralComma <|
  .itemBranch [.single (.literal 34)] structuralQuote <|
  .itemBranch (decimal ++ [.single (.literal 45)]) structuralNumber <|
  .itemBranch [.single (.literal 116), .single (.literal 102), .single (.literal 110)] structuralLiteral <|
  .otherwise fail

def structuralCommands : Command := .list [
  .choose (.itemIn whitespace) .returnNow .skip,
  .choose (.both (.both (.flag .nodeIdPending) (.itemDifferent (.literal 44))) (.itemNotIn decimal))
    (.list [fail, .returnNow]) .skip,
  .switchItem structuralCases,
  flag .previousArrayStart (.itemEquals (.literal 91))]

def structuralRender : List String :=
  ["procedure", "structural", "(", "current", ":", "in", "out", "state", ";", "item", ":", "character", ")", "is", "begin"] ++
  structuralCommands.render ++ ["end", "structural", ";"]

/-- Structural contains no recursive Structural call; the arbitrary parameter
here is unobservable. A theorem below makes this independence explicit. -/
def structural (helpers : Core.Helpers) (state : Core.State) (item : Nat) : Core.State :=
  (structuralCommands.eval helpers (fun state _ => state) ⟨state, item, 0⟩).frame.state

def Command.noStructural : Command → Bool
  | .action .structural => false
  | .sequence first second | .choose _ first second | .itemBranch _ first second | .modeBranch _ first second =>
      first.noStructural && second.noStructural
  | .switchItem body | .switchMode body | .otherwise body => body.noStructural
  | _ => true

theorem Command.eval_noStructural (command : Command) (none : command.noStructural = true)
    (helpers : Core.Helpers) (first second : StructuralCall) (frame : Frame) :
    command.eval helpers first frame = command.eval helpers second frame := by
  induction command generalizing frame with
  | skip | returnNow => rfl
  | action value =>
      cases value <;> simp_all [Command.noStructural, Command.eval, Action.eval]
  | sequence a b ia ib =>
      simp only [Command.noStructural, Bool.and_eq_true] at none
      simp only [Command.eval, ia none.1]
      split
      · rfl
      · exact ib none.2 _
  | choose test yes no iy ino =>
      simp only [Command.noStructural, Bool.and_eq_true] at none
      simp only [Command.eval]
      split
      · exact iy none.1 _
      · exact ino none.2 _
  | itemBranch choices yes no iy ino =>
      simp only [Command.noStructural, Bool.and_eq_true] at none
      simp only [Command.eval]
      split
      · exact iy none.1 _
      · exact ino none.2 _
  | modeBranch modes yes no iy ino =>
      simp only [Command.noStructural, Bool.and_eq_true] at none
      simp only [Command.eval]
      split
      · exact iy none.1 _
      · exact ino none.2 _
  | switchItem body ih | switchMode body ih | otherwise body ih => exact ih none frame

theorem structural_no_recursion : structuralCommands.noStructural = true := by decide +kernel

theorem structural_ignores_call (helpers : Core.Helpers) (call : StructuralCall) (state : Core.State) (item digit : Nat) :
    (structuralCommands.eval helpers call ⟨state, item, digit⟩) =
    structuralCommands.eval helpers (fun state _ => state) ⟨state, item, digit⟩ := by
  exact Command.eval_noStructural _ structural_no_recursion _ _ _ _

end Silver.ImageModel.ScannerNative
