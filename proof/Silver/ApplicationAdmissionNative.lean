module

public import Silver.ApplicationNativeGuards
public import Silver.ApplicationAdmissionModel

@[expose] public section

/-! Typed native admission-wrapper control flow. The three procedure calls keep
explicit in/out locations and evaluate every input before writing any output.
Uninitialized declarations preserve arbitrary incoming local values; the wrapper
meaning theorem must hold for all of them. No procedure is rendered as a function
assignment, and unit enumeration retains its exact Ada declaration order. -/
namespace Silver.ApplicationAdmission.Native
open ApplicationNative

inductive Fn : Ty → Type
  | sourcesValid : Fn (.arrow .bundle .truth)
  | allowedSource : Fn (.arrow .source .truth)
  | normalized : Fn (.arrow .source .source)
  | unitSource : Fn (.arrow .bundle (.arrow .unitKind .source))
  | prefix : Fn (.arrow .bundle (.arrow .unitKind .source))
  | stateValid : Fn (.arrow .source (.arrow .state .truth))
  | completeMetadata : Fn (.arrow .source (.arrow .metadata .truth))
  | functionsValid : Fn (.arrow .source (.arrow .functions .truth))
  | proceduresValid : Fn (.arrow .source (.arrow .procedures .truth))
  | packageMain : Fn (.arrow .bundle (.arrow .state (.arrow .metadata .analysis)))
  | analyzeApplication : Fn (.arrow .bundle .analysis)
  | analyzeModel : Fn (.arrow .bundle .analysis)
  | analyze : Fn (.arrow .bundle .analysis)

def functionNames : FunctionNames Fn
  | _, .sourcesValid => ["units", ".", "valid"]
  | _, .allowedSource => ["allowed_source"]
  | _, .normalized => ["normalized"]
  | _, .unitSource => ["units", ".", "unit_source"]
  | _, .prefix => ["units", ".", "prefix"]
  | _, .stateValid => ["valid_state"]
  | _, .completeMetadata => ["packages", ".", "complete_metadata"]
  | _, .functionsValid => ["functions", ".", "valid_metadata"]
  | _, .proceduresValid => ["procedures", ".", "valid_metadata"]
  | _, .packageMain => ["package_main_at"]
  | _, .analyzeApplication => ["analyze_application"]
  | _, .analyzeModel => ["analyze_model"]
  | _, .analyze => ["analyze"]

structure Callees where
  function : ApplicationNative.Calls Fn
  chargeUnit : Source → Nat → ChargeResult
  packageSpecification : Source → PackageBindings.Metadata → SpecificationResult
  packageBody : Source → Compose.ParserState → PackageBindings.Metadata → BodyResult

inductive Location : Ty → Type
  | variable (name : String) : Location ty
  | field : Field owner ty → Location owner → Location ty

def Location.expression : Location ty → Expr Fn ty
  | .variable name => .variable name
  | .field selected owner => .field selected owner.expression

def Location.set (callees : Callees) (locals : Locals) : Location ty → ty.meaning → Locals
  | .variable name, value => locals.set _ name value
  | .field selected owner, value =>
      owner.set callees locals (selected.set (owner.expression.eval callees.function locals) value)

inductive Command
  | nothing
  | assign : Location ty → Expr Fn ty → Command
  | sequence : Command → Command → Command
  | choose : Expr Fn .truth → Command → Command → Command
  | forUnits (name : String) : Command → Command
  | chargeUnit : Expr Fn .source → Location .number → Location .truth → Command
  | packageSpecification : Expr Fn .source → Location .metadata → Location .state → Command
  | packageBody : Expr Fn .source → Expr Fn .state → Location .metadata → Location .truth → Command
  | returned : Expr Fn .analysis → Command

def forKinds (body : Locals → (Locals → AnalysisResult) → AnalysisResult)
    (name : String) (kinds : List ApplicationUnits.UnitKind) (locals : Locals)
    (next : Locals → AnalysisResult) : AnalysisResult :=
  match kinds with
  | [] => next locals
  | kind :: rest => body (locals.set .unitKind name kind)
      (fun updated => forKinds body name rest updated next)

def Command.eval (callees : Callees) (locals : Locals) (next : Locals → AnalysisResult) :
    Command → AnalysisResult
  | .nothing => next locals
  | .assign target value => next (target.set callees locals (value.eval callees.function locals))
  | .sequence first rest => first.eval callees locals (fun updated => rest.eval callees updated next)
  | .choose test yes no =>
      if test.eval callees.function locals then yes.eval callees locals next else no.eval callees locals next
  | .forUnits name body =>
      forKinds (fun current continuation => body.eval callees current continuation) name originalKinds locals
        (fun updated => next (updated.set .unitKind name (locals .unitKind name)))
  | .chargeUnit text remaining accepted =>
      let result := callees.chargeUnit (text.eval callees.function locals)
        (remaining.expression.eval callees.function locals)
      let updated := remaining.set callees locals result.remaining
      next (accepted.set callees updated result.accepted)
  | .packageSpecification text info exports =>
      let result := callees.packageSpecification (text.eval callees.function locals)
        (info.expression.eval callees.function locals)
      let updated := info.set callees locals result.info
      next (exports.set callees updated result.exports)
  | .packageBody text exports info accepted =>
      let result := callees.packageBody (text.eval callees.function locals)
        (exports.eval callees.function locals) (info.expression.eval callees.function locals)
      let updated := info.set callees locals result.info
      next (accepted.set callees updated result.accepted)
  | .returned value => value.eval callees.function locals

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing

mutual
def Command.render : Command → List String
  | .nothing => []
  | .assign target value => target.expression.render functionNames ++ [":="] ++ value.render functionNames ++ [";"]
  | .sequence first rest => first.render ++ rest.render
  | .choose test yes no => ["if"] ++ test.render functionNames ++ ["then"] ++ yes.render ++
      no.renderElse ++ ["end", "if", ";"]
  | .forUnits name body => ["for", name, "in", "units", ".", "unit_kind", "loop"] ++
      body.render ++ ["end", "loop", ";"]
  | .chargeUnit text remaining accepted => ["charge_unit", "("] ++ text.render functionNames ++ [","] ++
      remaining.expression.render functionNames ++ [","] ++ accepted.expression.render functionNames ++ [")", ";"]
  | .packageSpecification text info exports => ["package_spec_at", "("] ++ text.render functionNames ++ [","] ++
      info.expression.render functionNames ++ [","] ++ exports.expression.render functionNames ++ [")", ";"]
  | .packageBody text exports info accepted => ["package_body_at", "("] ++ text.render functionNames ++ [","] ++
      exports.render functionNames ++ [","] ++ info.expression.render functionNames ++ [","] ++
      accepted.expression.render functionNames ++ [")", ";"]
  | .returned value => ["return"] ++ value.render functionNames ++ [";"]
def Command.renderElse : Command → List String
  | .nothing => []
  | .choose test yes no => ["elsif"] ++ test.render functionNames ++ ["then"] ++ yes.render ++ no.renderElse
  | command => ["else"] ++ command.render
end

structure Declaration where
  type : Ty
  name : String
  initial : Option (Expr Fn type) := none

def Declaration.typeName : Ty → List String
  | .number => ["concatenation_count"]
  | .truth => ["boolean"]
  | .state => ["parser_state"]
  | .metadata => ["packages", ".", "metadata"]
  | .analysis => ["analysis_result"]
  | _ => []

def Declaration.render (declaration : Declaration) : List String :=
  [declaration.name, ":"] ++ Declaration.typeName declaration.type ++
    (match declaration.initial with
      | none => []
      | some value => [":="] ++ value.render functionNames) ++ [";"]

def Declaration.eval (callees : Callees) (locals : Locals) (declaration : Declaration) : Locals :=
  match declaration.initial with
  | none => locals
  | some value => locals.set declaration.type declaration.name (value.eval callees.function locals)

structure Body where
  name : String
  declarations : List Declaration
  commands : Command

def Body.render (body : Body) : List String :=
  body.declarations.flatMap Declaration.render ++ ["begin"] ++ body.commands.render ++ ["end", body.name, ";"]

def Body.eval (body : Body) (callees : Callees) (locals : Locals) : AnalysisResult :=
  body.commands.eval callees (body.declarations.foldl (Declaration.eval callees) locals) (fun _ => invalidAnalysis)

def Location.root : Location ty → String
  | .variable name => name
  | .field _ owner => owner.root

def Location.scoped (scope : Scope) (writable : List String) (location : Location ty) : Bool :=
  decide (location.root ∈ writable) && location.expression.scoped scope

def Command.wellFormed : Command → Bool
  | .nothing => true
  | .assign target value => target.expression.wellFormed functionNames &&
      value.expression && value.wellFormed functionNames
  | .sequence first rest => first.wellFormed && rest.wellFormed
  | .choose test yes no => test.logical && test.wellFormed functionNames && yes.wellFormed && no.wellFormed
  | .forUnits name body => identifier name && body.wellFormed
  | .chargeUnit text remaining accepted => text.expression && text.wellFormed functionNames &&
      remaining.expression.wellFormed functionNames && accepted.expression.wellFormed functionNames
  | .packageSpecification text info exports => text.expression && text.wellFormed functionNames &&
      info.expression.wellFormed functionNames && exports.expression.wellFormed functionNames
  | .packageBody text exports info accepted => text.expression && text.wellFormed functionNames &&
      exports.expression && exports.wellFormed functionNames && info.expression.wellFormed functionNames &&
      accepted.expression.wellFormed functionNames
  | .returned value => value.expression && value.wellFormed functionNames

def Command.scoped (scope : Scope) (writable : List String) : Command → Bool
  | .nothing => true
  | .assign target value => target.scoped scope writable && value.scoped scope
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .forUnits name body => body.scoped (scope.bind .unitKind name) (writable.filter (· != name))
  | .chargeUnit text remaining accepted => text.scoped scope && remaining.scoped scope writable &&
      accepted.scoped scope writable
  | .packageSpecification text info exports => text.scoped scope && info.scoped scope writable &&
      exports.scoped scope writable
  | .packageBody text exports info accepted => text.scoped scope && exports.scoped scope &&
      info.scoped scope writable && accepted.scoped scope writable
  | .returned value => value.scoped scope

def Body.wellFormed (body : Body) : Bool :=
  identifier body.name && decide (body.declarations.map Declaration.name).Nodup &&
    body.declarations.all (fun declaration => identifier declaration.name &&
      !(Declaration.typeName declaration.type).isEmpty &&
      declaration.initial.all (fun value => value.expression && value.wellFormed functionNames)) &&
    body.commands.wellFormed

def Body.scoped (scope : Scope) (body : Body) : Bool :=
  let scanned := body.declarations.foldl (fun (result : Bool × Scope × List String) declaration =>
    (result.1 && declaration.initial.all (fun value => value.scoped result.2.1),
      result.2.1.bind declaration.type declaration.name, declaration.name :: result.2.2)) (true, scope, [])
  scanned.1 && body.commands.scoped scanned.2.1 scanned.2.2

end Silver.ApplicationAdmission.Native
