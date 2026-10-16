module

public import Silver.PredicateLoopNative
public import Silver.ComposeContracts

@[expose] public section
namespace Silver.Predicate.LoopNative
open Compose

attribute [local irreducible] ScalarExpression.read

/-- These are all token constants used by the checked loop body. -/
def loopTokens : List ShellToken :=
  [.word "for", .word "in", .word "reverse", .symbol "..", .word "loop", .word "end", .symbol ";"]

def CursorDomain (text : Source) (position : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position

def TokenDomain (text : Source) (position : Nat) (token : ShellToken) : Prop :=
  CursorDomain text position ∧ token ∈ loopTokens

def NameDomain (text : Source) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidName text first after

def WordDomain (text : Source) (first after : Nat) (word : String) : Prop :=
  NameDomain text first after ∧ 0 < word.toList.length ∧ word.toList.length ≤ 16

def ScalarDomain (text : Source) (position : Nat) (names : ScalarExpression.Environment)
    (first after : Nat) : Prop :=
  CursorDomain text position ∧ ScalarExpression.ValidEnvironment text names ∧ ScalarExpression.ValidMask text first after

/-- Native argument domains only. Source-derived component proofs discharge
these pointwise meanings; none assert a loop-scanner equivalence. -/
structure ImportsMeaning (imports : Imports) : Prop where
  token : ∀ text position token, TokenDomain text position token →
    imports.token text position token = tokenAfter text position token
  skip : ∀ text position, CursorDomain text position → imports.skip text position = skipAt text position
  nameAfter : ∀ text position, CursorDomain text position → imports.nameAfter text position = Compose.nameAfter text position
  forbidden : ∀ text first after, NameDomain text first after →
    imports.forbidden text first after = Named.forbiddenName text first after
  nameIs : ∀ text first after word, WordDomain text first after word →
    imports.nameIs text first after word = Named.nameIs text first after (word.toList.map Char.toNat)
  readScalar : ∀ text position names first after, ScalarDomain text position names first after →
    imports.readScalar text position names first after = ScalarExpression.read text position names first after
  append : ∀ names item, names.length < ScalarExpression.maxBindings → imports.append names item = names ++ [item]
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
    skip := fun text position => if CursorDomain text position then imports.skip text position else modelImports.skip text position
    nameAfter := fun text position => if CursorDomain text position then imports.nameAfter text position else modelImports.nameAfter text position
    forbidden := fun text first after => if NameDomain text first after then imports.forbidden text first after else modelImports.forbidden text first after
    nameIs := fun text first after word => if WordDomain text first after word then imports.nameIs text first after word else modelImports.nameIs text first after word
    readScalar := fun text position names first after => if ScalarDomain text position names first after then imports.readScalar text position names first after else modelImports.readScalar text position names first after
    append := fun names item => if names.length < ScalarExpression.maxBindings then imports.append names item else modelImports.append names item
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

theorem totalizeImports_readScalar (imports : Imports) (text : Source) (position : Nat) (names : ScalarExpression.Environment) (first after : Nat)
    (valid : ScalarDomain text position names first after) :
    (totalizeImports imports).readScalar text position names first after = imports.readScalar text position names first after := by
  simp only [totalizeImports, valid, ↓reduceIte]

theorem totalizeImports_append (imports : Imports) (names : ScalarExpression.Environment) (item : ScalarExpression.Binding)
    (valid : names.length < ScalarExpression.maxBindings) :
    (totalizeImports imports).append names item = imports.append names item := by
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
  · funext text position names first after
    dsimp only [totalizeImports]
    split
    · exact meaning.readScalar text position names first after ‹_›
    · rfl
  · funext names item
    dsimp only [totalizeImports]
    split
    · exact meaning.append names item ‹_›
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
  skip _ _ _ := rfl
  nameAfter _ _ _ := rfl
  forbidden _ _ _ _ := rfl
  nameIs _ _ _ _ _ := rfl
  readScalar _ _ _ _ _ _ := rfl
  append _ _ _ := rfl
  isEmpty _ _ := rfl
  normalize _ _ := rfl
  join _ _ := rfl
  emptyBounds := rfl
  emptyFacts := rfl

def Test.tokenCalls : Test → List ShellToken
  | .reverse => [.word "reverse"] | _ => []

def Update.tokenCalls : Update → List ShellToken
  | .inside => [.word "in"] | .reverse => [.word "reverse"] | .delimiter => [.symbol ".."]
  | .opening => [.word "loop"] | .token tok => [tok] | _ => []

def Command.tokenCalls : Command → List ShellToken
  | .update value => value.tokenCalls
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
