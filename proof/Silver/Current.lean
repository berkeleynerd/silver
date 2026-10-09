import Silver.OutputAdmission
import Silver.OutputRuntime
import Silver.Semantics
import Silver.NamedSemantics
import Silver.NamedDisjoint
import Silver.ArgumentsDisjoint
import Silver.ConcatDisjoint
import Silver.GuardedDisjoint
import Silver.GuardedObligations

/-! One current language, six productions. Guarded dynamic concatenation adds
bounded range schemas. Their arithmetic validity is proved; faithful generation
and completion of the pinned external tools on that concrete fragment are
explicit ToolContract premises. Optimization may remove a generated check, but
the real compiler must audit every check actually emitted. The selected library
bodies retain their separately audited obligations. -/

namespace Silver.Current

def Member (source : Source) : Prop := Silver.Member source ∨ Output.Member source ∨ Named.Member source ∨ Arguments.Member source ∨ Concat.Member source ∨ Guarded.Member source
def accepts (source : Source) : Bool := Silver.accepts source || (Output.accepts source || (Named.accepts source || (Arguments.accepts source || (Concat.accepts source || Guarded.accepts source))))

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, Member, Silver.accepts_iff_member, Output.accepts_iff_member, Named.accepts_iff_member, Arguments.accepts_iff_member, Concat.accepts_iff_member, Guarded.accepts_iff_member]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

inductive Program
  | nullMain
  | outputMain (literal : Source)
  | argumentMain (defaultValue : Source)
  | guardedMain (program : Guarded.Program)
  deriving DecidableEq, Repr

inductive SourceMeaning : Source → Program → Prop
  | nullMain {source : Source} : Silver.Member source → SourceMeaning source .nullMain
  | outputMain {source literal : Source} :
      Output.Member source → Output.Parsed source Output.requiredTokens 1 [literal] →
      SourceMeaning source (.outputMain literal)

  | namedMain {source : Source} {program : Named.Program} :
      Named.SourceMeaning source program → SourceMeaning source (.outputMain program.literal)

  | argumentMain {source : Source} {program : Arguments.Program} :
      Arguments.SourceMeaning source program → SourceMeaning source (.argumentMain program.defaultValue)

  | concatMain {source : Source} {program : Concat.Program} :
      Concat.SourceMeaning source program → SourceMeaning source (.outputMain program.bytes)

  | guardedMain {source : Source} {program : Guarded.Program} :
      Guarded.SourceMeaning source program → SourceMeaning source (.guardedMain program)

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ program, SourceMeaning source program := by
  rcases member with nullMember | outputMember | namedMember | argumentMember | concatMember | guardedMember
  · exact ⟨.nullMain, .nullMain nullMember⟩
  · obtain ⟨literal, parsed⟩ := outputMember.2.2.2
    exact ⟨.outputMain literal, .outputMain outputMember parsed⟩
  · obtain ⟨program, meaning⟩ := Named.member_has_meaning namedMember
    exact ⟨.outputMain program.literal, .namedMain meaning⟩
  · obtain ⟨program, meaning⟩ := Arguments.member_has_meaning argumentMember
    exact ⟨.argumentMain program.defaultValue, .argumentMain meaning⟩
  · obtain ⟨program, meaning⟩ := Concat.member_has_meaning concatMember
    exact ⟨.outputMain program.bytes, .concatMain meaning⟩

  · obtain ⟨program, meaning⟩ := Guarded.member_has_meaning guardedMember
    exact ⟨.guardedMain program, .guardedMain meaning⟩

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
      | namedMain namedMeaning => exact False.elim (Named.null_named_disjoint source ⟨member, namedMeaning.1⟩)
      | argumentMain meaning => exact False.elim (Arguments.null_argument_disjoint source ⟨member, meaning.1⟩)
      | concatMain meaning => exact False.elim (Concat.null_concat_disjoint source ⟨member, meaning.1⟩)
      | guardedMain other => exact False.elim (Guarded.null_guarded_disjoint source ⟨member, other.1⟩)
  | outputMain member parsed =>
      cases second with
      | nullMain nullMember => exact False.elim (member_disjoint source ⟨nullMember, member⟩)
      | outputMain outputMember other =>
          have same := Output.parsed_unique parsed other
          simpa using congrArg Program.outputMain (List.cons.inj same).1
      | namedMain namedMeaning => exact False.elim (Named.literal_named_disjoint source ⟨member, namedMeaning.1⟩)
      | argumentMain meaning => exact False.elim (Arguments.literal_argument_disjoint source ⟨member, meaning.1⟩)
      | concatMain meaning => exact False.elim (Concat.literal_concat_disjoint source ⟨member, meaning.1⟩)
      | guardedMain other => exact False.elim (Guarded.literal_guarded_disjoint source ⟨member, other.1⟩)
  | namedMain namedMeaning =>
      cases second with
      | nullMain member => exact False.elim (Named.null_named_disjoint source ⟨member, namedMeaning.1⟩)
      | outputMain member _ => exact False.elim (Named.literal_named_disjoint source ⟨member, namedMeaning.1⟩)
      | namedMain other =>
          exact congrArg (fun (program : Named.Program) => Program.outputMain program.literal)
            (Named.meaning_unique namedMeaning other)
      | argumentMain meaning => exact False.elim (Arguments.named_argument_disjoint source ⟨namedMeaning.1, meaning.1⟩)
      | concatMain meaning => exact False.elim (Concat.named_concat_disjoint source ⟨namedMeaning.1, meaning.1⟩)
      | guardedMain other => exact False.elim (Guarded.named_guarded_disjoint source ⟨namedMeaning.1, other.1⟩)
  | argumentMain meaning =>
      cases second with
      | nullMain member => exact False.elim (Arguments.null_argument_disjoint source ⟨member, meaning.1⟩)
      | outputMain member _ => exact False.elim (Arguments.literal_argument_disjoint source ⟨member, meaning.1⟩)
      | namedMain namedMeaning => exact False.elim (Arguments.named_argument_disjoint source ⟨namedMeaning.1, meaning.1⟩)
      | argumentMain other =>
          exact congrArg (fun (program : Arguments.Program) => Program.argumentMain program.defaultValue)
            (Arguments.meaning_unique meaning other)
      | concatMain other => exact False.elim (Concat.concat_argument_disjoint source ⟨other.1, meaning.1⟩)
      | guardedMain other => exact False.elim (Guarded.argument_guarded_disjoint source ⟨meaning.1, other.1⟩)
  | concatMain meaning =>
      cases second with
      | nullMain member => exact False.elim (Concat.null_concat_disjoint source ⟨member, meaning.1⟩)
      | outputMain member _ => exact False.elim (Concat.literal_concat_disjoint source ⟨member, meaning.1⟩)
      | namedMain other => exact False.elim (Concat.named_concat_disjoint source ⟨other.1, meaning.1⟩)
      | argumentMain other => exact False.elim (Concat.concat_argument_disjoint source ⟨meaning.1, other.1⟩)
      | concatMain other =>
          exact congrArg (fun (program : Concat.Program) => Program.outputMain program.bytes)
            (Concat.meaning_unique meaning other)
      | guardedMain other => exact False.elim (Guarded.concat_guarded_disjoint source ⟨meaning.1, other.1⟩)
  | guardedMain meaning =>
      cases second with
      | nullMain member => exact False.elim (Guarded.null_guarded_disjoint source ⟨member, meaning.1⟩)
      | outputMain member _ => exact False.elim (Guarded.literal_guarded_disjoint source ⟨member, meaning.1⟩)
      | namedMain other => exact False.elim (Guarded.named_guarded_disjoint source ⟨other.1, meaning.1⟩)
      | argumentMain other => exact False.elim (Guarded.argument_guarded_disjoint source ⟨other.1, meaning.1⟩)
      | concatMain other => exact False.elim (Guarded.concat_guarded_disjoint source ⟨other.1, meaning.1⟩)
      | guardedMain other => exact congrArg Program.guardedMain (Guarded.meaning_unique meaning other)

theorem literal_domain {source literal : Source}
    (meaning : SourceMeaning source (.outputMain literal)) :
    literal.length ≤ 4096 ∧ ∀ byte ∈ literal, Output.printable byte = true := by
  cases meaning with
  | outputMain member parsed =>
      have facts := (Output.parsed_literals parsed).2 literal (by simp)
      exact ⟨Nat.le_trans facts.1 member.2.1, facts.2⟩
  | namedMain meaning => exact Named.literal_domain meaning
  | concatMain meaning => exact Concat.output_domain meaning

theorem default_domain {source defaultValue : Source}
    (meaning : SourceMeaning source (.argumentMain defaultValue)) :
    Arguments.Runtime.message defaultValue = true := by
  cases meaning with
  | argumentMain meaning => exact Arguments.default_is_message meaning

def rangeObligations : Program → List Guarded.RangeObligation
  | .nullMain | .outputMain _ | .argumentMain _ => []
  | .guardedMain program => Guarded.rangeObligations program

def obligations (program : Program) : List Semantics.Obligation :=
  (rangeObligations program).map Guarded.RangeObligation.toObligation

/-- The source checker uses fixed maximal coefficients; no classical extraction
of a parse witness is needed. The per-program refinement theorem below links
these computed schemas to each admitted meaning. -/
def automaticDischarge (source : Source) : Option Bool :=
  if accepts source then
    some (Semantics.discharge (if Guarded.accepts source then Guarded.uniformObligations else []))
  else none

theorem automatic_discharge_complete {source : Source} (member : Member source) :
    automaticDischarge source = some true := by
  simp only [automaticDischarge, (accepts_iff_member source).mpr member, ite_true]
  cases Guarded.accepts source <;> simp [Semantics.discharge, Guarded.uniform_discharge]

/-- A concrete arithmetic fragment, independent of source membership or solver
success: each range schema is dominated by a checked uniform bound. -/
def BoundedRangeFragment (checks : List Guarded.RangeObligation) : Prop :=
  ∀ check ∈ checks, ∃ upper ∈ Guarded.uniformRangeObligations, check.Refines upper

theorem admitted_range_fragment {source : Source} {program : Program}
    (meaning : SourceMeaning source program) : BoundedRangeFragment (rangeObligations program) := by
  cases meaning with
  | nullMain | outputMain | namedMain | argumentMain | concatMain => simp [BoundedRangeFragment, rangeObligations]
  | guardedMain meaning => exact Guarded.obligations_refine_uniform meaning

theorem fragment_checks_valid {checks : List Guarded.RangeObligation}
    (fragment : BoundedRangeFragment checks) : ∀ check ∈ checks, check.Valid := by
  intro check member
  obtain ⟨upper, present, bounded⟩ := fragment check member
  exact Guarded.RangeObligation.valid_of_refines bounded (Guarded.uniform_range_valid upper present)

theorem all_obligations_discharge {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    Semantics.discharge (obligations program) = true ∧
      ∃ steps, steps ≤ (obligations program).length + 1 ∧
        Semantics.DischargeSteps (obligations program) true steps := by
  have discharged : Semantics.discharge (obligations program) = true := by
    apply (Semantics.discharge_iff _).mpr
    intro check member
    obtain ⟨range, present, rfl⟩ := List.mem_map.mp member
    exact (Guarded.RangeObligation.discharge_iff _).mpr
      (fragment_checks_valid (admitted_range_fragment meaning) range present)
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
  | .outputMain literal => .output literal
  | .argumentMain defaultValue =>
      if Arguments.Runtime.inputIsValid environment.arguments then
        .output (Arguments.Runtime.firstOrDefault defaultValue environment.arguments)
      else .reject

  | .guardedMain program =>
      if Guarded.guard environment.arguments program then
        .output (Guarded.decorated environment.arguments program)
      else .reject

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

theorem named_execution_refines {source : Source} {program : Named.Program}
    (meaning : Named.SourceMeaning source program) (environment : Environment) :
    Named.execute environment.output program = some (execute environment (.outputMain program.literal)) :=
  Named.execution_refines meaning environment.output

theorem concat_execution_refines {source : Source} {program : Concat.Program}
    (meaning : Concat.SourceMeaning source program) (environment : Environment) :
    Concat.execute environment.output program = some (execute environment (.outputMain program.bytes)) :=
  Concat.execution_refines meaning environment.output

theorem argument_execution_refines {source : Source} {program : Arguments.Program}
    (meaning : Arguments.SourceMeaning source program) (environment : Environment) :
    Arguments.execute environment.output environment.arguments program =
      some (execute environment (.argumentMain program.defaultValue)) := by
  rw [Arguments.execution_refines meaning, Arguments.Runtime.main_refines]
  cases valid : Arguments.Runtime.inputIsValid environment.arguments <;>
    simp [execute, action, valid, executeAction, Arguments.Runtime.outputMain]

theorem guarded_execution_refines {source : Source} {program : Guarded.Program}
    (meaning : Guarded.SourceMeaning source program) (environment : Environment) :
    Guarded.execute environment.output environment.arguments program =
      some (execute environment (.guardedMain program)) := by
  rw [Guarded.execution_refines meaning]
  cases valid : Guarded.guard environment.arguments program <;>
    simp [execute, action, valid, executeAction, Arguments.Runtime.outputMain,
      Arguments.Runtime.rejectProgram, Arguments.Runtime.Effect.execute]

theorem argument_rejection {source : Source} {program : Arguments.Program}
    (meaning : Arguments.SourceMeaning source program) (environment : Environment)
    (invalid : Arguments.Runtime.inputIsValid environment.arguments = false) :
    execute environment (.argumentMain program.defaultValue) = ⟨1, []⟩ := by
  have refined := argument_execution_refines meaning environment
  rw [Arguments.invalid_execution meaning environment.output environment.arguments invalid] at refined
  exact (Option.some.inj refined).symm

theorem argument_default_selected {source defaultValue : Source}
    (meaning : SourceMeaning source (.argumentMain defaultValue))
    (environment : Output.Runtime.Environment) :
    action ⟨environment, []⟩ (.argumentMain defaultValue) = .output defaultValue := by
  simp [action, Arguments.Runtime.inputIsValid, Arguments.Runtime.firstOrDefault, default_domain meaning]

theorem argument_empty_selected (environment : Output.Runtime.Environment) (defaultValue : Source) :
    action ⟨environment, [[]]⟩ (.argumentMain defaultValue) = .output [] := by
  simp [action, Arguments.Runtime.inputIsValid, Arguments.Runtime.firstOrDefault]

/-- Every output action has a safe byte domain; invalid input selects rejection
and cannot be confused with the valid explicit empty string. -/
theorem action_domain {source : Source} {program : Program}
    (meaning : SourceMeaning source program) (environment : Environment) (item : Source)
    (selected : action environment program = .output item) :
    item.length ≤ 4096 ∧ ∀ byte ∈ item, Output.printable byte = true := by
  cases program with
  | nullMain => cases selected
  | outputMain literal =>
      have same : literal = item := Action.output.inj selected
      subst item
      exact literal_domain meaning
  | argumentMain defaultValue =>
      simp only [action] at selected
      split at selected
      · cases selected
        have domain := (Arguments.Runtime.message_iff _).mp
          (Arguments.Runtime.initializer_domain environment.arguments defaultValue)
        refine ⟨domain.1, ?_⟩
        intro byte member
        exact decide_eq_true (domain.2 byte member)
      · cases selected
  | guardedMain program =>
      cases meaning with
      | guardedMain meaning =>
        simp only [action] at selected
        split at selected
        · rename_i guarded
          cases selected
          exact Guarded.output_domain meaning environment.arguments guarded
        · cases selected

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
  generate : Program → List Guarded.RangeObligation → Nat → Prop
  prove : List Guarded.RangeObligation → Nat → Prop
  verifyFixedLibrary : Nat → Prop
  build : Source → Artifact → Nat → Prop
  execute : Artifact → Environment → Output.Runtime.ProcessResult → Prop

/-- Completion marker for the fixed library's separately audited GNATprove run.
It is not a semantic contract or a proof that library verification succeeds:
ToolContract supplies completion separately from trusted compilation semantics. -/
def LibraryEvidence {Artifact : Type} (tools : Tools Artifact) : Program → Prop
  | .nullMain => True
  | .outputMain _ | .argumentMain _ | .guardedMain _ => ∃ steps, tools.verifyFixedLibrary steps

/-- Generic external-tool contracts, with no arbitrary-SPARK solver completeness.
Each generated check normalizes to an instance of a source concatenation range
schema; emitted checks may be simplified, repeated or omitted by optimization.
This relation does not certify the producer's obligation completeness, which
remains a trusted GNATprove premise audited through complete reports. The pinned
provers must complete on the concrete bounded arithmetic fragment. These facts
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
    ∀ check ∈ checks, ∃ schema ∈ rangeObligations program, check.Refines schema
  boundedRangeProofCompletes : ∀ checks, BoundedRangeFragment checks →
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
  generate := fun program checks steps => checks = rangeObligations program ∧ steps = 1
  prove := fun checks steps => BoundedRangeFragment checks ∧ steps = checks.length + 1
  verifyFixedLibrary := fun steps => steps = 1
  build := fun source program steps => SourceMeaning source program ∧ steps = 1
  execute := fun program environment result => result = execute environment program

theorem model_tool_contract : ToolContract modelTools where
  parseCompletes := fun _ _ meaning => ⟨1, meaning, rfl⟩
  parseFaithful := fun _ _ _ parsed => parsed.1
  generationCompletes := fun program => ⟨rangeObligations program, 1, rfl, rfl⟩
  generationFaithful := by
    intro program checks steps generated
    intro check member
    exact ⟨check, by simpa [generated.1] using member, Nat.le_refl _, Nat.le_refl _⟩
  boundedRangeProofCompletes := fun checks fragment => ⟨checks.length + 1, fragment, rfl⟩
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
  | complete {source : Source} {program : Program} {checks : List Guarded.RangeObligation}
      {artifact : Artifact} {parseSteps generateSteps proofSteps buildSteps : Nat} :
      tools.parse source program parseSteps → tools.generate program checks generateSteps →
      tools.prove checks proofSteps → LibraryEvidence tools program →
      tools.build source artifact buildSteps →
      Pipeline tools source artifact (parseSteps + generateSteps + proofSteps + buildSteps)

theorem generated_range_fragment {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} {program : Program}
    (meaning : SourceMeaning source program) {checks : List Guarded.RangeObligation} {steps : Nat}
    (generated : tools.generate program checks steps) : BoundedRangeFragment checks := by
  intro check member
  obtain ⟨schema, present, bounded⟩ := contract.generationFaithful program checks steps generated check member
  obtain ⟨upper, found, parent⟩ := admitted_range_fragment meaning schema present
  exact ⟨upper, found, Nat.le_trans bounded.1 parent.1, Nat.le_trans bounded.2 parent.2⟩

theorem automatic_pipeline {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} (member : Member source) :
    ∃ artifact steps, Pipeline tools source artifact steps := by
  obtain ⟨program, meaning⟩ := member_has_meaning member
  obtain ⟨parseSteps, parsed⟩ := contract.parseCompletes source program meaning
  obtain ⟨checks, generateSteps, generated⟩ := contract.generationCompletes program
  obtain ⟨proofSteps, proved⟩ := contract.boundedRangeProofCompletes checks
    (generated_range_fragment contract meaning generated)
  obtain ⟨artifact, buildSteps, built⟩ := contract.buildCompletes source program parseSteps parsed
  have library : LibraryEvidence tools program := by
    cases program with
    | nullMain => trivial
    | outputMain | argumentMain | guardedMain => exact contract.fixedLibraryProofCompletes
  exact ⟨artifact, _, .complete parsed generated proved library built⟩

theorem pipeline_checks_valid {Artifact : Type} {tools : Tools Artifact}
    (contract : ToolContract tools) {source : Source} {program : Program}
    (meaning : SourceMeaning source program) {checks : List Guarded.RangeObligation}
    {steps : Nat} (generated : tools.generate program checks steps) :
    ∀ check ∈ checks, check.Valid :=
  fragment_checks_valid (generated_range_fragment contract meaning generated)

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
