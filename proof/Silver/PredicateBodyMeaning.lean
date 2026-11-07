module

public import Silver.PredicateBodyBinderSeparation
public import Silver.PredicateConditionValidity
public import Silver.PredicateConditionSound
public import Silver.PredicateBodyBounds
public import Silver.PredicateBodyFlow
public import Silver.PredicateFlowInvariant

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata}
open Compose Bindings PathFacts

attribute [local irreducible] ScalarExpression.read

/-- Appending a lexical index changes precisely its fresh scalar identity.
The declaration prefix is retained, so the new readonly name is refinable. -/
theorem analysis_append_index (names : ScalarExpression.Environment) (declarations : Nat)
    (item : ScalarExpression.Binding) (declarationsBound : declarations ≤ names.length)
    (immutable : item.mutable = false) (nonstatic : item.isStatic = false) :
    ScalarMetadata.analysis (names ++ [item]) declarations =
      (ScalarMetadata.analysis names declarations).withIndex (names.length + 1) item.bounds := by
  unfold ScalarMetadata.analysis Integer.Analysis.withIndex
  simp only [ScalarExpression.ranges_append, ScalarExpression.mutability_append, immutable]
  congr 1
  · funext index
    by_cases fresh : index = names.length + 1
    · subst index
      simp [ScalarMetadata.staticness, Integer.put, ScalarExpression.binding_append_new, nonstatic]
    · by_cases old : 0 < index ∧ index ≤ names.length
      · have extended : 0 < index ∧ index ≤ (names ++ [item]).length := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.staticness, extended, old, and_self, decide_true, Bool.true_and,
          Integer.put, fresh, ↓reduceIte, ScalarExpression.binding_append_old names item index old.1 old.2]
      · have outside : ¬(0 < index ∧ index ≤ (names ++ [item]).length) := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.staticness, outside, old, decide_false, Bool.false_and,
          Integer.put, fresh, ↓reduceIte]
  · funext index
    by_cases fresh : index = names.length + 1
    · subst index
      simp [ScalarMetadata.refinable, Integer.put, ScalarExpression.binding_append_new,
        immutable, show declarations < names.length + 1 by omega]
    · by_cases old : 0 < index ∧ index ≤ names.length
      · have extended : 0 < index ∧ index ≤ (names ++ [item]).length := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.refinable, extended, old, and_self, decide_true, Bool.true_and,
          Integer.put, fresh, ↓reduceIte, ScalarExpression.binding_append_old names item index old.1 old.2]
      · have outside : ¬(0 < index ∧ index ≤ (names ++ [item]).length) := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.refinable, outside, old, decide_false, Bool.false_and,
          Integer.put, fresh, ↓reduceIte]

theorem loopInner_analysis {context : ParseContext} (header : LoopHeader)
    (declarationsBound : context.declarationCount ≤ context.scalarNames.length)
    (space : context.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit) :
    (loopInner context header).analysis = context.analysis.withIndex (context.scalarNames.length + 1)
      header.bounds := by
  change ArrayFlow.analysis context.arrayNames (ScalarMetadata.analysis _ _) = _
  dsimp only [loopInner]
  rw [analysis_append_index _ _ _ declarationsBound rfl rfl]
  exact ArrayFlow.analysis_withIndex _ _ _ _ space

theorem loopInner_baseReady {context : ParseContext} (header : LoopHeader)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (space : context.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit) :
    ScalarMetadata.BaseReady (loopInner context header).scalarNames (loopInner context header).declarationCount := by
  refine ⟨ScalarExpression.bodyReady_append base.body (by simp), ?_, ?_, ?_, ?_⟩
  · simp only [loopInner, List.length_append, List.length_singleton]
    exact Nat.le_trans base.count (Nat.le_succ _)
  · intro index positive declared
    have old : index ≤ context.scalarNames.length := Nat.le_trans declared base.count
    simpa only [loopInner, ScalarExpression.binding_append_old _ _ _ positive old] using
      base.declarationsNonempty index positive declared
  · intro index positive bounded mutable
    have bound : index ≤ context.scalarNames.length + 1 := by
      simpa only [loopInner, List.length_append, List.length_singleton] using bounded
    dsimp only [loopInner] at mutable ⊢
    by_cases old : index ≤ context.scalarNames.length
    · rw [ScalarExpression.binding_append_old _ _ index positive old] at mutable ⊢
      exact base.mutableNonempty index positive old mutable
    · have fresh : index = context.scalarNames.length + 1 := by omega
      subst index
      simp only [ScalarExpression.binding_append_new, Bool.false_eq_true] at mutable
  · simpa only [loopInner, List.length_append, List.length_singleton] using space

theorem loopHeader_scalar_model {text : Source} {context : ParseContext} {scan : BodyScan}
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (count : scan.count = context.scalarNames.length) :
    (loopHeader text context scan).entry.facts.model =
      loopEntry (ScalarMetadata.analysis context.scalarNames context.declarationCount) scan.facts.model (context.scalarNames.length + 1)
        (loopHeader text context scan).bounds := by
  let bounds := (loopHeader text context scan).bounds
  change scan.facts.count = context.scalarNames.length at count
  change (⟨loopContext scan.facts.path bounds,
    ((ActiveFlow.widen context.scalarNames scan.facts).append bounds).model.scalars⟩ : Flow) = _
  rw [ActiveFlow.append_model,
    ActiveFlow.widen_model context.scalarNames context.declarationCount scan.facts count ready,
    ActiveFlow.widen_count context.scalarNames scan.facts count, count]
  rfl

theorem loopHeader_model {text : Source} {context : ParseContext} {scan : BodyScan}
    (bodyMode : context.elaborating = false)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (count : scan.count = context.scalarNames.length)
    (space : context.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit) :
    context.flow (loopHeader text context scan).entry.facts =
      loopEntry context.analysis (context.flow scan.facts) (context.scalarNames.length + 1)
        (loopHeader text context scan).bounds := by
  let bounds := (loopHeader text context scan).bounds
  change scan.facts.count = context.scalarNames.length at count
  change context.flow { (scan.facts.widen context.scalarNames).append bounds with
    path := loopContext scan.facts.path bounds } = _
  rw [ParseContext.flow_withPath]
  simp only [ParseContext.flow, bodyMode]
  change {ArrayFlow.flow context.arrayNames ((scan.facts.widen context.scalarNames).append bounds) with
    path := loopContext scan.facts.path bounds} = _
  rw [ArrayFlow.flow_append _ _ _ (by rw [ActiveFlow.widen_count _ _ count, count]; exact space),
    ArrayFlow.flow_widen _ _ _ _ count ready,
    ActiveFlow.widen_count _ _ count, count]
  rfl

theorem loopHeader_compatible {text : Source} {context : ParseContext} {scan : BodyScan}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts) :
    ScalarMetadata.OverlayCompatible (loopInner context (loopHeader text context scan)).scalarNames
      (loopInner context (loopHeader text context scan)).declarationCount
      (loopHeader text context scan).entry.facts := by
  refine ⟨?_, ?_⟩
  · simpa only [loopInner, List.length_append, List.length_singleton, BodyScan.count] using
      loopHeader_count text context scan compatible.count
  · intro index positive bounded mutable declared
    have old : index ≤ context.scalarNames.length := Nat.le_trans declared base.count
    have bindingEq : ScalarExpression.binding
        (loopInner context (loopHeader text context scan)).scalarNames index =
        ScalarExpression.binding context.scalarNames index :=
      ScalarExpression.binding_append_old _ _ _ positive old
    rw [bindingEq] at mutable ⊢
    have readonly : (ScalarMetadata.analysis context.scalarNames context.declarationCount).mutable index = false := by
      simp only [ScalarMetadata.analysis, ScalarExpression.mutability,
        show 0 < index ∧ index ≤ context.scalarNames.length from ⟨positive, old⟩,
        and_self, decide_true, Bool.true_and, mutable]
    have cell := compatible.fixed_cell index positive old mutable declared
    have entryCell : (loopHeader text context scan).entry.facts.model.scalars index =
        some (ScalarExpression.binding context.scalarNames index).bounds := by
      rw [loopHeader_scalar_model base.body compatible.count]
      simpa only [loopEntry, Integer.put, show index ≠ context.scalarNames.length + 1 by omega,
        ↓reduceIte, Integer.Analysis.widen, readonly, Bool.false_eq_true] using cell
    change ActiveFlow.ranges (loopHeader text context scan).entry.facts.values index = _ at entryCell
    simp only [ActiveFlow.ranges, show index ≠ 0 by omega, ↓reduceIte] at entryCell
    simp only [List.getD_eq_getElem?_getD, entryCell, Option.getD_some]

theorem loopAfterFlow_model {context : ParseContext} {before after : ActiveFlow}
    (bodyMode : context.elaborating = false)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (count : before.count = context.scalarNames.length) (lower upper : Integer.Interval) :
    context.flow (loopAfterFlow context before after lower upper) =
      loopExit context.analysis (context.flow before) (context.flow after) lower upper := by
  have widened := congrArg Flow.scalars
    (ArrayFlow.flow_widen context.arrayNames context.scalarNames context.declarationCount before count ready)
  cases empty : (Integer.loopBounds lower upper).isEmpty with
  | true => simp only [loopAfterFlow, loopExit, empty, ↓reduceIte, ParseContext.flow_withPath]; rfl
  | false =>
      simp only [loopAfterFlow, loopExit, empty, Bool.false_eq_true, ↓reduceIte,
        ParseContext.flow, bodyMode]
      exact congrArg (fun ranges => Flow.mk (loopAfter before.path after.path lower upper) ranges) widened

theorem loopAfterHeader_model {context : ParseContext} {before after : ActiveFlow}
    (bodyMode : context.elaborating = false)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (count : before.count = context.scalarNames.length) (header : LoopHeader) :
    context.flow (loopAfterHeader context before after header) =
      if header.isArray then arrayLoopExit context.analysis (context.flow before) (context.flow after)
      else loopExit context.analysis (context.flow before) (context.flow after) header.lower.bounds header.upper.bounds := by
  unfold loopAfterHeader
  split
  · have widened := congrArg Flow.scalars
      (ArrayFlow.flow_widen context.arrayNames context.scalarNames context.declarationCount before count ready)
    simpa only [ParseContext.flow, bodyMode, arrayLoopExit, ArrayFlow.flow, ArrayFlow.ranges, ActiveFlow.model, ParseContext.analysis] using
      congrArg (fun ranges => Flow.mk after.path ranges) widened
  · exact loopAfterFlow_model bodyMode ready count _ _

/-- Separation follows from the concrete allocation layout and the source
scanner's capacity guard, never from a bound assumed for generic core names. -/
theorem arrayBinding_scalar_apart (item : ArrayBindings.Binding) (index : Nat)
    (low : index ≤ ArrayBindings.scalarLimit) : ¬item.descriptor.ContainsCell index := by
  intro inside
  simp only [ArrayBindings.Binding.descriptor, Integer.ArrayDescriptor.ContainsCell] at inside
  omega

theorem loopArrayReady {text : Source} {context : ParseContext} {scan : BodyScan}
    (bodyMode : context.elaborating = false)
    (arraysReady : context.ArraysReady text)
    (space : context.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit)
    (allowed : loopArrayAllowed text context scan = true) :
    arrayLoopReady context.analysis (context.flow scan.facts) (context.scalarNames.length + 1)
      (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).descriptor = true := by
  have constraints := allowed
  simp only [loopArrayAllowed, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq] at constraints
  have nonzero : loopArrayTarget text context scan ≠ 0 := constraints.1.1.1.2.2
  have immutable : (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).mutable = false :=
    constraints.1.1.2
  have targetBound : loopArrayTarget text context scan ≤ context.arrayNames.length := by
    unfold loopArrayTarget arrayTarget
    dsimp only
    split
    · exact Nat.zero_le _
    · exact ArrayBindings.Native.lookup_bound ..
  have member := ArrayBindings.Native.binding_mem (Nat.pos_of_ne_zero nonzero) targetBound
  have valid := (arraysReady.1.2.1 _ member).2.2.2
  have integerKind : (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).isBoolean = false :=
    constraints.2
  have selected := ArrayBindings.mem_integerNames.mpr ⟨member, integerKind⟩
  have metadata := ArrayBindings.integerNames_validBindings (fun entry found => (arraysReady.1.2.1 entry found).2.2.2)
  have ordered := ArrayBindings.integerNames_ordered arraysReady.2
  simp only [ParseContext.flow, bodyMode]
  apply (arrayLoopReady_iff _ _ _ _).mpr
  refine ⟨ArrayBindings.binding_descriptor_valid valid, arrayBinding_scalar_apart _ _ space,
    ArrayBindings.body_ranges_components
      metadata ordered selected [] _, ArrayBindings.body_ranges_components
      metadata ordered selected [] _, ?_, ArrayBindings.binding_component_valid valid⟩
  intro cell inside
  exact (ArrayBindings.ordered_mutability metadata ordered selected inside _).trans immutable

private theorem checked_statement_compatible {context : ParseContext} {before after : ActiveFlow}
    {item : Statement} {booleans : Boolean.Analysis} (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount before)
    (checked : item.check (signatures := catalogSignatures catalog) context.names.shape context.analysis (context.flow before) booleans = some (context.flow after))
    (count : after.count = context.scalarNames.length) :
    ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount after := by
  apply ScalarMetadata.overlayCompatible_of_preserved compatible count
  intro index positive bounded mutable declared
  have readonly : context.analysis.mutable index = false := by
    simp only [ParseContext.analysis, ArrayFlow.analysis, ArrayBindings.integerMutability, ArrayBindings.integerRefinability,
      ArrayBindings.mutability_scalar _ _ (Nat.le_trans bounded base.size),
      ScalarMetadata.analysis, ScalarExpression.mutability,
      show 0 < index ∧ index ≤ context.scalarNames.length from ⟨positive, bounded⟩,
      and_self, decide_true, Bool.true_and, mutable]
  have fixed : context.analysis.refinable index = false := by
    simp only [ParseContext.analysis, ArrayFlow.analysis, ArrayBindings.integerRefinability,
      ArrayBindings.refinability_scalar _ _ (Nat.le_trans bounded base.size),
      ScalarMetadata.analysis, ScalarMetadata.refinable,
      mutable, Bool.false_or, show ¬context.declarationCount < index by omega,
      decide_false, Bool.and_false]
  have cell : (context.flow before).scalars index = some (ScalarExpression.binding context.scalarNames index).bounds := by
    rw [context.flow_scalar before (Nat.le_trans bounded base.size)]
    exact compatible.fixed_cell index positive bounded mutable declared
  rw [← context.flow_scalar before (Nat.le_trans bounded base.size),
    ← context.flow_scalar after (Nat.le_trans bounded base.size)]
  exact (statement_preserves_fixed checked readonly fixed cell
    (base.declarationsNonempty index positive declared)).trans cell.symm

private theorem basic_bounded {text context scan item result}
    (bounded : scan.facts.path.Bounded) (parsed : BasicAt (catalog := catalog) text context scan item result) :
    result.facts.path.Bounded := by
  have resultBound := basicBody_factsBounded (catalog := catalog) text context scan bounded
  rw [parsed.equation] at resultBound
  exact resultBound

private theorem branch_meaning {text context scan keyword condition}
    (bodyMode : context.elaborating = false)
    (normal : NamesNormal context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (arraysReady : context.ArraysReady text)
    (nv : Compose.Expressions.ValidNames text context.names)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
    (bounded : scan.facts.path.Bounded) (parsed : BranchAt text context scan keyword condition) :
    condition.Grammatical ∧ condition.Readable context.hasArguments context.names.shape (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
    condition.checkBounds context.names.shape context.analysis (context.flow scan.facts) (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) = true ∧
    (context.flow (branchStart text context scan keyword).1.facts) =
      condition.refine context.names.shape context.analysis (context.flow scan.facts) true ∧
    (context.flow (branchStart text context scan keyword).2) =
      condition.refine context.names.shape context.analysis (context.flow scan.facts) false := by
  have meaning := condition_valid normal nv (by rw [bodyMode]; exact base.toContextReady) arraysReady compatible bounded parsed
  exact ⟨meaning.grammatical, meaning.readable, meaning.checked, meaning.whenTrue, meaning.whenFalse⟩

private theorem branch_compatible {text context scan keyword condition}
    (bodyMode : context.elaborating = false)
    (normal : NamesNormal context.names)
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (arraysReady : context.ArraysReady text)
    (nv : Compose.Expressions.ValidNames text context.names)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
    (bounded : scan.facts.path.Bounded) (parsed : BranchAt text context scan keyword condition) :
    ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount
      (branchStart text context scan keyword).1.facts ∧
    ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount
      (branchStart text context scan keyword).2 := by
  have meaning := condition_valid normal nv (by rw [bodyMode]; exact base.toContextReady) arraysReady compatible bounded parsed
  have counts := condition_counts text context (bodyToken text scan (.word keyword)).position scan.facts
  exact meaning.compatible (by rw [bodyMode]; exact base.toContextReady) compatible
    (counts.1.trans compatible.count) (counts.2.trans compatible.count)

mutual
  theorem statement_meaning {text context scan item result}
      (valid : FunctionBindings.ValidMetadata text catalog)
      (bodyMode : context.elaborating = false)
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (arraysReady : context.ArraysReady text)
      (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : StatementAt (catalog := catalog) text context scan item result) :
      item.WellFormed context.hasArguments context.names.shape (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      item.lower.check (signatures := catalogSignatures catalog) context.names.shape context.analysis (context.flow scan.facts) (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) = some (context.flow result.facts) ∧
      result.facts.path.Bounded := by
    cases parsed with
    | basic _ _ _ reading _ =>
        have meaning := basic_meaning (catalog := catalog) normal base arraysReady booleansBound compatible nv bounded bodyMode valid reading
        exact ⟨meaning.1, meaning.2, basic_bounded (catalog := catalog) bounded reading⟩
    | choice _ _ reading _ => exact choice_meaning valid bodyMode normal base arraysReady booleansBound nv compatible bounded reading
    | loop _ _ _ reading _ => exact loop_meaning valid bodyMode normal base arraysReady booleansBound nv compatible bounded reading
    | arrayLoop _ _ _ reading _ => exact arrayLoop_meaning valid bodyMode normal base arraysReady booleansBound nv compatible bounded reading
  termination_by (bodyRemaining text scan, 2)

  theorem loop_meaning {text context scan lower upper body result}
      (valid : FunctionBindings.ValidMetadata text catalog)
      (bodyMode : context.elaborating = false)
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (arraysReady : context.ArraysReady text)
      (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : LoopAt (catalog := catalog) text context scan lower upper body result) :
      (SourceStatement.forLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
        lower upper body).WellFormed context.hasArguments context.names.shape (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      (SourceStatement.forLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
        lower upper body).lower.check (signatures := catalogSignatures catalog) context.names.shape context.analysis (context.flow scan.facts) (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) =
          some (context.flow result.facts) ∧ result.facts.path.Bounded := by
    cases parsed with
    | loop counted allowed lowerRead upperRead _ bodyRead resultEq _ _ =>
        have space := loopNameAllowed_space base.size allowed
        have bodyGood := body_meaning valid (context := loopInner context (loopHeader text context scan))
          (scan := (loopHeader text context scan).entry) (by simpa only [loopInner] using bodyMode) normal
          (loopInner_baseReady _ base space) (loopInner_arraysReady _ arraysReady)
          (by simpa only [loopInner] using booleansBound) nv (loopHeader_compatible base compatible)
          (loopContext_bounded bounded _) bodyRead
        have factsEq : result.facts = _ := congrArg BodyScan.facts resultEq
        simp only [bodyTokens_facts] at factsEq
        have ranges := context.reading_ranges compatible
        have lowerInferred := lowerRead.inferred
        have upperInferred := upperRead.inferred
        rw [ranges] at lowerInferred upperInferred
        refine ⟨?_, ?_, ?_⟩
        · simp only [SourceStatement.WellFormed]
          exact ⟨by omega, body_nonempty (catalog := catalog) bodyRead, bodyGood.1⟩
        · simp only [SourceStatement.lower, Statement.check, lowerInferred, upperInferred, Option.bind_some]
          have checked := bodyGood.2.1
          simp only [loopInner_flow] at checked
          rw [loopInner_analysis _ base.count space, loopHeader_model bodyMode base.body compatible.count space] at checked
          simp only [LoopHeader.bounds, show (loopHeader text context scan).isArray = false from counted,
            Bool.false_eq_true, ↓reduceIte] at checked
          simp only [loopInner] at checked
          rw [checked]
          simp only [Option.map_some, factsEq, loopAfterHeader_model bodyMode base.body compatible.count,
            show (loopHeader text context scan).isArray = false from counted, Bool.false_eq_true, ↓reduceIte]
        · rw [factsEq]
          exact loopAfterHeader_bounded bounded bodyGood.2.2 _
  termination_by (bodyRemaining text scan, 1)

  theorem arrayLoop_meaning {text context scan body result}
      (valid : FunctionBindings.ValidMetadata text catalog)
      (bodyMode : context.elaborating = false)
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (arraysReady : context.ArraysReady text)
      (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : ArrayLoopAt (catalog := catalog) text context scan body result) :
      (SourceStatement.arrayLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
        (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).descriptor body).WellFormed
          context.hasArguments context.names.shape (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      (SourceStatement.arrayLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
        (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).descriptor body).lower.check (signatures := catalogSignatures catalog)
          context.names.shape context.analysis (context.flow scan.facts) (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) = some (context.flow result.facts) ∧
      result.facts.path.Bounded := by
    cases parsed with
    | loop iterable allowed arrayAllowed _ bodyRead resultEq _ _ =>
        have space := loopNameAllowed_space base.size allowed
        have bodyGood := body_meaning valid (context := loopInner context (loopHeader text context scan))
          (scan := (loopHeader text context scan).entry) (by simpa only [loopInner] using bodyMode) normal
          (loopInner_baseReady _ base space) (loopInner_arraysReady _ arraysReady)
          (by simpa only [loopInner] using booleansBound) nv
          (loopHeader_compatible base compatible) (loopContext_bounded bounded _) bodyRead
        have ready := loopArrayReady bodyMode arraysReady space arrayAllowed
        have innerLow : (loopInner context (loopHeader text context scan)).scalarNames.length ≤ ArrayBindings.scalarLimit := by
          simpa only [loopInner, List.length_append, List.length_singleton] using space
        have apart := body_bindersApart (catalog := catalog) innerLow (arrayBinding_scalar_apart
          (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan))) bodyRead
        have factsEq : result.facts = _ := congrArg BodyScan.facts resultEq
        simp only [bodyTokens_facts] at factsEq
        have isArray : (loopHeader text context scan).isArray = true := iterable
        have components : (loopHeader text context scan).bounds =
            (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).componentBounds := by
          simp only [LoopHeader.bounds, loopHeader, iterable, ↓reduceIte]
        have componentValid := ((arrayLoopReady_iff _ _ _ _).mp ready).2.2.2.2.2
        have nonempty : (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).componentBounds.isEmpty = false := by
          simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not, Int.not_lt]
          exact componentValid.2
        refine ⟨?_, ?_, ?_⟩
        · simp only [SourceStatement.WellFormed]
          exact ⟨by omega, body_nonempty (catalog := catalog) bodyRead, bodyGood.1⟩
        · simp only [SourceStatement.lower, Statement.check, ready, apart, Bool.and_self, ↓reduceIte]
          have checked := bodyGood.2.1
          simp only [loopInner_flow] at checked
          rw [loopInner_analysis _ base.count space, loopHeader_model bodyMode base.body compatible.count space,
            components] at checked
          have entry : loopEntry context.analysis (context.flow scan.facts) (context.scalarNames.length + 1)
              (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).componentBounds =
              arrayLoopEntry context.analysis (context.flow scan.facts) (context.scalarNames.length + 1)
                (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).componentBounds := by
              simp only [loopEntry, arrayLoopEntry, loopContext, nonempty, Bool.false_eq_true, ↓reduceIte]
          rw [entry] at checked
          simp only [loopInner] at checked
          simp only [ArrayBindings.Binding.descriptor] at checked ⊢
          rw [checked]
          simp only [Option.map_some, factsEq, loopAfterHeader_model bodyMode base.body compatible.count,
            isArray, ↓reduceIte]
        · rw [factsEq]
          exact loopAfterHeader_bounded bounded bodyGood.2.2 _
  termination_by (bodyRemaining text scan, 1)

  theorem choice_meaning {text context scan condition yes tail result}
      (valid : FunctionBindings.ValidMetadata text catalog)
      (bodyMode : context.elaborating = false)
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (arraysReady : context.ArraysReady text)
      (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : ChoiceAt (catalog := catalog) text context scan condition yes tail result) :
      (SourceStatement.choice condition yes tail).WellFormed context.hasArguments context.names.shape (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      (SourceStatement.choice condition yes tail).lower.check (signatures := catalogSignatures catalog) context.names.shape context.analysis (context.flow scan.facts) (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) =
        some (context.flow result.facts) ∧ result.facts.path.Bounded := by
    cases parsed with
    | choice conditionRead _ yesRead _ noRead resultEq _ _ =>
        have conditionGood := branch_meaning bodyMode normal base arraysReady nv compatible bounded conditionRead
        have branches := branch_compatible bodyMode normal base arraysReady nv compatible bounded conditionRead
        have yesBound : (branchStart text context scan "if").1.facts.path.Bounded := by
          change (context.flow (branchStart text context scan "if").1.facts).path.Bounded
          rw [conditionGood.2.2.2.1]
          exact Condition.refine_bounded bounded _ _ _ _
        have noBound : (branchStart text context scan "if").2.path.Bounded := by
          change (context.flow (branchStart text context scan "if").2).path.Bounded
          rw [conditionGood.2.2.2.2]
          exact Condition.refine_bounded bounded _ _ _ _
        have yesGood := body_meaning valid bodyMode normal base arraysReady booleansBound nv branches.1 yesBound yesRead
        have noGood := alternative_meaning valid bodyMode normal base arraysReady booleansBound nv branches.2 noBound noRead
        have factsEq : result.facts = _ := congrArg BodyScan.facts resultEq
        simp only [bodyTokens_facts] at factsEq
        refine ⟨?_, ?_, ?_⟩
        · simp only [SourceStatement.WellFormed]
          exact ⟨conditionGood.1, conditionGood.2.1, body_nonempty (catalog := catalog) yesRead, yesGood.1, noGood.1⟩
        · simp only [SourceStatement.lower, Statement.check, conditionGood.2.2.1, ↓reduceIte]
          rw [← conditionGood.2.2.2.1, yesGood.2.1]
          simp only [Option.bind_some]
          rw [← conditionGood.2.2.2.2, noGood.2.1]
          simp only [Option.map_some, factsEq, ParseContext.flow_join]
        · rw [factsEq]
          exact Context.join_bounded yesGood.2.2 noGood.2.2
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_meaning {text context scan tail result}
      (valid : FunctionBindings.ValidMetadata text catalog)
      (bodyMode : context.elaborating = false)
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (arraysReady : context.ArraysReady text)
      (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : AlternativeAt (catalog := catalog) text context scan tail result) :
      tail.WellFormed context.hasArguments context.names.shape (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      checkStatements (signatures := catalogSignatures catalog) context.names.shape context.analysis (context.flow scan.facts) tail.lower (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) = some (context.flow result.facts) ∧
      result.facts.path.Bounded := by
    cases parsed with
    | absent =>
        simp only [SourceAlternative.WellFormed, SourceAlternative.lower, checkStatements]
        exact ⟨trivial, trivial, bounded⟩
    | otherwise _ _ _ _ body _ =>
        have good := body_meaning valid (scan := bodyToken text scan (.word "else")) bodyMode normal base arraysReady booleansBound nv compatible bounded body
        simp only [SourceAlternative.WellFormed, SourceAlternative.lower]
        exact ⟨⟨body_nonempty (catalog := catalog) body, good.1⟩, good.2⟩
    | elsif _ _ conditionRead _ yesRead _ noRead resultEq _ _ =>
        have conditionGood := branch_meaning bodyMode normal base arraysReady nv compatible bounded conditionRead
        have branches := branch_compatible bodyMode normal base arraysReady nv compatible bounded conditionRead
        have yesBound : (branchStart text context scan "elsif").1.facts.path.Bounded := by
          change (context.flow (branchStart text context scan "elsif").1.facts).path.Bounded
          rw [conditionGood.2.2.2.1]
          exact Condition.refine_bounded bounded _ _ _ _
        have noBound : (branchStart text context scan "elsif").2.path.Bounded := by
          change (context.flow (branchStart text context scan "elsif").2).path.Bounded
          rw [conditionGood.2.2.2.2]
          exact Condition.refine_bounded bounded _ _ _ _
        have yesGood := body_meaning valid bodyMode normal base arraysReady booleansBound nv branches.1 yesBound yesRead
        have noGood := alternative_meaning valid bodyMode normal base arraysReady booleansBound nv branches.2 noBound noRead
        have factsEq : result.facts = _ := congrArg BodyScan.facts resultEq
        refine ⟨?_, ?_, ?_⟩
        · simp only [SourceAlternative.WellFormed]
          exact ⟨conditionGood.1, conditionGood.2.1, body_nonempty (catalog := catalog) yesRead, yesGood.1, noGood.1⟩
        · simp only [SourceAlternative.lower, checkStatements, Statement.check, conditionGood.2.2.1, ↓reduceIte]
          rw [← conditionGood.2.2.2.1, yesGood.2.1]
          simp only [Option.bind_some]
          rw [← conditionGood.2.2.2.2, noGood.2.1]
          simp only [Option.map_some, Option.bind_some, factsEq, ParseContext.flow_join]
        · rw [factsEq]
          exact Context.join_bounded yesGood.2.2 noGood.2.2
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_meaning {text context stop scan items result}
      (valid : FunctionBindings.ValidMetadata text catalog)
      (bodyMode : context.elaborating = false)
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (arraysReady : context.ArraysReady text)
      (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : BodyTailAt (catalog := catalog) text context stop scan items result) :
      SourceStatementsWellFormed context.hasArguments context.names.shape items (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      checkStatements (signatures := catalogSignatures catalog) context.names.shape context.analysis (context.flow scan.facts) (lowerStatements items) (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) =
        some (context.flow result.facts) ∧ result.facts.path.Bounded := by
    cases parsed with
    | done =>
        simp only [SourceStatementsWellFormed, lowerStatements, checkStatements]
        exact ⟨trivial, trivial, bounded⟩
    | next _ _ item _ rest _ =>
        have first := statement_meaning valid bodyMode normal base arraysReady booleansBound nv compatible bounded item
        have count := statementBody_count (catalog := catalog) text context scan compatible.count
        rw [statement_complete (catalog := catalog) item] at count
        have nextCompatible := checked_statement_compatible base compatible first.2.1 count
        have following := bodyTail_meaning valid bodyMode normal base arraysReady booleansBound nv nextCompatible first.2.2 rest
        simp only [SourceStatementsWellFormed]
        refine ⟨⟨first.1, following.1⟩, ?_, following.2.2⟩
        simp only [lowerStatements, checkStatements, first.2.1, Option.bind_some, following.2.1]
  termination_by (bodyRemaining text scan, 3)

  theorem body_meaning {text context stop scan items result}
      (valid : FunctionBindings.ValidMetadata text catalog)
      (bodyMode : context.elaborating = false)
      (normal : NamesNormal context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (arraysReady : context.ArraysReady text)
      (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
      (nv : Compose.Expressions.ValidNames text context.names)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount scan.facts)
      (bounded : scan.facts.path.Bounded) (parsed : BodyAt (catalog := catalog) text context scan stop items result) :
      SourceStatementsWellFormed context.hasArguments context.names.shape items (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) ∧
      checkStatements (signatures := catalogSignatures catalog) context.names.shape context.analysis (context.flow scan.facts) (lowerStatements items) (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) =
        some (context.flow result.facts) ∧ result.facts.path.Bounded := by
    cases parsed with
    | cons item _ rest _ =>
        have first := statement_meaning valid bodyMode normal base arraysReady booleansBound nv compatible bounded item
        have count := statementBody_count (catalog := catalog) text context scan compatible.count
        rw [statement_complete (catalog := catalog) item] at count
        have nextCompatible := checked_statement_compatible base compatible first.2.1 count
        have following := bodyTail_meaning valid bodyMode normal base arraysReady booleansBound nv nextCompatible first.2.2 rest
        simp only [SourceStatementsWellFormed]
        refine ⟨⟨first.1, following.1⟩, ?_, following.2.2⟩
        simp only [lowerStatements, checkStatements, first.2.1, Option.bind_some, following.2.1]
  termination_by (bodyRemaining text scan, 3)
end

theorem basicKind_closed {text context scan} (closed : ClosedFunctionContext context) :
    basicKind text context scan = .null ∨ basicKind text context scan = .scalarAssignment ∨
      basicKind text context scan = .booleanAssignment ∨ basicKind text context scan = .assignment := by
  unfold basicKind
  simp only [closed.pure, closed.noArguments, Bool.not_true, Bool.false_and,
    Bool.false_eq_true, ↓reduceIte]
  repeat' split <;> simp_all

theorem basic_source_scalar {text context scan item result}
    (closed : ClosedFunctionContext context)
    (parsed : BasicAt (catalog := catalog) text context scan item result) :
    ScalarFunctions.pureStatement item.lower = true ∧
      ScalarFunctions.scalarStatement item.lower = true := by
  have kinds := basicKind_closed (text := text) (scan := scan) closed
  cases parsed.payload with
  | null => simp only [SourceStatement.lower, ScalarFunctions.pureStatement,
      ScalarFunctions.scalarStatement, and_self]
  | output kind | put kind | reject kind | arrayAssignment kind | booleanArrayAssignment kind =>
      rcases kinds with allowed | allowed | allowed | allowed <;> simp_all
  | scalarCallAssignment _ reading | booleanCallAssignment _ reading =>
      simp only [SourceStatement.lower, ScalarFunctions.pureStatement,
        ScalarFunctions.scalarStatement, actuals_source_scalar closed reading.call.actuals, and_self]
  | scalarAssignment _ _ reading =>
      rw [closed.noArrays] at reading
      simp only [SourceStatement.lower, ScalarFunctions.pureStatement,
        ScalarFunctions.scalarStatement, scalarExpression_source_scalar reading, and_self]
  | booleanAssignment _ _ reading =>
      simp only [SourceStatement.lower, ScalarFunctions.pureStatement,
        ScalarFunctions.scalarStatement, condition_source_scalar closed reading, and_self]
  | assignment kind _ =>
      have raw := basic_raw_positive (catalog := catalog) (parsed.equation ▸ parsed.positive)
      simp [basicRaw, kind, closed.pure, invalidBody] at raw

theorem ClosedFunctionContext.loopInner {context : ParseContext}
    (closed : ClosedFunctionContext context) (header : LoopHeader) :
    ClosedFunctionContext (loopInner context header) :=
  ⟨closed.pure, closed.noArguments, closed.noNames, closed.noArrays⟩

mutual
  theorem statement_source_scalar {text context scan item result}
      (closed : ClosedFunctionContext context)
      (parsed : StatementAt (catalog := catalog) text context scan item result) :
      ScalarFunctions.pureStatement item.lower = true ∧
        ScalarFunctions.scalarStatement item.lower = true := by
    cases parsed with
    | basic _ _ _ reading _ => exact basic_source_scalar closed reading
    | choice _ _ reading _ => exact choice_source_scalar closed reading
    | loop _ _ _ reading _ => exact loop_source_scalar closed reading
    | arrayLoop _ _ _ reading _ =>
        cases reading with
        | loop _ _ allowed _ _ _ _ _ =>
            have emptyTarget : loopArrayTarget text context scan = 0 := by
              simp only [loopArrayTarget, arrayTarget, closed.noArrays, ArrayBindings.lookup,
                List.length_nil, ArrayBindings.lookupFrom]
              split <;> rfl
            simp [loopArrayAllowed, emptyTarget] at allowed
  termination_by (bodyRemaining text scan, 2)

  theorem loop_source_scalar {text context scan lower upper body result}
      (closed : ClosedFunctionContext context)
      (parsed : LoopAt (catalog := catalog) text context scan lower upper body result) :
      ScalarFunctions.pureStatement (SourceStatement.forLoop (context.scalarNames.length + 1)
        (loopHeader text context scan).reverse lower upper body).lower = true ∧
      ScalarFunctions.scalarStatement (SourceStatement.forLoop (context.scalarNames.length + 1)
        (loopHeader text context scan).reverse lower upper body).lower = true := by
    cases parsed with
    | loop _ _ lowerRead upperRead _ bodyRead _ _ _ =>
        have good := body_source_scalar (closed.loopInner _) bodyRead
        rw [closed.noArrays] at lowerRead upperRead
        exact ⟨by simpa only [SourceStatement.lower, ScalarFunctions.pureStatement] using good.1,
          by simp only [SourceStatement.lower, ScalarFunctions.scalarStatement,
          scalarExpression_source_scalar lowerRead, scalarExpression_source_scalar upperRead,
          good.2, Bool.and_self]⟩
  termination_by (bodyRemaining text scan, 1)

  theorem choice_source_scalar {text context scan condition yes tail result}
      (closed : ClosedFunctionContext context)
      (parsed : ChoiceAt (catalog := catalog) text context scan condition yes tail result) :
      ScalarFunctions.pureStatement (SourceStatement.choice condition yes tail).lower = true ∧
        ScalarFunctions.scalarStatement (SourceStatement.choice condition yes tail).lower = true := by
    cases parsed with
    | choice conditionRead _ yesRead _ noRead _ _ _ =>
        have yesGood := body_source_scalar closed yesRead
        have noGood := alternative_source_scalar closed noRead
        simp only [SourceStatement.lower, ScalarFunctions.pureStatement,
          ScalarFunctions.scalarStatement, condition_source_scalar closed conditionRead,
          yesGood.1, yesGood.2, noGood.1, noGood.2, Bool.and_self, and_self]
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_source_scalar {text context scan tail result}
      (closed : ClosedFunctionContext context)
      (parsed : AlternativeAt (catalog := catalog) text context scan tail result) :
      ScalarFunctions.pureStatements tail.lower = true ∧
        ScalarFunctions.scalarStatements tail.lower = true := by
    cases parsed with
    | absent => simp only [SourceAlternative.lower, ScalarFunctions.pureStatements,
        ScalarFunctions.scalarStatements, and_self]
    | otherwise _ _ _ _ bodyRead _ =>
        simpa only [SourceAlternative.lower] using body_source_scalar closed bodyRead
    | elsif _ _ conditionRead _ yesRead _ noRead _ _ _ =>
        have yesGood := body_source_scalar closed yesRead
        have noGood := alternative_source_scalar closed noRead
        simp only [SourceAlternative.lower, ScalarFunctions.pureStatements,
          ScalarFunctions.scalarStatements, ScalarFunctions.pureStatement,
          ScalarFunctions.scalarStatement, condition_source_scalar closed conditionRead,
          yesGood.1, yesGood.2, noGood.1, noGood.2, Bool.and_self, and_self]
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_source_scalar {text context stop scan items result}
      (closed : ClosedFunctionContext context)
      (parsed : BodyTailAt (catalog := catalog) text context stop scan items result) :
      ScalarFunctions.pureStatements (lowerStatements items) = true ∧
        ScalarFunctions.scalarStatements (lowerStatements items) = true := by
    cases parsed with
    | done => simp only [lowerStatements, ScalarFunctions.pureStatements,
        ScalarFunctions.scalarStatements, and_self]
    | next _ _ itemRead _ restRead _ =>
        have first := statement_source_scalar closed itemRead
        have rest := bodyTail_source_scalar closed restRead
        simp only [lowerStatements, ScalarFunctions.pureStatements, ScalarFunctions.scalarStatements,
          first.1, first.2, rest.1, rest.2, Bool.and_self, and_self]
  termination_by (bodyRemaining text scan, 3)

  theorem body_source_scalar {text context scan stop items result}
      (closed : ClosedFunctionContext context)
      (parsed : BodyAt (catalog := catalog) text context scan stop items result) :
      ScalarFunctions.pureStatements (lowerStatements items) = true ∧
        ScalarFunctions.scalarStatements (lowerStatements items) = true := by
    cases parsed with
    | cons itemRead _ restRead _ =>
        have first := statement_source_scalar closed itemRead
        have rest := bodyTail_source_scalar closed restRead
        simp only [lowerStatements, ScalarFunctions.pureStatements, ScalarFunctions.scalarStatements,
          first.1, first.2, rest.1, rest.2, Bool.and_self, and_self]
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
