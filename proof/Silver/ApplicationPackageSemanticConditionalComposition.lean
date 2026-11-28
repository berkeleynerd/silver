module

public import Silver.ApplicationPackageRoutineRecursiveTail

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive ApplicationPackageFrameLayout

set_option backward.dsimp.instances true

def checkedPackageChild (bound : Nat) (readers : Readers) (source : Statement.Input) : Statement.ChildReading :=
  fun input stop code result =>
    TailCodeAt readers packageNames (atInput source input) stop true false result code ∧
      PackageChecked bound (atInput source input) result code

theorem package_arm_codes_source {bound} {readers : Readers} {source entries codes}
    (reading : Statement.ArmCodesAt readers.statement source (checkedPackageChild bound readers source) entries codes) :
    Statement.ArmCodesAt readers.statement source (childReading readers packageNames source) entries codes := by
  induction reading with
  | nil => exact .nil
  | cons condition body rest ih => exact .cons condition body.1 ih

theorem package_else_code_source {bound} {readers : Readers} {source state code}
    (reading : Statement.ElseCodeAt readers.statement source (checkedPackageChild bound readers source) state code) :
    Statement.ElseCodeAt readers.statement source (childReading readers packageNames source) state code := by
  cases reading with
  | absent missing => exact .absent missing
  | present keyword body => exact .present keyword body.1

theorem package_arm_codes_binders {bound} {readers : Readers} {source entries codes alternative}
    (reading : Statement.ArmCodesAt readers.statement source (checkedPackageChild bound readers source) entries codes)
    (otherwise : Packages.StatementsLocalBinders (layout bound source.info source.context) alternative) :
    Packages.StatementsLocalBinders (layout bound source.info source.context) (Statement.lowerArms codes alternative) := by
  induction reading with
  | nil => exact otherwise
  | cons condition body rest ih =>
    simp only [Statement.lowerArms, Packages.StatementsLocalBinders, Packages.statementLocalBinders]
    exact ⟨⟨body.2.binders, ih⟩, trivial⟩

theorem package_else_code_binders {bound} {readers : Readers} {source state code}
    (reading : Statement.ElseCodeAt readers.statement source (checkedPackageChild bound readers source) state code) :
    Packages.StatementsLocalBinders (layout bound source.info source.context) code := by
  cases reading with
  | absent => simp only [Packages.StatementsLocalBinders]
  | present _ body => exact body.2.binders

theorem package_arm_codes_hidden {bound} {readers : Readers} {source entries codes}
    (reading : Statement.ArmCodesAt readers.statement source (checkedPackageChild bound readers source) entries codes) :
    ∀ prior arm, (prior, arm) ∈ entries → HiddenRanges bound source (source.context.flow arm.branch.scan.facts) := by
  induction reading with
  | nil => simp
  | cons condition body rest ih =>
    intro prior arm member
    rcases List.mem_cons.mp member with same | later
    · cases same
      exact body.2.hidden
    · exact ih prior arm later

theorem package_else_code_hidden {bound} {readers : Readers} {source state code}
    (reading : Statement.ElseCodeAt readers.statement source (checkedPackageChild bound readers source) state code)
    (incoming : HiddenRanges bound source (source.context.flow state.value.scan.facts)) :
    HiddenRanges bound source (source.context.flow (Statement.elseResult readers.statement source state).scan.facts) := by
  cases reading with
  | absent missing =>
    simpa only [Statement.elseResult, missing, ne_self_iff_false, ite_false] using incoming
  | present _ body => exact body.2.hidden

theorem package_finishArm_hidden {readers : Readers} {bound source prior arm after}
    (scope : PackageScope source) (legal : NativeDomain source)
    (parsed : Statement.readArm (sourceReaders readers).statement source prior = some arm)
    (step : Statement.armState (Statement.finishArm (sourceReaders readers).statement source arm) = some after)
    (previous : HiddenRanges bound source (source.context.flow prior.yes))
    (branch : HiddenRanges bound source (source.context.flow arm.branch.scan.facts)) :
    HiddenRanges bound source (source.context.flow after.yes) := by
  have fields := Statement.finishArm_fields step
  have observed := Statement.readArm_evaluation parsed
  rw [fields.2.1, observed.previousArm, observed.previousFlow]
  cases prior.haveYes with
  | false => exact branch
  | true =>
    change HiddenRanges bound source (source.context.flow (prior.yes.join arm.branch.scan.facts))
    rw [ParseContext.flow_join]
    exact previous.join scope legal branch

theorem package_arms_yes_hidden {readers : Readers} {bound source before entries after}
    (scope : PackageScope source) (legal : NativeDomain source)
    (reading : Statement.ArmsReading (sourceReaders readers).statement source before entries after)
    (previous : HiddenRanges bound source (source.context.flow before.yes))
    (branches : ∀ prior arm, (prior, arm) ∈ entries →
      HiddenRanges bound source (source.context.flow arm.branch.scan.facts)) :
    HiddenRanges bound source (source.context.flow after.yes) := by
  induction reading with
  | last parsed finished =>
    exact package_finishArm_hidden scope legal parsed (by rw [finished]; rfl) previous (branches _ _ List.mem_cons_self)
  | next parsed continued reading ih =>
    exact ih (package_finishArm_hidden scope legal parsed (by rw [continued]; rfl)
      previous (branches _ _ List.mem_cons_self))
      (fun prior arm member => branches prior arm (List.mem_cons_of_mem _ member))

theorem package_conditional_composed {readers : Readers} {bound source entries state result alternative}
    (scope : PackageScope source) (legal : NativeDomain source)
    (hidden : HiddenRanges bound source (source.context.flow source.input.scan.facts))
    (stateHidden : HiddenRanges bound source (source.context.flow state.value.scan.facts))
    (present : source.input.scan.position ≠ 0)
    (keyword : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "if") ≠ 0)
    (arms : Statement.ArmsReading (sourceReaders readers).statement source
      (firstArm (sourceReaders readers).statement source) entries state)
    (closing : Statement.ClosingReading (sourceReaders readers).statement source state result)
    (decode : ∀ prior arm, (prior, arm) ∈ entries → ∃ code,
      Statement.DecodedArm (sourceReaders readers).statement source
        (checkedPackageChild bound (sourceReaders readers) source)
        (Statement.packageConditionalChecker (ApplicationPackageCalls.completedEnvironment source.info)
          (layout bound source.info source.context) source.context scope.shape) prior arm code)
    (otherwise : Statement.ElseCodeAt (sourceReaders readers).statement source
      (checkedPackageChild bound (sourceReaders readers) source) state alternative)
    (alternativeForm : StatementsWellFormed source.context.hasArguments source.context.names.shape alternative
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)))
    (alternativeCheck : Packages.checkPackageStatements (ApplicationPackageCalls.completedEnvironment source.info)
      (layout bound source.info source.context) source.context.analysis (source.context.flow state.value.scan.facts)
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) alternative =
        some (source.context.flow (Statement.elseResult (sourceReaders readers).statement source state).scan.facts)) :
    ∃ code, StatementCodeAt (sourceReaders readers) packageNames source result code ∧
      PackageChecked bound source result code := by
  obtain ⟨codes, original, formed, checked⟩ := Statement.conditional_checked arms closing
    (fun _ _ => rfl) (fun _ _ => bodyToken_facts ..) decode alternativeForm alternativeCheck
  refine ⟨Statement.lowerArms codes alternative,
    .conditional present keyword (.of_reading arms (package_arm_codes_source original))
      (.of_reading (package_else_code_source otherwise)) closing, formed, checked,
    package_arm_codes_binders original (package_else_code_binders otherwise), ?_⟩
  rw [closing.flow (fun _ _ => rfl) (fun _ _ => bodyToken_facts ..)]
  exact (package_arms_yes_hidden scope legal arms hidden (package_arm_codes_hidden original)).join scope legal
    (package_else_code_hidden otherwise stateHidden)

end Silver.ApplicationPackageBodies.SourceSyntax
