module

public import Silver.ApplicationPackageBranchEffects

@[expose] public section

namespace Silver.ApplicationPackageSourceEffects
open Compose Predicate Packages Packages.EffectSummaries ApplicationPackages ApplicationPackageCalls
open ApplicationPackageFrameLayout ApplicationPackageBodies ApplicationPackageBodies.SourceSyntax
open ApplicationPackageBodies.Recursive

set_option backward.dsimp.instances true
attribute [local irreducible] PackageBindings.stateUnion packageCallAt

def EffectBound (bound : Nat) (source : Statement.Input) (code : List Predicate.Statement)
    (summary : Effects) : Prop :=
  ∀ effects, inferStatementsEffects (completedEnvironment source.info) (layout bound source.info source.context)
    code = some effects → Included effects summary

private theorem nil_bound (bound : Nat) (source : Statement.Input) (summary : Effects) :
    EffectBound bound source [] summary := by
  intro effects inferred
  simp only [inferStatementsEffects, Option.some.injEq] at inferred
  subst effects
  exact ⟨fun _ member => False.elim (List.not_mem_nil member),
    fun _ member => False.elim (List.not_mem_nil member)⟩

theorem inference_singleton (earlier : EffectEnvironment) (frame : FrameLayout) (item : Predicate.Statement) :
    inferStatementsEffects earlier frame [item] = inferStatementEffects earlier frame item := by
  simp only [inferStatementsEffects]
  cases found : inferStatementEffects earlier frame item with
  | none => rfl
  | some effects =>
    simp only [Option.bind_some, Option.map_some]
    cases effects
    simp only [Effects.merge, List.append_nil]

private theorem basic_returned {calls names source result item}
    (original : BasicCodeAt calls names source result item) :
    applicationBasic calls source.text source.context source.input source.info source.catalog source.procedures = result := by
  cases original <;> assumption

structure BodyEffects (bound : Nat) (source : Statement.Input) (result : ApplicationScan)
    (code : List Predicate.Statement) : Prop where
  legal : NativeDomain (atInput source result)
  width : result.MaskWidth
  progress : source.input.scan.position ≤ result.scan.position
  incoming : Included (scanEffects source.info source.input) (scanEffects source.info result)
  effects : EffectBound bound source code (scanEffects source.info result)

structure ArmsEffects (bound : Nat) (source : Statement.Input) (before after : Statement.Arms)
    (code : List Statement.ArmCode) : Prop where
  legal : ArmsDomain source after
  width : after.value.MaskWidth
  progress : before.value.scan.position ≤ after.value.scan.position
  incoming : Included (scanEffects source.info before.value) (scanEffects source.info after.value)
  effects : ∀ alternative summary, EffectBound bound source alternative summary →
    Included (scanEffects source.info after.value) summary →
    EffectBound bound source (Statement.lowerArms code alternative) summary

/-- Every original recursive body retains all inferred effects. Native field
and lookup domains, source declaration order, masks and loop layouts are derived
through the same original branch tree; no child effect coverage is assumed. -/
theorem original_body_effects {readers : Readers} (imports : ReaderEffects readers)
    {source : Statement.Input} {stop : BodyStop} {required seen : Bool} {result : ApplicationScan}
    {code : List Predicate.Statement} (bound : Nat)
    (original : TailCodeAt (sourceReaders readers) packageNames source stop required seen result code)
    (legal : NativeDomain source) (scope : PackageScope source) (width : source.input.MaskWidth) :
    BodyEffects bound source result code := by
  apply TailCodeAt.rec
    (motive_1 := fun source result code _ => NativeDomain source → PackageScope source →
      source.input.MaskWidth → BodyEffects bound source result code)
    (motive_2 := fun source before after code _ => ArmsDomain source before →
      PackageScope (atInput source before.value) → before.value.MaskWidth → ArmsEffects bound source before after code)
    (motive_3 := fun source state code _ => ArmsDomain source state →
      PackageScope (atInput source state.value) → state.value.MaskWidth →
      BodyEffects bound (atInput source state.value) (Statement.elseResult (sourceReaders readers).statement source state) code)
    (motive_4 := fun source _ _ _ result code _ => NativeDomain source → PackageScope source →
      source.input.MaskWidth → BodyEffects bound source result code)
    ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ original legal scope width
  · intro source result item _ _ _ _ accepted reading legal scope width
    have returned := basic_returned reading
    have normal : nativeBasicReaders (sourceReaders readers).basic = (sourceReaders readers).basic := rfl
    have native := native_basic_contract (calls := (sourceReaders readers).basic) legal legal.typed
    rw [normal] at native
    rw [returned] at native
    have resultWidth := native_basic_mask_width (sourceReaders readers).basic source width
    rw [normal, returned] at resultWidth
    have capacity : source.info.states.length ≤ PackageBindings.maxStates := legal.typed.2.2.2.2.1
    have incoming := NativeMasks.basic_incoming (sourceReaders readers).basic source capacity rfl
    rw [returned] at incoming
    refine ⟨legal.replaceInput native.1, resultWidth,
      Nat.le_of_lt (native.2.2.2.resolve_left accepted), incoming, ?_⟩
    intro effects inferred
    rw [inference_singleton] at inferred
    have startBound : scalarAssignmentStart source.text source.input.scan ≤ source.text.length + 1 :=
      fixedAfter_result_bound source.text _ ":=" false (by decide)
    exact BasicMasks.basic_effects reading accepted legal scope (by rw [width.2]; exact capacity) inferred
      (imports.target source.text source.context source.info source.input.scan.position
        legal.text (native_lookup legal) legal.scan.position)
      (imports.basic source.text source.context source.info (scalarAssignmentStart source.text source.input.scan)
        result.scan.position legal.text (native_lookup legal) startBound native.1.position)
  · intro source state result codes alternative _ keyword _ _ closing armsIH elseIH legal scope width
    have first := Expressions.model_fixed_advances source.text source.input.scan.position "if" true
      legal.scan.position (by decide) keyword
    have arms := armsIH (ArmsDomain.initial legal) (scope.atInput _ (Nat.le_of_lt first)) width
    have afterScope := (scope.atInput _ (Nat.le_of_lt first)).atInput state.value arms.progress
    have alternate := elseIH arms.legal afterScope arms.width
    have same : scanEffects source.info result =
        scanEffects source.info (Statement.elseResult (sourceReaders readers).statement source state) := by
      rw [closing.resultEq]; rfl
    refine ⟨legal.replaceInput (closing_scan_domain arms.legal alternate.legal.scan closing),
      ?_, Nat.le_of_lt closing.advances, ?_, ?_⟩
    · rw [closing.resultEq]; exact alternate.width
    · rw [same]; exact arms.incoming.trans alternate.incoming
    · rw [same]
      exact arms.effects alternative _ alternate.effects alternate.incoming
  · intro source iteration result lower upper body _ _ _ header kind bounds _ insideIH legal scope width
    have inner := insideIH (legal.loopInput header.header header.advances) (scope.loop legal header)
      (forHeader_mask_width width header.header)
    have binder := Statement.forHeader_binder_after legal.scan.position header.header
    have fresh : ∀ state ∈ source.info.states, iteration.first ≠ state.name.first := by
      intro state member
      exact Nat.ne_of_gt (Nat.lt_trans (scope.statesBefore state member) binder)
    have agreement := inner_global_agreement bound fresh
    have same : scanEffects source.info result =
        scanEffects source.info (Statement.loopResult (sourceReaders readers).statement source iteration) := by
      rw [header.resultEq]; rfl
    have capacity : source.info.states.length ≤ PackageBindings.maxStates := legal.typed.2.2.2.2.1
    refine ⟨legal.replaceInput (loop_scan_domain legal header inner.legal.scan), ?_,
      Nat.le_of_lt header.resultAdvances, ?_, ?_⟩
    · rw [header.resultEq]; exact inner.width
    · rw [same]
      exact (NativeMasks.header_incoming capacity header.header).trans inner.incoming
    · intro effects inferred
      rw [inference_singleton] at inferred
      simp only [inferStatementEffects, Option.map_eq_some_iff] at inferred
      obtain ⟨insideEffects, found, rfl⟩ := inferred
      have child : inferStatementsEffects (completedEnvironment source.info)
          (layout bound source.info (Statement.innerContext source iteration)) body = some insideEffects := by
        rw [statements_effects_agree agreement]
        exact found
      rw [same]
      exact ((counted_effects imports legal scope header kind bounds).trans inner.incoming).merge_bound
        (inner.effects _ child)
  · intro source iteration result body _ _ _ header kind _ _ legal scope width
    have impure := (Statement.arrayHeader_accepted (Statement.forHeader_array kind header.header)).1
    rw [scope.pure] at impure
    contradiction
  · intro source before read after condition body parsed guard _ finished insideIH legal scope width
    have observed := Statement.readArm_evaluation parsed
    have entry := legal.value.thenInput (calls := (sourceReaders readers).statement) rfl rfl
    have inner := insideIH entry (scope.atInput _ (Nat.le_of_lt observed.thenAdvanced))
      (thenInput_mask_width _ _ _ _ width)
    have step : Statement.armState (Statement.finishArm (sourceReaders readers).statement source read) = some after := by
      rw [finished]; rfl
    have advance := finishArm_position parsed (Nat.lt_of_lt_of_le observed.thenAdvanced inner.progress) step
    have same := NativeMasks.arm_masks step
    have capacity : source.info.states.length ≤ PackageBindings.maxStates := legal.value.typed.2.2.2.2.1
    refine ⟨legal.finish parsed inner.legal.scan step, finishArm_mask_width inner.width step,
      Nat.le_of_lt advance, ?_, ?_⟩
    · rw [same]
      exact (NativeMasks.then_incoming _ _ _ _ capacity).trans inner.incoming
    · intro alternative summary otherwiseBound afterBound effects inferred
      simp only [Statement.lowerArms, inference_singleton, inferStatementEffects,
        Option.bind_eq_some_iff, Option.map_eq_some_iff] at inferred
      obtain ⟨left, first, right, later, rfl⟩ := inferred
      have toSummary : Included (scanEffects source.info read.branch) summary := by
        rw [← same]; exact afterBound
      exact (((condition_effects imports legal.value scope.declarations guard).trans inner.incoming).trans toSummary).merge_bound
        ((inner.effects _ first).trans toSummary |>.merge_bound (otherwiseBound _ later))
  · intro source before read after final condition body rest parsed guard _ continued _ insideIH restIH legal scope width
    have observed := Statement.readArm_evaluation parsed
    have entry := legal.value.thenInput (calls := (sourceReaders readers).statement) rfl rfl
    have inner := insideIH entry (scope.atInput _ (Nat.le_of_lt observed.thenAdvanced))
      (thenInput_mask_width _ _ _ _ width)
    have step : Statement.armState (Statement.finishArm (sourceReaders readers).statement source read) = some after := by
      rw [continued]; rfl
    have advance := finishArm_position parsed (Nat.lt_of_lt_of_le observed.thenAdvanced inner.progress) step
    have nextLegal := legal.finish parsed inner.legal.scan step
    have nextWidth := finishArm_mask_width inner.width step
    have rest := restIH nextLegal (scope.atInput after.value (Nat.le_of_lt advance)) nextWidth
    have same := NativeMasks.arm_masks step
    have capacity : source.info.states.length ≤ PackageBindings.maxStates := legal.value.typed.2.2.2.2.1
    refine ⟨rest.legal, rest.width, Nat.le_trans (Nat.le_of_lt advance) rest.progress, ?_, ?_⟩
    · have first : Included (scanEffects source.info before.value) (scanEffects source.info after.value) := by
        rw [same]
        exact (NativeMasks.then_incoming _ _ _ _ capacity).trans inner.incoming
      exact first.trans rest.incoming
    · intro alternative summary otherwiseBound finalBound effects inferred
      simp only [Statement.lowerArms, inference_singleton, inferStatementEffects,
        Option.bind_eq_some_iff, Option.map_eq_some_iff] at inferred
      obtain ⟨left, first, right, later, rfl⟩ := inferred
      have toSummary : Included (scanEffects source.info read.branch) summary := by
        rw [← same]; exact rest.incoming.trans finalBound
      exact (((condition_effects imports legal.value scope.declarations guard).trans inner.incoming).trans toSummary).merge_bound
        ((inner.effects _ first).trans toSummary |>.merge_bound (rest.effects _ _ otherwiseBound finalBound _ later))
  · intro source state missing legal scope width
    have same : Statement.elseResult (sourceReaders readers).statement source state = state.value := by
      simp only [Statement.elseResult, missing, ne_self_iff_false, ite_false]
    rw [same]
    exact ⟨legal.value, width, Nat.le_refl _, Included.refl _, nil_bound _ _ _⟩
  · intro source state body keyword _ insideIH legal scope width
    have advance := Expressions.model_fixed_advances source.text state.value.scan.position "else" true
      legal.value.scan.position (by decide) keyword
    have child := insideIH (legal.value.atPosition (fixedAfter_result_bound _ _ "else" true (by decide)))
      (scope.atInput _ (Nat.le_of_lt advance)) width
    exact ⟨child.legal, child.width, Nat.le_trans (Nat.le_of_lt advance) child.progress, child.incoming, child.effects⟩
  · intro source stop required seen _ _ _ legal scope width
    exact ⟨legal, width, Nat.le_refl _, Included.refl _, nil_bound _ _ _⟩
  · intro source stop required seen first result head rest _ _ _ _ advance _ headIH restIH legal scope width
    have firstFacts := headIH legal scope width
    have remaining := restIH firstFacts.legal (scope.atInput first (Nat.le_of_lt advance)) firstFacts.width
    refine ⟨remaining.legal, remaining.width, Nat.le_trans firstFacts.progress remaining.progress,
      firstFacts.incoming.trans remaining.incoming, ?_⟩
    intro effects inferred
    rw [inference_append] at inferred
    simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at inferred
    obtain ⟨left, firstInferred, right, restInferred, rfl⟩ := inferred
    exact ((firstFacts.effects _ firstInferred).trans remaining.incoming).merge_bound (remaining.effects _ restInferred)

end Silver.ApplicationPackageSourceEffects
