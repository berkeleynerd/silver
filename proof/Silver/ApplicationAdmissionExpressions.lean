module

public import Silver.ApplicationAdmissionNative

@[expose] public section

namespace Silver.ApplicationAdmission.Native
open ApplicationNative

abbrev sourceBundle : Expr Fn .bundle := .variable "sources"
abbrev sourceText : Expr Fn .source :=
  .sourcePrefix (.field .bundlePool sourceBundle) (.field .bundleUsed sourceBundle)
abbrev exports : Expr Fn .state := .variable "exports"
abbrev info : Expr Fn .metadata := .variable "info"
abbrev result : Expr Fn .analysis := .variable "result"
abbrev unitPrefix (kind : ApplicationUnits.UnitKind) : Expr Fn .source :=
  .app (.app (.function .prefix) sourceBundle) (.unitKind kind)

def sourceRejected : Expr Fn .truth :=
  .orElse (.not (.app (.function .sourcesValid) sourceBundle))
    (.not (.app (.function .allowedSource) sourceText))

def specificationRejected : Expr Fn .truth :=
  .orElse (.eq (.field .statePosition exports) (.number 0))
    (.not (.app (.app (.function .stateValid) (unitPrefix .packageBody)) exports))

def bodyRejected : Expr Fn .truth :=
  .orElse (.orElse (.not (.variable "accepted"))
      (.not (.app (.app (.function .completeMetadata) sourceText) info)))
    (.not (.app (.app (.function .stateValid) sourceText) exports))

def resultRejected : Expr Fn .truth :=
  .orElse (.orElse (.orElse (.orElse
      (.not (.field .analysisAccepted result))
      (.unitMapNe (.field .infoUnits (.field .analysisPackageInfo result)) (.field .bundleUnits sourceBundle)))
      (.not (.app (.app (.function .completeMetadata) sourceText) (.field .analysisPackageInfo result))))
      (.not (.app (.app (.function .functionsValid) sourceText) (.field .analysisMainFunctions result))))
      (.not (.app (.app (.function .proceduresValid) sourceText) (.field .analysisMainProcedures result)))

def analyzeBody : Body :=
  { name := "analyze_application"
    declarations := [
      ⟨.metadata, "info", some .emptyMetadata⟩,
      ⟨.state, "exports", none⟩,
      ⟨.number, "remaining", some .maxConcatenations⟩,
      ⟨.truth, "accepted", none⟩,
      ⟨.analysis, "result", none⟩]
    commands := .list [
      .choose sourceRejected (.returned .invalidAnalysis) .nothing,
      .forUnits "unit" (.list [
        .chargeUnit (.app (.function .normalized)
          (.app (.app (.function .unitSource) sourceBundle) (.variable "unit")))
          (.variable "remaining") (.variable "accepted"),
        .choose (.not (.variable "accepted")) (.returned .invalidAnalysis) .nothing]),
      .assign (.field .infoUnits (.variable "info")) (.field .bundleUnits sourceBundle),
      .packageSpecification (unitPrefix .packageSpecification) (.variable "info") (.variable "exports"),
      .choose specificationRejected (.returned .invalidAnalysis) .nothing,
      .packageBody (unitPrefix .packageBody) exports (.variable "info") (.variable "accepted"),
      .choose bodyRejected (.returned .invalidAnalysis) .nothing,
      .assign (.variable "result") (.app (.app (.app (.function .packageMain) sourceBundle) exports) info),
      .choose resultRejected (.returned .invalidAnalysis) .nothing,
      .returned result] }

def analyzeModelBody : Expr Fn .analysis := .app (.function .analyzeApplication) sourceBundle
def analyzeAliasBody : Expr Fn .analysis := .app (.function .analyzeApplication) sourceBundle
def memberBody : Expr Fn .truth := .field .analysisAccepted (.app (.function .analyzeModel) sourceBundle)
def acceptsBody : Expr Fn .truth := .field .analysisAccepted (.app (.function .analyze) sourceBundle)

abbrev CheckedTrees : Prop :=
  analyzeBody.wellFormed = true ∧ analyzeBody.scoped [(.bundle, "sources")] = true ∧
  analyzeModelBody.wellFormedRoot functionNames = true ∧
  analyzeAliasBody.wellFormedRoot functionNames = true ∧
  memberBody.wellFormedRoot functionNames = true ∧ acceptsBody.wellFormedRoot functionNames = true ∧
  analyzeModelBody.scoped [(.bundle, "sources")] = true ∧
  analyzeAliasBody.scoped [(.bundle, "sources")] = true ∧
  memberBody.scoped [(.bundle, "sources")] = true ∧ acceptsBody.scoped [(.bundle, "sources")] = true

theorem checked_trees : CheckedTrees := by decide +kernel

def modelFunctions (calls : ApplicationAdmission.Calls) : ApplicationNative.Calls Fn
  | _, .sourcesValid => fun sources => decide sources.Layout
  | _, .allowedSource => calls.allowedSource
  | _, .normalized => id
  | _, .unitSource => ApplicationUnits.Bundle.unitSource
  | _, .prefix => ApplicationUnits.Bundle.prefix
  | _, .stateValid => calls.stateValid
  | _, .completeMetadata => fun text info => PackageBindings.completeMetadata ⟨1, text⟩ info
  | _, .functionsValid => fun text functions => decide (FunctionBindings.ValidMetadata text functions)
  | _, .proceduresValid => fun text procedures => decide (ProcedureBindings.ValidMetadata text procedures)
  | _, .packageMain => calls.packageMain
  | _, .analyzeApplication => ApplicationAdmission.analyzeApplication calls
  | _, .analyzeModel => ApplicationAdmission.analyzeModel calls
  | _, .analyze => ApplicationAdmission.analyze calls

def modelCallees (calls : ApplicationAdmission.Calls) : Callees where
  function := modelFunctions calls
  chargeUnit := calls.chargeUnit
  packageSpecification := calls.packageSpecification
  packageBody := calls.packageBody

end Silver.ApplicationAdmission.Native
