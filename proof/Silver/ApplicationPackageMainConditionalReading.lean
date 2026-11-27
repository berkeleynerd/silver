module

public import Silver.ApplicationPackageMainConditionalComposition

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive

set_option backward.dsimp.instances true

abbrev MainTailInduction (readers : Readers) (environment : Applications.Environment)
    (cutoff : Nat) (source : Statement.Input) : Prop :=
  ∀ context input, NativeDomain (atContext source context input) →
    MainScope environment cutoff (atContext source context input) →
    source.input.scan.position < input.scan.position → ∀ stop required,
    ((sourceReaders readers).tailResult (atContext source context input) stop required).scan.position ≠ 0 →
    ∃ code, TailCodeAt (sourceReaders readers) (mainNames environment) (atContext source context input)
        stop required false ((sourceReaders readers).tailResult (atContext source context input) stop required) code ∧
      MainChecked environment (atContext source context input)
        ((sourceReaders readers).tailResult (atContext source context input) stop required) code

theorem arms_native_domains {readers : Readers} {source : Statement.Input} {before entries after}
    (equations : Equations (sourceReaders readers) NativeDomain) (typed : source.info.Typed)
    (reading : Statement.ArmsReading (sourceReaders readers).statement source before entries after) :
    ArmsDomain source before → source.input.scan.position ≤ before.value.scan.position →
    ArmsDomain source after ∧ source.input.scan.position < after.value.scan.position ∧
      ∀ prior arm, (prior, arm) ∈ entries →
        ArmsDomain source prior ∧ source.input.scan.position ≤ prior.value.scan.position := by
  have contracts (value : ApplicationScan) (legal : NativeDomain (atInput source value))
      (_ : source.input.scan.position < value.scan.position) (stop : BodyStop) (required : Bool) :
      TailOutcome (sourceReaders readers) (atInput source value) stop required :=
    (Equations.outcomes (readers := sourceReaders readers) equations legal typed).2 stop required
  induction reading with
  | @last before read after parsed finished =>
    intro legal lower
    obtain ⟨scan, _, advanced, _⟩ := readArm_outcome (readers := sourceReaders readers) equations contracts legal lower parsed
    have step : Statement.armState (Statement.finishArm (sourceReaders readers).statement source read) = some after := by
      rw [finished]; rfl
    exact ⟨legal.finish parsed scan step, Nat.lt_of_le_of_lt lower (finishArm_position parsed advanced step),
      fun prior arm member => by cases List.mem_singleton.mp member; exact ⟨legal, lower⟩⟩
  | @next before read after entries final parsed continued reading ih =>
    intro legal lower
    obtain ⟨scan, _, advanced, _⟩ := readArm_outcome (readers := sourceReaders readers) equations contracts legal lower parsed
    have step : Statement.armState (Statement.finishArm (sourceReaders readers).statement source read) = some after := by
      rw [continued]; rfl
    have moved := Nat.lt_of_le_of_lt lower (finishArm_position parsed advanced step)
    obtain ⟨finalDomain, finalLower, remaining⟩ := ih (legal.finish parsed scan step) (Nat.le_of_lt moved)
    refine ⟨finalDomain, finalLower, ?_⟩
    intro prior arm member
    rcases List.mem_cons.mp member with current | following
    · cases current; exact ⟨legal, lower⟩
    · exact remaining prior arm following

theorem main_arm_decoded {readers environment cutoff source prior arm}
    (scope : MainScope environment cutoff source)
    (decode : MainTailInduction readers environment cutoff source)
    (legal : ArmsDomain source prior) (lower : source.input.scan.position ≤ prior.value.scan.position)
    (parsed : Statement.readArm (sourceReaders readers).statement source prior = some arm) :
    ∃ code, Statement.DecodedArm (sourceReaders readers).statement source
      (checkedChild environment (sourceReaders readers) source)
      (Statement.mainConditionalChecker environment.functionSignatures environment.procedureSignatures source.context)
      prior arm code := by
  have observed := Statement.readArm_evaluation parsed
  let input := Statement.thenInput (sourceReaders readers).statement source prior
    (Statement.conditionFor (sourceReaders readers).statement source prior)
  have childLegal : NativeDomain (atInput source input) := legal.value.thenInput rfl rfl
  have advanced : source.input.scan.position < input.scan.position := Nat.lt_of_le_of_lt lower observed.thenAdvanced
  have childScope := scope.atInput input (Nat.le_of_lt advanced)
  have same : (sourceReaders readers).tailResult (atInput source input) .arm true = arm.branch := observed.branchRead
  obtain ⟨body, original, checked⟩ := decode source.context input childLegal childScope advanced .arm true
    (same.symm ▸ observed.branchPresent)
  have normalized : atContext source source.context input = atInput source input := by cases source; rfl
  rw [normalized] at original checked
  rw [same] at original checked
  obtain ⟨native, contextEq, contextValid⟩ := legal.value.context
  have names : Expressions.ValidNames source.text source.context.names := contextEq ▸ contextValid.1
  obtain ⟨condition, decoded⟩ := Statement.decoded_arm_source
    (child := checkedChild environment (sourceReaders readers) source)
    (checker := Statement.mainConditionalChecker environment.functionSignatures environment.procedureSignatures source.context)
    parsed rfl legal.value.text names legal.value.scan.position scope.normal
    legal.value.base legal.value.arrays legal.value.scan.flow.compatible legal.value.scan.path
    (And.intro original checked) original.nonempty checked.form checked.check
  exact ⟨(condition, body), decoded⟩

theorem main_else_decoded {readers environment cutoff source state}
    (scope : MainScope environment cutoff source)
    (decode : MainTailInduction readers environment cutoff source)
    (legal : ArmsDomain source state) (lower : source.input.scan.position < state.value.scan.position)
    (present : (Statement.elseResult (sourceReaders readers).statement source state).scan.position ≠ 0) :
    ∃ code, Statement.ElseCodeAt (sourceReaders readers).statement source
        (checkedChild environment (sourceReaders readers) source) state code ∧
      StatementsWellFormed source.context.hasArguments source.context.names.shape code
        (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) ∧
      checkStatements source.context.names.shape source.context.analysis (source.context.flow state.value.scan.facts)
        code (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
        environment.functionSignatures environment.procedureSignatures =
          some (source.context.flow (Statement.elseResult (sourceReaders readers).statement source state).scan.facts) := by
  apply Statement.else_source_checked
    (checker := Statement.mainConditionalChecker environment.functionSignatures environment.procedureSignatures source.context)
    (fun flow => Statement.mainConditionalChecker_empty _ _ _ flow)
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
  obtain ⟨body, original, checked⟩ := decode source.context input childLegal childScope advanced .endOnly true (same ▸ present)
  have normalized : atContext source source.context input = atInput source input := by cases source; rfl
  rw [normalized] at original checked
  rw [← same] at original checked
  exact ⟨body, ⟨original, checked⟩, checked.form, checked.check⟩

/-- The complete original conditional is decoded by deriving every arm's
native invocation domain and consuming only the strictly-later local tail
induction hypothesis. All IF/ELSIF/ELSE branches remain in the source result. -/
theorem main_conditional_decoded {readers environment cutoff source entries state result}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (scope : MainScope environment cutoff source) (legal : NativeDomain source)
    (decode : MainTailInduction readers environment cutoff source)
    (present : source.input.scan.position ≠ 0)
    (keyword : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "if") ≠ 0)
    (arms : Statement.ArmsReading (sourceReaders readers).statement source
      (firstArm (sourceReaders readers).statement source) entries state)
    (closing : Statement.ClosingReading (sourceReaders readers).statement source state result) :
    ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) source result code ∧
      MainChecked environment source result code := by
  have first := Expressions.model_fixed_advances source.text source.input.scan.position "if" true
    legal.scan.position (by decide) keyword
  obtain ⟨stateLegal, stateLower, each⟩ := arms_native_domains equations scope.typed arms
    (ArmsDomain.initial legal) (Nat.le_of_lt first)
  obtain ⟨alternative, originalElse, elseForm, elseChecked⟩ :=
    main_else_decoded scope decode stateLegal stateLower closing.branchPresent
  exact main_conditional_composed present keyword arms closing
    (fun prior arm member => main_arm_decoded scope decode (each prior arm member).1
      (each prior arm member).2 (arms.originals prior arm member)) originalElse elseForm elseChecked

end Silver.ApplicationPackageBodies.SourceSyntax
