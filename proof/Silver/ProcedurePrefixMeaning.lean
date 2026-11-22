module

public import Silver.ProcedurePrefixExpressionMeaning
public import Silver.ProcedureFrameArrays
public import Silver.PredicateFunctionCallMeaning
public import Silver.FunctionInitializerShape
public import Silver.ScalarProcedureNoninterference

@[expose] public section

namespace Silver.Compose
open Predicate ScalarProcedures

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
        (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types)) actuals = true := by
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
      have types : middle.arrayNames.types = before.arrayNames.types := by rw [first.fields]
      rw [preserved, types] at ih
      have scalar := appendProcedureParameter_writable_type (by rw [output]; decide) (first.installed ▸ first.accepted)
      have meaning := actual_meaning normal names ready arrays compatible bounded first.value (fun _ => rfl)
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
        apply Bool.and_eq_true_iff.mpr
        refine ⟨?_, ih.2⟩
        simpa only [procedurePrefixFormal, formalType, procedureInputFormal, scalar, ne_eq, not_true_eq_false,
          ↓reduceIte] using meaning.2

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
      exact appendProcedureParameter_headerReady ready typed.2.2.1

theorem ProcedurePrefixAt.analyses {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (valid : Expressions.ValidState text frame) (positive : 0 < index)
    (declarations : Nat) (count : declarations ≤ frame.scalarNames.length) :
    ArrayViews.analysis final.arrayNames.names (functionScalarAnalysis final declarations) =
      parameterAnalysis frame.scalarNames.length
        (outFormals (ProcedureBindings.formalModels frame.procedures index
          (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types)) (ArrayViews.analysis frame.arrayNames.names (functionScalarAnalysis frame declarations)) ∧
    BooleanBindings.analysis final.booleanNames =
      parameterBooleans frame.booleanNames.length
        (outFormals (ProcedureBindings.formalModels frame.procedures index
          (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types)) (BooleanBindings.analysis frame.booleanNames) := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.procedures.parameters.length + 1 - index = 0 := by omega
      simp [empty, ProcedureBindings.formalModels, outFormals, parameterAnalysis, parameterBooleans]
  | @skip before final index actuals _ more input _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      cases mode : (ProcedureBindings.parameter before.procedures index).mode <;>
        try exact False.elim (input mode)
      all_goals simpa [ProcedureBindings.formalModel, ProcedureBindings.modeModel, mode, outFormals]
        using ih valid (by omega) count
  | @next before middle final index actual actuals _ more output first _ _ ih =>
      have grows := appendProcedureParameter_grows _ _ (first.installed ▸ first.accepted)
      rw [← first.installed] at grows
      have typed := valid.procedures.2.2.1 _ (ProcedureBindings.parameter_mem positive more)
      have nextValid := procedurePrefixStep_valid (readFrame := readFrame) (declarationCount := declarationCount) valid typed
      rw [first.complete] at nextValid
      have tail := ih nextValid (by omega) (Nat.le_trans count grows.1)
      rw [first.installed] at tail
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      have accepted := first.installed ▸ first.accepted
      let advancedFrame : ParserState := {before with position := fixedAfter text (procedurePrefixValueAfter text readFrame before (ProcedureBindings.parameter before.procedures index) declarationCount) ";" false}
      have scalar := appendProcedureParameter_writable_type (by rw [output]; decide) accepted
      have step := appendProcedureParameter_analyses advancedFrame
        (ProcedureBindings.parameter before.procedures index) declarations count accepted
      have arrays := appendProcedureParameter_scalar_arrays scalar accepted
      rw [arrays, step.1, step.2] at tail
      cases kind : (ProcedureBindings.parameter before.procedures index).kind with
      | integer =>
          have space : before.scalarNames.length ≠ ScalarExpression.maxBindings := by
            intro full
            simp [appendProcedureParameter, scalar, kind, full, invalidState] at accepted
          have low : before.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit := by
            have capacity := valid.2.2.2.2.2.1.1
            change before.scalarNames.length ≤ ArrayBindings.scalarLimit at capacity
            change before.scalarNames.length ≠ ArrayBindings.scalarLimit at space
            omega
          have writableMode : (ScalarProcedures.Mode.output != .input) = true := rfl
          simp only [appendProcedureParameter, scalar, ne_eq, not_true_eq_false, kind, ↓reduceIte, space,
            ProcedureBindings.formalModel, formalType, procedureInputFormal, output, ProcedureBindings.modeModel,
            parameterAnalysis, parameterBooleans, writableMode, advancedFrame] at tail
          have commute := viewAnalysis_procedureScalarCell before.arrayNames.names (functionScalarAnalysis before declarations)
            (before.scalarNames.length + 1) (ProcedureBindings.parameter before.procedures index).bounds true low
          unfold procedureScalarCell at commute
          simp only [functionScalarAnalysis] at tail commute
          rw [commute] at tail
          simpa [ProcedureBindings.formalModel, formalType, procedureInputFormal, scalar, kind, output,
            ProcedureBindings.modeModel, outFormals, parameterAnalysis, parameterBooleans, writableMode, functionScalarAnalysis] using tail
      | boolean =>
          have space : before.booleanNames.length ≠ BooleanBindings.maxBindings := by
            intro full
            simp [appendProcedureParameter, scalar, kind, full, invalidState] at accepted
          simp only [appendProcedureParameter, scalar, ne_eq, not_true_eq_false, kind, reduceCtorEq, ↓reduceIte, space] at tail
          simpa [ProcedureBindings.formalModel, formalType, procedureInputFormal, scalar, kind, output, ProcedureBindings.modeModel,
            outFormals, parameterAnalysis, parameterBooleans, functionScalarAnalysis, advancedFrame,
            show (ScalarProcedures.Mode.output != .input) = true from rfl] using tail

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
  | integers, booleans, .array _ :: rest => prefixTargets integers booleans rest
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
      | array => exact ih integers booleans integerBefore booleanBefore member

theorem copyBack_prefixTargets {domains : List ScalarFunctions.ScalarType} {values : List Value}
    (scalar : ∀ domain ∈ domains, domain.IsScalar)
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
          have tailScalar : ∀ other ∈ domains, other.IsScalar := fun other member => scalar other (by simp [member])
          have head := scalar domain (List.mem_cons_self ..)
          cases domain <;> cases value
          all_goals try exact False.elim fitting.1
          all_goals try exact False.elim head
          · exact ih tailScalar fitting.2 (integers + 1) booleans _
          · exact ih tailScalar fitting.2 integers (booleans + 1) _

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

/-- All selected output targets are scalar cells installed by this accepted prefix.
Their upper bounds follow from the true intermediate binding counts. -/
theorem ProcedurePrefixAt.outputLayout {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (types : ArrayBindings.TypeEnvironment) :
    (∀ domain ∈ outTypes (ProcedureBindings.formalModels frame.procedures index
      (frame.procedures.parameters.length + 1 - index) types), domain.IsScalar) ∧
    ∀ target ∈ prefixTargets frame.scalarNames.length frame.booleanNames.length
      (outTypes (ProcedureBindings.formalModels frame.procedures index
        (frame.procedures.parameters.length + 1 - index) types)),
      match target with
      | .integer identity _ => identity ≤ final.scalarNames.length
      | .boolean identity => identity ≤ final.booleanNames.length := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.procedures.parameters.length + 1 - index = 0 := by omega
      simp [empty, ProcedureBindings.formalModels, outTypes, prefixTargets]
  | @skip before final index actuals _ more input _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      cases mode : (ProcedureBindings.parameter before.procedures index).mode <;> try exact False.elim (input mode)
      all_goals simpa [ProcedureBindings.formalModel, ProcedureBindings.modeModel, mode, outTypes] using ih
  | @next before middle final index actual actuals _ more output first _ rest ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      have accepted := first.installed ▸ first.accepted
      have scalar := appendProcedureParameter_writable_type (by rw [output]; decide) accepted
      have growth := rest.grows
      rw [first.installed] at ih growth
      cases kind : (ProcedureBindings.parameter before.procedures index).kind with
      | integer =>
          have space : before.scalarNames.length ≠ ScalarExpression.maxBindings := by
            intro full
            simp [appendProcedureParameter, scalar, kind, full, invalidState] at accepted
          simp only [appendProcedureParameter, scalar, kind, ne_eq, not_true_eq_false, ↓reduceIte, space,
            List.length_append, List.length_singleton] at ih growth
          simpa [ProcedureBindings.formalModel, formalType, procedureInputFormal, scalar, kind, output,
            ProcedureBindings.modeModel, outTypes, prefixTargets, ScalarFunctions.ScalarType.IsScalar, growth.1] using ih
      | boolean =>
          have space : before.booleanNames.length ≠ BooleanBindings.maxBindings := by
            intro full
            simp [appendProcedureParameter, scalar, kind, full, invalidState] at accepted
          simp only [appendProcedureParameter, scalar, kind, ne_eq, not_true_eq_false, reduceCtorEq, ↓reduceIte, space,
            List.length_append, List.length_singleton] at ih growth
          simpa [ProcedureBindings.formalModel, formalType, procedureInputFormal, scalar, kind, output,
            ProcedureBindings.modeModel, outTypes, prefixTargets, ScalarFunctions.ScalarType.IsScalar, growth.2] using ih

/-- The source checker supplies safety in the fixed incoming state. Syntactic
read origins supply absence of every fresh output cell, including on branches
that are never evaluated for that particular input. -/
theorem ProcedurePrefixAt.sequential_eq_frozen {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (closed : ClosedFunctionContext (procedurePrefixContext readFrame declarationCount) descriptors)
    (capacity : readFrame.arrayNames.names ≠ [] → final.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (integers : readFrame.scalarNames.length ≤ frame.scalarNames.length)
    (booleans : readFrame.booleanNames.length ≤ frame.booleanNames.length)
    {state : ScalarFunctions.State} {shape : Bindings.Shape}
    (safe : ∀ actual ∈ actuals, actual.Safe shape state) :
    executePrefix (prefixTargets frame.scalarNames.length frame.booleanNames.length
      (outTypes (ProcedureBindings.formalModels frame.procedures index
        (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types))) actuals state =
      copyBack (prefixTargets frame.scalarNames.length frame.booleanNames.length
        (outTypes (ProcedureBindings.formalModels frame.procedures index
          (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types)))
        (ScalarFunctions.evaluateActuals state actuals) state := by
  apply executePrefix_eq_frozen safe
  intro target member
  apply source.reads_absent closed (targetCell target)
  have outside := prefixTargets_outside frame.scalarNames.length frame.booleanNames.length _
    readFrame.scalarNames.length readFrame.booleanNames.length integers booleans target member
  cases target with
  | integer identity bounds =>
      refine ⟨by simpa only [targetCell, procedurePrefixContext, contextOf, ScalarExpression.bodyEnvironment_length] using outside, ?_⟩
      intro item present
      have nonempty : readFrame.arrayNames.names ≠ [] := fun empty => by
        change item ∈ readFrame.arrayNames.names at present
        rw [empty] at present
        exact List.not_mem_nil present
      have targetBound := (source.outputLayout frame.arrayNames.types).2 _ member
      have low : identity ≤ ArrayBindings.scalarLimit := Nat.le_trans targetBound (capacity nonempty)
      unfold ArrayBindings.Binding.viewDescriptor
      split <;> simp only [ArrayBindings.Binding.descriptor, Integer.ArrayDescriptor.ContainsCell] <;> omega
  | boolean identity => exact outside

/-- Accepted prefix source is safe over every fitting local/input state. The
conclusion constructs the output frame from those actual source expressions;
it assumes neither a completed declaration law nor an initialized out value. -/
theorem ProcedurePrefixAt.execution {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (valid : Expressions.ValidState text readFrame)
    (contextClosed : ClosedFunctionContext (procedurePrefixContext readFrame declarationCount) descriptors)
    (capacity : readFrame.arrayNames.names ≠ [] → final.scalarNames.length ≤ ArrayBindings.scalarLimit)
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
      (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types)) (ScalarFunctions.evaluateActuals state actuals) ∧
    executePrefix (prefixTargets frame.scalarNames.length frame.booleanNames.length
      (outTypes (ProcedureBindings.formalModels frame.procedures index
        (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types))) actuals state =
      {state with
        integers := (ScalarFunctions.bindArguments frame.scalarNames.length frame.booleanNames.length
          (outTypes (ProcedureBindings.formalModels frame.procedures index
            (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types))
          (ScalarFunctions.evaluateActuals state actuals) ⟨state.integers, state.booleans⟩).integers,
        booleans := (ScalarFunctions.bindArguments frame.scalarNames.length frame.booleanNames.length
          (outTypes (ProcedureBindings.formalModels frame.procedures index
            (frame.procedures.parameters.length + 1 - index) frame.arrayNames.types))
          (ScalarFunctions.evaluateActuals state actuals) ⟨state.integers, state.booleans⟩).booleans} := by
  have normal : NamesNormal (procedurePrefixContext readFrame declarationCount).names := by
    rw [contextClosed.noNames]
    constructor <;> simp [NamesWellTyped, Bindings.BindingEnvironment.get]
  have names : Expressions.ValidNames text (procedurePrefixContext readFrame declarationCount).names := valid.2.1
  have contextReady : ScalarMetadata.ContextReady (procedurePrefixContext readFrame declarationCount).scalarNames
      declarationCount (procedurePrefixContext readFrame declarationCount).elaborating :=
    functionFrame_contextReady declarationCount valid ready count
  have arraysReady : (procedurePrefixContext readFrame declarationCount).ArraysReady text := valid.arrays.1
  have compatible : ScalarMetadata.OverlayCompatible (procedurePrefixContext readFrame declarationCount).scalarNames
      declarationCount (procedurePrefixFacts readFrame declarationCount) := ScalarMetadata.initial_compatible ..
  have bounded : (procedurePrefixFacts readFrame declarationCount).path.Bounded := by
    simp [procedurePrefixFacts, ActiveFlow.initial, contextClosed.noArguments, initialFacts,
      PathFacts.Context.Bounded, PathFacts.Region.Bounded]
  have checked := source.meaning normal names contextReady arraysReady compatible bounded
  have sound := ScalarFunctions.checkActuals_sound strings checked.1 allowed checked.2
  exact ⟨sound.1, sound.2,
    (source.sequential_eq_frozen contextClosed capacity integers booleans sound.1).trans
      (copyBack_prefixTargets (source.outputLayout frame.arrayNames.types).1 sound.2 _ _ state)⟩

end Silver.Compose
