module

public import Silver.PredicateBasicReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

abbrev BranchAt (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String)
    (condition : Condition) : Prop :=
  ConditionAt text context (bodyToken text scan (.word keyword)).position scan.facts condition
    (readCondition text context (bodyToken text scan (.word keyword)).position scan.facts)

/- Source readings retain every explicit arm and its source operands. Concrete
scanner equations are trace fields; validity is proved separately from them. -/
mutual
  inductive StatementAt (text : Source) :
      ParseContext → BodyScan → SourceStatement → BodyScan → Prop
    | basic {context scan item result} : scan.position ≠ 0 → fixedAfter text scan.position "if" true = 0 →
        fixedAfter text scan.position "for" true = 0 →
        BasicAt text context scan item result → statementBody text context scan = result →
        StatementAt text context scan item result
    | choice {context scan condition yes tail result} : scan.position ≠ 0 → fixedAfter text scan.position "if" true ≠ 0 →
        ChoiceAt text context scan condition yes tail result → statementBody text context scan = result →
        StatementAt text context scan (.choice condition yes tail) result
    | loop {context scan lower upper body result} : scan.position ≠ 0 → fixedAfter text scan.position "if" true = 0 →
        fixedAfter text scan.position "for" true ≠ 0 →
        LoopAt text context scan lower upper body result → statementBody text context scan = result →
        StatementAt text context scan
          (.forLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse lower upper body) result

  inductive LoopAt (text : Source) :
      ParseContext → BodyScan → Integer.Expr → Integer.Expr → List SourceStatement → BodyScan → Prop
    | loop {context scan lower upper body bodyResult result} :
        loopNameAllowed text context (loopHeader text context scan) = true →
        ScalarExpression.At (arrays := context.arrayNames) text (context.readingNames scan.facts) (loopLowerPosition text scan)
          lower (loopHeader text context scan).lower (loopFirst text scan) (loopNameAfter text scan) →
        ScalarExpression.At (arrays := context.arrayNames) text (context.readingNames scan.facts)
          (fixedAfter text (loopHeader text context scan).lower.after ".." false)
          upper (loopHeader text context scan).upper (loopFirst text scan) (loopNameAfter text scan) →
        bodyRemaining text (loopHeader text context scan).entry < bodyRemaining text scan →
        BodyAt text (loopInner context (loopHeader text context scan)) (loopHeader text context scan).entry
          .endOnly body bodyResult →
        result = bodyTokens text
          {bodyResult with facts := loopAfterHeader context scan.facts bodyResult.facts (loopHeader text context scan)}
          [.word "end", .word "loop", .symbol ";"] →
        result.position ≠ 0 → loopBody text context scan = result →
        LoopAt text context scan lower upper body result

  inductive ChoiceAt (text : Source) :
      ParseContext → BodyScan → Condition → List SourceStatement → SourceAlternative → BodyScan → Prop
    | choice {context scan condition yes tail yesResult noResult result} :
        BranchAt text context scan "if" condition →
        bodyRemaining text (branchStart text context scan "if").1 < bodyRemaining text scan →
        BodyAt text context (branchStart text context scan "if").1 .arm yes yesResult →
        bodyRemaining text yesResult < bodyRemaining text scan →
        AlternativeAt text context {yesResult with facts := (branchStart text context scan "if").2} tail noResult →
        result = bodyTokens text {noResult with facts := yesResult.facts.join noResult.facts}
          [.word "end", .word "if", .symbol ";"] →
        result.position ≠ 0 → conditionalBody text context scan = result →
        ChoiceAt text context scan condition yes tail result

  inductive AlternativeAt (text : Source) :
      ParseContext → BodyScan → SourceAlternative → BodyScan → Prop
    | absent {context scan} : scan.position ≠ 0 → fixedAfter text scan.position "elsif" true = 0 →
        fixedAfter text scan.position "else" true = 0 → fixedAfter text scan.position "end" true ≠ 0 →
        AlternativeAt text context scan .absent scan
    | otherwise {context scan items result} : scan.position ≠ 0 → fixedAfter text scan.position "elsif" true = 0 →
        fixedAfter text scan.position "else" true ≠ 0 →
        bodyRemaining text (bodyToken text scan (.word "else")) < bodyRemaining text scan →
        BodyAt text context (bodyToken text scan (.word "else")) .endOnly items result →
        alternativeBody text context scan = result →
        AlternativeAt text context scan (.otherwise items) result
    | elsif {context scan condition yes tail yesResult noResult result} :
        scan.position ≠ 0 → fixedAfter text scan.position "elsif" true ≠ 0 →
        BranchAt text context scan "elsif" condition →
        bodyRemaining text (branchStart text context scan "elsif").1 < bodyRemaining text scan →
        BodyAt text context (branchStart text context scan "elsif").1 .arm yes yesResult →
        bodyRemaining text yesResult < bodyRemaining text scan →
        AlternativeAt text context {yesResult with facts := (branchStart text context scan "elsif").2} tail noResult →
        result = {noResult with facts := yesResult.facts.join noResult.facts} →
        result.position ≠ 0 → alternativeBody text context scan = result →
        AlternativeAt text context scan (.elsif condition yes tail) result

  inductive BodyTailAt (text : Source) :
      ParseContext → BodyStop → BodyScan → List SourceStatement → BodyScan → Prop
    | done {context stop scan} : scan.position ≠ 0 → atBodyStop text scan.position stop = true →
        BodyTailAt text context stop scan [] scan
    | next {context stop scan item next rest result} : scan.position ≠ 0 → atBodyStop text scan.position stop = false →
        StatementAt text context scan item next →
        bodyRemaining text next < bodyRemaining text scan →
        BodyTailAt text context stop next rest result → bodyTail text context scan stop = result →
        BodyTailAt text context stop scan (item :: rest) result

  inductive BodyAt (text : Source) :
      ParseContext → BodyScan → BodyStop → List SourceStatement → BodyScan → Prop
    | cons {context scan stop item next rest result} : StatementAt text context scan item next →
        bodyRemaining text next < bodyRemaining text scan →
        BodyTailAt text context stop next rest result → readBody text context scan stop = result →
        BodyAt text context scan stop (item :: rest) result
end

theorem statement_complete {text context scan item result}
    (parsed : StatementAt text context scan item result) : statementBody text context scan = result := by
  cases parsed <;> assumption

theorem choice_complete {text context scan condition yes tail result}
    (parsed : ChoiceAt text context scan condition yes tail result) : conditionalBody text context scan = result := by
  cases parsed; assumption

theorem loop_complete {text context scan lower upper body result}
    (parsed : LoopAt text context scan lower upper body result) : loopBody text context scan = result := by
  cases parsed; assumption

theorem alternative_complete {text context scan tail result}
    (parsed : AlternativeAt text context scan tail result) : alternativeBody text context scan = result := by
  cases parsed with
  | absent positive noElsif noElse endPresent =>
      rw [alternativeBody]
      simp only [positive, noElsif, noElse, endPresent, ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte]
  | otherwise => assumption
  | elsif => assumption

theorem bodyTail_complete {text context stop scan items result}
    (parsed : BodyTailAt text context stop scan items result) : bodyTail text context scan stop = result := by
  cases parsed with
  | done positive stopped => rw [bodyTail]; simp only [positive, stopped, ↓reduceIte]
  | next => assumption

theorem body_complete {text context stop scan items result}
    (parsed : BodyAt text context scan stop items result) : readBody text context scan stop = result := by
  cases parsed; assumption

theorem body_nonempty {text context stop scan items result}
    (parsed : BodyAt text context scan stop items result) : items ≠ [] := by
  cases parsed; simp

end Silver.Predicate
