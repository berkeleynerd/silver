module

public import Silver.ApplicationAtomSafety

@[expose] public section

/-! Persistent package state is threaded through each iteration. Main's
ordinary readonly integer and restored-binder invariants remain available for
both counted loops and constant-array iteration. -/
namespace Silver.Applications
open Bindings Compose Predicate PathFacts
open ScalarFunctions (Frame)

theorem iterations_unchanged {step : Frame → Values → Integer.Store → Boolean.Store → Int → Execution}
    {globals : Frame} {values : Values} {integers : Integer.Store} {booleans : Boolean.Store}
    {indices : List Int} {index : Nat}
    (unchanged : ∀ shared current scalars flags value,
      (step shared current scalars flags value).integers index = scalars index) :
    (executeIterations step globals values integers booleans indices).integers index = integers index := by
  induction indices generalizing globals values integers booleans with
  | nil => rfl
  | cons value rest ih =>
      exact (ih (globals := (step globals values integers booleans value).globals)
        (values := (step globals values integers booleans value).values)
        (integers := (step globals values integers booleans value).integers)
        (booleans := (step globals values integers booleans value).booleans)).trans
          (unchanged globals values integers booleans value)

mutual
  theorem statement_unchanged {environment : Environment} {globals : Frame}
      {shape : Shape} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {before after : Flow}
      {item : Predicate.Statement} {input : Source} {valid : Bool} {values : Values}
      {integers : Integer.Store} {booleans : Boolean.Store} {index : Nat}
      (checked : item.check (signatures := environment.functionSignatures) (procedures := environment.procedureSignatures)
        shape analysis before booleanAnalysis = some after) (readonly : analysis.mutable index = false) :
      (executeStatement environment globals input valid values item integers booleans).integers index = integers index := by
    cases item with
    | choice condition yes no =>
        simp only [Predicate.Statement.check] at checked
        split at checked
        · simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, _⟩ := checked
          simp only [executeStatement]
          split
          · exact statements_unchanged yesChecked readonly
          · exact statements_unchanged noChecked readonly
        · contradiction
    | forLoop binder reverse lower upper body =>
        simp only [Predicate.Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, _, b, _, bodyAfter, bodyChecked, _⟩ := checked
        simp only [executeStatement]
        apply iterations_unchanged
        intro shared current scalars flags value
        by_cases same : index = binder
        · subst index
          simp only [Execution.restoreIndex, Integer.restore, Integer.put, ↓reduceIte]
        · have readonlyBody : (analysis.withIndex binder (Integer.loopBounds a b)).mutable index = false := by
            simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
          have preserved := statements_unchanged (environment := environment) (globals := shared)
            (input := input) (valid := valid) (values := current) (booleans := flags)
            (integers := Integer.put scalars binder value) bodyChecked readonlyBody
          simpa only [Execution.restoreIndex, Integer.restore, Integer.put, same, ↓reduceIte] using preserved
    | arrayLoop binder reverse array body =>
        simp only [Predicate.Statement.check] at checked
        split at checked
        · simp only [Option.map_eq_some_iff] at checked
          obtain ⟨bodyAfter, bodyChecked, _⟩ := checked
          simp only [executeStatement]
          apply iterations_unchanged
          intro shared current scalars flags component
          by_cases same : index = binder
          · subst index
            simp only [Execution.restoreIndex, Integer.restore, Integer.put, ↓reduceIte]
          · have readonlyBody : (analysis.withIndex binder array.componentBounds).mutable index = false := by
              simpa only [Integer.Analysis.withIndex, Integer.put, same, ↓reduceIte] using readonly
            have preserved := statements_unchanged (environment := environment) (globals := shared)
              (input := input) (valid := valid) (values := current) (booleans := flags)
              (integers := Integer.put scalars binder (array.project scalars component)) bodyChecked readonlyBody
            simpa only [Execution.restoreIndex, Integer.restore, Integer.put, same, ↓reduceIte] using preserved
        · contradiction
    | simple item | scalarAssign item | callAssign item | procedureCall item | arrayAssign item
    | booleanAssign item | booleanArrayAssign item =>
        simpa only [executeStatement, executeAtom, Execution.lift] using
          Predicate.statement_unchanged (functions := environment.functionsAt globals)
            (procedures := environment.proceduresAt globals) (input := input) (valid := valid)
            (values := values) (integers := integers) (booleans := booleans) checked readonly
    | reject => simp only [executeStatement, executeAtom, Execution.lift, Predicate.Statement.execute]
  termination_by sizeOf item

  theorem statements_unchanged {environment : Environment} {globals : Frame}
      {shape : Shape} {analysis : Integer.Analysis} {booleanAnalysis : Boolean.Analysis} {before after : Flow}
      {items : List Predicate.Statement} {input : Source} {valid : Bool} {values : Values}
      {integers : Integer.Store} {booleans : Boolean.Store} {index : Nat}
      (checked : Predicate.checkStatements (signatures := environment.functionSignatures)
        (procedures := environment.procedureSignatures) shape analysis before items booleanAnalysis = some after)
      (readonly : analysis.mutable index = false) :
      (executeStatements environment globals input valid values items integers booleans).integers index = integers index := by
    cases items with
    | nil => simp only [executeStatements]
    | cons item rest =>
        simp only [Predicate.checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        have first := statement_unchanged (environment := environment) (globals := globals)
          (input := input) (valid := valid) (values := values) (integers := integers) (booleans := booleans)
          firstChecked readonly
        have following := statements_unchanged (environment := environment)
          (globals := (executeStatement environment globals input valid values item integers booleans).globals)
          (input := input) (valid := valid)
          (values := (executeStatement environment globals input valid values item integers booleans).values)
          (integers := (executeStatement environment globals input valid values item integers booleans).integers)
          (booleans := (executeStatement environment globals input valid values item integers booleans).booleans)
          restChecked readonly
        simpa only [executeStatements] using following.trans first
  termination_by sizeOf items
end

theorem iterations_execution_sound {schema : Packages.StateSchema} {shape : Shape} {analysis : Integer.Analysis}
    {ranges : Integer.Ranges} {before after : Context} {globals : Frame}
    {input : Source} {valid rejected : Bool} {values : Values} {integers : Integer.Store}
    {booleans : Boolean.Store} {indices : List Int}
    {step : Frame → Values → Integer.Store → Boolean.Store → Int → Execution}
    {checkedStep : Frame → Values → Integer.Store → Boolean.Store → Int → Option Execution}
    (bodies : ∀ index ∈ indices, ∀ shared current scalars flags already,
      schema.Fits shared → Fits shape input current → before.Allows valid input.length already →
      Integer.Fits ranges scalars → Integer.Fits analysis.declared scalars →
      ExecutionSound schema shape analysis ⟨after, ranges⟩ input valid already
        (step shared current scalars flags index) (checkedStep shared current scalars flags index))
    (globalsFit : schema.Fits globals) (state : Fits shape input values)
    (allowed : before.Allows valid input.length rejected) (scalarState : Integer.Fits ranges integers)
    (declaredState : Integer.Fits analysis.declared integers) :
    ExecutionSound schema shape analysis ⟨if indices = [] then before else after, ranges⟩ input valid rejected
      (executeIterations step globals values integers booleans indices)
      (checkedIterations checkedStep globals values integers booleans indices) := by
  induction indices generalizing globals values integers booleans rejected with
  | nil =>
      exact ⟨state, by simp [executeIterations, Sequence.EffectsValid],
        by simp [executeIterations, NoOutput],
        by simpa only [executeIterations, rejectedAfter, List.any_nil, Bool.or_false, ↓reduceIte] using allowed,
        rfl, scalarState, declaredState, globalsFit⟩
  | cons index rest ih =>
      have first := bodies index (by simp) globals values integers booleans rejected
        globalsFit state allowed scalarState declaredState
      have remaining : ∀ item ∈ rest, ∀ shared current scalars flags already,
          schema.Fits shared → Fits shape input current → before.Allows valid input.length already →
          Integer.Fits ranges scalars → Integer.Fits analysis.declared scalars →
          ExecutionSound schema shape analysis ⟨after, ranges⟩ input valid already
            (step shared current scalars flags item) (checkedStep shared current scalars flags item) :=
        fun item member => bodies item (List.mem_cons_of_mem index member)
      have following := ih (booleans := (step globals values integers booleans index).booleans)
        remaining first.globals first.state
        (allows_after_effects allowed (step globals values integers booleans index).effects) first.scalars first.declared
      refine ⟨following.state, ?_, ?_, ?_, ?_, following.scalars, following.declared, following.globals⟩
      · exact Sequence.effects_valid_append first.effects following.effects
      · intro invalid
        exact noOutput_append (first.invalid_no_output invalid) (following.invalid_no_output invalid)
      · by_cases empty : rest = []
        · subst rest
          simpa only [executeIterations, List.append_nil, List.cons_ne_nil, ↓reduceIte] using first.next
        · simpa only [executeIterations, rejectedAfter_append, empty, List.cons_ne_nil, ↓reduceIte] using following.next
      · simp only [checkedIterations, first.agreement, Option.bind_some, following.agreement,
          Option.map_some, executeIterations]

end Silver.Applications
