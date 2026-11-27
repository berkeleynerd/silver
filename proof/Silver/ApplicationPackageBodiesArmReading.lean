module

public import Silver.ApplicationPackageBodiesStatementModel
public import Silver.PredicateConditionSound
public import Silver.PredicateConditionUnique
public import Silver.PredicateConditionValidity

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open ApplicationPackages Compose Predicate

structure ArmEvaluation (calls : Calls) (s : Input) (prior : Arms) (read : ReadArm) : Prop where
  conditionPresent : (conditionFor calls s prior).after ≠ 0
  thenAdvanced : prior.value.scan.position < (thenInput calls s prior (conditionFor calls s prior)).scan.position
  branchRead : tail calls s s.context (thenInput calls s prior (conditionFor calls s prior)) .arm = read.branch
  branchPresent : read.branch.scan.position ≠ 0
  previousFlow : read.yes = prior.yes
  previousArm : read.haveYes = prior.haveYes
  falseFlow : read.whenFalse = (conditionFor calls s prior).whenFalse
  first : read.start = prior.value.scan.position

theorem readArm_evaluation {calls : Calls} {s : Input} {prior : Arms} {read : ReadArm}
    (parsed : readArm calls s prior = some read) : ArmEvaluation calls s prior read := by
  dsimp only [readArm] at parsed
  split at parsed
  · contradiction
  · rename_i present
    split at parsed
    · contradiction
    · rename_i advanced
      split at parsed
      · contradiction
      · rename_i accepted
        cases parsed
        exact ⟨present, Nat.lt_of_not_ge advanced, rfl, accepted, rfl, rfl, rfl, rfl⟩

set_option maxRecDepth 8000 in
theorem thenInput_observations (calls : Calls) (s : Input) (prior : Arms) (condition : ConditionResult) :
    let entry := thenInput calls s prior condition
    entry.scan.position = calls.takeToken s.text condition.after (.word "then") ∧
      entry.scan.facts = condition.whenTrue ∧ entry.reads = PackageBindings.stateUnion prior.value.reads
        (calls.stateReads s.text s.context s.info prior.value.scan.position condition.after) ∧
      entry.writes = prior.value.writes := ⟨rfl, rfl, rfl, rfl⟩

/-- Recover the condition at its actual offset in each reached IF or ELSIF
arm. Both flow refinements are taken from the inherited reader at that same
input, before the recursively scanned arm. -/
theorem arm_source_condition {calls : Calls} {s : Input} {prior : Arms} {read : ReadArm}
    (parsed : readArm calls s prior = some read)
    (linked : conditionFor calls s prior =
      Predicate.readCondition s.text s.context prior.value.scan.position prior.value.scan.facts)
    (tv : Expressions.ValidText s.text) (nv : Expressions.ValidNames s.text s.context.names)
    (position : prior.value.scan.position ≤ s.text.length + 1) :
    ∃ condition, ConditionAt s.text s.context prior.value.scan.position prior.value.scan.facts
        condition (conditionFor calls s prior) ∧
      (∀ other, ConditionAt s.text s.context prior.value.scan.position prior.value.scan.facts
        other (conditionFor calls s prior) → other = condition) ∧
      (conditionFor calls s prior).after ≤ s.text.length + 1 ∧
      (thenInput calls s prior (conditionFor calls s prior)).scan.facts = (conditionFor calls s prior).whenTrue ∧
      read.whenFalse = (conditionFor calls s prior).whenFalse := by
  have observed := readArm_evaluation parsed
  have accepted := linked ▸ observed.conditionPresent
  obtain ⟨⟨condition, source⟩, bound⟩ :=
    condition_sound s.text s.context prior.value.scan.position prior.value.scan.facts tv nv position accepted
  rw [← linked] at source bound
  exact ⟨condition, source, fun _ other => condition_unique other source, bound, rfl, observed.falseFlow⟩

theorem arm_condition_meaning {calls : Calls} {s : Input} {prior : Arms} {read : ReadArm}
    (parsed : readArm calls s prior = some read)
    (linked : conditionFor calls s prior =
      Predicate.readCondition s.text s.context prior.value.scan.position prior.value.scan.facts)
    (tv : Expressions.ValidText s.text) (nv : Expressions.ValidNames s.text s.context.names)
    (position : prior.value.scan.position ≤ s.text.length + 1)
    (normal : NamesNormal s.context.names)
    (base : ScalarMetadata.ContextReady s.context.scalarNames s.context.declarationCount s.context.elaborating)
    (arrays : s.context.ArraysReady s.text)
    (compatible : ScalarMetadata.OverlayCompatible s.context.scalarNames s.context.declarationCount prior.value.scan.facts)
    (bounded : prior.value.scan.facts.path.Bounded) :
    ∃ condition, ConditionAt s.text s.context prior.value.scan.position prior.value.scan.facts condition
        (conditionFor calls s prior) ∧
      ConditionMeaning s.context prior.value.scan.facts condition (conditionFor calls s prior) [] := by
  obtain ⟨condition, source, _⟩ := arm_source_condition parsed linked tv nv position
  exact ⟨condition, source, condition_valid normal nv base arrays compatible bounded source⟩

end Silver.ApplicationPackageBodies.Statement
