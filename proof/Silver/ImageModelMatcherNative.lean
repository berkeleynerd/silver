module

public import Silver.ImageModelMatcher

@[expose] public section
set_option backward.dsimp.instances true

namespace Silver.ImageModel.Native

inductive Theory
  | integer | string | image
  deriving DecidableEq, Repr

def theories : List Theory := [.integer, .string, .image]

structure Tables where
  length : Theory → Nat
  byte : Theory → Nat → Nat

structure Matcher where
  inTheory : Bool
  cells : Theory → MatchState

/-- Native scalar tests in Match_Byte. Array selection and external table
lookups are explicit, retaining the finite Selected_Theory loop. -/
inductive Test
  | inTheory | live | matches
  deriving DecidableEq

def Test.eval (tables : Tables) (state : Matcher) (kind : Theory) (item : Nat) : Test → Bool
  | .inTheory => state.inTheory
  | .live => (state.cells kind).live
  | .matches => decide ((state.cells kind).position < tables.length kind ∧
      tables.byte kind ((state.cells kind).position + 1) = item)

def Test.render : Test → List String
  | .inTheory => ["current", ".", "in_theory"]
  | .live => ["current", ".", "live", "(", "kind", ")"]
  | .matches => ["current", ".", "matched", "(", "kind", ")", "<", "templates", ".", "length", "(",
      "template_kind", "(", "kind", ")", ")", "and", "then", "templates", ".", "byte_at", "(",
      "template_kind", "(", "kind", ")", ",", "current", ".", "matched", "(", "kind", ")", "+", "1", ")", "=", "item"]

inductive Update
  | advance | invalidate
  deriving DecidableEq

def Update.eval (state : Matcher) (kind : Theory) : Update → Matcher
  | .advance => {state with cells := (fun selected => if selected = kind
      then ⟨(state.cells selected).position + 1, (state.cells selected).live⟩
      else state.cells selected)}
  | .invalidate => {state with cells := (fun selected => if selected = kind
      then ⟨(state.cells selected).position, false⟩ else state.cells selected)}

def Update.render : Update → List String
  | .advance => ["current", ".", "matched", "(", "kind", ")", ":=", "current", ".", "matched", "(", "kind", ")", "+", "1", ";"]
  | .invalidate => ["current", ".", "live", "(", "kind", ")", ":=", "false", ";"]

inductive Command
  | skip | update (value : Update)
  | choose (test : Test) (yes no : Command)
  | forKinds (body : Command)
  deriving DecidableEq

def Command.eval (tables : Tables) (item : Nat) (state : Matcher) (kind : Theory) : Command → Matcher
  | .skip => state
  | .update value => value.eval state kind
  | .choose test yes no => if test.eval tables state kind item then yes.eval tables item state kind
      else no.eval tables item state kind
  | .forKinds body => theories.foldl (fun current selected => body.eval tables item current selected) state

mutual
  def Command.render : Command → List String
    | .skip => []
    | .update value => value.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
    | .forKinds body => ["for", "kind", "in", "selected_theory", "loop"] ++ body.render ++ ["end", "loop", ";"]
  def Command.renderElse : Command → List String
    | .skip => []
    | body => ["else"] ++ body.render
end

def cellCommands : Command :=
  .choose .live (.choose .matches (.update .advance) (.update .invalidate)) .skip

def matchCommands : Command := .choose .inTheory (.forKinds cellCommands) .skip

def matchRender : List String :=
  ["procedure", "match_byte", "(", "current", ":", "in", "out", "state", ";", "item", ":", "character", ")", "is", "begin"] ++
    matchCommands.render ++ ["end", "match_byte", ";"]

theorem cell_inTheory (tables : Tables) (state : Matcher) (kind : Theory) (item : Nat) :
    (cellCommands.eval tables item state kind).inTheory = state.inTheory := by
  by_cases live : (state.cells kind).live = true <;>
    by_cases matched : (state.cells kind).position < tables.length kind ∧
      tables.byte kind ((state.cells kind).position + 1) = item <;>
    simp [cellCommands, Command.eval, Test.eval, Update.eval, live, matched]

theorem cell_other (tables : Tables) (state : Matcher) (kind other : Theory) (item : Nat)
    (different : other ≠ kind) :
    (cellCommands.eval tables item state kind).cells other = state.cells other := by
  by_cases live : (state.cells kind).live = true <;>
    by_cases matched : (state.cells kind).position < tables.length kind ∧
      tables.byte kind ((state.cells kind).position + 1) = item <;>
    simp [cellCommands, Command.eval, Test.eval, Update.eval, live, matched, different]

theorem cell_self (tables : Tables) (state : Matcher) (kind : Theory) (item : Nat) :
    (cellCommands.eval tables item state kind).cells kind =
      matchByte (tables.byte kind) (tables.length kind) (state.cells kind) item := by
  simp only [cellCommands, Command.eval, Test.eval, matchByte]
  by_cases live : (state.cells kind).live = true
  · simp only [live, ↓reduceIte]
    by_cases matched : (state.cells kind).position < tables.length kind ∧
        tables.byte kind ((state.cells kind).position + 1) = item
    · simp [matched, Update.eval, live]
    · simp [matched, Update.eval]
  · simp [live]

/-- Every loop iteration updates exactly its own table cursor. The native array
loop therefore denotes the three independent mathematical stream matchers. -/
theorem match_cells (tables : Tables) (state : Matcher) (item : Nat) (kind : Theory) :
    (matchCommands.eval tables item state kind).cells kind =
      if state.inTheory then matchByte (tables.byte kind) (tables.length kind) (state.cells kind) item
      else state.cells kind := by
  by_cases active : state.inTheory = true
  · simp only [matchCommands, Command.eval, Test.eval, active, ↓reduceIte,
      theories, List.foldl_cons, List.foldl_nil]
    cases kind with
    | integer => rw [cell_other tables _ .image .integer item (by decide),
        cell_other tables _ .string .integer item (by decide), cell_self]
    | string => rw [cell_other tables _ .image .string item (by decide), cell_self,
        cell_other tables _ .integer .string item (by decide)]
    | image => rw [cell_self, cell_other tables _ .string .image item (by decide),
        cell_other tables _ .integer .image item (by decide)]
  · simp [matchCommands, Command.eval, Test.eval, active]

theorem match_inTheory (tables : Tables) (state : Matcher) (item : Nat) (kind : Theory) :
    (matchCommands.eval tables item state kind).inTheory = state.inTheory := by
  by_cases active : state.inTheory = true
  · simp only [matchCommands, Command.eval, Test.eval, active, ↓reduceIte,
      theories, List.foldl_cons, List.foldl_nil, cell_inTheory]
  · simp [matchCommands, Command.eval, Test.eval, active]

/-- Applying the checked native block preserves the independently proved
complete-table invariant for each selected theory. -/
theorem match_preserves (tables : Tables) (state : Matcher) (item : Nat)
    (active : state.inTheory = true) (inputs : Theory → List Nat)
    (invariants : ∀ kind, MatchInvariant (tables.byte kind) (tables.length kind) (inputs kind) (state.cells kind)) :
    ∀ kind, MatchInvariant (tables.byte kind) (tables.length kind) (inputs kind ++ [item])
      ((matchCommands.eval tables item state kind).cells kind) := by
  intro kind
  rw [match_cells, active]
  exact matchByte_preserves (invariants kind) item

end Silver.ImageModel.Native
