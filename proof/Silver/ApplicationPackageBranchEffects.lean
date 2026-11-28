module

public import Silver.ApplicationPackageInheritedEffects
public import Silver.ApplicationPackageRecursiveMasks
public import Silver.ApplicationPackageEffectsImports
public import Silver.ProcedureNamePunctuation

@[expose] public section

namespace Silver.ApplicationPackageSourceEffects
open Compose Predicate Packages ApplicationPackages ApplicationPackageCalls
open ApplicationPackageFrameLayout ApplicationPackageBodies ApplicationPackageBodies.SourceSyntax
open ApplicationPackageBodies.Recursive ApplicationPackageEffects

set_option backward.dsimp.instances true
attribute [local irreducible] PackageBindings.stateUnion readCountedBound ScalarExpression.ArrayAttributes.read

/-- Exact imported effect-helper equations on their native domains. These
contain no semantic effect coverage or accepted-program proposition. -/
structure ReaderEffects (readers : Readers) : Prop where
  target : ∀ text context info position, Expressions.ValidText text →
    ApplicationPackageEffects.LookupDomain text context → position ≤ text.length + 1 →
    readers.basic.stateTarget text context info position =
      ApplicationPackageEffects.stateTarget ApplicationPackageEffects.modelCalls text context info position
  basic : ∀ text context info first after, Expressions.ValidText text →
    ApplicationPackageEffects.LookupDomain text context → first ≤ text.length + 1 → after ≤ text.length + 1 →
    readers.basic.stateReads text context info first after =
      ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls text context info first after
  statement : ∀ text context info first after, Expressions.ValidText text →
    ApplicationPackageEffects.LookupDomain text context → first ≤ text.length + 1 → after ≤ text.length + 1 →
    readers.statement.stateReads text context info first after =
      ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls text context info first after

theorem native_lookup {source : Statement.Input} (legal : NativeDomain source) :
    ApplicationPackageEffects.LookupDomain source.text source.context := by
  obtain ⟨native, same, valid⟩ := legal.context
  exact same ▸ ApplicationPackageEffects.LookupDomain.of_native valid

private theorem condition_start {text context position facts condition result initials}
    (reading : ConditionAt text context position facts condition result initials) : position ≠ 0 := by
  cases reading with
  | condition _ relation _ _ _ => cases relation <;> assumption

/-- Every original IF/ELSIF guard is recorded before its child body. -/
theorem condition_effects {readers : Readers} (imports : ReaderEffects readers)
    {source : Statement.Input} {before : Statement.Arms} {condition : Condition} {bound : Nat}
    (legal : NativeDomain (atInput source before.value))
    (declarations : StateDeclarations source.text source.info.states)
    (guard : ConditionAt source.text source.context before.value.scan.position before.value.scan.facts
      condition (Statement.conditionFor (sourceReaders readers).statement source before)) :
    EffectSummaries.Included (directEffects (layout bound source.info source.context) (conditionReads condition) [])
      (scanEffects source.info (Statement.thenInput (sourceReaders readers).statement source before
        (Statement.conditionFor (sourceReaders readers).statement source before))) := by
  obtain ⟨native, same, valid⟩ := legal.context
  have names : Expressions.ValidNames source.text source.context.names := same ▸ valid.1
  have endBound : (Statement.conditionFor (sourceReaders readers).statement source before).after ≤ source.text.length + 1 :=
    condition_bound source.text source.context before.value.scan.position before.value.scan.facts
      legal.text names legal.scan.position
  have capacity : source.info.states.length ≤ PackageBindings.maxStates := legal.typed.2.2.2.2.1
  have lookup := native_lookup legal
  constructor
  · intro cell member
    apply union_right capacity _ _ cell
    change cell ∈ source.info.effectCells (readers.statement.stateReads _ _ _ _ _)
    rw [imports.statement source.text source.context source.info before.value.scan.position
      (Statement.conditionFor (sourceReaders readers).statement source before).after
      legal.text ⟨lookup.scalars, lookup.booleans⟩ legal.scan.position endBound]
    exact condition_global_reads guard (condition_start guard) legal.scan.position (Nat.le_refl _)
      declarations capacity legal.base.size (same ▸ valid.booleans.1) cell member
  · intro cell member
    simp only [directEffects, globalCells, List.filterMap_nil, List.not_mem_nil] at member

/-- Traversing the lower expression and the exact range delimiter carries the
native name scan to the upper expression. A counted header records both sides. -/
theorem counted_global_reads {text : Source} {context : ParseContext} {scan : BodyScan}
    {info : PackageBindings.Metadata} {bound limit : Nat} {lower upper : Integer.Expr}
    (source : LoopBoundsAt text context scan lower upper)
    (counted : loopIsArray text scan = false)
    (positive : (loopHeader text context scan).entry.position ≠ 0)
    (finishBound : (loopHeader text context scan).entry.position ≤ limit)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit) :
    ∀ cell ∈ globalCells (layout bound info context) (integerReads lower ++ integerReads upper),
      cell ∈ info.effectCells (ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls
        text context info (loopLowerPosition text scan) limit) := by
  cases source with
  | range reading =>
      intro cell member
      simp only [integerReads, List.nil_append, globalCells, List.filterMap_nil, List.not_mem_nil] at member
  | counted absent low high =>
      have lowBounds := low.cursorBounds
      have highBounds := high.cursorBounds
      have following : (loopHeader text context scan).entry.position =
          fixedAfter text (loopHeader text context scan).upper.after "loop" true := by
        simp only [loopHeader, counted, Bool.false_eq_true, ite_false, absent, ne_self_iff_false]
      have delimiter := Expressions.model_fixed_advances text (loopHeader text context scan).lower.after
        ".." false lowBounds.2.2 (by decide) (Nat.ne_of_gt highBounds.1)
      have final := Expressions.model_fixed_advances text (loopHeader text context scan).upper.after
        "loop" true highBounds.2.2 (by decide) (following ▸ positive)
      have lowerFinish : (loopHeader text context scan).lower.after ≤ limit := by omega
      have upperFinish : (loopHeader text context scan).upper.after ≤ limit := by omega
      intro cell member
      obtain ⟨localCell, used, placed⟩ := globalCells_mem.mp member
      cases localCell with
      | boolean slot =>
          rcases List.mem_append.mp used with used | used
          · exact (integerReads_no_boolean _ _ used).elim
          · exact (integerReads_no_boolean _ _ used).elim
      | integer slot =>
          cases selected : (layout bound info context).integers slot with
          | «local» _ => simp only [FrameLayout.place, selected] at placed; contradiction
          | global identity =>
              have cellEq : cell = .integer identity := by
                simpa only [FrameLayout.place, selected, Place.global.injEq] using placed.symm
              subst cell
              have live := slotAddress_global selected
              have same := stateIndex_some live.2.2
              rw [scalarRows_get] at same
              dsimp only at same
              have name := declarations.name same.1 same.2.1
              have domain := (ApplicationPackageNames.Native.validName_domain name).2
              have row : OriginalRow context (.integer slot) :=
                ⟨Nat.ne_of_gt live.1, by simpa only [scalarRows, List.length_map] using live.2.1,
                  same.2.2.1, by rw [← same.2.2.2.2.1]; exact Nat.ne_of_gt domain.1,
                  by rw [← same.2.2.2.2.1, ← same.2.2.2.2.2]; exact domain.2.1⟩
              have found : ScalarExpression.lookup text context.scalarNames
                  (info.stateAt identity).name.first (info.stateAt identity).name.after = slot := by
                have original : OriginalLookup text context (.integer slot) := by
                  rcases List.mem_append.mp used with used | used
                  · exact scalar_original_in_flow low.source row used
                  · exact scalar_original_in_flow high.source row used
                change ScalarExpression.lookup text context.scalarNames _ _ = slot at original
                simpa only [same.2.2.2.2.1, same.2.2.2.2.2] using original
              have visible : ApplicationPackageEffects.visibleState ApplicationPackageEffects.modelCalls text context info identity = true := by
                simp [ApplicationPackageEffects.visibleState, ApplicationPackageEffects.modelCalls,
                  Nat.not_lt.mpr same.2.1, name, same.2.2.2.1, found, row.1,
                  same.2.2.2.2.1.symm, same.2.2.2.2.2.symm]
              have occurrence : actualNameFree text (loopLowerPosition text scan) limit
                  (info.stateAt identity).name.first (info.stateAt identity).name.after = false := by
                apply Bool.eq_false_iff.mpr
                intro free
                have overlay : ScalarExpression.lookup text (context.readingNames scan.facts)
                    (info.stateAt identity).name.first (info.stateAt identity).name.after = slot := by
                  simpa only [ParseContext.readingNames, ScalarMetadata.readingNames_lookup] using found
                have first := (actualNameFree_sound free).scalar low lowerFinish overlay
                  (Nat.le_trans row.2.1 scalarCapacity)
                have range := first.2.fixedRange lowBounds.2.2 (Nat.ne_of_gt highBounds.1) (by omega)
                have second := range.scalar high upperFinish overlay (Nat.le_trans row.2.1 scalarCapacity)
                rcases List.mem_append.mp used with used | used
                · have missing := first.1
                  rw [integerReads_integer _ _ used] at missing
                  contradiction
                · have missing := second.1
                  rw [integerReads_integer _ _ used] at missing
                  contradiction
              have covered := (ApplicationPackageEffects.stateReads_cell ApplicationPackageEffects.modelCalls
                text context info (loopLowerPosition text scan) limit identity same.1 same.2.1
                (Nat.le_trans same.2.1 capacity)).mpr ⟨by omega, visible, occurrence⟩
              simpa only [PackageBindings.StateDeclaration.cell, same.2.2.2.1] using covered

private theorem counted_start (calls : Statement.Calls) (source : Statement.Input)
    (counted : loopIsArray source.text source.input.scan = false) :
    Statement.afterReverse (Statement.loopHeaderReaders calls) source.text
      ((Statement.loopHeaderReaders calls).takeToken source.text (loopNameAfter source.text source.input.scan) (.word "in")) =
      loopLowerPosition source.text source.input.scan := by
  unfold Statement.afterReverse loopLowerPosition loopReverse loopInAfter
  simp only [counted, Bool.false_eq_true, ite_false, Statement.loopHeaderReaders, tokenAfter, ShellToken.word]
  by_cases reverse : fixedAfter source.text
      (fixedAfter source.text (loopNameAfter source.text source.input.scan) "in" true) "reverse" true = 0
  all_goals simp [reverse]

theorem counted_masks {calls : Statement.Calls} {source : Statement.Input} {iteration : Statement.Iteration}
    (counted : loopIsArray source.text source.input.scan = false)
    (parsed : Statement.forHeader (Statement.loopHeaderReaders calls) source
      (tokenAfter source.text source.input.scan.position (.word "for")) = some iteration) :
    iteration.value.reads = PackageBindings.stateUnion source.input.reads
      (calls.stateReads source.text
        {source.context with maskFirst := iteration.first, maskAfter := iteration.last}
        source.info (loopLowerPosition source.text source.input.scan) iteration.value.scan.position) := by
  rw [Statement.forHeader_counted (calls := calls) counted parsed]
  dsimp only [Statement.originalCountedHeader, Statement.countedHeader]
  rw [counted_start calls source counted]
  split <;> rfl

/-- Both original counted bounds are included before the body, and the fresh
loop binder is a local cell rather than a package-state write. -/
theorem counted_effects {readers : Readers} (imports : ReaderEffects readers)
    {source : Statement.Input} {iteration : Statement.Iteration} {result : ApplicationScan}
    {lower upper : Integer.Expr} {bound : Nat}
    (legal : NativeDomain source) (scope : PackageScope source)
    (header : Statement.IterationReading (sourceReaders readers).statement source
      ((sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for")) iteration result)
    (counted : loopIsArray source.text source.input.scan = false)
    (bounds : LoopBoundsAt source.text source.context source.input.scan lower upper) :
    EffectSummaries.Included
      (directEffects (layout bound source.info source.context) (integerReads lower ++ integerReads upper)
        [.integer (source.context.scalarNames.length + 1)])
      (scanEffects source.info iteration.value) := by
  have positions := Statement.countedHeader_positions
    {readers.statement with
      readCondition := fun text context position facts => readCondition text context position facts
      joinInto := ActiveFlow.join} source counted
  have original := Statement.forHeader_counted counted header.header
  have endEq : iteration.value.scan.position = (loopHeader source.text source.context source.input.scan).entry.position := by
    rw [original]
    exact positions.2.2.1
  have endBound : iteration.value.scan.position ≤ source.text.length + 1 := by
    rw [endEq]
    exact loopHeader_bound _ _ _
  have capacity : source.info.states.length ≤ PackageBindings.maxStates := legal.typed.2.2.2.2.1
  have lookup := native_lookup legal
  have mask := counted_masks counted header.header
  constructor
  · intro cell member
    change cell ∈ source.info.effectCells iteration.value.reads
    rw [mask]
    apply union_right capacity _ _ cell
    change cell ∈ source.info.effectCells (readers.statement.stateReads _ _ _ _ _)
    rw [imports.statement source.text
      {source.context with maskFirst := iteration.first, maskAfter := iteration.last}
      source.info (loopLowerPosition source.text source.input.scan) iteration.value.scan.position
      legal.text ⟨lookup.scalars, lookup.booleans⟩ (loopLowerPosition_bound _ _) endBound]
    change cell ∈ source.info.effectCells (ApplicationPackageEffects.stateReads
      ApplicationPackageEffects.modelCalls source.text source.context source.info _ _)
    exact counted_global_reads bounds counted (by
      rw [← endEq]
      exact Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) header.advances))
      (Nat.le_of_eq endEq.symm) scope.declarations capacity legal.base.size cell member
  · intro cell member
    change cell ∈ globalCells (layout bound source.info source.context)
      [.integer (source.context.scalarNames.length + 1)] at member
    have absent : ¬(0 < source.context.scalarNames.length + 1 ∧
        source.context.scalarNames.length + 1 ≤ (scalarRows source.context).length) := by
      simp only [scalarRows, List.length_map]
      omega
    simp only [globalCells, List.filterMap_cons, List.filterMap_nil, FrameLayout.place,
      layout, slotAddress, absent, ite_false] at member
    contradiction

end Silver.ApplicationPackageSourceEffects
