module

public import Silver.ApplicationPackageSemanticConditionalComposition

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive ApplicationPackageFrameLayout

set_option backward.dsimp.instances true

theorem package_arm_condition_ranges {readers : Readers} {bound source prior arm}
    (scope : PackageScope source) (legal : ArmsDomain source prior)
    (lower : source.input.scan.position ≤ prior.value.scan.position)
    (hidden : HiddenRanges bound source (source.context.flow prior.value.scan.facts))
    (parsed : Statement.readArm (sourceReaders readers).statement source prior = some arm) :
    HiddenRanges bound source (source.context.flow (Statement.conditionFor (sourceReaders readers).statement source prior).whenTrue) ∧
      HiddenRanges bound source (source.context.flow (Statement.conditionFor (sourceReaders readers).statement source prior).whenFalse) := by
  obtain ⟨native, contextEq, contextValid⟩ := legal.value.context
  have names : Expressions.ValidNames source.text source.context.names := contextEq ▸ contextValid.1
  obtain ⟨condition, original, meaning⟩ := Statement.arm_condition_meaning parsed rfl legal.value.text names
    legal.value.scan.position scope.normal legal.value.base legal.value.arrays legal.value.scan.flow.compatible legal.value.scan.path
  exact HiddenRanges.condition (source := atInput source prior.value)
    (scope.atInput prior.value lower) legal.value hidden original meaning

theorem package_arm_next_hidden {readers : Readers} {bound source prior arm after}
    (scope : PackageScope source) (legal : ArmsDomain source prior)
    (lower : source.input.scan.position ≤ prior.value.scan.position)
    (hidden : HiddenRanges bound source (source.context.flow prior.value.scan.facts))
    (parsed : Statement.readArm (sourceReaders readers).statement source prior = some arm)
    (step : Statement.armState (Statement.finishArm (sourceReaders readers).statement source arm) = some after) :
    HiddenRanges bound source (source.context.flow after.value.scan.facts) := by
  rw [(Statement.finishArm_fields step).1, (Statement.readArm_evaluation parsed).falseFlow]
  exact (package_arm_condition_ranges scope legal lower hidden parsed).2

theorem package_arms_hidden_false {readers : Readers} {bound source before entries after}
    (scope : PackageScope source)
    (reading : Statement.ArmsReading (sourceReaders readers).statement source before entries after)
    (domains : ∀ prior arm, (prior, arm) ∈ entries →
      ArmsDomain source prior ∧ source.input.scan.position ≤ prior.value.scan.position)
    (hidden : HiddenRanges bound source (source.context.flow before.value.scan.facts)) :
    HiddenRanges bound source (source.context.flow after.value.scan.facts) ∧
      ∀ prior arm, (prior, arm) ∈ entries → HiddenRanges bound source (source.context.flow prior.value.scan.facts) := by
  induction reading with
  | last parsed finished =>
    have legal := domains _ _ List.mem_cons_self
    refine ⟨package_arm_next_hidden scope legal.1 legal.2 hidden parsed (by rw [finished]; rfl), ?_⟩
    intro prior arm member
    cases List.mem_singleton.mp member
    exact hidden
  | next parsed continued reading ih =>
    have legal := domains _ _ List.mem_cons_self
    have next := package_arm_next_hidden scope legal.1 legal.2 hidden parsed (by rw [continued]; rfl)
    obtain ⟨final, remaining⟩ := ih (fun prior arm member => domains prior arm (List.mem_cons_of_mem _ member)) next
    refine ⟨final, ?_⟩
    intro prior arm member
    rcases List.mem_cons.mp member with same | later
    · cases same
      exact hidden
    · exact remaining prior arm later

theorem package_arm_decoded {readers bound source prior arm}
    (scope : PackageScope source)
    (decode : PackageTailInduction readers bound source)
    (legal : ArmsDomain source prior) (lower : source.input.scan.position ≤ prior.value.scan.position)
    (hidden : HiddenRanges bound source (source.context.flow prior.value.scan.facts))
    (parsed : Statement.readArm (sourceReaders readers).statement source prior = some arm) :
    ∃ code, Statement.DecodedArm (sourceReaders readers).statement source
      (checkedPackageChild bound (sourceReaders readers) source)
      (Statement.packageConditionalChecker (ApplicationPackageCalls.completedEnvironment source.info)
        (layout bound source.info source.context) source.context scope.shape)
      prior arm code := by
  have observed := Statement.readArm_evaluation parsed
  let input := Statement.thenInput (sourceReaders readers).statement source prior
    (Statement.conditionFor (sourceReaders readers).statement source prior)
  have childLegal : NativeDomain (atInput source input) := legal.value.thenInput rfl rfl
  have advanced : source.input.scan.position < input.scan.position := Nat.lt_of_le_of_lt lower observed.thenAdvanced
  have childScope := scope.atInput input (Nat.le_of_lt advanced)
  have same : (sourceReaders readers).tailResult (atInput source input) .arm true = arm.branch := observed.branchRead
  have childHidden := (package_arm_condition_ranges scope legal lower hidden parsed).1
  obtain ⟨body, original, checked⟩ := decode source.context input childLegal childScope childHidden advanced .arm true
    (same.symm ▸ observed.branchPresent)
  have normalized : atContext source source.context input = atInput source input := by cases source; rfl
  rw [normalized] at original checked
  rw [same] at original checked
  obtain ⟨native, contextEq, contextValid⟩ := legal.value.context
  have names : Expressions.ValidNames source.text source.context.names := contextEq ▸ contextValid.1
  obtain ⟨condition, decoded⟩ := Statement.decoded_arm_source
    (child := checkedPackageChild bound (sourceReaders readers) source)
    (checker := Statement.packageConditionalChecker (ApplicationPackageCalls.completedEnvironment source.info)
        (layout bound source.info source.context) source.context scope.shape)
    parsed rfl legal.value.text names legal.value.scan.position scope.normal
    legal.value.base legal.value.arrays legal.value.scan.flow.compatible legal.value.scan.path
    (And.intro original checked) original.nonempty checked.form checked.check
  exact ⟨(condition, body), decoded⟩

theorem package_else_decoded {readers bound source state}
    (scope : PackageScope source)
    (decode : PackageTailInduction readers bound source)
    (legal : ArmsDomain source state) (lower : source.input.scan.position < state.value.scan.position)
    (hidden : HiddenRanges bound source (source.context.flow state.value.scan.facts))
    (present : (Statement.elseResult (sourceReaders readers).statement source state).scan.position ≠ 0) :
    ∃ code, Statement.ElseCodeAt (sourceReaders readers).statement source
        (checkedPackageChild bound (sourceReaders readers) source) state code ∧
      StatementsWellFormed source.context.hasArguments source.context.names.shape code
        (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) ∧
      Packages.checkPackageStatements (ApplicationPackageCalls.completedEnvironment source.info)
        (layout bound source.info source.context) source.context.analysis (source.context.flow state.value.scan.facts)
        (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) code =
          some (source.context.flow (Statement.elseResult (sourceReaders readers).statement source state).scan.facts) := by
  apply Statement.else_source_checked
    (checker := Statement.packageConditionalChecker (ApplicationPackageCalls.completedEnvironment source.info)
        (layout bound source.info source.context) source.context scope.shape)
    (fun flow => Statement.packageConditionalChecker_empty _ _ _ scope.shape flow)
  intro keyword
  let position := Statement.elsePosition (sourceReaders readers).statement source state
  let input := Statement.atPosition state.value position
  have advance := Expressions.model_fixed_advances source.text state.value.scan.position "else" true
    legal.value.scan.position (by decide) keyword
  have childLegal : NativeDomain (atInput source input) := legal.value.atPosition
    (fixedAfter_result_bound source.text state.value.scan.position "else" true (by decide))
  have advanced : source.input.scan.position < input.scan.position := Nat.lt_trans lower advance
  have childScope := scope.atInput input (Nat.le_of_lt advanced)
  have same : Statement.elseResult (sourceReaders readers).statement source state =
      (sourceReaders readers).tailResult (atInput source input) .endOnly true := by
    rw [Statement.elseResult, ite_eq_left keyword]
    rfl
  obtain ⟨body, original, checked⟩ := decode source.context input childLegal childScope hidden advanced .endOnly true (same ▸ present)
  have normalized : atContext source source.context input = atInput source input := by cases source; rfl
  rw [normalized] at original checked
  rw [← same] at original checked
  exact ⟨body, ⟨original, checked⟩, checked.form, checked.check⟩

/-- The complete original conditional is decoded by deriving every arm's
native invocation domain and consuming only the strictly-later local tail
induction hypothesis. All IF/ELSIF/ELSE branches remain in the source result. -/
theorem package_conditional_decoded {readers bound source entries state result}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (scope : PackageScope source) (legal : NativeDomain source)
    (hidden : HiddenRanges bound source (source.context.flow source.input.scan.facts))
    (decode : PackageTailInduction readers bound source)
    (present : source.input.scan.position ≠ 0)
    (keyword : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "if") ≠ 0)
    (arms : Statement.ArmsReading (sourceReaders readers).statement source
      (firstArm (sourceReaders readers).statement source) entries state)
    (closing : Statement.ClosingReading (sourceReaders readers).statement source state result) :
    ∃ code, StatementCodeAt (sourceReaders readers) packageNames source result code ∧
      PackageChecked bound source result code := by
  have first := Expressions.model_fixed_advances source.text source.input.scan.position "if" true
    legal.scan.position (by decide) keyword
  obtain ⟨stateLegal, stateLower, each⟩ := arms_native_domains equations scope.typed arms
    (ArmsDomain.initial legal) (Nat.le_of_lt first)
  obtain ⟨stateHidden, eachHidden⟩ := package_arms_hidden_false scope arms each hidden
  obtain ⟨alternative, originalElse, elseForm, elseChecked⟩ :=
    package_else_decoded scope decode stateLegal stateLower stateHidden closing.branchPresent
  exact package_conditional_composed scope legal hidden stateHidden present keyword arms closing
    (fun prior arm member => package_arm_decoded scope decode (each prior arm member).1
      (each prior arm member).2 (eachHidden prior arm member) (arms.originals prior arm member))
      originalElse elseForm elseChecked

end Silver.ApplicationPackageBodies.SourceSyntax
