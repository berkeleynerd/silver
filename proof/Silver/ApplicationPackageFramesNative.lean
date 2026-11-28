module

public import Silver.ApplicationNativeCommands
public import Silver.ApplicationPackageFrameValidity

@[expose] public section

/-! Typed imperative trees for the two frame transformations. Every assignment,
range loop, early return and native loop invariant appears in the rendering.
The companion interpretation and source modules supply the two separate links
from these trees to their model and to the authoritative implementation. -/
namespace Silver.ApplicationPackageFrames.Native
open ApplicationNative Compose

inductive Function : Ty → Type
  | validState : Function (.arrow .source (.arrow .state .truth))
  | forbiddenName : Function (.arrow .source (.arrow .number (.arrow .number .truth)))
  | equalName : Function (.arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth)))))
  | sameName : Function (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | outerDeclaration : Function (.arrow .metadata (.arrow .nameSpan .truth))
  | hideName : Function (.arrow .source (.arrow .hiding (.arrow .number (.arrow .number .hiding))))

def functionNames : FunctionNames Function
  | _, .validState => ["valid_state"]
  | _, .forbiddenName => ["forbidden_name"]
  | _, .equalName => ["equal_name"]
  | _, .sameName => ["packages", ".", "same_name"]
  | _, .outerDeclaration => ["outer_declaration"]
  | _, .hideName => ["hide_name"]

def modelCalls : Calls Function
  | _, .validState => stateValid
  | _, .forbiddenName => Named.forbiddenName
  | _, .equalName => Named.equalName
  | _, .sameName => fun text => PackageBindings.sameName (ApplicationPackageNames.metadataText text)
  | _, .outerDeclaration => ApplicationPackageNames.outerDeclaration
  | _, .hideName => Compose.hideName

abbrev E := Expr Function
abbrev P := Place Function
abbrev C := Command Function .state

def text : E .source := .variable "text"
def info : E .metadata := .variable "info"
def result : P .state := .variable "result"
def frame : E .state := .variable "frame"
def name : E .nameSpan := .variable "name"

def finalState : C := .sequence
  (.choose (.not (.app (.app (.function .validState) text) result.expression))
    (.returned .invalidState) .nothing)
  (.returned result.expression)

def qualifyBody (table : Field .state tableTy)
    (item : Index tableTy .number itemTy)
    (first after : Field itemTy .number) : C :=
  let selected : P itemTy := .index item (.field table result) (.variable "i")
  .sequence (.assign (.field first selected) (.field .infoNameFirst info))
    (.assign (.field after selected) (.field .infoNameAfter info))

def qualifyLoop (table : Field .state tableTy) (count : Field tableTy .number)
    (item : Index tableTy .number itemTy)
    (first after : Field itemTy .number) : C :=
  .forRange "i" (.number 1) (.field count (.field table result.expression))
    (qualifyBody table item first after)

def importedFrameBody : Body Function .state :=
  { name := "imported_frame"
    declarations := [⟨.state, "result", ["parser_state"], false,
      some (.update (.variable "exports")
        (.more .statePosition (.variable "position")
          (.more .stateContextFirst (.field .unitFirst (.index .unit info (.unitKind .mainBody)))
            (.more .statePackageFirst (.field .infoNameFirst info)
              (.more .statePackageAfter (.field .infoNameAfter info)
                (.more .statePure (.truth false) (.one .stateHiding .noHidden))))))), [], none⟩]
    commands := .list [
      qualifyLoop .stateScalarNames .scalarCount .scalar .scalarQualifierFirst .scalarQualifierAfter,
      qualifyLoop .stateBooleanNames .booleanCount .boolean .booleanQualifierFirst .booleanQualifierAfter,
      qualifyLoop .stateSubtypeNames .subtypeCount .subtype .subtypeQualifierFirst .subtypeQualifierAfter,
      .assign (.field .subtypesHiddenCalls (.field .stateSubtypeNames result)) .noCalls,
      .assign (.field .subtypesTrueHidden (.field .stateSubtypeNames result)) (.truth false),
      .assign (.field .subtypesFalseHidden (.field .stateSubtypeNames result)) (.truth false),
      finalState] }

def filterBody (table : Field .state tableTy)
    (item : Index tableTy .number itemTy)
    (first after qualifier : Field itemTy .number) (kept : String) : C :=
  let selected : E itemTy := .index item (.field table frame) (.variable "i")
  let selectedName : E .nameSpan := .nameSpan (.field first selected) (.field after selected)
  let matched : E .truth := .andThen (.eq (.field qualifier selected) (.number 0))
    (.app (.app (.app (.app (.app (.function .equalName) text)
      (.field .nameFirst name)) (.field .nameAfter name)) (.field first selected)) (.field after selected))
  .sequence (.invariant (.lt (.variable kept) (.variable "i"))) <|
      .choose matched
        (.choose (.not (.app (.app (.function .outerDeclaration) info) selectedName))
          (.returned .invalidState) .nothing)
        (.sequence (.assign (.variable kept) (.add (.variable kept) (.number 1)))
          (.assign (.index item (.field table result) (.variable kept)) selected))

def filterLoop (table : Field .state tableTy) (count : Field tableTy .number)
    (item : Index tableTy .number itemTy)
    (first after qualifier : Field itemTy .number) (kept : String) : C :=
  .forRange "i" (.number 1) (.field count (.field table frame))
    (filterBody table item first after qualifier kept)

def hideOuterBody : Body Function .state :=
  { name := "hide_outer"
    declarations := [⟨.state, "result", ["parser_state"], false, some frame, [], none⟩,
      ⟨.number, "scalars_kept", ["scalar_expressions", ".", "binding_count"], false, some (.number 0), [], none⟩,
      ⟨.number, "booleans_kept", ["boolean_count"], false, some (.number 0), [], none⟩,
      ⟨.number, "subtypes_kept", ["subtype_count"], false, some (.number 0), [], none⟩]
    commands := .list [
      .choose (.orElse
        (.app (.app (.app (.function .forbiddenName) text) (.field .nameFirst name)) (.field .nameAfter name))
        (.app (.app (.app (.function .sameName) text) name)
          (.nameSpan (.field .infoNameFirst info) (.field .infoNameAfter info))))
        (.returned .invalidState) .nothing,
      filterLoop .stateScalarNames .scalarCount .scalar .scalarFirst .scalarAfter .scalarQualifierFirst "scalars_kept",
      filterLoop .stateBooleanNames .booleanCount .boolean .booleanFirst .booleanAfter .booleanQualifierFirst "booleans_kept",
      filterLoop .stateSubtypeNames .subtypeCount .subtype .subtypeFirst .subtypeAfter .subtypeQualifierFirst "subtypes_kept",
      .assign (.field .scalarCount (.field .stateScalarNames result)) (.variable "scalars_kept"),
      .assign (.field .booleanCount (.field .stateBooleanNames result)) (.variable "booleans_kept"),
      .assign (.field .subtypeCount (.field .stateSubtypeNames result)) (.variable "subtypes_kept"),
      .assign (.field .stateHiding result)
        (.app (.app (.app (.app (.function .hideName) text) (.field .stateHiding result.expression))
          (.field .nameFirst name)) (.field .nameAfter name)),
      finalState] }

def importedScope : Scope := [(.source, "text"), (.state, "exports"), (.metadata, "info"), (.number, "position")]
def hideScope : Scope := [(.source, "text"), (.state, "frame"), (.metadata, "info"), (.nameSpan, "name")]

theorem frameTrees_wellFormed :
    importedFrameBody.wellFormed functionNames = true ∧ importedFrameBody.scoped importedScope = true ∧
    hideOuterBody.wellFormed functionNames = true ∧ hideOuterBody.scoped hideScope = true := by
  decide +kernel

end Silver.ApplicationPackageFrames.Native
