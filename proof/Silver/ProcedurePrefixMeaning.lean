module

public import Silver.ProcedurePrefixReadings
public import Silver.PredicateFunctionCallMeaning
public import Silver.FunctionInitializerShape
public import Silver.ScalarProcedureNoninterference

@[expose] public section

namespace Silver.Compose
open Predicate ScalarProcedures

/-- A cell outside the fixed read frame has no source binding in a prefix RHS.
Integer and Boolean identities use independent stores. -/
def ProcedureCellOutside (context : ParseContext) : Cell → Prop
  | .integer identity => context.scalarNames.length < identity
  | .boolean identity => context.booleanNames.length < identity

private theorem integerMentions_readsOnly {expression : Integer.Expr} {count identity : Nat}
    (source : expression.ReadsOnly (fun index => 0 < index ∧ index ≤ count))
    (outside : count < identity) : integerMentions identity expression = false := by
  induction expression with
  | literal | snapshot => rfl
  | name index =>
      simp only [Integer.Expr.ReadsOnly] at source
      simp only [integerMentions, beq_eq_false_iff_ne]
      omega
  | indexed => exact False.elim source
  | positive _ ih | negative _ ih | parenthesized _ ih => exact ih source
  | add _ _ ihl ihr | subtract _ _ ihl ihr | multiply _ _ ihl ihr
  | divide _ _ ihl ihr | modulo _ _ ihl ihr | remainder _ _ ihl ihr =>
      exact Bool.or_eq_false_iff.mpr ⟨ihl source.1, ihr source.2⟩

theorem prefix_scalar_read_absent {text} {context : ParseContext}
    {position facts expression result maskFirst maskAfter allowSign initials}
    (closed : context.arrayNames = []) (identity : Nat) (outside : context.scalarNames.length < identity)
    (source : ScalarExpression.At text (context.readingNames facts) position expression result
      maskFirst maskAfter allowSign context.arrayNames initials context.elaborating) :
    integerMentions identity expression = false := by
  rw [closed] at source
  apply integerMentions_readsOnly (ScalarExpression.syntax_readsOnly source.grammar)
  simpa only [ParseContext.readingNames, ScalarMetadata.readingNames_length] using outside

mutual
  theorem prefix_primary_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : PrimaryAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | group _ _ _ inner _ =>
        simpa only [conditionMentions] using prefix_condition_read_absent closed cell outside inner
    | boolean _ _ _ _ _ atom =>
        cases atom with
        | name _ _ =>
            cases cell with
            | integer => rfl
            | boolean identity =>
                have bounded := BooleanBindings.lookup_bound text context.booleanNames
                  (skipAt text position) (nameAfter text (skipAt text position))
                simp only [ProcedureCellOutside] at outside
                change (Cell.boolean identity == .boolean _) = false
                apply beq_eq_false_iff_ne.mpr
                intro same
                have indices := Cell.boolean.inj same
                omega
        | literal => cases cell <;> rfl
    | valid => rfl
    | booleanArray _ _ _ _ atom =>
        cases atom with
        | read found _ _ _ _ _ _ _ =>
            simp [closed.noArrays, ArrayBindings.lookup, ArrayBindings.lookupFrom] at found
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem prefix_booleanFactor_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : BooleanFactorAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | primary _ inner => exact prefix_primary_read_absent closed cell outside inner
    | negated _ _ inner =>
        simpa only [conditionMentions] using prefix_primary_read_absent closed cell outside inner
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem prefix_booleanRelation_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : BooleanRelationAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | factor inner _ _ => exact prefix_booleanFactor_read_absent closed cell outside inner
    | comparison left _ _ _ _ right _ =>
        exact Bool.or_eq_false_iff.mpr ⟨prefix_booleanFactor_read_absent closed cell outside left,
          prefix_booleanFactor_read_absent closed cell outside right⟩
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem prefix_relation_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : RelationAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | booleanNot _ _ inner | pureBoolean _ _ _ _ _ inner =>
        exact prefix_booleanRelation_read_absent closed cell outside inner
    | length => rfl
    | scalars _ _ _ _ left right _ =>
        cases cell with
        | boolean => rfl
        | integer identity =>
            exact Bool.or_eq_false_iff.mpr ⟨prefix_scalar_read_absent closed.noArrays identity outside left,
              prefix_scalar_read_absent closed.noArrays identity outside right⟩
    | strings _ _ _ _ _ _ _ _ impure | character _ _ _ _ _ _ impure
    | primary _ _ _ _ _ _ _ impure => simp [closed.pure] at impure
  termination_by (remainingAt text position, 4)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem prefix_chain_read_absent {text context condition result chained final finalResult facts initials originalStart}
      (closed : ClosedFunctionContext context) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : ChainAt text context condition result chained final finalResult facts initials originalStart)
      (first : conditionMentions cell condition = false) : conditionMentions cell final = false := by
    cases source with
    | done => exact first
    | @next _ _ condition result chained operator right rightResult final finalResult _ _ _ _ _ _ _ rightRead _ _ _ rest =>
        apply prefix_chain_read_absent closed cell outside rest
        have following := prefix_relation_read_absent closed cell outside rightRead
        cases operator <;> exact Bool.or_eq_false_iff.mpr ⟨first, following⟩
  termination_by (remainingAt text result.after, 6)
  decreasing_by all_goals subst_vars; all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem prefix_condition_read_absent {text context position facts condition result initials}
      (closed : ClosedFunctionContext context) (cell : Cell) (outside : ProcedureCellOutside context cell)
      (source : ConditionAt text context position facts condition result initials) :
      conditionMentions cell condition = false := by
    cases source with
    | condition _ first _ _ tail =>
        exact prefix_chain_read_absent closed cell outside tail (prefix_relation_read_absent closed cell outside first)
  termination_by (remainingAt text position, 5)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

theorem prefix_actual_read_absent {text context position facts formal actual after}
    (closed : ClosedFunctionContext context) (cell : Cell) (outside : ProcedureCellOutside context cell)
    (source : ActualAt text context position facts formal actual after) : valueMentions cell actual = false := by
  cases source.payload with
  | integer _ expression _ _ =>
      cases cell with
      | integer identity => exact prefix_scalar_read_absent closed.noArrays identity outside expression
      | boolean => rfl
  | boolean _ condition => exact prefix_condition_read_absent closed cell outside condition

theorem ProcedurePrefixAt.reads_absent {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (closed : ClosedFunctionContext (procedurePrefixContext readFrame declarationCount))
    (cell : Cell) (outside : ProcedureCellOutside (procedurePrefixContext readFrame declarationCount) cell) :
    ∀ actual ∈ actuals, valueMentions cell actual = false := by
  induction source with
  | done => simp
  | skip _ _ _ _ ih => exact ih
  | next _ _ _ first _ _ ih =>
      intro actual member
      rcases List.mem_cons.mp member with rfl | later
      · exact prefix_actual_read_absent closed cell outside first.value
      · exact ih actual later

theorem ProcedurePrefixAt.scalarOnly {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (closed : ClosedFunctionContext (procedurePrefixContext readFrame declarationCount)) :
    actuals.all ScalarFunctions.scalarActual = true := by
  induction source with
  | done => rfl
  | skip _ _ _ _ ih => exact ih
  | next _ _ _ first _ _ ih =>
      exact Bool.and_eq_true_iff.mpr ⟨actual_source_scalar closed first.value, ih⟩

theorem ProcedurePrefixAt.meaning {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (normal : NamesNormal (procedurePrefixContext readFrame declarationCount).names)
    (names : Expressions.ValidNames text (procedurePrefixContext readFrame declarationCount).names)
    (ready : ScalarMetadata.ContextReady (procedurePrefixContext readFrame declarationCount).scalarNames
      declarationCount (procedurePrefixContext readFrame declarationCount).elaborating)
    (arrays : (procedurePrefixContext readFrame declarationCount).ArraysReady text)
    (compatible : ScalarMetadata.OverlayCompatible (procedurePrefixContext readFrame declarationCount).scalarNames
      declarationCount (procedurePrefixFacts readFrame declarationCount))
    (bounded : (procedurePrefixFacts readFrame declarationCount).path.Bounded) :
    (∀ actual ∈ actuals, actual.Readable (procedurePrefixContext readFrame declarationCount).hasArguments
      (procedurePrefixContext readFrame declarationCount).names.shape
      (ArrayBindings.booleanAnalysis (procedurePrefixContext readFrame declarationCount).arrayNames
        (BooleanBindings.analysis (procedurePrefixContext readFrame declarationCount).booleanNames))) ∧
    ScalarFunctions.checkActuals (procedurePrefixContext readFrame declarationCount).names.shape
      (procedurePrefixContext readFrame declarationCount).analysis
      ((procedurePrefixContext readFrame declarationCount).flow (procedurePrefixFacts readFrame declarationCount))
      (ArrayBindings.booleanAnalysis (procedurePrefixContext readFrame declarationCount).arrayNames
        (BooleanBindings.analysis (procedurePrefixContext readFrame declarationCount).booleanNames))
      (outTypes (ProcedureBindings.formalModels frame.procedures index
        (frame.procedures.parameters.length + 1 - index))) actuals = true := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.procedures.parameters.length + 1 - index = 0 := by omega
      simp [empty, ProcedureBindings.formalModels, outTypes, ScalarFunctions.checkActuals]
  | @skip before final index actuals _ more input _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      cases mode : (ProcedureBindings.parameter before.procedures index).mode <;>
        simp_all [ProcedureBindings.formalModel, ProcedureBindings.modeModel, outTypes]
  | @next before middle final index actual actuals _ more output first _ _ ih =>
      have preserved := congrArg ParserState.procedures first.fields
      change middle.procedures = before.procedures at preserved
      rw [preserved] at ih
      have meaning := actual_meaning normal names ready arrays compatible bounded first.value
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      refine ⟨?_, ?_⟩
      · intro item member
        rcases List.mem_cons.mp member with rfl | later
        · exact meaning.1
        · exact ih.1 item later
      · rw [remaining, ProcedureBindings.formalModels]
        simp only [ProcedureBindings.formalModel, output, ProcedureBindings.modeModel, outTypes,
          ScalarFunctions.checkActuals]
        exact Bool.and_eq_true_iff.mpr ⟨meaning.2, ih.2⟩

theorem procedurePrefixStep_valid {text readFrame frame formal declarationCount}
    (valid : Expressions.ValidState text frame) (typed : ProcedureBindings.ValidFormal text formal) :
    Expressions.ValidState text (procedurePrefixStep text readFrame frame formal declarationCount) := by
  dsimp only [procedurePrefixStep]
  split
  · exact Expressions.model_invalid_state_valid text
  · apply appendProcedureParameter_valid
    · exact Expressions.model_state_position_valid text frame valid _
        (fixedAfter_result_bound text _ ";" false (by decide))
    · exact typed

theorem ProcedurePrefixAt.valid {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (valid : Expressions.ValidState text frame) (positive : 0 < index) : Expressions.ValidState text final := by
  induction source with
  | done => exact valid
  | skip _ _ _ _ ih => exact ih valid (by omega)
  | @next before middle final index actual actuals _ inside _ first _ _ ih =>
      have typed := valid.procedures.2.2.1 _ (ProcedureBindings.parameter_mem positive inside)
      have next := procedurePrefixStep_valid (readFrame := readFrame) (declarationCount := declarationCount) valid typed
      rw [first.complete] at next
      exact ih next (by omega)

theorem ProcedurePrefixAt.headerReady {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (valid : Expressions.ValidState text frame) (positive : 0 < index)
    (ready : ScalarMetadata.HeaderReady frame.scalarNames) : ScalarMetadata.HeaderReady final.scalarNames := by
  induction source with
  | done => exact ready
  | skip _ _ _ _ ih => exact ih valid (by omega) ready
  | @next before middle final index actual actuals _ inside _ first _ _ ih =>
      have typed := valid.procedures.2.2.1 _ (ProcedureBindings.parameter_mem positive inside)
      have next := procedurePrefixStep_valid (readFrame := readFrame) (declarationCount := declarationCount) valid typed
      rw [first.complete] at next
      apply ih next (by omega)
      rw [first.installed]
      exact appendProcedureParameter_headerReady ready typed.2.2

theorem ProcedurePrefixAt.analyses {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (declarations : Nat) (count : declarations ≤ frame.scalarNames.length) :
    functionScalarAnalysis final declarations =
      parameterAnalysis frame.scalarNames.length
        (outFormals (ProcedureBindings.formalModels frame.procedures index
          (frame.procedures.parameters.length + 1 - index))) (functionScalarAnalysis frame declarations) ∧
    BooleanBindings.analysis final.booleanNames =
      parameterBooleans frame.booleanNames.length
        (outFormals (ProcedureBindings.formalModels frame.procedures index
          (frame.procedures.parameters.length + 1 - index))) (BooleanBindings.analysis frame.booleanNames) := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.procedures.parameters.length + 1 - index = 0 := by omega
      simp [empty, ProcedureBindings.formalModels, outFormals, parameterAnalysis, parameterBooleans]
  | @skip before final index actuals _ more input _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      cases mode : (ProcedureBindings.parameter before.procedures index).mode <;>
        simp_all [ProcedureBindings.formalModel, ProcedureBindings.modeModel, outFormals]
  | @next before middle final index actual actuals _ more output first _ _ ih =>
      have grows := appendProcedureParameter_grows _ _ (first.installed ▸ first.accepted)
      rw [← first.installed] at grows
      have tail := ih (Nat.le_trans count grows.1)
      rw [first.installed] at tail
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      have accepted := first.installed ▸ first.accepted
      let advancedFrame : ParserState := {before with position := fixedAfter text (procedurePrefixValueAfter text readFrame before (ProcedureBindings.parameter before.procedures index) declarationCount) ";" false}
      have step := appendProcedureParameter_analyses advancedFrame
        (ProcedureBindings.parameter before.procedures index) declarations count accepted
      rw [step.1, step.2] at tail
      cases kind : (ProcedureBindings.parameter before.procedures index).kind with
      | integer =>
          have space : before.scalarNames.length ≠ ScalarExpression.maxBindings := by
            intro full
            simp [appendProcedureParameter, kind, full, invalidState] at accepted
          simp only [appendProcedureParameter, kind, ↓reduceIte, space] at tail
          have writableMode : (ScalarProcedures.Mode.output != .input) = true := by decide
          simpa [ProcedureBindings.formalModel, kind, output, ProcedureBindings.modeModel,
            outFormals, parameterAnalysis, parameterBooleans, functionScalarAnalysis,
            advancedFrame, writableMode] using tail
      | boolean =>
          have space : before.booleanNames.length ≠ BooleanBindings.maxBindings := by
            intro full
            simp [appendProcedureParameter, kind, full, invalidState] at accepted
          simp only [appendProcedureParameter, kind, reduceCtorEq, ↓reduceIte, space] at tail
          have writableMode : (ScalarProcedures.Mode.output != .input) = true := by decide
          simpa [ProcedureBindings.formalModel, kind, output, ProcedureBindings.modeModel,
            outFormals, parameterAnalysis, parameterBooleans, functionScalarAnalysis,
            advancedFrame, writableMode] using tail

end Silver.Compose

namespace Silver.ScalarProcedures
open ScalarFunctions (Target Value State)

/-- Fresh cells for the mandatory out-only initialization tuple. Their order
is the filtered declaration order, with separate Integer and Boolean indexes. -/
def prefixTargets : Nat → Nat → List ScalarFunctions.ScalarType → List Target
  | integers, booleans, .integer bounds :: rest =>
      .integer (integers + 1) bounds :: prefixTargets (integers + 1) booleans rest
  | integers, booleans, .boolean :: rest =>
      .boolean (booleans + 1) :: prefixTargets integers (booleans + 1) rest
  | _, _, [] => []

theorem prefixTargets_outside (integers booleans : Nat) (domains : List ScalarFunctions.ScalarType)
    (integerBound booleanBound : Nat) (integerBefore : integerBound ≤ integers) (booleanBefore : booleanBound ≤ booleans)
    (target : Target) (member : target ∈ prefixTargets integers booleans domains) :
    match targetCell target with
    | .integer identity => integerBound < identity
    | .boolean identity => booleanBound < identity := by
  induction domains generalizing integers booleans with
  | nil => simp [prefixTargets] at member
  | cons domain domains ih =>
      cases domain with
      | integer bounds =>
          rcases List.mem_cons.mp member with rfl | later
          · dsimp only [targetCell]; omega
          · exact ih (integers + 1) booleans (by omega) booleanBefore later
      | boolean =>
          rcases List.mem_cons.mp member with rfl | later
          · dsimp only [targetCell]; omega
          · exact ih integers (booleans + 1) integerBefore (by omega) later

theorem copyBack_prefixTargets {domains : List ScalarFunctions.ScalarType} {values : List Value}
    (fitting : ScalarFunctions.ArgumentsFit domains values) (integers booleans : Nat) (state : State) :
    copyBack (prefixTargets integers booleans domains) values state =
      {state with
        integers := (ScalarFunctions.bindArguments integers booleans domains values
          ⟨state.integers, state.booleans⟩).integers,
        booleans := (ScalarFunctions.bindArguments integers booleans domains values
          ⟨state.integers, state.booleans⟩).booleans} := by
  induction domains generalizing values integers booleans state with
  | nil =>
      cases values with
      | nil => rfl
      | cons => exact False.elim fitting
  | cons domain domains ih =>
      cases values with
      | nil => exact False.elim fitting
      | cons value values =>
          cases domain <;> cases value
          all_goals try exact False.elim fitting.1
          · exact ih fitting.2 (integers + 1) booleans _
          · exact ih fitting.2 integers (booleans + 1) _

/-- Ordinary source assignments evaluate each RHS in the state produced by
the preceding assignment. The source bridge proves this equals frozen input
evaluation because every output target is absent from every prefix RHS. -/
def executePrefix : List Target → List ScalarFunctions.Actual → State → State
  | target :: targets, actual :: actuals, state =>
      executePrefix targets actuals (target.write (actual.evaluate state) state)
  | _, _, state => state

theorem evaluateActuals_write_noninterference {actuals : List ScalarFunctions.Actual}
    {shape : Bindings.Shape} {state : State} {target : Target} (value : Value)
    (safe : ∀ actual ∈ actuals, actual.Safe shape state)
    (absent : ∀ actual ∈ actuals, valueMentions (targetCell target) actual = false) :
    ScalarFunctions.evaluateActuals (target.write value state) actuals = ScalarFunctions.evaluateActuals state actuals := by
  induction actuals with
  | nil => rfl
  | cons actual actuals ih =>
      have first := actual_write_noninterference value (safe actual (by simp)) (absent actual (by simp))
      change actual.evaluate (target.write value state) :: ScalarFunctions.evaluateActuals (target.write value state) actuals =
        actual.evaluate state :: ScalarFunctions.evaluateActuals state actuals
      rw [first.2, ih (fun item member => safe item (by simp [member]))
        (fun item member => absent item (by simp [member]))]

theorem executePrefix_eq_frozen {targets : List Target} {actuals : List ScalarFunctions.Actual}
    {shape : Bindings.Shape} {state : State}
    (safe : ∀ actual ∈ actuals, actual.Safe shape state)
    (absent : ∀ target ∈ targets, ∀ actual ∈ actuals, valueMentions (targetCell target) actual = false) :
    executePrefix targets actuals state = copyBack targets (ScalarFunctions.evaluateActuals state actuals) state := by
  induction targets generalizing actuals state with
  | nil => rfl
  | cons target targets ih =>
      cases actuals with
      | nil => rfl
      | cons actual actuals =>
          have remainingSafe : ∀ item ∈ actuals,
              item.Safe shape (target.write (actual.evaluate state) state) := by
            intro item member
            exact (actual_write_noninterference (actual.evaluate state)
              (safe item (by simp [member])) (absent target (by simp) item (by simp [member]))).1
          have remainingAbsent : ∀ other ∈ targets, ∀ item ∈ actuals,
              valueMentions (targetCell other) item = false := by
            intro other otherMember item itemMember
            exact absent other (by simp [otherMember]) item (by simp [itemMember])
          change executePrefix targets actuals (target.write (actual.evaluate state) state) =
            copyBack targets (ScalarFunctions.evaluateActuals state actuals) (target.write (actual.evaluate state) state)
          rw [ih remainingSafe remainingAbsent]
          rw [evaluateActuals_write_noninterference (actual.evaluate state)
            (fun item member => safe item (by simp [member]))
            (fun item member => absent target (by simp) item (by simp [member]))]

end Silver.ScalarProcedures

namespace Silver.Compose
open Predicate ScalarProcedures

/-- The source checker supplies safety in the fixed incoming state. Syntactic
read origins supply absence of every fresh output cell, including on branches
that are never evaluated for that particular input. -/
theorem ProcedurePrefixAt.sequential_eq_frozen {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (closed : ClosedFunctionContext (procedurePrefixContext readFrame declarationCount))
    (integers : readFrame.scalarNames.length ≤ frame.scalarNames.length)
    (booleans : readFrame.booleanNames.length ≤ frame.booleanNames.length)
    {state : ScalarFunctions.State} {shape : Bindings.Shape}
    (safe : ∀ actual ∈ actuals, actual.Safe shape state) :
    executePrefix (prefixTargets frame.scalarNames.length frame.booleanNames.length
      (outTypes (ProcedureBindings.formalModels frame.procedures index
        (frame.procedures.parameters.length + 1 - index)))) actuals state =
      copyBack (prefixTargets frame.scalarNames.length frame.booleanNames.length
        (outTypes (ProcedureBindings.formalModels frame.procedures index
          (frame.procedures.parameters.length + 1 - index))))
        (ScalarFunctions.evaluateActuals state actuals) state := by
  apply executePrefix_eq_frozen safe
  intro target member
  apply source.reads_absent closed (targetCell target)
  have outside := prefixTargets_outside frame.scalarNames.length frame.booleanNames.length _
    readFrame.scalarNames.length readFrame.booleanNames.length integers booleans target member
  cases cell : targetCell target <;>
    simpa only [ProcedureCellOutside, procedurePrefixContext, contextOf,
      ScalarExpression.bodyEnvironment_length, cell] using outside

/-- Accepted prefix source is safe over every fitting local/input state. The
conclusion constructs the output frame from those actual source expressions;
it assumes neither a completed declaration law nor an initialized out value. -/
theorem ProcedurePrefixAt.execution {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (valid : Expressions.ValidState text readFrame) (closed : ClosedFunctionState readFrame)
    (ready : ScalarMetadata.HeaderReady readFrame.scalarNames)
    (count : declarationCount ≤ readFrame.scalarNames.length)
    (integers : readFrame.scalarNames.length ≤ frame.scalarNames.length)
    (booleans : readFrame.booleanNames.length ≤ frame.booleanNames.length)
    (state : ScalarFunctions.State)
    (strings : Bindings.Fits (procedurePrefixContext readFrame declarationCount).names.shape state.input state.values)
    {rejected : Bool}
    (allowed : ((procedurePrefixContext readFrame declarationCount).flow (procedurePrefixFacts readFrame declarationCount)).Allows
      state.inputValid state.input.length rejected state.integers) :
    (∀ actual ∈ actuals, actual.Safe (procedurePrefixContext readFrame declarationCount).names.shape state) ∧
    ScalarFunctions.ArgumentsFit (outTypes (ProcedureBindings.formalModels frame.procedures index
      (frame.procedures.parameters.length + 1 - index))) (ScalarFunctions.evaluateActuals state actuals) ∧
    executePrefix (prefixTargets frame.scalarNames.length frame.booleanNames.length
      (outTypes (ProcedureBindings.formalModels frame.procedures index
        (frame.procedures.parameters.length + 1 - index)))) actuals state =
      {state with
        integers := (ScalarFunctions.bindArguments frame.scalarNames.length frame.booleanNames.length
          (outTypes (ProcedureBindings.formalModels frame.procedures index
            (frame.procedures.parameters.length + 1 - index)))
          (ScalarFunctions.evaluateActuals state actuals) ⟨state.integers, state.booleans⟩).integers,
        booleans := (ScalarFunctions.bindArguments frame.scalarNames.length frame.booleanNames.length
          (outTypes (ProcedureBindings.formalModels frame.procedures index
            (frame.procedures.parameters.length + 1 - index)))
          (ScalarFunctions.evaluateActuals state actuals) ⟨state.integers, state.booleans⟩).booleans} := by
  have contextClosed : ClosedFunctionContext (procedurePrefixContext readFrame declarationCount) := by
    refine ⟨closed.pure, ?_, closed.noNames, closed.noArrays⟩
    change decide (readFrame.dynamicFirst ≠ 0) = false
    simp only [closed.noArguments, ne_eq, not_true_eq_false, decide_false]
  have normal : NamesNormal (procedurePrefixContext readFrame declarationCount).names := by
    rw [contextClosed.noNames]
    constructor <;> simp [NamesWellTyped, Bindings.BindingEnvironment.get]
  have names : Expressions.ValidNames text (procedurePrefixContext readFrame declarationCount).names := valid.2.1
  have contextReady : ScalarMetadata.ContextReady (procedurePrefixContext readFrame declarationCount).scalarNames
      declarationCount (procedurePrefixContext readFrame declarationCount).elaborating :=
    functionFrame_contextReady declarationCount valid ready count
  have arraysReady : (procedurePrefixContext readFrame declarationCount).ArraysReady text := by
    simp [ParseContext.ArraysReady, contextClosed.noArrays, ArrayBindings.ValidMetadata]
  have compatible : ScalarMetadata.OverlayCompatible (procedurePrefixContext readFrame declarationCount).scalarNames
      declarationCount (procedurePrefixFacts readFrame declarationCount) := ScalarMetadata.initial_compatible ..
  have bounded : (procedurePrefixFacts readFrame declarationCount).path.Bounded := by
    simp [procedurePrefixFacts, ActiveFlow.initial, contextClosed.noArguments, initialFacts,
      PathFacts.Context.Bounded, PathFacts.Region.Bounded]
  have checked := source.meaning normal names contextReady arraysReady compatible bounded
  have sound := ScalarFunctions.checkActuals_sound strings checked.1 allowed checked.2
  exact ⟨sound.1, sound.2,
    (source.sequential_eq_frozen contextClosed integers booleans sound.1).trans
      (copyBack_prefixTargets sound.2 _ _ state)⟩

end Silver.Compose
