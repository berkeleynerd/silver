module

public import Silver.ApplicationPackageMainRecursiveDomain

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive

set_option backward.dsimp.instances true

theorem checkStatements_append {shape : Bindings.Shape} {analysis : Integer.Analysis}
    {booleans : Boolean.Analysis} {functions : ScalarFunctions.Signatures}
    {procedures : ScalarProcedures.Signatures} (first rest : List Predicate.Statement) (before : Flow) :
    checkStatements shape analysis before (first ++ rest) booleans functions procedures =
      (checkStatements shape analysis before first booleans functions procedures).bind
        (fun middle => checkStatements shape analysis middle rest booleans functions procedures) := by
  induction first generalizing before with
  | nil => simp only [List.nil_append, checkStatements, Option.bind_some]
  | cons head tail ih =>
    simp only [List.cons_append, checkStatements, ih, Option.bind_assoc]

theorem forms_append {hasArguments : Bool} {shape : Bindings.Shape} {booleans : Boolean.Analysis}
    {first rest : List Predicate.Statement}
    (left : StatementsWellFormed hasArguments shape first booleans)
    (right : StatementsWellFormed hasArguments shape rest booleans) :
    StatementsWellFormed hasArguments shape (first ++ rest) booleans := by
  induction first with
  | nil => exact right
  | cons head tail ih =>
    simp only [StatementsWellFormed] at left
    simp only [List.cons_append, StatementsWellFormed]
    exact ⟨left.1, ih left.2⟩

theorem binders_append (array : Integer.ArrayDescriptor) (first rest : List Predicate.Statement) :
    statementsBindersApart array (first ++ rest) =
      (statementsBindersApart array first && statementsBindersApart array rest) := by
  induction first with
  | nil => simp only [List.nil_append, statementsBindersApart, Bool.true_and]
  | cons head tail ih =>
    simp only [List.cons_append, statementsBindersApart, ih, Bool.and_assoc]

theorem BasicCodeAt.binders {readers names source result item}
    (original : BasicCodeAt readers names source result item) (array : Integer.ArrayDescriptor) :
    item.bindersApart array = true := by
  cases original with
  | inherited _ _ source =>
    cases source.payload with
    | primitive _ payload => cases payload <;> simp only [SourceStatement.lower, Predicate.Statement.bindersApart]
    | procedure _ _ => simp only [SourceStatement.lower, Predicate.Statement.bindersApart]
  | functionCall => simp only [Predicate.Statement.bindersApart]
  | procedureCall => simp only [Predicate.Statement.bindersApart]

/-- A derived local semantic result, kept separate from the source-only
relations. The binder fact covers every nested scalar binder, so array-loop
checking never assumes a no-alias certificate from the program author. -/
structure MainChecked (environment : Applications.Environment) (source : Statement.Input)
    (result : ApplicationScan) (code : List Predicate.Statement) : Prop where
  form : StatementsWellFormed source.context.hasArguments source.context.names.shape code
    (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
  check : checkStatements source.context.names.shape source.context.analysis
    (source.context.flow source.input.scan.facts) code
    (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
    environment.functionSignatures environment.procedureSignatures = some (source.context.flow result.scan.facts)
  binders : ∀ array : Integer.ArrayDescriptor,
    (∀ index, index ≤ ArrayBindings.scalarLimit → ¬array.ContainsCell index) →
    statementsBindersApart array code = true

theorem MainChecked.empty (environment : Applications.Environment) (source : Statement.Input) :
    MainChecked environment source source.input [] := by
  constructor
  · simp only [StatementsWellFormed]
  · simp only [checkStatements]
  · intros; simp only [statementsBindersApart]

theorem MainChecked.append {environment source middle result first rest}
    (left : MainChecked environment source middle first)
    (right : MainChecked environment (atInput source middle) result rest) :
    MainChecked environment source result (first ++ rest) := by
  constructor
  · exact forms_append left.form right.form
  · rw [checkStatements_append, left.check, Option.bind_some]
    exact right.check
  · intro array apart
    rw [binders_append, left.binders array apart, right.binders array apart]
    rfl

theorem MainChecked.obligations {environment source result code}
    (derived : MainChecked environment source result code) :
    discharged (statementsObligations source.context.names.shape source.context.analysis
      (source.context.flow source.input.scan.facts) code
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames))
      environment.functionSignatures environment.procedureSignatures) = true :=
  statements_obligations_discharge derived.check

theorem main_basic_decoded {readers environment cutoff source}
    (equations : Equations (sourceReaders readers) NativeDomain)
    (scope : MainScope environment cutoff source) (legal : NativeDomain source)
    (present : source.input.scan.position ≠ 0)
    (noIf : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "if") = 0)
    (noFor : (sourceReaders readers).statement.takeToken source.text source.input.scan.position (.word "for") = 0)
    (accepted : ((sourceReaders readers).statement.applicationBasic source.text source.context source.input
      source.info source.catalog source.procedures).scan.position ≠ 0) :
    let result := (sourceReaders readers).statement.applicationBasic source.text source.context source.input
      source.info source.catalog source.procedures
    ∃ code, StatementCodeAt (sourceReaders readers) (mainNames environment) source result code ∧
      MainChecked environment source result code := by
  have linked := equations.basic_model legal
  have nativeAccepted := accepted
  rw [linked] at nativeAccepted
  obtain ⟨item, original, formed, checked⟩ := scope.basic_reading legal nativeAccepted
  rw [← linked] at original checked
  refine ⟨[item], .basic present noIf noFor rfl accepted original, ?_⟩
  constructor
  · simp only [StatementsWellFormed]; exact ⟨formed, trivial⟩
  · simp only [checkStatements, checked, Option.bind_some]
  · intro array _
    simp only [statementsBindersApart, original.binders array, Bool.and_self]

end Silver.ApplicationPackageBodies.SourceSyntax
