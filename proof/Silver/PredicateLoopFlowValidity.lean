module

public import Silver.PredicateLoopProperties
public import Silver.PredicateConditionFlowValidity
public import Silver.PredicateFlowWidening

@[expose] public section

namespace Silver.Predicate
open Compose

attribute [local irreducible] ScalarExpression.read

namespace ScalarMetadata
open ScalarExpression

theorem environment_ranges_bounded {text : Source} {names : Environment}
    (environment : ValidEnvironment text names) : (ranges names).Bounded := by
  intro index bounds found
  unfold ranges at found
  split at found
  · rename_i active
    cases found
    have within : index - 1 < names.length := by omega
    have valid := environment.2 names[index - 1] (List.getElem_mem within)
    simpa only [binding, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem within, Option.getD_some] using valid.2.2.2.1
  · contradiction

theorem FlowReady.widen {text : Source} {names : Environment} {declarations : Nat} {flow : ActiveFlow}
    (base : BaseReady names declarations) (ready : FlowReady names declarations flow)
    (environment : ValidEnvironment text names) : FlowReady names declarations (ActiveFlow.widen names flow) := by
  have model := ActiveFlow.widen_model names declarations flow ready.compatible.count base.body
  refine ⟨?_, ?_, ?_, ?_⟩
  · apply overlayCompatible_of_preserved ready.compatible
      ((ActiveFlow.widen_count names flow ready.compatible.count).trans ready.compatible.count)
    intro index positive bounded immutable _declared
    rw [model]
    simp only [analysis, Integer.Analysis.widen, mutability, positive, bounded, and_self,
      decide_true, Bool.true_and, immutable, Bool.false_eq_true, ↓reduceIte]
  · rw [model]
    exact Integer.Analysis.widen_bounded ready.bounded (environment_ranges_bounded environment)
  · rw [model]
    exact Integer.Analysis.widen_refines ready.contained
  · intro index bounds mutable found
    rw [model] at found
    change (if mutability names index then (ranges names) index else flow.model.scalars index) = some bounds at found
    simp only [mutable, ↓reduceIte] at found
    obtain ⟨incoming, present, included⟩ := ready.contained index bounds found
    have nonempty := ready.mutableNonempty index incoming mutable present
    apply Integer.Interval.contains_nonempty (included incoming.lower ?_)
    simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty
    exact ⟨Int.le_refl _, by omega⟩

theorem BaseReady.append_immutable {names : Environment} {declarations : Nat}
    (base : BaseReady names declarations) (item : Binding) (immutable : item.mutable = false)
    (space : names.length + 1 ≤ ArrayBindings.scalarLimit) :
    BaseReady (names ++ [item]) declarations where
  body := bodyReady_append_immutable base.body immutable
  size := by simpa only [List.length_append, List.length_singleton] using space
  count := by simp only [List.length_append, List.length_singleton]; have := base.count; omega
  declarationsNonempty index positive declared := by
    rw [binding_append_old names item index positive (Nat.le_trans declared base.count)]
    exact base.declarationsNonempty index positive declared
  mutableNonempty index positive bounded mutable := by
    by_cases old : index ≤ names.length
    · rw [binding_append_old names item index positive old] at mutable ⊢
      exact base.mutableNonempty index positive old mutable
    · have fresh : index = names.length + 1 := by
        simp only [List.length_append, List.length_singleton] at bounded
        omega
      subst index
      simp only [binding_append_new, immutable, Bool.false_eq_true] at mutable

theorem FlowReady.append_immutable {names : Environment} {declarations : Nat} {flow : ActiveFlow}
    (base : BaseReady names declarations) (ready : FlowReady names declarations flow)
    (item : Binding) (immutable : item.mutable = false) (typed : item.bounds.Bounded) :
    FlowReady (names ++ [item]) declarations (flow.append item.bounds) := by
  have model := ActiveFlow.append_model flow item.bounds
  have count := ready.compatible.count
  refine ⟨?_, ?_, ?_, ?_⟩
  · refine ⟨by simp only [ActiveFlow.append_count, count, List.length_append, List.length_singleton], ?_⟩
    intro index positive _bounded isImmutable declared
    have oldBound := Nat.le_trans declared base.count
    rw [binding_append_old names item index positive oldBound] at isImmutable ⊢
    have within : index - 1 < flow.values.length := by
      change flow.values.length = names.length at count
      omega
    simpa only [ActiveFlow.append, List.getD_eq_getElem?_getD,
      List.getElem?_append_left within] using
      ready.compatible.immutable index positive oldBound isImmutable declared
  · rw [model]
    exact Integer.Ranges.put_bounded ready.bounded typed
  · rw [model]
    change Integer.Ranges.Refines (Integer.put flow.model.scalars (flow.count + 1) (some item.bounds))
      (ranges (names ++ [item]))
    rw [ranges_append, count]
    exact Integer.Ranges.put_refines ready.contained
  · intro index bounds mutable found
    rw [mutability_append] at mutable
    rw [model] at found
    change Integer.put flow.model.scalars (flow.count + 1) (some item.bounds) index = some bounds at found
    by_cases fresh : index = names.length + 1
    · simp only [Integer.put, fresh, ↓reduceIte, immutable, Bool.false_eq_true] at mutable
    · apply ready.mutableNonempty index bounds
      · simpa only [Integer.put, fresh, ↓reduceIte] using mutable
      · simpa only [Integer.put, count, fresh, ↓reduceIte] using found

end ScalarMetadata

theorem nativeLoopInner_baseReady {context : ParseContext}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (header : LoopHeader) (space : context.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit) :
    ScalarMetadata.BaseReady (loopInner context header).scalarNames (loopInner context header).declarationCount :=
  base.append_immutable _ rfl space

theorem loopHeader_flowReady {text : Source} {context : ParseContext} {scan : BodyScan}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount scan.facts)
    (environment : ScalarExpression.ValidEnvironment text context.scalarNames)
    (positive : (loopHeader text context scan).entry.position ≠ 0) :
    ScalarMetadata.FlowReady (loopInner context (loopHeader text context scan)).scalarNames
      (loopInner context (loopHeader text context scan)).declarationCount
      (loopHeader text context scan).entry.facts := by
  have typed := loopHeader_bounds_bounded positive
  let header := loopHeader text context scan
  let item : ScalarExpression.Binding :=
    ⟨header.first, header.after, header.bounds, false, header.bounds, false⟩
  exact (ScalarMetadata.FlowReady.append_immutable base
    (ScalarMetadata.FlowReady.widen base ready environment) item rfl typed).withPath _

theorem loopAfterFlow_flowReady {text : Source} {context : ParseContext} {before : ActiveFlow}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount before)
    (environment : ScalarExpression.ValidEnvironment text context.scalarNames)
    (after : ActiveFlow) (lower upper : Integer.Interval) :
    ScalarMetadata.FlowReady context.scalarNames context.declarationCount
      (loopAfterFlow context before after lower upper) := by
  unfold loopAfterFlow
  dsimp only
  split
  · exact ready.withPath _
  · exact (ScalarMetadata.FlowReady.widen base ready environment).withPath _

theorem loopAfterHeader_flowReady {text : Source} {context : ParseContext} {before : ActiveFlow}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount before)
    (environment : ScalarExpression.ValidEnvironment text context.scalarNames)
    (after : ActiveFlow) (header : LoopHeader) :
    ScalarMetadata.FlowReady context.scalarNames context.declarationCount
      (loopAfterHeader context before after header) := by
  unfold loopAfterHeader
  split
  · exact (ScalarMetadata.FlowReady.widen base ready environment).withPath _
  · exact loopAfterFlow_flowReady base ready environment _ _ _

end Silver.Predicate
