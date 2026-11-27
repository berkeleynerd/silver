module

public import Silver.ApplicationPackageImportControl

@[expose] public section

namespace Silver.ApplicationPackageImport.Native
open Compose ApplicationNative Control

inductive Function : Ty → Type
  | normalize : Function (.arrow .source .source)
  | skip : Function (.arrow .source (.arrow .number .number))
  | nameAfter : Function (.arrow .source (.arrow .number .number))
  | qualifiedNameAfter : Function (.arrow .source (.arrow .number .number))
  | nameIs : Function (.arrow .source (.arrow .number (.arrow .number (.arrow .spelling .truth))))
  | take : Function (.arrow .source (.arrow .number (.arrow .token .number)))
  | validName : Function (.arrow .source (.arrow .nameSpan .truth))
  | sameName : Function (.arrow .source (.arrow .nameSpan (.arrow .nameSpan .truth)))
  | noName : Function .nameSpan
  | maxSource : Function .number

def functionNames : FunctionNames Function
  | _, .normalize => ["normalized"]
  | _, .skip => ["skip_at"]
  | _, .nameAfter => ["name_after"]
  | _, .qualifiedNameAfter => ["silver_output_profile", ".", "name_after"]
  | _, .nameIs => ["name_is"]
  | _, .take => ["take_token"]
  | _, .validName => ["silver_package_bindings", ".", "valid_name"]
  | _, .sameName => ["silver_package_bindings", ".", "same_name"]
  | _, .noName => ["silver_package_bindings", ".", "no_name"]
  | _, .maxSource => ["max_source_length"]

structure Calls where
  normalize : Source → Source
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  nameIs : Source → Nat → Nat → String → Bool
  take : Source → Nat → ShellToken → Nat
  validName : Source → PackageBindings.NameSpan → Bool
  sameName : Source → PackageBindings.NameSpan → PackageBindings.NameSpan → Bool

def Calls.get (calls : Calls) : ApplicationNative.Calls Function
  | _, .normalize => calls.normalize
  | _, .skip => calls.skip
  | _, .nameAfter | _, .qualifiedNameAfter => calls.nameAfter
  | _, .nameIs => calls.nameIs
  | _, .take => calls.take
  | _, .validName => calls.validName
  | _, .sameName => calls.sameName
  | _, .noName => {}
  | _, .maxSource => Silver.maxSourceLength

abbrev E := Expr Function
abbrev C := Control.Command Function

def call2 (fn : Function (.arrow a (.arrow b c))) (x : E a) (y : E b) : E c :=
  .app (.app (.function fn) x) y
def call3 (fn : Function (.arrow a (.arrow b (.arrow c d)))) (x : E a) (y : E b) (z : E c) : E d :=
  .app (call2 fn x y) z
def call4 (fn : Function (.arrow a (.arrow b (.arrow c (.arrow d e)))))
    (x : E a) (y : E b) (z : E c) (w : E d) : E e := .app (call3 fn x y z) w

def constant (ty : Ty) (name : String) (typeName : List String) (initial : E ty) : Declaration Function :=
  ⟨ty, name, typeName, true, some initial, [], none⟩
def localDeclaration (ty : Ty) (name : String) (typeName : List String) (initial : E ty) : Declaration Function :=
  ⟨ty, name, typeName, false, some initial, [], none⟩

def mainSource : E .source := .variable "main_source"
def text : E .source := .variable "text"
def position : E .number := .variable "position"
def candidate : E .nameSpan := .variable "candidate"
def candidateFirst : E .number := .field .nameFirst candidate
def candidateAfter : E .number := .field .nameAfter candidate
def first : E .number := .variable "first"
def after : E .number := .variable "after"
def withClause : E .truth := .variable "with_clause"
def useClause : E .truth := .variable "use_clause"
def nameFirst : E .number := .variable "name_first"
def nameAfter : E .number := .variable "name_after"
def name : E .nameSpan := .variable "name"
def commaAfter : E .number := .variable "comma_after"
def semicolonAfter : E .number := .variable "semicolon_after"
def empty (value : E .number) : E .truth := .eq value (.number 0)
def present (value : E .number) : E .truth := .ne value (.number 0)
def rejectIf (test : E .truth) : C := .choose test (.returned .emptySource) .nothing
def nameValid : E .truth := call2 .validName text candidate

def entry : List (Declaration Function) := [
  constant .source "text" ["string"] (.app (.function .normalize) mainSource),
  localDeclaration .number "position" ["literal_position"] (.number 1),
  localDeclaration .nameSpan "candidate" ["silver_package_bindings", ".", "name_span"] (.function .noName)]

def clause (word : String) : E .truth := .andThen
  (.andThen (.gt first (.number 0)) (.gt after first)) (call4 .nameIs text first after (.word word))

def outerDeclarations : List (Declaration Function) := [
  constant .number "first" ["literal_position"] (call2 .skip text position),
  constant .number "after" ["literal_position"] (call2 .nameAfter text first),
  constant .truth "with_clause" ["boolean"] (clause "with"),
  constant .truth "use_clause" ["boolean"] (clause "use")]

def innerDeclarations : List (Declaration Function) := [
  constant .number "name_first" ["literal_position"] (call2 .skip text position),
  constant .number "name_after" ["literal_position"] (call2 .qualifiedNameAfter text nameFirst),
  constant .nameSpan "name" ["silver_package_bindings", ".", "name_span"] (.nameSpan nameFirst nameAfter),
  constant .number "comma_after" ["literal_position"] (call3 .take text nameAfter (.token (.symbol ","))),
  constant .number "semicolon_after" ["literal_position"] (call3 .take text nameAfter (.token (.symbol ";")))]

def innerBody : C := .list [
  .invariant (.inRange position after (.add (.sourceLast text) (.number 1))),
  .invariant (.orElse (empty candidateFirst) nameValid),
  .increases position,
  .block innerDeclarations (.list [
    rejectIf (.orElse (.not (call2 .validName text name))
      (.group (.andThen (empty commaAfter) (empty semicolonAfter)))),
    .choose (.andThen (.andThen withClause
      (.not (call4 .nameIs text nameFirst nameAfter (.word "silver_io"))))
      (.not (call4 .nameIs text nameFirst nameAfter (.word "silver_arguments"))))
      (.list [rejectIf (.andThen (present candidateFirst) (.not (call3 .sameName text candidate name))),
        .assign (.variable "candidate") name]) .nothing,
    .choose (present semicolonAfter)
      (.sequence (.assign (.variable "position") semicolonAfter) .exited) .nothing,
    .assign (.variable "position") commaAfter])]

def outerBody : C := .list [
  .invariant (.inRange position (.number 1) (.add (.sourceLast text) (.number 1))),
  .invariant (.orElse (empty candidateFirst) nameValid),
  .increases position,
  .block outerDeclarations (.list [
    .exitWhen (.andThen (.not withClause) (.not useClause)),
    .assign (.variable "position") after,
    .loopBody innerBody])]

def resultDeclarations : List (Declaration Function) := [
  constant .number "result_length" ["natural"] (.sub candidateAfter candidateFirst),
  ⟨.source, "result", ["string"], true,
    some (.sourceSlice text candidateFirst (.sub candidateAfter (.number 1))), [],
    some (.variable "result_length")⟩]

def body : C := .list [
  rejectIf (.orElse (empty (.sourceLength mainSource))
    (.gt (.sourceLength mainSource) (.function .maxSource))),
  .block entry (.list [
    .loopBody outerBody,
    rejectIf (empty candidateFirst),
    .block resultDeclarations (.returned (.variable "result"))])]

def render : List String := ["begin"] ++ body.render functionNames ++ ["end", "imported_package", ";"]

def input (prior : Locals) (source : Source) : Locals := prior.set .source "main_source" source

def execute (calls : Calls) (fuel : Nat) (prior : Locals) (source : Source) : Option Source :=
  body.eval calls.get fuel (input prior source) (fun _ => some []) (fun _ => none)

theorem trees_checked : body.wellFormed functionNames false = true ∧
    body.scoped [(.source, "main_source")] [] = true ∧
    body.namedCorrect (fun _ => []) = true := by decide +kernel

end Silver.ApplicationPackageImport.Native
