module

public import Silver.ApplicationPackageBodiesStatementModel
public import Silver.PredicateLoopProperties
public import Silver.PredicateFlowWidening

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open ApplicationPackages Compose Predicate

private theorem copied_values (items : List Integer.Interval) :
    (List.range items.length).map (fun i => items.getD i .empty) = items := by
  apply List.ext_getElem (by simp)
  intro i _ inside
  simp only [List.getElem_map, List.getElem_range, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem inside, Option.getD_some]

/-- The native iterator flow stores every existing cell followed by the
single readonly iterator. Count equality comes from the caller and Widen_Into. -/
theorem innerInput_flow (s : Input) (iteration : Iteration) (widened : ActiveFlow)
    (extent : s.input.count = widened.count) :
    (innerInput s iteration widened).scan.facts =
      {widened.append iteration.bounds with path := loopContext widened.path iteration.bounds} := by
  change s.input.count = widened.values.length at extent
  dsimp only [innerInput, withFacts, ActiveFlow.append, loopContext]
  rw [extent, copied_values]

theorem innerContext_header (s : Input) (it : Iteration) (header : LoopHeader)
    (first : it.first = header.first) (last : it.last = header.after) (bounds : it.bounds = header.bounds) :
    innerContext s it = loopInner s.context header := by
  simp only [innerContext, loopInner, first, last, bounds]

/-- For a counted iteration the copied cursor and effect sets come from the
nested body, while the outer scalar storage uses the exact guarded join. -/
theorem afterIteration_counted (calls : Calls) (s : Input) (it : Iteration) (inside : ApplicationScan)
    (low high : Integer.Interval) (bounds : it.bounds = Integer.loopBounds low high)
    (definite : it.definite = Integer.loopDefinite low high)
    (join : calls.pathJoin = PathFacts.Context.join) :
    (afterIteration calls s it (ActiveFlow.widen s.context.scalarNames s.input.scan.facts) inside).scan.facts =
      loopAfterFlow s.context s.input.scan.facts inside.scan.facts low high := by
  dsimp only [afterIteration, loopAfterFlow, loopAfter]
  rw [bounds, definite, join]
  split <;> rfl

theorem afterIteration_array (calls : Calls) (s : Input) (it : Iteration) (inside : ApplicationScan)
    (present : it.bounds.isEmpty = false) (definite : it.definite = true) :
    (afterIteration calls s it (ActiveFlow.widen s.context.scalarNames s.input.scan.facts) inside).scan.facts =
      {ActiveFlow.widen s.context.scalarNames s.input.scan.facts with path := inside.scan.facts.path} := by
  simp only [afterIteration, present, Bool.false_eq_true, ↓reduceIte, definite]

end Silver.ApplicationPackageBodies.Statement
