module

public import Silver.PackageDefinitions
public import Silver.PackageChecking

@[expose] public section

/-! Native summaries may conservatively include effects and store cells in a
different order. The semantic environment keeps those summaries at the original
routine identities; sound extension requires membership inclusion only. -/
namespace Silver.Packages.EffectSummaries
open ScalarFunctions (Frame)

structure Included (inferred summary : Effects) : Prop where
  reads : ∀ cell ∈ inferred.reads, cell ∈ summary.reads
  writes : ∀ cell ∈ inferred.writes, cell ∈ summary.writes

theorem Included.refl (effects : Effects) : Included effects effects :=
  ⟨fun _ member => member, fun _ member => member⟩

theorem Included.trans {first middle last : Effects}
    (left : Included first middle) (right : Included middle last) : Included first last :=
  ⟨fun cell member => right.reads cell (left.reads cell member),
    fun cell member => right.writes cell (left.writes cell member)⟩

theorem Included.cells {inferred summary : Effects} (included : Included inferred summary) :
    ∀ cell ∈ inferred.cells, cell ∈ summary.cells := by
  intro cell member
  rcases (Effects.mem_cells _ _).mp member with read | written
  · exact (Effects.mem_cells _ _).mpr (Or.inl (included.reads cell read))
  · exact (Effects.mem_cells _ _).mpr (Or.inr (included.writes cell written))

theorem Included.merge {first second firstSummary secondSummary : Effects}
    (left : Included first firstSummary) (right : Included second secondSummary) :
    Included (first.merge second) (firstSummary.merge secondSummary) := by
  constructor
  · intro cell member
    exact (List.mem_append.mp member).elim
      (fun read => List.mem_append_left _ (left.reads cell read))
      (fun read => List.mem_append_right _ (right.reads cell read))
  · intro cell member
    exact (List.mem_append.mp member).elim
      (fun write => List.mem_append_left _ (left.writes cell write))
      (fun write => List.mem_append_right _ (right.writes cell write))

theorem Included.merge_bound {first second summary : Effects}
    (left : Included first summary) (right : Included second summary) :
    Included (first.merge second) summary := by
  constructor
  · intro cell member
    exact (List.mem_append.mp member).elim (left.reads cell) (right.reads cell)
  · intro cell member
    exact (List.mem_append.mp member).elim (left.writes cell) (right.writes cell)

/- Successful semantic checking resolves exactly the callable identities used
by effect inference. No guessed summary or separate call-resolution premise is
needed, and both branches and every loop body are retained. -/
mutual
  theorem statement_inference {earlier : EffectEnvironment} {layout : FrameLayout}
      {analysis : Integer.Analysis} {before after : Predicate.Flow} {booleans : Boolean.Analysis}
      {statement : Predicate.Statement}
      (checked : checkPackageStatement earlier layout analysis before booleans statement = some after) :
      ∃ effects, inferStatementEffects earlier layout statement = some effects := by
    cases statement with
    | simple item =>
        cases item with
        | null => exact ⟨⟨[], []⟩, by simp only [inferStatementEffects]⟩
        | assign | output | put => simp only [checkPackageStatement] at checked; contradiction
    | scalarAssign | booleanAssign => exact ⟨_, by simp only [inferStatementEffects]; rfl⟩
    | callAssign update =>
        simp only [checkPackageStatement, checkFunctionAssignment, Option.bind_eq_some_iff] at checked
        obtain ⟨domain, called, _⟩ := checked
        obtain ⟨signature, found, _, _⟩ := checkFunction_success called
        have mapped : (lookupRoutine earlier update.call.callee).map RoutineEffects.signature =
            some (.function signature) := by
          by_cases zero : update.call.callee = 0
          · simp only [lookupRoutine, zero, ite_true] at found
            contradiction
          · simpa only [lookupRoutine, zero, ite_false, List.getElem?_map] using found
        obtain ⟨routine, known, kind⟩ := Option.map_eq_some_iff.mp mapped
        exact ⟨_, by simp only [inferStatementEffects, known, Option.bind_some, kind]; rfl⟩
    | procedureCall call =>
        simp only [checkPackageStatement, checkProcedureCall] at checked
        split at checked
        · simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨resolved, bound, routine, known, _⟩ := checked
          exact ⟨_, by simp only [inferStatementEffects, bound, Option.bind_some, known, Option.map_some]; rfl⟩
        · contradiction
    | choice condition yes no =>
        simp only [checkPackageStatement] at checked
        split at checked
        · simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, _⟩ := checked
          obtain ⟨left, inferredLeft⟩ := statements_inference yesChecked
          obtain ⟨right, inferredRight⟩ := statements_inference noChecked
          exact ⟨_, by simp only [inferStatementEffects, inferredLeft, Option.bind_some,
            inferredRight, Option.map_some]; rfl⟩
        · contradiction
    | forLoop index reverse lower upper body =>
        simp only [checkPackageStatement, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨_, _, _, _, _, bodyChecked, _⟩ := checked
        obtain ⟨inner, inferred⟩ := statements_inference bodyChecked
        exact ⟨_, by simp only [inferStatementEffects, inferred, Option.map_some]; rfl⟩
    | arrayAssign | booleanArrayAssign | reject | arrayLoop =>
        simp only [checkPackageStatement] at checked
        contradiction
  termination_by sizeOf statement

  theorem statements_inference {earlier : EffectEnvironment} {layout : FrameLayout}
      {analysis : Integer.Analysis} {before after : Predicate.Flow} {booleans : Boolean.Analysis}
      {statements : List Predicate.Statement}
      (checked : checkPackageStatements earlier layout analysis before booleans statements = some after) :
      ∃ effects, inferStatementsEffects earlier layout statements = some effects := by
    cases statements with
    | nil => exact ⟨⟨[], []⟩, by simp only [inferStatementsEffects]⟩
    | cons statement rest =>
        simp only [checkPackageStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, first, later⟩ := checked
        obtain ⟨head, inferredHead⟩ := statement_inference first
        obtain ⟨tail, inferredTail⟩ := statements_inference later
        exact ⟨_, by simp only [inferStatementsEffects, inferredHead, Option.bind_some,
          inferredTail, Option.map_some]; rfl⟩
  termination_by sizeOf statements
end

theorem body_inference {earlier : EffectEnvironment} {layout : FrameLayout}
    {analysis : Integer.Analysis} {before after : Predicate.Flow} {booleans : Boolean.Analysis}
    {statements : List Predicate.Statement}
    (scalar : ScalarProcedures.scalarStatements statements = true)
    (checked : checkPackageStatements earlier layout analysis before booleans statements = some after) :
    ∃ effects, inferBodyEffects earlier layout statements = some effects := by
  simpa only [inferBodyEffects, scalar, ite_true] using statements_inference checked

/-- Extra native capture cells preserve their incoming values unless the
inferred write footprint contains them. Both cases are proved by execution. -/
theorem execute_local_summary {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.LocalOn earlier) {definition : RoutineDefinition} {effects summary : Effects}
    (inferred : definition.inferEffects earlier = some effects) (included : Included effects summary)
    {first second : Frame} (same : EqualOn summary.cells first second) (inputs : List ScalarFunctions.Value) :
    (definition.execute environment second inputs).2 = (definition.execute environment first inputs).2 ∧
      EqualOn summary.cells (definition.execute environment first inputs).1
        (definition.execute environment second inputs).1 := by
  have precise := definition.execute_local previous inferred (same.mono included.cells) inputs
  exact ⟨precise.1, same.after_call precise.2
    (definition.execute_changes previous.footprints inferred first inputs)
    (definition.execute_changes previous.footprints inferred second inputs)⟩

theorem append_respects_summary {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.RespectsEffects earlier) {definition : RoutineDefinition} {effects summary : Effects}
    (inferred : definition.inferEffects earlier = some effects) (included : Included effects summary) :
    (environment.append definition).RespectsEffects (earlier ++ [⟨definition.signature, summary⟩]) := by
  refine ⟨by simp [SharedEnvironment.append, previous.1], ?_⟩
  intro identity routine found globals inputs
  rcases lookupRoutine_append found with ⟨old, known⟩ | ⟨current, rfl⟩
  · have apart : identity ≠ environment.signatures.length + 1 := by rw [previous.1, List.length_map]; omega
    simpa [SharedEnvironment.append, apart] using previous.2 identity routine known globals inputs
  · have same : identity = environment.signatures.length + 1 := by simpa [previous.1] using current
    cases kind : definition.signature with
    | function => simpa [SharedEnvironment.append, same, kind] using changesOnly_refl summary.writes globals
    | procedure =>
        simpa [SharedEnvironment.append, same, kind] using changesOnly_mono included.writes
          (definition.execute_changes previous inferred globals inputs)

/-- Keep the native summary table at the original declaration-order identity.
No checker or source-call transport to an inferred-effect table is necessary. -/
theorem append_local_summary {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.LocalOn earlier) {definition : RoutineDefinition} {effects summary : Effects}
    (inferred : definition.inferEffects earlier = some effects) (included : Included effects summary) :
    (environment.append definition).LocalOn (earlier ++ [⟨definition.signature, summary⟩]) := by
  refine ⟨append_respects_summary previous.footprints inferred included, ?_, ?_⟩
  · intro identity routine found first second inputs same
    rcases lookupRoutine_append found with ⟨old, known⟩ | ⟨current, rfl⟩
    · have apart : identity ≠ environment.signatures.length + 1 := by
        rw [previous.footprints.1, List.length_map]; omega
      simpa [SharedEnvironment.append, apart] using previous.functions identity routine known first second inputs same
    · have current : identity = environment.signatures.length + 1 := by
        simpa [previous.footprints.1] using current
      cases kind : definition.signature with
      | function =>
          simp only [SharedEnvironment.append, current, ↓reduceIte, kind]
          exact congrArg (fun values => values.headD (.integer 0))
            (execute_local_summary previous inferred included same inputs).1
      | procedure => simp [SharedEnvironment.append, current, kind]
  · intro identity routine found first second inputs same
    rcases lookupRoutine_append found with ⟨old, known⟩ | ⟨current, rfl⟩
    · have apart : identity ≠ environment.signatures.length + 1 := by
        rw [previous.footprints.1, List.length_map]; omega
      simpa [SharedEnvironment.append, apart] using previous.procedures identity routine known first second inputs same
    · have current : identity = environment.signatures.length + 1 := by
        simpa [previous.footprints.1] using current
      cases kind : definition.signature with
      | function => simpa [SharedEnvironment.append, current, kind] using And.intro (rfl : ([] : List ScalarFunctions.Value) = []) same
      | procedure => simpa [SharedEnvironment.append, current, kind] using execute_local_summary previous inferred included same inputs

end Silver.Packages.EffectSummaries
