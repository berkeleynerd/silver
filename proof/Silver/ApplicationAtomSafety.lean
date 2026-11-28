module

public import Silver.ApplicationExecution

@[expose] public section

/-! Ordinary leaf safety is reused with the complete Main expression state.
The extra package-state invariant follows from the checked library at the
exact resolved procedure identity and already-checked input tuple. -/
namespace Silver.Applications
open Bindings Compose Predicate
open ScalarFunctions (Frame)

structure ExecutionSound (schema : Packages.StateSchema) (shape : Shape) (analysis : Integer.Analysis)
    (flow : Flow) (input : Source) (valid beforeRejected : Bool)
    (result : Execution) (ordinary : Option Execution) : Prop where
  state : Fits shape input result.values
  effects : Sequence.EffectsValid result.effects
  invalid_no_output : valid = false → NoOutput result.effects
  next : flow.path.Allows valid input.length (rejectedAfter beforeRejected result.effects)
  agreement : ordinary = some result
  scalars : Integer.Fits flow.scalars result.integers
  declared : Integer.Fits analysis.declared result.integers
  globals : schema.Fits result.globals

theorem atomGlobals_fits {schema : Packages.StateSchema} {environment : Environment} {globals : Frame}
    {shape : Shape} {analysis : Integer.Analysis} {before after : Flow} {hasArguments : Bool}
    {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
    {item : Predicate.Statement} {input : Source} {values : Values} {valid rejected : Bool}
    (certified : environment.Valid schema) (globalsFit : schema.Fits globals)
    (wellFormed : item.WellFormed hasArguments shape booleanAnalysis)
    (checked : item.check (signatures := environment.functionSignatures)
      (procedures := environment.procedureSignatures) shape analysis before booleanAnalysis = some after)
    (state : Fits shape input values) (allowed : before.Allows valid input.length rejected integers) :
    schema.Fits (atomGlobals environment globals ⟨values, input, valid, integers, booleans⟩ item) := by
  cases item <;> try exact globalsFit
  case procedureCall call =>
    simp only [Predicate.Statement.WellFormed] at wellFormed
    simp only [Predicate.Statement.check] at checked
    split at checked
    · rename_i accepted
      obtain ⟨resolved, found, _, inputs, _⟩ := call.check_success accepted
      have bound := call.resolve_success found
      have readable := ScalarProcedures.bindActuals_inputs_readable wellFormed bound.2
      have actuals := ScalarFunctions.checkActuals_sound (state := ⟨values, input, valid, integers, booleans⟩)
        state readable allowed inputs
      simpa only [atomGlobals, procedureGlobals, found] using
        (environment.invokeProcedure_valid certified globalsFit bound.1 actuals.2).1
    · contradiction

theorem atom_execution_sound {schema : Packages.StateSchema} {environment : Environment} {globals : Frame}
    {shape : Shape} {analysis : Integer.Analysis} {before after : Flow} {hasArguments : Bool}
    {booleanAnalysis : Boolean.Analysis} {integers : Integer.Store} {booleans : Boolean.Store}
    {item : Predicate.Statement} {input : Source} {values : Values} {valid rejected : Bool}
    (certified : environment.Valid schema) (globalsFit : schema.Fits globals)
    (wellFormed : item.WellFormed hasArguments shape booleanAnalysis)
    (checked : item.check (signatures := environment.functionSignatures)
      (procedures := environment.procedureSignatures) shape analysis before booleanAnalysis = some after)
    (state : Fits shape input values) (printable : Bindings.Printable input)
    (allowed : before.Allows valid input.length rejected integers)
    (declaredState : Integer.Fits analysis.declared integers) :
    ExecutionSound schema shape analysis after input valid rejected
      (executeAtom environment globals input valid values integers booleans item)
      (checkedAtom environment globals input valid values integers booleans item) := by
  have ordinary := Predicate.statement_execution_sound_with_procedures
    (booleans := booleans)
    (environment.functionsAt_valid certified globalsFit) (environment.proceduresAt_valid certified globalsFit)
    wellFormed checked state printable allowed declaredState
  refine ⟨ordinary.state, ordinary.effects, ordinary.invalid_no_output, ordinary.next,
    ?_, ordinary.scalars, ordinary.declared,
    atomGlobals_fits certified globalsFit wellFormed checked state allowed⟩
  simp only [checkedAtom, ordinary.agreement, Option.map_some, executeAtom]

end Silver.Applications
