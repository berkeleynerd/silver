module

public import Silver.PredicateBodyReadings

@[expose] public section

set_option backward.dsimp.instances true

namespace Silver.Predicate
open Compose Bindings PathFacts Compose.Expressions

attribute [local irreducible] ScalarExpression.read

private theorem branch_sound {text context scan keyword}
    (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1)
    (positive : (branchStart text context scan keyword).1.position ≠ 0) :
    ∃ condition, BranchAt text context scan keyword condition := by
  have conditionPositive : (readCondition text context (bodyToken text scan (.word keyword)).position scan.facts).after ≠ 0 :=
    fixedAfter_nonzero positive
  exact (condition_sound text context _ _ tv nv (bodyToken_bound text scan _ sv) conditionPositive).1

private theorem conditional_shape {text context scan}
    (accepted : (conditionalBody text context scan).position ≠ 0) :
    let start := branchStart text context scan "if"
    let yes := readBody text context start.1 .arm
    let no := alternativeBody text context {yes with facts := start.2}
    scan.position < start.1.position ∧ bodyRemaining text start.1 < bodyRemaining text scan ∧
    scan.position < yes.position ∧ bodyRemaining text yes < bodyRemaining text scan ∧
    conditionalBody text context scan = bodyTokens text {no with facts := yes.facts.join no.facts}
      [.word "end", .word "if", .symbol ";"] := by
  rw [conditionalBody] at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i start
    simp [start, ↓reduceIte]
    split at accepted
    · rename_i advanced
      simp [advanced]
      split at accepted
      · exact False.elim (accepted rfl)
      · rename_i yes
        simp [yes, ↓reduceIte]
        split at accepted
        · rename_i yesAdvanced
          simp [yesAdvanced]
          split at accepted
          · exact False.elim (accepted rfl)
          · rename_i final
            simp [final]
            exact ⟨by omega, by omega⟩
        · exact False.elim (accepted rfl)
    · exact False.elim (accepted rfl)

mutual
  theorem statement_sound (text : Source) (context : ParseContext) (scan : BodyScan)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1)
      (accepted : (statementBody text context scan).position ≠ 0) :
      ∃ item, StatementAt text context scan item (statementBody text context scan) := by
    have positive : scan.position ≠ 0 := fun zero => accepted (by rw [statementBody_zero zero]; rfl)
    by_cases found : fixedAfter text scan.position "if" true ≠ 0
    · have equation : statementBody text context scan = conditionalBody text context scan := by
        rw [statementBody]; simp [positive, found, ↓reduceIte]
      obtain ⟨condition, yes, tail, parsed⟩ := choice_sound text context scan tv nv sv (equation ▸ accepted)
      exact ⟨_, .choice positive found (equation ▸ parsed) rfl⟩
    · have missing : fixedAfter text scan.position "if" true = 0 := by simpa using found
      by_cases loopFound : fixedAfter text scan.position "for" true ≠ 0
      · have equation : statementBody text context scan = loopBody text context scan := by
          rw [statementBody]; simp [positive, found, loopFound, ↓reduceIte]
        obtain ⟨lower, upper, body, parsed⟩ := loop_sound text context scan tv nv (equation ▸ accepted)
        exact ⟨_, .loop positive missing loopFound (equation ▸ parsed) rfl⟩
      · have noLoop : fixedAfter text scan.position "for" true = 0 := by simpa using loopFound
        have equation : statementBody text context scan = basicBody text context scan := by
          rw [statementBody]; simp [positive, found, loopFound, ↓reduceIte]
        obtain ⟨item, parsed⟩ := basic_sound (equation ▸ accepted)
        exact ⟨item, .basic positive missing noLoop (equation ▸ parsed) rfl⟩
  termination_by (bodyRemaining text scan, 2)

  theorem loop_sound (text : Source) (context : ParseContext) (scan : BodyScan)
      (tv : ValidText text) (nv : ValidNames text context.names)
      (accepted : (loopBody text context scan).position ≠ 0) :
      ∃ lower upper body, LoopAt text context scan lower upper body (loopBody text context scan) := by
    obtain ⟨allowed, entryForward, advanced, bodyForward, equation, _⟩ := loopBody_shape accepted
    obtain ⟨lower, upper, lowerRead, upperRead⟩ := loopHeader_readings (by omega :
      (loopHeader text context scan).entry.position ≠ 0)
    obtain ⟨body, bodyRead⟩ := body_sound text (loopInner context (loopHeader text context scan))
      (loopHeader text context scan).entry .endOnly tv nv (loopHeader_bound text context scan) (by omega)
    exact ⟨lower, upper, body, .loop allowed lowerRead upperRead advanced bodyRead equation accepted rfl⟩
  termination_by (bodyRemaining text scan, 1)

  theorem choice_sound (text : Source) (context : ParseContext) (scan : BodyScan)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1)
      (accepted : (conditionalBody text context scan).position ≠ 0) :
      ∃ condition yes tail, ChoiceAt text context scan condition yes tail (conditionalBody text context scan) := by
    obtain ⟨startForward, advanced, yesForward, yesAdvanced, equation⟩ := conditional_shape accepted
    have startPositive : (branchStart text context scan "if").1.position ≠ 0 := by omega
    obtain ⟨condition, conditionRead⟩ := branch_sound tv nv sv startPositive
    have yesPositive : (readBody text context (branchStart text context scan "if").1 .arm).position ≠ 0 := by omega
    obtain ⟨yes, yesRead⟩ := body_sound text context _ .arm tv nv
      (branchStart_bound text context scan "if" tv nv sv) yesPositive
    have noPositive : (alternativeBody text context
        {readBody text context (branchStart text context scan "if").1 .arm with facts :=
          (branchStart text context scan "if").2}).position ≠ 0 := by
      intro zero
      rw [equation] at accepted
      exact accepted (bodyTokens_zero zero)
    obtain ⟨tail, tailRead⟩ := alternative_sound text context
      {readBody text context (branchStart text context scan "if").1 .arm with facts := (branchStart text context scan "if").2} tv nv
      (readBody_bound text context _ .arm tv nv (branchStart_bound text context scan "if" tv nv sv)) noPositive
    exact ⟨condition, yes, tail, .choice conditionRead advanced yesRead yesAdvanced tailRead equation accepted rfl⟩
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_sound (text : Source) (context : ParseContext) (scan : BodyScan)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1)
      (accepted : (alternativeBody text context scan).position ≠ 0) :
      ∃ tail, AlternativeAt text context scan tail (alternativeBody text context scan) := by
    have positive : scan.position ≠ 0 := fun zero => accepted (by rw [alternativeBody_zero zero]; rfl)
    by_cases elsifFound : fixedAfter text scan.position "elsif" true ≠ 0
    · have reduced := accepted
      rw [alternativeBody] at reduced
      simp [positive, elsifFound, ↓reduceIte] at reduced
      try dsimp only at reduced
      split at reduced
      · exact False.elim (reduced rfl)
      · rename_i start
        split at reduced
        · rename_i advanced
          split at reduced
          · exact False.elim (reduced rfl)
          · rename_i yes
            split at reduced
            · rename_i yesAdvanced
              have equation : alternativeBody text context scan =
                  let yes := readBody text context (branchStart text context scan "elsif").1 .arm
                  let no := alternativeBody text context {yes with facts := (branchStart text context scan "elsif").2}
                  {no with facts := yes.facts.join no.facts} := by
                rw [alternativeBody]
                simp [positive, elsifFound, start, advanced, yes, yesAdvanced, ↓reduceIte, ↓reduceDIte]
              obtain ⟨condition, conditionRead⟩ := branch_sound (keyword := "elsif") tv nv sv (by omega)
              obtain ⟨yesItems, yesRead⟩ := body_sound text context _ .arm tv nv
                (branchStart_bound text context scan "elsif" tv nv sv) (by omega)
              obtain ⟨tail, tailRead⟩ := alternative_sound text context
                {readBody text context (branchStart text context scan "elsif").1 .arm with facts := (branchStart text context scan "elsif").2} tv nv
                (readBody_bound text context _ .arm tv nv (branchStart_bound text context scan "elsif" tv nv sv)) reduced
              exact ⟨_, .elsif positive elsifFound conditionRead advanced yesRead yesAdvanced tailRead equation accepted rfl⟩
            · exact False.elim (reduced rfl)
        · exact False.elim (reduced rfl)
    · have noElsif : fixedAfter text scan.position "elsif" true = 0 := by simpa using elsifFound
      by_cases elseFound : fixedAfter text scan.position "else" true ≠ 0
      · have reduced := accepted
        rw [alternativeBody, ite_eq_right positive, ite_eq_right elsifFound, ite_eq_left elseFound] at reduced
        dsimp only at reduced
        split at reduced
        · exact False.elim (reduced rfl)
        · rename_i start
          split at reduced
          · rename_i advanced
            have equation : alternativeBody text context scan = readBody text context (bodyToken text scan (.word "else")) .endOnly := by
              rw [alternativeBody, ite_eq_right positive, ite_eq_right elsifFound, ite_eq_left elseFound]
              dsimp only
              simp only [start, advanced, ↓reduceIte, ↓reduceDIte]
            obtain ⟨items, parsed⟩ := body_sound text context _ .endOnly tv nv (bodyToken_bound text scan _ sv) reduced
            exact ⟨_, .otherwise positive noElsif elseFound advanced (equation ▸ parsed) rfl⟩
          · exact False.elim (reduced rfl)
      · have noElse : fixedAfter text scan.position "else" true = 0 := by simpa using elseFound
        have endFound : fixedAfter text scan.position "end" true ≠ 0 := by
          intro zero
          rw [alternativeBody] at accepted
          simp [positive, elsifFound, elseFound, zero, invalidBody] at accepted
        have equation : alternativeBody text context scan = scan := by
          rw [alternativeBody]; simp [positive, elsifFound, elseFound, endFound, ↓reduceIte]
        exact ⟨_, by rw [equation]; exact AlternativeAt.absent positive noElsif noElse endFound⟩
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_sound (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1)
      (accepted : (bodyTail text context scan stop).position ≠ 0) :
      ∃ items, BodyTailAt text context stop scan items (bodyTail text context scan stop) := by
    have positive : scan.position ≠ 0 := fun zero => accepted (by rw [bodyTail_zero zero]; rfl)
    by_cases stopped : atBodyStop text scan.position stop = true
    · have equation : bodyTail text context scan stop = scan := by rw [bodyTail]; simp [positive, stopped, ↓reduceIte]
      exact ⟨[], by rw [equation]; exact BodyTailAt.done positive stopped⟩
    · have notStopped : atBodyStop text scan.position stop = false := by cases h : atBodyStop text scan.position stop <;> simp_all
      have reduced := accepted
      rw [bodyTail] at reduced
      simp [positive, stopped, ↓reduceIte] at reduced
      try dsimp only at reduced
      split at reduced
      · exact False.elim (reduced rfl)
      · rename_i next
        split at reduced
        · rename_i advanced
          have equation : bodyTail text context scan stop = bodyTail text context (statementBody text context scan) stop := by
            rw [bodyTail]; simp [positive, stopped, next, advanced, ↓reduceIte, ↓reduceDIte]
          obtain ⟨item, itemRead⟩ := statement_sound text context scan tv nv sv (by omega)
          obtain ⟨rest, restRead⟩ := bodyTail_sound text context _ stop tv nv
            (statementBody_bound text context scan tv nv sv) reduced
          exact ⟨_, .next positive notStopped itemRead advanced (equation ▸ restRead) rfl⟩
        · exact False.elim (reduced rfl)
  termination_by (bodyRemaining text scan, 3)

  theorem body_sound (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (tv : ValidText text) (nv : ValidNames text context.names) (sv : scan.position ≤ text.length + 1)
      (accepted : (readBody text context scan stop).position ≠ 0) :
      ∃ items, BodyAt text context scan stop items (readBody text context scan stop) := by
    have reduced := accepted
    rw [readBody] at reduced
    try dsimp only at reduced
    split at reduced
    · exact False.elim (reduced rfl)
    · rename_i next
      split at reduced
      · rename_i advanced
        have equation : readBody text context scan stop = bodyTail text context (statementBody text context scan) stop := by
          rw [readBody]; simp [next, advanced, ↓reduceIte, ↓reduceDIte]
        obtain ⟨item, itemRead⟩ := statement_sound text context scan tv nv sv next
        obtain ⟨rest, restRead⟩ := bodyTail_sound text context _ stop tv nv
          (statementBody_bound text context scan tv nv sv) reduced
        exact ⟨_, .cons itemRead advanced (equation ▸ restRead) rfl⟩
      · exact False.elim (reduced rfl)
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
