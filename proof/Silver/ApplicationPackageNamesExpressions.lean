module

public import Silver.ApplicationNativeGuards

@[expose] public section

/-! Exact typed expressions for the package name readers. Callee symbols remain
arbitrary; their native source interpretations are established separately. -/
namespace Silver.ApplicationPackageNames.Native

open Compose ApplicationNative

inductive Function : Ty → Type
  | skip : Function (.arrow .source (.arrow .number .number))
  | nameAfter : Function (.arrow .source (.arrow .number .number))
  | takeToken : Function (.arrow .source (.arrow .number (.arrow .token .number)))
  | nameIs : Function (.arrow .source (.arrow .number (.arrow .number (.arrow .spelling .truth))))
  | forbidden : Function (.arrow .source (.arrow .number (.arrow .number .truth)))
  | validName : Function (.arrow .source (.arrow .nameSpan .truth))
  | sameName : Function (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | lookupExport : Function (.arrow .source (.arrow .metadata (.arrow .nameSpan .number)))
  | lookupState : Function (.arrow .source (.arrow .metadata (.arrow .nameSpan .number)))
  | functionType : Function (.arrow .source (.arrow .state (.arrow .number .functionType)))

def functionNames : FunctionNames Function
  | _, .skip => ["skip_at"] | _, .nameAfter => ["name_after"] | _, .takeToken => ["take_token"]
  | _, .nameIs => ["name_is"] | _, .forbidden => ["forbidden_name"]
  | _, .validName => ["packages", ".", "valid_name"] | _, .sameName => ["packages", ".", "same_name"]
  | _, .lookupExport => ["packages", ".", "lookup_export"] | _, .lookupState => ["packages", ".", "lookup_state"]
  | _, .functionType => ["function_type_at"]

structure Calls where
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  takeToken : Source → Nat → ShellToken → Nat
  nameIs : Source → Nat → Nat → String → Bool
  forbidden : Source → Nat → Nat → Bool
  validName : Source → PackageBindings.NameSpan → Bool
  sameName : Source → PackageBindings.NameSpan → PackageBindings.NameSpan → Bool
  lookupExport : Source → PackageBindings.Metadata → PackageBindings.NameSpan → Nat
  lookupState : Source → PackageBindings.Metadata → PackageBindings.NameSpan → Nat
  functionType : Source → ParserState → Nat → FunctionTypeResult

def Calls.get (calls : Calls) : ApplicationNative.Calls Function
  | _, .skip => calls.skip | _, .nameAfter => calls.nameAfter | _, .takeToken => calls.takeToken
  | _, .nameIs => calls.nameIs | _, .forbidden => calls.forbidden | _, .validName => calls.validName
  | _, .sameName => calls.sameName | _, .lookupExport => calls.lookupExport | _, .lookupState => calls.lookupState
  | _, .functionType => calls.functionType

abbrev E := Expr Function

def apply2 (fn : Function (.arrow a (.arrow b c))) (x : E a) (y : E b) : E c :=
  .app (.app (.function fn) x) y

def apply3 (fn : Function (.arrow a (.arrow b (.arrow c d)))) (x : E a) (y : E b) (z : E c) : E d :=
  .app (.app (.app (.function fn) x) y) z

def apply4 (fn : Function (.arrow a (.arrow b (.arrow c (.arrow d e)))))
    (w : E a) (x : E b) (y : E c) (z : E d) : E e :=
  .app (.app (.app (.app (.function fn) w) x) y) z

def conjunction : List (E .truth) → E .truth
  | [] => .truth true
  | first :: rest => rest.foldl .andThen first

def text : E .source := .variable "text"
def info : E .metadata := .variable "info"
def name : E .nameSpan := .variable "name"
def position : E .number := .variable "position"
def frame : E .state := .variable "frame"
def first : E .number := .variable "first"
def after : E .number := .variable "after"
def last : E .number := .variable "last"
def value : E .functionType := .variable "value"
def exportId : E .number := .variable "export"

def nameAllowedBody : E .truth := conjunction
  ([apply2 .validName text name,
    .not (apply3 .forbidden text (.field .nameFirst name) (.field .nameAfter name))] ++
    ["main", "ada", "interfaces", "system", "gnat", "silver_arguments", "silver_output_libc",
      "silver_runtime",
      "boolean", "false", "true", "integer",
      "natural", "positive", "short_short_integer", "short_integer",
      "long_integer", "long_long_integer", "long_long_long_integer", "short_float",
      "float", "long_float", "long_long_float", "character",
      "wide_character", "wide_wide_character", "string", "wide_string",
      "wide_wide_string", "duration", "constraint_error", "program_error",
      "storage_error", "tasking_error", "numeric_error", "ascii"].map (fun word =>
        .not (apply4 .nameIs text (.field .nameFirst name) (.field .nameAfter name) (.word word))))

def nameFreshBody : E .truth := conjunction
  [apply2 .validName text name,
   .not (apply3 .forbidden text (.field .nameFirst name) (.field .nameAfter name)),
   .not (apply3 .sameName text name (.nameSpan (.field .infoNameFirst info) (.field .infoNameAfter info))),
   .eq (apply3 .lookupExport text info name) (.number 0),
   .eq (apply3 .lookupState text info name) (.number 0),
   .group (.forAll "i" (.number 1) (.field .routineCount info)
     (.not (apply3 .sameName text name (.field .routineSpecName (.index .routine info (.variable "i"))))))]

def outerDeclarationBody : E .truth := .orElse
  (.group (.forSome "i" (.number 1) (.field .exportCount info)
    (.nameEq (.field .exportName (.index .export info (.variable "i"))) name)))
  (.group (.forSome "i" (.number 1) (.field .stateCount info)
    (.nameEq (.field .declarationName (.index .state info (.variable "i"))) name)))

def packageWordResult : E .number := .group (.ite
  (conjunction [.ne first (.number 0), .gt after first,
    apply4 .nameIs text first after (.variable "word")]) after (.number 0))

def sparkPragmaResult : E .number :=
  apply3 .takeToken text
    (apply3 .takeToken text
      (apply3 .takeToken text
        (apply3 .takeToken text
          (apply3 .takeToken text
            (apply3 .takeToken text position (.token (.word "pragma")))
            (.token (.word "spark_mode")))
          (.token (.symbol "(")))
        (.token (.word "on")))
      (.token (.symbol ")")))
    (.token (.symbol ";"))

def typeRejected : E .truth := .orElse
  (.not (apply2 .validName text (.nameSpan first last)))
  (.ne (.field .typeAfter value) last)

def typeBoolean : E .truth := .kindEq (.field .typeKind value) (.scalarKind .boolean)
def typeInteger : E .truth := apply4 .nameIs text first last (.word "integer")
def typeExport : E .truth := .andThen (.ne exportId (.number 0))
  (.exportEq (.field .exportKind (.index .export info exportId)) (.exportKind .integerSubtype))

def typeResult (bounds : E .interval) (identity : E .number) : E .packageType :=
  .packageType (.nameSpan first last) last (.field .typeKind value) bounds identity

structure Inputs where
  text : Source := []
  info : PackageBindings.Metadata := {}
  name : PackageBindings.NameSpan := {}
  position : Nat := 0
  frame : ParserState := invalidState
  word : String := ""
  first : Nat := 0
  after : Nat := 0
  last : Nat := 0
  value : FunctionTypeResult := ⟨0,.integer,.empty,0⟩
  exportId : Nat := 0

def Inputs.locals (inputs : Inputs) : Locals
  | .source, "text" => inputs.text | .metadata, "info" => inputs.info | .nameSpan, "name" => inputs.name
  | .number, "position" => inputs.position | .state, "frame" => inputs.frame | .spelling, "word" => inputs.word
  | .number, "first" => inputs.first | .number, "after" => inputs.after | .number, "last" => inputs.last
  | .functionType, "value" => inputs.value | .number, "export" => inputs.exportId
  | ty, _ => ty.default

abbrev WellFormedTrees : Prop :=
  nameAllowedBody.wellFormedRoot functionNames = true ∧
  nameFreshBody.wellFormedRoot functionNames = true ∧
  outerDeclarationBody.wellFormedRoot functionNames = true ∧
  packageWordResult.wellFormedRoot functionNames = true ∧
  sparkPragmaResult.wellFormedRoot functionNames = true ∧
  typeRejected.wellFormedRoot functionNames = true ∧ typeBoolean.wellFormedRoot functionNames = true ∧
  typeInteger.wellFormedRoot functionNames = true ∧ typeExport.wellFormedRoot functionNames = true ∧
  (typeResult .full .booleanType).wellFormedRoot functionNames = true ∧
  (typeResult (.field .typeBounds value) .integerType).wellFormedRoot functionNames = true ∧
  (typeResult (.field .typeBounds value) (.add exportId (.number 1))).wellFormedRoot functionNames = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

abbrev WellScopedTrees : Prop :=
  nameAllowedBody.scoped [(.source,"text"),(.nameSpan,"name")] = true ∧
  nameFreshBody.scoped [(.source,"text"),(.metadata,"info"),(.nameSpan,"name")] = true ∧
  outerDeclarationBody.scoped [(.metadata,"info"),(.nameSpan,"name")] = true ∧
  packageWordResult.scoped [(.source,"text"),(.number,"first"),(.number,"after"),(.spelling,"word")] = true ∧
  sparkPragmaResult.scoped [(.source,"text"),(.number,"position")] = true

theorem checked_scopes : WellScopedTrees := by decide +kernel

end Silver.ApplicationPackageNames.Native
