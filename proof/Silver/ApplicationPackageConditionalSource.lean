module

public import Silver.ApplicationPackageConditionalChecking

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open Compose Predicate ApplicationPackages

theorem ArmsReading.originals {calls source before entries after}
    (read : ArmsReading calls source before entries after) :
    ∀ prior arm, (prior, arm) ∈ entries → readArm calls source prior = some arm := by
  induction read with
  | last parsed _ =>
    intro prior arm member
    cases List.mem_singleton.mp member
    exact parsed
  | next parsed _ _ ih =>
    intro prior arm member
    rcases List.mem_cons.mp member with same | rest
    · cases same
      exact parsed
    · exact ih prior arm rest

/-- The condition and all of its intermediate bounds come from the actual
inherited condition reader. Only the child-tail result is the recursive
hypothesis; no condition certificate is supplied by the program author. -/
theorem decoded_arm_source {calls : Calls} {source : Input} {prior : Arms} {read : ReadArm}
    {child : ChildReading} {checker : ConditionalChecker source.context} {body : List Predicate.Statement}
    (parsed : readArm calls source prior = some read)
    (linked : conditionFor calls source prior =
      Predicate.readCondition source.text source.context prior.value.scan.position prior.value.scan.facts)
    (tv : Expressions.ValidText source.text) (nv : Expressions.ValidNames source.text source.context.names)
    (position : prior.value.scan.position ≤ source.text.length + 1)
    (normal : NamesNormal source.context.names)
    (base : ScalarMetadata.ContextReady source.context.scalarNames source.context.declarationCount source.context.elaborating)
    (arrays : source.context.ArraysReady source.text)
    (compatible : ScalarMetadata.OverlayCompatible source.context.scalarNames source.context.declarationCount prior.value.scan.facts)
    (bounded : prior.value.scan.facts.path.Bounded)
    (childSource : child (thenInput calls source prior (conditionFor calls source prior)) .arm body read.branch)
    (nonempty : body ≠ [])
    (wellFormed : StatementsWellFormed source.context.hasArguments source.context.names.shape body
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)))
    (checked : checker.check
      (source.context.flow (thenInput calls source prior (conditionFor calls source prior)).scan.facts) body =
      some (source.context.flow read.branch.scan.facts)) :
    ∃ condition, DecodedArm calls source child checker prior read (condition, body) := by
  obtain ⟨condition, sourceCondition, meaning⟩ :=
    arm_condition_meaning parsed linked tv nv position normal base arrays compatible bounded
  exact ⟨condition, sourceCondition, childSource, nonempty, wellFormed, meaning, checked⟩

inductive ElseCodeAt (calls : Calls) (source : Input) (child : ChildReading) (state : Arms) :
    List Predicate.Statement → Prop
  | absent : elsePosition calls source state = 0 → ElseCodeAt calls source child state []
  | present {body} : elsePosition calls source state ≠ 0 →
      child (atPosition state.value (elsePosition calls source state)) .endOnly body (elseResult calls source state) →
      ElseCodeAt calls source child state body

theorem packageConditionalChecker_empty (earlier : Packages.EffectEnvironment) (layout : Packages.FrameLayout)
    (context : ParseContext) (emptyShape : context.names.shape = Bindings.emptyShape) (flow : Flow) :
    (packageConditionalChecker earlier layout context emptyShape).check flow [] = some flow := by
  simp only [packageConditionalChecker, Packages.checkPackageStatements]

theorem mainConditionalChecker_empty (functions : ScalarFunctions.Signatures) (procedures : ScalarProcedures.Signatures)
    (context : ParseContext) (flow : Flow) :
    (mainConditionalChecker functions procedures context).check flow [] = some flow := by
  simp only [mainConditionalChecker, checkStatements]

/-- Recover the actual optional ELSE. Absence contributes the unchanged false
flow; a present ELSE is always decoded through its original recursive call. -/
theorem else_source_checked {calls : Calls} {source : Input} {child : ChildReading}
    {checker : ConditionalChecker source.context} {state : Arms}
    (empty : ∀ flow, checker.check flow [] = some flow)
    (decode : elsePosition calls source state ≠ 0 →
      ∃ body, child (atPosition state.value (elsePosition calls source state)) .endOnly body
          (elseResult calls source state) ∧
        StatementsWellFormed source.context.hasArguments source.context.names.shape body
          (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) ∧
        checker.check (source.context.flow (atPosition state.value (elsePosition calls source state)).scan.facts) body =
          some (source.context.flow (elseResult calls source state).scan.facts)) :
    ∃ body, ElseCodeAt calls source child state body ∧
      StatementsWellFormed source.context.hasArguments source.context.names.shape body
        (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) ∧
      checker.check (source.context.flow state.value.scan.facts) body =
        some (source.context.flow (elseResult calls source state).scan.facts) := by
  by_cases missing : elsePosition calls source state = 0
  · refine ⟨[], .absent missing, ?_, ?_⟩
    · simp only [StatementsWellFormed]
    · simpa only [elseResult, missing, ne_self_iff_false, ite_false] using empty (source.context.flow state.value.scan.facts)
  · obtain ⟨body, read, wellFormed, checked⟩ := decode missing
    exact ⟨body, .present missing read, wellFormed, checked⟩

end Silver.ApplicationPackageBodies.Statement
