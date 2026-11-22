module

public import Silver.PackageDefinitions
public import Silver.ScalarFunctionSemantics

@[expose] public section

/-! Package initialization follows the original elaboration order: full-domain
inputs precede local declarations, and each RHS uses its own name-resolution
layout. The checked pass computes the next local interval from that RHS.
Global cells are never reinitialized at entry. These rules establish safety and
automatic obligations independently of the later body/call induction. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value ScalarType Actual)

structure SharedRanges where
  globals : Integer.Ranges
  locals : Integer.Ranges

def SharedRanges.Fits (ranges : SharedRanges) (state : SharedState) : Prop :=
  Integer.Fits ranges.globals state.globals.integers ∧
    Integer.Fits ranges.locals state.locals.integers

def SharedRanges.view (ranges : SharedRanges) (layout : FrameLayout) : Integer.Ranges :=
  fun index => match layout.integers index with
    | .global identity => ranges.globals identity
    | .local identity => ranges.locals identity

theorem SharedRanges.view_fits {ranges : SharedRanges} {state : SharedState}
    (fitting : ranges.Fits state) (layout : FrameLayout) :
    Integer.Fits (ranges.view layout) (state.view layout).integers := by
  intro index bounds found
  cases selected : layout.integers index with
  | global identity =>
      simpa only [SharedState.view, SharedState.integer, selected] using
        fitting.1 identity bounds (by simpa only [view, selected] using found)
  | «local» identity =>
      simpa only [SharedState.view, SharedState.integer, selected] using
        fitting.2 identity bounds (by simpa only [view, selected] using found)

def extendRanges (ranges : Integer.Ranges) (target : Cell) (domain : ScalarType) : Integer.Ranges :=
  match target, domain with
  | .integer identity, .integer bounds => Integer.put ranges identity (some bounds)
  | _, _ => ranges

theorem extendRanges_fits {ranges : Integer.Ranges} {frame : Frame} {target : Cell}
    {domain : ScalarType} {value : Value} (kind : CellDomain target domain)
    (fitting : Integer.Fits ranges frame.integers) (within : domain.Contains value) :
    Integer.Fits (extendRanges ranges target domain) (writeCell frame target value).integers := by
  cases target <;> cases domain <;> cases value <;>
    simp only [CellDomain, ScalarType.Contains] at kind within
  all_goals try contradiction
  · exact Integer.put_fits fitting within
  · exact fitting

def inputRangesFrom : Integer.Ranges → List InputBinding → Integer.Ranges
  | ranges, [] => ranges
  | ranges, binding :: rest => inputRangesFrom (extendRanges ranges binding.target binding.domain) rest

theorem bindInputs_fits {bindings : List InputBinding} {values : List Value}
    (valid : ∀ binding ∈ bindings, binding.Valid)
    (inputs : ScalarFunctions.ArgumentsFit (bindings.map InputBinding.domain) values)
    (ranges : Integer.Ranges) (frame : Frame) (fitting : Integer.Fits ranges frame.integers) :
    Integer.Fits (inputRangesFrom ranges bindings) (bindInputs frame bindings values).integers := by
  induction bindings generalizing ranges frame values with
  | nil => simpa only [inputRangesFrom, bindInputs] using fitting
  | cons binding rest ih =>
      cases values with
      | nil => contradiction
      | cons value values =>
          exact ih (fun next member => valid next (by simp [member])) inputs.2 _ _
            (extendRanges_fits (valid binding (by simp)).1 fitting inputs.1)

def StateSchema.integerRanges : StateSchema → Integer.Ranges
  | [] => Integer.emptyRanges
  | declaration :: rest => extendRanges (StateSchema.integerRanges rest) declaration.cell declaration.domain

theorem StateSchema.integerRanges_fits {schema : StateSchema} {frame : Frame}
    (valid : schema.Valid) (fitting : schema.Fits frame) : Integer.Fits schema.integerRanges frame.integers := by
  induction schema with
  | nil => exact Integer.empty_fits _
  | cons declaration rest ih =>
      have restValid : StateSchema.Valid rest :=
        ⟨(List.nodup_cons.mp valid.1).2, fun item member => valid.2 item (by simp [member])⟩
      have restFits : StateSchema.Fits rest frame := fun item member => fitting item (by simp [member])
      have initial := extendRanges_fits (valid.2 declaration (by simp)).2.1
        (ih restValid restFits) (fitting declaration (by simp))
      simpa only [integerRanges, writeCell_read] using initial

def LocalInitializer.flow (item : LocalInitializer) (ranges : SharedRanges) : Predicate.Flow :=
  ⟨ScalarFunctions.entryContext, ranges.view item.layout⟩

def LocalInitializer.check (item : LocalInitializer) (ranges : SharedRanges) : Option SharedRanges :=
  if ScalarFunctions.scalarActual item.value then
    match item.target, item.domain, item.value with
    | .integer identity, .integer target, .integer expression =>
        (expression.infer (ranges.view item.layout)).bind fun bounds =>
          if !bounds.isEmpty && bounds.included target then
            some {ranges with locals := Integer.put ranges.locals identity (some bounds)}
          else none
    | .boolean _, .boolean, .boolean condition =>
        if condition.checkBounds Bindings.emptyShape item.analysis (item.flow ranges) item.booleans
        then some ranges else none
    | _, _, _ => none
  else none

def LocalInitializer.Readable (item : LocalInitializer) : Prop :=
  item.value.Readable false Bindings.emptyShape item.booleans

theorem LocalInitializer.check_actual {item : LocalInitializer} {before after : SharedRanges}
    (checked : item.check before = some after) :
    item.value.check Bindings.emptyShape item.analysis (item.flow before) item.booleans item.domain = true := by
  simp only [check] at checked
  split at checked
  · cases target : item.target <;> cases domain : item.domain <;> cases value : item.value <;>
      simp only [target, domain, value] at checked
    all_goals try contradiction
    · simp only [Option.bind_eq_some_iff] at checked
      obtain ⟨bounds, inferred, selected⟩ := checked
      split at selected
      · rename_i accepted
        simpa only [ScalarFunctions.Actual.check, value, domain, flow, inferred] using accepted
      · contradiction
    · split at checked
      · simpa only [ScalarFunctions.Actual.check, value, domain] using ‹_ = true›
      · contradiction
  · contradiction

theorem LocalInitializer.check_sound {item : LocalInitializer} {before after : SharedRanges}
    {state : SharedState} (checked : item.check before = some after)
    (readable : item.Readable) (fitting : before.Fits state) :
    let evaluation := scalarState (state.view item.layout)
    item.value.Safe Bindings.emptyShape evaluation ∧
      item.domain.Contains (item.value.evaluate evaluation) ∧
      item.value.checkedEvaluate evaluation = some (item.value.evaluate evaluation) ∧
      after.Fits (state.write (.local item.target) (item.value.evaluate evaluation)) := by
  have allowed : (item.flow before).Allows true 0 false (state.view item.layout).integers :=
    ⟨ScalarFunctions.entryContext_allows _, before.view_fits fitting item.layout⟩
  have values : Bindings.Fits Bindings.emptyShape [] Bindings.emptyValues := Bindings.empty_fits []
  have sound := ScalarFunctions.Actual.check_sound (state := scalarState (state.view item.layout))
    values readable allowed (item.check_actual checked)
  refine ⟨sound.1, sound.2, ScalarFunctions.Actual.checkedEvaluate_agrees values sound.1, ?_⟩
  simp only [check] at checked
  split at checked
  · cases target : item.target <;> cases domain : item.domain <;> cases value : item.value <;>
      simp only [target, domain, value] at checked
    all_goals try contradiction
    · simp only [Option.bind_eq_some_iff] at checked
      obtain ⟨bounds, inferred, selected⟩ := checked
      split at selected
      · cases Option.some.inj selected
        have within := (Integer.Expr.infer_sound inferred (before.view_fits fitting item.layout)).1
        exact ⟨fitting.1, Integer.put_fits fitting.2 within⟩
      · contradiction
    · split at checked
      · cases Option.some.inj checked
        exact fitting
      · contradiction
  · contradiction

def checkInitializers : SharedRanges → List LocalInitializer → Option SharedRanges
  | ranges, [] => some ranges
  | ranges, item :: rest => (item.check ranges).bind fun next => checkInitializers next rest

def checkedInitializeLocals : SharedState → List LocalInitializer → Option SharedState
  | state, [] => some state
  | state, item :: rest =>
      (item.value.checkedEvaluate (scalarState (state.view item.layout))).bind fun value =>
        if item.domain.contains value then checkedInitializeLocals (state.write (.local item.target) value) rest
        else none

def InitializersSafe : SharedState → List LocalInitializer → Prop
  | _, [] => True
  | state, item :: rest =>
      item.value.Safe Bindings.emptyShape (scalarState (state.view item.layout)) ∧
        item.domain.Contains (item.value.evaluate (scalarState (state.view item.layout))) ∧
        InitializersSafe (state.write (.local item.target)
          (item.value.evaluate (scalarState (state.view item.layout)))) rest

theorem checkInitializers_sound {initial final : SharedRanges} {state : SharedState}
    {items : List LocalInitializer} (checked : checkInitializers initial items = some final)
    (readable : ∀ item ∈ items, item.Readable) (fitting : initial.Fits state) :
    InitializersSafe state items ∧ final.Fits (initializeLocals state items) ∧
      checkedInitializeLocals state items = some (initializeLocals state items) := by
  induction items generalizing initial state with
  | nil => cases Option.some.inj checked; exact ⟨trivial, fitting, rfl⟩
  | cons item rest ih =>
      simp only [checkInitializers, Option.bind_eq_some_iff] at checked
      obtain ⟨next, head, tail⟩ := checked
      have first := item.check_sound head (readable item (by simp)) fitting
      have remaining := ih tail (fun item member => readable item (by simp [member])) first.2.2.2
      refine ⟨⟨first.1, first.2.1, remaining.1⟩, remaining.2.1, ?_⟩
      simp only [checkedInitializeLocals, first.2.2.1, Option.bind_some, initializeLocals]
      have contained : item.domain.contains (item.value.evaluate (scalarState (state.view item.layout))) = true :=
        (ScalarFunctions.ScalarType.contains_iff _ _).mpr first.2.1
      simp only [contained, ↓reduceIte, remaining.2.2]

def LocalInitializer.obligations (item : LocalInitializer) (ranges : SharedRanges) : List Predicate.Obligation :=
  Predicate.actualObligations Bindings.emptyShape item.analysis (item.flow ranges) item.booleans item.domain item.value

theorem LocalInitializer.obligations_discharge {item : LocalInitializer} {before after : SharedRanges}
    (checked : item.check before = some after) : Predicate.discharged (item.obligations before) = true :=
  Predicate.actual_obligations_discharge (item.check_actual checked)

def initializersObligations : SharedRanges → List LocalInitializer → List Predicate.Obligation
  | _, [] => []
  | ranges, item :: rest => item.obligations ranges ++
      match item.check ranges with
      | none => [.impossible]
      | some next => initializersObligations next rest

theorem initializers_obligations_discharge {initial final : SharedRanges} {items : List LocalInitializer}
    (checked : checkInitializers initial items = some final) :
    Predicate.discharged (initializersObligations initial items) = true := by
  induction items generalizing initial with
  | nil => rfl
  | cons item rest ih =>
      simp only [checkInitializers, Option.bind_eq_some_iff] at checked
      obtain ⟨next, head, tail⟩ := checked
      rw [initializersObligations, Predicate.discharged_append, item.obligations_discharge head,
        head, Bool.true_and]
      exact ih tail

theorem invocation_inputs_full_domain {schema : StateSchema} {globals : Frame}
    {bindings : List InputBinding} {inputs : List Value}
    (valid : schema.Valid) (globalFit : schema.Fits globals)
    (bindingsValid : ∀ binding ∈ bindings, binding.Valid)
    (inputsFit : ScalarFunctions.ArgumentsFit (bindings.map InputBinding.domain) inputs) :
    SharedRanges.Fits ⟨schema.integerRanges, inputRangesFrom Integer.emptyRanges bindings⟩
      ⟨globals, bindInputs ⟨Integer.emptyStore, Boolean.emptyStore⟩ bindings inputs⟩ :=
  ⟨schema.integerRanges_fits valid globalFit,
    bindInputs_fits bindingsValid inputsFit _ _ (Integer.empty_fits _)⟩

end Silver.Packages
