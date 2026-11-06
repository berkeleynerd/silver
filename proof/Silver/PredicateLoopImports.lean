module

public import Silver.PredicateLoopNative
public import Silver.ComposeContracts
public import Silver.PredicateBodyControls

@[expose] public section
namespace Silver.Predicate.LoopNative
open Compose

attribute [local irreducible] ScalarExpression.read

/-- These are all token constants used by the checked loop body. -/
def loopTokens : List ShellToken :=
  [.word "for", .word "in", .word "of", .word "reverse", .symbol "..", .word "loop", .word "end", .symbol ";"]

def CursorDomain (text : Source) (position : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position

def TokenDomain (text : Source) (position : Nat) (token : ShellToken) : Prop :=
  CursorDomain text position ∧ token ∈ loopTokens

def BodyTokenDomain (text : Source) (context : Native.Context) (scan : BodyScan) (token : ShellToken) : Prop :=
  (Expressions.ValidText text ∧ Native.ValidContext text context ∧
    scan.position ≤ text.length + 1 ∧ Controls context.model scan ∧ Native.ValidFlow context scan.facts) ∧
    token ∈ loopTokens

def NameDomain (text : Source) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidName text first after

def WordDomain (text : Source) (first after : Nat) (word : String) : Prop :=
  NameDomain text first after ∧ 0 < word.toList.length ∧ word.toList.length ≤ 16

def EqualNameDomain (text : Source) (first after otherFirst otherAfter : Nat) : Prop :=
  NameDomain text first after ∧ Expressions.ValidName text otherFirst otherAfter

def ArrayTargetDomain (text : Source) (context : Native.Context) (position : Nat) : Prop :=
  Expressions.ValidText text ∧ Native.ValidContext text context ∧ Expressions.ValidCursor text position

def FlowDomain (text : Source) (context : Native.Context) (facts : ActiveFlow) : Prop :=
  Expressions.ValidText text ∧ Native.ValidContext text context ∧ Native.ValidFlow context facts

def ScalarDomain (text : Source) (context : Native.Context) (position : Nat) (facts : ActiveFlow)
    (first after : Nat) : Prop :=
  FlowDomain text context facts ∧ position ≤ text.length + 1 ∧ ScalarExpression.ValidMask text first after

def WidenDomain (context : Native.Context) (facts : ActiveFlow) : Prop :=
  facts.count = context.scalarNames.length ∧ context.scalarNames.length ≤ ScalarExpression.maxBindings

/-- Native argument domains only. Source-derived component proofs discharge
these pointwise meanings; none assert a loop-scanner equivalence. -/
structure ImportsMeaning (imports : Imports) : Prop where
  token : ∀ text position token, TokenDomain text position token →
    imports.token text position token = tokenAfter text position token
  bodyToken : ∀ text context scan token, BodyTokenDomain text context scan token →
    imports.bodyToken text context scan token = Predicate.bodyToken text scan token
  invalid : ∀ scan, scan.count ≤ ScalarExpression.maxBindings → imports.invalid scan = invalidBody scan
  skip : ∀ text position, CursorDomain text position → imports.skip text position = skipAt text position
  nameAfter : ∀ text position, CursorDomain text position → imports.nameAfter text position = Compose.nameAfter text position
  forbidden : ∀ text first after, NameDomain text first after →
    imports.forbidden text first after = Named.forbiddenName text first after
  nameIs : ∀ text first after word, WordDomain text first after word →
    imports.nameIs text first after word = Named.nameIs text first after (word.toList.map Char.toNat)
  equalName : ∀ text first after otherFirst otherAfter, EqualNameDomain text first after otherFirst otherAfter →
    imports.equalName text first after otherFirst otherAfter = Named.equalName text first after otherFirst otherAfter
  arrayTarget : ∀ text context position, ArrayTargetDomain text context position →
    imports.arrayTarget text context position = Predicate.arrayTarget text context.model position
  readScalar : ∀ text context position facts first after, ScalarDomain text context position facts first after →
    imports.readScalar text context position facts first after =
      readCountedBound text context.model position facts first after
  widen : ∀ context facts, WidenDomain context facts →
    imports.widen context facts = ActiveFlow.widen context.scalarNames facts
  isEmpty : ∀ value, value.Bounded → imports.isEmpty value = value.isEmpty
  normalize : ∀ value, value.Bounded → imports.normalize value = value.normalize
  join : ∀ left right, imports.join left right = left.join right
  emptyBounds : imports.emptyBounds = Integer.Interval.empty
  emptyFacts : imports.emptyFacts = PathFacts.Context.empty

/-- Formal extension beyond the checked call domains. It retains every legal
native call, and is used only to state total mathematical source equations. -/
noncomputable def totalizeImports (imports : Imports) : Imports := by
  classical
  exact {
    token := fun text position token => if TokenDomain text position token then imports.token text position token else modelImports.token text position token
    bodyToken := fun text context scan token => if BodyTokenDomain text context scan token then
      imports.bodyToken text context scan token else modelImports.bodyToken text context scan token
    invalid := fun scan => if scan.count ≤ ScalarExpression.maxBindings then imports.invalid scan else modelImports.invalid scan
    skip := fun text position => if CursorDomain text position then imports.skip text position else modelImports.skip text position
    nameAfter := fun text position => if CursorDomain text position then imports.nameAfter text position else modelImports.nameAfter text position
    forbidden := fun text first after => if NameDomain text first after then imports.forbidden text first after else modelImports.forbidden text first after
    nameIs := fun text first after word => if WordDomain text first after word then imports.nameIs text first after word else modelImports.nameIs text first after word
    equalName := fun text first after otherFirst otherAfter => if EqualNameDomain text first after otherFirst otherAfter then
      imports.equalName text first after otherFirst otherAfter else modelImports.equalName text first after otherFirst otherAfter
    arrayTarget := fun text context position => if ArrayTargetDomain text context position then
      imports.arrayTarget text context position else modelImports.arrayTarget text context position
    readScalar := fun text context position facts first after =>
      if ScalarDomain text context position facts first after then imports.readScalar text context position facts first after
      else modelImports.readScalar text context position facts first after
    widen := fun context facts => if WidenDomain context facts then imports.widen context facts else modelImports.widen context facts
    isEmpty := fun value => if value.Bounded then imports.isEmpty value else modelImports.isEmpty value
    normalize := fun value => if value.Bounded then imports.normalize value else modelImports.normalize value
    join := imports.join
    emptyBounds := imports.emptyBounds
    emptyFacts := imports.emptyFacts }

theorem totalizeImports_token (imports : Imports) (text : Source) (position : Nat) (token : ShellToken)
    (valid : TokenDomain text position token) :
    (totalizeImports imports).token text position token = imports.token text position token := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_skip (imports : Imports) (text : Source) (position : Nat)
    (valid : CursorDomain text position) :
    (totalizeImports imports).skip text position = imports.skip text position := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_bodyToken (imports : Imports) (text : Source) (context : Native.Context)
    (scan : BodyScan) (token : ShellToken) (valid : BodyTokenDomain text context scan token) :
    (totalizeImports imports).bodyToken text context scan token = imports.bodyToken text context scan token := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_invalid (imports : Imports) (scan : BodyScan)
    (capacity : scan.count ≤ ScalarExpression.maxBindings) :
    (totalizeImports imports).invalid scan = imports.invalid scan := by
  simp only [totalizeImports, capacity, ↓reduceIte]

theorem totalizeImports_nameAfter (imports : Imports) (text : Source) (position : Nat)
    (valid : CursorDomain text position) :
    (totalizeImports imports).nameAfter text position = imports.nameAfter text position := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_forbidden (imports : Imports) (text : Source) (first after : Nat)
    (valid : NameDomain text first after) :
    (totalizeImports imports).forbidden text first after = imports.forbidden text first after := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_nameIs (imports : Imports) (text : Source) (first after : Nat) (word : String)
    (valid : WordDomain text first after word) :
    (totalizeImports imports).nameIs text first after word = imports.nameIs text first after word := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_readScalar (imports : Imports) (text : Source) (context : Native.Context)
    (position : Nat) (facts : ActiveFlow) (first after : Nat)
    (valid : ScalarDomain text context position facts first after) :
    (totalizeImports imports).readScalar text context position facts first after =
      imports.readScalar text context position facts first after := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_equalName (imports : Imports) (text : Source) (first after otherFirst otherAfter : Nat)
    (valid : EqualNameDomain text first after otherFirst otherAfter) :
    (totalizeImports imports).equalName text first after otherFirst otherAfter = imports.equalName text first after otherFirst otherAfter := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_arrayTarget (imports : Imports) (text : Source) (context : Native.Context) (position : Nat)
    (valid : ArrayTargetDomain text context position) :
    (totalizeImports imports).arrayTarget text context position = imports.arrayTarget text context position := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_widen (imports : Imports) (context : Native.Context) (facts : ActiveFlow)
    (valid : WidenDomain context facts) :
    (totalizeImports imports).widen context facts = imports.widen context facts := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_isEmpty (imports : Imports) (value : Integer.Interval)
    (valid : value.Bounded) :
    (totalizeImports imports).isEmpty value = imports.isEmpty value := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_normalize (imports : Imports) (value : Integer.Interval)
    (valid : value.Bounded) :
    (totalizeImports imports).normalize value = imports.normalize value := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_eq_model {imports : Imports} (meaning : ImportsMeaning imports) :
    totalizeImports imports = modelImports := by
  apply Imports.ext
  · funext text position token
    dsimp only [totalizeImports]
    split
    · exact meaning.token text position token ‹_›
    · rfl
  · funext text context scan token
    dsimp only [totalizeImports]
    split
    · exact meaning.bodyToken text context scan token ‹_›
    · rfl
  · funext scan
    dsimp only [totalizeImports]
    split
    · exact meaning.invalid scan ‹_›
    · rfl
  · funext text position
    dsimp only [totalizeImports]
    split
    · exact meaning.skip text position ‹_›
    · rfl
  · funext text position
    dsimp only [totalizeImports]
    split
    · exact meaning.nameAfter text position ‹_›
    · rfl
  · funext text first after
    dsimp only [totalizeImports]
    split
    · exact meaning.forbidden text first after ‹_›
    · rfl
  · funext text first after word
    dsimp only [totalizeImports]
    split
    · exact meaning.nameIs text first after word ‹_›
    · rfl
  · funext text first after otherFirst otherAfter
    dsimp only [totalizeImports]
    split
    · exact meaning.equalName text first after otherFirst otherAfter ‹_›
    · rfl
  · funext text context position
    dsimp only [totalizeImports]
    split
    · exact meaning.arrayTarget text context position ‹_›
    · rfl
  · funext text context position facts first after
    dsimp only [totalizeImports]
    split
    · exact meaning.readScalar text context position facts first after ‹_›
    · rfl
  · funext context facts
    dsimp only [totalizeImports]
    split
    · exact meaning.widen context facts ‹_›
    · rfl
  · funext value
    dsimp only [totalizeImports]
    split
    · exact meaning.isEmpty value ‹_›
    · rfl
  · funext value
    dsimp only [totalizeImports]
    split
    · exact meaning.normalize value ‹_›
    · rfl
  · exact funext fun left => funext fun right => meaning.join left right
  · exact meaning.emptyBounds
  · exact meaning.emptyFacts

theorem evalWith_of_meaning {imports : Imports} (meaning : ImportsMeaning imports)
    (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) :
    evalWith (totalizeImports imports) read text context scan = eval read text context scan := by
  rw [totalizeImports_eq_model meaning, evalWith_model]

theorem model_imports_meaning : ImportsMeaning modelImports where
  token _ _ _ _ := rfl
  bodyToken _ _ _ _ _ := rfl
  invalid _ _ := rfl
  skip _ _ _ := rfl
  nameAfter _ _ _ := rfl
  forbidden _ _ _ _ := rfl
  nameIs _ _ _ _ _ := rfl
  equalName _ _ _ _ _ _ := rfl
  arrayTarget _ _ _ _ := rfl
  readScalar _ _ _ _ _ _ _ := rfl
  widen _ _ _ := rfl
  isEmpty _ _ := rfl
  normalize _ _ := rfl
  join _ _ := rfl
  emptyBounds := rfl
  emptyFacts := rfl

def Test.tokenCalls : Test → List ShellToken
  | .array => [.word "of"] | .reverse => [.word "reverse"] | _ => []

def Update.tokenCalls : Update → List ShellToken
  | .inside => [.word "in"] | .iterable => [.word "of"] | .reverse => [.word "reverse"] | .delimiter => [.symbol ".."]
  | .opening | .arrayOpening => [.word "loop"] | .token tok => [tok] | _ => []

def Command.tokenCalls : Command → List ShellToken
  | .update value => value.tokenCalls
  | .scope body | .arrayScope body => body.tokenCalls
  | .sequence first second => first.tokenCalls ++ second.tokenCalls
  | .choose test yes no => test.tokenCalls ++ yes.tokenCalls ++ no.tokenCalls
  | _ => []

/-- The initial Body_Token and every command token remain in the exact finite
native enum domain, including unreachable branches. -/
theorem loop_tokens_complete :
    ∀ token ∈ .word "for" :: commands.tokenCalls, token ∈ loopTokens := by
  have checked : ((.word "for" :: commands.tokenCalls).all
    (fun token => decide (token ∈ loopTokens))) = true := by decide +kernel
  intro token present
  exact of_decide_eq_true ((List.all_eq_true.mp checked) token present)

end Silver.Predicate.LoopNative
