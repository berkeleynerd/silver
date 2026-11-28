module

public import Silver.ApplicationAssurance
public import Silver.PackageSummaryLibrarySafety

@[expose] public section

/-! The application consumer for original initializer phases and conservative native
effect summaries. The checked library covers every inferred effect; Main retains
its full checker, source syntax and operational semantics. Original-source
construction is a separate obligation, not a premise supplied by program authors. -/
namespace Silver.Applications
open Bindings Compose Predicate PathFacts
open ScalarFunctions (Frame)
open Packages (StateSchema SummaryRoutineEntry RoutineLibrary)

theorem summary_environmentFor_valid {schema : StateSchema} {entries : List SummaryRoutineEntry} {library : RoutineLibrary}
    {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment}
    (schemaValid : schema.Valid) (forms : ∀ entry ∈ entries, entry.Form schema)
    (built : Packages.checkSummaryLibrary schema entries = some library)
    (functionValid : functions.Valid) (procedureValid : procedures.Valid) :
    (environmentFor functions procedures library).Valid schema :=
  ⟨functionValid, procedureValid, (Packages.checkSummaryLibrary_sound schemaValid forms built).1⟩

def summaryObligations (schema : StateSchema) (entries : List SummaryRoutineEntry) (environment : Environment)
    (shape : Shape) (analysis : Integer.Analysis) (before : Flow)
    (items : List Predicate.Statement) (booleans : Boolean.Analysis) : List Predicate.Obligation :=
  Packages.summaryLibraryObligationsFrom schema .empty entries ++
    Predicate.statementsObligations (signatures := environment.functionSignatures)
      (procedures := environment.procedureSignatures) shape analysis before items booleans

theorem summary_obligations_discharge {schema : StateSchema} {entries : List SummaryRoutineEntry} {library : RoutineLibrary}
    {environment : Environment} {shape : Shape} {analysis : Integer.Analysis} {before after : Flow}
    {items : List Predicate.Statement} {booleans : Boolean.Analysis}
    (built : Packages.checkSummaryLibrary schema entries = some library)
    (checked : Predicate.checkStatements (signatures := environment.functionSignatures)
      (procedures := environment.procedureSignatures) shape analysis before items booleans = some after) :
    Predicate.discharged (summaryObligations schema entries environment shape analysis before items booleans) = true := by
  rw [summaryObligations, Predicate.discharged_append,
    Packages.checkSummaryLibraryFrom_obligations_discharge built,
    Predicate.statements_obligations_discharge checked]
  rfl

theorem checked_summary_application_sound {schema : StateSchema} {entries : List SummaryRoutineEntry} {library : RoutineLibrary}
    {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment}
    {shape : Shape} {before after : Flow} {hasArguments : Bool}
    {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
    {integers : Integer.Store} {booleans : Boolean.Store}
    {items : List Predicate.Statement} {input : Source} {values : Values} {valid rejected : Bool}
    (schemaValid : schema.Valid) (forms : ∀ entry ∈ entries, entry.Form schema)
    (built : Packages.checkSummaryLibrary schema entries = some library)
    (functionValid : functions.Valid) (procedureValid : procedures.Valid)
    (wellFormed : StatementsWellFormed hasArguments shape items booleanAnalysis)
    (checked : Predicate.checkStatements
      (signatures := (environmentFor functions procedures library).functionSignatures)
      (procedures := (environmentFor functions procedures library).procedureSignatures)
      shape analysis before items booleanAnalysis = some after)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : before.Allows valid input.length rejected integers)
    (declaredState : Integer.Fits analysis.declared integers) :
    Packages.SummaryRoutinesSafeFrom schema .empty entries ∧
      ExecutionSound schema shape analysis after input valid rejected
        (executeStatements (environmentFor functions procedures library) (Packages.initialState schema)
          input valid values items integers booleans)
        (checkedStatements (environmentFor functions procedures library) (Packages.initialState schema)
          input valid values items integers booleans) ∧
      Predicate.discharged (summaryObligations schema entries (environmentFor functions procedures library)
        shape analysis before items booleanAnalysis) = true := by
  have packageSound := Packages.checkSummaryLibrary_sound schemaValid forms built
  have certified := summary_environmentFor_valid schemaValid forms built functionValid procedureValid
  exact ⟨packageSound.2.2.1,
    statements_execution_sound (booleans := booleans) certified (Packages.initialState_fits schemaValid)
      wellFormed checked state printable allowed declaredState,
    summary_obligations_discharge built checked⟩

end Silver.Applications
