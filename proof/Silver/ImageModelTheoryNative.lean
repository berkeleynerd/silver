module

public import Silver.ImageModelDecodedSource

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.TheoryNative

inductive Phase
  | beforeRoot | rootKey | rootColon | rootList | firstTheory | nextTheory
  | theorySeparator | rootEnd | afterRoot
  deriving DecidableEq

structure Frame where
  failed : Bool
  matcher : Native.Matcher
  field : Nat
  theory : Option Native.Theory
  seen : Native.Theory → Bool
  candidateDeclarations : Nat
  candidateIncludes : Nat
  declarations : Nat
  includes : Nat
  depth : Nat
  phase : Phase

def selected (frame : Frame) : Native.Theory := frame.theory.getD .integer

inductive Test
  | fields | selected | invalid | image
  deriving DecidableEq

def invalid (tables : Native.Tables) (frame : Frame) : Bool :=
  frame.seen (selected frame) || !(frame.matcher.cells (selected frame)).live ||
    decide ((frame.matcher.cells (selected frame)).position ≠ tables.length (selected frame))

def Test.eval (tables : Native.Tables) (frame : Frame) : Test → Bool
  | .fields => decide (frame.field ≠ 7)
  | .selected => frame.theory.isSome
  | .invalid => TheoryNative.invalid tables frame
  | .image => decide (frame.theory = some .image)

def Test.render : Test → List String
  | .fields => ["current", ".", "field", "/=", "7"]
  | .selected => ["current", ".", "theory", "/=", "other_theory"]
  | .invalid => ["current", ".", "seen", "(", "current", ".", "theory", ")", "or", "else", "not",
      "current", ".", "live", "(", "current", ".", "theory", ")", "or", "else", "current", ".", "matched",
      "(", "current", ".", "theory", ")", "/=", "templates", ".", "length", "(", "template_kind", "(",
      "current", ".", "theory", ")", ")"]
  | .image => ["current", ".", "theory", "=", "image_theory"]

inductive Action
  | close | fail | seen | declarations | includes | leave | depth | separator
  deriving DecidableEq

def Action.eval (matchCall : DecodedNative.MatchCall) (frame : Frame) : Action → Frame
  | .close => {frame with matcher := matchCall frame.matcher 93}
  | .fail => {frame with failed := true}
  | .seen => {frame with seen := (fun kind => if kind = selected frame then true else frame.seen kind)}
  | .declarations => {frame with declarations := frame.candidateDeclarations}
  | .includes => {frame with includes := frame.candidateIncludes}
  | .leave => {frame with matcher := {frame.matcher with inTheory := false}}
  | .depth => {frame with depth := 2}
  | .separator => {frame with phase := .theorySeparator}

def Action.render : Action → List String
  | .close => ["match_byte", "(", "current", ",", "']'", ")", ";"]
  | .fail => ["current", ".", "failed", ":=", "true", ";"]
  | .seen => ["current", ".", "seen", "(", "current", ".", "theory", ")", ":=", "true", ";"]
  | .declarations => ["current", ".", "declarations_offset", ":=", "current", ".", "candidate_declarations", ";"]
  | .includes => ["current", ".", "includes_offset", ":=", "current", ".", "candidate_includes", ";"]
  | .leave => ["current", ".", "in_theory", ":=", "false", ";"]
  | .depth => ["current", ".", "depth", ":=", "2", ";"]
  | .separator => ["current", ".", "phase", ":=", "theory_separator", ";"]

inductive Command
  | skip | action (value : Action) | sequence (first second : Command)
  | choose (test : Test) (yes no : Command)
  deriving DecidableEq

def Command.eval (tables : Native.Tables) (matchCall : DecodedNative.MatchCall) (frame : Frame) : Command → Frame
  | .skip => frame | .action value => value.eval matchCall frame
  | .sequence first second => second.eval tables matchCall (first.eval tables matchCall frame)
  | .choose test yes no => if test.eval tables frame then yes.eval tables matchCall frame else no.eval tables matchCall frame

mutual
  def Command.render : Command → List String
    | .skip => [] | .action value => value.render
    | .sequence first second => first.render ++ second.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
  def Command.renderElse : Command → List String
    | .skip => [] | value => ["else"] ++ value.render
end

def Command.list (items : List Command) : Command := items.foldr .sequence .skip

def commands : Command := .list [.action .close,
  .choose .fields (.action .fail) .skip,
  .choose .selected (.list [.choose .invalid (.action .fail) .skip, .action .seen,
    .choose .image (.sequence (.action .declarations) (.action .includes)) .skip]) .skip,
  .action .leave, .action .depth, .action .separator]

def render : List String := ["procedure", "end_theory", "(", "current", ":", "in", "out", "state", ")", "is", "begin"] ++
  commands.render ++ ["end", "end_theory", ";"]

def model (tables : Native.Tables) (matchCall : DecodedNative.MatchCall) (frame : Frame) : Frame :=
  let closed := {frame with matcher := matchCall frame.matcher 93}
  let checked := {closed with failed := (if frame.field ≠ 7 then true else frame.failed)}
  let selectedFrame :=
    if frame.theory.isSome then
      { checked with
        failed := (if invalid tables closed then true else checked.failed)
        seen := (fun kind => if kind = selected frame then true else frame.seen kind)
        declarations := (if frame.theory = some .image then frame.candidateDeclarations else frame.declarations)
        includes := (if frame.theory = some .image then frame.candidateIncludes else frame.includes) }
    else checked
  {selectedFrame with matcher := {selectedFrame.matcher with inTheory := false}, depth := 2, phase := .theorySeparator}

theorem eval_model (tables : Native.Tables) (matchCall : DecodedNative.MatchCall) (frame : Frame) :
    commands.eval tables matchCall frame = model tables matchCall frame := by
  cases theory : frame.theory with
  | none =>
      by_cases fields : frame.field ≠ 7 <;>
        simp [commands, Command.list, Command.eval, Test.eval, Action.eval, model, theory, fields]
  | some kind =>
      by_cases fields : frame.field ≠ 7 <;>
        by_cases bad : invalid tables {frame with matcher := matchCall frame.matcher 93} = true <;>
        cases kind <;>
        simp [commands, Command.list, Command.eval, Test.eval, Action.eval, model, theory,
          fields, invalid, selected] at bad ⊢ <;> simp_all <;> rfl

/-- A successful selected theory closes only after its complete matching check.
Duplicate targets cannot overwrite the earlier target's declaration offsets. -/
theorem successful_selected (tables : Native.Tables) (matchCall : DecodedNative.MatchCall) (frame : Frame)
    (kind : Native.Theory) (target : frame.theory = some kind)
    (accepted : (model tables matchCall frame).failed = false) :
    frame.field = 7 ∧ frame.seen kind = false ∧
      ((matchCall frame.matcher 93).cells kind).live = true ∧
      ((matchCall frame.matcher 93).cells kind).position = tables.length kind := by
  simp only [model, target, Option.isSome_some, ↓reduceIte] at accepted
  by_cases fields : frame.field ≠ 7
  · simp [fields] at accepted
  · have field : frame.field = 7 := by omega
    have valid : invalid tables {frame with matcher := matchCall frame.matcher 93} = false := by
      cases bad : invalid tables {frame with matcher := matchCall frame.matcher 93} <;> simp_all [invalid, selected]
    simp only [invalid, selected, target, Option.getD_some, Bool.or_eq_false_iff,
      Bool.not_eq_false', decide_eq_false_iff_not] at valid
    exact ⟨field, valid.1.1, valid.1.2, by omega⟩

end Silver.ImageModel.TheoryNative
