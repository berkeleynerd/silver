module

public import Silver.ApplicationPackageRoutineEffects
public import Silver.ApplicationPackageRoutineSourceLibrary

@[expose] public section

namespace Silver.ApplicationPackageRoutineFooterEffects
open Compose Predicate Packages ApplicationPackages PackageBindings
open Packages.EffectSummaries ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrameLayout ApplicationPackageInitializers ApplicationPackageRoutineResults
open ApplicationPackageRoutineSources ApplicationPackageSourceEffects

set_option backward.dsimp.instances true

theorem actual_start_nonzero {text context position facts formal actual after}
    (source : ActualAt text context position facts formal actual after) : position ≠ 0 := by
  intro zero
  apply source.positive
  rw [← source.equation, zero, actualAfter_zero]

/-- A function return adds its source read mask; a procedure return retains
the scan. Neither can discard an effect accumulated by the original body. -/
theorem return_preserves {calls : CompletionCalls} {text : Source} {context : ParseContext}
    {info : Metadata} {item : Routine} {input returned : ApplicationScan}
    (capacity : info.states.length ≤ maxStates)
    (read : completionReturn calls text context info item input = some returned) :
    Included (scanEffects info input) (scanEffects info returned) := by
  cases kind : item.kind with
  | function =>
    obtain ⟨rfl, _, _, _, _⟩ := completionReturn_function kind read
    dsimp only [scanEffects, maskEffects, returnScan]
    have monotone := union_left (info := info) capacity input.reads
      (calls.stateReads text context info (calls.takeToken text input.scan.position (.word "return"))
        (calls.functionReturnAfter text context input.scan ⟨0, item.resultKind, item.resultBounds, 0⟩))
    exact ⟨monotone, fun _ member => member⟩
  | procedure =>
    simp only [completionReturn, kind, reduceCtorEq, ite_false, Option.some.injEq] at read
    subst returned
    exact Included.refl _

/-- Original result syntax is covered by the return scan. Implicit procedure
copy-back reads invocation-local formal cells and contributes no global read. -/
theorem results_included {calls : CompletionCalls} {text : Source} {context : ParseContext}
    {info : Metadata} {item : Routine} {input returned : ApplicationScan}
    {values : List ScalarFunctions.Actual} (bound : Nat)
    (source : ResultValuesAt text context info item input.scan values)
    (read : completionReturn calls text context info item input = some returned)
    (take : calls.takeToken = tokenAfter)
    (returnAfter : calls.functionReturnAfter = functionReturnAfter)
    (reads : calls.stateReads = ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls)
    (declarations : StateDeclarations text info.states)
    (capacity : info.states.length ≤ maxStates)
    (scalarCapacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanCapacity : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (localNames : ∀ formal ∈ item.formals info,
      ApplicationPackageNames.outerDeclaration info formal.bodyName = false) :
    Included (directEffects (layout bound info context) (actualsReads values) []) (scanEffects info returned) := by
  constructor
  · intro cell member
    cases source with
    | @function actual kind value =>
      have expression : cell ∈ globalCells (layout bound info context) (actualReads actual) := by
        simpa only [directEffects, actualsReads, List.flatMap_cons, List.flatMap_nil, List.append_nil] using member
      have covered := actual_global_reads value rfl (actual_start_nonzero value)
        (fixedAfter_result_bound text input.scan.position "return" true (by decide)) (Nat.le_refl _)
        declarations capacity scalarCapacity booleanCapacity cell expression
      obtain ⟨same, _, _, _, _⟩ := completionReturn_function kind read
      rw [same]
      dsimp only [scanEffects, maskEffects, returnScan]
      apply union_right (info := info) capacity input.reads _ cell
      simpa only [take, returnAfter, reads, tokenAfter, ShellToken.word] using covered
    | procedure kind values =>
      have empty := values.no_global_reads localNames bound
      change cell ∈ globalCells (layout bound info context) (actualsReads _) at member
      rw [empty] at member
      contradiction
  · intro cell member
    change cell ∈ globalCells (layout bound info context) [] at member
    contradiction

/-- The footer stores precisely the returned native masks in the original
routine cell; its state-table interpretation is unchanged. -/
theorem footer_effects {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (read : CompletionBodyRead (declarationReaders reader calls) text globals frames.signature.info
      (info.completed + 1) (frames.signature.info.routineAt (info.completed + 1)) frames.outputs.body result)
    (pending : info.completed < info.routines.length) :
    (result.info.routineAt result.info.completed).effects result.info =
      scanEffects frames.signature.info read.returned := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have tables : CompletedTables info frames.signature.info := signed ▸ readSignature_tables text globals info
  have within : info.completed + 1 ≤ frames.signature.info.routines.length := by
    rw [tables.lengths.2]
    omega
  have selected := (read.stored_item (by omega) within).2.2
  rw [selected, read.stored]
  rfl

theorem constant_seed_reads (seed : ConstantSeed) :
    globalCells seed.initializer.layout (actualReads seed.initializer.value) = [] := by
  cases seed <;> rfl

theorem constant_seed_initializers_reads (seeds : List ConstantSeed) :
    initializerReads (seeds.map ConstantSeed.initializer) = [] := by
  induction seeds with
  | nil => rfl
  | cons first rest ih =>
    simp only [List.map_cons, initializerReads, List.flatMap_cons, constant_seed_reads, List.nil_append] at ih ⊢
    exact ih

/-- The accepted output-prefix row records exactly its original RHS mask. -/
theorem output_read_mask {calls : CompletionCalls} {text : Source} {info : Metadata} {row : OutputObject}
    (output : (info.parameterAt row.index).mode = .output)
    (read : outputInitializer calls text info (info.parameterAt row.index) row.before = some row.after) :
    row.after.reads = stateUnion row.before.reads
      (calls.stateReads text (row.context calls) info (row.valueFirst calls text) (row.valueAfter calls text info)) := by
  unfold outputInitializer at read
  simp only [output, ne_eq, not_true_eq_false, ite_false] at read
  split at read
  · contradiction
  · split at read
    · contradiction
    · split at read
      · contradiction
      · have same := Option.some.inj read
        have stored := congrArg InitializationFrame.reads same
        simpa only [OutputObject.context, OutputObject.valueFirst, OutputObject.valueAfter, OutputObject.formal]
          using stored.symm

/-- Every output RHS mask and the incoming initializer mask survive the
entire original prefix, including skipped input and in-out parameters. -/
theorem output_history_masks {calls : CompletionCalls} {text : Source} {info : Metadata}
    {indices : List Nat} {before after : InitializationFrame} {rows : List OutputObject}
    (history : OutputObjects calls text info indices before rows after)
    (capacity : info.states.length ≤ maxStates) :
    (∀ cell ∈ info.effectCells before.reads, cell ∈ info.effectCells after.reads) ∧
    (∀ row ∈ rows, ∀ cell ∈ info.effectCells
      (calls.stateReads text (row.context calls) info (row.valueFirst calls text) (row.valueAfter calls text info)),
        cell ∈ info.effectCells after.reads) := by
  induction history with
  | nil => exact ⟨fun _ member => member, by simp⟩
  | skipped _ _ ih => exact ih
  | @added row indices rows final output read rest ih =>
    have stored := output_read_mask output read
    constructor
    · intro cell member
      apply ih.1 cell
      rw [stored]
      exact union_left capacity _ _ cell member
    · intro seen member cell selected
      rcases List.mem_cons.mp member with rfl | later
      · apply ih.1 cell
        rw [stored]
        exact union_right capacity _ _ cell selected
      · exact ih.2 seen later cell selected

theorem output_values_reads {calls : CompletionCalls} {text : Source} {info : Metadata}
    {rows : List OutputObject} {items : List LocalInitializer} {bound : Nat} {finalMask : StateSet}
    (source : OutputValuesAt bound calls info text rows items)
    (take : calls.takeToken = tokenAfter)
    (reads : calls.stateReads = ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls)
    (declarations : StateDeclarations text info.states) (capacity : info.states.length ≤ maxStates)
    (counts : ∀ row ∈ rows,
      (row.context calls).scalarNames.length ≤ ArrayBindings.scalarLimit ∧
      (row.context calls).booleanNames.length ≤ BooleanBindings.maxBindings)
    (masks : ∀ row ∈ rows, ∀ cell ∈ info.effectCells
      (calls.stateReads text (row.context calls) info (row.valueFirst calls text) (row.valueAfter calls text info)),
        cell ∈ info.effectCells finalMask) :
    ∀ cell ∈ initializerReads items, cell ∈ info.effectCells finalMask := by
  induction source with
  | nil => simp [initializerReads]
  | @cons row rows items value original rest ih =>
    intro cell member
    rcases List.mem_append.mp member with first | later
    · have count := counts row List.mem_cons_self
      apply masks row List.mem_cons_self cell
      rw [reads]
      apply actual_global_reads original rfl (actual_start_nonzero original) ?_ (Nat.le_refl _)
        declarations capacity count.1 count.2 cell first
      change calls.takeToken text _ (.symbol ":=") ≤ _
      rw [take]
      exact fixedAfter_result_bound _ _ ":=" false (by decide)
    · exact ih (fun seen present => counts seen (List.mem_cons_of_mem _ present))
        (fun seen present => masks seen (List.mem_cons_of_mem _ present)) cell later

end Silver.ApplicationPackageRoutineFooterEffects
