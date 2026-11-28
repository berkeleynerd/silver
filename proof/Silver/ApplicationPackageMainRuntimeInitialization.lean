module

public import Silver.ApplicationPackageMainInitializerEntry
public import Silver.ComposeArrayStore
public import Silver.ComposeMain

@[expose] public section

/-! Source initialization of Main's runtime stores. Imported scalar constants
seed the original declaration evaluation; arrays retain their original ordered
elaboration, and String/Boolean declarations execute their source inventories.
The native body context and initial flow are derived separately from these
stores, without an assumed program checker or runtime fitting certificate. -/
namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate Bindings ApplicationPackageMain

def MainInventory.runtimeIntegers (inventory : MainInventory) (entry final : ParserState) : Integer.Store :=
  ArrayBindings.integerStore final.arrayNames.names final.arrayNames.values
    (Integer.executeDeclarations (ScalarExpression.constants entry.scalarNames) inventory.integers).store

def MainInventory.runtimeValues (inventory : MainInventory) (argument : Bool) (input : Source) : Values :=
  executeDeclarations input inventory.strings
    (if argument then argumentDeclaration.execute emptyValues input else emptyValues)

def MainInventory.runtimeBooleans (inventory : MainInventory) (entry : ParserState)
    (values : Values) (input : Source) (valid : Bool) : Boolean.Store :=
  executeBooleanDeclarations values input valid Integer.emptyStore inventory.booleans
    (BooleanBindings.initialValues entry.booleanNames)

private theorem scalar_header_ready {text arguments state final values}
    (source : ScalarDeclarationsAt text arguments state values final)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady final.scalarNames := by
  induction source with
  | done => exact ready
  | string _ _ _ _ _ _ _ first _ _ ih =>
    rw [declaration_scalarNames first] at ih
    exact ih ready
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih ready
  | scalar _ _ _ _ first _ _ ih => exact ih (scalar_declaration_header_ready ready first)
  | array _ _ _ _ _ first _ _ ih =>
    rw [(array_declaration_preserves first).2] at ih
    exact ih ready
  | booleanArray _ _ _ _ _ first _ _ ih =>
    rw [(boolean_array_declaration_preserves first).2.1] at ih
    exact ih ready
  | subtype _ _ _ first _ _ ih => cases first; exact ih ready
  | arrayType _ _ _ first _ ih => cases first; exact ih ready
  | callable _ _ accepted _ ih =>
    rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).scalarNames] at ih
    exact ih ready

/-- A source elaboration snapshot fits the widened body intervals. In
particular mutable objects use their declared subtype, not a singleton that
would incorrectly restrict later execution. -/
private theorem constants_body_fits {names : ScalarExpression.Environment}
    (ready : ScalarMetadata.HeaderReady names) :
    Integer.Fits (ScalarExpression.ranges (ScalarExpression.bodyEnvironment names))
      (Integer.Constants.store (ScalarExpression.constants names)) := by
  intro index bounds found
  by_cases active : 0 < index ∧ index ≤ names.length
  · have within : index - 1 < names.length := by omega
    have row := ready.binding index active.1 active.2
    have value : Integer.Constants.store (ScalarExpression.constants names) index =
        (ScalarExpression.binding names index).bounds.lower := by
      simp only [Integer.Constants.store, Integer.Constants.get, ScalarExpression.constants,
        show index ≠ 0 by omega, ↓reduceIte, List.getElem?_map,
        List.getElem?_eq_getElem within, Option.map_some, Option.getD_some,
        ScalarExpression.binding, List.getD_eq_getElem?_getD]
    rw [value]
    have selected : bounds = (ScalarExpression.bodyBinding (ScalarExpression.binding names index)).bounds := by
      simpa only [ScalarExpression.ranges, ScalarExpression.bodyEnvironment_length,
        active, and_self, ↓reduceIte, ScalarExpression.bodyEnvironment_binding, Option.some.injEq] using found.symm
    rw [selected]
    unfold ScalarExpression.bodyBinding
    split
    · rename_i mutable
      have included := row.2 mutable
      have nonempty := row.1
      simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty
      change (ScalarExpression.binding names index).declaredBounds.Contains
        (ScalarExpression.binding names index).bounds.lower
      exact ⟨included.1, by omega⟩
    · have nonempty := row.1
      simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty
      change (ScalarExpression.binding names index).bounds.Contains
        (ScalarExpression.binding names index).bounds.lower
      exact ⟨Int.le_refl _, by omega⟩
  · simp only [ScalarExpression.ranges, ScalarExpression.bodyEnvironment_length,
      active, ↓reduceIte] at found
    contradiction

/-- Complete scalar evaluation starts with the actual imported constants.
The array invariant is an elaboration invariant on the source entry, and is
constructed from the original specification below. -/
theorem MainInventory.runtime_integers {text : Source} {arguments : Bool}
    {entry final : ParserState} {inventory : MainInventory}
    (source : inventory.SourceAt text arguments entry final)
    (domain : DeclarationEntry text entry)
    (arrays : ArrayBindings.SourceReady text entry.arrayNames) :
    inventory.runtimeIntegers entry final =
        frozenIntegers final.scalarNames final.arrayNames.names final.arrayNames.values ∧
      Integer.DeclarationsSafe (ScalarExpression.constants entry.scalarNames) inventory.integers ∧
      Integer.Fits (Predicate.contextOf ⟨final, false, false⟩).analysis.declared
        (inventory.runtimeIntegers entry final) := by
  have checked := scalar_declarations_checked source.integers domain.static
    domain.native.base.2.2.2.2.2.1.1 domain.native.base.2.2.2.2.2.2.2.1 domain.stored
  have evaluated := Integer.declarations_sound checked
  have same : inventory.runtimeIntegers entry final =
      frozenIntegers final.scalarNames final.arrayNames.names final.arrayNames.values := by
    simp only [MainInventory.runtimeIntegers, frozenIntegers, ← evaluated.1]
  have ready := scalar_header_ready source.integers domain.native.ready
  have stored := declarations_stored source.strings domain.stored
  have arrayReady := declarations_array_ready source.strings arrays domain.native.base.arrayTypes
    domain.native.base.2.2.2.2.2.2.2.1
  refine ⟨same, evaluated.2, ?_⟩
  rw [same]
  change Integer.Fits
    (ArrayBindings.integerRanges (ArrayBindings.viewNames final.arrayNames.names) [] false
      (ScalarExpression.ranges (ScalarExpression.bodyEnvironment final.scalarNames))) _
  rw [ArrayBindings.viewNames_stored stored]
  exact ArrayBindings.body_ranges_fits (ArrayBindings.integerNames final.arrayNames.names)
    (ArrayBindings.integerNames_initialsFit arrayReady.2.2.2) (constants_body_fits ready)

theorem MainInventory.runtime_booleans {text : Source} {arguments : Bool}
    {entry final : ParserState} {inventory : MainInventory}
    (source : inventory.SourceAt text arguments entry final)
    (textValid : ValidText text) (domain : DeclarationEntry text entry)
    {values : Values} {input : Source} {valid : Bool}
    (fit : Fits final.names.shape input values)
    (allowed : (booleanDeclarationFacts entry).path.Allows valid input.length false) :
    BooleanDeclarationsSafe final.names.shape values input valid Integer.emptyStore
        inventory.booleans (BooleanBindings.initialValues entry.booleanNames) ∧
      checkedBooleanDeclarations values input valid Integer.emptyStore inventory.booleans
        (BooleanBindings.initialValues entry.booleanNames) =
          some (inventory.runtimeBooleans entry values input valid) := by
  have checked := boolean_declarations_valid textValid source.booleans domain.native.bounds.normal
    domain.native.base domain.native.ready domain.static domain.stored
  exact boolean_declarations_sound checked.1 checked.2.1 fit
    ⟨allowed, fun _ _ absent => by cases absent⟩

/-- Body_Of installs the same declared scalar ranges that contextOf exposes,
including physical array cells. The initial path is the sole remaining runtime
input condition; it will be derived from the optional source argument. -/
theorem MainInventory.runtime_flow {text : Source} {arguments : Bool}
    {entry final : ParserState} {inventory : MainInventory}
    (source : inventory.SourceAt text arguments entry final)
    (domain : DeclarationEntry text entry)
    (arrays : ArrayBindings.SourceReady text entry.arrayNames)
    {input : Source} {valid rejected : Bool}
    (allowed : (booleanDeclarationFacts entry).path.Allows valid input.length rejected) :
    ((Predicate.contextOf ⟨final, false, false⟩).flow (Predicate.bodyOf ⟨final, false, false⟩).facts).Allows
      valid input.length rejected (inventory.runtimeIntegers entry final) := by
  have fit := (inventory.runtime_integers source domain arrays).2.2
  have dynamic := (declarations_fields source.strings).2.2.1
  constructor
  · simpa only [Predicate.contextOf, Predicate.bodyOf, ParseContext.flow, ActiveFlow.initial,
      Predicate.initialFacts, booleanDeclarationFacts, decide_eq_true_eq, dynamic] using allowed
  · have initial := congrArg Flow.scalars (ActiveFlow.initial_model
      (ScalarExpression.bodyEnvironment final.scalarNames)
      (initialFacts (decide (final.dynamicFirst ≠ 0))))
    change Integer.Fits (ArrayBindings.viewRanges final.arrayNames.names [] false
      (ActiveFlow.initial (ScalarExpression.bodyEnvironment final.scalarNames)
        (initialFacts (decide (final.dynamicFirst ≠ 0)))).model.scalars) _
    rw [initial]
    exact fit

end Silver.ApplicationPackageInitializers

namespace Silver.ApplicationPackageMain.RuntimeArraySeed
open Compose Compose.Expressions Predicate ApplicationPackageDeclarations
open ApplicationPackageInitializers ApplicationPackageFrames

private def ArrayRetains (before after : ParserState) : Prop :=
  after.arrayNames = before.arrayNames

private theorem finish_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {result : ObjectResult}
    (present : (finishObject calls text original result).frame.position ≠ 0) :
    ArrayRetains result.frame (finishObject calls text original result).frame := by
  dsimp only [finishObject] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i advanced
    rw [ite_eq_right advanced]
    exact rfl

private theorem booleanFinish_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd after : Nat} {localObject : Bool} {result : ObjectResult}
    (present : (objectBooleanFinish calls text original first last constantEnd after localObject result).frame.position ≠ 0) :
    ArrayRetains result.frame
      (objectBooleanFinish calls text original first last constantEnd after localObject result).frame :=
  finish_retains present

private theorem boolean_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd : Nat} {localObject : Bool} {result : ObjectResult}
    (present : (objectBoolean calls text original first last constantEnd localObject result).frame.position ≠ 0) :
    ArrayRetains result.frame (objectBoolean calls text original first last constantEnd localObject result).frame := by
  dsimp only [objectBoolean] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i checked
    rw [ite_eq_right checked]
    split at present
    · rename_i global
      rw [ite_eq_left global]
      split at present
      · exact False.elim (present rfl)
      · rename_i same
        rw [ite_eq_right same]
        exact booleanFinish_retains present
    · rename_i localBranch
      rw [ite_eq_right localBranch]
      exact booleanFinish_retains present

private theorem scalar_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd : Nat} {localObject : Bool} {result : ObjectResult} {constraint : ScalarConstraintResult}
    (present : (objectScalar calls text original first last constantEnd localObject result constraint).frame.position ≠ 0) :
    ArrayRetains result.frame (objectScalar calls text original first last constantEnd localObject result constraint).frame := by
  dsimp only [objectScalar] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i checked
    rw [ite_eq_right checked]
    exact finish_retains present

private theorem initialized_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd : Nat} {localObject : Bool} {result : ObjectResult} {constraint : ScalarConstraintResult}
    (present : (objectInitialized calls text original first last constantEnd localObject result constraint).frame.position ≠ 0) :
    ArrayRetains result.frame (objectInitialized calls text original first last constantEnd localObject result constraint).frame := by
  dsimp only [objectInitialized] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i checked
    rw [ite_eq_right checked]
    split at present
    · rename_i integer
      rw [ite_eq_left integer]
      exact scalar_retains present
    · rename_i boolean
      rw [ite_eq_right boolean]
      exact boolean_retains present

private theorem typed_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {info : PackageBindings.Metadata} {first last colonEnd constantEnd : Nat} {localObject : Bool}
    {result : ObjectResult}
    (present : (objectTyped calls text original info first last colonEnd constantEnd localObject result).frame.position ≠ 0) :
    result.frame.position ≠ 0 ∧ ArrayRetains result.frame
      (objectTyped calls text original info first last colonEnd constantEnd localObject result).frame := by
  dsimp only [objectTyped] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i live
    rw [ite_eq_right live]
    refine ⟨by simpa only [decide_eq_true_eq] using live, ?_⟩
    by_cases constant : constantEnd = 0 <;>
      simp only [constant, decide_true, decide_false, Bool.false_eq_true, ↓reduceIte] at present ⊢
    all_goals
      split at present
      · exact False.elim (present rfl)
      · rename_i typed
        rw [ite_eq_right typed]
        split at present
        · rename_i integer
          rw [ite_eq_left integer]
          exact initialized_retains present
        · rename_i boolean
          rw [ite_eq_right boolean]
          exact initialized_retains present


private theorem object_arrays {calls : ObjectCalls} {text : Source} {frame : ParserState}
    {info : PackageBindings.Metadata}
    (present : (objectStep calls text frame info false).frame.position ≠ 0) :
    ArrayRetains frame (objectStep calls text frame info false).frame := by
  dsimp only [objectStep, objectNameStep] at present ⊢
  simp only [Bool.false_eq_true, ite_false] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i named
    rw [ite_eq_right named]
    split at present
    · rename_i fresh
      rw [ite_eq_left fresh]
      exact (typed_retains present).2
    · exact False.elim (present rfl)

structure Seed (frame : ParserState) : Prop where
  arrays : frame.arrayNames = {}

private theorem initial_seed : Seed initialState := ⟨rfl⟩
private theorem invalid_seed : Seed invalidState := ⟨rfl⟩

private def Start : SpecificationStart → Prop
  | .returned result => Seed result.exports
  | .loop state => Seed state.exports

private def Step : SpecificationStep → Prop
  | .returned result => Seed result.exports
  | .ready state | .next state => Seed state.exports

private def Exit : SpecificationExit → Prop
  | .returned result => Seed result.exports
  | .ready state => Seed state.exports

private theorem start (calls : SpecificationCalls) (text : Source) (info : PackageBindings.Metadata) :
    Start (specificationStart calls text info) := by
  dsimp only [specificationStart]
  split
  · exact invalid_seed
  · split <;> exact ⟨initial_seed.arrays⟩

private theorem continue_state (calls : SpecificationCalls) (text : Source) (before : Nat)
    (state : SpecificationState) (known : Seed state.exports) :
    Step (continueSpecification calls text before state) := by
  dsimp only [continueSpecification]
  split
  · exact invalid_seed
  · exact known

private theorem routine (calls : SpecificationCalls) (text : Source) (state : SpecificationState)
    (known : Seed state.exports) : Step (specificationRoutine calls text state) := by
  dsimp only [specificationRoutine]
  split
  · exact invalid_seed
  · exact continue_state _ _ _ _ ⟨known.arrays⟩

private theorem subtype (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state : SpecificationState) (known : Seed state.exports) :
    Step (specificationSubtype (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationSubtype, modelSpecificationCalls]
  split
  · exact invalid_seed
  · rename_i present
    split
    · exact invalid_seed
    · unfold appendExport
      apply continue_state
      have preserved {next : ParserState} (parsed : SubtypeDeclarationAt text false state.exports next) :
          Seed next := by
        cases parsed
        exact ⟨known.arrays⟩
      exact preserved (subtype_declaration_sound text state.exports false present)

private theorem object (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state : SpecificationState) (known : Seed state.exports) :
    Step (specificationObject (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationObject, modelSpecificationCalls]
  split
  · exact invalid_seed
  · rename_i accepted
    have present : (objectStep (modelObjectCalls reader) text state.exports state.info false).frame.position ≠ 0 :=
      fun zero => accepted (by simp only [zero, decide_true, Bool.true_or])
    unfold appendExport
    apply continue_state
    have retained := object_arrays present
    exact ⟨retained.trans known.arrays⟩

private theorem step (reader : BooleanElaboration.Native.Reader) (text : Source)
    (state : SpecificationState) (known : Seed state.exports) :
    Step (specificationStep (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationStep]
  split
  · exact known
  · split
    · exact routine _ _ _ known
    · split
      · exact invalid_seed
      · split
        · exact subtype _ _ _ known
        · exact object _ _ _ known

private theorem loop {reader text state result}
    (run : SpecificationLoop (modelSpecificationCalls reader) text state result)
    (known : Seed state.exports) : Exit result := by
  induction run with
  | returned parsed =>
    have retained := step reader text _ known
    rwa [parsed] at retained
  | ready parsed =>
    have retained := step reader text _ known
    rwa [parsed] at retained
  | next parsed _ ih =>
    have retained := step reader text _ known
    rw [parsed] at retained
    exact ih retained

private theorem finish (calls : SpecificationCalls) (text : Source) (state : SpecificationState)
    (known : Seed state.exports) : Seed (finishSpecification calls text state).exports := by
  dsimp only [finishSpecification]
  split
  · exact invalid_seed
  · exact ⟨known.arrays⟩

/-- Every original Specification result, including early rejection, retains
the complete empty array environment, including its backing values and count. -/
theorem specification_seed {reader text info result}
    (exec : SpecificationExec (modelSpecificationCalls reader) text info result) : Seed result.exports := by
  have started := start (modelSpecificationCalls reader) text info
  unfold SpecificationExec at exec
  cases entry : specificationStart (modelSpecificationCalls reader) text info with
  | returned failed =>
    simp only [entry] at started exec
    subst result
    exact started
  | loop state =>
    simp only [entry] at started exec
    obtain ⟨exit, ran, resultEq⟩ := exec
    have retained := loop ran started
    cases exit with
    | returned failed => subst result; exact retained
    | ready finalState => subst result; exact finish _ _ _ retained

theorem readSpecification_seed (reader : BooleanElaboration.Native.Reader) (text : Source)
    (info : PackageBindings.Metadata) : Seed (readSpecification reader text info).exports :=
  specification_seed (readSpecification_exec reader text info)


end Silver.ApplicationPackageMain.RuntimeArraySeed

namespace Silver.ApplicationPackageMain.RuntimeArraySeed
open Compose Compose.Expressions Predicate ApplicationPackageFrames

theorem Seed.ready {text : Source} {frame : ParserState} (seed : Seed frame) :
    ArrayBindings.SourceReady text frame.arrayNames := by
  rw [seed.arrays]
  simp [ArrayBindings.SourceReady, ArrayBindings.ValidEnvironment, ArrayBindings.ValidMetadata,
    ArrayBindings.ValidInitials, ArrayBindings.InitialsFit]

theorem imported (exports : ParserState) (info : PackageBindings.Metadata) (position : Nat)
    (text : Source) (seed : Seed exports) : Seed (importedFrame text exports info position) := by
  unfold importedFrame
  dsimp only
  split
  · exact ⟨seed.arrays⟩
  · exact ⟨rfl⟩

theorem Seed.argument {text : Source} {frame : ParserState} (seed : Seed frame) :
    Seed (argumentAt text frame) := by
  unfold argumentAt
  dsimp only
  split
  · exact ⟨rfl⟩
  · exact ⟨seed.arrays⟩

attribute [local irreducible] Names.readContext tokenAfter Compose.argumentAt Compose.declarationsAt
  ApplicationPackageFrames.importedFrame

theorem argument_frame (other : Calls) (sources : ApplicationUnits.Bundle)
    (exports : ParserState) (info : PackageBindings.Metadata) (seed : Seed exports) :
    Seed (argumentFrame (DeclarationLibraries.model other) sources exports info) := by
  have base := imported exports info (mainStart (DeclarationLibraries.model other) sources info)
    (textOf sources) seed
  change Seed (if (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith then
    argumentAt (textOf sources) (importedFrame (textOf sources) exports info
      (mainStart (DeclarationLibraries.model other) sources info)) else
    importedFrame (textOf sources) exports info (mainStart (DeclarationLibraries.model other) sources info))
  cases (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith
  · exact base
  · exact base.argument

end Silver.ApplicationPackageMain.RuntimeArraySeed

namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate Bindings ApplicationPackageMain

/-- The optional source argument and runtime boundary data. No checker result,
store-fitting assertion, or safety premise is part of this relation. A failed
runtime input has the empty byte string specified by the argument library. -/
inductive MainRuntimeStart (text : Source) (entry : ParserState) : Bool → Source → Bool → Prop
  | absent (names : entry.names = []) (dynamic : entry.dynamicFirst = 0) :
      MainRuntimeStart text entry false [] true
  | argument {before : ParserState} {fallback input : Source} {valid : Bool}
      (source : ArgumentAt text before fallback entry)
      (bounded : input.length ≤ maxSourceLength) (printable : Bindings.Printable input)
      (invalid : valid = false → input = []) :
      MainRuntimeStart text entry true input valid

private theorem argument_dynamic {text : Source} {before entry : ParserState} {fallback : Source}
    (source : ArgumentAt text before fallback entry) : entry.dynamicFirst ≠ 0 := by
  cases source with
  | argument _ allowed _ _ _ =>
    exact Nat.ne_of_gt (newNameAllowed_span _ _ _ _ _ allowed).1

theorem MainRuntimeStart.domain {text input : Source} {entry : ParserState} {argument valid : Bool}
    (start : MainRuntimeStart text entry argument input valid) :
    input.length ≤ maxSourceLength ∧ Bindings.Printable input ∧
      (booleanDeclarationFacts entry).path.Allows valid input.length false := by
  cases start with
  | absent names dynamic =>
    refine ⟨Nat.zero_le _, by simp [Bindings.Printable], ?_⟩
    simp [booleanDeclarationFacts, dynamic, ActiveFlow.initial, PathFacts.Context.Allows,
      PathFacts.Region.Contains, PathFacts.Interval.Contains]
  | argument source bounded printable invalid =>
    refine ⟨bounded, printable, ?_⟩
    have dynamic := argument_dynamic source
    change (if entry.dynamicFirst ≠ 0 then PathFacts.Context.initial maxSourceLength
      else ⟨some ⟨0, 0⟩, false, false⟩).Allows valid input.length false
    rw [ite_eq_left dynamic]
    cases value : valid with
    | true => exact PathFacts.Context.initial_valid bounded false
    | false => rw [invalid value]; exact PathFacts.Context.initial_invalid _ _

theorem MainRuntimeStart.values_fit {text input : Source} {entry final : ParserState}
    {argument valid : Bool} {inventory : MainInventory}
    (start : MainRuntimeStart text entry argument input valid)
    (source : inventory.SourceAt text argument entry final)
    (textValid : ValidText text) (domain : DeclarationEntry text entry) :
    Fits final.names.shape input (inventory.runtimeValues argument input) := by
  cases start with
  | absent names dynamic =>
    exact (declarations_bounds_from_empty textValid.2 (Nat.zero_le _) (by simp [Bindings.Printable])
      names domain.static domain.stored source.strings).2.2
  | argument argument bounded printable invalid =>
    exact (declarations_bounds_after_argument textValid.2 bounded printable domain.static
      domain.stored argument source.strings).2.2

/-- The complete runtime entry contract is a consequence of the source
declarations and raw argument selection. In particular no integer or Boolean
fit assumption is required from the caller. -/
theorem MainInventory.runtime_stores {text input : Source} {entry final : ParserState}
    {argument valid : Bool} {inventory : MainInventory}
    (start : MainRuntimeStart text entry argument input valid)
    (source : inventory.SourceAt text argument entry final)
    (textValid : ValidText text) (domain : DeclarationEntry text entry)
    (seed : RuntimeArraySeed.Seed entry) :
    Fits final.names.shape input (inventory.runtimeValues argument input) ∧
      Bindings.Printable input ∧
      ((Predicate.contextOf ⟨final, false, false⟩).flow
        (Predicate.bodyOf ⟨final, false, false⟩).facts).Allows valid input.length false
          (inventory.runtimeIntegers entry final) ∧
      Integer.Fits (Predicate.contextOf ⟨final, false, false⟩).analysis.declared
        (inventory.runtimeIntegers entry final) ∧
      BooleanDeclarationsSafe final.names.shape (inventory.runtimeValues argument input) input valid
        Integer.emptyStore inventory.booleans (BooleanBindings.initialValues entry.booleanNames) ∧
      checkedBooleanDeclarations (inventory.runtimeValues argument input) input valid Integer.emptyStore
        inventory.booleans (BooleanBindings.initialValues entry.booleanNames) =
          some (inventory.runtimeBooleans entry (inventory.runtimeValues argument input) input valid) := by
  have data := start.domain
  have strings := start.values_fit source textValid domain
  have integers := inventory.runtime_integers source domain seed.ready
  have flags := inventory.runtime_booleans source textValid domain strings data.2.2
  exact ⟨strings, data.2.1, inventory.runtime_flow source domain seed.ready data.2.2,
    integers.2.2, flags⟩

end Silver.ApplicationPackageInitializers

namespace Silver.ApplicationPackageMain
open Compose Compose.Expressions Predicate Bindings ApplicationPackageInitializers
open ApplicationPackageDeclarations ApplicationPackageFrames ApplicationPackageRoutineClosedFrames

/-- Original optional argument syntax, retaining its fallback literal. -/
inductive MainArgumentAt (text : Source) (entry : ParserState) : Bool → Source → Prop
  | absent (names : entry.names = []) (dynamic : entry.dynamicFirst = 0) :
      MainArgumentAt text entry false []
  | present {before : ParserState} {fallback : Source}
      (source : ArgumentAt text before fallback entry) : MainArgumentAt text entry true fallback

def runtimeInput (hasArgument : Bool) (fallback : Source) (arguments : Arguments.Runtime.Arguments) : Source :=
  if hasArgument then selected fallback arguments else []

def runtimeInputValid (hasArgument : Bool) (arguments : Arguments.Runtime.Arguments) : Bool :=
  if hasArgument then Arguments.Runtime.inputIsValid arguments else true

theorem MainArgumentAt.runtime_start {text fallback : Source} {entry : ParserState} {hasArgument : Bool}
    (source : MainArgumentAt text entry hasArgument fallback) (arguments : Arguments.Runtime.Arguments) :
    MainRuntimeStart text entry hasArgument (runtimeInput hasArgument fallback arguments)
      (runtimeInputValid hasArgument arguments) := by
  cases source with
  | absent names dynamic => exact .absent names dynamic
  | present source =>
    exact .argument source (selected_domain _ arguments).1 (selected_domain _ arguments).2
      (selected_invalid _ arguments)

private theorem imported_tables (text : Source) (exports : ParserState)
    (info : PackageBindings.Metadata) (position : Nat) (tables : Tables exports) :
    Tables (importedFrame text exports info position) := by
  unfold importedFrame
  dsimp only
  split
  · exact ⟨tables.dynamicFirst, tables.names, tables.arrayNames⟩
  · exact invalid_tables

attribute [local irreducible] Names.readContext tokenAfter Compose.argumentAt Compose.declarationsAt
  ApplicationPackageFrames.importedFrame

/-- Accepted original argument syntax determines the runtime fallback and
entry bytes. No body checker or runtime invariant is assumed. -/
theorem original_argument (other : Calls) (sources : ApplicationUnits.Bundle)
    (exports : ParserState) (info : PackageBindings.Metadata) (tables : Tables exports)
    (present : (argumentFrame (DeclarationLibraries.model other) sources exports info).position ≠ 0) :
    ∃ fallback, MainArgumentAt (textOf sources)
      (argumentFrame (DeclarationLibraries.model other) sources exports info)
      (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith fallback := by
  let frame := importedFrame (textOf sources) exports info
    (mainStart (DeclarationLibraries.model other) sources info)
  have base := imported_tables (textOf sources) exports info
    (mainStart (DeclarationLibraries.model other) sources info) tables
  change (if (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith then
    argumentAt (textOf sources) frame else frame).position ≠ 0 at present
  change ∃ fallback, MainArgumentAt (textOf sources)
    (if (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith then
      argumentAt (textOf sources) frame else frame)
    (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith fallback
  cases args : (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith with
  | false => exact ⟨[], .absent base.names base.dynamicFirst⟩
  | true =>
    simp only [args, ↓reduceIte] at present
    obtain ⟨fallback, read⟩ := argument_sound (textOf sources) frame present
    exact ⟨fallback, .present read⟩

namespace BodyLibraries

theorem runtime_context (library : BodyLibraries) (other : Calls) (sources : ApplicationUnits.Bundle)
    (exports : ParserState) (info : PackageBindings.Metadata) :
    (library.input other sources exports info).context = Predicate.contextOf
      ⟨declarationsFrame (library.model other) sources exports info, false, false⟩ := rfl

theorem runtime_initial_flow (library : BodyLibraries) (other : Calls) (sources : ApplicationUnits.Bundle)
    (exports : ParserState) (info : PackageBindings.Metadata)
    (count : (declarationsFrame (library.model other) sources exports info).scalarNames.length ≤
      ScalarExpression.maxBindings) :
    (library.input other sources exports info).context.flow
        (library.input other sources exports info).input.scan.facts =
      (Predicate.contextOf ⟨declarationsFrame (library.model other) sources exports info, false, false⟩).flow
        (Predicate.bodyOf ⟨declarationsFrame (library.model other) sources exports info, false, false⟩).facts := by
  let frame := bodyFrame (DeclarationLibraries.model other) sources exports info
  let scan : ScanResult := ⟨frame, frame.assignedInFunctions, false⟩
  have bounded : scan.state.scalarNames.length ≤ ScalarExpression.maxBindings := count
  change (library.flow.context scan).model.flow
    (ApplicationPackages.applicationOf (library.flow.wrappers.bodyOf scan)).scan.facts = _
  rw [library.flow.body_meaning scan bounded, library.flow.context_meaning]
  rfl

/-- All runtime entry premises of checked_summary_application_sound follow
from the original specification and Main declaration history. The fallback is
the original source literal, and the claim quantifies over every runtime
argument list, including invalid input and the absent-argument branch. -/
theorem original_runtime (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    {reader : BooleanElaboration.Native.Reader} {specification : SpecificationResult}
    (specified : readSpecification reader (sources.prefix .packageSpecification)
      {units := sources.units} = specification)
    (info : PackageBindings.Metadata) {inventory : MainInventory}
    (source : inventory.SourceAt (textOf sources)
      (contextClauses (library.model other) sources info).argumentsWith
      (argumentFrame (library.model other) sources specification.exports info)
      (declarationsFrame (library.model other) sources specification.exports info))
    (domain : DeclarationEntry (textOf sources)
      (argumentFrame (library.model other) sources specification.exports info))
    (present : (argumentFrame (library.model other) sources specification.exports info).position ≠ 0) :
    let entry := argumentFrame (library.model other) sources specification.exports info
    let final := declarationsFrame (library.model other) sources specification.exports info
    let hasArgument := (contextClauses (library.model other) sources info).argumentsWith
    let original := library.input other sources specification.exports info
    ∃ fallback, MainArgumentAt (textOf sources) entry hasArgument fallback ∧
      ∀ arguments : Arguments.Runtime.Arguments,
        let input := runtimeInput hasArgument fallback arguments
        let inputValid := runtimeInputValid hasArgument arguments
        Fits original.context.names.shape input (inventory.runtimeValues hasArgument input) ∧
          Bindings.Printable input ∧
          (original.context.flow original.input.scan.facts).Allows inputValid input.length false
            (inventory.runtimeIntegers entry final) ∧
          Integer.Fits original.context.analysis.declared (inventory.runtimeIntegers entry final) := by
  dsimp only
  have executed := specified ▸ readSpecification_exec reader (sources.prefix .packageSpecification)
    {units := sources.units}
  have tables := specification_tables (reader := reader) rfl rfl executed
  have initial := RuntimeArraySeed.specification_seed executed
  have seed := RuntimeArraySeed.argument_frame (library.bodyCalls other) sources
    specification.exports info initial
  obtain ⟨fallback, reading⟩ := original_argument (library.bodyCalls other) sources
    specification.exports info tables present
  refine ⟨fallback, reading, ?_⟩
  intro arguments
  have initialized := inventory.runtime_stores (reading.runtime_start arguments) source
    (textOf_valid valid) domain seed
  have count := scalar_declarations_count_bound source.integers domain.native.base.2.2.2.2.2.1.1
  refine ⟨?_, initialized.2.1, ?_, ?_⟩
  · rw [library.runtime_context]
    exact initialized.1
  · rw [library.runtime_initial_flow other sources specification.exports info count]
    exact initialized.2.2.1
  · rw [library.runtime_context]
    exact initialized.2.2.2.1

end BodyLibraries
end Silver.ApplicationPackageMain
