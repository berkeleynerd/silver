module

public import Silver.PredicateBodyAdmission
public import Silver.ComposeGrammar
public import Silver.ComposeCharacterBounds
public import Silver.PredicateCharacterReadings
public import Silver.PredicateReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

/-- Assignment source trees distinguish whole Strings, scalar Characters and
indexed String elements while sharing the initialized byte store. -/
inductive StringAssignmentReading (text : Source) (context : ParseContext) (scan : BodyScan) :
    Bindings.Assignment → Prop
  | whole {value} :
      TargetReading text (parserState context scan) (stringAssignmentTarget text context scan) false →
      stringAssignmentKind text context scan = .whole →
      ExpressionAt (integerHidden := context.integerHidden text) (elaborating := context.elaborating)
        (arrays := context.arrayTable) (scalarNames := context.readingNames scan.facts) text context.names
        (fixedAfter text (stringAssignmentStart text context scan).position ":=" false) value
        (readStringInFlow text context
          (fixedAfter text (stringAssignmentStart text context scan).position ":=" false) scan.facts) →
      StringAssignmentReading text context scan ⟨(stringAssignmentTarget text context scan).target, value⟩
  | character {value result} :
      TargetReading text (parserState context scan) (stringAssignmentTarget text context scan) false →
      stringAssignmentKind text context scan = .character →
      CharacterAt text context.names (context.readingNames scan.facts) context.arrayTable [] false
        (characterAssignmentPosition text context scan) value result →
      StringAssignmentReading text context scan
        ⟨(stringAssignmentTarget text context scan).target, [.character value]⟩
  | element {info index upper value result} :
      TargetReading text (parserState context scan) (stringAssignmentTarget text context scan) false →
      stringAssignmentKind text context scan = .element →
      IndexedReading text context.names (context.readingNames scan.facts) context.arrayTable [] false true
        scan.position info index upper →
      CharacterAt text context.names (context.readingNames scan.facts) context.arrayTable [] false
        (characterAssignmentPosition text context scan) value result →
      StringAssignmentReading text context scan
        ⟨(stringAssignmentTarget text context scan).target,
          [.replace (stringAssignmentTarget text context scan).target info.firstIndex index value]⟩

theorem stringAssignment_target_positive {text context scan}
    (nonzero : (stringAssignmentTarget text context scan).target ≠ 0) :
    (stringAssignmentTarget text context scan).position ≠ 0 := by
  unfold stringAssignmentTarget targetAt at nonzero ⊢
  dsimp only at nonzero ⊢
  split
  · rename_i failed
    simp only [ite_eq_left failed, invalidState] at nonzero
    contradiction
  · rename_i allowed
    have selected : lookupName text (parserState context scan).names
        (skipAt text (parserState context scan).position)
        (nameAfter text (skipAt text (parserState context scan).position)) ≠ 0 :=
      fun zero => allowed (Or.inl zero)
    have progress := (lookupName_found selected).2.1
    change nameAfter text (skipAt text (parserState context scan).position) ≠ 0
    omega

theorem stringAssignment_sound {text context scan}
    (accepted : (stringAssignmentBody text context scan).position ≠ 0) :
    ∃ update, StringAssignmentReading text context scan update := by
  have selected : (stringAssignmentTarget text context scan).target ≠ 0 := by
    intro zero
    simp [stringAssignmentBody, stringAssignmentStart, zero, invalidBody] at accepted
  have target := target_reading text (parserState context scan) false
    (stringAssignment_target_positive selected)
  cases branch : stringAssignmentKind text context scan with
  | whole =>
      have positive : (readStringInFlow text context
          (fixedAfter text (stringAssignmentStart text context scan).position ":=" false) scan.facts).after ≠ 0 := by
        intro zero
        simp only [stringAssignmentStart] at zero
        simp [stringAssignmentBody, stringAssignmentStart, selected, branch,
          bodyToken, tokenAfter, ShellToken.symbol, zero, invalidBody] at accepted
      obtain ⟨value, source⟩ := expressionAt_sound _ _ _ positive
      exact ⟨_, .whole target branch source⟩
  | character =>
      simp only [stringAssignmentBody, stringAssignmentStart, selected, ↓reduceIte, branch] at accepted
      split at accepted
      · exact False.elim (accepted rfl)
      · rename_i positive
        obtain ⟨value, source⟩ := character_sound _ positive
        exact ⟨_, .character target branch source⟩
  | element =>
      simp only [stringAssignmentBody, stringAssignmentStart, selected, ↓reduceIte, branch] at accepted
      split at accepted
      · exact False.elim (accepted rfl)
      · rename_i positive
        obtain ⟨value, source⟩ := character_sound _ positive
        have startPositive := character_input_nonzero source
        have indexedPositive : (elementTargetRead text context scan).after ≠ 0 := by
          apply fixedAfter_nonzero
          simpa only [characterAssignmentPosition, branch, ↓reduceIte] using startPositive
        obtain ⟨info, index, upper, indexed⟩ := indexed_sound indexedPositive
        exact ⟨_, .element target branch indexed source⟩

theorem stringAssignment_unique {text context scan left right}
    (first : StringAssignmentReading text context scan left)
    (second : StringAssignmentReading text context scan right) : left = right := by
  cases first with
  | whole _ branch source =>
      cases second with
      | whole _ _ other =>
          obtain ⟨rfl, _⟩ := expressionTail_unique source other
          rfl
      | character _ other | element _ other => simp_all
  | character _ branch source =>
      cases second with
      | character _ _ other =>
          obtain ⟨rfl, _⟩ := character_unique source other
          rfl
      | whole _ other | element _ other => simp_all
  | element _ branch indexed source =>
      cases second with
      | element _ _ otherIndex other =>
          obtain ⟨rfl, rfl, _⟩ := indexed_unique indexed otherIndex
          obtain ⟨rfl, _⟩ := character_unique source other
          rfl
      | whole _ other | character _ other => simp_all

end Silver.Predicate

