module

public import Silver.ApplicationPackageUnitMetadata
public import Silver.ApplicationPackageSpecificationMetadataImports
public import Silver.ApplicationPackageMainBodyComposition
public import Silver.ApplicationAdmissionEquations

@[expose] public section

namespace Silver.ApplicationAdmission
open Compose Compose.Expressions ApplicationUnits ApplicationPackageDeclarations
open ApplicationPackageBodies

/-- Preserve the wrapper's source/budget interfaces while composing its original
Specification, Unit and Main readers. The source and budget imports are connected
separately; this definition is not an application safety certificate. -/
noncomputable def packageCalls (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) (main : ApplicationPackageMain.Calls)
    (other : Calls) : Calls :=
  {other with
    stateValid := ApplicationPackageFrames.stateValid
    packageSpecification := readSpecification reader
    packageBody := readBody reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
    packageMain := ApplicationPackageMain.packageMainAt main}

/-- Only Main differs between these wrappers. Its agreement is required at the
actual reached call, after both original guards; rejected paths require nothing
about an uncalled parser. -/
private theorem analyze_main_congr (calls : Calls)
    (left right : Bundle → ParserState → PackageBindings.Metadata → AnalysisResult)
    (sources : Bundle)
    (same : sources.Layout →
      let specification := calls.packageSpecification (sources.prefix .packageSpecification) {units := sources.units}
      let body := calls.packageBody (sources.prefix .packageBody) specification.exports specification.info
      calls.stateValid (sources.prefix .packageBody) specification.exports = true →
      body.accepted = true →
      PackageBindings.completeMetadata ⟨1, sources.pool.take sources.used⟩ body.info = true →
      calls.stateValid (sources.pool.take sources.used) specification.exports = true →
      left sources specification.exports body.info = right sources specification.exports body.info) :
    analyzeApplication {calls with packageMain := left} sources =
      analyzeApplication {calls with packageMain := right} sources := by
  have budgets (main : Bundle → ParserState → PackageBindings.Metadata → AnalysisResult) :
      chargeUnits {calls with packageMain := main} sources originalKinds maxConcatenations =
        chargeUnits calls sources originalKinds maxConcatenations := rfl
  simp only [analyzeApplication, budgets]
  split
  · rfl
  · rename_i entered
    have layout : sources.Layout := by
      have passed := Bool.eq_false_iff.mpr entered
      simp only [Bool.or_eq_false_iff, Bool.not_eq_false', decide_eq_true_eq] at passed
      exact passed.1
    cases charged : chargeUnits calls sources originalKinds maxConcatenations with
    | none => rfl
    | some remaining =>
      dsimp only
      split
      · rfl
      · rename_i specificationPassed
        have specificationGuard := Bool.eq_false_iff.mpr specificationPassed
        simp only [Bool.or_eq_false_iff, Bool.not_eq_false', decide_eq_false_iff_not] at specificationGuard
        split
        · rfl
        · rename_i bodyPassed
          have bodyGuard := Bool.eq_false_iff.mpr bodyPassed
          simp only [Bool.or_eq_false_iff, Bool.not_eq_false'] at bodyGuard
          rw [same layout specificationGuard.2 bodyGuard.1.1 bodyGuard.1.2 bodyGuard.2]

/-- The wrapper's Specification output and successful Unit result supply the
native Main component types. Its executable state and completion guards supply
the other Main preconditions; none is assumed as a successful semantic check. -/
theorem package_main_imports (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) (main : ApplicationPackageMain.BodyLibraries)
    (mainOther : ApplicationPackageMain.Calls) (other : Calls) (sources : Bundle)
    (represented : sources.Representable) :
    analyzeApplication (packageCalls library reader (main.calls mainOther) other) sources =
      analyzeApplication (packageCalls library reader (main.model mainOther) other) sources := by
  apply analyze_main_congr (packageCalls library reader mainOther other)
    (ApplicationPackageMain.packageMainAt (main.calls mainOther))
    (ApplicationPackageMain.packageMainAt (main.model mainOther)) sources
  intro layout
  dsimp only
  intro specificationValid accepted complete mainValid
  have valid : sources.Valid := ⟨represented, layout⟩
  have specified := readSpecification_typed reader
    (specification_prefix_valid sources valid .packageSpecification)
    {units := sources.units} (specification_seed_typed sources represented)
  have framed : ReaderFrame (sources.prefix .packageBody)
      (readSpecification reader (sources.prefix .packageSpecification) {units := sources.units}).exports :=
    ⟨specified.2.typed, specificationValid⟩
  have typed := readBody_accepted_typed library reader
    (specification_prefix_valid sources valid .packageBody) _ framed _ specified.1 accepted
  exact main.main_meaning mainOther valid _ ⟨specified.2.typed, mainValid⟩ _ typed complete

/-- Arbitrary wrapper scratch locals remain arbitrary. The typed native wrapper
and original callee domains now carry Main's full imported-reader equation. -/
theorem package_main_native (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) (main : ApplicationPackageMain.BodyLibraries)
    (mainOther : ApplicationPackageMain.Calls) (other : Calls) (locals : ApplicationNative.Locals)
    (represented : (locals .bundle "sources").Representable) :
    Native.analyzeBody.eval
      (Native.modelCallees (packageCalls library reader (main.calls mainOther) other)) locals =
      analyzeApplication (packageCalls library reader (main.model mainOther) other)
        (locals .bundle "sources") := by
  rw [Native.analyzeBody_meaning]
  exact package_main_imports library reader main mainOther other _ represented

end Silver.ApplicationAdmission
