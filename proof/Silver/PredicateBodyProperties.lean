module

public import Silver.PredicateBodyAdmission
public import Silver.PredicateLoopProperties
public import Silver.PredicateBodyFlow
public import Silver.ComposeCharacterBounds
public import Silver.PredicateStringAssignmentFields

@[expose] public section
namespace Silver.Predicate
open Compose Bindings PathFacts Compose.Expressions

attribute [local irreducible] ScalarExpression.read

@[simp] theorem bodyToken_position (text : Source) (scan : BodyScan) (token : ShellToken) :
    (bodyToken text scan token).position = tokenAfter text scan.position token := rfl
@[simp] theorem bodyToken_facts (text : Source) (scan : BodyScan) (token : ShellToken) :
    (bodyToken text scan token).facts = scan.facts := rfl
@[simp] theorem bodyToken_target (text : Source) (scan : BodyScan) (token : ShellToken) :
    (bodyToken text scan token).target = scan.target := rfl
@[simp] theorem bodyToken_assigned (text : Source) (scan : BodyScan) (token : ShellToken) :
    (bodyToken text scan token).assigned = scan.assigned := rfl
@[simp] theorem bodyToken_output (text : Source) (scan : BodyScan) (token : ShellToken) :
    (bodyToken text scan token).output = scan.output := rfl

@[simp] theorem bodyTokens_facts (text : Source) (scan : BodyScan) (tokens : List ShellToken) :
    (bodyTokens text scan tokens).facts = scan.facts := by
  induction tokens generalizing scan with
  | nil => rfl
  | cons token tokens ih => exact ih (bodyToken text scan token)

theorem bodyToken_bound (text : Source) (scan : BodyScan) (token : ShellToken)
    (bounded : scan.position ≤ text.length + 1) :
    (bodyToken text scan token).position ≤ text.length + 1 := by
  cases token <;> simp only [bodyToken_position, tokenAfter]
  all_goals first | exact model_fixed_valid text _ _ _ bounded | exact Nat.zero_le _

theorem bodyTokens_bound (text : Source) (scan : BodyScan) (tokens : List ShellToken)
    (bounded : scan.position ≤ text.length + 1) :
    (bodyTokens text scan tokens).position ≤ text.length + 1 := by
  induction tokens generalizing scan with
  | nil => exact bounded
  | cons token tokens ih => exact ih _ (bodyToken_bound text scan token bounded)

theorem bodyToken_zero {text scan token} (zero : scan.position = 0) :
    (bodyToken text scan token).position = 0 := by
  cases token <;> simp [bodyToken, tokenAfter, fixedAfter, zero]

theorem bodyTokens_zero {text scan tokens} (zero : scan.position = 0) :
    (bodyTokens text scan tokens).position = 0 := by
  induction tokens generalizing scan with
  | nil => exact zero
  | cons token tokens ih => exact ih (bodyToken_zero (token := token) zero)

theorem arrayIndex_bound (text : Source) (context : ParseContext) (scan : BodyScan) :
    (arrayIndex text context scan).after ≤ text.length + 1 :=
  scalarRead_bound text _ (context.readingNames scan.facts) 0 0 []
    (model_fixed_valid text _ "(" false (model_name_valid text _))

theorem arrayValueStart_bound (text : Source) (context : ParseContext) (scan : BodyScan) :
    arrayValueStart text context scan ≤ text.length + 1 :=
  model_fixed_valid text _ ":=" false
    (model_fixed_valid text _ ")" false (arrayIndex_bound text context scan))

theorem condition_bound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : position ≤ text.length + 1) :
    (readCondition text context position facts).after ≤ text.length + 1 := by
  by_cases zero : (readCondition text context position facts).after = 0
  · simp [zero]
  · exact (condition_sound text context position facts textValid namesValid bounded zero).2

private theorem bodyChoicePosition_bound (test : Prop) [Decidable test] (yes no : BodyScan) (limit : Nat)
    (yesBound : yes.position ≤ limit) (noBound : no.position ≤ limit) :
    (if test then yes else no).position ≤ limit := by
  split <;> assumption

theorem characterRead_bound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
    (characterAt text position context.names (context.readingNames facts) context.arrayNames).after ≤ text.length + 1 := by
  by_cases zero : (characterAt text position context.names (context.readingNames facts) context.arrayNames).after = 0
  · rw [zero]; omega
  · obtain ⟨value, reading⟩ := character_sound _ zero
    exact character_after_bounded reading

theorem basicRaw_bound (text : Source) (context : ParseContext) (scan : BodyScan)
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : scan.position ≤ text.length + 1) :
    (basicRaw text context scan).position ≤ text.length + 1 := by
  unfold basicRaw
  cases basicKind text context scan with
  | null => exact bodyToken_bound text scan _ bounded
  | output =>
      try dsimp only
      split
      · exact Nat.zero_le _
      · dsimp only [bodyToken, tokenAfter, ShellToken.symbol]
        apply model_fixed_valid
        exact (model_expression_valid (arrays := context.arrayNames) (scalarNames := context.readingNames scan.facts) text textValid _ context.names
            (Names.associationAfter_bound text _ false
              (model_fixed_valid text _ "(" false (model_callAfter_valid (arrays := context.arrayNames) (scalarNames := context.scalarNames) (booleans := context.booleanNames) (subtypeHidden := context.subtypeHiding.get .output) text context.names scan.position .output bounded))) namesValid).1
  | put =>
      try dsimp only
      split
      · exact Nat.zero_le _
      · dsimp only [bodyToken, tokenAfter, ShellToken.symbol]
        apply model_fixed_valid
        exact (model_expression_valid (arrays := context.arrayNames) (scalarNames := context.readingNames scan.facts) text textValid _ context.names
            (Names.associationAfter_bound text _ false
              (model_fixed_valid text _ "(" false (model_callAfter_valid (arrays := context.arrayNames) (scalarNames := context.scalarNames) (booleans := context.booleanNames) (subtypeHidden := context.subtypeHiding.get .partialOutput) text context.names scan.position .partialOutput bounded))) namesValid).1
  | reject => exact model_callAfter_valid (arrays := context.arrayNames) (scalarNames := context.scalarNames) (booleans := context.booleanNames) (subtypeHidden := context.subtypeHiding.get .reject) text context.names scan.position .reject bounded
  | scalarAssignment =>
      unfold scalarAssignmentBody
      dsimp only
      split
      · exact Nat.zero_le _
      · exact scalarRead_bound (elaborating := context.elaborating) text _ (context.readingNames scan.facts) 0 0 context.arrayNames
          (model_fixed_valid text _ ":=" false (model_name_valid text _))
  | booleanAssignment =>
      unfold booleanAssignmentBody
      dsimp only
      split
      · exact Nat.zero_le _
      · exact condition_bound text context _ scan.facts textValid namesValid
          (model_fixed_valid text _ ":=" false (model_name_valid text _))
  | booleanArrayAssignment =>
      unfold booleanArrayAssignmentBody
      dsimp only
      split
      · exact Nat.zero_le _
      · exact condition_bound text context _ scan.facts textValid namesValid
          (model_fixed_valid text _ ":=" false (by
            by_cases zero : booleanArrayAfter text context scan.position scan.facts = 0
            · simp only [zero]
              exact Nat.zero_le _
            · exact (booleanArray_sound zero).2))
  | arrayAssignment =>
      unfold arrayAssignmentBody
      dsimp only
      split
      · exact Nat.zero_le _
      · exact scalarRead_bound (elaborating := context.elaborating) text _ (context.readingNames scan.facts) 0 0 context.arrayNames
          (model_fixed_valid text _ ":=" false (model_fixed_valid text _ ")" false
            (scalarRead_bound text _ (context.readingNames scan.facts) 0 0 []
              (model_fixed_valid text _ "(" false (model_name_valid text _)))))
  | assignment =>
      have targetBound : (stringAssignmentTarget text context scan).position ≤ text.length + 1 := by
        unfold stringAssignmentTarget targetAt
        dsimp only
        split
        · exact Nat.zero_le _
        · exact model_name_valid text _
      unfold stringAssignmentBody
      dsimp only
      apply bodyChoicePosition_bound
      · exact Nat.zero_le _
      · cases stringAssignmentKind text context scan with
        | character | element =>
            apply bodyChoicePosition_bound
            · exact Nat.zero_le _
            · exact characterRead_bound text context _ scan.facts
        | whole =>
            apply bodyChoicePosition_bound
            · exact Nat.zero_le _
            · exact (model_expression_valid (integerHidden := context.integerHidden text)
                (elaborating := context.elaborating) (arrays := context.arrayNames)
                (scalarNames := context.readingNames scan.facts) text textValid _ context.names
                (bodyToken_bound text _ _ targetBound) namesValid).1

theorem basicBody_bound (text : Source) (context : ParseContext) (scan : BodyScan)
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : scan.position ≤ text.length + 1) :
    (basicBody text context scan).position ≤ text.length + 1 := by
  unfold basicBody
  split
  · exact Nat.zero_le _
  · try dsimp only
    split
    · exact Nat.zero_le _
    · exact bodyToken_bound text _ _ (basicRaw_bound text context scan textValid namesValid bounded)

theorem basicBody_progress (text : Source) (context : ParseContext) (scan : BodyScan)
    (positive : (basicBody text context scan).position ≠ 0) :
    scan.position < (basicBody text context scan).position := by
  unfold basicBody at positive ⊢
  split <;> rename_i h
  · simp [h, invalidBody] at positive
  · simp only [h, ↓reduceIte] at positive
    try dsimp only at *
    split <;> rename_i failed
    · rw [ite_eq_left failed] at positive
      exact False.elim (positive rfl)
    · omega

theorem basicBody_zero {text context scan} (zero : scan.position = 0) :
    basicBody text context scan = invalidBody scan := by simp [basicBody, zero]

@[simp] theorem branchStart_assigned (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String) :
    (branchStart text context scan keyword).1.assigned = scan.assigned := rfl
@[simp] theorem branchStart_output (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String) :
    (branchStart text context scan keyword).1.output = scan.output := rfl
@[simp] theorem branchStart_target (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String) :
    (branchStart text context scan keyword).1.target = scan.target := rfl

theorem branchStart_bound (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String)
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : scan.position ≤ text.length + 1) :
    (branchStart text context scan keyword).1.position ≤ text.length + 1 :=
  bodyToken_bound text _ _ (condition_bound text context _ _ textValid namesValid
    (bodyToken_bound text scan _ bounded))

mutual
  theorem statementBody_bound (text : Source) (context : ParseContext) (scan : BodyScan)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1) :
      (statementBody text context scan).position ≤ text.length + 1 := by
    rw [statementBody]
    split
    · exact Nat.zero_le _
    · split
      · exact conditionalBody_bound text context scan tv nv sv
      · split
        · exact loopBody_bound text context scan tv nv sv
        · exact basicBody_bound text context scan tv nv sv
  termination_by (bodyRemaining text scan, 2)

  theorem loopBody_bound (text : Source) (context : ParseContext) (scan : BodyScan)
      (tv : ValidText text) (nv : ValidNames text context.names) (_sv : scan.position ≤ text.length + 1) :
      (loopBody text context scan).position ≤ text.length + 1 := by
    rw [loopBody]
    dsimp only
    split
    · exact Nat.zero_le _
    · split
      · exact Nat.zero_le _
      · split
        · split
          · exact Nat.zero_le _
          · split
            · exact Nat.zero_le _
            · exact bodyTokens_bound text _ _
                (readBody_bound text (loopInner context (loopHeader text context scan)) _ .endOnly tv nv
                  (loopHeader_bound text context scan))
        · exact Nat.zero_le _
  termination_by (bodyRemaining text scan, 1)

  theorem conditionalBody_bound (text : Source) (context : ParseContext) (scan : BodyScan)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1) :
      (conditionalBody text context scan).position ≤ text.length + 1 := by
    rw [conditionalBody]
    try dsimp only
    split
    · exact Nat.zero_le _
    · split
      · split
        · exact Nat.zero_le _
        · split
          · try dsimp only
            split
            · exact Nat.zero_le _
            · exact bodyTokens_bound text _ _ (alternativeBody_bound text context _ tv nv
                (readBody_bound text context _ .arm tv nv (branchStart_bound text context scan _ tv nv sv)))
          · exact Nat.zero_le _
      · exact Nat.zero_le _
  termination_by (bodyRemaining text scan, 1)

  theorem alternativeBody_bound (text : Source) (context : ParseContext) (scan : BodyScan)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1) :
      (alternativeBody text context scan).position ≤ text.length + 1 := by
    rw [alternativeBody]
    split
    · exact Nat.zero_le _
    · split
      · try dsimp only
        split
        · exact Nat.zero_le _
        · split
          · split
            · exact Nat.zero_le _
            · split
              · exact alternativeBody_bound text context _ tv nv
                  (readBody_bound text context _ .arm tv nv (branchStart_bound text context scan _ tv nv sv))
              · exact Nat.zero_le _
          · exact Nat.zero_le _
      · split
        · try dsimp only
          split
          · exact Nat.zero_le _
          · split
            · exact readBody_bound text context _ .endOnly tv nv (bodyToken_bound text scan _ sv)
            · exact Nat.zero_le _
        · split
          · exact sv
          · exact Nat.zero_le _
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_bound (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1) :
      (bodyTail text context scan stop).position ≤ text.length + 1 := by
    rw [bodyTail]
    split
    · exact Nat.zero_le _
    · split
      · exact sv
      · try dsimp only
        split
        · exact Nat.zero_le _
        · split
          · exact bodyTail_bound text context _ stop tv nv (statementBody_bound text context scan tv nv sv)
          · exact Nat.zero_le _
  termination_by (bodyRemaining text scan, 3)

  theorem readBody_bound (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1) :
      (readBody text context scan stop).position ≤ text.length + 1 := by
    rw [readBody]
    try dsimp only
    split
    · exact Nat.zero_le _
    · split
      · exact bodyTail_bound text context _ stop tv nv (statementBody_bound text context scan tv nv sv)
      · exact Nat.zero_le _
  termination_by (bodyRemaining text scan, 3)
end

@[simp] theorem statementBody_zero {text context scan} (zero : scan.position = 0) :
    statementBody text context scan = invalidBody scan := by rw [statementBody]; simp [zero]
@[simp] theorem bodyTail_zero {text context scan stop} (zero : scan.position = 0) :
    bodyTail text context scan stop = invalidBody scan := by rw [bodyTail]; simp [zero]
@[simp] theorem alternativeBody_zero {text context scan} (zero : scan.position = 0) :
    alternativeBody text context scan = invalidBody scan := by rw [alternativeBody]; simp [zero]
@[simp] theorem readBody_zero {text context scan stop} (zero : scan.position = 0) :
    readBody text context scan stop = invalidBody scan := by rw [readBody, statementBody_zero zero]; rfl

theorem readCondition_zero (text : Source) (context : ParseContext) (facts : ActiveFlow) :
    readCondition text context 0 facts = invalidCondition facts := by
  rw [readCondition, readRelation]
  simp [invalidCondition]

theorem branchStart_zero {text context scan keyword} (zero : scan.position = 0) :
    (branchStart text context scan keyword).1.position = 0 := by
  simp only [branchStart, bodyToken, tokenAfter, ShellToken.word, zero, fixedAfter,
    ↓reduceIte, readCondition_zero, invalidCondition]

theorem conditionalBody_zero {text context scan} (zero : scan.position = 0) :
    conditionalBody text context scan = invalidBody scan := by
  rw [conditionalBody]
  simp only [branchStart_zero zero, zero, Nat.le_refl, ↓reduceIte]

theorem conditionalBody_progress (text : Source) (context : ParseContext) (scan : BodyScan)
    (positive : (conditionalBody text context scan).position ≠ 0) :
    scan.position < (conditionalBody text context scan).position := by
  rw [conditionalBody] at positive ⊢
  try dsimp only at *
  split <;> rename_i start
  · simp only [start, ↓reduceIte, invalidBody, ne_eq, not_true_eq_false] at positive
  · simp only [start, ↓reduceIte] at positive
    split <;> rename_i advanced
    · simp only [advanced, ↓reduceDIte] at positive
      split <;> rename_i yes
      · simp only [yes, ↓reduceIte, invalidBody, ne_eq, not_true_eq_false] at positive
      · simp only [yes, ↓reduceIte] at positive
        split <;> rename_i yesAdvanced
        · simp only [yesAdvanced, ↓reduceDIte] at positive
          split <;> rename_i final
          · rw [ite_eq_left final] at positive
            exact False.elim (positive rfl)
          · omega
        · simp only [yesAdvanced, ↓reduceDIte, invalidBody, ne_eq, not_true_eq_false] at positive
    · simp only [advanced, ↓reduceDIte, invalidBody, ne_eq, not_true_eq_false] at positive

theorem statementBody_progress (text : Source) (context : ParseContext) (scan : BodyScan)
    (positive : (statementBody text context scan).position ≠ 0) :
    scan.position < (statementBody text context scan).position := by
  rw [statementBody] at positive ⊢
  by_cases zero : scan.position = 0
  · rw [ite_eq_left zero] at positive
    exact False.elim (positive rfl)
  · rw [ite_eq_right zero] at positive ⊢
    by_cases found : fixedAfter text scan.position "if" true ≠ 0
    · rw [ite_eq_left found] at positive ⊢
      exact conditionalBody_progress text context scan positive
    · rw [ite_eq_right found] at positive ⊢
      by_cases loopFound : fixedAfter text scan.position "for" true ≠ 0
      · rw [ite_eq_left loopFound] at positive ⊢
        exact loopBody_progress text context scan positive
      · rw [ite_eq_right loopFound] at positive ⊢
        exact basicBody_progress text context scan positive

theorem bodyTail_nondecreasing (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
    (positive : (bodyTail text context scan stop).position ≠ 0) :
    scan.position ≤ (bodyTail text context scan stop).position := by
  rw [bodyTail] at positive ⊢
  split <;> rename_i zero
  · simp [zero, invalidBody] at positive
  · simp only [zero, ↓reduceIte] at positive
    split <;> rename_i stopped
    · exact Nat.le_refl _
    · rw [ite_eq_right stopped] at positive
      try dsimp only at *
      split <;> rename_i failed
      · simp [failed, invalidBody] at positive
      · simp only [failed, ↓reduceIte] at positive
        split <;> rename_i advanced
        · simp only [advanced, ↓reduceDIte] at positive
          have next := bodyTail_nondecreasing text context (statementBody text context scan) stop positive
          omega
        · simp only [advanced, ↓reduceDIte, invalidBody, ne_eq, not_true_eq_false] at positive
termination_by bodyRemaining text scan

theorem readBody_progress (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
    (positive : (readBody text context scan stop).position ≠ 0) :
    scan.position < (readBody text context scan stop).position := by
  rw [readBody] at positive ⊢
  try dsimp only at *
  split <;> rename_i zero
  · simp [zero, invalidBody] at positive
  · simp only [zero, ↓reduceIte] at positive
    split <;> rename_i advanced
    · simp only [advanced, ↓reduceDIte] at positive
      exact Nat.lt_of_lt_of_le (statementBody_progress text context scan zero)
        (bodyTail_nondecreasing text context _ stop positive)
    · simp only [advanced, ↓reduceDIte, invalidBody, ne_eq, not_true_eq_false] at positive

end Silver.Predicate
