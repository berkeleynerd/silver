module

public import Silver.ApplicationPackageBodiesPrimitives

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statements
open ApplicationNative ApplicationPackages

inductive Command (Fn : Ty → Type)
  | nothing
  | assign : Place Fn ty → Expr Fn ty → Command Fn
  | procedure : Primitive Fn → Command Fn
  | sequence : Command Fn → Command Fn → Command Fn
  | choose : Expr Fn .truth → Command Fn → Command Fn → Command Fn
  | block : List (Declaration Fn) → Command Fn → Command Fn
  | whileLoop : Expr Fn .truth → Command Fn → Command Fn
  | loopBody : Command Fn → Command Fn
  | forFlowValues (name : String) : Expr Fn .activeFlow → Command Fn → Command Fn
  | exitWhen : Expr Fn .truth → Command Fn
  | invariant : Expr Fn .truth → Command Fn
  | increases : Expr Fn .number → Command Fn
  | returned : Expr Fn .appScan → Command Fn

variable {Fn : Ty → Type}

abbrev Continuation := Locals → Option ApplicationScan

def loop (test : Locals → Bool) (body : Locals → Continuation → Continuation → Option ApplicationScan)
    (next : Continuation) : Nat → Continuation
  | 0, _ => none
  | fuel + 1, locals => if test locals then body locals (loop test body next fuel) next else next locals

def flowRange (name : String) (body : Locals → Continuation → Continuation → Option ApplicationScan)
    (next : Continuation) : List Nat → Continuation
  | [], locals => next locals
  | index :: rest, locals => body (locals.set .number name index) (flowRange name body next rest) next

/-- Resize unspecified local vector storage at its actual declaration. Every
native value with the declared bounds is retained verbatim. -/
def allocatedValues (count : Nat) (prior : List Integer.Interval) : List Integer.Interval :=
  prior.take count ++ List.replicate (count - prior.length) .empty

theorem allocatedValues_count (count : Nat) (prior : List Integer.Interval) :
    (allocatedValues count prior).length = count := by simp [allocatedValues]; omega

theorem allocatedValues_same {count : Nat} {prior : List Integer.Interval} (sized : prior.length = count) :
    allocatedValues count prior = prior := by simp [allocatedValues, ← sized]

def allocatedFlow (count : Nat) (prior : Predicate.ActiveFlow) : Predicate.ActiveFlow :=
  {prior with values := allocatedValues count prior.values}

def allocate (ty : Ty) (count : Nat) : ty.meaning → ty.meaning :=
  match ty with
  | .appScan => fun prior => {prior with scan := {prior.scan with facts := allocatedFlow count prior.scan.facts}}
  | .conditionResult => fun prior => {prior with
      whenTrue := allocatedFlow count prior.whenTrue
      whenFalse := allocatedFlow count prior.whenFalse}
  | .activeFlow => allocatedFlow count
  | _ => id

def enter (calls : Calls Fn) (locals : Locals) (declaration : Declaration Fn) : Locals :=
  let shaped := match declaration.initial, declaration.constraint with
    | none, some count => declaration.names.foldl (fun current name =>
        current.set declaration.type name (allocate declaration.type (count.eval calls locals) (locals declaration.type name))) locals
    | _, _ => locals
  declaration.eval calls shaped

def Command.eval (functions : Calls Fn) (procedures : Procedures) (fuel : Nat)
    (locals : Locals) (next leave : Continuation) : Command Fn → Option ApplicationScan
  | .nothing | .invariant _ | .increases _ => next locals
  | .assign target value => next (target.set functions locals (value.eval functions locals))
  | .procedure call => next (call.eval functions procedures locals)
  | .sequence first rest => first.eval functions procedures fuel locals
      (fun updated => rest.eval functions procedures fuel updated next leave) leave
  | .choose test yes no => if test.eval functions locals then yes.eval functions procedures fuel locals next leave
      else no.eval functions procedures fuel locals next leave
  | .block declarations body =>
    let restore := Declarations.restore declarations locals
    body.eval functions procedures fuel (declarations.foldl (enter functions) locals)
      (fun updated => next (restore updated)) (fun updated => leave (restore updated))
  | .whileLoop test body =>
    loop (fun current => test.eval functions current)
      (fun current cont exitLoop => body.eval functions procedures fuel current cont exitLoop) next fuel locals
  | .loopBody body =>
    loop (fun _ => true)
      (fun current cont exitLoop => body.eval functions procedures fuel current cont exitLoop) next fuel locals
  | .forFlowValues name facts body =>
    let values := (List.range (facts.eval functions locals).count).map (· + 1)
    flowRange name (fun current cont exitLoop => body.eval functions procedures fuel current cont exitLoop)
      (fun updated => next (updated.set .number name (locals .number name))) values locals
  | .exitWhen test => if test.eval functions locals then leave locals else next locals
  | .returned value => some (value.eval functions locals)

def Command.list (commands : List (Command Fn)) : Command Fn := commands.foldr .sequence .nothing

mutual
def Command.render (names : FunctionNames Fn) : Command Fn → List String
  | .nothing => []
  | .assign place value => (ApplicationNative.Command.assign (resultType := .appScan) place value).render names
  | .procedure call => call.render names
  | .sequence first rest => first.render names ++ rest.render names
  | .choose test yes no => ["if"] ++ test.render names ++ ["then"] ++ yes.render names ++ no.renderElse names ++ ["end", "if", ";"]
  | .block declarations body => ["declare"] ++ declarations.flatMap (Declaration.render names) ++ ["begin"] ++ body.render names ++ ["end", ";"]
  | .whileLoop test body => ["while"] ++ test.render names ++ ["loop"] ++ body.render names ++ ["end", "loop", ";"]
  | .loopBody body => ["loop"] ++ body.render names ++ ["end", "loop", ";"]
  | .forFlowValues name facts body =>
    ["for", name, "in"] ++ facts.render names ++ [".", "values", "'", "range", "loop"] ++ body.render names ++ ["end", "loop", ";"]
  | .exitWhen test => ["exit", "when"] ++ test.render names ++ [";"]
  | .invariant test => (ApplicationNative.Command.invariant (resultType := .appScan) test).render names
  | .increases value => (ApplicationPackageProcedure.Command.increases value).render names
  | .returned value => (ApplicationNative.Command.returned value).render names

def Command.renderElse (names : FunctionNames Fn) : Command Fn → List String
  | .nothing => []
  | .choose test yes no => ["elsif"] ++ test.render names ++ ["then"] ++ yes.render names ++ no.renderElse names
  | command => ["else"] ++ command.render names
end

def Command.wellFormed (names : FunctionNames Fn) (inLoop : Bool) : Command Fn → Bool
  | .nothing => true
  | .assign target value => (ApplicationNative.Command.assign (resultType := .appScan) target value).wellFormed names
  | .procedure call => call.expressions (fun value => value.expression && value.wellFormed names)
  | .sequence first rest => first.wellFormed names inLoop && rest.wellFormed names inLoop
  | .choose test yes no => test.logical && test.wellFormed names && yes.wellFormed names inLoop && no.wellFormed names inLoop
  | .block declarations body => declarations.all (Declaration.wellFormed names) && body.wellFormed names inLoop
  | .whileLoop test body => test.logical && test.wellFormed names && body.wellFormed names true
  | .loopBody body => body.wellFormed names true
  | .forFlowValues name facts body => identifier name && facts.prefix && facts.wellFormed names && body.wellFormed names true
  | .exitWhen test => inLoop && test.logical && test.wellFormed names
  | .invariant test => inLoop && (ApplicationNative.Command.invariant (resultType := .appScan) test).wellFormed names
  | .increases value => inLoop && value.simple && value.wellFormed names
  | .returned value => (ApplicationNative.Command.returned value).wellFormed names

def Command.scoped (scope : Scope) (writable : List String) : Command Fn → Bool
  | .nothing => true
  | .assign target value => (ApplicationNative.Command.assign (resultType := .appScan) target value).scoped scope writable
  | .procedure call => call.scoped scope writable
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .block declarations body =>
    let scanned := Declarations.scan scope writable declarations
    scanned.1 && body.scoped scanned.2.1 scanned.2.2
  | .whileLoop test body => test.scoped scope && body.scoped scope writable
  | .loopBody body => body.scoped scope writable
  | .forFlowValues name facts body => facts.scoped scope && body.scoped (scope.bind .number name) (writable.filter (· != name))
  | .exitWhen test | .invariant test | .returned test | .increases test => test.scoped scope

def Command.namedCorrect (parameters : FunctionParameters Fn) : Command Fn → Bool
  | .nothing => true
  | .assign target value => target.expression.namedCorrect parameters && value.namedCorrect parameters
  | .procedure call => call.expressions (fun value => value.namedCorrect parameters)
  | .sequence first rest => first.namedCorrect parameters && rest.namedCorrect parameters
  | .choose test yes no => test.namedCorrect parameters && yes.namedCorrect parameters && no.namedCorrect parameters
  | .block declarations body => declarations.all (Declaration.namedCorrect parameters) && body.namedCorrect parameters
  | .whileLoop test body | .forFlowValues _ test body => test.namedCorrect parameters && body.namedCorrect parameters
  | .loopBody body => body.namedCorrect parameters
  | .exitWhen test | .invariant test | .returned test | .increases test => test.namedCorrect parameters

structure Body (Fn : Ty → Type) where
  name : String
  declarations : List (Declaration Fn)
  commands : Command Fn

def Body.eval (body : Body Fn) (functions : Calls Fn) (procedures : Procedures) (fuel : Nat) (locals : Locals) : Option ApplicationScan :=
  body.commands.eval functions procedures fuel (body.declarations.foldl (enter functions) locals) (fun _ => none) (fun _ => none)

def Body.render (names : FunctionNames Fn) (body : Body Fn) : List String :=
  body.declarations.flatMap (Declaration.render names) ++ ["begin"] ++ body.commands.render names ++ ["end", body.name, ";"]

def Body.checked (body : Body Fn) (names : FunctionNames Fn) (parameters : FunctionParameters Fn) (scope : Scope) : Bool :=
  let scanned := Declarations.scan scope [] body.declarations
  identifier body.name && body.declarations.all (Declaration.wellFormed names) && body.commands.wellFormed names false &&
    scanned.1 && body.commands.scoped scanned.2.1 scanned.2.2 &&
    body.declarations.all (Declaration.namedCorrect parameters) && body.commands.namedCorrect parameters

end Silver.ApplicationPackageBodies.Statements
