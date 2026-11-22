module

public import Silver.ApplicationSafety

@[expose] public section

/-! Semantic composition endpoint: checked package definitions establish all
callee typing; Main uses the unchanged full Predicate checker and obligations.
Original-source integration must construct these syntax/representation facts
from the actual Bundle, and derive the existing Main-local libraries' validity.
This module alone makes no recognizer or original-source correspondence claim. -/
namespace Silver.Applications
open Bindings Compose Predicate PathFacts
open ScalarFunctions (Frame)
open Packages (StateSchema RoutineEntry RoutineLibrary)

def environmentFor (functions : ScalarFunctions.Environment) (procedures : ScalarProcedures.Environment)
    (library : RoutineLibrary) : Environment := ⟨functions, procedures, library.environment⟩

theorem environmentFor_valid {schema : StateSchema} {entries : List RoutineEntry} {library : RoutineLibrary}
    {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment}
    (schemaValid : schema.Valid) (forms : ∀ entry ∈ entries, entry.Form schema)
    (built : Packages.checkLibrary schema entries = some library)
    (functionValid : functions.Valid) (procedureValid : procedures.Valid) :
    (environmentFor functions procedures library).Valid schema :=
  ⟨functionValid, procedureValid, (Packages.checkLibrary_sound schemaValid forms built).1⟩

def obligations (schema : StateSchema) (entries : List RoutineEntry) (environment : Environment)
    (shape : Shape) (analysis : Integer.Analysis) (before : Flow)
    (items : List Predicate.Statement) (booleans : Boolean.Analysis) : List Predicate.Obligation :=
  Packages.libraryObligationsFrom schema .empty entries ++
    Predicate.statementsObligations (signatures := environment.functionSignatures)
      (procedures := environment.procedureSignatures) shape analysis before items booleans

theorem obligations_discharge {schema : StateSchema} {entries : List RoutineEntry} {library : RoutineLibrary}
    {environment : Environment} {shape : Shape} {analysis : Integer.Analysis} {before after : Flow}
    {items : List Predicate.Statement} {booleans : Boolean.Analysis}
    (built : Packages.checkLibrary schema entries = some library)
    (checked : Predicate.checkStatements (signatures := environment.functionSignatures)
      (procedures := environment.procedureSignatures) shape analysis before items booleans = some after) :
    Predicate.discharged (obligations schema entries environment shape analysis before items booleans) = true := by
  rw [obligations, Predicate.discharged_append,
    Packages.checkLibraryFrom_obligations_discharge built,
    Predicate.statements_obligations_discharge checked]
  rfl

theorem checked_application_sound {schema : StateSchema} {entries : List RoutineEntry} {library : RoutineLibrary}
    {functions : ScalarFunctions.Environment} {procedures : ScalarProcedures.Environment}
    {shape : Shape} {before after : Flow} {hasArguments : Bool}
    {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
    {integers : Integer.Store} {booleans : Boolean.Store}
    {items : List Predicate.Statement} {input : Source} {values : Values} {valid rejected : Bool}
    (schemaValid : schema.Valid) (forms : ∀ entry ∈ entries, entry.Form schema)
    (built : Packages.checkLibrary schema entries = some library)
    (functionValid : functions.Valid) (procedureValid : procedures.Valid)
    (wellFormed : StatementsWellFormed hasArguments shape items booleanAnalysis)
    (checked : Predicate.checkStatements
      (signatures := (environmentFor functions procedures library).functionSignatures)
      (procedures := (environmentFor functions procedures library).procedureSignatures)
      shape analysis before items booleanAnalysis = some after)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : before.Allows valid input.length rejected integers)
    (declaredState : Integer.Fits analysis.declared integers) :
    Packages.RoutinesSafeFrom schema .empty entries ∧
      ExecutionSound schema shape analysis after input valid rejected
        (executeStatements (environmentFor functions procedures library) (Packages.initialState schema)
          input valid values items integers booleans)
        (checkedStatements (environmentFor functions procedures library) (Packages.initialState schema)
          input valid values items integers booleans) ∧
      Predicate.discharged (obligations schema entries (environmentFor functions procedures library)
        shape analysis before items booleanAnalysis) = true := by
  have packageSound := Packages.checkLibrary_sound schemaValid forms built
  have certified := environmentFor_valid schemaValid forms built functionValid procedureValid
  exact ⟨packageSound.2.2.1,
    statements_execution_sound (booleans := booleans) certified (Packages.initialState_fits schemaValid)
      wellFormed checked state printable allowed declaredState,
    obligations_discharge built checked⟩

theorem completed_invalid_rejected {schema : StateSchema} {environment : Environment} {globals : Frame}
    {shape : Shape} {before after : Flow} {hasArguments : Bool}
    {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis}
    {integers : Integer.Store} {booleans : Boolean.Store}
    {items : List Predicate.Statement} {input : Source} {values : Values}
    (certified : environment.Valid schema) (globalsFit : schema.Fits globals)
    (wellFormed : StatementsWellFormed hasArguments shape items booleanAnalysis)
    (checked : Predicate.checkStatements (signatures := environment.functionSignatures)
      (procedures := environment.procedureSignatures) shape analysis before items booleanAnalysis = some after)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : before.Allows false input.length false integers) (finished : completed after.path = true)
    (declaredState : Integer.Fits analysis.declared integers) :
    Sequence.Effect.reject ∈ (executeStatements environment globals input false values items integers booleans).effects ∧
      NoOutput (executeStatements environment globals input false values items integers booleans).effects := by
  have sound := statements_execution_sound (booleans := booleans) certified globalsFit
    wellFormed checked state printable allowed declaredState
  have reachable := sound.next.2.1
  have guaranteed : after.path.invalidRejected = true := by
    simpa only [completed, reachable, Bool.not_true, Bool.false_or] using finished
  have rejected := Context.invalid_rejection_required sound.next guaranteed
  constructor
  · simp only [rejectedAfter, Bool.false_or, List.any_eq_true] at rejected
    obtain ⟨effect, member, isRejection⟩ := rejected
    cases effect with
    | output bytes | put bytes => contradiction
    | reject => exact member
  · exact sound.invalid_no_output rfl

end Silver.Applications
