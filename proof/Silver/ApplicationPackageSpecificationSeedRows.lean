module

public import Silver.ApplicationPackageSpecificationSeeds
public import Silver.ApplicationPackageRoutineSeedRanges
public import Silver.ApplicationPackageExportRows

@[expose] public section

/-! The original specification fold relates every exported scalar row to the
constant load at its defining byte. No semantic range-map certificate is an
input to the source history. -/
namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate Packages ApplicationPackageDeclarations
open ApplicationPackageObjectRows ApplicationPackageExportRows

def ConstantRangeRows (ranges : SharedRanges) (names : ScalarExpression.Environment) : Prop :=
  ∀ row ∈ names, ranges.locals row.first = some row.bounds ∧ row.mutable = false

def seedRanges (ranges : SharedRanges) (seeds : List ConstantSeed) : SharedRanges :=
  initializerDomains ranges (seeds.map ConstantSeed.initializer)

theorem seedRanges_nil (ranges : SharedRanges) : seedRanges ranges [] = ranges := rfl

theorem seedRanges_cons (ranges : SharedRanges) (seed : ConstantSeed) (rest : List ConstantSeed) :
    seedRanges ranges (seed :: rest) = seedRanges (seed.initializer.declare ranges) rest := rfl

theorem object_seed_rows {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult} {ranges : SharedRanges}
    (parsed : objectStep (modelObjectCalls reader) text before info false = out)
    (present : out.frame.position ≠ 0) (constant : out.constantObject = true) (order : FrameOrder before)
    (rows : ConstantRangeRows ranges before.scalarNames) :
    ConstantRangeRows ((objectConstantSeed out).initializer.declare ranges) out.frame.scalarNames := by
  obtain ⟨storage, _, _⟩ := objectStep_storage parsed present
  have positions := parsed ▸ objectStep_positions reader text before info false (parsed ▸ present)
  cases kind : out.mark.kind with
  | integer =>
    obtain ⟨_, stored, _⟩ := storage.integerStorage kind
    simp only [objectConstantSeed, kind, ConstantSeed.initializer]
    intro row member
    rw [stored] at member
    rcases List.mem_append.mp member with old | installed
    · have earlier : row.first < out.name.first :=
        Nat.lt_of_lt_of_le (order.scalar_before old) positions.1
      refine ⟨?_, (rows row old).2⟩
      change Integer.put ranges.locals out.name.first (some (.singleton out.initialBounds.lower)) row.first = _
      rw [Integer.put, ite_eq_right (Nat.ne_of_lt earlier)]
      exact (rows row old).1
    · cases List.mem_singleton.mp installed
      have singleton := object_global_singleton reader text before info parsed present
      refine ⟨?_, by simp only [constant, Bool.not_true]⟩
      change Integer.put ranges.locals out.name.first (some (.singleton out.initialBounds.lower)) out.name.first = _
      simp only [Integer.put, ite_true]
      exact congrArg some (congrArg (Integer.Interval.mk out.initialBounds.lower) singleton)
  | boolean =>
    obtain ⟨_, _, stored⟩ := storage.booleanStorage kind
    simpa only [stored, objectConstantSeed, kind, ConstantSeed.initializer, LocalInitializer.declare,
      extendRanges, initializerBase, Bool.false_eq_true, ite_false] using rows

theorem continue_specification_next {calls : SpecificationCalls} {text : Source} {before : Nat}
    {state after : SpecificationState}
    (run : continueSpecification calls text before state = .next after) :
    after = state ∧ before < state.exports.position := by
  unfold continueSpecification at run
  split at run
  · contradiction
  · rename_i accepted
    exact ⟨(SpecificationStep.next.inj run).symm,
      Nat.lt_of_not_ge (fun failed => accepted (by simp only [failed, decide_true, Bool.true_or]))⟩

private theorem subtype_tables {text : Source} {before after : ParserState}
    (read : SubtypeDeclarationAt text false before after) :
    after.scalarNames = before.scalarNames ∧ after.booleanNames = before.booleanNames := by
  cases read
  exact ⟨rfl, rfl⟩

theorem SpecificationSyntax.seed_rows {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before after : SpecificationState} {inventory : SpecificationSyntax} {ranges : SharedRanges}
    (source : inventory.SourceAt reader text before after)
    (order : FrameOrder before.exports) (rows : ConstantRangeRows ranges before.exports.scalarNames) :
    FrameOrder after.exports ∧ before.exports.position < after.exports.position ∧
      ConstantRangeRows (seedRanges ranges inventory.seed.toList) after.exports.scalarNames := by
  cases inventory with
  | routine =>
    change specificationRoutine (modelSpecificationCalls reader) text before = .next after at source
    dsimp only [specificationRoutine] at source
    split at source
    · contradiction
    · obtain ⟨rfl, advanced⟩ := continue_specification_next source
      exact ⟨reframe order rfl rfl (Nat.le_of_lt advanced), advanced, rows⟩
  | subtype inventory =>
    have run := source.1
    dsimp only [specificationSubtype, modelSpecificationCalls] at run
    split at run
    · contradiction
    · rename_i present
      have tables := subtype_tables (subtype_declaration_sound text before.exports false present)
      split at run
      · contradiction
      · unfold appendExport at run
        obtain ⟨rfl, advanced⟩ := continue_specification_next run
        refine ⟨reframe order tables.1 tables.2 (Nat.le_of_lt advanced), advanced, ?_⟩
        simpa only [tables.1, SpecificationSyntax.seed, Option.toList_none, seedRanges_nil] using rows
  | object out inventory =>
    have run := source.1
    have parsed := source.2.1
    have accepted := specification_object_present parsed run
    dsimp only [specificationObject, modelSpecificationCalls] at run
    simp only [parsed, accepted.1, accepted.2, decide_false, Bool.not_true, Bool.or_self,
      Bool.false_eq_true, ite_false] at run
    unfold appendExport at run
    obtain ⟨rfl, advanced⟩ := continue_specification_next run
    exact ⟨objectStep_frameOrder parsed accepted.1 order, advanced,
      object_seed_rows parsed accepted.1 accepted.2 order rows⟩

theorem specification_ready_same {calls : SpecificationCalls} {text : Source} {before after : SpecificationState}
    (step : specificationStep calls text before = .ready after) : before = after := by
  dsimp only [specificationStep] at step
  split at step
  · exact SpecificationStep.ready.inj step
  · split at step
    · dsimp only [specificationRoutine, continueSpecification] at step
      split at step <;> (try contradiction)
      split at step <;> contradiction
    · split at step
      · contradiction
      · split at step
        · dsimp only [specificationSubtype, appendExport, continueSpecification] at step
          split at step <;> (try contradiction)
          split at step <;> (try contradiction)
          split at step <;> contradiction
        · dsimp only [specificationObject, appendExport, continueSpecification] at step
          split at step <;> (try contradiction)
          split at step <;> contradiction

def specificationExitSeedRows (ranges : SharedRanges) : SpecificationExit → Prop
  | .returned _ => True
  | .ready final => FrameOrder final.exports ∧ ConstantRangeRows ranges final.exports.scalarNames

theorem SpecificationInventories.seed_rows {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before : SpecificationState} {rows : List SpecificationItem} {exit : SpecificationExit}
    (history : SpecificationInventories reader text before rows exit) {ranges : SharedRanges}
    (ordered : FrameOrder before.exports) (initial : ConstantRangeRows ranges before.exports.scalarNames) :
    specificationExitSeedRows (seedRanges ranges (specificationSeeds rows)) exit := by
  induction history generalizing ranges with
  | returned => trivial
  | ready step =>
    cases specification_ready_same step
    exact ⟨ordered, initial⟩
  | @next row rest exit step source history ih =>
    obtain ⟨nextOrder, _, nextRows⟩ := SpecificationSyntax.seed_rows source ordered initial
    have checked := ih nextOrder nextRows
    cases selected : row.inventory.seed <;>
      simpa only [specificationSeeds, List.filterMap_cons, selected, seedRanges, Option.toList,
        List.map_cons, List.map_nil, initializerDomains] using checked

end Silver.ApplicationPackageInitializers
