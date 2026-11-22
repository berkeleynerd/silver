module

public import Silver.ApplicationPackageMainNative

@[expose] public section

namespace Silver.ApplicationPackageMain.Native
open ApplicationNative

abbrev sourceBundle : Expr Fn .bundle := .variable "sources"
abbrev sourceText : Expr Fn .source := .variable "text"
abbrev exports : Expr Fn .state := .variable "exports"
abbrev info : Expr Fn .metadata := .variable "info"
abbrev frame : Expr Fn .state := .variable "frame"
abbrev contextClausesValue : Expr Fn .contextClauses := .variable "context_clauses"
abbrev argumentsWith : Expr Fn .truth := .field .contextArgumentsWith contextClausesValue
abbrev result : Expr Fn .appScan := .variable "result"
abbrev mainScan : Expr Fn .scanResult := .scanResult frame (.field .stateAssignedInFunctions frame) (.truth false)

abbrev take (position : Expr Fn .number) (token : Compose.ShellToken) : Expr Fn .number :=
  .app (.app (.app (.function .takeToken) sourceText) position) (.token token)

def mainDeclarations : List Declaration := [
  ⟨.string, ["text"], true, some (.sourcePrefix (.field .bundlePool sourceBundle) (.field .bundleUsed sourceBundle))⟩,
  ⟨.string, ["imported"], true, some (.app (.function .importedPackage)
    (.app (.app (.function .unitSource) sourceBundle) (.unitKind .mainBody)))⟩,
  ⟨.contextClauses, ["context_clauses"], true, some
    (.app (.app (.app (.app (.function .readContext) sourceText)
      (.field .unitFirst (.index .bundleUnit sourceBundle (.unitKind .mainBody))))
      (.field .infoNameFirst info)) (.field .infoNameAfter info))⟩,
  ⟨.parserState, ["frame"], false, none⟩,
  ⟨.position, ["start", "following"], false, none⟩]

def bodyDeclarations : List Declaration := [
  ⟨.bodyContext, ["context"], true, some (.app (.function .contextOf) mainScan)⟩,
  ⟨.applicationScan, ["result"], true, some
    (.app (.app (.app (.app (.app (.app (.app (.app (.function .applicationTail)
      sourceText) (.variable "context"))
      (.app (.function .applicationOf) (.app (.function .bodyOf) mainScan))) info)
      (.bodyStop .endOnly)) (.truth true)) (.field .stateFunctions frame)) (.field .stateProcedures frame))⟩]

def importedRejected : Expr Fn .truth :=
  .orElse (.not (.app (.app (.app (.function .samePackageSpelling) sourceText) info) (.variable "imported")))
    (.eq (.field .contextAfter contextClausesValue) (.number 0))

def footerRejected : Expr Fn .truth :=
  .orElse (.orElse (.eq (.variable "following") (.number 0))
    (.ne (.app (.app (.function .skipAt) sourceText) (.variable "following"))
      (.add (.sourceLast sourceText) (.number 1))))
    (.not (.app (.function .completed) (.field .activeFlowPath (.field .scanFacts (.field .applicationScan result)))))

def mainBody : Body :=
  {name := "package_main_at", declarations := mainDeclarations,
    commands := .list [
      .choose importedRejected (.returned .invalidAnalysis) .nothing,
      .assign (.variable "start") (.app (.app (.function .sparkPragmaAfter) sourceText)
        (take (take (take (.field .contextAfter contextClausesValue) (.word "procedure")) (.word "main")) (.word "is"))),
      .choose (.eq (.variable "start") (.number 0)) (.returned .invalidAnalysis) .nothing,
      .assign (.variable "frame") (.app (.app (.app (.app (.function .importedFrame) sourceText) exports) info) (.variable "start")),
      .choose argumentsWith
        (.assign (.variable "frame") (.app (.app (.function .argumentAt) sourceText) frame)) .nothing,
      .choose (.eq (.field .statePosition frame) (.number 0)) (.returned .invalidAnalysis) .nothing,
      .assign (.variable "frame") (.app (.app (.app (.function .readDeclarations) sourceText) frame) argumentsWith),
      .assign (.field .statePosition (.variable "frame")) (take (.field .statePosition frame) (.word "begin")),
      .choose (.eq (.field .statePosition frame) (.number 0)) (.returned .invalidAnalysis) .nothing,
      .block bodyDeclarations (.list [
        .assign (.variable "following")
          (take (take (take (.field .scanPosition (.field .applicationScan result)) (.word "end")) (.word "main")) (.symbol ";")),
        .choose footerRejected (.returned .invalidAnalysis) .nothing,
        .returned (.analysisValue (.truth true) info (.field .stateFunctions frame) (.field .stateProcedures frame)
          argumentsWith (.field .scanAssigned (.field .applicationScan result)) (.field .scanOutput (.field .applicationScan result)))]) ]}

abbrev CheckedTree : Prop :=
  mainBody.wellFormed = true ∧
    mainBody.scoped [(.bundle, "sources"), (.state, "exports"), (.metadata, "info")] = true

theorem checked_tree : CheckedTree := by decide +kernel

end Silver.ApplicationPackageMain.Native
