module

public import Silver.StaticBooleanRelationNative
public import Silver.StaticBooleanLoopNative
public import Silver.ComposeBooleanDeclarationSource
public import Silver.ApplicationPackageFrameValidity

@[expose] public section

/-! Complete native type, contract and body requirements for the four exact
Boolean readers. A `Checked` witness must come from the actual complete source
tokens. This file neither supplies that witness nor assumes imported meaning. -/
namespace Silver.BooleanElaboration.Native.SourceChecks
open Silver.SourceBridge

def implHeader : List String := expectedTokens
  "(Text : String; Frame : Parser_State; Position : Literal_Position) return Static_Boolean_Result"

def contractHeader (name : String) (rank : Nat) : List String := implHeader ++ expectedTokens
  ("with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length " ++
   "and then Valid_State (Text, Frame) and then Position <= Text'Last + 1, Post => " ++
   name ++ "'Result.After = 0 or else " ++ name ++ "'Result.After in Position + 1 .. Text'Last + 1, " ++
   "Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => " ++ toString rank ++ ")")

/-- Native field subtypes and the full executable precondition are retained
separately. In particular, position zero and all valid failure states remain. -/
structure Domain (text : Source) (frame : Compose.ParserState) (position : Nat) : Prop where
  textValid : Compose.Expressions.ValidText text
  frameType : ApplicationPackageFrames.StateType frame
  frameValid : ApplicationPackageFrames.stateValid text frame = true
  cursor : position ≤ text.length + 1

def ResultContract (text : Source) (position : Nat) (result : Result) : Prop :=
  result.after = 0 ∨ position < result.after ∧ result.after ≤ text.length + 1

theorem Domain.frameDomain {text frame position} (domain : Domain text frame position) :
    Predicate.OuterReadiness.ValidState text frame :=
  ApplicationPackageFrames.stateValid_domain domain.frameType domain.frameValid

structure Checked (tokens : List String) : Prop where
  resultRecord : Lexical.SourceBridge.recordDeclaration "static_boolean_result" tokens = some
    (expectedTokens "record After : Literal_Position := 0; Value : Boolean := False; end record")
  invalid : Source.declaration "invalid_static_boolean" tokens = some
    (expectedTokens "constant Static_Boolean_Result := (others => <>)")
  primaryHeader : functionHeader "static_boolean_primary" "is" tokens = some
    (contractHeader "Static_Boolean_Primary" 1)
  factorHeader : functionHeader "static_boolean_factor" "is" tokens = some
    (contractHeader "Static_Boolean_Factor" 2)
  relationHeader : functionHeader "static_boolean_relation" "is" tokens = some
    (contractHeader "Static_Boolean_Relation" 3)
  conditionSpec : functionHeader "static_boolean_at" ";" tokens = some
    (contractHeader "Static_Boolean_At" 4)
  conditionImpl : functionHeader "static_boolean_at" "is" tokens = some implHeader
  primaryBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "static_boolean_primary" tokens = some Native.primaryBody.render
  factorBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "static_boolean_factor" tokens = some Native.factorBody.render
  relationBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "static_boolean_relation" tokens = some Relation.render
  conditionBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "static_boolean_at" tokens = some Condition.render

/-- Source matching and typed denotation are conjuncts over the same complete
tree. Imported-call and recursive-call meaning remain explicit parameters. -/
theorem Checked.primary_meaning {tokens} (checked : Checked tokens)
    (imports : Imports) (recursions : Recursions)
    (text : Source) (frame : Compose.ParserState) (position : Nat) :
    Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "static_boolean_primary" tokens =
      some Native.primaryBody.render ∧
    Native.primaryBody.eval imports recursions text frame position =
      primaryStep imports recursions.condition text frame position :=
  ⟨checked.primaryBody, primary_body_denotation imports recursions text frame position⟩

theorem Checked.factor_meaning {tokens} (checked : Checked tokens)
    (imports : Imports) (recursions : Recursions)
    (text : Source) (frame : Compose.ParserState) (position : Nat) :
    Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "static_boolean_factor" tokens =
      some Native.factorBody.render ∧
    Native.factorBody.eval imports recursions text frame position =
      factorStep imports recursions.primary text frame position :=
  ⟨checked.factorBody, factor_body_denotation imports recursions text frame position⟩

theorem Checked.relation_meaning {tokens} (checked : Checked tokens)
    (imports : Imports) (factor : Reader) (initial : Relation.Frame) :
    Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "static_boolean_relation" tokens =
      some Relation.render ∧
    Relation.eval imports factor initial = relationStep imports factor initial.text initial.state initial.position :=
  ⟨checked.relationBody, Relation.denotation imports factor initial⟩

theorem Checked.condition_meaning {tokens} (checked : Checked tokens)
    (imports : Imports) (relation : Reader) (initial : Condition.Frame) (output : Result) :
    Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "static_boolean_at" tokens =
      some Condition.render ∧
    (Condition.BodyExec imports relation initial output ↔
      ConditionExec imports relation initial.text initial.state initial.position output) :=
  ⟨checked.conditionBody, Condition.body_denotation imports relation initial output⟩

end Silver.BooleanElaboration.Native.SourceChecks
