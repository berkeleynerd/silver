module

public import Silver.ApplicationNativeGuards
public import Silver.ApplicationPackageMainModel

@[expose] public section

/-! Typed ordinary-function syntax for Package_Main_At. Native uninitialized
locals range over arbitrary values, and nested declarations have ordinary lexical
scope. Every callable symbol has a fixed type and source spelling. -/
namespace Silver.ApplicationPackageMain.Native
open ApplicationNative

inductive Fn : Ty → Type
  | unitSource : Fn (.arrow .bundle (.arrow .unitKind .source))
  | importedPackage : Fn (.arrow .source .source)
  | samePackageSpelling : Fn (.arrow .source (.arrow .metadata (.arrow .source .truth)))
  | readContext : Fn (.arrow .source (.arrow .number (.arrow .number (.arrow .number .contextClauses))))
  | takeToken : Fn (.arrow .source (.arrow .number (.arrow .token .number)))
  | sparkPragmaAfter : Fn (.arrow .source (.arrow .number .number))
  | importedFrame : Fn (.arrow .source (.arrow .state (.arrow .metadata (.arrow .number .state))))
  | argumentAt : Fn (.arrow .source (.arrow .state .state))
  | readDeclarations : Fn (.arrow .source (.arrow .state (.arrow .truth .state)))
  | contextOf : Fn (.arrow .scanResult .parseContext)
  | bodyOf : Fn (.arrow .scanResult .bodyScan)
  | applicationOf : Fn (.arrow .bodyScan .appScan)
  | applicationTail : Fn (.arrow .source (.arrow .parseContext (.arrow .appScan
      (.arrow .metadata (.arrow .bodyStop (.arrow .truth (.arrow .functions (.arrow .procedures .appScan))))))))
  | skipAt : Fn (.arrow .source (.arrow .number .number))
  | completed : Fn (.arrow .path .truth)

def functionNames : FunctionNames Fn
  | _, .unitSource => ["units", ".", "unit_source"]
  | _, .importedPackage => ["imported_package"]
  | _, .samePackageSpelling => ["same_package_spelling"]
  | _, .readContext => ["names", ".", "read_context"]
  | _, .takeToken => ["take_token"]
  | _, .sparkPragmaAfter => ["spark_pragma_after"]
  | _, .importedFrame => ["imported_frame"]
  | _, .argumentAt => ["argument_at"]
  | _, .readDeclarations => ["read_declarations"]
  | _, .contextOf => ["context_of"]
  | _, .bodyOf => ["body_of"]
  | _, .applicationOf => ["application_of"]
  | _, .applicationTail => ["application_tail"]
  | _, .skipAt => ["skip_at"]
  | _, .completed => ["paths", ".", "completed"]

def modelFunctions (calls : ApplicationPackageMain.Calls) : ApplicationNative.Calls Fn
  | _, .unitSource => ApplicationUnits.Bundle.unitSource
  | _, .importedPackage => calls.importedPackage
  | _, .samePackageSpelling => calls.samePackageSpelling
  | _, .readContext => calls.readContext
  | _, .takeToken => calls.takeToken
  | _, .sparkPragmaAfter => calls.sparkPragmaAfter
  | _, .importedFrame => calls.importedFrame
  | _, .argumentAt => calls.argumentAt
  | _, .readDeclarations => calls.readDeclarations
  | _, .contextOf => calls.contextOf
  | _, .bodyOf => calls.bodyOf
  | _, .applicationOf => ApplicationPackages.applicationOf
  | _, .applicationTail => calls.applicationTail
  | _, .skipAt => calls.skipAt
  | _, .completed => calls.completed

inductive LocalType
  | string | contextClauses | parserState | position | bodyContext | applicationScan

def LocalType.type : LocalType → Ty
  | .string => .source | .contextClauses => .contextClauses | .parserState => .state
  | .position => .number | .bodyContext => .parseContext | .applicationScan => .appScan

def LocalType.spelling : LocalType → List String
  | .string => ["string"] | .contextClauses => ["names", ".", "context_result"]
  | .parserState => ["parser_state"] | .position => ["literal_position"]
  | .bodyContext => ["body_context"] | .applicationScan => ["application_scan"]

structure Declaration where
  localType : LocalType
  names : List String
  constant : Bool := false
  initial : Option (Expr Fn localType.type) := none

def Declaration.render (declaration : Declaration) : List String :=
  (declaration.names.map fun name => [name]).intersperse [","] |>.flatten |>
    fun names => names ++ [":"] ++ (if declaration.constant then ["constant"] else []) ++
      declaration.localType.spelling ++
      (match declaration.initial with | none => [] | some value => [":="] ++ value.render functionNames) ++ [";"]

def Declaration.eval (calls : ApplicationNative.Calls Fn) (locals : Locals) (declaration : Declaration) : Locals :=
  match declaration.initial with
  | none => locals
  | some value => declaration.names.foldl
      (fun current name => current.set declaration.localType.type name (value.eval calls locals)) locals

def Declaration.bind (scope : Scope) (declaration : Declaration) : Scope :=
  declaration.names.foldl (fun current name => current.bind declaration.localType.type name) scope

def Declaration.writable (names : List String) (declaration : Declaration) : List String :=
  let retained := names.filter (fun name => !(declaration.names.contains name))
  if declaration.constant then retained else declaration.names ++ retained

def Declaration.restore (outer inner : Locals) (declaration : Declaration) : Locals :=
  declaration.names.foldl (fun current name =>
    current.set declaration.localType.type name (outer declaration.localType.type name)) inner

inductive Location : Ty → Type
  | variable (name : String) : Location ty
  | field : Field owner ty → Location owner → Location ty

def Location.expression : Location ty → Expr Fn ty
  | .variable name => .variable name
  | .field selected owner => .field selected owner.expression

def Location.set (calls : ApplicationNative.Calls Fn) (locals : Locals) : Location ty → ty.meaning → Locals
  | .variable name, value => locals.set _ name value
  | .field selected owner, value =>
      owner.set calls locals (selected.set (owner.expression.eval calls locals) value)

def Location.root : Location ty → String
  | .variable name => name
  | .field _ owner => owner.root

inductive Command
  | nothing
  | assign : Location ty → Expr Fn ty → Command
  | sequence : Command → Command → Command
  | choose : Expr Fn .truth → Command → Command → Command
  | block : List Declaration → Command → Command
  | returned : Expr Fn .analysis → Command

def Command.eval (calls : ApplicationNative.Calls Fn) (locals : Locals)
    (next : Locals → ApplicationAdmission.AnalysisResult) : Command → ApplicationAdmission.AnalysisResult
  | .nothing => next locals
  | .assign target value => next (target.set calls locals (value.eval calls locals))
  | .sequence first rest => first.eval calls locals (fun updated => rest.eval calls updated next)
  | .choose test yes no => if test.eval calls locals then yes.eval calls locals next else no.eval calls locals next
  | .block declarations body =>
      body.eval calls (declarations.foldl (Declaration.eval calls) locals)
        (fun updated => next (declarations.foldl (Declaration.restore locals) updated))
  | .returned value => value.eval calls locals

mutual
def Command.render : Command → List String
  | .nothing => []
  | .assign target value => target.expression.render functionNames ++ [":="] ++ value.render functionNames ++ [";"]
  | .sequence first rest => first.render ++ rest.render
  | .choose test yes no => ["if"] ++ test.render functionNames ++ ["then"] ++
      yes.render ++ no.renderElse ++ ["end", "if", ";"]
  | .block declarations body => ["declare"] ++ declarations.flatMap Declaration.render ++
      ["begin"] ++ body.render ++ ["end", ";"]
  | .returned value => ["return"] ++ value.render functionNames ++ [";"]
def Command.renderElse : Command → List String
  | .nothing => []
  | .choose test yes no => ["elsif"] ++ test.render functionNames ++ ["then"] ++ yes.render ++ no.renderElse
  | command => ["else"] ++ command.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing

def Declaration.wellFormed (declaration : Declaration) : Bool :=
  !declaration.names.isEmpty && declaration.names.all identifier && decide declaration.names.Nodup &&
    (!declaration.constant || declaration.initial.isSome) &&
    declaration.initial.all (fun value => value.expression && value.wellFormed functionNames)

def Command.wellFormed : Command → Bool
  | .nothing => true
  | .assign target value => target.expression.wellFormed functionNames && value.expression &&
      value.wellFormed functionNames
  | .sequence first rest => first.wellFormed && rest.wellFormed
  | .choose test yes no => test.logical && test.wellFormed functionNames && yes.wellFormed && no.wellFormed
  | .block declarations body => declarations.all Declaration.wellFormed &&
      decide (declarations.flatMap Declaration.names).Nodup && body.wellFormed
  | .returned value => value.expression && value.wellFormed functionNames

def declarationsScope (scope : Scope) (writable : List String) (declarations : List Declaration) :
    Bool × Scope × List String :=
  declarations.foldl (fun (current : Bool × Scope × List String) declaration =>
    (current.1 && declaration.initial.all (fun value => value.scoped current.2.1),
      declaration.bind current.2.1, declaration.writable current.2.2)) (true, scope, writable)

def Command.scoped (scope : Scope) (writable : List String) : Command → Bool
  | .nothing => true
  | .assign target value => decide (target.root ∈ writable) && target.expression.scoped scope && value.scoped scope
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .block declarations body =>
      let inside := declarationsScope scope writable declarations
      inside.1 && body.scoped inside.2.1 inside.2.2
  | .returned value => value.scoped scope

structure Body where
  name : String
  declarations : List Declaration
  commands : Command

def Body.render (body : Body) : List String :=
  body.declarations.flatMap Declaration.render ++ ["begin"] ++ body.commands.render ++ ["end", body.name, ";"]

def Body.eval (body : Body) (calls : ApplicationNative.Calls Fn) (locals : Locals) : ApplicationAdmission.AnalysisResult :=
  body.commands.eval calls (body.declarations.foldl (Declaration.eval calls) locals)
    (fun _ => ApplicationAdmission.invalidAnalysis)

def Body.wellFormed (body : Body) : Bool :=
  identifier body.name && body.declarations.all Declaration.wellFormed &&
    decide (body.declarations.flatMap Declaration.names).Nodup && body.commands.wellFormed

def Body.scoped (scope : Scope) (body : Body) : Bool :=
  let scanned := declarationsScope scope [] body.declarations
  scanned.1 && body.commands.scoped scanned.2.1 scanned.2.2

end Silver.ApplicationPackageMain.Native
