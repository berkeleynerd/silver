import Silver.OutputAdmission
import Silver.OutputRuntime
import Silver.Semantics

/-! One current language, two productions. User calls have no public precondition,
constrained formal or dynamic literal evaluation; their user obligation set is
empty. The fixed library body retains its separately audited obligations. -/

namespace Silver.Current

def Member (source : Source) : Prop := Silver.Member source ∨ Output.Member source
def accepts (source : Source) : Bool := Silver.accepts source || Output.accepts source

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, Member, Silver.accepts_iff_member, Output.accepts_iff_member]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

inductive Program
  | nullMain
  | outputMain (literal : Source)
  deriving DecidableEq, Repr

inductive SourceMeaning : Source → Program → Prop
  | nullMain {source : Source} : Silver.Member source → SourceMeaning source .nullMain
  | outputMain {source literal : Source} :
      Output.Member source → Output.Parsed source Output.requiredTokens 1 [literal] →
      SourceMeaning source (.outputMain literal)

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ program, SourceMeaning source program := by
  rcases member with nullMember | outputMember
  · exact ⟨.nullMain, .nullMain nullMember⟩
  · obtain ⟨literal, parsed⟩ := outputMember.2.2.2
    exact ⟨.outputMain literal, .outputMain outputMember parsed⟩

theorem literal_domain {source literal : Source}
    (meaning : SourceMeaning source (.outputMain literal)) :
    literal.length ≤ 4096 ∧ ∀ byte ∈ literal, Output.printable byte = true := by
  cases meaning with
  | outputMain member parsed =>
      have facts := (Output.parsed_literals parsed).2 literal (by simp)
      exact ⟨Nat.le_trans facts.1 member.2.1, facts.2⟩

def obligations : Program → List Semantics.Obligation
  | .nullMain => []
  | .outputMain _ => []

theorem obligations_empty (program : Program) : obligations program = [] := by
  cases program <;> rfl

def automaticDischarge (source : Source) : Option Bool :=
  if accepts source then some (Semantics.discharge []) else none

theorem automatic_discharge_complete {source : Source} (member : Member source) :
    automaticDischarge source = some true := by
  simp [automaticDischarge, (accepts_iff_member source).mpr member, Semantics.discharge]

theorem all_obligations_discharge (program : Program) :
    Semantics.discharge (obligations program) = true ∧
      Semantics.DischargeSteps (obligations program) true 1 := by
  rw [obligations_empty]
  exact ⟨rfl, .done⟩

def execute (environment : Output.Runtime.Environment) : Program → Output.Runtime.Result
  | .nullMain => .returned []
  | .outputMain literal => Output.Runtime.execute environment literal Output.Runtime.program []

def intendedBytes : Program → Source
  | .nullMain => []
  | .outputMain literal => literal ++ [10]

def SpecifiedOutcome (environment : Output.Runtime.Environment) (program : Program) :
    Output.Runtime.Result → Prop
  | .returned bytes => bytes = intendedBytes program ∧
      (∀ literal, program = .outputMain literal → environment.flushStatus = 0)
  | .exited status bytes => status = 1 ∧ ∃ rest, bytes ++ rest = intendedBytes program

theorem execution_specified (environment : Output.Runtime.Environment) (program : Program) :
    SpecifiedOutcome environment program (execute environment program) := by
  cases program with
  | nullMain => simp [execute, SpecifiedOutcome, intendedBytes]
  | outputMain literal =>
      cases result : Output.Runtime.execute environment literal Output.Runtime.program [] with
      | returned bytes =>
          have facts := Output.Runtime.successful_output environment literal bytes result
          simpa [execute, result, SpecifiedOutcome, intendedBytes] using ⟨facts.2.1, facts.2.2⟩
      | exited status bytes =>
          simpa [execute, result, SpecifiedOutcome, intendedBytes] using
            Output.Runtime.failed_output environment literal bytes status result

/-- Total finite execution for completed external replies. Physical call
progress, SIGPIPE behavior and actual emission remain environmental premises. -/
theorem admitted_assurance {source : Source} (member : Member source) :
    automaticDischarge source = some true ∧
    ∃ program, SourceMeaning source program ∧ obligations program = [] ∧
      Semantics.DischargeSteps (obligations program) true 1 ∧
      ∀ environment, SpecifiedOutcome environment program (execute environment program) := by
  obtain ⟨program, meaning⟩ := member_has_meaning member
  exact ⟨automatic_discharge_complete member, program, meaning, obligations_empty program,
    (all_obligations_discharge program).2, fun environment => execution_specified environment program⟩

theorem healthy_execution {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Output.Runtime.Environment)
    (healthy : Output.Runtime.Healthy environment) :
    execute environment program = .returned (intendedBytes program) := by
  cases program with
  | nullMain => rfl
  | outputMain literal =>
      apply Output.Runtime.healthy_output environment healthy literal (literal_domain meaning).1
      intro byte member
      have bounds := (literal_domain meaning).2 byte member
      simp only [Output.printable, decide_eq_true_eq] at bounds
      omega

/-- Every interpretation of every admitted source receives the guarantee. -/
theorem every_meaning_assured {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    obligations program = [] ∧ Semantics.DischargeSteps (obligations program) true 1 ∧
    ∀ environment, SpecifiedOutcome environment program (execute environment program) ∧
      (Output.Runtime.Healthy environment →
        execute environment program = .returned (intendedBytes program)) := by
  exact ⟨obligations_empty program, (all_obligations_discharge program).2,
    fun environment => ⟨execution_specified environment program,
      healthy_execution meaning environment⟩⟩

structure Tools (Artifact : Type) where
  parse : Source → Program → Nat → Prop
  generate : Program → List Semantics.Obligation → Nat → Prop
  prove : List Semantics.Obligation → Nat → Prop
  verifyFixedLibrary : Nat → Prop
  build : Source → Artifact → Nat → Prop
  execute : Artifact → Output.Runtime.Environment → Output.Runtime.Result → Prop

/-- This evidence concerns the one fixed library specification/body pair. Its
GNATprove discharge is separately audited; it is not assumed from membership. -/
def LibraryEvidence {Artifact : Type} (tools : Tools Artifact) : Program → Prop
  | .nullMain => True
  | .outputMain _ => ∃ steps, tools.verifyFixedLibrary steps

/-- Generic external-tool contracts, with no arbitrary-SPARK solver completeness.
Compilation uses the same source as parsing, and preserves and realizes the
checked runtime semantics under the documented external-call interpretation. -/
structure ToolContract {Artifact : Type} (tools : Tools Artifact) : Prop where
  parseCompletes : ∀ source program, SourceMeaning source program →
    ∃ steps, tools.parse source program steps
  parseFaithful : ∀ source program steps, tools.parse source program steps →
    SourceMeaning source program
  generationCompletes : ∀ program, ∃ steps, tools.generate program (obligations program) steps
  generationFaithful : ∀ program checks steps, tools.generate program checks steps →
    checks = obligations program
  emptyProofCompletes : ∃ steps, tools.prove [] steps
  fixedLibraryProofCompletes : ∃ steps, tools.verifyFixedLibrary steps
  buildCompletes : ∀ source program steps, tools.parse source program steps →
    ∃ artifact buildSteps, tools.build source artifact buildSteps
  compilationPreserves : ∀ source program artifact buildSteps,
    SourceMeaning source program → tools.build source artifact buildSteps →
    ∀ environment result, tools.execute artifact environment result →
      result = execute environment program
  compilationRealizes : ∀ source program artifact buildSteps,
    SourceMeaning source program → tools.build source artifact buildSteps →
    ∀ environment, tools.execute artifact environment (execute environment program)

inductive Pipeline {Artifact : Type} (tools : Tools Artifact) : Source → Artifact → Nat → Prop
  | complete {source : Source} {program : Program} {checks : List Semantics.Obligation}
      {artifact : Artifact} {parseSteps generateSteps proofSteps buildSteps : Nat} :
      tools.parse source program parseSteps → tools.generate program checks generateSteps →
      tools.prove checks proofSteps → LibraryEvidence tools program →
      tools.build source artifact buildSteps →
      Pipeline tools source artifact (parseSteps + generateSteps + proofSteps + buildSteps)

theorem automatic_pipeline {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} (member : Member source) :
    ∃ artifact steps, Pipeline tools source artifact steps := by
  obtain ⟨program, meaning⟩ := member_has_meaning member
  obtain ⟨parseSteps, parsed⟩ := contract.parseCompletes source program meaning
  obtain ⟨generateSteps, generated⟩ := contract.generationCompletes program
  obtain ⟨proofSteps, proved⟩ := contract.emptyProofCompletes
  obtain ⟨artifact, buildSteps, built⟩ := contract.buildCompletes source program parseSteps parsed
  have library : LibraryEvidence tools program := by
    cases program with
    | nullMain => trivial
    | outputMain => exact contract.fixedLibraryProofCompletes
  rw [obligations_empty] at generated
  exact ⟨artifact, _, .complete parsed generated proved library built⟩

theorem pipeline_obligations_empty {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {program : Program} {checks : List Semantics.Obligation}
    {steps : Nat} (generated : tools.generate program checks steps) : checks = [] := by
  rw [contract.generationFaithful program checks steps generated, obligations_empty]

theorem pipeline_preserves {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} {artifact : Artifact} {steps : Nat}
    (pipeline : Pipeline tools source artifact steps) :
    ∃ program, SourceMeaning source program ∧ LibraryEvidence tools program ∧
      ∀ environment result, tools.execute artifact environment result →
        SpecifiedOutcome environment program result := by
  cases pipeline with
  | complete parsed generated proved library built =>
      have meaning := contract.parseFaithful _ _ _ parsed
      refine ⟨_, meaning, library, ?_⟩
      intro environment result executed
      rw [contract.compilationPreserves _ _ _ _ meaning built environment result executed]
      exact execution_specified environment _

theorem pipeline_realizes {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} {artifact : Artifact} {steps : Nat}
    (pipeline : Pipeline tools source artifact steps) :
    ∃ program, SourceMeaning source program ∧
      ∀ environment, tools.execute artifact environment (execute environment program) ∧
        (Output.Runtime.Healthy environment →
          tools.execute artifact environment (.returned (intendedBytes program))) := by
  cases pipeline with
  | complete parsed generated proved library built =>
      have meaning := contract.parseFaithful _ _ _ parsed
      refine ⟨_, meaning, ?_⟩
      intro environment
      have actual := contract.compilationRealizes _ _ _ _ meaning built environment
      refine ⟨actual, ?_⟩
      intro healthy
      simpa [healthy_execution meaning environment healthy] using actual

end Silver.Current
