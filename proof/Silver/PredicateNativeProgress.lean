module

public import Silver.PredicateNativeRanges

@[expose] public section

namespace Silver.Predicate.Native
open Compose Compose.Expressions

set_option backward.dsimp.instances true

theorem booleanArray_progress (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (accepted : booleanArrayAfter text context position facts ≠ 0) :
    position < booleanArrayAfter text context position facts := by
  unfold booleanArrayAfter at accepted ⊢
  dsimp only at accepted ⊢
  split <;> (try simp only [*, ↓reduceIte] at accepted)
  · contradiction
  · rename_i allowed
    omega

theorem booleanAtom_progress (text : Source) (context : ParseContext) (position : Nat)
    (bounded : position ≤ text.length + 1) (accepted : booleanAtomAfter text context position ≠ 0) :
    position < booleanAtomAfter text context position := by
  unfold booleanAtomAfter at accepted ⊢
  dsimp only at accepted ⊢
  split <;> (try simp only [*, ↓reduceIte] at accepted)
  · contradiction
  · rename_i allowed
    have firstNonzero : skipAt text position ≠ 0 := fun bad => allowed (Or.inl bad)
    have advanced : skipAt text position < nameAfter text (skipAt text position) :=
      Nat.lt_of_not_ge (fun bad => allowed (Or.inr (Or.inl bad)))
    have skipped := skipAt_advances text position bounded firstNonzero
    split <;> (try simp only [*, ↓reduceIte] at accepted)
    · omega
    · split <;> (try simp only [*, ↓reduceIte] at accepted)
      · omega
      · contradiction

theorem primary_progress (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) {initials : ArrayBindings.Initials}
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : position ≤ text.length + 1) (accepted : (readPrimary text context position facts initials).after ≠ 0) :
    position < (readPrimary text context position facts initials).after := by
  by_cases zero : position = 0
  · simp [readPrimary, zero, invalidCondition] at accepted
  · by_cases opening : fixedAfter text position "(" false ≠ 0
    · by_cases advanced : remainingAt text (fixedAfter text position "(" false) < remainingAt text position
      · have closed : fixedAfter text (readCondition text context (fixedAfter text position "(" false) facts initials).after ")" false ≠ 0 := by
          intro absent
          simp [readPrimary, zero, opening, advanced, absent, invalidCondition] at accepted
        have innerPositive := (model_fixed_input_nonzero _ _ _ _) closed
        have afterBound := model_fixed_valid text position "(" false bounded
        have start := model_fixed_advances text position "(" false bounded (by decide) opening
        have inner := condition_progress text context _ facts innerPositive
        have innerBound := condition_bound text context _ facts textValid namesValid afterBound (initials := initials)
        have stop := model_fixed_advances text _ ")" false innerBound (by decide) closed
        simp [readPrimary, zero, opening, advanced, closed]
        omega
      · simp [readPrimary, zero, opening, advanced, invalidCondition] at accepted
    · have noOpening : fixedAfter text position "(" false = 0 := by omega
      by_cases array : booleanArrayAfter text context position facts ≠ 0
      · simpa only [readPrimary, zero, noOpening, array, ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte]
          using booleanArray_progress text context position facts array
      · have noArray : booleanArrayAfter text context position facts = 0 := by omega
        by_cases atom : booleanAtomAfter text context position ≠ 0
        · simpa only [readPrimary, zero, noOpening, noArray, atom, ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte]
            using booleanAtom_progress text context position bounded atom
        · have noAtom : booleanAtomAfter text context position = 0 := by omega
          have arguments : context.hasArguments = true := by
            cases arguments : context.hasArguments with
            | false => simp [readPrimary, zero, noOpening, noArray, noAtom, arguments, invalidCondition] at accepted
            | true => rfl
          have finalPositive : callAfter text context.names position .validity context.scalarNames context.arrayNames
              (context.validityHidden text) context.booleanNames ≠ 0 := by
            intro absent
            simp [readPrimary, zero, noOpening, noArray, noAtom, arguments, absent, invalidCondition] at accepted
          have progress := model_callAfter_advances text context.names position .validity bounded finalPositive
          simpa only [readPrimary, zero, noOpening, noArray, noAtom, arguments, ne_eq, not_true_eq_false,
            Bool.not_true, Bool.false_eq_true, finalPositive, ↓reduceIte] using progress

theorem booleanFactor_progress (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    {initials : ArrayBindings.Initials}
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : position ≤ text.length + 1) (accepted : (readBooleanFactor text context position facts initials).after ≠ 0) :
    position < (readBooleanFactor text context position facts initials).after := by
  by_cases noNot : fixedAfter text position "not" true = 0
  · simp only [readBooleanFactor, noNot, ↓reduceIte] at accepted ⊢
    exact primary_progress text context position facts textValid namesValid bounded accepted
  · by_cases advanced : remainingAt text (fixedAfter text position "not" true) < remainingAt text position
    · have positive : (readPrimary text context (fixedAfter text position "not" true) facts initials).after ≠ 0 := by
        simpa only [readBooleanFactor, noNot, advanced, ↓reduceIte, ↓reduceDIte] using accepted
      have inner := primary_progress text context _ facts textValid namesValid
        (model_fixed_valid text position "not" true bounded) positive
      have start := model_fixed_advances text position "not" true bounded (by decide) noNot
      simp only [readBooleanFactor, noNot, advanced, ↓reduceIte, ↓reduceDIte]
      exact Nat.lt_trans start inner
    · simp [readBooleanFactor, noNot, advanced, invalidCondition] at accepted

theorem booleanRelation_progress (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    {initials : ArrayBindings.Initials}
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : position ≤ text.length + 1) (accepted : (readBooleanRelation text context position facts initials).after ≠ 0) :
    position < (readBooleanRelation text context position facts initials).after := by
  obtain ⟨condition, parsed⟩ := (booleanRelation_sound text context position facts textValid namesValid bounded accepted).1
  generalize equation : readBooleanRelation text context position facts initials = result at parsed accepted ⊢
  cases parsed with
  | factor inner positive _ =>
    rw [← booleanFactor_complete inner] at positive ⊢
    exact booleanFactor_progress text context position facts textValid namesValid bounded positive
  | @comparison _ _ _ _ leftResult rightResult left _ _ _ advanced right rightPositive =>
    have leftBound := booleanFactor_bound text context position facts textValid namesValid bounded (initials := initials)
    rw [booleanFactor_complete left] at leftBound
    have rightProgress : (comparisonAt text leftResult.after).after < rightResult.after := by
      rw [← booleanFactor_complete right] at rightPositive ⊢
      exact booleanFactor_progress text context _ facts textValid namesValid
        (comparison_bound text leftResult.after leftBound) rightPositive
    dsimp only
    unfold remainingAt at advanced
    omega

theorem relation_progress (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) {initials : ArrayBindings.Initials}
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : position ≤ text.length + 1) (accepted : (readRelation text context position facts initials).after ≠ 0) :
    position < (readRelation text context position facts initials).after := by
  obtain ⟨condition, parsed⟩ := (relation_sound text context position facts textValid namesValid bounded accepted).1
  generalize equation : readRelation text context position facts initials = result at parsed accepted ⊢
  cases parsed with
  | booleanNot _ _ inner =>
    rw [← booleanRelation_complete inner] at accepted ⊢
    exact booleanRelation_progress text context position facts textValid namesValid bounded accepted
  | length _ _ _ _ _ advanced => exact advanced
  | scalars _ _ _ _ _ _ advanced => exact advanced
  | strings _ _ _ _ _ _ _ advanced => exact advanced
  | character _ _ _ _ _ inner =>
    cases inner with
    | comparison _ _ _ _ advanced _ => exact advanced
  | primary _ _ _ _ _ _ inner =>
    rw [← booleanRelation_complete inner] at accepted ⊢
    exact booleanRelation_progress text context position facts textValid namesValid bounded accepted

end Silver.Predicate.Native
