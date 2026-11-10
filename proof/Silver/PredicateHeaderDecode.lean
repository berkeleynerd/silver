module

public import Silver.PredicateBodyAdmission
public import Silver.ComposeDecode
public import Silver.SequenceContext

@[expose] public section

/-! Decoding the shared header retains ordered String, Integer and Boolean
declarations and the original initializer checks. The body receives the
resulting declared scalar ranges and initialized Boolean mutability metadata. -/
namespace Silver.Predicate
open Compose Bindings PathFacts

def decodePrefix (form : Form) (events : List Event) (items : List SourceStatement)
    (integerDeclarations : List Integer.Declaration := [])
    (integerConstants : Integer.Constants := [])
    (initializerChecks : List Integer.Obligation := []) (arrays : ArrayBindings.Env := {})
    (booleans : List BooleanDeclaration := []) (booleanChecks : List Obligation := [])
    (functions : List ScalarFunctions.Definition := [])
    (procedures : List ScalarProcedures.Definition := []) : Option Program :=
  match form, events with
  | .direct, [.declarations values names] => some ⟨values, names, [], false, lowerStatements items, integerDeclarations, integerConstants, initializerChecks, arrays, booleans, booleanChecks, functions, procedures⟩
  | .argument, [.argument fallback, .declarations values names] =>
      some ⟨argumentDeclaration :: values, names, fallback, true, lowerStatements items, integerDeclarations, integerConstants, initializerChecks, arrays, booleans, booleanChecks, functions, procedures⟩
  | _, _ => none

theorem prefix_decoded_valid (form : Form) (events : List Event) (items : List SourceStatement)
    (integerDeclarations : List Integer.Declaration) (integerConstants : Integer.Constants)
    (initializerChecks : List Integer.Obligation) (arrays : ArrayBindings.Env)
    (booleans : List BooleanDeclaration) (booleanChecks : List Obligation)
    (functions : List ScalarFunctions.Definition)
    (functionsChecked : ScalarFunctions.DefinitionsChecked [] functions)
    (procedures : List ScalarProcedures.Definition)
    (proceduresChecked : ScalarProcedures.DefinitionsChecked (functions.map ScalarFunctions.Definition.signature) [] procedures)
    (booleanValid : BooleanDeclarationsWellFormed form.hasArguments
      (Sequence.eventsContext (emptyShape, maxSourceLength) events).1 {} booleans)
    (booleanChecked : checkBooleanDeclarations
      (Sequence.eventsContext (emptyShape, maxSourceLength) events).1 Integer.Analysis.empty
      ⟨initialFacts form.hasArguments, Integer.emptyRanges⟩ {} booleans = true)
    (booleanDischarged : discharged booleanChecks = true)
    (arraysValid : ArrayBindings.ValidInitials arrays.values)
    (arraysFit : ArrayBindings.InitialsFit arrays.names arrays.values)
    (shape : events.map Event.kind = form.prefix.filterMap ShellToken.eventKind)
    (stream : StreamValid emptyShape maxSourceLength events)
    (nonempty : items ≠ [])
    (body : SourceStatementsWellFormed form.hasArguments
      (Sequence.eventsContext (emptyShape, maxSourceLength) events).1 items (booleanBodyAnalysis booleans))
    (checked : ∃ after, checkStatements (signatures := functions.map ScalarFunctions.Definition.signature)
      (procedures := procedures.map ScalarProcedures.Definition.signature) (Sequence.eventsContext (emptyShape, maxSourceLength) events).1
      (ArrayFlow.analysis arrays.names (Integer.Analysis.ofDeclarations integerDeclarations))
      (Flow.initial (ArrayFlow.analysis arrays.names (Integer.Analysis.ofDeclarations integerDeclarations)) (initialFacts form.hasArguments))
      (lowerStatements items) (booleanBodyAnalysis booleans) = some after ∧ completed after.path = true)
    (scalars : Integer.checkDeclarations [] integerDeclarations = some integerConstants)
    (initializers : Integer.discharged initializerChecks = true) :
    ∃ program, decodePrefix form events items integerDeclarations integerConstants initializerChecks arrays booleans booleanChecks functions procedures = some program ∧ program.Valid := by
  cases form with
  | direct =>
      change events.map Event.kind = [.declarations] at shape
      obtain ⟨values, names, rest, rfl, shape0⟩ := (declarations_event_shape _ _).mp shape
      have empty := List.map_eq_nil_iff.mp shape0
      subst rest
      refine ⟨⟨values, names, [], false, lowerStatements items, integerDeclarations, integerConstants, initializerChecks, arrays, booleans, booleanChecks, functions, procedures⟩, rfl, ?_⟩
      refine ⟨⟨stream.1, booleanValid, booleanChecked, booleanDischarged, functionsChecked, by simpa only [Program.functionEnvironment, ScalarFunctions.compileDefinitions_signatures] using proceduresChecked⟩, by simp [Bindings.Printable], by simp [maxSourceLength],
        lowerStatements_nonempty nonempty, lowerStatements_wellFormed body, ?_⟩
      obtain ⟨after, bodyChecked, completed⟩ := checked
      exact ⟨after, (Program.checkBody_iff _ after).mpr ⟨scalars, initializers, ⟨arraysValid, arraysFit⟩, by simpa [Program.functionEnvironment, Program.procedureEnvironment, ScalarFunctions.compileDefinitions_signatures,
        ScalarProcedures.compileDefinitions_signatures, Program.bodyAnalysis, Program.initialFlow, Program.initialContext,
        Program.bodyBooleanAnalysis, Sequence.eventsContext, Sequence.eventContext, Form.hasArguments, initialFacts] using bodyChecked⟩, completed⟩
  | argument =>
      change events.map Event.kind = [.argument, .declarations] at shape
      obtain ⟨fallback, rest, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨values, names, rest, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      have empty := List.map_eq_nil_iff.mp shape1
      subst rest
      refine ⟨⟨argumentDeclaration :: values, names, fallback, true, lowerStatements items, integerDeclarations, integerConstants, initializerChecks, arrays, booleans, booleanChecks, functions, procedures⟩, rfl, ?_⟩
      refine ⟨⟨prepend_argument stream.2.2.1, booleanValid, booleanChecked, booleanDischarged, functionsChecked, by simpa only [Program.functionEnvironment, ScalarFunctions.compileDefinitions_signatures] using proceduresChecked⟩, stream.1, stream.2.1,
        lowerStatements_nonempty nonempty, lowerStatements_wellFormed body, ?_⟩
      obtain ⟨after, bodyChecked, completed⟩ := checked
      exact ⟨after, (Program.checkBody_iff _ after).mpr ⟨scalars, initializers, ⟨arraysValid, arraysFit⟩, by simpa [Program.functionEnvironment, Program.procedureEnvironment, ScalarFunctions.compileDefinitions_signatures,
        ScalarProcedures.compileDefinitions_signatures, Program.bodyAnalysis, Program.initialFlow, Program.initialContext,
        Program.bodyBooleanAnalysis, Sequence.eventsContext, Sequence.eventContext, Form.hasArguments, initialFacts] using bodyChecked⟩, completed⟩


theorem decoded_initializer_checks {form events items scalars constants checks arrays booleans booleanChecks functions procedures program}
    (decoded : decodePrefix form events items scalars constants checks arrays booleans booleanChecks functions procedures = some program) :
    program.initializerChecks = checks := by
  unfold decodePrefix at decoded
  split at decoded <;> cases decoded <;> rfl

theorem decoded_integer_state {form events items scalars constants checks arrays booleans booleanChecks functions procedures program}
    (decoded : decodePrefix form events items scalars constants checks arrays booleans booleanChecks functions procedures = some program) :
    program.integerConstants = constants ∧ program.arrays = arrays := by
  unfold decodePrefix at decoded
  split at decoded <;> cases decoded <;> exact ⟨rfl, rfl⟩


theorem decoded_boolean_state {form events items scalars constants checks arrays booleans booleanChecks functions procedures program}
    (decoded : decodePrefix form events items scalars constants checks arrays booleans booleanChecks functions procedures = some program) :
    program.booleanDeclarations = booleans ∧ program.booleanInitializerChecks = booleanChecks := by
  unfold decodePrefix at decoded
  split at decoded <;> cases decoded <;> exact ⟨rfl, rfl⟩

theorem decoded_functions {form events items scalars constants checks arrays booleans booleanChecks functions procedures program}
    (decoded : decodePrefix form events items scalars constants checks arrays booleans booleanChecks functions procedures = some program) :
    program.functions = functions := by
  unfold decodePrefix at decoded
  split at decoded <;> cases decoded <;> rfl

/-- Metadata selected for reports and execution denotes the same declared
procedure sequence carried by the source meaning. -/
theorem decoded_procedures {form events items scalars constants checks arrays booleans booleanChecks functions procedures program}
    (decoded : decodePrefix form events items scalars constants checks arrays booleans booleanChecks functions procedures = some program) :
    program.procedures = procedures := by
  unfold decodePrefix at decoded
  split at decoded <;> cases decoded <;> rfl

end Silver.Predicate
