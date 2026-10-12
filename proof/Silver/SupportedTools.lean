module

public import Silver.Semantics

@[expose] public section

/-!
Conditional end-to-end theorem for approved external tools in a supported
execution environment. These are explicit theorem parameters, not axioms.

The contracts describe independent tool behavior: faithful parsing of the
modeled Ada constructs, faithful obligation generation, terminating acceptance
of an empty obligation set, and terminating compilation that preserves source
semantics. No premise says that Silver membership implies proof success, and
no premise requires a solver complete for arbitrary valid SPARK programs.

Constructing a `Contract` for a physical invocation requires the approved
external-tool trust boundary and an operational environment: installed matching
tools, accessible immutable source, sufficient resources, and completion of
the invoked processes. This file does not prove those environmental premises
or certify the GNAT/GNATprove implementations. The source parameter is identical
in parsing and building; the SPARK driver's guarded protocol must establish
that relationship for the real files and invocations.
-/

namespace Silver.SupportedTools

open Semantics

structure Operations (Artifact : Type) where
  parse : Source → Command → Nat → Prop
  generate : Command → List Obligation → Nat → Prop
  prove : List Obligation → Bool → Nat → Prop
  build : Source → Artifact → Nat → Prop
  execute : Artifact → State → Trace → Outcome → Prop

/-- Laws of the external tools, conditional on a supported operational environment. -/
structure Contract {Artifact : Type} (tools : Operations Artifact) : Prop where
  parseCompletes : ∀ source command,
    (∀ byte ∈ source, allowedCharacter byte = true) → SourceMeaning source command →
    ∃ steps, tools.parse source command steps
  parseFaithful : ∀ source command steps, tools.parse source command steps →
    SourceMeaning source command
  generationCompletes : ∀ command,
    ∃ steps, tools.generate command (obligations command) steps
  generationFaithful : ∀ command checks steps, tools.generate command checks steps →
    checks = obligations command
  emptyProofCompletes : ∃ steps, tools.prove [] true steps
  compilationCompletes : ∀ source command parseSteps,
    tools.parse source command parseSteps →
    ∃ artifact steps, tools.build source artifact steps
  compilationPreserves : ∀ source command artifact buildSteps,
    SourceMeaning source command → tools.build source artifact buildSteps →
    ∀ state trace outcome, tools.execute artifact state trace outcome →
      Executes command state trace outcome
  compilationRealizes : ∀ source command artifact buildSteps,
    SourceMeaning source command → tools.build source artifact buildSteps →
    ∀ state trace outcome, Executes command state trace outcome →
      tools.execute artifact state trace outcome

/-- A successful pipeline uses exactly the same source in parsing and building. -/
inductive Pipeline {Artifact : Type} (tools : Operations Artifact) :
    Source → Artifact → Nat → Prop
  | complete {source : Source} {command : Command} {checks : List Obligation}
      {artifact : Artifact} {parseSteps generationSteps proofSteps buildSteps : Nat} :
      tools.parse source command parseSteps →
      tools.generate command checks generationSteps →
      tools.prove checks true proofSteps →
      tools.build source artifact buildSteps →
      Pipeline tools source artifact (parseSteps + generationSteps + proofSteps + buildSteps)

/-- Every admitted source completes under the stated generic external contracts. -/
theorem admitted_pipeline_completes {Artifact : Type} {tools : Operations Artifact}
    (contract : Contract tools) {source : Source} (member : Member source) :
    ∃ artifact steps, Pipeline tools source artifact steps := by
  have meaning := member_has_meaning member
  obtain ⟨parseSteps, parsed⟩ :=
    contract.parseCompletes source admittedCommand member.2.2.1 meaning
  obtain ⟨generationSteps, generated⟩ := contract.generationCompletes admittedCommand
  obtain ⟨proofSteps, proved⟩ := contract.emptyProofCompletes
  obtain ⟨artifact, buildSteps, built⟩ :=
    contract.compilationCompletes source admittedCommand parseSteps parsed
  have empty := obligations_empty admittedCommand
  rw [empty] at generated
  exact ⟨artifact, parseSteps + generationSteps + proofSteps + buildSteps,
    .complete parsed generated proved built⟩

/-- Successful supported runs cover exactly the obligations of the parsed source. -/
theorem pipeline_obligations_empty {Artifact : Type} {tools : Operations Artifact}
    (contract : Contract tools) {source : Source} {command : Command}
    {checks : List Obligation} {parseSteps generationSteps : Nat}
    (parsed : tools.parse source command parseSteps)
    (generated : tools.generate command checks generationSteps) : checks = [] := by
  have meaning := contract.parseFaithful source command parseSteps parsed
  have shape := meaning_unique meaning
  rw [contract.generationFaithful command checks generationSteps generated, shape]
  exact obligations_empty admittedCommand

theorem supported_pipeline_preserves {Artifact : Type} {tools : Operations Artifact}
    (contract : Contract tools) {source : Source} {artifact : Artifact} {steps : Nat}
    (pipeline : Pipeline tools source artifact steps) :
    ∀ state trace outcome, tools.execute artifact state trace outcome →
      trace = [] ∧ outcome = .normal state ∧ BronzeSafe state trace ∧ SilverSafe outcome := by
  cases pipeline with
  | complete parsed _ _ built =>
      have meaning := contract.parseFaithful _ _ _ parsed
      intro state trace outcome execution
      have sourceExecution := contract.compilationPreserves _ _ _ _ meaning built _ _ _ execution
      have identity := execution_identity sourceExecution
      have safety := execution_safe sourceExecution
      exact ⟨identity.1, identity.2, safety.1, safety.2⟩

theorem supported_pipeline_executes {Artifact : Type} {tools : Operations Artifact}
    (contract : Contract tools) {source : Source} {artifact : Artifact} {steps : Nat}
    (pipeline : Pipeline tools source artifact steps) (state : State) :
    tools.execute artifact state [] (.normal state) := by
  cases pipeline with
  | complete parsed _ _ built =>
      have meaning := contract.parseFaithful _ _ _ parsed
      exact contract.compilationRealizes _ _ _ _ meaning built _ _ _ (execution_exists _ state)

end Silver.SupportedTools
