module

public import Silver.PredicateBodyCorrespondence
public import Silver.PredicateBodySizing

@[expose] public section

namespace Silver.Predicate.BodyNative

structure SizedBodies (primitive : Primitives) (calls : Calls) : Prop where
  conditional : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → conditionalFunction.Sized primitive calls {text,context,scan}
  alternative : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan,
    ValidScan text context scan → alternativeFunction.Sized primitive calls {text,context,scan}
  tailModel : ∀ text, ValidText text → ∀ context, Native.ValidContext text context → ∀ scan stop,
    ValidScan text context scan → tailModelBody.Sized primitive calls {text,context,scan,stop}

private theorem condition_true_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
    (readCondition text context position facts).whenTrue.count = facts.count := (condition_counts ..).1
private theorem condition_false_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
    (readCondition text context position facts).whenFalse.count = facts.count := (condition_counts ..).2

private theorem read_count (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
    (same : scan.count = context.scalarNames.length) :
    (readBody text context scan stop).facts.count = context.scalarNames.length := readBody_count text context scan stop same
private theorem alternative_count (text : Source) (context : ParseContext) (scan : BodyScan)
    (same : scan.count = context.scalarNames.length) :
    (alternativeBody text context scan).facts.count = context.scalarNames.length := alternativeBody_count text context scan same

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

attribute [local simp] BodyScan.count ConditionResult.Counts Native.Context.model
  condition_true_count condition_false_count read_count alternative_count ActiveFlow.join_count

/-- The native constrained locals all retain the entry allocation extent.
Keep these projections explicit while stepping through the imperative tree. -/
private structure FrameCounts (frame : Frame) : Prop where
  context : frame.scan.count = frame.context.scalarNames.length
  result : frame.result.count = frame.scan.count
  condition : frame.condition.Counts frame.scan.count
  yes : frame.yes.count = frame.scan.count

private theorem model_scan_count (expression : ScanExpr) (frame : Frame)
    (extent : frame.scan.count = frame.context.scalarNames.length)
    (current : frame.result.count = frame.scan.count) :
    (expression.eval modelPrimitives modelCalls frame).count = frame.scan.count := by
  induction expression with
  | input => rfl
  | result => exact current
  | invalid expression ih | invalidModel expression ih => exact ih
  | token token expression ih => exact ih
  | basic expression ih =>
      exact (basic_count frame.text frame.context.model
        (expression.eval modelPrimitives modelCalls frame)).trans ih
  | statement expression ih =>
      exact (statementBody_count frame.text frame.context.model
        (expression.eval modelPrimitives modelCalls frame) (ih.trans extent)).trans extent.symm
  | loop expression ih =>
      exact (loopBody_count frame.text frame.context.model
        (expression.eval modelPrimitives modelCalls frame) (ih.trans extent)).trans extent.symm
  | conditional expression ih =>
      exact (conditionalBody_count frame.text frame.context.model
        (expression.eval modelPrimitives modelCalls frame) (ih.trans extent)).trans extent.symm
  | alternative expression ih =>
      exact (alternativeBody_count frame.text frame.context.model
        (expression.eval modelPrimitives modelCalls frame) (ih.trans extent)).trans extent.symm
  | tailModel stop expression ih | tail stop expression ih =>
      exact (bodyTail_count frame.text frame.context.model
        (expression.eval modelPrimitives modelCalls frame) (stop.eval frame) (ih.trans extent)).trans extent.symm
  | read stop expression ih =>
      exact (readBody_count frame.text frame.context.model
        (expression.eval modelPrimitives modelCalls frame) (stop.eval frame) (ih.trans extent)).trans extent.symm

private theorem model_facts_count (expression : FactsExpr) (frame : Frame)
    (counts : FrameCounts frame) : (expression.eval frame).count = frame.scan.count := by
  cases expression with
  | result => exact counts.result
  | yes => exact counts.yes
  | whenTrue => exact counts.condition.1
  | whenFalse => exact counts.condition.2

/-- Simultaneous sizing and preservation prevents opaque successor frames from
losing the entry/result/condition/yes count equations at an early return. -/
private theorem model_command_sized (command : Command) (frame : Frame)
    (counts : FrameCounts frame) :
    command.Sized modelPrimitives modelCalls frame ∧
      FrameCounts (command.eval modelPrimitives modelCalls frame).2 := by
  induction command generalizing frame with
  | nothing => exact ⟨True.intro, counts⟩
  | assign expression =>
      have assigned := model_scan_count expression frame counts.context counts.result
      exact ⟨assigned, ⟨counts.context, assigned, counts.condition, counts.yes⟩⟩
  | condition =>
      have condition : (readCondition frame.text frame.context.model
          frame.result.position frame.result.facts).Counts frame.scan.count :=
        ⟨(condition_counts frame.text frame.context.model frame.result.position frame.result.facts).1.trans
            counts.result,
          (condition_counts frame.text frame.context.model frame.result.position frame.result.facts).2.trans
            counts.result⟩
      exact ⟨⟨counts.result, condition⟩,
        ⟨counts.context, counts.result, condition, counts.yes⟩⟩
  | positionAfter =>
      exact ⟨True.intro, ⟨counts.context, counts.result, counts.condition, counts.yes⟩⟩
  | facts expression =>
      have assigned := model_facts_count expression frame counts
      exact ⟨assigned, ⟨counts.context, assigned, counts.condition, counts.yes⟩⟩
  | saveYes =>
      exact ⟨counts.result, ⟨counts.context, counts.result, counts.condition, counts.result⟩⟩
  | joinYes =>
      have joined : (frame.result.facts.join frame.yes).count = frame.scan.count :=
        (ActiveFlow.join_count frame.result.facts frame.yes
          (counts.result.trans counts.yes.symm)).trans counts.result
      exact ⟨⟨counts.result, counts.yes, joined⟩,
        ⟨counts.context, joined, counts.condition, counts.yes⟩⟩
  | ret expression => exact ⟨True.intro, counts⟩
  | sequence first second firstIH secondIH =>
      obtain ⟨firstSized, firstCounts⟩ := firstIH frame counts
      cases outcome : first.eval modelPrimitives modelCalls frame with
      | mk returned next =>
          have nextCounts : FrameCounts next := by
            simpa only [outcome] using firstCounts
          cases returned with
          | none =>
              obtain ⟨secondSized, secondCounts⟩ := secondIH next nextCounts
              simpa only [Command.Sized, Command.eval, outcome] using
                (And.intro (And.intro firstSized secondSized) secondCounts)
          | some returned =>
              simpa only [Command.Sized, Command.eval, outcome] using
                (And.intro (And.intro firstSized True.intro) nextCounts)
  | choose test yes no yesIH noIH =>
      by_cases selected : test.eval modelPrimitives modelCalls frame = true
      · simpa only [Command.Sized, Command.eval, selected, ↓reduceIte] using yesIH frame counts
      · simpa only [Command.Sized, Command.eval, selected, Bool.false_eq_true, ↓reduceIte] using noIH frame counts

private theorem model_function_sized (fn : Function) (frame : Frame)
    (counts : FrameCounts frame) (capacity : frame.scan.count ≤ ScalarExpression.maxBindings) :
    fn.Sized modelPrimitives modelCalls frame := by
  have initial := model_scan_count fn.initial frame counts.context counts.result
  exact ⟨capacity, initial,
    (model_command_sized fn.body {frame with result := fn.initial.eval modelPrimitives modelCalls frame}
      ⟨counts.context, initial, counts.condition, counts.yes⟩).1⟩

theorem model_sizedBodies : SizedBodies modelPrimitives modelCalls where
  conditional text _ context cv scan sv := by
    exact model_function_sized conditionalFunction {text,context,scan}
      ⟨sv.2.2.2.compatible.count, rfl, ⟨rfl,rfl⟩, rfl⟩ (sv.2.2.count_le cv)
  alternative text _ context cv scan sv := by
    exact model_function_sized alternativeFunction {text,context,scan}
      ⟨sv.2.2.2.compatible.count, rfl, ⟨rfl,rfl⟩, rfl⟩ (sv.2.2.count_le cv)
  tailModel text _ context _ scan stop sv := by
    have count : (statementBody text context.model scan).count = scan.count :=
      (statementBody_count text context.model scan sv.2.2.2.compatible.count).trans
        sv.2.2.2.compatible.count.symm
    dsimp +instances only [tailModelBody, ModelExpr.Sized, ScanExpr.eval, Test.eval,
      modelPrimitives, modelCalls]
    repeat' first | (simp_all +instances; done) | split

end Silver.Predicate.BodyNative
