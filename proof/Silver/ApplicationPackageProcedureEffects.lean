module

public import Silver.ApplicationPackageSourceEffects
public import Silver.ApplicationPackageProcedureSourceFlow

@[expose] public section

/-! Original procedure actuals determine their copy-in reads and copy-back
targets. The native masks are obtained from the executed argument reader. -/
namespace Silver.ApplicationPackageSourceEffects.SourceFrames
open Compose Predicate Packages ApplicationPackages ApplicationPackageCalls
open ApplicationPackageFrameLayout ApplicationPackageBodies

private theorem reads_cons {layout : FrameLayout} {head : ScalarFunctions.Actual}
    {tail : List ScalarFunctions.Actual} {cells : List Cell}
    (first : ∀ cell ∈ globalCells layout (actualReads head), cell ∈ cells)
    (later : ∀ cell ∈ globalCells layout (actualsReads tail), cell ∈ cells) :
    ∀ cell ∈ globalCells layout (actualsReads (head :: tail)), cell ∈ cells := by
  intro cell member
  obtain ⟨localCell, used, selected⟩ := globalCells_mem.mp member
  simp only [actualsReads, List.flatMap_cons] at used
  rcases List.mem_append.mp used with firstRead | laterRead
  · exact first cell (globalCells_mem.mpr ⟨localCell, firstRead, selected⟩)
  · exact later cell (globalCells_mem.mpr ⟨localCell, laterRead, selected⟩)

/-- Binding determines whether an original target contributes a copy-in read:
`out` targets do not, while `in out` targets do. -/
theorem procedure_arguments_reads {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {afterName bound : Nat} {frame : ActualFrame} {slots : List Nat}
    {values : List ScalarProcedures.Actual} {actuals : ScalarProcedures.ActualBindings}
    (source : Basic.ProcedureArgumentsAt text context input info frame slots values)
    (binding : ScalarProcedures.bindActuals
      (slots.map fun slot => (info.parameterAt slot).semantic) values = some actuals)
    (read : readActuals modelCalls text context.model input info item afterName = some frame)
    (domain : ∀ slot ∈ slots, 0 < slot ∧ (frame.actual slot).first ≤ text.length + 1 ∧
      (frame.actual slot).after ≠ 0)
    (valid : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.model.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : context.model.booleanNames.length ≤ BooleanBindings.maxBindings) :
    ∀ cell ∈ globalCells (layout bound info context.model) (actualsReads actuals.inputs),
      cell ∈ info.effectCells frame.result.result.reads := by
  induction source generalizing actuals with
  | nil =>
      cases Option.some.inj binding
      intro cell member
      simp only [actualsReads, List.flatMap_nil, globalCells, List.filterMap_nil, List.not_mem_nil] at member
  | @value slot slots value values head rest ih =>
      have slotDomain := domain slot (List.mem_cons_self ..)
      cases mode : (info.parameterAt slot).mode with
      | input =>
          simp only [List.map_cons, PackageBindings.Formal.semantic, mode,
            ScalarProcedures.bindActuals, Option.map_eq_some_iff] at binding
          obtain ⟨following, remaining, rfl⟩ := binding
          exact reads_cons
            (NativeReads.actual_read_included read head slotDomain.1 (by rw [mode]; decide)
              slotDomain.2.1 declarations capacity scalarCapacity booleanCapacity)
            (ih remaining (fun index member => domain index (List.mem_cons_of_mem _ member)))
      | output | inputOutput =>
          simp only [List.map_cons, PackageBindings.Formal.semantic, mode,
            ScalarProcedures.bindActuals, reduceCtorEq] at binding
  | @target slot slots values writable target ends rest ih =>
      have slotDomain := domain slot (List.mem_cons_self ..)
      cases mode : (info.parameterAt slot).mode with
      | input => exact False.elim (writable mode)
      | output =>
          simp only [List.map_cons, PackageBindings.Formal.semantic, mode,
            ScalarProcedures.bindActuals, Option.map_eq_some_iff] at binding
          obtain ⟨following, remaining, rfl⟩ := binding
          exact ih (actuals := following) remaining
            (fun index member => domain index (List.mem_cons_of_mem _ member))
      | inputOutput =>
          simp only [List.map_cons, PackageBindings.Formal.semantic, mode,
            ScalarProcedures.bindActuals, Option.map_eq_some_iff] at binding
          obtain ⟨following, remaining, rfl⟩ := binding
          exact reads_cons
            (NativeReads.target_read_included read target ends slotDomain.1 (by rw [mode]; decide)
              slotDomain.2.2 slotDomain.2.1 valid declarations capacity)
            (ih remaining (fun index member => domain index (List.mem_cons_of_mem _ member)))

/-- Every explicit writable target retains its own original source slot. -/
theorem procedure_target_source {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : PackageBindings.Metadata} {frame : ActualFrame}
    {slots : List Nat} {values : List ScalarProcedures.Actual}
    (source : Basic.ProcedureArgumentsAt text context input info frame slots values)
    (present : ∀ slot ∈ slots, (frame.actual slot).after ≠ 0)
    {object : ScalarFunctions.Target} (member : ScalarProcedures.Actual.target object ∈ values) :
    ∃ slot ∈ slots, (info.parameterAt slot).mode ≠ .input ∧
      WritableNameAt text context.model (frame.actual slot).first (frame.actual slot).after
        (ScalarProcedures.targetCell object) := by
  induction source with
  | nil => contradiction
  | @value slot slots value values head rest ih =>
      have later : ScalarProcedures.Actual.target object ∈ values := by
        simpa only [List.mem_cons, reduceCtorEq, false_or] using member
      obtain ⟨index, inRange, writable, named⟩ :=
        ih (fun index member => present index (List.mem_cons_of_mem _ member)) later
      exact ⟨index, List.mem_cons_of_mem _ inRange, writable, named⟩
  | @target slot slots values writable target ends rest ih =>
      rcases List.mem_cons.mp member with same | later
      · have targetEq := ScalarProcedures.Actual.target.inj same
        subst object
        have nonzero : (procedureTargetActual text context.model (frame.actual slot).first input.scan.facts
            (outputFormal (info.parameterAt slot))).after ≠ 0 := by
          rw [target, ← ends]
          exact present slot (List.mem_cons_self ..)
        have named := procedureTargetActual_name nonzero
        rw [target, ← ends] at named
        exact ⟨slot, List.mem_cons_self .., writable, named⟩
      · obtain ⟨index, inRange, writable, named⟩ :=
          ih (fun index member => present index (List.mem_cons_of_mem _ member)) later
        exact ⟨index, List.mem_cons_of_mem _ inRange, writable, named⟩

/-- Copy-back writes come from the original argument targets and the actual
native mask fold, including named argument reorderings. -/
theorem procedure_arguments_writes {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {afterName bound : Nat} {frame : ActualFrame} {values : List ScalarProcedures.Actual}
    {actuals : ScalarProcedures.ActualBindings}
    (source : Basic.ProcedureArgumentsAt text context input info frame (formalSlots item) values)
    (binding : ScalarProcedures.bindActuals ((item.formals info).map PackageBindings.Formal.semantic)
      values = some actuals)
    (read : readActuals modelCalls text context.model input info item afterName = some frame)
    (present : ∀ slot ∈ formalSlots item, (frame.actual slot).after ≠ 0)
    (first : 0 < item.count → 0 < item.formalFirst)
    (formals : 0 < item.count → item.formalFirst + item.count - 1 ≤ PackageBindings.maxFormals)
    (maskCapacity : info.states.length ≤ item.mayWrite.length)
    (valid : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (declarations : StateDeclarations text info.states) :
    ∀ cell ∈ globalCells (layout bound info context.model)
      (actuals.outputs.map ScalarProcedures.targetCell), cell ∈ info.effectCells frame.callWrites := by
  intro cell member
  obtain ⟨localCell, used, placed⟩ := globalCells_mem.mp member
  obtain ⟨object, output, same⟩ := List.mem_map.mp used
  rw [← same] at placed
  rw [ScalarProcedures.bindActuals_outputs binding] at output
  obtain ⟨slot, inRange, writable, named⟩ :=
    procedure_target_source source present ((ScalarProcedures.mem_writableTargets _ _).mp output)
  obtain ⟨identity, positive, active, equal⟩ := layout_global_state placed
  rw [equal] at placed ⊢
  rw [info.effectCells_index positive active]
  apply (readActuals_writable_bits (stateTarget_zero text context.model info) read first formals
    identity positive (Nat.le_trans active maskCapacity)).mpr
  exact Or.inr ⟨slot, inRange, writable,
    (writableName_stateTarget_iff valid declarations named identity positive bound).mpr placed⟩

theorem procedure_call_arguments {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : PackageBindings.Metadata} {position bound : Nat}
    {call : ScalarProcedures.Call} {frame : ActualFrame} {actuals : ScalarProcedures.ActualBindings}
    (original : Basic.ProcedureCallAt text context input info position call)
    (read : readActuals modelCalls text context.model input info (info.routineAt call.callee)
      (modelCalls.reference text position).after = some frame)
    (binding : ScalarProcedures.bindActuals
      (((info.routineAt call.callee).formals info).map PackageBindings.Formal.semantic)
      call.actuals = some actuals)
    (first : 0 < (info.routineAt call.callee).count → 0 < (info.routineAt call.callee).formalFirst)
    (formals : 0 < (info.routineAt call.callee).count →
      (info.routineAt call.callee).formalFirst + (info.routineAt call.callee).count - 1 ≤ PackageBindings.maxFormals)
    (maskCapacity : info.states.length ≤ (info.routineAt call.callee).mayWrite.length)
    (valid : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.model.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : context.model.booleanNames.length ≤ BooleanBindings.maxBindings) :
    (∀ cell ∈ globalCells (layout bound info context.model) (actualsReads actuals.inputs),
      cell ∈ info.effectCells frame.result.result.reads) ∧
    (∀ cell ∈ globalCells (layout bound info context.model)
      (actuals.outputs.map ScalarProcedures.targetCell), cell ∈ info.effectCells frame.callWrites) := by
  obtain ⟨_, sourceFrame, entries, trace, arguments⟩ := original
  have same := original_executed trace read
  have source := same.procedure_arguments arguments
  have domain : ∀ slot ∈ formalSlots (info.routineAt call.callee),
      0 < slot ∧ (frame.actual slot).first ≤ text.length + 1 ∧ (frame.actual slot).after ≠ 0 := by
    intro slot member
    have positions := trace.slot_positions formals slot member
    have firstEq := congrArg Prod.fst (same.row slot)
    have afterEq := congrArg (fun value : Nat × Nat × ProcedureActualResult => value.2.1) (same.row slot)
    dsimp only [rowSyntax] at firstEq afterEq
    rw [firstEq, afterEq] at positions
    obtain ⟨offset, inRange, equal⟩ := List.mem_map.mp member
    have live := List.mem_range.mp inRange
    have positive := first (by omega)
    exact ⟨by omega, positions⟩
  refine ⟨procedure_arguments_reads source ?_ read domain valid declarations capacity scalarCapacity booleanCapacity,
    procedure_arguments_writes source binding read (fun slot member => (domain slot member).2.2)
      first formals maskCapacity valid declarations⟩
  simpa only [formalSlots, PackageBindings.Routine.formals, List.map_map, Function.comp_def] using binding

theorem callee_writes_included {calls text context input info item position frame}
    (read : readActuals calls text context input info item position = some frame)
    (formals : 0 < item.count → item.formalFirst + item.count - 1 ≤ PackageBindings.maxFormals)
    (maskCapacity : info.states.length ≤ item.mayWrite.length) :
    ∀ cell ∈ info.effectCells item.mayWrite, cell ∈ info.effectCells frame.callWrites := by
  intro cell member
  obtain ⟨offset, active, written, same⟩ := (info.mem_effectCells _ _).mp member
  apply (info.mem_effectCells _ _).mpr
  refine ⟨offset, active, ?_, same⟩
  exact (readActuals_write_bits read formals (offset + 1) (by omega) (by omega)).mpr (Or.inl written)

/-- All direct and transitive procedure effects are present in the actual
call's outgoing native masks. The semantic inference and original syntax retain
the callee identity in its original completed prefix. -/
theorem procedure_call_effects {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : PackageBindings.Metadata} {position bound : Nat}
    {call : ScalarProcedures.Call} {effects : Effects}
    (original : Basic.ProcedureCallAt text context input info position call)
    (accepted : (packageCallAt modelCalls text context.model input info position .procedure).value.after ≠ 0)
    (inferred : inferStatementEffects (completedEnvironment info) (layout bound info context.model)
      (.procedureCall call) = some effects)
    (typed : info.Typed) (valid : 0 < text.length ∧ text.length ≤ maxSourceLength)
    (declarations : StateDeclarations text info.states)
    (scalarCapacity : context.model.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : context.model.booleanNames.length ≤ BooleanBindings.maxBindings) :
    EffectSummaries.Included effects
      (scanEffects info (packageCallAt modelCalls text context.model input info position .procedure).result) := by
  have dimensions := accepted_call_dimensions typed accepted
  rw [← original.1] at dimensions
  obtain ⟨callee, item, frame, checked, selected, present, itemEq, read, _, _, masks⟩ := accepted_aliases accepted
  have same : callee = call.callee := selected.trans original.1.symm
  rw [same] at present
  rw [itemEq, same] at read masks
  obtain ⟨_, _, kind, found⟩ := callee_completed original.1.symm present rfl
  have signature := lookup_effect_signature found
  have capacity : info.states.length ≤ PackageBindings.maxStates := typed.2.2.2.2.1
  have reads := congrArg Prod.fst masks
  have writes := congrArg Prod.snd masks
  dsimp only [footprint] at reads writes
  cases binding : ScalarProcedures.bindActuals
      (((info.routineAt call.callee).formals info).map PackageBindings.Formal.semantic) call.actuals with
  | none =>
      simp only [inferStatementEffects, resolveProcedure, signature, PackageBindings.Routine.signature,
        kind, Option.bind_some, binding, Option.map_none, Option.bind_none] at inferred
      contradiction
  | some actuals =>
      simp only [inferStatementEffects, resolveProcedure, signature, PackageBindings.Routine.signature,
        kind, Option.bind_some, binding, Option.map_some, found, Option.some.injEq] at inferred
      subst effects
      have direct := procedure_call_arguments original read binding dimensions.1 dimensions.2.1
        dimensions.2.2 valid declarations capacity scalarCapacity booleanCapacity (bound := bound)
      have implicit := callee_writes_included read dimensions.2.1 dimensions.2.2
      apply EffectSummaries.Included.merge_bound
      · constructor
        · intro cell member
          change cell ∈ info.effectCells _
          rw [reads]
          exact union_left capacity _ _ cell (direct.1 cell member)
        · intro cell member
          change cell ∈ info.effectCells _
          rw [writes]
          exact union_right capacity _ _ cell (direct.2 cell member)
      · constructor
        · intro cell member
          change cell ∈ info.effectCells _
          rw [reads]
          exact union_right capacity _ _ cell member
        · intro cell member
          change cell ∈ info.effectCells _
          rw [writes]
          exact union_right capacity _ _ cell (implicit cell member)

end Silver.ApplicationPackageSourceEffects.SourceFrames
