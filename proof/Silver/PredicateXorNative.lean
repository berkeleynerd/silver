module

public import Silver.PredicateXorAdmission
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.XorNative

set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true
set_option linter.unusedSimpArgs false

structure Calls where
  characterLiteral : Source → Nat → Nat
  model : Source → Nat → Nat → Bool → Bool → Bool → Bool
  xorFree : Source → Nat → Nat → Bool

/-- Only the bounded offsets and byte operations used by the native scanner.
The closed operands prevent an infix tree from changing Ada association. -/
inductive Number
  | position | after | characterAfter | constant (n : Nat)
  | offset (n : Nat) | remaining
  | byte (offset : Nat) | lowerByte (offset : Nat)
  deriving Repr

structure Frame where
  text : Source
  position : Nat
  after : Nat
  quoted : Bool
  comment : Bool
  wordStart : Bool

def Number.eval (calls : Calls) (f : Frame) : Number → Nat
  | .position => f.position | .after => f.after | .constant n => n
  | .characterAfter => calls.characterLiteral f.text f.position
  | .offset n => f.position + n | .remaining => f.after - f.position
  | .byte n => Cursor.byteAt f.text (f.position + n)
  | .lowerByte n => lowercase (Cursor.byteAt f.text (f.position + n))

def Number.render : Number → List String
  | .position => ["position"] | .after => ["after"] | .constant n => [toString n]
  | .characterAfter => ["character_literal_after", "(", "text", ",", "position", ")"]
  | .offset n => ["position", "+", toString n] | .remaining => ["after", "-", "position"]
  | .byte n => ["text", "("] ++ (if n = 0 then ["position"] else ["position", "+", toString n]) ++ [")"]
  | .lowerByte n => ["lowercase", "(", "text", "("] ++ (if n = 0 then ["position"] else ["position", "+", toString n]) ++ [")", ")"]

inductive Test
  | truth (value : Bool) | quoted | comment | wordStart
  | eq (left right : Number) | ne (left right : Number) | le (left right : Number) | lt (left right : Number) | gt (left right : Number) | ge (left right : Number)
  | charEq (left : Number) (value : Nat)
  | quoteEq (left : Number)
  | commentEnd | identifier (offset : Nat)
  | not (value : Test) | group (value : Test)
  | andThen (left right : Test) | orElse (left right : Test)
  deriving Repr

def Test.eval (calls : Calls) (f : Frame) : Test → Bool
  | .truth value => value | .quoted => f.quoted | .comment => f.comment | .wordStart => f.wordStart
  | .eq a b => decide (a.eval calls f = b.eval calls f) | .lt a b => decide (a.eval calls f < b.eval calls f)
  | .ne a b => decide (a.eval calls f ≠ b.eval calls f) | .le a b => decide (a.eval calls f ≤ b.eval calls f)
  | .gt a b => decide (a.eval calls f > b.eval calls f) | .ge a b => decide (a.eval calls f ≥ b.eval calls f)
  | .charEq a n => decide (a.eval calls f = n) | .quoteEq a => decide (a.eval calls f = 34)
  | .commentEnd => lineEnd (Cursor.byteAt f.text f.position)
  | .identifier n => identifierCharacter (Cursor.byteAt f.text (f.position + n))
  | .not value => !(value.eval calls f) | .group value => value.eval calls f
  | .andThen a b => a.eval calls f && b.eval calls f | .orElse a b => a.eval calls f || b.eval calls f

def Test.render : Test → List String
  | .truth value => [if value then "true" else "false"]
  | .quoted => ["quoted"] | .comment => ["comment"] | .wordStart => ["word_start"]
  | .eq a b => a.render ++ ["="] ++ b.render | .lt a b => a.render ++ ["<"] ++ b.render
  | .ne a b => a.render ++ ["/="] ++ b.render | .le a b => a.render ++ ["<="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render | .ge a b => a.render ++ [">="] ++ b.render
  | .charEq a n => a.render ++ ["=", "'" ++ String.singleton (Char.ofNat n) ++ "'"]
  | .quoteEq a => a.render ++ ["=", "character", "'", "val", "(", "34", ")"]
  | .commentEnd => ["is_comment_end", "(", "text", "(", "position", ")", ")"]
  | .identifier n => ["is_identifier_character", "("] ++ (.byte n : Number).render ++ [")"]
  | .not value => ["not"] ++ value.render | .group value => ["("] ++ value.render ++ [")"]
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .orElse a b => a.render ++ ["or", "else"] ++ b.render

/-- Logical operator families may mix only under an explicit group. -/
def Test.primary : Test → Bool
  | .truth _ | .quoted | .comment | .wordStart | .commentEnd | .identifier _ | .group _ => true
  | _ => false

def Test.relation : Test → Bool
  | .andThen _ _ | .orElse _ _ => false
  | _ => true

def Test.andLeft : Test → Bool
  | .orElse _ _ => false | _ => true

def Test.orLeft : Test → Bool
  | .andThen _ _ => false | _ => true

def Test.wellFormed : Test → Bool
  | .not t => t.primary && t.wellFormed | .group t => t.wellFormed
  | .andThen a b => a.andLeft && b.relation && a.wellFormed && b.wellFormed
  | .orElse a b => a.orLeft && b.relation && a.wellFormed && b.wellFormed
  | _ => true

inductive Tree
  | value (value : Bool)
  | characterRecurse
  | recurse (offset : Nat) (q c w : Test)
  | ite (condition : Test) (yes no : Tree)
  | group (body : Tree)
  deriving Repr

def Tree.eval (calls : Calls) (f : Frame) : Tree → Bool
  | .value result => result
  | .characterRecurse => calls.model f.text (calls.characterLiteral f.text f.position) f.after false false true
  | .recurse n q c w => calls.model f.text (f.position + n) f.after (q.eval calls f) (c.eval calls f) (w.eval calls f)
  | .ite c a b => if c.eval calls f then a.eval calls f else b.eval calls f
  | .group body => body.eval calls f

def Tree.render : Tree → List String
  | .value result => [if result then "true" else "false"]
  | .characterRecurse => ["xor_free_model", "(", "text", ","] ++ Number.characterAfter.render ++
      [",", "after", ",", "false", ",", "false", ",", "true", ")"]
  | .recurse n q c w => ["xor_free_model", "(", "text", ",", "position", "+", toString n,
      ",", "after", ","] ++ q.render ++ [","] ++ c.render ++ [","] ++ w.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .ite _ _ _ => ["elsif"] ++ b.render.drop 1 | _ => ["else"] ++ b.render)
  | .group body => ["("] ++ body.render ++ [")"]

def Tree.branch : Tree → Bool
  | .ite _ _ _ => false | _ => true

def Tree.wellFormed : Tree → Bool
  | .value _ | .characterRecurse => true
  | .recurse _ q c w => q.wellFormed && c.wellFormed && w.wellFormed
  | .ite c a b => c.wellFormed && a.branch && a.wellFormed && b.wellFormed
  | .group body => body.wellFormed

def body : Tree :=
  .ite (.orElse (.eq .position (.constant 0)) (.gt .position .after)) (.value false) <|
  .ite (.eq .position .after) (.value true) <|
  .ite .comment (.recurse 1 (.truth false) (.not .commentEnd) (.truth true)) <|
  .ite .quoted (.group <|
    .ite (.quoteEq (.byte 0)) (.group <|
      .ite (.andThen (.lt (.offset 1) .after) (.quoteEq (.byte 1)))
        (.recurse 2 (.truth true) (.truth false) (.truth true))
        (.recurse 1 (.truth false) (.truth false) (.truth true)))
      (.recurse 1 (.truth true) (.truth false) (.truth true))) <|
  .ite (.andThen (.andThen (.charEq (.byte 0) 45) (.lt (.offset 1) .after)) (.charEq (.byte 1) 45))
    (.recurse 2 (.truth false) (.truth true) (.truth true)) <|
  .ite (.andThen (.ne .characterAfter (.constant 0)) (.le .characterAfter .after)) .characterRecurse <|
  .ite (.quoteEq (.byte 0)) (.recurse 1 (.truth true) (.truth false) (.truth true)) <|
  .ite (.andThen (.andThen (.andThen (.andThen (.andThen .wordStart (.ge .remaining (.constant 3)))
      (.charEq (.lowerByte 0) 120)) (.charEq (.lowerByte 1) 111)) (.charEq (.lowerByte 2) 114))
      (.group (.orElse (.eq (.offset 3) .after) (.not (.identifier 3)))))
    (.value false) (.recurse 1 (.truth false) (.truth false) (.not (.identifier 0)))

theorem body_precedence : body.wellFormed = true := rfl

abbrev ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ maxSourceLength

structure Equations (calls : Calls) : Prop where
  characterLiteral : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.characterLiteral text position = Compose.characterLiteralAfter text position
  model : ∀ text, ValidText text → ∀ position after quoted comment wordStart,
    position ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.model text position after quoted comment wordStart =
      body.eval calls ⟨text,position,after,quoted,comment,wordStart⟩
  runtime : ∀ text, ValidText text → ∀ first after,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.xorFree text first after = calls.model text first after false false true

def modelCalls : Calls := ⟨Compose.characterLiteralAfter, xorFreeModel, xorFree⟩

theorem model_equations : Equations modelCalls where
  characterLiteral := by intros; rfl
  model text _ position after quoted comment wordStart _ _ := by
    rw [show modelCalls.model = xorFreeModel from rfl, xorFreeModel]
    dsimp +instances only [body, Tree.eval, Test.eval, Number.eval, modelCalls]
    simp only [Nat.add_zero, Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq, and_assoc]

  runtime := by intros; rfl

theorem model_meaning (calls : Calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position after : Nat)
    (quoted comment wordStart : Bool) (pb : position ≤ text.length + 1) (ab : after ≤ text.length + 1) :
    calls.model text position after quoted comment wordStart = xorFreeModel text position after quoted comment wordStart := by
  rw [equations.model text valid position after quoted comment wordStart pb ab, xorFreeModel]
  dsimp +instances only [body, Tree.eval, Test.eval, Number.eval]
  rw [equations.characterLiteral text valid position pb]
  simp only [Nat.add_zero]
  simp only [Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq, and_assoc]
  split
  · simp_all
  · split
    · simp_all
    · repeat (any_goals (first | split | rfl))
      all_goals simp_all
      all_goals apply model_meaning calls equations text valid <;> omega

termination_by after - position
decreasing_by
  all_goals try omega
  have advances := Compose.characterLiteralAfter_bounds (text := text) (position := position) (by omega)
  omega

end Silver.Predicate.XorNative
