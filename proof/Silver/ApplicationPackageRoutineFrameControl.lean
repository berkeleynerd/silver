module

public import Silver.ApplicationPackageProcedureControl
public import Silver.ApplicationNativeLoopFacts

@[expose] public section

/-! Returning control for Routine_Frame. Ordinary commands retain their existing
typed semantics; the one procedure call uses the checked in/out primitive. The
wrapper adds only composition, conditional and range contexts needed to combine
those commands. Early function returns bypass all remaining continuations. -/
namespace Silver.ApplicationPackageRoutineFrame.Control
open ApplicationNative

inductive Command (Fn : Ty → Type)
  | native : ApplicationNative.Command Fn .state → Command Fn
  | primitive : ApplicationPackageProcedure.Primitive Fn → Command Fn
  | namedMark : Place Fn .packageType → Expr Fn .nameSpan → Expr Fn .number →
      Expr Fn .scalarKind → Expr Fn .interval → Expr Fn .number → Command Fn
  | sequence : Command Fn → Command Fn → Command Fn
  | choose : Expr Fn .truth → Command Fn → Command Fn → Command Fn
  | forRange : String → Expr Fn .number → Expr Fn .number → Command Fn → Command Fn

variable {Fn : Ty → Type}

abbrev Command.nothing : Command Fn := .native .nothing
abbrev Command.assign (place : Place Fn ty) (value : Expr Fn ty) : Command Fn := .native (.assign place value)
abbrev Command.returned (value : Expr Fn .state) : Command Fn := .native (.returned value)
def Command.list (commands : List (Command Fn)) : Command Fn := commands.foldr .sequence .nothing

def Command.eval (functions : Calls Fn) (procedures : ApplicationPackageProcedure.ProcedureCalls)
    (locals : Locals) (next : Locals → Compose.ParserState) : Command Fn → Compose.ParserState
  | .native command => ApplicationNative.Command.eval (resultType := .state) functions locals next command
  | .primitive call => next (call.eval functions procedures locals)
  | .namedMark place name after kind bounds identity =>
      next (place.set functions locals ((Expr.packageType name after kind bounds identity).eval functions locals))
  | .sequence first rest => first.eval functions procedures locals
      (fun updated => rest.eval functions procedures updated next)
  | .choose test yes no => if test.eval functions locals then yes.eval functions procedures locals next
      else no.eval functions procedures locals next
  | .forRange name first last body =>
      let low := first.eval functions locals
      let values := (List.range (last.eval functions locals + 1 - low)).map (low + ·)
      forValues (resultType := .state)
        (fun current continuation => body.eval functions procedures current continuation) name values locals
        (fun updated => next (updated.set .number name (locals .number name)))

mutual
def Command.render (names : FunctionNames Fn) : Command Fn → List String
  | .native command => command.render names
  | .primitive call => call.render names
  | .namedMark place name after kind bounds identity =>
      place.expression.render names ++ [":=", "(", "name", "=>"] ++ name.render names ++
        [",", "after", "=>"] ++ after.render names ++ [",", "kind", "=>"] ++ kind.render names ++
        [",", "bounds", "=>"] ++ bounds.render names ++ [",", "identity", "=>"] ++ identity.render names ++ [")", ";"]
  | .sequence first rest => first.render names ++ rest.render names
  | .choose test yes no => ["if"] ++ test.render names ++ ["then"] ++ yes.render names ++
      no.renderElse names ++ ["end", "if", ";"]
  | .forRange name first last body => ["for", name, "in"] ++ first.render names ++ [".."] ++
      last.render names ++ ["loop"] ++ body.render names ++ ["end", "loop", ";"]
def Command.renderElse (names : FunctionNames Fn) : Command Fn → List String
  | .native .nothing => []
  | .choose test yes no => ["elsif"] ++ test.render names ++ ["then"] ++ yes.render names ++ no.renderElse names
  | command => ["else"] ++ command.render names
end

def Command.wellFormed (names : FunctionNames Fn) : Command Fn → Bool
  | .native command => command.wellFormed names
  | .primitive call => call.wellFormed names
  | .namedMark place name after kind bounds identity =>
      (ApplicationNative.Command.assign place (.packageType name after kind bounds identity)
        : ApplicationNative.Command Fn .state).wellFormed names
  | .sequence first rest => first.wellFormed names && rest.wellFormed names
  | .choose test yes no => test.logical && test.wellFormed names && yes.wellFormed names && no.wellFormed names
  | .forRange name first last body => identifier name && first.simple && last.simple &&
      first.wellFormed names && last.wellFormed names && body.wellFormed names

def Command.scoped (scope : Scope) (writable : List String) : Command Fn → Bool
  | .native command => command.scoped scope writable
  | .primitive call => call.scoped scope writable
  | .namedMark place name after kind bounds identity =>
      (ApplicationNative.Command.assign place (.packageType name after kind bounds identity)
        : ApplicationNative.Command Fn .state).scoped scope writable
  | .sequence first rest => first.scoped scope writable && rest.scoped scope writable
  | .choose test yes no => test.scoped scope && yes.scoped scope writable && no.scoped scope writable
  | .forRange name first last body => first.scoped scope && last.scoped scope &&
      body.scoped (scope.bind .number name) (writable.filter (· != name))

structure Body (Fn : Ty → Type) where
  name : String
  declarations : List (Declaration Fn)
  commands : Command Fn

def Body.render (names : FunctionNames Fn) (body : Body Fn) : List String :=
  body.declarations.flatMap (Declaration.render names) ++ ["begin"] ++
    body.commands.render names ++ ["end", body.name, ";"]

def Body.eval (body : Body Fn) (functions : Calls Fn)
    (procedures : ApplicationPackageProcedure.ProcedureCalls) (locals : Locals) : Compose.ParserState :=
  body.commands.eval functions procedures (body.declarations.foldl (Declaration.eval functions) locals)
    (fun _ => Compose.invalidState)

def Body.wellFormed (names : FunctionNames Fn) (body : Body Fn) : Bool :=
  identifier body.name && body.declarations.all (Declaration.wellFormed names) &&
    decide (body.declarations.flatMap Declaration.names).Nodup && body.commands.wellFormed names

def Body.scoped (scope : Scope) (writable : List String) (body : Body Fn) : Bool :=
  let inside := Declarations.scan scope writable body.declarations
  inside.1 && body.commands.scoped inside.2.1 inside.2.2

end Silver.ApplicationPackageRoutineFrame.Control
