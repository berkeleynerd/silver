module

public import Silver.PredicateBasicStepReadings

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
open Compose Bindings PathFacts

abbrev BranchAt (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String)
    (condition : Condition) : Prop :=
  ConditionAt text context (bodyToken text scan (.word keyword)).position scan.facts condition
    (readCondition text context (bodyToken text scan (.word keyword)).position scan.facts)

/- Source readings retain every explicit arm and its source operands. Concrete
scanner equations are trace fields; validity is proved separately from them. -/
mutual
  inductive StatementAt (text : Source) (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) :
      ParseContext → BodyScan → SourceStatement → BodyScan → Prop
    | basic {context scan item result} : scan.position ≠ 0 → fixedAfter text scan.position "if" true = 0 →
        fixedAfter text scan.position "for" true = 0 →
        BasicStepAt (catalog := catalog) (procedures := procedures) text context scan item result → statementBody (catalog := catalog) (procedures := procedures) text context scan = result →
        StatementAt (catalog := catalog) (procedures := procedures) text context scan item result
    | choice {context scan condition yes tail result} : scan.position ≠ 0 → fixedAfter text scan.position "if" true ≠ 0 →
        ChoiceAt (catalog := catalog) (procedures := procedures) text context scan condition yes tail result → statementBody (catalog := catalog) (procedures := procedures) text context scan = result →
        StatementAt (catalog := catalog) (procedures := procedures) text context scan (.choice condition yes tail) result
    | loop {context scan lower upper body result} : scan.position ≠ 0 → fixedAfter text scan.position "if" true = 0 →
        fixedAfter text scan.position "for" true ≠ 0 →
        LoopAt (catalog := catalog) (procedures := procedures) text context scan lower upper body result → statementBody (catalog := catalog) (procedures := procedures) text context scan = result →
        StatementAt (catalog := catalog) (procedures := procedures) text context scan
          (.forLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse lower upper body) result
    | arrayLoop {context scan body result} : scan.position ≠ 0 → fixedAfter text scan.position "if" true = 0 →
        fixedAfter text scan.position "for" true ≠ 0 →
        ArrayLoopAt (catalog := catalog) (procedures := procedures) text context scan body result → statementBody (catalog := catalog) (procedures := procedures) text context scan = result →
        StatementAt (catalog := catalog) (procedures := procedures) text context scan
          (.arrayLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
            (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).viewDescriptor body) result

  inductive LoopAt (text : Source) (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) :
      ParseContext → BodyScan → Integer.Expr → Integer.Expr → List SourceStatement → BodyScan → Prop
    | loop {context scan lower upper body bodyResult result} :
        loopIsArray text scan = false →
        loopNameAllowed text context (loopHeader text context scan) = true →
        LoopBoundsAt text context scan lower upper →
        bodyRemaining text (loopHeader text context scan).entry < bodyRemaining text scan →
        BodyAt (catalog := catalog) (procedures := procedures) text (loopInner context (loopHeader text context scan)) (loopHeader text context scan).entry
          .endOnly body bodyResult →
        result = bodyTokens text
          {bodyResult with facts := loopAfterHeader context scan.facts bodyResult.facts (loopHeader text context scan)}
          [.word "end", .word "loop", .symbol ";"] →
        result.position ≠ 0 → loopBody (catalog := catalog) (procedures := procedures) text context scan = result →
        LoopAt (catalog := catalog) (procedures := procedures) text context scan lower upper body result

  inductive ArrayLoopAt (text : Source) (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) :
      ParseContext → BodyScan → List SourceStatement → BodyScan → Prop
    | loop {context scan body bodyResult result} :
        loopIsArray text scan = true →
        loopNameAllowed text context (loopHeader text context scan) = true →
        loopArrayAllowed text context scan = true →
        bodyRemaining text (loopHeader text context scan).entry < bodyRemaining text scan →
        BodyAt (catalog := catalog) (procedures := procedures) text (loopInner context (loopHeader text context scan)) (loopHeader text context scan).entry
          .endOnly body bodyResult →
        result = bodyTokens text
          {bodyResult with facts := loopAfterHeader context scan.facts bodyResult.facts (loopHeader text context scan)}
          [.word "end", .word "loop", .symbol ";"] →
        result.position ≠ 0 → loopBody (catalog := catalog) (procedures := procedures) text context scan = result →
        ArrayLoopAt (catalog := catalog) (procedures := procedures) text context scan body result

  inductive ChoiceAt (text : Source) (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) :
      ParseContext → BodyScan → Condition → List SourceStatement → SourceAlternative → BodyScan → Prop
    | choice {context scan condition yes tail yesResult noResult result} :
        BranchAt text context scan "if" condition →
        bodyRemaining text (branchStart text context scan "if").1 < bodyRemaining text scan →
        BodyAt (catalog := catalog) (procedures := procedures) text context (branchStart text context scan "if").1 .arm yes yesResult →
        bodyRemaining text yesResult < bodyRemaining text scan →
        AlternativeAt (catalog := catalog) (procedures := procedures) text context {yesResult with facts := (branchStart text context scan "if").2} tail noResult →
        result = bodyTokens text {noResult with facts := yesResult.facts.join noResult.facts}
          [.word "end", .word "if", .symbol ";"] →
        result.position ≠ 0 → conditionalBody (catalog := catalog) (procedures := procedures) text context scan = result →
        ChoiceAt (catalog := catalog) (procedures := procedures) text context scan condition yes tail result

  inductive AlternativeAt (text : Source) (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) :
      ParseContext → BodyScan → SourceAlternative → BodyScan → Prop
    | absent {context scan} : scan.position ≠ 0 → fixedAfter text scan.position "elsif" true = 0 →
        fixedAfter text scan.position "else" true = 0 → fixedAfter text scan.position "end" true ≠ 0 →
        AlternativeAt (catalog := catalog) (procedures := procedures) text context scan .absent scan
    | otherwise {context scan items result} : scan.position ≠ 0 → fixedAfter text scan.position "elsif" true = 0 →
        fixedAfter text scan.position "else" true ≠ 0 →
        bodyRemaining text (bodyToken text scan (.word "else")) < bodyRemaining text scan →
        BodyAt (catalog := catalog) (procedures := procedures) text context (bodyToken text scan (.word "else")) .endOnly items result →
        alternativeBody (catalog := catalog) (procedures := procedures) text context scan = result →
        AlternativeAt (catalog := catalog) (procedures := procedures) text context scan (.otherwise items) result
    | elsif {context scan condition yes tail yesResult noResult result} :
        scan.position ≠ 0 → fixedAfter text scan.position "elsif" true ≠ 0 →
        BranchAt text context scan "elsif" condition →
        bodyRemaining text (branchStart text context scan "elsif").1 < bodyRemaining text scan →
        BodyAt (catalog := catalog) (procedures := procedures) text context (branchStart text context scan "elsif").1 .arm yes yesResult →
        bodyRemaining text yesResult < bodyRemaining text scan →
        AlternativeAt (catalog := catalog) (procedures := procedures) text context {yesResult with facts := (branchStart text context scan "elsif").2} tail noResult →
        result = {noResult with facts := yesResult.facts.join noResult.facts} →
        result.position ≠ 0 → alternativeBody (catalog := catalog) (procedures := procedures) text context scan = result →
        AlternativeAt (catalog := catalog) (procedures := procedures) text context scan (.elsif condition yes tail) result

  inductive BodyTailAt (text : Source) (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) :
      ParseContext → BodyStop → BodyScan → List SourceStatement → BodyScan → Prop
    | done {context stop scan} : scan.position ≠ 0 → atBodyStop text scan.position stop = true →
        BodyTailAt (catalog := catalog) (procedures := procedures) text context stop scan [] scan
    | next {context stop scan item next rest result} : scan.position ≠ 0 → atBodyStop text scan.position stop = false →
        StatementAt (catalog := catalog) (procedures := procedures) text context scan item next →
        bodyRemaining text next < bodyRemaining text scan →
        BodyTailAt (catalog := catalog) (procedures := procedures) text context stop next rest result → bodyTail (catalog := catalog) (procedures := procedures) text context scan stop = result →
        BodyTailAt (catalog := catalog) (procedures := procedures) text context stop scan (item :: rest) result

  inductive BodyAt (text : Source) (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) :
      ParseContext → BodyScan → BodyStop → List SourceStatement → BodyScan → Prop
    | cons {context scan stop item next rest result} : StatementAt (catalog := catalog) (procedures := procedures) text context scan item next →
        bodyRemaining text next < bodyRemaining text scan →
        BodyTailAt (catalog := catalog) (procedures := procedures) text context stop next rest result → readBody (catalog := catalog) (procedures := procedures) text context scan stop = result →
        BodyAt (catalog := catalog) (procedures := procedures) text context scan stop (item :: rest) result
end

theorem statement_complete {text context scan item result}
    (parsed : StatementAt (catalog := catalog) (procedures := procedures) text context scan item result) : statementBody (catalog := catalog) (procedures := procedures) text context scan = result := by
  cases parsed <;> assumption

theorem choice_complete {text context scan condition yes tail result}
    (parsed : ChoiceAt (catalog := catalog) (procedures := procedures) text context scan condition yes tail result) : conditionalBody (catalog := catalog) (procedures := procedures) text context scan = result := by
  cases parsed; assumption

theorem loop_complete {text context scan lower upper body result}
    (parsed : LoopAt (catalog := catalog) (procedures := procedures) text context scan lower upper body result) : loopBody (catalog := catalog) (procedures := procedures) text context scan = result := by
  cases parsed; assumption

theorem arrayLoop_complete {text context scan body result}
    (parsed : ArrayLoopAt (catalog := catalog) (procedures := procedures) text context scan body result) : loopBody (catalog := catalog) (procedures := procedures) text context scan = result := by
  cases parsed; assumption

theorem alternative_complete {text context scan tail result}
    (parsed : AlternativeAt (catalog := catalog) (procedures := procedures) text context scan tail result) : alternativeBody (catalog := catalog) (procedures := procedures) text context scan = result := by
  cases parsed with
  | absent positive noElsif noElse endPresent =>
      rw [alternativeBody]
      simp only [positive, noElsif, noElse, endPresent, ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte]
  | otherwise => assumption
  | elsif => assumption

theorem bodyTail_complete {text context stop scan items result}
    (parsed : BodyTailAt (catalog := catalog) (procedures := procedures) text context stop scan items result) : bodyTail (catalog := catalog) (procedures := procedures) text context scan stop = result := by
  cases parsed with
  | done positive stopped => rw [bodyTail]; simp only [positive, stopped, ↓reduceIte]
  | next => assumption

theorem body_complete {text context stop scan items result}
    (parsed : BodyAt (catalog := catalog) (procedures := procedures) text context scan stop items result) : readBody (catalog := catalog) (procedures := procedures) text context scan stop = result := by
  cases parsed; assumption

theorem body_nonempty {text context stop scan items result}
    (parsed : BodyAt (catalog := catalog) (procedures := procedures) text context scan stop items result) : items ≠ [] := by
  cases parsed; simp

end Silver.Predicate
