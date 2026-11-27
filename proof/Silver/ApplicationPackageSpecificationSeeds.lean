module

public import Silver.ApplicationPackageConstantSeeds

@[expose] public section

namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate Packages ApplicationPackageDeclarations ApplicationPackageObjectRows

def objectConstantSeed (out : ObjectResult) : ConstantSeed :=
  match out.mark.kind with
  | .integer => .integer out.name.first out.initialBounds.lower
  | .boolean => .boolean out.name.first out.booleanValue

def SpecificationSyntax.seed : SpecificationSyntax → Option ConstantSeed
  | .routine | .subtype _ => none
  | .object out _ => some (objectConstantSeed out)

def specificationSeeds (rows : List SpecificationItem) : List ConstantSeed :=
  rows.filterMap fun row => row.inventory.seed

theorem specification_object_present {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before after : SpecificationState} {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls reader) text before.exports before.info false = out)
    (accepted : specificationObject (modelSpecificationCalls reader) text before = .next after) :
    out.frame.position ≠ 0 ∧ out.constantObject = true := by
  dsimp only [specificationObject, modelSpecificationCalls] at accepted
  simp only [parsed] at accepted
  split at accepted
  · contradiction
  · rename_i admitted
    have fields : (decide (out.frame.position = 0) || !out.constantObject) = false :=
      Bool.eq_false_iff.mpr admitted
    simpa only [Bool.or_eq_false_iff, decide_eq_false_iff_not, Bool.not_eq_false'] using fields

theorem objectConstantSeed_valid {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : PackageBindings.Metadata} {out : ObjectResult}
    (framed : ReaderFrame text frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info false = out)
    (present : out.frame.position ≠ 0) : (objectConstantSeed out).Valid := by
  have calls := object_value_calls reader text frame framed info false (parsed ▸ present)
  rw [parsed] at calls
  cases kind : out.mark.kind with
  | integer =>
    obtain ⟨_, _, inferred, _, _, _⟩ := calls.scalar_inventory kind
    simpa only [objectConstantSeed, kind, ConstantSeed.Valid] using
      (Integer.Expr.infer_bounded inferred).1
  | boolean => simp only [objectConstantSeed, kind, ConstantSeed.Valid]

theorem SpecificationSyntax.seed_valid {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before after : SpecificationState} {inventorySyntax : SpecificationSyntax} {seed : ConstantSeed}
    (source : inventorySyntax.SourceAt reader text before after) (framed : ReaderFrame text before.exports)
    (selected : inventorySyntax.seed = some seed) : seed.Valid := by
  cases inventorySyntax with
  | routine | subtype => cases selected
  | object out inventory =>
    cases Option.some.inj selected
    exact objectConstantSeed_valid framed source.2.1 (specification_object_present source.2.1 source.1).1

/-- Source order selects every immutable value object from the original
specification. The complete raw inventory (including subtype/range arithmetic)
is retained independently; this theorem only constructs the loading prefix. -/
theorem SpecificationInventories.seeds_valid {reader : BooleanElaboration.Native.Reader} {text : Source}
    (textValid : ValidText text) {before : SpecificationState} {rows : List SpecificationItem} {exit : SpecificationExit}
    (history : SpecificationInventories reader text before rows exit) (framed : ReaderFrame text before.exports) :
    ∀ seed ∈ specificationSeeds rows, seed.Valid := by
  induction history with
  | returned | ready => simp [specificationSeeds]
  | @next row rows exit step source rest ih =>
    have nextFrame : ReaderFrame text row.after.exports := by
      have preserved := specification_step_framed reader textValid row.before framed
      rw [step] at preserved
      exact preserved
    intro seed member
    simp only [specificationSeeds, List.filterMap_cons] at member
    cases selected : row.inventory.seed with
    | none =>
      simp only [selected] at member
      exact ih nextFrame seed member
    | some first =>
      simp only [selected, List.mem_cons] at member
      rcases member with rfl | later
      · exact SpecificationSyntax.seed_valid source framed selected
      · exact ih nextFrame seed later

theorem SpecificationInventories.seeds_checked {reader : BooleanElaboration.Native.Reader} {text : Source}
    (textValid : ValidText text) {before : SpecificationState} {rows : List SpecificationItem} {exit : SpecificationExit}
    (history : SpecificationInventories reader text before rows exit) (framed : ReaderFrame text before.exports)
    (entry : SharedRanges) :
    checkInitializers entry ((specificationSeeds rows).map ConstantSeed.initializer) =
      some (initializerDomains entry ((specificationSeeds rows).map ConstantSeed.initializer)) :=
  constant_seeds_check _ entry (history.seeds_valid textValid framed)

/-- The Boolean load has the original static initializer's value under every
scalar-fitting and known-Boolean-fitting store. The reader library and source
checks are the actual original evaluator, including all its recursive calls. -/
theorem object_boolean_constant_seed {objects : ObjectLibraries}
    (library : BooleanElaboration.Native.SourceImports.Library objects)
    {tokens : List String} (checked : BooleanElaboration.Native.SourceChecks.Checked tokens)
    (text : Source) (textValid : ValidText text) (frame : ParserState)
    (framed : ReaderFrame text frame) (info : PackageBindings.Metadata)
    (present : (objectStep (modelObjectCalls library.condition) text frame info false).frame.position ≠ 0)
    (kind : (objectStep (modelObjectCalls library.condition) text frame info false).mark.kind = .boolean) :
    let out := objectStep (modelObjectCalls library.condition) text frame info false
    let base := initializerBase text frame info (objectName text frame) false
    ∃ expression,
      BooleanElaboration.Native.ExpressionAt text base .condition out.initFirst expression out.initAfter ∧
      (∀ integers flags, Integer.Fits (ScalarExpression.ranges base.scalarNames) integers →
        BooleanBindings.KnownFits base.booleanNames flags → ∀ values input inputValid,
        ScalarFunctions.Value.boolean (expression.evaluate values input inputValid integers flags) =
          (objectConstantSeed out).value) := by
  obtain ⟨expression, source, value⟩ := object_global_boolean_exact library checked text textValid frame framed info present kind
  refine ⟨expression, source, ?_⟩
  intro integers flags fitting known values input inputValid
  simpa only [objectConstantSeed, kind, ConstantSeed.value] using
    congrArg ScalarFunctions.Value.boolean (value integers flags fitting known values input inputValid)

end Silver.ApplicationPackageInitializers
