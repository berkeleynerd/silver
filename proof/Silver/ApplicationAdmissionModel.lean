module

public import Silver.ApplicationUnitsEquations
public import Silver.PackageBindings
public import Silver.PredicateBodyScanner

@[expose] public section

/-! Raw application-wrapper equations preserve original unit boundaries and
every native failure return. Subreader calls are explicit parameters until the
actual-source companion binds them to their separately checked native bodies.
These equations and acceptance postconditions do not assume or establish
subreader correctness, language safety or original-Bundle source meaning. -/
namespace Silver.ApplicationAdmission
open Compose
open ApplicationUnits (Bundle UnitKind)

structure AnalysisResult where
  accepted : Bool := false
  packageInfo : PackageBindings.Metadata := {}
  mainFunctions : FunctionBindings.Metadata := {}
  mainProcedures : ProcedureBindings.Metadata := {}
  usesArguments : Bool := false
  usesAssignment : Bool := false
  usesOutput : Bool := false

def invalidAnalysis : AnalysisResult := {}

structure ChargeResult where
  remaining : Nat
  accepted : Bool

structure SpecificationResult where
  info : PackageBindings.Metadata
  exports : ParserState

structure BodyResult where
  info : PackageBindings.Metadata
  accepted : Bool

structure Calls where
  allowedSource : Source → Bool
  chargeUnit : Source → Nat → ChargeResult
  stateValid : Source → ParserState → Bool
  packageSpecification : Source → PackageBindings.Metadata → SpecificationResult
  packageBody : Source → ParserState → PackageBindings.Metadata → BodyResult
  packageMain : Bundle → ParserState → PackageBindings.Metadata → AnalysisResult

def originalKinds : List UnitKind := [.packageSpecification, .packageBody, .mainBody]

def chargeUnits (calls : Calls) (sources : Bundle) : List UnitKind → Nat → Option Nat
  | [], remaining => some remaining
  | kind :: rest, remaining =>
      let charged := calls.chargeUnit (sources.unitSource kind) remaining
      if charged.accepted then chargeUnits calls sources rest charged.remaining else none

def unitsEqual (left right : UnitKind → ApplicationUnits.Span) : Bool :=
  decide (left .packageSpecification = right .packageSpecification ∧
    left .packageBody = right .packageBody ∧ left .mainBody = right .mainBody)

theorem unitsEqual_iff (left right : UnitKind → ApplicationUnits.Span) :
    unitsEqual left right = true ↔ left = right := by
  simp only [unitsEqual, decide_eq_true_eq]
  constructor
  · intro values
    funext kind
    cases kind
    · exact values.1
    · exact values.2.1
    · exact values.2.2
  · intro same
    subst right
    exact ⟨rfl, rfl, rfl⟩

def resultValid (sources : Bundle) (result : AnalysisResult) : Bool :=
  result.accepted && unitsEqual result.packageInfo.units sources.units &&
    PackageBindings.completeMetadata ⟨1, sources.pool.take sources.used⟩ result.packageInfo &&
    decide (FunctionBindings.ValidMetadata (sources.pool.take sources.used) result.mainFunctions) &&
    decide (ProcedureBindings.ValidMetadata (sources.pool.take sources.used) result.mainProcedures)

def analyzeApplication (calls : Calls) (sources : Bundle) : AnalysisResult :=
  let text := sources.pool.take sources.used
  if !(decide sources.Layout) || !calls.allowedSource text then invalidAnalysis
  else
    match chargeUnits calls sources originalKinds maxConcatenations with
    | none => invalidAnalysis
    | some _ =>
        let specification := calls.packageSpecification (sources.prefix .packageSpecification) {units := sources.units}
        if specification.exports.position = 0 ||
            !calls.stateValid (sources.prefix .packageBody) specification.exports then invalidAnalysis
        else
          let body := calls.packageBody (sources.prefix .packageBody) specification.exports specification.info
          if !body.accepted || !PackageBindings.completeMetadata ⟨1, text⟩ body.info ||
              !calls.stateValid text specification.exports then invalidAnalysis
          else
            let result := calls.packageMain sources specification.exports body.info
            if resultValid sources result then result else invalidAnalysis

def analyzeModel (calls : Calls) (sources : Bundle) : AnalysisResult := analyzeApplication calls sources
def analyze (calls : Calls) (sources : Bundle) : AnalysisResult := analyzeApplication calls sources
def isApplicationMember (calls : Calls) (sources : Bundle) : Bool := (analyzeModel calls sources).accepted
def acceptsApplication (calls : Calls) (sources : Bundle) : Bool := (analyze calls sources).accepted

theorem acceptsApplication_eq_member (calls : Calls) (sources : Bundle) :
    acceptsApplication calls sources = isApplicationMember calls sources := rfl

structure AcceptedTrace (calls : Calls) (sources : Bundle) (result : AnalysisResult) : Prop where
  layout : sources.Layout
  alphabet : calls.allowedSource (sources.pool.take sources.used) = true
  budget : ∃ remaining, chargeUnits calls sources originalKinds maxConcatenations = some remaining
  readers : ∃ specification body,
    calls.packageSpecification (sources.prefix .packageSpecification) {units := sources.units} = specification ∧
    specification.exports.position ≠ 0 ∧
    calls.stateValid (sources.prefix .packageBody) specification.exports = true ∧
    calls.packageBody (sources.prefix .packageBody) specification.exports specification.info = body ∧
    body.accepted = true ∧ PackageBindings.completeMetadata ⟨1, sources.pool.take sources.used⟩ body.info = true ∧
    calls.stateValid (sources.pool.take sources.used) specification.exports = true ∧
    calls.packageMain sources specification.exports body.info = result ∧ resultValid sources result = true

theorem analyzeApplication_trace {calls : Calls} {sources : Bundle}
    (accepted : (analyzeApplication calls sources).accepted = true) :
    AcceptedTrace calls sources (analyzeApplication calls sources) := by
  generalize completed : analyzeApplication calls sources = result at accepted ⊢
  dsimp only [analyzeApplication] at completed
  split at completed
  · subst result
    simp only [invalidAnalysis, Bool.false_eq_true] at accepted
  · rename_i sourceRejected
    split at completed
    · subst result
      simp only [invalidAnalysis, Bool.false_eq_true] at accepted
    · rename_i remaining charged
      split at completed
      · subst result
        simp only [invalidAnalysis, Bool.false_eq_true] at accepted
      · rename_i specificationRejected
        split at completed
        · subst result
          simp only [invalidAnalysis, Bool.false_eq_true] at accepted
        · rename_i bodyRejected
          split at completed
          · rename_i finalAccepted
            subst result
            have sourceAccepted := Bool.eq_false_iff.mpr sourceRejected
            have specificationAccepted := Bool.eq_false_iff.mpr specificationRejected
            have bodyAccepted := Bool.eq_false_iff.mpr bodyRejected
            simp only [Bool.or_eq_false_iff, Bool.not_eq_false', decide_eq_true_eq] at sourceAccepted
            simp only [Bool.or_eq_false_iff, Bool.not_eq_false', decide_eq_false_iff_not] at specificationAccepted
            simp only [Bool.or_eq_false_iff, Bool.not_eq_false'] at bodyAccepted
            exact ⟨sourceAccepted.1, sourceAccepted.2, ⟨remaining, charged⟩,
              _, _, rfl, specificationAccepted.1, specificationAccepted.2,
              rfl, bodyAccepted.1.1, bodyAccepted.1.2, bodyAccepted.2, rfl, finalAccepted⟩
          · subst result
            simp only [invalidAnalysis, Bool.false_eq_true] at accepted

theorem analyzeApplication_post {calls : Calls} {sources : Bundle}
    (represented : sources.Representable) (accepted : (analyzeApplication calls sources).accepted = true) :
    sources.Valid ∧ (analyzeApplication calls sources).packageInfo.units = sources.units ∧
      PackageBindings.completeMetadata ⟨1, sources.pool.take sources.used⟩
        (analyzeApplication calls sources).packageInfo = true ∧
      FunctionBindings.ValidMetadata (sources.pool.take sources.used) (analyzeApplication calls sources).mainFunctions ∧
      ProcedureBindings.ValidMetadata (sources.pool.take sources.used) (analyzeApplication calls sources).mainProcedures := by
  have trace := analyzeApplication_trace accepted
  obtain ⟨specification, body, _, _, _, _, _, _, _, _, valid⟩ := trace.readers
  simp only [resultValid, Bool.and_eq_true, decide_eq_true_eq, unitsEqual_iff] at valid
  exact ⟨⟨represented, trace.layout⟩, valid.1.1.1.2, valid.1.1.2, valid.1.2, valid.2⟩

end Silver.ApplicationAdmission
