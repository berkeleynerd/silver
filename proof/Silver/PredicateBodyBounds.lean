module

public import Silver.PredicateBodyControls
public import Silver.PredicateConditionBounds

@[expose] public section
namespace Silver.Predicate
open Compose Bindings PathFacts

attribute [local irreducible] ScalarExpression.read

theorem basicRaw_factsBounded (text : Source) (context : ParseContext) (scan : BodyScan)
    (bounded : scan.facts.Bounded) : (basicRaw text context scan).facts.Bounded := by
  unfold basicRaw
  cases basicKind text context scan with
  | null => exact bounded
  | output | put =>
      dsimp only
      split
      · exact Context.empty_bounded
      · simpa only [bodyToken_facts, bodyTokens_facts] using bounded
  | reject => simpa only [bodyTokens_facts] using Context.reject_bounded bounded
  | scalarAssignment =>
      unfold scalarAssignmentBody
      dsimp only
      split
      · exact Context.empty_bounded
      · exact bounded
  | assignment =>
      dsimp only
      split
      · exact Context.empty_bounded
      · exact bounded

theorem basicBody_factsBounded (text : Source) (context : ParseContext) (scan : BodyScan)
    (bounded : scan.facts.Bounded) : (basicBody text context scan).facts.Bounded := by
  unfold basicBody
  split
  · exact Context.empty_bounded
  · dsimp only
    split
    · exact Context.empty_bounded
    · exact basicRaw_factsBounded text context scan bounded

theorem branchStart_factsBounded (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String)
    (bounded : scan.facts.Bounded) : (branchStart text context scan keyword).1.facts.Bounded ∧
      (branchStart text context scan keyword).2.Bounded :=
  readCondition_bounded text context _ _ bounded

theorem loopContext_bounded {context : Context} (bounded : context.Bounded) (bounds : Integer.Interval) :
    (loopContext context bounds).Bounded := by
  unfold loopContext
  split
  · exact Context.empty_bounded
  · exact bounded

theorem loopAfter_bounded {before after : Context} (entry : before.Bounded) (body : after.Bounded)
    (lower upper : Integer.Interval) : (loopAfter before after lower upper).Bounded := by
  unfold loopAfter
  split
  · exact entry
  · split
    · exact body
    · exact Context.join_bounded entry body

mutual
  theorem statementBody_factsBounded (text : Source) (context : ParseContext) (scan : BodyScan)
      (sv : scan.facts.Bounded) : (statementBody text context scan).facts.Bounded := by
    rw [statementBody]
    split
    · exact Context.empty_bounded
    · split
      · exact conditionalBody_factsBounded text context scan sv
      · split
        · exact loopBody_factsBounded text context scan sv
        · exact basicBody_factsBounded text context scan sv
  termination_by (bodyRemaining text scan, 2)

  theorem loopBody_factsBounded (text : Source) (context : ParseContext) (scan : BodyScan)
      (sv : scan.facts.Bounded) : (loopBody text context scan).facts.Bounded := by
    rw [loopBody]
    dsimp only
    split
    · exact Context.empty_bounded
    · split
      · exact Context.empty_bounded
      · split
        · split
          · exact Context.empty_bounded
          · split
            · exact Context.empty_bounded
            · simp only [bodyTokens_facts]
              exact loopAfter_bounded sv
                (readBody_factsBounded text (loopInner context (loopHeader text context scan)) _ .endOnly
                  (loopContext_bounded sv _)) _ _
        · exact Context.empty_bounded
  termination_by (bodyRemaining text scan, 1)

  theorem conditionalBody_factsBounded (text : Source) (context : ParseContext) (scan : BodyScan)
      (sv : scan.facts.Bounded) : (conditionalBody text context scan).facts.Bounded := by
    rw [conditionalBody]
    dsimp only
    split
    · exact Context.empty_bounded
    · split
      · split
        · exact Context.empty_bounded
        · split
          · try dsimp only
            split
            · exact Context.empty_bounded
            · simp only [bodyTokens_facts]
              exact Context.join_bounded
                (readBody_factsBounded text context _ .arm (branchStart_factsBounded text context scan "if" sv).1)
                (alternativeBody_factsBounded text context _ (branchStart_factsBounded text context scan "if" sv).2)
          · exact Context.empty_bounded
      · exact Context.empty_bounded
  termination_by (bodyRemaining text scan, 1)

  theorem alternativeBody_factsBounded (text : Source) (context : ParseContext) (scan : BodyScan)
      (sv : scan.facts.Bounded) : (alternativeBody text context scan).facts.Bounded := by
    rw [alternativeBody]
    split
    · exact Context.empty_bounded
    · split
      · dsimp only
        split
        · exact Context.empty_bounded
        · split
          · split
            · exact Context.empty_bounded
            · split
              · exact Context.join_bounded
                  (readBody_factsBounded text context _ .arm (branchStart_factsBounded text context scan "elsif" sv).1)
                  (alternativeBody_factsBounded text context _ (branchStart_factsBounded text context scan "elsif" sv).2)
              · exact Context.empty_bounded
          · exact Context.empty_bounded
      · split
        · dsimp only
          split
          · exact Context.empty_bounded
          · split
            · exact readBody_factsBounded text context _ .endOnly sv
            · exact Context.empty_bounded
        · split
          · exact sv
          · exact Context.empty_bounded
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_factsBounded (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (sv : scan.facts.Bounded) : (bodyTail text context scan stop).facts.Bounded := by
    rw [bodyTail]
    split
    · exact Context.empty_bounded
    · split
      · exact sv
      · dsimp only
        split
        · exact Context.empty_bounded
        · split
          · exact bodyTail_factsBounded text context _ stop (statementBody_factsBounded text context scan sv)
          · exact Context.empty_bounded
  termination_by (bodyRemaining text scan, 3)

  theorem readBody_factsBounded (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (sv : scan.facts.Bounded) : (readBody text context scan stop).facts.Bounded := by
    rw [readBody]
    try dsimp only
    split
    · exact Context.empty_bounded
    · split
      · exact bodyTail_factsBounded text context _ stop (statementBody_factsBounded text context scan sv)
      · exact Context.empty_bounded
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
