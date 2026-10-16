module

public import Silver.ImageModelStringNative

@[expose] public section
set_option backward.dsimp.instances true
namespace Silver.ImageModel.FinishNative

inductive Kind
  | invalid | unchanged | refine
  deriving DecidableEq

structure Plan where
  kind : Kind := .invalid
  bytes : Nat := 0
  declarations : Nat := 0
  includes : Nat := 0
  greatestId : Nat := 0
  deriving DecidableEq

structure Input where
  failed : Bool
  mode : StringNative.Mode
  phase : TheoryNative.Phase
  depth : Nat
  inTheory : Bool
  nodeIdPending : Bool
  seen : Native.Theory → Bool
  bytes : Nat
  declarations : Nat
  includes : Nat
  greatestId : Nat

structure Frame where
  current : Input
  result : Plan

inductive Test
  | invalid | absent | ready
  deriving DecidableEq

def Test.eval (state : Input) : Test → Bool
  | .invalid => state.failed || decide (state.mode ≠ .between) || decide (state.phase ≠ .afterRoot) ||
      decide (state.depth ≠ 0) || state.inTheory || state.nodeIdPending
  | .absent => !(state.seen .image)
  | .ready => state.seen .integer && state.seen .string && decide (state.declarations < state.includes) &&
      decide (state.includes < state.bytes)

def Test.render : Test → List String
  | .invalid => ["current", ".", "failed", "or", "else", "current", ".", "mode", "/=", "between_tokens", "or", "else",
      "current", ".", "phase", "/=", "after_root", "or", "else", "current", ".", "depth", "/=", "0", "or", "else",
      "current", ".", "in_theory", "or", "else", "current", ".", "node_id_pending"]
  | .absent => ["not", "current", ".", "seen", "(", "image_theory", ")"]
  | .ready => ["current", ".", "seen", "(", "integer_theory", ")", "and", "then", "current", ".", "seen", "(",
      "string_theory", ")", "and", "then", "current", ".", "declarations_offset", "<", "current", ".",
      "includes_offset", "and", "then", "current", ".", "includes_offset", "<", "current", ".", "bytes"]

inductive Action
  | unchanged | refine | declarations | includes
  deriving DecidableEq

def Action.eval (frame : Frame) : Action → Frame
  | .unchanged => {frame with result := {frame.result with kind := .unchanged}}
  | .refine => {frame with result := {frame.result with kind := .refine}}
  | .declarations => {frame with result := {frame.result with declarations := frame.current.declarations}}
  | .includes => {frame with result := {frame.result with includes := frame.current.includes}}

def Action.render : Action → List String
  | .unchanged => ["result", ".", "kind", ":=", "unchanged", ";"]
  | .refine => ["result", ".", "kind", ":=", "refine", ";"]
  | .declarations => ["result", ".", "declarations_offset", ":=", "current", ".", "declarations_offset", ";"]
  | .includes => ["result", ".", "includes_offset", ":=", "current", ".", "includes_offset", ";"]

inductive Command
  | skip | action (value : Action) | result | sequence (first second : Command)
  | choose (test : Test) (yes no : Command)
  deriving DecidableEq

def Command.eval (frame : Frame) (next : Frame → Plan) : Command → Plan
  | .skip => next frame | .action value => next (value.eval frame) | .result => frame.result
  | .sequence first second => first.eval frame (fun state => second.eval state next)
  | .choose test yes no => if test.eval frame.current then yes.eval frame next else no.eval frame next

mutual
  def Command.render : Command → List String
    | .skip => [] | .action value => value.render | .result => ["return", "result", ";"]
    | .sequence first second => first.render ++ second.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
  def Command.renderElse : Command → List String
    | .skip => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | value => ["else"] ++ value.render
end

def Command.list (items : List Command) : Command := items.foldr .sequence .skip

def commands : Command := .sequence
  (.choose .invalid .result (.choose .absent (.action .unchanged)
    (.choose .ready (.list [.action .refine, .action .declarations, .action .includes]) .skip))) .result

def initial (state : Input) : Frame :=
  ⟨state, {bytes := state.bytes, greatestId := state.greatestId}⟩

def render : List String := ["function", "finish", "(", "current", ":", "state", ")", "return", "plan", "is",
  "result", ":", "plan", ":=", "(", "bytes", "=>", "current", ".", "bytes", ",", "greatest_id", "=>",
  "current", ".", "greatest_id", ",", "others", "=>", "<", ">", ")", ";", "begin"] ++ commands.render ++ ["end", "finish", ";"]

def model (state : Input) : Plan :=
  let empty := (initial state).result
  if Test.invalid.eval state then empty
  else if Test.absent.eval state then {empty with kind := .unchanged}
  else if Test.ready.eval state then {empty with kind := .refine, declarations := state.declarations, includes := state.includes}
  else empty

theorem eval_model (state : Input) : commands.eval (initial state) (·.result) = model state := by
  simp only [commands, Command.eval, Command.list, List.foldr_cons, List.foldr_nil, initial, Action.eval, model]

theorem refine_ready (state : Input) (refined : (model state).kind = .refine) :
    Test.invalid.eval state = false ∧ state.seen .image = true ∧ Test.ready.eval state = true := by
  unfold model at refined
  by_cases invalid : Test.invalid.eval state = true
  · simp [invalid, initial] at refined
  · by_cases absent : Test.absent.eval state = true
    · simp [invalid, absent, initial] at refined
    · by_cases ready : Test.ready.eval state = true
      · have a : Test.invalid.eval state = false := Bool.eq_false_iff.mpr invalid
        have image : state.seen .image = true := by
          cases seen : state.seen .image <;> simp_all [Test.eval]
        exact ⟨a, image, ready⟩
      · simp [invalid, absent, ready, initial] at refined

theorem refine_offsets (state : Input) (refined : (model state).kind = .refine) :
    (model state).declarations = state.declarations ∧ (model state).includes = state.includes ∧
      state.declarations < state.includes ∧ state.includes < state.bytes := by
  obtain ⟨valid, image, ready⟩ := refine_ready state refined
  have bounds : state.declarations < state.includes ∧ state.includes < state.bytes := by
    simp only [Test.eval, Bool.and_eq_true, decide_eq_true_eq] at ready
    exact ⟨ready.1.2, ready.2⟩
  have absent : Test.absent.eval state = false := by simp [Test.eval, image]
  simp only [model, valid, absent, ready, Bool.false_eq_true, ↓reduceIte]
  exact ⟨True.intro, True.intro, bounds⟩

end Silver.ImageModel.FinishNative
