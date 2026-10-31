module

public import Silver.PredicateBodyAdmission
public import Silver.PredicateConditionFlow

@[expose] public section

namespace Silver.Predicate
open Compose

@[simp] theorem invalidBody_count (scan : BodyScan) : (invalidBody scan).count = scan.count := rfl

@[simp] theorem bodyToken_count (text : Source) (scan : BodyScan) (token : ShellToken) :
    (bodyToken text scan token).count = scan.count := rfl

@[simp] theorem bodyTokens_count (text : Source) (scan : BodyScan) (tokens : List ShellToken) :
    (bodyTokens text scan tokens).count = scan.count := by
  induction tokens generalizing scan with
  | nil => rfl
  | cons token tokens ih => exact ih (bodyToken text scan token)

theorem scalarAssignment_count (text : Source) (context : ParseContext) (scan : BodyScan) :
    (scalarAssignmentBody text context scan).count = scan.count := by
  unfold scalarAssignmentBody
  dsimp only
  split
  · rfl
  · exact ActiveFlow.replace_count ..

theorem basicRaw_count (text : Source) (context : ParseContext) (scan : BodyScan) :
    (basicRaw text context scan).count = scan.count := by
  unfold basicRaw
  cases basicKind text context scan with
  | null => rfl
  | output =>
      try dsimp only
      split <;> rfl
  | put =>
      try dsimp only
      split <;> rfl
  | reject => rfl
  | scalarAssignment => exact scalarAssignment_count ..
  | booleanAssignment =>
      unfold booleanAssignmentBody
      dsimp only
      split <;> rfl
  | arrayAssignment =>
      unfold arrayAssignmentBody
      dsimp only
      split <;> rfl
  | assignment =>
      have countIf (condition : Prop) [Decidable condition] (left right : BodyScan)
          (leftCount : left.count = scan.count) (rightCount : right.count = scan.count) :
          (if condition then left else right).count = scan.count := by
        by_cases chosen : condition
        · simpa only [chosen, ↓reduceIte] using leftCount
        · simpa only [chosen, ↓reduceIte] using rightCount
      cases kind : stringAssignmentKind text context scan
      all_goals
        simp only [stringAssignmentBody, kind]
        apply countIf
        · rfl
        · apply countIf <;> rfl

theorem basic_count (text : Source) (context : ParseContext) (scan : BodyScan) :
    (basicBody text context scan).count = scan.count := by
  unfold basicBody
  split
  · rfl
  · try dsimp only
    split
    · rfl
    · exact basicRaw_count ..

theorem branchStart_counts (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String) :
    (branchStart text context scan keyword).1.count = scan.count ∧
      (branchStart text context scan keyword).2.count = scan.count := by
  exact condition_counts text context (bodyToken text scan (.word keyword)).position scan.facts

theorem loopHeader_count (text : Source) (context : ParseContext) (scan : BodyScan)
    (same : scan.count = context.scalarNames.length) :
    (loopHeader text context scan).entry.count = context.scalarNames.length + 1 := by
  change ((ActiveFlow.widen context.scalarNames scan.facts).values ++ [_]).length = _
  simpa only [List.length_append, List.length_singleton, ActiveFlow.count] using
    congrArg (· + 1) ((ActiveFlow.widen_count context.scalarNames scan.facts same).trans same)

theorem loopAfterFlow_count (context : ParseContext) (before after : ActiveFlow)
    (lower upper : Integer.Interval) (same : before.count = context.scalarNames.length) :
    (loopAfterFlow context before after lower upper).count = before.count := by
  unfold loopAfterFlow
  dsimp only
  split
  · rfl
  · exact ActiveFlow.widen_count context.scalarNames before same

theorem loopAfterHeader_count (context : ParseContext) (before after : ActiveFlow)
    (header : LoopHeader) (same : before.count = context.scalarNames.length) :
    (loopAfterHeader context before after header).count = before.count := by
  unfold loopAfterHeader
  split
  · exact ActiveFlow.widen_count context.scalarNames before same
  · exact loopAfterFlow_count context before after _ _ same

theorem loopBody_count (text : Source) (context : ParseContext) (scan : BodyScan)
    (same : scan.count = context.scalarNames.length) :
    (loopBody text context scan).count = context.scalarNames.length := by
  rw [loopBody]
  dsimp only
  split
  · exact same
  · split
    · exact same
    · split
      · split
        · exact same
        · split
          · exact same
          · rw [bodyTokens_count]
            exact (loopAfterHeader_count context scan.facts _ _ same).trans same
      · exact same

mutual
  theorem statementBody_count (text : Source) (context : ParseContext) (scan : BodyScan)
      (same : scan.count = context.scalarNames.length) :
      (statementBody text context scan).count = context.scalarNames.length := by
    rw [statementBody]
    split
    · exact same
    · split
      · exact conditionalBody_count text context scan same
      · split
        · exact loopBody_count text context scan same
        · exact (basic_count text context scan).trans same
  termination_by (bodyRemaining text scan, 2)

  theorem conditionalBody_count (text : Source) (context : ParseContext) (scan : BodyScan)
      (same : scan.count = context.scalarNames.length) :
      (conditionalBody text context scan).count = context.scalarNames.length := by
    rw [conditionalBody]
    try dsimp only
    split
    · exact same
    · split
      · split
        · exact same
        · split
          · try dsimp only
            split
            · exact same
            · rw [bodyTokens_count]
              have branches := branchStart_counts text context scan "if"
              have yes := readBody_count text context (branchStart text context scan "if").1 .arm (branches.1.trans same)
              have no := alternativeBody_count text context
                {readBody text context (branchStart text context scan "if").1 .arm with
                  facts := (branchStart text context scan "if").2} (branches.2.trans same)
              exact (ActiveFlow.join_count _ _ (yes.trans no.symm)).trans yes
          · exact same
      · exact same
  termination_by (bodyRemaining text scan, 1)

  theorem alternativeBody_count (text : Source) (context : ParseContext) (scan : BodyScan)
      (same : scan.count = context.scalarNames.length) :
      (alternativeBody text context scan).count = context.scalarNames.length := by
    rw [alternativeBody]
    split
    · exact same
    · split
      · try dsimp only
        split
        · exact same
        · split
          · split
            · exact same
            · split
              · have branches := branchStart_counts text context scan "elsif"
                have yes := readBody_count text context (branchStart text context scan "elsif").1 .arm (branches.1.trans same)
                have no := alternativeBody_count text context
                  {readBody text context (branchStart text context scan "elsif").1 .arm with
                    facts := (branchStart text context scan "elsif").2} (branches.2.trans same)
                exact (ActiveFlow.join_count _ _ (yes.trans no.symm)).trans yes
              · exact same
          · exact same
      · split
        · try dsimp only
          split
          · exact same
          · split
            · exact readBody_count text context _ .endOnly same
            · exact same
        · split <;> exact same
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_count (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (same : scan.count = context.scalarNames.length) :
      (bodyTail text context scan stop).count = context.scalarNames.length := by
    rw [bodyTail]
    split
    · exact same
    · split
      · exact same
      · try dsimp only
        split
        · exact statementBody_count text context scan same
        · split
          · exact bodyTail_count text context _ stop (statementBody_count text context scan same)
          · exact statementBody_count text context scan same
  termination_by (bodyRemaining text scan, 3)

  theorem readBody_count (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (same : scan.count = context.scalarNames.length) :
      (readBody text context scan stop).count = context.scalarNames.length := by
    rw [readBody]
    try dsimp only
    split
    · exact statementBody_count text context scan same
    · split
      · exact bodyTail_count text context _ stop (statementBody_count text context scan same)
      · exact statementBody_count text context scan same
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
