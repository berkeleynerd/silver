module

public import Silver.StaticBooleanModel

@[expose] public section

/-! Typed trees for the straight-line and branching Boolean elaboration helpers.
Each operand has one source spelling and one interpretation. Recursive calls
remain explicit parameters until the well-founded source bridge discharges them. -/
namespace Silver.BooleanElaboration.Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

inductive NumberLocal | opened | negated | found
  deriving DecidableEq, Repr

def NumberLocal.name : NumberLocal → String
  | .opened => "open" | .negated => "negated" | .found => "found"

@[ext] structure Frame where
  text : Source
  state : Compose.ParserState
  position : Nat
  numbers : NumberLocal → Nat := fun _ => 0
  reference : QualifiedNames.Reference := {}
  result : Result := invalid

structure Recursions where
  condition : Reader
  primary : Reader

inductive Expr : Type → Type 1
  | number : Nat → Expr Nat
  | flag : Bool → Expr Bool
  | position : Expr Nat
  | local : NumberLocal → Expr Nat
  | reference : Expr QualifiedNames.Reference
  | result : Expr Result
  | invalid : Expr Result
  | resultAfter : Expr Result → Expr Nat
  | resultValue : Expr Result → Expr Bool
  | first : Expr QualifiedNames.Reference → Expr Nat
  | after : Expr QualifiedNames.Reference → Expr Nat
  | qualifierFirst : Expr QualifiedNames.Reference → Expr Nat
  | take : Expr Nat → Token → Expr Nat
  | readReference : Expr Nat → Expr QualifiedNames.Reference
  | lookup : Expr QualifiedNames.Reference → Expr Nat
  | known : Expr Nat → Expr Bool
  | storedValue : Expr Nat → Expr Bool
  | booleanAtom : Expr Nat → Expr Nat
  | nameIs : Expr QualifiedNames.Reference → String → Expr Bool
  | condition : Expr Nat → Expr Result
  | primary : Expr Nat → Expr Result
  | aggregate : Expr Nat → Expr Bool → Expr Result
  | equal : Expr Nat → Expr Nat → Expr Bool
  | unequal : Expr Nat → Expr Nat → Expr Bool
  | greater : Expr Nat → Expr Nat → Expr Bool
  | not : Expr Bool → Expr Bool
  | andThen : Expr Bool → Expr Bool → Expr Bool
  | ite : Expr Bool → Expr Nat → Expr Nat → Expr Nat

def Expr.eval (imports : Imports) (recursions : Recursions) (frame : Frame) : Expr α → α
  | .number value => value
  | .flag value => value
  | .position => frame.position
  | .local name => frame.numbers name
  | .reference => frame.reference
  | .result => frame.result
  | .invalid => Silver.BooleanElaboration.Native.invalid
  | .resultAfter value => (value.eval imports recursions frame).after
  | .resultValue value => (value.eval imports recursions frame).value
  | .first value => (value.eval imports recursions frame).first
  | .after value => (value.eval imports recursions frame).after
  | .qualifierFirst value => (value.eval imports recursions frame).qualifierFirst
  | .take cursor token => imports.take frame.text (cursor.eval imports recursions frame) token
  | .readReference cursor => imports.reference frame.text (cursor.eval imports recursions frame)
  | .lookup queryRef =>
      let value := queryRef.eval imports recursions frame
      imports.lookup frame.text frame.state.booleanNames value.first value.after
        value.qualifierFirst value.qualifierAfter
  | .known index => (BooleanBindings.binding frame.state.booleanNames (index.eval imports recursions frame)).known
  | .storedValue index => (BooleanBindings.binding frame.state.booleanNames (index.eval imports recursions frame)).value
  | .booleanAtom cursor => imports.booleanAtom frame.text frame.state (cursor.eval imports recursions frame)
  | .nameIs queryRef spelling =>
      let value := queryRef.eval imports recursions frame
      imports.nameIs frame.text value.first value.after spelling
  | .condition cursor => recursions.condition frame.text frame.state (cursor.eval imports recursions frame)
  | .primary cursor => recursions.primary frame.text frame.state (cursor.eval imports recursions frame)
  | .aggregate finish value => ⟨finish.eval imports recursions frame, value.eval imports recursions frame⟩
  | .equal left right => left.eval imports recursions frame == right.eval imports recursions frame
  | .unequal left right => left.eval imports recursions frame != right.eval imports recursions frame
  | .greater left right => decide (right.eval imports recursions frame < left.eval imports recursions frame)
  | .not value => !(value.eval imports recursions frame)
  | .andThen left right => left.eval imports recursions frame && right.eval imports recursions frame
  | .ite test yes no => if test.eval imports recursions frame then yes.eval imports recursions frame
      else no.eval imports recursions frame

def call (name : List String) (arguments : List (List String)) : List String :=
  name ++ ["("] ++ List.flatten (List.intersperse [","] arguments) ++ [")"]

def Expr.render : Expr α → List String
  | .number value => [toString value]
  | .flag value => [if value then "true" else "false"]
  | .position => ["position"]
  | .local name => [name.name]
  | .reference => ["reference"]
  | .result => ["result"]
  | .invalid => ["invalid_static_boolean"]
  | .resultAfter value => value.render ++ [".", "after"]
  | .resultValue value => value.render ++ [".", "value"]
  | .first value => value.render ++ [".", "first"]
  | .after value => value.render ++ [".", "after"]
  | .qualifierFirst value => value.render ++ [".", "qualifier_first"]
  | .take cursor token => call ["take_token"] [["text"], cursor.render, [token.name]]
  | .readReference cursor => call ["scalar_expressions", ".", "read_reference"] [["text"], cursor.render]
  | .lookup queryRef => call ["lookup_boolean"]
      [["text"], ["frame", ".", "boolean_names"], queryRef.render ++ [".", "first"],
       queryRef.render ++ [".", "after"], queryRef.render ++ [".", "qualifier_first"],
       queryRef.render ++ [".", "qualifier_after"]]
  | .known index => ["frame", ".", "boolean_names", ".", "items", "("] ++ index.render ++ [")", ".", "known"]
  | .storedValue index => ["frame", ".", "boolean_names", ".", "items", "("] ++ index.render ++ [")", ".", "value"]
  | .booleanAtom cursor => call ["boolean_atom_after"]
      [["text"], call ["context_of"] [["(", "frame", ",", "false", ",", "false", ")"]], cursor.render]
  | .nameIs queryRef spelling => call ["name_is"]
      [["text"], queryRef.render ++ [".", "first"], queryRef.render ++ [".", "after"], ["\"" ++ spelling ++ "\""]]
  | .condition cursor => call ["static_boolean_at"] [["text"], ["frame"], cursor.render]
  | .primary cursor => call ["static_boolean_primary"] [["text"], ["frame"], cursor.render]
  | .aggregate finish value => ["("] ++ finish.render ++ [","] ++ value.render ++ [")"]
  | .equal left right => left.render ++ ["="] ++ right.render
  | .unequal left right => left.render ++ ["/="] ++ right.render
  | .greater left right => left.render ++ [">"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .ite test yes no => ["(", "if"] ++ test.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render ++ [")"]

/-- Ada field prefixes must be actual record names, and each operand of a
logical chain is a relation. These checks rule out ambiguous renderings. -/
def Expr.primaryOperand : Expr α → Bool
  | .equal _ _ | .unequal _ _ | .greater _ _ | .not _ | .andThen _ _ => false
  | _ => true

def Expr.relation : Expr Bool → Bool
  | .andThen _ _ => false
  | _ => true

def Expr.wellFormed : Expr α → Bool
  | .number _ | .flag _ | .position | .local _ | .reference | .result | .invalid => true
  | .resultAfter value | .resultValue value => match value with | .result => true | _ => false
  | .first value | .after value | .qualifierFirst value => match value with | .reference => true | _ => false
  | .take cursor _ | .readReference cursor | .booleanAtom cursor | .condition cursor | .primary cursor =>
      cursor.primaryOperand && cursor.wellFormed
  | .known index | .storedValue index => index.primaryOperand && index.wellFormed
  | .lookup queryRef | .nameIs queryRef _ => match queryRef with | .reference => true | _ => false
  | .aggregate finish value => finish.primaryOperand && finish.wellFormed && value.primaryOperand && value.wellFormed
  | .equal left right | .unequal left right | .greater left right =>
      left.primaryOperand && left.wellFormed && right.primaryOperand && right.wellFormed
  | .not value => value.primaryOperand && value.wellFormed
  | .andThen left right => left.wellFormed && right.relation && right.wellFormed
  | .ite test yes no => test.wellFormed && yes.primaryOperand && yes.wellFormed && no.primaryOperand && no.wellFormed

inductive Command
  | nothing
  | setResult : Expr Result → Command
  | setAfter : Expr Nat → Command
  | setValue : Expr Bool → Command
  | sequence : Command → Command → Command
  | choose : Expr Bool → Command → Command → Command
  | returned : Expr Result → Command

def Command.eval (imports : Imports) (recursions : Recursions) (frame : Frame) (next : Frame → Result) : Command → Result
  | .nothing => next frame
  | .setResult value => next {frame with result := value.eval imports recursions frame}
  | .setAfter value => next {frame with result := {frame.result with after := value.eval imports recursions frame}}
  | .setValue value => next {frame with result := {frame.result with value := value.eval imports recursions frame}}
  | .sequence first rest => first.eval imports recursions frame (fun updated => rest.eval imports recursions updated next)
  | .choose test yes no => if test.eval imports recursions frame then yes.eval imports recursions frame next
      else no.eval imports recursions frame next
  | .returned value => value.eval imports recursions frame

mutual
  def Command.render : Command → List String
    | .nothing => []
    | .setResult value => ["result", ":="] ++ value.render ++ [";"]
    | .setAfter value => ["result", ".", "after", ":="] ++ value.render ++ [";"]
    | .setValue value => ["result", ".", "value", ":="] ++ value.render ++ [";"]
    | .sequence first rest => first.render ++ rest.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
    | .returned value => ["return"] ++ value.render ++ [";"]
  def Command.renderElse : Command → List String
    | .nothing => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | command => ["else"] ++ command.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing

def Command.wellFormed : Command → Bool
  | .nothing => true
  | .setResult value | .setAfter value | .returned value => value.primaryOperand && value.wellFormed
  | .setValue value => value.wellFormed
  | .sequence first rest => first.wellFormed && rest.wellFormed
  | .choose test yes no => test.wellFormed && yes.wellFormed && no.wellFormed

def primaryCommands : Command := .list [
  .choose (.equal .position (.number 0)) (.returned .invalid) .nothing,
  .choose (.unequal (.local .opened) (.number 0))
    (.list [.setResult (.condition (.local .opened)),
      .setAfter (.take (.resultAfter .result) .rightParenthesis), .returned .result])
    (.choose (.andThen (.unequal (.local .found) (.number 0)) (.known (.local .found)))
      (.returned (.aggregate (.after .reference) (.storedValue (.local .found))))
      (.choose (.andThen (.andThen (.andThen (.andThen
          (.equal (.local .found) (.number 0)) (.equal (.qualifierFirst .reference) (.number 0)))
          (.unequal (.first .reference) (.number 0))) (.greater (.after .reference) (.first .reference)))
          (.unequal (.booleanAtom .position) (.number 0)))
        (.choose (.nameIs .reference "true") (.returned (.aggregate (.after .reference) (.flag true)))
          (.choose (.nameIs .reference "false") (.returned (.aggregate (.after .reference) (.flag false))) .nothing))
        .nothing)),
  .returned .invalid]

def factorCommands : Command := .list [
  .choose (.unequal (.local .negated) (.number 0)) (.setValue (.not (.resultValue .result))) .nothing,
  .returned .result]

def primaryFrame (imports : Imports) (text : Source) (state : Compose.ParserState) (position : Nat) : Frame :=
  let reference := imports.reference text position
  {text, state, position, reference,
   numbers := fun name => match name with
     | .opened => imports.take text position .leftParenthesis
     | .negated => 0
     | .found => imports.lookup text state.booleanNames reference.first reference.after
         reference.qualifierFirst reference.qualifierAfter}

def factorFrame (imports : Imports) (recursions : Recursions)
    (text : Source) (state : Compose.ParserState) (position : Nat) : Frame :=
  let negated := imports.take text position .notKeyword
  {text, state, position, numbers := fun name => if name = .negated then negated else 0,
   result := recursions.primary text state (if negated = 0 then position else negated)}

inductive Declaration
  | number : NumberLocal → Expr Nat → Declaration
  | reference : Expr QualifiedNames.Reference → Declaration
  | result : Option (Expr Result) → Declaration

def Declaration.eval (imports : Imports) (recursions : Recursions) (frame : Frame) : Declaration → Frame
  | .number name value =>
      let evaluated := Expr.eval imports recursions frame value
      {frame with numbers := fun query => if query = name then evaluated else frame.numbers query}
  | .reference value => {frame with reference := Expr.eval imports recursions frame value}
  | .result value => {frame with result := match value with
      | none => invalid | some initial => Expr.eval imports recursions frame initial}

def Declaration.render : Declaration → List String
  | .number name value => [name.name, ":", "constant", (if name = .found then "boolean_count" else "literal_position"), ":="] ++
      value.render ++ [";"]
  | .reference value => ["reference", ":", "constant", "scalar_expressions", ".", "name_reference", ":="] ++
      value.render ++ [";"]
  | .result value => ["result", ":", "static_boolean_result"] ++
      (match value with | none => [] | some initial => [":="] ++ initial.render) ++ [";"]

def primaryDeclarations : List Declaration := [
  .number .opened (.take .position .leftParenthesis),
  .reference (.readReference .position),
  .number .found (.lookup .reference),
  .result none]

def factorDeclarations : List Declaration := [
  .number .negated (.take .position .notKeyword),
  .result (some (.primary (.ite (.equal (.local .negated) (.number 0)) .position (.local .negated))))]

structure Body where
  name : String
  declarations : List Declaration
  commands : Command

def Body.eval (body : Body) (imports : Imports) (recursions : Recursions)
    (text : Source) (state : Compose.ParserState) (position : Nat) : Result :=
  let initial : Frame := {text, state, position}
  body.commands.eval imports recursions
    (body.declarations.foldl (Declaration.eval imports recursions) initial) (fun _ => invalid)

def Body.render (body : Body) : List String := body.declarations.flatMap Declaration.render ++
  ["begin"] ++ body.commands.render ++ ["end", body.name, ";"]

def primaryBody : Body := ⟨"static_boolean_primary", primaryDeclarations, primaryCommands⟩
def factorBody : Body := ⟨"static_boolean_factor", factorDeclarations, factorCommands⟩

theorem primary_declarations (imports : Imports) (recursions : Recursions)
    (text : Source) (state : Compose.ParserState) (position : Nat) :
    primaryDeclarations.foldl (Declaration.eval imports recursions) {text, state, position} =
      primaryFrame imports text state position := by
  apply Frame.ext <;> try rfl
  funext name
  cases name <;> rfl

theorem factor_declarations (imports : Imports) (recursions : Recursions)
    (text : Source) (state : Compose.ParserState) (position : Nat) :
    factorDeclarations.foldl (Declaration.eval imports recursions) {text, state, position} =
      factorFrame imports recursions text state position := by
  simp only [factorDeclarations, List.foldl, Declaration.eval, Expr.eval, factorFrame,
    beq_iff_eq, ↓reduceIte]

theorem primary_wellFormed : primaryCommands.wellFormed = true := rfl

theorem factor_wellFormed : factorCommands.wellFormed = true := rfl

theorem primary_denotation (imports : Imports) (recursions : Recursions)
    (text : Source) (state : Compose.ParserState) (position : Nat) :
    primaryCommands.eval imports recursions (primaryFrame imports text state position) (fun _ => invalid) =
      primaryStep imports recursions.condition text state position := by
  dsimp +instances only [primaryCommands, Command.list, List.foldr, Command.eval, Expr.eval, primaryFrame,
    primaryStep]
  simp only [Bool.and_eq_true, beq_iff_eq, bne_iff_ne, decide_eq_true_eq, and_assoc]

theorem factor_denotation (imports : Imports) (recursions : Recursions)
    (text : Source) (state : Compose.ParserState) (position : Nat) :
    factorCommands.eval imports recursions (factorFrame imports recursions text state position) (fun _ => invalid) =
      factorStep imports recursions.primary text state position := by
  simp only [factorCommands, Command.list, List.foldr, Command.eval, Expr.eval, factorFrame,
    factorStep, bne_iff_ne, ↓reduceIte]

theorem primary_body_denotation (imports : Imports) (recursions : Recursions)
    (text : Source) (state : Compose.ParserState) (position : Nat) :
    primaryBody.eval imports recursions text state position =
      primaryStep imports recursions.condition text state position := by
  unfold Body.eval primaryBody
  dsimp only
  rw [primary_declarations]
  exact primary_denotation imports recursions text state position

theorem factor_body_denotation (imports : Imports) (recursions : Recursions)
    (text : Source) (state : Compose.ParserState) (position : Nat) :
    factorBody.eval imports recursions text state position =
      factorStep imports recursions.primary text state position := by
  unfold Body.eval factorBody
  dsimp only
  rw [factor_declarations]
  exact factor_denotation imports recursions text state position

end Silver.BooleanElaboration.Native
