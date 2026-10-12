module

public import Silver.Expressions

@[expose] public section

/-!
Checks the Ada expression grammar categories of the selected typed trees.
The renderer does not insert grouping silently: these conditions require
explicit groups wherever flattening would change precedence or association.
They follow Ada 2022 RM 4.4: simple expressions, relations, logical expressions,
primary operands of `not`, and grouped conditional/quantified expressions.
-/

namespace Silver.Expressions

def Number.primary : Number → Bool
  | .add _ _ | .sub _ _ | .ite _ _ _ | .elsif _ _ _ => false
  | _ => true

def Number.simple : Number → Bool
  | .ite _ _ _ | .elsif _ _ _ => false
  | _ => true

def Number.isElsif : Number → Bool
  | .elsif _ _ _ => true
  | _ => false

def Condition.primary : Condition → Bool
  | .wordFlag | .group _ | .whitespace _ | .identifier _ | .lineEnd _ | .allowed _
  | .tokenAt _ _ | .suffix _ _ | .allowedNormalized | .suffixNormalized => true
  | _ => false

def Condition.relation : Condition → Bool
  | .andThen _ _ | .orElse _ _ | .forallWord _ | .forallText _ | .ite _ _ _ => false
  | _ => true

def Condition.logical : Condition → Bool
  | .forallWord _ | .forallText _ | .ite _ _ _ => false
  | _ => true

def Condition.andLeft : Condition → Bool
  | .andThen _ _ => true
  | value => value.relation

def Condition.orLeft : Condition → Bool
  | .orElse _ _ => true
  | value => value.relation

mutual
def Number.wellFormed : Number → Bool
  | .add left right | .sub left right =>
      left.wellFormed && right.wellFormed && left.simple && right.primary
  | .group value => value.wellFormed && !value.isElsif
  | .textAt argument | .wordAt argument | .introducerAt argument | .lower argument
  | .comment argument | .trivia argument | .spellingLength argument
  | .characterVal argument | .characterPos argument =>
      argument.wellFormed && argument.simple
  | .ite condition yes no | .elsif condition yes no =>
      condition.wellFormed && condition.logical && yes.wellFormed && yes.simple &&
        no.wellFormed && (no.simple || no.isElsif)
  | _ => true

def Condition.wellFormed : Condition → Bool
  | .wordFlag | .allowedNormalized | .suffixNormalized => true
  | .equal left right | .less left right | .greater left right | .lessEqual left right =>
      left.wellFormed && right.wellFormed && left.simple && right.simple
  | .range value first bound =>
      value.wellFormed && first.wellFormed && bound.wellFormed && value.simple && first.simple && bound.simple
  | .andThen left right => left.wellFormed && right.wellFormed && left.andLeft && right.relation
  | .orElse left right => left.wellFormed && right.wellFormed && left.orLeft && right.relation
  | .not value => value.wellFormed && value.primary
  | .group value => value.wellFormed
  | .whitespace value | .identifier value | .lineEnd value | .allowed value =>
      value.wellFormed && value.simple
  | .forallWord body | .forallText body => body.wellFormed && body.logical
  | .tokenAt cursor token | .suffix cursor token =>
      cursor.wellFormed && token.wellFormed && cursor.simple && token.simple
  | .ite condition yes no => condition.wellFormed && yes.wellFormed && no.wellFormed &&
      condition.logical && yes.logical && no.logical
end

theorem checked_expression_precedence :
    commentBody.wellFormed = true ∧ triviaBody.wellFormed = true ∧
    tokenBody.wellFormed = true ∧ suffixBody.wellFormed = true ∧
    memberBody.wellFormed = true ∧ allowedBody.wellFormed = true ∧
    whitespaceBody.wellFormed = true ∧ allowedCharacterBody.wellFormed = true ∧
    lineEndBody.wellFormed = true ∧ identifierBody.wellFormed = true ∧
    lowercaseBody.wellFormed = true := by decide

end Silver.Expressions
