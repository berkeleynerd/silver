module

public import Silver.ComposeDecode
public import Silver.ComposeExecution
public import Silver.ComposeObligations
public import Silver.Cursor

@[expose] public section

/-! One current language: null plus the shared expression/shell grammar.
Every admitted source has one selected meaning. The explicit external tool
contract retains faithful obligation generation and bounded-fragment solver
completion; source membership never depends on the solver. -/

namespace Silver.Current

def Member (source : Source) : Prop := Silver.Member source ∨ Compose.Member source

def accepts (source : Source) : Bool := Silver.accepts source || Compose.accepts source

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, Member, Silver.accepts_iff_member, Compose.accepts_iff_member]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

inductive Program
  | nullMain
  | composed (program : Compose.Program)
  deriving DecidableEq, Repr

inductive SourceMeaning : Source → Program → Prop
  | nullMain {source : Source} : Silver.Member source → SourceMeaning source .nullMain
  | composed {source : Source} {form : Compose.Form} {events : List Compose.Event}
      {program : Compose.Program} :
      Compose.SourceMeaning source form events → Compose.decode form events = some program →
      SourceMeaning source (.composed program)

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ program, SourceMeaning source program := by
  rcases member with nullMember | outputMember
  · exact ⟨.nullMain, .nullMain nullMember⟩
  · obtain ⟨form, events, meaning⟩ := Compose.member_has_meaning outputMember
    obtain ⟨program, decoded, _⟩ := Compose.decoded_valid meaning
    exact ⟨.composed program, .composed meaning decoded⟩

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  cases first with
  | nullMain member =>
      cases second with
      | nullMain => rfl
      | composed meaning _ => exact False.elim (Compose.null_compose_disjoint source ⟨member, _, meaning.1⟩)
  | composed meaning decoded =>
      cases second with
      | nullMain member => exact False.elim (Compose.null_compose_disjoint source ⟨member, _, meaning.1⟩)
      | composed other otherDecoded =>
          obtain ⟨rfl, rfl⟩ := Compose.meaning_unique meaning other
          exact congrArg Program.composed (Option.some.inj (decoded.symm.trans otherDecoded))

theorem composed_valid {source : Source} {program : Compose.Program}
    (meaning : SourceMeaning source (.composed program)) : program.Valid := by
  cases meaning with
  | composed parsed decoded =>
      obtain ⟨other, same, valid⟩ := Compose.decoded_valid parsed
      have equal := Option.some.inj (decoded.symm.trans same)
      simpa [equal] using valid

def rangeObligations : Program → List Guarded.RangeObligation
  | .nullMain => []
  | .composed program => Compose.rangeObligations program

def checks : Program → List Compose.Check
  | .nullMain => []
  | .composed program => Compose.checks program

def obligations (program : Program) : List Semantics.Obligation :=
  (checks program).map Compose.Check.toObligation

def uniformObligations : List Semantics.Obligation :=
  Compose.uniformRangeObligations.map Guarded.RangeObligation.toObligation ++
    [Compose.Check.toObligation (.length ⟨.argument, .argument⟩)]

theorem uniform_discharge : Semantics.discharge uniformObligations = true := by decide +kernel

/-- The uniform range certificate and reflexive symbolic-length certificate
cover the two checked arithmetic forms. Source-specific obligations are proved
below to lie in that fragment, independently of external solver success. -/
def automaticDischarge (source : Source) : Option Bool :=
  if accepts source then some (Semantics.discharge uniformObligations) else none

theorem automatic_discharge_complete {source : Source} (member : Member source) :
    automaticDischarge source = some true := by
  simp [automaticDischarge, (accepts_iff_member source).mpr member, uniform_discharge]

def BoundedFragment (checks : List Compose.Check) : Prop :=
  ∀ check ∈ checks, check.InFragment

theorem admitted_fragment {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : BoundedFragment (checks program) := by
  cases program with
  | nullMain => simp [BoundedFragment, checks]
  | composed program => exact Compose.program_checks_fragment (composed_valid meaning)

theorem fragment_checks_valid {checks : List Compose.Check}
    (fragment : BoundedFragment checks) : ∀ check ∈ checks, check.Valid := by
  intro check member
  exact Compose.Check.fragment_valid (fragment check member)

theorem all_obligations_discharge {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    Semantics.discharge (obligations program) = true ∧
      ∃ steps, steps ≤ (obligations program).length + 1 ∧
        Semantics.DischargeSteps (obligations program) true steps := by
  have discharged : Semantics.discharge (obligations program) = true := by
    apply (Semantics.discharge_iff _).mpr
    intro check member
    obtain ⟨schema, present, rfl⟩ := List.mem_map.mp member
    exact (Compose.Check.discharge_iff _).mpr
      (fragment_checks_valid (admitted_fragment meaning) schema present)
  have steps := Semantics.discharge_terminates (obligations program)
  rw [discharged] at steps
  exact ⟨discharged, steps⟩

structure Environment where
  output : Output.Runtime.Environment
  arguments : Arguments.Runtime.Arguments

inductive Action
  | noOutput
  | output (item : Source)
  | reject
  deriving DecidableEq, Repr

/-- Fixed composition: initialization uses one immutable argument snapshot,
then the mandatory guard selects output or ordinary returning rejection. -/
def action (environment : Environment) : Program → Action
  | .nullMain => .noOutput
  | .composed program =>
      match program.action environment.arguments with
      | .reject => .reject
      | .output bytes => .output bytes

def executeAction (environment : Output.Runtime.Environment) : Action → Output.Runtime.ProcessResult
  | .noOutput => ⟨0, []⟩
  | .reject => ⟨1, []⟩
  | .output item => Output.Runtime.completeMain
      (Output.Runtime.execute environment item Output.Runtime.program [])

def execute (environment : Environment) (program : Program) : Output.Runtime.ProcessResult :=
  executeAction environment.output (action environment program)

def intendedBytes (environment : Environment) (program : Program) : Source :=
  match action environment program with
  | .noOutput | .reject => []
  | .output item => item ++ [10]

def expectedStatus (environment : Environment) (program : Program) : Nat :=
  match action environment program with
  | .reject => 1
  | _ => 0

def ActionOutcome (environment : Output.Runtime.Environment) : Action → Output.Runtime.ProcessResult → Prop
  | .noOutput, result => result = ⟨0, []⟩
  | .reject, result => result = ⟨1, []⟩
  | .output item, result =>
      if result.status = 0 then result.accepted = item ++ [10] ∧ environment.flushStatus = 0
      else result.status = 1 ∧ ∃ rest, result.accepted ++ rest = item ++ [10]

def SpecifiedOutcome (environment : Environment) (program : Program)
    (result : Output.Runtime.ProcessResult) : Prop :=
  ActionOutcome environment.output (action environment program) result

theorem action_execution_specified (environment : Output.Runtime.Environment) (selected : Action) :
    ActionOutcome environment selected (executeAction environment selected) := by
  cases selected with
  | noOutput | reject => rfl
  | output item =>
      cases result : Output.Runtime.execute environment item Output.Runtime.program [] with
      | returned bytes =>
          have facts := Output.Runtime.successful_output environment item bytes result
          simpa [executeAction, result, Output.Runtime.completeMain, ActionOutcome] using ⟨facts.2.1, facts.2.2⟩
      | failedReturn status bytes =>
          obtain ⟨rfl, acceptedPrefix⟩ := Output.Runtime.failed_output environment item bytes status result
          simpa [executeAction, result, Output.Runtime.completeMain, ActionOutcome] using acceptedPrefix

theorem execution_specified (environment : Environment) (program : Program) :
    SpecifiedOutcome environment program (execute environment program) :=
  action_execution_specified _ _

theorem action_domain {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Environment) (item : Source)
    (output : action environment program = .output item) :
    item.length ≤ 4096 ∧ ∀ byte ∈ item, Output.printable byte = true := by
  cases program with
  | nullMain => cases output
  | composed program =>
      cases selected : program.action environment.arguments with
      | reject => simp [action, selected] at output
      | output bytes =>
          have same : bytes = item := by simpa [action, selected] using output
          subst item
          exact Compose.action_domain (composed_valid meaning) environment.arguments selected

theorem healthy_execution {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Environment)
    (healthy : Output.Runtime.Healthy environment.output) :
    execute environment program = ⟨expectedStatus environment program, intendedBytes environment program⟩ := by
  cases selected : action environment program with
  | noOutput | reject => simp [execute, intendedBytes, expectedStatus, selected, executeAction]
  | output item =>
      have domain := action_domain meaning environment item selected
      have bytes : ∀ byte ∈ item, byte ≤ 255 := by
        intro byte member
        have bounded := domain.2 byte member
        simp only [Output.printable, decide_eq_true_eq] at bounded
        omega
      simp [execute, intendedBytes, expectedStatus, selected, executeAction,
        Output.Runtime.healthy_output environment.output healthy item domain.1 bytes, Output.Runtime.completeMain]

theorem admitted_assurance {source : Source} (member : Member source) :
    automaticDischarge source = some true ∧
    ∃ program, SourceMeaning source program ∧
      Semantics.discharge (obligations program) = true ∧
      (∃ steps, steps ≤ (obligations program).length + 1 ∧
        Semantics.DischargeSteps (obligations program) true steps) ∧
      ∀ environment, SpecifiedOutcome environment program (execute environment program) := by
  obtain ⟨program, meaning⟩ := member_has_meaning member
  have checked := all_obligations_discharge meaning
  exact ⟨automatic_discharge_complete member, program, meaning, checked.1, checked.2,
    fun environment => execution_specified environment program⟩

theorem every_meaning_assured {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    Semantics.discharge (obligations program) = true ∧
    (∃ steps, steps ≤ (obligations program).length + 1 ∧
      Semantics.DischargeSteps (obligations program) true steps) ∧
    ∀ environment, SpecifiedOutcome environment program (execute environment program) ∧
      (Output.Runtime.Healthy environment.output →
        execute environment program = ⟨expectedStatus environment program, intendedBytes environment program⟩) := by
  have checked := all_obligations_discharge meaning
  exact ⟨checked.1, checked.2, fun environment =>
    ⟨execution_specified environment program, healthy_execution meaning environment⟩⟩

structure Tools (Artifact : Type) where
  parse : Source → Program → Nat → Prop
  generate : Program → List Compose.Check → Nat → Prop
  prove : List Compose.Check → Nat → Prop
  verifyFixedLibrary : Nat → Prop
  build : Source → Artifact → Nat → Prop
  execute : Artifact → Environment → Output.Runtime.ProcessResult → Prop

/-- Completion marker for the fixed library's separately audited GNATprove run.
It is not a semantic contract or a proof that library verification succeeds:
ToolContract supplies completion separately from trusted compilation semantics. -/
def LibraryEvidence {Artifact : Type} (tools : Tools Artifact) : Program → Prop
  | .nullMain => True
  | .composed _ => ∃ steps, tools.verifyFixedLibrary steps

/-- Generic external-tool contracts, with no arbitrary-SPARK solver completeness.
Each generated check normalizes to a source concatenation range schema or an
exact-length schema for declaration initialization or assignment; emitted checks
may be simplified, repeated or omitted by optimization.
This relation does not certify the producer's obligation completeness, which
remains a trusted GNATprove premise audited through complete reports. The pinned
provers must complete on the concrete range and exact-length fragment. These facts
are external-tool premises, not results about their implementation or a measured
universal solver step bound. Compilation uses the same source as parsing, and preserves and realizes the
checked runtime semantics under the documented external-call interpretation. -/
structure ToolContract {Artifact : Type} (tools : Tools Artifact) : Prop where
  parseCompletes : ∀ source program, SourceMeaning source program →
    ∃ steps, tools.parse source program steps
  parseFaithful : ∀ source program steps, tools.parse source program steps →
    SourceMeaning source program
  generationCompletes : ∀ program, ∃ checks steps, tools.generate program checks steps
  generationFaithful : ∀ program checks steps, tools.generate program checks steps →
    ∀ check ∈ checks, ∃ schema ∈ Current.checks program, check.Refines schema
  boundedProofCompletes : ∀ checks, BoundedFragment checks →
    ∃ steps, tools.prove checks steps
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
  generate := fun program checks steps => checks = Current.checks program ∧ steps = 1
  prove := fun checks steps => BoundedFragment checks ∧ steps = checks.length + 1
  verifyFixedLibrary := fun steps => steps = 1
  build := fun source program steps => SourceMeaning source program ∧ steps = 1
  execute := fun program environment result => result = execute environment program

theorem model_tool_contract : ToolContract modelTools where
  parseCompletes := fun _ _ meaning => ⟨1, meaning, rfl⟩
  parseFaithful := fun _ _ _ parsed => parsed.1
  generationCompletes := fun program => ⟨Current.checks program, 1, rfl, rfl⟩
  generationFaithful := by
    intro program checks steps generated
    intro check member
    exact ⟨check, by simpa [generated.1] using member, Compose.Check.refines_refl _⟩
  boundedProofCompletes := fun checks fragment => ⟨checks.length + 1, fragment, rfl⟩
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
  | complete {source : Source} {program : Program} {checks : List Compose.Check}
      {artifact : Artifact} {parseSteps generateSteps proofSteps buildSteps : Nat} :
      tools.parse source program parseSteps → tools.generate program checks generateSteps →
      tools.prove checks proofSteps → LibraryEvidence tools program →
      tools.build source artifact buildSteps →
      Pipeline tools source artifact (parseSteps + generateSteps + proofSteps + buildSteps)

theorem generated_fragment {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} {program : Program}
    (meaning : SourceMeaning source program) {checks : List Compose.Check} {steps : Nat}
    (generated : tools.generate program checks steps) : BoundedFragment checks := by
  intro check member
  obtain ⟨schema, present, bounded⟩ := contract.generationFaithful program checks steps generated check member
  exact Compose.Check.fragment_of_refines bounded (admitted_fragment meaning schema present)

theorem automatic_pipeline {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} (member : Member source) :
    ∃ artifact steps, Pipeline tools source artifact steps := by
  obtain ⟨program, meaning⟩ := member_has_meaning member
  obtain ⟨parseSteps, parsed⟩ := contract.parseCompletes source program meaning
  obtain ⟨checks, generateSteps, generated⟩ := contract.generationCompletes program
  obtain ⟨proofSteps, proved⟩ := contract.boundedProofCompletes checks
    (generated_fragment contract meaning generated)
  obtain ⟨artifact, buildSteps, built⟩ := contract.buildCompletes source program parseSteps parsed
  have library : LibraryEvidence tools program := by
    cases program with
    | nullMain => trivial
    | composed => exact contract.fixedLibraryProofCompletes
  exact ⟨artifact, _, .complete parsed generated proved library built⟩

theorem pipeline_checks_valid {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} {program : Program}
    (meaning : SourceMeaning source program) {checks : List Compose.Check}
    {steps : Nat} (generated : tools.generate program checks steps) :
    ∀ check ∈ checks, check.Valid :=
  fragment_checks_valid (generated_fragment contract meaning generated)

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
        (Output.Runtime.Healthy environment.output →
          tools.execute artifact environment ⟨expectedStatus environment program, intendedBytes environment program⟩) := by
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
