module

public import Silver.ApplicationPackageLocalInitializerEffects

@[expose] public section

namespace Silver.ApplicationPackageRoutineInitializerEffects
open Compose Compose.Expressions Predicate Packages PackageBindings ApplicationPackages
open ApplicationPackageEffects
open ApplicationPackageDeclarations ApplicationPackageBodies ApplicationPackageInitializers
open ApplicationPackageFrameLayout ApplicationPackageRoutineSources
open ApplicationPackageSourceEffects ApplicationPackageRoutineFooterEffects
open ApplicationPackageLocalInitializerEffects

set_option backward.dsimp.instances true

theorem local_history_domains {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {info : Metadata} {routine : Routine}
    {before after : InitializationFrame} {rows : List LocalObject}
    (history : LocalObjects calls text info routine before rows after)
    (valid : ValidText text) (framed : ReaderFrame text before.frame)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true) :
    ReaderFrame text after.frame ∧ ∀ row ∈ rows,
      ReaderFrame text row.before.frame ∧
      objectStep (modelObjectCalls reader) text row.before.frame info true = row.object ∧
      row.object.frame.position ≠ 0 := by
  induction history with
  | finished => exact ⟨framed, by simp⟩
  | @added row final following _ _ parsed advanced rest ih =>
    have execution := (original row List.mem_cons_self).symm.trans parsed
    have present : row.object.frame.position ≠ 0 := by omega
    have next := execution ▸ objectStep_reader_frame reader valid row.before.frame framed
      info true (execution ▸ present)
    obtain ⟨last, later⟩ := ih next (fun seen member => original seen (List.mem_cons_of_mem _ member))
    refine ⟨last, ?_⟩
    intro seen member
    rcases List.mem_cons.mp member with rfl | following
    · exact ⟨framed, execution, present⟩
    · exact later seen following

theorem output_history_counts {calls : CompletionCalls} {text : Source} {info : Metadata}
    {indices : List Nat} {before after : InitializationFrame} {rows : List OutputObject}
    (history : OutputObjects calls text info indices before rows after)
    (take : calls.takeToken = tokenAfter) (contexts : calls.contextOf = contextOf)
    (framed : ReaderFrame text before.frame) :
    ∀ row ∈ rows, (row.context calls).scalarNames.length ≤ ArrayBindings.scalarLimit ∧
      (row.context calls).booleanNames.length ≤ BooleanBindings.maxBindings := by
  induction history with
  | nil => simp
  | skipped _ _ ih => exact ih framed
  | @added row indices rows final output read rest ih =>
    have next := output_reader_frame take framed read
    intro seen member
    rcases List.mem_cons.mp member with rfl | later
    · simpa only [OutputObject.context, contexts, contextOf, ScalarExpression.bodyEnvironment_length,
        ScalarExpression.maxBindings, ArrayBindings.scalarLimit]
        using And.intro framed.typed.scalarCount framed.typed.booleanCount
    · exact ih next seen later

/-- Original specification constants, local declaration RHSs and output-prefix
RHSs are all covered by the exact native mask entering this routine's body.
Every initializer keeps the layout at which its own expression was read. -/
theorem initializer_effects {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult} {readers}
    {frames : CompletionFrames (declarationReaders reader calls) text globals info result}
    (source : RoutineCode frames readers) (specRows : List SpecificationItem)
    (valid : ValidText text) (entry : ReaderFrame text frames.entry)
    (declarations : StateDeclarations text frames.signature.info.states)
    (capacity : frames.signature.info.states.length ≤ maxStates)
    (reads : calls.stateReads = stateReads ApplicationPackageEffects.modelCalls) :
    Packages.EffectSummaries.Included (source.definition specRows).initialEffects
      (scanEffects frames.signature.info frames.bodySource.input) := by
  have locals := local_history_domains frames.declarations valid entry (fun _ _ => rfl)
  have localMasks := local_history_masks frames.declarations capacity
  have localReads := local_values_reads (calls := declarationReaders reader calls)
    source.localSource reads rfl declarations capacity
    (fun row member => (locals.2 row member).1)
    (fun row member => (locals.2 row member).2.1)
    (fun row member => (locals.2 row member).2.2) localMasks.2
  have begun : ReaderFrame text (beginOutputs (declarationReaders reader calls) text frames.locals).frame := by
    apply locals.1.at_position
    exact fixedAfter_result_bound text _ "begin" true (by decide)
  have outputMasks := output_history_masks source.outputHistory capacity
  have counts := output_history_counts source.outputHistory rfl rfl begun
  have outputReads := output_values_reads source.outputSource rfl reads declarations capacity counts outputMasks.2
  constructor
  · intro cell member
    change cell ∈ initializerReads
      (((specificationSeeds specRows).map ConstantSeed.initializer ++ source.locals) ++ source.outputs) at member
    have appendReads (first rest : List LocalInitializer) :
        initializerReads (first ++ rest) = initializerReads first ++ initializerReads rest :=
      List.flatMap_append
    rw [appendReads, appendReads, constant_seed_initializers_reads, List.nil_append] at member
    change cell ∈ frames.signature.info.effectCells frames.outputs.initialized.reads
    rcases List.mem_append.mp member with localRead | outputRead
    · exact outputMasks.1 cell (localReads cell localRead)
    · exact outputReads cell outputRead
  · intro cell member
    change cell ∈ [] at member
    contradiction

end Silver.ApplicationPackageRoutineInitializerEffects
