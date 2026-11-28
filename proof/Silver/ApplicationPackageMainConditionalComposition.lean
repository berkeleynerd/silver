module

public import Silver.ApplicationPackageMainRecursiveChecking

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive

/-- Only a local composition aid: the checked child is derived by recursive
induction and erased when constructing the source-only parent node. -/
def checkedChild (environment : Applications.Environment) (readers : Readers)
    (source : Statement.Input) : Statement.ChildReading :=
  fun input stop code result =>
    TailCodeAt readers (mainNames environment) (atInput source input) stop true false result code ∧
      MainChecked environment (atInput source input) result code

theorem arm_codes_source {environment} {readers : Readers} {source entries codes}
    (reading : Statement.ArmCodesAt readers.statement source (checkedChild environment readers source) entries codes) :
    Statement.ArmCodesAt readers.statement source (childReading readers (mainNames environment) source) entries codes := by
  induction reading with
  | nil => exact .nil
  | cons condition body rest ih => exact .cons condition body.1 ih

theorem else_code_source {environment} {readers : Readers} {source state code}
    (reading : Statement.ElseCodeAt readers.statement source (checkedChild environment readers source) state code) :
    Statement.ElseCodeAt readers.statement source (childReading readers (mainNames environment) source) state code := by
  cases reading with
  | absent missing => exact .absent missing
  | present keyword body => exact .present keyword body.1

theorem arm_codes_binders {environment} {readers : Readers} {source entries codes}
    (reading : Statement.ArmCodesAt readers.statement source (checkedChild environment readers source) entries codes)
    {array : Integer.ArrayDescriptor}
    (apart : ∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index)
    {alternative : List Predicate.Statement} (otherwise : statementsBindersApart array alternative = true) :
    statementsBindersApart array (Statement.lowerArms codes alternative) = true := by
  induction reading with
  | nil => exact otherwise
  | cons condition body rest ih =>
    simp only [Statement.lowerArms, statementsBindersApart, Predicate.Statement.bindersApart,
      body.2.binders array apart, ih, Bool.and_self]

theorem else_code_binders {environment} {readers : Readers} {source state code}
    (reading : Statement.ElseCodeAt readers.statement source (checkedChild environment readers source) state code)
    (array : Integer.ArrayDescriptor)
    (apart : ∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index) :
    statementsBindersApart array code = true := by
  cases reading with
  | absent => simp only [statementsBindersApart]
  | present _ body => exact body.2.binders array apart

theorem main_conditional_composed {readers : Readers} {environment : Applications.Environment}
    {source : Statement.Input} {entries state result alternative}
    (present : source.input.scan.position ≠ 0)
    (keyword : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "if") ≠ 0)
    (arms : Statement.ArmsReading (sourceReaders readers).statement source
      (firstArm (sourceReaders readers).statement source) entries state)
    (closing : Statement.ClosingReading (sourceReaders readers).statement source state result)
    (decode : ∀ prior arm, (prior, arm) ∈ entries → ∃ code,
      Statement.DecodedArm (sourceReaders readers).statement source
        (checkedChild environment (sourceReaders readers) source)
        (Statement.mainConditionalChecker environment.functionSignatures environment.procedureSignatures source.context)
        prior arm code)
    (otherwise : Statement.ElseCodeAt (sourceReaders readers).statement source
      (checkedChild environment (sourceReaders readers) source) state alternative)
    (alternativeForm : StatementsWellFormed source.context.hasArguments source.context.names.shape alternative
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)))
    (alternativeCheck : checkStatements source.context.names.shape source.context.analysis
      (source.context.flow state.value.scan.facts) alternative
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
      environment.functionSignatures environment.procedureSignatures =
        some (source.context.flow (Statement.elseResult (sourceReaders readers).statement source state).scan.facts)) :
    ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) source result code ∧
      MainChecked environment source result code := by
  obtain ⟨codes, original, formed, checked⟩ := Statement.conditional_checked arms closing
    (fun _ _ => rfl) (fun _ _ => bodyToken_facts ..) decode alternativeForm alternativeCheck
  refine ⟨Statement.lowerArms codes alternative,
    .conditional present keyword (.of_reading arms (arm_codes_source original))
      (.of_reading (else_code_source otherwise)) closing, formed, checked, ?_⟩
  intro array apart
  exact arm_codes_binders original apart (else_code_binders otherwise array apart)

end Silver.ApplicationPackageBodies.SourceSyntax
