module

public import Silver.PredicateStringActualAssurance
public import Silver.PredicateGrammar
public import Silver.Cursor

@[expose] public section

/-! One current language: null plus path-checked predicate statements. Every admitted
source has one selected meaning. The explicit external tool contract retains
faithful obligation generation and bounded-fragment solver completion; source
membership never depends on the solver. -/

namespace Silver.Current

def Member (source : Source) : Prop := Silver.Member source ∨ Predicate.Member source

def accepts (source : Source) : Bool := Silver.accepts source || Predicate.accepts source

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, Member, Silver.accepts_iff_member, Predicate.accepts_iff_member]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

inductive Program
  | nullMain
  | sequence (program : Predicate.Program)
  deriving Repr

inductive SourceMeaning : Source → Program → Prop
  | nullMain {source : Source} : Silver.Member source → SourceMeaning source .nullMain
  | sequence {source : Source} {program : Predicate.Program} :
      Predicate.SourceMeaning source program → SourceMeaning source (.sequence program)

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ program, SourceMeaning source program := by
  rcases member with nullMember | sequenceMember
  · exact ⟨.nullMain, .nullMain nullMember⟩
  · obtain ⟨program, meaning⟩ := Predicate.member_has_meaning sequenceMember
    exact ⟨.sequence program, .sequence meaning⟩

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  cases first with
  | nullMain member =>
      cases second with
      | nullMain => rfl
      | sequence meaning =>
          exact False.elim (Predicate.null_predicate_disjoint source ⟨member, Predicate.meaning_member meaning⟩)
  | sequence meaning =>
      cases second with
      | nullMain member =>
          exact False.elim (Predicate.null_predicate_disjoint source ⟨member, Predicate.meaning_member meaning⟩)
      | sequence other => exact congrArg Program.sequence (Predicate.meaning_unique meaning other)

theorem sequence_valid {source : Source} {program : Predicate.Program}
    (meaning : SourceMeaning source (.sequence program)) : program.Valid := by
  cases meaning with
  | sequence parsed => exact Predicate.meaning_valid parsed

def checks : Program → List Predicate.Check
  | .nullMain => []
  | .sequence program => program.checks

def obligations (program : Program) : List Semantics.Obligation :=
  (checks program).map Predicate.Check.toObligation

def uniformObligations : List Semantics.Obligation :=
  Compose.uniformRangeObligations.map Guarded.RangeObligation.toObligation ++
    [Compose.Check.toObligation (.length ⟨Bindings.Bound.argument.summary, Bindings.Bound.argument.summary⟩)]

theorem uniform_discharge : Semantics.discharge uniformObligations = true := by decide +kernel

/-- Admission supplies the complete source-derived endpoint certificate. This
small decision retains the declaration certificate; all source-specific
path schemas are separately proved discharged below. It does not invoke or
predict the external solver. -/
def automaticDischarge (source : Source) : Option Bool :=
  if accepts source then some (Semantics.discharge uniformObligations) else none

theorem automatic_discharge_complete {source : Source} (member : Member source) :
    automaticDischarge source = some true := by
  simp [automaticDischarge, (accepts_iff_member source).mpr member, uniform_discharge]

def BoundedFragment (checks : List Predicate.Check) : Prop :=
  ∀ check ∈ checks, check.InFragment

theorem admitted_fragment {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : BoundedFragment (checks program) := by
  cases program with
  | nullMain => simp [BoundedFragment, checks]
  | sequence program => exact Predicate.Program.checks_fragment (sequence_valid meaning)

theorem fragment_checks_valid {checks : List Predicate.Check}
    (fragment : BoundedFragment checks) : ∀ check ∈ checks, check.Valid := by
  intro check member
  exact Predicate.Check.fragment_valid (fragment check member)

theorem all_obligations_discharge {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    Semantics.discharge (obligations program) = true ∧
      ∃ steps, steps ≤ (obligations program).length + 1 ∧
        Semantics.DischargeSteps (obligations program) true steps := by
  have discharged : Semantics.discharge (obligations program) = true := by
    apply (Semantics.discharge_iff _).mpr
    intro check member
    obtain ⟨schema, present, rfl⟩ := List.mem_map.mp member
    exact Predicate.Check.fragment_discharge (admitted_fragment meaning schema present)
  have steps := Semantics.discharge_terminates (obligations program)
  rw [discharged] at steps
  exact ⟨discharged, steps⟩

abbrev Environment := Sequence.Environment

def SourceBoundsRefinement (source : Source) : Program → Prop
  | .nullMain => True
  | .sequence program => Predicate.SourceBoundsRefinement source program

def StringBoundsSafe (source : Source) (environment : Environment) : Program → Prop
  | .nullMain => True
  | .sequence program => program.CompleteStringBoundsSafe source environment.arguments

theorem source_string_bounds_assured {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    SourceBoundsRefinement source program ∧ ∀ environment, StringBoundsSafe source environment program := by
  cases meaning with
  | nullMain => exact ⟨trivial, fun _ => trivial⟩
  | sequence meaning =>
      have assured := Predicate.source_actual_string_bounds_assured meaning
      exact ⟨assured.1, fun environment => assured.2 environment.arguments⟩

def effects (environment : Environment) : Program → List Sequence.Effect
  | .nullMain => []
  | .sequence program => (program.execute environment.arguments).effects

def execute (environment : Environment) (program : Program) : Output.Runtime.ProcessResult :=
  Sequence.executeEffects environment.output 0 (effects environment program)

def intendedBytes (environment : Environment) (program : Program) : Source :=
  Sequence.intendedEffectBytes (effects environment program)

def expectedStatus (environment : Environment) (program : Program) : Nat :=
  Sequence.expectedEffectStatus (effects environment program)

def SpecifiedOutcome (environment : Environment) (program : Program)
    (result : Output.Runtime.ProcessResult) : Prop :=
  Sequence.TraceOutcome environment.output 0 (effects environment program) result

theorem execution_specified (environment : Environment) (program : Program) :
    SpecifiedOutcome environment program (execute environment program) :=
  Sequence.effects_execution_specified _ _ _

theorem effects_domain {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Environment) :
    Sequence.EffectsValid (effects environment program) := by
  cases program with
  | nullMain => simp [effects, Sequence.EffectsValid]
  | sequence program =>
      exact (Predicate.Program.execution_sound (sequence_valid meaning) environment.arguments).2.1

theorem healthy_execution {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Environment)
    (healthy : environment.Healthy) :
    execute environment program = ⟨expectedStatus environment program, intendedBytes environment program⟩ :=
  Sequence.healthy_effects _ healthy _ (effects_domain meaning environment)

theorem cumulative_output_bound {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Environment) :
    (execute environment program).accepted.length ≤
      Sequence.outputCount (effects environment program) * (maxSourceLength + 1) :=
  Sequence.accepted_effects_bound _ _ (effects_domain meaning environment)

theorem admitted_assurance {source : Source} (member : Member source) :
    automaticDischarge source = some true ∧
    ∃ program, SourceMeaning source program ∧
      Semantics.discharge (obligations program) = true ∧
      (∃ steps, steps ≤ (obligations program).length + 1 ∧
        Semantics.DischargeSteps (obligations program) true steps) ∧
      SourceBoundsRefinement source program ∧
      ∀ environment, StringBoundsSafe source environment program ∧
        SpecifiedOutcome environment program (execute environment program) := by
  obtain ⟨program, meaning⟩ := member_has_meaning member
  have checked := all_obligations_discharge meaning
  have bounds := source_string_bounds_assured meaning
  exact ⟨automatic_discharge_complete member, program, meaning, checked.1, checked.2, bounds.1,
    fun environment => ⟨bounds.2 environment, execution_specified environment program⟩⟩

theorem every_meaning_assured {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    Semantics.discharge (obligations program) = true ∧
    (∃ steps, steps ≤ (obligations program).length + 1 ∧
      Semantics.DischargeSteps (obligations program) true steps) ∧
    SourceBoundsRefinement source program ∧
    ∀ environment, StringBoundsSafe source environment program ∧
      SpecifiedOutcome environment program (execute environment program) ∧
      (environment.Healthy →
        execute environment program = ⟨expectedStatus environment program, intendedBytes environment program⟩) := by
  have checked := all_obligations_discharge meaning
  have bounds := source_string_bounds_assured meaning
  exact ⟨checked.1, checked.2, bounds.1, fun environment =>
    ⟨bounds.2 environment, execution_specified environment program, healthy_execution meaning environment⟩⟩

structure Tools (Artifact : Type) where
  parse : Source → Program → Nat → Prop
  generate : Program → List Predicate.Check → Nat → Prop
  prove : List Predicate.Check → Nat → Prop
  verifyFixedLibrary : Nat → Prop
  build : Source → Artifact → Nat → Prop
  execute : Artifact → Environment → Output.Runtime.ProcessResult → Prop

/-- Completion marker for the fixed library's separately audited GNATprove run.
It is not a semantic contract or a proof that library verification succeeds:
ToolContract supplies completion separately from trusted compilation semantics. -/
def LibraryEvidence {Artifact : Type} (tools : Tools Artifact) : Program → Prop
  | .nullMain => True
  | .sequence _ => ∃ steps, tools.verifyFixedLibrary steps

/-- Generic external-tool contracts, without arbitrary-SPARK solver
completeness. Declaration and executable-body obligations normalize to the
source-derived range, exact/affine length, index, scalar arithmetic, Integer Image,
loop and input-validity schemas under the exact refined path context.
Their endpoint certificates are checked in Lean. Generation may omit or repeat
schemas; its coverage of every native Bronze/Silver obligation remains a
trusted GNATprove premise audited through complete reports.

The pinned solvers must finish this concrete fragment. This is an external
completion premise, not a theorem about the solver implementation or a measured
universal step bound. Compilation consumes the same source and preserves and
realizes the checked runtime semantics under the documented external-call
interpretation. Physical build completion also depends on the reviewed frontend
configuration (including the pinned current-value-replacement correction in
docs/scalar-guard-frontend-repair.md); this contract does not verify GNAT. -/
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
    exact ⟨check, by simpa [generated.1] using member, Predicate.Check.refines_refl _⟩
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
  | complete {source : Source} {program : Program} {checks : List Predicate.Check}
      {artifact : Artifact} {parseSteps generateSteps proofSteps buildSteps : Nat} :
      tools.parse source program parseSteps → tools.generate program checks generateSteps →
      tools.prove checks proofSteps → LibraryEvidence tools program →
      tools.build source artifact buildSteps →
      Pipeline tools source artifact (parseSteps + generateSteps + proofSteps + buildSteps)

theorem generated_fragment {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} {program : Program}
    (meaning : SourceMeaning source program) {checks : List Predicate.Check} {steps : Nat}
    (generated : tools.generate program checks steps) : BoundedFragment checks := by
  intro check member
  obtain ⟨schema, present, bounded⟩ := contract.generationFaithful program checks steps generated check member
  exact Predicate.Check.fragment_of_refines bounded (admitted_fragment meaning schema present)

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
    | sequence => exact contract.fixedLibraryProofCompletes
  exact ⟨artifact, _, .complete parsed generated proved library built⟩

theorem pipeline_checks_valid {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} {program : Program}
    (meaning : SourceMeaning source program) {checks : List Predicate.Check}
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
        (environment.Healthy →
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
