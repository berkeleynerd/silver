module

public import Silver.ImageFilesSplice

@[expose] public section
namespace Silver.ImageModel.FilesSplice

/-! Checks for operators exposed by the existing splice expression syntax.
Opaque token leaves and the inherited Ada/source interpretation remain outside
this structural evidence. All constructors receive explicit rules. -/

def Number.primary : Number → Bool
  | .count | .iterator | .zero | .offset _ | .length _ | .fragmentLength _
  | .big _ | .countBig _ | .inserted _ _ => true
  | .add _ _ => false

def Number.wellFormed : Number → Bool
  | .count | .iterator | .zero | .offset _ | .length _ | .fragmentLength _ => true
  | .big value | .countBig value | .inserted value _ => value.wellFormed
  | .add left right => left.wellFormed && right.wellFormed && right.primary

def Byte.wellFormed : Byte → Bool
  | .get _ index | .fragment _ index => index.wellFormed

/-- A conditional or quantified expression needs its surrounding parentheses;
it cannot be an ungrouped operand of an outer `and then`. -/
def Predicate.logical : Predicate → Bool
  | .numberEqual _ _ | .byteEqual _ _ | .andThen _ _ | .group _ => true
  | .ifCopied _ _ | .allOriginal _ | .allInserted _ _ => false

def Predicate.wellFormed : Predicate → Bool
  | .numberEqual left right => left.wellFormed && right.wellFormed
  | .byteEqual left right => left.wellFormed && right.wellFormed
  | .andThen left right =>
      left.wellFormed && right.wellFormed && left.logical && right.logical
  | .group value => value.wellFormed
  | .ifCopied _ value | .allOriginal value | .allInserted _ value =>
      value.wellFormed && value.logical

theorem checked_precedence : expression.wellFormed = true ∧ expression.logical = true := by decide +kernel

/-- Addition is left-associated in the source, including inside byte indices. -/
theorem arithmetic_controls :
    (Number.add (.add (.countBig .count) (.inserted .count .declarations)) (.inserted .count .includes)).render =
      (Number.add (.countBig .count) (.add (.inserted .count .declarations) (.inserted .count .includes))).render ∧
    (shifted .count).wellFormed = true ∧
    (Number.add (.countBig .count) (.add (.inserted .count .declarations) (.inserted .count .includes))).wellFormed = false ∧
    (Byte.get .refined (.add (.countBig .iterator) (.add .zero .zero))).wellFormed = false ∧
    (Byte.fragment .declarations (.big (.add .iterator (.add .zero .zero)))).wellFormed = false ∧
    (Number.inserted (.countBig (.add .count (.add .zero .zero))) .declarations).wellFormed = false := by decide +kernel

/-- These token collisions move a trailing conjunct across the conditional or
quantifier boundary. The guarded version keeps it inside that expression. -/
theorem predicate_controls :
    (Predicate.group (.ifCopied .declarations (.andThen (.numberEqual .count .zero) (.numberEqual .iterator .zero)))).render =
      (Predicate.group (.andThen (.ifCopied .declarations (.numberEqual .count .zero)) (.numberEqual .iterator .zero))).render ∧
    (Predicate.group (.ifCopied .declarations (.andThen (.numberEqual .count .zero) (.numberEqual .iterator .zero)))).wellFormed = true ∧
    (Predicate.group (.andThen (.ifCopied .declarations (.numberEqual .count .zero)) (.numberEqual .iterator .zero))).wellFormed = false ∧
    (Predicate.group (.allOriginal (.andThen (.numberEqual .count .zero) (.numberEqual .iterator .zero)))).render =
      (Predicate.group (.andThen (.allOriginal (.numberEqual .count .zero)) (.numberEqual .iterator .zero))).render ∧
    (Predicate.group (.allOriginal (.andThen (.numberEqual .count .zero) (.numberEqual .iterator .zero)))).wellFormed = true ∧
    (Predicate.group (.andThen (.allOriginal (.numberEqual .count .zero)) (.numberEqual .iterator .zero))).wellFormed = false ∧
    (Predicate.allInserted .includes (.ifCopied .declarations (.numberEqual .count .zero))).wellFormed = false ∧
    (Predicate.byteEqual (.get .refined (.add .iterator (.add .zero .zero))) (.get .original .iterator)).wellFormed = false ∧
    (Predicate.andThen (.andThen (.numberEqual .count .zero) (.numberEqual .iterator .zero)) (.numberEqual .count .iterator)).wellFormed = true ∧
    (Predicate.andThen (.numberEqual .count .zero) (.andThen (.numberEqual .iterator .zero) (.numberEqual .count .iterator))).wellFormed = true := by decide +kernel

end Silver.ImageModel.FilesSplice
