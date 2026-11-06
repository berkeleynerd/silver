module

public import Silver.PredicateConditionAdmission
public import Silver.ComposeCharacterProperties
public import Silver.PathBounds

@[expose] public section

namespace Silver.Predicate
open Compose Bindings

/-- Both operands retain their actual Character/scalar source trees. At least
one typed name or indexed String resolves Ada's predefined Character type. -/
inductive CharacterRelationAt (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) : Condition → ConditionResult → Prop
  | comparison {left right : Character.Expr} {leftResult rightResult : ValueResult} :
      CharacterAt text context.names (context.readingNames facts) context.arrayNames initials context.elaborating
        position left leftResult →
      CharacterAt text context.names (context.readingNames facts) context.arrayNames initials context.elaborating
        (comparisonAt text leftResult.after).after right rightResult →
      leftResult.after ≠ 0 → (comparisonAt text leftResult.after).after ≠ 0 →
      position < rightResult.after → (leftResult.nonliteralSeen || rightResult.nonliteralSeen) = true →
      CharacterRelationAt text context position facts initials
        (.characterCompare (comparisonAt text leftResult.after).operator left right)
        ⟨rightResult.after, facts, facts⟩

theorem characterRelation_complete {text context position facts initials condition result}
    (parsed : CharacterRelationAt text context position facts initials condition result) :
    characterCondition text context position facts initials = result := by
  cases parsed with
  | comparison left right leftPositive operatorPositive progress typed =>
      simp [characterCondition, character_complete left, character_complete right,
        leftPositive, operatorPositive, Nat.not_le.mpr progress, typed]

theorem characterRelation_sound {text context position facts initials}
    (accepted : (characterCondition text context position facts initials).after ≠ 0) :
    ∃ condition, CharacterRelationAt text context position facts initials condition
      (characterCondition text context position facts initials) := by
  unfold characterCondition at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i good
    rw [ite_eq_right good]
    have leftPositive : (characterAt text position context.names (context.readingNames facts)
        context.arrayNames initials context.elaborating).after ≠ 0 := fun zero => good (Or.inl zero)
    have operatorPositive : (comparisonAt text (characterAt text position context.names (context.readingNames facts)
        context.arrayNames initials context.elaborating).after).after ≠ 0 := fun zero => good (Or.inr (Or.inl zero))
    have progress : position < (characterAt text
        (comparisonAt text (characterAt text position context.names (context.readingNames facts)
          context.arrayNames initials context.elaborating).after).after context.names
        (context.readingNames facts) context.arrayNames initials context.elaborating).after := by
      have h := fun bad => good (Or.inr (Or.inr (Or.inl bad)))
      omega
    have typed : ((characterAt text position context.names (context.readingNames facts)
        context.arrayNames initials context.elaborating).nonliteralSeen ||
        (characterAt text (comparisonAt text (characterAt text position context.names (context.readingNames facts)
          context.arrayNames initials context.elaborating).after).after context.names
        (context.readingNames facts) context.arrayNames initials context.elaborating).nonliteralSeen) = true := by
      have h := fun bad => good (Or.inr (Or.inr (Or.inr bad)))
      cases seen : ((characterAt text position context.names (context.readingNames facts)
          context.arrayNames initials context.elaborating).nonliteralSeen ||
          (characterAt text (comparisonAt text (characterAt text position context.names (context.readingNames facts)
            context.arrayNames initials context.elaborating).after).after context.names
          (context.readingNames facts) context.arrayNames initials context.elaborating).nonliteralSeen) with
      | false => exact False.elim (h (by simp only [seen, Bool.not_false]))
      | true => rfl
    obtain ⟨left, leftReading⟩ := character_sound position leftPositive
    obtain ⟨right, rightReading⟩ := character_sound
      (comparisonAt text (characterAt text position context.names (context.readingNames facts)
        context.arrayNames initials context.elaborating).after).after (by omega)
    exact ⟨_, .comparison leftReading rightReading leftPositive operatorPositive progress typed⟩

theorem characterRelation_meaning {text context position facts initials condition result}
    (normal : NamesNormal context.names)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (parsed : CharacterRelationAt text context position facts initials condition result) :
    condition.Grammatical ∧
      condition.Readable context.hasArguments context.names.shape (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      condition.checkBounds context.names.shape context.analysis (context.flow facts initials)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) = true ∧
      context.flow result.whenTrue initials = condition.refine context.names.shape context.analysis (context.flow facts initials) true ∧
      context.flow result.whenFalse initials = condition.refine context.names.shape context.analysis (context.flow facts initials) false := by
  cases parsed with
  | comparison left right _ _ _ _ =>
      refine ⟨trivial, ⟨character_readable normal left, character_readable normal right,
        character_literals left, character_literals right⟩, ?_, rfl, rfl⟩
      have leftChecked := character_check normal left
      have rightChecked := character_check normal right
      rw [context.reading_ranges compatible initials] at leftChecked rightChecked
      simp only [Condition.checkBounds, leftChecked, rightChecked, Bool.and_self]

theorem characterRelation_positive {text context position facts initials condition result}
    (parsed : CharacterRelationAt text context position facts initials condition result) : result.after ≠ 0 := by
  cases parsed with
  | comparison _ _ _ _ progress _ => simp only; omega

theorem characterRelation_after_bounded {text context position facts initials condition result}
    (parsed : CharacterRelationAt text context position facts initials condition result) : result.after ≤ text.length + 1 := by
  cases parsed with
  | comparison _ right _ _ _ _ => exact character_after_bounded right

theorem characterRelation_unique {text context position facts initials left right leftResult rightResult}
    (first : CharacterRelationAt text context position facts initials left leftResult)
    (second : CharacterRelationAt text context position facts initials right rightResult) : left = right := by
  cases first with
  | comparison leftRead rightRead _ _ _ _ =>
      cases second with
      | comparison otherLeft otherRight _ _ _ _ =>
          obtain ⟨rfl, rfl⟩ := character_unique leftRead otherLeft
          obtain ⟨rfl, rfl⟩ := character_unique rightRead otherRight
          rfl

theorem characterCondition_bounded (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) (bounded : facts.path.Bounded) :
    (characterCondition text context position facts initials).whenTrue.path.Bounded ∧
      (characterCondition text context position facts initials).whenFalse.path.Bounded := by
  unfold characterCondition
  dsimp only
  split
  · exact ⟨PathFacts.Context.empty_bounded, PathFacts.Context.empty_bounded⟩
  · exact ⟨bounded, bounded⟩

end Silver.Predicate
