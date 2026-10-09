import Silver.OutputAdmission
import Silver.OutputRuntime
import Silver.Semantics

/-! One current language, two productions. The obligation model assigns an
empty list to both application forms. Agreement with GNATprove's actual
obligation generation is an explicit ToolContract premise, checked per compile;
this module is not a verified Ada/SPARK obligation generator. The fixed library
body retains its separately audited obligations. -/

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

/-- The first nontrivia token is `procedure` or `with`, never both. -/
theorem member_disjoint (source : Source) : ¬ (Silver.Member source ∧ Output.Member source) := by
  rintro ⟨nullMember, outputMember⟩
  have nullParsed := (Cursor.isMember_iff source).mpr nullMember
  change (_ && _ && (Cursor.tokenAt source (Cursor.triviaPosition source 1)
    .procedureKeyword && _)) = true at nullParsed
  simp only [Bool.and_eq_true] at nullParsed
  have nullToken := nullParsed.2.1
  obtain ⟨literal, parsed⟩ := outputMember.2.2.2
  cases parsed with
  | token different matched rest =>
      simp only [Cursor.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at nullToken
      simp only [Output.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at matched
      have firstNull := nullToken.1.2 ⟨0, by decide⟩
      have firstOutput := matched.1.2 ⟨0, by decide⟩
      simp [Silver.Token.spelling, Output.Token.spelling, Output.Token.spellingText] at firstNull firstOutput
      omega

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  cases first with
  | nullMain member =>
      cases second with
      | nullMain => rfl
      | outputMain outputMember parsed => exact False.elim (member_disjoint source ⟨member, outputMember⟩)
  | outputMain member parsed =>
      cases second with
      | nullMain nullMember => exact False.elim (member_disjoint source ⟨nullMember, member⟩)
      | outputMain outputMember other =>
          have same := Output.parsed_unique parsed other
          simpa using congrArg Program.outputMain (List.cons.inj same).1

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

def execute (environment : Output.Runtime.Environment) : Program → Output.Runtime.ProcessResult
  | .nullMain => ⟨0, []⟩
  | .outputMain literal => Output.Runtime.completeMain
      (Output.Runtime.execute environment literal Output.Runtime.program [])

def intendedBytes : Program → Source
  | .nullMain => []
  | .outputMain literal => literal ++ [10]

def SpecifiedOutcome (environment : Output.Runtime.Environment) (program : Program)
    (result : Output.Runtime.ProcessResult) : Prop :=
  if result.status = 0 then result.accepted = intendedBytes program ∧
      (∀ literal, program = .outputMain literal → environment.flushStatus = 0)
  else result.status = 1 ∧ ∃ rest, result.accepted ++ rest = intendedBytes program

theorem execution_specified (environment : Output.Runtime.Environment) (program : Program) :
    SpecifiedOutcome environment program (execute environment program) := by
  cases program with
  | nullMain => simp [execute, SpecifiedOutcome, intendedBytes]
  | outputMain literal =>
      cases result : Output.Runtime.execute environment literal Output.Runtime.program [] with
      | returned bytes =>
          have facts := Output.Runtime.successful_output environment literal bytes result
          simpa [execute, result, Output.Runtime.completeMain, SpecifiedOutcome, intendedBytes]
            using ⟨facts.2.1, facts.2.2⟩
      | failedReturn status bytes =>
          obtain ⟨rfl, acceptedPrefix⟩ := Output.Runtime.failed_output environment literal bytes status result
          simpa [execute, result, Output.Runtime.completeMain, SpecifiedOutcome, intendedBytes]
            using acceptedPrefix

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
    execute environment program = ⟨0, intendedBytes program⟩ := by
  cases program with
  | nullMain => rfl
  | outputMain literal =>
      have output := Output.Runtime.healthy_output environment healthy literal
        (literal_domain meaning).1 (by
          intro byte member
          have bounds := (literal_domain meaning).2 byte member
          simp only [Output.printable, decide_eq_true_eq] at bounds
          omega)
      simp [execute, output, Output.Runtime.completeMain, intendedBytes]

/-- Every interpretation of every admitted source receives the guarantee. -/
theorem every_meaning_assured {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    obligations program = [] ∧ Semantics.DischargeSteps (obligations program) true 1 ∧
    ∀ environment, SpecifiedOutcome environment program (execute environment program) ∧
      (Output.Runtime.Healthy environment →
        execute environment program = ⟨0, intendedBytes program⟩) := by
  exact ⟨obligations_empty program, (all_obligations_discharge program).2,
    fun environment => ⟨execution_specified environment program,
      healthy_execution meaning environment⟩⟩

structure Tools (Artifact : Type) where
  parse : Source → Program → Nat → Prop
  generate : Program → List Semantics.Obligation → Nat → Prop
  prove : List Semantics.Obligation → Nat → Prop
  verifyFixedLibrary : Nat → Prop
  build : Source → Artifact → Nat → Prop
  execute : Artifact → Output.Runtime.Environment → Output.Runtime.ProcessResult → Prop

/-- Completion marker for the fixed library's separately audited GNATprove run.
It is not a semantic contract or a proof that library verification succeeds:
ToolContract supplies completion separately from trusted compilation semantics. -/
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

/-- An explicit model of the interface shows its premises are jointly
inhabited. It is not an implementation or verification of the external tools. -/
def modelTools : Tools Program where
  parse := fun source program steps => SourceMeaning source program ∧ steps = 1
  generate := fun program checks steps => checks = obligations program ∧ steps = 1
  prove := fun checks steps => checks = [] ∧ steps = 1
  verifyFixedLibrary := fun steps => steps = 1
  build := fun source program steps => SourceMeaning source program ∧ steps = 1
  execute := fun program environment result => result = execute environment program

theorem model_tool_contract : ToolContract modelTools where
  parseCompletes := fun _ _ meaning => ⟨1, meaning, rfl⟩
  parseFaithful := fun _ _ _ parsed => parsed.1
  generationCompletes := fun _ => ⟨1, rfl, rfl⟩
  generationFaithful := fun _ _ _ generated => generated.1
  emptyProofCompletes := ⟨1, rfl, rfl⟩
  fixedLibraryProofCompletes := ⟨1, rfl⟩
  buildCompletes := fun _ program _ parsed => ⟨program, 1, parsed.1, rfl⟩
  compilationPreserves := by
    intro source program artifact steps meaning built environment result executed
    have same := meaning_unique meaning built.1
    simpa [modelTools, same] using executed
  compilationRealizes := by
    intro source program artifact steps meaning built environment
    have same := meaning_unique meaning built.1
    simp [modelTools, same]

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
          tools.execute artifact environment ⟨0, intendedBytes program⟩) := by
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
